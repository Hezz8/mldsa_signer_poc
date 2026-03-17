"""Configuration helpers for the software daemon skeleton."""

from __future__ import annotations

import os
from dataclasses import dataclass, replace

from sw.mmio import register_map as reg


class ConfigError(ValueError):
    """Raised when daemon configuration values are invalid."""


@dataclass(frozen=True)
class DaemonConfig:
    host: str = "127.0.0.1"
    port: int = 50051
    timeout_s: float = 1.0
    poll_interval_s: float = 0.0
    max_workers: int = 4
    backend_mode: str = "fake"
    mmio_base_addr: int | None = None
    mmio_region_size: int = reg.MMIO_REGION_SIZE
    devmem_path: str = "/dev/mem"

    @property
    def bind_address(self) -> str:
        return f"{self.host}:{self.port}"

    def with_overrides(self, **kwargs) -> "DaemonConfig":
        cleaned = {key: value for key, value in kwargs.items() if value is not None}
        updated = replace(self, **cleaned)
        updated._validate()
        return updated

    def _validate(self) -> None:
        if self.backend_mode not in {"fake", "real"}:
            raise ConfigError(f"unsupported backend mode: {self.backend_mode}")
        if self.timeout_s <= 0.0:
            raise ConfigError("timeout_s must be positive")
        if self.poll_interval_s < 0.0:
            raise ConfigError("poll_interval_s must be non-negative")
        if self.mmio_region_size <= 0:
            raise ConfigError("mmio_region_size must be positive")

    @classmethod
    def from_env(cls) -> "DaemonConfig":
        config = cls(
            host=os.getenv("PQSIG_HOST", cls.host),
            port=int(os.getenv("PQSIG_PORT", cls.port)),
            timeout_s=float(os.getenv("PQSIG_TIMEOUT_S", cls.timeout_s)),
            poll_interval_s=float(os.getenv("PQSIG_POLL_INTERVAL_S", cls.poll_interval_s)),
            max_workers=int(os.getenv("PQSIG_MAX_WORKERS", cls.max_workers)),
            backend_mode=os.getenv("PQSIG_BACKEND", cls.backend_mode).strip().lower(),
            mmio_base_addr=_parse_optional_int(os.getenv("PQSIG_MMIO_BASE_ADDR")),
            mmio_region_size=_parse_optional_int(os.getenv("PQSIG_MMIO_REGION_SIZE"), cls.mmio_region_size),
            devmem_path=os.getenv("PQSIG_DEVMEM_PATH", cls.devmem_path),
        )
        config._validate()
        return config


def _parse_optional_int(value: str | None, default: int | None = None) -> int | None:
    if value is None or value == "":
        return default
    return int(value, 0)