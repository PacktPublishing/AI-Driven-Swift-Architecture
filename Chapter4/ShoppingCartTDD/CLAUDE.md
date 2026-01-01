# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Swift framework project demonstrating Test-Driven Development (TDD) for a shopping cart implementation. Part of Chapter 4 in an AI-Driven Swift Architecture learning series.

## Architecture

- **ShoppingCartTDD/**: Main framework source code
- **ShoppingCartTDDTests/**: Test suite using Swift Testing framework (not XCTest)
- Built as a macOS/iOS framework (.framework)

## Testing

This project uses the **Swift Testing** framework (imported as `import Testing`), not XCTest. Key differences:
- Tests use `@Test` attribute instead of XCTest's test methods
- Assertions use `#expect(...)` instead of `XCTAssert...`
- Test structures are plain Swift structs, not classes inheriting from XCTestCase

## Common Commands

### Building
```bash
xcodebuild -scheme ShoppingCartTDD -configuration Debug build
```

### Running Tests
```bash
# Run all tests
xcodebuild test -scheme ShoppingCartTDD

# Run tests with verbose output
xcodebuild test -scheme ShoppingCartTDD -verbose
```

### Running Single Test
```bash
# Swift Testing uses test filtering
xcodebuild test -scheme ShoppingCartTDD -only-testing:ShoppingCartTDDTests/StructName/testName
```

## Core TDD Principles

### What is Test-Driven Development?

Test-Driven Development (TDD) is a software development discipline where:
1. You write a failing test BEFORE writing production code
2. You write the minimum code to make the test pass
3. You refactor while keeping tests green

This cycle repeats for every new feature or behavior.

### Why TDD for Shopping Cart?

Shopping cart logic involves:
- **Calculations:** Totals, discounts, taxes
- **Validation:** Prices, quantities, promo codes  
- **State:** Adding/removing items
- **Edge cases:** Empty cart, overflow, invalid input

### Key Benefits

1. **Design Feedback:** Tests reveal design issues early
2. **Documentation:** Tests show usage examples
3. **Regression Safety:** Changes can't break existing features
4. **Confidence:** Deploy with certainty
5. **Debugging Speed:** Small iterations = easier debugging

## Essential TDD Technique #1: Triangulation ⭐⭐⭐

### Definition

Triangulation is the process of driving out the correct implementation by 
writing multiple test cases that force you to generalize from specific 
examples to a general solution.

**Metaphor:** Just as you determine your position on a map using multiple 
landmarks, you discover the right code structure by using multiple test cases.

**Reference:** Beck, K. (2002). *Test-Driven Development: By Example*. 
Addison-Wesley. Chapter 1, pages 12-18.

### When to Use Triangulation

✅ **Use triangulation when:**
- The correct abstraction is unclear
- The implementation path isn't obvious
- You want to avoid over-engineering
- You're dealing with complex business logic
- You're teaching/learning TDD

❌ **Don't use triangulation when:**
- The solution is obvious (use Obvious Implementation instead)
- Only one test case is needed
- You're confident about the implementation

### The Triangulation Process

### Common Mistake: Redundant Second Test ❌

**The Problem:**

A common triangulation mistake is writing two tests that force the **same implementation**:

```swift
// ❌ BAD: Both force the same implementation (return items[0])
@Test func singleItemWithPrice10() {
    var cart = ShoppingCart()
    cart.add(price: 10.0)
    #expect(cart.total == 10.0)
}

@Test func singleItemWithPrice25() {  // REDUNDANT!
    var cart = ShoppingCart()
    cart.add(price: 25.0)
    #expect(cart.total == 25.0)
}
```

Both tests above could pass with this naive implementation:
```swift
var total: Double { items[0] }  // Just return first item
```

**The Fix:**

Each test must add a **new constraint** that forces a different implementation:

```swift
// ✅ GOOD: Proper triangulation sequence
@Test func emptyCart() {
    let cart = ShoppingCart()
    #expect(cart.total == 0)
    // Forces: return a constant (0)
}

@Test func singleItem() {
    var cart = ShoppingCart()
    cart.add(price: 10.0)
    #expect(cart.total == 10.0)
    // Forces: access stored item (items.first or items[0])
}

@Test func multipleItems() {
    var cart = ShoppingCart()
    cart.add(price: 10.0)
    cart.add(price: 15.0)
    #expect(cart.total == 25.0)
    // Forces: generalization (sum/reduce all items)
}
```

**Key Principle:**

> "Don't write a second test that forces the same implementation.
> Each test should add a new dimension that requires generalization."
>
> — Kent Beck, *Test-Driven Development: By Example*

**Triangulation Steps:**

1. **Step 1 (Constant):** Empty state → forces returning a constant
2. **Step 2 (Access):** Single element → forces accessing stored data
3. **Step 3 (Generalize):** Multiple elements → forces iteration/aggregation

Changing just the **value** (10 vs 25) doesn't add a new constraint.
You must change the **structure** (0 items → 1 item → many items).
## Essential TDD Technique #2: Transformation Priority Premise (TPP) ⭐⭐⭐

### Definition

The Transformation Priority Premise (TPP) is an ordered list of code transformations 
from simplest to most complex. It guides how to evolve code during the GREEN phase 
of Red-Green-Refactor.

**Key Insight:** When a test fails, consult the TPP list and choose the **simplest** 
transformation that makes the test pass.

**Created by:** Robert C. Martin (Uncle Bob)

**Reference:** Martin, R.C. (2013). "The Transformation Priority Premise"
Blog post: https://blog.cleancoder.com/uncle-bob/2013/05/27/TheTransformationPriorityPremise.html

---

### How TPP Complements Triangulation

**Triangulation** answers: "What tests should I write?"
- Test 1: Simplest case
- Test 2: Different case
- Test 3: Generalization

**TPP** answers: "How do I evolve the code to pass each test?"
- Use the simplest transformation from the list
- Don't skip transformations
- Progress incrementally

**Together:**
```
Triangulation (WHAT)          TPP (HOW)
Test 1: Empty cart      →     {} → constant (return 0.0)
Test 2: Single item     →     constant → variable (items[0].price)
Test 3: Multiple items  →     expression → function (reduce)
```

---

### The Complete Transformation List (Ordered by Simplicity)
```
1.  {} → nil                    (no code → null value)
2.  nil → constant              (null → fixed value)
3.  constant → variable         (fixed value → computed value)
4.  statement → statements      (one line → multiple lines)
5.  unconditional → if          (direct code → conditional)
6.  scalar → array              (single value → collection)
7.  array → container           (simple array → complex structure)
8.  statement → recursion       (iteration → recursive call)
9.  if → while                  (condition → loop)
10. expression → function       (inline code → extracted function)
11. variable → assignment       (immutable → mutable)
```

**Golden Rule:** Always choose the transformation with the lowest number 
that makes the test pass.

---

### When to Use TPP

✅ **Use TPP when:**
- You're in the GREEN phase (making a failing test pass)
- You're unsure which implementation to write
- You want to avoid over-engineering
- You're teaching/learning TDD

❌ **Don't use TPP when:**
- The implementation is obvious
- You're in RED phase (writing tests)
- You're in REFACTOR phase (improving existing code)

**TPP is specifically for the GREEN phase.**

---

### Complete Example: Shopping Cart Quantity Validation

We'll implement `cart.add(price:quantity:)` with validation using TPP.

#### Baseline: Starting Point
```swift
struct ShoppingCart {
    private var items: [Double] = []
    
    mutating func add(price: Double) {
        items.append(price)
    }
    
    var total: Double {
        items.reduce(0.0, +)
    }
}
```

---

#### Transformation 1: `{}` → `constant`

**Test:**
```swift
@Test("Item has default quantity of 1")
func itemDefaultQuantity() {
    var cart = ShoppingCart()
    cart.add(price: 10.0)
    
    #expect(cart.itemCount == 1) // ❌ FAILS - property doesn't exist
}
```

**What test forces:** Add `itemCount` property

**TPP Guidance:** Use transformation #2 (nil → constant)

**Implementation:**
```swift
var itemCount: Int { 1 } // ✅ Simplest: return constant
```

**Result:** ✅ Test passes

**Why this works:** Test only requires the value 1, so a constant is sufficient.

---

#### Transformation 2: `constant` → `variable`

**Test:**
```swift
@Test("Multiple items increase count")
func multipleItemsCount() {
    var cart = ShoppingCart()
    cart.add(price: 10.0)
    cart.add(price: 20.0)
    cart.add(price: 5.0)
    
    #expect(cart.itemCount == 3) // ❌ FAILS - constant returns 1
}
```

**What test forces:** Calculate actual count

**TPP Guidance:** Use transformation #3 (constant → variable)

**Implementation:**
```swift
var itemCount: Int { 
    items.count // ✅ Computed from actual data
}
```

**Result:** ✅ Both tests pass

**Why this works:** Now we derive the value instead of hardcoding it.

---

#### Transformation 3: `statement` → `statements`

**Test:**
```swift
@Test("Adding item with explicit quantity")
func addItemWithQuantity() {
    var cart = ShoppingCart()
    cart.add(price: 10.0, quantity: 3) // ❌ COMPILE ERROR
    
    #expect(cart.itemCount == 3)
    #expect(cart.total == 30.0)
}
```

## Essential TDD Technique #3: Test Data Builders ⭐⭐⭐

### Definition

Test Data Builders are classes that provide a fluent API for creating test objects with sensible defaults and easy customization. They eliminate duplication in test setup and make tests more readable by focusing on what matters.

**Problem they solve:** Repetitive, verbose object creation in tests that obscures test intent.

**Created by:** Nat Pryce (2007)

**References:**

**Primary Source:**
Pryce, N. (2007). "Test Data Builders: an alternative to the Object Mother pattern"
Blog post: http://www.natpryce.com/articles/000714.html

**Comprehensive Treatment:**
Freeman, S., & Pryce, N. (2009). *Growing Object-Oriented Software, Guided by Tests*. 
Addison-Wesley Professional. ISBN: 978-0321503626
Chapter 22: "Constructing Complex Test Data", pages 239-252.

---

### When to Use Test Data Builders

✅ **Use builders when:**
- Creating the same type of object repeatedly in tests
- Objects have many properties (3+)
- Most properties have sensible defaults
- Tests should focus on specific property variations
- Setup code is verbose and obscures test intent

❌ **Don't use builders when:**
- Objects are very simple (1-2 properties)
- Each test needs completely different objects
- Direct construction is already clear
- It's a one-time use in a single test

**Rule of thumb:** If you create the same object 3+ times in tests, consider a builder.

---

### The Problem: Test Duplication

#### Without Builders ❌
```swift
@Test("Single item total")
func singleItemTotal() {
    var cart = ShoppingCart()
    let item = Item(name: "Book", price: 15.99)
    try? cart.add(item)
    #expect(cart.total == 15.99)
}

@Test("Multiple items total")
func multipleItemsTotal() {
    var cart = ShoppingCart()
    // Repetition starts 👇
    let item1 = Item(name: "Book", price: 15.99)
    let item2 = Item(name: "Pen", price: 2.50)
    let item3 = Item(name: "Notebook", price: 5.99)
    
    try? cart.add(item1)
    try? cart.add(item2)
    try? cart.add(item3)
    
    #expect(cart.total == 24.48)
}

@Test("Free shipping threshold")
func freeShippingThreshold() {
    var cart = ShoppingCart()
    // Same repetition 👇
    let item1 = Item(name: "Laptop", price: 60.0)
    let item2 = Item(name: "Mouse", price: 25.0)
    
    try? cart.add(item1)
    try? cart.add(item2)
    
    #expect(cart.qualifiesForFreeShipping)
}
```

**Problems:**
- 🔴 `Item(name:price:)` repeated everywhere
- 🔴 Names irrelevant to most tests (just need prices)
- 🔴 If `Item` constructor changes → update 20+ tests
- 🔴 Hard to see what each test is actually testing
- 🔴 15+ lines of setup for a 2-line test

---

### The Solution: Test Data Builders

#### With Builders ✅
```swift
@Test("Single item total")
func singleItemTotal() {
    var cart = ShoppingCart()
    let item = ItemBuilder().priced(15.99).build()
    
    try? cart.add(item)
    #expect(cart.total == 15.99)
}

@Test("Multiple items total")
func multipleItemsTotal() {
    var cart = ShoppingCart()
    
    try? cart.add(ItemBuilder().priced(15.99).build())
    try? cart.add(ItemBuilder().priced(2.50).build())
    try? cart.add(ItemBuilder().priced(5.99).build())
    
    #expect(cart.total == 24.48)
}

@Test("Free shipping threshold")
func freeShippingThreshold() {
    var cart = ShoppingCart()
    
    try? cart.add(ItemBuilder().priced(60.0).build())
    try? cart.add(ItemBuilder().priced(25.0).build())
    
    #expect(cart.qualifiesForFreeShipping)
}
```

**Benefits:**
- ✅ Focus on what matters (price)
- ✅ Sensible defaults (name, category, etc.)
- ✅ Easy to customize when needed
- ✅ One place to update if constructor changes
- ✅ Clear test intent

---

### Builder Pattern Structure
```swift
class ItemBuilder {
    // 1. Properties with sensible defaults
    private var name = "Test Item"
    private var price = 10.0
    private var category: Category = .general
    
    // 2. Fluent setters (return self for chaining)
    func named(_ name: String) -> ItemBuilder {
        self.name = name
        return self
    }
    
    func priced(_ price: Double) -> ItemBuilder {
        self.price = price
        return self
    }
    
    func inCategory(_ category: Category) -> ItemBuilder {
        self.category = category
        return self
    }
    
    // 3. Build method creates the final object
    func build() -> Item {
        Item(name: name, price: price, category: category)
    }
}

// Usage: Fluent API
let item = ItemBuilder()
    .named("Swift Book")
    .priced(29.99)
    .inCategory(.books)
    .build()
```

**Key principles:**
1. **Sensible defaults** for all properties
2. **Fluent API** (return `self` for chaining)
3. **Build method** creates the final object
4. **Clear naming** (`priced()` not `withPrice()`)

---

### Complete Example: ItemBuilder for Shopping Cart
```swift
import Foundation
@testable import ShoppingCart

/// Test Data Builder for creating Item test objects
/// 
/// Usage:
///   let item = ItemBuilder().priced(15.99).build()
///   let book = ItemBuilder.book().priced(29.99).build()
class ItemBuilder {
    
    // MARK: - Default Values
    
    private var name = "Test Item"
    private var price = 10.0
    
    // MARK: - Fluent Configuration Methods
    
    /// Set the item name
    func named(_ name: String) -> ItemBuilder {
        self.name = name
        return self
    }
    
    /// Set the item price
    func priced(_ price: Double) -> ItemBuilder {
        self.price = price
        return self
    }
    
    // MARK: - Factory Methods for Common Items
    
    /// Create a builder for book items with typical defaults
    static func book() -> ItemBuilder {
        ItemBuilder()
            .named("Test Book")
            .priced(15.99)
    }
    
    /// Create a builder for electronic items
    static func electronics() -> ItemBuilder {
        ItemBuilder()
            .named("Test Electronics")
            .priced(299.99)
    }
    
    /// Create a builder for office supplies
    static func office() -> ItemBuilder {
        ItemBuilder()
            .named("Test Office Item")
            .priced(5.99)
    }
    
    /// Create a builder for free items
    static func free() -> ItemBuilder {
        ItemBuilder()
            .named("Free Sample")
            .priced(0.0)
    }
    
    // MARK: - Build
    
    /// Create the final Item instance
    func build() -> Item {
        Item(name: name, price: price)
    }
}
```

---

### Advanced: CartBuilder

For more complex scenarios, build entire carts:
```swift
class CartBuilder {
    private var items: [Item] = []
    
    /// Add an item to the cart
    func with(_ item: Item, quantity: Int = 1) -> CartBuilder {
        for _ in 0..<quantity {
            items.append(item)
        }
        return self
    }
    
    /// Add an item using a builder
    func with(_ builder: ItemBuilder, quantity: Int = 1) -> CartBuilder {
        return with(builder.build(), quantity: quantity)
    }
    
    /// Build the final cart
    func build() -> ShoppingCart {
        var cart = ShoppingCart()
        for item in items {
            try? cart.add(item: item)
        }
        return cart
    }
}

// Usage: Compose builders
let cart = CartBuilder()
    .with(ItemBuilder.book().priced(29.99))
    .with(ItemBuilder.office(), quantity: 3)
    .build()
```

---

### Before and After: Real Impact

#### Before Builders ❌
```swift
@Suite("Shopping Cart Tests")
struct ShoppingCartTests {
    
    @Test("Calculate total with multiple items")
    func calculateTotal() throws {
        var cart = ShoppingCart()
        
        // 15 lines of setup
        let item1 = Item(name: "Programming in Swift", price: 45.99)
        let item2 = Item(name: "iOS Development Guide", price: 39.99)
        let item3 = Item(name: "SwiftUI Essentials", price: 29.99)
        
        try cart.add(item: item1)
        try cart.add(item: item2)
        try cart.add(item: item3)
        
        // 1 line of actual test
        #expect(cart.total == 115.97)
    }
    
    @Test("Apply discount")
    func applyDiscount() throws {
        var cart = ShoppingCart()
        
        // Repeated setup (duplication)
        let item1 = Item(name: "Programming in Swift", price: 45.99)
        let item2 = Item(name: "iOS Development Guide", price: 39.99)
        
        try cart.add(item: item1)
        try cart.add(item: item2)
        
        cart.applyDiscount(percent: 10)
        
        #expect(cart.total == 77.38)
    }
    
    @Test("Free item doesn't affect total")
    func freeItem() throws {
        var cart = ShoppingCart()
        
        // More duplication
        let paidItem = Item(name: "Book", price: 29.99)
        let freeItem = Item(name: "Sample", price: 0.0)
        
        try cart.add(item: paidItem)
        try cart.add(item: freeItem)
        
        #expect(cart.total == 29.99)
    }
}

// Stats:
// - Total lines: ~45
// - Setup lines: ~35 (78%)
// - Test lines: ~10 (22%)
// - Duplication: Item() called 8 times
```

---

#### After Builders ✅
```swift
@Suite("Shopping Cart Tests")
struct ShoppingCartTests {
    
    @Test("Calculate total with multiple items")
    func calculateTotal() throws {
        let cart = CartBuilder()
            .with(ItemBuilder().priced(45.99))
            .with(ItemBuilder().priced(39.99))
            .with(ItemBuilder().priced(29.99))
            .build()
        
        #expect(cart.total == 115.97)
    }
    
    @Test("Apply discount")
    func applyDiscount() throws {
        var cart = CartBuilder()
            .with(ItemBuilder().priced(45.99))
            .with(ItemBuilder().priced(39.99))
            .build()
        
        cart.applyDiscount(percent: 10)
        
        #expect(cart.total == 77.38)
    }
    
    @Test("Free item doesn't affect total")
    func freeItem() throws {
        let cart = CartBuilder()
            .with(ItemBuilder().priced(29.99))
            .with(ItemBuilder.free())
            .build()
        
        #expect(cart.total == 29.99)
    }
}