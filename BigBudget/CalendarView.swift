import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var selectedDate = Date()
    @State private var showingAddEntry = false
    @State private var showingAllUpcoming = false
    @State private var showingWeeklyView = false
    @State private var showingPaymentChecklist = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Calendar Section
                    VStack(spacing: 16) {
                        CalendarHeaderView(selectedDate: $selectedDate)
                            .padding(.top, 16)
                        
                        DateGridView(
                            selectedDate: $selectedDate,
                            viewModel: viewModel,
                            showingWeeklyView: $showingWeeklyView
                        )
                    }
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.1), radius: 8, y: 2)
                    .padding(.horizontal)
                    
                    // Upcoming Expenses Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label("Upcoming", systemImage: "calendar.badge.clock")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Spacer()
                            if !viewModel.upcomingEntries.isEmpty {
                                Button {
                                    withAnimation {
                                        showingAllUpcoming.toggle()
                                    }
                                } label: {
                                    Text(showingAllUpcoming ? "Show Less" : "Show More")
                                        .font(.subheadline)
                                }
                            }
                        }
                        
                        if viewModel.upcomingEntries.isEmpty {
                            ContentUnavailableView {
                                Label("No Upcoming Expenses", systemImage: "calendar.badge.plus")
                            } description: {
                                Text("Add expenses to see them here")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.tertiarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            ForEach(viewModel.upcomingEntries.prefix(showingAllUpcoming ? 10 : 3)) { entry in
                                UpcomingEntryRow(entry: entry)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.1), radius: 8, y: 2)
                    .padding(.horizontal)
                    
                    // Monthly Breakdown Section
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Monthly Overview", systemImage: "chart.bar.fill")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.bottom, 4)
                        
                        VStack(spacing: 16) {
                            // Monthly Totals
                            HStack(spacing: 16) {
                                TotalCard(
                                    title: "Expenses",
                                    amount: viewModel.monthlyExpenses(for: selectedDate),
                                    color: .red
                                )
                                
                                TotalCard(
                                    title: "Income",
                                    amount: viewModel.monthlyIncome(for: selectedDate),
                                    color: .green
                                )
                            }
                            
                            // Weekly Breakdown Header
                            Text("Weekly Breakdown")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 8)
                            
                            // Weekly Breakdown
                            ForEach(viewModel.weeklyBreakdown(for: selectedDate), id: \.weekNumber) { week in
                                DisclosureGroup {
                                    if !week.entries.isEmpty {
                                        VStack(spacing: 0) {
                                            ForEach(week.entries) { entry in
                                                VStack(spacing: 0) {
                                                    HStack(alignment: .center, spacing: 12) {
                                                        if entry.entryType == .birthday {
                                                            Image(systemName: "birthday.cake.fill")
                                                                .foregroundStyle(.pink)
                                                                .frame(width: 24)
                                                        } else {
                                                            Circle()
                                                                .fill(entry.amount < 0 ? .red : .green)
                                                                .frame(width: 8, height: 8)
                                                                .frame(width: 24)
                                                        }
                                                        
                                                        VStack(alignment: .leading, spacing: 4) {
                                                            Text(entry.title)
                                                                .fontWeight(.medium)
                                                            HStack {
                                                                Text(entry.date.formatted(.dateTime.weekday(.wide)))
                                                                    .font(.caption)
                                                                    .foregroundStyle(.secondary)
                                                                if entry.isPaid {
                                                                    Image(systemName: "checkmark.circle.fill")
                                                                        .foregroundStyle(.green)
                                                                        .font(.caption)
                                                                }
                                                            }
                                                        }
                                                        
                                                        Spacer()
                                                        
                                                        if entry.entryType != .birthday {
                                                            Text(entry.amount < 0 ? "-$\(-entry.amount, specifier: "%.2f")" : "$\(entry.amount, specifier: "%.2f")")
                                                                .monospacedDigit()
                                                                .fontWeight(.medium)
                                                                .foregroundStyle(entry.amount < 0 ? .red : .green)
                                                        }
                                                    }
                                                    .padding(.vertical, 8)
                                                    .padding(.horizontal)
                                                    .background(Color(.tertiarySystemGroupedBackground))
                                                    
                                                    if entry.id != week.entries.last?.id {
                                                        Divider()
                                                            .padding(.leading, 44)
                                                    }
                                                }
                                            }
                                        }
                                        .background(Color(.tertiarySystemGroupedBackground))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    } else {
                                        Text("No transactions")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .padding()
                                            .background(Color(.tertiarySystemGroupedBackground))
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack(spacing: 8) {
                                                Text("Week \(week.weekNumber)")
                                                    .font(.headline)
                                                    .fontWeight(.semibold)
                                                
                                                Text("\(week.entries.count) transaction\(week.entries.count == 1 ? "" : "s")")
                                                    .font(.subheadline)
                                                    .foregroundStyle(.secondary)
                                            }
                                            
                                            if !week.entries.isEmpty {
                                                let expenses = week.entries.filter { $0.amount < 0 }
                                                let income = week.entries.filter { $0.amount > 0 }
                                                HStack(spacing: 12) {
                                                    if !expenses.isEmpty {
                                                        Label("\(expenses.count)", systemImage: "arrow.down")
                                                            .font(.caption)
                                                            .foregroundStyle(.red)
                                                    }
                                                    if !income.isEmpty {
                                                        Label("\(income.count)", systemImage: "arrow.up")
                                                            .font(.caption)
                                                            .foregroundStyle(.green)
                                                    }
                                                }
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        if week.total != 0 {
                                            Text(week.total < 0 ? "-$\(-week.total, specifier: "%.2f")" : "$\(week.total, specifier: "%.2f")")
                                                .fontWeight(.semibold)
                                                .monospacedDigit()
                                                .foregroundStyle(week.total < 0 ? .red : .green)
                                        }
                                    }
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal)
                                .background(Color(.tertiarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.separator), lineWidth: 0.5)
                                )
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.1), radius: 8, y: 2)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Budget Calendar")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showingAddEntry = true
                        } label: {
                            Label("Add Entry", systemImage: "plus")
                        }
                        
                        Button {
                            showingPaymentChecklist = true
                        } label: {
                            Label("Payment Checklist", systemImage: "checklist")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.title3)
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        selectedDate = Date()
                    } label: {
                        Text("Today")
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                NavigationStack {
                    AddBudgetEntryView(viewModel: viewModel, date: selectedDate)
                }
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingWeeklyView) {
                WeeklyEntriesView(
                    viewModel: viewModel,
                    selectedDate: selectedDate
                )
            }
            .sheet(isPresented: $showingPaymentChecklist) {
                NavigationStack {
                    PaymentChecklistView(viewModel: viewModel)
                }
                .presentationDragIndicator(.visible)
            }
        }
    }
}

