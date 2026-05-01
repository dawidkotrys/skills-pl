# 05. Flow: duża inicjatywa

Nowy moduł, cross-cutting concern, refactor architektoniczny, integracja z external system. Coś co przekracza 1 dzień pracy lub dotyka >5 plików / >2 modułów.

## Charakterystyka

- Wiele vertical slices (3+ niezależnych issues)
- Decyzje architektoniczne do podjęcia (kwalifikują się na ADR)
- Ryzyko regresji **nie jest** ograniczone do jednego obszaru
- Możliwe parallel work (subagenty pickup-ują niezależne issues)
- Plan **nie jest** oczywisty — wymaga grillingu

Jeśli mówisz "to wprowadza nowy concept w domain" / "to dotyka jak users się logują" / "to zmienia jak data leci przez system" — to **duża inicjatywa**.

---

## Flow

```
PLANOWANIE
  1. Grill                     →  /grill-with-docs        (CONTEXT.md + ADR-y)
  2. PRD + vertical slices     →  /to-prd                 (doc/decisions/ + doc/backlog.md)
  3. Bridge na implementację   →  /code-manager (Tryb 4B) (krótki plan-most)

IMPLEMENTACJA per slice (sekwencja agent ↔ user ↔ Manager — 3 STOP-y)
  4. Agent wykonawczy implementuje → /kronikarz live (faza impl)
  5. Manual test scenariusze inline na czat → STOP #1 user QA
  6. Fix-y po user QA (jeśli były) → /kronikarz live update
  7. Agent NIE odpala /critical-code-review — zwraca raport do Managera (przez user)
  8. Manager (Opus) odpala /critical-code-review → STOP #2 user decyzje per-finding
  9. Agent fix-uje FIX'y → /kronikarz live → re-test (STOP #3 jeśli były fixy)
  10. Agent zwraca raport końcowy do Managera

MERGE GATE
  11. Manager odpala /kronikarz close → sign-off, update backlog/indeks, commit
  12. Manager pyta usera "merge?" → user "akcept" → Manager merguje
```

Krok 1-3 to **day shift** (twoja pełna uwaga, designujesz z agentem). Krok 4-9 to mix **night shift** (agent implementuje, fixuje) i **day shift** (Twoje QA + decyzje per-finding po code review). Krok 11-12 znowu **day shift** (autonomy gate).

