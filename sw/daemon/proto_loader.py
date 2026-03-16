"""Helpers for optional runtime gRPC/proto code generation."""

from __future__ import annotations

import importlib
import sys
import tempfile
from pathlib import Path
from types import ModuleType


class ProtoSupportError(RuntimeError):
    """Raised when optional gRPC/protobuf dependencies are unavailable."""


_PROTO_CACHE: tuple[ModuleType, ModuleType] | None = None


def load_proto_modules() -> tuple[ModuleType, ModuleType]:
    global _PROTO_CACHE
    if _PROTO_CACHE is not None:
        return _PROTO_CACHE

    try:
        from grpc_tools import protoc
    except ImportError as exc:
        raise ProtoSupportError(
            "gRPC support requires the 'grpcio-tools' package for runtime proto generation"
        ) from exc

    proto_dir = Path(__file__).resolve().parents[1] / "proto"
    proto_file = proto_dir / "signing.proto"
    temp_dir = Path(tempfile.mkdtemp(prefix="pqsig_proto_"))

    args = [
        "grpc_tools.protoc",
        f"-I{proto_dir}",
        f"--python_out={temp_dir}",
        f"--grpc_python_out={temp_dir}",
        str(proto_file),
    ]
    result = protoc.main(args)
    if result != 0:
        raise ProtoSupportError(f"proto generation failed with exit code {result}")

    sys.path.insert(0, str(temp_dir))
    signing_pb2 = importlib.import_module("signing_pb2")
    signing_pb2_grpc = importlib.import_module("signing_pb2_grpc")
    _PROTO_CACHE = (signing_pb2, signing_pb2_grpc)
    return _PROTO_CACHE
