#!/usr/bin/env bash
# validate-skill.sh — Validates all SKILL.md files against the Agent Skills specification
# https://agentskills.io/specification
set -euo pipefail

ERRORS=0

# Navigate to repo root (parent of tests/)
cd "$(dirname "$0")/.."

pass() { echo "  PASS: $1"; }
fail() { echo "  FAIL: $1"; ERRORS=$((ERRORS + 1)); }

# Validate a single SKILL.md file
validate_skill() {
  local SKILL_DIR="$1"
  local SKILL_FILE="${SKILL_DIR}/SKILL.md"
  local EXPECTED_NAME
  EXPECTED_NAME=$(basename "$SKILL_DIR")

  echo ""
  echo "=== Validating ${SKILL_FILE} ==="

  # 1. SKILL.md exists
  if [[ -f "$SKILL_FILE" ]]; then
    pass "SKILL.md exists at ${SKILL_FILE}"
  else
    fail "SKILL.md not found at ${SKILL_FILE}"
    return
  fi

  # 2. Extract frontmatter (between first and second ---)
  FRONTMATTER=$(sed -n '/^---$/,/^---$/p' "$SKILL_FILE" | sed '1d;$d')

  if [[ -z "$FRONTMATTER" ]]; then
    fail "No YAML frontmatter found (must be between --- delimiters)"
    return
  else
    pass "YAML frontmatter found"
  fi

  # 3. Extract name field
  NAME=$(echo "$FRONTMATTER" | grep -E '^name:' | sed 's/^name:[[:space:]]*//')

  if [[ -z "$NAME" ]]; then
    fail "Missing required 'name' field in frontmatter"
  else
    pass "name field present: ${NAME}"

    # 3a. Name matches directory name
    if [[ "$NAME" == "$EXPECTED_NAME" ]]; then
      pass "name matches directory name"
    else
      fail "name '${NAME}' does not match directory name '${EXPECTED_NAME}'"
    fi

    # 3b. Name is lowercase with hyphens only
    if echo "$NAME" | grep -qE '^[a-z0-9]([a-z0-9-]*[a-z0-9])?$'; then
      pass "name uses valid characters (lowercase + hyphens)"
    else
      fail "name contains invalid characters (must be lowercase letters, numbers, hyphens)"
    fi

    # 3c. No consecutive hyphens
    if echo "$NAME" | grep -qE '\-\-'; then
      fail "name contains consecutive hyphens"
    else
      pass "name has no consecutive hyphens"
    fi

    # 3d. Name length <= 64
    NAME_LEN=${#NAME}
    if [[ $NAME_LEN -le 64 ]]; then
      pass "name length ${NAME_LEN} <= 64"
    else
      fail "name length ${NAME_LEN} exceeds 64 characters"
    fi
  fi

  # 4. Extract description field
  DESCRIPTION=$(python3 -c "
import sys
in_desc = False
lines = []
for line in sys.stdin:
    line = line.rstrip()
    if line.startswith('description:'):
        rest = line[len('description:'):].strip()
        if rest.startswith('|-') or rest.startswith('|'):
            in_desc = True
            continue
        elif rest:
            lines.append(rest)
            break
    elif in_desc:
        if line and line[0] == ' ':
            lines.append(line.strip())
        else:
            break
print(' '.join(lines))
" <<< "$FRONTMATTER")

  if [[ -z "$DESCRIPTION" ]]; then
    fail "Missing required 'description' field in frontmatter"
  else
    DESC_LEN=${#DESCRIPTION}
    if [[ $DESC_LEN -le 1024 ]]; then
      pass "description length ${DESC_LEN} <= 1024"
    else
      fail "description length ${DESC_LEN} exceeds 1024 characters"
    fi

    if [[ $DESC_LEN -ge 10 ]]; then
      pass "description is substantive (${DESC_LEN} chars)"
    else
      fail "description is too short (${DESC_LEN} chars, should be substantive)"
    fi
  fi

  # 5. Body exists after frontmatter
  BODY_START=$(grep -n '^---$' "$SKILL_FILE" | sed -n '2p' | cut -d: -f1)

  if [[ -z "$BODY_START" ]]; then
    fail "No closing --- for frontmatter found"
  else
    TOTAL_LINES=$(wc -l < "$SKILL_FILE" | tr -d ' ')
    BODY_LINES=$((TOTAL_LINES - BODY_START))

    if [[ $BODY_LINES -gt 0 ]]; then
      pass "Body content exists (${BODY_LINES} lines after frontmatter)"
    else
      fail "No body content after frontmatter"
    fi

    # 6. Body is < 500 lines
    if [[ $BODY_LINES -lt 500 ]]; then
      pass "Body length ${BODY_LINES} < 500 lines"
    else
      fail "Body length ${BODY_LINES} exceeds 500 lines"
    fi
  fi
}

# Validate all skills in skills/ directory
for skill_dir in skills/*/; do
  if [[ -f "${skill_dir}SKILL.md" ]]; then
    validate_skill "${skill_dir%/}"
  fi
done

# Also validate legacy calendar-scheduling if it still exists
if [[ -f "calendar-scheduling/SKILL.md" ]]; then
  validate_skill "calendar-scheduling"
fi

echo ""
if [[ $ERRORS -eq 0 ]]; then
  echo "RESULT: All checks passed"
  exit 0
else
  echo "RESULT: ${ERRORS} error(s) found"
  exit 1
fi
