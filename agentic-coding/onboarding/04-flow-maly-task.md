# 04. Flow: mały task

Bug fix, drobny refactor, mała zmiana funkcjonalna. Coś co zmieści się w 1-2 godzinach pracy.

## Charakterystyka

- 1 vertical slice (jedna funkcja end-to-end)
- 1-3 plików zmienionych typowo
- Ryzyko regresji ograniczone do jednego obszaru
- Brak nowej architektury, nowych patternów, nowych zależności
- Decyzje implementacyjne **proste** (jest jasne CO trzeba zrobić)

Jeśli **nie jesteś pewien czy to mały task** — to znaczy że to nie mały task. Idź do [05-flow-duza-inicjatywa.md](./05-flow-duza-inicjatywa.md).

---

## Flow

Dwie ścieżki — wybór zależy od skali:

### Ścieżka A — bardzo mały task (typo, jednoplikowa poprawka)

```
1. Plan = jedno zdanie w wiadomości (default agent)
2. Implementacja → bezpośrednia
3. Weryfikacja → 1 manual click + 1 test jeśli istnieje
4. Commit + push (kronikarz pomijasz, commit message wystarcza)
```

### Ścieżka B — mały ale nietrywialny task (przez `/code-manager`)

```
1. (opcjonalnie) Grill           →  /grill-with-docs       jeśli problem niejasny
2. Plan / dispatch               →  /code-manager (Tryb 4A — full plan mode)
3. Implementacja                 →  agent wykonawczy → /kronikarz live (faza impl)
4. Manual test inline na czat    →  STOP #1 user QA
5. Fix-y po user QA jeśli były   →  /kronikarz live update
6. External code review          →  Manager (Opus) odpala /critical-code-review
                                    → STOP #2 user decyzje per-finding (FIX/BACKLOG/SKIP)
7. Fix-y z review jeśli były     →  re-test → STOP #3 user re-weryfikacja
                                    (pomijasz #3 jeśli zero fix-ów z review)
8. Manager close                 →  /kronikarz close (sign-off, update backlog/indeks, commit)
9. Autonomy gate                 →  Manager: "merge?" → user: "akcept" → Manager merguje
```

