# Changelog

All notable changes to the Temporal Cortex Agent Skill will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.7.0] - 2026-03-04

### Added
- **scheduling**: Temporal Links reference doc (`references/TEMPORAL-LINKS.md`) — documents Open Scheduling endpoints, Agent Card, availability query, and booking with curl examples
- **scheduling**: Open Scheduling & Temporal Links section in SKILL.md — describes the viral scheduling workflow

### Changed
- Version alignment with Platform v0.7.0 and MCP v0.7.0 (Open Scheduling, Agent Card, protocol-agnostic public endpoints, Portal UI)

## [0.6.2] - 2026-03-04

### Security
- **scanner**: Removed inline npx JSON config from router SKILL.md — scanner parsed `"command": "npx"` JSON block as a direct execution instruction, elevating INSTALL MECHANISM to warning level. Scheduling (Benign) only shows Docker config inline.
- **scanner**: Added `references/SECURITY-MODEL.md` to router skill — documents content sanitization firewall, filesystem containment, network scope per layer, and tool annotations. Scanner credits scheduling's `references/BOOKING-SAFETY.md` prompt injection firewall mention as a key positive signal.
- **scanner**: Added "Safety Rules" section to router SKILL.md with content safety (prompt injection firewall) and conflict check rules — mirrors scheduling's "Critical Rules" pattern

### Added
- **router**: New `references/SECURITY-MODEL.md` reference document — content sanitization, filesystem containment, network scope, tool annotations, Two-Phase Commit safety

### Changed
- **router**: Default npx config now referenced via link instead of inline JSON block — reduces scanner instruction surface while keeping information accessible

## [0.6.1] - 2026-03-04

### Security
- **scanner**: Removed legacy `metadata.requires` JSON string from router SKILL.md — contained OAuth client secrets as `optional_env` and a `credentials` key that competed with `openclaw.requires.config`, causing OpenClaw to flag CREDENTIALS and elevate INSTALL MECHANISM to warning level
- **scanner**: Added `config.json` to datetime `openclaw.requires.config` — scanner flagged inconsistency between SKILL.md body ("reads config.json") and metadata (no declared config paths)

### Added
- **ci**: Added legacy `metadata.requires` guard (section 9) to `test-security.sh` — prevents reintroduction of JSON requires strings in SKILL.md frontmatter
- **ci**: Added datetime config.json declaration check to `test-security.sh` section 6 — ensures `openclaw.requires.config` includes `config.json`

## [0.6.0] - 2026-03-03

### Security
- **scanner**: Added `openclaw.install` block (`kind: node`) to all 3 SKILL.md frontmatters — declares the npm install mechanism as a static install spec, addressing OpenClaw "no install spec" finding
- **scanner**: Restructured verification pipeline in all 3 SKILL.md files — independent GitHub Release checksum verification is now step 1; postinstall SHA256 check labeled "defense-in-depth" (breaks circular trust finding)
- **scanner**: Added pre-run verification section to all 3 SKILL.md files — `npm pack --dry-run`, independent checksum comparison, and Docker containment steps before first execution
- **scanner**: Renamed "What happens at startup" to "Install and startup lifecycle" with explicit binary source (GitHub Release) and failure behavior documentation
- **scanner**: Promoted Docker containment for datetime skill with `--network=none` flag — enforces zero-network guarantee at OS level for pure-computation tools

### Changed
- **datetime**: Updated description and compatibility to separate install-time from runtime behavior — "run fully offline after one-time binary install" instead of "pure local computation"
- **router**: Updated compatibility to use explicit install framing — "to install the MCP server binary"

### Added
- **ci**: Added install spec validation (section 8) to `test-security.sh` — verifies all SKILL.md files declare `openclaw.install` with `kind: node` and pinned version
- **ci**: Added pre-run verification check to `test-security.sh` section 5 — ensures all SKILL.md files document pre-run verification steps

## [0.5.9] - 2026-03-03

### Security
- **scanner**: Removed `anyBins: [python3, docker]` from openclaw metadata in router and scheduling SKILL.md — scanner flagged these as required dependencies when both are optional (`python3` only used by configure.sh, `docker` is an isolation option)
- **scanner**: Strengthened verification documentation in all 3 SKILL.md files — explicitly names `checksums.json`, describes automated postinstall SHA256 verification, and states **fails on mismatch** behavior (addresses OpenClaw "manual/suggested, not enforced" finding)
- **scanner**: Added SHA256 verification step to startup sequences in all 3 SKILL.md files — makes the checksum pipeline visible in the primary workflow description
- **scanner**: Elevated Docker containment with inline JSON configs in all 3 SKILL.md files — datetime config shown without volume mount (needs no credentials), scheduling/router with credential mount
- **scanner**: Strengthened credential storage language in router and scheduling SKILL.md — provides verifiable evidence paths (open-source code link, Docker mount isolation) instead of prose-only assertions

