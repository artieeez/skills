---
name: lighthouse-chrome-memory
description: Append-only syntax memory for Lighthouse (lighthouse / lhci CLIs) and headless Chrome CLI usage. Read references/corrections.md before running lighthouse, lhci, or chrome --headless commands; append a correction on any syntax error or --help lookup. Triggers on lighthouse audits, web-vitals measurement, lhci collect/assert/upload, and headless Chrome flags (--dump-dom, --screenshot, --print-to-pdf, --remote-debugging-port). Not for the CrUX API, web-vitals in-page library, or non-headless GUI Chrome.
license: CC-BY-4.0
metadata:
  author: Artur Webber
  version: 1.0.0
---

# lighthouse-chrome memory

Append-only correction log for the `lighthouse` / `lhci` CLIs and headless `Google Chrome` CLI. The purpose is to never repeat a syntax mistake: every time you get a command wrong or consult `--help`, you record the correct usage here.

## Instructions

### Step 1: Read the memory before using lighthouse or headless Chrome

Before your first `lighthouse`, `lhci`, or `chrome --headless` command in any session, read `references/corrections.md` in full. It is small by design. Skip only when you are confident the command is already in the file.

### Step 2: Append a correction on every failure or --help lookup

Whenever a `lighthouse` / `lhci` / `chrome --headless` command fails with a syntax/usage error, or whenever you run `--help` to discover the right syntax, append a new entry to `references/corrections.md` before retrying. Do not proceed without recording it — the whole point is that the next session learns from it.

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

### Example 1: Lighthouse output format

User says: audit the homepage and show me the score.
Agent runs `lighthouse http://localhost:3000` and gets an HTML report file, not numbers it can read. Agent runs `lighthouse --help`, sees `--output [default: ["html"]]`, then appends:

```markdown
## lighthouse: default output is HTML, not JSON

- **Wrong:** `lighthouse http://localhost:3000` expecting JSON on stdout
- **Right:** `lighthouse http://localhost:3000 --output=json` (JSON defaults to stdout; add `--output-path=./report.json` to write a file)
- **Note:** help shows `--output [array] [default: ["html"]]`; HTML/CSV default to a dated file in cwd, JSON defaults to stdout.
```

### Example 2: Chrome binary lookup

User says: run a Lighthouse audit.
Agent runs `which lighthouse` → found; but a bare `chrome` lookup fails. Agent verifies the binary path, then appends:

```markdown
## chrome: binary path on macOS

- **Wrong:** assuming `chrome` is on PATH
- **Right:** `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome` (or set `CHROME_PATH` for Lighthouse)
- **Note:** on macOS the app binary is not on PATH; Lighthouse discovers it automatically but `CHROME_PATH` overrides.
```

## Troubleshooting

### The skill itself fails to help

Cause: the correction you need isn't recorded yet.
Solution: run `lighthouse --help`, `lhci --help`, or `chrome --headless=new --help` (as applicable), verify with a real invocation, then append the entry per Step 3.
