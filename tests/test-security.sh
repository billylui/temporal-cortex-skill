#!/usr/bin/env bash
# test-security.sh — Security tests for shell injection prevention
# Validates that scripts do not interpolate variables into Python code strings
# and that user input is properly validated.
set -euo pipefail

ERRORS=0

# Navigate to repo root (parent of tests/)
cd "$(dirname "$0")/.."

pass() { echo "  PASS: $1"; }
fail() { echo "  FAIL: $1"; ERRORS=$((ERRORS + 1)); }

echo "=== Security Tests ==="

# ---------------------------------------------------------------------------
# 1. Python env-var isolation — no ${VAR} interpolation in python3 -c blocks
# ---------------------------------------------------------------------------
echo ""
echo "--- Python Env-Var Isolation ---"

check_no_interpolation() {
  local file="$1"
  local label="$2"

  if [[ ! -f "$file" ]]; then
    fail "${label}: file not found"
    return
  fi

  local found
  found=$(awk '
    /python3 -c/ { in_block = 1; start = NR }
    in_block && /open\(.*\$\{/ { print NR ": " $0 }
    in_block && /= .*\x27\$\{/ { print NR ": " $0 }
    in_block && /^"[[:space:]]*$/ && NR > start { in_block = 0 }
  ' "$file")

  if [[ -n "$found" ]]; then
    fail "${label}: contains \${} interpolation in python3 -c blocks"
  else
    pass "${label}: no variable interpolation in Python code"
  fi
}

check_no_interpolation "scripts/configure.sh" "configure.sh"
check_no_interpolation "scripts/status.sh" "status.sh"
check_no_interpolation "tests/validate-structure.sh" "validate-structure.sh"

# ---------------------------------------------------------------------------
# 2. Timezone input validation — configure.sh must reject malicious input
# ---------------------------------------------------------------------------
echo ""
echo "--- Timezone Input Validation ---"

if grep -q '\^\\[A-Za-z0-9/_+-\\]\\+\$' "scripts/configure.sh" 2>/dev/null || \
   grep -qE 'TIMEZONE.*=~.*\^' "scripts/configure.sh" 2>/dev/null; then
  pass "configure.sh: timezone input validation regex present"
else
  fail "configure.sh: no timezone input validation regex found"
fi

VALID_TIMEZONES=("America/New_York" "UTC" "Etc/GMT+5" "US/Eastern" "Asia/Kolkata" "Pacific/Auckland")
INVALID_TIMEZONES=("America/'; echo pwned; '" "UTC; rm -rf /" "\`whoami\`" "US/Eastern\$(id)" "a'b" "x;y")

REGEX_PATTERN='^[A-Za-z0-9/_+-]+$'

for tz in "${VALID_TIMEZONES[@]}"; do
  if [[ "$tz" =~ $REGEX_PATTERN ]]; then
    pass "Regex accepts valid timezone: ${tz}"
  else
    fail "Regex rejects valid timezone: ${tz}"
  fi
done

for tz in "${INVALID_TIMEZONES[@]}"; do
  if [[ "$tz" =~ $REGEX_PATTERN ]]; then
    fail "Regex accepts malicious input: ${tz}"
  else
    pass "Regex rejects malicious input: ${tz}"
  fi
done

# ---------------------------------------------------------------------------
# 3. setup.sh provider validation — only allow known providers
# ---------------------------------------------------------------------------
echo ""
echo "--- Provider Input Validation ---"

if grep -q 'google|outlook|caldav)' "scripts/setup.sh" 2>/dev/null; then
  pass "setup.sh: provider restricted to google|outlook|caldav"
else
  fail "setup.sh: provider not properly restricted"
fi

# ---------------------------------------------------------------------------
# 4. NPX version pinning — setup.sh and .mcp.json must pin npm package version
# ---------------------------------------------------------------------------
echo ""
echo "--- NPX Version Pinning ---"

if grep -q '@temporal-cortex/cortex-mcp@[0-9]' "scripts/setup.sh" 2>/dev/null; then
  pass "setup.sh: npx command has version pin"
else
  fail "setup.sh: npx command missing version pin"
fi

MCP_JSON=".mcp.json"
for var in TIMEZONE WEEK_START; do
  if grep -q "\"${var}\"" "$MCP_JSON" 2>/dev/null; then
    pass ".mcp.json: declares ${var} env var"
  else
    fail ".mcp.json: missing ${var} env var"
  fi
done

for var in GOOGLE_CLIENT_ID GOOGLE_CLIENT_SECRET MICROSOFT_CLIENT_ID MICROSOFT_CLIENT_SECRET; do
  if grep -q "\"${var}\"" "$MCP_JSON" 2>/dev/null; then
    fail ".mcp.json: should not declare ${var} (optional, triggers scanner warnings)"
  else
    pass ".mcp.json: correctly omits ${var}"
  fi
done

# ---------------------------------------------------------------------------
# 5. OpenClaw registry metadata — check all sub-skill SKILL.md files
# ---------------------------------------------------------------------------
echo ""
echo "--- OpenClaw Registry Metadata ---"

# Check the router skill (has the fullest metadata)
SKILL_FILE="skills/temporal-cortex/SKILL.md"

FRONTMATTER=$(sed -n '/^---$/,/^---$/p' "$SKILL_FILE" | sed '1d;$d')

if echo "$FRONTMATTER" | grep -q '^\s*openclaw:'; then
  pass "Router SKILL.md: metadata.openclaw block present"
else
  fail "Router SKILL.md: metadata.openclaw block missing"
fi

if echo "$FRONTMATTER" | grep -qE '^\s+bins:'; then
  pass "Router SKILL.md: openclaw.requires.bins declared"
else
  fail "Router SKILL.md: openclaw.requires.bins missing"
fi

if echo "$FRONTMATTER" | grep -qF -- '- npx'; then
  pass "Router SKILL.md: openclaw.requires.bins includes npx"
else
  fail "Router SKILL.md: openclaw.requires.bins missing npx"
fi

OPENCLAW_SECTION=$(echo "$FRONTMATTER" | sed -n '/openclaw:/,/^[^ ]/p')
if echo "$OPENCLAW_SECTION" | grep -qE '^\s+env:'; then
  fail "Router SKILL.md: openclaw.requires.env should not exist (vars are optional)"
else
  pass "Router SKILL.md: openclaw.requires.env correctly absent"
fi

if echo "$FRONTMATTER" | grep -q 'primaryEnv:'; then
  fail "Router SKILL.md: primaryEnv should not exist (not a credential)"
else
  pass "Router SKILL.md: primaryEnv correctly absent"
fi

for var in GOOGLE_CLIENT_ID GOOGLE_CLIENT_SECRET MICROSOFT_CLIENT_ID MICROSOFT_CLIENT_SECRET; do
  if echo "$OPENCLAW_SECTION" | grep -qF -- "- ${var}"; then
    fail "Router SKILL.md: openclaw block should not include ${var} (optional)"
  else
    pass "Router SKILL.md: openclaw block correctly omits ${var}"
  fi
done

if echo "$FRONTMATTER" | grep -q 'credentials.json'; then
  pass "Router SKILL.md: openclaw.requires.config includes credentials.json path"
else
  fail "Router SKILL.md: openclaw.requires.config missing credentials.json path"
fi

if echo "$FRONTMATTER" | grep -qE '^\s+homepage:'; then
  pass "Router SKILL.md: metadata.homepage present"
else
  fail "Router SKILL.md: metadata.homepage missing (provenance concern)"
fi

if echo "$FRONTMATTER" | grep -qE '^\s+repository:'; then
  pass "Router SKILL.md: metadata.repository present"
else
  fail "Router SKILL.md: metadata.repository missing (provenance concern)"
fi

# Check all sub-skills have repository metadata
for skill_dir in skills/*/; do
  SKILL_FILE="${skill_dir}SKILL.md"
  if [[ ! -f "$SKILL_FILE" ]]; then
    continue
  fi
  SKILL_NAME=$(basename "$skill_dir")
  FM=$(sed -n '/^---$/,/^---$/p' "$SKILL_FILE" | sed '1d;$d')

  if echo "$FM" | grep -qE '^\s+repository:'; then
    pass "${SKILL_NAME}: metadata.repository present"
  else
    fail "${SKILL_NAME}: metadata.repository missing"
  fi
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "=== Security Test Summary ==="
if [[ "$ERRORS" -eq 0 ]]; then
  echo "All security tests passed."
  exit 0
else
  echo "${ERRORS} security test(s) FAILED."
  exit 1
fi
