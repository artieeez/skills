# Classification rules

Read this before labeling any decision in a coverage report or backlog entry.

## Buckets (exactly one)

| Bucket | Meaning | Backlog? |
| --- | --- | --- |
| Covered by ADR | An Accepted (or Proposed) ADR in `docs/adr/` already records this decision | No |
| Covered by skill | An installed skill fully specifies the convention; reversing it means changing the skill, not the product ADR set | No |
| ADR-worthy gap | Product/architecture boundary not owned by a skill and not recorded in an ADR | Yes |
| STATE/polish only | Feature-local or tactical; belongs in `.specs/STATE.md` or design notes | No |

## ADR-worthy signals

Treat as ADR-worthy when the choice is about **boundaries that future engineers must not silently reverse**:

- Application stack or primary framework
- Authn/authz model and public vs session HTTP surface
- Persistence engine, journal mode, single-writer / scale limits
- Cutover / migration strategy between systems
- Multi-tenancy, trust boundaries, external IdP coupling
- Introducing a new integration pattern that is product-specific (not the generic skill pattern)

## Skill-owned signals

If an installed skill (e.g. `rails-dev`) already mandates it, classify **Covered by skill**:

- State-as-records vs booleans
- CRUD-everything / noun resources
- Soft references without FK constraints
- Solid Queue / Cache / Cable (no Redis)
- Generic inbound webhook inbox (verify → store → ack → async process)
- Minitest + fixtures, minimal-dependencies stance

Product-specific applications of a skill pattern can still be ADR-worthy when they choose **whether** to expose a boundary (e.g. "Wix webhooks are the only public HTTP" is ADR material; "use an inbox table" is skill material).

## STATE/polish only

- Visual density, theme, chrome layout
- Session TTL, rate-limit constants (unless changing the auth model)
- Controller concern wiring details once the cross-cutting approach is settled
- One-off PORO naming when the integration architecture ADR (or skill) already covers the pattern

## Conflict resolution

1. Exact ADR title/topic match → Covered by ADR
2. Else skill owns the convention → Covered by skill
3. Else boundary/strategy signal → ADR-worthy gap
4. Else → STATE/polish only

When unsure between gap and polish, prefer **registering a gap** with status `open` and let the user defer or reclassify — the Design hard-stop exists to surface these, not hide them.

## TLC STATE.md AD-NNN entries

Design often appends `AD-NNN` to `.specs/STATE.md`. Re-classify each active decision through this file; do not assume every AD is ADR-worthy.
