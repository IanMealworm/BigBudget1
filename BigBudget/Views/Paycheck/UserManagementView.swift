import SwiftUI

struct UserManagementView: View {
    @ObservedObject var paycheckManager: PaycheckManager
    @Binding var selectedUser: PaycheckUser?
    @State private var showingAddUser = false
    @State private var editingUser: PaycheckUser?
    @State private var showingUserForm = false
    
    var body: some View {
        Group {
            if paycheckManager.users.isEmpty {
                Button {
                    editingUser = nil
                    showingUserForm = true
                } label: {
                    Label("Add New User", systemImage: "person.badge.plus")
                }
            } else {
                ForEach(paycheckManager.users) { user in
                    Button {
                        selectedUser = user
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.name)
                                    .fontWeight(selectedUser?.id == user.id ? .semibold : .regular)
                                Text("$\(user.hourlyRate, specifier: "%.2f")/hr")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            if selectedUser?.id == user.id {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .tint(.primary)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            paycheckManager.deleteUser(user)
                            if selectedUser?.id == user.id {
                                selectedUser = nil
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            editingUser = user
                            showingUserForm = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.orange)
                    }
                }
                
                Button {
                    editingUser = nil
                    showingUserForm = true
                } label: {
                    Label("Add Another User", systemImage: "person.badge.plus")
                        .foregroundStyle(.blue)
                }
            }
        }
        .sheet(isPresented: $showingUserForm) {
            NavigationStack {
                AddPaycheckUserView(
                    paycheckManager: paycheckManager,
                    editingUser: editingUser
                )
            }
            .presentationDragIndicator(.visible)
        }
    }
} 