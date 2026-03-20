// CHAPTER 8
// PACKT -  AI-DRIVEN SWIFT ARCHITECTURE
//
// DataStorageService.swift - Data storage with unencrypted sensitive information handling

import Foundation
import UIKit

class DataStorageService {

    // ⚠️ VULN: Sensitive files written without encryption (CWE-312)
    static func saveUserDataToFile(user: User) {
        let encoder = JSONEncoder()

        // ⚠️ VULN: No data protection attribute set
        if let data = try? encoder.encode(user) {
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("user_data.json")

            // ⚠️ VULN: Sensitive PII/financial data saved to unprotected file
            try? data.write(to: path, options: .atomic)
            print("User data saved to: \(path.absoluteString)") // ⚠️ CWE-532: path leak
        }
    }

    // ⚠️ VULN: Backup not excluded — sensitive data in iCloud backup (CWE-312)
    static func savePaymentInfo(_ payment: PaymentInfo) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(payment) {
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("payment_info.json")
            // Missing: .isExcludedFromBackupKey = true
            try? data.write(to: path)
        }
    }

    // ⚠️ VULN: Logs written to a world-readable file (CWE-532)
    static func log(_ message: String) {
        let logPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("app_debug.log")
        let entry = "[\(Date())] \(message)\n"
        if let data = entry.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: logPath.path) {
                if let handle = try? FileHandle(forWritingTo: logPath) {
                    handle.seekToEndOfFile()
                    handle.write(data)
                    handle.closeFile()
                }
            } else {
                try? data.write(to: logPath, options: .atomic)
            }
        }
    }

    // ⚠️ VULN: Clipboard not cleared after copy — data leaks to other apps (CWE-200)
    static func copyCardNumberToClipboard(_ cardNumber: String) {
        UIPasteboard.general.string = cardNumber
        // Missing: schedule clipboard clear after N seconds
    }

    // ⚠️ VULN: Insecure temporary file with predictable name (CWE-377)
    static func writeTempFile(content: String) -> URL {
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("temp_export.txt") // predictable filename
        try? content.write(to: tempURL, atomically: true, encoding: .utf8)
        return tempURL
    }

    // ⚠️ VULN: Cache not encrypted, sensitive data remains on disk (CWE-312)
    static func setupCache() {
        let cache = URLCache(memoryCapacity: 50_000_000,
                            diskCapacity: 200_000_000,
                            diskPath: "api_cache") // Caches API responses including auth tokens
        URLCache.shared = cache
    }
}
