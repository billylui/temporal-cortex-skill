# Changelog

All notable changes to the Temporal Cortex Agent Skill will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- **setup.sh**: Renamed "Cloud Mode" to "Platform Mode" — `--platform` flag replaces `--cloud` (backward-compatible: `--cloud` still works)
- **SKILL.md**: Updated "Managed cloud" section to "Temporal Cortex Platform" with Platform capabilities description
- **BOOKING-SAFETY.md**: Consistent "Platform Mode" capitalization

## [0.5.0] - 2026-02-26

### Added
- `list_calendars` tool — new Layer 0 discovery tool returns all connected calendars with provider-prefixed IDs, names, labels, primary status, and access roles
- Calendar labeling documentation — user-assigned labels for human-friendly calendar identification
- `discover_calendars` MCP prompt for guided calendar discovery workflow
- `format` parameter added to `get_availability`, `find_free_slots`, and `expand_rrule` tools
- DST prediction fields (`dst_next_transition`, `dst_next_offset`) in `get_temporal_context` output

### Changed
- **5-step workflow**: Discover → Orient → Resolve → Query → Act (was 4-step: Orient → Resolve → Query → Act)
- Tool count 11 → 12 (added `list_calendars`)
- MCP prompts 3 → 4 (added `discover_calendars`)
- TOON is now the default output format for `list_events`, `list_calendars`, `find_free_slots`, `expand_rrule`, and `get_availability` (~40% fewer tokens than JSON)
- `list_events` default format changed from `"json"` to `"toon"`
- MULTI-CALENDAR.md rewritten: replaced manual calendar ID guidance with `list_calendars` discovery workflow
- Presets updated: removed explicit `format: "json"` (server TOON default applies), added `list_calendars` workflow hints
- `setup.sh` references `cortex-mcp setup` as primary setup flow, `auth` as fallback

## [0.4.5] - 2026-02-25

### Changed
- Version alignment with MCP server v0.4.5 (tool annotations, prompts, resources, ServerInfo, improved Smithery quality score)
- Pinned MCP server version to `@temporal-cortex/cortex-mcp@0.4.5` in `.mcp.json` and `setup.sh`

## [0.4.4] - 2026-02-25

### Changed
- Version alignment with MCP server v0.4.4 (server card endpoint for Smithery registry discovery)
- Pinned MCP server version to `@temporal-cortex/cortex-mcp@0.4.4` in `.mcp.json` and `setup.sh`

## [0.4.3] - 2026-02-24

### Changed
- Optimized SKILL.md `description` for AEO (Agent Engine Optimization) — front-loaded action verbs, replaced implementation jargon with user-language triggers ("free time", "appointments", "busy", "timezones"), improved ClawHub truncation resilience (first sentence completes within 101 chars)

## [0.4.2] - 2026-02-24

### Security
- Removed `primaryEnv: TIMEZONE` — scanner misinterprets TIMEZONE as a credential env var, but it is a user preference (auto-detected from OS)
- Removed `openclaw.requires.env` block — TIMEZONE and WEEK_START are optional overrides with auto-detection, not required env vars
- Moved TIMEZONE and WEEK_START from `env` to `optional_env` in `metadata.requires` JSON for backward-compat scanners
- Added `metadata.homepage` and `metadata.repository` for publisher provenance verification

### Changed
- **ci**: Added Dependabot auto-merge workflow — auto-approves and merges patch updates after CI passes
- Updated `test-security.sh` OpenClaw assertions to validate absence of `env` block and `primaryEnv`, validate presence of `homepage` and `repository`

## [0.4.1] - 2026-02-23

### Security
- Removed OAuth env vars from `metadata.openclaw.requires.env` — optional bring-your-own-app overrides, not required for normal operation (resolves OpenClaw "over-broad credentials" finding)
- Removed OAuth env vars from `.mcp.json` env block — MCP client UIs no longer prompt for optional fields
- Changed `openclaw.primaryEnv` from `GOOGLE_CLIENT_ID` to `TIMEZONE`
- Added missing `WEEK_START` to `openclaw.requires.env`

### Changed
- Updated MULTI-CALENDAR.md env var table to clarify OAuth vars are for custom OAuth apps only
- Updated `test-security.sh` assertions to validate corrected metadata structure

## [0.4.0] - 2026-02-23

### Added
- Cloud mode support — `--cloud` flag for `setup.sh`, updated `.mcp.json` with cloud config

## [0.3.6] - 2026-02-23

