# Changelog

All notable changes to the Temporal Cortex Agent Skill will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/billylui/temporal-cortex-skill/compare/v0.3.4...HEAD
[0.3.4]: https://github.com/billylui/temporal-cortex-skill/compare/v0.3.3...v0.3.4
[0.3.3]: https://github.com/billylui/temporal-cortex-skill/compare/v0.3.2...v0.3.3
[0.3.2]: https://github.com/billylui/temporal-cortex-skill/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/billylui/temporal-cortex-skill/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/billylui/temporal-cortex-skill/releases/tag/v0.3.0
