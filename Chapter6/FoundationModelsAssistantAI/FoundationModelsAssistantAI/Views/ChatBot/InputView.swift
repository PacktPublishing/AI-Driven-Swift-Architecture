//
//  InputView.swift
//  FoundationModelsAssistantAI
//
//  AI-DRIVEN SWIFT ARCHITECTURE
//

import SwiftUI

/// A text input component with a send button for composing messages.
///
/// Provides a multi-line text field with automatic height adjustment
/// and a circular send button. The button is disabled when the input
/// is empty or when `isDisabled` is true.
struct InputView: View {

    /// A binding to the current text input value.
    ///
    /// Updated as the user types and cleared by the parent after submission.
    @Binding var text: String

    /// The placeholder text displayed when the field is empty.
    let placeholder: String

    /// Whether the input should be disabled.
    ///
    /// When true, the text field and send button are non-interactive.
    let isDisabled: Bool

    /// The action to perform when the user submits the input.
    ///
    /// Called when the user taps the send button or presses return.
    let onSubmit: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(spacing: 12) {
                TextField(placeholder, text: $text, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 20))
                    .lineLimit(1...5)
                    .submitLabel(.send)
                    .onSubmit(onSubmit)

                Button("Send", systemImage: "arrow.up.circle.fill", action: onSubmit)
                    .buttonStyle(.plain)
                    .labelStyle(.iconOnly)
                    .font(.title)
                    .disabled(text.isEmpty || isDisabled)
                    .foregroundStyle(text.isEmpty || isDisabled ? .secondary : Color.accentColor)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}
