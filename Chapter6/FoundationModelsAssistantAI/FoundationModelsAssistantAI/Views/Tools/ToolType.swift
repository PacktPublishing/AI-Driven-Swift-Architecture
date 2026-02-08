//
//  ToolType.swift
//  FoundationModelsAssistantAI
//
//  AI-DRIVEN SWIFT ARCHITECTURE
//

import SwiftUI

/// Enumerates the tool types available for Foundation Models tool calling.
///
/// Each case maps to a concrete `Tool` implementation (e.g., ``CalendarTool``,
/// ``WeatherTool``) and is displayed in the toolbar picker of ``ToolsView``.
/// Tool calling enables the language model to invoke developer-defined functions
/// during generation, interacting with external data sources.
enum ToolType: String, CaseIterable, Identifiable {

    /// Calendar management tool for creating, reading, and querying events.
    case calendar = "Calendar"

    /// Weather information tool for current conditions and forecasts.
    case weather = "Weather"

    /// The unique identifier derived from the raw value.
    var id: String { rawValue }

    /// The SF Symbol icon representing this tool type in the UI.
    var systemImage: String {
        switch self {
        case .calendar: "calendar"
        case .weather: "cloud.sun"
        }
    }

    /// A description of what this tool can do.
    var toolDescription: String {
        switch self {
        case .calendar:
            "Manage calendar events: create, read, query, update, and delete."
        case .weather:
            "Get weather information: current conditions, daily and hourly forecasts."
        }
    }

    /// Example prompts that demonstrate the tool's capabilities.
    var examplePrompts: [String] {
        switch self {
        case .calendar:
            [
                "What meetings do I have this week?",
                "Schedule a team meeting tomorrow at 2pm for 1 hour",
                "Find available time slots for next Monday"
            ]
        case .weather:
            [
                "What's the weather like Paris today?",
                "Give me a 5-day forecast for Tokyo",
                "What's the hourly forecast for New York today?"
            ]
        }
    }
}
