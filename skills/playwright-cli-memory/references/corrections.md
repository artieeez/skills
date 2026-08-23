# playwright-cli corrections (append-only)

Learned corrections for the `playwright-cli` tool. Append new entries at the end. Never edit or delete older entries.

## screenshot: filename is an option, not a positional argument

- **Wrong:** `playwright-cli screenshot /tmp/shot.png`
- **Right:** `playwright-cli screenshot --filename /tmp/shot.png --full-page`
- **Note:** defaults to page-{timestamp}.png in cwd if --filename omitted. Also: --hires for device pixels.

## snapshot: element refs are per-snapshot

- **Wrong:** clicking a ref from an old snapshot after the page changed
- **Right:** run `playwright-cli snapshot` again before `click <ref>`
- **Note:** refs (e.g. e16) are only valid for the snapshot they appeared in. After navigation (goto/open/click) refs change.

## open and goto: --json result shape

- **Wrong:** expecting `result.url` / `result.title` in the JSON output
- **Right:** `playwright-cli --json goto <url>` returns only `{"snapshot": {"file": "..."}}`; open returns `{"session","pid","result":{"snapshot":{"file"}}}`
- **Note:** URL and title appear only in the human-readable (non-json) output under "Page URL:" / "Page Title:". Use `--raw` for just the value.

## open: browser must be open before other commands

- **Wrong:** running goto/click/snapshot without an open browser → "Browser 'default' is not open."
- **Right:** `playwright-cli open <url>` first (session persists across commands until `close`)
- **Note:** the default session is named 'default'; `close` ends it.

## close: idempotent-ish

- **Wrong:** assuming close errors when already closed
- **Right:** `playwright-cli close` prints "Browser 'default' closed" when open, "Browser 'default' is not open." when not — either is fine.
