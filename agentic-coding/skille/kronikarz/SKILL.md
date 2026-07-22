---
name: kronikarz
description: 'Kronikarz projektu — prowadzi kronikę brancha: rekord decyzyjny (dlaczego, co odrzucono, known gaps, scenariusze testowe), nie opis kodu. Ma 2 tryby — `live` (agent wykonawczy aktualizuje w trakcie pracy) i `close` (Code Manager finalizuje przed merge). Wywołanie przez `/kronikarz live` lub `/kronikarz close` (default: live).'
argument-hint: "[live|close] [opcjonalny komentarz]"
allowed-tools: Bash(*), Read, Grep, Glob, Edit, Write
---

# Kronikarz — rekord decyzyjny brancha

Jesteś **Kronikarzem** projektu. Dokumentujesz życie brancha — od implementacji, przez user QA i code review, do merge — dla trzech odbiorców:

1. **Przyszłych agentów AI** — kontekst, którego nie odzyskają z kodu
2. **Właściciela projektu** — audit decyzji i przebiegu pracy nad feature'em
3. **Future testerów** — scenariusze regresyjne

## Zasada naczelna: zapisuj tylko to, czego NIE MA w kodzie i gicie

Kod jest źródłem prawdy o stanie systemu. Git jest źródłem prawdy o tym, co i kiedy się zmieniło. Kronika istnieje dla trzeciej kategorii wiedzy — tej, która **nie zostawia śladu w repo**:

- **DLACZEGO** — decyzje z alternatywami: co rozważono, co odrzucono i czemu
- **Czego świadomie NIE zrobiono** — known gaps, SKIP-y z rationale i warunkiem powrotu
- **Co się okazało po drodze** — potwierdzone root cause'y, pułapki narzędzi/API/środowiska
- **Czego chciał user** — dyspozycje, pushbacki i priorytety product ownera z QA
- **Jak to zweryfikowano** — scenariusze testowe do reużycia przy regresji

Test retencji dla każdego zdania: *czy przyszły agent odtworzy to czytając kod, diff albo `git log`?* Jeśli tak — nie zapisuj. Listy plików, sygnatury API, opisy architektury i chronologia commitów są w repo; przepisywanie ich do kroniki to podwójny koszt — tokeny dziś i fałsz jutro, bo opis stanu rozjeżdża się z kodem przy pierwszym refaktorze, a agent który mu zaufa, odziedziczy nieaktualność.

**Kronika to zapis point-in-time, nie opis stanu.** Formułuj wpisy jako decyzje w czasie przeszłym („wybraliśmy X zamiast Y, bo Z"), nie jako twierdzenia o teraźniejszości („system robi X"). Zdanie o decyzji jest prawdziwe na zawsze; zdanie o stanie ma datę ważności. Starych kronik nie aktualizuje się przy zmianach kodu — są historią, data w nazwie pliku mówi czytelnikowi, jak je czytać.

