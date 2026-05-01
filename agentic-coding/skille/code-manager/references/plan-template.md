# Plan Template — format `doc/plans/<branch-name>.md`

Każdy plan to **source of truth** dla subagenta, który będzie pracował na danym branchu/worktree. Subagent startuje z czystym kontekstem — plan musi być na tyle kompletny, żeby mógł od razu wejść w pracę bez dziesięciu rund pytań. Jednocześnie nie może być przepełniony — jeśli rośnie do 500 linii, to znaczy że próbujesz robić pracę za subagenta.

## Nazwa pliku

`doc/plans/<branch-name>.md` — slashy w nazwie brancha zamieniasz na dashe.

**Przykłady:**
- Branch `feat/file-explorer-context-menu` → plik `doc/plans/feat-file-explorer-context-menu.md`
- Branch `perf/local-agent-render-split-subscriptions` → plik `doc/plans/perf-local-agent-render-split-subscriptions.md`
- Branch `fix/drop-overlay-local-tab` → plik `doc/plans/fix-drop-overlay-local-tab.md`

## Szkielet

```markdown
# <Tytuł zadania — human-readable, krótko>

**Branch:** `<branch-name>`
**Źródło:** `<source-branch, typowo develop lub main>`
**Data utworzenia planu:** YYYY-MM-DD
**Manager:** Claude Opus 4.7 (via /code-manager)
**Status:** draft | in progress | ready for merge | merged

## Cel

<1-2 akapity: co robimy i DLACZEGO teraz. Nie "jak" — "co" i "po co".>

## Kontekst równoległej pracy

<Jeśli inny worktree jest aktywny — tu wypisujesz eksplicytnie:>

- Branch `<X>` w worktree `<path>` pracuje nad `<zadaniem>`. **Nie dotykaj:** [lista plików/folderów/symboli].
- Strategia merge: <kto merguje pierwszy, kto rebase'uje>.

<Jeśli pracujesz solo — napisz: "Brak równoległej pracy. Swoboda."> 

## Zasady z CLAUDE.md do podkreślenia

Subagent załaduje CLAUDE.md z repo przy starcie, ale warto wyciągnąć reguły **szczególnie istotne** dla tego zadania. Przykładowo:

- **Pareto 90/10 (CLAUDE.md rule #2):** <jeśli zadanie ma pokusę over-engineeringu — podkreśl>
- **Reuse realny, nie hipotetyczny (rule #5):** <jeśli istnieje szansa na premature abstraction — podkreśl>
- **Surgical changes (rule #10):** <jeśli zadanie dotyka pliku który ma inne "magnets for cleanup">
- **Przed kodowaniem — surface confusion (top section):** <jeśli zakres ma ambiguity — podkreśl żeby subagent zadał pytania>
- **User-facing values real (rule #3):** <jeśli zadanie dotyka wartości pokazywanych userowi>

## Punkty startowe — czytaj pełne pliki ZANIM cokolwiek proponujesz

Lista plików do przeczytania **w pełni** (nie sam diff):

1. `src/foo.ts` — bo tam jest obecna logika X, musisz zrozumieć dlaczego jest taka
2. `src/bar.tsx` — bo to jest call site który zmienisz
3. `doc/history/YYYY-MM-DD-<poprzedni-branch>.md` — bo tam są decyzje które poprzedzają to zadanie

Grep/glob przydatne:

```bash
grep -rn "<symbol>" src/
```

## Scope i acceptance criteria

**W zakresie:**
- <konkretny punkt 1>
- <konkretny punkt 2>

**Poza zakresem (explicit):**
- <co świadomie nie robimy w tym branchu — np. "refactor X, zostawiamy na osobny task">
- <pre-existing issues które subagent może zauważyć ale nie naprawia>

**Acceptance criteria (verifiowalne):**

- [ ] <warunek 1 — np. "clicking X opens Y dialog">
- [ ] <warunek 2 — np. "typecheck passes">
- [ ] <warunek 3 — np. "nowe testy w <plik> pokrywają scenariusze 1-5">

## Scenariusze testowe

Numerowana lista. Golden path + edge cases. Piszemy **zanim** subagent zacznie implementację — to kontrakt.

1. Happy path: <krok po kroku>
2. Edge case A: <krok po kroku>
3. Edge case B: <krok po kroku>
4. Regresja cross-feature: <np. "knowledge audio upload nadal działa po zmianach w drop handler">

## Potencjalne pułapki

<Co wiesz z pre-existing kodu/historii, że może pójść nie tak:>

- <pułapka 1: "watcher debounce 500ms, więc UI może się nie zaktualizować od razu">
- <pułapka 2: "jest już invariant X — nie złam go">

## Pierwsze 3 kroki konkretnie

Żeby subagent nie spędził 2000 tokenów na "let me explore the codebase":

1. **<Konkretna akcja 1>** — np. `git log --oneline -20` + przeczytaj `doc/history/README.md` (top 3 entries)
2. **<Konkretna akcja 2>** — np. przeczytaj pełne pliki `src/foo.ts` + `src/bar.tsx`
3. **<Konkretna akcja 3>** — np. **Przedstaw użytkownikowi plan implementacji** przed napisaniem pierwszej linii kodu. Get approval first.

## Koniec pracy — sekwencja agent ↔ user ↔ Manager

⚠️ **Filozofia tej sekwencji** (per ADR-0002, ADR-0003):

- "Po co reviewować coś co nie działa" — implementacja musi **najpierw zadziałać user-side** (manual QA = imposing taste, zasada #26), dopiero potem polerowanie.
- **External code review** — Manager (Opus) odpala `/critical-code-review`, NIE agent wykonawczy. Świeże oczy, brak confirmation bias na własne decyzje (peer review principle).
- **Kronika żyje przez całą drogę** — agent uruchamia `/kronikarz live` per faza. Manager finalizuje przez `/kronikarz close` na samym końcu.
- **Merge przez Managera z autonomy gate** (ADR-0001) — Manager pyta usera "merge?", user "akcept", Manager merguje.

**Sekwencja (3 STOP-y, 4 manual ferrying messages user↔Manager):**

### Krok 1: Implementacja kompletna

Wszystkie acceptance criteria z planu zaimplementowane, kod się buduje, testy automatyczne (jeśli są) przechodzą.

→ Wywołaj `/kronikarz live` aby zalogować implementację (nowe pliki, zmodyfikowane pliki, decyzje architektoniczne, API surface, komentarze w kodzie linkujące do kroniki).

### Krok 2: Przygotuj manual test scenariusze dla użytkownika

User-friendly instrukcje krok-po-kroku, gotowe do wyklikania. Format:

```
### Test N: <krótka nazwa testu>

