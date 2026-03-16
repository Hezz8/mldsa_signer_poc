# Signing Daemon Area

This directory now contains the first executable software skeleton for the appliance.

Key files:

- `main.py`: entry point for self-test mode and the optional gRPC server mode
- `server.py`: local harness and optional gRPC transport binding
- `service.py`: transport-independent signing orchestration layer
- `config.py`: daemon configuration object
- `proto_loader.py`: runtime helper for optional proto generation when gRPC dependencies are installed

Current behavior remains stubbed. The daemon validates a 64-byte digest, sequences the MMIO device abstraction, and returns a deterministic fake signature.
