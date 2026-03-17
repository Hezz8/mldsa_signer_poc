"""Core signing service logic independent of the transport binding."""

from __future__ import annotations

from dataclasses import dataclass

from sw.mmio.device import DeviceError, DeviceTimeoutError, PQSignatureDevice
from sw.mmio import register_map as reg


class SigningServiceError(RuntimeError):
    """Base class for service-level failures."""


class SigningValidationError(SigningServiceError):
    """Raised when the request is invalid before touching hardware."""


class SigningExecutionError(SigningServiceError):
    """Raised when the device path cannot complete the request."""


@dataclass(frozen=True)
class SigningResult:
    signature: bytes
    signature_length: int
    status: str


class SigningService:
    """Thin orchestration layer over the MMIO device abstraction."""

    def __init__(
        self,
        device: PQSignatureDevice,
        timeout_s: float = 1.0,
        poll_interval_s: float = 0.0,
        success_status: str = "STUB_OK",
    ) -> None:
        self.device = device
        self.timeout_s = timeout_s
        self.poll_interval_s = poll_interval_s
        self.success_status = success_status

    def sign_prehash(self, digest: bytes) -> SigningResult:
        self._validate_digest(digest)
        try:
            signature = self.device.sign_digest(
                digest,
                timeout_s=self.timeout_s,
                poll_interval_s=self.poll_interval_s,
            )
        except (DeviceError, DeviceTimeoutError) as exc:
            raise SigningExecutionError(str(exc)) from exc
        return SigningResult(
            signature=signature,
            signature_length=len(signature),
            status=self.success_status,
        )

    def close(self) -> None:
        self.device.close()

    @staticmethod
    def _validate_digest(digest: bytes) -> None:
        if len(digest) != reg.DIGEST_SIZE:
            raise SigningValidationError(
                f"digest must be exactly {reg.DIGEST_SIZE} bytes; got {len(digest)} bytes"
            )