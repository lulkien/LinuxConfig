#!/usr/bin/env bash
set -euo pipefail

# ----------------------------------------------------------------------
# Universal GitHub Release Installer/Updater/Uninstaller
# Supports: eza, shadowsocks-rust, zellij
# Usage: $0 <tool> [--uninstall] [--force]
# ----------------------------------------------------------------------

# --- Global root check ---
if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root (no sudo, just root)." >&2
    exit 1
fi

# --- Helper functions ---
error_exit() { echo "ERROR: $1" >&2; exit 1; }
info() { echo "INFO: $1"; }
warn() { echo "WARNING: $1" >&2; }

# --- Tool configurations ---
declare -A TOOL_CONFIG
TOOL_CONFIG=(
    # Eza 
    ["eza:repo_owner"]="eza-community"
    ["eza:repo_name"]="eza"
    ["eza:binary_name"]="eza"
    ["eza:version_cmd"]="eza --version | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+' | head -1 | sed 's/^v//'"
    ["eza:binary_asset"]="eza_x86_64-unknown-linux-musl.tar.gz"
    ["eza:man_asset_prefix"]="man"
    ["eza:has_man"]="true"
    ["eza:binaries"]="eza"

    # Shadowsocks 
    ["shadowsocks:repo_owner"]="shadowsocks"
    ["shadowsocks:repo_name"]="shadowsocks-rust"
    ["shadowsocks:binary_name"]="ssservice"   # primary binary for version check
    ["shadowsocks:version_cmd"]="ssservice --version 2>/dev/null | awk '{print \$2}' | sed 's/^v//'"
    ["shadowsocks:binary_asset"]="shadowsocks-{tag}.x86_64-unknown-linux-musl.tar.xz"
    ["shadowsocks:man_asset_prefix"]=""
    ["shadowsocks:has_man"]="false"
    ["shadowsocks:binaries"]="sslocal ssserver ssservice ssurl ssmanager"

    # Zellij
    ["zellij:repo_owner"]="zellij-org"
    ["zellij:repo_name"]="zellij"
    ["zellij:binary_name"]="zellij"
    ["zellij:version_cmd"]="zellij --version 2>/dev/null | awk '{print \$2}' | sed 's/^v//'"
    ["zellij:binary_asset"]="zellij-x86_64-unknown-linux-musl.tar.gz"
    ["zellij:man_asset_prefix"]=""
    ["zellij:has_man"]="false"
    ["zellij:binaries"]="zellij"
)

# --- Parse arguments ---
if [[ $# -lt 1 ]]; then
    cat <<EOF
Usage: $0 <tool> [--uninstall] [--force]

Tools: eza, shadowsocks, zellij

Examples:
  $0 eza                     # install/update eza
  $0 eza --uninstall         # remove eza (with confirmation)
  $0 eza --uninstall --force # remove without confirmation
  $0 shadowsocks
  $0 zellij
EOF
    exit 1
fi

TOOL="$1"
UNINSTALL=false
FORCE=false
shift
for arg in "$@"; do
    case "$arg" in
        --uninstall) UNINSTALL=true ;;
        --force) FORCE=true ;;
        *) error_exit "Unknown argument: $arg. Use --uninstall or --force" ;;
    esac
done

# Validate tool
if [[ ! -v "TOOL_CONFIG[$TOOL:repo_owner]" ]]; then
    error_exit "Unknown tool: $TOOL. Supported: eza, shadowsocks, zellij"
fi

# --- Extract configuration variables for the selected tool ---
REPO_OWNER="${TOOL_CONFIG[$TOOL:repo_owner]}"
REPO_NAME="${TOOL_CONFIG[$TOOL:repo_name]}"
BINARY_NAME="${TOOL_CONFIG[$TOOL:binary_name]}"
VERSION_CMD="${TOOL_CONFIG[$TOOL:version_cmd]}"
BINARY_ASSET_TEMPLATE="${TOOL_CONFIG[$TOOL:binary_asset]}"
MAN_PREFIX="${TOOL_CONFIG[$TOOL:man_asset_prefix]:-}"
HAS_MAN="${TOOL_CONFIG[$TOOL:has_man]:-false}"
BINARIES="${TOOL_CONFIG[$TOOL:binaries]}"
INSTALL_DIR="/usr/local/bin"
MAN_BASE="/usr/local/share/man"

