# Subagent Briefing Template

Gdy Manager kończy pisanie planu (`doc/plans/<branch>.md`), przygotowuje **briefing** — prompt startowy executora, którego Manager spawnuje bezpośrednio jako subagenta. (Wariant dwóch okien: user wkleja briefing jako pierwszą wiadomość w osobnej sesji executora.)

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

Przeczytaj CLAUDE.md projektu w całości — briefing nie powtarza jego reguł; wymienia tylko te, które są krytyczne SPECYFICZNIE dla tego taska:

- **<Rule X z CLAUDE.md z wyjaśnieniem dlaczego w tym zadaniu kluczowe>**
- **<Rule Y>**
- **<Specyfika projektu jeśli istotna — np. "no-overwrite policy w agent tools, pamiętaj przy dotykaniu write_file">**

## Pierwsze 3 kroki

1. `git status && git log --oneline -5` — zobacz w jakim stanie zaczynasz
2. Przeczytaj `doc/plans/<branch-name>.md` w pełni
3. Przeczytaj pliki z sekcji "Punkty startowe" planu
4. **Przedstaw plan implementacji** (konkretne komponenty, akcje, flow) **zanim napiszesz pierwszą linię kodu** i czekaj na approval Managera, który Cię prowadzi.

## Gdy skończysz

Sekwencja agent ↔ user ↔ Manager (3-STOP — pełna specyfikacja: ~/.claude/skills/code-manager/references/lifecycle-3stop.md):

1. STOP #1 user QA: /kronikarz live → scenariusze inline (co klikasz → czego oczekujesz) → user testuje; poprawki = fix in-branch + ponowny STOP #1.
2. STOP #2 review: NIE odpalasz /critical-code-review — raport-do-wkleienia dla Managera; Manager robi review, user decyduje FIX/BACKLOG/SKIP; fixy in-branch + SKIP template.
3. STOP #3 re-test (tylko jeśli były FIXy): user re-testuje scenariusze dotknięte zmianami.
4. Raport końcowy do Managera („zlecam /kronikarz close"). NIE pushujesz, NIE mergujesz — Manager owner of remote/main.

**NIE dotykaj shared indexów:**
- `doc/features/*/backlog.md`
- `doc/backlog.md`
- `doc/history/README.md`
- `doc/features/*/observations/*`

Manager aktualizuje je post-merge na develop. W Twoim raporcie końcowym **zawrzyj sekcję "Post-merge Manager action"** z ready-to-apply listą zmian (które items oznaczyć `[x]`, które follow-upy z code review dopisać do backlogu, entry w history/README do dodania). Manager ma gotowy patch zamiast re-wymyślać z kroniki.

**Powód:** równoległe branche edytujące shared docs → merge drugi zawsze CONFLICTING (pattern obserwowany 2×). Manager jako single writer eliminuje race.

**NIE merguj do `<source-branch>`** — user merguje po review.

## Raport końcowy

Gdy praca domknięta (po STOP #3 lub gdy wszystkie findingi poszły w BACKLOG/SKIP), raportuj Managerowi krótko:
- Branch + link do kroniki
- Czy były odchylenia od planu (i gdzie opisane w kronice)
- Follow-upy z code review przygotowane do backlogu (lista, sekcja "Post-merge Manager action")
- Czy wszystkie acceptance criteria spełnione

Manager robi verification Medium, /kronikarz close i — po "akcept" usera — merge.

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
