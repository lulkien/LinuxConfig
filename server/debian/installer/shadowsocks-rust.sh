#!/usr/bin/env bash
set -euo pipefail

# --- Configuration ---
REPO_OWNER="shadowsocks"
REPO_NAME="shadowsocks-rust"
ASSET_PATTERN="shadowsocks-*.x86_64-unknown-linux-musl.tar.xz"
INSTALL_DIR="/usr/local/bin"
BINARIES=("sslocal" "ssmanager" "ssserver" "ssservice" "ssurl")

# --- Check root privileges ---
if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root (no sudo, just root)." >&2
    exit 1
fi

# --- Helper functions ---
error_exit() {
    echo "ERROR: $1" >&2
    exit 1
}

info() {
    echo "INFO: $1"
}

# --- Check required commands ---
for cmd in curl tar; do
    if ! command -v "$cmd" &>/dev/null; then
        error_exit "$cmd is required but not installed."
    fi
done

# --- Get currently installed version (using ssservice) ---
if ! command -v ssservice &>/dev/null; then
    info "shadowsocks-rust is not installed. Will install the latest version."
    CURRENT_VERSION=""
else
    # ssservice --version output example: "shadowsocks 1.24.0"
    CURRENT_VERSION=$(ssservice --version 2>/dev/null | awk '{print $2}' | sed 's/^v//' || echo "")
    if [[ -z "$CURRENT_VERSION" ]]; then
        error_exit "Failed to get current shadowsocks-rust version."
    fi
    info "Currently installed version: v$CURRENT_VERSION"
fi

# --- Fetch latest release tag from GitHub ---
info "Fetching latest release tag from GitHub API..."
API_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest"
TEMP_JSON=$(mktemp)

# Optional: use GITHUB_TOKEN from environment for higher rate limit
AUTH_HEADER=()
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
    AUTH_HEADER=(-H "Authorization: token $GITHUB_TOKEN")
fi

if ! curl --silent --show-error --fail "${AUTH_HEADER[@]}" -o "$TEMP_JSON" "$API_URL"; then
    error_exit "Failed to fetch release information from GitHub API."
fi

# Extract tag_name (prefer jq, fallback to grep/sed)
if command -v jq &>/dev/null; then
    LATEST_TAG=$(jq -r '.tag_name // empty' "$TEMP_JSON")
else
    LATEST_TAG=$(grep -o '"tag_name"[[:space:]]*:[[:space:]]*"[^"]*"' "$TEMP_JSON" | sed 's/.*"\([^"]*\)"$/\1/' | head -1)
fi
rm -f "$TEMP_JSON"

if [[ -z "$LATEST_TAG" ]]; then
    error_exit "Could not determine the latest release tag."
fi

# Remove leading 'v' for version comparison
LATEST_VERSION="${LATEST_TAG#v}"
info "Latest release tag: $LATEST_TAG (version $LATEST_VERSION)"

# --- Version comparison (semver-aware using sort -V) ---
version_gt() {
    test "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" != "$1"
}

if [[ -n "$CURRENT_VERSION" ]]; then
    if ! version_gt "$LATEST_VERSION" "$CURRENT_VERSION"; then
        info "Already up to date (current v$CURRENT_VERSION = latest v$LATEST_VERSION). Exiting."
        exit 0
    fi
    info "Newer version available: v$LATEST_VERSION (current v$CURRENT_VERSION). Updating..."
else
    info "No existing installation found. Installing v$LATEST_VERSION..."
fi

# --- Find the exact asset name (the versioned filename) ---
# GitHub release assets have names like "shadowsocks-v1.24.0.x86_64-unknown-linux-musl.tar.xz"
# We need to construct the asset name dynamically using the tag.
ASSET_NAME="shadowsocks-${LATEST_TAG}.x86_64-unknown-linux-musl.tar.xz"
DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${LATEST_TAG}/${ASSET_NAME}"
TARBALL_PATH="/tmp/${ASSET_NAME}"

info "Downloading $ASSET_NAME ..."
if ! curl --progress-bar --location --fail -o "$TARBALL_PATH" "$DOWNLOAD_URL"; then
    error_exit "Download failed. Check URL: $DOWNLOAD_URL"
fi

# --- Extract the tarball (.tar.xz) ---
info "Extracting ..."
TEMP_EXTRACT_DIR=$(mktemp -d)

# tar auto-detects compression (xz) with -xvf; but explicitly use -xJf for safety
if ! tar -xJf "$TARBALL_PATH" -C "$TEMP_EXTRACT_DIR"; then
    error_exit "Extraction failed. The file may be corrupted or not in xz format."
fi

# The tarball extracts a directory like "shadowsocks-v1.24.0.x86_64-unknown-linux-musl"
# and inside that directory are all the binaries. Find that directory.
EXTRACTED_DIR=$(find "$TEMP_EXTRACT_DIR" -maxdepth 1 -type d -name "shadowsocks-*" | head -1)
if [[ -z "$EXTRACTED_DIR" ]]; then
    # Fallback: maybe binaries are directly in the temp dir
    EXTRACTED_DIR="$TEMP_EXTRACT_DIR"
fi

# --- Install each binary ---
info "Installing binaries to ${INSTALL_DIR} ..."
for bin in "${BINARIES[@]}"; do
    SRC="${EXTRACTED_DIR}/${bin}"
    DST="${INSTALL_DIR}/${bin}"
    if [[ ! -f "$SRC" ]]; then
        error_exit "Binary not found: $SRC"
    fi
    mv "$SRC" "$DST" || error_exit "Failed to move $bin to $INSTALL_DIR"
    chmod +x "$DST" || error_exit "Failed to make $bin executable"
    info "  Installed $bin"
done

# --- Clean up ---
rm -rf "$TEMP_EXTRACT_DIR"
rm -f "$TARBALL_PATH"

info "Update complete! New version: $(ssservice --version)"
exit 0
