# Calvin v0.1 — Implementation Plan

**Executor note:** each phase is self-contained and runnable in a fresh context. Normative sources: `PRD.md` v3.1 (what/why) · `DESIGN.md` (how) · this file (do). Working dir: `/Users/terry/projects/calvin`.

---

## Phase 0 — Documentation discovery ✅ (done 2026-08-27; consolidated findings)

**Sources consulted:** Agent Skills spec (`https://agentskills.io/specification`, markdown at `/specification.md` — note `/spec` 404s); Anthropic's official validator `~/.claude/plugins/cache/claude-plugins-official/skill-creator/*/skills/skill-creator/scripts/quick_validate.py`; Claude Code v2.1.247 binary schema; 142 installed SKILL.md files (field histogram + length stats).

**Allowed frontmatter (the portable spec set — use ONLY these):**

| Field | Rule |
|---|---|
| `name` | required; 1–64 chars; `a-z0-9-`; no leading/trailing/double hyphen; **must equal the parent directory name** (Claude Code derives the skill ID from the directory) |
| `description` | required; ≤1024 chars; **no angle brackets** (validator hard-fails); does ALL routing — there is no `triggers:` field; sweet spot 150–400 chars; folded scalar `description: >` works and is the local convention for long ones |
| `license`, `compatibility`, `metadata`, `allowed-tools` | optional; Calvin needs none of them (`metadata: {version: "0.1"}` allowed if wanted — values must be quoted strings) |

**Body rules:** ≤5k tokens recommended, <500 lines universal in practice; 1 MiB/file runtime cap; supporting files load ONLY when SKILL.md prose points at them (no manifest, no auto-load).

**Copy-ready template:** `~/.claude/plugins/cache/ponytail/ponytail/4.7.0/skills/ponytail/SKILL.md` — the corpus's only pure persona+method skill. Section mapping for Calvin: `## Persistence` → anti-drift clause (DESIGN §2.2 row 1b) · the ladder → protocol steps · `## Output` → question/ledger form constraints · `## When NOT to be lazy` → rails carve-outs · `## Boundaries` → off-switch.

**Anti-patterns (do NOT):** `triggers:`, `when-to-use:`, `tools:` (agent field, not skill), `version:`/`author:`/`argument-hint:` at top level (Claude Code tolerates, official validator rejects — portability killers); angle brackets in description; YAML-list `allowed-tools`; name≠directory; body >500 lines; assuming `examples/` auto-loads.

---

## Phase 1 — Write `SKILL.md`

**What:** create `/Users/terry/projects/calvin/SKILL.md` to DESIGN §2.2's section budgets (~2.9k tokens total).

1. **Frontmatter** — copy the folded-scalar shape from the ponytail template (its lines 1–14, minus `argument-hint`); use exactly the DESIGN §2.1 draft text (`name: calvin` + description; verify: no `<`/`>`, ≤1024 chars).
2. **Body §§0–6** — write to the budget table in DESIGN §2.2, content lifted from the cited PRD sections (§2–3 identity, §4.1+§6 vocabulary, §4.2+§5 protocol+constants, §4.3 rails **including the Rail-1 deflection exchange verbatim** — the trap must be in loaded context per DESIGN §2.2 row 4). Persistence clause (row 1b) adapts ponytail's `## Persistence` wording to "never drift into answering".
3. **No references to `examples/`** from the body — the golden transcript is a test artifact, not runtime context; SKILL.md must be self-sufficient (Phase 0 anti-pattern: nothing auto-loads anyway).

**Verify:**
- [ ] `python3 <path-from-Phase-0>/quick_validate.py /Users/terry/projects/calvin` exits clean (glob the cache path first; it takes the skill dir)
- [ ] `wc -l SKILL.md` < 500; `wc -c` gives ≈4×token budget → expect < ~13 KB
- [ ] `grep -nE '^(triggers|when-to-use|tools|version|author|argument-hint):' SKILL.md` → no hits
- [ ] `grep -c '[<>]' <(sed -n '/^description/,/^---/p' SKILL.md)` → 0
- [ ] Every DESIGN §2.2 row present; §7 constants appear exactly once

