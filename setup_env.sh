#!/usr/bin/env bash
# DEV_ENV=$(pwd) ./setup_env.sh "filter"
# Stops immediately on any error or undefined variable
set -euo pipefail

# ---------------------------------------------------------------------------
# Compatibility checks
# ---------------------------------------------------------------------------

# Require bash 4+ for mapfile; Fedora 43 ships bash 5, Debian 12 ships bash 5
if ((BASH_VERSINFO[0] < 4)); then
  echo "Error: bash 4+ required (found ${BASH_VERSION})" >&2
  exit 1
fi

# Detect OS for any platform-specific handling
os_id=""
if [[ -f /etc/os-release ]]; then
  os_id="$(. /etc/os-release && echo "${ID:-unknown}")"
fi

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------

# Resolve the directory this script lives in
# BASH_SOURCE[0] is the reliable cross-distro way when sourced or executed
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" &>/dev/null && pwd)"

# Defaults
filter=""
dry_run=false

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------

while [[ $# -gt 0 ]]; do
  case "$1" in
  --dry)
    dry_run=true
    ;;
  --filter)
    shift
    filter="${1:-}"
    ;;
  -*)
    echo "Error: Unknown option '$1'" >&2
    echo "Usage: $(basename "$0") [--dry] [--filter <pattern>] [<pattern>]" >&2
    exit 1
    ;;
  *)
    # Positional argument as filter (preserves original call convention)
    filter="$1"
    ;;
  esac
  shift
done

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

log() {
  if $dry_run; then
    echo "[DRY_RUN] $1"
  else
    echo "$1"
  fi
}

# ---------------------------------------------------------------------------
# Pre-flight
# ---------------------------------------------------------------------------

log "RUN: filter='$filter' os='${os_id}'"

jobs_dir="$script_dir/jobs"
if [[ ! -d "$jobs_dir" ]]; then
  echo "Error: jobs directory not found at '$jobs_dir'" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Discover and run jobs
# ---------------------------------------------------------------------------

# -perm /111  → any execute bit set (POSIX; works on GNU find in both distros)
# -perm -111  → all execute bits set (non-POSIX; works on both but less correct)
mapfile -t run_scripts < <(find "$jobs_dir" -mindepth 1 -maxdepth 1 -type f -perm /111 | sort)

if [[ ${#run_scripts[@]} -eq 0 ]]; then
  log "No executable scripts found in $jobs_dir"
  exit 0
fi

for script in "${run_scripts[@]}"; do
  name="$(basename "$script")"

  # Apply optional filter
  if [[ -n "$filter" && ! "$name" =~ $filter ]]; then
    log "Filtered out: $name (did not match '$filter')"
    continue
  fi

  log "Running: $name"

  if ! $dry_run; then
    "$script" || {
      echo "Error: $name failed — aborting." >&2
      exit 1
    }
  fi
done
