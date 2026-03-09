# Temporal Cortex Agent Skills

Public Agent Skills repo. Follows the [Agent Skills specification](https://agentskills.io/specification). 3 canonical skills + 1 legacy alias, all backed by the same MCP server.

## Development

### CI Jobs

`validate-skill` (all 4 skills), `test-security`, `lint-scripts` (ShellCheck), `lint-json`, `link-check` (pull_request + schedule only), `publish-clawhub` (on `v*` tags)

### Conventions

- NEVER interpolate `${VAR}` into `python3 -c` strings (shell injection)
- Pin npm versions ONLY in SKILL.md `openclaw.install.package`, Dockerfile, smithery.yaml — NOT in user-facing docs or scripts
- Version tracks MCP server (currently 0.8.1)
- SKILL.md body < 500 lines, references < 300 lines
- Relative links within-skill, absolute GitHub URLs for cross-skill references

### Legacy Alias

`calendar-scheduling` is auto-generated from the router via `scripts/generate-alias.sh`. Re-run after editing `skills/temporal-cortex/SKILL.md`. CI freshness check verifies via `git diff --exit-code`.

### Boundaries

- Always: run ShellCheck on scripts before committing
- Ask first: changing tool counts, layer assignments, or skill decomposition
- Never: edit `skills/calendar-scheduling/SKILL.md` directly (auto-generated)

## Skill Index

| Skill | Directory | Description | Tools |
|-------|-----------|-------------|-------|
| `temporal-cortex` | [skills/temporal-cortex](skills/temporal-cortex/SKILL.md) | Router — routes calendar intents to focused sub-skills | All 18 |
| `temporal-cortex-datetime` | [skills/temporal-cortex-datetime](skills/temporal-cortex-datetime/SKILL.md) | Time resolution, timezone conversion, duration math | 5 (Layer 1) |
| `temporal-cortex-scheduling` | [skills/temporal-cortex-scheduling](skills/temporal-cortex-scheduling/SKILL.md) | Calendar ops, availability, booking, contact resolution, and proposal composition | 14 (Layers 0-4) |
| `calendar-scheduling` | [skills/calendar-scheduling](skills/calendar-scheduling/SKILL.md) | Backward-compatible alias for temporal-cortex router | All 18 |

## MCP Server

All skills share one MCP server: `@temporal-cortex/cortex-mcp`

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

## Installation

```bash
npx skills add temporal-cortex/skills
```
