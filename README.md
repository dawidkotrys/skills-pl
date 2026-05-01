# skills-pl

Repozytorium skili dla Claude Code w języku polskim. Zbiór modułów rozszerzających możliwości Claude Code o opinionated workflow do agentic coding, planowania, code review, refactoringu i prowadzenia projektu w długim horyzoncie.

## Kategorie

- **[agentic-coding/](./agentic-coding/)** — ekosystem skili + slash commands do pracy z Claude Code metodą agentic coding. Część zasad inspirowana Matt Pocock — atrybucja w [agentic-coding/README.md](./agentic-coding/README.md).

W przyszłości mogą dojść inne kategorie (np. `seo/`, `marketing/`, `domain-specific/`).

## Dla kogo to jest

Sweet spot:

- **Solo dev / mały zespół** pracujący z Claude Code
- **Indie projekty / startupy** gdzie nie ma narzuconego workflow przez korporacyjne narzędzia
- Ludzie którzy chcą **opinionated default** zamiast budować własny workflow od zera

Co jest **uniwersalne** (działa wszędzie):

- 28 zasad metodologii (vertical slicing, deep modules, grilling, Clear>Compact, build feedback loop FIRST, …)
- Persistent kontekst na dysku (CONTEXT.md, ADR-y, backlog.md, kronika)

Co jest **opinionated** (możesz nie lubić):

- **Workflow z 3 STOP-ami** — implementacja → user QA → external code review (przez Code Managera, nie samego implementera) → re-test → kronikarz close → autonomy gate "merge?/akcept" → merge przez Managera
- **Markdown-first trackery** — `doc/backlog.md`, `doc/decisions/` zamiast GitHub Issues / Linear / Jira
- **Manager values** — komunikacja agent→manager bez presji (research-backed: badanie Anthropic 2026-04-02 pokazuje że presja → reward hacking)
- **Polski jako język domyślny** w skilach (kod / commit messages / ADR-y mogą być w dowolnym języku)
- **Struktura `doc/`** zamiast `docs/`

Czego **NIE oczekuj out-of-the-box**:

- Linear / Jira / GitHub Issues integration
- Native angielska wersja — kanon nazw skili pozostaje (`/to-prd`, `/tdd`), ale instrukcje są po polsku

## Filozofia

**„Bad codebase = bad agent output"** (zasada #16). Jakość outputu AI jest ograniczona jakością twoich feedback loops, structure i persistent kontekstu. Te skille **nie** są o "magicznych promptach" — są o budowie codebase, w którym agent może działać efektywnie.

Kluczowe założenia:

1. **Kod jest polem bitwy, NIE specs** — implementacja zmusza decyzje, których spec nie pokazuje
2. **Vertical slices > horizontal slices** — zawsze przekrój przez wszystkie warstwy
3. **Clear > Compact** — `/clear` reset jest tańszy niż `/compact` z zaśmieconym kontekstem (plus `/save-session-*` + `/restore-session-*` slash commands jeśli musisz utrzymać kontekst)
4. **Persistent kontekst na dysku** — sesja jest ulotna, dysk jest trwały (Memento problem)
5. **Po co reviewować coś co nie działa** — najpierw user QA (imposing taste), potem external code review przez Managera, kronika na końcu
6. **Implementer pulls, reviewer pushes** — Code Manager (Opus) reviewuje pracę agenta wykonawczego (Sonnet), nie sam siebie

Pełna lista 28 zasad: [agentic-coding/onboarding/02-zasady-metodologii.md](./agentic-coding/onboarding/02-zasady-metodologii.md).

## Jak zacząć

1. Przeczytaj **[agentic-coding/onboarding/](./agentic-coding/onboarding/)** — 7 dokumentów wprowadzających (fundamenty, zasady, konwencje, flow per typ taska, instalacja).
2. Zainstaluj skille (`~/.claude/skills/`) i slash commands (`~/.claude/commands/`) — pełna instrukcja w [07-instalacja.md](./agentic-coding/onboarding/07-instalacja.md).
3. Pracuj z metodologią — odpalaj skille kontekstowo (`/grill-with-docs`, `/to-prd`, `/code-manager`, `/diagnose`, etc.) zgodnie z flow w [04-flow-maly-task.md](./agentic-coding/onboarding/04-flow-maly-task.md), [05-flow-duza-inicjatywa.md](./agentic-coding/onboarding/05-flow-duza-inicjatywa.md), [06-flow-bug.md](./agentic-coding/onboarding/06-flow-bug.md).

## Sync z `~/.claude/skills/`

Single source of truth = `~/.claude/skills/` (skille) + `~/.claude/commands/` (slash commands) na maszynie autora. To repo to **kopia** synchronizowana manualnie. Jeśli widzisz różnicę między repo a wersją u autora — repo może być chwilowo behind.

## Licencja

MIT — patrz [LICENSE](./LICENSE). Możesz forkować, modyfikować, używać komercyjnie, publikować pochodne.
