import SwiftUI
import Combine

struct AddPaycheckUserView: View {
    @ObservedObject var paycheckManager: PaycheckManager
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusedField: Field?
    
    var editingUser: PaycheckUser?
    
    @State private var name = ""
    @State private var birthDate = Date()
    @State private var hourlyRateString = ""
    @State private var lunchDurationString = ""
    @State private var paySchedule: PaycheckSchedule = .biweekly
    @State private var sampleGrossPayString = ""
    @State private var sampleNetPayString = ""
    @State private var sampleFederalTaxString = ""
    @State private var sampleSocialSecurityString = ""
    @State private var sampleMedicareString = ""
    @State private var sampleStateTaxString = ""
    @State private var updateTrigger = false
    
    private var hourlyRate: Double? {
        Double(hourlyRateString.replacingOccurrences(of: "$", with: ""))
    }
    
    private var lunchDuration: Double? {
        Double(lunchDurationString)
    }
    
    private var sampleGrossPay: Double? {
        Double(sampleGrossPayString.replacingOccurrences(of: "$", with: ""))
    }
    
    private var sampleNetPay: Double? {
        Double(sampleNetPayString.replacingOccurrences(of: "$", with: ""))
    }
    
    private var sampleFederalTax: Double? {
        Double(sampleFederalTaxString.replacingOccurrences(of: "$", with: ""))
    }
    
    private var sampleSocialSecurity: Double? {
        Double(sampleSocialSecurityString.replacingOccurrences(of: "$", with: ""))
    }
    
    private var sampleMedicare: Double? {
        Double(sampleMedicareString.replacingOccurrences(of: "$", with: ""))
    }
    
    private var sampleStateTax: Double? {
        Double(sampleStateTaxString.replacingOccurrences(of: "$", with: ""))
    }
    
    enum Field {
        case name
        case hourlyRate
        case lunchDuration
        case grossPay
        case netPay
        case federalTax
        case socialSecurity
        case medicare
        case stateTax
    }
    
    private var calculatedTaxRates: TaxRates {
        paycheckManager.calculateTaxRates(
            grossPay: sampleGrossPay ?? 0,
            netPay: sampleNetPay ?? 0,
            federalTax: sampleFederalTax ?? 0,
            socialSecurity: sampleSocialSecurity ?? 0,
            medicare: sampleMedicare ?? 0,
            stateTax: sampleStateTax ?? 0
        )
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Full Name", text: $name)
                    .textContentType(.name)
                    .focused($focusedField, equals: .name)
                
                DatePicker("Birth Date", selection: $birthDate, displayedComponents: .date)
                
                Picker("Pay Schedule", selection: $paySchedule) {
                    ForEach(PaycheckSchedule.allCases, id: \.self) { schedule in
                        Text(schedule.rawValue).tag(schedule)
                    }
                }
                
                LabeledContent("Hourly Rate") {
                    HStack {
                        Text("$")
                        TextField("0.00", text: $hourlyRateString)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .hourlyRate)
                            .multilineTextAlignment(.trailing)
                            .frame(minWidth: 80, maxWidth: 120)
                    }
                }
                
