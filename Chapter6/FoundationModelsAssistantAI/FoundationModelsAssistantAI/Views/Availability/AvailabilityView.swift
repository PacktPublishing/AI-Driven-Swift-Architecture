//
//  AvailabilityView.swift
//  FoundationModelsAssistantAI
//
//  AI-DRIVEN SWIFT ARCHITECTURE
//

import FoundationModels
import SwiftUI

/// Displays the availability status of the Foundation Models system language model.
///
/// Shows different informational content based on the unavailability reason:
/// - Device not eligible (hardware requirements not met)
/// - Apple Intelligence not enabled (user action required)
/// - Unknown status (fallback for other cases)
struct AvailabilityView: View {

    /// The system language model instance used to check availability.
    private var model: SystemLanguageModel {
        .default
    }

    var body: some View {
        Form {
            Section {
                availabilityStatusView
            } header: {
                Text("Model Availability")
            } footer: {
                Text("Foundation Models run on-device for privacy and speed. Your data never leaves your device.")
                    .font(.caption)
            }
            .navigationTitle("Availability")
            .formStyle(.grouped)
        }
    }

    @ViewBuilder
    private var availabilityStatusView: some View {
        switch model.availability {
        /// Should not happen: view is only presented when unavailable
        case .available:

            EmptyView()

        case .unavailable(.deviceNotEligible):
            VStack(alignment: .leading, spacing: 12) {
                Label(
                    "Device Not Eligible",
                    systemImage: "xmark.circle.fill"
                )
                .foregroundStyle(.red)
                .font(.headline)

                Text("This device doesn't support Apple Intelligence")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                InfoBox(
                    icon: "exclamationmark.triangle.fill",
                    color: .red,
                    title: "Upgrade Required",
                    description: "Foundation Models require iPhone 15 Pro or later, iPad with M1 chip or later, or Mac with Apple Silicon."
                )
            }
        case .unavailable(.appleIntelligenceNotEnabled):

            VStack(alignment: .leading, spacing: 12) {
                Label(
                    "Apple Intelligence Not Enabled",
                    systemImage: "exclamationmark.triangle.fill"
                )
                .foregroundStyle(.orange)
                .font(.headline)

                Text("Your device supports AI, but it's not enabled yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                InfoBox(
                    icon: "gearshape.fill",
                    color: .orange,
                    title: "How to Enable",
                    description: "Go to Settings → Apple Intelligence & Siri → Toggle 'Apple Intelligence' ON. The model will download (~2GB)."
                )
            }
        default:
            VStack(alignment: .leading, spacing: 12) {
                Label("Model Unavailable", systemImage: "questionmark.circle.fill")
                    .foregroundStyle(.secondary)
                    .font(.headline)

                Text("Unable to determine availability")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                InfoBox(
                    icon: "info.circle.fill",
                    color: .gray,
                    title: "Unknown Status",
                    description: "Please check your iOS version (requires 18.2+) and device compatibility."
                )
            }
        }
    }
}

/// A styled information box used to display status details and instructions.
///
/// Presents an icon, title, and description in a rounded container with
/// a tinted background matching the icon color.
private struct InfoBox: View {

    /// The SF Symbol name for the leading icon.
    let icon: String

    /// The tint color applied to the icon and background.
    let color: Color

    /// The bold headline text.
    let title: String

    /// The explanatory body text.
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.bold())
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}
