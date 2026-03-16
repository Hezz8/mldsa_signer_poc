"""Transport bindings for the pq-signature-appliance daemon skeleton."""

from __future__ import annotations

import logging
from concurrent import futures
from dataclasses import dataclass

from sw.mmio.device import PQSignatureDevice
from sw.mmio.fake_backend import FakeMMIOBackend

from .config import DaemonConfig
from .proto_loader import ProtoSupportError, load_proto_modules
from .service import SigningExecutionError, SigningService, SigningValidationError


class GrpcDependencyError(RuntimeError):
    """Raised when the gRPC transport cannot be started in the current environment."""


@dataclass
class LocalSigningServer:
    """Simple local harness used when gRPC dependencies are unavailable."""

    service: SigningService

    def handle_digest(self, digest: bytes):
        return self.service.sign_prehash(digest)


class GrpcSigningServer:
    """Optional real gRPC server binding generated at runtime from the canonical proto."""

    def __init__(self, service: SigningService, config: DaemonConfig) -> None:
        self.service = service
        self.config = config
        self._grpc_server = None

    def start(self) -> None:
        try:
            import grpc
        except ImportError as exc:
            raise GrpcDependencyError("gRPC transport requires the 'grpcio' package") from exc

        try:
            signing_pb2, signing_pb2_grpc = load_proto_modules()
        except ProtoSupportError as exc:
            raise GrpcDependencyError(str(exc)) from exc

        service = self.service

        class SigningServicer(signing_pb2_grpc.SigningServiceServicer):
            def SignPrehash(self, request, context):
                try:
                    result = service.sign_prehash(request.digest)
                except SigningValidationError as exc:
                    context.abort(grpc.StatusCode.INVALID_ARGUMENT, str(exc))
                except SigningExecutionError as exc:
                    context.abort(grpc.StatusCode.INTERNAL, str(exc))
                return signing_pb2.SignPrehashResponse(
                    signature=result.signature,
                    signature_length=result.signature_length,
                    status=result.status,
                )

        server = grpc.server(futures.ThreadPoolExecutor(max_workers=self.config.max_workers))
        signing_pb2_grpc.add_SigningServiceServicer_to_server(SigningServicer(), server)
        server.add_insecure_port(self.config.bind_address)
        server.start()
        self._grpc_server = server
        logging.info("gRPC signing server listening on %s", self.config.bind_address)

    def wait_for_termination(self) -> None:
        if self._grpc_server is None:
            raise RuntimeError("server not started")
        self._grpc_server.wait_for_termination()



def create_default_service(config: DaemonConfig) -> SigningService:
    device = PQSignatureDevice(FakeMMIOBackend())
    return SigningService(device=device, timeout_s=config.timeout_s, poll_interval_s=config.poll_interval_s)