**Setup:** <konkretne kroki przygotowania>

**Kroki:**
1. <kliknij/wpisz/zrób X>
2. <obserwuj Y>

**Acceptance:** <co user powinien zobaczyć — konkretny visual / behavior, BEZ żargonu>

**Co sprawdza:** <1 zdanie funkcjonalnie, czemu test ma znaczenie>
```

**Wymagania per zasada #4 SKIL.md (user-perspective):**

- **Język nie-techniczny.** Nie "verify React.memo gates render", tylko *"drzewo plików nie powinno mignąć"*.
- **Konkretne komendy do skopiowania** jeśli scenariusz wymaga terminala.
- **Brak DevTools / React Profiler** w scenariuszach dla usera — jeśli efekt niewidoczny gołym okiem, oznacz: *"Pomijalne dla użytkownika — Manager zweryfikuje pomiarowo."*
- **Zgrupuj na 3 najważniejsze MUST + reszta opcjonalna.** User ma ~10 min.
- **Po każdym scenariuszu sprzątanie** (`rm`, reset settings).

→ Te scenariusze trafiają **inline na czat** (zawsze, ADR-0010) **plus** są duplikowane do kroniki w sekcji `## 🧪 Testy` (search-friendly marker).

### Krok 3: 🛑 STOP #1 — wyślij scenariusze userowi

Format raportu (publikujesz na czat, user testuje sam):

```
Implementacja gotowa. Manual test scenariusze (~X min Twojego czasu):

### Najważniejsze (MUST PASS)
[Test 1, Test 2, Test 3 — pełen format z setup/kroki/acceptance]

### Opcjonalne (sanity / regression)
[Test 4-N]

Czekam na feedback per-test:
- ✅ Pass
- ⚠️ Partial (co zaobserwowane)
- ❌ Fail (co vs co oczekiwano)
```

### Krok 4: Po feedback usera — fix-y in-branch jeśli były problemy

Per fail/partial → osobny commit `fix(<scope>): <co naprawiono> per user QA`. Update kroniki przez `/kronikarz live` (sekcja 🧪 Testy, dorzuć "Co nie poszło" + "Jak naprawiono: commit abc123" + "Re-test: ✅").

Jeśli wszystkie zielone → idź do Kroku 5 bez fix'ów.

### Krok 5: Raport gotowości do external review (do Managera, przez usera)

**NIE odpalasz `/critical-code-review` sam** — to robi Manager (ADR-0002). Twój output: wiadomość-do-wkleienia dla user'a żeby przekazał Managerowi.

Format:

```
## 📋 Wiadomość od agenta dla Managera
*Wklej cały blok poniżej do Managera w głównym czacie.*
---
TL;DR: Implementacja `<branch>` gotowa, user QA zielone (X testów pass).
Pełen kontekst: doc/history/YYYY-MM-DD-<branch>.md
---

Status:
- Branch: `<branch-name>` na worktree `<path>`
- Ostatni commit: <SHA> (<short message>)
- Acceptance criteria: ✅ wszystkie spełnione
- User QA: ✅ N MUST + M opcjonalnych pass

Pliki dotknięte: <lista>
Kluczowe decyzje implementacyjne: doc/history/<file>.md#decyzje (link)

Zlecam: odpal `/critical-code-review` i zwróć findingsy. Po Twoich
decyzjach per-finding wracam do fix-ów lub jadę do close.
```

### Krok 6: 🛑 STOP #2 — czekaj na findingsy od Managera

User kopiuje raport do Managera → Manager odpala `/critical-code-review` na finalnym kodzie → Manager przygotowuje wiadomość dla Ciebie z findingsami i rekomendacjami per-finding (FIX/BACKLOG/SKIP) + decyzjami usera.

User wkleja Ci wiadomość Managera. Czytaj wiadomość, sprawdź raport (`doc/code-reviews/YYYY-MM-DD-<branch>.md`).

### Krok 7: Po decyzjach Managera — fix-y in-branch

- Każdy finding oznaczony FIX → osobny commit `fix(<scope>): <co naprawiono> per CR <symbol>`
- Każdy finding BACKLOG → entry przygotowany do `doc/backlog.md` (Manager dopisze w `/kronikarz close`)
- Każdy finding SKIP → entry w kronice z **ustrukturyzowanym templatem** (Impact / Koszt / Rationale / Re-evaluate gdy — ADR-0011)

→ Update kroniki przez `/kronikarz live` (sekcja "Code review findings + decyzje per-finding" z statusem 🔴🟡🟢).

