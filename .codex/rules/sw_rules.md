# Software Rules

## Scope

These rules apply to the Linux daemon, MMIO access layer, client utilities, and software-side tests.

## Design Rules

- Keep service logic, transport definitions, and MMIO access separate.
- Validate request size and semantics before touching hardware.
- Treat hardware timeouts and malformed state as first-class error cases.
- Build for observability: logging, counters, and health reporting matter even in the PoC.

## Interface Rules

- The proto definition is the external contract baseline.
- The MMIO layer must reflect the register map documents exactly.
- Do not hardcode register offsets in multiple places; centralize them when implementation begins.

## Testing Rules

- Add unit tests for request validation and serialization behavior.
- Add integration tests for daemon-to-MMIO sequencing once stubs exist.
- Keep software tests runnable without requiring the final hardware core.
