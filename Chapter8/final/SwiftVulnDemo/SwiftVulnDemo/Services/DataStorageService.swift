// CHAPTER 8
// PACKT -  AI-DRIVEN SWIFT ARCHITECTURE
//
// DataStorageService.swift - RFC-002: PCI-compliant data storage
// Fixes: CWE-312, CWE-532, CWE-200, CWE-377

import Foundation
#if canImport(UIKit)
import UIKit
#endif
import CryptoKit
import Security
import os.log

class DataStorageService {

    // Secure system logger — does not write to world-readable files (CWE-532 fix)
    private static let logger = Logger(subsystem: "com.example.SwiftVulnDemo", category: "DataStorage")

    // MARK: - Encryption Key Management

    /// Loads an existing AES-256 key from Keychain or generates and stores a new one.
    private static func loadOrCreateEncryptionKey() throws -> SymmetricKey {
        let keychainKey = "com.example.SwiftVulnDemo.storageKey"
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.example.SwiftVulnDemo",
            kSecAttrAccount as String: keychainKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecSuccess, let data = result as? Data {
            return SymmetricKey(data: data)
        }
        // Generate a new 256-bit key and persist it in Keychain
        let newKey = SymmetricKey(size: .bits256)
        let keyData = newKey.withUnsafeBytes { Data($0) }
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.example.SwiftVulnDemo",
            kSecAttrAccount as String: keychainKey,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        SecItemDelete(addQuery as CFDictionary)
        SecItemAdd(addQuery as CFDictionary, nil)
        return newKey
    }

    // MARK: - Log Sanitization

    /// Redacts card numbers and CVV values before logging (CWE-532 fix).
    private static func sanitize(_ message: String) -> String {
        // Redact 13-19 digit sequences (card numbers)
        var result = message.replacingOccurrences(of: "\\b\\d{13,19}\\b",
                                                   with: "****",
                                                   options: .regularExpression)
        // Redact 3-4 digit sequences near cvv/cvc labels
        result = result.replacingOccurrences(of: "(?i)(cvv|cvc)[=: ]+\\d{3,4}",
                                              with: "$1=****",
                                              options: .regularExpression)
        return result
    }

    // MARK: - User Data

    /// Saves user data with .completeFileProtection and excludes from iCloud backup (CWE-312 fix).
    /// NOTE: Truly sensitive data such as SSNs and card numbers must be stored via Keychain
    ///       or handled server-side — never in local files, even when encrypted at rest.
    static func saveUserDataToFile(user: User) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(user) {
            var path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("user_data.json")

            // Write with strongest data-protection class (CWE-312 fix)
            try? data.write(to: path, options: [.atomic, .completeFileProtection])

            // Exclude file from iCloud / iTunes backup (PCI-DSS 3.2 / CWE-312 fix)
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try? path.setResourceValues(resourceValues)

            logger.info("User data saved successfully.")
        }
    }

    // MARK: - Payment Token Storage

    /// Stores a tokenized payment reference using AES-GCM encryption (CWE-312 fix).
    /// Per PCI-DSS 3.4: raw card numbers, CVV, and full PANs must NEVER be stored
    /// post-authorisation. Only a PaymentToken (opaque reference from your payment
    /// processor) may be persisted.
    /// NOTE: PaymentToken is defined in User.swift (Security Dev A's responsibility).
    static func savePaymentToken(_ token: PaymentToken) {
        guard let tokenData = try? JSONEncoder().encode(token) else { return }

        do {
            let key = try loadOrCreateEncryptionKey()
            let sealedBox = try AES.GCM.seal(tokenData, using: key)
            guard let encrypted = sealedBox.combined else { return }

            var path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("payment_token.enc")

            // Write with strongest data-protection class (CWE-312 fix)
            try encrypted.write(to: path, options: [.atomic, .completeFileProtection])

            // Exclude from iCloud / iTunes backup (PCI-DSS 3.2)
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try path.setResourceValues(resourceValues)

            logger.info("Payment token saved securely.")
        } catch {
            logger.error("Failed to save payment token: \(error.localizedDescription, privacy: .public)")
        }
    }

    // MARK: - Logging (CWE-532 fix)

    /// Secure logging via os.Logger. Messages are sanitized to remove card/CVV data.
    /// The old file-based debug log has been removed — it wrote to a world-readable
    /// path and could contain sensitive data.
    static func log(_ message: String) {
        let safe = sanitize(message)
        logger.log("[\(Date(), privacy: .public)] \(safe, privacy: .public)")
    }

    // MARK: - Clipboard (CWE-200 fix)

    /// Copies a value to the clipboard and schedules a clear after `seconds` seconds.
    /// Renamed from `copyCardNumberToClipboard` — callers should avoid placing full
    /// PANs on the clipboard; prefer masked or last-4 values only.
    static func copyToClipboard(_ value: String, clearAfter seconds: TimeInterval = 30) {
        #if canImport(UIKit)
        UIPasteboard.general.string = value
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            // Only clear if our value is still on the clipboard
            if UIPasteboard.general.string == value {
                UIPasteboard.general.string = ""
            }
        }
        #endif
    }

    // MARK: - Temp Files (CWE-377 fix)

    /// Writes content to a temp file with a UUID-based (unpredictable) filename.
    static func writeTempFile(content: String) -> URL {
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString) // CWE-377 fix: unpredictable name
        if let data = content.data(using: .utf8) {
            #if os(iOS)
            try? data.write(to: tempURL, options: [.atomic, .completeFileProtection])
            #else
            try? data.write(to: tempURL, options: .atomic)
            #endif
        }
        return tempURL
    }

    // MARK: - URL Cache (CWE-312 fix)

    /// Configures URLCache with memory-only storage so sensitive API responses
    /// (including auth tokens) are never written to disk.
    static func setupCache() {
        // diskCapacity: 0 and no diskPath — API responses must not be cached on disk
        let cache = URLCache(memoryCapacity: 4_000_000,
                            diskCapacity: 0,
                            diskPath: nil)
        URLCache.shared = cache
    }
}
