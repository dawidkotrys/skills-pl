---
name: repo-onboarding
description: Analizuje repozytorium i wdraża metodologię Claude Code — hierarchiczne CLAUDE.md, skille workflow'owe, doc structure, workflow guide. Działa na dowolnym typie repo (kod, baza wiedzy, dokumentacja strategiczna).
disable-model-invocation: true
argument-hint: "[opcjonalny typ repo: code|knowledge|docs|mixed]"
model: opus
allowed-tools: Bash(*), Read, Grep, Glob, Write, Edit, Agent, AskUserQuestion, WebSearch, WebFetch
---

# Repo Onboarding — Wdrożenie metodologii Claude Code

Jesteś architektem kontekstu AI. Twoim zadaniem jest przeanalizowanie repozytorium i wdrożenie pełnej metodologii "Infrastructure as Code dla interakcji z agentem AI".

Efekt końcowy: repozytorium, w którym Claude Code od pierwszej sesji zna konwencje, wzorce, pułapki i workflow — bez potrzeby odkrywania ich od nowa.

ultrathink

---

## Wymagania — companion skills

Skill rekomenduje i odwołuje się do innych skilli z metodologii agentic coding. Pełny zestaw jest dostępny w publicznym repo:

**👉 https://github.com/dawidkotrys/skills-pl**

Zainstaluj te skille globalnie (`~/.claude/skills/`) zanim uruchomisz `/repo-onboarding`, jeśli chcesz pełny workflow. W szczególności:

- **`grill-with-docs`** — wymagany twardo. Faza 4 używa pliku `~/.claude/skills/grill-with-docs/CONTEXT-FORMAT.md` jako specyfikacji formatu `CONTEXT.md`. Bez niego krok zawiedzie.
- **`pre-session-onboarding`, `kronikarz`, `tdd`, `diagnose`, `improve-codebase-architecture`, `critical-code-review`, `code-manager`, `to-prd`** — opcjonalne. Skill rekomenduje je w Fazie 2.3 per typ repo. Bez nich plan wdrożenia nadal się wygeneruje, ale rekomendacje skilli będą wskazywać na komendy których user nie ma.

Jeśli któregoś brak — zainstaluj z repo, albo pomiń rekomendację w prezentacji planu (Faza 3).

---

## Faza 1: Analiza repozytorium

### 1.1 Zbierz kontekst strukturalny

Uruchom **równolegle**:

```bash
# Struktura katalogów (max 3 poziomy)
find . -maxdepth 3 -type d | grep -v node_modules | grep -v .git | grep -v __pycache__ | grep -v .next | grep -v dist | grep -v build | head -80

# Pliki w rootcie
ls -la

# Git info
git log --oneline -15
git remote -v
git branch -a

# Istniejące CLAUDE.md
find . -name "CLAUDE.md" -o -name "CLAUDE.local.md" | head -20

# Istniejąca dokumentacja
find . -name "*.md" -maxdepth 3 | grep -v node_modules | grep -v .git | head -40

# Istniejące skille projektowe
find .claude/skills -name "SKILL.md" 2>/dev/null

# Package manager / stack detection
ls package.json pyproject.toml Cargo.toml go.mod requirements.txt Gemfile pom.xml build.gradle composer.json Makefile 2>/dev/null
```

### 1.2 Zidentyfikuj stack i typ repo

Przeczytaj pliki konfiguracyjne (package.json, pyproject.toml, itp.) i README jeśli istnieje.

Określ **typ repozytorium**:

| Typ | Sygnały |
|-----|---------|
| `code-webapp` | Framework frontend/backend, package.json, src/ |
| `code-backend` | API, serwer, brak frontend assets |
| `code-library` | Eksportuje moduły, ma testy, publikowane do registry |
| `code-mobile` | Flutter, React Native, Swift, Kotlin |
| `knowledge` | Głównie .md pliki, baza wiedzy, notatki, konteksty |
| `docs` | Dokumentacja techniczna, ADR, specyfikacje |
| `strategy` | Plany biznesowe, OKR, strategie, roadmapy |
| `mixed` | Kombinacja powyższych |

Jeśli podano argument ($ARGUMENTS), użyj go jako wskazówki typu. Jeśli nie — wywnioskuj z analizy.

### 1.3 Sprawdź istniejące globalne skille

```bash
find ~/.claude/skills -name "SKILL.md" 2>/dev/null | sort
```

Przeczytaj nagłówki (frontmatter) każdego znalezionego skilla — zrozum jakie workflow'y są już dostępne globalnie.

### 1.4 Przeczytaj istniejące CLAUDE.md i dokumentację

Jeśli istnieją CLAUDE.md — przeczytaj je. Nie nadpisuj dobrych instrukcji.
Jeśli istnieje README — wyciągnij kluczowe informacje.
Jeśli istnieje istniejąca dokumentacja w doc/ — zrozum co już jest pokryte.

---

