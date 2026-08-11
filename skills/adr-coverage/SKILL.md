---
name: adr-coverage
description: Audits ADR coverage and maintains an ADR backlog so architecture decisions are not lost during feature work. Use when the user says "ADR coverage", "are we missing ADRs", "init ADR coverage", "ADR backlog", "register ADR gap", or during TLC Design, PRD, or TDD work when architectural choices appear. Maps decisions covered by ADRs, covered by installed skills, and ADR-worthy gaps; hard-stops Design to Tasks until gaps are registered in docs/adr/BACKLOG.md. After create-adr saves a file, refreshes the coverage report and closes matching backlog rows. Do NOT use to write ADRs (use create-adr), to drive undecided proposals (use create-rfc), for implementation plans (use technical-design-doc-creator), or to modify tlc-spec-driven.
license: CC-BY-4.0
metadata:
  author: Artur Webber
  version: 1.0.0
---

# ADR Coverage

Gatekeeper for architecture decisions: audit coverage, register ADR-worthy gaps, hard-stop TLC Design→Tasks until gaps are on the backlog. Never writes ADRs — hand off to `create-adr`.

## Neighbor skills

| Skill | Relationship |
| --- | --- |
| `create-adr` | Writer. Coverage registers gaps and refreshes after an ADR file is saved. |
| `create-rfc` | Use when the decision is not made yet; still register the gap as `needs-rfc` if ADR-worthy. |
| `tlc-spec-driven` | Do not modify. When this skill is loaded during Design, run the Design hard-stop before moving to Tasks. |
| `technical-design-doc-creator` | When a TDD introduces stack/boundary choices, run a coverage scan and register gaps. |
| Domain skills (e.g. `rails-dev`) | Decisions fully owned by an installed skill are **not** ADR-worthy. |

## Paths (layout C)

```
docs/adr/
├── NNN-….md                 # Accepted ADRs (create-adr owns these)
├── BACKLOG.md               # TRACKED — ADR-worthy queue
└── .coverage/               # GITIGNORED — report cache
    ├── report.md
    ├── skills-snapshot.md
    └── meta.json
```

If `docs/adr/` does not exist and the user asks for a report or Design gate, run **Init** first.

Read `references/backlog-schema.md` before creating or editing `BACKLOG.md` or report files. Read `references/classify.md` before classifying any decision.

---

## Commands

### Init

When the user says "init ADR coverage" or coverage paths are missing:

1. Run `scripts/init_coverage.sh` from the repo root (creates dirs, gitignore entries, seeds `BACKLOG.md` if absent).
2. Create a new branch (e.g. `chore/adr-coverage-init`).
3. Stage only: `.gitignore` changes and `docs/adr/BACKLOG.md` (never stage `docs/adr/.coverage/`).
4. Commit and open a PR. Suggest message: `chore(adr): initialize ADR coverage backlog and gitignore cache`.
5. Stop. Do not invent backlog items during init.

**On failure:** If `docs/adr/` cannot be created (permissions / not a git repo), stop and report. Do not write cache files elsewhere.

### Report

When the user asks for coverage / "are we missing ADRs" / after Design scan / after `create-adr`:

1. Ensure init has been done (`.coverage/` exists or run Init).
2. Collect sources:
   - All `docs/adr/*.md` except `BACKLOG.md`
   - `.specs/STATE.md` Decisions (if present)
   - Feature `design.md` / `context.md` / TDD / PRD paths in the current conversation
   - Installed skills: scan `~/.cursor/skills/*/SKILL.md` (and project `.cursor/skills` / `.claude/skills` if present). Snapshot names + one-line purpose into `.coverage/skills-snapshot.md`
3. Classify each candidate per `references/classify.md` into exactly one bucket:
   - **Covered by ADR**
   - **Covered by skill**
   - **ADR-worthy gap**
   - **STATE/polish only** (not ADR material — list briefly, do not backlog)
4. Write `.coverage/report.md` using the schema in `references/backlog-schema.md`.
5. Write `.coverage/meta.json` with `generated_at` (ISO-8601), `sources` (paths), `adr_count`, `gap_count`, `skill_covered_count`.
6. Present a short summary to the user (three buckets). Prefer a canvas when the map is non-trivial; otherwise markdown.

