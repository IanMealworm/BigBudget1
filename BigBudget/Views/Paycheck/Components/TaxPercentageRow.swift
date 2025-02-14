import SwiftUI

struct TaxPercentageRow: View {
    let label: String
    let rate: Double
    
    var body: some View {
        LabeledContent(label) {
            Text("\(rate * 100, specifier: "%.2f")%")
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }
} 