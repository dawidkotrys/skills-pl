# 03. Konwencje — pliki persistent kontekstu

Metodologia opiera się na kilku kluczowych plikach na dysku. Ten dokument opisuje ich format, lokalizację i kiedy je tworzyć.

---

## CLAUDE.md — konwencje per repo

Plik w roocie (i opcjonalnie w podkatalogach) który Claude Code **automatycznie** wczytuje przy każdej sesji. Zawiera **konwencje specyficzne dla tego repo**:

- Stack + wersje
- Wzorce nazewnictwa, styl kodu, framework conventions
- Komendy (build, test, dev, lint)
- Środowisko (env vars, lokalne config)
- Quality bar / opinions per repo (np. "zawsze TypeScript strict", "PR base = develop")
- Workflow ze skilami (które skille typowo używać dla typowych sytuacji)

**To NIE jest miejsce na:**

- Domain glossary (to → `CONTEXT.md`)
- Architectural decisions (to → `doc/decisions/`)
- Backlog (to → `doc/backlog.md`)

### Hierarchia

Można mieć `CLAUDE.md` na różnych poziomach — każdy bardziej szczegółowy:

```
CLAUDE.md                    # global per repo
src/components/CLAUDE.md     # per katalog (np. design system)
src/api/CLAUDE.md            # per warstwa
```

Claude Code wczytuje wszystkie odpowiednie do bieżącej pracy. Per typ repo (web app, backend, library, mobile, knowledge base, strategy) — wzorce są w `repo-onboarding/patterns.md`.

---

## CONTEXT.md — domain glossary (zasada #17)

`CONTEXT.md` to **język domeny**, nie techniczny opis. Terminy biznesowe, ich znaczenia, aliasy do unikania, relacje. Czytany przez agenta na początku każdej sesji.

### Format

```md
# {Nazwa kontekstu}

{1-2 zdania: czym ten kontekst jest i dlaczego istnieje.}

## Język

**Order**:
Zwięzła definicja terminu — czym JEST, nie co ROBI.
_Unikaj_: Purchase, transaction

**Invoice**:
Żądanie płatności wysłane do klienta po dostawie.
_Unikaj_: Bill, payment request

**Customer**:
Osoba lub organizacja, która składa zamówienia.
_Unikaj_: Client, buyer, account

## Relacje

- **Order** generuje jeden lub więcej **Invoice**
- **Invoice** należy do dokładnie jednego **Customer**

## Przykładowy dialog

> **Dev:** „Kiedy **Customer** składa **Order** — czy tworzymy **Invoice** od razu?"
> **Domain expert:** „Nie, **Invoice** powstaje dopiero po potwierdzeniu **Fulfillmentu**."

## Zaflagowane niejasności

- „account" było używane zarówno w znaczeniu **Customer**, jak i **User** — rozstrzygnięte: to są oddzielne pojęcia.
```

### Zasady

- **Bądź zdecydowany.** Wybierz jedno słowo, resztę wymień jako aliasy do unikania.
- **Konflikty flaguj eksplicytnie** w sekcji „Zaflagowane niejasności" z rozstrzygnięciem.
- **Zwięźle.** Definicje max 1 zdanie. Czym coś **jest**, nie co **robi**.
- **Tylko terminy domenowe.** Pomijaj generic programming concepts (timeout, error, util).
- **5-10 terminów seed** na start — dodajesz w trakcie pracy gdy nowe pojawia się w rozmowie.
- **Pokazuj relacje** z kardynalnością tam gdzie oczywista.
- **Napisz przykładowy dialog** dev ↔ domain expert — testuje czy terminy współgrają.

### Repo z wieloma kontekstami (DDD bounded contexts)

Jeśli repo ma odrębne moduły domenowe (np. `ordering/`, `billing/`, `fulfillment/`) — utwórz `CONTEXT-MAP.md` w roocie i osobne `CONTEXT.md` per moduł:

```md
# Mapa kontekstów

## Konteksty
- [Ordering](./src/ordering/CONTEXT.md) — przyjmuje i śledzi zamówienia
- [Billing](./src/billing/CONTEXT.md) — generuje faktury i przetwarza płatności

## Relacje
- **Ordering → Fulfillment**: emituje eventy `OrderPlaced`
- **Ordering ↔ Billing**: współdzielone typy `CustomerId`, `Money`
```

---

## doc/decisions/ — Architecture Decision Records (zasada #18)

Numeracja sekwencyjna: `0001-slug.md`, `0002-slug.md`. Twórz katalog **leniwie** — gdy pojawia się pierwszy ADR.

### Format

```md
# {Krótki tytuł decyzji}

{1-3 zdania: jaki jest kontekst, co zdecydowaliśmy, dlaczego.}
```

To wszystko. ADR może być pojedynczym akapitem. Wartość polega na zapisaniu *że* decyzja zapadła i *dlaczego* — nie na wypełnianiu sekcji.

### Sekcje opcjonalne

Dodawaj tylko gdy realnie wnoszą wartość:

