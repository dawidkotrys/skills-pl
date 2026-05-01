# Kronikarz — Przewodnik dokumentacji

Ten plik zawiera rozszerzone wytyczne do generowania wpisu. Załaduj go gdy potrzebujesz głębszej perspektywy.

## Tryby — kiedy który

- **`live`** (default, agent wykonawczy w trakcie pracy): kronika żyje przez cały lifecycle taska. Append entries per faza (impl → user QA → review → re-test). NIE commit, NIE update backlog/indeks.
- **`close`** (Code Manager przed merge): finalizacja. Sign-off, update `doc/backlog.md`, update `doc/history/README.md`, commit. Manager merguje po user akcept (nie auto).

## Perspektywa Kronikarza

Kronikarz jest **dokumentalistą**, nie recenzentem kodu. Code review robi `/critical-code-review` (uruchamiany przez Code Managera, nie agenta wykonawczego).

Kronikarz zadaje sobie pytania:

- "Gdyby za miesiąc inny agent AI miał modyfikować ten moduł — czy miałby wszystko czego potrzebuje?"
- "Czy developer czytający ten kod po raz pierwszy zrozumie dlaczego podjęto takie decyzje?"
- "Czy znane problemy z review zostały uwzględnione w dokumentacji?"

## Współpraca z review

Code Manager (Opus) odpala `/critical-code-review` po user QA — nie agent wykonawczy. Raport: `doc/code-reviews/YYYY-MM-DD-<branch>.md`.

Findings z review trafiają do:
1. Sekcja "Code review findings + decyzje per-finding" w kronice (z statusem 🔴🟡🟢 + decyzją FIX/BACKLOG/SKIP)
2. `doc/backlog.md` jako nowe wpisy (tylko BACKLOG findings) — w trybie close

### SKIP findings — ustrukturyzowany template

Każdy finding świadomie odrzucony (low/medium niewart fix-a) wymaga:

```
- [LOW] 🟢 <symbol> → SKIP
  Impact: <co się stanie jeśli nie zrobimy>
  Koszt fix-a: <szacunkowy>
  Rationale: <dlaczego trade-off>
  Re-evaluate gdy: <warunek powrotu>
```

Bez tego templatu SKIP entry jest niepełny — manager close odrzuca i wraca do live.

## Decyzje architektoniczne — na co zwracać uwagę

Dokumentuj **decyzje**, nie problemy (problemy są w review). Zwróć uwagę na:
- Dlaczego wybrano dane podejście (np. Canvas zamiast DOM, edge functions zamiast API routes)
- Jakie alternatywy rozważano
- Co to oznacza dla przyszłego rozwoju
- Nowe wzorce wprowadzone na tym branchu (warte powielenia)

## Brakujące pytania — typowe sytuacje

Agent implementujący często pomija pytania o:
- **UX/Design**: "Jak powinno to wyglądać na mobile?", "Jaki jest expected behavior przy braku danych?"
- **Edge cases**: "Co się dzieje gdy user traci połączenie?", "Co jeśli lista jest pusta?"
- **Biznes**: "Czy to ma być dostępne dla wszystkich planów?", "Jaki jest expected flow dla nowego użytkownika?"
- **Integracje**: "Czy ten webhook ma retry logic?", "Co jeśli external API jest niedostępne?"

## Checklist kontekstu — przed generowaniem wpisu

Upewnij się że masz:

- [ ] `git log main..HEAD --oneline` — lista commitów
- [ ] `git diff main...HEAD --name-status` — lista plików (A/M/D/R)
- [ ] `git diff main...HEAD --stat` — statystyki zmian
- [ ] `git status` + `git diff` — niezacommitowane zmiany
- [ ] `git diff main...HEAD -- package.json` — nowe zależności
- [ ] Przeczytany kod kluczowych plików (max 8 w pełni, reszta z diffa)
- [ ] Przeczytane ostatnie wpisy w `doc/history/` (max 3 + nagłówki)
- [ ] Przeczytane raporty z `doc/code-reviews/` dla tego brancha
- [ ] Sprawdzony plan implementacji (`.claude/plans/`) jeśli istnieje

## Komentarze w kodzie ↔ kronika

W kodzie zostawiaj **krótkie** markery linkujące do kroniki — pełne rozumowanie zostaje w kronice. Format domyślny:

```typescript
// kronika: doc/history/2026-05-01-feat-checkout.md#decyzja-3
function processOrder(order: Order) { ... }
```

Zasada: **komentarz = "co i kiedy", kronika = "dlaczego"**. Future agent modyfikujący kod otwiera kronikę i widzi szerszy kontekst (alternatywy, trade-offy, kto co decydował).

W sekcji `## Zmodyfikowane pliki` kroniki dorzuć kolumnę "Linki do komentarzy w kodzie" (`src/foo.ts:42` → `#decyzja-3`).

## Typowe pułapki

- **Nie polegaj na samym diffie** — diff pokazuje co się zmieniło, ale nie jak to działa w kontekście
- **Nie pomijaj niezacommitowanych zmian** — `git status` może ujawnić dodatkowe zmiany
- **Nie kopiuj kodu do dokumentacji** — opisuj sygnatury, flow, decyzje
- **Nie duplikuj review** — kronikarz nie szuka bugów, tylko dokumentuje znane problemy z doc/code-reviews/
- **Nie zapominaj o poprzednich wpisach** — narastające problemy powinny być trackowane z fazy na fazę
- **Sprawdzaj czy faza rozwiązała coś z backlogu** — wcześniejsze wpisy mogą mieć otwarte issues które ta faza naprawia
- **Tryb live ≠ tryb close** — w live nie commituj, nie updateuj backlogu/indeksu. Czekaj aż manager wywoła close.
- **SKIP bez templatu = blokada close** — manager close nie finalizuje kroniki gdy jakiś SKIP nie ma Impact/Koszt/Rationale/Re-evaluate
