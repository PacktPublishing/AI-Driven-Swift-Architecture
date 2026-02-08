//
//  MessagesListView.swift
//  FoundationModelsAssistantAI
//
//  AI-DRIVEN SWIFT ARCHITECTURE
//

import SwiftUI

/// A scrollable list that displays the conversation message history.
///
/// Uses `LazyVStack` for efficient rendering of potentially large message lists
/// and `ScrollViewReader` to enable programmatic scrolling.
struct MessagesListView: View {

    /// The array of messages to display in the conversation.
    let messages: [Message]

    /// Indicates whether a response is currently being generated.
    ///
    /// Can be used to show typing indicators or disable interactions.
    let isResponding: Bool

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(messages) { message in
                        MessageView(message: message)
                            .id(message.id)
                    }

                    if isResponding, messages.last?.content.isEmpty ?? true {
                        HStack(spacing: 8) {
                            ProgressView()
                            Text("Thinking…")
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .id("typingIndicator")
                    }
                }
            }
            .contentMargins(.all, 16, for: .scrollContent)
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: messages.last?.id) {
                guard let lastID = messages.last?.id else { return }
                withAnimation {
                    proxy.scrollTo(lastID, anchor: .bottom)
                }
            }
            .onChange(of: messages.last?.content) {
                guard let lastID = messages.last?.id else { return }
                proxy.scrollTo(lastID, anchor: .bottom)
            }
        }
    }
}