**Never commit** `.coverage/` files.

### Register

When Design (or PRD/TDD) surfaces an ADR-worthy gap:

1. Append a row to `docs/adr/BACKLOG.md` per schema (id `GAP-NNN`, status `open` or `needs-rfc`).
2. Deduplicate: if the same decision title/slug already exists, update the existing row’s `sources` instead of adding a duplicate.
3. Refresh the report (Report steps 4–6).
4. Tell the user the gap id and that `create-adr` can close it later.

### Design hard-stop (mandatory)

When this skill is active and the conversation is finishing **TLC Design** (or the user asks to move Design → Tasks):

1. Run Report against the feature’s design/context + STATE Decisions.
2. For every **ADR-worthy** item not already on `BACKLOG.md` with status `open`, `needs-rfc`, `deferred`, or `resolved`: **Register** it.
3. If any ADR-worthy item for this feature is still unregistered after step 2, **HARD STOP**:
   - Do not start Tasks or Execute.
   - List the items and required action: register (done by this skill) or user confirms “not ADR-worthy” (reclassify and document in report).
4. Once every ADR-worthy item for this feature appears on the backlog, allow Design to complete. Do **not** require the ADR file to exist before Tasks (that is Design-only registration). Writing the ADR is a later `create-adr` step.

### After create-adr (auto-refresh)

When an ADR file is saved under `docs/adr/NNN-*.md` in this conversation (or the user says the ADR was just created):

1. Match backlog rows by title slug, explicit `adr` field, or close wording.
2. Set matched rows to `resolved`, set `adr` to the file path / `ADR-NNN`.
3. Run Report and show the updated map.
4. If no backlog row matches, still refresh the report; mention the unmatched ADR so the user can link it.

---

## Classification rules (summary)

Full rules: `references/classify.md`.

- Stack, auth boundary, persistence, public HTTP surface, cutover strategy → usually **ADR-worthy** unless an ADR already exists.
- Conventions fully specified by an installed skill (e.g. rails-dev state-as-records, Solid Queue, webhook inbox) → **Covered by skill**, not a gap.
- UI polish, session TTL tweaks, one-off implementation shapes → **STATE/polish only**.
- Undecided direction → register as `needs-rfc`, then use `create-rfc` — do not call `create-adr` yet.

---

## Examples

### Example 1: Init

User: "Init ADR coverage in this repo"

Actions: run `scripts/init_coverage.sh` → branch → commit gitignore + `BACKLOG.md` → `gh pr create`

Result: PR with tracked backlog stub; `.coverage/` gitignored and empty until first report.

### Example 2: Design hard-stop

User: finishing Design for a feature that introduces a new public webhook provider

Actions: classify → gap "Public Acme webhooks outside session auth" not in backlog → register `GAP-003` → report refreshed → allow Design to complete only after registration

Result: Tasks may start; ADR still pending on backlog for `create-adr`.

### Example 3: After create-adr

User: "Write an ADR for big-bang cutover" → `create-adr` saves `docs/adr/0005-big-bang-cutover.md`

Actions: set `GAP-001` → `resolved`, `adr: ADR-005` → refresh report

Result: gap closed; report shows decision under Covered by ADR.

---

## Troubleshooting

### Coverage paths missing

Cause: Init never run.
Solution: Run Init (script + PR). Do not invent an alternate cache root.

### False ADR-worthy gaps for skill conventions

Cause: Classifier ignored installed skills.
Solution: Re-read `skills-snapshot.md` and `references/classify.md`; move item to Covered by skill; remove from backlog if mistakenly added.

### Hard-stop feels stuck

Cause: Item is polish misclassified as ADR-worthy, or user refuses backlog.
Solution: User may reclassify as STATE-only (update report). Do not silently skip. Explicit user override: "defer GAP-NNN" sets status `deferred` and unblocks Design.

### create-adr saved but backlog still open

Cause: Title mismatch.
Solution: Manually set `adr` + `resolved` on the row, then refresh.

---

## Anti-patterns

- Writing ADR bodies in this skill
- Patching `tlc-spec-driven`
- Committing `.coverage/`
- Treating skill-owned conventions as ADR gaps
- Hard-stopping Execute (Design only)
- Blocking Design until the ADR file exists (registration is enough)
