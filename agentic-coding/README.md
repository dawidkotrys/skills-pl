# agentic-coding/

Ekosystem skili do pracy z Claude Code metodą agentic coding. Pokrywa pełny cykl: od grillingu pomysłu, przez planowanie i slicing, implementację, code review, aż po dokumentację zmian i utrzymanie persistent kontekstu.

## Co tu jest

```
agentic-coding/
├── onboarding/                  # 4 dokumenty wprowadzające (proces, zasady, pliki, instalacja)
├── skille/                      # 10 skili wykonawczych
└── commands/                    # 4 slash commands do session-state save/restore
```

### Onboarding (zacznij tu)

Sugerowana kolejność:

1. **[00-start.md](./onboarding/00-start.md)** — główny przewodnik procesu: aktorzy, Twoje cztery punkty decyzyjne, trzy ścieżki wg skali (mały task / duża inicjatywa / bug).
2. [02-zasady-metodologii.md](./onboarding/02-zasady-metodologii.md) — 10 fundamentalnych zasad, które stoją za procesem.
3. [03-pliki-projektu.md](./onboarding/03-pliki-projektu.md) — kluczowe pliki na dysku: `CLAUDE.md`, `CONTEXT.md`, `doc/plans/`, `doc/decisions/`, `doc/backlog.md`, kroniki.
4. [07-instalacja.md](./onboarding/07-instalacja.md) — jak zainstalować skille.

**Pierwszy raz?** Przeczytaj **00-start** dla obrazu całości, potem 02 (zasady) i 03 (pliki). Szczegóły każdego etapu agent zna ze skilli i sam Cię przez nie poprowadzi.

### Skille wykonawcze

| Skill | Cel |
|---|---|
| `grill` | Grilling pomysłu z budowaniem persistent kontekstu (CONTEXT.md, ADR-y) |
| `to-prd` | Konwersja kontekstu rozmowy na folder inicjatywy `doc/plans/<slug>/` z `prd.md` (vision + slices) i scaffold `backlog.md` |
| `critical-prd-review` | Krytyczny audyt PRD przed task breakdown'em — security/scalability/architecture lens. Pre-code review na poziomie wymagań. Werdykt Needs revision / Almost ready / Ready + feedback dla agenta-autora PRD do iteracji |
| `to-tasks` | Task breakdown bieżącego slice'a — manager invoke per slice w pętli, rozbija slice na 3-7 granularnych tasków z file targets + acceptance |
| `diagnose` | Zdyscyplinowana pętla diagnostyczna dla bugów i regresji |
| `repo-onboarding` | Onboarding nowego repo: CLAUDE.md, CONTEXT.md, doc/ structure |
| `code-manager` | Bird's-eye manager: planowanie, dispatch do subagentów, weryfikacja, archive po close inicjatywy |
| `critical-code-review` | Krytyczne code review przez doświadczonego architekta |
| `design-checker` | Weryfikacja zgodności kodu UI z design systemem (kolory, typografia, spacing, radius) |
| `kronikarz` | Dokumentacja zmian, ADR creation, update CHANGELOG / backlog |

### Slash commands (session-state)

[`commands/`](./commands/) — 4 slash commands do save/restore kontekstu sesji przed/po `/clear` (Memento problem):

- `/save-session-manager` + `/restore-session-manager` — strategy mode Code Managera
- `/save-session-agent` + `/restore-session-agent` — universal (kod / copy / oferta / research)

Komendy zapisują do `doc/session/`, restore archiwizuje plik po wczytaniu. Patrz [commands/README.md](./commands/README.md).

---

Część skilli bazuje na [mattpocock/skills](https://github.com/mattpocock/skills) (MIT).

## Filozofia per skill

Każdy skill respektuje uniwersalne zasady (patrz [02-zasady-metodologii.md](./onboarding/02-zasady-metodologii.md)):

- **Vertical slicing** — `/to-prd` rozbija destination document na cienkie slicesy end-to-end
- **Grill > eager planning** — `/grill` przed `/to-prd` (Manager wskazuje handoff)
- **Per-slice planning loop** — `/to-tasks` rozbija JEDEN slice na taski przed startem agenta, kolejny slice rozpisuje się dopiero po close poprzedniego (manager-driven cadence, nie wszystko z góry)
- **Persistent kontekst** — `/repo-onboarding` zakłada `CONTEXT.md`, `/kronikarz` żyje przez cały lifecycle taska (live mode)
- **Build feedback loop FIRST** — `/diagnose` Faza 1 to reprodukcja w fast/deterministic loop
- **External review na dwóch poziomach** — `/critical-prd-review` na poziomie wymagań (po `/to-prd`, przed `/to-tasks`); `/critical-code-review` na poziomie kodu (po STOP #1 user QA, przed merge). Oba odpala Code Manager w świeżym subagencie, NIE agent wykonawczy — peer review principle (autor nie recenzuje własnej pracy). PRD review łapie luki bezpieczeństwa/skalowania **zanim** powstanie kod
- **Po co reviewować coś co nie działa** — najpierw user QA (zasada #9 imposing taste), potem external review, kronikarz close na końcu
- **Komunikacja bez presji** — `code-manager/references/manager-values.md` (research-backed: badanie Anthropic 2026-04-02)
- **Autonomy gate** — Manager merguje, ale po user "akcept" (zasada #10: crucial decisions z udziałem człowieka)
