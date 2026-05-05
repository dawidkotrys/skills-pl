---
name: to-prd
description: Zamień bieżący kontekst rozmowy na PRD (destination document) + folder inicjatywy `doc/plans/<slug>/` z dwoma plikami - `prd.md` (vision + slices) i `backlog.md` (scaffold ze statusem `[ ] niezdetailowany` per slice). Używaj kiedy chcesz utrwalić ustalenia z grillingu/rozmowy jako trwały dokument zanim zaczniecie implementację — szczególnie przy dużych inicjatywach przed `/tusks` rozbijaniem slicesów na taski. Triggery - "napisz PRD", "stwórz PRD", "PRD z naszej rozmowy", "destination document", "zarys planu", "nowa inicjatywa". NIE auto-trigger.
disable-model-invocation: true
---

# `/to-prd` — Konwersacja → folder inicjatywy + PRD + scaffold backlog

Ten skill bierze bieżący kontekst rozmowy i zrozumienie kodu, i produkuje **trzy artefakty na dysku**:

1. Folder `doc/plans/<slug>/` (nowy)
2. `doc/plans/<slug>/prd.md` — destination document (vision, vertical slices, slice-level acceptance)
3. `doc/plans/<slug>/backlog.md` — scaffold (metadata header + sekcja per slice ze statusem `[ ] niezdetailowany` + skopiowane slice purpose/acceptance z PRD)

**NIE przesłuchuj użytkownika** — po prostu zsyntetyzuj to, co już wiesz z konwersacji + kodu. Jedyne pytanie: potwierdzenie sluga folderu (Krok 3a).

## Pozycja w workflow

```
/grill (opcjonalny grilling) → [ /to-prd ] → /tusks slice 1 → agent wykonuje → ...
                                  ↓
                           folder + prd.md + backlog.md scaffold
```

`/to-prd` zostawia inicjatywę w stanie **gotowym do `/tusks`** — slice'y są zdefiniowane w PRD, ale **nierozbite na taski wykonawcze**. Manager wraca później z `/tusks slice <N>` żeby rozpisać konkretny etap.

## Pojedyncza odpowiedzialność

Tworzysz folder + PRD + scaffold backlog. Konkretnie **NIE robisz**:

