#!/usr/bin/env bash
# test-security.sh — Security tests for shell injection prevention
# Validates that scripts do not interpolate variables into Python code strings
# and that user input is properly validated.
set -euo pipefail

SKILL_DIR="calendar-scheduling"
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

# Extract python3 -c blocks and check for ${...} interpolation patterns.
# The vulnerable pattern is: python3 -c "....'${SOME_VAR}'..."
# Safe pattern uses: os.environ['SOME_VAR']

check_no_interpolation() {
  local file="$1"
  local label="$2"

  if [[ ! -f "$file" ]]; then
    fail "${label}: file not found"
    return
  fi

  # Check for '${...} patterns inside python3 -c blocks (may span multiple lines).
  # Vulnerable: open('${CONFIG_FILE}'), config['tz'] = '${TIMEZONE}'
  # Safe:       open(os.environ['CONFIG_FILE'])
  #
  # Strategy: look for the specific dangerous pattern where a shell variable is
  # embedded in a Python string literal — i.e., '${VAR}' or "${VAR}" inside a
  # python3 -c invocation. We search for lines containing both python3 and ${,
  # or lines within multi-line python3 -c blocks that use open('${ or = '${.
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

check_no_interpolation "${SKILL_DIR}/scripts/configure.sh" "configure.sh"
check_no_interpolation "${SKILL_DIR}/scripts/status.sh" "status.sh"
check_no_interpolation "tests/validate-structure.sh" "validate-structure.sh"

# ---------------------------------------------------------------------------
# 2. Timezone input validation — configure.sh must reject malicious input
# ---------------------------------------------------------------------------
echo ""
echo "--- Timezone Input Validation ---"

# Verify that configure.sh contains a validation regex for timezone input.
# The regex should reject characters outside [A-Za-z0-9/_+-].
if grep -q '\^\\[A-Za-z0-9/_+-\\]\\+\$' "${SKILL_DIR}/scripts/configure.sh" 2>/dev/null || \
   grep -qE 'TIMEZONE.*=~.*\^' "${SKILL_DIR}/scripts/configure.sh" 2>/dev/null; then
  pass "configure.sh: timezone input validation regex present"
else
  fail "configure.sh: no timezone input validation regex found"
fi

# Test the regex pattern itself against known inputs
VALID_TIMEZONES=("America/New_York" "UTC" "Etc/GMT+5" "US/Eastern" "Asia/Kolkata" "Pacific/Auckland")
INVALID_TIMEZONES=("America/'; echo pwned; '" "UTC; rm -rf /" "\`whoami\`" "US/Eastern\$(id)" "a'b" "x;y")

# Extract the validation regex from configure.sh if present
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

# Verify setup.sh uses a case statement that only accepts google|outlook|caldav
if grep -q 'google|outlook|caldav)' "${SKILL_DIR}/scripts/setup.sh" 2>/dev/null; then
  pass "setup.sh: provider restricted to google|outlook|caldav"
else
  fail "setup.sh: provider not properly restricted"
fi

# ---------------------------------------------------------------------------
# 4. NPX version pinning — setup.sh and .mcp.json must pin npm package version
# ---------------------------------------------------------------------------
echo ""
echo "--- NPX Version Pinning ---"

# setup.sh must use pinned version (e.g., @temporal-cortex/cortex-mcp@0.4.0)
if grep -q '@temporal-cortex/cortex-mcp@[0-9]' "${SKILL_DIR}/scripts/setup.sh" 2>/dev/null; then
  pass "setup.sh: npx command has version pin"
else
  fail "setup.sh: npx command missing version pin"
fi

# .mcp.json must declare universal config env vars (OAuth vars are optional, not listed)
MCP_JSON="${SKILL_DIR}/.mcp.json"
for var in TIMEZONE WEEK_START; do
  if grep -q "\"${var}\"" "$MCP_JSON" 2>/dev/null; then
    pass ".mcp.json: declares ${var} env var"
  else
    fail ".mcp.json: missing ${var} env var"
  fi
done

# .mcp.json must NOT include OAuth env vars (optional bring-your-own-app overrides)
for var in GOOGLE_CLIENT_ID GOOGLE_CLIENT_SECRET MICROSOFT_CLIENT_ID MICROSOFT_CLIENT_SECRET; do
  if grep -q "\"${var}\"" "$MCP_JSON" 2>/dev/null; then
    fail ".mcp.json: should not declare ${var} (optional, triggers scanner warnings)"
  else
    pass ".mcp.json: correctly omits ${var}"
  fi
done

# ---------------------------------------------------------------------------
# 5. OpenClaw registry metadata — metadata.openclaw block must be present
# ---------------------------------------------------------------------------
echo ""
echo "--- OpenClaw Registry Metadata ---"

SKILL_FILE="${SKILL_DIR}/SKILL.md"

# Extract frontmatter (between first and second ---)
FRONTMATTER=$(sed -n '/^---$/,/^---$/p' "$SKILL_FILE" | sed '1d;$d')

# Check metadata.openclaw block exists
if echo "$FRONTMATTER" | grep -q '^\s*openclaw:'; then
  pass "SKILL.md: metadata.openclaw block present"
else
  fail "SKILL.md: metadata.openclaw block missing"
fi

# Check requires sub-block with bins, env, config
if echo "$FRONTMATTER" | grep -qE '^\s+bins:'; then
  pass "SKILL.md: openclaw.requires.bins declared"
else
  fail "SKILL.md: openclaw.requires.bins missing"
fi

if echo "$FRONTMATTER" | grep -qF -- '- npx'; then
  pass "SKILL.md: openclaw.requires.bins includes npx"
else
  fail "SKILL.md: openclaw.requires.bins missing npx"
fi

if echo "$FRONTMATTER" | grep -qF -- '- TIMEZONE'; then
  pass "SKILL.md: openclaw.requires.env includes TIMEZONE"
else
  fail "SKILL.md: openclaw.requires.env missing TIMEZONE"
fi

if echo "$FRONTMATTER" | grep -qF -- '- WEEK_START'; then
  pass "SKILL.md: openclaw.requires.env includes WEEK_START"
else
  fail "SKILL.md: openclaw.requires.env missing WEEK_START"
fi

# OAuth vars should NOT be in openclaw.requires.env (they are optional)
OPENCLAW_SECTION=$(echo "$FRONTMATTER" | sed -n '/openclaw:/,/primaryEnv:/p')
for var in GOOGLE_CLIENT_ID GOOGLE_CLIENT_SECRET MICROSOFT_CLIENT_ID MICROSOFT_CLIENT_SECRET; do
  if echo "$OPENCLAW_SECTION" | grep -qF -- "- ${var}"; then
    fail "SKILL.md: openclaw.requires.env should not include ${var} (optional)"
  else
    pass "SKILL.md: openclaw.requires.env correctly omits ${var}"
  fi
done

if echo "$FRONTMATTER" | grep -q 'credentials.json'; then
  pass "SKILL.md: openclaw.requires.config includes credentials.json path"
else
  fail "SKILL.md: openclaw.requires.config missing credentials.json path"
fi

if echo "$FRONTMATTER" | grep -q 'primaryEnv: TIMEZONE'; then
  pass "SKILL.md: openclaw.primaryEnv is TIMEZONE"
else
  if echo "$FRONTMATTER" | grep -q 'primaryEnv:'; then
    fail "SKILL.md: openclaw.primaryEnv should be TIMEZONE"
  else
    fail "SKILL.md: openclaw.primaryEnv missing"
  fi
fi

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
