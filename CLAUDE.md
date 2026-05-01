# CLAUDE.md — skills-pl

Instrukcje dla Claude Code pracującego w tym repo. Repo jest **publiczne** (github.com/dawidkotrys/skills-pl) — wszystko co commit'ujesz jest widoczne dla każdego.

## Praca z commitami

Repo jest publiczne. Commit messages widzą wszyscy — nie tylko ty.

**Zasady commit messages:**

- Stwierdzaj **co commit dodaje/zmienia** w finalnej formie. Zostaje **stan**, nie ślad procesu.
- **NIE** odwołuj się do feedbacku ("po feedbacku usera", "po uwadze że X").
- **NIE** opisuj poprzednich wersji ani powodów zmian wersji ("wcześniejsze brzmienie X brzmiało jak Y", "usunięte defensywne zwroty", "skrócona atrybucja").
- **NIE** używaj internal jargonu z naszych sesji — `Slice 1/2/3`, `Stage 1`, `BEZ push`, `Wywal`, `wywalono`.
- Bez polskich kolokwializmów — `wywal`, `pchnięcie`, `lipa`. Trzymaj neutralny, opisowy ton.
- Jeden commit = jedna logiczna zmiana. Title pod 70 znaków, body opcjonalne dla detali.

**Dobre przykłady:**

```
Add /design-checker skill (UI design system verification)
Update kronikarz with live/close modes
Refactor manager workflow: external code review by Code Manager
Add session-state slash commands
```

**Złe przykłady (NIE rób tak):**

```
Wywal 99-przyszle-rozszerzenia.md (Polish slang, internal action verb)
Slice 2: external review przez Managera (internal jargon)
README: usuń autoreklamę procesu (process leak — zdradza że było coś źle)
Po feedbacku — wcześniejsze brzmienie X brzmiało jak Y (process leak)
Initial commit: skills-pl repo (Stage 1, BEZ push) (internal flow notes)
```

## Sync source-of-truth ↔ repo

Single source of truth = `~/.claude/skills/` (skille) + `~/.claude/commands/` (slash commands) na maszynie autora. To repo to **kopia** synchronizowana manualnie.

**Workflow przy zmianach:**

1. Edytujesz w `~/.claude/skills/` lub `~/.claude/commands/` (source of truth)
2. Testujesz w realnej pracy
3. `cp` do odpowiedniego folderu w repo (`agentic-coding/skille/` lub `agentic-coding/commands/`)
4. Commit z opisowym message (per zasady wyżej)
5. `git push origin main`

**NIE** edytuj plików bezpośrednio w repo bez sync z source-of-truth — drift psuje single-source-of-truth pattern.

## Audit przed commitem

Przed każdym commitem sprawdź:

```bash
grep -rn -E "Dawid|Voicie|100M|Two Colours|Notatnik|/Users/" .
```

Repo nie powinno zawierać:

- Imion / nazw firm autora w skilach (poza explicit credit/atrybucja)
- Quality bar projektu (`$X production app`) — to per repo CLAUDE.md, nie skill content
- Absolute paths z `/Users/...` (linkuj relatywnie)
- Referencji do internal projektów / repo (Voicie, Two Colours, etc.)

Wyjątki: imię + lokacje w `LICENSE` (copyright), GitHub username w atrybucji repo.

## Atrybucja

Część skili w `agentic-coding/skille/` jest inspirowana metodologią Matt Pocock. Atrybucja w jednym miejscu — `agentic-coding/README.md` sekcja "Atrybucja" + tabela skili z kolumną Status.

**NIE dodawaj** w README:

- "PR-y mile widziane" / "kontrybucje welcome" / "feedback welcome"
- Defensywnego tłumaczenia się autorom źródeł
- Słów "autorski/autorskie" w sekcjach opisowych — lista cech mówi sama za siebie. Wyjątek: status "autorski" w tabeli skili (vs "inspired by Matt Pocock") jako neutralny fakt.

## Decisions folder

`decisions/` (gitignored) — lokalne ADR-y decyzji architektonicznych. Format zgodny z `agentic-coding/skille/grill-with-docs/ADR-FORMAT.md`. NIE commit'uj do public repo — to internal record.

## Struktura

```
skills-pl/
├── README.md                       # public-facing landing
├── LICENSE                         # MIT
├── CLAUDE.md                       # ten plik
├── .gitignore
├── agentic-coding/
│   ├── README.md                   # opis ekosystemu skili
│   ├── onboarding/                 # 7 dokumentów wprowadzających
│   ├── skille/                     # 10 skili wykonawczych
│   └── commands/                   # 4 slash commands
└── decisions/                      # gitignored — lokalne ADR-y
```
