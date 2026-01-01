//
//  ShoppingCartTDDTests.swift
//  ShoppingCartTDDTests
//
//  Created by Walid SASSI on 25/12/2025.
//

import Testing
@testable import ShoppingCartTDD

// MARK: - Test Constants

private enum TestPrices {
    static let small = 10.0
    static let large = 15.0
    static let tiny = 5.0
}

// MARK: - Triangulation Tests

/// Tests demonstrating proper triangulation technique.
/// Each test adds a NEW constraint that forces implementation evolution.
@Suite("Shopping Cart - Triangulation")
struct ShoppingCartTriangulationTests {

    // MARK: - Step 1: Empty State (Forces Constant)

    /// Triangulation Step 1: Empty cart
    /// Forces: Returning a constant value (0)
    /// Implementation: `var total: Double { 0 }`
    @Test func emptyCartHasZeroTotal() {
        // Arrange
        let cart = ShoppingCart()

        // Act & Assert
        #expect(cart.isEmpty)
        #expect(cart.itemCount == 0)
        #expect(cart.total == 0)  // Triangulation constraint
    }

    // MARK: - Step 2: Single Element (Forces Access)

    /// Triangulation Step 2: Single item
    /// Forces: Accessing stored item data
    /// Implementation: `var total: Double { items.first ?? 0 }` or `items[0]`
    @Test func singleItem() {
        // Arrange
        let cart = CartBuilder()
            .with(price: TestPrices.small)
            .build()

        // Assert
        #expect(cart.total == TestPrices.small)
        #expect(cart.itemCount == 1)
    }

    // MARK: - Step 3: Multiple Elements (Forces Generalization)

    /// Triangulation Step 3: Multiple items
    /// Forces: Iteration and aggregation (sum/reduce)
    /// Implementation: `var total: Double { items.reduce(0, +) }`
    @Test func multipleItems() {
        // Arrange
        let cart = CartBuilder()
            .with(price: TestPrices.small)
            .with(price: TestPrices.large)
            .with(price: TestPrices.tiny)
            .build()

        // Assert
        #expect(cart.total == 30.0)
        #expect(cart.itemCount == 3)
    }
}

// MARK: - TPP: Adding Quantity Support

/// Tests demonstrating the Transformation Priority Premise (TPP) technique.
/// Each transformation evolves code from simple to complex using the TPP ordered list.
@Suite("Shopping Cart - TPP Quantity Support")
struct ShoppingCartTPPTests {

    // TPP Transformation 1: {} → constant
    /// Establishes the totalQuantity property.
    /// Forces: Adding a new property that returns a constant value.
    /// This sets the foundation for quantity support.
    @Test("Single item has default total quantity of 1")
    func singleItemDefaultQuantity() {
        // Arrange
        let cart = CartBuilder()
            .with(price: 10.0)
            .build()

        // Assert
        #expect(cart.totalQuantity == 1)  // ✅ Passes with constant
    }

    // TPP Transformation 2: constant → variable
    /// Forces computing totalQuantity from actual data instead of returning constant.
    /// Multiple items should increase the total quantity.
    /// Implementation must change from `return 1` to `return items.count`.
    @Test("Multiple items increase total quantity")
    func multipleItemsIncreaseQuantity() {
        // Arrange
        let cart = CartBuilder()
            .with(price: TestPrices.small)
            .with(price: TestPrices.large)
            .with(price: TestPrices.tiny)
            .build()

        // Assert
        #expect(cart.totalQuantity == 3)  // ✅ Passes with items.count
    }

    // TPP Transformation 3: statement → statements
    /// Forces adding quantity parameter to add() method.
    /// Requires restructuring data storage to handle price + quantity.
    /// Implementation must change from [Double] to storing Item structs.
    @Test("Adding item with explicit quantity")
    func addItemWithExplicitQuantity() {
        // Arrange
        let cart = CartBuilder()
            .with(price: 10.0, quantity: 3)
            .build()

        // Assert
        #expect(cart.totalQuantity == 3)
        #expect(cart.total == 30.0)
    }

    // TPP Transformation 4: unconditional → if
    /// Forces adding validation logic to reject invalid quantities.
    /// Previously the add() method unconditionally accepted any quantity.
    /// Now it must add conditional check: if quantity <= 0, throw error.
    @Test("Adding zero quantity throws error")
    func addingZeroQuantityThrowsError() {
        // Arrange
        var cart = ShoppingCart()

        // Act & Assert
        #expect(throws: CartError.invalidQuantity) {
            try cart.add(price: 10.0, quantity: 0)
        }
    }
}
