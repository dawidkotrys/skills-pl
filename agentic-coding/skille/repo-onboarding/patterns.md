# Wzorce CLAUDE.md per typ repozytorium

Dokument referencyjny dla skilla `/repo-onboarding`. Zawiera wzorce hierarchii CLAUDE.md, typowe skille i struktury dokumentacji dla różnych typów repozytoriów.

---

## Code: Web App (React/Next.js/Vue/Angular/Svelte)

### Hierarchia CLAUDE.md

```
CLAUDE.md                    # Stack, routing, state management, styling, deployment
src/components/CLAUDE.md     # Design system, tokeny, accessibility, animacje
src/data/CLAUDE.md           # API patterns, data fetching, mutations
src/hooks/CLAUDE.md          # Custom hooks conventions
src/store/CLAUDE.md          # State management patterns
src/lib/CLAUDE.md            # Typy, utils, stałe
src/app/CLAUDE.md            # Routing, layouts, middleware
```

### Kluczowe sekcje root CLAUDE.md
- Framework + wersja, bundler, package manager
- Routing pattern (file-based, config-based)
- State management (co gdzie: server state vs client state)
- Styling approach (CSS modules, Tailwind, styled-components, CSS vars)
- Data fetching pattern (SWR, TanStack Query, server components)
- Konwencje nazewnictwa plików i komponentów
- Znane pułapki (hydration, SSR gotchas, env vars)
- Build/dev/test komendy

### Typowe skille
- `/quality-guard` — quick check jakości kodu
- `/design-checker` — weryfikacja design systemu (jeśli custom design tokens)
- `/kronikarz` — dokumentacja zmian przed push

---

## Code: Backend / API (Node, Python, Go, Rust, Java)

### Hierarchia CLAUDE.md

```
CLAUDE.md                    # Stack, architektura, deployment, env vars
src/routes/CLAUDE.md         # API conventions, auth, validation
src/services/CLAUDE.md       # Business logic patterns
src/models/CLAUDE.md         # ORM/DB patterns, migrations
src/middleware/CLAUDE.md      # Middleware chain, error handling
```

### Kluczowe sekcje root CLAUDE.md
- Framework + wersja, runtime
- Architektura (monolith, microservices, serverless)
- Database (ORM, migration tool, naming conventions)
- Auth pattern (JWT, session, OAuth)
- API conventions (REST/GraphQL, versioning, error format)
- Environment variables (wymagane, opcjonalne)
- Deployment (Docker, cloud provider, CI/CD)
- Test runner + jak uruchomić testy

### Typowe skille
- `/quality-guard` — jakość kodu, security checks
- `/api-docs` — generowanie/aktualizacja dokumentacji API
- `/migration-check` — weryfikacja migracji DB

---

## Code: Library / Package

### Hierarchia CLAUDE.md

```
CLAUDE.md                    # API surface, versioning, publishing
src/CLAUDE.md                # Internal patterns, exports
```

### Kluczowe sekcje root CLAUDE.md
- Public API (eksportowane funkcje/klasy)
- Versioning strategy (semver rules)
- Publishing workflow
- Backward compatibility rules
- Test strategy (unit, integration, e2e)
- Bundle size concerns
- Supported platforms/environments

### Typowe skille
- `/release` — przygotowanie nowej wersji
- `/breaking-change-check` — weryfikacja backward compatibility

---

## Code: Mobile (Flutter, React Native)

### Hierarchia CLAUDE.md

```
CLAUDE.md                    # Stack, platforms, state, navigation
lib/features/CLAUDE.md       # Feature-based architecture
lib/core/CLAUDE.md           # Shared utils, theme, DI
```

### Kluczowe sekcje root CLAUDE.md
- Framework + target platforms
- State management (BLoC, Riverpod, Redux)
- Navigation pattern
- Theme/styling system
- Platform-specific code conventions
- Build flavors / environments
- CI/CD + code signing

---

## Knowledge Base

Repozytorium z bazą wiedzy — notatki, konteksty, informacje referencyjne.

### Hierarchia CLAUDE.md

```
CLAUDE.md                    # Cel bazy, struktura, konwencje, indeksy
<kategoria>/CLAUDE.md        # Specyfika danej kategorii (opcjonalnie)
```

### Kluczowe sekcje root CLAUDE.md
- Cel i zakres bazy wiedzy (co tu jest, a czego nie)
- Struktura katalogów z opisami kategorii
- Format plików (konwencje nagłówków, tagów, metadanych)
- Relacje między dokumentami (jak linkować, cross-referencing)
- Jak dodawać nowe wpisy (naming, lokalizacja)
- Jak aktualizować istniejące (wersjonowanie, daty)
- Indeksy i spisy treści (gdzie są, jak aktualizować)

### Typowe skille
- `/summarize` — podsumowanie sekcji lub dokumentu
- `/consistency-check` — weryfikacja spójności dat, nazw, informacji
- `/update-index` — aktualizacja spisów treści i indeksów
- `/find-gaps` — identyfikacja brakujących informacji

### Struktura doc/
```
doc/
├── backlog.md              # Brakujące informacje, do uzupełnienia
└── For humans/
    └── workflow-guide.md
```

---

