from __future__ import annotations

import io
import unittest
from contextlib import redirect_stdout

from sw.daemon.main import main
from sw.mmio.device import PQSignatureDevice
from sw.mmio.fake_backend import FakeMMIOBackend
from sw.mmio.probe import probe_device


class ProbeTests(unittest.TestCase):
    def test_probe_device_reports_fake_backend_idle_state(self) -> None:
        device = PQSignatureDevice(FakeMMIOBackend())
        report = probe_device(device)
        self.assertEqual(report.error_name, "none")
        self.assertEqual(report.signature_length, 0)
        self.assertIn("idle", report.status_flags)

    def test_cli_probe_mmio_runs_in_fake_mode(self) -> None:
        output = io.StringIO()
        with redirect_stdout(output):
            rc = main(["probe-mmio", "--backend", "fake"])
        self.assertEqual(rc, 0)
        rendered = output.getvalue()
        self.assertIn("backend=fake", rendered)
        self.assertIn("status_flags=idle", rendered)


if __name__ == "__main__":
    unittest.main()