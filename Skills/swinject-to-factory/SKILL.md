---
name: swinject-to-factory
description: Migrates runtime-based dependency injection using Swinject to compile-time–oriented dependency injection using Factory. Use when refactoring DI containers, composition roots, and dependency lifetimes in a Clean Architecture–oriented Swift project.
---

# Skill: Swinject to Factory Migration

## Context

This project currently relies on **Swinject**, a runtime-based dependency injection framework.
Dependencies are registered imperatively, resolved dynamically, and validated only at runtime.

The goal of this Skill is to guide a **controlled migration** toward **Factory**, a dependency injection approach that encodes dependency graphs declaratively and enables earlier validation through Swift’s type system.

This Skill must be applied with architectural awareness, not as a mechanical API replacement.

---

## Architectural Intent

This migration is driven by the following architectural goals:

- Shift dependency validation from runtime to compile time whenever possible
- Eliminate dynamic `resolve` calls from application code
- Express dependency graphs declaratively
- Simplify the composition root
- Preserve existing Clean Architecture boundaries
- Avoid redesigning the module graph or business logic

Factory is treated as a **composition mechanism**, not as a service locator.

---

## What This Skill Is Not

This Skill must NOT:

- Redesign domain models or use cases
- Merge or split modules
- Change public APIs unrelated to dependency injection
- Introduce global state beyond Factory’s scoped containers
- Mix Swinject and Factory patterns in the same layer

The migration must be consistent and complete within the affected scope.

---

### External Dependency Rule

Factory must be added as an external dependency using Swift Package Manager.

Rules:
- Add Factory as a package dependency where required
- Declare Factory in the external dependency classification enum
- Remove Swinject from Package.swift entirely
- Do not allow Swinject and Factory to coexist in the same target

## Migration Rules

### 1. Registration → Factory Declaration

**Swinject pattern (before):**
- Dependencies are registered in a container
- Factories are defined imperatively
- Resolution occurs via `resolve`

**Factory pattern (after):**
- Dependencies are declared as typed factories
- No explicit registration phase
- No dynamic resolution

Rules:
- Replace Swinject `register` calls with `Factory<T>` declarations
- Do not call `resolve` inside Factory definitions
- Express dependencies through direct factory calls

---

### 2. Resolution Elimination

Rules:
- Remove all calls to `resolve(...)` from application and feature code
- Dependencies must be injected via initializers or accessed through factories
- No optional resolution is allowed (`!` or fallback logic)

Missing dependencies should surface as compilation errors, not runtime crashes.

---

### 3. Scope Translation

Translate Swinject scopes to Factory scopes as follows:

- `.transient` → default Factory behavior
- `.container` (singleton) → `.singleton`
- `.graph` → `.shared` or `.cached` (depending on semantics)

Rules:
- Scopes must be explicit
- Do not rely on implicit defaults when lifetime matters
- Favor shorter lifetimes unless shared state is explicitly required

---

### 4. Composition Root Simplification

Rules:
- Remove imperative registration logic from the application entry point
- Eliminate `init()` blocks whose sole purpose is to register dependencies
- Composition should emerge from Factory declarations, not from startup code

The composition root remains conceptually at the application boundary, but its implementation becomes declarative rather than procedural.

---

### 5. Container Usage Constraints

Rules:
- Use Factory’s `Container` as a namespace for dependency declarations
- Do not expose containers as service locators
- Feature code must not dynamically request dependencies

Factories should be accessed in a controlled and explicit manner.

---

## Module-Scoped Factory Declarations (Assembly Equivalents)

Factory does not provide a runtime Assembly mechanism.
Instead, dependency composition must be expressed statically through extensions on `Container`.

In this project, each module must declare its own factories.
These declarations serve as **logical assemblies**, scoped by module and responsibility.

---

### Rules

- Each module (Data, Domain, Utilities, Analytics, etc.) must declare its own Factory definitions.
- Factory declarations must be placed inside the module they belong to.
- Use `public extension Container` to expose factories across module boundaries.
- Do not centralize all Factory declarations in the App module.
- The App module must not define factories for domain or data components.

---

### Responsibilities by Layer

**Data modules**:
- Declare factories for services, repositories, and data sources.
- Depend only on utilities and abstractions.

**Domain modules**:
- Declare factories for use cases.
- Depend only on abstractions and other domain-level contracts.

**Utility modules**:
- Declare factories for cross-cutting technical services (e.g. analytics, networking wrappers).

**App module**:
- Acts as an activation root.
- Imports modules but does not declare factories.
- May override factories only for testing, previews, or environment-specific configuration.

---

### Forbidden Patterns

- A single centralized `Container` extension containing all factories.
- Factory declarations inside the App module for domain or data logic.
- Dynamic access patterns resembling service locators.
- Mixing Swinject-style registration logic with Factory declarations.

---

### Rationale

This structure preserves:
- modular autonomy,
- clear ownership of dependency declarations,
- alignment with Clean Architecture boundaries,
- and compile-time visibility of the dependency graph.

While Factory eliminates the need for runtime assemblies, organizing factories by module provides the same architectural benefits as Swinject assemblies without reintroducing runtime indirection.

---

### Validation Checklist (Extended)

- [ ] No centralized Factory container in the App module
- [ ] Each module exposes only its own factories
- [ ] Factory visibility matches module boundaries
- [ ] App module contains no wiring logic
- [ ] Dependency graph remains acyclic and explicit

## Validation Checklist

Before considering the migration complete:

- [ ] No Swinject imports remain
- [ ] No `register` or `resolve` calls remain
- [ ] Dependency lifetimes are explicitly declared where relevant
- [ ] Composition root contains no imperative wiring
- [ ] Application builds successfully
- [ ] Missing dependencies fail at compile time

---

## Expected Outcome

After applying this Skill:

- Dependency graphs are visible in code
- Dependency errors surface earlier
- Object lifetimes are easier to reason about
- The composition root is simpler and smaller
- The architecture is more explicit and verifiable

This Skill prioritizes **architectural clarity and safety** over mechanical refactoring.
