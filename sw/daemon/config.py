"""Configuration helpers for the software daemon skeleton."""

from __future__ import annotations

import os
from dataclasses import dataclass


@dataclass(frozen=True)
class DaemonConfig:
    host: str = "127.0.0.1"
    port: int = 50051
    timeout_s: float = 1.0
    poll_interval_s: float = 0.0
    max_workers: int = 4

    @property
    def bind_address(self) -> str:
        return f"{self.host}:{self.port}"

    @classmethod
    def from_env(cls) -> "DaemonConfig":
        return cls(
            host=os.getenv("PQSIG_HOST", cls.host),
            port=int(os.getenv("PQSIG_PORT", cls.port)),
            timeout_s=float(os.getenv("PQSIG_TIMEOUT_S", cls.timeout_s)),
            poll_interval_s=float(os.getenv("PQSIG_POLL_INTERVAL_S", cls.poll_interval_s)),
            max_workers=int(os.getenv("PQSIG_MAX_WORKERS", cls.max_workers)),
        )