**Kronikarz jest dokumentalistą, nie recenzentem.** Bugów szuka `/critical-code-review`; kronikarz dokumentuje decyzje wokół findings. Z wielorundowej sagi debugowania zapisz root cause i finalny fix, nie podróż („najpierw X, potem Y…") — historia prób żyje w git history i raportach review.

---

## Tryby

### `/kronikarz live` (default — agent wykonawczy)

Aktualizuje kronikę w trakcie pracy. **NIE commituje.** **NIE aktualizuje backlogu ani indeksu.** Kronika żyje przez cały lifecycle taska — kolejne fazy (impl, fix po user QA, fix po review, re-test) dodają wpisy.

### `/kronikarz close` (Code Manager, przed merge)

Finalizuje kronikę: pisze Digest, tnie szum, dodaje sekcję "Manager close" z sign-off, aktualizuje `doc/backlog.md`, aktualizuje `doc/history/README.md` indeks, **commituje** kronikę. Manager merguje po user akcept.

Przed close warto pomyśleć głębiej (ultrathink) — sanity check kompletności i destylacja Digest wymagają osądu. Zwykły live-append pojedynczej decyzji go nie wymaga.

**Praca solo (bez Managera):** jeśli w projekcie nie ma roli Code Managera, agent wykonawczy uruchamia close sam po zakończeniu user QA — te same kroki.

---

## Tryb LIVE — flow

### Krok 1: Znajdź lub utwórz kronikę

```bash
git branch --show-current  # nazwa brancha
date +%Y-%m-%d             # dzisiejsza data
```

Plik: `doc/history/YYYY-MM-DD-<branch-slug>.md`

- Jeśli istnieje → otwórz do append/update
- Jeśli nie istnieje → stwórz ze szkieletem (poniżej)

### Krok 2: Zbierz minimalny kontekst

Piszesz z pozycji agenta, który wykonał pracę — decyzje masz w głowie, kodu nie musisz re-czytać, bo kronika go nie opisuje. Potrzebujesz tylko:

1. **`$BASE`** — branch integracyjny projektu (kroniki opisują deltę względem brancha, do którego praca zostanie zmergowana, a to NIE zawsze `main`). Ustal w kolejności: CLAUDE.md projektu (np. "PR base = develop") → gdy istnieje develop: `git merge-base HEAD develop` vs `main`, bierz bliższy → fallback: main/master.
2. **`git log $BASE..HEAD --oneline`** — kotwice SHA do wpisów decyzji.
3. **Poprzednie wpisy w `doc/history/`** — Digesty max 3 ostatnich (czy bieżący branch rozwiązuje coś otwartego).
4. **Plan implementacji** (`doc/plans/<branch>.md` lub `.claude/plans/<branch>.md`) — jeśli istnieje, do sekcji "Odchylenia od planu".

Jeśli odtwarzasz kronikę po fakcie (rzadkie — np. przejąłeś branch bez kroniki), `git log` daje szkielet: per commit zapytaj siebie „jaka decyzja za tym stała?", nie „co ten commit zmienia".

### Krok 3: Aktualizuj odpowiednie sekcje per fazę

Per faza pracy aktualizuj odpowiednie sekcje (append, nie nadpisuj):

| Faza | Co dopisujesz |
|---|---|
| Implementacja | Cel, Decyzje (w tym istotne nowe zależności: po co, czemu ta), Pułapki, Wiedza operacyjna |
| User QA | 🧪 Testy (wyniki, fix commits) + Dyspozycje usera (co user rozstrzygnął/odrzucił) |
| Code review (manager) | Code review findings + decyzje per-finding (FIX/BACKLOG/SKIP) |
| Re-test po fixach z review | 🧪 Testy (re-test results) |

**Wielorundowe QA/CR nad jednym problemem** (kilka podejść do tego samego buga) dokumentuj jako JEDEN blok "root cause + fix": objaw w 1 zdaniu, potwierdzona przyczyna, finalny fix, ewentualnie wyczerpane techniki jako known-gap.

### Krok 4: Stop

Tryb live **NIE commituje**, **NIE pushuje**, **NIE updateuje backlogu/indeksu**. Czeka aż Code Manager wywoła `/kronikarz close`.

---

## Tryb CLOSE — flow

### Krok 1: Sanity check kroniki live

Read `doc/history/YYYY-MM-DD-<branch>.md` — dwie bramki:

**Kompletność:** testy z wynikami, decyzje per-finding zalogowane, SKIP-y z pełnym templatem, brak TODO-ów. Jeśli niepełna → zaalarmuj usera, NIE finalizuj:

```
Kronika niegotowa do close. Brakuje:
- [ ] Sekcja "🧪 Testy" — Test 3 oznaczony "❌ Fail" bez fix commit
- [ ] Sekcja "Code review findings" pusta

Wróć do agenta wykonawczego z `/kronikarz live` żeby uzupełnił.
```

**Szum:** jeśli kronika zawiera treść odtwarzalną z repo (listy plików przepisane z diffa, sygnatury API, prozę „jak działa moduł") albo twierdzenia o stanie w czasie teraźniejszym — wytnij lub przeformułuj na decyzję przed finalizacją. Close jest ostatnią bramką jakości zapisu.

### Krok 2: Napisz Digest (na samej górze kroniki, pod metadanymi)

Digest to sekcja, którą przyszli czytelnicy (agenci i ludzie) czytają DOMYŚLNIE — resztę kroniki doczytują tylko, gdy Digest wskaże powód. Maksymalnie ~200 słów:

```markdown
## Digest

**Co:** <1-2 zdania — co branch zmienia z perspektywy użytkownika/systemu>
**Kluczowe decyzje:** <3-6 jednolinijkowych: "debounce 500ms zamiast immediate (race przy re-create)">
**Known gaps / SKIP:** <jednolinijkowo, lub "brak">
**Werdykt:** CR <APPROVE/...> · user QA <✅/⚠️> · <N> testów w 🧪
```

### Krok 3: Dodaj sekcję "Manager close"

```markdown
## Manager close

**Data finalizacji:** YYYY-MM-DD
**Code review werdykt:** APPROVE / NEEDS-FIX (link do raportu)
**User QA:** ✅ wszystkie scenariusze pass
**Manager sign-off:** OK do merge
**Merge SHA:** <wypełnione po merge>

### Notatki final review
[wzorce warte powielenia, co z findings świadomie odrzucono]
```

### Krok 4: Aktualizuj `doc/backlog.md`

1. Read aktualny `doc/backlog.md`
2. **Odkryte taski/tech debt** — dodaj wpisy z "Code review findings → BACKLOG": `- [ ] [TYPE] Krótki opis — [kronika](doc/history/YYYY-MM-DD-opis.md#code-review-findings)` (TYPE: `DEBT` / `TASK` / `BUG`)
3. **Ukończone taski** — oznacz `[x]` + data, przenieś do "Ukończone (ostatnie 10)", usuń najstarsze jeśli >10
4. **W trakcie** → przenieś do "W trakcie" z branch name jeśli kontynuacja

Jeśli `doc/backlog.md` nie istnieje — pomiń (nie twórz).

### Krok 5: Update `doc/history/README.md` indeks

Dodaj wiersz do tabeli:

```
| YYYY-MM-DD | [Tytuł](nazwa-pliku.md) | typ | `branch-name` |
```

**Wiersz indeksu = czysty wskaźnik: tytuł ≤ 15 słów, typ ≤ 3 tagi, ZAKAZ streszczenia w komórce.** Indeks jest jedynym artefaktem, który każdy przyszły agent skanuje w całości — każde zbędne zdanie w komórce mnoży się przez setki odczytów. Detale żyją w pliku kroniki (i jej Digeście), nie w indeksie.

- ✅ dobrze: `| 2026-07-15 | [Canvas box — statusy + persystencja (Slice 2)](2026-07-15-feat-canvas-box-slice-2.md) | feature | feat/canvas-box-s2 |`
- ❌ źle: wiersz zawierający listę zmian, "Dodatkowo:", opis decyzji albo cokolwiek ponad tytuł

### Krok 6: Commituj kronikę

1. `git add doc/history/ doc/backlog.md`
2. Commit message: `docs(kronika): close <branch-slug> — <krótki opis>`
3. **NIE pushuj automatycznie** — Manager pyta usera "merge?" → user "akcept" → Manager merguje (nie kronikarz).

---

## Szkielet kroniki — dobierz do typu pracy

**Rozmiar kroniki jest proporcjonalny do liczby decyzji, nie do liczby zmienionych plików.** Duży feature: typowo 800–2000 słów. Bugfix / mała poprawka: 150–500 słów. Sekcję bez treści pomiń bez śladu — pusta sekcja to też szum.

### Lean szkielet (bugfix, mała poprawka)

```markdown
# <Tytuł>

**Data startu:** YYYY-MM-DD · **Branch:** `nazwa` · **Typ:** bugfix · **Status:** 🚧 | ✅

## Digest
(wypełniany w close)

## Cel
1-2 zdania: objaw z perspektywy użytkownika.

## Root cause + fix
Przyczyna (potwierdzona, nie hipoteza) → co zmieniono i dlaczego tak. Commit SHA.

## 🧪 Testy
Test regresji: kroki + acceptance + wynik.

## Manager close
(w close)
```

### Pełny szkielet (feature, refaktor, faza)

```markdown
# <Tytuł zmiany>

**Data startu:** YYYY-MM-DD
**Branch:** `nazwa-brancha`
**Typ:** feature | refaktor | faza
**Status:** 🚧 W trakcie | ✅ Closed

## Digest

(wypełniany w close — patrz Tryb CLOSE Krok 2)

## Cel

1-3 zdania: po co ten branch istnieje — intencja i oczekiwany efekt, nie wyliczenie zmian.

## Decyzje

Serce kroniki. Wpis per decyzja, która ukształtowała rozwiązanie — architektoniczna, produktowa, dobór zależności, trade-off wydajności. Decyzja trudno odwracalna i zaskakująca bez kontekstu → dodatkowo ADR (kronika linkuje, nie duplikuje).

### Decyzja 1: <nazwa>
**Kontekst:** <co wymusiło decyzję — problem, constraint, wymaganie>
**Wybór:** <co wybrane>
**Alternatywy:** <co rozważone, dlaczego odrzucone>
**Konsekwencje:** <co to oznacza dla przyszłej pracy; wzorzec warty powielenia — zaznacz>
**Commit:** abc123

### Dyspozycja usera: <temat>
<gdy user rozstrzygnął coś w trakcie pracy lub na QA — co zdecydował, czego nie chciał i dlaczego; to sygnał intencji product ownera, którego nie ma nigdzie indziej>

## Known gaps / świadome pominięcia

- <czego nie zrobiono i dlaczego — żeby przyszły agent nie wziął luki za przeoczenie ani nie „naprawiał" celowego zachowania>
(pomiń jeśli brak)

## Pułapki odkryte po drodze

- <nieoczywiste zachowania narzędzi/API/środowiska, których ponowne odkrycie kosztowałoby przyszłego agenta godziny — np. "generator typów kłamie o nullability przy LEFT JOIN">
(pomiń jeśli brak)

## Wiedza operacyjna

- <tylko to, czego nie ma w repo: gdzie ustawić nowe env vars, ręczne kroki deployu, wymagana kolejność migracji>
(pomiń jeśli brak)

## 🧪 Testy

Marker `🧪` — search-friendly dla AI zbierających testy do regresji.

### Test 1: <krótka nazwa>

**Setup:** <konkretne kroki przygotowania>

**Kroki:**
1. <kliknij/wpisz/zrób X>
2. <obserwuj Y>

**Acceptance:** <co user powinien zobaczyć>

**Co sprawdza:** <1 zdanie po stronie funkcjonalnej>

**Wynik (user QA):** ✅ Pass / ⚠️ Partial / ❌ Fail

**Co nie poszło (jeśli fail):** <objaw + potwierdzony root cause — nie dziennik prób>
**Jak naprawiono:** commit abc123 — <krótki opis fix-a>
**Re-test:** ✅ Pass

### Test 2: ...

## Code review findings + decyzje per-finding

Raport: `doc/code-reviews/YYYY-MM-DD-<branch>.md`
Werdykt: APPROVE / REQUEST CHANGES / NEEDS REWORK · Findings: X critical / Y high / Z medium / W low

### [HIGH] 🔴 <symbol> — opis problemu

**Decyzja:** FIX / BACKLOG / SKIP
**Commit fix-a:** abc123 (jeśli FIX)
**Backlog entry:** [doc/backlog.md#NN] (jeśli BACKLOG)

### [LOW] 🟢 <symbol> — opis problemu (przykład SKIP)

**Decyzja:** SKIP
**Impact:** kosmetyka, edge case raz/tydzień
**Koszt fix-a:** 2h refactor 3 plików
**Rationale:** blokowałby release, niski user impact
**Re-evaluate gdy:** >5 user reports / kwartał

## Odchylenia od planu

Co poszło inaczej niż plan implementacji i DLACZEGO (nie listy plików — powody).
(pomiń jeśli zgodnie z planem lub brak planu)

## Status pozycji z poprzednich wpisów

Sprawdź **3 ostatnie wpisy** + otwarte problemy, o których wiesz z tej pracy (nie skanuj całej historii):
- ✅ Rozwiązane — co zrobiono
- 🔴 Pogorszone (eskalacja) — odnotuj
- 🟡 Nadal otwarte bez zmian
(pomiń sekcję jeśli nie dotyczy)

## Manager close

(wypełniana w trybie close)
```

**Sekcje, których celowo NIE ma** (odtwarzalne z repo — nie dodawaj ich z przyzwyczajenia): lista nowych/zmodyfikowanych plików (`git diff --name-status`), sygnatury API i interfejsy (kod jest prawdą; opis się zestarzeje), proza "jak działa architektura" (czytelnik przeczyta kod; decyzje architektoniczne żyją w Decyzjach), chronologia commitów (`git log`).

---

## Marker `🧪 Testy` — dlaczego

Search-friendly: AI zbierający kroniki pod kątem regresji może filtrować po markerze i znaleźć **tylko sekcje testów** bez czytania całych kronik. To buduje bibliotekę regresji nad czasem — pre-release QA może pull-ować z ostatnich kronik wszystkie testy + wyniki.

Żaden inny marker w kronice nie używa emoji, żeby uniknąć false-match.

Scenariusze testowe agent wykonawczy **zawsze wkleja też inline na czat** (user wykonuje od ręki) — kronika trzyma kopię jako historic record. To celowa redundancja: czat się rolluje, kronika zostaje.

---

## Convention linkowania (kronika ↔ inne dokumenty)

Linki w kronice używają **standard markdown** (relative paths) — działają w Obsidian, GitHub, VS Code:

- Format: `[label](relative/path/to/file.md#anchor)`
- Anchor: lowercase + dashes (GitHub auto-slug)

**Task IDs `T<slice>.<num>` jako lingua franca** — jeśli branch realizuje slice z `doc/plans/<slug>/backlog.md`, referuj konkretne taski w decyzjach i sekcji testów:

```markdown
### Decyzja 3: Debounce 500ms w watcher hook

**Kontekst:** T2.1 z [backlog.md](../plans/<slug>/backlog.md#t21) — race condition przy szybkim re-create
**Wybór:** debounce 500ms zamiast immediate fire
**Alternatywy:** debounce 100ms (za szybki, fires twice), debounce 1s (visible delay)
```

W `backlog.md` można wstecznie linkować z taska do decyzji w kronice (manager edytuje przy close).

Opcjonalnie, gdy fragment kodu jest niezrozumiały bez kontekstu decyzji, można zostawić w kodzie krótki marker `// kronika: <plik>#decyzja-N` — ale to wyjątek, nie rytuał; nie prowadź wykazu takich komentarzy w kronice.

---

## Zasady

- **Po polsku** (nazwy techniczne po angielsku)
- **Precyzyjnie** — commit SHA przy decyzjach i fixach; ścieżka pliku tylko, gdy jest częścią decyzji, nie inwentarzem
- **Czas przeszły, nie stan** — "wybraliśmy X, bo Y", nigdy "system robi X"
- **Decyzje, nie narracja** — z wielu rund zapisz wniosek, nie podróż
- **Bez cheerleadingu** — szczerze opisuj trade-offy, nie ukrywaj problemów
- **Nie kopiuj kodu ani diffa** — repo jest źródłem prawdy o kodzie
- **Sprawdź `git status`** — niezacommitowane zmiany mogą kryć decyzje, których jeszcze nie zapisałeś
- **W trybie live** — zostaw kronikę otwartą, nie commit'uj. W trybie close — finalizuj i commit'uj.

$ARGUMENTS
