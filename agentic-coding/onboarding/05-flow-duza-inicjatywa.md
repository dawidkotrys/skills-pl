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
  1. Grill                     →  /grill        (CONTEXT.md + ADR-y)
  2. PRD + scaffold backlog    →  /to-prd       (folder doc/plans/<slug>/{prd.md, backlog.md})
  3. Bridge na implementację   →  /code-manager (Tryb 4B) — invoke /to-tasks slice <N>
                                  + krótki plan-most dla agenta

IMPLEMENTACJA per slice (loop, slice po slicie)
  4. Agent wykonawczy implementuje → /kronikarz live + sekwencja 3-STOP
     (patrz 00-glowny-flow.md#cztery-punkty-kontrolne-usera)
  5. Manager Tryb 5C close + slice → ✅ done w backlog.md
  6. User /clear + restore → wróć do kroku 3 dla slice N+1

ARCHIVE (po merge ostatniego slice'a)
  7. Manager Tryb 5D → folder doc/plans/<slug>/ → doc/plans/archive/<slug>/
```

Krok 1-3 to **day shift** (twoja pełna uwaga, designujesz z agentem). Krok 4 to mix **night shift** (agent implementuje) i **day shift** (Twoje QA + decyzje per-finding po code review).

**Per-slice loop:** każdy slice z PRD przechodzi pełną sekwencję 3-STOP osobno (`/to-tasks` → impl → user QA → external review → close → merge). Manager rozpisuje **tylko bieżący slice** — nie wszystko z góry. Po merge slice'a kolejny slice rozpisuje się dopiero gdy manager jest gotów.

**Filozofia 3-STOP** (jednolicie opisana w [00-glowny-flow.md](./00-glowny-flow.md#cztery-punkty-kontrolne-usera)): "po co reviewować coś co nie działa" — implementacja musi najpierw zadziałać user-side (zasada #9 imposing taste), dopiero potem polerowanie przez external review.

**External review**: Manager (Opus) odpala `/critical-code-review` na finalnym kodzie, **nie agent wykonawczy** (Sonnet). Peer review principle, brak confirmation bias na własne decyzje.

**Autonomy gate**: Manager nie merguje sam — pyta usera "merge?", po user "akcept" → Manager `git push` + merge. Człowiek ma ostateczne słowo przed irreversible action.

---

## Krok 1 — Grill (`/grill`)

**Najważniejszy krok.** Nie skracaj. Per zasada #4 — eager planning bez grillingu = plan który nie wytrzyma kontaktu z rzeczywistością.

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

## Krok 2 — PRD + scaffold backlog (`/to-prd`)

Po grillingu — `/to-prd` konwertuje kontekst rozmowy na **destination document**: PRD (Product Requirements Document) + scaffold execution-grade backlog'u.

PRD nie jest kontraktem — jest **kierunkiem**:

- Cel inicjatywy (jednym zdaniem)
- User stories / scenariusze
- Constraints i non-goals (co eksplicytnie NIE jest scope)
- High-level approach
- Vertical slices z `Slice purpose` + `Slice acceptance` per slice
- Decyzje już podjęte (linki do ADR-ów)
- Otwarte pytania (do dorobienia w trakcie)

`/to-prd` produkuje **folder inicjatywy** `doc/plans/<slug>/` z dwoma plikami:
- `prd.md` — destination document (vision + slices)
- `backlog.md` — scaffold execution-grade (sekcja per slice ze statusem `[ ] niezdetailowany`)

Slice'y w `backlog.md` zostają **niezdetailowane** dopóki manager nie invoke `/to-tasks slice <N>` (krok 4). To kluczowa decyzja: **nie rozpisujemy wszystkich tasków z góry**, tylko bieżący slice w pętli.

### Każdy slice musi być

- **Vertical slice** (zasada #5) — UI → API → DB → tests dla jednej małej funkcjonalności end-to-end
- **Tracer bullet** — działający kod, nie prototyp
- **Cienki** — bias na cieńsze. Jeśli wahasz się czy podzielić — dziel.
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

## Krok 3 — Bridge + task breakdown (`/code-manager` Tryb 4B + `/to-tasks`)

Po `/to-prd` masz folder inicjatywy. Przed implementacją: bridge mode managera. Manager:

- Wybiera **bieżący slice** (typowo Slice 0 lub 1)
- Invoke `/to-tasks slice <N>` → rozbija slice na 3-7 granularnych tasków wykonawczych z file targets + acceptance criteria. Status sekcji slice'a: `[ ] niezdetailowany` → `🔄 in-progress`
- Pisze krótki **bridge plan** (~30-50 linii) — link do PRD + tasks w backlog.md, kontekst pracy równoległej, kolejność wykonania, pułapki
- Dispatchuje do agenta wykonawczego (wiadomość-do-wkleienia)

Output: bridge plan + zaktualizowany `backlog.md` (current slice rozpisany na taski).

---

## Krok 4 — Implementacja per slice (sekwencja 3-STOP)

Per bieżący slice:

- Agent wykonawczy implementuje taski po kolei (T<N>.1 → T<N>.2 → ...)
- `/kronikarz live` przez całą drogę
- Sekwencja 3-STOP — szczegóły w [00-glowny-flow.md](./00-glowny-flow.md#cztery-punkty-kontrolne-usera)
- Per Memento (zasada #2) — jeśli kontekst się zaśmieca → save/restore session

Manager Tryb 5C zamyka slice po merge: status `🔄 in-progress` → `✅ done` w `backlog.md`.

---

## Krok 5 — Loop dla kolejnego slice'a

Po close slice'a N: **user `/clear` + `/restore-session-manager`** → świeża sesja managera dla slice'a N+1. Wracasz do **kroku 3** (manager invoke `/to-tasks slice <N+1>`).

Per-slice loop trwa aż wszystkie slices są `✅ done`. Wtedy → krok 6.

---

## Krok 6 — Archive folderu inicjatywy

Manager Tryb 5D: po merge ostatniego slice'a → folder `doc/plans/<slug>/` przenosi się do `doc/plans/archive/<slug>/`. Zawartość intact (audit trail). Frontmatter `status: in-progress` → `status: done`.

---

## Anty-wzorce

### Pomijanie grillingu

"Już wiem co trzeba zrobić, lecę do `/to-prd`". Tracisz okazję do testu hipotez. Plan będzie wyglądał OK ale rozsypie się przy implementacji.

### Slices które są horizontal

Każdy slice **musi** być vertical slice end-to-end. Patrz zasada #5.

### Rozpisanie wszystkich slicesów na taski z góry

Anti-pattern. `/to-tasks` invoke per slice w pętli — nie wszystko z góry. Powód: kontekst kolejnego slice'a jest informowany przez to czego się nauczyłeś przy poprzednim. Eager task breakdown wszystkich slicesów = drift od rzeczywistości.

### Pisanie wszystkich testów na początku (anti-TDD)

Per zasada #7 — to pozwala AI na cheating (hardcoded values żeby satysfakcjonować wszystkie testy). TDD red-green vertical, jeden test → jedna decyzja implementacyjna.

### Brak QA loop

"Code review przeszło, mergujemy". QA nie jest opcjonalne. QA to imposing taste i pętla, nie checkpoint (zasada #9).

### Pisanie ADR-a po fakcie / dla każdej decyzji

ADR-y sparingly. Hard-to-reverse + surprising + real trade-off. Reszta to commit messages. (Patrz `03-pliki-projektu.md` sekcja `doc/decisions/`.)