**Jeśli były fix-y z review** — wróć do user QA dla zmienionych obszarów (Krok 8).
**Jeśli wszystko BACKLOG/SKIP** (zero fix'ów in-branch) — pomiń Krok 8, idź do Kroku 9.

### Krok 8: 🛑 STOP #3 — re-test po fix'ach z review (jeśli były)

Re-test scenariuszy dotykających zmienionych obszarów. Format raportu jak w Kroku 3, ale tylko subset relevantnych testów:

```
Naprawy z review zakończone. Re-test scenariuszy dotyczących zmian:
[Test X — affected by fix CR-3, Test Y — affected by fix CR-7]

Czekam na re-feedback.
```

Jeśli re-test zielony → idź do Kroku 9. Jeśli fail/partial → fix-y in-branch + update kroniki + ponowny re-test (loop max 3 cykle, potem zaraportuj Managerowi propozycję scope-down per ADR-0005 failure handling).

### Krok 9: Raport końcowy do Managera (do close)

Wszystko zielone, kronika live ma wszystkie sekcje wypełnione. Format wiadomości-do-wkleienia:

```
## 📋 Wiadomość od agenta dla Managera
*Wklej cały blok poniżej do Managera.*
---
TL;DR: `<branch>` gotowy do close — wszystkie sekwencje zielone.
Pełen kontekst: doc/history/YYYY-MM-DD-<branch>.md
---

Status:
- User QA: ✅ pass
- Code review: APPROVE (po Twoich fix-ach FIX) / NEEDS-FIX (jeśli BACKLOG entries)
- Re-test po review: ✅ pass / N/A (zero fix'ów in-branch)

Branch: `<branch-name>`, ostatni commit: <SHA>
Acceptance criteria: ✅ wszystkie
SKIP/BACKLOG entries do `doc/backlog.md`: <lista linków do kroniki>

Zlecam: odpal `/kronikarz close`, zaktualizuj backlog/indeks, zaproponuj
"merge?" userowi.
```

### Krok 10: Manager przejmuje (Twoja praca tu się kończy)

Po Kroku 9 — Manager:
- Odpala `/kronikarz close` (sign-off, update `doc/backlog.md` + `doc/history/README.md` indeks, commit)
- Pyta usera "merge?"
- Po user "akcept" → Manager wykonuje `git push` + merge do source brancha (autonomy gate per ADR-0001)

**Ty (agent) nie pushujesz, nie mergujesz, nie odpalasz `/kronikarz close`.** Twoja rola kończy się na raporcie z Kroku 9.

9. **W raporcie końcowym do Managera zawrzyj sekcję "Post-merge Manager action"** — ready-to-apply lista zmian do wprowadzenia w shared docs (patrz "Docs ownership" niżej). Format:

   ```
   ## Post-merge Manager action

   **`doc/features/<area>/backlog.md`:**
   - Oznacz [x]: item "<nazwa>" (sekcja <jaka>) — bo ukończony w tym branchu
   - Dopisz w sekcji "Tech Debt" / "UX" / etc:
     - "<nowy follow-up entry z code review LOW-X>" — powód / link do code review
   - Reopen / przeformatuj: <item Y> — bo w trakcie manual testu ujawniło że nie jest RESOLVED

   **`doc/history/README.md`:**
   - Dodaj entry: `YYYY-MM-DD <branch> — <one-line summary>` (link do kroniki)

   **`doc/plans/<branch>.md`:**
   - Status: merged (lub przenieś do `doc/plans/archive/YYYY/` jeśli konwencja).
   ```

10. **NIE merguj sam.** Manager Medium-level verification po push, potem merge, potem Manager aplikuje "Post-merge Manager action" na develop.

### Docs ownership — CO AGENT PISZE / CZEGO NIE DOTYKA

**Agent owns (per-branch files, unikalne nazwy = zero kolizji):**
- `doc/history/YYYY-MM-DD-<branch>.md` — kronika swojego brancha
- `doc/code-reviews/YYYY-MM-DD-<branch>.md` — raport code review
- `doc/design-reviews/YYYY-MM-DD-<branch>.md` — jeśli dotyczy
- `doc/plans/<branch>.md` — update status, odchylenia od planu (in-branch update OK)

**Manager owns (shared indexes — aktualizowane POST-MERGE na develop):**
- `doc/features/*/backlog.md`
- `doc/backlog.md`
- `doc/history/README.md`
- `doc/features/*/observations/*`

**Powód:** równoległe branche często oba chcą oznaczyć `[x]` / dopisać entry w tych samych shared indexach → drugi merge zawsze CONFLICTING (obserwowane 2×: PR #43 i PR #45). Source code zero overlap, ale shared docs = race. Manager jako single writer po merge eliminuje problem architektonicznie, nie przez timing.

**Agent NIE edytuje shared indexów nawet jeśli "ma pewność że nic nie koliduje"** — habit formation. Zawsze zostawia ready-to-apply patch w raporcie końcowym, Manager aplikuje.

**Wyjątek (solo work):** gdy Manager explicit mówi "nie ma równoległych branchy, możesz updatować backlog in-branch" — wtedy OK. Domyślnie: separacja.

### Dlaczego ten gate jest krytyczny

Bez gate'a (subagent leci review → fix → kronika automatycznie):
- Subagent decyduje za użytkownika które findings fixować — naruszenie zasady #1 Managera ("nie decyduj za usera")
- Kronika pisana przed decyzjami → dezaktualizuje się natychmiast jeśli użytkownik zażyczy więcej/mniej fixów
- użytkownik nie ma okazji powiedzieć: *"hej, ten LOW jest aktualnie ważniejszy niż wam się wydaje, fixujmy"* lub *"ten MEDIUM jest pre-existing tech debt, zostawmy do osobnego brancha"*
- Pre-existing patterns w plikach które subagent zauważył "po drodze" mogą zostać niewidocznie pominięte (lub odwrotnie — subagent fixuje "przy okazji" naruszając rule #10 surgical changes)

Z gate'em:
- użytkownik widzi pełen obraz "co code review znalazł" przed wyborami
- Naprawy są świadome i oparte o decyzje strategiczne (np. "to fixujemy bo user widzi", "tamto do backlogu bo refactor cross-branch")
- Kronika dokumentuje **finalny stan** (włącznie z decyzjami) — jest stabilna od momentu napisania

## Raport końcowy do Managera

Po push napisz do Managera (lub do usera przekazującego Managerowi):

- Link do PR
- Krótkie podsumowanie: co weszło, czy były problemy
- Czy były odchylenia od planu i gdzie są opisane w kronice
- Czy code review wygenerował follow-upy które zostawiasz w backlogu (lista)
- Czy wszystkie acceptance criteria są spełnione (tak/częściowo/nie — wyjaśnij)
```

## Uwagi dodatkowe

- **Nie duplikuj treści z CLAUDE.md.** Jeśli zasada jest generyczna — wystarczy link/odwołanie. Plan ma być **specyficzny dla taska**.
- **Nie pisz planu "co masz zaimplementować" na poziomie linii kodu.** Subagent jest inteligentny — dajesz mu kontrakt (acceptance, scope, pitfalls), a on decyduje jak to zrealizować.
- **Jeśli plan przekracza 300 linii — coś jest nie tak.** Albo task jest za duży (rozbij), albo piszesz za subagenta.
- **Jeśli plan jest krótszy niż 50 linii — też coś jest nie tak.** Zazwyczaj brak punktów startowych, pułapek, albo acceptance criteria.
