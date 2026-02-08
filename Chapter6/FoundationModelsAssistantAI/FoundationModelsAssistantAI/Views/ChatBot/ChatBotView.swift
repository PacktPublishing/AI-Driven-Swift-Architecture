//
//  ChatBotView.swift
//  FoundationModelsAssistantAI
//
//  AI-DRIVEN SWIFT ARCHITECTURE
//

import SwiftUI
import FoundationModels

/// The main chat interface for interacting with the Foundation Models language model.
///
/// This view provides:
/// - A scrollable message history displaying the conversation
/// - A text input field for composing messages
/// - Access to settings for configuring model parameters
/// - Automatic session recovery when context limits are exceeded
///
/// The view conditionally renders based on `SystemLanguageModel.default.isAvailable`,
/// showing `AvailabilityView` when the model is not available.
struct ChatBotView: View {

    // MARK: - State Properties

    /// The active language model session that maintains conversation context.
    ///
    /// Recreated when system instructions change or when recovering from
    /// context window overflow.
    @State private var session = LanguageModelSession()

    /// Indicates whether the model is currently generating a response.
    ///
    /// Used to disable input and show a loading indicator during generation.
    @State private var isResponding = false

    /// Controls the presentation of the settings sheet.
    @State private var showingSettings = false

    /// The current model configuration including instructions and sampling parameters.
    ///
    /// Changes to `instructions` trigger session recreation to apply new system prompts.
    @State private var configuration = ModelConfiguration()

    /// The array of messages representing the conversation history.
    ///
    /// New messages are appended during `sendMessage()` and updated during
    /// streaming responses.
    @State private var messages = [Message]()

    /// The current text in the input field.
    ///
    /// Cleared after the user sends a message.
    @State private var input = ""

    var body: some View {
        if SystemLanguageModel.default.isAvailable {
            NavigationStack {
                VStack(spacing: 0) {
                    MessagesListView(
                        messages: messages,
                        isResponding: isResponding
                    )

                    InputView(
                        text: $input,
                        placeholder: "Message",
                        isDisabled: isResponding,
                        onSubmit: sendMessage
                    )
                }
                .navigationTitle("Foundation Models Assistant")
                .toolbar {
                    Button("Settings", systemImage: "gearshape") {
                        showingSettings = true
                    }
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView(configuration: $configuration)
                }
                .onChange(of: configuration.instructions) {
                    if configuration.instructions.isEmpty {
                        session = LanguageModelSession()
                    } else {
                        session = LanguageModelSession(instructions: configuration.instructions)
                    }
                }
            }
        } else {
            AvailabilityView()
        }
    }

    // MARK: - Methods

    /// Processes user input and initiates response generation.
    ///
    /// Validates that input is non-empty, appends the user's message to the
    /// conversation history, clears the input field, and triggers streaming
    /// response generation.
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

            await generateStreamingResponse(for: prompt)
        }

    }

    /// Generates a complete response in one request.
    ///
    /// Uses the session's `respond(to:options:)` method to get a full response
    /// before displaying it. Shows a loading indicator during generation.
    ///
    /// - Parameter input: The user's prompt text.
    func generateStandardResponse(for input: String) async {
        isResponding = true

        defer { isResponding = false }

        do {

            let response = try await session.respond(
                to: input,
                options: configuration.generationOptions
            )

            messages.append(
                Message(
                    content: response.content,
                    isUser: false
                )
            )
        } catch {

            messages.append(
                Message(
                    content: "Sorry, I couldn't generate a response.",
                    isUser: false
                )
            )

        }

    }

    /// Generates a response with real-time streaming.
    ///
    /// Uses the session's `streamResponse(to:options:)` method to receive
    /// partial responses as they're generated, updating the UI in real-time.
    /// Handles context overflow by recovering the session with a condensed transcript.
    ///
    /// - Parameter input: The user's prompt text.
    func generateStreamingResponse(for input: String) async {
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
                to: input,
                options: configuration.generationOptions
            ) {

                messages[messageIndex] = Message(content: partial.content, isUser: false)
            }
        }
        catch  LanguageModelSession.GenerationError.exceededContextWindowSize {

            messages.append(
                Message(
                    content: "This conversation is too long. Please start a new session.",
                    isUser: false
                )
            )

            session = recoverSession(from: session)

        }

        catch LanguageModelSession.GenerationError.unsupportedLanguageOrLocale {

            messages.append(
                Message(
                    content: "This language is not supported. Please try English or another supported language",
                    isUser: false
                )
            )

        }
        catch {
            messages.append(
                Message(
                    content: "Sorry, I couldn't generate a response.",
                    isUser: false
                )
            )
        }

    }

    /// Creates a new session with a condensed transcript after context overflow.
    ///
    /// Preserves the first and last entries from the original session's transcript
    /// to maintain some conversation context while staying within limits.
    ///
    /// - Parameter session: The session that exceeded its context window.
    /// - Returns: A new `LanguageModelSession` with the condensed transcript.
    func recoverSession(
        from session: LanguageModelSession
    ) -> LanguageModelSession {

        let entries = session.transcript

        let condensedEntries = [
            entries.first,
            entries.last
        ].compactMap { $0 }

        let transcript = Transcript(entries: condensedEntries)

        let newSession = LanguageModelSession(transcript: transcript)

        newSession.prewarm()
        return newSession
    }
}
