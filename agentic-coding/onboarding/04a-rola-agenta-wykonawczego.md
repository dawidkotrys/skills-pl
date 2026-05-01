# 04a. Rola agenta wykonawczego

Counterpart do [`code-manager/SKILL.md`](../skille/code-manager/SKILL.md) **z perspektywy drugiej strony** — agenta wykonawczego (Sonnet, pracującego w worktree lub na branchu).

Manager planuje i orkiestruje. **Ty piszesz kod.** Ten dokument mówi: co dostajesz, co robisz, czego nie robisz, kiedy raportujesz.

Pełna choreografia trzech aktorów (User ↔ Manager ↔ Executor) — zobacz [00-glowny-flow.md](./00-glowny-flow.md).

---

## Co dostajesz od managera

Wiadomość-do-wkleienia od managera (user kopiuje). Format zależy od trybu:

### Tryb 4A — full plan (mały-średni task)

- Link do `doc/plans/<branch>.md` z **pełnym planem** (cel, scope, acceptance criteria, scenariusze testowe, pierwsze 3 kroki, sekcja "Koniec pracy")
- Sekcja **"Punkty startowe"** — pliki do przeczytania **w pełni** zanim cokolwiek zaczniesz proponować
- Sekcja **"Pierwsze 3 kroki"** — żebyś nie zaczynał od "let me explore" (waste of tokens)
- Sekcja **"Koniec pracy"** — sekwencja 3-STOP

### Tryb 4B — bridge (slice z PRD, large initiative)

- Link do `doc/plans/<branch>.md` z **krótkim** bridge planem (~30-50 linii)
- Link do issue w `doc/backlog.md` (acceptance criteria — **source of truth**)
- Link do PRD w `doc/decisions/NNNN-<slug>.md` (kontekst dlaczego)
- Wycinek z PRD relevantny dla tego slica

**W bridge mode acceptance criteria są w issue body, nie w planie. Plan-bridge ich nie powtarza** — czytasz issue.

---

## Co robisz — sekwencja

### 1. Czytaj zanim cokolwiek ruszasz

- `CLAUDE.md` (root + relevantne nested)
- `CONTEXT.md` (terms domeny — używaj ich w nazwach)
- Plan / bridge w `doc/plans/<branch>.md`
- Issue body w `doc/backlog.md` (jeśli bridge mode)
- PRD w `doc/decisions/NNNN-*.md` (jeśli bridge mode)
- Pliki z sekcji "Punkty startowe" — **pełne**, nie diffy
- 2-3 ostatnie kroniki w `doc/history/` — żeby złapać format i otwarte problemy

### 2. Odpal `/kronikarz live` ZANIM zaczniesz pisać kod

Skill stworzy szkielet kroniki w `doc/history/YYYY-MM-DD-<branch>.md` (jeśli nie istnieje). Wypełnij **przed** kodem:

- **Cel** — co osiąga ta zmiana z perspektywy usera (1-3 zdania)
- **Architektura i wzorce** — które patterny zastosujesz i dlaczego

Tę sekcję wypełniasz **przed** kodem żeby ustabilizować swój plan i mieć baseline na pull-up review managera. Kronika żyje przez cały lifecycle, kolejne fazy dopisują (nie nadpisują).

### 3. Implementuj

Per slice / faza:

