import SwiftUI

struct PaycheckView: View {
    @StateObject private var paycheckManager = PaycheckManager()
    @State private var selectedUser: PaycheckUser?
    @State private var hoursWorked: Double = 0
    @State private var hoursString = ""
    @State private var lunchDays: Int = 0
    @State private var taxFreeBonus: Double = 0
    @State private var bonusString = ""
    @State private var showingTaxBreakdown = false
    @State private var calculation: PaycheckCalculation?
    @FocusState private var focusedField: Field?
    
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
                    // Calculator Input Section
                    Section {
                        LabeledContent("Hours Worked") {
                            TextField("0.00", text: $hoursString)
                                .focused($focusedField, equals: .hours)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .onChange(of: hoursString) { oldValue, newValue in
                                    let filtered = newValue.filter { "0123456789.".contains($0) }
                                    if filtered != newValue {
                                        hoursString = filtered
                                    }
                                    if let value = Double(filtered) {
                                        hoursWorked = value
                                    }
                                }
                        }
                        
                        HStack {
                            Label("Lunch Days", systemImage: "fork.knife")
                            Spacer()
                            Text("\(lunchDays) of \(user.paySchedule.maxLunchDays)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .frame(minWidth: 65, alignment: .trailing)
                            Stepper("\(lunchDays)", value: $lunchDays, in: 0...user.paySchedule.maxLunchDays)
                                .labelsHidden()
                                .frame(width: 100)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Lunch Days")
                        .accessibilityValue("\(lunchDays) of \(user.paySchedule.maxLunchDays) days")
                        
                        LabeledContent("Tax-Free Bonus") {
                            TextField("0.00", text: $bonusString)
                                .focused($focusedField, equals: .bonus)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .onChange(of: bonusString) { oldValue, newValue in
                                    let filtered = newValue.filter { "0123456789.".contains($0) }
                                    if filtered != newValue {
                                        bonusString = filtered
                                    }
                                    if let value = Double(filtered) {
                                        taxFreeBonus = value
                                    }
                                }
                        }
                        
                        LabeledContent("Pay Schedule", value: user.paySchedule.rawValue)
                            .foregroundStyle(.secondary)
                        
                        Button {
                            calculation = PaycheckCalculation(
                                hoursWorked: hoursWorked,
                                lunchDays: lunchDays,
                                taxFreeBonus: taxFreeBonus,
                                user: user
                            )
                        } label: {
                            Text("Calculate")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(hoursWorked == 0)
                        .padding(.vertical, 8)
                    } header: {
                        Text("Calculator")
                    } footer: {
                        Text("Enter your hours and any adjustments to calculate your paycheck")
                    }
                    
                    // Results Section
                    if let calc = calculation {
                        PaycheckResultsSection(
                            calculation: calc,
                            taxFreeBonus: taxFreeBonus,
                            showingTaxBreakdown: $showingTaxBreakdown
                        )
                    }
                } else {
                    Section {
                        HStack {
                            Spacer()
                            VStack(spacing: 12) {
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .font(.system(size: 44))
                                    .foregroundStyle(.secondary)
                                Text("Select or add a user to start")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            Spacer()
                        }
                    }
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
        }
    }
} 