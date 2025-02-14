import SwiftUI

struct AddExpenseView: View {
    @ObservedObject var budgetManager: BudgetManager
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var amount = 0.0
    @State private var dueDate = Date()
    @State private var recurringType: RecurringType = .none
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name
        case amount
    }
    
    var body: some View {
        ZStack {
            // Background tap gesture
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    focusedField = nil
                }
            
            Form {
                TextField("Expense Name", text: $name)
                    .focused($focusedField, equals: .name)
                
                HStack {
                    Text("$")
                    TextField("Amount", value: $amount, format: .number)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .amount)
                }
                
                DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                
                Picker("Recurring", selection: $recurringType) {
                    ForEach(RecurringType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                
                Button("Save Expense") {
                    focusedField = nil
                    let expense = Expense(
                        name: name,
                        dueDate: dueDate,
                        amount: amount,
                        recurringType: recurringType
                    )
                    budgetManager.addExpense(expense)
                    dismiss()
                }
                .disabled(name.isEmpty || amount == 0)
            }
            .navigationTitle("Add Expense")
        }
    }
}

struct EditExpenseView: View {
    @ObservedObject var budgetManager: BudgetManager
    @Environment(\.dismiss) var dismiss
    let expense: Expense
    
    @State private var name: String
    @State private var amount: Double
    @State private var dueDate: Date
    @State private var recurringType: RecurringType
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name
        case amount
    }
    
    init(expense: Expense, budgetManager: BudgetManager) {
        self.expense = expense
        self.budgetManager = budgetManager
        _name = State(initialValue: expense.name)
        _amount = State(initialValue: expense.amount)
        _dueDate = State(initialValue: expense.dueDate)
        _recurringType = State(initialValue: expense.recurringType)
    }
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    focusedField = nil
                }
            
            Form {
                TextField("Expense Name", text: $name)
                    .focused($focusedField, equals: .name)
                
                HStack {
                    Text("$")
                    TextField("Amount", value: $amount, format: .number)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .amount)
                }
                
                DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                
                Picker("Recurring", selection: $recurringType) {
                    ForEach(RecurringType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                
                Button("Update Expense") {
                    focusedField = nil
                    let updatedExpense = Expense(
                        id: expense.id,
                        name: name,
                        dueDate: dueDate,
                        amount: amount,
                        recurringType: recurringType
                    )
                    budgetManager.updateExpense(updatedExpense)
                    dismiss()
                }
                .disabled(name.isEmpty || amount == 0)
            }
            .navigationTitle("Edit Expense")
        }
    }
}

struct AddDepositView: View {
    @ObservedObject var budgetManager: BudgetManager
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var amount = 0.0
    @State private var date = Date()
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name
        case amount
    }
    
    var body: some View {
        ZStack {
            // Background tap gesture
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    focusedField = nil
                }
            
            Form {
                TextField("Deposit Name", text: $name)
                    .focused($focusedField, equals: .name)
                
                HStack {
                    Text("$")
                    TextField("Amount", value: $amount, format: .number)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .amount)
                }
                
                DatePicker("Date", selection: $date, displayedComponents: .date)
                
                Button("Save Deposit") {
                    focusedField = nil
                    let deposit = Deposit(name: name, amount: amount, date: date)
                    budgetManager.deposits.append(deposit)
                    dismiss()
                }
                .disabled(name.isEmpty || amount == 0)
            }
            .navigationTitle("Add Deposit")
        }
    }
}

#Preview {
    NavigationView {
        AddExpenseView(budgetManager: BudgetManager())
    }
} 