## Strategy / Business

Repozytorium ze strategią, planami, OKR, roadmapami.

### Hierarchia CLAUDE.md

```
CLAUDE.md                    # Kontekst firmy/projektu, struktura, konwencje
```

### Kluczowe sekcje root CLAUDE.md
- Kontekst organizacji (branża, rozmiar, etap)
- Struktura dokumentacji (co gdzie)
- Konwencje formatowania (jak pisać OKR, jak formatować roadmapy)
- Terminy i kadencje (Q1/Q2 daty, cykle planowania)
- Kluczowe metryki i KPI (nazwy, definicje)
- Relacje między dokumentami strategicznymi

### Typowe skille
- `/quarterly-review` — podsumowanie postępów OKR
- `/consistency-check` — spójność celów i metryk
- `/decision-log` — dokumentowanie decyzji

---

## Mixed / Multi-purpose

Repozytorium łączące kod z dokumentacją, bazą wiedzy, strategią.

### Podejście
1. Root CLAUDE.md z mapą całego repo
2. Nested CLAUDE.md per sekcja — dopasowane do typu tej sekcji
3. Jasne granice: "ta część to kod, ta to dokumentacja"

---

## Uniwersalne wzorce

### CONTEXT.md — domain glossary (zawsze w roocie)

`CONTEXT.md` to persistent kontekst językowy projektu — słownik terminów domenowych, ich znaczeń, aliasów do unikania i relacji. Czytany przez agenta na początku każdej sesji. **Pełny format** w `~/.claude/skills/grill-with-docs/CONTEXT-FORMAT.md`.

**Szkielet (skrócony):**

```markdown
# {Nazwa kontekstu}

{1-2 zdania o tym, czym ten kontekst jest i dlaczego istnieje.}

## Język

**{Termin}**:
{Zwięzła definicja — 1 zdanie. Czym JEST, nie co ROBI.}
_Unikaj_: {alias1}, {alias2}

**{Termin 2}**:
{...}

## Relacje

- **{Termin A}** generuje jeden lub więcej **{Termin B}**
- **{Termin B}** należy do dokładnie jednego **{Termin C}**

## Przykładowy dialog

> **Dev:** „Kiedy **X** robi **Y** — czy **Z** jest tworzony od razu?"
> **Domain expert:** „Nie, **Z** powstaje dopiero po..."

## Zaflagowane niejasności

- (uzupełnij gdy znajdziesz konflikt terminologii)
```

**Zasady:**

- **5-10 terminów seed** — wybieraj te najczęściej powtarzane w kodzie/README/folderach
- **Tylko terminy domenowe** — pomijaj generic programming concepts (timeout, error, util)
- **Bądź zdecydowany** — gdy istnieje wiele słów na to samo pojęcie, wybierz JEDNO i wymień pozostałe jako aliasy do unikania
- **Definicje zwięzłe** — max 1 zdanie. Czym coś JEST, nie co ROBI
- **Pokazuj relacje** — kardynalność (1:N, N:M, ...) tam gdzie oczywista
- **Konflikty flaguj** — niejednoznaczne terminy zaznacz w "Zaflagowanych niejasnościach" z rozstrzygnięciem

**Repo z wieloma kontekstami (DDD bounded contexts):**

Jeśli repo ma wyraźnie odrębne moduły domenowe (np. `ordering/`, `billing/`, `fulfillment/`) — utwórz `CONTEXT-MAP.md` w roocie + osobne `CONTEXT.md` w każdym module:

```markdown
# Mapa kontekstów

## Konteksty
- [Ordering](./src/ordering/CONTEXT.md) — przyjmuje i śledzi zamówienia
- [Billing](./src/billing/CONTEXT.md) — generuje faktury i przetwarza płatności

## Relacje
- **Ordering → Fulfillment**: emituje eventy `OrderPlaced`
- **Ordering ↔ Billing**: współdzielone typy `CustomerId`, `Money`
```

### Backlog — zawsze ten sam format

```markdown
# Backlog

## Priorytetowe
- [ ] [TASK] Opis

## W trakcie
- [ ] [WIP] Opis — branch: `feature/xyz`

## Tech Debt
- [ ] [DEBT] Opis

## Pomysły
- [ ] [IDEA] Opis

## Ukończone (ostatnie 10)
- [x] [DONE] Opis — YYYY-MM-DD
```

### ADR — Architecture/Any Decision Record

```markdown
# ADR NNNN: Tytuł decyzji

**Data:** YYYY-MM-DD
**Status:** Proposed | Accepted | Deprecated | Superseded
**Autor:** Imię

## Kontekst
Dlaczego ta decyzja jest potrzebna.

## Decyzja
Co postanowiono.

## Konsekwencje
### Pozytywne
### Negatywne
### Mitigacja

## Alternatywy rozważane
```

### Workflow guide — obowiązkowe sekcje

1. Jak zacząć sesję (który skill odpalić)
2. Jak pracować na co dzień
3. Skrót typowego flow
4. Gdzie leżą skille (pełne ścieżki)
5. Gdzie leżą CLAUDE.md (pełne ścieżki + zakres)
6. Co gdzie trafia (kto aktualizuje, co zawiera)
