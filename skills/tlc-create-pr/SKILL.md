---
name: tlc-create-pr
description: Closes out a TLC roadmap feature by syncing ROADMAP and Mermaid /roadmap, merging main, opening a GitHub PR, then checking out the next m{N}/feature-slug branch. Use when the user says "create a PR", "open a PR", "open pr for this", "ship this feature", "PR this", "pr it", or "finish with a PR" on a repo that uses .specs/project/ROADMAP.md and AGENTS branch naming. Do NOT use for reviewing PRs (use pr-review), addressing review comments, fixing CI on an existing PR, or commits that are not meant to open a pull request.
license: CC-BY-4.0
metadata:
  author: Artur Webber
  version: 1.1.0
---

# TLC Create PR

Sequential handoff after `tlc-spec-driven` Execute: keep ROADMAP honest, open the PR, land on the next roadmap branch. Does not replace Specify/Design/Tasks/Execute or the Verifier.

## Neighbor skills

| Skill | Relationship |
| --- | --- |
| `tlc-spec-driven` | Feature work and Verifier belong there. This skill only ships and hands off. |
| `pr-review` | Reviews an existing PR — opposite direction. |
| Project `AGENTS.md` | Authoritative for `m{N}/{feature-slug}`, Playwright UAT, and local Ruby (`mise`). |

## Critical rules

1. Run only when the user asked to create/open/ship a PR.
2. Read `AGENTS.md` and `.specs/project/ROADMAP.md` before any git mutation.
3. Do not mark a feature COMPLETE/DONE in ROADMAP if TLC gates are still missing (UI → automated gates + Playwright UAT per AGENTS.md).
4. Never force-push to `main`, never skip hooks, never commit secrets.
5. Load [references/mermaid-roadmap.md](references/mermaid-roadmap.md) only when step 2 will edit `app/views/roadmaps/show.html.erb`.

## Workflow

Track this checklist:

```
TLC Create PR:
- [ ] 0. Identify feature + gate check
- [ ] 1. Sync ROADMAP (+ STATE handoff)
- [ ] 2. Sync Mermaid /roadmap (if present)
- [ ] 3. Commit pending work for this PR
- [ ] 4. Merge origin/main into current branch
- [ ] 5. Push + create PR
- [ ] 6. Checkout next roadmap branch
```

### 0. Identify feature + gate check

Validation: know the feature slug and that completion claims are honest.

1. Resolve feature from branch name (`m{N}/{slug}`), `.specs/features/<slug>/`, and STATE handoff.
2. If the user (or you) would mark it Complete and the surface is browser UI: confirm Verifier/Playwright evidence exists (e.g. `validation.md`). If missing → **stop**, list what’s missing, do not open a “done” PR.

On failure: stop and report. Do not merge or push yet.

### 1. Sync ROADMAP (+ STATE)

Depends on: step 0 passed.

Update `.specs/project/ROADMAP.md` when status is stale: mark the feature COMPLETE/DONE in the project’s existing vocabulary; refresh milestone Current/Status when the milestone boundary moves. Do not invent milestones or rewrite unrelated sections.

If `.specs/project/STATE.md` or `.specs/STATE.md` has Handoff, refresh what shipped and the proposed next feature (PR URL can be filled after step 5).

### 2. Sync Mermaid `/roadmap`

Depends on: step 1 (ROADMAP is source of truth for statuses).

If `app/views/roadmaps/show.html.erb` is missing → skip. Otherwise read [references/mermaid-roadmap.md](references/mermaid-roadmap.md) and update the hand-authored `flowchart LR` so milestones/statuses match ROADMAP. Keep the page mermaid-panel-only.

### 3. Commit pending work for this PR

Depends on: steps 1–2 done (or skipped as no-ops).

1. `git status` / `git diff` / recent `git log`.
2. Stage and commit everything that belongs to this feature PR, including ROADMAP/Mermaid/STATE updates from steps 1–2. Follow the user’s git commit protocol (HEREDOC message; no `-i`; no amend unless their amend rules allow).
3. If the worktree has clearly unrelated or sensitive files (other features, `.env`, credentials) → **ask** what to include; do not silently commit them.
4. Prefer atomic messages, e.g. feature commit(s) already present plus `docs(roadmap): mark <feature> complete and refresh /roadmap` when only docs changed in this step.

