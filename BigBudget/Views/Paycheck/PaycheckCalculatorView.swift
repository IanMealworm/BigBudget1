import SwiftUI

struct PaycheckCalculatorView: View {
    @StateObject private var paycheckManager = PaycheckManager()
    @State private var selectedUser: PaycheckUser?
    @State private var hoursWorked: Double = 0
    @State private var hoursString = ""
    @State private var lunchDays: Int = 0
    @State private var taxFreeBonus: Double = 0
    @State private var bonusString = ""
    @State private var showingTaxBreakdown = false
    @State private var calculation: PaycheckCalculation?
    @State private var focusedField: Field?
    
    enum Field {
        case hours
        case bonus
    }
    
    var body: some View {
        NavigationStack {
            List {
                // User Management Section
                Section {
                    UserManagementView(
                        paycheckManager: paycheckManager,
                        selectedUser: $selectedUser
                    )
                } header: {
                    Text("User Profile")
                }
                
                if let user = selectedUser {
                    PaycheckInputSection(
                        user: user,
                        hoursString: $hoursString,
                        hoursWorked: $hoursWorked,
                        lunchDays: $lunchDays,
                        bonusString: $bonusString,
                        taxFreeBonus: $taxFreeBonus,
                        calculation: $calculation,
                        focusedField: $focusedField
                    )
                    
                    if let calc = calculation {
                        PaycheckResultsSection(
                            calculation: calc,
                            taxFreeBonus: taxFreeBonus,
                            showingTaxBreakdown: $showingTaxBreakdown
                        )
                    }
                } else {
                    EmptyUserSection()
                }
            }
            .navigationTitle("Paycheck Calculator")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .onTapGesture {
                focusedField = nil
            }
        }
    }
}

#Preview {
    PaycheckCalculatorView()
} 