- Nie rozbijasz slicesów na taski wykonawcze (to robi `/tusks` — slice po slice'cie, w pętli z managerem)
- Nie commit'ujesz (manager owns docs commits — rule projektowa)
- Nie eksplorujesz pełnego repo (rule surgical — czytasz wystarczająco żeby napisać sensowne slices)
- Nie tworzysz ADR-ów (to robi `/grill` — proponuje ADR-y oszczędnie, gdy decyzja jest hard-to-reverse + zaskakująca + wynik trade-off'u)

---

## Flow

### Krok 1: Eksploruj repo dla kontekstu

Cel: respektować **język domeny** projektu i istniejące decyzje.

- Przeczytaj `CONTEXT.md` (jeśli istnieje) — używaj słownika domeny konsekwentnie w PRD
- Sprawdź `doc/decisions/` (lub `docs/adr/`) — relevantne ADR-y dla obszaru który PRD dotyka
- Przeskanuj `doc/plans/` — czy jest aktywna powiązana inicjatywa? Jeśli tak — flag dla user'a (możliwy overlap, dependency, lub merge dwóch w jeden)

Limit: **max 5-7 plików** czytanych w pełni. Surgical — czytasz żeby PRD był spójny z resztą repo, nie buduj pełnej mapy.

### Krok 2: Zarysuj główne moduły i vertical slices

Aktywnie szukaj okazji do wyodrębnienia **głębokich modułów** (deep modules — Ousterhout). Głęboki moduł enkapsuluje dużo funkcjonalności w prostym, testowalnym interfejsie który rzadko się zmienia.

**Vertical slicing** dla slicesów (tracer-bullet pattern):
- Każdy slice cuts through ALL integration layers end-to-end (schema → API → UI → tests)
- Slice jest demoable / verifiowalny samodzielnie
- Preferuj **wiele cienkich slicesów** zamiast kilku grubych

**Heurystyka liczby slicesów:** 3-8 vertical slices typowo. Mniej = inicjatywa może być za mała na PRD (rozważ luźny plan w `doc/plans/<slug>.md`). Więcej = warto split na dwa PRD'y.

Skonfrontuj proponowany podział z user'em — czy slice'y odpowiadają jego oczekiwaniom? Iteruj zanim zaczniesz pisać PRD.

### Krok 3a: Wybierz slug + utwórz folder

**Slug** = kebab-case nazwa folderu, derivowana z tytułu inicjatywy. Zasady:
- Lowercase, słowa rozdzielone `-`
- Bez polskich znaków (ż → z, ł → l) — żeby ścieżka była portable
- Krótki, ale unikalny (nie myli się z innymi inicjatywami)
- Bez prefiksu numerowanego (PRD'y są referowane przez slug, nie numer)

**Flow:**
1. Zaproponuj slug: *"Slug folderu: `<proposed-slug>`. Akceptujesz lub podaj inny?"*
2. Czekaj na potwierdzenie / override'a (one-line interaction)
3. **Verify** że folder nie istnieje — `ls doc/plans/<slug>/`. Jeśli istnieje, zaalarmuj user'a (możliwy duplikat lub kolizja z poprzednią inicjatywą).
4. Utwórz folder: `mkdir -p doc/plans/<slug>/`

**Przykład sluga:** *"Offline mode dla Knowledge / Source items"* → `offline-mode-knowledge-source-items`

### Krok 3b: Napisz `prd.md`

Pełna ścieżka: `doc/plans/<slug>/prd.md`. Użyj template'u poniżej.

**Krytyczne dla późniejszego scaffolding'u** (Krok 3c) i konsumpcji przez `/tusks`:
- Slice headings w formacie `## Slice N: <tytuł>` — żeby anchor był deterministic (`#slice-1-<slug>`)
- Per-slice section MUSI mieć **Slice purpose** (jedno-dwa zdania) i **Slice acceptance** (lista bullet'ów) — to są pola które `/tusks` konsumuje, agent wykonawczy też na nich operuje

### Krok 3c: Scaffold `backlog.md`

Pełna ścieżka: `doc/plans/<slug>/backlog.md`. Użyj template'u poniżej.

**Co skill robi:**
1. Czyta wygenerowany `prd.md` (sekcje slice'ów)
2. Generuje frontmatter metadata (`status: init`, `current_slice: null`, `total_slices: <N>`, `last_update: <today>`)
3. Generuje sekcję per slice — kopiuje **Slice purpose** + **Slice acceptance** z PRD do backlog'u
4. W każdej sekcji slice'a wstawia placeholder `_Slice niezdetailowany. Manager invoke /tusks slice <N> żeby rozbić na taski._`
5. Status każdego slice'a: `[ ] niezdetailowany`

**Dlaczego kopia, nie link:**
- Backlog ma być **self-contained execution document** — agent wykonawczy nie powinien wracać do PRD per task
- Linki do PRD są dodatkowe (sekcja `[→ prd.md#slice-N]`), ale acceptance i purpose są w backlog'u directly
- Drift: jeśli ktoś updatuje PRD acceptance po scaffolding'u, to red flag (PRD = destination document, immutable po `/to-prd`; dłuższa zmiana wymaga `/grill` + nowa iteracja)

---

## Template `prd.md`

```markdown
# <Tytuł inicjatywy>

## Problem

Problem, z którym mierzy się użytkownik, z perspektywy użytkownika.

## Rozwiązanie

Rozwiązanie problemu, z perspektywy użytkownika.

## User Stories

DŁUGA, ponumerowana lista user stories. Każda w formacie:

1. Jako <aktor>, chcę <funkcjonalność>, żeby <korzyść>

Lista user stories powinna być wyczerpująca i pokrywać wszystkie aspekty funkcji.

## Decyzje implementacyjne

Lista decyzji implementacyjnych, które zostały podjęte. Może obejmować:

- Moduły, które zostaną zbudowane/zmodyfikowane
- Interfejsy tych modułów
- Doprecyzowania techniczne od dewelopera
- Decyzje architektoniczne
- Zmiany schematu bazy
- Kontrakty API
- Konkretne interakcje

NIE umieszczaj konkretnych ścieżek plików ani fragmentów kodu — szybko się dezaktualizują. Konkrety lądują w `backlog.md` per task (zadanie `/tusks`).

## Decyzje testowe

Lista decyzji testowych. Uwzględnij:

- Opis tego, co stanowi dobry test (testuj zewnętrzne zachowanie, nie szczegóły implementacyjne)
- Które moduły będą testowane
- Prior art dla testów (podobne typy testów już istniejące w kodzie)

## Vertical slices

Każdy slice = sekcja z fixed format (kontrakt z `/tusks` i `backlog.md`).

### Slice 1: <Krótki tytuł>

**Slice purpose:** <jedno-dwa zdania — co ten slice osiąga end-to-end>

**Slice acceptance:**
- <verifiowalne kryterium 1>
- <verifiowalne kryterium 2>
- <verifiowalne kryterium 3>

**Decyzje slice-level:** <opcjonalnie — niuanse implementacyjne których nie chcesz w głównej sekcji "Decyzje implementacyjne", bo są specyficzne dla tego slice'a>

### Slice 2: <Krótki tytuł>

**Slice purpose:** ...
**Slice acceptance:**
- ...

### Slice 3: ...

## Out of scope

Opis rzeczy, które są **poza zakresem** tego PRD. Ta sekcja jest kluczowa dla jasnej definicji "done".

## Dodatkowe uwagi

Wszelkie dalsze notatki dotyczące funkcji.
```

---

## Template `backlog.md` (scaffold)

```markdown
---
prd: prd.md
status: init
current_slice: null
total_slices: <N>
last_update: <YYYY-MM-DD>
---

# Backlog — <Tytuł inicjatywy>

> Backlog wykonawczy. Slice-level scope i acceptance są w [prd.md](prd.md).
> Statusy slicesów: `[ ] niezdetailowany` | `🔄 in-progress` | `✅ done`.
> Statusy tasków: `[ ]` niezrobione | `🔄 in-progress` | `👀 to-review` | `✅ done`.

## Slice 1: <Tytuł z PRD> [ ] niezdetailowany

**Slice purpose** (z PRD): <skopiuj z prd.md#slice-1>
**Pełny kontekst:** [→ prd.md#slice-1](prd.md#slice-1-<slug>)

**Slice acceptance** (z PRD):
- <skopiuj kryterium 1>
- <skopiuj kryterium 2>
- <skopiuj kryterium 3>

### Tasks

_Slice niezdetailowany. Manager invoke `/tusks slice 1` żeby rozbić na taski._

---

## Slice 2: <Tytuł z PRD> [ ] niezdetailowany

**Slice purpose** (z PRD): ...
**Pełny kontekst:** [→ prd.md#slice-2](prd.md#slice-2-<slug>)

**Slice acceptance** (z PRD):
- ...

### Tasks

_Slice niezdetailowany. Manager invoke `/tusks slice 2` żeby rozbić na taski._

---

## Slice <N>: ...
```

---

## Convention linkowania

Wszystkie skille produkujące dokumentację używają **standard markdown** linków:

- Format: `[label](relative/path/to/file.md#anchor)`
- Linki **relative** zawsze (Obsidian buduje graph, GitHub renderuje natywnie, linters je sprawdzają)
- Anchor: lowercase + dashes (GitHub auto-slug — `## Slice 2: Sync engine` → `#slice-2-sync-engine`)
- Slice IDs `Slice <N>` jako referencja w PRD/backlog
- Task IDs `T<slice>.<num>` (generowane przez `/tusks` w fazie task breakdown'u) jako lingua franca: backlog → commits → kroniki → code reviews → ADR-y

W PRD linkuj do:
- `CONTEXT.md` (jeśli używasz terminów ze słownika)
- ADR-y w `doc/decisions/NNNN-*.md` (relevantne dla decyzji architektonicznych)
- Powiązane PRD-y w `doc/plans/<other-slug>/prd.md` (jeśli inicjatywy mają zależności)

---

## Anti-patterny

| Pokusa | Dlaczego nie | Co zamiast |
|---|---|---|
| "Wpiszę konkretne ścieżki plików w decyzjach implementacyjnych" | Ścieżki plików dezaktualizują się szybko, PRD ma żyć długo. | Decyzje high-level w PRD; konkretne pliki w `backlog.md` per task (`/tusks`). |
| "Rozbiję slice 1 na taski od razu w PRD" | Mieszasz odpowiedzialności — PRD to vision, taski to execution. | PRD zostaje na poziomie slice. `/tusks` invoke później rozbija slice na taski. |
| "Zapomnę o `Slice acceptance` — wystarczy `Slice purpose`" | `/tusks` i agent wykonawczy konsumują acceptance. Bez nich = slice mglisty. | Każdy slice MUSI mieć acceptance (3-5 verifiowalnych kryteriów). |
| "Commitnę po Write żeby nic nie zginęło" | Manager owns docs commits. | Zostawiasz pliki na dysku (uncommitted). Manager commituje sam. |

---

## Zasady ogólne

- **Polski w body, polski w description** (per `skills-pl/CLAUDE.md` convention)
- **Imperative form** — "Wczytaj CONTEXT.md", nie "Powinieneś wczytać"
- **Bez przesłuchiwania** — synthesizuj z konwersacji, jedyne pytanie to slug folderu (Krok 3a)
- **Verify before recommend** — slice'y które proponujesz muszą być real (pliki które referujesz istnieją, lub explicit zaznaczone jako "nowe")
- **Polskie znaki w kodzie/ścieżkach** — NIE. Slug bez ł/ż/ć itp.
