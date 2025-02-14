import SwiftUI

struct OnboardingView: View {
    @ObservedObject var budgetManager: BudgetManager
    @State private var currentStep = 0
    @State private var paySchedule: PaySchedule = .monthly
    @State private var hourlyRate: Double = 0
    @State private var birthday = Date()
    @State private var expenseName = ""
    @State private var expenseDueDate = Date()
    @State private var expenseAmount: Double = 0
    @FocusState private var focusedField: Field?
    
    enum Field {
        case hourlyRate
        case expenseName
        case expenseAmount
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background tap gesture
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        focusedField = nil
                    }
                
                VStack {
                    TabView(selection: $currentStep) {
                        // Income Section
                        VStack(spacing: 20) {
                            Text("Income Information")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Picker("Pay Schedule", selection: $paySchedule) {
                                ForEach(PaySchedule.allCases, id: \.self) { schedule in
                                    Text(schedule.rawValue).tag(schedule)
                                }
                            }
                            .pickerStyle(.segmented)
                            
                            HStack {
                                Text("$")
                                TextField("Hourly Rate", value: $hourlyRate, format: .number)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                                    .focused($focusedField, equals: .hourlyRate)
                                Text("/Hr")
                            }
                            .padding()
                            
                            Button("Next") {
                                focusedField = nil
                                withAnimation {
                                    currentStep = 1
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                        .tag(0)
                        
                        // Initial Expense Section
                        VStack(spacing: 20) {
                            Text("Add Your First Expense")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            TextField("Expense Name", text: $expenseName)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)
                                .focused($focusedField, equals: .expenseName)
                            
                            HStack {
                                Text("$")
                                TextField("Amount", value: $expenseAmount, format: .number)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                                    .focused($focusedField, equals: .expenseAmount)
                            }
                            .padding(.horizontal)
                            
                            DatePicker("Due Date", selection: $expenseDueDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                            
                            Button("Next") {
                                focusedField = nil
                                if !expenseName.isEmpty && expenseAmount > 0 {
                                    let expense = Expense(name: expenseName, dueDate: expenseDueDate, amount: expenseAmount)
                                    budgetManager.expenses.append(expense)
                                    withAnimation {
                                        currentStep = 2
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(expenseName.isEmpty || expenseAmount == 0)
                        }
                        .padding()
                        .tag(1)
                        
                        // Birthday Section
                        VStack(spacing: 20) {
                            Text("When's Your Birthday?")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                            
                            Button("Complete") {
                                focusedField = nil
                                completeOnboarding()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                        .tag(2)
                    }
                    .tabViewStyle(.page)
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    private func completeOnboarding() {
        let profile = UserProfile(
            paySchedule: paySchedule,
            hourlyRate: hourlyRate,
            birthday: birthday
        )
        budgetManager.userProfile = profile
        withAnimation {
            budgetManager.hasCompletedOnboarding = true
        }
    }
}

#Preview {
    OnboardingView(budgetManager: BudgetManager())
} 