// CHAPTER 8
// PACKT -  AI-DRIVEN SWIFT ARCHITECTURE
//
// SwiftVulnDemoApp.swift - App entry point with hardcoded credentials and SSL vulnerabilities

import SwiftUI

@main
struct SwiftVulnDemoApp: App {

    // ⚠️ VULN: Hardcoded credentials in source code (CWE-798)
    let apiKey = "sk-prod-1234567890abcdef1234567890abcdef"
    let adminPassword = "Admin@123!"

    init() {
        // ⚠️ VULN: Sensitive data logged (CWE-532)
        print("App started with API key: \(apiKey)")
        setupApp()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    private func setupApp() {
        // ⚠️ VULN: Disabling SSL validation globally (CWE-295)
        URLSession.shared.configuration.urlCache = nil
    }
}
