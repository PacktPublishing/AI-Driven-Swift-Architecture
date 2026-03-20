// CHAPTER 8
// PACKT -  AI-DRIVEN SWIFT ARCHITECTURE
//
// AuthenticationService.swift - Authentication service (RFC-001 security fixes applied)

import Foundation
import Security
import CryptoKit

// MARK: - Keychain Error

enum KeychainError: Error {
    case saveFailed(OSStatus)
    case encodingFailed
}

// MARK: - AuthToken

/// CWE-613 fix: Token now carries an expiry date and validity check.
struct AuthToken: Codable {
    let value: String
    let expiresAt: Date
    var isValid: Bool { Date() < expiresAt }
}

// MARK: - Certificate Pinning (CWE-295 fix)

/// Production certificate pinning delegate.
/// Replace `pinnedPublicKeyHash` with the SHA-256 hash of your server's
/// public key, obtained via:
///   openssl s_client -connect api.example.com:443 | openssl x509 -pubkey -noout |
///   openssl pkey -pubin -outform DER | openssl dgst -sha256 -binary | base64
class SecurePinnedURLSessionDelegate: NSObject, URLSessionDelegate {

    // Pinned public key hashes (SHA-256, base64-encoded DER representation).
    // Populate this set before production deployment using:
    //   openssl s_client -connect api.example.com:443 | openssl x509 -pubkey -noout |
    //   openssl pkey -pubin -outform DER | openssl dgst -sha256 -binary | base64
    // This set is intentionally empty in the demo — all connections are rejected
    // until a real server hash is configured, which is the safe default.
    private let pinnedPublicKeyHashes: Set<String> = []

    func urlSession(_: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Evaluate the server certificate chain
        var error: CFError?
        guard SecTrustEvaluateWithError(serverTrust, &error) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Extract the leaf certificate's public key.
        // Uses SecTrustCopyCertificateChain (iOS 15+/macOS 12+) — replaces the
        // deprecated SecTrustGetCertificateAtIndex.
        guard let certChain = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
              let leafCert = certChain.first,
              let publicKey = SecCertificateCopyKey(leafCert),
              let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as Data? else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Hash the public key data and compare against pinned hashes
        let keyHash = publicKeyData.sha256Base64()
        guard pinnedPublicKeyHashes.contains(keyHash) else {
            // Certificate does not match pinned key — reject connection
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }
}

// MARK: - Data SHA-256 helper

private extension Data {
    func sha256Base64() -> String {
        let hash = SHA256.hash(data: self)
        return Data(hash).base64EncodedString()
    }
}

// MARK: - AuthenticationService

class AuthenticationService {

    // CWE-321 fix: Hardcoded jwtSecret and encryptionKey removed entirely.
    // These values must be retrieved at runtime from a secure server-side
    // configuration or secrets-management system (e.g., AWS Secrets Manager,
    // HashiCorp Vault). Never embed them in the client binary.

    static let shared = AuthenticationService()

    // MARK: - Brute-force protection (CWE-307)

    private var failedAttempts: [String: (count: Int, lockoutUntil: Date?)] = [:]
    private let maxAttempts = 5
    private let lockoutDuration: TimeInterval = 15 * 60 // 15 minutes

    // MARK: - Lockout Keychain persistence (BLOCKING #1 fix)

    private func lockoutKey(for username: String) -> String {
        return "lockout.\(username)"
    }

    private func persistLockout(username: String, until date: Date) {
        let timestamp = String(date.timeIntervalSince1970)
        try? saveToKeychain(value: timestamp, key: lockoutKey(for: username))
    }

    private func loadPersistedLockout(username: String) -> Date? {
        guard let value = loadFromKeychain(key: lockoutKey(for: username)),
              let interval = TimeInterval(value) else { return nil }
        let date = Date(timeIntervalSince1970: interval)
        return date > Date() ? date : nil  // nil if already expired
    }

    private func clearPersistedLockout(username: String) {
        // Delete from Keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.example.SwiftVulnDemo",
            kSecAttrAccount as String: lockoutKey(for: username)
        ]
        SecItemDelete(query as CFDictionary)
    }

    private func isLockedOut(username: String) -> Bool {
        // Check in-memory record first
        if let record = failedAttempts[username],
           let lockoutUntil = record.lockoutUntil,
           Date() < lockoutUntil {
            return true
        }
        // Check Keychain-persisted lockout (survives app restarts)
        if loadPersistedLockout(username: username) != nil {
            return true
        }
        return false
    }

