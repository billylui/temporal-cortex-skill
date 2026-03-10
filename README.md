# Temporal Cortex Skills

[![CI](https://github.com/temporal-cortex/skills/actions/workflows/ci.yml/badge.svg)](https://github.com/temporal-cortex/skills/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**v0.9.1** · March 2026 · [Changelog](CHANGELOG.md) · **Website:** [temporal-cortex.com](https://temporal-cortex.com)

Agent Skills that give AI agents scheduling capabilities — from finding contacts to booking or sending proposals. Built on [Temporal Cortex](https://github.com/temporal-cortex/mcp) open scheduling infrastructure with 18 tools across 5 layers. Compatible with 26+ agent platforms.

## Skills

| Skill | Description | Tools |
|-------|-------------|-------|
| [temporal-cortex](skills/temporal-cortex/SKILL.md) | Router — routes calendar intents to sub-skills | All 18 |
| [temporal-cortex-datetime](skills/temporal-cortex-datetime/SKILL.md) | Time resolution, timezone conversion, duration math (no credentials needed) | 5 |
| [temporal-cortex-scheduling](skills/temporal-cortex-scheduling/SKILL.md) | Contact resolution, calendar ops, availability, booking, and Open Scheduling | 14 |
| [calendar-scheduling](skills/calendar-scheduling/SKILL.md) | Legacy alias for temporal-cortex (auto-generated) | All 18 |

> **Zero-setup Layer 1:** The `temporal-cortex-datetime` skill works immediately — no OAuth, no API keys, no configuration. All 5 temporal tools (timezone conversion, datetime resolution, duration math) are pure computation. Connect calendar providers only when you need calendar operations (Layers 2-4).

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
├── temporal-cortex-datetime/         # Time & timezone tools (no credentials needed)
│   ├── SKILL.md
│   └── references/DATETIME-TOOLS.md
├── temporal-cortex-scheduling/       # Calendar ops + booking (needs OAuth)
│   ├── SKILL.md
│   └── references/
│       ├── BOOKING-SAFETY.md
│       ├── CALENDAR-TOOLS.md
│       ├── MULTI-CALENDAR.md
│       ├── OPEN-SCHEDULING.md
│       ├── RRULE-GUIDE.md
│       └── TEMPORAL-LINKS.md
└── calendar-scheduling/              # Legacy alias (auto-generated, do not edit)
    ├── SKILL.md
    └── references/
        └── SECURITY-MODEL.md
scripts/                              # Shared automation
├── setup.sh                          # OAuth + calendar connection
├── configure.sh                      # Timezone + week start
└── status.sh                         # Connection health check
assets/presets/                       # Workflow presets
├── meeting-coordinator.json
├── personal-assistant.json
├── recruiter-agent.json
└── team-coordinator.json
```

## Tool Layers

| Layer | Tools | Skill |
|-------|-------|-------|
| 4. Booking | `book_slot`, `request_booking` | scheduling |
| 3. Availability | `get_availability`, `query_public_availability` | scheduling |
| 2. Calendar Ops | `list_calendars`, `list_events`, `find_free_slots`, `expand_rrule`, `check_availability` | scheduling |
| 1. Temporal Context | `get_temporal_context`, `resolve_datetime`, `convert_timezone`, `compute_duration`, `adjust_timestamp` | datetime |
| 0. Discovery | `resolve_identity` | scheduling |

## Presets

| Preset | Use Case | Default Slot |
|--------|----------|-------------|
| Meeting Coordinator | Cross-user scheduling with Open Scheduling | 30 min |
| Personal Assistant | General scheduling | 30 min |
| Recruiter Agent | Interview coordination | 60 min |
| Team Coordinator | Group meetings | 30 min |

## FAQ

### What agent platforms support these skills?

The skills follow the [Agent Skills specification](https://agentskills.io/specification) and work with Claude Code, Claude Desktop, OpenAI Codex CLI, Google Gemini CLI, GitHub Copilot, Cursor, Windsurf, and 20+ other platforms.

### Can I use datetime skills without calendar credentials?

Yes. The `temporal-cortex-datetime` skill works immediately with zero setup — no OAuth or API keys needed. All 5 tools are pure computation with no external API calls.

### What happened to `calendar-scheduling`?

The original `calendar-scheduling` skill was renamed to `temporal-cortex` at v0.5.1 when it was decomposed into a router + 2 focused sub-skills. The `calendar-scheduling` slug is still published on all directories as a backward-compatible alias — it is auto-generated from the router SKILL.md and installs the same MCP server.

### How do the router and sub-skills interact?

The router skill (`temporal-cortex`) knows the full 7-step workflow and routes to the appropriate sub-skill based on intent. For a full scheduling workflow (resolve time → check availability → book), the agent progresses through datetime → scheduling sub-skills.

## Listings

These skills are published on multiple directories:

- **[ClawHub](https://clawhub.ai)** — All 3 skills + legacy `calendar-scheduling` alias published individually (auto-published on release via CI)
- **[anthropics/skills](https://github.com/anthropics/skills/pull/479)** — Official Anthropic skill directory (PR pending)
- **[awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills/pull/281)** — Community curated list (PR pending)

## More

- **[temporal-cortex/mcp](https://github.com/temporal-cortex/mcp)** — MCP server
- **[temporal-cortex/core](https://github.com/temporal-cortex/core)** — Truth Engine + TOON
- **[Agent Skills Specification](https://agentskills.io/specification)** — The open standard these skills follow

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)
