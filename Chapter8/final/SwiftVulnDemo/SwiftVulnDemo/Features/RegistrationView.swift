// CHAPTER 8
// PACKT -  AI-DRIVEN SWIFT ARCHITECTURE
//
// RegistrationView.swift - User registration form collecting and transmitting sensitive PII

import SwiftUI

struct RegistrationView: View {

    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var email: String = ""
    @State private var ssn: String = ""
    @State private var message: String = ""

    var body: some View {
        Form {
            Section("Account") {
                TextField("Username", text: $username)
                // ⚠️ VULN: Password visible in plain TextField (CWE-200)
                TextField("Password", text: $password)
                TextField("Confirm Password", text: $confirmPassword)
                TextField("Email", text: $email)
            }

            Section("Personal Info") {
                // ⚠️ VULN: SSN collected unnecessarily (CWE-359)
                TextField("Social Security Number", text: $ssn)
                    .keyboardType(.numberPad)
            }

            Text(message).foregroundColor(.red)

            Button("Register") {
                register()
            }
        }
        .navigationTitle("Create Account")
    }

    private func register() {
        // ⚠️ VULN: No password strength requirements (CWE-521)
        guard !username.isEmpty && !password.isEmpty else {
            message = "Fill all fields"
            return
        }

        // ⚠️ VULN: Passwords compared with == (timing attack, CWE-208)
        guard password == confirmPassword else {
            // ⚠️ VULN: Returns both passwords in error log (CWE-532)
            print("Password mismatch: \(password) != \(confirmPassword)")
            message = "Passwords don't match"
            return
        }

        // ⚠️ VULN: Weak MD5 hash before sending to server
        let hashedPassword = AuthenticationService.shared.hashPassword(password)

        // ⚠️ VULN: SSN sent in request body without encryption
        let registrationData: [String: Any] = [
            "username": username,
            "password": hashedPassword,
            "email": email,
            "ssn": ssn // PII sent to server
        ]

        // ⚠️ VULN: Insecure HTTP endpoint
        guard let registrationURL = URL(string: AppConfig.registerURL) else { return }
        var request = URLRequest(url: registrationURL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: registrationData)
        URLSession.shared.dataTask(with: request).resume()

        message = "Account created!"
    }
}

#Preview {
    RegistrationView()
}
