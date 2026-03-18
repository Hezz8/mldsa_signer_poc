# Build Modes

## Purpose

This note defines how engine mode is selected for target hardware builds.

## Current Selection Method

Engine mode is selected at compile time or synthesis time through the RTL top-level that instantiates `axi_lite_wrapper` with a fixed `ENGINE_MODE` parameter.

There is no software-visible runtime mode register in the current design.

## First Real Board Image

The first board bitstream shall use:

- `hw/rtl/pqsig_top_stub_mode.sv`
- wrapper engine mode: `ENGINE_MODE_STUB`

This is the required first hardware bring-up image because it preserves the deterministic software-visible signature rule and reduces risk during initial PS-to-PL validation.

## Later MLDSA_OSH Image

A later board image may use:

- `hw/rtl/pqsig_top_mldsa_osh_mode.sv`
- wrapper engine mode: `ENGINE_MODE_MLDSA_OSH`

That transition is explicitly deferred until STUB-mode board validation is complete.

## Build-Mode Constants

The repository also provides `hw/include/build_config.svh` for shared engine-mode identifiers. These constants are documentation and integration aids; the first board image is still expected to use the dedicated STUB-mode top-level.