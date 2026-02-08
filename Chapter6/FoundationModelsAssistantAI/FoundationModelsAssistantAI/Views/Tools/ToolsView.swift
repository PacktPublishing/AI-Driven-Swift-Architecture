//
//  ToolsView.swift
//  FoundationModelsAssistantAI
//
//  AI-DRIVEN SWIFT ARCHITECTURE
//

import SwiftUI
import FoundationModels

/// Demonstrates Foundation Models tool-calling capabilities.
///
/// This view provides:
/// - A picker to select between available tools (Calendar, Weather)
/// - A chat-like interface where the model can invoke the selected tool
/// - Example prompts to demonstrate each tool's capabilities
/// - Settings for configuring model parameters
///
/// Tool calling allows `LanguageModelSession` to invoke developer-defined functions
/// during generation, enabling the model to interact with external data sources
/// and perform actions beyond text generation.
struct ToolsView: View {

    // MARK: - State Properties

    /// The active language model session used for tool-calling requests.
    ///
    /// Recreated when system instructions change to apply the new prompt context.
    @State private var session = LanguageModelSession()

    /// Indicates whether the model is currently generating a response.
    ///
    /// Disables input while a generation is in progress.
    @State private var isResponding = false

    /// Controls the presentation of the settings sheet.
    @State private var showingSettings = false

    /// The current model configuration including instructions and sampling parameters.
    ///
    /// Changes to `instructions` trigger session recreation to apply new system prompts.
    @State private var configuration = ModelConfiguration()

    /// The currently selected tool type.
    @State private var selectedTool: ToolType = .weather

    /// The array of messages representing the conversation history.
    @State private var messages = [Message]()

    /// The current text in the input field.
    @State private var input = ""

    var body: some View {
        if SystemLanguageModel.default.isAvailable {
            NavigationStack {
                VStack(spacing: 0) {
                    toolInfoHeader

                    if messages.isEmpty {
                        examplePromptsView
                    } else {
                        MessagesListView(
                            messages: messages,
                            isResponding: isResponding
                        )
                    }

                    InputView(
                        text: $input,
                        placeholder: "Ask about \(selectedTool.rawValue.lowercased())...",
                        isDisabled: isResponding,
                        onSubmit: sendMessage
                    )
                }
                .navigationTitle("Tools")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Picker("Tool", selection: $selectedTool) {
                            ForEach(ToolType.allCases) { tool in
                                Label(tool.rawValue, systemImage: tool.systemImage)
                                    .tag(tool)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    ToolbarItem(placement: .secondaryAction) {
                        Button("Clear", systemImage: "trash") {
                            messages.removeAll()
                            session = createSession()
                        }
                        .disabled(messages.isEmpty)
                    }

                    ToolbarItem(placement: .secondaryAction) {
                        Button("Settings", systemImage: "gearshape") {
                            showingSettings = true
                        }
                    }
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView(configuration: $configuration)
                }
                .onChange(of: configuration.instructions) {
                    session = createSession()
                }
                .onChange(of: selectedTool) {
                    messages.removeAll()
                    session = createSession()
                }
            }
        } else {
            AvailabilityView()
        }
    }

    // MARK: - Subviews

    /// Header showing the currently selected tool and its description.
    private var toolInfoHeader: some View {
        HStack {
            Image(systemName: selectedTool.systemImage)
                .font(.title2)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text(selectedTool.rawValue)
                    .font(.headline)
                Text(selectedTool.toolDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    /// View showing example prompts when the conversation is empty.
    private var examplePromptsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Try asking:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top)

                ForEach(selectedTool.examplePrompts, id: \.self) { prompt in
                    Button {
                        input = prompt
                        sendMessage()
                    } label: {
                        HStack {
                            Image(systemName: "text.bubble")
                                .foregroundStyle(.secondary)
                            Text(prompt)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundStyle(.tint)
                        }
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }

    // MARK: - Methods

    /// Creates a new session with the appropriate tool and instructions.
    private func createSession() -> LanguageModelSession {
        let baseInstructions = configuration.instructions.isEmpty
            ? "You are a helpful assistant."
            : configuration.instructions

        let toolInstructions = """
        \(baseInstructions)

        You have access to the \(selectedTool.rawValue) tool. Use it to help the user with their requests.
        Always use the tool when the user asks about \(selectedTool.rawValue.lowercased())-related information.
        """

        let tools: [any Tool] = switch selectedTool {
        case .calendar:
            [CalendarTool()]
        case .weather:
            [WeatherTool()]
        }

        return LanguageModelSession(tools: tools, instructions: toolInstructions)
    }

    /// Processes user input and initiates response generation with tool calling.
    func sendMessage() {
        guard input.isEmpty == false else { return }

        let prompt = input.trimmingCharacters(in: .whitespacesAndNewlines)

        messages.append(
            Message(
                content: prompt,
                isUser: true
            )
        )

        input = ""

        Task {
            await generateResponseWithTool(for: prompt)
        }
    }

    /// Generates a response using the selected tool.
    ///
    /// Uses the session's `streamResponse(to:tools:options:)` method to allow
    /// the model to invoke the appropriate tool during generation.
    ///
    /// - Parameter prompt: The user's prompt text.
    func generateResponseWithTool(for prompt: String) async {
        isResponding = true
        defer { isResponding = false }

        let messageIndex = messages.count

        messages.append(
            Message(
                content: "",
                isUser: false
            )
        )

        do {
            for try await partial in session.streamResponse(
                to: prompt,
                options: configuration.generationOptions
            ) {
                messages[messageIndex] = Message(
                    content: partial.content,
                    isUser: false
                )
            }
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
            messages[messageIndex] = Message(
                content: "This conversation is too long. Please clear and start a new session.",
                isUser: false
            )
        } catch LanguageModelSession.GenerationError.unsupportedLanguageOrLocale {
            messages[messageIndex] = Message(
                content: "This language is not supported. Please try English or another supported language.",
                isUser: false
            )
        } catch {
            messages[messageIndex] = Message(
                content: "Error: \(error.localizedDescription)",
                isUser: false
            )
        }
    }
}
