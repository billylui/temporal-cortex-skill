---
name: temporal-cortex
description: |-
  Schedule meetings, check availability, and manage calendars across Google, Outlook, and CalDAV. Routes to focused sub-skills for datetime resolution and calendar scheduling.
license: MIT
compatibility: |-
  Requires npx (Node.js 18+) or Docker for the MCP server. python3 optional (configure/status scripts). Stores OAuth credentials at ~/.config/temporal-cortex/. Works with Claude Code, Claude Desktop, Cursor, Windsurf, and any MCP-compatible client.
metadata:
  author: temporal-cortex
  version: "0.5.5"
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
| [temporal-cortex-datetime](https://github.com/temporal-cortex/skills/blob/main/skills/temporal-cortex-datetime/SKILL.md) | Time resolution, timezone conversion, duration math. No credentials needed — works immediately. | 5 tools (Layer 1) |
| [temporal-cortex-scheduling](https://github.com/temporal-cortex/skills/blob/main/skills/temporal-cortex-scheduling/SKILL.md) | List calendars, events, free slots, availability, RRULE expansion, and booking. Requires OAuth credentials. | 8 tools (Layers 0-4) |

## Routing Table

| User Intent | Route To |
|------------|----------|
| "What time is it?", "Convert timezone", "How long until..." | **temporal-cortex-datetime** |
| "Show my calendar", "Find free time", "Check availability", "Expand recurring rule" | **temporal-cortex-scheduling** |
| "Book a meeting", "Schedule an appointment" | **temporal-cortex-scheduling** |
| "Schedule a meeting next Tuesday at 2pm" (full workflow) | **temporal-cortex-datetime** → **temporal-cortex-scheduling** |

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
| 0 — Discovery | `list_calendars` | scheduling |
| 1 — Temporal Context | `get_temporal_context`, `resolve_datetime`, `convert_timezone`, `compute_duration`, `adjust_timestamp` | datetime |
| 2 — Calendar Ops | `list_events`, `find_free_slots`, `expand_rrule`, `check_availability` | scheduling |
| 3 — Availability | `get_availability` | scheduling |
| 4 — Booking | `book_slot` | scheduling |

## MCP Server Connection

All sub-skills share the [Temporal Cortex MCP server](https://github.com/temporal-cortex/mcp) (`@temporal-cortex/cortex-mcp@0.5.5`), a compiled Rust binary distributed as an npm package.

**What happens at startup:**
1. `npx` downloads `@temporal-cortex/cortex-mcp@0.5.5` from the npm registry (one-time, cached locally)
2. The MCP server starts as a local process communicating over stdio
3. Layer 1 tools (datetime) execute as pure local computation — no further network access
4. Layer 2-4 tools (calendar) make authenticated API calls to your configured providers (Google, Outlook, CalDAV)

**Credential storage:** OAuth tokens are stored and used locally at `~/.config/temporal-cortex/credentials.json` — never sent to Temporal Cortex servers.

**Verification:** SHA256 checksums are published with each [GitHub Release](https://github.com/temporal-cortex/mcp/releases) and embedded in the npm package for automatic postinstall verification. Source: [github.com/temporal-cortex/mcp](https://github.com/temporal-cortex/mcp) (MIT-licensed).

See [.mcp.json](https://github.com/temporal-cortex/skills/blob/main/.mcp.json) for the default configuration:

```json
{
  "mcpServers": {
    "temporal-cortex": {
      "command": "npx",
      "args": ["-y", "@temporal-cortex/cortex-mcp@0.5.5"]
    }
  }
}
```

For managed hosting (no local setup), see [Platform Mode](https://github.com/temporal-cortex/mcp#local-mode-vs-platform-mode) in the MCP repo.

Layer 1 tools work immediately with zero configuration. Calendar tools require a one-time OAuth setup — run the [setup script](https://github.com/temporal-cortex/skills/blob/main/scripts/setup.sh) or `npx @temporal-cortex/cortex-mcp@0.5.5 auth google`.
