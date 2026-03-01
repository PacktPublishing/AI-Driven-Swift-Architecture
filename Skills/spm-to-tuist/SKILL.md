
---
name: spm-to-tuist
description: Migrates a generative, enum-driven Swift Package Manager (SPM) modular architecture to Tuist while preserving architectural invariants and meta-structure.
---

# Intent

Migrate a Swift Package Manager (SPM) project to Tuist **without losing its generative architecture model**.

The existing SPM setup is not flat. Targets and products are derived from enums, and dependencies are strongly typed through helper abstractions.  
This migration must preserve not only module boundaries, but also the architectural meta-model.

---

# Architectural Invariants

The following constraints must remain true after migration:

- Each enum case represents exactly one module.
- Each module produces exactly one product.
- Each module has a corresponding test target.
- Dependency direction rules must remain enforced.
- Abstraction modules must remain dependency-free (except explicitly allowed external modules).
- Utilities must not introduce upward coupling.
- No circular dependencies may be introduced.
- Folder conventions must remain intact.

---

# Step 1 — Introduce Tuist Alongside SPM

Create a `Project.swift` file next to your existing `Package.swift` file.

Example minimal Project.swift:

```swift
import ProjectDescription

let project = Project(
    name: "App",
    targets: [
        .target(
            name: "App",
            destinations: .iOS,
            product: .app,
            bundleId: "dev.tuist.App",
            sources: ["Sources/**/*.swift"]
        )
    ]
)
```

Important distinctions:

- You now import `ProjectDescription` instead of `PackageDescription`.
- You export a `Project` instance instead of a `Package` instance.
- The modeling primitives mirror Xcode concepts (targets, schemes, build phases, etc.).

Next, create a `Tuist.swift` file at the root of the project:

```swift
import ProjectDescription

let tuist = Tuist()
```

The presence of `Tuist.swift` defines the root of the Tuist project and enables configuration.

At this stage, Swift Package Manager still governs the build.  
Tuist has been introduced but has not yet taken ownership of the structure.

---

# Step 2 — Preserve the Generative Model

The current SPM configuration encodes architecture using enum-driven generation.

Example:

```swift
enum DataProduct: String, CaseIterable {
    case BasketData
    case ProductData
    case UserData
}
```

Targets and products are derived from:

```swift
products: DataProduct.allCases.map(\.product)
targets: DataProduct.allCases.map(\.target)
```

Dependencies are expressed through typed helpers:

```swift
.abstraction(.BasketAbstraction)
.utility(.API)
.internal(.BasketData)
```

The Tuist migration must preserve:

- The enum-driven module definition pattern.
- The strongly-typed dependency helpers.
- The one-to-one mapping between enum cases and targets.
- The separation between abstraction, utility, and internal dependencies.

Flattening this structure into manually written targets is not acceptable.

---

# Migration Strategy

The migration must follow these phases:

1. Introduce Tuist without removing SPM.
2. Recreate the enum-driven model in Tuist manifests.
3. Map each enum case to a Tuist target.
4. Recreate dependency helpers (abstraction, utility, internal).
5. Preserve test target conventions.
6. Validate the dependency graph.
7. Remove Package.swift only after structural equivalence is verified.

---

# Required Skill Behavior

The Skill must instruct the AI agent to:

- Analyze existing enum-driven package definitions.
- Detect module-generation patterns.
- Preserve meta-structure during transformation.
- Recreate architectural constraints inside Tuist manifests.
- Reject migrations that flatten or weaken dependency rules.

---

# Validation

After migration:

- Run `tuist install`
- Run `tuist generate`
- Build the project
- Execute tests
- Run `tuist graph`
- Ensure no new dependency violations exist

The migration is complete only if architectural invariants and meta-structure are preserved.
