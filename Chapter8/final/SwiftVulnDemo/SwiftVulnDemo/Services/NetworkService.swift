// CHAPTER 8
// PACKT -  AI-DRIVEN SWIFT ARCHITECTURE
//
// NetworkService.swift - RFC-002: secure network service
// Fixes: CWE-319, CWE-598, CWE-798, CWE-312, CWE-835, CWE-601, CWE-22

import Foundation
import Security

class NetworkService {

    // CWE-798 / environment fix: base URL loaded from Info.plist (set via xcconfig per environment)
    // Add "API_BASE_URL" key to Info.plist pointing to $(API_BASE_URL) from xcconfig.
    // Fallback to staging URL if not configured.
    private let baseURL: String = AppConfig.apiBaseURL

    private let stagingURL: String = AppConfig.stagingBaseURL

    // CWE-798 fix: API keys must be loaded from a secure configuration (e.g.,
    // a provisioning-profile-embedded secret, a server-issued short-lived token,
    // or a device-attestation flow) — never hardcoded in source code.

    static let shared = NetworkService()

    // MARK: - Keychain Helper (CWE-312 fix)

    /// Reads a string value from Keychain for the given account key.
    private func loadFromKeychain(account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.example.SwiftVulnDemo",
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - User Profile (CWE-22 + CWE-312 fix)

    func fetchUserProfile(userId: String, completion: @escaping (Data?) -> Void) {
        // CWE-22 fix: percent-encode userId before interpolating into the URL path.
        guard let encodedId = userId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            completion(nil)
            return
        }
        let urlString = "\(baseURL)/users/\(encodedId)"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)

        // CWE-312 fix: auth token loaded from Keychain, not UserDefaults.
        let authToken = loadFromKeychain(account: "auth_token") ?? ""
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        // The hardcoded apiSecret header has been removed (CWE-798 fix).

        URLSession.shared.dataTask(with: request) { data, _, _ in
            completion(data)
        }.resume()
    }

    // MARK: - Payment Submission (CWE-319 / CWE-598 fix)

    /// Submits a tokenised payment over HTTPS.
    /// IMPORTANT: The `paymentToken` MUST be an opaque token from a PCI-compliant
    /// client-side SDK (Stripe Elements, Adyen Drop-In, etc.) — never a raw PAN.
    /// Raw card numbers must never reach the app server; the SDK tokenises them
    /// client-side before they leave the device.
    func submitPayment(paymentToken: String, amount: Double) {
        guard let url = URL(string: AppConfig.paymentChargeURL) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        let body: [String: Any] = [
            "paymentToken": paymentToken,  // Opaque SDK token, NOT a raw PAN
            "amount": amount
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request).resume()
    }

    // MARK: - XML Data Fetch

    func fetchXMLData(endpoint: String, completion: @escaping (Data?) -> Void) {
        guard let encodedEndpoint = endpoint.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "\(baseURL)/\(encodedEndpoint)") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            completion(data)
        }.resume()
    }

    // MARK: - Retry (CWE-835 fix)

    /// Fetches a URL with automatic retry on failure, capped at 3 attempts.
    func fetchWithRetry(url: URL, retryCount: Int = 0) {
        // CWE-835 fix: guard against infinite retry loop.
        guard retryCount < 3 else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if error != nil {
                self.fetchWithRetry(url: url, retryCount: retryCount + 1)
            }
        }.resume()
    }

    // MARK: - Redirect Handling (CWE-601 fix)

    /// Allowlist of trusted redirect hosts.
    private let allowedRedirectHosts: Set<String> = [
        "api.example.com",
        "payment.example.com"
    ]

    /// Follows redirect Location headers only when the target host is in the allowlist.
    func handleRedirect(response: HTTPURLResponse) {
        guard
            let location = response.allHeaderFields["Location"] as? String,
            let url = URL(string: location),
            let host = url.host,
            allowedRedirectHosts.contains(host)   // CWE-601 fix: validate redirect host
        else {
            // Redirect rejected — host not in allowlist or URL is malformed.
            return
        }
        fetchWithRetry(url: url)
    }
}
