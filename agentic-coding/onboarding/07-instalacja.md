# 07. Instalacja skili

## Wymagania

- **Claude Code CLI** zainstalowany ([instrukcja Anthropic](https://docs.claude.com/en/docs/claude-code))
- Konto Anthropic z dostępem do Claude (API key lub subskrypcja)
- macOS / Linux / WSL (Windows native może działać, ale nie testowane)

## Lokalizacja skili

Skille Claude Code żyją w `~/.claude/skills/{nazwa-skilla}/`. Każdy skill to katalog z:

- `SKILL.md` — główny plik z frontmatterem (`name`, `description`) i instrukcjami
- (opcjonalnie) podpliki `references/`, `modules/`, `scripts/` itd.

Claude Code automatycznie wykrywa skille z tego katalogu i triggeruje je gdy `description` w frontmatterze pasuje do intencji w rozmowie (lub gdy user explicite wpisuje `/{nazwa-skilla}`).

## Instalacja z tego repo

### Wariant 1 — pojedynczy skill

```bash
# Skopiuj skill do ~/.claude/skills/
cp -r ~/aiOS/Projekty/skills-pl/agentic-coding/skille/grill-with-docs ~/.claude/skills/

# Lub przez git clone + symlink (jeśli chcesz update przez git pull)
ln -s ~/aiOS/Projekty/skills-pl/agentic-coding/skille/grill-with-docs ~/.claude/skills/grill-with-docs
```

Po skopiowaniu — restart Claude Code (jeśli był odpalony) żeby wykrył nowy skill.

### Wariant 2 — wszystkie skille naraz

```bash
cd ~/aiOS/Projekty/skills-pl/agentic-coding/skille
for s in */; do
  cp -r "$s" ~/.claude/skills/
done

```

### Wariant 3 — symlink całego repo (dla developerów)

Jeśli chcesz **edytować skille u siebie i kontrybuować z powrotem do repo**:

```bash
# Sklonuj repo (jeśli jeszcze nie masz)
cd ~/aiOS/Projekty/
git clone https://github.com/{user}/skills-pl.git  # placeholder URL — patrz manifest

# Symlink każdy skill do ~/.claude/skills/
for s in ~/aiOS/Projekty/skills-pl/agentic-coding/skille/*/; do
  name=$(basename "$s")
  ln -s "$s" ~/.claude/skills/"$name"
done

```

Teraz każda zmiana w repo natychmiast działa w Claude Code.

## Weryfikacja

W Claude Code wpisz:

```
/help
```

Skille powinny być widoczne w liście. Albo wpisz część nazwy z `description` skilla i sprawdź czy auto-trigger zadziała:

```
"chcę grill na ten pomysł"
```

→ powinien auto-trigger `grill-with-docs`.

## Sugerowana kolejność instalacji

Jeśli zaczynasz z metodologią — instaluj **stopniowo**:

### Etap 1 — onboarding repo (najważniejsze)

1. `repo-onboarding` — onboarding nowego repo do metodologii (CLAUDE.md, CONTEXT.md, doc/)

### Etap 2 — daily flow

2. `grill-with-docs` — grilling pomysłu przed planem
3. `code-manager` — bird's-eye manager dla planowania i dispatch
4. `kronikarz` — dokumentacja zmian po implementacji

### Etap 3 — większe inicjatywy

5. `to-prd` — destination document

### Etap 4 — testowanie i debugowanie

6. `tdd` — TDD red-green-refactor
7. `diagnose` — pętla diagnostyczna

### Etap 5 — review i refactor

8. `critical-code-review` — krytyczne code review
9. `improve-codebase-architecture` — deepening modułów
10. `design-checker` — weryfikacja zgodności UI z design systemem (jeśli repo ma custom design tokens)

### Etap 6 — slash commands (session-state)

Slash commands nie są skilami — instalujesz je do `~/.claude/commands/<nazwa>.md` (NIE `~/.claude/skills/`).

```bash
cp ~/aiOS/Projekty/skills-pl/agentic-coding/commands/*.md ~/.claude/commands/
```

Komendy:

11. `/save-session-manager` + `/restore-session-manager` — kontekst Code Managera
12. `/save-session-agent` + `/restore-session-agent` — kontekst agenta wykonawczego (universal: kod / copy / oferta / research)

Plus dorzuć `doc/session/` do `.gitignore` projektu w którym używasz tych komend.

## Update

Repo to **kopia** — single source of truth jest u autora w `~/.claude/skills/`. Sync robi się manualnie: `git pull` w repo, ponownie kopiujesz / aktualizujesz symlinki.

Nie ma auto-sync. Nie ma menedżera pakietów. Świadoma decyzja.

## Troubleshooting

**Skill się nie triggeruje automatycznie.** Sprawdź `description` w `SKILL.md` — czy keywords pasują do twojej intencji. Możesz zmodyfikować lokalnie. Możesz też zawsze wpisać `/{nazwa-skilla}` żeby triggerować ręcznie.

**Skill robi dziwne rzeczy.** Przeczytaj `SKILL.md` — może instrukcje zakładają coś czego nie masz (np. konkretną strukturę `doc/`). Odpal `/repo-onboarding` żeby zaadaptować repo.

**Konflikty z istniejącymi skilami.** Jeśli masz już skill o tej samej nazwie — Claude Code użyje pierwszego znalezionego. Zmień nazwę katalogu albo usuń konflikt.
