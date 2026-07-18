---
description: Odzyskaj kontekst Code Managera zapisany przez `/save-session-manager`. Wczytuje plik `doc/session/manager-session.md` i archiwizuje go po sukcesie (ulotne).
---

Cel: załaduj kontekst aktualnej sesji **w roli Code Managera** z pliku `doc/session/manager-session.md`, kontynuuj pracę bezstratnie. Po sukcesie archiwizujesz plik (ulotne — aktywna lokalizacja pusta po restore).

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

**Obowiązkowo** przeczytaj pliki zlinkowane w sekcji Kluczowe pliki (kronika live, plan) — session-file to most, treść żyje na dysku.

## Krok 3: Sanity check stanu repo

Po wczytaniu kontekstu, sprawdź czy stan repo zgadza się z tym co jest w pliku:

```bash
git status --short
git branch --show-current
git worktree list
git log --oneline -5
```

Porównaj z opisem w session file. Jeśli **zauważysz drift** (np. plik mówi "STOP #2 na branch X" ale `git log` pokazuje że X jest mergowany) — **zaraportuj to userowi przed dalszą pracą**.

## Krok 4: Zarchiwizuj plik (ulotny session-state)

```bash
mkdir -p doc/session/archive
mv doc/session/manager-session.md doc/session/archive/manager-session.md.$(date +%Y-%m-%d-%H%M)
ls doc/session/  # session-file przeniesiony do archive/
```

Folder `doc/session/` jest **ulotny** — scratchpad między save a restore, gitignored, nie commituje się. Nie `rm`: crash tuż po usunięciu = bezpowrotna utrata (gitignored, brak historii); `mv` do `archive/` zostawia ślad. Po archiwizacji plik znika z aktywnej lokalizacji, żeby uniknąć confusion przy kolejnym save (no stale state).

## Krok 5: Raport startowy

Po sukcesie poinformuj usera:

```
Manager session przywrócony z `doc/session/manager-session.md` (plik zarchiwizowany po wczytaniu).

## Krótki briefing — gdzie jesteśmy:
[2-3 zdania syntezy: bieżąca inicjatywa, najważniejszy aktywny handoff, następny krok]

## Otwarte handoff'y do śledzenia:
[lista z session file]

## Mam kontynuować od:
[konkretny krok per "Następny krok po restore" z pliku]
```

## Uwagi

- Jeśli sanity check (Krok 3) wykrywa drift → **NIE archiwizuj** pliku (zostaw na miejscu), daj userowi wybór: "Plik pokazuje stan X, repo pokazuje Y. Co aktualizujemy?"
- Jeśli folder `doc/session/` nie istniał (rare) → utwórz po fakcie do następnego save (`mkdir -p doc/session`)

$ARGUMENTS
