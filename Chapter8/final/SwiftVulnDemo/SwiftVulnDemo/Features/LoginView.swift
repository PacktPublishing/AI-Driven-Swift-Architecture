// CHAPTER 8
// PACKT -  AI-DRIVEN SWIFT ARCHITECTURE
//
// LoginView.swift - Login UI (RFC-001 security fixes applied)

import SwiftUI

struct LoginView: View {

    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false
    @State private var errorMessage: String = ""

    // CWE-798 fix: backdoorUsername and backdoorPassword constants removed.
    // The "Debug Login (Admin)" button has been removed entirely.

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "lock.shield")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)

                Text("SwiftVuln Demo")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                VStack(spacing: 12) {
                    TextField("Username", text: $username)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)

                    // CWE-200 fix: SecureField masks password input.
                    SecureField("Password", text: $password)
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

                // CWE-798 fix: "Debug Login (Admin)" button removed.

                NavigationLink("Create Account", destination: RegistrationView())
                    .font(.callout)
            }
            .padding()
            .navigationDestination(isPresented: $isLoggedIn) {
                DashboardView()
            }
        }
        // CWE-312 fix: .onAppear block that loaded credentials from UserDefaults removed.
    }

    private func login() {
        AuthenticationService.shared.login(username: username, password: password) { success, token in
            DispatchQueue.main.async {
                if success {
                    // CWE-312 fix: saveCredentials no longer persists the password.
                    // Only the username is saved (to Keychain) for UX convenience.
                    AuthenticationService.shared.saveCredentials(username: username)
                    isLoggedIn = true
                } else {
                    // CWE-209 fix: Generic error message that does not reveal
                    // whether the username or password was incorrect.
                    errorMessage = "Invalid credentials. Please try again."
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
