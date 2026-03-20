// CHAPTER 8
// PACKT -  AI-DRIVEN SWIFT ARCHITECTURE
//
// NetworkService.swift - Network service making insecure HTTP requests with hardcoded secrets

import Foundation

class NetworkService {

    // ⚠️ VULN: Hardcoded internal IP / staging URL exposed (CWE-615)
    private let baseURL = "http://192.168.1.100:8080/api/v1"
    private let stagingURL = "http://staging-internal.corp.example.com"

    // ⚠️ VULN: API secret in source code (CWE-798)
    private let apiSecret = "s3cr3t-4p1-k3y-d0-n0t-sh4r3"

    static let shared = NetworkService()

    // ⚠️ VULN: No input validation or sanitization (CWE-20)
    func fetchUserProfile(userId: String, completion: @escaping (Data?) -> Void) {
        // ⚠️ VULN: No validation — path traversal possible (CWE-22)
        let urlString = "\(baseURL)/users/\(userId)"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        // ⚠️ VULN: Auth token from UserDefaults, not Keychain
        request.addValue(UserDefaults.standard.string(forKey: "auth_token") ?? "", forHTTPHeaderField: "Authorization")
        // ⚠️ VULN: API secret sent in every request header
        request.addValue(apiSecret, forHTTPHeaderField: "X-API-Secret")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            completion(data)
        }.resume()
    }

    // ⚠️ VULN: Sensitive data in URL (CWE-598) + insecure HTTP
    func submitPayment(cardNumber: String, cvv: String, amount: Double) {
        let url = URL(string: "http://payment.example.com/charge?card=\(cardNumber)&cvv=\(cvv)&amount=\(amount)")!
        URLSession.shared.dataTask(with: url).resume()
    }

    // ⚠️ VULN: XML External Entity injection risk if parsing response (CWE-611)
    func fetchXMLData(endpoint: String, completion: @escaping (Data?) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            // No XXE prevention configured on parser
            completion(data)
        }.resume()
    }

    // ⚠️ VULN: Infinite retry loop — DoS risk (CWE-835)
    func fetchWithRetry(url: URL, retryCount: Int = 0) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if error != nil {
                self.fetchWithRetry(url: url, retryCount: retryCount + 1) // No max retry
            }
        }.resume()
    }

    // ⚠️ VULN: Server response not validated — open redirect possible (CWE-601)
    func handleRedirect(response: HTTPURLResponse) {
        if let location = response.allHeaderFields["Location"] as? String,
           let url = URL(string: location) {
            // Follows any redirect without validation
            fetchWithRetry(url: url)
        }
    }
}
