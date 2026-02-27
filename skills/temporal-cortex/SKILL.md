---
name: temporal-cortex
description: |-
  AI calendar scheduling — routes to focused sub-skills for datetime resolution, calendar operations, and conflict-free booking. Start here to discover which skill handles your task.
license: MIT
compatibility: |-
  Requires npx (Node.js 18+) or Docker for the MCP server. python3 optional (configure/status scripts). Stores OAuth credentials at ~/.config/temporal-cortex/. Works with Claude Code, Claude Desktop, Cursor, Windsurf, and any MCP-compatible client.
metadata:
  author: temporal-cortex
  version: "0.5.2"
  mcp-server: "@temporal-cortex/cortex-mcp"
  homepage: "https://temporal-cortex.com"
  repository: "https://github.com/temporal-cortex/skills"
  requires: '{"bins":["npx"],"optional_bins":["python3","docker"],"optional_env":["TIMEZONE","WEEK_START","HTTP_PORT","GOOGLE_CLIENT_ID","GOOGLE_CLIENT_SECRET","MICROSOFT_CLIENT_ID","MICROSOFT_CLIENT_SECRET","GOOGLE_OAUTH_CREDENTIALS","TEMPORAL_CORTEX_TELEMETRY"],"credentials":["~/.config/temporal-cortex/credentials.json","~/.config/temporal-cortex/config.json"]}'
  openclaw:
    requires:
      bins:
        - npx
      anyBins:
        - python3
        - docker
      config:
        - ~/.config/temporal-cortex/credentials.json
        - ~/.config/temporal-cortex/config.json
---

# Temporal Cortex — Calendar Scheduling Router

This is the router skill for Temporal Cortex calendar operations. It routes your task to the right sub-skill based on intent.

## Sub-Skills

| Sub-Skill | When to Use | Tools |
|-----------|------------|-------|
| [temporal-cortex-datetime](../temporal-cortex-datetime/SKILL.md) | Time resolution, timezone conversion, duration math | 5 tools (Layer 1) |
| [temporal-cortex-calendars](../temporal-cortex-calendars/SKILL.md) | List calendars, events, free slots, availability, RRULE expansion | 7 tools (Layers 0-3) |
| [temporal-cortex-booking](../temporal-cortex-booking/SKILL.md) | Book a time slot with conflict prevention | 1 tool (Layer 4) |

## Routing Table

| User Intent | Route To |
|------------|----------|
| "What time is it?", "Convert timezone", "How long until..." | **temporal-cortex-datetime** |
| "Show my calendar", "Find free time", "Check availability", "Expand recurring rule" | **temporal-cortex-calendars** |
| "Book a meeting", "Schedule an appointment" | **temporal-cortex-booking** |
| "Schedule a meeting next Tuesday at 2pm" (full workflow) | **temporal-cortex-datetime** → **temporal-cortex-calendars** → **temporal-cortex-booking** |

## Core Workflow

Every calendar interaction follows this 5-step pattern:

```
1. Discover  →  list_calendars                (know which calendars are available)
2. Orient    →  get_temporal_context           (know the current time)
3. Resolve   →  resolve_datetime              (turn human language into timestamps)
4. Query     →  list_events / find_free_slots / get_availability
5. Act       →  check_availability → book_slot (verify then book)
```

**Always start with step 1** when calendars are unknown. Never assume the current time. Never skip the conflict check before booking.

## All 12 Tools (5 Layers)

| Layer | Tools | Sub-Skill |
|-------|-------|-----------|
| 0 — Discovery | `list_calendars` | calendars |
| 1 — Temporal Context | `get_temporal_context`, `resolve_datetime`, `convert_timezone`, `compute_duration`, `adjust_timestamp` | datetime |
| 2 — Calendar Ops | `list_events`, `find_free_slots`, `expand_rrule`, `check_availability` | calendars |
| 3 — Availability | `get_availability` | calendars |
| 4 — Booking | `book_slot` | booking |

## MCP Server Connection

All sub-skills share the same MCP server. See [.mcp.json](../../.mcp.json) for the default configuration.

**Local mode** (default):
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

**Temporal Cortex Platform** (no local setup):
```json
{
  "mcpServers": {
    "temporal-cortex": {
      "url": "https://mcp.temporal-cortex.com/sse",
      "headers": { "Authorization": "Bearer ${TC_API_KEY}" }
    }
  }
}
```

Layer 1 tools work immediately with zero configuration. Calendar tools require a one-time OAuth setup — run the [setup script](../../scripts/setup.sh) or `npx @temporal-cortex/cortex-mcp auth google`.
