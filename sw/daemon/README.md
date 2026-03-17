# Signing Daemon Area

This directory contains the executable software skeleton for the appliance.

Key files:

- `main.py`: entry point for self-test, probe, and optional gRPC server modes
- `server.py`: local harness, optional gRPC transport binding, and backend selection helpers
- `service.py`: transport-independent signing orchestration layer
- `config.py`: daemon configuration object, including backend selection and MMIO mapping inputs
- `proto_loader.py`: runtime helper for optional proto generation when gRPC dependencies are installed

Current behavior:

- local development still uses the fake backend by default
- `probe-mmio` provides a safe register-visibility path for future target-board use
- `selftest --backend real` is available for explicit target-hardware sequencing checks once register visibility is confirmed
- the daemon still validates a 64-byte digest and preserves the public software contract