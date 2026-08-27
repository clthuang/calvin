# Calvin — Hook Insertion Points

**Question answered here:** where in Terry's actual workflow does ambiguous text enter the pipeline, and what's the cheapest mechanism at each point that *forces* a Calvin pass — without adding machinery Calvin itself must carry. Researched 2026-08-27 against the live config (`~/.claude/settings.json`, `~/.claude/hooks/`, `~/.codex/`, pd + claude-mem plugin skills).

**Force spectrum:** `remember` (CLAUDE.md rule — model-enforced) → `inject` (deterministic hook adds a reminder at the exact moment) → `gate` (block until a ledger exists). v0.1 ships remember+inject; gates need headless `report` mode hardening (v0.3) to avoid blocking on a dialogue.

---

## Where ambiguous text enters (observed surfaces)

| # | Entry point | Evidence | Ambiguity risk |
|---|------------|----------|----------------|
| 1 | Specs/PRDs/plans Terry drafts fast | this repo; premortem cause #2 | **highest** — unreviewed text goes straight to agents |
| 2 | `claude-mem:make-plan` output → `claude-mem:do` executes it | both skills installed; do fans out to subagents that never question the plan | **high** — a vague plan multiplies across every subagent |
| 3 | Plan-mode plans (ExitPlanMode → approval) | daily Claude Code usage | medium — Terry reviews these anyway |
| 4 | pd feature `shape.md` `## Requirements` | pd `specifying` skill defines the quality bar | medium — pd already enforces *criteria form*; Calvin adds *intent interrogation* |
| 5 | Prompts typed mid-session | UserPromptSubmit hook exists (worktree-remind) | low value — interrogating every prompt = friction death (premortem #1 inverted) |
| 6 | Commit messages / PR bodies on spec files | git repos, no hooks today | defer — needs headless report mode (v0.3) |

## Recommended insertions (ranked, leverage per line)

### H1 — Global CLAUDE.md rule (`remember`, ~4 lines) — DO FIRST
Covers entries 1, 2, 3 in one block; zero machinery; the premortem's single highest-leverage change. Proposed text for `~/.claude/CLAUDE.md`:

```markdown
# Clarity (calvin)
- Before implementing from any spec, PRD, plan, or prompt-file that was written
  fast or by an agent, run calvin on it first and let the author adjudicate.
- After `make-plan` (or plan mode) produces a plan and BEFORE `do`/execution:
  calvin the plan document. Skip only if the doc already has a calvin ledger.
```

### H2 — PostToolUse spec-file reminder (`inject`, one ~15-line script) — DO SECOND
Deterministic version of H1: fires at the exact moment a spec-shaped file is written, once per file per session. Reuses the existing pattern (`~/.claude/hooks/*.sh`, registered in settings.json — same shape as `worktree-remind.sh`).

```bash
#!/bin/bash
# calvin-remind.sh — PostToolUse(Edit|Write): one nudge per spec-like file per session
input=$(cat)
path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
sid=$(printf '%s' "$input" | jq -r '.session_id // "s"')
case "$(basename "$path" | tr '[:upper:]' '[:lower:]')" in
  *prd*.md|*spec*.md|*plan*.md|*design*.md|*rfc*.md|shape.md|*brief*.md) ;;
  *) exit 0 ;;
esac
mark="${TMPDIR:-/tmp}/calvin-remind-$(printf '%s' "$sid$path" | shasum | cut -c1-12)"
[ -e "$mark" ] && exit 0
touch "$mark"
echo "Spec-shaped file written: $path — run calvin on it before anything implements from it (Calvin questions, the author adjudicates)."
```
Register: `PostToolUse`, matcher `Edit|Write`. Exclusion note: skip paths inside `~/projects/calvin/` itself to avoid self-nagging while building Calvin.

### H3 — `~/.codex/AGENTS.md` section (`remember`, mirrors H1) — WITH v0.2
The file already has Working Agreements + Reviews sections; add a `## Specs` section with H1's two bullets. Pairs with the v0.2 install symlink (`~/.agents/skills/calvin`). No point before Calvin is verified on Codex.

### H4 — pd `specifying` seam (`remember`, edit at source) — WHEN TOUCHING pd
pd is Terry's own plugin: add one line to the `specifying` skill in the pd repo (not the plugin cache — it's overwritten on update): "Before a shape.md Requirements section is marked done, calvin it; attach the ledger." pd's bar checks criteria *form*; Calvin checks the author *meant* them. Complementary, not redundant.

## Rejected (with reasons)

- **UserPromptSubmit interrogation of prompts** — Calvin on every prompt is the friction that premortem cause #1 says kills the tool; prompts are cheap to clarify conversationally.
- **Hard gates now** (PreToolUse block on ExitPlanMode / pre-commit rejecting specs without ledgers) — blocking on an interactive dialogue deadlocks agent pipelines; revisit at v0.3 when `report` mode is CI-hardened and a gate can demand a ledger file instead of a conversation.
- **Stop-hook session audit** — strictly worse than H2: same signal, later, with transcript parsing.
- **Editing plugin caches** (claude-mem make-plan/do) — overwritten on update; the seam is covered by H1's second bullet instead.

## Generalization across agents

Two layers, different portability:

- **Portable (any host):** the entry-point analysis, the force spectrum, and the rejections — reasoning about *where* to force clarity, no host assumed.
- **Per-host (Claude Code-first):** H1–H4 are mechanisms. Equivalents by layer: the *remember* layer ports via `AGENTS.md` (the cross-tool instructions standard — Codex and Gemini read it natively; Grok auto-discovers Claude config wholesale), so H1's text drops into any host's instructions file unchanged. The *inject* layer does not port: hook systems are proprietary per host (Codex has `~/.codex/hooks/`; Gemini/Grok hook support unverified). Per-host inject mechanisms follow the same rule as the skill itself: verified at v0.2, not assumed.

## Sequencing

| When | Action |
|------|--------|
| Now (pre-v0.1) | H1 — it also creates the dogfood-gate habit PLAN Phase 4 needs |
| With v0.1 install (PLAN Phase 3) | H2 — script + settings.json registration |
| With v0.2 (Codex verified) | H3 |
| Next pd release | H4 |
| v0.3 (report mode in CI) | Revisit gates: git pre-commit `calvin report` on spec paths, exit code on blocker-count |
