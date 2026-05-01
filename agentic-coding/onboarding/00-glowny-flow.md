# 00. Główny flow — choreografia Manager ↔ User ↔ Executor

Ten dokument pokazuje **pełen przepływ pracy w metodologii** — od momentu gdy masz pomysł, aż do zmergowanej zmiany. Łączy w jednym miejscu role, artefakty, komendy i punkty kontrolne usera.

Pozostałe dokumenty onboarding (04, 05, 06) opisują **warianty per skala**. Ten dokument opisuje **wspólny szkielet** który jest pod nimi. Czytaj go pierwszy — potem wybierz wariant per skalę swojego taska.

---

## Trzej aktorzy

```
[USER] ←→ [MANAGER] ←→ [USER] ←→ [EXECUTOR]
                                    ↓
                              real code changes
```

- **User (Ty)** — autorytet decyzyjny. Każdy STOP w sekwencji to twoja decyzja. Mediator wiadomości między Managerem a Executorem (kopiuj-wklej).
- **Manager (Opus, `/code-manager`)** — bird's-eye view, planowanie, dispatch, external code review, close, autonomy gate, merge. **Nie pisze kodu produktowego.**
- **Executor (Sonnet, agent w worktree/branchu)** — pisze kod. Aktualizuje kronikę live. Raportuje do Managera (przez user). **Nie odpala `/critical-code-review`, nie pushuje, nie merguje.**

User pełni rolę **bus'a komunikacyjnego** — Manager nie rozmawia bezpośrednio z Executorem. Każda wiadomość przechodzi przez user'a (kopiuj-wklej). To zapobiega autonomous loop'om bez human-in-the-loop i wymusza imposing taste (zasada #26) na każdym STOP-ie.

---

## ASCII sequence diagram — large initiative (canonical: grill-first)

**Kluczowa zasada:** Manager wchodzi do gry **dopiero gdy PRD istnieje na dysku.** Grill+PRD odbywają się w **default agent** (fresh smart zone, brak managera w kontekście). To minimalizuje bloat managera i pozwala mu w Tryb 4B czytać czysty PRD jako input zamiast brać udział w jego tworzeniu.

```
USER             DEFAULT AGENT          MANAGER (Opus)         EXECUTOR (Sonnet)        DYSK / ARTEFAKTY
────             ─────────────          ──────────────         ─────────────────        ─────────────────

(1) wstępny brief (w głowie usera lub plik notatkowy)
    [day shift — fresh smart zone, MANAGER NIE jest jeszcze w grze]

(2) USER → /grill-with-docs
    rozmowa user ↔ default agent
    przesłuchanie planu, rozwiązywanie zależności          ──►   CONTEXT.md (nowe terminy)
                                                                  doc/decisions/NNNN-*.md (jeśli ADR)

(3) USER → /to-prd
    rozmowa user ↔ default agent
    konwersja rozmowy na destination document               ──►  doc/decisions/NNNN-<slug>.md (PRD)
                                                                  doc/backlog.md (vertical slices z acceptance criteria)

(4) USER → /code-manager (PIERWSZE wejście managera, Tryb 4B bridge mode)
                          czyta PRD + slices + CONTEXT.md
                          wybiera pierwszy slice z userem
                          pisze bridge plan (~30-50 linii)  ──►   doc/plans/<branch>.md
                          ◄── wiadomość-do-wkleienia dla executora ─

(5) USER kopiuje ─────────────────────────────────────► EXECUTOR
    do okna executora                                     czyta plan + PRD + CLAUDE.md + CONTEXT.md
    (np. nowy worktree)                                   (manager albo user) tworzy worktree
                                                          odpala /kronikarz live   ──►   doc/history/YYYY-MM-DD-<branch>.md
                                                          wypełnia "Cel" + "Architektura" PRZED kodem
                                                          implementuje slice (vertical)
                                                          update kronika per decyzja (Implementacja log)
                                                          komentarze w kodzie linkują → kronika
                                                          przygotowuje scenariusze testowe inline
                                                          ◄── raport "STOP #1: user QA" ─

(6) STOP #1   ←── scenariusze inline ── EXECUTOR czeka
    USER QA       [opcja] /design-checker (jeśli UI) ──►          doc/design-reviews/...
    klikam, czytam, dotykam (zasada #26)
    ✅ ok / ⚠️ poprawki / ❌ broken ────► EXECUTOR
                                          jeśli ⚠️ → fix-y in-branch (commit "fix per user QA")
                                          update kronika 🧪 Testy
                                          ponowny STOP #1 jeśli były fix-y
                                          ◄── raport końcowy do managera ─
                                          "user QA ✅, zlecam /critical-code-review"

(7) wklej     ──► MANAGER Tryb 5A
    raport        pull branch + read kronika + plan
                  /critical-code-review                ──►        doc/code-reviews/YYYY-MM-DD-<branch>.md
                  tłumaczy findings na human language (zasada #4 manager-values)
                  ◄── findings + rekomendacje per-finding ─

(8) STOP #2   per-finding decyzje (FIX / BACKLOG / SKIP)
    ────────► MANAGER
              pisze wiadomość-do-wkleienia (technical, decyzje)
              ◄── wiadomość ─

(9) wklej    ─────────────────────────────► EXECUTOR
                                            fix-y dla FIX
                                            entry do backlogu dla BACKLOG (przygotowane, manager wstawia)
                                            SKIP z templatem (Impact / Koszt / Rationale / Re-evaluate)
                                            update kronika (sekcja Code review findings + decyzje)
                                            ◄── raport "STOP #3: re-test" ─

(10) STOP #3 ←── scenariusze których dotykały zmiany ── EXECUTOR
     re-test    (pomijasz jeśli wszystko BACKLOG/SKIP)
     ✅ ok ───► EXECUTOR
                                            ◄── raport końcowy do managera ─
                                            "wszystko ✅, zlecam /kronikarz close"

(11) wklej   ──► MANAGER Tryb 5B
                 sanity check kroniki (czy wszystkie sekcje wypełnione)
                 /kronikarz close                      ──►        doc/history/... (sekcja Manager close)
                                                                  doc/backlog.md (DONE entries z BACKLOG)
                                                                  doc/history/README.md (indeks)
                                                                  git commit kroniki
                 pull-up review (luki kronika ↔ backlog)
                 ◄── human-language podsumowanie do merge ─

(12) AUTONOMY GATE: "merge?"
     "akcept" ──► MANAGER Tryb 5C
                  git push
                  merge do source brancha (PR / direct per CLAUDE.md)
                  update merge SHA w kronice close
                  ◄── final raport ─
```

