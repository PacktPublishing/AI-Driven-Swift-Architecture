// CHAPTER 8
// PACKT -  AI-DRIVEN SWIFT ARCHITECTURE
//
// LoginView.swift - Login UI with password visibility and debug backdoor access

import SwiftUI

struct LoginView: View {

    // ⚠️ VULN: Password stored in @State (in-memory plaintext, visible in view hierarchy)
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false
    @State private var errorMessage: String = ""

    // ⚠️ VULN: Hardcoded admin backdoor credentials (CWE-798)
    private let backdoorUsername = "admin_debug"
    private let backdoorPassword = "debug2024!"

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "lock.shield")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)

                Text("SwiftVuln Demo")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("⚠️ AI-Generated — Intentionally Vulnerable")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack(spacing: 12) {
                    TextField("Username", text: $username)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)

                    // ⚠️ VULN: Using TextField instead of SecureField (password visible)
                    TextField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .padding(.horizontal)

                Button(action: login) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Button("Debug Login (Admin)") {
                    // ⚠️ VULN: Debug backdoor left in production code (CWE-912)
                    username = backdoorUsername
                    password = backdoorPassword
                    login()
                }
                .foregroundColor(.red)
                .font(.caption)

                NavigationLink("Create Account", destination: RegistrationView())
                    .font(.callout)
            }
            .padding()
            .navigationDestination(isPresented: $isLoggedIn) {
                DashboardView()
            }
        }
        .onAppear {
            // ⚠️ VULN: Auto-fill from UserDefaults on appear
            if let (u, p) = AuthenticationService.shared.loadCredentials() {
                username = u
                password = p
            }
        }
    }

    private func login() {
        // ⚠️ VULN: No input length validation, no sanitization
        AuthenticationService.shared.login(username: username, password: password) { success, token in
            DispatchQueue.main.async {
                if success {
                    // ⚠️ VULN: Saving credentials unencrypted
                    AuthenticationService.shared.saveCredentials(username: username, password: password)
                    isLoggedIn = true
                } else {
                    // ⚠️ VULN: Verbose error reveals whether username or password was wrong (CWE-209)
                    errorMessage = "Login failed for user '\(username)': Invalid password"
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
