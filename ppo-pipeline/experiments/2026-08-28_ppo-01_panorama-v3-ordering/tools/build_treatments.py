#!/usr/bin/env python3
"""Assemble treatments/<T>/<locale>/<dt>/NN_<slug>.png from renders/<dt>/<locale>/0N.png
following the orders in treatments/_manifest.json. Hard-links (same bytes, no
duplicate storage) so md5 verification after upload matches.

Usage: build_treatments.py <experiment_dir>
"""
from __future__ import annotations

import json
import os
import shutil
import sys
from pathlib import Path


def main() -> int:
    exp = Path(sys.argv[1]).resolve()
    manifest = json.loads((exp / "treatments" / "_manifest.json").read_text())
    slugs = manifest["slugs"]
    locales = sorted(p.name for p in (exp / "renders" / "67").iterdir() if p.is_dir())
    for name, order in manifest["treatments"].items():
        n = 0
        for dt, cfg in manifest["display_types"].items():
            dt_locales = locales if cfg["locales"] == "all" else cfg["locales"]
            for locale in dt_locales:
                dst_dir = exp / "treatments" / name / locale / dt
                if dst_dir.exists():
                    shutil.rmtree(dst_dir)
                dst_dir.mkdir(parents=True)
                for pos, panel in enumerate(order, 1):
                    src = exp / "renders" / dt / locale / f"0{panel}.png"
                    dst = dst_dir / f"{pos:02d}_{slugs[str(panel)]}.png"
                    try:
                        os.link(src, dst)
                    except OSError:
                        shutil.copyfile(src, dst)
                    n += 1
        print(f"{name}: {n} files ({len(locales)} locales)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
