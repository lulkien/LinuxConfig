#!/usr/bin/env bash

set -euo pipefail

# --- Configuration ---
REPO_OWNER="eza-community"
REPO_NAME="eza"
BINARY_NAME="eza"
INSTALL_DIR="/usr/local/bin"
MAN_BASE="/usr/local/share/man"
ASSET_BINARY="eza_x86_64-unknown-linux-musl.tar.gz"
ASSET_MAN_PREFIX="man"

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
info() { echo "INFO: $1"; }
warn() { echo "WARNING: $1" >&2; }

# --- Uninstall function ---
do_uninstall() {
    local force="$1"
    echo "This will remove:"
    echo "  - ${INSTALL_DIR}/${BINARY_NAME}"
    echo "  - All eza man pages from ${MAN_BASE}/man1/ and ${MAN_BASE}/man5/"
    if [[ "$force" != "true" ]]; then
        read -p "Are you sure? (y/N) " -r confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            info "Uninstall cancelled."
            exit 0
        fi
    fi

    if [[ -f "${INSTALL_DIR}/${BINARY_NAME}" ]]; then
        rm -f "${INSTALL_DIR}/${BINARY_NAME}"
        info "Removed binary: ${INSTALL_DIR}/${BINARY_NAME}"
    else
        warn "Binary not found: ${INSTALL_DIR}/${BINARY_NAME}"
    fi

    for file in "${MAN_BASE}/man1/eza.1" \
        "${MAN_BASE}/man5/eza_colors.5" \
        "${MAN_BASE}/man5/eza_colors-explanation.5"; do
        if [[ -f "$file" ]]; then
            rm -f "$file"
            info "Removed man page: $file"
        fi
    done
    find "${MAN_BASE}/man1" "${MAN_BASE}/man5" -maxdepth 1 -type f -name "eza*" -delete 2>/dev/null || true

    if command -v mandb &>/dev/null; then
        mandb &>/dev/null && info "Updated man database (mandb)"
    fi

    info "Uninstall complete."
    exit 0
}

