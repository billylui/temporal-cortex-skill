---
name: temporal-cortex-calendars
description: |-
  List calendars, query events, find free slots, check availability across Google/Outlook/CalDAV, and expand RFC 5545 recurrence rules. Read-only calendar operations with TOON token compression and multi-calendar merging.
license: MIT
compatibility: |-
  Requires npx (Node.js 18+) or Docker for the MCP server. Stores OAuth credentials at ~/.config/temporal-cortex/. Works with Claude Code, Claude Desktop, Cursor, Windsurf, and any MCP-compatible client.
metadata:
  author: temporal-cortex
  version: "0.5.0"
  mcp-server: "@temporal-cortex/cortex-mcp"
  homepage: "https://temporal-cortex.com"
  repository: "https://github.com/temporal-cortex/skills"
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

# Calendar Operations & Availability

7 read-only tools for calendar discovery, event querying, free slot finding, availability checking, and RRULE expansion. All tools are read-only and idempotent.

## Tools

### Layer 0 — Discovery

| Tool | When to Use |
|------|------------|
| `list_calendars` | First call when calendars are unknown. Returns all connected calendars with provider-prefixed IDs, names, labels, primary status, and access roles. |

### Layer 2 — Calendar Operations

| Tool | When to Use |
|------|------------|
| `list_events` | List events in a time range. TOON format by default (~40% fewer tokens than JSON). Use provider-prefixed IDs for multi-calendar: `"google/primary"`, `"outlook/work"`. |
| `find_free_slots` | Find available gaps in a calendar. Set `min_duration_minutes` for minimum slot length. |
| `expand_rrule` | Expand recurrence rules (RFC 5545) into concrete instances. Handles DST, BYSETPOS, EXDATE, leap years. Use `dtstart` as local datetime (no timezone suffix). |
| `check_availability` | Check if a specific time slot is free. Checks both events and active booking locks. |

### Layer 3 — Cross-Calendar Availability

| Tool | When to Use |
|------|------------|
| `get_availability` | Merged free/busy view across multiple calendars. Pass `calendar_ids` array. Privacy: `"opaque"` (default, hides sources) or `"full"`. |

## Critical Rules

1. **Discover calendars first** — call `list_calendars` when you don't know which calendars are connected. Use the returned provider-prefixed IDs for all subsequent calls.
2. **Use provider-prefixed IDs** for multi-calendar setups: `"google/primary"`, `"outlook/work"`, `"caldav/personal"`. Bare IDs (e.g., `"primary"`) route to the default provider.
3. **TOON is the default format** — output uses TOON (~40% fewer tokens than JSON). Pass `format: "json"` only if you need structured parsing.
4. **Timezone awareness** — all calendar tools accept RFC 3339 with timezone offsets. Never use bare dates.

## Common Patterns

### List Events This Week

```
1. list_calendars → discover connected calendars
2. get_temporal_context → current time (use temporal-cortex-datetime)
3. resolve_datetime("start of this week") → week start
4. resolve_datetime("end of this week") → week end
5. list_events(calendar_id: "google/primary", start, end)
```

### Find Free Time Across Calendars

```
1. list_calendars → discover all connected calendars
2. get_availability(
     start, end,
     calendar_ids: ["google/primary", "outlook/work"],
     privacy: "full"
   ) → merged free/busy blocks with source_count
```

### Check a Specific Slot

```
check_availability(calendar_id: "google/primary", start, end) → true/false
```

### Expand Recurring Events

```
expand_rrule(
  rrule: "FREQ=MONTHLY;BYDAY=FR;BYSETPOS=-1",
  dtstart: "2026-01-01T10:00:00",     ← local datetime, no timezone suffix
  timezone: "America/New_York",
  count: 12
) → last Friday of every month for 2026
```

## Provider-Prefixed Calendar IDs

All calendar IDs use provider-prefixed format:

| Format | Example | Routes to |
|--------|---------|-----------|
| `google/<id>` | `"google/primary"` | Google Calendar |
| `outlook/<id>` | `"outlook/work"` | Microsoft Outlook |
| `caldav/<id>` | `"caldav/personal"` | CalDAV (iCloud, Fastmail) |
| `<id>` (bare) | `"primary"` | Default provider |

## Privacy Modes

| Mode | `source_count` | Use case |
|------|---------------|----------|
| `"opaque"` (default) | Always `0` | Sharing availability externally |
| `"full"` | Actual count | Internal use — shows which calendars are busy |

## Error Handling

| Error | Action |
|-------|--------|
| "No credentials found" | Run: `npx @temporal-cortex/cortex-mcp auth google` (or `outlook` / `caldav`). |
| "Timezone not configured" | Prompt for IANA timezone. Or run the auth command which configures timezone. |

## Additional References

- [Calendar Tools Reference](references/CALENDAR-TOOLS.md) — Complete input/output schemas for all 7 tools
- [Multi-Calendar Guide](references/MULTI-CALENDAR.md) — Provider routing, labels, privacy modes, cross-provider operations
- [RRULE Guide](references/RRULE-GUIDE.md) — Recurrence rule patterns, DST edge cases, 5 LLM failure modes
