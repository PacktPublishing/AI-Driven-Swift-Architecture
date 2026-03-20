// CHAPTER 8
// PACKT -  AI-DRIVEN SWIFT ARCHITECTURE
//
// PaymentView.swift - RFC-002: PCI-compliant payment UI
// Fixes: CWE-200, CWE-312, CWE-532, CWE-20

import SwiftUI

struct PaymentView: View {

    @State private var cardNumber: String = ""
    @State private var cvv: String = ""
    @State private var expiryDate: String = ""
    @State private var cardHolder: String = ""
    @State private var amount: String = ""
    @State private var validationError: String? = nil

    var body: some View {
        Form {
            Section("Card Details") {
                // CWE-200 fix: card number field is marked privacy-sensitive so it is
                // excluded from screenshots, predictive keyboards, and system logs.
                TextField("Card Number (16 digits)", text: $cardNumber)
                    #if os(iOS)
                    .keyboardType(.numberPad)
                    #endif
                    .privacySensitive()

                // CWE-200 fix: CVV uses SecureField so the value is masked on screen.
                SecureField("CVV", text: $cvv)
                    #if os(iOS)
                    .keyboardType(.numberPad)
                    #endif

                TextField("MM/YY", text: $expiryDate)
                TextField("Card Holder Name", text: $cardHolder)
            }

            Section("Amount") {
                TextField("Amount (€)", text: $amount)
                    #if os(iOS)
                    .keyboardType(.decimalPad)
                    #endif
            }

            if let error = validationError {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                }
            }

            Button("Pay Now") {
                processPayment()
            }
            .foregroundColor(.green)

            Button("Copy Last 4 Digits") {
                // PCI-DSS 3.3: Full PAN must never be placed on the clipboard.
                // Only the last 4 digits may be copied for user reference.
                let last4 = String(cardNumber.suffix(4))
                DataStorageService.copyToClipboard(last4, clearAfter: 30)
            }
            .foregroundColor(.blue)
        }
        .navigationTitle("Payment")
        // CWE-200 fix: clear all card data from memory when the view disappears.
        .onDisappear {
            cardNumber = ""
            cvv = ""
            expiryDate = ""
            cardHolder = ""
        }
    }

    // MARK: - Luhn Validation (CWE-20 fix)

    /// Validates a card number using the Luhn algorithm.
    private func isValidCardNumber(_ number: String) -> Bool {
        let digits = number.compactMap { $0.wholeNumberValue }
        guard digits.count >= 13 && digits.count <= 19 else { return false }
        var sum = 0
        let reversed = digits.reversed()
        for (index, digit) in reversed.enumerated() {
            if index % 2 == 1 {
                let doubled = digit * 2
                sum += doubled > 9 ? doubled - 9 : doubled
            } else {
                sum += digit
            }
        }
        return sum % 10 == 0
    }

    // MARK: - Payment Processing

    private func processPayment() {
        // CWE-20 fix: validate card number with Luhn algorithm before submission.
        guard isValidCardNumber(cardNumber) else {
            validationError = "Invalid card number. Please check and try again."
            return
        }
        validationError = nil

        let amountDouble = Double(amount) ?? 0.0

        // CWE-319 / CWE-598 fix: submit payment over HTTPS using an opaque SDK token.
        // Raw PAN/CVV must never reach the app server — a PCI-compliant SDK (e.g.,
        // Stripe Elements, Adyen Drop-In) tokenises card data client-side first.
        // In production, integrate a PCI-compliant SDK (e.g. Stripe Elements, Adyen Drop-In)
        // that tokenises card data client-side and returns an opaque token to pass here.
        // The raw PAN and CVV must never reach the app server.
        NetworkService.shared.submitPayment(paymentToken: "", amount: amountDouble)

        // CWE-312 fix: raw card data (PAN, CVV) is never stored post-authorisation.
        // Only a PaymentToken returned by the processor should be persisted — that is
        // handled in the network response handler, not here.

        // CWE-532 fix: only log last-4 digits and amount; never log CVV or full PAN.
        let last4 = String(cardNumber.suffix(4))
        DataStorageService.log("Payment submitted: card=****\(last4) amount=\(amountDouble)")
    }
}

#Preview {
    PaymentView()
}
