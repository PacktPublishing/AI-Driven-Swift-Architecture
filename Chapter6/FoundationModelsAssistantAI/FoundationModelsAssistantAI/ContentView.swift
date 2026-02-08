//
//  ContentView.swift
//  FoundationModelsAssistantAI
//
//  AI-DRIVEN SWIFT ARCHITECTURE
//

import SwiftUI

/// Identifies the available screens in the navigation sidebar.
///
/// Each case corresponds to a distinct feature area of the application,
/// routed through the `NavigationSplitView` in ``ContentView``.
enum Screen: String, Identifiable {

    /// The conversational chat interface backed by `LanguageModelSession`.
    case chatBot

    /// The structured generation view using `@Generable` custom models.
    case generable

    /// The tool-calling demonstration view.
    case tools

    /// The custom-trained model chat interface.
    case trainedModel

    /// Returns `self` as the stable identity for SwiftUI list diffing.
    var id: Self { self }

    /// The screens that demonstrate Foundation Models capabilities.
    static let foundationModels: [Screen] = [
        .chatBot, .generable, .tools, .trainedModel
    ]

    /// A human-readable display name for the sidebar.
    var displayName: String {
        switch self {
        case .chatBot: "Chat Bot"
        case .generable: "Generable"
        case .tools: "Tools"
        case .trainedModel: "Trained Model"
        }
    }

    /// The SF Symbol icon for the sidebar row.
    var systemImage: String {
        switch self {
        case .chatBot: "bubble.left.and.bubble.right"
        case .generable: "doc.text"
        case .tools: "wrench.and.screwdriver"
        case .trainedModel: "brain.head.profile"
        }
    }
}

/// The root navigation view that presents a sidebar of feature screens.
///
/// Uses a `NavigationSplitView` to display the list of available screens
/// in the sidebar and the corresponding detail view for the selected screen.
struct ContentView: View {

    /// The currently selected screen in the sidebar.
    ///
    /// Drives the detail view content via a `switch` statement. `nil` when
    /// no screen is selected.
    @State private var selectedScreen: Screen? = .chatBot

    var body: some View {
        NavigationSplitView {

            List(selection: $selectedScreen) {
                Section("The Foundation Models") {
                    ForEach(Screen.foundationModels) { screen in
                        Label(screen.displayName, systemImage: screen.systemImage)
                            .tag(screen)
                    }
                }
            }
            .navigationTitle("AI-Driven Swift Architecture")
            #if os(macOS)
            .navigationSubtitle("Sample Code")
            #endif
        } detail: {
            if let selectedScreen  {
                switch selectedScreen {
                case .chatBot:
                    ChatBotView()
                case .generable:
                    GenerableView()
                case .tools:
                    ToolsView()
                case .trainedModel:
                    ChatBotWithTrainedModelView()
                }
            }
        }
    }

}
