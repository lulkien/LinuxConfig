#!/usr/bin/env bash
set -euo pipefail

# --- Configuration ---
REPO_OWNER="zellij-org"
REPO_NAME="zellij"
ASSET_NAME="zellij-x86_64-unknown-linux-musl.tar.gz"
INSTALL_DIR="/usr/local/bin"
BINARY_NAME="zellij"
BINARY_PATH="${INSTALL_DIR}/${BINARY_NAME}"

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

# --- Get currently installed version ---
if ! command -v zellij &>/dev/null; then
    info "zellij is not installed. Will install the latest version."
    CURRENT_VERSION=""
else
    # zellij --version outputs something like "zellij 0.44.1"
    CURRENT_VERSION=$(zellij --version 2>/dev/null | awk '{print $2}' | sed 's/^v//' || echo "")
    if [[ -z "$CURRENT_VERSION" ]]; then
        error_exit "Failed to get current zellij version."
    fi
    info "Currently installed version: v$CURRENT_VERSION"
fi

# --- Fetch latest release tag from GitHub ---
info "Fetching latest release tag from GitHub API..."
API_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest"
TEMP_JSON=$(mktemp)

AUTH_HEADER=()
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
    AUTH_HEADER=(-H "Authorization: token $GITHUB_TOKEN")
fi

if ! curl --silent --show-error --fail "${AUTH_HEADER[@]}" -o "$TEMP_JSON" "$API_URL"; then
    error_exit "Failed to fetch release information from GitHub API."
fi

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

# --- Version comparison (semver-aware) ---
version_gt() {
    # Returns 0 (true) if $1 > $2, using sort -V
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

# --- Download and install ---
DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${LATEST_TAG}/${ASSET_NAME}"
TARBALL_PATH="/tmp/${ASSET_NAME}"

info "Downloading $ASSET_NAME ..."
if ! curl --progress-bar --location --fail -o "$TARBALL_PATH" "$DOWNLOAD_URL"; then
    error_exit "Download failed. Check URL: $DOWNLOAD_URL"
fi

info "Extracting ..."
TEMP_EXTRACT_DIR=$(mktemp -d)
if ! tar -xzf "$TARBALL_PATH" -C "$TEMP_EXTRACT_DIR"; then
    error_exit "Extraction failed."
fi

EXTRACTED_BINARY="${TEMP_EXTRACT_DIR}/${BINARY_NAME}"
if [[ ! -f "$EXTRACTED_BINARY" ]]; then
    error_exit "Extracted binary not found at $EXTRACTED_BINARY"
fi

info "Installing to ${BINARY_PATH} ..."
mv "$EXTRACTED_BINARY" "$BINARY_PATH" || error_exit "Failed to move binary to ${INSTALL_DIR}."
chmod +x "$BINARY_PATH" || error_exit "Failed to make binary executable."

# --- Clean up ---
rm -rf "$TEMP_EXTRACT_DIR"
rm -f "$TARBALL_PATH"

info "Update complete! New version: $(zellij --version)"

exit 0