- **Vertical slice** end-to-end (zasada #8). Nie horizontal.
- **Cienkie** slicesy (zasada #10). Bias do dzielenia.
- Komentarze w kodzie **krótkie** linkują do kroniki:
  ```typescript
  // kronika: doc/history/2026-05-01-feat-checkout.md#decyzja-3
  ```
- Per nietrywialna decyzja → wpis w sekcji "Implementacja log" kroniki:
  ```
  ### Decyzja N: <nazwa>
  Kontekst: ...
  Wybór: ...
  Alternatywy: ... (czemu odrzucone)
  Konsekwencje: ...
  Commit: <SHA>
  ```

### 4. Update kronikę po każdej fazie

Per faza, append entries (nie nadpisuj):

| Faza | Sekcje kroniki |
|---|---|
| Po implementacji | Cel, Nowe pliki, Zmodyfikowane pliki, Architektura, API, Implementacja log |
| Po user QA | 🧪 Testy (wyniki per scenariusz, fix commits jeśli były) |
| Po code review (od managera) | Code review findings + decyzje per-finding (FIX/BACKLOG/SKIP) |
| Po re-test | 🧪 Testy (re-test results) |

**Kronika live = NIE commit, NIE push, NIE update backlogu/indeksu.** Manager robi `/kronikarz close` na końcu — to jego responsibility.

### 5. Przygotuj scenariusze testowe inline na czat

Format dla user QA (idą **w czacie do managera/usera**, nie tylko w kronice):

```
🧪 Test 1: <nazwa>

Setup: <konkretne kroki przygotowania>
Kroki:
1. <kliknij/wpisz/zrób X>
2. <obserwuj Y>

Acceptance: <co user powinien zobaczyć>
Co sprawdza: <1 zdanie po stronie funkcjonalnej>
```

User QA odbywa się **na nich**. Bez scenariuszy → blind clicking → nieprzewidywalna jakość weryfikacji.

### 6. (Opcjonalnie) Odpal `/design-checker`

**Tylko jeśli zmiana dotyka UI** (`*.tsx`, `*.css`, design tokens). **Po STOP #1 user QA, przed raportem do managera.**

Output: `doc/design-reviews/YYYY-MM-DD-<branch>.md`. 

- Werdykt **PASS** → wzmianka w raporcie do managera, idziesz dalej
- Werdykt **NEEDS FIXES** → fix-uj naruszenia (kolory hardcoded, spacing poza skalą, typografia, accessibility) → ponowny `/design-checker` → dopiero raport do managera

### 7. STOP #1 — czekaj na user QA

Po implementacji + scenariuszach inline + (opcjonalnym) design-check → **stop**. Czekasz na user feedback per scenariusz.

User mówi:
- ✅ "wszystko ok" → idziesz do raportu (krok 8)
- ⚠️ "poprawki: [lista]" → fix-y in-branch (commit `fix per user QA`), update kronika 🧪 Testy, **ponowny STOP #1** (re-test po fixach)
- ❌ "broken" → flag eskalacja w raporcie, executor nie próbuje sam wymyślić rozwiązania

### 8. Raport do managera (przez user-mediated wklejkę)

Format:

```
TL;DR: Implementacja gotowa, user QA ✅, branch <X>.
Kronika: doc/history/YYYY-MM-DD-<branch>.md
Design check: PASS / NEEDS FIXES → naprawione (jeśli odpalany)
Zlecam: /critical-code-review
```

User kopiuje wiadomość do managera. Manager Tryb 5A robi external review.

### 9. STOP #2 — przyjmij decyzje z review

Manager wraca z wiadomością-do-wkleienia: lista findings z decyzjami per-finding (FIX/BACKLOG/SKIP).

Twoje akcje:
- **FIX** — fix in-branch, commit, kronika update (sekcja Code review findings + decyzje)
- **BACKLOG** — przygotuj entry do `doc/backlog.md` (manager wstawi w kronikarz close, nie ty)
- **SKIP** — wpis w kronice z templatem:
  ```
  Decyzja: SKIP
  Impact: <opis>
  Koszt fix-a: <oszacowanie>
  Rationale: <dlaczego SKIP>
  Re-evaluate gdy: <warunek triggerujący ponowną ocenę>
  ```

### 10. STOP #3 — re-test po fix-ach z review

Tylko jeśli były FIX-y. Jeśli wszystko BACKLOG/SKIP — **pomijasz**.

Re-testujesz **scenariusze których dotykały zmiany z review**. Update kronika 🧪 Testy (re-test results).

### 11. Raport końcowy do managera

```
Wszystkie fix-y z review zaaplikowane, re-test ✅ (lub N/A jeśli wszystko BACKLOG/SKIP).
Kronika finalna: doc/history/YYYY-MM-DD-<branch>.md
Zlecam: /kronikarz close
```

User kopiuje do managera. Manager Tryb 5B → close → autonomy gate → merge.

**Twoja praca tu się kończy.**

---

## Czego NIE robisz

- ❌ **NIE odpalasz `/critical-code-review`** — to jest peer review przez managera (Opus), nie self-review (Sonnet ↔ Sonnet = confirmation bias). Per zasada #25
- ❌ **NIE pushujesz** — manager owner of remote
- ❌ **NIE mergujesz** — manager owner of main, autonomy gate przed merge
- ❌ **NIE odpalasz `/kronikarz close`** — to robi manager, ty robisz tylko `live`
- ❌ **NIE update'ujesz `doc/backlog.md` ani `doc/history/README.md`** — kronikarz close to robi
- ❌ **NIE ignorujesz STOP-ów** — zatrzymujesz się i czekasz na user feedback po każdej fazie
- ❌ **NIE rozszerzasz scope poza plan** — jeśli widzisz potrzebę, flagujesz w raporcie do managera, nie wprowadzasz unilaterally
- ❌ **NIE commitujesz bez explicit zgody** — per CLAUDE.md rule #9 (chyba że plan/bridge wyraźnie pozwala na commit per faza)

---

## Komunikacja z managerem (przez usera)

Zasady (skrót):

- ✅ **Konkretne fakty**: branch, commit SHA, pliki, scenariusze. Nie "wszystko działa" — "test 1, 2, 3 ✅, manualny smoke pass na flow X"
- ✅ **Linkuj artefakty**: kronika, design review, fix commits, plan
- ✅ **Bez emocji, bez "musiałem", bez "kryzys"** — neutralne raporty
- ✅ **Eskalacja**: jeśli plan rozjeżdża się z rzeczywistością (assumption violation, blocker) — flagujesz w raporcie, **nie** próbujesz wymyślić rozwiązanie sam (per zasada #4 — kod jest polem bitwy, ale decyzje strategiczne wracają do managera/usera)

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
4. re-read kronika + plan       → żeby załadować świeży kontekst z dysku
5. kontynuuj
```

`doc/session/` jest gitignored — to ulotny scratch, nie historic record.

### Kiedy NIE używać

- Krótka sesja (mały task, 1 slice) — flow zmieści się w smart zone
- Brak kontekstu wartego zachowania → po prostu `/clear` i re-read plików z dysku
- Per zasada #2 (Memento): dysk jest source of truth, jeśli wszystko ważne jest w plikach, restore nie jest potrzebny

---

## Powiązane skille (które ty odpalasz)

- **`/tdd`** — gdy plan zaleca test-first (vertical red-green-refactor)
- **`/diagnose`** — gdy task to bug fixing (Reprodukcja → Hipotezy → Fix → test regresji)
- **`/improve-codebase-architecture`** — rzadko, gdy plan zawiera refactor / deepening modułów
- **`/design-checker`** — po STOP #1 user QA, jeśli zmiana dotyka UI (przed raportem do managera)
- **`/save-session-agent` + `/restore-session-agent`** — przy długiej sesji w smart→dumb zone

## Powiązane skille (które odpala manager, NIE ty)

- **`/critical-code-review`** — Tryb 5A managera, peer review pracy executora
- **`/kronikarz close`** — Tryb 5B managera, finalizacja kroniki + commit + index update

---

## Anti-patterny

- **Implementacja przed czytaniem CLAUDE.md / CONTEXT.md / planu** — losowo wymyślasz patterny, drift od konwencji repo, manager wpada na review które nie pasuje do projektu
- **Kronika tylko w trybie close** — manager wpada na pustą kronikę, brakuje rozumowania per decyzję, pull-up review niemożliwy
- **Pomijanie scenariuszy testowych inline** — user QA bez scenariuszy = blind clicking, nieprzewidywalna jakość STOP #1
- **Ignorowanie sekwencji 3-STOP** — łatwo zrobić "jak skończę wszystko, raport" zamiast STOP per faza. Łamie filozofię "po co reviewować coś co nie działa"
- **Self-review zamiast raport do managera** — łamie peer review principle (zasada #25)
- **Multi-slice work bez save/restore** — wpadasz w dumb zone w środku slica 4 z 7, halucynacje, kosztowne błędy
- **Hardcoded values żeby satisfact-ować testy** — agent może to robić pod presją (badanie Anthropic 2026-04-02). Manager nie naciska "musisz / kryzys" → ty nie powinieneś desperacko hackować testów
- **Brak komentarzy w kodzie linkujących do kroniki** — future agent edytujący ten kod nie wie skąd wzięło się rozwiązanie, powtarza analizę alternatyw

---

## Test sam dla siebie przed raportem

Przeczytaj draft raportu i zadaj sobie pytania:

- **Czy manager ma wszystko co potrzebne** żeby zrobić code review bez dodatkowych pytań? (Branch, kronika, scenariusze testowe, design check status, lista commits)
- **Czy są konkretne fakty**, nie "wszystko działa"?
- **Czy flagujem assumption violations** które wykryłem w trakcie implementacji?
- **Czy nie próbuję podejmować decyzji strategicznych sam** (zmiana scope, nowe features, nowe abstrakcje)?

Jeśli na którekolwiek "nie" — przepisz raport.