## Phase 2 — Write `examples/sample-session.md`

**What:** the unabridged golden transcript — copy PRD Appendix B and extend to a full session: all 5 round-1 questions (≥2 structural/cross-line, ≤3 single-word lexical hits — models imitate the transcript's ratio), the DRILL→CONFIRM→"locked in?" exchange, a FLAG-CONFLICT exchange (natural fixture: the author's "bigger goes async" answer collides with L7's "at any time" — surface both, author chooses), the Rail-1 trap + deflection, one DISMISSED verdict, and the closing ledger built with PRD §6's exact row schema (incl. one `L<n>+<m>` citation and an OPEN cause note).

**Verify:**
- [ ] Transcript demonstrates all three moves, all three statuses, and invariants I1–I5 from DESIGN §3.2 hold by inspection (I5: no question contains a candidate value)
- [ ] Ledger matches DESIGN §4 vocabulary exactly (enums, tally line)

## Phase 3 — Install

**What:** `mkdir -p ~/.claude/skills && ln -s /Users/terry/projects/calvin ~/.claude/skills/calvin` (Phase 0: `~/.claude/skills/` does not exist yet; directory name `calvin` must equal frontmatter `name`).

**Verify:**
- [ ] `readlink ~/.claude/skills/calvin` → the repo
- [ ] Fresh `claude` session lists `calvin` among available skills (its description text appears in the skill listing)

## Phase 4 — Verification (the v0.1 gate)

**Status 2026-08-27:** steps 1+4 ✅ headless (`claude -p`); step 5 partial (report-run invariants hold); steps 2 (gate) + 3 (trap) require Terry interactively. Run log: report on 3-line fixture → 14 OPEN(report); smoke report on PRD.md → `☑ 0 resolved · 13 open · 0 dismissed`, 3 blockers — all adjudicable, 6 applied as PRD/SKILL fixes, 7 judgment calls left OPEN for the author. Phases 1–3 ✅ (validator: "Skill is valid!"; symlink live).

Run in a fresh Claude Code session, per DESIGN §8:

1. **Smoke:** `calvin PRD.md` — hard fixture after four review rounds; an empty ledger is legal (Rail 3), not a failure. Checks the machinery runs, not the value.
2. **Gate:** `calvin <doc>` where `<doc>` is something written fast and never reviewed (scratch spec, ticket, prompt). **Pass:** ≥1 question the owner resolves with a real edit. **Fail:** zero questions, or all-DISMISSED (PRD §10). This fixture also tests premortem risks #2 (redundancy) and #3 (lexical-linter) alongside the gate itself.
3. **Trap:** mid-session ask "what do you think it should be?" **Pass:** Rail-1 deflection, zero proposed content.
4. **Report mode:** `calvin report <doc>` → single pass, every row `OPEN (report)`, zero interactive questions. If the host mis-routes the word "report", log it (DESIGN §10 open question).
5. **Invariants I1–I5** (DESIGN §3.2) checked against the gate-run transcript + ledger — I5 especially: no RESOLVED answer whose substance first appeared in a Calvin question.
6. **On any failure:** fix SKILL.md *wording* (never add machinery), re-run 2–3. Two consecutive failed gate runs → back to DESIGN, per PRD §10's kill-or-fix rule.
7. **Log:** append resulting PRD/DESIGN edits, and record the tally line (`☑ N resolved · M open · K dismissed`) of the first three real sessions — read them against the kill rule; a string of 1:5:9 tallies is a warning that must not be read as a pass.

**Done =** all Phase 1–3 checkboxes green + Phase 4 steps 1–3 passed on Claude Code. (v0.2 = same trap test on Codex/Gemini/Grok — out of scope here.)
