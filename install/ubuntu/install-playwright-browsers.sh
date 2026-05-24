#!/usr/bin/env bash
# install-playwright-browsers.sh
#
# Workaround for Playwright's `install` command hanging during zip extraction.
# Manually downloads and installs Chromium, headless shell, and FFmpeg to
# ~/.cache/ms-playwright/ with INSTALLATION_COMPLETE markers.
#
# Usage:
#   ./install-playwright-browsers.sh                # defaults: rev 1224 / Chrome 149 / FFmpeg 1011
#   ./install-playwright-browsers.sh --auto          # auto-detect from nearest playwright-core
#   ./install-playwright-browsers.sh --project DIR   # auto-detect from a project
#   ./install-playwright-browsers.sh --revision 1224 --chrome-version 149.0.7827.3

set -euo pipefail

# ---- Defaults ---------------------------------------------------------------
# Chrome for Testing 149.0.7827.3 / playwright chromium rev 1224
DEFAULT_CHROMIUM_REV=1224
DEFAULT_CHROME_VERSION="149.0.7827.3"
DEFAULT_FFMPEG_REV=1011

CACHE_DIR="${PLAYWRIGHT_BROWSERS_PATH:-$HOME/.cache/ms-playwright}"
DETECT_FROM=""
AUTO_DETECT=0
CHROMIUM_REV=""
CHROME_VERSION=""
HEADLESS_REV=""
HEADLESS_CHROME_VERSION=""
FFMPEG_REV=""
PLAYWRIGHT_DIR=""
VERBOSE=0

# ---- Help -------------------------------------------------------------------
usage() {
  cat <<ENDHELP
Usage: $(basename "$0") [OPTIONS]

Options:
  --revision N          Chromium revision number (default: $DEFAULT_CHROMIUM_REV)
  --chrome-version X.Y  Chrome for Testing version (default: $DEFAULT_CHROME_VERSION)
  --headless-revision N Headless shell revision (defaults to --revision)
  --ffmpeg-revision N   FFmpeg revision (default: $DEFAULT_FFMPEG_REV)
  --auto                Auto-detect versions from installed playwright-core
  --project DIR         Auto-detect from a project's node_modules/playwright-core
  --verbose             Verbose output
  --help                Show this help

With no arguments, installs with the default versions:
  Chromium rev $DEFAULT_CHROMIUM_REV / Chrome $DEFAULT_CHROME_VERSION / FFmpeg rev $DEFAULT_FFMPEG_REV

Use --auto or --project to auto-detect from an existing playwright-core.

Examples:
  ./install-playwright-browsers.sh                # defaults
  ./install-playwright-browsers.sh --auto          # auto-detect
  ./install-playwright-browsers.sh --project DIR   # from a project
  ./install-playwright-browsers.sh --revision 1224 --chrome-version 149.0.7827.3
ENDHELP
  exit 0
}

# ---- Parse args -------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --revision) CHROMIUM_REV="$2"; shift 2 ;;
    --chrome-version) CHROME_VERSION="$2"; shift 2 ;;
    --headless-revision) HEADLESS_REV="$2"; shift 2 ;;
    --ffmpeg-revision) FFMPEG_REV="$2"; shift 2 ;;
    --project) DETECT_FROM="$2"; AUTO_DETECT=1; shift 2 ;;
    --auto) AUTO_DETECT=1; shift ;;
    --verbose) VERBOSE=1; shift ;;
    --help|-h) usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

log() { echo "$@"; }
vlog() { [ "$VERBOSE" -eq 1 ] && echo "[verbose] $@" || true; }

