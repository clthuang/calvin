# Calvin — Design Doc

| | |
|---|---|
| **Status** | Draft, ready for v0.1 build |
| **Owner** | Terry |
| **Updated** | 2026-08-27 |
| **Upstream** | `PRD.md` v3.1 (normative for *what/why*; survived 3 review rounds). This doc is normative for *how*. |
| **Scope** | The v0.1 deliverable: one `SKILL.md` + golden transcript. Out of scope: v0.2 host verification, v0.3 CI/diff mode, v1.0 MCP (PRD §11). |

---

## 1. System context

Calvin has no runtime of its own. The host agent (Claude Code, Codex, Gemini CLI, Grok Build, …) loads `SKILL.md`; the host's model *becomes* Calvin for the session; all state lives in the conversation as the Ledger.

```
 author (human or agent)
        │  "calvin spec.md" / pasted text
        ▼
 ┌─────────────────┐   loads    ┌──────────────────────────┐
 │ host agent CLI  │──────────▶ │ SKILL.md (persona+method) │
 └─────────────────┘            └──────────────────────────┘
        │ model adopts protocol
        ▼
   interrogation dialogue ──▶ Ledger (markdown, in-conversation)
        ▲                          │
        └── author answers ◀───────┘  resume = re-feed doc + last ledger
```

Design consequences:
- **No persistence layer.** The Ledger is the only state (PRD §6). Resume/round-*n*+1 = re-feed document + last ledger.
- **No config surface.** Two modes (`interrogate`, `report`); everything else is a constant inside SKILL.md (PRD §5).
- **Enforcement is prompt-level.** The rails hold only as well as the SKILL.md text holds under each host's model — hence the trap test (§8).

## 2. The deliverable: SKILL.md anatomy

Per the Agent Skills standard: frontmatter `description` is always in context (spec cap 1024 chars; keep ~150–400 per local convention); the body loads on activation (≤5k tokens recommended, <500 lines — PLAN Phase 0).

### 2.1 Frontmatter (verbatim, current)

```yaml
---
name: calvin
description: >
  Socratic interrogator. Reads a document line by line and asks questions
  about ambiguity, vagueness, inconsistency, hidden assumptions, gaps, and
  shaky reasoning — causal leaps, biased data. Never answers, proposes,
  or rewrites — the author adjudicates every question. Use when asked to
  "calvin", interrogate, poke holes in, or disambiguate a spec, PRD,
  prompt, or design doc before implementation.
---
```

(≈380 chars ≤400. The word "calvin" appears as its own trigger so `calvin foo.md` activates on every host. This block mirrors the live SKILL.md — sync it whenever the description changes.)

### 2.2 Body layout and token budget

| # | Section | Contents (normative source) | Budget |
|---|---------|------------------------------|--------|
| 0 | Install note | HTML comment at the END of the file — non-model-facing, so it no longer holds the primacy slot (one `ln -sfn` per host path, PRD §7.1) | 60 |
| 1 | Identity & Prime Directive | Persona, never-answer rule, fallibility clause (PRD §2–3) | 350 |
| 1b | Persistence clause | "Active every response — no drift into answering; off only on explicit stop" (pattern: ponytail SKILL.md `## Persistence`) | 100 |
| 2 | Vocabulary | Zoom levels Z1–Z4 (sweep lenses) + six-category enum incl. `reasoning` + inline weasel list, severity enum, status/cause enums, citation grammar (PRD §4.1, §6) | 700 |
| 3 | Protocol | The loop of §3 below, incl. constants: rounds ≤3, ≤5 q/round, why-budget 3, one aside/round (PRD §4.2, §5) | 800 |
| 4 | Rails | Rails 1–5 verbatim-tight, **including the Rail-1 deflection exchange** — the trap must be in loaded context, marked as an example of the move, not a required script: vary the wording, keep the shape (PRD §4.3, §7.2) | 450 |
| 5 | Ledger template | The §4 table skeleton + tally line + empty-ledger line | 250 |
| 6 | Micro-example | 6–8 line condensed interrogation (full version lives in `examples/`) | 300 |
| | **Total** | | **~2,860** — comfortable headroom under 5k |

Rule: if a section busts its budget, cut prose, never cut an enum or a rail.

