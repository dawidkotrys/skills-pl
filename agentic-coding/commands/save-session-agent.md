---
description: Universal session-save dla agenta wykonawczego. Zapisuje kontekst aktualnej pracy (kod, copy, oferta, research, …) do `doc/session/agent-session.md` przed `/clear`.
---

Cel: utrwal kontekst aktualnej sesji **agenta wykonawczego** do pliku `doc/session/agent-session.md`, niezależnie od domeny pracy. Universal — działa w każdym projekcie (kodowanie, copywriting, oferty, research, strategia). User za chwilę zrobi `/clear` — po nim wykona `/restore-session-agent` żeby załadować kontekst z powrotem.

## Krok 1: Sprawdź lokalizację

```bash
pwd
ls doc/ 2>/dev/null
ls doc/session/ 2>/dev/null
```

- Jeśli folder `doc/` nie istnieje — utwórz go (`mkdir -p doc/session`)
- Jeśli istnieje `doc/session/agent-session.md` → ostrzeż usera ("istnieje już zapis sesji agenta, nadpisać?") i czekaj na potwierdzenie

## Krok 2: Wykryj domenę pracy

Spójrz na pliki w cwd + na to nad czym pracowaliście w tej sesji. Wykryj jedną z domen:

- **Kod** — pliki `.ts/.js/.py/.go/...`, `package.json`, `git`
- **Copy / content** — `.md` z postami / artykułami / scenariuszami
- **Oferta / strategia** — dokumenty handlowe / planowanie biznesowe
- **Research** — notatki / analizy / źródła

Jeśli niejednoznaczne — zapytaj usera *"Co dokładnie zapisuję? (np. praca nad postem X / kod brancha Y / oferta dla Z)"*.

## Krok 3: Zbierz kontekst

Twój session-state agenta ma zawierać:

- **Kim jesteś** — w jakiej roli pracujesz tej sesji (np. agent wykonawczy na branch `feat/x`, copywriter dla Y, researcher dla projektu Z)
- **Co robisz teraz** — bieżący task w 2-3 zdaniach + faza (impl / draft / review / etc.)
- **Co już zrobione w tej sesji** — lista konkretnych output'ów (commity / akapity / pliki / decyzje)
- **Co zostało do zrobienia** — explicite, tak żeby nowa sesja wiedziała co robić jako pierwsze
- **Otwarte pytania / blockery** — czekasz na decyzję usera? Na feedback? Na external resource?
- **Kluczowe pliki / źródła** — co czytałeś, co edytowałeś, gdzie są decyzje (linki względne, np. `doc/plans/...`)
- **Konwencje / styl** — co specyficznego dla tego projektu (per `CLAUDE.md`, lessons-learned, style guide)
- **Następny krok po restore** — konkretnie, czym zacząć w nowej sesji

## Krok 4: Zapisz plik

Format pliku `doc/session/agent-session.md`:

```markdown
# Agent session — <YYYY-MM-DD HH:MM>

## Domena pracy

<kod / copy / oferta / research / inne>

## Rola

<kim jesteś — np. "agent wykonawczy na branch `feat/oauth-flow` w worktree
`<projekt>-feat-oauth`">

## Bieżący task

<2-3 zdania o tym co robisz, na jakiej fazie>

## Co już zrobione w tej sesji

- ...
- ...

## Co zostało do zrobienia

1. ...
2. ...
3. ...

## Otwarte pytania / blockery

- ...

## Kluczowe pliki / źródła

- doc/plans/<branch>.md (plan pracy)
- doc/history/YYYY-MM-DD-<branch>.md (kronika live)
- src/foo.ts:42 (ostatnia ważna edycja)
- ...

## Konwencje / styl tej sesji

- Z `CLAUDE.md`: <key rules tego projektu>
- Z lessons-learned: <jeśli applicable>
- Inne: <specyficzne ustalenia z user'em w tej sesji>

## Następny krok po restore

<konkretnie co zrobić jako pierwsze — np. "Wczytaj plan w doc/plans/feat-oauth.md,
sprawdź acceptance criteria #3 (token refresh), zaimplementuj rotację refresh tokena.
Po impl odpalisz /kronikarz live">
```

## Krok 5: Potwierdzenie

Po zapisaniu poinformuj usera:

```
Agent session zapisany do `doc/session/agent-session.md` (X linii, domena: <domena>).

Możesz teraz wykonać `/clear`. Po wyczyszczeniu wpisz `/restore-session-agent`
żeby odzyskać kontekst. Plik zostanie usunięty po restore (ulotny).
```

## Uwagi

- **NIE commituj** pliku do git — folder `doc/session/` ma być w `.gitignore`
- Plik **nadpisywany** przy każdym `/save-session-agent` — scratchpad, nie historic record
- Universal — działa w każdej domenie. NIE jest przywiązany do kodu

$ARGUMENTS
