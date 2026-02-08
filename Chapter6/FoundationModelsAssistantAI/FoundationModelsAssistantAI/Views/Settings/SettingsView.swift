//
//  SettingsView.swift
//  FoundationModelsAssistantAI
//
//  AI-DRIVEN SWIFT ARCHITECTURE
//

import SwiftUI

/// A form-based settings interface for configuring language model parameters.
///
/// Provides controls for:
/// - System instructions to guide model behavior
/// - Temperature to control response randomness
/// - Sampling method selection (Greedy, Top-K, Top-P)
/// - Sampling-specific parameters (K value or P threshold)
struct SettingsView: View {

    /// A binding to the model configuration being edited.
    ///
    /// Changes are immediately reflected in the parent view's configuration
    /// and take effect on subsequent model responses.
    @Binding var configuration: ModelConfiguration

    /// Environment action to dismiss this sheet.
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Instructions") {
                    TextField("Instructions", text: $configuration.instructions, axis: .vertical)
                        .lineLimit(2...10)
                        .labelsHidden()
                }

                Section("Response") {
                    LabeledContent("Temperature: \(configuration.temperature, format: .number.precision(.fractionLength(2)))") {
                        Slider(
                            value: $configuration.temperature,
                            in: 0...1
                        )
                    }

                }

                Section("Sampling") {
                    Picker("Method", selection: $configuration.samplingType) {
                        ForEach(SamplingType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)

                    if configuration.samplingType == .topK {
                        LabeledContent("Top K: \(Int(configuration.topK))") {
                            Slider(value: $configuration.topK, in: 1...100, step: 5)
                        }
                    }

                    if configuration.samplingType == .topP {
                        LabeledContent("Top P: \(configuration.topP, format: .number.precision(.fractionLength(2)))") {
                            Slider(value: $configuration.topP, in: 0...1)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .formStyle(.grouped)
            .toolbar {
                Button("Done", role: .close) {
                    dismiss()
                }
            }
        }
    }
}
