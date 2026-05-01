# Subagent Briefing Template

Gdy Manager kończy pisanie planu (`doc/plans/<branch>.md`), przygotowuje **wiadomość briefingową** dla usera. User kopiuje ją i wkleja jako pierwszą wiadomość do subagenta w nowym worktree / sesji.

Cel briefingu: zero-context-loss onboarding. Subagent po przeczytaniu briefingu **wie dokładnie** co robić, gdzie szukać szczegółów, czego unikać, kiedy skończyć. Bez briefingu subagent spędza pierwsze 30 minut na ogarnianiu kontekstu.

## Struktura briefingu

```markdown
# Zadanie: <krótki tytuł, human-readable>

## Kontekst

<1-3 zdania: co, dlaczego, po co. Ton: jesteś teraz członkiem zespołu, tu masz brief.>

## Twój worktree

- **Branch:** `<branch-name>`
- **Worktree path:** `/path/to/worktree`
- **Source branch:** `<develop / main>`
- **Status:** plan napisany, czekasz na start

## Pełny plan pracy

**Czytaj najpierw:** `doc/plans/<branch-name>.md`

Tam masz: cel, scope, acceptance criteria, scenariusze testowe, punkty startowe, pułapki, pierwsze 3 kroki, kryteria zakończenia pracy. **Nie zaczynaj kodować zanim przeczytasz pełen plan + pliki z sekcji "Punkty startowe".**

## Równoległa praca — bądź świadomy

<Jeśli jest drugi aktywny worktree:>

Inny agent pracuje teraz na branchu `<X>` w worktree `<path>`. Zajmuje się: `<opisem>`. **Nie dotykaj:**
- `<plik/folder 1>`
- `<plik/folder 2>`
- `<symbol/pattern>`

Collision analysis pokazuje <zero/niski/średni> overlap — plan na merge: <kto pierwszy, kto rebase, na co uważać>.

<Jeśli pracujesz solo:>

Nie ma równoległej pracy w innych worktreeach. Masz swobodę w całym repo, ale pamiętaj o scope z planu.

## Zasady projektu do przypomnienia

Gdy załadujesz kontekst, `CLAUDE.md` z repo Ci się wczyta automatycznie. Ale w tym zadaniu **szczególnie istotne** są:

- **<Rule X z CLAUDE.md z wyjaśnieniem dlaczego w tym zadaniu kluczowe>**
- **<Rule Y>**
- **<Specyfika projektu jeśli istotna — np. "no-overwrite policy w agent tools, pamiętaj przy dotykaniu write_file">**

## Pierwsze 3 kroki

1. `git status && git log --oneline -5` — zobacz w jakim stanie zaczynasz
2. Przeczytaj `doc/plans/<branch-name>.md` w pełni
3. Przeczytaj pliki z sekcji "Punkty startowe" planu
4. **Przedstaw userowi plan implementacji** (konkretne komponenty, akcje, flow) **zanim napiszesz pierwszą linię kodu**. Czekaj na approval.

## Gdy skończysz

Sekwencja agent ↔ user ↔ Manager (filozofia: "po co reviewować coś co nie działa" — najpierw user QA, potem **external review przez Managera**, kronika na końcu, **merge przez Managera z user-OK gate**):

1. **Implementacja gotowa** → wywołaj `/kronikarz live` (zaloguj implementację). Przygotuj manual test scenariusze (user-friendly, ~10 min wyklikania, język nie-techniczny). **Inline na czat** plus duplikuj do kroniki w sekcji `## 🧪 Testy`.
2. **STOP #1** — czekaj na user feedback per-test (✅/⚠️/❌).
3. **Po user QA** → fix in-branch jeśli fail/partial (commit `fix(<scope>): ... per user QA`). Update kroniki (sekcja 🧪 Testy: "Co nie poszło" + "Jak naprawiono: commit X" + "Re-test: ✅"). Jeśli zielone od razu — idź dalej.
4. **NIE odpalasz `/critical-code-review`** — to robi Manager (ADR-0002, peer review principle). Przygotuj **wiadomość-do-wkleienia** dla usera żeby przekazał Managerowi: TL;DR + status branch (SHA, acceptance) + link do kroniki + "Zlecam odpal /critical-code-review".
5. **STOP #2** — czekaj aż user wklei Ci wiadomość Managera z findingsami i rekomendacjami per-finding (FIX/BACKLOG/SKIP) + decyzjami usera.
6. **Po decyzjach Managera** → fix in-branch dla FIX'ów. SKIP entries w kronice z ustrukturyzowanym templatem (Impact / Koszt / Rationale / Re-evaluate gdy — ADR-0011). Update kroniki przez `/kronikarz live`.
7. **Jeśli były fix-y z review** → re-test scenariuszy dotyczących zmian. **STOP #3** dla user re-weryfikacji. **Jeśli zero fix'ów (wszystko BACKLOG/SKIP)** → pomiń STOP #3.
8. **Raport końcowy do Managera** (przez user-mediated wiadomość-do-wkleienia): TL;DR + status (user QA ✅, review APPROVE/NEEDS-FIX, re-test ✅/N/A) + lista BACKLOG entries do dopisania + "Zlecam /kronikarz close".
9. **Twoja praca tu się kończy.** Manager: odpala `/kronikarz close`, pyta usera "merge?", po user "akcept" pushuje + merguje. **NIE pushujesz, nie mergujesz, nie odpalasz `/kronikarz close`** — Manager owner of remote/main.

