"""Entry point for the pq-signature-appliance software daemon skeleton."""

from __future__ import annotations

import argparse
import logging
import sys

from sw.mmio import register_map as reg

from .config import DaemonConfig
from .server import GrpcDependencyError, GrpcSigningServer, LocalSigningServer, create_default_service



def _default_digest() -> bytes:
    return bytes(range(reg.DIGEST_SIZE))



def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="PQ signature appliance daemon skeleton")
    parser.add_argument("mode", choices=("serve", "selftest"), help="execution mode")
    parser.add_argument("--host", default=None, help="server bind host")
    parser.add_argument("--port", type=int, default=None, help="server bind port")
    parser.add_argument("--timeout-s", type=float, default=None, help="device timeout in seconds")
    return parser



def main(argv: list[str] | None = None) -> int:
    logging.basicConfig(level=logging.INFO, format="%(levelname)s %(message)s")
    args = _build_parser().parse_args(argv)
    config = DaemonConfig.from_env()
    if args.host is not None:
        config = DaemonConfig(
            host=args.host,
            port=config.port if args.port is None else args.port,
            timeout_s=config.timeout_s if args.timeout_s is None else args.timeout_s,
            poll_interval_s=config.poll_interval_s,
            max_workers=config.max_workers,
        )
    elif args.port is not None or args.timeout_s is not None:
        config = DaemonConfig(
            host=config.host,
            port=config.port if args.port is None else args.port,
            timeout_s=config.timeout_s if args.timeout_s is None else args.timeout_s,
            poll_interval_s=config.poll_interval_s,
            max_workers=config.max_workers,
        )

    service = create_default_service(config)

    if args.mode == "selftest":
        local_server = LocalSigningServer(service)
        result = local_server.handle_digest(_default_digest())
        print(f"selftest status={result.status} signature_length={result.signature_length}")
        print(result.signature.hex())
        return 0

    grpc_server = GrpcSigningServer(service, config)
    try:
        grpc_server.start()
    except GrpcDependencyError as exc:
        logging.error("cannot start gRPC server: %s", exc)
        logging.error("install 'grpcio', 'grpcio-tools', and 'protobuf' to enable the transport binding")
        return 2
    grpc_server.wait_for_termination()
    return 0


if __name__ == "__main__":
    sys.exit(main())