### Alternative entry — manager-first (fallback gdy nie wiesz czy to large)

Jeśli wchodzisz do managera Tryb 1 z **wstępnym briefem** zamiast iść grill-first — manager klasyfikuje skalę i odsyła z powrotem:

```
1. USER → /code-manager Tryb 1 ("wstępny brief, chcę X")
2. MANAGER klasyfikuje, jeśli 🔴 large → "Canonical flow to grill+PRD bez mnie. Odpal /grill-with-docs, potem /to-prd, wróć z gotowym PRD."
3. USER → /grill-with-docs → /to-prd (default agent, BEZ managera)
4. USER → /code-manager (świeża sesja, Tryb 4B bridge) → kontynuacja od kroku (4) canonical flow
```

To jest **fallback, nie default**. Kosztuje więcej bo manager Tryb 1 obciąża swój kontekst recap'em backlogu/git state niepotrzebnie przy large initiative. Lepsza praktyka: gdy wiesz że to large → idź od razu do `/grill-with-docs`, manager poczeka.

### Mały task — manager-first jest poprawny

**Mały task** (Ścieżka B z [04](./04-flow-maly-task.md)) używa skróconego flow: pomija (`/grill-with-docs`, `/to-prd`) i wchodzi od razu w `/code-manager` **Tryb 4A (full plan mode)** — tu manager-first jest canonical bo nie ma PRD do napisania. Manager pisze pełny plan (~150-200 linii) i dispatch-uje do executora. Reszta sekwencji 3-STOP + autonomy gate identyczna jak w large.

| Skala | Entry point | Tryb managera |
|---|---|---|
| 🟢 Bardzo mały | bezpośrednio default agent → impl → commit | n/a (manager pominięty) |
| 🟢/🟡 Mały-średni | `/code-manager` (manager-first) | Tryb 4A full plan |
| 🔴 Large initiative | `/grill-with-docs` → `/to-prd` → `/code-manager` | Tryb 4B bridge |
| Bug | `/diagnose` lub `/code-manager` jeśli formalny flow | Tryb 4A jeśli przez managera |

---

## Per-aktor: kto co aktualizuje

