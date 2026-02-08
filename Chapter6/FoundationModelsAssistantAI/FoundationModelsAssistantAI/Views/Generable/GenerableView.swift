//
//  GenerableView.swift
//  FoundationModelsAssistantAI
//
//  AI-DRIVEN SWIFT ARCHITECTURE
//

import FoundationModels
import SwiftUI

/// Demonstrates structured response generation using `@Generable` models.
///
/// This view lets the user select a ``CustomModelType`` from the toolbar,
/// then streams a typed response from `LanguageModelSession.streamResponse(to:generating:options:)`.
/// The partial results are formatted into Markdown and displayed as they arrive.
///
/// Structured generation constrains the model to return data conforming to
/// a `@Generable` schema, ensuring predictable, typed output rather than
/// free-form text.
struct GenerableView: View {

    // MARK: - State Properties

    /// The active language model session used for structured generation requests.
    ///
    /// Recreated when system instructions change to apply the new prompt context.
    @State private var session = LanguageModelSession()

    /// Indicates whether the model is currently generating a structured response.
    ///
    /// Disables the toolbar menu items while a generation is in progress.
    @State private var isResponding = false

    /// Controls the presentation of the settings sheet.
    @State private var showingSettings = false

    /// The current model configuration including instructions and sampling parameters.
    ///
    /// Changes to `instructions` trigger session recreation to apply new system prompts.
    @State private var configuration = ModelConfiguration()

    /// The Markdown-formatted output text displayed in the scroll view.
    ///
    /// Updated incrementally during streaming as partial results arrive.
    /// Cleared at the start of each new generation request.
    @State private var output = ""

    var body: some View {
        ScrollView {
            if output.isEmpty {
                ContentUnavailableView(
                    "No Content Yet",
                    systemImage: "doc.text",
                    description: Text("Select a model type from the Generate menu to get started.")
                )
            } else {
                VStack {
                    Text(.init(output))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .contentMargins(.all, 16, for: .scrollContent)
        .navigationTitle("Custom Models")
        .toolbar {
            Menu("Generate") {
                ForEach(CustomModelType.allCases) { type in
                    Button(type.rawValue, systemImage: type.systemImage) {
                        generate(type)
                    }
                    .labelStyle(.titleAndIcon)
                    .buttonStyle(.bordered)
                    .disabled(isResponding)
                }
            }

            Button("Settings", systemImage: "gearshape") {
                showingSettings = true
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(
                configuration: $configuration
            )
        }
        .onChange(of: configuration.instructions) {
            if configuration.instructions.isEmpty {
                session = LanguageModelSession()
            } else {
                session = LanguageModelSession(instructions: configuration.instructions)
            }
        }
    }

    /// Dispatches to the appropriate generator function based on the selected type.
    /// - Parameter type: The type of content to generate.
    func generate(_ type: CustomModelType) {
        switch type {
        case .countryRecommendation:

            generateCountryRecommendation()

        case .quiz:

            generateQuiz()

        case .storyIdea:

            generateStoryIdea()
        }
    }

    /// Streams a structured generation request and formats partial results for display.
    ///
    /// Uses `LanguageModelSession.streamResponse(to:generating:options:)` to receive
    /// incremental `PartiallyGenerated` values. Each partial is passed through the
    /// `format` closure to produce a human-readable Markdown string.
    ///
    /// - Parameters:
    ///   - prompt: The text prompt sent to the language model.
    ///   - type: The `@Generable` type that defines the expected output schema.
    ///   - format: A closure that converts a `PartiallyGenerated` value into a display string.
    func streamGeneration<T: Generable>(
        prompt: String,
        type: T.Type,
        format: @escaping (T.PartiallyGenerated) -> String
    ) {
        isResponding = true
        output = ""

        Task {
            do {
                for try await partial in session.streamResponse(
                    to: prompt,
                    generating: type,
                    options: configuration.generationOptions
                ) {
                    output = format(partial.content)
                }
            } catch {
                output = "Error: \(error.localizedDescription)"
            }

            isResponding = false
        }
    }
}
