---
name: roadmap
description: "Manages a TLC feature through its roadmap lifecycle: naming and validating m{N}/{feature-slug} branches, renaming the opencode session to the branch, and closing out the feature by syncing ROADMAP + Mermaid /roadmap, merging main, running local bin/ci (fix-and-log failures to tmp/), opening a GitHub PR only when CI is green, then checking out the next roadmap branch. Use when creating, validating, or checking out a feature branch, deciding whether to work in a git worktree, renaming a session to its branch, or when the user says create a PR, open a PR, ship this feature, PR this, or finish with a PR on a repo that uses .specs/project/ROADMAP.md and TLC branch naming. Do NOT use for the tlc-spec-driven Specify/Design/Tasks/Execute or Verifier work itself, reviewing PRs (use pr-review), addressing review comments, fixing CI on an existing PR, or commits not meant to open a pull request."
license: CC-BY-4.0
metadata:
  author: Artur Webber
  version: 1.0.0
---

# Roadmap — the TLC feature lifecycle

A feature lives on the roadmap through a loop: branch it, work it, close it out
on the roadmap, ship it as a PR, then hand off to the next feature. This skill
owns the start and end of that loop; the work in the middle belongs to
`tlc-spec-driven`.

```
roadmap → Phase 0 (branch) → Phase 1 (work, tlc-spec-driven) → Phase 2 (close ROADMAP/Mermaid)
        → Phase 3 (merge + CI) → Phase 4 (PR) → Phase 5 (next branch) → back to Phase 0
```

## Phase 0 · Start — branch + session

Create a feature branch, then rename the session to match.

### Conventions

- **Branch pattern**: `m{N}/{feature-slug}` (e.g. `m2/agent-voice`), where `N`
  is the roadmap milestone number.
- **One feature per branch** — never mix features on a branch.
- **Base**: create feature branches from updated `main` (or the repo's default
  branch), never from another feature branch.
- **Max length**: keep the branch under 100 characters.

### How to name a branch

Never invent a branch name. Derive it from the feature's spec:

1. Resolve the milestone number `N` and the feature slug from the roadmap /
   `.specs/features/<slug>/`.
2. Normalize the slug: lowercase and trim; replace any character outside
   `a-z0-9-` with `-`; collapse runs of `-`; strip leading/trailing `-`.
3. Assemble `m{N}/{feature-slug}`.

Example: milestone 2, feature "Agent Voice" → `m2/agent-voice`.

### Validate a branch name

A valid branch:

- matches `m\d+/{feature-slug}` (milestone prefix `m`, a number, slash, slug)
- does not start with `-`, `/`, and does not end with `/`
- has no `//`, no `..`, no `@{`
- contains none of ` ~^:?*[\]` or control characters
- does not end with `.lock`

If a proposed name fails validation, fix the slug rather than bypassing the
pattern.

### Session naming

Keep the opencode session title in sync with the work in progress. After
creating or switching to a feature branch, rename the session via the
`rename_session` tool with a title that names the milestone and feature being
worked on:

- `rename_session(title: "<milestone> <feature>")` — e.g.
  `rename_session(title: "M2 agent-voice")` or `m2/agent-voice` for the raw
  branch form.
- Also rename when the task changes on an existing branch (e.g. moving from
  Specify to Execute, or picking up a different feature).

The title should let anyone reading the session list know the milestone and the
feature, matching the branch and the roadmap vocabulary.

### Worktrees

When the current session is already busy on a feature branch, do not reuse it —
start isolated work in a git worktree:

1. From the repo root, add the worktree as a sibling directory:
   `git worktree add ../<repo>-<slug> m{N}/{feature-slug}` (create the branch
   first if it does not exist).
2. Do the feature work inside the new directory.
3. When done, commit from inside the worktree, then remove it from the main
   repo: `git worktree remove <path>`. Delete the branch after it merges.

## Phase 1 · Work

The feature's Specify/Design/Tasks/Execute and the Verifier are
`tlc-spec-driven`'s job — not this skill's. Come back here when the feature is
ready to close out.

## Phase 2 · Close — sync ROADMAP (+ Mermaid /roadmap)

### 2a. Sync ROADMAP (+ STATE)

Update `.specs/project/ROADMAP.md` when status is stale: mark the feature
COMPLETE/DONE in the project's existing vocabulary; refresh milestone
Current/Status when the milestone boundary moves. Do not invent milestones or
rewrite unrelated sections.

If `.specs/STATE.md` has Handoff, refresh what shipped and the proposed next
feature (PR URL can be filled after Phase 4).

### 2b. Sync Mermaid `/roadmap`

