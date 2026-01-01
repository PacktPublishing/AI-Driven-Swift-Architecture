//
//  ShoppingCartTDD.swift
//  ShoppingCartTDD
//
//  Created by Walid SASSI on 25/12/2025.
//

import Foundation

// TPP Transformation 4: Define error type for validation
public enum CartError: Error {
    case invalidQuantity
}

public struct ShoppingCart {
    // TPP Transformation 3: statement → statements
    // Changed from [Double] to [Item] to support quantities
    private struct Item {
        let price: Double
        let quantity: Int
    }

    private var items: [Item] = []

    public var isEmpty: Bool {
        items.isEmpty
    }

    public var itemCount: Int {
        items.count
    }

    // TPP Transformation 3: Sum quantities from all items
    public var totalQuantity: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    // TPP Transformation 3: Calculate total as price × quantity for each item
    public var total: Double {
        items.reduce(0.0) { $0 + ($1.price * Double($1.quantity)) }
    }

    public init() {}

    // TPP Transformation 4: unconditional → if
    // Added validation: reject invalid quantities
    // Default quantity = 1 for backward compatibility
    public mutating func add(price: Double, quantity: Int = 1) throws {
        // Conditional check - TPP Transformation 4
        if quantity <= 0 {
            throw CartError.invalidQuantity
        }

        items.append(Item(price: price, quantity: quantity))
    }
}
