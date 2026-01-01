//
//  CartBuilder.swift
//  ShoppingCartTDDTests
//
//  Test Data Builder for ShoppingCart
//

import Foundation
@testable import ShoppingCartTDD

/// Test Data Builder for creating ShoppingCart test objects
///
/// Follows the Test Data Builder pattern to eliminate test duplication
/// and make tests focus on what matters.
///
/// **Usage:**
/// ```swift
/// // Simple cart with one item
/// let cart = CartBuilder()
///     .with(price: 15.99)
///     .build()
///
/// // Cart with multiple items
/// let cart = CartBuilder()
///     .with(price: 10.0)
///     .with(price: 15.0)
///     .with(price: 5.0)
///     .build()
///
/// // Cart with quantities
/// let cart = CartBuilder()
///     .with(price: 10.0, quantity: 3)
///     .build()
/// ```
///
/// **Reference:** Freeman & Pryce (2009), "Growing Object-Oriented Software, Guided by Tests"
class CartBuilder {

    // MARK: - Properties

    private var items: [(price: Double, quantity: Int)] = []

    // MARK: - Fluent Configuration Methods

    /// Add an item to the cart with specified price and quantity
    ///
    /// - Parameters:
    ///   - price: The price of the item
    ///   - quantity: The quantity of the item (default: 1)
    /// - Returns: Self for method chaining
    func with(price: Double, quantity: Int = 1) -> CartBuilder {
        items.append((price, quantity))
        return self
    }

    // MARK: - Build

    /// Create the final ShoppingCart instance
    ///
    /// - Returns: A configured ShoppingCart with all items added
    func build() -> ShoppingCart {
        var cart = ShoppingCart()
        for item in items {
            try! cart.add(price: item.price, quantity: item.quantity)
        }
        return cart
    }
}
