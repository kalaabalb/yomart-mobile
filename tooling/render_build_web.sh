#!/usr/bin/env bash
set -euo pipefail

# Render Static Sites does not provide the Flutter SDK. Keep the toolchain
# pinned to the stable version used by local verification, and authenticate
# the downloaded archive against Flutter's official release manifest value.
readonly FLUTTER_VERSION='3.44.9'
readonly FLUTTER_ARCHIVE_SHA256='a9120fa4a01048bdef438ddc3a2d4b7389662ea98a95db86eeaf10382bc4efcb'
readonly FLUTTER_ARCHIVE_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
flutter_bin="${FLUTTER_BIN:-}"
sdk_tmp=''

cleanup() {
  if [[ -n "$sdk_tmp" ]]; then rm -rf -- "$sdk_tmp"; fi
}
trap cleanup EXIT

if [[ -z "$flutter_bin" ]]; then
  if command -v flutter >/dev/null 2>&1; then
    flutter_bin="$(command -v flutter)"
  else
    for command_name in curl tar sha256sum; do
      command -v "$command_name" >/dev/null 2>&1 || {
        echo "Missing required build command: $command_name" >&2
        exit 1
      }
    done
    sdk_tmp="$(mktemp -d "${TMPDIR:-/tmp}/yomart-flutter-${FLUTTER_VERSION}.XXXXXX")"
    archive="$sdk_tmp/flutter.tar.xz"
    curl --fail --location --silent --show-error "$FLUTTER_ARCHIVE_URL" --output "$archive"
    printf '%s  %s\n' "$FLUTTER_ARCHIVE_SHA256" "$archive" | sha256sum --check --status || {
      echo 'Flutter SDK archive checksum did not match the pinned official release.' >&2
      exit 1
    }
    tar -xJf "$archive" -C "$sdk_tmp"
    flutter_bin="$sdk_tmp/flutter/bin/flutter"
  fi
fi

[[ -x "$flutter_bin" ]] || {
  echo 'FLUTTER_BIN must point to an executable Flutter SDK binary.' >&2
  exit 1
}
export PATH="$(dirname "$flutter_bin"):$PATH"

installed_version="$("$flutter_bin" --version --machine | node -e 'let input=""; process.stdin.on("data", part => input += part); process.stdin.on("end", () => { try { process.stdout.write(JSON.parse(input).frameworkVersion || ""); } catch { process.exitCode = 2; } });')"
[[ "$installed_version" == "$FLUTTER_VERSION" ]] || {
  echo "Flutter $FLUTTER_VERSION is required; found ${installed_version:-unknown}." >&2
  exit 1
}

cd "$repo_root"
"$flutter_bin" pub get
node tooling/build_web.mjs
