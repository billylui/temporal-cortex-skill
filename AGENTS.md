# Temporal Cortex Agent Skills

Machine-readable skill index for the Temporal Cortex MCP server.

## Available Skills

| Skill | Directory | Description | Tools |
|-------|-----------|-------------|-------|
| `temporal-cortex` | [skills/temporal-cortex](skills/temporal-cortex/SKILL.md) | Router — routes calendar intents to focused sub-skills | All 12 |
| `temporal-cortex-datetime` | [skills/temporal-cortex-datetime](skills/temporal-cortex-datetime/SKILL.md) | Time resolution, timezone conversion, duration math | 5 (Layer 1) |
| `temporal-cortex-calendars` | [skills/temporal-cortex-calendars](skills/temporal-cortex-calendars/SKILL.md) | Calendar discovery, events, free slots, availability, RRULE | 7 (Layers 0-3) |
| `temporal-cortex-booking` | [skills/temporal-cortex-booking](skills/temporal-cortex-booking/SKILL.md) | Atomic booking with Two-Phase Commit | 1 (Layer 4) |

## MCP Server

All skills share one MCP server: `@temporal-cortex/cortex-mcp`

```json
{
  "mcpServers": {
    "temporal-cortex": {
      "command": "npx",
      "args": ["-y", "@temporal-cortex/cortex-mcp@0.5.0"]
    }
  }
}
```

## Installation

```bash
npx skills add temporal-cortex/skills
```
