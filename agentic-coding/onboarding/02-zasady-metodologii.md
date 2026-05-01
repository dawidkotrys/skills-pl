# 02. 28 zasad metodologii agentic coding

Pełna lista zasad metodologii Matt Pocock + autorska adaptacja. Pełnotekstowa wersja do czytania i nauki. Nie musisz pamiętać ich wszystkich — wystarczy wiedzieć **że istnieją** i o czym są, żeby wracać tu po szczegóły kiedy trzeba.

---

## Spis treści

- [A. Constraints LLM](#a-constraints-llm) — zasady **1-3** (smart zone, Memento, Clear>Compact)
- [B. Filozofia pracy](#b-filozofia-pracy) — zasady **4-7** (kod-pole-bitwy, grilling, day/night shift, old-school books)
- [C. Slicing](#c-slicing) — zasady **8-11** (vertical, tracer bullets, thin-over-thick, canon board)
- [D. Architektura](#d-architektura) — zasady **12-16** (deep modules, deletion test, seamy, interfaces, bad-codebase-bad-output)
- [E. Persistent kontekst](#e-persistent-kontekst) — zasady **17-19** (CONTEXT.md, ADR sparingly, session-state)
- [F. Testing](#f-testing) — zasady **20-23** (TDD vertical, behavior, feedback loop FIRST, iterate na loopie)
- [G. Standards enforcement](#g-standards-enforcement) — zasady **24-25** (implementer pulls/reviewer pushes, Sonnet/Opus split)
- [H. Human role](#h-human-role) — zasady **26-28** (QA=taste, QA jako pętla, crucial decisions=ludzie)

---

## A. Constraints LLM

### 1. Smart zone vs dumb zone

Każdy LLM ma kontekstową krzywą inteligencji. Próg ~100k tokenów (niezależnie od deklarowanego context window — Claude może mieć "1M context", ale od ~100k zaczyna głupieć). **Przed tym progiem** model jest precyzyjny, dotyka detalu. **Po progiem** halucynuje, gubi nuanse, miesza fakty.

**Konsekwencja:** trzymaj sesje krótkie. Czyść kontekst zanim wpadniesz w dumb zone. Persistent kontekst trzymaj na dysku, nie w sesji.

### 2. Memento problem

LLM nie pamięta nic między sesjami. Każda nowa rozmowa to "pacjent z amnezją" który czyta kartę z dnia poprzedniego. Sesja jest **ulotna**, dysk jest **trwały**.

**Konsekwencja:** wszystko co ważne (decyzje, ustalenia, terminy) musi trafić do plików (`CONTEXT.md`, `doc/decisions/`, `doc/backlog.md`). Nigdy nie polegaj na "AI pamięta z poprzedniej sesji".

### 3. Clear > Compact

Compact tworzy **sediment** — destylat poprzedniej destylacji. Z każdą iteracją tracisz precyzję, dodajesz halucynacje. To jak xerokopia xerokopii — każda kolejna gorsza.

`/clear` jest reset. Startujesz świeży kontekst, zaczytujesz pliki z dysku które wiesz że są prawdą.

**Konsekwencja:** gdy kontekst się zaśmieca / AI zaczyna halucynować — `/clear`, nie `/compact`.

---

## B. Filozofia pracy

### 4. Kod jest polem bitwy, NIE specs

Anti-pattern: *"oto pełen spec, zaimplementuj go"*. Spec jest **destination**, kierunek. Kod jest **polem bitwy** — tu konfrontują się hipotezy projektowe z rzeczywistością.

Specy są niedoskonałe. Kod ujawnia braki specu. Implementacja zmusza decyzje.

**Konsekwencja:** PRD to kierunek, nie kontrakt. Bądź gotów zaktualizować PRD gdy implementacja ujawni assumption violation.

### 5. Grilling > eager planning

Cel pracy z modelem to **shared design concept** (oboje rozumiecie tak samo), nie **plan** (lista TODO).

Eager planning bez grillingu daje plany które wyglądają OK ale nie wytrzymują kontaktu z rzeczywistością — bo żaden constraint nie został przetestowany.

**Konsekwencja:** zawsze grill (`/grill-with-docs`) przed planem. Grilling = test hipotez, plan = wynik testów.

### 6. Day shift vs night shift

**Day shift** (human-in-the-loop) — planning, alignment, QA, decyzje strategiczne. Tu jesteś niezbędny.

**Night shift** (AFK / autonomous) — implementation, refactoring, bug fixing po reprodukcji. Tu agent może lecieć sam (z dobrym feedback loopem).

**Konsekwencja:** rezerwuj swoje uwagę dla day shift (grilling, design decisions, QA). Implementację puszczaj agentowi.

### 7. Old-school books są golden

Najlepsze książki o software design **wcale nie są o AI**:

- *The Pragmatic Programmer* (Hunt, Thomas)
- *Refactoring* (Fowler)
- *A Philosophy of Software Design* (Ousterhout) — deep modules, deletion test
- *The Design of Design* (Brooks)

LLM-y są nowe, problemy są stare. Złe abstrakcje, ciasne sprzężenia, premature optimization — to wszystko zna się od dekad. AI tylko amplifikuje skutki.

---

## C. Slicing

### 8. Vertical slices, NIE horizontal

**Vertical slice** = przekrój przez wszystkie warstwy (UI → API → DB → tests) dla jednej małej funkcjonalności end-to-end.

**Horizontal slice** = robimy "wszystkie modele", potem "wszystkie API", potem "wszystkie UI". Anti-pattern.

**Konsekwencja:** każdy issue/feature to vertical slice. Po slice user widzi działającą wartość.

### 9. Tracer bullets

Cienki, działający slice end-to-end **wcześniej niż** kompletny moduł. Cel: feedback **prawie natychmiast** — czy idziemy w dobrym kierunku?

Tracer bullet ≠ prototyp do wyrzucenia. To prawdziwy kod, tylko wąski.

### 10. Prefer many thin slices over few thick

Bias ku **cienkim**. Jeśli wahasz się czy slice "podzielić jeszcze raz" — dziel.

Cienkie slicesy mają mniejsze ryzyko, szybszy feedback, łatwiejszy collision-detection przy parallel work.

### 11. Canon board > sequential plan

**Canon board** = DAG (graf zależności) issues z blocking relationships. Subagenty pickup-ują niezależne issues równolegle.

**Sequential plan** (linia) — antywzorzec. Wymusza sekwencyjność tam gdzie nie ma faktycznych zależności.

**Konsekwencja:** plan to canon board (DAG), nie linia. `/code-manager` Tryb 3 robi collision detection żeby pickup był bezpieczny.

---

## D. Architektura

### 12. Deep modules > shallow modules (Ousterhout)

**Deep module** = mała interface, dużo logiki w środku. High leverage. Caller pisze 1 linijkę, dostaje 100 linii functionality.

**Shallow module** = interface prawie tak skomplikowany jak implementacja. Pass-through. Brak leverage.

**Konsekwencja:** preferuj `db.saveOrder(order)` nad `db.beginTx() → db.insert(...) → db.commit()`. Pierwsze ukrywa złożoność, drugie ją eksponuje.

### 13. Deletion test

Wyobraź sobie że usuwasz moduł. Pytanie: czy złożoność **znika** (moduł był pass-through, shallow) czy **pojawia się ponownie u N callerów** (moduł zarabiał na siebie, deep)?

**"Znika"** = moduł był shallow, był nadmiarowy. Wyciągnięcie nie miało sensu.
**"Pojawia się u N callerów"** = moduł był deep, koncentrował logikę. Trzymaj.

### 14. Jeden adapter = hipotetyczny seam. Dwa adaptery = prawdziwy seam.

**Anti-pattern speculative flexibility:** wprowadzanie abstrakcji "na zapas", bo *może w przyszłości* będzie drugi adapter.

Jeden adapter = abstrakcja jest hipotetyczna. Nie wiesz jakie potrzeby będą mieć inne adaptery, więc abstrakcja będzie **zawsze źle dopasowana** gdy drugi przyjdzie.

**Konsekwencja:** zostaw concrete dependency. Wprowadź abstrakcję dopiero gdy realna potrzeba (drugi adapter) pojawi się.

### 15. Designuj interfejsy, deleguj implementacje

Twoja uwaga jest najlepiej spożytkowana na projektowaniu **interfejsów** (typy, error modes, ordering, inwarianty). Implementacje deleguj agentowi.

Interfejsy wymagają taste i context. Implementacje wymagają precyzji i wytrwałości — agent jest w tym dobry.

### 16. Bad codebase = bad agent output

Jakość outputu AI jest ograniczona jakością **feedback loops**. Slow tests, flaky tests, brak typów, brak structure — agent nie ma szans.

**Konsekwencja:** inwestuj w testowość, type safety, fast feedback. To bezpośrednio podnosi sufit jakości tego co AI Ci dostarczy.

---

## E. Persistent kontekst

### 17. CONTEXT.md = domain glossary

`CONTEXT.md` to **język domeny**, nie technical documentation. Terminy biznesowe, ich znaczenia, aliasy do unikania, relacje.

NIE jest to "co projekt robi". Jest to "jak nazywamy rzeczy w tym projekcie".

**Konsekwencja:** każde repo ma `CONTEXT.md` w roocie. Czytany przez agenta na początku każdej sesji.

### 18. ADR-y sparingly

Architecture Decision Record tylko gdy decyzja jest:

- **Hard-to-reverse** (drogo by było cofnąć)
- **Surprising bez kontekstu** (przyszły reader pomyśli "WTF?" bez wyjaśnienia)
- **Real trade-off** (wybór wymagał odrzucenia innej opcji o realnej wartości)

Jeśli decyzja jest oczywista lub łatwa do cofnięcia — **NIE pisz ADR**. Spamming ADR-ami zaśmieca repo.

### 19. _session-state.md przy multi-phase features

Gdy feature jest tak duży że potrzebujesz `/clear` w trakcie — przed clear zapisz **session state** do pliku tymczasowego (`_session-state.md` w gitignore). Po cleare wczytujesz go i odzyskujesz kontekst.

To "save game" przed bossem.

---

## F. Testing

### 20. TDD red-green vertical, NIE horizontal

Write 1 test. Watch it fail. Write minimal impl. Watch it pass. Refactor. Next test.

**Anti-pattern:** "napisz wszystkie testy, potem zaimplementuj". To pozwala AI na **cheating** — model patrzy na wszystkie testy i pisze impl który "magicznie" wszystkie satysfakcjonuje, często z hard-coded values.

Vertical TDD wymusza pojedyncze decyzje implementacyjne.

### 21. Test behavior, NIE implementation

Test który zna szczegóły implementacji (nazwy private methods, internal state) **nie przeżyje refactoru**. Test który testuje behavior (input → output, side effects observable) — przeżyje.

**Konsekwencja:** testy są **zewnętrzną perspektywą** — testują interfejs, nie wnętrze.

### 22. Build feedback loop FIRST (diagnose Phase 1)

Phase 1 of `/diagnose`: zanim zaczniesz **fixować**, zbuduj **fast, deterministic feedback loop**. Reprodukuj buga w teście / scenariuszu który leci za 1s nie 60s.

90% buga jest fixed gdy masz solidny feedback loop. Wtedy hipotezy weryfikujesz w sekundach, nie minutach.

### 23. Iterate na samym feedback loop

Czasem największy zysk to **uczynienie feedback loop szybszym** zamiast atakowania problemu. Przykład: test biegnie 30s? Najpierw zrób żeby leciał 1s, potem szukaj buga.

Inwestycja w feedback loop zwraca się 10x.

---

## G. Standards enforcement

### 24. Implementer pulls, reviewer pushes

**Coding standards** (jak pisać kod) — implementer **pull**uje z dokumentu (skill, CLAUDE.md, conventions doc). Standardy są dostępne, implementer korzysta z nich gdy potrzebuje.

**Reviewer push** uje (egzekwuje, blokuje merge). Reviewer **musi** sprawdzić zgodność, bo to jego ostatnia bramka.

**Konsekwencja:** nie wsadzaj 50 standardów do system promptu agenta-implementera. Wsadź je do skilla / docs które agent może czytać. Reviewer (Opus) je egzekwuje.

### 25. Sonnet implements, Opus reviews

Reviewing wymaga **więcej smarts** niż implementacja. Implementer wykonuje konkretny task; reviewer musi wykryć subtelne bugi, security gaps, anti-patterny.

**Konsekwencja:** używaj Sonneta do implementacji (taniej, szybciej), Opusa do `/critical-code-review`.

---

## H. Human role

### 26. QA = imposing taste

QA to nie "sprawdzanie czy działa". QA to **narzucanie smaku** — Ty decydujesz czy to wygląda dobrze, czy UX jest przyjemny, czy kopiowanie brzmi naturalnie.

Bez human touch wszystko wygląda jak slop. AI generuje "OK", człowiek narzuca "good".

**Konsekwencja:** zawsze manualny QA pass. Klikaj przez aplikację. Czytaj copy. Dotknij rzeczywistego obiektu.

### 27. QA tworzy nowe issues

QA nie jest linią finishową. QA jest **pętlą** — znajdujesz problemy, dorzucasz issues, agent fixuje, wracasz do QA.

**Anti-pattern:** "merge bo QA przeszło". QA nie ma "przejść". QA ma "wygenerować feedback loop dla kolejnej iteracji".

### 28. Crucial decisions wymagają wielu ludzi

Domain expert + product owner + dev + AI w jednym pokoju. AI nie zastąpi domain expertyzy. Domain expert nie zastąpi production reality. Product owner nie zastąpi technical constraints.

**Konsekwencja:** dla decyzji architektonicznych / produktowych — nie próbuj decydować sam z AI. Włącz domain experta. AI jest amplifikatorem, nie zamiennikiem.

---

## Jak używać tej listy

**Pierwszy raz** — przeczytaj sekwencyjnie od A do H, pomija się tylko jeśli już temat znasz.

**Na co dzień** — wracasz tu kiedy potrzebujesz przypomnienia konkretnej zasady (np. "co Ousterhout mówił o deletion test" → sekcja D).

**Reguła:** zasady mają wartość tylko gdy są stosowane w realnej pracy. Same z siebie są tylko listą bullet pointów.

---

## Atrybucja

Zasady inspirowane materiałami [Matt Pocock](https://www.mattpocock.com/) o agentic coding (publiczne wystąpienia, podcasty). Tłumaczenie i adaptacja na polski. Większość zasad ma korzenie w klasykach software design (Ousterhout *Philosophy of Software Design*, Fowler *Refactoring*, Hunt/Thomas *Pragmatic Programmer*, Brooks *Design of Design*) — Matt zsyntetyzował je i nadał im nowy kontekst pracy z LLM-ami.