## Faza 2: Zaplanuj wdrożenie

Na podstawie analizy przygotuj plan. Skonsultuj się z użytkownikiem (AskUserQuestion) jeśli masz wątpliwości dotyczące:
- Języka instrukcji (polski/angielski)
- Priorytetów (co jest najważniejsze dla tego repo)
- Specyficznych konwencji których nie da się wywnioskować z kodu

### 2.1 Zaplanuj hierarchię CLAUDE.md

Szczegółowe wzorce per typ repo znajdziesz w [patterns.md](patterns.md).

**Zasady dla każdego CLAUDE.md:**
- Max 200 linii — jeśli dłuższy, rozbij na osobne pliki lub użyj `@import`
- Tylko rzeczy których Claude nie wywnioskuje sam z kodu
- Konkretne przykłady > ogólne zasady
- Znane pułapki i gotchas = najwyższy priorytet
- Nie opisuj standardowych konwencji języka — Claude je zna

**Root CLAUDE.md** (zawsze tworzony) powinien zawierać:
1. Jednozdaniowy opis projektu
2. Stack / technologie (jeśli code repo)
3. Struktura katalogów z 1-zdaniowymi opisami
4. Konwencje nazewnictwa (jeśli niestandardowe)
5. Kluczowe wzorce architektoniczne
6. Znane pułapki i gotchas
7. Workflow ze skillami (tabela: skill → kiedy → co robi)
8. Referencje do zagnieżdżonych CLAUDE.md i dokumentacji

**Zagnieżdżone CLAUDE.md** — twórz tylko dla katalogów z niestandardowymi konwencjami. Nie twórz pustych/oczywistych plików. Każdy musi wnosić wartość której nie da się wywnioskować z kodu.

### 2.2 Zaplanuj strukturę doc/ + CONTEXT.md

```
CONTEXT.md                  # Słownik domeny (terminy, relacje, aliasy do unikania)
doc/
├── backlog.md              # Taski, tech debt, pomysły
└── decisions/              # ADR (Architecture/Any Decision Records)
    └── 0001-<opis>.md
```

**`CONTEXT.md` — domain glossary (zawsze w roocie repo):**

Persistent kontekst językowy projektu. Nie jest opisem techniki — jest opisem **języka domeny**: terminów, ich znaczeń, aliasów do unikania, relacji między pojęciami. Format: zobacz `~/.claude/skills/grill-with-docs/CONTEXT-FORMAT.md` (sekcja "Struktura").

W tej fazie zaplanuj **5-10 terminów seed** wyciągniętych z analizy:
- README — nazwy domenowe powtarzające się w opisie
- package.json / pyproject.toml — nazwy modułów, paczek wewnętrznych
- Folder structure — kategorie biznesowe (np. `ordering/`, `billing/` → `Order`, `Invoice`)
- Komentarze w kodzie / nazwy funkcji — terminy specyficzne dla biznesu

Jeśli repo jest duże i ma wyraźnie odrębne konteksty (np. ordering, billing, fulfillment) — zaplanuj `CONTEXT-MAP.md` w roocie + osobne `CONTEXT.md` w każdym module.

**Pomijaj** ogólne pojęcia programistyczne (timeout, error, util) — tylko terminy domenowe specyficzne dla tego projektu.

Dodatkowe katalogi per typ repo:
- Code: `doc/history/` (kroniki zmian), `doc/design-reviews/`
- Knowledge: nie wymaga history ani design-reviews
- Strategy: `doc/decisions/` jest kluczowy

### 2.3 Zaplanuj skille projektowe

Rozważ które z tych skilli byłyby wartościowe dla tego repo (NIE twórz wszystkich — tylko te które mają sens):

**Uniwersalne (rozważ dla każdego repo):**
- `/pre-session-onboarding` — briefing startowy (jeśli nie istnieje globalnie)
- `/kronikarz` lub wariant — dokumentacja zmian (jeśli repo jest aktywnie rozwijane)

