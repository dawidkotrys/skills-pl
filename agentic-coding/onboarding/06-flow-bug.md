# 06. Flow: bug

Coś działa źle. Test failuje, klient zgłosił, regresja w produkcji, mysterious behavior na staging. Ten flow jest osobny od "mały task" / "duża inicjatywa", bo bug ma swoją specyfikę: **najpierw zrozum, potem fixuj**.

## Charakterystyka

- Reprodukcja **NIE** jest oczywista (gdyby była — fix też byłby trywialny)
- Ryzyko że "fix" maskuje prawdziwy problem (treat symptom, not cause)
- Może wymagać **głębokiej** instrumentacji żeby zrozumieć
- Często wymaga **building feedback loop FIRST** (zasada #22)

---

## Flow `/diagnose`

```
1. Reprodukcja                  →  zrób żeby bug się odpalał deterministycznie
2. Minimalizacja                →  zredukuj input do najmniejszego który triggeruje bug
3. Build feedback loop FIRST    →  zasada #22 — fast, deterministic test/scenario
4. Hipotezy                     →  co MOGŁO to spowodować? lista możliwości
5. Instrumentacja               →  loggery / breakpointy / asserts żeby weryfikować hipotezy
6. Test hipotez                 →  weryfikujesz każdą za pomocą feedback loopu
7. Fix                          →  najmniejsza zmiana która usuwa root cause
8. Test regresji                →  test który złapie ponowne pojawienie się buga w przyszłości
9. Dokumentacja                 →  /kronikarz live — co było, root cause, fix, test regresji
```

Skill `/diagnose` prowadzi przez ten flow.

**Jeśli używasz `/code-manager`** dla bug-fixa (Ścieżka B per [04-flow-maly-task.md](./04-flow-maly-task.md)) — po Kroku 9 wchodzi pełna sekwencja 3-STOP: user QA fix-a → external review przez Managera → re-test → kronikarz close + autonomy gate. Standalone `/diagnose` (bez Managera) = krótszy flow zakończony commit + push.

---

## Krok 1 — Reprodukcja

**Bug który nie reprodukuje się deterministycznie nie jest jeszcze bugiem — jest zgłoszeniem.**

Cel: ustal **dokładne kroki** które wywołują problem. Nie "czasem nie działa" — "kliknij A, wpisz B, wciśnij Enter, error w konsoli X".

### Strategie reprodukcji

- **Production logs** — szukaj wzorca, kiedy się wywaliło, jakie dane
- **Replay user session** — jeśli masz session replay (Sentry, FullStory)
- **Pytaj usera** — co dokładnie zrobiłeś? jaki browser? jaki user account?
- **Brute force** — testuj typowe edge case'y (null, empty, very long, special chars, concurrent)

### Sygnały że reprodukcja **NIE JEST** deterministyczna

- "To się dzieje raz na 10 prób" → race condition / timing dependency
- "Tylko po pełnej sesji 30 minut" → state accumulation / memory leak
- "Tylko na tym koncie usera" → data-specific (uszkodzony record, edge case w danych)

W tych przypadkach **najpierw** zrób reprodukcję deterministyczną. Bez tego cały flow się rozpada.

---

## Krok 2 — Minimalizacja

Jak masz reprodukcję, **redukuj** input do najmniejszego który triggeruje bug:

- Usuwaj pola z requesta po jednym → czy bug nadal jest?
- Skracaj string → kiedy bug znika?
- Redukuj testową bazę danych → minimalny dataset

Po minimalizacji: masz **canonical reproducer**. Coś jak unit test który failuje. To jest twój feedback loop (krok 3).

---

## Krok 3 — Build feedback loop FIRST (zasada #22)

**Najważniejszy krok**. 90% buga jest **fixed** kiedy masz solidny feedback loop.

Loop powinien być:

- **Fast** — sekundy, nie minuty. Jeśli twój reproducer trwa 60s, najpierw zrób żeby trwał 1s (zasada #23 — iterate na samym feedback loop)
- **Deterministic** — leci za każdym razem tak samo. Brak flakiness.
- **Local** — leci u ciebie, nie wymaga staging environment / external service. Mock / fixture jeśli trzeba.
- **Targeted** — testuje **dokładnie** ten bug, nie cały system

Forma loopa:

- Unit test który failuje
- Mały skrypt który deterministycznie wywoła błąd
- Manual click sequence z observable expectation

**Bez fast feedback loopa** — debugging staje się gambling.

---

## Krok 4 — Hipotezy

Wypisz **wszystkie** możliwe przyczyny które przychodzą do głowy. **Nie filtruj** na tym etapie — głupie hipotezy też zapisz.

Format:

```
H1: Ordering nie commitsuje transakcji przed wysłaniem event'a → race condition w Billing
H2: Customer.id ma nieoczekiwany format (UUID vs int) i fail w parse'ie
H3: Cache TTL jest za długi i serwujemy stary state
H4: Frontend retryuje request gdy network slow → duplicate write
H5: ...
```

Po wypisaniu — **rank** według prawdopodobieństwa. Najbardziej prawdopodobne pierwsze.

---

## Krok 5-6 — Instrumentacja + Test hipotez

Per hipoteza:

- **Co byłoby dowodem na prawdę?** Jaki output / state / sequence by potwierdził?
- **Co byłoby dowodem na fałsz?** Jaki output by wykluczył?

Następnie: **instrumentuj** żeby zobaczyć dane.

- Loggery z timestamps
- Asserty na invariants ("ten stan **nie powinien** być możliwy")
- Breakpointy (jeśli debugger dostępny)
- Network traces / DB query logs

Odpalasz feedback loop → patrzysz na output → potwierdzasz / wykluczasz hipotezę. Jeśli hipoteza odpada — wracasz do listy. Jeśli się potwierdza — masz **root cause**.

### Anty-wzorzec — fix bez root cause

Pokusą jest "wpisać try/catch żeby błąd zniknął". To jest **maskowanie symptomu**. Bug nadal jest. Pojawi się w innej formie. Per zasada #16 — bad codebase = bad agent output, takie maskowanie psuje jakość codebase.

**Zawsze** root cause przed fixem.

---

## Krok 7 — Fix

**Najmniejsza** zmiana która usuwa **root cause** (nie symptom).

Zasada: po fixie powinieneś być w stanie wyjaśnić "dlaczego ten bug już nie wystąpi" w 1-2 zdaniach. Jeśli wyjaśnienie wymaga 3 paragrafów warunków — fix nie jest na root cause.

---

## Krok 8 — Test regresji

**Zawsze**. Bez testu regresji bug może wrócić w ciągu tygodni i nikt nie zauważy.

Test powinien:

- Reprodukować dokładnie ten scenariusz który był w canonical reproducer
- Failować przed fixem, przechodzić po fixie
- Być wystarczająco specyficzny żeby ochronić przed nawrotem **dokładnie tego buga**, ale nie tak specyficzny żeby breakować przy każdym refactorze (zasada #21 — test behavior, nie implementation)

---

## Krok 9 — Dokumentacja (`/kronikarz`)

Dla nietrywialnego buga:

- Wpis w `CHANGELOG.md` (jeśli zauważalne dla usera)
- Update `doc/backlog.md` (przerzuć do "Ukończone")
- (rzadko) ADR — jeśli bug ujawnił architectural assumption violation i fix jest hard-to-reverse

Format wpisu w changelog:

```
- Fix: empty cart no longer breaks checkout (#123)
```

Format wpisu w `_session-state.md` (jeśli bug fix jest multi-session):

```
## Bug: empty cart breaks checkout

- Reproducer: src/checkout/cart.test.ts:42 (skipped, will un-skip after fix)
- Root cause: getCart() returns null when no items, but checkout assumes empty array
- Fix candidate: Cart.empty() factory zwraca [], nie null
- Test regresji: testEmptyCartCheckoutFlow
```

---

## Anty-wzorce

### Skipping reprodukcji

"Wiem co to jest, lecę z fixem". Często **nie wiesz** — twoja hipoteza jest jedną z wielu. Fix bez reprodukcji = gambling.

### Skipping building feedback loop FIRST

"Mam reproducer, lecę z hipotezami". Jeśli reproducer trwa 60s, każda hipoteza kosztuje 60s. Jeśli trwa 1s, możesz przetestować 30 hipotez w czasie jednej z poprzedniej wersji.

### Maskowanie symptomu

`try/catch`, `if (x === null) return`, `setTimeout` żeby wyglądało że nie ma race condition. Bug nadal jest. Wraca w innej formie. Często **gorszej**.

### Brak testu regresji

"Fix działa, mergujemy". Bez testu regresji bug wraca w ciągu tygodni. Test regresji jest **częścią** fixu, nie opcją.

### Fix wewnątrz produkcji bez reprodukcji lokalnie

"Dodam logger w prod, zobaczę". Czasem zasadne (problem widoczny tylko w prod scale), ale: zawsze próbuj reprodukować lokalnie najpierw. Prod logging jest ostatecznością.

### Treating symptom + cause jako to samo

Czasem fix wymaga **i** maskowania symptomu (ochrona usera od crashy w produkcji **teraz**) **i** root cause (prawdziwy fix). Jeśli tak — zrób oba, ale wyraźnie nazwij które jest które:

```
- HOTFIX: catch null cart, return empty array (mask symptom, deploy ASAP)
- ROOT FIX: Cart.empty() factory, propagate through type system (PR #124, ETA tomorrow)
```
