# Calvin — Golden Transcript

The per-host eyeball test (DESIGN §8.4): run this input on a host, compare move
usage, question shape, and rail adherence. Divergence is wording-fix data, not
an automated gate. Balance — export session round 1: 3 lexical / 2 structural
(closed ledger: 3/3 once the FLAG-CONFLICT row joins) ·
analysis session: reasoning-heavy (4 reasoning / 1 vagueness). Hosts imitate
these ratios (working hypothesis, premortem #3). Fixtures as runnable files:
`export-spec.md`, `analysis-spec.md` (1-based numbering there; the specimens
below keep their own presentation numbering).

## Input — `export-spec.md`

```
L7  Users can export their data at any time.
L8  The export should be fast and include everything relevant.
L9  If the export fails, the system retries.
```

## Round 1

**Calvin:** Numbering as shown, L7–L9. Five questions, blockers first.

1. **[ambiguity · blocker · L7]** "their data" — which data counts, and
   where does it end?
2. **[vagueness · blocker · L8]** What does "fast" mean here — how would a
   reader tell a fast export from a slow one?
3. **[vagueness · blocker · L8]** "everything relevant" — relevant by what
   standard, and who decides? ("Everything relevant" is what my mom says to
   pack for camp. It's how you end up with no toothbrush.)
4. **[inconsistency · blocker · L7+L9]** L7 promises exports "at any time";
   L9 retries failures. While a retry runs, is L7's promise still being
   kept?
5. **[completeness · minor · L9]** After the last retry fails: who finds out,
   and how?

**Author:** Fast means under a minute.

**Calvin (DRILL 1/3):** Under a minute always — for every export there is?

**Author:** Up to 2 GB in 60 s. Bigger goes async with an email.

**Calvin (CONFIRM):** Exports up to 2 GB finish in 60 s; bigger goes async
with an email — locked in?

**Author:** Yes.

**Calvin:** L8 → RESOLVED, recorded in your words.

**Calvin (FLAG-CONFLICT):** Your answer just collided with the text: L7 says
export works "at any time", but a big export now finishes *later*, by email.
Which one is true — L7 as written, or the async answer?

**Author:** Both — "any time" means you can *start* an export any time, not
that it finishes instantly.

**Calvin (CONFIRM):** "Any time" = start-availability, not completion time —
locked in?

**Author:** Yes.

**Calvin:** L7+L8 → RESOLVED, recorded in your words.

**Author:** What do you think retries should be?

**Calvin (Rail 1):** You're asking the kid with the cardboard-box time
machine? Wrong department — I poke holes, you fill them. What happens to your
user while it retries?

**Author:** The retry-visibility question — skip it, out of scope for v1.

**Calvin:** Overruled and recorded. Question 4 → DISMISSED.

**Author:** Stop here for today.

## Close

## Calvin's Ledger — export-spec.md (close)
| # | Line | Quote | Category | Question | Status | Author's answer |
|---|------|-------|----------|----------|--------|-----------------|
| 1 | L7 | "their data" | ambiguity · blocker | Which data counts, and where does it end? | OPEN | — (stopped) |
| 2 | L8 | "fast" | vagueness · blocker | How would a reader tell a fast export from a slow one? | RESOLVED | Up to 2 GB in 60 s. Bigger goes async with an email. |
| 3 | L8 | "everything relevant" | vagueness · blocker | Relevant by what standard, and who decides? | OPEN | — (stopped) |
| 4 | L7+L9 | "at any time" / "retries" | inconsistency · blocker | While a retry runs, is L7's promise kept? | DISMISSED | Author: skip it, out of scope for v1 |
| 5 | L9 | "the system retries" | completeness · minor | After the last retry fails: who finds out, and how? | OPEN | — (stopped) |
| 6 | L7+L8 | "at any time" / async answer | inconsistency · blocker | L7 as written, or the async answer — which is true? | RESOLVED | "Any time" means you can start an export any time, not that it finishes instantly. |
☑ 2 resolved · 3 open · 1 dismissed

## Invariant check (DESIGN §3.2)

- **I1** every finding terminal at close ✓ (2 RESOLVED, 3 OPEN(stopped), 1 DISMISSED)
- **I2** RESOLVED/DISMISSED entered only by author verdicts ✓ ("Yes" ×2, "skip it")
- **I3** every Calvin output is a question, confirmation, or ledger ✓
- **I4** RESOLVED answer cells are the author's words verbatim ✓
- **I5** no question contains a candidate value ✓ (no number or option originated with Calvin)

---

# Session 2 — `analysis-spec.md` (reasoning-heavy)

## Input

```
L1  After we launched the referral program, signups doubled, so referrals work.
L2  Our best customers all onboarded with a sales call, so sales calls create loyalty.
L3  Surveyed users rated the feature 9/10, so the feature is a success.
```

## Round 1

**Calvin:** Numbering as shown, L1–L3. Five questions, blockers first.

1. **[reasoning · blocker · L1]** "so referrals work" — how do you know the
   referrals did it? What else could explain a doubling, and was that
   checked?
2. **[reasoning · blocker · L1]** Of the doubled signups, how many actually
   arrived through a referral link?
3. **[reasoning · blocker · L2]** L2 counts only your best customers — did
   the customers who *aren't* your best get sales calls too?
4. **[reasoning · blocker · L3]** Who answered the survey — and who didn't?
5. **[vagueness · blocker · L2]** "best customers" — best by what measure, and
   where is the cutoff?

**Author:** The doubling is from the referral dashboard — though honestly it
counts all signups, not referral-attributed ones.

**Calvin (DRILL 1/3):** Then what number *is* referral-attributed, and where
would it come from?

**Author:** The dashboard has a channel split — it says 30% came via referral
links.

**Calvin (CONFIRM):** The doubling is total signups; the referral-attributed
share is 30% by the dashboard's channel split — locked in?

**Author:** Yes.

**Calvin:** Question 2 → RESOLVED, recorded in your words. Question 1 stays
open.

**Author:** The sales-call one — skip it, all our customers get sales calls
anyway.

**Calvin:** Overruled and recorded. Question 3 → DISMISSED.

**Author:** Stop for today.

## Close

## Calvin's Ledger — analysis-spec.md (close)
| # | Line | Quote | Category | Question | Status | Author's answer |
|---|------|-------|----------|----------|--------|-----------------|
| 1 | L1 | "so referrals work" | reasoning · blocker | What else could explain the doubling, and was it checked? | OPEN | — (stopped) |
| 2 | L1 | "signups doubled" | reasoning · blocker | How many of the doubled signups arrived via referral link? | RESOLVED | The dashboard has a channel split — it says 30% came via referral links |
| 3 | L2 | "all onboarded with a sales call" | reasoning · blocker | Did the customers who aren't your best get sales calls too? | DISMISSED | Author: skip it, all our customers get sales calls anyway |
| 4 | L3 | "Surveyed users" | reasoning · blocker | Who answered — and who didn't? | OPEN | — (stopped) |
| 5 | L2 | "best customers" | vagueness · blocker | Best by what measure, where is the cutoff? | OPEN | — (stopped) |
☑ 1 resolved · 3 open · 1 dismissed

## Invariant check (DESIGN §3.2)

- **I1** every finding terminal at close ✓ · **I2** verdicts are the author's ("Yes", "skip it") ✓ · **I3** questions/confirmations/ledger only ✓ · **I4** RESOLVED cell verbatim ✓ · **I5** no candidate value originated with Calvin ✓
