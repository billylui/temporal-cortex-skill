# Temporal Cortex Skills

[![CI](https://github.com/temporal-cortex/skills/actions/workflows/ci.yml/badge.svg)](https://github.com/temporal-cortex/skills/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**v0.5.0** · February 2026 · [Changelog](CHANGELOG.md) · **Website:** [temporal-cortex.com](https://temporal-cortex.com)

Agent Skills for AI calendar scheduling using the [Temporal Cortex MCP server](https://github.com/temporal-cortex/mcp). Teaches AI agents the correct workflow for calendar discovery, temporal orientation, datetime resolution, multi-calendar availability merging, and conflict-free booking. Compatible with 26+ agent platforms.

## Skills

| Skill | Description | Tools |
|-------|-------------|-------|
| [temporal-cortex](skills/temporal-cortex/SKILL.md) | Router — routes calendar intents to sub-skills | All 12 |
| [temporal-cortex-datetime](skills/temporal-cortex-datetime/SKILL.md) | Time resolution, timezone conversion, duration math | 5 |
| [temporal-cortex-calendars](skills/temporal-cortex-calendars/SKILL.md) | Calendar discovery, events, free slots, availability, RRULE | 7 |
| [temporal-cortex-booking](skills/temporal-cortex-booking/SKILL.md) | Atomic booking with Two-Phase Commit | 1 |

## Installation

```bash
npx skills add temporal-cortex/skills
```

Or manually:

```bash
git clone https://github.com/temporal-cortex/skills.git
cp -r skills/temporal-cortex* ~/.claude/skills/
```

## MCP Server Connection

All skills share one MCP server. The included [.mcp.json](.mcp.json) provides the default configuration:

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
npx @temporal-cortex/cortex-mcp auth google     # Google Calendar
npx @temporal-cortex/cortex-mcp auth outlook    # Microsoft Outlook
npx @temporal-cortex/cortex-mcp auth caldav     # CalDAV (iCloud, Fastmail)
```

## Repository Structure

```
skills/
├── temporal-cortex/                  # Router skill
│   └── SKILL.md
├── temporal-cortex-datetime/         # Time & timezone tools
│   ├── SKILL.md
│   └── references/DATETIME-TOOLS.md
├── temporal-cortex-calendars/        # Calendar operations
│   ├── SKILL.md
│   └── references/
│       ├── CALENDAR-TOOLS.md
│       ├── MULTI-CALENDAR.md
│       └── RRULE-GUIDE.md
└── temporal-cortex-booking/          # Conflict-free booking
    ├── SKILL.md
    └── references/BOOKING-SAFETY.md
scripts/                              # Shared automation
├── setup.sh                          # OAuth + calendar connection
├── configure.sh                      # Timezone + week start
└── status.sh                         # Connection health check
assets/presets/                       # Workflow presets
├── personal-assistant.json
├── recruiter-agent.json
└── team-coordinator.json
```

## Tool Layers

| Layer | Tools | Skill |
|-------|-------|-------|
| 4. Booking | `book_slot` | booking |
| 3. Availability | `get_availability` | calendars |
| 2. Calendar Ops | `list_events`, `find_free_slots`, `expand_rrule`, `check_availability` | calendars |
| 1. Temporal Context | `get_temporal_context`, `resolve_datetime`, `convert_timezone`, `compute_duration`, `adjust_timestamp` | datetime |
| 0. Discovery | `list_calendars` | calendars |

## Presets

| Preset | Use Case | Default Slot |
|--------|----------|-------------|
| Personal Assistant | General scheduling | 30 min |
| Recruiter Agent | Interview coordination | 60 min |
| Team Coordinator | Group meetings | 30 min |

## FAQ

### What agent platforms support these skills?

The skills follow the [Agent Skills specification](https://agentskills.io/specification) and work with Claude Code, Claude Desktop, OpenAI Codex CLI, Google Gemini CLI, GitHub Copilot, Cursor, Windsurf, and 20+ other platforms.

### Can I use datetime skills without calendar credentials?

Yes. The `temporal-cortex-datetime` skill works immediately with zero configuration — all 5 tools are pure computation with no external API calls.

### How do the router and sub-skills interact?

The router skill (`temporal-cortex`) knows the full 5-step workflow and routes to the appropriate sub-skill based on intent. For a full scheduling workflow (resolve time → check availability → book), the agent progresses through datetime → calendars → booking sub-skills.

## More

- **[temporal-cortex/mcp](https://github.com/temporal-cortex/mcp)** — MCP server
- **[temporal-cortex/core](https://github.com/temporal-cortex/core)** — Truth Engine + TOON
- **[Agent Skills Specification](https://agentskills.io/specification)** — The open standard these skills follow

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)
