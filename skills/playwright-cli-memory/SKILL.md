---
name: playwright-cli-memory
description: Append-only syntax memory for playwright-cli. Read references/corrections.md before using playwright-cli; append a correction on any syntax error or --help lookup. Triggers on playwright-cli browser automation (open, snapshot, click, screenshot). Not for npx playwright test, test files, or MCP.
license: CC-BY-4.0
metadata:
  author: Artur Webber
  version: 1.0.0
---

# playwright-cli memory

Append-only correction log for the `playwright-cli` browser automation tool. The purpose is to never repeat a syntax mistake: every time you get a command wrong or consult `--help`, you record the correct usage here.

## Instructions

### Step 1: Read the memory before using playwright-cli

Before your first `playwright-cli` command in any session, read `references/corrections.md` in full. It is small by design. Skip only when you are confident the command is already in the file.

### Step 2: Append a correction on every failure or --help lookup

Whenever a `playwright-cli` command fails with a syntax/usage error, or whenever you run `playwright-cli --help <command>` to discover the right syntax, append a new entry to `references/corrections.md` before retrying. Do not proceed without recording it — the whole point is that the next session learns from it.

### Step 3: Use the entry format

Each entry must be one block, appended at the end of the file:

```markdown
## <command>: <what the gotcha is>

- **Wrong:** <the failing invocation or wrong assumption>
- **Right:** <the correct invocation>
- **Note:** <why / when it matters, one line>
```

Rules:
- Append only. Never edit or delete older entries.
- One gotcha per entry. Keep each line short.
- Use real command syntax from `--help` or successful runs — no guessing.

## Examples

### Example 1: screenshot filename

User says: take a screenshot of the page.
Agent runs `playwright-cli screenshot /tmp/shot.png` → error.
Agent runs `playwright-cli --help screenshot`, discovers `--filename` is an option, not a positional arg. Appends:

```markdown
## screenshot: filename is an option, not a positional argument

- **Wrong:** `playwright-cli screenshot /tmp/shot.png`
- **Right:** `playwright-cli screenshot --filename /tmp/shot.png --full-page`
- **Note:** defaults to page-{timestamp}.png in cwd if --filename omitted.
```

### Example 2: stale element refs

User says: click the Learn more link.
Agent clicks a ref captured before navigation → "Ref not found in the current page snapshot". Agent re-runs `snapshot`, gets new refs, clicks successfully, then appends:

```markdown
## snapshot: element refs are per-snapshot

- **Wrong:** clicking a ref from an old snapshot after the page changed
- **Right:** run `playwright-cli snapshot` again before `click <ref>`
- **Note:** refs (e.g. e16) are only valid for the snapshot they appeared in.
```

## Troubleshooting

### The skill itself fails to help

Cause: the correction you need isn't recorded yet.
Solution: run `playwright-cli --help <command>` (or `playwright-cli --help` for the full list), verify with a real invocation, then append the entry per Step 3.
