//
//  MessageView.swift
//  FoundationModelsAssistantAI
//
//  AI-DRIVEN SWIFT ARCHITECTURE
//

import SwiftUI

/// Displays a single message bubble with conditional styling based on sender.
///
/// User messages are right-aligned with a blue background, while assistant
/// messages are left-aligned with a white background.
struct MessageView: View {

    /// The message data to display.
    ///
    /// The `isUser` property determines the visual styling and alignment.
    let message: Message

    var body: some View {

        let alignment: Alignment = message.isUser ? .trailing : .leading

        Text(verbatim: message.content)
            .padding(10)
            .background(
                alignment == .trailing
                ? Color.blue.opacity(0.2)
                : Color.gray.opacity(1.0)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(message.isUser ? .leading : .trailing, 60)
            .frame(maxWidth: .infinity, alignment: alignment)
    }
}