# --- Installation / Update function ---
do_install() {
    for cmd in curl tar; do
        if ! command -v "$cmd" &>/dev/null; then
            error_exit "$cmd is required but not installed."
        fi
    done

    if ! command -v eza &>/dev/null; then
        info "eza is not installed. Will install the latest version."
        CURRENT_VERSION=""
    else
        CURRENT_VERSION=$(eza --version 2>/dev/null | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+' | head -1 | sed 's/^v//')
        [[ -z "$CURRENT_VERSION" ]] && error_exit "Failed to get current eza version."
        info "Currently installed version: v$CURRENT_VERSION"
    fi

    info "Fetching latest release tag from GitHub API..."
    API_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest"
    TEMP_JSON=$(mktemp)

    AUTH_HEADER=()
    [[ -n "${GITHUB_TOKEN:-}" ]] && AUTH_HEADER=(-H "Authorization: token $GITHUB_TOKEN")

    curl --silent --show-error --fail "${AUTH_HEADER[@]}" -o "$TEMP_JSON" "$API_URL" || error_exit "Failed to fetch release information."

    if command -v jq &>/dev/null; then
        LATEST_TAG=$(jq -r '.tag_name // empty' "$TEMP_JSON")
    else
        LATEST_TAG=$(grep -o '"tag_name"[[:space:]]*:[[:space:]]*"[^"]*"' "$TEMP_JSON" | sed 's/.*"\([^"]*\)"$/\1/' | head -1)
    fi
    rm -f "$TEMP_JSON"
    [[ -z "$LATEST_TAG" ]] && error_exit "Could not determine the latest release tag."

    LATEST_VERSION="${LATEST_TAG#v}"
    info "Latest release tag: $LATEST_TAG (version $LATEST_VERSION)"

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

    # Binary
    BIN_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${LATEST_TAG}/${ASSET_BINARY}"
    TARBALL_BIN="/tmp/${ASSET_BINARY}"
    info "Downloading binary ${ASSET_BINARY} ..."
    curl --progress-bar --location --fail -o "$TARBALL_BIN" "$BIN_URL" || error_exit "Binary download failed."
    info "Extracting binary ..."
    TEMP_BIN=$(mktemp -d)
    tar -xzf "$TARBALL_BIN" -C "$TEMP_BIN" || error_exit "Binary extraction failed."
    BINARY_PATH="${INSTALL_DIR}/${BINARY_NAME}"
    mv "${TEMP_BIN}/${BINARY_NAME}" "$BINARY_PATH" || error_exit "Failed to move binary."
    chmod +x "$BINARY_PATH"
    rm -rf "$TEMP_BIN" "$TARBALL_BIN"

    # Clean old man pages
    info "Cleaning old eza man pages from ${MAN_BASE}..."
    rm -f "${MAN_BASE}/man1/eza.1" 2>/dev/null || true
    rm -f "${MAN_BASE}/man5/eza_colors.5" 2>/dev/null || true
    rm -f "${MAN_BASE}/man5/eza_colors-explanation.5" 2>/dev/null || true
    find "${MAN_BASE}/man1" "${MAN_BASE}/man5" -maxdepth 1 -type f -name "eza*" -delete 2>/dev/null || true

    # Man pages
    MAN_ASSET="${ASSET_MAN_PREFIX}-${LATEST_VERSION}.tar.gz"
    MAN_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${LATEST_TAG}/${MAN_ASSET}"
    TARBALL_MAN="/tmp/${MAN_ASSET}"
    info "Downloading man pages ${MAN_ASSET} ..."
    if curl --progress-bar --location --fail -o "$TARBALL_MAN" "$MAN_URL"; then
        info "Extracting man pages ..."
        TEMP_MAN=$(mktemp -d)
        tar -xzf "$TARBALL_MAN" -C "$TEMP_MAN" || error_exit "Man page extraction failed."

        # The tarball may extract into a subdirectory like target/man-0.23.4/ or directly.
        # Find the directory containing the man pages (look for eza.1).
        MAN_DIR=$(find "$TEMP_MAN" -type f -name "eza.1" -exec dirname {} \; | head -1)
        if [[ -z "$MAN_DIR" ]]; then
            error_exit "Could not locate eza.1 in extracted man pages."
        fi

        mkdir -p "${MAN_BASE}/man1" "${MAN_BASE}/man5"

        # Copy man pages
        cp "${MAN_DIR}/eza.1" "${MAN_BASE}/man1/" || error_exit "Failed to install eza.1"
        cp "${MAN_DIR}/eza_colors.5" "${MAN_BASE}/man5/" || error_exit "Failed to install eza_colors.5"
        cp "${MAN_DIR}/eza_colors-explanation.5" "${MAN_BASE}/man5/" || error_exit "Failed to install eza_colors-explanation.5"
        info "  Installed man pages"

        rm -rf "$TEMP_MAN" "$TARBALL_MAN"

        if command -v mandb &>/dev/null; then
            mandb &>/dev/null && info "Updated man database (mandb)"
        fi
    else
        info "Man pages not available for this release (skipping)."
        rm -f "$TARBALL_MAN"
    fi

    info "Installation complete! New version: $(eza --version | head -1)"
    exit 0
}

# --- Argument parsing ---
UNINSTALL=false
FORCE=false
for arg in "$@"; do
    case "$arg" in
    --uninstall) UNINSTALL=true ;;
    --force) FORCE=true ;;
    --help | -h)
        cat <<EOF
Usage: $0 [--uninstall] [--force]

Options:
  --uninstall   Remove eza binary and man pages (requires root)
  --force       Skip confirmation prompt when used with --uninstall
  --help, -h    Show this help

Without options, the script installs or updates eza.
EOF
        exit 0
        ;;
    *) error_exit "Unknown argument: $arg. Use --help for usage." ;;
    esac
done

if [[ "$UNINSTALL" == true ]]; then
    do_uninstall "$FORCE"
else
    do_install
fi
