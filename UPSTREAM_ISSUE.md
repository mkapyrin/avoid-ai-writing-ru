I maintain a Russian adaptation of the skill and would like to request a link in the Community / Multilingual section.

**Repository:** https://github.com/mkapyrin/avoid-ai-writing-ru
**Maintainer:** mkapyrin
**Language and dialect:** Russian, standard literary register as written in Russia (ru-RU). Not tested on Russian as written in Kazakhstan, Belarus, Ukraine or emigre media, or on translated text.
**License:** MIT, based on avoid-ai-writing v3.22.0; attribution kept in LICENSE and README.

**Native-language changes**

- Lexical tiers rebuilt from Russian AI output; no English entries were translated.
- Your 1A/1B split is kept: Russian bureaucratic style (kantselyarit) and English calques are tagged separately as style, since people write that way too.
- Reveal-by-negation ("Это не X. Это Y.") is its own P1 rule; plain factual correction is a must-not-fire case.
- Dash rule: Russian grammar requires dashes in several positions, so grammatical dashes stay in the author's form and only theatrical ones are flagged (P2). The dash character is not treated as evidence of authorship. Stricter mechanics, such as a no-dash rule, live in an optional house-style file, similar to your `--style` layer.
- The skill classifies input as machine-written, mixed or human and sets edit depth accordingly, with a claim-preservation check for machine-written text.
- An `official` profile for contracts, orders, minutes and academic text; niche vocabularies plug in as extension files.

**Evidence and limitations**

- Vocabulary tables are editorial hypotheses from one maintainer's practice, not corpus measurements.
- `examples/` has 54 hand-written cases (21 should fire, 33 must stay clean) across registers. They illustrate intended behaviour; they are not a benchmark.
- Two held-out runs (20 unseen texts each; previous version, candidate and a plain prompt; three editors from two model families; blind LLM judges; a blind check by the maintainer) tested v3.3 and v3.4. Neither passed its pre-registered rule. In the second run LLM judges preferred v3.4 for every editor, but the maintainer picked the plain prompt in 7 of 12 cases. The current v4.0 has not been evaluated on held-out text yet. Reports: [2026-11-21](https://github.com/mkapyrin/avoid-ai-writing-ru/blob/main/evals/reports/2026-11-21-heldout.md), [2026-11-22](https://github.com/mkapyrin/avoid-ai-writing-ru/blob/main/evals/reports/2026-11-22-heldout.md). Known limitations: [LIMITATIONS.md](https://github.com/mkapyrin/avoid-ai-writing-ru/blob/main/LIMITATIONS.md).

**Where to report problems:** https://github.com/mkapyrin/avoid-ai-writing-ru/issues (Russian or English).
