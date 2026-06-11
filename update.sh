#!/usr/bin/env bash
# Usage: ./update.sh 7.7
# Or just ./update.sh to re-hash current version

set -euo pipefail

VERSION="${1:-7.7}"
MAJOR="${VERSION//./}"   # "77" from "7.7"
URL="https://cheatengine.org/download/CheatEngineLinux${MAJOR}.zip"

echo "Fetching hash for CE ${VERSION} from ${URL}..."
HASH=$(nix hash convert --hash-algo sha256 \
  "$(nix-prefetch-url --unpack "${URL}" 2>/dev/null)")

echo "Hash: ${HASH}"

sed -i "s|version = \".*\"|version = \"${VERSION}\"|" package.nix
sed -i "s|hash = \"sha256-.*\"|hash = \"${HASH}\"|" package.nix
sed -i "s|CheatEngineLinux[0-9]*.zip|CheatEngineLinux${MAJOR}.zip|" package.nix

echo "Updated package.nix to CE ${VERSION}"
