# avoid-ai-writing-ru

Скилл для AI-агентов, который находит в русском тексте следы машинной генерации и канцелярит и переписывает текст живым языком. Русская адаптация [avoid-ai-writing](https://github.com/conorbronsdon/avoid-ai-writing) Конора Бронсдона.

Работает в Claude Code, OpenClaw, Cursor и любом агенте, который читает формат [`SKILL.md`](https://agentskills.io). Внешних зависимостей нет.

[English summary below](#english-summary)

## Пример

**Было:**

> Конечно! Вот пост для вашего канала.
>
> В современном мире кофейни -- это не просто места, где пьют кофе. Это пространства для общения. Кофейня «Зерно» открывает новую главу в истории казанского кофе: с 1 декабря мы запускаем завтраки с 7 утра. Важно отметить, что меню включает уникальные, авторские и сезонные позиции. Более того, гостей ждёт бесшовный сервис и комплексный подход к качеству. Будущее покажет, как это изменит утро горожан!
>
> #кофе #Казань #утро #завтрак #бизнес #вдохновение #жизнь

**Стало:**

> С 1 декабря «Зерно» открывается в 7 утра: запускаем завтраки. В меню есть авторские и сезонные позиции.
>
> #кофе #Казань #завтрак

**Что нашёл скилл** (режим detect):

| Приоритет | Правило | Фрагмент |
|---|---|---|
| P0 | `chatbot` | «Конечно! Вот пост для вашего канала.» |
| P0 | `significance-inflation` | «открывает новую главу в истории казанского кофе» |
| P1 | `negation-reveal` | «кофейни -- это не просто места… Это пространства для общения» |
| P1 | `lex-1a` | «В современном мире», «Важно отметить», «уникальные», «бесшовный», «комплексный подход» |
| P1 | `hashtag-spam` | семь тегов, из них четыре общих |
| P2 | `dash` | «--» вместо тире |
| P2 | `triple` | «уникальные, авторские и сезонные» |
| P2 | `lex-2` | «Более того» |
| P2 | `generic-conclusion` | «Будущее покажет…» |

Переписанный текст не содержит ничего, чего не было в исходнике: скилл вычитает, а факты и мнения не добавляет.

## Чем отличается от английского оригинала

Английский словарь upstream (`delve`, `tapestry`, `leverage`) в русский не переносится, поэтому словарь собран заново по русским AI-текстам. Структурные правила (ритм, тест перестановки абзацев, порог полного переписывания) перенесены почти без изменений. Своё в русской версии:

- **Канцелярит и кальки с английского**: отглагольные существительные, цепочки родительных падежей, «является», «играет ключевую роль». Помечаются отдельно от AI-маркеров (уровень 1B), потому что так пишут и люди.
- **Драматическое отрицание** «Это не X. Это Y.» как отдельное правило (P1). Фактическое уточнение («не во вторник, а в среду») под него не попадает.
- **Правило тире.** В русском тире входит в пунктуацию, поэтому грамматическое тире остаётся в той форме, какую выбрал автор: длинное, среднее или дефис с пробелами. Флагуются театральные тире: драматическая пауза, вставка вместо запятой, тире почти в каждом абзаце.
- **Домашний стиль.** Личные и редакционные механики, например запрет тире, задаются отдельным файлом и подключаются по желанию. Пример: [`examples/styles/no-dash.md`](examples/styles/no-dash.md).
- **Профиль `official`** для договоров, приказов, протоколов и академических текстов, где канцелярит - норма жанра.
- **Расширения**: нишевые словари и тезаурусы подключаются отдельными файлами (см. [`references/README.md`](references/README.md)).

## Установка

**Claude Code:**

```bash
git clone https://github.com/mkapyrin/avoid-ai-writing-ru ~/.claude/skills/avoid-ai-writing-ru
```

**OpenClaw:**

```bash
git clone https://github.com/mkapyrin/avoid-ai-writing-ru ~/.openclaw/skills/avoid-ai-writing-ru
```

**Cursor и другие агенты:** скопируйте `SKILL.md` в папку правил или скиллов и сошлитесь на него в инструкциях проекта.

**Claude.ai:** упакуйте папку в ZIP и загрузите в разделе скиллов настроек.

## Как вызвать

Попросите агента:

- «убери следы ИИ из этого поста»
- «проверь текст на машинность»
- «убери канцелярит»
- «перепиши по-человечески»

Режимы:

| Режим | Что делает | Как включить |
|---|---|---|
| `rewrite` | переписывает, выводит финальный текст | по умолчанию |
| `detect` | только помечает маркеры по приоритету P0/P1/P2 | «найди», «проверь», «аудит», «просто пометь» |
| `edit` | правит файл на месте | назвать файл: «почисти draft.md» |

Чтобы увидеть отчёт вместе с переписанным текстом, добавьте «покажи правки».

Сначала скилл определяет тип исходника: машинный текст (A), смешанный (B) или живой (C). В машинном тексте убираются все приёмы, а каждое утверждение, факт и образ остаются; во втором проходе это сверяется с исходником. В смешанном так же правятся только машинные куски. В живом исправляются тире, канцелярит и ошибки внутри предложений, голос, повторы и приёмы автора остаются.

Профиль текста определяется автоматически (`social`, `blog`, `technical-blog`, `official`, `personal`, `email-friendly`, `creative`, `casual`), но его можно назвать явно: «проверь как официальный документ».

## Насколько этому верить

Правила основаны на редакторском опыте. Частоты на русском корпусе не измерялись, словари служат рабочими гипотезами. Версии сравнивались слепым тестом на 25 текстах разных жанров и двумя прогонами на отложенных выборках по 20 новых текстов. Судьи-модели ставят текущие правила выше простого промпта, слепая проверка человеком пока выбирает простой промпт. Результаты и ограничения описаны в `LIMITATIONS.md` и `evals/reports/`. Подробно о доказательной базе, вариантах русского, ложных срабатываниях правила тире и художественном тексте написано в [`LIMITATIONS.md`](LIMITATIONS.md).

Совпадение с маркерами не доказывает, что текст написал AI. Не используйте скилл для решений о людях.

Примеры, на которых правила должны срабатывать и на которых не должны, лежат в [`examples/`](examples/).

## Ошибки и предложения

Если скилл пометил нормальный человеческий текст, [откройте issue](https://github.com/mkapyrin/avoid-ai-writing-ru/issues/new/choose) по шаблону «Ложное срабатывание». Как предложить правило или расширение, описано в [`CONTRIBUTING.md`](CONTRIBUTING.md).

## Лицензия

MIT. Адаптация [avoid-ai-writing](https://github.com/conorbronsdon/avoid-ai-writing) (MIT, Conor Bronsdon), основа: v3.22.0. Upstream этот репозиторий не поддерживает и за его правила не отвечает.

---

## English summary

A Russian adaptation of [avoid-ai-writing](https://github.com/conorbronsdon/avoid-ai-writing): an agent skill that flags and rewrites AI-writing tells in Russian prose.

- **Language and register:** standard literary Russian (ru-RU). Profiles cover social posts, blogs, technical articles, official/legal/academic documents, personal letters, fiction and chat.
- **Native-language changes:** lexical tiers were rebuilt from Russian AI output rather than translated. Added rules cover Russian bureaucratese (kantselyarit) and English calques, the "Это не X. Это Y." reveal pattern, and a dash rule that keeps grammatical dashes in whatever form the author used and flags only theatrical ones. Stricter mechanics such as a no-dash rule live in an optional house-style file (`examples/styles/`). Structural rules from upstream carry over largely unchanged. Niche vocabularies and thesauri plug in as separate extension files.
- **Adaptive depth:** the skill first classifies the input as machine-written, mixed, or human, then edits fully, by parts, or minimally.
- **Evidence:** the vocabulary tables are editorial hypotheses from one maintainer's editing practice, not corpus measurements. Versions were compared in four blind rounds on 25 private texts across genres (LLM executors and judges, one judge per pair); the adaptive version won 17 of 26 pairs against the previous one, 4 losses, 5 ties. That sample was also used for tuning, so treat it as a development-set result. Two held-out runs followed (20 unseen texts each; previous version, candidate and a plain prompt; three editors from two model families; blind LLM judges; a blind check by the maintainer). In the second run LLM judges ranked the candidate first for every editor, with a third of the previous version's fact losses, but the maintainer picked the plain prompt in 7 of 12 cases and the candidate in none. Neither run passed its pre-registered decision rule. `examples/` holds hand-written cases that should fire and cases that must stay clean, across registers. See `LIMITATIONS.md` for known false positives (the boundary between grammatical and theatrical dashes, regional Russian, stylized fiction).
- **Maintainer:** [mkapyrin](https://github.com/mkapyrin). Issues in Russian or English.
