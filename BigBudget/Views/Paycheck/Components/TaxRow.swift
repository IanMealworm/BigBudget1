import SwiftUI

struct TaxRow: View {
    let label: String
    let amount: Double
    
    var body: some View {
        LabeledContent(label) {
            Text("-$\(amount, specifier: "%.2f")")
                .foregroundStyle(.red)
        }
        .foregroundStyle(.secondary)
    }
} 