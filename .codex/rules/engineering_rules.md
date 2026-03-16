# Engineering Rules

## Purpose

These rules define the baseline engineering discipline for `pq-signature-appliance`.

## Core Principles

- Treat the repository as a long-lived engineering program, not a demo.
- Preserve clean separation between requirements, architecture, implementation, and verification.
- Prefer explicit interfaces and traceable decisions over implicit assumptions.
- Optimize first for correctness, reviewability, and maintainability.

## Change Control

- Record design decisions before major implementation changes when the tradeoff is non-trivial.
- Keep requirements, architecture, interface definitions, and implementation aligned in the same workstream.
- Do not introduce third-party repositories, vendor IP drops, or generated tool artifacts without an explicit decision record.
- Do not add real cryptographic core logic until the surrounding interfaces and verification scaffolding are ready.

## Working Practices

- Keep commits and change sets scoped to a coherent engineering objective.
- Capture assumptions in documents, not only in prompts or chat history.
- Prefer placeholder modules and documented contracts over speculative code.
- Flag PoC-only choices clearly so they are not mistaken for production decisions.

## Review Expectations

- Architecture-affecting changes require corresponding documentation updates.
- Interface changes require updates to the ICD, wrapper spec, register map, and any relevant proto files.
- Verification impact must be stated for hardware, software, and system-level changes.
