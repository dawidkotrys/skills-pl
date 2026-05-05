# 05. Flow: duża inicjatywa

Nowy moduł, cross-cutting concern, refactor architektoniczny, integracja z external system. Coś co przekracza 1 dzień pracy lub dotyka >5 plików / >2 modułów.

## Charakterystyka

- Wiele vertical slices (3+ niezależnych issues)
- Decyzje architektoniczne do podjęcia (kwalifikują się na ADR)
- Ryzyko regresji **nie jest** ograniczone do jednego obszaru
- Możliwe parallel work (subagenty pickup-ują niezależne issues)
- Plan **nie jest** oczywisty — wymaga grillingu

Jeśli mówisz "to wprowadza nowy concept w domain" / "to dotyka jak users się logują" / "to zmienia jak data leci przez system" — to **duża inicjatywa**.

---

## Flow

```
PLANOWANIE
  1. Grill                     →  /grill                 (CONTEXT.md + ADR-y)
  2. PRD + scaffold backlog    →  /to-prd                (folder doc/plans/<slug>/{prd.md, backlog.md})
  3. Audyt PRD (iteracyjny)    →  /critical-prd-review   (security/scale/architecture lens
                                                          → werdykt Needs revision / Almost ready / Ready
                                                          → feedback wklejany agentowi-autorowi do iteracji
                                                          → pętla aż Ready)
  4. Bridge na implementację   →  /code-manager (Tryb 4B) — invoke /to-tasks slice <N>
                                  + krótki plan-most dla agenta

IMPLEMENTACJA per slice (loop, slice po slicie)
  5. Agent wykonawczy implementuje → /kronikarz live + sekwencja 3-STOP
     (patrz 00-glowny-flow.md#cztery-punkty-kontrolne-usera)
  6. Manager Tryb 5C close + slice → ✅ done w backlog.md
  7. User /clear + restore → wróć do kroku 4 dla slice N+1

ARCHIVE (po merge ostatniego slice'a)
  8. Manager Tryb 5D → folder doc/plans/<slug>/ → doc/plans/archive/<slug>/
```

Krok 1-4 to **day shift** (twoja pełna uwaga, designujesz z agentem). Krok 5 to mix **night shift** (agent implementuje) i **day shift** (Twoje QA + decyzje per-finding po code review).

**Per-slice loop:** każdy slice z PRD przechodzi pełną sekwencję 3-STOP osobno (`/to-tasks` → impl → user QA → external review → close → merge). Manager rozpisuje **tylko bieżący slice** — nie wszystko z góry. Po merge slice'a kolejny slice rozpisuje się dopiero gdy manager jest gotów.

