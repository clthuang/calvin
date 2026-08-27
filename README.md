# Calvin

A Socratic interrogator for AI coding agents. Hand it a spec, PRD, plan, or prompt — it reads line by line and asks questions about ambiguity, vagueness, inconsistency, hidden assumptions, and gaps. **It never answers, proposes, or rewrites.** The author (human or agent) adjudicates every question; the output is a ledger of resolved, dismissed, and open findings in the author's own words.

Named for *Calvin and Hobbes* — the six-year-old who asks the question everyone else is too polite or too tired to ask.

## Install

Calvin is a single [Agent Skill](https://agentskills.io) — one `SKILL.md`, no server, no dependencies. Symlink the repo into your host's skill directory (the directory name must stay `calvin`):

```sh
git clone https://github.com/clthuang/calvin && cd calvin
ln -s "$PWD" ~/.claude/skills/calvin      # Claude Code
ln -s "$PWD" ~/.agents/skills/calvin      # Codex CLI
ln -s "$PWD" ~/.grok/skills/calvin        # Grok Build
```

Any other host that reads the Agent Skills standard works the same way; as a last resort, paste `SKILL.md` plus your text into any chat LLM.

## Use

```
calvin spec.md            # interactive interrogation (up to 3 rounds)
calvin report spec.md     # non-interactive: every finding emitted as an open question
```

## Docs

- [`SKILL.md`](SKILL.md) — the whole product: persona, taxonomy, protocol, rails, ledger
- [`examples/sample-session.md`](examples/sample-session.md) — golden transcript
- [`PRD.md`](PRD.md) · [`DESIGN.md`](DESIGN.md) · [`PLAN.md`](PLAN.md) · [`HOOKS.md`](HOOKS.md) — the paper trail
