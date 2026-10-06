import hashlib
import json
import shutil
import sys
import tempfile
import urllib.request
import zipfile
from pathlib import Path
from hxgmod import staging_directory

RELEASE_URL = "https://api.github.com/repos/luttje/glua-api-snippets/releases/latest"

API_DIR = Path("api")
JSON_DIR = API_DIR / "raw"
LUA_DIR = API_DIR / "lua"
SOURCE_FILE = API_DIR / "source.json"


def request(url: str):
    req = urllib.request.Request(
        url,
        headers={
            "User-Agent": "HxGMod-Binding-Updater",
            "Accept": "application/vnd.github+json",
        },
    )
    return urllib.request.urlopen(req, timeout=60)


def find_asset(assets: list[dict], suffix: str) -> dict | None:
    return next(
        (asset for asset in assets if asset.get("name", "").endswith(suffix)),
        None,
    )


def download_and_extract(asset: dict, target_dir: Path) -> str:
    asset_name = asset["name"]
    download_url = asset["browser_download_url"]

    print(f"Downloading {asset_name}...")

    with staging_directory(API_DIR.parent / '.work', prefix="api-") as temp_name:
        temp_dir = Path(temp_name)
        zip_path = temp_dir / asset_name
        extract_dir = temp_dir / "extracted"
        extract_dir.mkdir()

        sha256 = hashlib.sha256()

        with request(download_url) as response, zip_path.open("wb") as output:
            while True:
                chunk = response.read(1024 * 1024)
                if not chunk:
                    break

                output.write(chunk)
                sha256.update(chunk)

        digest = "sha256:" + sha256.hexdigest()
        expected_digest = asset.get("digest")

        if expected_digest and digest != expected_digest:
            raise RuntimeError(
                f"SHA-256 mismatch for {asset_name}: "
                f"expected {expected_digest}, got {digest}"
            )

        with zipfile.ZipFile(zip_path) as archive:
            root = extract_dir.resolve()

            for member in archive.infolist():
                destination = (extract_dir / member.filename).resolve()

                try:
                    destination.relative_to(root)
                except ValueError as exc:
                    raise RuntimeError(
                        f"Unsafe archive path: {member.filename}"
                    ) from exc

            archive.extractall(extract_dir)

        if target_dir.exists():
            shutil.rmtree(target_dir)

        shutil.copytree(extract_dir, target_dir)

    return digest


def main() -> int:
    API_DIR.mkdir(parents=True, exist_ok=True)

    print("Fetching latest glua-api-snippets release...")

    with request(RELEASE_URL) as response:
        release = json.load(response)

    assets = release.get("assets", [])

    json_asset = find_asset(assets, ".json.zip")
    lua_asset = find_asset(assets, ".lua.zip")

    if json_asset is None:
        print("ERROR: Latest release has no .json.zip asset.", file=sys.stderr)
        return 1

    if lua_asset is None:
        print("ERROR: Latest release has no .lua.zip asset.", file=sys.stderr)
        return 1

    tag = release.get("tag_name", "unknown")

    print(f"Release: {tag}")

    try:
        json_digest = download_and_extract(json_asset, JSON_DIR)
        lua_digest = download_and_extract(lua_asset, LUA_DIR)
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1

    SOURCE_FILE.write_text(
        json.dumps(
            {
                "repository": "luttje/glua-api-snippets",
                "tag": tag,
                "json": {
                    "asset": json_asset["name"],
                    "digest": json_digest,
                },
                "lua": {
                    "asset": lua_asset["name"],
                    "digest": lua_digest,
                },
            },
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )

    json_files = list(JSON_DIR.rglob("*.json"))
    lua_files = list(LUA_DIR.rglob("*.lua"))

    print(f"Extracted {len(json_files)} JSON files.")
    print(f"Extracted {len(lua_files)} Lua annotation files.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
