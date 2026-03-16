# Implementation Workflow

## Goal

Add implementation incrementally without breaking system coherence.

## Steps

1. Identify the governing requirements, ADRs, and architecture documents.
2. Capture any new design decision before major implementation divergence.
3. Implement one subsystem boundary at a time.
4. Update the affected documents in the same workstream.
5. Add or update verification artifacts alongside the implementation.
6. Record handoff notes, open issues, and next steps.

## Guardrails

- Do not bypass the documented interfaces for short-term convenience.
- Do not merge undocumented architectural changes.
- Do not treat PoC-only shortcuts as permanent design decisions.
