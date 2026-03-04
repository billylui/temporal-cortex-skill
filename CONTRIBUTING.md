# Contributing to Temporal Cortex Skills

Thank you for your interest in contributing to the Temporal Cortex Agent Skills.

## About This Repo

This is a **documentation and configuration** repository. It contains the Temporal Cortex Agent Skills (router + 2 sub-skills) — SKILL.md files, reference documents, presets, and scripts. The MCP server source code is maintained separately in [temporal-cortex/mcp](https://github.com/temporal-cortex/mcp).

## Getting Started

1. Fork the repository
2. Clone your fork locally
3. Create a branch for your changes: `git checkout -b docs/your-change`
4. Make your changes following the guidelines below
5. Push to your fork and submit a pull request

## How to Contribute

### Bug Reports

Found a bug in the skill? Search [existing issues](https://github.com/temporal-cortex/skills/issues) first. If not found, [open a new issue](https://github.com/temporal-cortex/skills/issues/new?template=bug_report.yml).

For MCP server bugs, report at [temporal-cortex-mcp](https://github.com/temporal-cortex/mcp/issues).

### Feature Requests

Have an idea? [Open an issue](https://github.com/temporal-cortex/skills/issues/new?template=feature_request.yml) describing your use case.

### Skill Improvements

- Changes to SKILL.md or reference documents
- New presets in `assets/presets/`
- Script improvements in `scripts/`

## Guidelines

- Keep SKILL.md body under 500 lines (Agent Skills spec requirement)
- Keep reference documents focused and under 300 lines each
- All JSON files must be valid (CI validates this)
- All shell scripts must pass ShellCheck
- Use `#!/usr/bin/env bash` shebang in all scripts
- Test changes locally before submitting:

```bash
bash tests/validate-skill.sh
bash tests/validate-structure.sh
```

## Commit Messages

Use clear, descriptive commit messages with conventional prefixes:

- `docs: improve RRULE edge case examples`
- `fix: correct broken link in TOOL-REFERENCE.md`
- `feat: add healthcare-scheduler preset`
- `chore: update CI workflow action versions`

## Agent Skills Specification

This skill follows the [Agent Skills specification](https://agentskills.io/specification). Key constraints:

- `name` field: lowercase, hyphens only, ≤ 64 characters, must match directory name
- `description` field: ≤ 1024 characters
- Body: < 500 lines, optimized for progressive disclosure

## Code of Conduct

This project follows the [Contributor Covenant v2.1](https://www.contributor-covenant.org/version/2/1/code_of_conduct/). See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## License

By contributing, you agree that your contributions will be licensed under the MIT license terms of this project.
