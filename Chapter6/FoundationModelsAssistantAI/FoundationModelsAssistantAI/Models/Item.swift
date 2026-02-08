//
//  Item.swift
//  FoundationModelsAssistantAI
//
//  AI-DRIVEN SWIFT ARCHITECTURE
//

import Foundation
import SwiftData

/// A SwiftData model representing a timestamped item.
///
/// This model is provided as part of the SwiftData template and can be
/// extended for persistent storage needs.
@Model
final class Item {

    /// The date and time when this item was created.
    var timestamp: Date

    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
