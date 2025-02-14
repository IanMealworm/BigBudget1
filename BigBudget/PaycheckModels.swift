import Foundation

enum PaycheckSchedule: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case biweekly = "Bi-Weekly"
    case monthly = "Monthly"
    
    var standardHours: Double {
        switch self {
        case .daily: return 8
        case .weekly: return 40
        case .biweekly: return 80
        case .monthly: return 160
        }
    }
    
    var maxLunchDays: Int {
        switch self {
        case .daily: return 1
        case .weekly: return 5
        case .biweekly: return 10
        case .monthly: return 20
        }
    }
}

struct TaxRates: Codable, Hashable {
    var federalIncomeTax: Double
    var socialSecurity: Double
    var medicare: Double
    var stateIncomeTax: Double
    
    var totalTaxRate: Double {
        federalIncomeTax + socialSecurity + medicare + stateIncomeTax
    }
}

struct PaycheckUser: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let birthDate: Date
    let hourlyRate: Double
    let lunchDuration: TimeInterval // in minutes
    let paySchedule: PaycheckSchedule
    let taxRates: TaxRates
    
    // Sample check information used to calculate tax rates
    let sampleGrossPay: Double
    let sampleNetPay: Double
    let sampleFederalTax: Double
    let sampleSocialSecurity: Double
    let sampleMedicare: Double
    let sampleStateTax: Double
    
    init(name: String, birthDate: Date, hourlyRate: Double, lunchDuration: TimeInterval, paySchedule: PaycheckSchedule, taxRates: TaxRates,
         sampleGrossPay: Double, sampleNetPay: Double, sampleFederalTax: Double, sampleSocialSecurity: Double,
         sampleMedicare: Double, sampleStateTax: Double) {
        self.id = UUID()
        self.name = name
        self.birthDate = birthDate
        self.hourlyRate = hourlyRate
        self.lunchDuration = lunchDuration
        self.paySchedule = paySchedule
        self.taxRates = taxRates
        self.sampleGrossPay = sampleGrossPay
        self.sampleNetPay = sampleNetPay
        self.sampleFederalTax = sampleFederalTax
        self.sampleSocialSecurity = sampleSocialSecurity
        self.sampleMedicare = sampleMedicare
        self.sampleStateTax = sampleStateTax
    }
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PaycheckUser, rhs: PaycheckUser) -> Bool {
        lhs.id == rhs.id
    }
}

struct PaycheckCalculation {
    let hoursWorked: Double
    let lunchDays: Int
    let taxFreeBonus: Double
    let user: PaycheckUser
    
    var grossPay: Double {
        let lunchHours = (Double(lunchDays) * user.lunchDuration) / 3600
        return (hoursWorked - lunchHours) * user.hourlyRate
    }
    
    var federalTax: Double {
        grossPay * user.taxRates.federalIncomeTax
    }
    
    var socialSecurity: Double {
        grossPay * user.taxRates.socialSecurity
    }
    
    var medicare: Double {
        grossPay * user.taxRates.medicare
    }
    
    var stateTax: Double {
        grossPay * user.taxRates.stateIncomeTax
    }
    
    var totalTax: Double {
        federalTax + socialSecurity + medicare + stateTax
    }
    
    var netPay: Double {
        grossPay - totalTax + taxFreeBonus
    }
}

extension Double {
    func rounded(to places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return (self * multiplier).rounded() / multiplier
    }
}

class PaycheckManager: ObservableObject {
    @Published var users: [PaycheckUser] = [] {
        didSet {
            saveUsers()
        }
    }
    
    init() {
        loadUsers()
    }
    
    func addUser(_ user: PaycheckUser) {
        users.append(user)
    }
    
    func updateUser(_ user: PaycheckUser) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
        }
    }
    
    func deleteUser(_ user: PaycheckUser) {
        users.removeAll { $0.id == user.id }
    }
    
    func calculateTaxRates(grossPay: Double, netPay: Double, federalTax: Double, socialSecurity: Double, medicare: Double, stateTax: Double) -> TaxRates {
        // Prevent division by zero and negative rates
        guard grossPay > 0 else {
            return TaxRates(
                federalIncomeTax: 0.0789,  // 7.89% Federal
                socialSecurity: 0.062,      // 6.2% Social Security
                medicare: 0.0145,           // 1.45% Medicare
                stateIncomeTax: 0.0409      // 4.09% State
            )
        }
        
        // Calculate exact rates from the sample check, ensuring positive values
        let fedRate = max((federalTax / grossPay).rounded(to: 4), 0)
        let ssRate = max((socialSecurity / grossPay).rounded(to: 4), 0)
        let medRate = max((medicare / grossPay).rounded(to: 4), 0)
        let stateRate = max((stateTax / grossPay).rounded(to: 4), 0)
        
        // Validate total tax rate doesn't exceed gross pay
        let totalRate = fedRate + ssRate + medRate + stateRate
        if totalRate > 1.0 {
            let scaleFactor = 1.0 / totalRate
            return TaxRates(
                federalIncomeTax: (fedRate * scaleFactor).rounded(to: 4),
                socialSecurity: (ssRate * scaleFactor).rounded(to: 4),
                medicare: (medRate * scaleFactor).rounded(to: 4),
                stateIncomeTax: (stateRate * scaleFactor).rounded(to: 4)
            )
        }
        
        return TaxRates(
            federalIncomeTax: fedRate,
            socialSecurity: ssRate,
            medicare: medRate,
            stateIncomeTax: stateRate
        )
    }
    
    private func saveUsers() {
        do {
            // Print debug info before saving
            for user in users {
                print("\nSaving tax rates for \(user.name):")
                print("Federal: \(user.taxRates.federalIncomeTax * 100)%")
                print("Social Security: \(user.taxRates.socialSecurity * 100)%")
                print("Medicare: \(user.taxRates.medicare * 100)%")
                print("State: \(user.taxRates.stateIncomeTax * 100)%")
            }
            
            let data = try JSONEncoder().encode(users)
            try data.write(to: getUsersFile())
        } catch {
            print("Error saving users: \(error)")
        }
    }
    
    private func loadUsers() {
        do {
            let data = try Data(contentsOf: getUsersFile())
            users = try JSONDecoder().decode([PaycheckUser].self, from: data)
            
            // Print debug info after loading
            for user in users {
                print("\nLoaded tax rates for \(user.name):")
                print("Federal: \(user.taxRates.federalIncomeTax * 100)%")
                print("Social Security: \(user.taxRates.socialSecurity * 100)%")
                print("Medicare: \(user.taxRates.medicare * 100)%")
                print("State: \(user.taxRates.stateIncomeTax * 100)%")
            }
        } catch {
            print("Error loading users: \(error)")
            users = []
        }
    }
    
    private func getUsersFile() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent("paycheckUsers.json")
    }
} 