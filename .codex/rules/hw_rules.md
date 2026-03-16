# Hardware Rules

## Scope

These rules apply to RTL, wrappers, simulations, constraints, and hardware architecture work.

## Design Rules

- Keep the AXI-Lite wrapper contract stable and well documented.
- Separate wrapper control logic from future ML-DSA datapath logic.
- Use explicit reset, busy, done, and error semantics.
- Parameterize widths and buffer sizing where practical, but do not obscure the PoC interface.

## Repository Rules

- Place synthesizable logic under `hw/rtl/` and wrapper-specific logic under `hw/wrapper/`.
- Place reusable headers under `hw/include/`.
- Keep simulation collateral under `hw/sim/` and `hw/tb/`.
- Do not commit generated Vivado project files unless an explicit workflow requires them.

## Verification Rules

- Every new hardware-visible register or status bit must be covered in simulation.
- Wrapper behavior must be testable without the final crypto core.
- Timing and clocking assumptions must be written down, not implied.