| Artefakt | Tworzy | Aktualizuje (kiedy) | Finalizuje |
|---|---|---|---|
| `CONTEXT.md` | `/grill-with-docs` lub `/repo-onboarding` | grilling kolejnych sesji (gdy nowy termin) | nigdy nie "zamyka się" |
| `doc/decisions/NNNN-*.md` (ADR / PRD) | `/grill-with-docs` lub `/to-prd` | rzadko (gdy decyzja rewidowana) | tylko status w nagłówku |
| `doc/backlog.md` | manual lub `/to-prd` | manager (Tryb 6), kronikarz close, manager session-start (auto-DONE detection) | n/a — żyje cały czas |
| `doc/plans/<branch>.md` | manager (Tryb 4A/4B) | rzadko (zmiana scope w trakcie) | n/a |
| `doc/history/YYYY-MM-DD-<branch>.md` (kronika) | executor (`/kronikarz live` Krok 1) | executor live mode (impl, user QA, fix po review, re-test) | manager (`/kronikarz close`) — sekcja "Manager close" + commit |
| `doc/history/README.md` (indeks) | `/repo-onboarding` lub kronikarz close (jeśli brak) | kronikarz close per branch | n/a |
| `doc/code-reviews/YYYY-MM-DD-<branch>.md` | manager (`/critical-code-review`) | n/a — read-only | n/a |
| `doc/design-reviews/YYYY-MM-DD-<branch>.md` | executor (`/design-checker` po STOP #1, jeśli UI) | n/a — read-only | n/a |

---

## Cztery punkty kontrolne usera

To są **cztery momenty** w pełnym flow gdy bez Twojego "ok" sekwencja się zatrzymuje. Bez nich cały system się rozpada (autonomous reward hacking, brak imposing taste, merge bez user QA).

### STOP #1 — user QA po implementacji

Co robisz: **klikasz, czytasz, dotykasz** rzeczywistego obiektu. Per zasada #26 (imposing taste). Manualny QA pass na scenariuszach które executor podał inline.

Co mówisz:
- ✅ "wszystko ok, zlecaj /critical-code-review" → executor raportuje do managera
- ⚠️ "poprawki: [lista]" → executor fix-uje, kronika update, **ponowny STOP #1**
- ❌ "broken, wracaj do brief" → executor flaguje co odkrył, eskalacja do managera

### STOP #2 — decyzje per-finding po external review

Manager przedstawia findings w **human language** (zasada #4 z manager-values). Per finding decydujesz:
- **FIX** — wymaga naprawy in-branch przed merge
- **BACKLOG** — wartościowe ale nie blokuje merge → wpis do `doc/backlog.md`
- **SKIP** — świadomie odrzucone z templatem (Impact / Koszt / Rationale / Re-evaluate gdy)

### STOP #3 — re-weryfikacja po fix-ach z review

Tylko jeśli były FIX-y. Jeśli wszystko BACKLOG/SKIP — **pomijasz**. Re-testujesz **scenariusze których dotykały zmiany z review**, nie pełny rerun.

### Autonomy gate — "merge?"

Po `/kronikarz close` manager pyta: "Branch X gotowy do merge. OK?" — czekasz na **"akcept"**. Bez tego manager **NIE** mergeuje. Per zasada #28 (crucial decisions wymagają human-in-the-loop) i ADR-0001.

---

## Tabela komend — kiedy która, kto odpala, gdzie output

| Komenda | Kto odpala | Kiedy | Output (gdzie) |
|---|---|---|---|
| `/repo-onboarding` | user (default agent) | nowe repo, brak CLAUDE.md / CONTEXT.md / doc/ | CLAUDE.md, CONTEXT.md, doc/ structure |
| `/grill-with-docs` | user (default agent) | mglisty pomysł / large initiative przed planem | CONTEXT.md (terms), doc/decisions/ (ADR-y) |
| `/to-prd` | user (default agent) | po grillingu, large initiative | doc/decisions/NNNN-*.md (PRD), doc/backlog.md (slices) |
| `/code-manager` | user → manager | start sesji / planowanie / external review / close / merge | doc/plans/ + commits |
| `/kronikarz live` | executor | przed implementacją + per faza pracy | doc/history/YYYY-MM-DD-<branch>.md (no commit) |
| `/kronikarz close` | manager | po raporcie końcowym executora | finalize kronika + doc/backlog.md + doc/history/README.md + git commit |
| `/critical-code-review` | manager | po STOP #1 user QA (Tryb 5A) | doc/code-reviews/YYYY-MM-DD-<branch>.md |
| `/design-checker` | executor | po STOP #1 user QA, **jeśli UI dotknięte** | doc/design-reviews/YYYY-MM-DD-<branch>.md |
| `/tdd` | executor | task wymaga test-first (vertical TDD) | testy + impl |
| `/diagnose` | executor | bug fixing | reproducer + fix + test regresji |
| `/improve-codebase-architecture` | user (default agent) | refactor / deepening modułów | propozycje + ADR jeśli reject |
| `/save-session-manager` | manager | przed `/clear` w trakcie multi-session inicjatywy | doc/session/manager-session.md (gitignored) |
| `/restore-session-manager` | manager | po `/clear` | wczytuje + usuwa plik |
| `/save-session-agent` | executor | przed `/clear` w trakcie multi-slice slica | doc/session/agent-session.md (gitignored) |
| `/restore-session-agent` | executor | po `/clear` | wczytuje + usuwa plik |

---

## Save/restore session — context gap & dump

**Kiedy:** w trakcie multi-slice large initiative kontekst executora rośnie ponad ~100k tokenów (smart zone → dumb zone, zasada #1). Sygnały: powtarzanie tego samego, halucynacje nazw plików, "OK-ish" odpowiedzi zamiast precyzyjnych.

### Procedura dump → gap → restore (executor):

```
1. /save-session-agent     → doc/session/agent-session.md
2. /clear                  → kontekst pusty
3. /restore-session-agent  → wczytuje plik, usuwa go po sukcesie
4. (opcjonalnie) re-read kronika live + plan, żeby załadować świeży kontekst
5. kontynuuj implementację
```

### Procedura dla managera

Analogiczna, ale ze swoim plikiem (`doc/session/manager-session.md`). Manager dumpuje gdy w jednej sesji obsługuje **wiele równoległych worktreeów** i kontekst się zaczyna mieszać.

### Kiedy NIE używać save/restore

- Mały task (Ścieżka A z 04) — flow zmieści się w smart zone
- Brak kontekstu wartego zachowania (pusta sesja) → po prostu `/clear` i re-read plików z dysku
- Per zasada #2 (Memento): dysk jest source of truth — jeśli wszystko ważne jest w plikach, restore nie jest potrzebny

### Worktree per branch

Każdy worktree ma własny `doc/session/` — brak konfliktu między równoległymi sesjami managera/executorów.

---

## Skala → flow per dokument

| Skala | Flow | Document |
|---|---|---|
| 🟢 Bardzo mały (typo, jednoplikowa poprawka) | Default agent → impl → commit | [04 Ścieżka A](./04-flow-maly-task.md#ścieżka-a--bardzo-mały-task-typo-jednoplikowa-poprawka) |
| 🟢/🟡 Mały-średni | Manager Tryb 4A → 3 STOP-y → close → merge | [04 Ścieżka B](./04-flow-maly-task.md#ścieżka-b--mały-ale-nietrywialny-task-przez-code-manager) |
| 🔴 Duża inicjatywa | Grill → PRD → Manager Tryb 4B per slice → 3 STOP-y per slice → close per slice → merge per slice | [05](./05-flow-duza-inicjatywa.md) |
| Bug | Diagnose loop → fix → test regresji → (opcjonalnie) Manager 3 STOP-y | [06](./06-flow-bug.md) |

---

## Anti-patterny w komunikacji

- **Manager pisze do executora bezpośrednio** (bez user mediacji) — łamie autonomy gate, brak imposing taste
- **Executor odpala `/critical-code-review`** — peer review principle złamany (Sonnet review-uje Sonnet, confirmation bias). Per zasada #25 — Opus reviewuje pracę Sonneta
- **Pomijanie STOP #1** — kod idzie do review zanim user zweryfikował user-facing behavior. Zasada #26 (imposing taste) pominięta. "Po co reviewować coś co nie działa?"
- **Manager mergeuje bez user "akcept"** — autonomy gate złamany. Per ADR-0001 → zawsze human-in-the-loop dla irreversible action
- **Kronika tylko w trybie close** — executor nie odpala `/kronikarz live` per faza, manager wpada na zamykanie pustej kroniki, brakuje rozumowania per decyzję
- **`/grill-with-docs` pominięty przy 🔴 large initiative** — eager planning bez grillingu, zasada #5 złamana → plan nie wytrzyma kontaktu z rzeczywistością
- **`/design-checker` pominięty przy zmianach UI** — design tokens drift po fakcie, niespójność wizualna w bazie kodu
- **Multi-slice work bez save/restore** — wpadasz w dumb zone w środku slica 4 z 7, halucynacje, kosztowne błędy
- **Raport bez konkretów** — "wszystko działa" zamiast "test 1, 2, 3 ✅, manualny smoke pass na X" → manager nie ma czego review-ować

---

## Dalej

Jeśli pierwszy raz: czytaj sekwencyjnie [01-fundamenty.md](./01-fundamenty.md) → [02-zasady-metodologii.md](./02-zasady-metodologii.md) → [03-konwencje.md](./03-konwencje.md), potem **wracaj tutaj** dla pełnego obrazu choreografii.

Jeśli jesteś agentem wykonawczym — zobacz [04a-rola-agenta-wykonawczego.md](./04a-rola-agenta-wykonawczego.md), counterpart `code-manager/SKILL.md` z perspektywy executora.
