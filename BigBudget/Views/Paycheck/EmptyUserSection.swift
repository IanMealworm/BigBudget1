import SwiftUI

struct EmptyUserSection: View {
    var body: some View {
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

#Preview {
    List {
        EmptyUserSection()
    }
} 