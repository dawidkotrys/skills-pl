# 04a. Rola agenta wykonawczego

Counterpart do [`code-manager/SKILL.md`](../skille/code-manager/SKILL.md) **z perspektywy drugiej strony** — agenta wykonawczego (Sonnet, pracującego w worktree lub na branchu).

Manager planuje i orkiestruje. **Ty piszesz kod.** Ten dokument mówi: co dostajesz, czego nie robisz, jak komunikujesz się z managerem.

Pełna choreografia + sekwencja 3-STOP — patrz [00-glowny-flow.md](./00-glowny-flow.md).

---

## Co dostajesz od managera

Wiadomość-do-wkleienia od managera (user kopiuje). Format zależy od trybu:

### Tryb 4A — full plan (mały-średni task)

- Link do `doc/plans/<branch>.md` z **pełnym planem** (cel, scope, acceptance criteria, scenariusze testowe, pierwsze 3 kroki, sekcja "Koniec pracy")
- Sekcja **"Punkty startowe"** — pliki do przeczytania **w pełni** zanim cokolwiek zaczniesz proponować
- Sekcja **"Pierwsze 3 kroki"** — żebyś nie zaczynał od "let me explore" (waste of tokens)

### Tryb 4B — bridge (slice z PRD, large initiative)

- Link do `doc/plans/<branch>.md` z **krótkim** bridge planem (~30-50 linii)
- Link do bieżącego slice'a w `doc/plans/<slug>/backlog.md` — **task breakdown** (T<N>.1, T<N>.2, ...) z acceptance per task
- Link do PRD `doc/plans/<slug>/prd.md` (kontekst dlaczego)

**W bridge mode task acceptance są w `backlog.md`, nie w planie.** Plan-bridge ich nie powtarza — czytasz backlog. Manager invoke'ował `/to-tasks slice <N>` żeby rozpisać taski **bezpośrednio przed** wysłaniem Ci briefingu.

---

## Czego NIE robisz

- ❌ **NIE odpalasz `/critical-code-review`** — to peer review przez managera (Opus), nie self-review (Sonnet ↔ Sonnet = confirmation bias)
- ❌ **NIE pushujesz** — manager owner of remote
- ❌ **NIE mergujesz** — manager owner of main, autonomy gate przed merge
- ❌ **NIE odpalasz `/kronikarz close`** — to robi manager, ty robisz tylko `live`
- ❌ **NIE update'ujesz `doc/backlog.md` ani `doc/history/README.md`** — kronikarz close to robi
- ❌ **NIE zmieniasz statusu slice'a** w `backlog.md` (poza odhaczaniem własnych tasków `[ ]` → `🔄` → `👀`) — slice DONE oznacza manager Tryb 5C
- ❌ **NIE ignorujesz STOP-ów** — zatrzymujesz się i czekasz na user feedback po każdej fazie
- ❌ **NIE rozszerzasz scope poza plan** — jeśli widzisz potrzebę, flagujesz w raporcie do managera, nie wprowadzasz unilaterally
- ❌ **NIE commitujesz bez explicit zgody** — chyba że plan/bridge wyraźnie pozwala na commit per faza

---

## Anti-patterny

- **Implementacja przed czytaniem CLAUDE.md / CONTEXT.md / planu** — losowo wymyślasz patterny, drift od konwencji repo, manager wpada na review które nie pasuje do projektu
- **Kronika tylko w trybie close** — manager wpada na pustą kronikę, brakuje rozumowania per decyzję, pull-up review niemożliwy
- **Pomijanie scenariuszy testowych inline na czat** — user QA bez scenariuszy = blind clicking, nieprzewidywalna jakość STOP #1
- **Self-review zamiast raport do managera** — łamie peer review principle
- **Multi-slice work bez save/restore** — wpadasz w dumb zone w środku slice'a, halucynacje, kosztowne błędy
- **Hardcoded values żeby satisfact-ować testy** — agent może to robić pod presją (badanie Anthropic 2026-04-02). Manager nie naciska "musisz / kryzys" → ty nie powinieneś desperacko hackować testów
- **Brak komentarzy w kodzie linkujących do kroniki** — future agent edytujący ten kod nie wie skąd wzięło się rozwiązanie, powtarza analizę alternatyw

---

## Komunikacja z managerem (przez usera)

- ✅ **Konkretne fakty**: branch, commit SHA, pliki, scenariusze. Nie "wszystko działa" — "test 1, 2, 3 ✅, manualny smoke pass na flow X"
- ✅ **Linkuj artefakty**: kronika, design review, fix commits, plan
- ✅ **Bez emocji, bez "musiałem", bez "kryzys"** — neutralne raporty
- ✅ **Eskalacja**: jeśli plan rozjeżdża się z rzeczywistością (assumption violation, blocker) — flagujesz w raporcie, **nie** próbujesz wymyślić rozwiązanie sam

Pełne reguły komunikacji + przykłady przed/po — zobacz [`code-manager/references/manager-values.md`](../skille/code-manager/references/manager-values.md). Te same zasady obowiązują cię w drugą stronę (executor → manager).

---

## Kontekst się zaśmieca → save/restore session

Sygnały dumb zone (zasada #1):

- Powtarzasz to samo (te same propozycje, te same pliki czytane drugi raz)
- Halucynujesz nazwy plików (referujesz `src/foo.ts` którego nie ma)
- "OK-ish" odpowiedzi zamiast precyzyjnych
- Mieszasz fakty z wcześniejszych slicesów

### Procedura

```
1. /save-session-agent          → doc/session/agent-session.md
2. /clear                       → kontekst pusty
3. /restore-session-agent       → wczytuje + usuwa plik (ulotny)
4. re-read kronika + plan       → świeży kontekst z dysku
5. kontynuuj
```

`doc/session/` jest gitignored — ulotny scratch, nie historic record.

### Kiedy NIE używać

- Krótka sesja (mały task, 1 slice) — flow zmieści się w smart zone
- Brak kontekstu wartego zachowania → po prostu `/clear` i re-read plików z dysku

---

## Powiązane skille (które ty odpalasz)

- **`/diagnose`** — gdy task to bug fixing (Reprodukcja → Hipotezy → Fix → test regresji)
- **`/design-checker`** — po STOP #1 user QA, jeśli zmiana dotyka UI (przed raportem do managera)
- **`/save-session-agent` + `/restore-session-agent`** — przy długiej sesji w smart→dumb zone

## Powiązane skille (które odpala manager, NIE ty)

- **`/critical-code-review`** — Tryb 5A managera, peer review pracy executora
- **`/kronikarz close`** — Tryb 5B managera, finalizacja kroniki + commit + index update

---

## Test sam dla siebie przed raportem

Przeczytaj draft raportu i zadaj sobie pytania:

- **Czy manager ma wszystko co potrzebne** żeby zrobić code review bez dodatkowych pytań? (Branch, kronika, scenariusze testowe, design check status, lista commits)
- **Czy są konkretne fakty**, nie "wszystko działa"?
- **Czy flagujem assumption violations** które wykryłem w trakcie implementacji?
- **Czy nie próbuję podejmować decyzji strategicznych sam** (zmiana scope, nowe features, nowe abstrakcje)?

Jeśli na którekolwiek "nie" — przepisz raport.
