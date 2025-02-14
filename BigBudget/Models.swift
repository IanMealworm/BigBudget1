import Foundation

enum PaySchedule: String, CaseIterable, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
}

enum RecurringType: String, Codable, CaseIterable {
    case none = "One-time"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
}

struct UserProfile: Codable {
    var paySchedule: PaySchedule
    var hourlyRate: Double
    var birthday: Date
}

struct Expense: Identifiable, Codable {
    var id = UUID()
    var name: String
    var dueDate: Date
    var amount: Double
    var recurringType: RecurringType
    var isRecurring: Bool { recurringType != .none }
    var isPaid: Bool
    var paidDate: Date?
    
    init(id: UUID = UUID(), name: String, dueDate: Date, amount: Double, recurringType: RecurringType = .none, isPaid: Bool = false, paidDate: Date? = nil) {
        self.id = id
        self.name = name
        self.dueDate = dueDate
        self.amount = amount
        self.recurringType = recurringType
        self.isPaid = isPaid
        self.paidDate = paidDate
    }
}

struct Deposit: Identifiable, Codable {
    var id = UUID()
    var name: String
    var amount: Double
    var date: Date
}

struct DataStore: Codable {
    let userProfile: UserProfile?
    let expenses: [Expense]
    let deposits: [Deposit]
}

@MainActor
class BudgetManager: ObservableObject {
    @Published var userProfile: UserProfile? = nil {
        didSet { saveData() }
    }
    @Published var expenses: [Expense] = [] {
        didSet { saveData() }
    }
    @Published var deposits: [Deposit] = [] {
        didSet { saveData() }
    }
    @Published var hasCompletedOnboarding: Bool = false
    
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 1
        return calendar
    }
    
    init() {
        loadData()
    }
    
    func addExpense(_ expense: Expense) {
        if expense.isRecurring {
            // Add the original expense
            expenses.append(expense)
            
            // Generate future recurring instances
            let futureExpenses = generateRecurringExpenses(from: expense)
            expenses.append(contentsOf: futureExpenses)
        } else {
            expenses.append(expense)
        }
    }
    
    func deleteExpense(_ expense: Expense) {
        if expense.isRecurring {
            // Delete all instances of recurring expense with same name and amount
            expenses.removeAll { 
                $0.name == expense.name && 
                $0.amount == expense.amount &&
                $0.recurringType == expense.recurringType
            }
        } else {
            expenses.removeAll { $0.id == expense.id }
        }
    }
    
    func updateExpense(_ updatedExpense: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == updatedExpense.id }) {
            let oldExpense = expenses[index]
            
            if oldExpense.isRecurring {
                // Remove all old recurring instances
                deleteExpense(oldExpense)
            }
            
            // Add the updated expense and its recurring instances if any
            addExpense(updatedExpense)
        }
    }
    
    private func generateRecurringExpenses(from expense: Expense) -> [Expense] {
        var futureExpenses: [Expense] = []
        let calendar = Calendar.current
        
        // Generate instances for the next year
        let endDate = calendar.date(byAdding: .year, value: 1, to: expense.dueDate)!
        var currentDate = calendar.date(byAdding: expense.recurringType.dateComponent, value: 1, to: expense.dueDate) ?? expense.dueDate
        
        while currentDate <= endDate {
            let newExpense = Expense(
                id: UUID(), // New unique ID for each instance
                name: expense.name,
                dueDate: currentDate,
                amount: expense.amount,
                recurringType: expense.recurringType
            )
            futureExpenses.append(newExpense)
            
            // Move to next occurrence
            if let nextDate = calendar.date(byAdding: expense.recurringType.dateComponent, value: 1, to: currentDate) {
                currentDate = nextDate
            } else {
                break
            }
        }
        
        return futureExpenses
    }
    
    func deleteDeposit(_ deposit: Deposit) {
        deposits.removeAll { $0.id == deposit.id }
    }
    
    private func saveData() {
        do {
            // Only save non-recurring expenses to avoid duplicates
            let nonRecurringExpenses = expenses.filter { !$0.isRecurring }
            let recurringBaseExpenses = expenses.filter { $0.isRecurring }.reduce(into: [String: Expense]()) { dict, expense in
                // Keep only the earliest instance of each recurring expense
                if let existing = dict[expense.name] {
                    if expense.dueDate < existing.dueDate {
                        dict[expense.name] = expense
                    }
                } else {
                    dict[expense.name] = expense
                }
            }.values
            
            let dataStore = DataStore(
                userProfile: userProfile,
                expenses: Array(nonRecurringExpenses) + Array(recurringBaseExpenses),
                deposits: deposits
            )
            
            let data = try JSONEncoder().encode(dataStore)
            try data.write(to: getDataFile())
        } catch {
            print("Error saving data: \(error)")
        }
    }
    
    private func loadData() {
        do {
            let data = try Data(contentsOf: getDataFile())
            let dataStore = try JSONDecoder().decode(DataStore.self, from: data)
            userProfile = dataStore.userProfile
            deposits = dataStore.deposits
            
            // Load base expenses
            expenses = dataStore.expenses
            
            // Generate recurring instances
            let recurringExpenses = expenses.filter { $0.isRecurring }
            for expense in recurringExpenses {
                let futureExpenses = generateRecurringExpenses(from: expense)
                expenses.append(contentsOf: futureExpenses)
            }
        } catch {
            print("Error loading data: \(error)")
            userProfile = nil
            expenses = []
            deposits = []
        }
    }
    
    private func getDataFile() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent("budgetData.json")
    }
}

extension RecurringType {
    var dateComponent: Calendar.Component {
        switch self {
        case .none:
            return .day // Won't be used
        case .weekly:
            return .weekOfYear
        case .monthly:
            return .month
        case .yearly:
            return .year
        }
    }
} 