# --- Uninstall function ---
do_uninstall() {
    local force="$1"
    echo "This will remove:"
    for bin in $BINARIES; do
        echo "  - ${INSTALL_DIR}/${bin}"
    done
    if [[ "$HAS_MAN" == "true" ]]; then
        echo "  - All ${TOOL} man pages from ${MAN_BASE}/man1/ and ${MAN_BASE}/man5/"
    fi
    if [[ "$force" != "true" ]]; then
        read -p "Are you sure? (y/N) " -r confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            info "Uninstall cancelled."
            exit 0
        fi
    fi

    # Remove binaries
    for bin in $BINARIES; do
        if [[ -f "${INSTALL_DIR}/${bin}" ]]; then
            rm -f "${INSTALL_DIR}/${bin}"
            info "Removed binary: ${INSTALL_DIR}/${bin}"
        else
            warn "Binary not found: ${INSTALL_DIR}/${bin}"
        fi
    done

    # Remove man pages (if any)
    if [[ "$HAS_MAN" == "true" ]]; then
        rm -f "${MAN_BASE}/man1/${BINARY_NAME}.1" 2>/dev/null || true
        rm -f "${MAN_BASE}/man5/${BINARY_NAME}_colors.5" 2>/dev/null || true
        rm -f "${MAN_BASE}/man5/${BINARY_NAME}_colors-explanation.5" 2>/dev/null || true
        find "${MAN_BASE}/man1" "${MAN_BASE}/man5" -maxdepth 1 -type f -name "${BINARY_NAME}*" -delete 2>/dev/null || true
        if command -v mandb &>/dev/null; then
            mandb &>/dev/null && info "Updated man database (mandb)"
        fi
    fi

    info "Uninstall complete."
    exit 0
}

# --- Version comparison helper ---
version_gt() {
    test "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" != "$1"
}

# --- Fetch latest release tag from GitHub API ---
get_latest_tag() {
    local api_url="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest"
    local temp_json=$(mktemp)
    local auth_header=()
    [[ -n "${GITHUB_TOKEN:-}" ]] && auth_header=(-H "Authorization: token $GITHUB_TOKEN")

    curl --silent --show-error --fail "${auth_header[@]}" -o "$temp_json" "$api_url" || error_exit "Failed to fetch release information."

    local tag
    if command -v jq &>/dev/null; then
        tag=$(jq -r '.tag_name // empty' "$temp_json")
    else
        tag=$(grep -o '"tag_name"[[:space:]]*:[[:space:]]*"[^"]*"' "$temp_json" | sed 's/.*"\([^"]*\)"$/\1/' | head -1)
    fi
    rm -f "$temp_json"
    if [[ -z "$tag" ]]; then
        error_exit "Could not determine the latest release tag."
    fi
    echo "$tag"
}

# --- Download and extract binary asset (handles both .tar.gz and .tar.xz) ---
download_and_install_binary() {
    local tag="$1"
    local version="${tag#v}"
    local asset_name
    # Replace {tag} placeholder if present (for shadowsocks), else use literal
    asset_name="${BINARY_ASSET_TEMPLATE/\{tag\}/$tag}"
    local url="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${tag}/${asset_name}"
    local tarball="/tmp/${asset_name}"
    info "Downloading ${asset_name} ..."
    curl --progress-bar --location --fail -o "$tarball" "$url" || error_exit "Binary download failed."

    info "Extracting ..."
    local temp_dir=$(mktemp -d)
    # Auto-detect compression: .tar.xz -> -xJf, .tar.gz -> -xzf
    if [[ "$asset_name" == *.tar.xz ]]; then
        tar -xJf "$tarball" -C "$temp_dir" || error_exit "Extraction failed (xz)."
    else
        tar -xzf "$tarball" -C "$temp_dir" || error_exit "Extraction failed (gz)."
    fi

    # Install each binary (the tarball may contain a directory or the binaries directly)
    for bin in $BINARIES; do
        local src
        # Look for binary in extracted tree
        src=$(find "$temp_dir" -type f -name "$bin" -executable -o -name "$bin" | head -1)
        if [[ -z "$src" ]]; then
            error_exit "Binary '$bin' not found in extracted archive."
        fi
        mv "$src" "${INSTALL_DIR}/${bin}" || error_exit "Failed to move $bin to $INSTALL_DIR"
        chmod +x "${INSTALL_DIR}/${bin}"
        info "  Installed $bin"
    done

    rm -rf "$temp_dir" "$tarball"
}

