# 01. Fundamenty — jak działa LLM w pracy z kodem

Ten dokument opisuje **fundamentalne ograniczenia** LLM-ów które kształtują całą metodologię agentic coding. Zrozumienie ich pozwala pracować z modelem efektywnie zamiast walczyć z naturą narzędzia.

---

## Smart zone vs dumb zone

Każdy LLM ma **kontekstową krzywą inteligencji**. Niezależnie od deklarowanego context window (Claude może mieć "1M tokens", GPT-4 też ma duże okno) — **od ~100k tokenów model zaczyna głupieć**:

- **Smart zone** (~0-100k tokenów): model jest precyzyjny, łapie nuanse, łączy fakty, dotyka detalu
- **Dumb zone** (~100k+ tokenów): halucynacje, gubienie kontekstu, mieszanie faktów, "OK-ish" odpowiedzi zamiast precyzyjnych

**Konsekwencja:** trzymaj sesje **krótkie**. Czyść kontekst zanim wpadniesz w dumb zone. Nie traktuj 1M kontekstu jako przestrzeni do wypełnienia — traktuj go jako **margines bezpieczeństwa**.

Praktycznie:

- Jeśli sesja dotyczy 5+ niezwiązanych tematów — przerwij, `/clear`, kontynuuj z świeżym kontekstem
- Jeśli zauważasz że model **zaczyna powtarzać się**, **gubić wcześniejsze ustalenia**, **halucynować nazwy plików** — to sygnał dumb zone
- Persistent kontekst (CONTEXT.md, ADR-y, backlog) trzymaj **na dysku**, nie w sesji

---

## Memento problem

Tytuł od filmu Christophera Nolana — bohater nie ma pamięci krótkotrwałej, codziennie czyta swoje notatki żeby zrozumieć kim jest. **LLM ma dokładnie ten problem** między sesjami.

- Sesja jest **ulotna** — co napiszesz w jednej rozmowie, znika z modelu po jej zakończeniu
- Dysk jest **trwały** — pliki w repo, CLAUDE.md, CONTEXT.md, ADR-y są dostępne każdej sesji

**Konsekwencja:** wszystko **co ważne** musi trafić do plików. Decyzje, ustalenia, terminy, edge case'y które omówiliście — jeśli nie są w pliku, nie istnieją z perspektywy następnej sesji.

Co zapisywać:

- **Domain glossary** → `CONTEXT.md`
- **Architectural decisions** → `doc/decisions/0001-*.md`
- **Backlog** → `doc/backlog.md`
- **Konwencje per repo** → `CLAUDE.md`
- **Workflow guide** dla człowieka → `doc/For humans/workflow-guide.md`
- **Multi-phase feature mid-flight** → `_session-state.md` (gitignored — tymczasowe save game przed `/clear`)

Anty-wzorzec: *„Pamiętasz co wczoraj ustaliliśmy?"* — nie, nie pamięta. Wczytaj z dysku.

---

## Clear > Compact

Claude Code (i podobne narzędzia) oferują dwie operacje czyszczenia kontekstu:

- **`/compact`** — destyluje obecną sesję do skrótu, zostawia skrót w kontekście, kontynuuje
- **`/clear`** — usuwa cały kontekst, startujesz świeżą sesję

`/compact` wydaje się atrakcyjne ("zachowuje co ważne"), ale wprowadza **sediment**:

> Compact = destylat poprzedniej destylacji. Z każdą iteracją tracisz precyzję, dodajesz halucynacje. To jak xerokopia xerokopii — każda kolejna gorsza.

`/clear` jest **resetem**. Tracisz wszystko, ale to "wszystko" w 80% było szumem (twoje próby, ślepe uliczki, intermediate stany). To **co ważne** jest na dysku — zaczytasz z plików.

**Konsekwencja:** gdy kontekst się zaśmieca / AI zaczyna halucynować — `/clear`, **nie** `/compact`. Po cleare:

1. Czytasz `CONTEXT.md` (domain glossary)
2. Czytasz `doc/decisions/` (jakie decyzje już są)
3. Czytasz `doc/backlog.md` (co w toku)
4. Kontynuujesz świadomy

Praktyczna heurystyka: jeśli rozważasz `/compact`, zadaj sobie pytanie — *czy to co ważne z tej sesji jest już w pliku?* Jeśli nie — zapisz najpierw (np. session-state.md), potem `/clear`.

---

## Co z tego wynika dla metodologii

Te trzy ograniczenia kształtują wszystko co dalej:

1. **Persistent kontekst na dysku** (zasada #17, #18, #19) — bo Memento
2. **Vertical slicing + thin slices** (zasada #8, #9, #10) — bo każdy slice = kompletny session w smart zone
3. **Grilling > eager planning** (zasada #5) — bo plan napisany w smart zone jest precyzyjny; plan napisany w dumb zone jest sloppy
4. **Day shift vs night shift** (zasada #6) — human dostarcza taste i decisions w smart zone; AI implementuje w dobrze zdefiniowanej, wąskiej domenie
5. **Bad codebase = bad agent output** (zasada #16) — fast feedback loops i czysta struktura **przedłużają smart zone** poprzez redukcję noise w kontekście

Wszystkie 28 zasad metodologii: [02-zasady-metodologii.md](./02-zasady-metodologii.md).

---

## Praktyczna lista kontrolna

Zanim zaczniesz pracę z Claude Code w danym repo:

- [ ] Czy istnieje `CLAUDE.md` w roocie z konwencjami projektu?
- [ ] Czy istnieje `CONTEXT.md` z domain glossary?
- [ ] Czy istnieje `doc/decisions/` (lub równoważnik) z ADR-ami?
- [ ] Czy istnieje `doc/backlog.md`?
- [ ] Czy testy biegną szybko i deterministycznie? (jeśli nie — to pierwszy task)

Jeśli **brakuje** czegoś z powyższych — odpal `/repo-onboarding` zanim zaczniesz feature work.
