# Commands — slash commands dla session-state

Folder zawiera **slash commands** (nie skille) dla Claude Code. Komendy nie mają auto-trigger ani description triggering — user świadomie wywołuje przez `/<nazwa-komendy>`.

## Lokalizacja instalacji

`~/.claude/commands/<nazwa>.md` — tam Claude Code je wczytuje. Skopiuj pliki z tego folderu lub utwórz symlinki.

## Komendy w tym folderze

### Session-state (per ADR-0008)

Manager i agent wykonawczy potrzebują save/restore kontekstu przy `/clear` (Memento problem). Komendy zapisują kontekst do plików tymczasowych w `doc/session/`, restore wczytuje + **usuwa** plik (ulotne).

| Komenda | Opis | Plik docelowy |
|---|---|---|
| `/save-session-manager` | Zapisz strategy mode Code Managera | `doc/session/manager-session.md` |
| `/restore-session-manager` | Wczytaj + usuń manager session | `doc/session/manager-session.md` |
| `/save-session-agent` | Universal save agenta wykonawczego (kod / copy / oferta / research) | `doc/session/agent-session.md` |
| `/restore-session-agent` | Wczytaj + usuń agent session | `doc/session/agent-session.md` |

## Workflow

```
1. Pracujesz w sesji (manager albo agent wykonawczy)
2. Kontekst się zaśmieca / zbliżasz się do dumb zone (~100k tokenów)
3. Wywołujesz /save-session-<rola> — komenda zapisuje kontekst do doc/session/<rola>-session.md
4. /clear (Claude Code czyści kontekst)
5. /restore-session-<rola> — komenda wczytuje plik do nowej sesji + usuwa go
6. Kontynuujesz pracę bez utraty kontekstu
```

## Universal `/save-session-agent`

Agent wykonawczy może pracować w różnych domenach (kod, copywriting, oferta, strategia, research). Komenda **wykrywa domenę** z plików w cwd + konwersacji, dostosowuje co zapisuje (kim jesteś, co robisz, konwencje stylu, kluczowe pliki).

## Mechanizm "delete after restore"

Folder `doc/session/` jest **ulotny** — pliki tam żyją tylko między save a restore. Po restore plik znika żeby uniknąć confusion przy kolejnym save (no stale state). Jeśli sanity check po restore wykrywa drift między plikiem a stanem repo — **plik NIE jest usuwany**, użytkownik decyduje co aktualizować.

## Worktree per-branch

Każdy worktree ma własne `doc/session/` (osobna struktura plików per branch) — brak konfliktu między równoległymi sesjami managera/agentów.

## Gitignore

Folder `doc/session/` powinien być w `.gitignore` projektu w którym używasz tych komend (NIE chcemy commit'ować ulotnych session-state'ów).

## Why komendy, nie skille

- Komendy nie potrzebują auto-trigger — user świadomie wywołuje
- Brak `description` triggering = mniej noise w skill list
- Krótszy plik (no frontmatter z `argument-hint`, `model`, `allowed-tools`)
- Per ADR-0008: "session commands jako slash commands, nie skille"
