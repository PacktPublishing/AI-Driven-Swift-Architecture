// CHAPTER 8
// PACKT -  AI-DRIVEN SWIFT ARCHITECTURE
//
// AppConfig.swift - Centralized URL configuration
// Satisfies swift:S1075 — URIs loaded from a single customizable source.

import Foundation

enum AppConfig {

    // MARK: - API Base URL
    // Loaded from Info.plist key "API_BASE_URL" (set via .xcconfig per environment).
    // Falls back to the default endpoint when the build-time variable is absent.
    static let apiBaseURL: String = {
        if let value = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
           !value.isEmpty, value != "$(API_BASE_URL)" {
            return value
        }
        return defaultAPIBaseURL
    }()

    // MARK: - Named URL Constants
    // Centralised here so they can be overridden via xcconfig / Info.plist
    // without modifying source code.

    /// Default REST API base (v1).
    static let defaultAPIBaseURL  = "https://api.example.com/v1"

    /// Staging environment base URL.
    static let stagingBaseURL      = "https://staging.example.com"

    /// Payment processing endpoint.
    static let paymentChargeURL    = "https://payment.example.com/charge"

    /// Login endpoint.
    static let loginURL            = "https://api.example.com/login"

    /// Registration endpoint.
    static let registerURL         = "https://api.example.com/register"
}
