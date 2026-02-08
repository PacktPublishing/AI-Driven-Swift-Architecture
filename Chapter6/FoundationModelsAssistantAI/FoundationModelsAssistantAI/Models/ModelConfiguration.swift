//
//  ModelConfiguration.swift
//  FoundationModelsAssistantAI
//
//  AI-DRIVEN SWIFT ARCHITECTURE
//

import Foundation
import FoundationModels

/// Configuration parameters for language model text generation.
///
/// This struct encapsulates all configurable options that control how the
/// `LanguageModelSession` generates responses, including system instructions,
/// temperature, and sampling strategy.
struct ModelConfiguration: Equatable {

    /// System instructions that guide the model's behavior and persona.
    ///
    /// When non-empty, these instructions are passed to the `LanguageModelSession`
    /// to customize how the model responds to user prompts.
    var instructions: String = ""

    /// Controls the randomness of the model's output.
    ///
    /// Values range from 0.0 (more deterministic) to 1.0 (more random).
    /// Higher values produce more creative but potentially less coherent responses.
    var temperature: Double = 0.7

    /// The sampling strategy used for token selection during generation.
    ///
    /// Determines whether the model uses greedy decoding or probabilistic
    /// sampling (Top-K or Top-P).
    var samplingType: SamplingType = .greedy

    /// The number of highest-probability tokens to consider when using Top-K sampling.
    ///
    /// Only used when `samplingType` is `.topK`. Higher values increase diversity.
    var topK: Double = 20.0

    /// The cumulative probability threshold for Top-P (nucleus) sampling.
    ///
    /// Only used when `samplingType` is `.topP`. The model considers the smallest
    /// set of tokens whose cumulative probability exceeds this threshold.
    var topP: Double = 0.5

    /// Converts this configuration into `GenerationOptions` for the Foundation Models API.
    ///
    /// Maps the sampling type and associated parameters to the appropriate
    /// `GenerationOptions` initializer.
    var generationOptions: GenerationOptions {

        switch samplingType {

        case .greedy:

                .init(
                    sampling: .greedy,
                    temperature: temperature
                )

        case .topK:

                .init(
                    sampling: .random(top: Int(topK)),
                    temperature: temperature
                )

        case .topP:

                .init(
                    sampling: .random(probabilityThreshold: topP),
                    temperature: temperature
                )
        }
    }
}
