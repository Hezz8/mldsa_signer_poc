from __future__ import annotations

import os
import unittest
from unittest.mock import patch

from sw.daemon.config import DaemonConfig
from sw.daemon.server import BackendSelectionError, create_backend_from_config, create_default_service
from sw.mmio import register_map as reg


class BackendSelectionTests(unittest.TestCase):
    def test_default_service_uses_fake_backend_by_default(self) -> None:
        service = create_default_service(DaemonConfig())
        try:
            result = service.sign_prehash(bytes(range(reg.DIGEST_SIZE)))
        finally:
            service.close()
        self.assertEqual(result.status, "STUB_OK")
        self.assertEqual(result.signature, reg.build_stub_signature(bytes(range(reg.DIGEST_SIZE))))

    def test_real_backend_requires_base_address(self) -> None:
        config = DaemonConfig(backend_mode="real")
        with self.assertRaises(BackendSelectionError):
            create_backend_from_config(config)

    def test_env_parsing_supports_backend_and_base_address(self) -> None:
        with patch.dict(
            os.environ,
            {
                "PQSIG_BACKEND": "real",
                "PQSIG_MMIO_BASE_ADDR": "0xA0000000",
                "PQSIG_MMIO_REGION_SIZE": hex(reg.MMIO_REGION_SIZE),
                "PQSIG_DEVMEM_PATH": "/tmp/fake-devmem",
            },
            clear=False,
        ):
            config = DaemonConfig.from_env()
        self.assertEqual(config.backend_mode, "real")
        self.assertEqual(config.mmio_base_addr, 0xA0000000)
        self.assertEqual(config.mmio_region_size, reg.MMIO_REGION_SIZE)
        self.assertEqual(config.devmem_path, "/tmp/fake-devmem")


if __name__ == "__main__":
    unittest.main()