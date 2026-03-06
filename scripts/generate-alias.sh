#!/usr/bin/env bash
# generate-alias.sh — Generates skills/calendar-scheduling/ (SKILL.md +
# references/) from the router skill (skills/temporal-cortex/).
#
# The calendar-scheduling slug is a backward-compatible alias kept for users
# who installed the original monolithic skill before the v0.5.1 restructuring.
#
# Usage: bash scripts/generate-alias.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="${REPO_ROOT}/skills/temporal-cortex/SKILL.md"
TARGET_DIR="${REPO_ROOT}/skills/calendar-scheduling"
TARGET="${TARGET_DIR}/SKILL.md"

if [[ ! -f "$SOURCE" ]]; then
  echo "ERROR: Source not found: ${SOURCE}"
  exit 1
fi

mkdir -p "$TARGET_DIR"

# Copy reference docs from router so clawhub publish includes them.
# These are identical copies — the alias is a backward-compat mirror.
REFS_SOURCE="${REPO_ROOT}/skills/temporal-cortex/references"
REFS_TARGET="${TARGET_DIR}/references"
if [[ -d "$REFS_SOURCE" ]]; then
  rm -rf "$REFS_TARGET"
  cp -R "$REFS_SOURCE" "$REFS_TARGET"
  echo "Copied: ${REFS_SOURCE} → ${REFS_TARGET}"
fi

# Build the alias SKILL.md:
#   1. Replace name: temporal-cortex → name: calendar-scheduling
#   2. Append backward-compat note to description
#   (Minimal changes to keep alias body close to router for scanner parity)
{
  awk '
    BEGIN { in_desc = 0 }

    # Replace name field
    /^name: temporal-cortex$/ {
      print "name: calendar-scheduling"
      next
    }

    # Detect multi-line description start
    /^description: \|-$/ {
      in_desc = 1
      print
      next
    }

    # Append backward-compat note to end of description block
    in_desc && /^[^ ]/ && !/^  / {
      print "  Previously published as calendar-scheduling, now maintained as temporal-cortex — this listing is kept for backward compatibility."
      in_desc = 0
    }

    { print }
  ' "$SOURCE"
} > "$TARGET"

echo "Generated: ${TARGET}"
