# Backlog and report schemas

Use these shapes exactly so agents and humans can parse coverage state across sessions.

## `docs/adr/BACKLOG.md` (tracked)

Seed (init):

```markdown
# ADR backlog

Open architecture decisions that need an ADR (or RFC first). Managed by the `adr-coverage` skill. ADRs themselves are written with `create-adr`.

| ID | Title | Status | Priority | Sources | ADR | Notes |
| --- | --- | --- | --- | --- | --- | --- |
```

### Status values

| Status | Meaning |
| --- | --- |
| `open` | Decision made (or nearly made); needs `create-adr` |
| `needs-rfc` | Decision not made; use `create-rfc` before ADR |
| `deferred` | Explicitly postponed; Design hard-stop treats as registered |
| `resolved` | ADR exists; `ADR` column points at it |
| `rejected` | Not ADR-worthy after review; keep row for audit trail |

### Priority

`high` | `medium` | `low` — based on whether reversing the decision forces a redesign.

### ID

`GAP-001`, `GAP-002`, … zero-padded to three digits. Never reuse IDs.

### Sources

Short paths or feature slugs, comma-separated (e.g. `.specs/features/foo/design.md`, `STATE AD-003`).

### ADR column

Empty while open; set to `ADR-NNN` (`docs/adr/NNN-….md`) when resolved.

---

## `docs/adr/.coverage/report.md` (gitignored)

```markdown
# ADR coverage report

Generated: {ISO-8601}

## Covered by ADRs

| ADR | Title | Topics |
| --- | --- | --- |
| ADR-001 | … | … |

## Covered by installed skills

| Skill | Decision / convention | Why not an ADR |
| --- | --- | --- |
| rails-dev | … | … |

## ADR-worthy gaps

| Gap | Title | Status | Priority | In backlog |
| --- | --- | --- | --- | --- |
| GAP-001 | … | open | medium | yes |

## STATE / polish only (not backlogged)

| Decision | Source | Why not ADR |
| --- | --- | --- |
| … | … | … |
```

Omit a section only if it has zero rows (except always keep the four headings for stable diffs in the cache).

---

## `docs/adr/.coverage/skills-snapshot.md` (gitignored)

```markdown
# Skills snapshot

Generated: {ISO-8601}

| Skill | Path | One-line purpose |
| --- | --- | --- |
| create-adr | ~/.cursor/skills/create-adr | Writes ADR markdown |
```

---

## `docs/adr/.coverage/meta.json` (gitignored)

```json
{
  "generated_at": "2026-08-01T15:12:00-03:00",
  "sources": ["docs/adr/", ".specs/STATE.md"],
  "adr_count": 4,
  "gap_count": 1,
  "skill_covered_count": 3,
  "backlog_open_count": 1
}
```
