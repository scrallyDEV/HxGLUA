"""Compatibility entrypoint; packaging lives in hxgmod.py."""
import sys
from pathlib import Path
from hxgmod import package_project, HxGModError

if __name__ == "__main__":
    try:
        package_project(Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve())
    except (HxGModError, OSError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        raise SystemExit(1)