### Security
- Added `metadata.openclaw` block with structured `requires.bins`, `requires.env`, `requires.config`, and `primaryEnv` fields for ClawHub/OpenClaw scanner compatibility ([clawhub#340](https://github.com/openclaw/clawhub/issues/340))
- Annotated `REDIS_URLS` and `LOCK_TTL_SECS` as platform-mode only in BOOKING-SAFETY reference doc

### Changed
- Added 7 OpenClaw registry metadata assertions to `test-security.sh` (29 total)

## [0.3.5] - 2026-02-23

### Security
- Pinned npm version in `setup.sh` (`@temporal-cortex/cortex-mcp@0.3.5`) for supply chain auditability
- Added `-y` flag to `setup.sh` npx invocation for consistent non-interactive behavior
- Added OAuth credential env var hints (`GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, `MICROSOFT_CLIENT_ID`, `MICROSOFT_CLIENT_SECRET`) to `.mcp.json` for scanner visibility

### Changed
- Added NPX version pinning and env var visibility assertions to `test-security.sh`

## [0.3.4] - 2026-02-23

### Security
- Pinned MCP server version in `.mcp.json` (`@temporal-cortex/cortex-mcp@0.3.4`) for supply chain auditability
- Added env var hints to `.mcp.json` for security scanner visibility

### Changed
- Expanded `metadata.requires`: added `MICROSOFT_CLIENT_SECRET`, `GOOGLE_OAUTH_CREDENTIALS`, `TEMPORAL_CORTEX_TELEMETRY` to `optional_env`; added `config.json` to `credentials`
- Added `MICROSOFT_CLIENT_SECRET` to MULTI-CALENDAR reference env var table

## [0.3.3] - 2026-02-22

### Security
- Fixed shell injection vulnerability in configure.sh — user-provided timezone was
  interpolated directly into Python code strings (reported by VirusTotal)
- Applied same env-var-passing fix to status.sh and validate-structure.sh
- Added input validation regex for IANA timezone format

### Added
- Security test suite (tests/test-security.sh) — validates input sanitization and
  Python env-var isolation across all scripts

### Changed
- Expanded SKILL.md compatibility field to declare python3 and credential storage
- Added metadata.requires declaration for automated security scanners

## [0.3.2] - 2026-02-22

### Changed
- Version alignment with MCP server v0.3.2 (interactive onboarding UX)
- Updated SKILL.md metadata version to 0.3.2

## [0.3.1] - 2026-02-22

### Changed
- Version alignment with MCP server v0.3.1 (anonymous telemetry support)
- Updated SKILL.md metadata version to 0.3.1

## [0.3.0] - 2026-02-22

### Added

- Initial release of the `calendar-scheduling` Agent Skill
- SKILL.md with 4-step workflow: orient → resolve → query → book
- Reference documents: BOOKING-SAFETY, MULTI-CALENDAR, RRULE-GUIDE, TOOL-REFERENCE
- Scripts: setup.sh, configure.sh, status.sh
- Presets: personal-assistant, recruiter-agent, team-coordinator
- .mcp.json for local MCP server connection
- CI pipeline: SKILL.md validation, ShellCheck, JSON validation, link check

[Unreleased]: https://github.com/billylui/temporal-cortex-skill/compare/v0.5.0...HEAD
[0.5.0]: https://github.com/billylui/temporal-cortex-skill/compare/v0.4.5...v0.5.0
[0.4.5]: https://github.com/billylui/temporal-cortex-skill/compare/v0.4.4...v0.4.5
[0.4.4]: https://github.com/billylui/temporal-cortex-skill/compare/v0.4.3...v0.4.4
[0.4.3]: https://github.com/billylui/temporal-cortex-skill/compare/v0.4.2...v0.4.3
[0.4.2]: https://github.com/billylui/temporal-cortex-skill/compare/v0.4.1...v0.4.2
[0.4.1]: https://github.com/billylui/temporal-cortex-skill/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/billylui/temporal-cortex-skill/compare/v0.3.6...v0.4.0
[0.3.6]: https://github.com/billylui/temporal-cortex-skill/compare/v0.3.5...v0.3.6
[0.3.5]: https://github.com/billylui/temporal-cortex-skill/compare/v0.3.4...v0.3.5
[0.3.4]: https://github.com/billylui/temporal-cortex-skill/compare/v0.3.3...v0.3.4
[0.3.3]: https://github.com/billylui/temporal-cortex-skill/compare/v0.3.2...v0.3.3
[0.3.2]: https://github.com/billylui/temporal-cortex-skill/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/billylui/temporal-cortex-skill/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/billylui/temporal-cortex-skill/releases/tag/v0.3.0
