---
title: Anti-outsourcing framing — README Intent section + IndyDevDan quote
date: 2026-04-24
status: draft
scope: design / content
related_issues: []
depends_on: []
supersedes: []
---

# Anti-outsourcing framing

## Goal

Make the **intent** of the repo impossible to miss on first read: this plugin
is *food for agents* that helps you **think**, not an autopilot that lets you
stop thinking.

## What changes

A new README section titled **"Intent: extend your thinking, not outsource
it."** lands immediately after the header/intro block and before
*"Why Should You Care?"*. The section:

1. Opens with a short IndyDevDan quote from
   [the video](https://www.youtube.com/watch?v=efctPj6bjCY) — the one where he
   argues against copy-pasting prompts and for understanding the primitives.
2. Gives a one-paragraph stance translating the quote into this plugin's
   concrete posture: the teach-back commands, the advisory hook, the journal,
   the Socratic catalog are all mechanisms for keeping the user in the
   driver's seat of their own design.
3. Links out to [`docs/philosophy.md`](../philosophy.md) for the long-form
   argument (already written, no change needed there).

## Quote sourcing

1. **Attempt primary source:**

    ```bash
    yt-dlp-priv.py --md 'https://www.youtube.com/watch?v=efctPj6bjCY' \
      > docs/reference-cache/indydevdan-4-layer-transcript.md
    ```

2. Grep for anchor phrases:

    ```bash
    grep -inE 'outsourc|by hand|understand|prompt jockey' \
      docs/reference-cache/indydevdan-4-layer-transcript.md
    ```

3. Extract the tightest passage that makes the anti-outsourcing point and
   quote it verbatim with attribution and a timestamp if available.

4. **Fallback if transcript retrieval fails:** commit a *clearly marked
   paraphrase* — never invent a verbatim quote. Format:

    > *"[paraphrase] — IndyDevDan, 4-Layer Architecture video*
    > *[link](https://www.youtube.com/watch?v=efctPj6bjCY), paraphrased from*
    > *memory pending transcript verification."*

   And leave a TODO comment in the README pointing at the follow-up issue.

## Stance paragraph (draft)

> This plugin is designed to be *food for your thinking*, not a substitute for
> it. Its commands ask you to articulate before they act. Its hooks nudge, but
> never block. Its journal records your reasoning so you — not a stateless
> agent — own the design. If you find yourself running
> `/four-layer-architecture:feynman-check` and wanting to skip every question,
> that's a signal worth taking seriously: either the question is wrong, or the
> part of your architecture it's pointing at is the part you understand least.

## Where the text lives

* README: new level-2 section as specified above.
* The stance paragraph is duplicated in
  [`docs/philosophy.md`](../philosophy.md) only if it adds something not
  already said there (currently it doesn't — so just link).

## Out of scope

* Rewriting philosophy.md.
* Adding the IndyDevDan quote to every skill/agent file.
  *Why:* it would be load-bearing in one place (README) and decorative
  everywhere else. Keep it load-bearing.