struct CalendarHeaderView: View {
    @Binding var selectedDate: Date
    @Environment(\.calendar) var calendar
    
    private var month: String {
        selectedDate.formatted(.dateTime.month(.wide).year())
    }
    
    var body: some View {
        HStack {
            Button {
                withAnimation {
                    selectedDate = calendar.date(
                        byAdding: .month,
                        value: -1,
                        to: selectedDate
                    ) ?? selectedDate
                }
            } label: {
                Image(systemName: "chevron.left")
                    .fontWeight(.semibold)
            }
            
            Text(month)
                .font(.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
            
            Button {
                withAnimation {
                    selectedDate = calendar.date(
                        byAdding: .month,
                        value: 1,
                        to: selectedDate
                    ) ?? selectedDate
                }
            } label: {
                Image(systemName: "chevron.right")
                    .fontWeight(.semibold)
            }
        }
        .padding(.horizontal)
        .foregroundStyle(.primary)
    }
}

struct DateGridView: View {
    @Binding var selectedDate: Date
    @Environment(\.calendar) var calendar
    let viewModel: CalendarViewModel
    @Binding var showingWeeklyView: Bool
    
    private let daysOfWeek = Array(zip(0..., ["S", "M", "T", "W", "T", "F", "S"]))
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    private var weeks: [[Date?]] {
        let month = calendar.component(.month, from: selectedDate)
        let year = calendar.component(.year, from: selectedDate)
        
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
        else { return [] }
        
        let formatter = DateFormatter()
        formatter.timeZone = calendar.timeZone
        
        var weeks: [[Date?]] = []
        var week: [Date?] = []
        
        calendar.enumerateDates(
            startingAfter: monthFirstWeek.start - 1,
            matching: DateComponents(hour: 0),
            matchingPolicy: .nextTime
        ) { date, _, stop in
            guard let date = date else { return }
            
            if date > monthLastWeek.end {
                if !week.isEmpty {
                    weeks.append(week)
                }
                stop = true
                return
            }
            
            if week.count == 7 {
                weeks.append(week)
                week = []
            }
            
            if calendar.component(.month, from: date) == month {
                week.append(date)
            } else {
                week.append(nil)
            }
        }
        
        if !week.isEmpty {
            weeks.append(week)
        }
        
        return weeks
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Days of week header
            HStack {
                ForEach(daysOfWeek, id: \.0) { index, day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Date grid
            ForEach(weeks.indices, id: \.self) { weekIndex in
                HStack(spacing: 0) {
                    ForEach(0..<7) { dayIndex in
                        if weekIndex < weeks.count && dayIndex < weeks[weekIndex].count,
                           let date = weeks[weekIndex][dayIndex] {
                            DateCell(
                                date: date,
                                isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                viewModel: viewModel
                            )
                            .onTapGesture {
                                withAnimation {
                                    selectedDate = date
                                }
                            }
                            .onTapGesture(count: 2) {
                                withAnimation {
                                    selectedDate = date
                                    showingWeeklyView = true
                                }
                            }
                        } else {
                            Color.clear
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct DateCell: View {
    let date: Date
    let isSelected: Bool
    @ObservedObject var viewModel: CalendarViewModel
    @Environment(\.calendar) var calendar
    
    private var day: String {
        String(calendar.component(.day, from: date))
    }
    
    private var hasIncome: Bool {
        viewModel.hasIncome(for: date)
    }
    
    private var hasExpense: Bool {
        viewModel.hasExpense(for: date)
    }
    
    private var hasBirthday: Bool {
        viewModel.entries(for: date)?.contains { $0.entryType == .birthday } ?? false
    }
    
    private var hasUnpaidExpense: Bool {
        viewModel.entries(for: date)?.contains { $0.amount < 0 && !$0.isPaid } ?? false
    }
    
    private var isPastDue: Bool {
        guard let entries = viewModel.entries(for: date) else { return false }
        let today = calendar.startOfDay(for: Date())
        let entryDate = calendar.startOfDay(for: date)
        return entries.contains { $0.amount < 0 && !$0.isPaid && entryDate < today }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? Color.accentColor : Color.clear)
                .frame(width: 32, height: 32)
            
            Text(day)
                .font(.callout)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : .primary)
            
            if !isSelected {
                VStack(spacing: 2) {
                    Spacer()
                    
                    if hasBirthday {
                        Image(systemName: "birthday.cake.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(.pink)
                    } else {
                        HStack(spacing: 4) {
                            if hasExpense {
                                Circle()
                                    .fill(.red)
                                    .frame(width: 4, height: 4)
                            }
                            if hasIncome {
                                Circle()
                                    .fill(.green)
                                    .frame(width: 4, height: 4)
                            }
                        }
                    }
                }
                .frame(height: 44)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .overlay(alignment: .topTrailing) {
            if !isSelected && isPastDue {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(.red)
                    .offset(x: 2, y: -2)
            }
        }
        .id("\(date)-\(viewModel.entries(for: date)?.count ?? 0)-\(isPastDue)")
    }
}

struct BudgetEntryRow: View {
    let entry: BudgetEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .fontWeight(.medium)
                
                if !entry.notes.isEmpty {
                    Text(entry.notes)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Text(entry.amount < 0 ? "-$\(-entry.amount, specifier: "%.2f")" : "$\(entry.amount, specifier: "%.2f")")
                .fontWeight(.medium)
                .foregroundStyle(entry.amount < 0 ? .red : .green)
        }
        .padding(.vertical, 4)
    }
}

struct AddBudgetEntryView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: CalendarViewModel
    @State private var selectedDate: Date
    @State private var title = ""
    @State private var amountString = ""
    @State private var amount = 0.0
    @State private var notes = ""
    @State private var isExpense = true
    @State private var isRecurring = false
    @State private var recurringType: RecurringType = .none
    @FocusState private var focusedField: Field?
    private let editingEntry: BudgetEntry?
    @State private var isAmountFirstFocus = true
    
    init(viewModel: CalendarViewModel, date: Date) {
        self.viewModel = viewModel
        self.editingEntry = nil
        _selectedDate = State(initialValue: date)
        _amountString = State(initialValue: "")
        _isAmountFirstFocus = State(initialValue: true)
    }
    
    init(viewModel: CalendarViewModel, entry: BudgetEntry) {
        self.viewModel = viewModel
        self.editingEntry = entry
        _selectedDate = State(initialValue: entry.date)
        _title = State(initialValue: entry.title)
        _amountString = State(initialValue: String(format: "%.2f", abs(entry.amount)))
        _amount = State(initialValue: abs(entry.amount))
        _notes = State(initialValue: entry.notes)
        _isExpense = State(initialValue: entry.amount < 0)
        _isAmountFirstFocus = State(initialValue: false)
        _isRecurring = State(initialValue: entry.recurringType != .none)
        _recurringType = State(initialValue: entry.recurringType)
    }
    
    enum Field {
        case title
        case amount
        case notes
    }
    
    var body: some View {
        Form {
            Group {
                Section {
                    DatePicker(
                        "Date",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    
                    Picker("Type", selection: $isExpense) {
                        Text("Expense").tag(true)
                        Text("Income").tag(false)
                    }
                    .pickerStyle(.segmented)
                    
                    TextField("Title", text: $title)
                        .focused($focusedField, equals: .title)
                        .textContentType(.none)
                        .autocorrectionDisabled()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                focusedField = .title
                            }
                        }
                    
                    LabeledContent("Amount") {
                        TextField("0.00", text: $amountString)
                            .focused($focusedField, equals: .amount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: amountString) { oldValue, newValue in
                                let filtered = newValue.filter { "0123456789.".contains($0) }
                                if filtered != newValue {
                                    amountString = filtered
                                }
                                if let value = Double(filtered) {
                                    amount = value
                                }
                            }
                    }
                    
                    LabeledContent("Repeats") {
                        Picker("", selection: $recurringType) {
                            ForEach(RecurringType.allCases, id: \.self) { frequency in
                                Label(frequency.rawValue, systemImage: frequency.icon)
                                    .tag(frequency)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    TextField("Notes", text: $notes, axis: .vertical)
                        .focused($focusedField, equals: .notes)
                        .lineLimit(3)
                }
                
                Section {
                    Button(action: {
                        let entry = BudgetEntry(
                            id: editingEntry?.id ?? UUID(),
                            date: selectedDate,
                            title: title,
                            amount: isExpense ? -abs(amount) : abs(amount),
                            notes: notes,
                            recurringType: recurringType,
                            entryType: isExpense ? .regular : .birthday
                        )
                        
                        if editingEntry != nil {
                            viewModel.editEntry(entry)
                        } else {
                            viewModel.addEntry(entry)
                        }
                        dismiss()
                    }) {
                        Text(editingEntry != nil ? "Save Changes" : "Save Entry")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(title.isEmpty || amount == 0)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
            .onTapGesture {
                focusedField = nil
            }
        }
        .navigationTitle(editingEntry != nil ? "Edit Entry" : "Add Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
    }
}

struct TotalCard: View {
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(abs(amount), format: .currency(code: "USD"))
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct UpcomingEntryRow: View {
    let entry: BudgetEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .fontWeight(.medium)
                Text(entry.date.formatted(.dateTime.month().day().weekday()))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(entry.amount < 0 ? "-$\(-entry.amount, specifier: "%.2f")" : "$\(entry.amount, specifier: "%.2f")")
                .fontWeight(.medium)
                .foregroundStyle(entry.amount < 0 ? .red : .green)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct WeeklyEntriesView: View {
    @Environment(\.dismiss) var dismiss
    let viewModel: CalendarViewModel
    let selectedDate: Date
    @State private var editingEntry: BudgetEntry?
    @State private var entryToDelete: BudgetEntry?
    
    private var groupedEntries: [(Date, [BudgetEntry])] {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfMonth, for: selectedDate) else {
            return []
        }
        
        let weekEntries = viewModel.allEntries.filter {
            $0.date >= weekInterval.start && $0.date < weekInterval.end
        }
        
        let grouped = Dictionary(grouping: weekEntries) {
            calendar.startOfDay(for: $0.date)
        }
        
        return grouped.sorted { $0.key < $1.key }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedEntries, id: \.0) { date, entries in
                    Section {
                        ForEach(entries) { entry in
                            BudgetEntryRow(entry: entry)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        if entry.isRecurring {
                                            entryToDelete = entry
                                        } else {
                                            viewModel.deleteEntry(entry)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    
                                    Button {
                                        editingEntry = entry
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.orange)
                                }
                        }
                    } header: {
                        Text(date.formatted(.dateTime.weekday(.wide).month().day()))
                    }
                }
                
                if groupedEntries.isEmpty {
                    ContentUnavailableView {
                        Label("No Entries", systemImage: "calendar.badge.plus")
                    } description: {
                        Text("No budget entries for this week")
                    }
                }
            }
            .navigationTitle("Weekly View")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $editingEntry) { entry in
                NavigationStack {
                    AddBudgetEntryView(viewModel: viewModel, entry: entry)
                }
                .presentationDragIndicator(.visible)
            }
            .confirmationDialog(
                "Delete Recurring Entry",
                isPresented: .init(
                    get: { entryToDelete != nil },
                    set: { if !$0 { entryToDelete = nil } }
                ),
                actions: {
                    if let entry = entryToDelete {
                        Button("Delete Only This Entry", role: .destructive) {
                            viewModel.deleteEntry(entry)
                            entryToDelete = nil
                        }
                        
                        Button("Delete This and Future Entries", role: .destructive) {
                            viewModel.deleteRecurringEntries(entry)
                            entryToDelete = nil
                        }
                        
                        Button("Cancel", role: .cancel) {
                            entryToDelete = nil
                        }
                    }
                },
                message: {
                    Text("Would you like to delete just this entry or this and all future entries?")
                }
            )
        }
    }
}

// Sample model types for reference
struct BudgetEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let title: String
    let amount: Double
    let notes: String
    let recurringType: RecurringType
    let entryType: EntryType
    var isPaid: Bool
    var paidDate: Date?
    
    var isRecurring: Bool { recurringType != .none }
    
    init(id: UUID = UUID(), date: Date, title: String, amount: Double, notes: String = "", recurringType: RecurringType = .none, entryType: EntryType = .regular, isPaid: Bool = false, paidDate: Date? = nil) {
        self.id = id
        self.date = date
        self.title = title
        self.amount = amount
        self.notes = notes
        self.recurringType = recurringType
        self.entryType = entryType
        self.isPaid = isPaid
        self.paidDate = paidDate
    }
    
    // Convert to Expense
    var asExpense: Expense {
        Expense(id: id, name: title, dueDate: date, amount: amount, recurringType: recurringType)
    }
    
    // Create from Expense
    init(from expense: Expense) {
        self.id = expense.id
        self.date = expense.dueDate
        self.title = expense.name
        self.amount = expense.amount
        self.notes = ""
        self.recurringType = expense.recurringType
        self.entryType = .regular
        self.isPaid = false
        self.paidDate = nil
    }
    
    enum EntryType: String, Codable {
        case regular
        case birthday
    }
}

class CalendarViewModel: ObservableObject {
    @Published private var entries: [BudgetEntry] = [] {
        didSet {
            saveEntries()
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    @Published var userProfile: UserProfile?
    @Published var deposits: [Deposit] = []
    
    private var birthdayEntries: [BudgetEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let paycheckManager = PaycheckManager()
        var birthdays: [BudgetEntry] = []
        
        for user in paycheckManager.users {
            // Get this year's birthday
            let birthdayThisYear = calendar.date(from: DateComponents(
                year: calendar.component(.year, from: today),
                month: calendar.component(.month, from: user.birthDate),
                day: calendar.component(.day, from: user.birthDate)
            ))!
            
            // Add birthday for this year if it hasn't passed
            if birthdayThisYear >= today {
                birthdays.append(BudgetEntry(
                    date: birthdayThisYear,
                    title: "🎂 Happy Birthday, \(user.name)! 🎉",
                    amount: 0,
                    notes: "Birthday Celebration",
                    entryType: .birthday
                ))
            }
            
            // Add birthday for next year
            let birthdayNextYear = calendar.date(byAdding: .year, value: 1, to: birthdayThisYear)!
            birthdays.append(BudgetEntry(
                date: birthdayNextYear,
                title: "🎂 Happy Birthday, \(user.name)! 🎉",
                amount: 0,
                notes: "Birthday Celebration",
                entryType: .birthday
            ))
        }
        
        return birthdays
    }
    
    var allEntries: [BudgetEntry] {
        entries + birthdayEntries
    }
    
    init() {
        loadEntries()
    }
    
    var upcomingEntries: [BudgetEntry] {
        let today = Calendar.current.startOfDay(for: Date())
        return allEntries
            .filter { $0.amount < 0 && $0.date >= today && !$0.isPaid }
            .sorted { $0.date < $1.date }
            .prefix(10)
            .map { $0 }
    }
    
    func monthlyExpenses(for date: Date) -> Double {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        return abs(entries
            .filter {
                let components = calendar.dateComponents([.month, .year], from: $0.date)
                return components.month == month && components.year == year && $0.amount < 0
            }
            .reduce(0) { $0 + $1.amount })
    }
    
    func monthlyIncome(for date: Date) -> Double {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        return entries
            .filter {
                let components = calendar.dateComponents([.month, .year], from: $0.date)
                return components.month == month && components.year == year && $0.amount > 0
            }
            .reduce(0) { $0 + $1.amount }
    }
    
    struct WeekBreakdown: Identifiable {
        var id: Int { weekNumber }
        let weekNumber: Int
        let entries: [BudgetEntry]
        let total: Double
    }
    
    func weeklyBreakdown(for date: Date) -> [WeekBreakdown] {
        let calendar = Calendar.current
        
        // Get the month interval for the selected date
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else {
            return []
        }
        
        // Get all weeks in the month
        var weeks: [WeekBreakdown] = []
        
        // Get all entries for processing, including recurring ones
        let entriesForMonth = allEntries.filter {
            let entryMonth = calendar.component(.month, from: $0.date)
            let entryYear = calendar.component(.year, from: $0.date)
            let targetMonth = calendar.component(.month, from: date)
            let targetYear = calendar.component(.year, from: date)
            return entryMonth == targetMonth && entryYear == targetYear
        }
        
        // Get the range of week ordinals in the month
        let weekRange = calendar.range(of: .weekOfMonth, in: .month, for: date) ?? 1..<5
        
        // Create a breakdown for each week in the month
        for weekNumber in weekRange {
            // Get the first day of this week in the month
            guard let weekStart = calendar.date(from: DateComponents(
                year: calendar.component(.year, from: date),
                month: calendar.component(.month, from: date),
                weekday: calendar.firstWeekday,
                weekOfMonth: weekNumber
            )) else { continue }
            
            // Get the week interval
            guard let weekInterval = calendar.dateInterval(of: .weekOfMonth, for: weekStart) else { continue }
            
            // Filter entries within this week
            let weekEntries = entriesForMonth.filter { entry in
                let entryDate = calendar.startOfDay(for: entry.date)
                let weekStartDate = calendar.startOfDay(for: weekInterval.start)
                let weekEndDate = calendar.startOfDay(for: weekInterval.end)
                
                return (entryDate >= weekStartDate && entryDate < weekEndDate) &&
                       calendar.component(.month, from: entry.date) == calendar.component(.month, from: date)
            }
            
            // Calculate total for the week
            let weekTotal = weekEntries.reduce(0.0) { $0 + $1.amount }
            
            // Create week breakdown
            let breakdown = WeekBreakdown(
                weekNumber: weekNumber,
                entries: weekEntries.sorted { $0.date < $1.date },
                total: weekTotal
            )
            
            weeks.append(breakdown)
        }
        
        return weeks.sorted { $0.weekNumber < $1.weekNumber }
    }
    
    var datesWithEntries: Set<Date> {
        Set(entries.map { $0.date })
    }
    
    func entries(for date: Date) -> [BudgetEntry]? {
        let calendar = Calendar.current
        let filtered = allEntries.filter { calendar.isDate($0.date, inSameDayAs: date) }
        return filtered.isEmpty ? nil : filtered
    }
    
    func hasIncome(for date: Date) -> Bool {
        entries(for: date)?.contains { $0.amount > 0 } ?? false
    }
    
    func hasExpense(for date: Date) -> Bool {
        entries(for: date)?.contains { $0.amount < 0 } ?? false
    }
    
    func totalAmount(for date: Date) -> Double? {
        guard let entries = entries(for: date) else { return nil }
        return entries.reduce(0) { $0 + $1.amount }
    }
    
    func totalAmount(forMonth date: Date) -> Double {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        return entries
            .filter {
                let components = calendar.dateComponents([.month, .year], from: $0.date)
                return components.month == month && components.year == year
            }
            .reduce(0) { $0 + $1.amount }
    }
    
    func totalAmount(forWeek date: Date) -> Double {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfMonth, for: date) else { return 0 }
        
        return entries
            .filter { entry in
                entry.date >= weekInterval.start && entry.date < weekInterval.end
            }
            .reduce(0) { $0 + $1.amount }
    }
    
    func addEntry(_ entry: BudgetEntry) {
        entries.append(entry)
        
        // If it's a recurring entry, generate future instances
        if entry.isRecurring {
            let futureEntries = generateRecurringEntries(from: entry)
            entries.append(contentsOf: futureEntries)
        }
        
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    private func generateRecurringEntries(from entry: BudgetEntry) -> [BudgetEntry] {
        var futureEntries: [BudgetEntry] = []
        let calendar = Calendar.current
        
        // Generate instances for the next year
        let endDate = calendar.date(byAdding: .year, value: 1, to: entry.date)!
        var currentDate = calendar.date(byAdding: entry.recurringType.dateComponent, value: 1, to: entry.date) ?? entry.date
        
        while currentDate <= endDate {
            let newEntry = BudgetEntry(
                id: UUID(), // New unique ID for each instance
                date: currentDate,
                title: entry.title,
                amount: entry.amount,
                notes: entry.notes,
                recurringType: entry.recurringType,
                entryType: entry.entryType,
                isPaid: false,  // Each instance starts as unpaid
                paidDate: nil   // Each instance has its own paid date
            )
            futureEntries.append(newEntry)
            
            // Move to next occurrence
            if let nextDate = calendar.date(byAdding: entry.recurringType.dateComponent, value: 1, to: currentDate) {
                currentDate = nextDate
            } else {
                break
            }
        }
        
        return futureEntries
    }
    
    func deleteEntry(_ entry: BudgetEntry) {
        if entry.isRecurring {
            // Only delete this specific instance since each recurring entry is independent
            entries.removeAll { $0.id == entry.id }
        } else {
            entries.removeAll { $0.id == entry.id }
        }
        
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    func editEntry(_ entry: BudgetEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    
    private let calendar = Calendar.current
    
    private func saveEntries() {
        do {
            // Convert BudgetEntries to Expenses for saving
            let expensesToSave = entries.map { entry -> Expense in
                // For recurring entries, save each instance with its own paid status
                if entry.isRecurring {
                    return Expense(
                        id: entry.id,
                        name: entry.title,
                        dueDate: entry.date,
                        amount: entry.amount,
                        recurringType: entry.recurringType,
                        isPaid: entry.isPaid,
                        paidDate: entry.paidDate
                    )
                } else {
                    return entry.asExpense
                }
            }
            
            let dataStore = DataStore(
                userProfile: userProfile,
                expenses: expensesToSave,
                deposits: deposits
            )
            
            let data = try JSONEncoder().encode(dataStore)
            try data.write(to: getEntriesFile())
        } catch {
            print("Error saving entries: \(error)")
        }
    }
    
    private func loadEntries() {
        do {
            let data = try Data(contentsOf: getEntriesFile())
            let dataStore = try JSONDecoder().decode(DataStore.self, from: data)
            
            // Convert loaded expenses to BudgetEntries
            var loadedEntries: [BudgetEntry] = []
            
            for expense in dataStore.expenses {
                // Create the base entry
                let baseEntry = BudgetEntry(
                    id: expense.id,
                    date: expense.dueDate,
                    title: expense.name,
                    amount: expense.amount,
                    notes: "",
                    recurringType: expense.recurringType,
                    entryType: .regular,
                    isPaid: expense.isPaid,
                    paidDate: expense.paidDate
                )
                
                loadedEntries.append(baseEntry)
                
                // Generate future recurring entries if it's a recurring expense
                if baseEntry.isRecurring {
                    let futureEntries = generateRecurringEntries(from: baseEntry)
                    loadedEntries.append(contentsOf: futureEntries)
                }
            }
            
            entries = loadedEntries
            userProfile = dataStore.userProfile
            deposits = dataStore.deposits
        } catch {
            print("Error loading entries: \(error)")
            entries = []
            userProfile = nil
            deposits = []
        }
    }
    
    private func getEntriesFile() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent("budgetEntries.json")
    }
    
    func togglePaymentStatus(_ entry: BudgetEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            var updatedEntry = entries[index]
            updatedEntry.isPaid.toggle()
            updatedEntry.paidDate = updatedEntry.isPaid ? Date() : nil
            entries[index] = updatedEntry
            
            saveEntries()
            
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    
    func monthlyEntries(for date: Date) -> [BudgetEntry] {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        return allEntries
            .filter {
                let components = calendar.dateComponents([.month, .year], from: $0.date)
                return components.month == month && components.year == year
            }
            .sorted { $0.date < $1.date }
    }
    
    func deleteRecurringEntries(_ entry: BudgetEntry) {
        let calendar = Calendar.current
        let entryDate = calendar.startOfDay(for: entry.date)
        
        // Delete this entry and all future entries with the same title and amount
        entries.removeAll { candidate in
            if candidate.title == entry.title &&
               candidate.amount == entry.amount &&
               candidate.recurringType == entry.recurringType {
                let candidateDate = calendar.startOfDay(for: candidate.date)
                return candidateDate >= entryDate
            }
            return false
        }
        
        saveEntries()
        
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
}

extension RecurringType {
    var icon: String {
        switch self {
        case .none:
            return "calendar"
        case .weekly:
            return "calendar.badge.clock"
        case .monthly:
            return "calendar.badge.exclamationmark"
        case .yearly:
            return "calendar.badge.plus"
        }
    }
    
    var description: String {
        switch self {
        case .none:
            return "one-time"
        case .weekly:
            return "every week"
        case .monthly:
            return "every month"
        case .yearly:
            return "every year"
        }
    }
}

// Add a new view for the Payment Checklist
struct PaymentChecklistView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Environment(\.calendar) var calendar
    @State private var selectedMonth = Date()
    
    private func changeMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: selectedMonth) {
            selectedMonth = calendar.startOfDay(for: newDate)
        }
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    Button {
                        changeMonth(by: -1)
                    } label: {
                        Image(systemName: "chevron.left")
                            .fontWeight(.semibold)
                            .imageScale(.large)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    
                    Text(selectedMonth.formatted(.dateTime.month(.wide).year()))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                    
                    Button {
                        changeMonth(by: 1)
                    } label: {
                        Image(systemName: "chevron.right")
                            .fontWeight(.semibold)
                            .imageScale(.large)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 4)
            }
            
            let entries = viewModel.monthlyEntries(for: selectedMonth)
                .filter { $0.entryType == .regular && $0.amount < 0 }
            
            let unpaidEntries = entries.filter { !$0.isPaid }
            let paidEntries = entries.filter { $0.isPaid }
            
            if unpaidEntries.isEmpty && paidEntries.isEmpty {
                ContentUnavailableView {
                    Label("No Expenses", systemImage: "checklist")
                } description: {
                    Text("No expenses to track for \(selectedMonth.formatted(.dateTime.month().year()))")
                }
            } else {
                if !unpaidEntries.isEmpty {
                    Section("Pending Payments") {
                        ForEach(unpaidEntries.sorted { $0.date < $1.date }) { entry in
                            ChecklistEntryRow(entry: entry, viewModel: viewModel)
                        }
                    }
                }
                
                if !paidEntries.isEmpty {
                    Section("Completed Payments") {
                        ForEach(paidEntries.sorted { $0.date < $1.date }) { entry in
                            ChecklistEntryRow(entry: entry, viewModel: viewModel)
                        }
                    }
                }
            }
        }
        .navigationTitle("Payment Checklist")
        .id(selectedMonth) // Force view refresh when month changes
    }
}

struct ChecklistEntryRow: View {
    let entry: BudgetEntry
    @ObservedObject var viewModel: CalendarViewModel
    @Environment(\.calendar) var calendar
    @State private var showingDeleteConfirmation = false
    
    private var isPastDue: Bool {
        let today = calendar.startOfDay(for: Date())
        let entryDate = calendar.startOfDay(for: entry.date)
        return !entry.isPaid && entryDate < today
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.togglePaymentStatus(entry)
            } label: {
                Image(systemName: entry.isPaid ? "checkmark.square.fill" : "square")
                    .foregroundStyle(entry.isPaid ? .green : .secondary)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.title)
                        .fontWeight(.medium)
                }
                
                Text(entry.date.formatted(.dateTime.month().day().weekday()))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if entry.isPaid, let paidDate = entry.paidDate {
                    Text("Paid on \(paidDate.formatted(.dateTime.month().day()))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if isPastDue {
                    Text("Past due")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            
            Spacer()
            
            Text(entry.amount < 0 ? "-$\(-entry.amount, specifier: "%.2f")" : "$\(entry.amount, specifier: "%.2f")")
                .fontWeight(.medium)
                .foregroundStyle(entry.amount < 0 ? .red : .green)
        }
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing) {
            Button {
                viewModel.togglePaymentStatus(entry)
            } label: {
                if entry.isPaid {
                    Label("Mark Unpaid", systemImage: "xmark.circle.fill")
                } else {
                    Label("Mark Paid", systemImage: "checkmark.circle.fill")
                }
            }
            .tint(entry.isPaid ? .red : .green)
            
            if entry.isRecurring {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            } else {
                Button(role: .destructive) {
                    viewModel.deleteEntry(entry)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .confirmationDialog(
            "Delete Recurring Entry",
            isPresented: $showingDeleteConfirmation,
            actions: {
                Button("Delete Only This Entry", role: .destructive) {
                    viewModel.deleteEntry(entry)
                }
                
                Button("Delete This and Future Entries", role: .destructive) {
                    viewModel.deleteRecurringEntries(entry)
                }
                
                Button("Cancel", role: .cancel) {}
            },
            message: {
                Text("Would you like to delete just this entry or this and all future entries?")
            }
        )
    }
}

#Preview {
    CalendarView()
} 