If `app/views/roadmaps/show.html.erb` is missing → skip. Otherwise read
[references/mermaid-roadmap.md](references/mermaid-roadmap.md) and update the
hand-authored `flowchart LR` so milestones/statuses match ROADMAP. Keep the
page mermaid-panel-only.

### 2c. Commit pending work for this PR

1. `git status` / `git diff` / recent `git log`.
2. Stage and commit everything that belongs to this feature PR, including
   ROADMAP/Mermaid/STATE updates from 2a–2b. Follow the user's git commit
   protocol (HEREDOC message; no `-i`; no amend unless their amend rules allow).
3. If the worktree has clearly unrelated or sensitive files (other features,
   `.env`, credentials) → **ask** what to include; do not silently commit them.
4. Prefer atomic messages, e.g. feature commit(s) already present plus
   `docs(roadmap): mark <feature> complete and refresh /roadmap` when only docs
   changed in this step.

If the branch is already clean and ROADMAP was already accurate → continue with
no commit.

## Phase 3 · Merge + local CI gate

### 3a. Merge `origin/main`

```bash
git fetch origin
git merge origin/main
```

On conflicts: resolve and commit the merge. Never resolve by discarding the
feature's intent blindly. Local CI in 3b covers re-validation after a conflicted
merge. On failure you cannot resolve → stop; leave the branch as-is and report.

### 3b. Local CI gate (`bin/ci`)

Goal: the branch that will be pushed must pass the same local CI entrypoint the
project uses for GitHub CI parity.

1. Run full CI with the project's Ruby toolchain (AGENTS.md: `mise`):

```bash
mise exec -- bin/ci
```

If `mise` is unavailable and the environment already uses the correct Ruby,
`bin/ci` alone is acceptable — prefer `mise exec` when present.

2. **On success (exit 0):** proceed to Phase 4. Do not create or update the
   failure log.

3. **On failure:** do not push or open a PR. Enter the fix loop:

   a. **Document** — append one entry to `tmp/ci-failure-log.md` (create the
      file if missing). Never stage this file. Use this shape:

      ```markdown
      ## YYYY-MM-DD HH:MM — branch `m{N}/{slug}` — FAIL

      - Step: <CI step name from bin/ci output, e.g. "Style: Ruby" / "Tests: Rails">
      - Summary: <one-line cause>
      - Excerpt:
        ```
        <short relevant stderr/stdout; truncate aggressively>
        ```
      - Fix applied: <what you changed, or "blocked — needs human">
      ```

   b. **Fix** — address the failure surgically (rubocop, security finding,
      failing test, etc.). Commit the fix with a focused message (e.g.
      `fix: make rubocop happy before PR`).

   c. **Re-run** — `mise exec -- bin/ci` again.

   d. Repeat a–c until exit 0, or until blocked (unclear root cause, needs
      product decision, flaky infra). If blocked → stop, report the failure and
      point the user at `tmp/ci-failure-log.md`. Leave commits local; no
      push/PR.

Why the log stays uncommitted: it is a personal pattern ledger for recurring CI
pain (candidates for better linters/formatters/automation), not part of the
feature PR. `tmp/` is gitignored; still never force-add it.

## Phase 4 · Push + create PR

Follow the user's creating-pull-requests protocol: status/diff/log/
`git diff origin/main...HEAD`, push `-u` if needed, then `gh pr create` with
HEREDOC:

```markdown
## Summary
- <1–3 bullets: why this ships>

## Test plan
- [ ] Local `bin/ci` passed
- [ ] <gates / Playwright / manual checks from the feature>
```

Base: default branch (`main` unless the repo uses another). Return the PR URL.
Optionally paste the URL into STATE handoff and amend only if the user's amend
rules allow; otherwise a tiny follow-up commit is fine if they want STATE
updated — default is leave STATE with "PR opened" noted in the chat if already
committed.

## Phase 5 · Next — checkout next roadmap branch

1. Propose next work from ROADMAP (+ STATE): first PLANNED/ASAP/incomplete item
   in milestone order; slug from `.specs/features/<slug>/` when present; branch
   `m{N}/{feature-slug}` per Phase 0.
2. If two+ ASAP items or unclear → ask before checkout.
3. When clear or confirmed:

```bash
git checkout main
git pull origin main
git checkout -b m{N}/{feature-slug}
```

4. Rename the session per Phase 0 so it tracks the new milestone/feature. Tell
   the user: PR URL, new branch, next TLC step (usually Specify). Mention
   `tmp/ci-failure-log.md` only if entries were appended this run (so the user
   can skim for automation opportunities).

