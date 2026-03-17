"""Transport bindings for the pq-signature-appliance daemon skeleton."""

from __future__ import annotations

import logging
from concurrent import futures
from dataclasses import dataclass

from sw.mmio.backend import BackendError
from sw.mmio.device import PQSignatureDevice
from sw.mmio.fake_backend import FakeMMIOBackend
from sw.mmio.real_backend import RealMMIOBackend

from .config import DaemonConfig
from .proto_loader import ProtoSupportError, load_proto_modules
from .service import SigningExecutionError, SigningService, SigningValidationError


class GrpcDependencyError(RuntimeError):
    """Raised when the gRPC transport cannot be started in the current environment."""


class BackendSelectionError(RuntimeError):
    """Raised when the configured backend cannot be created."""


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


def create_backend_from_config(config: DaemonConfig):
    if config.backend_mode == "fake":
        return FakeMMIOBackend()
    if config.backend_mode == "real":
        if config.mmio_base_addr is None:
            raise BackendSelectionError(
                "real backend requires PQSIG_MMIO_BASE_ADDR or --mmio-base-addr"
            )
        try:
            return RealMMIOBackend(
                base_address=config.mmio_base_addr,
                region_size=config.mmio_region_size,
                device_path=config.devmem_path,
            )
        except BackendError as exc:
            raise BackendSelectionError(str(exc)) from exc
    raise BackendSelectionError(f"unsupported backend mode: {config.backend_mode}")


def create_device_from_config(config: DaemonConfig) -> PQSignatureDevice:
    return PQSignatureDevice(create_backend_from_config(config))


def create_default_service(config: DaemonConfig) -> SigningService:
    device = create_device_from_config(config)
    success_status = "STUB_OK" if config.backend_mode == "fake" else "DEVICE_OK"
    return SigningService(
        device=device,
        timeout_s=config.timeout_s,
        poll_interval_s=config.poll_interval_s,
        success_status=success_status,
    )