# --- Download and install man pages (only for eza) ---
download_and_install_man() {
    local tag="$1"
    local version="${tag#v}"
    local asset_name="${MAN_PREFIX}-${version}.tar.gz"
    local url="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${tag}/${asset_name}"
    local tarball="/tmp/${asset_name}"
    info "Downloading man pages ${asset_name} ..."
    if curl --progress-bar --location --fail -o "$tarball" "$url"; then
        info "Extracting man pages ..."
        local temp_dir=$(mktemp -d)
        tar -xzf "$tarball" -C "$temp_dir" || error_exit "Man page extraction failed."
        # Find the directory containing eza.1
        local man_dir=$(find "$temp_dir" -type f -name "eza.1" -exec dirname {} \; | head -1)
        if [[ -z "$man_dir" ]]; then
            error_exit "Could not locate eza.1 in extracted man pages."
        fi
        mkdir -p "${MAN_BASE}/man1" "${MAN_BASE}/man5"
        cp "${man_dir}/eza.1" "${MAN_BASE}/man1/" || error_exit "Failed to install eza.1"
        cp "${man_dir}/eza_colors.5" "${MAN_BASE}/man5/" || error_exit "Failed to install eza_colors.5"
        cp "${man_dir}/eza_colors-explanation.5" "${MAN_BASE}/man5/" || error_exit "Failed to install eza_colors-explanation.5"
        info "  Installed man pages"
        rm -rf "$temp_dir" "$tarball"
        if command -v mandb &>/dev/null; then
            mandb &>/dev/null && info "Updated man database (mandb)"
        fi
    else
        info "Man pages not available for this release (skipping)."
        rm -f "$tarball"
    fi
}

# --- Main installation/update logic ---
do_install() {
    # Dependencies
    for cmd in curl tar; do
        if ! command -v "$cmd" &>/dev/null; then
            error_exit "$cmd is required but not installed."
        fi
    done

    # Get current version (if any)
    local current_version=""
    if command -v "$BINARY_NAME" &>/dev/null; then
        current_version=$(eval "$VERSION_CMD" 2>/dev/null || echo "")
        if [[ -n "$current_version" ]]; then
            info "Currently installed version: v$current_version"
        else
            warn "Could not parse current version, will proceed with update."
        fi
    else
        info "$TOOL is not installed. Will install the latest version."
    fi

    # Fetch latest tag
    local latest_tag=$(get_latest_tag)
    local latest_version="${latest_tag#v}"
    info "Latest release tag: $latest_tag (version $latest_version)"

    # Compare versions
    if [[ -n "$current_version" ]] && ! version_gt "$latest_version" "$current_version"; then
        info "Already up to date (current v$current_version = latest v$latest_version). Exiting."
        exit 0
    fi

    if [[ -n "$current_version" ]]; then
        info "Newer version available: v$latest_version (current v$current_version). Updating..."
    else
        info "Installing $TOOL v$latest_version..."
    fi

    # Clean old man pages (if any) before installing new ones
    if [[ "$HAS_MAN" == "true" ]]; then
        info "Cleaning old ${TOOL} man pages from ${MAN_BASE}..."
        rm -f "${MAN_BASE}/man1/${BINARY_NAME}.1" 2>/dev/null || true
        rm -f "${MAN_BASE}/man5/${BINARY_NAME}_colors.5" 2>/dev/null || true
        rm -f "${MAN_BASE}/man5/${BINARY_NAME}_colors-explanation.5" 2>/dev/null || true
        find "${MAN_BASE}/man1" "${MAN_BASE}/man5" -maxdepth 1 -type f -name "${BINARY_NAME}*" -delete 2>/dev/null || true
    fi

    # Install binary
    download_and_install_binary "$latest_tag"

    # Install man pages (if supported)
    if [[ "$HAS_MAN" == "true" ]]; then
        download_and_install_man "$latest_tag"
    fi

    # Final version check
    local new_version=$(eval "$VERSION_CMD" 2>/dev/null || echo "unknown")
    info "Installation complete! New version: $new_version"
    exit 0
}

# --- Run ---
if [[ "$UNINSTALL" == true ]]; then
    do_uninstall "$FORCE"
else
    do_install
fi