# ---- Auto-detect browser versions from playwright-core/browsers.json --------
auto_detect() {
  local search_dirs=()

  if [ -n "$DETECT_FROM" ]; then
    search_dirs+=("$DETECT_FROM/node_modules/playwright-core")
    search_dirs+=("$DETECT_FROM/node_modules/@playwright/test/node_modules/playwright-core")
  fi

  # Global npx caches
  for d in "$HOME/.npm/_npx"/*/node_modules/playwright-core; do
    [ -d "$d" ] && search_dirs+=("$d")
  done

  # Global pnpm store
  for d in "$HOME/.local/share/pnpm/store"/*/links/*/playwright-core; do
    [ -d "$d" ] && search_dirs+=("$d")
  done

  # Global bun installs
  for d in "$HOME/.bun/install/global/node_modules/playwright-core" \
           "$HOME/.bun/install/global/node_modules/@playwright/test/node_modules/playwright-core"; do
    [ -d "$d" ] && search_dirs+=("$d")
  done

  # Current project node_modules
  search_dirs+=("node_modules/playwright-core")
  search_dirs+=("node_modules/@playwright/test/node_modules/playwright-core")

  for dir in "${search_dirs[@]}"; do
    local json="$dir/browsers.json"
    if [ -f "$json" ]; then
      vlog "Found browsers.json: $json"

      CHROMIUM_REV=$(python3 -c "
import json,sys
data=json.load(open('$json'))
for b in data.get('browsers',[]):
    if b['name']=='chromium':
        print(b['revision'])
        sys.exit(0)
" 2>/dev/null || echo "")

      CHROME_VERSION=$(python3 -c "
import json,sys
data=json.load(open('$json'))
for b in data.get('browsers',[]):
    if b['name']=='chromium':
        print(b.get('browserVersion',''))
        sys.exit(0)
" 2>/dev/null || echo "")

      HEADLESS_REV=$(python3 -c "
import json,sys
data=json.load(open('$json'))
for b in data.get('browsers',[]):
    if b['name']=='chromium-headless-shell':
        print(b['revision'])
        sys.exit(0)
" 2>/dev/null || echo "")

      HEADLESS_CHROME_VERSION=$(python3 -c "
import json,sys
data=json.load(open('$json'))
for b in data.get('browsers',[]):
    if b['name']=='chromium-headless-shell':
        print(b.get('browserVersion',''))
        sys.exit(0)
" 2>/dev/null || echo "")

      FFMPEG_REV=$(python3 -c "
import json,sys
data=json.load(open('$json'))
for b in data.get('browsers',[]):
    if b['name']=='ffmpeg':
        print(b['revision'])
        sys.exit(0)
" 2>/dev/null || echo "")

      PLAYWRIGHT_DIR="$dir"
      if [ -n "$CHROMIUM_REV" ] && [ -n "$CHROME_VERSION" ]; then
        # Fallback defaults for anything not found
        [ -z "$HEADLESS_REV" ] && HEADLESS_REV="$CHROMIUM_REV"
        [ -z "$HEADLESS_CHROME_VERSION" ] && HEADLESS_CHROME_VERSION="$CHROME_VERSION"
        [ -z "$FFMPEG_REV" ] && FFMPEG_REV=$DEFAULT_FFMPEG_REV

        echo "Auto-detected from: $PLAYWRIGHT_DIR"
        echo "  chromium:                rev=$CHROMIUM_REV  version=$CHROME_VERSION"
        echo "  chromium-headless-shell:  rev=$HEADLESS_REV  version=$HEADLESS_CHROME_VERSION"
        echo "  ffmpeg:                  rev=$FFMPEG_REV"
        return 0
      fi
    fi
  done

  return 1
}

# ---- Download and extract a browser component -------------------------------
install_browser() {
  local name="$1"          # e.g. "chromium", "chromium_headless_shell", "ffmpeg"
  local revision="$2"
  local url="$3"           # full download URL
  local binary_relpath="$4" # relative path to binary inside extracted dir
  local chrome_version="${5:-}"  # optional, for INSTALLATION_COMPLETE content

  local target_dir="$CACHE_DIR/${name}-${revision}"

  # Check if already installed
  if [ -f "$target_dir/INSTALLATION_COMPLETE" ] && [ -f "$target_dir/$binary_relpath" ]; then
    echo "  [ok] $name rev=$revision already installed"
    return 0
  fi

  echo "  -> Downloading $name rev=$revision..."
  mkdir -p "$target_dir"
  local zip_name="playwright-download-${name}-${revision}.zip"
  rm -f "/tmp/$zip_name"

  curl -L -o "/tmp/$zip_name" "$url" 2>&1 | \
    awk '{if(NR%5==0||/^  %/||/100/) print "\033[1A" $0}' || true

  # Verify download
  local file_size
  file_size=$(stat -c%s "/tmp/$zip_name" 2>/dev/null || echo "0")
  if [ "$file_size" -lt 100000 ]; then
    echo "  [ERR] Download failed or too small ($file_size bytes)." >&2
    cat "/tmp/$zip_name" 2>/dev/null | head -3 >&2
    rm -f "/tmp/$zip_name"
    return 1
  fi
  echo "         Downloaded: $(numfmt --to=iec $file_size)"

  echo "         Extracting to $target_dir ..."
  unzip -o "/tmp/$zip_name" -d "$target_dir" 2>&1 | tail -1
  rm -f "/tmp/$zip_name"

  # Verify binary exists
  if [ ! -f "$target_dir/$binary_relpath" ]; then
    echo "  [ERR] Binary missing at $target_dir/$binary_relpath after extraction." >&2
    ls -la "$target_dir/" 2>/dev/null >&2 || true
    return 1
  fi

  # Create installation marker
  if [ -n "$chrome_version" ]; then
    echo "$chrome_version" > "$target_dir/INSTALLATION_COMPLETE"
  else
    touch "$target_dir/INSTALLATION_COMPLETE"
  fi
  chmod +x "$target_dir/$binary_relpath"
  echo "  [ok] $name rev=$revision installed ($(numfmt --to=iec $(stat -c%s "$target_dir/$binary_relpath")))"
}

# ---- Verify with Playwright -------------------------------------------------
verify_installation() {
  echo ""
  echo "-- Verifying Playwright browser launch --"

  # Try to use gstack's bundled playwright first (most reliable)
  local gstack_pw="/home/dev2x/.pi/agent/gstack-pi/repo"
  if [ -d "$gstack_pw/node_modules/playwright-core" ]; then
    echo "  Testing with gstack's bundled playwright..."
    local result
    result=$(cd "$gstack_pw" && timeout 15 bun --eval '
import { chromium } from "playwright";
try {
  const b = await chromium.launch({ headless: true });
  const v = await b.version();
  await b.close();
  console.log("OK: Browser launched, version " + v);
  process.exit(0);
} catch(e) {
  console.error("FAIL: " + e.message);
  process.exit(1);
}
' 2>&1 || true)
    if echo "$result" | grep -q "OK:"; then
      echo "  $result"
      return 0
    else
      echo "  $result"
      return 1
    fi
  fi

  # Fallback: try global bun/node
  local test_cmd=""
  for cmd in \
    "bun --eval 'import { chromium } from \"playwright\"; const b = await chromium.launch({headless:true}); console.log(\"OK: \" + (await b.version())); await b.close();'" \
    "node -e 'const {chromium}=require(\"playwright\"); (async()=>{const b=await chromium.launch({headless:true}); console.log(\"OK: \"+await b.version()); await b.close();})()'"; do
    if command -v "${cmd%% *}" >/dev/null 2>&1; then
      test_cmd="$cmd"
      break
    fi
  done

  if [ -z "$test_cmd" ]; then
    echo "  (no Playwright runtime available to verify)"
    return 0
  fi

  local result
  result=$(timeout 15 bash -c "$test_cmd" 2>&1 || true)
  if echo "$result" | grep -q "OK:"; then
    echo "  $result"
  else
    echo "  Could not verify: $result"
    echo "  (this is non-critical - browsers are installed)"
  fi
}

# =============================================================================
# Main
# =============================================================================

echo "============================================"
echo " Playwright Browser Installer"
echo " (manual extraction workaround)"
echo "============================================"
echo ""

# Determine versions
if [ "$AUTO_DETECT" -eq 1 ]; then
  # --auto or --project: detect from playwright-core
  if auto_detect; then
    :  # detected successfully
  else
    if [ -n "$DETECT_FROM" ]; then
      echo "Error: Could not auto-detect from --project $DETECT_FROM" >&2
      echo "Make sure the project has node_modules/playwright-core installed." >&2
    else
      echo "Error: Could not auto-detect Playwright browser versions." >&2
      echo "Run without --auto to use defaults, or supply --revision and --chrome-version." >&2
    fi
    exit 1
  fi
elif [ -n "$CHROMIUM_REV" ] || [ -n "$CHROME_VERSION" ]; then
  # Explicit version: both required
  if [ -z "$CHROMIUM_REV" ] || [ -z "$CHROME_VERSION" ]; then
    echo "Error: --revision and --chrome-version must be given together" >&2
    exit 1
  fi
else
  # No args: use defaults directly
  CHROMIUM_REV=$DEFAULT_CHROMIUM_REV
  CHROME_VERSION=$DEFAULT_CHROME_VERSION
  echo "Using defaults: rev=$CHROMIUM_REV / Chrome $CHROME_VERSION"
fi

# Default headless shell to match chromium if not set
[ -z "$HEADLESS_REV" ] && HEADLESS_REV="$CHROMIUM_REV"
[ -z "$HEADLESS_CHROME_VERSION" ] && HEADLESS_CHROME_VERSION="$CHROME_VERSION"
# Default ffmpeg revision if not set
[ -z "$FFMPEG_REV" ] && FFMPEG_REV=$DEFAULT_FFMPEG_REV

echo ""
echo "Target browsers:"
echo "  Cache: $CACHE_DIR"
echo "  chromium:                rev=$CHROMIUM_REV  version=$CHROME_VERSION"
echo "  chromium-headless-shell:  rev=$HEADLESS_REV  version=$HEADLESS_CHROME_VERSION"
echo "  ffmpeg:                  rev=$FFMPEG_REV"
echo ""

# Step 1: Install Chromium (regular browser)
echo "-- Installing Chromium --"
install_browser \
  "chromium" \
  "$CHROMIUM_REV" \
  "https://cdn.playwright.dev/builds/cft/${CHROME_VERSION}/linux64/chrome-linux64.zip" \
  "chrome-linux64/chrome" \
  "$CHROME_VERSION" || exit 1

# Step 2: Install Chromium Headless Shell
echo ""
echo "-- Installing Chromium Headless Shell --"
install_browser \
  "chromium_headless_shell" \
  "$HEADLESS_REV" \
  "https://cdn.playwright.dev/builds/cft/${HEADLESS_CHROME_VERSION}/linux64/chrome-headless-shell-linux64.zip" \
  "chrome-headless-shell-linux64/chrome-headless-shell" \
  "$HEADLESS_CHROME_VERSION" || exit 1

# Step 3: Install FFmpeg
echo ""
echo "-- Installing FFmpeg --"
install_browser \
  "ffmpeg" \
  "$FFMPEG_REV" \
  "https://cdn.playwright.dev/dbazure/download/playwright/builds/ffmpeg/${FFMPEG_REV}/ffmpeg-linux.zip" \
  "ffmpeg-linux" || exit 1

# Step 4: Verify
verify_installation || true

echo ""
echo "Done."
echo ""
echo "Installed:"
echo "  $CACHE_DIR/chromium-${CHROMIUM_REV}/chrome-linux64/chrome"
echo "  $CACHE_DIR/chromium_headless_shell-${HEADLESS_REV}/chrome-headless-shell-linux64/chrome-headless-shell"
echo "  $CACHE_DIR/ffmpeg-${FFMPEG_REV}/ffmpeg-linux"
echo ""
echo "Next, run the gstack setup:"
echo "  cd /home/dev2x/.pi/agent/gstack-pi/repo && ./setup"
