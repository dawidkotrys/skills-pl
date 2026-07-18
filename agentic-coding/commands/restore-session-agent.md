---
description: Odzyskaj kontekst agenta wykonawczego (universal — kod / copy / oferta / research) z `doc/session/agent-session.md` i zarchiwizuj plik po sukcesie.
---

Cel: załaduj kontekst aktualnej sesji **agenta wykonawczego** z pliku `doc/session/agent-session.md`. Po sukcesie archiwizujesz plik (ulotne — aktywna lokalizacja pusta po restore).

## Krok 1: Znajdź plik

```bash
ls doc/session/agent-session.md 2>&1
```

- Jeśli plik nie istnieje — zaalarmuj usera: *"Brak `doc/session/agent-session.md`. Czy na pewno wcześniej był wykonany `/save-session-agent`? Sprawdź worktree / cwd."* Zatrzymaj się.

## Krok 2: Wczytaj kontekst

Przeczytaj `doc/session/agent-session.md` w pełni. Załaduj do kontekstu:

- Domena pracy (kod / copy / oferta / research / inne)
- Rola — kim jesteś
- Bieżący task — na czym jesteś
- Co już zrobione + co zostało
- Otwarte pytania / blockery
- Kluczowe pliki / źródła
- Konwencje / styl
- Następny krok

**Obowiązkowo** przeczytaj pliki zlinkowane w sekcji Kluczowe pliki / źródła (kronika live, plan, źródła) — session-file to most, treść żyje na dysku.

## Krok 3: Sanity check stanu

Sprawdź czy stan środowiska zgadza się z plikiem:

- **Kod**: `git status --short`, `git branch --show-current`, `git log --oneline -5`
- **Copy / content**: `ls` ostatnio edytowane pliki, sprawdź mtime
- **Oferta / strategia / research**: `ls doc/`, sprawdź czy referencowane pliki istnieją

Jeśli **drift** (np. plik mówi "branch X" a jesteś na Y) — zaalarmuj usera przed dalszą pracą.

## Krok 4: Zarchiwizuj plik

```bash
mkdir -p doc/session/archive
mv doc/session/agent-session.md doc/session/archive/agent-session.md.$(date +%Y-%m-%d-%H%M)
ls doc/session/  # session-file przeniesiony do archive/
```

Folder `doc/session/` jest ulotny — scratchpad między save a restore, gitignored, nie commituje się; plik znika z aktywnej lokalizacji po restore. Nie `rm`: crash tuż po usunięciu = bezpowrotna utrata (gitignored, brak historii); `mv` do `archive/` zostawia ślad.

## Krok 5: Raport startowy

```
Agent session przywrócony z `doc/session/agent-session.md` (domena: <X>, plik zarchiwizowany).

## Briefing — gdzie jestem:
[2-3 zdania: rola, bieżący task, faza pracy]

## Co zostało do zrobienia:
[lista z session file]

## Otwarte:
[blockery / pytania]

## Zaczynam od:
[konkretny krok per "Następny krok po restore"]
```

## Uwagi

- Drift w Kroku 3 → **NIE archiwizuj** pliku (zostaw na miejscu). Daj userowi decyzję: aktualizujemy plik czy stan?
- Universal — restore działa w każdej domenie

$ARGUMENTS
