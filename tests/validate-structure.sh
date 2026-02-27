#!/usr/bin/env bash
# validate-structure.sh — Validates the multi-skill directory structure and file integrity
set -euo pipefail

ERRORS=0

# Navigate to repo root (parent of tests/)
cd "$(dirname "$0")/.."

pass() { echo "  PASS: $1"; }
fail() { echo "  FAIL: $1"; ERRORS=$((ERRORS + 1)); }

echo "=== Validating Multi-Skill Directory Structure ==="

# 1. Required skill directories
SKILL_DIRS=(
  "skills/temporal-cortex"
  "skills/temporal-cortex-datetime"
  "skills/temporal-cortex-calendars"
  "skills/temporal-cortex-booking"
)

for dir in "${SKILL_DIRS[@]}"; do
  if [[ -d "$dir" ]]; then
    pass "Skill directory exists: ${dir}"
  else
    fail "Missing skill directory: ${dir}"
  fi
done

# 2. Required shared directories
for dir in "scripts" "assets/presets"; do
  if [[ -d "$dir" ]]; then
    pass "Shared directory exists: ${dir}"
  else
    fail "Missing shared directory: ${dir}"
  fi
done

echo ""
echo "=== Validating Required Files ==="

# 3. Each skill has a SKILL.md
for dir in "${SKILL_DIRS[@]}"; do
  if [[ -f "${dir}/SKILL.md" ]]; then
    pass "SKILL.md exists: ${dir}/SKILL.md"
  else
    fail "Missing SKILL.md: ${dir}/SKILL.md"
  fi
done

# 4. Root files
ROOT_FILES=(".mcp.json" "AGENTS.md")
for f in "${ROOT_FILES[@]}"; do
  if [[ -f "$f" ]]; then
    pass "Root file exists: ${f}"
  else
    fail "Missing root file: ${f}"
  fi
done

# 5. Reference documents in correct sub-skills
REFERENCE_FILES=(
  "skills/temporal-cortex-datetime/references/DATETIME-TOOLS.md"
  "skills/temporal-cortex-calendars/references/CALENDAR-TOOLS.md"
  "skills/temporal-cortex-calendars/references/MULTI-CALENDAR.md"
  "skills/temporal-cortex-calendars/references/RRULE-GUIDE.md"
  "skills/temporal-cortex-booking/references/BOOKING-SAFETY.md"
)

for f in "${REFERENCE_FILES[@]}"; do
  if [[ -f "$f" ]]; then
    pass "Reference exists: ${f}"
  else
    fail "Missing reference: ${f}"
  fi
done

# 6. Shared scripts
SCRIPT_FILES=(
  "scripts/setup.sh"
  "scripts/configure.sh"
  "scripts/status.sh"
)

for f in "${SCRIPT_FILES[@]}"; do
  if [[ -f "$f" ]]; then
    pass "Script exists: ${f}"
  else
    fail "Missing script: ${f}"
  fi
done

# 7. Preset files
PRESET_FILES=(
  "assets/presets/personal-assistant.json"
  "assets/presets/recruiter-agent.json"
  "assets/presets/team-coordinator.json"
)

for f in "${PRESET_FILES[@]}"; do
  if [[ -f "$f" ]]; then
    pass "Preset exists: ${f}"
  else
    fail "Missing preset: ${f}"
  fi
done

echo ""
echo "=== Validating Scripts ==="

# 8. Scripts have shebangs
for script in scripts/*.sh; do
  if [[ ! -f "$script" ]]; then
    continue
  fi

  FIRST_LINE=$(head -n 1 "$script")
  if [[ "$FIRST_LINE" == "#!/usr/bin/env bash" ]] || [[ "$FIRST_LINE" == "#!/bin/bash" ]]; then
    pass "Shebang present: ${script}"
  else
    fail "Missing or invalid shebang in ${script} (got: ${FIRST_LINE})"
  fi

  if [[ -x "$script" ]]; then
    pass "Executable: ${script}"
  else
    echo "  WARN: Not executable: ${script} (set with: chmod +x ${script})"
  fi
done

echo ""
echo "=== Validating JSON Files ==="

# 9. JSON files are valid
for json_file in assets/presets/*.json .mcp.json; do
  if [[ ! -f "$json_file" ]]; then
    continue
  fi

  if JSON_FILE="$json_file" python3 -c "import json, os; json.load(open(os.environ['JSON_FILE']))" 2>/dev/null; then
    pass "Valid JSON: ${json_file}"
  else
    fail "Invalid JSON: ${json_file}"
  fi
done

echo ""
echo "=== Validating File Sizes ==="

# 10. All SKILL.md body < 500 lines
for skill_md in skills/*/SKILL.md; do
  if [[ ! -f "$skill_md" ]]; then
    continue
  fi

  TOTAL_LINES=$(wc -l < "$skill_md" | tr -d ' ')
  if [[ $TOTAL_LINES -lt 520 ]]; then
    pass "${skill_md} total ${TOTAL_LINES} lines (within budget)"
  else
    fail "${skill_md} has ${TOTAL_LINES} lines (body should be < 500)"
  fi
done

# 11. Reference files should be focused (< 300 lines each)
for ref in skills/*/references/*.md; do
  if [[ ! -f "$ref" ]]; then
    continue
  fi

  REF_LINES=$(wc -l < "$ref" | tr -d ' ')
  if [[ $REF_LINES -lt 300 ]]; then
    pass "Reference ${ref} is ${REF_LINES} lines (< 300)"
  else
    fail "Reference ${ref} is ${REF_LINES} lines (exceeds 300)"
  fi
done

echo ""
if [[ $ERRORS -eq 0 ]]; then
  echo "RESULT: All structure checks passed"
  exit 0
else
  echo "RESULT: ${ERRORS} error(s) found"
  exit 1
fi
