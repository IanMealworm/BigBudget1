import SwiftUI

struct PaycheckInputSection: View {
    let user: PaycheckUser
    @Binding var hoursString: String
    @Binding var hoursWorked: Double
    @Binding var lunchDays: Int
    @Binding var bonusString: String
    @Binding var taxFreeBonus: Double
    @Binding var calculation: PaycheckCalculation?
    @Binding var focusedField: PaycheckCalculatorView.Field?
    
    var body: some View {
        Section {
            LabeledContent("Hours Worked") {
                TextField("0.00", text: $hoursString)
                    .onChange(of: focusedField) { oldValue, newValue in
                        if newValue == .hours {
                            hoursString = ""
                        }
                    }
                    .onTapGesture {
                        focusedField = .hours
                    }
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
                    .onChange(of: focusedField) { oldValue, newValue in
                        if newValue == .bonus {
                            bonusString = ""
                        }
                    }
                    .onTapGesture {
                        focusedField = .bonus
                    }
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
                focusedField = nil
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
    }
}

#Preview {
    List {
        PaycheckInputSection(
            user: PaycheckUser(
                name: "Test User",
                birthDate: Date(),
                hourlyRate: 25.0,
                lunchDuration: 30 * 60,
                paySchedule: .biweekly,
                taxRates: TaxRates(
                    federalIncomeTax: 0.12,
                    socialSecurity: 0.062,
                    medicare: 0.0145,
                    stateIncomeTax: 0.04
                ),
                sampleGrossPay: 2000,
                sampleNetPay: 1600,
                sampleFederalTax: 240,
                sampleSocialSecurity: 124,
                sampleMedicare: 29,
                sampleStateTax: 80
            ),
            hoursString: .constant(""),
            hoursWorked: .constant(0),
            lunchDays: .constant(0),
            bonusString: .constant(""),
            taxFreeBonus: .constant(0),
            calculation: .constant(nil),
            focusedField: .constant(nil)
        )
    }
} 