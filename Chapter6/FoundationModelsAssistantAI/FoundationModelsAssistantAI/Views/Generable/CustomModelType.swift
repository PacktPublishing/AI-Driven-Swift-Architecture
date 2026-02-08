//
//  CustomModelType.swift
//  FoundationModelsAssistantAI
//
//  AI-DRIVEN SWIFT ARCHITECTURE
//

import FoundationModels
import SwiftUI

/// Enumerates the `@Generable` model types available for structured generation.
///
/// Each case maps to a concrete `@Generable` struct (e.g., ``CountryRecommendation``,
/// ``Quiz``, ``StoryIdea``) and is displayed in the toolbar menu of ``GenerableView``.
/// Structured output ensures the language model returns typed, predictable data
/// rather than free-form text.
enum CustomModelType: String, CaseIterable, Identifiable {

    /// A travel recommendation with cities, cuisine, and logistics.
    case countryRecommendation = "Country Recommendation"

    /// An educational quiz with multiple-choice questions and explanations.
    case quiz = "Quiz"

    /// A creative story outline with characters, plot points, and conflict.
    case storyIdea = "Story Idea"

    /// The unique identifier derived from the raw value.
    var id: String { rawValue }

    /// The SF Symbol icon representing this model type in the UI.
    var systemImage: String {
        switch self {
        case .countryRecommendation: "list.clipboard"
        case .quiz: "app.badge.checkmark"
        case .storyIdea: "books.vertical"
        }
    }
}

