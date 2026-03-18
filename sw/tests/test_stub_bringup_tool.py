from __future__ import annotations

import io
import unittest
from contextlib import redirect_stdout

from sw.tools.run_stub_bringup import main


class StubBringupToolTests(unittest.TestCase):
    def test_fake_backend_path_reports_pass(self) -> None:
        output = io.StringIO()
        with redirect_stdout(output):
            rc = main(["--backend", "fake"])
        self.assertEqual(rc, 0)
        rendered = output.getvalue()
        self.assertIn("== Probe ==", rendered)
        self.assertIn("== Selftest ==", rendered)
        self.assertIn("verified_stub_signature=true", rendered)
        self.assertIn("BRINGUP_RESULT=PASS", rendered)

    def test_real_backend_missing_device_reports_fail(self) -> None:
        output = io.StringIO()
        with redirect_stdout(output):
            rc = main([
                "--backend",
                "real",
                "--mmio-base-addr",
                "0xA0000000",
                "--devmem-path",
                "/definitely/missing",
            ])
        self.assertEqual(rc, 2)
        self.assertIn("BRINGUP_RESULT=FAIL", output.getvalue())


if __name__ == "__main__":
    unittest.main()