                LabeledContent("Lunch Duration") {
                    TextField("Minutes", text: $lunchDurationString)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .lunchDuration)
                        .multilineTextAlignment(.trailing)
                        .frame(minWidth: 80, maxWidth: 120)
                }
            } header: {
                Text("Basic Information")
            } footer: {
                Text("Enter your personal information and work schedule details")
            }
            
            Section {
                LabeledContent("Gross Pay") {
                    HStack {
                        Text("$")
                        TextField("0.00", text: $sampleGrossPayString)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .grossPay)
                            .multilineTextAlignment(.trailing)
                            .frame(minWidth: 80, maxWidth: 120)
                            .onChange(of: sampleGrossPayString) { _ in updateTrigger.toggle() }
                    }
                }
                
                LabeledContent("Net Pay") {
                    HStack {
                        Text("$")
                        TextField("0.00", text: $sampleNetPayString)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .netPay)
                            .multilineTextAlignment(.trailing)
                            .frame(minWidth: 80, maxWidth: 120)
                            .onChange(of: sampleNetPayString) { _ in updateTrigger.toggle() }
                    }
                }
                
                LabeledContent("Federal Tax") {
                    HStack {
                        Text("$")
                        TextField("0.00", text: $sampleFederalTaxString)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .federalTax)
                            .multilineTextAlignment(.trailing)
                            .frame(minWidth: 80, maxWidth: 120)
                            .onChange(of: sampleFederalTaxString) { _ in updateTrigger.toggle() }
                    }
                }
                
                LabeledContent("Social Security") {
                    HStack {
                        Text("$")
                        TextField("0.00", text: $sampleSocialSecurityString)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .socialSecurity)
                            .multilineTextAlignment(.trailing)
                            .frame(minWidth: 80, maxWidth: 120)
                            .onChange(of: sampleSocialSecurityString) { _ in updateTrigger.toggle() }
                    }
                }
                
                LabeledContent("Medicare") {
                    HStack {
                        Text("$")
                        TextField("0.00", text: $sampleMedicareString)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .medicare)
                            .multilineTextAlignment(.trailing)
                            .frame(minWidth: 80, maxWidth: 120)
                            .onChange(of: sampleMedicareString) { _ in updateTrigger.toggle() }
                    }
                }
                
                LabeledContent("State Tax") {
                    HStack {
                        Text("$")
                        TextField("0.00", text: $sampleStateTaxString)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .stateTax)
                            .multilineTextAlignment(.trailing)
                            .frame(minWidth: 80, maxWidth: 120)
                            .onChange(of: sampleStateTaxString) { _ in updateTrigger.toggle() }
                    }
                }
            } header: {
                Text("Sample Check Information")
            } footer: {
                Text("Enter the amounts from a recent paycheck to calculate your tax rates")
            }
            
            Section {
                if let grossPay = sampleGrossPay, grossPay > 0 {
                    let _ = updateTrigger
                    TaxPercentageRow(label: "Federal Tax", rate: calculatedTaxRates.federalIncomeTax)
                    TaxPercentageRow(label: "Social Security", rate: calculatedTaxRates.socialSecurity)
                    TaxPercentageRow(label: "Medicare", rate: calculatedTaxRates.medicare)
                    TaxPercentageRow(label: "State Tax", rate: calculatedTaxRates.stateIncomeTax)
                    Divider()
                    TaxPercentageRow(label: "Total Tax Rate", rate: calculatedTaxRates.totalTaxRate)
                        .fontWeight(.semibold)
                } else {
                    Text("Enter gross pay and tax amounts above to see calculated rates")
                        .foregroundStyle(.secondary)
                        .font(.callout)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                }
            } header: {
                Text("Calculated Tax Rates")
            }
            
            Section {
                Button(editingUser == nil ? "Save User" : "Update User") {
                    focusedField = nil
                    
                    let user = PaycheckUser(
                        name: name,
                        birthDate: birthDate,
                        hourlyRate: hourlyRate ?? 0,
                        lunchDuration: (lunchDuration ?? 30) * 60,
                        paySchedule: paySchedule,
                        taxRates: calculatedTaxRates,
                        sampleGrossPay: sampleGrossPay ?? 0,
                        sampleNetPay: sampleNetPay ?? 0,
                        sampleFederalTax: sampleFederalTax ?? 0,
                        sampleSocialSecurity: sampleSocialSecurity ?? 0,
                        sampleMedicare: sampleMedicare ?? 0,
                        sampleStateTax: sampleStateTax ?? 0
                    )
                    
                    if editingUser != nil {
                        paycheckManager.updateUser(user)
                    } else {
                        paycheckManager.addUser(user)
                    }
                    dismiss()
                }
                .disabled(name.isEmpty || hourlyRate == nil || sampleGrossPay == nil)
            }
        }
        .navigationTitle(editingUser == nil ? "Add User" : "Edit User")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    focusedField = nil
                }
            }
        }
        .onAppear {
            if let user = editingUser {
                name = user.name
                birthDate = user.birthDate
                hourlyRateString = String(user.hourlyRate)
                lunchDurationString = String(user.lunchDuration / 60)
                paySchedule = user.paySchedule
                sampleGrossPayString = String(user.sampleGrossPay)
                sampleNetPayString = String(user.sampleNetPay)
                sampleFederalTaxString = String(user.sampleFederalTax)
                sampleSocialSecurityString = String(user.sampleSocialSecurity)
                sampleMedicareString = String(user.sampleMedicare)
                sampleStateTaxString = String(user.sampleStateTax)
            }
        }
    }
} 