**Filozofia 3-STOP** (jednolicie opisana w [00-glowny-flow.md](./00-glowny-flow.md#cztery-punkty-kontrolne-usera)): "po co reviewować coś co nie działa" — implementacja musi najpierw zadziałać user-side (zasada #9 imposing taste), dopiero potem polerowanie przez external review.

**External review**: Manager (Opus) odpala `/critical-code-review` na finalnym kodzie, **nie agent wykonawczy** (Sonnet). Peer review principle, brak confirmation bias na własne decyzje.

**Autonomy gate**: Manager nie merguje sam — pyta usera "merge?", po user "akcept" → Manager `git push` + merge. Człowiek ma ostateczne słowo przed irreversible action.

---

## Krok 1 — Grill (`/grill`)

**Najważniejszy krok.** Nie skracaj. Per zasada #4 — eager planning bez grillingu = plan który nie wytrzyma kontaktu z rzeczywistością.

Cel grillingu:

- **Shared design concept** — Ty i agent rozumiecie problem **tak samo**
- **Constraints na stole** — wszystkie ograniczenia (latency, security, compliance, backward compat) wyartykułowane
- **Edge case'y zidentyfikowane** — co jeśli null, co jeśli concurrent, co jeśli partial failure
- **CONTEXT.md zaktualizowane** — terminy domenowe które padły w grillingu zostają w słowniku
- **Decisions wstępnie zaproponowane** — które będą ADR-ami

Grill może trwać 30-60 minut rozmowy. To **nie jest** strata czasu — to inwestycja w jakość planu.

### Sygnały że grill jest "done"

- Możesz **w zwięzłej formie** opisać problem, rozwiązanie i dlaczego (nie ma dziur)
- Padły 3+ pytania na które **musiałeś dopytać** (siebie, dokumentację, domain experta)
- Zmodyfikowałeś początkową hipotezę (znak że kontakt z rzeczywistością coś dał)
- `CONTEXT.md` ma 2-5 nowych / zaktualizowanych terminów

### Sygnały że grill jest **przedwczesny** / niepełny

- Wszystko brzmi "OK", "logiczne", "powinno działać" → nie zostało przetestowane przez konfrontację
- Nie padło ani jedno "ale co jeśli..."
- Twoja początkowa hipoteza jest **identyczna** z tą z którą zaczynałeś — albo jesteś genialny, albo grill nic nie wniósł

---

## Krok 2 — PRD + scaffold backlog (`/to-prd`)

Po grillingu — `/to-prd` konwertuje kontekst rozmowy na **destination document**: PRD (Product Requirements Document) + scaffold execution-grade backlog'u.

PRD nie jest kontraktem — jest **kierunkiem**:

- Cel inicjatywy (jednym zdaniem)
- User stories / scenariusze
- Constraints i non-goals (co eksplicytnie NIE jest scope)
- High-level approach
- Vertical slices z `Slice purpose` + `Slice acceptance` per slice
- Decyzje już podjęte (linki do ADR-ów)
- Otwarte pytania (do dorobienia w trakcie)

`/to-prd` produkuje **folder inicjatywy** `doc/plans/<slug>/` z dwoma plikami:
- `prd.md` — destination document (vision + slices)
- `backlog.md` — scaffold execution-grade (sekcja per slice ze statusem `[ ] niezdetailowany`)

Slice'y w `backlog.md` zostają **niezdetailowane** dopóki manager nie invoke `/to-tasks slice <N>` (krok 4). To kluczowa decyzja: **nie rozpisujemy wszystkich tasków z góry**, tylko bieżący slice w pętli.

### Każdy slice musi być

- **Vertical slice** (zasada #4) — UI → API → DB → tests dla jednej małej funkcjonalności end-to-end
- **Tracer bullet** — działający kod, nie prototyp
- **Cienki** — bias na cieńsze. Jeśli wahasz się czy podzielić — dziel.
- **Blocking relationships** explicite — `wymaga: SLICE-3`, `blokuje: SLICE-5`

### Anty-wzorzec — horizontal slicing

```
Slice 1: Wszystkie modele DB
Slice 2: Wszystkie API endpoints
Slice 3: Wszystkie UI komponenty
```

To jest **horizontal**. Każdy slice jest niemożliwy do zweryfikowania dopóki nie zrobi się wszystkich. Brak feedback loop. Catastrophe.

### Wzorzec — vertical slicing

```
Slice 1: Tracer bullet — list orders (read only, hard-coded data, minimal UI)
Slice 2: Real data fetch (DB → API → UI)
Slice 3: Filtering by status
Slice 4: Pagination
Slice 5: Search by customer name
```

Każdy slice **dostarcza** coś działającego. User po slice 1 widzi listę (nawet jeśli hard-coded). Po slice 2 widzi prawdziwe dane. Itd.

---

## Krok 3 — Audyt PRD (`/critical-prd-review`)

Przed task breakdown'em — audyt PRD jak critical code review **wykonane zanim powstanie kod**. Skill wchodzi w rolę wymagającego reviewera techniczno-produktowego i szuka luk w trzech wymiarach: **security by design** (least privilege, threat model, walidacja na granicy backendu, sekrety, audytowalność), **scalability by design** (limity, backpressure, idempotencja, timeouts, koszty, degradacja), **simple deep architecture** (głębokie moduły, proste kontrakty, brak płytkich wrapperów).

Output: werdykt **Needs revision** / **Almost ready** / **Ready** + feedback z etykietami **BLOCKER / MAJOR / MINOR / QUESTION**, każda uwaga zakotwiczona w konkretnym fragmencie PRD lub brakującej sekcji.

### Kto odpala — agent-auditor, nie agent-autor PRD

Peer review principle, analogiczny do `/critical-code-review`. Audyt PRD **musi** robić agent który nie pisał PRD — inaczej confirmation bias: agent broni własnych decyzji zamiast je kwestionować.

Praktycznie: User puszcza skill w **świeżej sesji** (default agent) lub w **innym CLI** (np. Codex / inny LLM provider — feedback z innego modelu jest dodatkową soczewką). Wkleja PRD lub linkuje plik. Audyt zwraca raport.

### Iteracja — feedback → revision → re-audit

```
revision N:
  feedback z auditora    ──►   user wkleja agentowi-autorowi
  agent-autor naprawia luki   ──►   commit "PRD <slug> rev. <N+1> — <K> fixów"
  ◄── prd.md rev. N+1 ──

revision N+1:
  user puszcza /critical-prd-review na nowej wersji
  ◄── nowy werdykt ──
```

Pętla biegnie aż werdykt = **Ready** (lub świadomie **Almost ready** z explicit acceptance pozostałych MINOR-ów). Każda rev. zostawia ślad: `doc/code-reviews/<DATE>-prd-<slug>-rev<N>.md` (raport audytora) + commity rev. w git history PRD.

### Sygnały że audyt jest wartościowy

- Wykrył 1+ **BLOCKER** który prowadziłby do rewrite po implementacji (np. brakujący authorization model, unbounded query, frontend-only validation security)
- Wymusił 2-5 **MAJOR** doprecyzowań w decyzjach implementacyjnych / testowych
- Wskazał luki w out-of-scope (rzeczy które wyglądają jak in-scope ale nie są jasno wykluczone)
- Skrócił późniejszy `/critical-code-review` (mniej findings na finalnym kodzie, bo PRD już je wyłapał na poziomie wymagań)

### Sygnały że audyt jest "fake green"

- Werdykt **Ready** za pierwszym razem na nietrywialnym PRD bez żadnych BLOCKER/MAJOR — najczęściej oznacza że auditor nie wszedł w detale, nie skonfrontował z `CONTEXT.md`, nie sprawdził kodu który PRD dotyka
- Feedback w stylu "warto rozważyć" / "może doprecyzować" — łagodne sformułowania zamiast konkretnej zmiany do dopisania w PRD
- Brak Pre-Code Review Checklist coverage — audyt który nie sprawdza klasyk z security/scalability hard gates jest powierzchowny

W obu przypadkach: nie akceptuj werdyktu, puść audyt jeszcze raz — najlepiej przez innego agenta / inny model / explicit prompt "ostrzejsza linia".

---

## Krok 4 — Bridge + task breakdown (`/code-manager` Tryb 4B + `/to-tasks`)

Po **PRD audit Ready** masz folder inicjatywy z dopracowanym PRD. Przed implementacją: bridge mode managera. Manager:

- Wybiera **bieżący slice** (typowo Slice 0 lub 1)
- Invoke `/to-tasks slice <N>` → rozbija slice na 3-7 granularnych tasków wykonawczych z file targets + acceptance criteria. Status sekcji slice'a: `[ ] niezdetailowany` → `🔄 in-progress`
- Pisze krótki **bridge plan** (~30-50 linii) — link do PRD + tasks w backlog.md, kontekst pracy równoległej, kolejność wykonania, pułapki
- Dispatchuje do agenta wykonawczego (wiadomość-do-wkleienia)

Output: bridge plan + zaktualizowany `backlog.md` (current slice rozpisany na taski).

---

## Krok 5 — Implementacja per slice (sekwencja 3-STOP)

Per bieżący slice:

- Agent wykonawczy implementuje taski po kolei (T<N>.1 → T<N>.2 → ...)
- `/kronikarz live` przez całą drogę
- Sekwencja 3-STOP — szczegóły w [00-glowny-flow.md](./00-glowny-flow.md#cztery-punkty-kontrolne-usera)
- Per Memento (zasada #2) — jeśli kontekst się zaśmieca → save/restore session

Manager Tryb 5C zamyka slice po merge: status `🔄 in-progress` → `✅ done` w `backlog.md`.

---

## Krok 6 — Loop dla kolejnego slice'a

Po close slice'a N: **user `/clear` + `/restore-session-manager`** → świeża sesja managera dla slice'a N+1. Wracasz do **kroku 4** (manager invoke `/to-tasks slice <N+1>`).

Per-slice loop trwa aż wszystkie slices są `✅ done`. Wtedy → krok 7.

---

## Krok 7 — Archive folderu inicjatywy

Manager Tryb 5D: po merge ostatniego slice'a → folder `doc/plans/<slug>/` przenosi się do `doc/plans/archive/<slug>/`. Zawartość intact (audit trail). Frontmatter `status: in-progress` → `status: done`.

---

## Anty-wzorce

### Pomijanie grillingu

"Już wiem co trzeba zrobić, lecę do `/to-prd`". Tracisz okazję do testu hipotez. Plan będzie wyglądał OK ale rozsypie się przy implementacji.

### Pomijanie PRD audit przed task breakdown'em

"PRD jest jasny, lecę do `/to-tasks`". `/critical-prd-review` łapie luki **na poziomie wymagań** które inaczej wyjdą jako CRITICAL findings w `/critical-code-review` po implementacji — wtedy fix wymaga rewrite kodu, nie poprawki w PRD. Audyt PRD trwa minuty, audyt kodu trwa godziny + rewrite. Pomijanie = oszczędzanie minut kosztem godzin.

### PRD audit zrobiony przez agenta-autora PRD

Confirmation bias. Agent który napisał PRD nie znajdzie luk w swoich własnych decyzjach — broni ich. Audyt **musi** robić agent w świeżej sesji lub innym CLI/modelu. Peer review principle, identyczny jak dla `/critical-code-review`.

### Slices które są horizontal

Każdy slice **musi** być vertical slice end-to-end. Patrz zasada #4.

### Rozpisanie wszystkich slicesów na taski z góry

Anti-pattern. `/to-tasks` invoke per slice w pętli — nie wszystko z góry. Powód: kontekst kolejnego slice'a jest informowany przez to czego się nauczyłeś przy poprzednim. Eager task breakdown wszystkich slicesów = drift od rzeczywistości.

### Pisanie wszystkich testów na początku (anti-TDD)

Per zasada #7 — to pozwala AI na cheating (hardcoded values żeby satysfakcjonować wszystkie testy). TDD red-green vertical, jeden test → jedna decyzja implementacyjna.

### Brak QA loop

"Code review przeszło, mergujemy". QA nie jest opcjonalne. QA to imposing taste i pętla, nie checkpoint (zasada #9).

### Pisanie ADR-a po fakcie / dla każdej decyzji

ADR-y sparingly. Hard-to-reverse + surprising + real trade-off. Reszta to commit messages. (Patrz `03-pliki-projektu.md` sekcja `doc/decisions/`.)
