# Verification Checklist — Medium Level Post-Merge

Ten dokument precyzuje co Manager **robi** (i **czego nie robi**) gdy user raportuje że subagent skończył pracę i/lub zmergował do target brancha.

## Dlaczego Medium, nie Heavy

User explicitnie: "każdy z tych agentów będzie i tak przeprowadzał Code Review samodzielnie, więc ty jesteś tylko takim jakby wisienką na torcie. Ale powinieneś oceniać to krytycznie, ale bez wchodzenia jakoś bardzo głęboko w kod. Żeby po prostu nie przepalać zasobów, które już były mocno wyeksploatowane przy Cold Review."

Konsekwencje tej decyzji:

**NIE robisz:**
- Nie uruchamiasz `/critical-code-review` — subagent powinien był go odpalić sam
- Nie czytasz całego diffu linia po linii
- Nie uruchamiasz testów (subagent już to zrobił, masz wierzyć)
- Nie weryfikujesz każdej implementacji decyzji przeciw alternatywom

**ROBISZ:**
- Czytasz kronikę (to jest esencja pracy, zawsze czytaj)
- Porównujesz kronikę z planem (scope discipline)
- Sprawdzasz że backlog jest zaktualizowany (follow-upy, completed items)
- Spot-check na wybranych plikach jeśli coś wyda Ci się dziwne w kronice

## Checklist krok po kroku

### Krok 1: Pull latest

Nie weryfikuj stale state. Pierwsze:

```bash
git fetch origin
git checkout <target-branch>  # typowo develop
git pull origin <target-branch>
git log --oneline -10
```

Zobacz merge commit, parent branches, i co było mergowane.

### Krok 2: Znajdź nowe artefakty

```bash
# Co dodane w ostatnich merge'ach
ls -lt doc/history/ | head -5
ls -lt doc/code-reviews/ | head -5
ls -lt doc/design-reviews/ 2>/dev/null | head -5
```

Sprawdź czy są:
- Nowa kronika w `doc/history/` z datą dzisiejszą / branch name
- Nowy code review raport (nie obowiązkowy jeśli subagent uruchomił ale nie zapisał — ale zazwyczaj jest)
- Update w `doc/history/README.md` (wpis w tabeli)
- Update w `doc/plans/<branch>.md` (status: merged)

**Brak któregoś z powyższych = pierwsza luka do zgłoszenia.**

### Krok 3: Czytaj kronikę w pełni

To jest Twoja główna dawka informacji. Szczególnie szukaj:

- **Sekcja "Cel"** — czy matchuje z celem z planu?
- **Sekcja "Odchylenia od planu"** — jeśli były odchylenia, czy są wyjaśnione? (jeśli odchylenia są ale sekcja brakuje — luka)
- **Sekcja "Znane problemy i trade-offy"** — co zostało świadomie odłożone? Czy to jest w backlogu?
- **Sekcja "Decyzje architektoniczne"** — czy decyzje są zgodne z CLAUDE.md (Pareto, surgical, no speculative)?
- **Sekcja "Scenariusze testowe"** — czy pokrywa acceptance criteria z planu?

### Krok 4: Porównaj kronikę z planem

```bash
cat doc/plans/<branch>.md
cat doc/history/<latest>.md
```

Pytania:
- Wszystkie acceptance criteria z planu → zaadresowane w kronice?
- Scope z planu vs. zakres plików w kronice — matchuje?
- Pułapki z planu → czy subagent wspomina że ich uniknął / wpadł w nie / zidentyfikował nowe?

### Krok 5: Aktualizuj shared docs sam (post-merge) — TY jesteś właścicielem

Od konwencji v2 (feedback_parallel_docs_ownership, 2026-04-19) agent **NIE dotyka** `doc/**/backlog.md`, `doc/history/README.md`, `doc/features/*/observations/*`. Update shared indexów jest Twoim zadaniem po merge.

**Źródło prawdy dla patchu:** sekcja "Post-merge Manager action" w raporcie końcowym agenta (powinna być). Jeśli brakuje — wyczytaj z kroniki + code review co należy nanieść.

**Konkretne zmiany do aplikowania:**
- Oznacz `[x]` items które zostały ukończone w tym branchu
- Dopisz follow-upy z code review decyzjone jako BACKLOG (per-finding, z linkiem do raportu)
- Dodaj entry w `doc/history/README.md` wskazujący na nową kronikę (tabela, format wg konwencji projektu)
- Update `doc/plans/<branch>.md` status: merged (lub przenieś do `doc/plans/archive/YYYY/` jeśli archiwizacja)
- Jeśli kronika mówi "rozwiązuje też regresję Y" — zaktualizuj stary backlog item

**Po aktualizacjach:** commit + push do integration branch (typowo `develop` lub `main` — zgodnie z konwencją projektu). Manager ma autonomiczne commit uprawnienia na docs jeśli `CLAUDE.md` projektu tak stanowi — pokaż userowi commit message + scope post-hoc żeby mógł zaczepić jeśli coś się rozjechało.

