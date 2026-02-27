---
name: temporal-cortex-booking
description: |-
  Book calendar events atomically with Two-Phase Commit conflict prevention. The only write operation — always check availability first, then book with lock-verify-write-release safety.
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

# Conflict-Free Calendar Booking

1 tool for atomic calendar booking with Two-Phase Commit (2PC) conflict prevention. This is the only non-read-only tool in the Temporal Cortex toolkit.

## Tool

| Tool | When to Use |
|------|------------|
| `book_slot` | Book a time slot atomically. Lock → verify → write → release. **Always `check_availability` first.** |

## Critical Rules

1. **Check before booking** — always call `check_availability` (from [temporal-cortex-calendars](../temporal-cortex-calendars/SKILL.md)) before `book_slot`. Never skip the conflict check.
2. **Content safety** — event summaries and descriptions pass through a sanitization firewall before reaching the calendar API.
3. **Use provider-prefixed IDs** — specify where to create the event: `"google/primary"`, `"outlook/work"`.

## Full Booking Workflow

```
1. Discover  →  list_calendars                           (temporal-cortex-calendars)
2. Orient    →  get_temporal_context                     (temporal-cortex-datetime)
3. Resolve   →  resolve_datetime("next Tuesday at 2pm") (temporal-cortex-datetime)
4. Check     →  check_availability(calendar_id, start, end) (temporal-cortex-calendars)
5. Book      →  book_slot(calendar_id, start, end, summary) (this skill)
```

If the slot is busy at step 4, use `find_free_slots` to suggest alternatives.

## Two-Phase Commit Protocol

```
Agent calls book_slot(calendar_id, start, end, summary)
    │
    ├─ 1. LOCK    →  Acquire exclusive lock on the time slot
    │                 (in-memory local; Redis Redlock in Platform Mode)
    │
    ├─ 2. VERIFY  →  Check for overlapping events and active locks
    │
    ├─ 3. WRITE   →  Create event in calendar provider (Google/Outlook/CalDAV)
    │                 Record event in shadow calendar
    │
    └─ 4. RELEASE →  Release the exclusive lock
```

If any step fails, the lock is released and the booking is aborted. No partial writes.

## Error Handling

| Error | Action |
|-------|--------|
| Slot is busy / conflict detected | Use `find_free_slots` to suggest alternatives. Present options to user. |
| Lock acquisition failed | Another agent is booking the same slot. Wait briefly and retry, or suggest alternative times. |
| Content rejected by sanitization | Rephrase the event summary/description. The firewall blocks prompt injection attempts. |

## Tool Annotations

| Property | Value | Meaning |
|----------|-------|---------|
| `readOnlyHint` | `false` | Creates calendar events |
| `destructiveHint` | `false` | Never deletes or overwrites existing events |
| `idempotentHint` | `false` | Calling twice creates two events |
| `openWorldHint` | `true` | Makes external API calls |

## Additional References

- [Booking Safety](references/BOOKING-SAFETY.md) — 2PC details, concurrent booking, lock TTL, content sanitization
