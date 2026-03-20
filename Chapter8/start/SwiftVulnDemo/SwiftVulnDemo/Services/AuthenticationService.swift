// CHAPTER 8
// PACKT -  AI-DRIVEN SWIFT ARCHITECTURE
//
// AuthenticationService.swift - Authentication service with multiple security vulnerabilities

import Foundation
import CommonCrypto

class AuthenticationService {

    // ⚠️ VULN: Hardcoded secret key (CWE-321)
    private let jwtSecret = "my_super_secret_jwt_key_2024"
    private let encryptionKey = "1234567890123456" // 16-byte AES key hardcoded

    // ⚠️ VULN: Singleton with mutable shared state (CWE-362)
    static let shared = AuthenticationService()

    // ⚠️ VULN: Credentials stored in UserDefaults (CWE-312)
    func saveCredentials(username: String, password: String) {
        UserDefaults.standard.set(username, forKey: "saved_username")
        UserDefaults.standard.set(password, forKey: "saved_password")
        UserDefaults.standard.set(true, forKey: "is_logged_in")
        print("Credentials saved for user: \(username), password: \(password)") // ⚠️ VULN: CWE-532
    }

    func loadCredentials() -> (String, String)? {
        let username = UserDefaults.standard.string(forKey: "saved_username") ?? ""
        let password = UserDefaults.standard.string(forKey: "saved_password") ?? ""
        return (username, password)
    }

    // ⚠️ VULN: Weak hashing algorithm MD5 (CWE-327)
    func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        data.withUnsafeBytes { bytes in
            _ = CC_MD5(bytes.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    // ⚠️ VULN: No brute-force protection, no rate limiting (CWE-307)
    func login(username: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        // ⚠️ VULN: SQL Injection via string interpolation if used with SQLite (CWE-89)
        let query = "SELECT * FROM users WHERE username='\(username)' AND password='\(password)'"
        print("Executing query: \(query)")

        // ⚠️ VULN: Insecure HTTP (not HTTPS) (CWE-319)
        let url = URL(string: "http://api.example.com/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // ⚠️ VULN: Credentials sent in URL query params (CWE-598)
        let loginURL = "http://api.example.com/login?user=\(username)&pass=\(password)"
        print("Login URL: \(loginURL)")

        let body: [String: Any] = [
            "username": username,
            "password": password // ⚠️ Plaintext in body, no hashing before send
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        // ⚠️ VULN: Certificate pinning disabled — MITM vulnerable (CWE-295)
        let session = URLSession(configuration: .default, delegate: InsecureURLSessionDelegate(), delegateQueue: nil)
        session.dataTask(with: request) { data, response, error in
            if let data = data {
                // ⚠️ VULN: Force unwrap — crash risk (CWE-476)
                let json = try! JSONSerialization.jsonObject(with: data) as! [String: Any]
                let token = json["token"] as! String

                // ⚠️ VULN: Token stored in UserDefaults instead of Keychain (CWE-312)
                UserDefaults.standard.set(token, forKey: "auth_token")
                sessionToken = token
                isAuthenticated = true
                completion(true, token)
            } else {
                completion(false, nil)
            }
        }.resume()
    }

    // ⚠️ VULN: Token never expires, no revocation logic (CWE-613)
    func isTokenValid(_ token: String) -> Bool {
        return token.count > 0 // No expiry check whatsoever
    }

    // ⚠️ VULN: Biometric bypass — fallback to hardcoded PIN (CWE-287)
    func authenticateWithBiometric(completion: @escaping (Bool) -> Void) {
        let hardcodedFallbackPin = "0000"
        print("Fallback PIN: \(hardcodedFallbackPin)")
        completion(true) // Always returns true — no real check
    }
}

// ⚠️ VULN: NSURLSessionDelegate that disables SSL validation (CWE-295)
class InsecureURLSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // ⚠️ Accepts ANY certificate including self-signed / expired
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}
