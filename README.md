# skills

Personal agent skills for Cursor, Claude Code, and friends.

Built to sit on top of [tech-leads-club/agent-skills](https://github.com/tech-leads-club/agent-skills) (`tlc-spec-driven`, `create-adr`, `create-rfc`, …). Install those first when you need the building blocks.

## Install

```bash
npx skills add artieeez/skills -g -a cursor -a claude-code -y
```

One skill:

```bash
npx skills add artieeez/skills --skill adr-coverage -g -a cursor -y
```

## Skills

| Skill | What it does |
| --- | --- |
| [adr-coverage](skills/adr-coverage) | ADR coverage map + backlog; Design→Tasks hard-stop when gaps are missing. Hands off writing to `create-adr`. |
| [artr-platform-ops](skills/artr-platform-ops) | Diagnose the artr personal platform (Argo CD, kubectl logs/events, deploy GitHub Actions, OCI/kube reachability). Read-only by default. |

## License

CC-BY-4.0 (skill content). Validator script adapted from TLC skill-architect.
