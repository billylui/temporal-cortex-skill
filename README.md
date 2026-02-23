# Temporal Cortex Skill

[![CI](https://github.com/billylui/temporal-cortex-skill/actions/workflows/ci.yml/badge.svg)](https://github.com/billylui/temporal-cortex-skill/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**v0.4.0** · February 2026 · [Changelog](CHANGELOG.md)

The calendar-scheduling Agent Skill teaches AI agents the correct workflow for calendar operations using the [Temporal Cortex MCP server](https://github.com/billylui/temporal-cortex-mcp). It provides procedural knowledge for temporal orientation, natural language datetime resolution, multi-calendar availability merging, and conflict-free booking with Two-Phase Commit. Compatible with 26+ agent platforms including Claude Code, Codex CLI, and Cursor.

## What does the calendar-scheduling skill do?

This skill gives AI agents procedural knowledge for calendar operations:

- **Temporal orientation** — always know the current time and timezone before acting
- **Natural language resolution** — convert "next Tuesday at 2pm" to precise timestamps
- **Multi-calendar availability** — merge free/busy across Google Calendar, Microsoft Outlook, and CalDAV
- **Conflict-free booking** — Two-Phase Commit ensures no double-bookings
- **RRULE expansion** — deterministic recurrence rule handling (DST, BYSETPOS, leap years)

The skill teaches the 4-step workflow: **orient → resolve → query → book**. Powered by [Temporal Cortex Core](https://github.com/billylui/temporal-cortex-core) (Truth Engine) and the [Temporal Cortex MCP server](https://github.com/billylui/temporal-cortex-mcp).

## How do I install the calendar-scheduling skill?

**Install in 3 steps:**

1. **Clone the repository** — `git clone https://github.com/billylui/temporal-cortex-skill.git`
2. **Copy to skills directory** — `cp -r temporal-cortex-skill/calendar-scheduling ~/.claude/skills/` (or your agent's skills location)
3. **Configure MCP server** — ensure the [MCP server](https://github.com/billylui/temporal-cortex-mcp) is configured and run `npx @temporal-cortex/cortex-mcp auth google` for calendar access.

### Claude Code

```bash
# Clone into your skills directory
git clone https://github.com/billylui/temporal-cortex-skill.git
cp -r temporal-cortex-skill/calendar-scheduling ~/.claude/skills/
```

Or add as a project skill:

```bash
cp -r temporal-cortex-skill/calendar-scheduling .claude/skills/
```

### Cursor / Codex CLI

Copy the `calendar-scheduling/` directory to your agent's skills location. The `SKILL.md` format is supported by 26+ platforms including Claude, OpenAI Codex, Google Gemini, and GitHub Copilot.

## How do I connect the MCP server?

This skill requires the [Temporal Cortex MCP server](https://github.com/billylui/temporal-cortex-mcp). The included `.mcp.json` points to the local npm binary:

```json
{
  "mcpServers": {
    "temporal-cortex": {
      "command": "npx",
      "args": ["-y", "@temporal-cortex/cortex-mcp"]
    }
  }
}
```

Layer 1 tools (temporal context, datetime resolution) work immediately. Calendar tools require a one-time OAuth setup:

```bash
# Google Calendar
npx @temporal-cortex/cortex-mcp auth google

# Microsoft Outlook
npx @temporal-cortex/cortex-mcp auth outlook

# CalDAV (iCloud, Fastmail)
npx @temporal-cortex/cortex-mcp auth caldav
```

## What files are in the skill directory?

```
calendar-scheduling/
├── SKILL.md                      # Core skill definition (Agent Skills spec)
├── .mcp.json                     # MCP server connection config
├── scripts/
│   ├── setup.sh                  # OAuth flow + calendar connection
│   ├── configure.sh              # Timezone + week start configuration
│   └── status.sh                 # Connection health check
├── references/
│   ├── BOOKING-SAFETY.md         # Two-Phase Commit, conflict resolution
│   ├── MULTI-CALENDAR.md         # Provider-prefixed IDs, privacy modes
│   ├── RRULE-GUIDE.md            # Recurrence patterns, DST edge cases
│   └── TOOL-REFERENCE.md         # Complete schemas for all 11 tools
└── assets/presets/
    ├── personal-assistant.json   # Personal scheduling preset
    ├── recruiter-agent.json      # Interview scheduling preset
    └── team-coordinator.json     # Team scheduling preset
```

## What scheduling presets are available?

Presets provide workflow hints for specific use cases:

| Preset | Use Case | Default Slot |
|--------|----------|-------------|
| Personal Assistant | General scheduling | 30 min |
| Recruiter Agent | Interview coordination | 60 min |
| Team Coordinator | Group meetings | 30 min |

See [TOOL-REFERENCE.md](calendar-scheduling/references/TOOL-REFERENCE.md) for complete input/output schemas of all 11 tools.

## What tools does the MCP server expose?

| Layer | Tools |
|-------|-------|
| 4. Booking | `book_slot` |
| 3. Availability | `get_availability` |
| 2. Calendar Ops | `list_events`, `find_free_slots`, `expand_rrule`, `check_availability` |
| 1. Temporal Context | `get_temporal_context`, `resolve_datetime`, `convert_timezone`, `compute_duration`, `adjust_timestamp` |

See [TOOL-REFERENCE.md](calendar-scheduling/references/TOOL-REFERENCE.md) for complete schemas.

## Frequently Asked Questions

### What agent platforms support this skill?

The skill follows the [Agent Skills specification](https://agentskills.io/specification) and works with Claude Code, Claude Desktop, OpenAI Codex CLI, Google Gemini CLI, GitHub Copilot, Cursor, Windsurf, and 20+ other platforms. Any tool that reads SKILL.md files can load this skill.

### What is the orient-resolve-query-book workflow?

Every calendar interaction follows 4 steps: (1) Orient — call `get_temporal_context` to know the current time and timezone. (2) Resolve — use `resolve_datetime` to convert human language to RFC 3339 timestamps. (3) Query — use `list_events`, `find_free_slots`, or `get_availability` to check calendars. (4) Book — use `check_availability` then `book_slot` for conflict-free booking with Two-Phase Commit.

### Can I use the skill without calendar credentials?

Yes, partially. Layer 1 tools (temporal context, datetime resolution, timezone conversion, duration computation, timestamp adjustment) work immediately with zero configuration. Calendar tools (Layers 2-4) require a one-time OAuth setup with at least one provider (Google Calendar, Microsoft Outlook, or CalDAV).

### Do I need to modify SKILL.md?

No. SKILL.md contains the skill definition in Agent Skills specification format and should not be edited. To customize behavior, use the preset JSON files in `assets/presets/` or modify the environment variables (`TIMEZONE`, `WEEK_START`) on the MCP server.

### How does this skill relate to the MCP server?

The skill provides procedural knowledge (what to do and in what order). The Model Context Protocol server provides tool execution (the actual computation and calendar API calls). Install both for optimal results: the skill teaches your AI agent the correct 4-step workflow for using the server's 11 tools effectively.

## Where can I learn more about Temporal Cortex?

- **[temporal-cortex-mcp](https://github.com/billylui/temporal-cortex-mcp)** — MCP server (the tool execution layer)
- **[temporal-cortex-core](https://github.com/billylui/temporal-cortex-core)** — Truth Engine + TOON (the computation layer)
- **[Agent Skills Specification](https://agentskills.io/specification)** — The open standard this skill follows

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Security

See [SECURITY.md](SECURITY.md).

## License

[MIT](LICENSE)
