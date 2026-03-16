"""Client entry point for the pq-signature-appliance skeleton."""

from __future__ import annotations

import argparse
import sys

from sw.daemon.config import DaemonConfig
from sw.daemon.proto_loader import ProtoSupportError, load_proto_modules
from sw.daemon.server import create_default_service
from sw.mmio import register_map as reg


class ClientError(RuntimeError):
    """Raised when the client cannot satisfy the requested mode."""


class LocalSigningClient:
    """Local in-process client used for dependency-free smoke testing."""

    def __init__(self) -> None:
        self.service = create_default_service(DaemonConfig())

    def sign_prehash(self, digest: bytes):
        return self.service.sign_prehash(digest)



def build_digest_from_args(hex_digest: str | None) -> bytes:
    if hex_digest is None:
        return bytes(range(reg.DIGEST_SIZE))
    digest = bytes.fromhex(hex_digest)
    if len(digest) != reg.DIGEST_SIZE:
        raise ClientError(f"digest must decode to exactly {reg.DIGEST_SIZE} bytes")
    return digest



def sign_via_grpc(target: str, digest: bytes):
    try:
        import grpc
    except ImportError as exc:
        raise ClientError("gRPC mode requires the 'grpcio' package") from exc

    try:
        signing_pb2, signing_pb2_grpc = load_proto_modules()
    except ProtoSupportError as exc:
        raise ClientError(str(exc)) from exc

    with grpc.insecure_channel(target) as channel:
        stub = signing_pb2_grpc.SigningServiceStub(channel)
        response = stub.SignPrehash(signing_pb2.SignPrehashRequest(digest=digest))
    return response



def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Client for the pq-signature-appliance skeleton")
    parser.add_argument("--mode", choices=("local", "grpc"), default="local", help="transport mode")
    parser.add_argument("--target", default="127.0.0.1:50051", help="gRPC target in host:port form")
    parser.add_argument("--digest-hex", default=None, help="128 hex characters representing the 64-byte digest")
    return parser



def main(argv: list[str] | None = None) -> int:
    args = _build_parser().parse_args(argv)
    digest = build_digest_from_args(args.digest_hex)

    if args.mode == "local":
        response = LocalSigningClient().sign_prehash(digest)
        status = response.status
        signature = response.signature
        signature_length = response.signature_length
    else:
        response = sign_via_grpc(args.target, digest)
        status = response.status
        signature = response.signature
        signature_length = response.signature_length

    print(f"status={status}")
    print(f"signature_length={signature_length}")
    print(f"signature_hex={signature.hex()}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