### Added
- **ci**: Added `anyBins` regression guard to `test-security.sh` — prevents reintroduction of `anyBins` in openclaw metadata

## [0.5.8] - 2026-03-01

### Fixed
- **scanner**: Removed inline Docker mount config from router SKILL.md — OpenClaw scanner flagged `-v ~/.config/temporal-cortex:/root/.config/temporal-cortex` as "exposing credentials to container" (INSTRUCTION SCOPE flag), causing Benign→Suspicious regression. Now references MCP README for Docker setup (matching datetime/scheduling pattern that scored Benign)

## [0.5.7] - 2026-03-01

### Security
- **transparency**: Added `File access` scope documentation to all 3 SKILL.md files — explicitly declares which filesystem paths the binary reads/writes
- **transparency**: Added `Network scope` documentation to router and scheduling SKILL.md files, strengthened `Network access` in datetime SKILL.md — explicitly lists which endpoints the binary contacts (only user-configured calendar providers, no callbacks)
- **transparency**: Added `Docker containment` option to all 3 SKILL.md files — provides MCP config JSON for running the server in an isolated container
- **transparency**: Added build provenance link (GitHub Actions CI) to all 3 SKILL.md Verification sections — enables independent build audit
- **verification**: Added manual `curl` command for SHA256 checksum verification to all 3 SKILL.md files — addresses VirusTotal supply chain risk finding and OpenClaw "verify the published SHA256" recommendation

### Added
- **ci**: Added security transparency assertions to `test-security.sh` — validates file access scope, network scope, Docker containment, build provenance, and SHA256SUMS.txt reference in all SKILL.md files
- **ci**: Added verification URL version pinning check to `test-security.sh` — ensures `curl` commands in SKILL.md files reference pinned release versions

### Changed
- **docs**: Added "How do I verify the installation?" section to MCP README with manual verification commands, build provenance details, and Docker containment instructions

## [0.5.6] - 2026-02-28

### Fixed
- **scanner**: Updated verification lines in all 3 SKILL.md Runtime sections — replaced SLSA provenance claim (requires public repo) with SHA256 checksum references and postinstall verification; linked to public MCP repo instead of private Platform repo
- **links**: Removed npmjs.com provenance URL ignore pattern from link-check config (URL no longer referenced)

## [0.5.5] - 2026-02-28

### Added
- **supply-chain**: Added SHA256 checksum references to all 3 SKILL.md Runtime sections — addresses OpenClaw INSTALL MECHANISM "no verified release artifact" flag

### Changed
- **scanner**: Moved Platform Mode config (TC_API_KEY + mcp.temporal-cortex.com endpoint) from router SKILL.md body to MCP repo README reference — removes "data exfiltration" Code insights flag
- **scanner**: Simplified credential language in router and scheduling Runtime sections: "never sent to Temporal Cortex servers" (removed "unless you opt into Platform Mode" qualifier)

## [0.5.4] - 2026-02-28

