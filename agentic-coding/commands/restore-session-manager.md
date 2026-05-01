---
description: Odzyskaj kontekst Code Managera zapisany przez `/save-session-manager`. Wczytuje plik `doc/session/manager-session.md` i USUWA go po sukcesie (ulotne).
---

Cel: załaduj kontekst aktualnej sesji **w roli Code Managera** z pliku `doc/session/manager-session.md`, kontynuuj pracę bezstratnie. Po sukcesie usuwasz plik (ulotne — folder ma być pusty po restore).

## Krok 1: Znajdź plik

```bash
ls doc/session/manager-session.md 2>&1
```

- Jeśli plik nie istnieje — zaalarmuj usera: *"Brak `doc/session/manager-session.md`. Czy na pewno wcześniej był wykonany `/save-session-manager`? Sprawdź czy jesteś w odpowiednim worktree."* I zatrzymaj się.

## Krok 2: Wczytaj kontekst

Przeczytaj `doc/session/manager-session.md` w pełni (`Read` tool). Załaduj do swojego kontekstu:

- Bieżąca inicjatywa / scope
- Stan worktreeów i otwarte handoff'y
- Kluczowe decyzje tej sesji
- Status backlogów (co zmienione)
- Kluczowe pliki (kroniki, review, plany, PRD)
- Nierozwiązane / blockery
- Następny krok

## Krok 3: Sanity check stanu repo

Po wczytaniu kontekstu, sprawdź czy stan repo zgadza się z tym co jest w pliku:

```bash
git status --short
git branch --show-current
git worktree list
git log --oneline -5
```

Porównaj z opisem w session file. Jeśli **zauważysz drift** (np. plik mówi "STOP #2 na branch X" ale `git log` pokazuje że X jest mergowany) — **zaraportuj to userowi przed dalszą pracą**.

## Krok 4: Usuń plik (ulotny session-state)

```bash
rm doc/session/manager-session.md
ls doc/session/  # weryfikacja czy folder pusty
```

Per ADR-0008: folder `doc/session/` jest **ulotny** — pliki tam żyją tylko między save a restore. Po restore plik znika żeby uniknąć confusion przy kolejnym save (no stale state).

## Krok 5: Raport startowy

Po sukcesie poinformuj usera:

```
Manager session przywrócony z `doc/session/manager-session.md` (plik usunięty po wczytaniu).

## Krótki briefing — gdzie jesteśmy:
[2-3 zdania syntezy: bieżąca inicjatywa, najważniejszy aktywny handoff, następny krok]

## Otwarte handoff'y do śledzenia:
[lista z session file]

## Mam kontynuować od:
[konkretny krok per "Następny krok po restore" z pliku]
```

## Uwagi

- Jeśli sanity check (Krok 3) wykrywa drift → **NIE usuwaj** pliku, daj userowi wybór: "Plik pokazuje stan X, repo pokazuje Y. Co aktualizujemy?"
- Jeśli folder `doc/session/` nie istniał (rare) → utwórz po fakcie do następnego save (`mkdir -p doc/session`)

$ARGUMENTS
