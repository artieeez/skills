---
name: principle-tradeoffs
description: Reframes design and architecture option sets as software-engineering principles and tradeoffs (e.g. events vs blob, queryability vs schema cost, time-as-first-class vs snapshot). Use when the user asks to explain options, what principles are in play, higher-level rationale before choosing, why approaches differ, or "I don't get A/B/C". Do NOT use for implementing features, writing TLC specs/designs, auto-running whenever TLC lists approaches, grilling ideas (use the-fool/grilling), or picking an option for the user without asking.
license: CC-BY-4.0
metadata:
  author: Artur Webber
  version: 1.0.0
---

# Principle Tradeoffs

When options are framed as concrete solutions, reframe them as architecture principles and tradeoffs so the owner can choose with understanding. Only run when the user asks to explain — never auto-trigger on TLC approach dumps.

## Neighbor skills

| Skill | Relationship |
| --- | --- |
| `tlc-spec-driven` | Often the source of A/B/C. This skill explains; it does not replace Specify/Design or write `design.md`. |
| `the-fool` / `grilling` | Challenge/stress-test ideas. This skill clarifies dimensions; it does not red-team. |
| `create-adr` / `adr-coverage` | After a choice is made and ADR-worthy, those skills record it. |

## Critical rules

1. **Opt-in only.** If the user did not ask to explain principles/tradeoffs/options, do not load this workflow.
2. **Principles before implementations.** Lead with the engineering dimension in play; map options onto it; then show gain/give-up.
3. **Do not decide for them.** End by asking which option (or hybrid) they want. A recommendation is allowed only as a labeled gut check, not a silent pick.
4. **Same scope.** Do not invent new product scope while explaining. If an option changes WHAT to build, flag it as scope creep and stay on HOW.
5. **Match depth.** Default = medium. If they say `shorter` or `deeper`, adjust.

## Depth modes

| Mode | When | Shape |
| --- | --- | --- |
| **Medium (default)** | Unspecified | Dimension → map options → gain/give-up table → gut check → ask to pick |
| **Shorter** | User says shorter / tl;dr | One sentence naming the dimension + one line per option |
| **Deeper** | User says deeper / teach me | Medium + failure modes, evolution cost, and when the “simple” option becomes painful |

## Workflow

### 1. Restate the decision in one sentence

Ignore solution jargon first. Name what is actually being chosen (storage shape, consistency model, coupling boundary, sync vs async, etc.).

Expected output: one plain sentence, e.g. “This is about how you store facts that happen over time.”

### 2. Name the principle dimension(s)

Pick 1–3 dimensions that actually differ across the options. Prefer durable SE vocabulary over feature nouns.

Common lenses (use only what applies; do not dump the whole list):

| Lens | Typical tension |
| --- | --- |
| Events vs snapshot/blob | Time/history first-class vs “current document” |
| Queryability vs write simplicity | Rows/indexes vs one JSON dump |
| Schema cost vs flexibility | Migrations/associations vs fewer lines now |
| Coupling vs duplication | Shared abstraction vs copy-paste locality |
| Consistency vs availability / latency | Strong sync vs eventual / async |
| Explicit vs convention | Named types/records vs implicit shape in code |
| Present cost vs future-proofing | Ship faster vs cheaper to evolve later |
| Runtime product path vs operator/dev path | What Visitors hit vs what only you run locally |

Expected output: a short “principles in play” list with one line each.

### 3. Map each option onto those dimensions

For every Approach A/B/C (or equivalent), say what it optimizes and what it treats as secondary — in principle language, not file paths.

### 4. Gain / give-up table

Compact markdown table: option × what you gain × what you give up. No more than one idea per cell.

### 5. Gut check (optional recommendation)

2–4 lines: “Pick A if … / B if …”. If you recommend one, label it clearly and keep the ask open.

### 6. Stop and ask

Ask them to pick (A/B/C/hybrid/tweak). Do not proceed to write `design.md` or implement unless they already asked for that in the same message.

## Output shape (medium)

```markdown
The tradeoffs are really about **[dimension]**, not about [feature jargon].

### Principles in play
1. **[Principle]** — [one line]
2. …

### How to read the options
| | What you optimize for | What you give up |
| --- | --- | --- |
| **A** | … | … |
| **B** | … | … |

### Gut check
- Pick **A** if …
- Pick **B** if …

Which do you want (or any tweak)?
```

## Examples

### Example 1: TLC storage approaches (events vs blob)

User says: "what engineering principles are in play on those options?"

Actions:

1. Restate: choosing how to store facts over time for tool traces.
2. Principles: events vs blob; queryability vs schema cost; present simplicity vs future-proofing.
3. Table mapping A (records) / B (JSON columns) / C (hybrid).
4. Gut check; ask them to pick.

Result: explanation like “tool calls are a sequence of events; rows make history first-class; JSON is fewer lines but weaker to query later” — then stop for their choice.

### Example 2: User wants shorter

User says: "shorter — why not just JSON?"

Actions: one sentence dimension + one line per option; skip long lens catalog.

### Example 3: Must NOT run

User is mid-TLC Design and the agent listed Approach A/B/C. User did not ask to explain.

Actions: do nothing with this skill. Continue Design only if they are choosing or asked for the full design doc.

## Anti-patterns

- ❌ Re-listing implementation details (table names, file paths) without naming the principle
- ❌ Auto-explaining every TLC fork when the user did not ask
- ❌ Choosing the approach and writing `design.md` in the same turn without confirmation
- ❌ Turning the explain into a new feature proposal
- ❌ Wall of textbook principles that do not differ across the actual options

## Troubleshooting

### Options are not actually different on principles

Cause: A/B/C are the same architecture with cosmetic naming.
Solution: Say so plainly; collapse to one approach and ask whether to proceed with that.

### User still wants concrete solutions

Cause: Principles clicked; they need the mapping back.
Solution: After they pick the principle side, map it back to the concrete approach in 3–5 lines — still do not implement unless asked.
