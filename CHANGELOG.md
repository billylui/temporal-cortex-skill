# Changelog

All notable changes to the Temporal Cortex Agent Skill will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/billylui/temporal-cortex-skill/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/billylui/temporal-cortex-skill/compare/v0.3.6...v0.4.0
[0.3.6]: https://github.com/billylui/temporal-cortex-skill/compare/v0.3.5...v0.3.6
[0.3.5]: https://github.com/billylui/temporal-cortex-skill/compare/v0.3.4...v0.3.5
[0.3.4]: https://github.com/billylui/temporal-cortex-skill/compare/v0.3.3...v0.3.4
[0.3.3]: https://github.com/billylui/temporal-cortex-skill/compare/v0.3.2...v0.3.3
[0.3.2]: https://github.com/billylui/temporal-cortex-skill/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/billylui/temporal-cortex-skill/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/billylui/temporal-cortex-skill/releases/tag/v0.3.0