**Dla code repos — workflow methodology (Matt Pocock, dostępne globalnie):**
- `/grill-with-docs` — grilling przed planowaniem, zamiast eager-planning
- `/to-prd` — destination document po grilling session (z vertical slices i acceptance criteria w `doc/backlog.md`), gdy inicjatywa duża
- `/tdd` — red-green-refactor pętla (test-first, vertical slicing)
- `/diagnose` — bug fixing przez Reprodukcję → Minimalizację → Hipotezy → Fix
- `/improve-codebase-architecture` — deepening modułów (Ousterhout's deep modules)
- `/critical-code-review` — formalny audyt przed merge

**Dla code repos — operacyjne:**
- `/code-manager` — orchestrator sesji (wybór taska, plan, weryfikacja)
- `/quality-guard` — quick check jakości kodu
- `/design-checker` — weryfikacja design systemu (jeśli ma UI)

**Dla knowledge/docs/strategy repos:**
- `/summarize` — podsumowanie sekcji lub całego repo
- `/consistency-check` — weryfikacja spójności informacji
- `/update-index` — aktualizacja indeksów i spisu treści

Sprawdź czy globalne skille już pokrywają potrzeby — nie duplikuj.

---

## Faza 3: Prezentacja planu

Wyświetl plan użytkownikowi w formacie:

```
## 🏗️ Plan wdrożenia metodologii Claude Code

### Typ repozytorium: [typ]

### Pliki do utworzenia

| Plik | Opis |
|------|------|
| `CLAUDE.md` | Root context — [krótki opis zawartości] |
| `src/xyz/CLAUDE.md` | [opis] |
| `doc/backlog.md` | Backlog projektu |
| ... | ... |

### Skille do utworzenia (projektowe)
| Skill | Opis |
|-------|------|
| ... | ... |

### Istniejące globalne skille (nie duplikujemy)
| Skill | Opis |
|-------|------|
| ... | ... |

### Istniejące pliki do zachowania/aktualizacji
| Plik | Akcja |
|------|-------|
| ... | ... |
```

**Zapytaj użytkownika o akceptację** przez AskUserQuestion z opcjami:
- "Wdrażaj cały plan"
- "Chcę zmodyfikować plan"

Jeśli użytkownik chce modyfikacji — dostosuj plan i zapytaj ponownie.

---

## Faza 4: Implementacja

Po akceptacji planu, twórz pliki w kolejności:

1. **Root CLAUDE.md**
2. **Zagnieżdżone CLAUDE.md** (jeśli zaplanowane)
3. **CONTEXT.md** — domain glossary z 5-10 terminami seed (lub `CONTEXT-MAP.md` + per-module `CONTEXT.md` dla repo z wieloma kontekstami)
4. **doc/backlog.md** — z istniejącymi taskami jeśli da się je wyciągnąć z TODO/README/issues
5. **doc/decisions/0001-claude-code-methodology.md** — ADR dokumentujący wdrożenie
6. **Skille projektowe** (jeśli zaplanowane) — do `.claude/skills/`

**Tworzenie `CONTEXT.md`:**

- Format dokładnie jak w `~/.claude/skills/grill-with-docs/CONTEXT-FORMAT.md`
- 5-10 terminów seed wyciągniętych z analizy fazy 1 (README, package.json, struktura folderów, nazwy modułów)
- Każdy termin: zwięzła definicja (1 zdanie) + `_Unikaj_:` z aliasami które nie powinny być używane
- Sekcja **Relacje** — kardynalność między terminami (np. "Order generuje jeden lub więcej Invoice")
- Sekcja **Przykładowy dialog** — krótki dialog dev/domain expert pokazujący użycie
- Sekcja **Zaflagowane niejasności** — pusta na start, do uzupełnienia w trakcie pracy
- Tylko terminy **specyficzne dla domeny** projektu — pomijaj ogólne pojęcia programistyczne

Jeśli nie udaje się wydobyć terminów z analizy (repo jest puste/nowe) — zostaw `CONTEXT.md` z pustym szkieletem i komentarzem "Uzupełnij gdy poznasz domenę". Lepszy szkielet niż brak pliku.

### Tworzenie plików

- Używaj Write tool, nie Bash
- Nie twórz pustych katalogów — tylko te z plikami
- Jeśli plik istnieje i ma wartościową zawartość — Edit zamiast nadpisywania
- Sprawdź czy `doc/` istnieje zanim tworzysz podkatalogi

---

## Faza 5: Weryfikacja

Po utworzeniu wszystkich plików:

1. Wylistuj utworzone pliki
2. Sprawdź że root CLAUDE.md < 200 linii
3. Sprawdź że każdy nested CLAUDE.md < 200 linii
4. Wyświetl podsumowanie:

```
## ✅ Wdrożenie zakończone

### Utworzono X plików:
- CLAUDE.md (Y linii)
- ...

### Następne kroki:
1. Przejrzyj CLAUDE.md — popraw jeśli coś nie pasuje
2. Uruchom `/pre-session-onboarding` żeby przetestować briefing
3. [Dodatkowe kroki specyficzne dla repo]
```

---

## Zasady ogólne

- Pisz CLAUDE.md i pozostałą dokumentację w tym samym języku co reszta repo (jeśli repo jest po polsku — pisz po polsku, jeśli po angielsku — po angielsku). Zapytaj użytkownika jeśli nie jest jasne.
- Nie twórz plików "na zapas" — każdy plik musi wnosić konkretną wartość
- Bądź precyzyjny w CLAUDE.md — podawaj ścieżki, nazwy, przykłady
- Sekcja "Znane pułapki" to najważniejsza część CLAUDE.md — poświęć jej najwięcej uwagi
- Nie duplikuj informacji z README — linkuj do niego
- Skille projektowe twórz w `.claude/skills/`, nie w `~/.claude/skills/` (żeby były w repo)

$ARGUMENTS