**Filozofia 3-STOP**: "po co reviewować coś co nie działa" — implementacja musi najpierw zadziałać user-side (zasada #26 imposing taste), dopiero potem polerowanie przez external review.

**External review**: Manager (Opus) odpala `/critical-code-review` na finalnym kodzie, **nie agent wykonawczy** (Sonnet). Peer review principle, brak confirmation bias na własne decyzje.

**Autonomy gate**: Manager nie merguje sam — pyta usera "merge?", po user "akcept" → Manager `git push` + merge. Człowiek ma ostateczne słowo przed irreversible action.

---

## Krok 1 — Grill (`/grill-with-docs`)

**Najważniejszy krok.** Nie skracaj. Per zasada #5 — eager planning bez grillingu = plan który nie wytrzyma kontaktu z rzeczywistością.

Cel grillingu:

- **Shared design concept** — Ty i agent rozumiecie problem **tak samo**
- **Constraints na stole** — wszystkie ograniczenia (latency, security, compliance, backward compat) wyartykułowane
- **Edge case'y zidentyfikowane** — co jeśli null, co jeśli concurrent, co jeśli partial failure
- **CONTEXT.md zaktualizowane** — terminy domenowe które padły w grillingu zostają w słowniku
- **Decisions wstępnie zaproponowane** — które będą ADR-ami

Grill może trwać 30-60 minut rozmowy. To **nie jest** strata czasu — to inwestycja w jakość planu.

### Sygnały że grill jest "done"

- Możesz **w zwięzłej formie** opisać problem, rozwiązanie i dlaczego (nie ma dziur)
- Padły 3+ pytania na które **musiałeś dopytać** (siebie, dokumentację, domain experta)
- Zmodyfikowałeś początkową hipotezę (znak że kontakt z rzeczywistością coś dał)
- `CONTEXT.md` ma 2-5 nowych / zaktualizowanych terminów

### Sygnały że grill jest **przedwczesny** / niepełny

- Wszystko brzmi "OK", "logiczne", "powinno działać" → nie zostało przetestowane przez konfrontację
- Nie padło ani jedno "ale co jeśli..."
- Twoja początkowa hipoteza jest **identyczna** z tą z którą zaczynałeś — albo jesteś genialny, albo grill nic nie wniósł

---

## Krok 2 — PRD + vertical slices (`/to-prd`)

Po grillingu — `/to-prd` konwertuje kontekst rozmowy na **destination document**: PRD (Product Requirements Document) + rozbicie na **canon board** (zasada #11) — DAG slicesów z blocking relationships, zapisany w `doc/backlog.md`.

PRD nie jest kontraktem (zasada #4 — kod jest polem bitwy, nie spec). PRD jest **kierunkiem**:

- Cel inicjatywy (jednym zdaniem)
- User stories / scenariusze
- Constraints i non-goals (co eksplicytnie NIE jest scope)
- High-level approach
- Decyzje już podjęte (linki do ADR-ów)
- Otwarte pytania (do dorobienia w trakcie)

PRD trafia do `doc/prd/` lub `doc/initiatives/{nazwa}/prd.md`. Konkretna lokalizacja zależy od konwencji repo (sprawdź `CLAUDE.md`). Vertical slices z acceptance criteria — do `doc/backlog.md`.

### Każdy slice musi być

- **Vertical slice** (zasada #8) — UI → API → DB → tests dla jednej małej funkcjonalności end-to-end
- **Tracer bullet** (zasada #9) — działający kod, nie prototyp
- **Cienki** (zasada #10) — bias na cieńsze. Jeśli wahasz się czy podzielić — dziel.
- **Blocking relationships** explicite — `wymaga: SLICE-3`, `blokuje: SLICE-5`

### Anty-wzorzec — horizontal slicing

```
Slice 1: Wszystkie modele DB
Slice 2: Wszystkie API endpoints
Slice 3: Wszystkie UI komponenty
```

To jest **horizontal**. Każdy slice jest niemożliwy do zweryfikowania dopóki nie zrobi się wszystkich. Brak feedback loop. Catastrophe.

### Wzorzec — vertical slicing

```
Slice 1: Tracer bullet — list orders (read only, hard-coded data, minimal UI)
Slice 2: Real data fetch (DB → API → UI)
Slice 3: Filtering by status
Slice 4: Pagination
Slice 5: Search by customer name
```

Każdy slice **dostarcza** coś działającego. User po slice 1 widzi listę (nawet jeśli hard-coded). Po slice 2 widzi prawdziwe dane. Itd.

---

## Krok 3 — Bridge (`/code-manager` Tryb 4B)

Po `/to-prd` masz **plan**. Przed implementacją: bridge mode managera. Manager:

- Audituje slicesy (czy są wystarczająco cienkie? czy mają jasne acceptance criteria?)
- Identyfikuje **kandydaty na parallel pickup** (slicesy bez blocking relationships)
- Identyfikuje **collision risks** (czy slice A i slice B nie ruszą tego samego pliku?)
- Proponuje **kolejność** dla sequential pickup (jeśli parallel niemożliwe)

Output: bridge plan dla implementatora.

---

## Krok 4 — Implementacja per slice

Per slice:

- **Mała inicjatywa wewnątrz dużej** → flow jak w [04-flow-maly-task.md](./04-flow-maly-task.md), ale w kontekście większego planu
- **TDD red-green-refactor** dla każdego slice (zasada #20) — jeśli scope tego wymaga, odpal `/tdd`
- **Per Memento (#2)** — jeśli implementacja slice'a jest długa i kontekst się zaśmieca → przed `/clear` zapisz `_session-state.md` (zasada #19)

Manager (Tryb 1) dispatchuje do subagenta-implementera, weryfikuje, raportuje progress.

---

## Krok 5 — Code review (`/critical-code-review`)

Per zasada #25 — Sonnet implementuje, Opus reviewuje. Po każdym slice (lub batchu):

- `/critical-code-review` przegląda zmiany krytycznym okiem
- Identyfikuje bugi, security gaps, anti-patterny, brak edge case handling
- Generuje formalny werdykt (pass / fix needed / reject)

**To NIE jest** "ostatnia bramka przed merge" — to jest pętla. Per zasada #27 — review tworzy nowe issues, fixujesz, wracasz do review.

---

## Krok 6 — Dokumentacja (`/kronikarz`)

Po **całej inicjatywie** (nie po każdym slice):

- ADR-y dla decyzji architektonicznych podjętych w trakcie
- Update `CHANGELOG.md`
- Update `CONTEXT.md` (jeśli pojawiły się nowe terminy które przeżyły implementację)
- Update `doc/backlog.md` (przerzuć ukończone issues do archiwum)
- Update `CLAUDE.md` jeśli inicjatywa wprowadziła nowe konwencje per repo

---

## Krok 7 — QA loop

Per zasada #27 — QA rodzi nowe issues. Nie ma "QA przeszło, mergujemy".

Cykl:

1. Manualny QA (klikasz, czytasz, dotykasz)
2. Znajdujesz problem → dorzucasz issue do `doc/backlog.md`
3. Fix → wraca do code review
4. Powrót do QA
5. ... aż QA jest **really** clean

Per zasada #26 — QA to **imposing taste**, nie tylko sprawdzanie czy działa.

---

## Krok 8 — Merge / release

Per konwencje repo (sprawdź `CLAUDE.md`):

- PR base: develop / main / integration branch
- Squash / merge / rebase strategy
- Wymagane checks (CI, code review approvals)
- Release notes (jeśli releasowy projekt)

---

## Iteracje wewnątrz dużej inicjatywy

Duża inicjatywa **NIE jest** linią finishową. Może mieć fazy:

- **Faza 1 — tracer bullet** (slice 1, najbardziej ryzykowny / najbardziej learning)
- **Faza 2 — happy path** (kolejne slice'y, building feature)
- **Faza 3 — edge cases + polish** (refinement)
- **Faza 4 — performance / scaling** (jeśli zasadne)

Między fazami: stop, ocena, eventualne aktualizacje PRD (zasada #4 — kod jest polem bitwy, PRD jest kierunkiem, gotów do aktualizacji gdy implementacja ujawni assumption violation).

---

## Anty-wzorce

### Pomijanie grillingu

"Już wiem co trzeba zrobić, lecę do `/to-prd`". Tracisz okazję do testu hipotez. Plan będzie wyglądał OK ale rozsypie się przy implementacji.

### Issues które są horizontal

Patrz wyżej — każdy issue **musi** być vertical slice end-to-end.

### Pisanie wszystkich testów na początku (anti-TDD)

Per zasada #20 — to pozwala AI na cheating (hardcoded values żeby satysfakcjonować wszystkie testy). TDD red-green vertical, jeden test → jedna decyzja implementacyjna.

### Sequential plan zamiast canon board

Per zasada #11 — wymusza sekwencyjność tam gdzie nie ma faktycznych zależności. Marnuje okazję do parallel pickup.

### Brak QA loop

"Code review przeszło, mergujemy". QA nie jest opcjonalne. QA to imposing taste i pętla, nie checkpoint.

### Pisanie ADR-a po fakcie / dla każdej decyzji

Per zasada #18 — ADR-y sparingly. Hard-to-reverse + surprising + real trade-off. Reszta to commit messages.
