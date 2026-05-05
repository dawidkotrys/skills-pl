# agentic-coding/

Ekosystem skili do pracy z Claude Code metodą agentic coding. Pokrywa pełny cykl: od grillingu pomysłu, przez planowanie i slicing, implementację, code review, aż po dokumentację zmian i utrzymanie persistent kontekstu.

## Co tu jest

```
agentic-coding/
├── onboarding/                  # 9 dokumentów wprowadzających (główny flow + warianty)
├── skille/                      # 10 skili wykonawczych
└── commands/                    # 4 slash commands do session-state save/restore
```

### Onboarding (zacznij tu)

Sugerowana kolejność:

1. [01-fundamenty.md](./onboarding/01-fundamenty.md) — LLM constraints, smart/dumb zone, Memento problem, Clear>Compact
2. [02-zasady-metodologii.md](./onboarding/02-zasady-metodologii.md) — 10 fundamentalnych zasad agentic coding
3. [03-pliki-projektu.md](./onboarding/03-pliki-projektu.md) — kluczowe pliki projektu: `CLAUDE.md`, `CONTEXT.md`, `doc/plans/<slug>/`, `doc/decisions/`, `doc/backlog.md`
4. **[00-glowny-flow.md](./onboarding/00-glowny-flow.md)** — choreografia Manager ↔ User ↔ Executor (sequence diagram, tabela komend, save/restore session)
5. [04-flow-maly-task.md](./onboarding/04-flow-maly-task.md) — bug fix, mała feature, drobny refactor
6. [04a-rola-agenta-wykonawczego.md](./onboarding/04a-rola-agenta-wykonawczego.md) — co dostajesz, co robisz, czego nie robisz (counterpart code-manager z perspektywy executora)
7. [05-flow-duza-inicjatywa.md](./onboarding/05-flow-duza-inicjatywa.md) — nowy moduł, cross-cutting concern
8. [06-flow-bug.md](./onboarding/06-flow-bug.md) — diagnose loop, build feedback FIRST
9. [07-instalacja.md](./onboarding/07-instalacja.md) — jak zainstalować skille

**Pierwszy raz?** 01-03 (fundamenty/zasady/konwencje), potem **00** dla pełnego obrazu choreografii, dopiero potem warianty per skala (04, 05, 06) i 04a (rola executora).

### Skille wykonawcze

| Skill | Cel | Status |
|---|---|---|
| `grill` | Grilling pomysłu z budowaniem persistent kontekstu (CONTEXT.md, ADR-y) | autorski (inspired by Matt Pocock) |
| `to-prd` | Konwersja kontekstu rozmowy na folder inicjatywy `doc/plans/<slug>/` z `prd.md` (vision + slices) i scaffold `backlog.md` | autorski (inspired by Matt Pocock) |
| `critical-prd-review` | Krytyczny audyt PRD przed task breakdown'em — security/scalability/architecture lens. Pre-code review na poziomie wymagań. Werdykt Needs revision / Almost ready / Ready + feedback dla agenta-autora PRD do iteracji | autorski |
| `to-tasks` | Task breakdown bieżącego slice'a — manager invoke per slice w pętli, rozbija slice na 3-7 granularnych tasków z file targets + acceptance | autorski |
| `diagnose` | Zdyscyplinowana pętla diagnostyczna dla bugów i regresji | inspired by Matt Pocock |
| `repo-onboarding` | Onboarding nowego repo: CLAUDE.md, CONTEXT.md, doc/ structure | autorski |
| `code-manager` | Bird's-eye manager: planowanie, dispatch do subagentów, weryfikacja, archive po close inicjatywy | autorski |
| `critical-code-review` | Krytyczne code review przez doświadczonego architekta | autorski |
| `design-checker` | Weryfikacja zgodności kodu UI z design systemem (kolory, typografia, spacing, radius) | autorski |
| `kronikarz` | Dokumentacja zmian, ADR creation, update CHANGELOG / backlog | autorski |

### Slash commands (session-state)

[`commands/`](./commands/) — 4 slash commands do save/restore kontekstu sesji przed/po `/clear` (Memento problem):

- `/save-session-manager` + `/restore-session-manager` — strategy mode Code Managera
- `/save-session-agent` + `/restore-session-agent` — universal (kod / copy / oferta / research)

Komendy zapisują do `doc/session/`, restore usuwa plik po wczytaniu (ulotne). Patrz [commands/README.md](./commands/README.md).

## Atrybucja

Skille w tabeli oznaczone jako *inspired by Matt Pocock* są polskimi adaptacjami jego oryginalnych skili — credit: [Matt Pocock](https://www.mattpocock.com/).

Większość zasad metodologii ma korzenie w klasykach software design — Ousterhout (*Philosophy of Software Design*), Fowler (*Refactoring*), Hunt/Thomas (*Pragmatic Programmer*), Brooks (*Design of Design*). LLM-y są nowe, problemy są stare.

## Filozofia per skill

Każdy skill respektuje uniwersalne zasady (patrz [02-zasady-metodologii.md](./onboarding/02-zasady-metodologii.md)):

- **Vertical slicing** — `/to-prd` rozbija destination document na cienkie slicesy end-to-end
- **Grill > eager planning** — `/grill` przed `/to-prd` (Manager wskazuje handoff)
- **Per-slice planning loop** — `/to-tasks` rozbija JEDEN slice na taski przed startem agenta, kolejny slice rozpisuje się dopiero po close poprzedniego (manager-driven cadence, nie wszystko z góry)
- **Persistent kontekst** — `/repo-onboarding` zakłada `CONTEXT.md`, `/kronikarz` żyje przez cały lifecycle taska (live mode)
- **Build feedback loop FIRST** — `/diagnose` Faza 1 to reprodukcja w fast/deterministic loop
- **External review na dwóch poziomach** — `/critical-prd-review` na poziomie wymagań (po `/to-prd`, przed `/to-tasks`); `/critical-code-review` na poziomie kodu (po STOP #1 user QA, przed merge). Oba odpalane przez Code Managera (Opus), NIE przez agenta wykonawczego (Sonnet) — peer review principle. PRD review łapie luki bezpieczeństwa/skalowania **zanim** powstanie kod
- **Po co reviewować coś co nie działa** — najpierw user QA (zasada #9 imposing taste), potem external review, kronikarz close na końcu
- **Komunikacja bez presji** — `code-manager/references/manager-values.md` (research-backed: badanie Anthropic 2026-04-02)
- **Autonomy gate** — Manager merguje, ale po user "akcept" (zasada #10: crucial decisions z udziałem człowieka)
