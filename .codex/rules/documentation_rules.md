# Documentation Rules

## Documentation Is Part of the Design

Documentation in this repository is normative for system intent. LaTeX documents under `docs/` define the current engineering baseline and must be updated when architecture or interfaces change.

## Required Behavior

- Update affected documents in the same change that alters architecture, interfaces, or assumptions.
- Keep terminology consistent across README, ADRs, ICD, wrapper spec, and software or hardware notes.
- Mark placeholders, open items, and PoC-only assumptions explicitly.
- Prefer concise, reviewable wording over narrative sprawl.

## Required Documents For Common Changes

- External API changes: update `docs/interfaces/ICD.tex`, `sw/proto/signing.proto`, and `README.md`.
- Register or MMIO changes: update `docs/interfaces/Register_Map.tex`, `docs/architecture/Wrapper_Spec.tex`, and software MMIO notes.
- HW/SW partition changes: update `docs/architecture/PDR.tex`, `docs/architecture/Software_Architecture.tex`, and `docs/architecture/Hardware_Microarchitecture.tex`.
- Verification strategy changes: update `docs/verification/Verification_Plan.tex`.

## Style

- Use precise engineering language.
- Avoid unsupported performance claims.
- Distinguish present implementation from planned future work.
