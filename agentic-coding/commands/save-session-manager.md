---
description: Zapisz aktualny kontekst sesji Code Managera przed `/clear`. Pozwala odzyskać kontekst po wyczyszczeniu przez `/restore-session-manager`.
---

Cel: utrwal kontekst aktualnej sesji **w roli Code Managera** (strategy mode) do pliku `doc/session/manager-session.md`. User za chwilę zrobi `/clear` — po nim wykona `/restore-session-manager` żeby załadować ten plik z powrotem do kontekstu.

## Krok 1: Sprawdź lokalizację

```bash
pwd
git rev-parse --show-toplevel 2>/dev/null
ls doc/session/ 2>/dev/null
```

- Jeśli istnieje `doc/session/manager-session.md` → ostrzeż usera ("istnieje już zapis sesji managera, nadpisać?") i czekaj na potwierdzenie
- Jeśli folder `doc/session/` nie istnieje — utwórz go (`mkdir -p doc/session`)

## Krok 2: Zbierz kontekst do zapisania

Jako Code Manager — strategiczna rola — Twój session-state ma zawierać **wszystko czego nowa sesja Managera potrzebuje** żeby kontynuować bezstratnie:

- **Bieżąca inicjatywa / scope** — nad czym pracujesz, na jakim etapie (planowanie / implementacja / review / merge)
- **Aktywne branche i worktrees** — `git worktree list`, status każdego (kto pracuje, na jakiej fazie 3-STOP)
- **Otwarte handoff'y** — czy czekasz na user QA? Na decyzje per-finding po review? Na user akcept dla merge?
- **Kluczowe decyzje** — co wynegocjowane / zaakceptowane w tej sesji (które ADR-y do napisania, które TODO odhaczone)
- **Status backlogów** — co odhaczone w tej sesji, jakie nowe entries dopisane
- **Linki do kluczowych plików** — kroniki live, code-review reports, plany w `doc/plans/`, PRD w `doc/decisions/`
- **Nierozwiązane pytania / blockery** — co czeka na decyzję, co eskalowane
- **Następny krok po restore** — konkretnie, co zrobić jako pierwsze gdy sesja zostanie wczytana

## Krok 3: Zapisz plik

Format pliku `doc/session/manager-session.md`:

```markdown
# Manager session — <YYYY-MM-DD HH:MM>

## Bieżąca inicjatywa

<nazwa + scope w 2-3 zdaniach>

## Stan worktreeów

<lista z `git worktree list` + opis fazy każdego>

## Otwarte handoff'y

- [ ] STOP #1 user QA na branch `<X>` — czekam na ✅/⚠️/❌
- [ ] STOP #2 user decyzje per-finding na branch `<Y>` — czekam na FIX/BACKLOG/SKIP
- [ ] STOP #3 user re-weryfikacja na branch `<Z>`
- [ ] Autonomy gate "merge?" pending dla `<W>`

## Kluczowe decyzje tej sesji

- ...

## Status backlogów

- `doc/backlog.md`: <co zmienione w tej sesji>
- `doc/features/<x>/backlog.md`: <co zmienione>

## Kluczowe pliki (linki)

- Kronika live: doc/history/YYYY-MM-DD-<branch>.md
- Code review: doc/code-reviews/YYYY-MM-DD-<branch>.md
- Plan: doc/plans/<branch>.md
- PRD: doc/decisions/NNNN-<slug>.md

## Nierozwiązane / blockery

- ...

## Następny krok po restore

<konkretnie co zrobić — np. "Czekaj na user QA na branch X. Po feedback od user'a, idź do Tryb 5A external review.">
```

## Krok 4: Potwierdzenie

Po zapisaniu, poinformuj usera:

```
Manager session zapisany do `doc/session/manager-session.md` (X linii).

Możesz teraz wykonać `/clear`. Po wyczyszczeniu wpisz `/restore-session-manager`
żeby odzyskać kontekst.

Plik zostanie automatycznie usunięty po restore (ulotny session-state).
```

## Uwagi

- **NIE commituj** pliku do git — folder `doc/session/` powinien być w `.gitignore` (jeśli nie jest, dorzuć)
- Plik **nadpisywany** przy każdym `/save-session-manager` — to nie jest historic record, to jest scratchpad
- Worktree per-branch = brak konfliktu między równoległymi managerami (każdy worktree ma własne `doc/session/`)

$ARGUMENTS