**Filozofia 3-STOP:** "po co reviewować coś co nie działa". Implementacja musi najpierw zadziałać user-side (zasada #26 — imposing taste), dopiero potem polerowanie przez external code review.

**Manager owner of remote/main:** agent wykonawczy NIE pushuje, NIE merguje, NIE odpala `/critical-code-review` ani `/kronikarz close` — to robi Manager (peer review principle, ADR-0002).

---

## Krok 1 — grill (opcjonalny)

Tylko gdy:

- Bug jest **tajemniczy** — nie wiesz CO go powoduje, dlaczego go widzisz, jakie są edge case'y
- Refactor jest **subtelny** — łatwo wprowadzić regres, trzeba ustalić scope
- Mały task **dotyka** krytycznej części kodu (auth, payments, data integrity)

Wtedy: `/grill-with-docs` lub po prostu rozmowa z domyślnym agentem dopóki nie masz **shared design concept** (zasada #5).

Pytaj o:

- Reprodukcję (kiedy to się dzieje? na jakich danych?)
- Edge case'y (co jeśli X jest null? co jeśli concurrent?)
- Side effects (czy fix nie zepsuje czegoś innego?)
- Test który złapie regression w przyszłości

---

## Krok 2 — plan

Plan dla małego taska to **jedno zdanie + 2-3 bullet pointy**:

```
Fix: timeout w /api/orders/:id gdy klient nie ma zamówień (powinno zwracać [], nie 500).

- Edytuj src/api/orders.ts:42 — handle empty result
- Dodaj test integracyjny w src/api/orders.test.ts
- Manual smoke test: GET /api/orders/new-customer-id
```

Nie potrzebujesz pełnego PRD, nie potrzebujesz `/to-prd`. To jest mały task.

---

## Krok 3 — implementacja

### Opcja A — default agent

Najprostsze. Mówisz agentowi co zrobić, on robi. Działa dla rzeczy oczywistych.

### Opcja B — `/code-manager` Tryb 4A (full plan mode)

Gdy chcesz mieć kontrolę nad **dispatch + weryfikacją + external review + merge gate** — Manager planuje, dispatchuje do agenta-implementera, odpala `/critical-code-review` po user QA, finalizuje przez `/kronikarz close`, mergeuje po user "akcept". Przydatne gdy:

- Plan ma 3+ kroków
- Chcesz zostać w bird's-eye view (zasada Clear>Compact — Manager nie zaśmieca swojego kontekstu detalami implementacji)
- Multitaskujesz (Manager pilnuje, ty robisz coś innego)
- Chcesz peer review (external — Manager-Opus na pracę agenta-Sonnet)

W tej opcji obowiązuje pełna sekwencja **3-STOP** (Ścieżka B w sekcji "Flow" wyżej).

### TDD czy nie

Per zasada #20 — TDD jest fajne, ale dla **bardzo** małego taska (typo, kosmetyka) overhead jest większy niż wartość. Heurystyka:

- **Zmiana behavior obserwowalnego z zewnątrz** → napisz test (red), zaimplementuj (green), refactor
- **Zmiana czysto kosmetyczna / refactor preserving behavior** → uruchom istniejące testy, jeśli przejdą — done

Jeśli chcesz pełny TDD flow → odpal `/tdd`.

---

## Krok 4 — weryfikacja

**Zawsze** dwie warstwy:

1. **Automated** — testy przechodzą? lint clean? typecheck OK?
2. **Manual** — kliknąłeś przez to w przeglądarce / CLI / aplikacji? Zachowanie zgadza się z intencją? UX nie jest słop?

Per zasada #26 — automated testy mówią że "działa", manualny QA mówi że "jest dobre". Oba potrzebne.

---

## Krok 5 — dokumentacja (`/kronikarz`)

Skill ma **2 tryby**:

- **`live`** — agent wykonawczy aktualizuje kronikę przez całą drogę (impl, user QA results, fix-y po review). NIE commit, NIE update backlogu/indeksu. Kronika żyje przez lifecycle taska.
- **`close`** — Manager finalizuje przed merge: sign-off, update `doc/backlog.md` (DONE entries), update `doc/history/README.md` indeks, commit.

W Ścieżce A (bardzo mały task) — pomijasz cały kronikarz, commit message wystarcza dla:

- Drobnej kosmetyki (typo, formatowanie)
- Wewnętrznego refactoru bez zmiany API
- Buga którego nikt poza tobą nie zauważył

W Ścieżce B (przez `/code-manager`) — agent automatycznie odpala `/kronikarz live` per faza (sekwencja 3-STOP), Manager `close` przed merge.

Robisz pełnego kronikarza (live + close) dla:

- Zmiany **zauważalnej** z zewnątrz (UI, API, behavior)
- Buga **który był flagowany** (klient zgłosił, jest na backlog)
- Zmiany która łata **bezpieczny problem** (dla śladu w historii)

---

## Krok 6 — commit

Krótkie, opisowe commit messages. Format zależy od projektu (sprawdź `git log` żeby dopasować styl).

```
fix(orders): empty array for customer with no orders

Resolves 500 when GET /api/orders/:id and customer has no orders.
```

Push (jeśli pracujesz na branchu) lub direct na develop (jeśli convention projektu na to pozwala).

---

## Anty-wzorce

### „To tylko mały task" → eskalacja w trakcie

Zacząłeś jako mały task, w trakcie odkrywasz że trzeba ruszyć 8 plików, dotknąć 3 modułów, zmienić architekturę. **Stop.** Zatrzymaj się, zrób mental model resetu:

- To jest duża inicjatywa, nie mały task
- Wróć do `/grill-with-docs`, potem `/to-prd`
- Per zasada #5 — eager planning bez grillingu = kłopoty

### Pomijanie weryfikacji bo „mały task"

Małe taski są **najczęstszym** źródłem regresji właśnie dlatego, że ludzie pomijają QA. Nie ma czegoś takiego jak "task za mały żeby zweryfikować".

### Pisanie ADR dla małej zmiany

Per zasada #18 — ADR tylko gdy hard-to-reverse + surprising + real trade-off. Drobny fix nie spełnia tych kryteriów. Commit message wystarcza.
