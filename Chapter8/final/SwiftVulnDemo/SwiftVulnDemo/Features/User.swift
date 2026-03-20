// CHAPTER 8
// PACKT -  AI-DRIVEN SWIFT ARCHITECTURE
//
// User.swift - Data model (RFC-001 security fixes applied)

import Foundation

// MARK: - User

/// RFC-001 fix: `password`, `creditCardNumber`, and `ssn` removed from the model.
/// Sensitive fields must never be stored in a serializable struct that could be
/// persisted to disk or transmitted in plain text.
/// CWE-208 fix: `isPasswordValid` removed (password field no longer exists).
struct User: Codable {
    var id: String
    var username: String
    var email: String
    var isAdmin: Bool
    // authToken removed — tokens are stored exclusively in Keychain (CWE-312)
}

// MARK: - AppSession (CWE-362 fix)

/// Thread-safe session state using Swift's actor model.
/// Replaces the global mutable variables `currentUser`, `sessionToken`,
/// and `isAuthenticated` which were vulnerable to data races (CWE-362).
actor AppSession {
    static let shared = AppSession()

    private(set) var currentUser: User? = nil
    private(set) var sessionToken: String = ""
    private(set) var isAuthenticated: Bool = false

    func setUser(_ user: User?) { currentUser = user }
    func setToken(_ token: String) { sessionToken = token }
    func setAuthenticated(_ value: Bool) { isAuthenticated = value }
    func logout() { currentUser = nil; sessionToken = ""; isAuthenticated = false }
}

// MARK: - PaymentToken (replaces PaymentInfo)

/// RFC-001 / RFC-002 alignment: Replaces `PaymentInfo` which stored full card
/// PAN, CVV, and expiry in plaintext (PCI-DSS violation).
/// Only a tokenized reference and the last 4 digits are kept; CVV is never stored.
struct PaymentToken: Codable {
    let token: String
    let last4Digits: String
    let brand: String
    let expiryMonth: Int
    let expiryYear: Int
}
