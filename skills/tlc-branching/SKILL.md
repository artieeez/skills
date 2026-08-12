---
name: tlc-branching
description: Branching conventions and worktree workflow for tlc-spec-driven features: create, validate, and check out m{N}/{feature-slug} branches, decide whether to work in a git worktree, and keep the session name in sync with the branch. Use when creating, validating, or checking out a feature branch, choosing between worktree and in-repo work, or renaming the session to its branch. Do NOT use for general git tasks, branch names outside the m{N}/{feature-slug} convention, or the tlc-spec-driven Specify/Design/Tasks/Execute workflow itself.
license: CC-BY-4.0
metadata:
  author: Artur Webber
  version: 1.0.0
---

# TLC Branching

Branching conventions for `tlc-spec-driven` features. Keep branch names
consistent, safe, and traceable to the roadmap milestone and the feature spec.

## Conventions

- **Branch pattern**: `m{N}/{feature-slug}` (e.g. `m2/agent-voice`), where `N`
  is the roadmap milestone number.
- **One feature per branch** — never mix features on a branch.
- **Base**: create feature branches from updated `main` (or the repo's default
  branch), never from another feature branch.
- **Max length**: keep the branch under 100 characters.

## How to name a branch

Never invent a branch name. Derive it from the feature's spec:

1. Resolve the milestone number `N` and the feature slug from the roadmap /
   `.specs/features/<slug>/`.
2. Normalize the slug: lowercase and trim; replace any character outside
   `a-z0-9-` with `-`; collapse runs of `-`; strip leading/trailing `-`.
3. Assemble `m{N}/{feature-slug}`.

Example: milestone 2, feature "Agent Voice" → `m2/agent-voice`.

## Validate a branch name

A valid branch:

- matches `m\d+/{feature-slug}` (milestone prefix `m`, a number, slash, slug)
- does not start with `-`, `/`, and does not end with `/`
- has no `//`, no `..`, no `@{`
- contains none of ` ~^:?*[\]` or control characters
- does not end with `.lock`

If a proposed name fails validation, fix the slug rather than bypassing the
pattern.

## Worktrees

When the current session is already busy on a feature branch, do not reuse it —
start isolated work in a git worktree:

1. From the repo root, add the worktree as a sibling directory:
   `git worktree add ../<repo>-<slug> m{N}/{feature-slug}` (create the branch
   first if it does not exist).
2. Do the feature work inside the new directory.
3. When done, commit from inside the worktree, then remove it from the main
   repo: `git worktree remove <path>`. Delete the branch after it merges.

## Session naming

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

## Notes

- Branch conventions previously lived in project `AGENTS.md`; if a project
  documents its own conventions, the project rules win — update this skill only
  if you own it.
- The slug should match the feature's spec directory
  (`.specs/features/<slug>/` when present) and the roadmap vocabulary.
