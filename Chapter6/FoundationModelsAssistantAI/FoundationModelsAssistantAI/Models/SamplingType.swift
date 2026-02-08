//
//  SamplingType.swift
//  FoundationModelsAssistantAI
//
//  AI-DRIVEN SWIFT ARCHITECTURE
//

/// Defines the available token sampling strategies for text generation.
///
/// Sampling strategies control how the language model selects the next token
/// during generation, balancing between determinism and creativity.
enum SamplingType: String, CaseIterable, Identifiable {

    /// Deterministic decoding that always selects the highest-probability token.
    ///
    /// Produces consistent, reproducible outputs but may lack variety.
    case greedy = "Greedy"

    /// Probabilistic sampling from the top K highest-probability tokens.
    ///
    /// The model randomly samples from the K most likely tokens, where K
    /// is specified by `ModelConfiguration.topK`.
    case topK = "Top K"

    /// Nucleus sampling based on cumulative probability threshold.
    ///
    /// The model samples from the smallest set of tokens whose cumulative
    /// probability exceeds the threshold specified by `ModelConfiguration.topP`.
    case topP = "Top P"

    /// Returns self as the stable identity for SwiftUI.
    var id: Self { self }
}
