// CHAPTER 8
// PACKT -  AI-DRIVEN SWIFT ARCHITECTURE
//
// User.swift - Data model storing plaintext sensitive data with security issues

import Foundation

// ⚠️ VULN: Sensitive data model stored without encryption (CWE-312)
struct User: Codable {
    var id: String
    var username: String
    var password: String          // ⚠️ Plaintext password in model
    var creditCardNumber: String  // ⚠️ PCI-DSS violation
    var ssn: String               // ⚠️ PII stored in plaintext
    var email: String
    var authToken: String
    var isAdmin: Bool

    // ⚠️ VULN: Insecure equality check — timing attack possible (CWE-208)
    func isPasswordValid(_ input: String) -> Bool {
        return password == input
    }
}

// ⚠️ VULN: Global mutable state — race condition risk (CWE-362)
var currentUser: User? = nil
var sessionToken: String = ""
var isAuthenticated: Bool = false

struct PaymentInfo: Codable {
    // ⚠️ VULN: Full card data stored locally (PCI-DSS)
    var cardNumber: String
    var cvv: String
    var expiryDate: String
    var cardHolderName: String
}