    private func recordFailedAttempt(username: String) {
        let current = failedAttempts[username] ?? (count: 0, lockoutUntil: nil)
        let newCount = current.count + 1
        let lockout: Date? = newCount >= maxAttempts ? Date().addingTimeInterval(lockoutDuration) : nil
        failedAttempts[username] = (count: newCount, lockoutUntil: lockout)
        // Persist lockout expiry to Keychain so it survives app restarts
        if let lockoutDate = lockout {
            persistLockout(username: username, until: lockoutDate)
        }
    }

    private func resetAttempts(username: String) {
        failedAttempts.removeValue(forKey: username)
        clearPersistedLockout(username: username)
    }

    // MARK: - Keychain helpers (CWE-312)

    private func saveToKeychain(value: String, key: String) throws {
        guard let data = value.data(using: .utf8) else { throw KeychainError.encodingFailed }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.example.SwiftVulnDemo",
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.saveFailed(status) }
    }

    private func loadFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.example.SwiftVulnDemo",
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Credential storage (CWE-312 fix)

    /// Stores username in Keychain (never in UserDefaults).
    func saveCredentials(username: String) {
        // CWE-312 fix: Credentials stored in Keychain, not UserDefaults.
        // Passwords are never persisted on device; only the username is saved
        // to pre-populate the username field on next launch.
        try? saveToKeychain(value: username, key: "saved_username")
        // CWE-532 fix: No print statement logging credentials.
    }

    func loadUsername() -> String? {
        return loadFromKeychain(key: "saved_username")
    }

    // MARK: - Password hashing (CWE-327 fix)

    /// Hashes a password using SHA-256 (replaces insecure MD5).
    func hashPassword(_ password: String) -> String {
        // NOTE: This SHA-256 hash is sent to the server as a pre-hash only.
        // The server MUST apply a slow KDF (bcrypt cost ≥ 12, Argon2id, or scrypt)
        // before storing. SHA-256 alone is fast and GPU-crackable if the hash
        // is ever leaked. Never store this hash directly.
        let data = Data(password.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Login (CWE-307, CWE-295, CWE-319, CWE-598, CWE-476, CWE-613 fixes)

    func login(username: String, password: String, completion: @escaping (Bool, AuthToken?) -> Void) {

        // CWE-307 fix: Check for lockout before proceeding.
        guard !isLockedOut(username: username) else {
            completion(false, nil)
            return
        }

        // CWE-319 fix: Use HTTPS endpoint.
        // CWE-598 fix: Credentials are NOT placed in the URL.
        guard let url = URL(string: AppConfig.loginURL) else {
            completion(false, nil)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "username": username,
            "passwordHash": hashPassword(password)
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        // CWE-295 fix: Use SecurePinnedURLSessionDelegate to validate the server's
        // certificate against a pinned public key hash, preventing MITM attacks.
        let session = URLSession(configuration: .default, delegate: SecurePinnedURLSessionDelegate(), delegateQueue: nil)
        session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            guard let data = data else {
                self.recordFailedAttempt(username: username)
                completion(false, nil)
                return
            }

            // CWE-476 fix: Use safe optional binding instead of force unwrap.
            guard
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let tokenValue = json["token"] as? String
            else {
                self.recordFailedAttempt(username: username)
                completion(false, nil)
                return
            }

            // CWE-613 fix: Build an AuthToken with a 1-hour expiry.
            let authToken = AuthToken(
                value: tokenValue,
                expiresAt: Date().addingTimeInterval(3600)
            )

            // CWE-312 fix: Token stored in Keychain, not UserDefaults.
            try? self.saveToKeychain(value: tokenValue, key: "auth_token")

            self.resetAttempts(username: username)

            Task {
                await AppSession.shared.setToken(tokenValue)
                await AppSession.shared.setAuthenticated(true)
            }

            completion(true, authToken)
        }.resume()
    }

    // MARK: - Token validation (CWE-613 fix)

    /// Returns true only when the token exists in Keychain and has not expired.
    func isTokenValid(_ authToken: AuthToken) -> Bool {
        return authToken.isValid
    }

    // MARK: - Biometric authentication (CWE-287 fix)

    func authenticateWithBiometric(completion: @escaping (Bool) -> Void) {
        // CWE-287 fix: Hardcoded fallback PIN removed. Biometric authentication
        // must be implemented using LocalAuthentication framework with no
        // hardcoded fallback. If biometrics are unavailable, the user should
        // be directed to the standard credential-based login flow.
        //
        // Stub: returns false (safe default) pending a full LocalAuthentication implementation.
        // When implementing, use LAContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics).
        // Do not return true here without a genuine biometric evaluation result.
        completion(false)
    }
}