**NIE dotykaj shared indexów:**
- `doc/features/*/backlog.md`
- `doc/backlog.md`
- `doc/history/README.md`
- `doc/features/*/observations/*`

Manager aktualizuje je post-merge na develop. W Twoim raporcie końcowym **zawrzyj sekcję "Post-merge Manager action"** z ready-to-apply listą zmian (które items oznaczyć `[x]`, które follow-upy z code review dopisać do backlogu, entry w history/README do dodania). Manager ma gotowy patch zamiast re-wymyślać z kroniki.

**Powód:** równoległe branche edytujące shared docs → merge drugi zawsze CONFLICTING (pattern obserwowany 2×). Manager jako single writer eliminuje race.

**NIE merguj do `<source-branch>`** — user merguje po review.

## Raport zwrotny

Gdy push + PR zrobione, odpowiedz userowi krótko:
- Link do PR
- Czy były odchylenia od planu (i gdzie opisane w kronice)
- Czy code review wygenerował follow-upy które zostały w backlogu (lista)
- Czy wszystkie acceptance criteria spełnione

User przekaże ten raport Managerowi, który zrobi verification Medium i ewentualny merge.

Powodzenia. 🚀
```

## Uwagi jak adaptować briefing

- **Krótszy dla małych tasków.** Jeśli task to "fix literówki w nagłówku" — briefing może być 10 linii. Briefing ma być proporcjonalny do zadania, nie template'owy.
- **Dłuższy dla ryzykownych tasków.** Jeśli task dotyka agent-loop, security boundaries, migrations — rozbuduj sekcję "Pułapki" i "Zasady do przypomnienia".
- **Język usera.** Jeśli user pisze po polsku — briefing po polsku. Jeśli angielski — angielski. Subagent zobaczy briefing + CLAUDE.md w jego natywnym języku.
- **Nie duplikuj planu.** Briefing to onboarding message, plan to kontrakt pracy. Linkuj, nie kopiuj.

## Co NIE piszesz w briefingu

- Pełnego opisu problemu — to jest w planie
- Listy plików do edycji — to jest w planie
- Rozwiązań technicznych — subagent ma to sam zaproponować
- Pochwał albo motivation speeches — subagent to Claude, nie intern

## Final test

Przeczytaj swój briefing jakbyś był świeżym Claude'em bez żadnego kontekstu. Czy od razu wiesz: (a) co masz zrobić, (b) gdzie znaleźć szczegóły, (c) czego nie dotykać, (d) kiedy skończyć, (e) co zrobić po skończeniu? Jeśli tak — briefing jest gotowy.