Branch from updated `main`, not from the just-pushed feature branch (Phase 0:
one feature per branch). The PR may still be unmerged — that is expected.

## Critical rules

1. Run only when the user asked to start/ship a roadmap feature or create/open a
   PR.
2. Read `AGENTS.md` and `.specs/project/ROADMAP.md` before any git mutation.
3. Do not mark a feature COMPLETE/DONE in ROADMAP if TLC gates are still missing
   (UI → automated gates + Playwright UAT per AGENTS.md).
4. Never force-push to `main`, never skip hooks, never commit secrets.
5. Never push or `gh pr create` until local `bin/ci` exits 0.
6. Never stage or commit `tmp/ci-failure-log.md` (or any other CI failure log
   under `tmp/`).
7. Load [references/mermaid-roadmap.md](references/mermaid-roadmap.md) only when
   Phase 2b will edit `app/views/roadmaps/show.html.erb`.

## Neighbor skills

| Skill | Relationship |
| --- | --- |
| `tlc-spec-driven` | Feature work and Verifier belong there (Phase 1). This skill only starts and ships. |
| `pr-review` | Reviews an existing PR — opposite direction. |
| Project `AGENTS.md` | Still authoritative for project gates (e.g. Playwright UAT) and local tooling (`mise`). |

## Examples

### Example 1: Happy path

User says: "create a PR"

Actions: Confirm branch `m3/agent-voice`; ROADMAP still says PLANNED → mark
COMPLETE; refresh Mermaid M3 node; commit docs; merge `origin/main`;
`mise exec -- bin/ci` green; push; `gh pr create`; propose
`m3/dynamic-prompt-suggestions`; checkout that branch from `main`; rename
session to `M3 dynamic-prompt-suggestions`.

Result: PR URL + on `m3/dynamic-prompt-suggestions` ready for Specify.

### Example 2: CI fails then fixed

User says: "ship this feature"

Actions: Phases 0–3a OK; `bin/ci` fails on `Style: Ruby`. Append entry to
`tmp/ci-failure-log.md`; fix offenses; commit `fix: rubocop before PR`; re-run
`bin/ci` green; push + create PR. Leave the log uncommitted.

Result: Green PR; user can later read `tmp/ci-failure-log.md` for recurring lint
pain.

### Example 3: Gates missing

User says: "ship this feature" on a Hotwire UI branch with no Playwright UAT in
`validation.md`.

Actions: Stop after Phase 0 identify. List missing UAT. Do not mark COMPLETE, do
not open a done PR.

Result: User runs TLC validate / Playwright first.

### Example 4: Dirty unrelated files

User says: "open a PR" with feature files plus an unrelated `.env` edit.

Actions: Sync ROADMAP/Mermaid; ask whether to include `.env` (refuse secrets);
commit feature + docs only; merge; `bin/ci`; continue PR/next branch.

Result: Clean PR without secrets.

## Troubleshooting

### Error: Verifier or Playwright UAT missing

Cause: AGENTS.md requires those gates before Complete for UI. Solution: Hand
back to `tlc-spec-driven` validate; re-run this skill after evidence exists.
Draft PR only if the user explicitly wants a WIP PR — then do not mark COMPLETE.
WIP still should not skip Phase 3b unless the user explicitly waives local CI.

### Error: `bin/ci` failing

Cause: Style, security audit, Brakeman, or tests. Solution: Append to
`tmp/ci-failure-log.md`, fix, commit, re-run. Do not push red. If blocked after a
reasonable fix attempt, stop and hand the log path to the user.

### Error: merge conflicts with origin/main

Cause: main moved. Solution: Resolve carefully; commit merge; let Phase 3b prove
green. If blocked, stop and report conflicted paths — do not force-push.

### Error: gh auth or push rejected

Cause: Missing credentials or branch protection. Solution: Stop after
explaining; leave commits local; do not invent alternate remotes.

### Error: no next roadmap item

Cause: ROADMAP has only IDEAS/research or empty queue. Solution: Open the PR
anyway (after green CI); ask the user for the next branch or stop after PR URL.

## Notes

- Branch conventions previously lived in project `AGENTS.md`; if a project
  documents its own conventions, the project rules win — update this skill only
  if you own it.
- The slug should match the feature's spec directory
  (`.specs/features/<slug>/` when present) and the roadmap vocabulary.

## Out of scope

- Implementing the next feature (`tlc-spec-driven`)
- Merging the GitHub PR
- Reviewing the PR (`pr-review`)
- Force-push, hook skips, or rewriting shared history
- Committing CI failure logs under `tmp/`
