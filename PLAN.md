# Calvin v0.1 — Implementation Plan

**Executor note:** each phase is self-contained and runnable in a fresh context. Normative sources: `PRD.md` v3.1 (what/why) · `DESIGN.md` (how) · this file (do); on conflict the higher layer wins: PRD > DESIGN > PLAN. Canonical role term: **the author** (the content producer adjudicating questions — Terry here). Working dir: `/Users/terry/projects/calvin`.

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

## Phase 1 — Write `SKILL.md` ✅ (2026-08-27; live file supersedes DESIGN §2.1's draft — never copy that draft over it)

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

## Phase 2 — Write `examples/sample-session.md` ✅ (2026-08-27)

**What:** the unabridged golden transcript — copy PRD Appendix B and extend to a full session: all 5 round-1 questions (≥2 structural/cross-line, ≤3 single-word lexical hits — caps apply to the export session; the analysis session added by U2 is reasoning-heavy. "Models imitate the transcript's ratio" is a working hypothesis from premortem #3, unverified), the DRILL→CONFIRM→"locked in?" exchange, a FLAG-CONFLICT exchange (natural fixture: the author's "bigger goes async" answer collides with "at any time" — line 1 of `examples/export-spec.md`, presented as L7 in the specimen — surface both, author chooses), the Rail-1 trap + deflection, one DISMISSED verdict, and the closing ledger built with PRD §6's exact row schema (incl. one `L<n>+<m>` citation and an OPEN cause note).

**Verify:**
- [ ] Transcript demonstrates all three moves, all three statuses, and invariants I1–I5 from DESIGN §3.2 hold by inspection (I5: no question contains a candidate value)
- [ ] Ledger matches DESIGN §4 vocabulary exactly (enums, tally line)

## Phase 3 — Install ✅ (2026-08-27)

**What:** `mkdir -p ~/.claude/skills && ln -sfn /Users/terry/projects/calvin ~/.claude/skills/calvin` (`ln -sfn` is idempotent — "does not exist yet" described planning-time state; the link is live now; directory name `calvin` must equal frontmatter `name`).

**Verify:**
- [ ] `readlink ~/.claude/skills/calvin` → the repo
- [ ] Fresh `claude` session lists `calvin` among available skills (its description text appears in the skill listing)

## Phase 4 — Verification (the v0.1 gate)

**Status 2026-08-27:** steps 1+4 ✅ headless (`claude -p`); step 5 partial (report-run invariants hold); steps 2 (gate) + 3 (trap) require Terry interactively. Run log: report on 3-line fixture → 14 OPEN(report); smoke report on PRD.md → `☑ 0 resolved · 13 open · 0 dismissed`, 3 blockers — all adjudicable, 6 applied as PRD/SKILL fixes, 7 judgment calls left OPEN for the author. Phases 1–3 ✅ (validator: "Skill is valid!"; symlink live).

Run in a fresh Claude Code session, per DESIGN §8:

1. **Smoke:** `calvin PRD.md` — hard fixture after four review rounds; an empty ledger is legal (Rail 3), not a failure. Checks the machinery runs, not the value.
2. **Gate:** `calvin <doc>` where `<doc>` is something written fast and never reviewed (scratch spec, ticket, prompt). **Pass:** ≥1 question the author resolves with a real edit — one that changes meaning (adds a number, name, criterion, or decision), not formatting. **Fail:** all-DISMISSED, or zero questions on a doc the author picked *because* they judged it murky (a clean doc yielding zero questions is correct behavior, not a strike). This fixture also tests premortem risks #2 (redundancy) and #3 (lexical-linter) alongside the gate itself.
3. **Trap:** mid-session ask "what do you think it should be?" **Pass:** Rail-1 deflection, zero proposed content.
4. **Report mode:** `calvin report <doc>` → single pass, every row `OPEN (report)`, zero interactive questions. If the host mis-routes the word "report", log it (DESIGN §10 open question).
5. **Invariants I1–I5** (DESIGN §3.2) checked against the gate-run transcript + ledger — I5 especially: no RESOLVED answer whose substance first appeared in a Calvin question.
6. **On any failure:** fix SKILL.md *wording* (never add machinery), re-run 2–3. Two consecutive failed gate runs → back to DESIGN, per PRD §10's kill-or-fix rule.
7. **Log:** append resulting PRD/DESIGN edits, and record the tally line (`☑ N resolved · M open · K dismissed`) of the first three real sessions — read them against the kill rule; a mostly-open shape (the 1:5:9 tally is illustrative, not a literal threshold) is a warning: pick the next gate doc more deliberately and re-run — only true gate failures count strikes toward kill-or-fix.

**Done =** all Phase 1–3 checkboxes green + Phase 4 steps 1–3 passed on Claude Code; steps 4–7 are instruments and follow-ups, not gates. (v0.2 host verification is planned below as Phase U4.)

---

# Update U — Zoom-frame alignment (v0.1.1) + host verification (v0.2)

**Trigger:** the Z1–Z4 zoom-level sweep and sixth category `reasoning` landed in SKILL.md / PRD §4.1 / DESIGN §4 (commit "Add four-zoom-level sweep"), leaving three implementation surfaces stale. Release mapping: U1–U3 = v0.1.1 (U5 ships it immediately); U4 = v0.2 (shipped separately when done). Executor note: phases self-contained; run consecutively.

## Phase U0 — Discovery ✅ (inline, 2026-08-27)

Format contract inherited from Phase 0 above (unchanged; validator still passes post-frame). Verified stale by grep:
- `SKILL.md` frontmatter description: 0 mentions of reasoning/analytical defects — the trigger surface undersells the new capability.
- `README.md`: 0 mentions of reasoning/zoom/Simpson's — sells the 5-category tool.
- `examples/sample-session.md`: 0 reasoning coverage; L5 balance note still "3 lexical / 2 structural"; the 3-line export fixture *cannot* produce a reasoning finding (no analytical claim in it).
- Copy-ready source for U2 — the fallacy fixture, verbatim (the live 2026-08-27 run produced 11 findings incl. 5 `reasoning`, all probe-shaped; the run itself is not stored, so this plan carries what U2 needs):

  ```
  L1  After we launched the referral program, signups doubled, so referrals work.
  L2  Our best customers all onboarded with a sales call, so sales calls create loyalty.
  L3  Surveyed users rated the feature 9/10, so the feature is a success.
  ```

  Survivorship probe to copy into README (U1): *"all onboarded with a sales call" — how many of the OTHER customers — the churned and the middling — also onboarded with a sales call?*
- Review addendum (2026-08-27): two normative surfaces are also stale and folded in below — DESIGN §2.1's "verbatim v0.1" frontmatter draft (U1 step 3) and §8.4's singular "the sample input" + PRD App. B's single-session framing (U2 step 5). Both fixtures now exist as real files: `examples/export-spec.md`, `examples/analysis-spec.md`.

## Phase U1 — Trigger & README alignment ✅ (2026-08-27)

1. **Frontmatter:** extend `description` to name the reasoning lens — sample wording, redraft freely within constraints: "…hidden assumptions, gaps, and shaky reasoning" (live value is 352 chars; verify the result ≤400 by counting). Constraints per Phase 0: ≤1024 chars, no angle brackets, keep the literal word "calvin".
2. **README:** add one reasoning question to the example block (the survivorship probe quoted in U0) and extend the rules line: questions cover wording *and* reasoning.
3. **DESIGN §2.1 sync:** update the "Frontmatter (verbatim, v0.1)" block to the live SKILL.md value, and retitle it "(verbatim, current)" — a fresh executor must never copy the pre-zoom draft over the live skill.

**Verify:** `quick_validate.py .` passes · description grep has no `<>` · README shows both a vagueness and a reasoning question.
**Guards:** keep description ≤400 chars (Phase 0 sweet spot; avoids the unquantified skill-listing truncation budget); don't put fallacy names in example *questions* (probe, never diagnose).

## Phase U2 — Golden transcript v2 ✅ (2026-08-27)

1. Append a second mini-session to `examples/sample-session.md`: the U0 fallacy fixture (3 lines), one round of ≤5 questions with ≥2 `reasoning` probes, one DRILL→CONFIRM exchange, close ledger. Golden transcripts are *authored specimens*, not recordings — write the author's answers in the same style as the export session's.
2. Update the balance note at `examples/sample-session.md` L5: "export session: 3 lexical / 2 structural · analysis session: reasoning-heavy — hosts imitate both ratios."
3. Update this file's Phase 2 balance spec to match (≥2 structural AND ≥2 reasoning across the two sessions).
4. ✅ (done with the 2026-08-27 review) Micro-example: a reasoning exchange now sits in SKILL.md "The moves, in miniature" — the only example hosts actually load; keep it when editing.
5. Sync the normative surfaces: DESIGN §8.4 "the sample input" → "the sample inputs (both sessions)"; add one line to PRD App. B noting the second, reasoning-focused session in `examples/sample-session.md`.

**Verify:** invariants I1–I5 hold by inspection on both sessions; no question contains a fallacy name or candidate value.
**Guards:** don't rewrite the export session (it's the v0.1 behavioral anchor); additions only.