Section order in the file (2026-08-27 simplify pass, research-backed): identity → persistence → **rails** → vocabulary → protocol → ledger → example — the constraint region sits contiguous at the head instead of in the mid-file attention valley, and all four field enums (severity, status, cause, citation) consolidate in Vocabulary.

### 2.3 Repo

```
calvin/
  SKILL.md                    # everything above
  examples/sample-session.md  # golden transcripts, both sessions = per-host eyeball test
  examples/export-spec.md     # runnable fixture — session 1 input
  examples/analysis-spec.md   # runnable fixture — session 2 input (reasoning)
  PRD.md / DESIGN.md / PLAN.md / HOOKS.md
```

Install: `ln -s ~/projects/calvin ~/.claude/skills/calvin` (and per-host equivalents from PRD §7.1). No script.

## 3. Control flow

### 3.1 Session loop (pseudocode)

```
lines    = number(input)                  # file path or pasted text
findings = sweep(lines)                   # tag: span, category, blocker|minor
if mode == report:
    emit ledger(all findings OPEN(report)); END

for round in 1..3:                        # human author may extend; agent author may not
    batch = top5(findings where status==unasked, blockers_first)
    if batch empty: break
    ask(batch)                            # ≤5 questions, one decision each, ≤1 aside
    process answers with moves {CONFIRM, DRILL, FLAG-CONFLICT}   # drills stay inside this round
    emit ledger                           # round-end checkpoint = the resume state
emit ledger                               # final — always, even if the author vanished
```

### 3.2 Finding state machine

```
              sweep                round asks it
   (text) ─────────▶ OPEN(unasked) ─────────────▶ AWAITING
                                                     │
        ┌────────────────────────┬───────────────────┼──────────────────┐
        │ vague answer &         │ answer conflicts  │ author answers   │ author says
        │ budget>0               │ w/ text or prior  │ concretely       │ "overruled"
        ▼                        ▼                   ▼                  ▼
   DRILL (budget−−) ──▶ AWAITING FLAG-CONFLICT ──▶ AWAITING        DISMISSED ▣
        │ budget==0                                  │                (reason, author's words)
        ▼                                            ▼
   OPEN(budget) ▣                        CONFIRM "locked in?"
                                             │ yes          │ no: correction = new answer
                                             ▼              └──────▶ AWAITING
                                        RESOLVED ▣ (answer verbatim)

   session ends (round cap / author stops):  any AWAITING or OPEN(unasked) ──▶ OPEN(stopped) ▣
   ▣ = terminal. report mode: everything ──▶ OPEN(report) ▣
```

Invariants (test these — §8):
- **I1** Every finding is terminal when the ledger is emitted at close.
- **I2** RESOLVED and DISMISSED are entered only by author verdicts, never unilaterally.
- **I3** No Calvin output exists outside {question, paraphrase-for-confirmation, ledger}.
- **I4** RESOLVED answer cells contain the author's words, not Calvin's paraphrase.
- **I5** No RESOLVED answer's substance (number, name, criterion) first appeared in Calvin's question — the leading-question check (Rail 2).

### 3.3 Bounds

Worst interactive case: 3 rounds × 5 questions = 15 primary questions; each finding ≤3 drills + 1 confirm → ≤75 Calvin turns, in practice far fewer. The cap is the *termination guarantee* for agent-vs-agent sessions (PRD §4.2): an agent author cannot extend rounds. `report` mode is single-pass — cost is one sweep regardless of document size.

## 4. Data design: the Ledger

One artifact, markdown, emitted into the conversation.

**Citation grammar:** `L<n>` · `L<n>–<m>` (contiguous range) · `L<n>+<m>` (non-contiguous pair). Line numbers refer to Calvin's numbering from step 1, which is stated at the top of the first round.

**Vocabulary (closed enums):**

| Field | Values |
|-------|--------|
| Category | `ambiguity` `vagueness` `inconsistency` `assumption` `completeness` `reasoning` |
| Severity | `blocker` (implementer would guess) · `minor` (friction) |
| Status | `RESOLVED` · `DISMISSED` · `OPEN` |
| OPEN cause (answer cell) | `(unasked)` `(budget)` `(stopped)` `(report)` |

**Row schema:** `# · Line · Quote · Category · Question · Status · Author's answer`
**Tally line:** `☑ N resolved · M open · K dismissed`
**Empty case (Rail 3):** no table — the single line `Nothing questionable — ledger empty.`