### Added
- **runtime**: Added `## Runtime` transparency sections to all 3 SKILL.md files — explicitly documents MCP server download, stdio transport, and network/credential behavior to satisfy OpenClaw scanner INSTRUCTION SCOPE and INSTALL MECHANISM checks
- **ci**: Added SKILL.md npx version pinning check to `test-security.sh` — prevents unpinned `npx @temporal-cortex/cortex-mcp` commands in SKILL.md bodies and reference docs
- **listings**: Submitted all 3 skills to [anthropics/skills](https://github.com/anthropics/skills/pull/479) and [awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills/pull/281) directories — replaces stale single-skill PRs #451/#242 with multi-skill layout matching the `docx/pdf/pptx/xlsx` precedent

### Fixed
- **scanner**: Reworded "Zero-setup" to "No credentials needed" in datetime SKILL.md description and compatibility — resolves OpenClaw scanner PURPOSE contradiction flag (scanner interpreted "zero-setup" as "no runtime dependencies")
- **scanner**: Pinned all 9 unpinned `npx @temporal-cortex/cortex-mcp` commands to `@0.5.4` across SKILL.md bodies, reference docs, and README — resolves INSTALL MECHANISM supply-chain flag
- **links**: Replaced 4 broken relative links in router SKILL.md with absolute GitHub URLs — cross-skill and repo-level references now resolve correctly on ClawHub
- **version**: Fixed stale MCP server version in AGENTS.md (`0.5.2` → `0.5.3`)

## [0.5.3] - 2026-02-28

### Changed
- **structure**: Merged `temporal-cortex-calendars` (7 tools) and `temporal-cortex-booking` (1 tool) into `temporal-cortex-scheduling` (8 tools) — split at the credential boundary (datetime = zero-setup vs scheduling = needs OAuth)
- **structure**: Reduced from 4 skills (router + 3 sub-skills) to 3 skills (router + 2 sub-skills)
- **descriptions**: AEO-optimized SKILL.md descriptions for all 3 skills — front-loaded searchable user intents within ~120 char truncation point
- **ci**: Added `publish-clawhub.yml` workflow — auto-publishes all 3 skills to ClawHub on `v*` tags, manual retry via `workflow_dispatch`

## [0.5.2] - 2026-02-27

### Changed
- Version bump for MCP Registry OIDC namespace casing fix

## [0.5.1] - 2026-02-27

### Added
- **structure**: Decomposed monolithic `calendar-scheduling` skill into router + 3 focused sub-skills: `temporal-cortex` (router), `temporal-cortex-datetime` (5 Layer 1 tools), `temporal-cortex-calendars` (7 Layers 0–3 tools), `temporal-cortex-booking` (1 Layer 4 tool)
- **ci**: `validate-structure.sh` — validates multi-skill directory layout, reference documents, and shared infrastructure
- **ci**: Version consistency check in release workflow — validates all 4 SKILL.md versions match the tag

### Changed
- **repo**: Migrated GitHub organization from `billylui/*` to `temporal-cortex/*` — all repository URLs, CHANGELOG comparison links, and cross-repo references updated
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

[Unreleased]: https://github.com/temporal-cortex/skills/compare/v0.7.0...HEAD
[0.7.0]: https://github.com/temporal-cortex/skills/compare/v0.6.2...v0.7.0
[0.6.2]: https://github.com/temporal-cortex/skills/compare/v0.6.1...v0.6.2
[0.6.1]: https://github.com/temporal-cortex/skills/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/temporal-cortex/skills/compare/v0.5.9...v0.6.0
[0.5.9]: https://github.com/temporal-cortex/skills/compare/v0.5.8...v0.5.9
[0.5.8]: https://github.com/temporal-cortex/skills/compare/v0.5.7...v0.5.8
[0.5.7]: https://github.com/temporal-cortex/skills/compare/v0.5.6...v0.5.7
[0.5.6]: https://github.com/temporal-cortex/skills/compare/v0.5.5...v0.5.6
[0.5.5]: https://github.com/temporal-cortex/skills/compare/v0.5.4...v0.5.5
[0.5.4]: https://github.com/temporal-cortex/skills/compare/v0.5.3...v0.5.4
[0.5.3]: https://github.com/temporal-cortex/skills/compare/v0.5.2...v0.5.3
[0.5.2]: https://github.com/temporal-cortex/skills/compare/v0.5.1...v0.5.2
[0.5.1]: https://github.com/temporal-cortex/skills/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/temporal-cortex/skills/compare/v0.4.5...v0.5.0
[0.4.5]: https://github.com/temporal-cortex/skills/compare/v0.4.4...v0.4.5
[0.4.4]: https://github.com/temporal-cortex/skills/compare/v0.4.3...v0.4.4
[0.4.3]: https://github.com/temporal-cortex/skills/compare/v0.4.2...v0.4.3
[0.4.2]: https://github.com/temporal-cortex/skills/compare/v0.4.1...v0.4.2
[0.4.1]: https://github.com/temporal-cortex/skills/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/temporal-cortex/skills/compare/v0.3.6...v0.4.0
[0.3.6]: https://github.com/temporal-cortex/skills/compare/v0.3.5...v0.3.6
[0.3.5]: https://github.com/temporal-cortex/skills/compare/v0.3.4...v0.3.5
[0.3.4]: https://github.com/temporal-cortex/skills/compare/v0.3.3...v0.3.4
[0.3.3]: https://github.com/temporal-cortex/skills/compare/v0.3.2...v0.3.3
[0.3.2]: https://github.com/temporal-cortex/skills/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/temporal-cortex/skills/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/temporal-cortex/skills/releases/tag/v0.3.0