- **Status** (`proposed | accepted | deprecated | superseded by ADR-NNNN`) — gdy decyzje są rewidowane
- **Considered Options** — gdy odrzucone alternatywy warto zapamiętać
- **Consequences** — gdy są nieoczywiste skutki uboczne

### Kiedy pisać ADR

**Wszystkie trzy** warunki muszą być spełnione (zasada #18):

1. **Trudna do cofnięcia** — koszt zmiany w przyszłości jest znaczący
2. **Zaskakująca bez kontekstu** — przyszły czytelnik zapyta „dlaczego, na litość boską?"
3. **Wynik realnego trade-offu** — istniały realne alternatywy, wybraliście jedną z konkretnych powodów

### Co się kwalifikuje

- **Kształt architektoniczny** — „monorepo", „event-sourced write model"
- **Wzorce integracji między kontekstami** — „Ordering i Billing przez domain events, nie HTTP"
- **Wybory technologiczne z lock-inem** — DB, message bus, auth provider, deploy target. NIE każda biblioteka — tylko te, których wymiana zajmie kwartał
- **Decyzje o granicach i zakresie** — „Customer dane są właściwością kontekstu Customer; inni referują przez ID"
- **Świadome odstępstwa od oczywistej ścieżki** — „ręczny SQL zamiast ORM-a, bo X". Powstrzymuje następnego inżyniera przed „naprawianiem" zamierzonego stanu
- **Ograniczenia niewidoczne w kodzie** — „nie AWS przez compliance", „latency < 200ms przez kontrakt z partnerem"
- **Odrzucone alternatywy gdy odrzucenie jest nieoczywiste** — żeby za pół roku ktoś nie zaproponował znowu tego samego

### Co NIE jest ADR

- Decyzja oczywista (nie ma trade-offu)
- Decyzja łatwa do cofnięcia (po prostu cofniesz)
- Wybór konwencji nazewniczej (to → `CLAUDE.md`)
- Implementation detail (to → komentarz w kodzie albo nigdzie)

---

## doc/backlog.md — lokalny tracker

**Markdown-first.** Bez GitHub Issues / Linear / Jira — wszystko w jednym pliku w repo. Per zasada #11 (canon board) — to nie tylko TODO list, to graf z blocking relationships.

### Format

```md
# Backlog

## Priorytetowe
- [ ] [TASK] Opis — blokuje: TASK-3

## W trakcie
- [ ] [WIP] Opis — branch: `feature/xyz`

## Tech Debt
- [ ] [DEBT] Opis

## Pomysły
- [ ] [IDEA] Opis

## Ukończone (ostatnie 10)
- [x] [DONE] Opis — 2026-04-29
```

### Konwencje

- **Aktywne sekcje na górze** (Priorytetowe, W trakcie), **archiwum na dole** (Ukończone)
- **Daty zawsze absolutne** (`2026-04-29`), nigdy „w czwartek" — bo Memento
- **Zależności explicite** w opisie (`blokuje: X`, `wymaga: Y`)
- **Ukończone trzymaj 10 ostatnich** — starsze przerzucaj do CHANGELOG.md (jeśli istnieje) albo usuwaj
- **`code-manager` Tryb 3** czyta backlog i wybiera niezależne taski do parallel pickup

---

## doc/For humans/ — workflow guides

Dokumenty dla **ciebie**, nie dla AI. Notatki jak ty pracujesz w tym repo, jak zaczynać sesję, którego skilla użyć kiedy.

Typowo `workflow-guide.md` z sekcjami:

1. Jak zacząć sesję (który skill odpalić)
2. Jak pracować na co dzień
3. Skrót typowego flow
4. Gdzie leżą skille (pełne ścieżki)
5. Gdzie leżą CLAUDE.md (pełne ścieżki + zakres)
6. Co gdzie trafia (kto aktualizuje, co zawiera)

---

## _session-state.md — save game (zasada #19)

Tymczasowy plik (gitignored) tworzony **tylko** gdy multi-phase feature wymaga `/clear` w trakcie. Format:

```md
# Session state — {feature/initiative}

**Data:** {YYYY-MM-DD}
**Status:** {co zrobione, co w toku, co blokuje}

## Decyzje już podjęte
- ...

## Otwarte pytania
- ...

## Następne kroki
1. ...
2. ...

## Pliki kluczowe
- {path:line} — {co tam jest}
```

Po `/clear` → wczytujesz `_session-state.md` jako pierwszy plik. Po zakończeniu inicjatywy → usuwasz lub przerzucasz wartościowe ustalenia do `doc/decisions/`.

---

## Lista plików per repo (typowy zestaw)

```
{repo}/
├── CLAUDE.md                          # konwencje per repo
├── CONTEXT.md                         # domain glossary (lub CONTEXT-MAP.md)
├── doc/
│   ├── decisions/
│   │   ├── 0001-meta.md
│   │   ├── 0002-...md
│   │   └── ...
│   ├── backlog.md
│   └── For humans/
│       └── workflow-guide.md
└── src/
    └── ...
```

Onboarding nowego repo: odpal `/repo-onboarding`. Jeśli któreś pliki istnieją ale w innym formacie — skill robi audit i sugeruje migrację.
