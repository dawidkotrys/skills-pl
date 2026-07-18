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
**Manager:** <model Managera> (via /code-manager)
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

## Koniec pracy (3-STOP — pełna specyfikacja: ~/.claude/skills/code-manager/references/lifecycle-3stop.md)

1. STOP #1 user QA: /kronikarz live → scenariusze inline (co klikasz → czego oczekujesz) → user testuje; poprawki = fix in-branch + ponowny STOP #1.
2. STOP #2 review: NIE odpalasz /critical-code-review — raport-do-wkleienia dla Managera; Manager robi review, user decyduje FIX/BACKLOG/SKIP; fixy in-branch + SKIP template.
3. STOP #3 re-test (tylko jeśli były FIXy): user re-testuje scenariusze dotknięte zmianami.
4. Raport końcowy do Managera („zlecam /kronikarz close"). NIE pushujesz, NIE mergujesz — Manager owner of remote/main.
```

## Uwagi dodatkowe

- **Nie duplikuj treści z CLAUDE.md.** Jeśli zasada jest generyczna — wystarczy link/odwołanie. Plan ma być **specyficzny dla taska**.
- **Nie pisz planu "co masz zaimplementować" na poziomie linii kodu.** Subagent jest inteligentny — dajesz mu kontrakt (acceptance, scope, pitfalls), a on decyduje jak to zrealizować.
- **Jeśli plan przekracza 300 linii — coś jest nie tak.** Albo task jest za duży (rozbij), albo piszesz za subagenta.
- **Jeśli plan jest krótszy niż 50 linii — też coś jest nie tak.** Zazwyczaj brak punktów startowych, pułapek, albo acceptance criteria.
