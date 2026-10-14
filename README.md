# Calvin 🚼

**The AI that never answers.** Calvin reads your spec, PRD, plan, or prompt line by line and does exactly one thing: asks the questions everyone else is too polite or too tired to ask.

```
L8  The export should be fast and include everything relevant.

Calvin: What does "fast" mean here — how would a reader tell
        a fast export from a slow one?
Calvin: "everything relevant" — relevant by what standard, and
        who decides? ("Everything relevant" is what my mom says
        to pack for camp. It's how you end up with no toothbrush.)
```

It hunts sloppy wording and shaky reasoning alike:

```
L2  Our best customers all onboarded with a sales call,
    so sales calls create loyalty.

Calvin: That counts only your best customers — did the
        customers who AREN'T your best get sales calls too?
```

You answer, Calvin locks it in, and you get a ledger of your own words — ready to paste back into the doc. Vague specs make AI agents guess; Calvin makes *you* decide before they do.

Named for *Calvin and Hobbes*: six years old, unbounded curiosity, zero deference.

## The rules

- **Questions only.** Never a fix, a rewrite, or an opinion — ask it "what do you think?" and it deflects.
- **You're the judge.** Calvin's questions can be wrong; dismissing one costs a single "not an issue".
- **It always ends.** Max 3 rounds of ≤5 questions, biggest problems first.
- **Asks from ignorance.** No expert frames, no demanded formats — only your words and the universal challenges: define it, ground it, bound it, trace it, and above all — why? All three ways: what is this for, why do *you* need it, and what problem is it actually solving?

## Install

One file, no server, no dependencies — a standard [Agent Skill](https://agentskills.io):

```sh
git clone https://github.com/clthuang/calvin && cd calvin
mkdir -p ~/.claude/skills ~/.agents/skills ~/.grok/skills
ln -sfn "$PWD" ~/.claude/skills/calvin      # Claude Code
ln -sfn "$PWD" ~/.agents/skills/calvin      # Codex CLI
ln -sfn "$PWD" ~/.grok/skills/calvin        # Grok Build
```

Other hosts that read the Agent Skills standard work the same way. Last resort: paste `SKILL.md` plus your text into any chat LLM.

## Use

```
calvin spec.md           # interactive — Calvin asks, you answer
calvin report spec.md    # one-shot — every question emitted, no dialogue
```

## More

[`SKILL.md`](SKILL.md) is the whole product. [`examples/sample-session.md`](examples/sample-session.md) shows a full session; [`PRD.md`](PRD.md), [`DESIGN.md`](DESIGN.md), [`PLAN.md`](PLAN.md), and [`HOOKS.md`](HOOKS.md) are the paper trail. [`hooks/`](hooks/) holds the optional Claude Code reminder hook (see HOOKS.md H2).
