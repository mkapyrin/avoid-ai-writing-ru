<!--
Draft of the community-link request for conorbronsdon/avoid-ai-writing.
Not posted. Post only after the repository is public, then delete this file.
Command (run manually after review):
  gh issue create -R conorbronsdon/avoid-ai-writing --title "Community link: Russian adaptation (avoid-ai-writing-ru)" --body-file UPSTREAM_ISSUE.md
-->

I maintain a Russian adaptation of the skill and would like to request a link in the Community / Multilingual section.

**Repository:** https://github.com/mkapyrin/avoid-ai-writing-ru
**Maintainer:** mkapyrin
**Language and dialect:** Russian, standard literary register as written in Russia (ru-RU). Not tested on Russian as written in Kazakhstan, Belarus, Ukraine or emigre media, or on translated text.
**Based on:** avoid-ai-writing v3.22.0, MIT, attribution kept in LICENSE and README.

**Native-language changes**

- Lexical tiers were rebuilt from Russian AI output. None of the English entries were translated; words like "delve" or "tapestry" have no stable Russian counterpart.
- Your 1A/1B split is kept and matters more in Russian: bureaucratic style (kantselyarit) and English calques (nominalised verbs, genitive chains, "является", "играет ключевую роль") are tagged separately as style, since people write that way too.
- A dedicated P1 rule for the reveal-by-negation frame "Это не X. Это Y." Plain factual correction ("не во вторник, а в среду") is a documented must-not-fire case.
- Dash rule: Russian grammar requires dashes in several positions (between subject and predicate, for an omitted word, in dialogue), so grammatical dashes stay in whatever form the author used: em dash, en dash or spaced hyphen. Only theatrical dashes are flagged (dramatic pauses, asides that need a comma, a dash in nearly every paragraph), at P2. The dash character is not treated as evidence of authorship.
- Optional house style: personal or editorial mechanics, such as a no-dash rule, live in a separate style file, similar to your `--style` layer. An example ships in `examples/styles/`.
- An `official` profile for contracts, orders, minutes and academic text, where kantselyarit is the norm of the genre.
- Niche vocabularies and thesauri are kept out of the core and plug in as extension files with a documented format.
- Structural rules (rhythm, paragraph reshuffle test, treadmill, rewrite threshold) carry over largely unchanged.

**Evidence and limitations**

- The vocabulary tables are editorial hypotheses from one maintainer's editing practice. There is no Russian corpus behind them and no measured precision or recall.
- `examples/` contains 54 hand-written cases: 21 that should fire and 33 that must stay clean, across official/legal, academic, journalism, conversation, technical writing, fiction dialogue and factual contrast. They illustrate intended behaviour; they are not a benchmark.
- Known false positives are documented in LIMITATIONS.md: the grammatical/theatrical dash boundary; regional Russian; stylised fiction.
- Versions were compared in four blind A/B rounds on 25 private texts from one author's archive (posts, lyric prose, announcements, reports, articles, participant reviews), with LLM executors and one blind LLM judge per pair. The current version classifies input as machine-written, mixed or human and adjusts edit depth; it won 17 of 26 pairs, lost 4, tied 5 against the previous release. This is a development-set result: versions 3.1-3.3 were tuned on the same 25 texts, with no held-out split, one niche, one model family, one judge per pair and no human adjudication. See LIMITATIONS.md.
- A held-out run followed (20 unseen texts; baseline, candidate and a plain prompt; Claude Opus, Claude Sonnet and an OpenAI-family model as editors; blind LLM judges). The candidate did not pass the pre-registered rule: it beats the previous version on human-written text and misses fewer tells, but loses more facts and invents more than the plain prompt, mostly on fully machine-written input. A blind check by the maintainer on 9 cases picked the plain prompt 4 times, the previous version 3 times and the candidate once, agreeing with the LLM judge in 1 of 8 decided cases. Report: evals/reports/2026-11-21-heldout.md.
- A second held-out run used 20 other unseen texts (previous version, candidate, plain prompt; same editors). LLM judges ranked the candidate first for every editor, with about a third of the previous version's fact losses. It still failed the pre-registered rule (more invented content than the plain prompt for two editors, more unnecessary edits than the previous version for one). A blind check by the maintainer on 12 cases picked the plain prompt 7 times, the previous version twice and the candidate never; judges and maintainer agreed in 4 of 9 decided cases. The maintainer preferred visibly edited output, while the candidate often left text almost unchanged. Report: evals/reports/2026-11-22-heldout.md. Both human checks were done by one rater, who is also the maintainer.
- These runs used v3.3 and v3.4. Version 4.0 moved the maintainer's personal no-dash rule into an optional house style and has not been evaluated on held-out text yet.
- The README states that matches are signals, not proof of authorship.

**Where to report problems:** https://github.com/mkapyrin/avoid-ai-writing-ru/issues (Russian or English).
