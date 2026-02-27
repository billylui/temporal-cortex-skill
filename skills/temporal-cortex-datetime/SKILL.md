---
name: temporal-cortex-datetime
description: |-
  Resolve natural language time expressions, convert timezones, compute durations, and adjust timestamps with DST awareness. Pure computation — no calendar API calls, no credentials required.
license: MIT
compatibility: |-
  Requires npx (Node.js 18+) for the MCP server. No OAuth or credentials needed — all tools are pure computation. Works with Claude Code, Claude Desktop, Cursor, Windsurf, and any MCP-compatible client.
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
---

# Temporal Context & Datetime Resolution

5 tools for temporal orientation and datetime computation. All are pure computation (no external API calls), read-only, and idempotent. No OAuth or calendar credentials required.

## Tools

| Tool | When to Use |
|------|------------|
| `get_temporal_context` | First call in any session. Returns current time, timezone, UTC offset, DST status, DST prediction, day of week. |
| `resolve_datetime` | Convert human expressions to RFC 3339. Supports 60+ patterns: `"next Tuesday at 2pm"`, `"tomorrow morning"`, `"+2h"`, `"start of next week"`, `"third Friday of March"`. |
| `convert_timezone` | Convert RFC 3339 datetime between IANA timezones. |
| `compute_duration` | Duration between two timestamps (days, hours, minutes). |
| `adjust_timestamp` | DST-aware timestamp adjustment. `"+1d"` across spring-forward = same wall-clock time. |

## Critical Rules

1. **Always call `get_temporal_context` before time-dependent work** — never assume the time or timezone.
2. **Resolve before querying** — convert `"next Tuesday at 2pm"` to RFC 3339 with `resolve_datetime` before passing to calendar tools.
3. **Timezone awareness** — all datetime tools produce RFC 3339 with timezone offsets.

## resolve_datetime Expression Patterns

The expression parser supports 60+ patterns across 10 categories:

| Category | Examples |
|----------|---------|
| Relative | `"now"`, `"today"`, `"tomorrow"`, `"yesterday"` |
| Named days | `"next Monday"`, `"this Friday"`, `"last Wednesday"` |
| Time of day | `"morning"` (09:00), `"noon"`, `"evening"` (18:00), `"eob"` (17:00) |
| Clock time | `"2pm"`, `"14:00"`, `"3:30pm"` |
| Offsets | `"+2h"`, `"-30m"`, `"in 2 hours"`, `"3 days ago"` |
| Compound | `"next Tuesday at 2pm"`, `"tomorrow morning"`, `"this Friday at noon"` |
| Period boundaries | `"start of week"`, `"end of month"`, `"start of next week"`, `"end of last month"` |
| Ordinal weekday | `"first Monday of March"`, `"third Friday of next month"` |
| RFC 3339 passthrough | `"2026-03-15T14:00:00-04:00"` (returned as-is) |
| Week start aware | Uses configured `WEEK_START` (Monday default, Sunday option) |

## Common Patterns

### Get Current Time Context

```
get_temporal_context()
→ utc, local, timezone, utc_offset, dst_active, dst_next_transition,
  day_of_week, iso_week, is_weekday, day_of_year, week_start
```

### Resolve a Meeting Time

```
resolve_datetime("next Tuesday at 2pm")
→ resolved_utc, resolved_local, timezone, interpretation
```

### Convert Across Timezones

```
1. get_temporal_context → user's timezone
2. convert_timezone(datetime: "2026-03-15T14:00:00-04:00", target_timezone: "Asia/Tokyo")
   → same moment in Tokyo time with DST and offset info
```

### Calculate Duration

```
compute_duration(start: "2026-03-15T09:00:00-04:00", end: "2026-03-15T17:30:00-04:00")
→ total_seconds: 30600, hours: 8, minutes: 30, human_readable: "8 hours 30 minutes"
```

### DST-Aware Adjustment

```
adjust_timestamp(
  datetime: "2026-03-07T23:00:00-05:00",
  adjustment: "+1d",
  timezone: "America/New_York"
) → same wall-clock time (23:00) on March 8, even though DST spring-forward occurs
```

## Additional References

- [Datetime Tools Reference](references/DATETIME-TOOLS.md) — Complete input/output schemas for all 5 tools
