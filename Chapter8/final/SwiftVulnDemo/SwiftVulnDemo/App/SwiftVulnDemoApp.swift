// CHAPTER 8
// PACKT -  AI-DRIVEN SWIFT ARCHITECTURE
//
// SwiftVulnDemoApp.swift - App entry point (RFC-002 security fixes applied)
// Fixes: CWE-798 (hardcoded secrets), CWE-532 (sensitive data logging)

import SwiftUI

@main
struct SwiftVulnDemoApp: App {

    // CWE-798 fix: Hardcoded apiKey and adminPassword removed entirely.
    // API keys must be loaded at runtime from a secure configuration:
    // - Server-issued short-lived tokens via a device-attestation flow
    // - Secrets embedded via provisioning profile entitlements
    // Never hardcode production credentials in source code.

    init() {
        // CWE-532 fix: print statement logging the API key has been removed.
        DataStorageService.setupCache() // Disable disk URL cache (CWE-312)
        setupApp()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    private func setupApp() {
        // CWE-295 fix: URLSession.shared.configuration.urlCache = nil line removed.
        // Cache is configured via DataStorageService.setupCache() above, which uses
        // a memory-only URLCache (diskCapacity: 0) to prevent sensitive API
        // responses from being written to disk.
    }
}