If the branch is already clean and ROADMAP was already accurate → continue with no commit.

### 4. Merge `origin/main`

Depends on: step 3 complete (clean commit state for the PR).

```bash
git fetch origin
git merge origin/main
```

On conflicts: resolve, re-run the project’s relevant tests if code conflicted, commit the merge. Never resolve by discarding the feature’s intent blindly.

On failure you cannot resolve → stop; leave the branch as-is and report.

### 5. Push + create PR

Depends on: merge succeeded.

Follow the user’s creating-pull-requests protocol: status/diff/log/`git diff origin/main...HEAD`, push `-u` if needed, then `gh pr create` with HEREDOC:

```markdown
## Summary
- <1–3 bullets: why this ships>

## Test plan
- [ ] <gates / Playwright / manual checks from the feature>
```

Base: default branch (`main` unless the repo uses another). Return the PR URL. Optionally paste the URL into STATE handoff and amend only if the user’s amend rules allow; otherwise a tiny follow-up commit is fine if they want STATE updated — default is leave STATE with “PR opened” noted in the chat if already committed.

### 6. Checkout next roadmap branch

Depends on: PR URL returned.

1. Propose next work from ROADMAP (+ STATE): first PLANNED/ASAP/incomplete item in milestone order; slug from `.specs/features/<slug>/` when present; branch `m{N}/{feature-slug}` per AGENTS.md.
2. If two+ ASAP items or unclear → ask before checkout.
3. When clear or confirmed:

```bash
git checkout main
git pull origin main
git checkout -b m{N}/{feature-slug}
```

4. Tell the user: PR URL, new branch, next TLC step (usually Specify).

Branch from updated `main`, not from the just-pushed feature branch (AGENTS.md: one feature per branch). The PR may still be unmerged — that is expected.

## Examples

### Example 1: Happy path

User says: "create a PR"

Actions: Confirm branch `m3/agent-voice`; ROADMAP still says PLANNED → mark COMPLETE; refresh Mermaid M3 node; commit docs; merge `origin/main`; push; `gh pr create`; propose `m3/dynamic-prompt-suggestions`; checkout that branch from `main`.

Result: PR URL + on `m3/dynamic-prompt-suggestions` ready for Specify.

### Example 2: Gates missing

User says: "ship this feature" on a Hotwire UI branch with no Playwright UAT in `validation.md`.

Actions: Stop after step 0. List missing UAT. Do not mark COMPLETE, do not open a done PR.

Result: User runs TLC validate / Playwright first.

### Example 3: Dirty unrelated files

User says: "open a PR" with feature files plus an unrelated `.env` edit.

Actions: Sync ROADMAP/Mermaid; ask whether to include `.env` (refuse secrets); commit feature + docs only; continue merge/PR/next branch.

Result: Clean PR without secrets.

## Troubleshooting

### Error: Verifier or Playwright UAT missing

Cause: AGENTS.md requires those gates before Complete for UI. Solution: Hand back to `tlc-spec-driven` validate; re-run this skill after evidence exists. Draft PR only if the user explicitly wants a WIP PR — then do not mark COMPLETE.

### Error: merge conflicts with origin/main

Cause: main moved. Solution: Resolve carefully; run tests; commit merge. If blocked, stop and report conflicted paths — do not force-push.

### Error: gh auth or push rejected

Cause: Missing credentials or branch protection. Solution: Stop after explaining; leave commits local; do not invent alternate remotes.

### Error: no next roadmap item

Cause: ROADMAP has only IDEAS/research or empty queue. Solution: Open the PR anyway; ask the user for the next branch or stop after PR URL.

## Out of scope

- Implementing the next feature (`tlc-spec-driven`)
- Merging the GitHub PR
- Reviewing the PR (`pr-review`)
- Force-push, hook skips, or rewriting shared history
