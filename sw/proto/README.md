# Proto Definitions

This directory contains the canonical external service contract for the appliance.

Current notes:

- `signing.proto` remains the source of truth for the intended gRPC API.
- The repository currently ships a transport-independent software skeleton so the project can run without requiring proto code generation.
- The optional Python gRPC path uses runtime generation from this proto once `grpcio`, `grpcio-tools`, and `protobuf` are installed.