**Carry-over:** a round-*n* ledger contains *all* findings from rounds 1..*n*. Re-feeding doc + ledger reconstructs the session completely; terminal rows are never re-asked (Rail 4).

## 5. Invocation design

| Host | Interactive | Report mode |
|------|-------------|-------------|
| Claude Code | `calvin spec.md` or "use calvin on <text>" — skill triggers on description match | "calvin report spec.md" |
| Codex / Gemini / Grok | Same phrasing; skills auto-discovered from standard paths (verify: v0.2) | same |
| Any chat LLM (fallback) | Paste SKILL.md body + the text | prepend "report mode:" |

Input contract: exactly one document per session (multi-file = multiple sessions). Mode defaults to `interrogate`; the word "report" in the invocation selects `report`.

## 6. Edge cases

| Case | Behavior |
|------|----------|
| Empty/trivial input (< ~3 substantive lines) | `Nothing questionable — ledger empty.` — no manufactured findings (Rail 3) |
| Long document (≳300 lines) | Interrogate section by section, one session each; ledger carries over; line numbers stay global to the full document (PRD §6) |
| Code files | Best-effort in v0.1: interrogate comments, identifiers, strings as prose; the taxonomy is prose-tuned. Real policy lands with diff mode (v0.3) |
| Author answers a question with a question | Rail 1 deflection; the finding stays AWAITING |
| Author ignores a question / answers something else | Finding stays AWAITING; at session end → OPEN(stopped). Never re-asked within the round |
| Author tries to resolve several findings with one sweeping answer | CONFIRM each affected finding separately; partial confirmations allowed |
| Context loss mid-session | State = the ledger; author re-feeds doc + last emitted ledger. Calvin emits the current ledger at every round end to keep the checkpoint fresh |
| Host model breaks Rail 1 (proposes content) | P0 (PRD §10). No runtime guard possible at prompt level — caught by trap test + real use; fix = tighten SKILL.md wording |

## 7. Constants (single source of truth)

Defined once in SKILL.md §3, referenced nowhere else: `ROUNDS_MAX = 3` (human-extendable) · `QUESTIONS_PER_ROUND_MAX = 5` · `WHY_BUDGET = 3` · `ASIDES_PER_ROUND_MAX = 1`. Changing one = editing SKILL.md (PRD §5).

## 8. Testing & verification

1. **Dogfood (v0.1 gate, PRD §10):** smoke-run `calvin PRD.md` (hard fixture — an empty ledger is legal), then gate on `calvin <fresh unreviewed doc>`. Pass = the gate run yields ≥1 question the owner resolves with a real edit; all-DISMISSED or zero questions = fail.
2. **Trap test (every host, staged v0.1→v0.2):** mid-session, author asks "what do you think it should be?" Pass = Rail-1 deflection; any proposed content = fail.
3. **Invariant checks on the dogfood transcript:** I1–I5 by inspection (they are visible properties of the ledger + transcript; I5 = no RESOLVED substance originated in a question).
4. **Golden transcript diff:** run the sample inputs (both sessions — `examples/export-spec.md`, `examples/analysis-spec.md`) per host; eyeball divergence in move usage, question quality, rail adherence. Divergence is data for wording fixes, not an automated gate.
5. **Regression rule:** any SKILL.md edit → re-run 1 and 2 on Claude Code before calling it done.

## 9. Build plan (v0.1, ~half a day)

1. Write `SKILL.md` §§0–6 to the budgets in §2.2. — 2h
2. Write `examples/sample-session.md` (unabridged PRD App. B session incl. trap exchange). — 30m
3. `ln -s` into `~/.claude/skills/`. — 1m
4. Run dogfood + trap + invariants; fix wording; re-run. — 1–2h
5. Log resulting PRD edits (the dogfood output *is* PRD feedback). — 15m

## 10. Open questions

- **Code-input policy** — deferred until v0.3 diff mode forces it; v0.1 ships the best-effort row in §6.
- **Gemini/Grok discovery paths** — table in PRD §7.1 is doc-sourced; empirical verification is the whole of v0.2.
- **Trigger collision** — "report" is a common word; if a host mis-routes `calvin report`, fall back to explicit "calvin in report mode". Revisit only if it actually happens.
