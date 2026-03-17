"""Backend abstraction for memory-mapped register access."""

from __future__ import annotations

from abc import ABC, abstractmethod


class BackendError(RuntimeError):
    """Raised when a backend cannot satisfy the requested MMIO operation."""


class MMIOBackend(ABC):
    """Abstract backend for 32-bit MMIO reads and writes."""

    @abstractmethod
    def read32(self, offset: int) -> int:
        raise NotImplementedError

    @abstractmethod
    def write32(self, offset: int, value: int) -> None:
        raise NotImplementedError

    def flush(self) -> None:
        """Ensure writes are visible to downstream hardware when applicable."""

    def tick(self) -> None:
        """Advance backend time for polling-oriented tests.

        Real hardware backends may ignore this hook.
        """

    def close(self) -> None:
        """Release backend resources when applicable."""