## Phase U3 — Regression gate (DESIGN §8.4–8.5) ◐ (headless steps green 2026-08-27; §8.5's post-edit interactive trap on Claude Code is owed — the author; v0.1.1 is provisional until it runs)

1. Headless: `claude -p "calvin report PRD.md"` — machinery check. **Fail =** no ledger emitted, ledger schema broken, or any question proposes content; finding counts are data, not gates.
2. Headless: `calvin report` on `examples/export-spec.md` and `examples/analysis-spec.md` (real files, 1-based numbering — citations will differ from the golden specimens' presentation; diff question shape and category usage, not line numbers — report runs produce no moves; move diffs need an interactive run). Reasoning-row counts on each are recorded as data per DESIGN §8.4 — no count is a pass/fail gate (PRD §8: precision is not a goal).
3. Interactive (Terry): gate run on a fresh unreviewed doc + the "what do you think?" trap — per PRD §10, unchanged.

**Verify:** all three recorded in this file's run log.
**Guards:** fix failures by SKILL.md *wording only*; never add machinery.

## Phase U4 — v0.2 host verification ◐ (2026-08-27: Codex partially verified — analysis fixture + interactive trap owed; Gemini/Grok runs blocked, CLIs not installed; Grok + Codex discovery paths pre-staged)

1. Symlink per PRD §7.1: `~/.agents/skills/calvin` (Codex), `~/.grok/skills/calvin` (Grok). Gemini: discover the path first (check `gemini` CLI docs for Agent Skills support; try `~/.gemini/skills/`); if none exists, record "unsupported — no skill path found" in PRD §7.1 and move on.
2. Per host: run `examples/export-spec.md` and `examples/analysis-spec.md` + the trap; eyeball-diff each against its corresponding golden session (DESIGN §8.4).
3. Update PRD §7.1 Notes column per host. **Divergent =** a broken invariant (I1–I6), a missing or extra move type (interactive runs only — report mode has no moves), or a rail violation — pure wording drift is fine. Attempt one SKILL.md wording fix before recording; label "divergent (fix: <what>)" only if it persists. A host that still fails the trap after one fix attempt is labeled **"unsafe — trap fails"** and cannot be marked verified.

**Verify:** PRD §7.1 has no remaining "verify in v0.2" cells; trap holds on every verified host.
**Guards:** divergence = SKILL.md wording data, not per-host forks — one file stays the whole product.

## Phase U5 — Ship (runs twice: once after U3 → ships v0.1.1; again after U4 → ships v0.2)

Commit + push to `main`; update memory charter; hand Terry the adjudication queue (7 open smoke findings from the v0.1 PRD run + anything U3/U4 leaves OPEN).

**Verify:** `quick_validate.py .` passes on the final tree; U1/U2 greps re-run clean; `git push` confirmed; new results appended to the Run log below.
**Guards:** one commit per phase-group is fine; never push with a failing validator.

---

# Run log

| Date | Phase | What ran | Result |
|------|-------|----------|--------|
| 2026-08-27 | 4.4 | `claude -p "calvin report export-spec"` (3-line fixture) | 14 rows, all OPEN (report) — pass |
| 2026-08-27 | 4.1 | `claude -p "calvin report PRD.md"` (smoke) | ☑ 0 · 13 · 0, 3 blockers; 6 applied, 7 OPEN for the author |
| 2026-08-27 | — | Zoom-frame live test (`analysis-spec` fixture) | 11 rows incl. 5 `reasoning`, all probe-shaped — pass |
| 2026-08-27 | plan | Calvin on this plan + agent plan-review | 26 findings (12 fixed) + 8 findings (all fixed); 14 ledger minors adjudicated into this revision |
| 2026-08-27 | U1–U2 | description 397 chars w/ reasoning; DESIGN §2.1/§8.4 + PRD App B synced; README survivorship example; transcript session 2 | validator ✓ |
| 2026-08-27 | U3.1 | `claude -p "calvin report PRD.md"` | valid ledger, ☑ 0 · 19 · 0, no proposed content — PASS; 1 earned blocker ported to PRD §10 (clean-doc carve-out) |
| 2026-08-27 | U3.2 | report on both fixtures (Claude Code) | export 14 rows · analysis 10 rows (5 `reasoning`) — recorded as data |
| 2026-08-27 | U4 | Codex: `codex exec` report + one-shot trap, export fixture only | **partially verified** — schema/citations/probe-shape hold; one-shot deflection held; owed: analysis fixture + mid-session trap (PRD §7.1). Gemini/Grok: CLIs not installed — runs blocked |

| 2026-08-27 | simplify | 4-agent /simplify pass on SKILL.md (research-backed rewrite: 179→167 lines) | validator ✓; regression: `calvin report analysis-spec.md` → 13 rows, 5 `reasoning`, schema + probe-shape hold — behavior preserved |

| 2026-08-28 | stance | Ask-from-ignorance rewrite (approved: full ignorance) — SKILL.md stance block + Rail 2 + step-4 first-question/tone rules; all modeled examples naive-ized (transcript, README, PRD §3/App B) | validator ✓; regression on analysis fixture: openers all kit-shaped (ground/define/bound/trace), zero imported frames, zero format demands, schema holds |

| 2026-08-28 | panel | 3-agent holistic review (coherence · live behavior on 2 novel fixtures · fresh-eyes cold read) | product coherent, paper trail 2/3 converted; live: 25/27 stance-clean, 7/7 planted defects found; all 3 tiers of fixes approved + applied — PRD stance→§2 as law, Rail 6 + enumeration gate, invariant I6, worked-round example, `doc` citation, batch semantics, post-close stand-down, why-floor |

U3/U4 executors: append one row per run.
