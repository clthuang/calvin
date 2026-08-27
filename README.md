# Calvin 🚼

**The AI that never answers.** Calvin reads your spec, PRD, plan, or prompt line by line and does exactly one thing: asks the questions everyone else is too polite or too tired to ask.

```
L8  The export should be fast and include everything relevant.

Calvin: "fast" — number, please. What's the biggest export that
        must still finish, and in how many seconds?
Calvin: "everything relevant" — relevant according to whom?
        List it, or point at the list. ("Everything relevant" is
        what my mom says to pack for camp. It's how you end up
        with no toothbrush.)
```

You answer, Calvin locks it in, and you get a ledger of your own words — ready to paste back into the doc. Vague specs make AI agents guess; Calvin makes *you* decide before they do.

Named for *Calvin and Hobbes*: six years old, unbounded curiosity, zero deference.

## The rules

- **Questions only.** Never a fix, a rewrite, or an opinion — ask it "what do you think?" and it deflects.
- **You're the judge.** Calvin's questions can be wrong; dismissing one costs a single "not an issue".
- **It always ends.** Max 3 rounds of ≤5 questions, biggest problems first.

## Install

One file, no server, no dependencies — a standard [Agent Skill](https://agentskills.io):

```sh
git clone https://github.com/clthuang/calvin && cd calvin
ln -s "$PWD" ~/.claude/skills/calvin      # Claude Code
ln -s "$PWD" ~/.agents/skills/calvin      # Codex CLI
ln -s "$PWD" ~/.grok/skills/calvin        # Grok Build
```

Other hosts that read the Agent Skills standard work the same way. Last resort: paste `SKILL.md` plus your text into any chat LLM.

## Use

```
calvin spec.md           # interactive — Calvin asks, you answer
calvin report spec.md    # one-shot — every question emitted, no dialogue
```

## More

[`SKILL.md`](SKILL.md) is the whole product. [`examples/sample-session.md`](examples/sample-session.md) shows a full session; [`PRD.md`](PRD.md), [`DESIGN.md`](DESIGN.md), [`PLAN.md`](PLAN.md), and [`HOOKS.md`](HOOKS.md) are the paper trail.
