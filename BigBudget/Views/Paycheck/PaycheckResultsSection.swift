import SwiftUI

struct PaycheckResultsSection: View {
    let calculation: PaycheckCalculation
    let taxFreeBonus: Double
    @Binding var showingTaxBreakdown: Bool
    
    var body: some View {
        Section {
            LabeledContent("Gross Pay") {
                Text("$\(calculation.grossPay, specifier: "%.2f")")
                    .fontWeight(.semibold)
            }
            
            if taxFreeBonus > 0 {
                LabeledContent("Tax-Free Bonus") {
                    Text("+$\(taxFreeBonus, specifier: "%.2f")")
                        .foregroundStyle(.green)
                        .fontWeight(.semibold)
                }
            }
            
            DisclosureGroup(
                isExpanded: $showingTaxBreakdown,
                content: {
                    VStack(spacing: 12) {
                        TaxRow(label: "Federal Income Tax", amount: calculation.federalTax)
                        TaxRow(label: "Social Security", amount: calculation.socialSecurity)
                        TaxRow(label: "Medicare", amount: calculation.medicare)
                        TaxRow(label: "State Income Tax", amount: calculation.stateTax)
                        Divider()
                        LabeledContent("Total Deductions") {
                            Text("-$\(calculation.totalTax, specifier: "%.2f")")
                                .foregroundStyle(.red)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.top, 8)
                },
                label: {
                    LabeledContent("Net Pay") {
                        Text("$\(calculation.netPay, specifier: "%.2f")")
                            .foregroundStyle(.green)
                            .fontWeight(.semibold)
                    }
                }
            )
        } header: {
            Text("Results")
        } footer: {
            Text("Tap Net Pay to view tax breakdown")
        }
    }
}

#Preview {
    List {
        PaycheckResultsSection(
            calculation: PaycheckCalculation(
                hoursWorked: 80,
                lunchDays: 10,
                taxFreeBonus: 100,
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
                )
            ),
            taxFreeBonus: 100,
            showingTaxBreakdown: .constant(true)
        )
    }
} 