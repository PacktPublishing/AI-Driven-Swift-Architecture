// CHAPTER 8
// PACKT -  AI-DRIVEN SWIFT ARCHITECTURE
//
// PaymentView.swift - Payment form displaying card data in plain text without masking

import SwiftUI

struct PaymentView: View {

    @State private var cardNumber: String = ""
    @State private var cvv: String = ""
    @State private var expiryDate: String = ""
    @State private var cardHolder: String = ""
    @State private var amount: String = ""

    var body: some View {
        Form {
            Section("Card Details") {
                // ⚠️ VULN: Card number shown in plain TextField, no masking (CWE-200)
                TextField("Card Number (16 digits)", text: $cardNumber)
                    .keyboardType(.numberPad)

                // ⚠️ VULN: CVV in plain TextField, not SecureField (CWE-200)
                TextField("CVV", text: $cvv)
                    .keyboardType(.numberPad)

                TextField("MM/YY", text: $expiryDate)
                TextField("Card Holder Name", text: $cardHolder)
            }

            Section("Amount") {
                TextField("Amount (€)", text: $amount)
                    .keyboardType(.decimalPad)
            }

            Button("Pay Now") {
                processPayment()
            }
            .foregroundColor(.green)

            Button("Copy Card Number") {
                // ⚠️ VULN: Card number in clipboard, never cleared (CWE-200)
                DataStorageService.copyCardNumberToClipboard(cardNumber)
            }
            .foregroundColor(.blue)
        }
        .navigationTitle("Payment")
        .onDisappear {
            // ⚠️ VULN: Card data not cleared from memory on view dismissal
        }
    }

    private func processPayment() {
        // ⚠️ VULN: No Luhn validation, no format check (CWE-20)
        // ⚠️ VULN: All card data sent via insecure HTTP in URL params (CWE-319, CWE-598)
        let amountDouble = Double(amount) ?? 0.0
        NetworkService.shared.submitPayment(cardNumber: cardNumber, cvv: cvv, amount: amountDouble)

        // ⚠️ VULN: Saving full PCI data locally after payment (CWE-312)
        let payment = PaymentInfo(cardNumber: cardNumber, cvv: cvv,
                                  expiryDate: expiryDate, cardHolderName: cardHolder)
        DataStorageService.savePaymentInfo(payment)

        // ⚠️ VULN: Full card data in logs (CWE-532)
        print("Payment processed: card=\(cardNumber) cvv=\(cvv) amount=\(amount)")
        DataStorageService.log("Payment: card=\(cardNumber), cvv=\(cvv), holder=\(cardHolder)")
    }
}

#Preview {
    PaymentView()
}
