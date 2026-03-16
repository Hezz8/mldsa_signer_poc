# Client Area

`client.py` provides a lightweight client for the current phase.

Modes:

- `local`: executes against the in-process stub service without external dependencies
- `grpc`: targets the future daemon transport once `grpcio`, `grpcio-tools`, and `protobuf` are installed

The client sends a 64-byte digest request and prints the returned status and signature length.
