---
name: package-swift-cleanup
description: Cleans and maintains Package.swift files in a Clean Architecture–oriented Swift project. Use when removing obsolete dependencies, refactoring module graphs, or enforcing architectural conventions encoded in Package.swift.
---

# Skill: Package.swift Structural Cleanup

## Context

This project uses `Package.swift` files not only as dependency manifests, but as **architectural artifacts**.

Package files encode:
- feature-based modularization,
- dependency classification (external, utility, abstraction),
- and architectural intent through enums and helper extensions.

This structure is **not standard Swift Package Manager usage** and must be handled explicitly.

---

### 1. Domain-Scoped Data Modules

Modules such as `BasketData`, `ProductData`, and `UserData` belong to the **Data layer**.
They provide infrastructure implementations (repositories, services, data sources) scoped by domain.

Rules:
- Each enum case represents an active Data-layer module.
- Modules are organized by business domain, not by UI feature.
- Targets and test targets are generated from enum cases.
- Do not inline targets manually.

---

### 2. Dependency Classification

Dependencies are classified using enums:

- `ExternalModule` → third-party libraries (e.g. RxSwift)
- `Utility` → cross-cutting technical packages (e.g. Networking / API)
- `AbstractionModule` → domain-facing contracts (interfaces)

These enums are **semantic**, not incidental.

---

### 3. Cleanup Rules

When a dependency is removed from the codebase:

Required actions:
- Remove the package from `Package.dependencies`
- Remove all target-level references
- Remove unused enum cases in dependency classification enums
- Remove entire enums if they become empty
- Remove helper extensions that exist only for removed dependencies

Forbidden actions:
- Do not comment out obsolete dependencies
- Do not keep unused enum cases as placeholders
- Do not preserve architectural constructs that no longer reflect reality

Package.swift must describe the current architecture, not its history.

---

### 4. Obsolete Dependency Cleanup Rule

Any dependency classification entry (external, abstraction, or utility) that is no longer referenced by any target must be removed.

This includes:
- enum cases that are no longer used,
- entire enums that become empty after cleanup,
- helper extensions that only exist to support removed dependencies.

Leaving unused architectural constructs in Package.swift is considered a structural error.

---

### 5. Consistency Across Packages

This cleanup must be applied consistently:
- across all feature packages,
- across Data, Domain, Utilities, etc.

Partial cleanup is not acceptable.

---

## Validation Checklist

Before considering Package.swift cleanup complete:

- [ ] No unused enums remain
- [ ] No unused dependency helpers remain
- [ ] Dependency graph reflects actual code usage
- [ ] Package.swift still compiles
- [ ] Architectural intent remains readable

---

## Goal

The goal of this Skill is to ensure that `Package.swift` remains:
- truthful to the codebase,
- expressive of architecture,
- free of obsolete concepts after refactoring.

This Skill prioritizes **semantic clarity over mechanical cleanup**.