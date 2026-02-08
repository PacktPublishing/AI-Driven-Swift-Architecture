//
//  Message.swift
//  FoundationModelsAssistantAI
//
//  AI-DRIVEN SWIFT ARCHITECTURE
//

import Foundation

/// A value type representing a single message in the chat conversation.
///
/// Messages are immutable once created and are identified by a unique UUID.
/// They track the content, sender (user or assistant), and timestamp for
/// display in the conversation history.
struct Message: Equatable, Identifiable {

    /// A unique identifier for this message, used for SwiftUI list diffing.
    let id = UUID()

    /// The text content of the message.
    let content: String

    /// Indicates whether this message was sent by the user.
    ///
    /// When `true`, the message originated from the user. When `false`,
    /// the message is a response from the language model.
    let isUser: Bool

    /// The date and time when this message was created.
    let timestamp = Date.now
}