**Dlaczego Manager a nie agent:** 2 równoległe branche edytujące shared indexy = merge drugi zawsze CONFLICTING (obserwowane PR #43 + #45). Single writer eliminuje race architektonicznie.

### Krok 6: Quick diff scan

```bash
git diff <merge-parent>..HEAD --stat | head -30
git diff <merge-parent>..HEAD --name-only
```

Patrzysz na:
- **Rozmiar diffu** — zgodny z intuicją wg kroniki? (jeśli kronika mówi "mała zmiana" a diff ma +2000 linii — luka)
- **Zakres plików** — zgodny z kroniką? (jeśli kronika mówi "dotykamy tylko file explorera" a w diffie widzisz zmiany w `agent-loop.ts` — luka)
- **Nowe pliki** — wszystkie wspomniane w kronice w tabeli "Nowe pliki"? (jeśli subagent dodał plik nie wspomniany — luka dokumentacyjna)

### Krok 7: Spot-check wybranych plików (opcjonalnie)

**Tylko jeśli coś Cię niepokoi** — np. kronika jest vague, ryzykowna zmiana, albo subagent zaraportował "drobną zmianę" a diff sugeruje inaczej.

```bash
git show <merge-sha> -- <podejrzany-plik>
```

Szukasz:
- Nietypowych patternów (które nie są w CLAUDE.md, nie są w istniejącym kodzie)
- `TODO` / `FIXME` / `HACK` / `as any` — czy uzasadnione w kronice
- Zakomentowanego kodu (dead code)
- Testów z `.skip` / `.only`

**Nie czytaj pełnego pliku.** Cel: wyłapać red flags, nie przeprowadzać review.

### Krok 8: Zbierz werdykt

Przedstaw userowi w formie:

```markdown
## Weryfikacja merge `<branch>` — Medium

### Co jest w porządku ✅
- <punkt 1>
- <punkt 2>

### Potencjalne luki 🟡
- <luka 1: np. "kronika wspomina M3 findings ale nie dopisany w backlog">
- <luka 2>

### Red flags 🔴 (jeśli są)
- <red flag: np. "diff obejmuje `src-tauri/src/main.rs` którego kronika nie wspomina">

### Rekomendacja

<jedna z:>
- **Akceptuję stan post-merge, backlog kompletny.** User może iść dalej.
- **Luki dokumentacyjne — proponuję dopisać X, Y.** (nie blokujące, ale warto)
- **Red flag wymagający wyjaśnienia.** Spytaj subagenta lub wróć do diffu.
```

## Typowe luki które Manager łapie

Na podstawie sesji historycznych:

1. **Kronika mówi o follow-upach ale backlog ich nie zawiera** — subagent czasami wspomina "M3 jest otwarty" ale zapomina dopisać do backlogu. Manager łapie.
2. **HIGH/MEDIUM z code review "świadomie odłożone"** — subagent pisze w kronice że zostawia coś na później, ale nie wszystkie trafiają do backlogu.
3. **Design review findings z "innych branchy"** — jeśli subagent uruchomił `/design-checker` i znalazł coś poza swoim scope'em (np. `text-white` w `ChatPanel` gdy pracował nad file explorerem), typowo wzmiankuje ale nie tworzy entry w global backlogu.
4. **Brak wpisu w `doc/history/README.md`** — subagent napisał kronikę ale zapomniał dodać wiersza w tabeli indexu.
5. **Cross-reference do poprzednich branchy** — kronika wspomina "naprawia regresję z brancha X" ale stary backlog-item z brancha X nadal nie jest zamknięty.
6. **Scope creep bez wyjaśnienia** — kronika pokazuje że zostały zrobione rzeczy spoza planu (czasami wartościowe, czasami nie). Manager prosi o uzasadnienie i jeśli OK — zostaje, jeśli nie — dyskutuje z userem co z tym zrobić (revert? nowy backlog?).

## Gdy znajdziesz luki — co dalej

User decyduje:

1. **Tylko dokumentacja** — Manager może sam dopisać (backlog entry, README update) po zgodzie
2. **Wymaga powrotu subagenta** — user przekazuje Managerowi feedback → Manager pisze krótki message do subagenta żeby uzupełnił
3. **Akceptacja luki** — user mówi "zostawmy, nieważne", Manager odpuszcza (szanuj decyzję usera)

## Timing

Medium verification powinna zajmować:
- Małe merge (kilka plików) — 2-5 minut
- Średnie merge (kronika + CR + 10-20 plików) — 5-10 minut
- Duże merge (multi-day branch) — 10-20 minut

**Jeśli Ci to zajmuje godzinę** — robisz za dużo (prawdopodobnie wchodzisz w Heavy, a powinno być Medium). Wróć do zasady "wisienka na torcie".
