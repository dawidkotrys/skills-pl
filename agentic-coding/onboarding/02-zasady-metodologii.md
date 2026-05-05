# 02. 10 fundamentalnych zasad agentic coding

Krótka lista zasad metodologii pracy z LLM-ami w kodzie. **10 punktów** — wszystko czego potrzebujesz na start. Nie musisz pamiętać ich wszystkich — wystarczy wiedzieć **że istnieją** i o czym są, żeby wracać tu po szczegóły kiedy trzeba.

Zasady są inspirowane materiałami [Matt Pocock](https://www.mattpocock.com/) o agentic coding + autorska adaptacja autora. Większość ma korzenie w klasykach software design (Ousterhout *Philosophy of Software Design*, Fowler *Refactoring*, Hunt/Thomas *Pragmatic Programmer*) — LLM-y są nowe, problemy są stare.

---

## 1. Smart zone vs dumb zone

Każdy LLM ma kontekstową krzywą inteligencji. Próg ~100k tokenów (niezależnie od deklarowanego context window — Claude może mieć "1M context", ale od ~100k zaczyna głupieć). **Przed tym progiem** model jest precyzyjny, dotyka detalu. **Po progie** halucynuje, gubi nuanse, miesza fakty.

**Konsekwencja:** trzymaj sesje krótkie. Czyść kontekst zanim wpadniesz w dumb zone. Persistent kontekst trzymaj na dysku, nie w sesji.

---

## 2. Memento problem

LLM nie pamięta nic między sesjami. Każda nowa rozmowa to "pacjent z amnezją" który czyta kartę z dnia poprzedniego. Sesja jest **ulotna**, dysk jest **trwały**.

**Konsekwencja:** wszystko co ważne (decyzje, ustalenia, terminy) musi trafić do plików (`CONTEXT.md`, `doc/decisions/`, `doc/plans/<slug>/`). Nigdy nie polegaj na "AI pamięta z poprzedniej sesji".

---

## 3. Clear > Compact

Compact tworzy **sediment** — destylat poprzedniej destylacji. Z każdą iteracją tracisz precyzję, dodajesz halucynacje. To jak xerokopia xerokopii — każda kolejna gorsza.

`/clear` jest reset. Startujesz świeży kontekst, zaczytujesz pliki z dysku które wiesz że są prawdą.

**Konsekwencja:** gdy kontekst się zaśmieca / AI zaczyna halucynować — `/clear`, nie `/compact`.

---

## 4. Grilling > eager planning

Cel pracy z modelem to **shared design concept** (oboje rozumiecie tak samo), nie **plan** (lista TODO).

Eager planning bez grillingu daje plany które wyglądają OK ale nie wytrzymują kontaktu z rzeczywistością — bo żaden constraint nie został przetestowany.

**Konsekwencja:** zawsze grill (`/grill`) przed planem. Grilling = test hipotez, plan = wynik testów.

---

## 5. Vertical slices, NIE horizontal

**Vertical slice** = przekrój przez wszystkie warstwy (UI → API → DB → tests) dla jednej małej funkcjonalności end-to-end.

**Horizontal slice** = robimy "wszystkie modele", potem "wszystkie API", potem "wszystkie UI". Anti-pattern — każdy slice jest niemożliwy do zweryfikowania dopóki nie zrobi się wszystkich. Brak feedback loop.

**Konsekwencja:** każdy issue/feature to vertical slice. Po slice user widzi działającą wartość. Bias ku **cienkim** slicesom — jeśli wahasz się czy podzielić jeszcze raz, dziel.

---

## 6. Bad codebase = bad agent output

Jakość outputu AI jest ograniczona jakością **feedback loops**. Slow tests, flaky tests, brak typów, brak structure — agent nie ma szans.

**Konsekwencja:** inwestuj w testowość, type safety, fast feedback. To bezpośrednio podnosi sufit jakości tego co AI Ci dostarczy.

---

## 7. TDD red-green vertical, NIE horizontal

Write 1 test. Watch it fail. Write minimal impl. Watch it pass. Refactor. Next test.

**Anti-pattern:** "napisz wszystkie testy, potem zaimplementuj". To pozwala AI na **cheating** — model patrzy na wszystkie testy i pisze impl który "magicznie" wszystkie satysfakcjonuje, często z hard-coded values.

Vertical TDD wymusza pojedyncze decyzje implementacyjne.

---

## 8. Build feedback loop FIRST

Phase 1 of `/diagnose`: zanim zaczniesz **fixować**, zbuduj **fast, deterministic feedback loop**. Reprodukuj buga w teście / scenariuszu który leci za 1s nie 60s.

90% buga jest fixed gdy masz solidny feedback loop. Wtedy hipotezy weryfikujesz w sekundach, nie minutach. Inwestycja w feedback loop zwraca się 10x.

---

## 9. QA = imposing taste

QA to nie "sprawdzanie czy działa". QA to **narzucanie smaku** — Ty decydujesz czy to wygląda dobrze, czy UX jest przyjemny, czy kopiowanie brzmi naturalnie.

Bez human touch wszystko wygląda jak slop. AI generuje "OK", człowiek narzuca "good".

QA nie jest linią finishową — jest **pętlą**. Znajdujesz problemy, dorzucasz issues, agent fixuje, wracasz do QA. *Anti-pattern:* "merge bo QA przeszło".

**Konsekwencja:** zawsze manualny QA pass. Klikaj przez aplikację. Czytaj copy. Dotknij rzeczywistego obiektu.

---

## 10. Crucial decisions wymagają wielu ludzi

Domain expert + product owner + dev + AI w jednym pokoju. AI nie zastąpi domain expertyzy. Domain expert nie zastąpi production reality. Product owner nie zastąpi technical constraints.

**Konsekwencja:** dla decyzji architektonicznych / produktowych — nie próbuj decydować sam z AI. Włącz domain experta. AI jest amplifikatorem, nie zamiennikiem.

---

## Jak używać tej listy

**Pierwszy raz** — przeczytaj sekwencyjnie 1-10.

**Na co dzień** — wracaj tu kiedy potrzebujesz przypomnienia konkretnej zasady (np. "co Pocock mówił o vertical slicing" → zasada #5).

**Reguła:** zasady mają wartość tylko gdy są stosowane w realnej pracy. Same z siebie są tylko listą bullet pointów.
