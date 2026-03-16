# Project Context

## Program Summary

`pq-signature-appliance` is a post-quantum signature appliance project targeting ML-DSA-87 on a Zynq UltraScale+ platform.

## Current Phase

Bootstrap and documentation baseline only.

## Fixed Baseline Assumptions

- Input to the signing service is a 64-byte digest.
- The first exposed network interface is gRPC over Ethernet.
- Linux runs on the Zynq PS.
- The signing engine will live in PL behind an AXI-Lite wrapper for the PoC.
- The first PoC emphasizes correctness and continuous signing, not peak throughput.
- PoC key storage may be hardcoded in PL for bring-up only.

## Boundaries

- No real ML-DSA core implementation is present yet.
- No external repository integration has been performed.
- No production-grade key management scheme has been selected.

## Collaboration Notes

- Hardware, software, and verification work should converge through shared documents.
- Any prompt that changes architecture should cite the governing documents first.
