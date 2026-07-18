---
name: critical-prd-review
description: 'Krytyczny audyt Product Requirements Document przed implementacją, działający jak critical code review wykonane przed napisaniem kodu. Używaj po sesji grill/to-prd, gdy użytkownik wkleja PRD, prosi o review/audyt PRD, chce znaleźć luki techniczne, produktowe, testowe, bezpieczeństwa, skalowania lub architektoniczne przed rozbiciem na taski, albo chce feedback do agenta, który stworzył PRD po grillowaniu. Obsługuje też kolejne rewizje (delta-audyt poprawionego PRD). Szczególny nacisk: security by design, scalability by design, prostota architektury i standard produkcyjny systemów działających pod realnym obciążeniem.'
---

# Critical PRD Review

Audytuj PRD jak wymagający reviewer techniczno-produktowy wykonujący critical code review zanim powstanie kod. Celem nie jest przepisanie dokumentu, tylko znalezienie luk, ryzyk, niejawnych założeń i brakujących decyzji, które agent autora PRD ma poprawić w kolejnej iteracji.

Traktuj wynik jako feedback do wklejenia agentowi, który stworzył PRD. Auditor poproszony o szukanie luk zawsze jakieś znajdzie — Twoja wartość polega na trafnym rozdzieleniu luk, które realnie zepsują implementację, od doprecyzowań, które mogą poczekać.

## Tryb — pierwsza rewizja czy delta?

- **Pierwszy audyt tego PRD → tryb FULL:** pełna procedura, wszystkie soczewki, Pre-Code Checklist.
- **W rozmowie lub na dysku istnieje poprzedni feedback / poprawiona wersja → tryb DELTA:** audytuj tylko (a) sekcje zmienione od poprzedniej rewizji, (b) wcześniej otwarte uwagi — rozwiązane czy nadal otwarte, (c) nowe luki wprowadzone przez poprawki. Nie powtarzaj pełnego 12-soczewkowego przebiegu nad sekcjami, które nie zmieniły się od rewizji, którą już audytowałeś — to regeneruje ten sam raport za wielokrotny koszt i skłania do wymyślania nowych uwag tam, gdzie praca jest skończona.

## Standard Audytu

Audytuj dokument tak, jakby opisywany system miał działać w realnej produkcji: realni użytkownicy, dane warte ochrony, kosztowne awarie, rosnące obciążenie i dług techniczny, który szybko się kapitalizuje.

Ten standard nie oznacza mnożenia technologii, procesów i abstrakcji. Preferuj najprostsze eleganckie rozwiązanie, które spełnia wysokie wymagania bezpieczeństwa, skalowalności, operacyjności i utrzymania. Odróżniaj brakujący profesjonalny fundament od nadmiarowej złożoności.

Priorytety audytu:

1. **Security by design**: least privilege, secure defaults, jasny model uprawnień, ochrona danych, threat model, abuse cases, brak sekretów i przypadkowych wycieków.
2. **Scalability by design**: znany profil obciążenia, limity, backpressure, concurrency, idempotencja, koszty, degradacja jakości zamiast awarii kaskadowej.
3. **Simple, deep architecture**: mało ruchomych części, głębokie moduły, proste kontrakty, brak płytkich wrapperów i przedwczesnej platformizacji.
4. **Operational excellence**: observability, rollback, migracje, feature flags tam, gdzie potrzebne, jasna odpowiedzialność za incydenty.
5. **Product clarity**: PRD ma ograniczać zgadywanie przy implementacji, a nie przenosić decyzje na później.

Zanim zaczniesz oceniać, rozumiej. PRD, które wygląda zbyt ogólnie, może opierać się na konwencjach repo albo ustaleniach z `CONTEXT.md`; PRD, które wygląda prosto, może ukrywać ryzyko security, danych lub skalowania. Twoim zadaniem jest odróżnić realną lukę od świadomego uproszczenia.

## Wejście

- Jeśli użytkownik wkleił PRD, audytuj ten tekst.
- Jeśli podał plik lub link lokalny, przeczytaj go przed audytem.
- Jeśli PRD nie ma w kontekście, poproś krótko o wklejenie PRD.
- Jeśli PRD zawiera sekcję świadomych trade-offów / zaakceptowanych kompromisów albo poprzednia rewizja zawiera uwagi jawnie zaakceptowane przez użytkownika jako known-gap — te rozstrzygnięcia **nie podlegają ponownemu zgłaszaniu**. Możesz je zakwestionować tylko z NOWYM faktem, którego decyzja nie uwzględniała.

## Kontekst Repo

Jeśli PRD dotyczy konkretnego repozytorium, sprawdź lokalny kontekst tam, gdzie to zwiększa trafność audytu:

- `CLAUDE.md` lub podobne instrukcje projektowe dla stacku, konwencji, znanych pułapek i decyzji jakościowych.
- `CONTEXT.md` / `CONTEXT-MAP.md` dla języka domeny i granic kontekstów.
- `doc/decisions/`, `docs/adr/` lub podobne katalogi dla utrwalonych decyzji.
- Kod, testy i istniejące moduły, gdy PRD opisuje zachowanie, integrację albo zmianę architektury, którą można zweryfikować.

Nie zatrzymuj audytu na pytaniach, jeśli luka może zostać zweryfikowana przez eksplorację kodu. Jeżeli nie masz dostępu do repo lub nie da się czegoś sprawdzić szybko, oznacz to jako „do weryfikacji w repo".

## Triage Ryzyka

Najpierw określ powierzchnię ryzyka PRD. Dla dużych dokumentów nie próbuj równomiernie komentować wszystkiego; priorytetyzuj obszary, które później w critical code review najczęściej blokują merge:

- autentykacja, autoryzacja, role, uprawnienia i granice tenantów,
- mutacje danych, migracje, import/export, usuwanie, synchronizacja,
- API, edge/backend functions, webhooks, kolejki, integracje zewnętrzne,
- płatności, billing, limity planów, operacje kosztotwórcze,
- uploady, pliki, transkrypcje, user-generated content, dane wrażliwe,
- listy i wyszukiwanie rosnące z danymi użytkowników,
- long-running jobs, retry, concurrency, cache, offline/sync,
- zależności od nowych bibliotek, vendorów lub usług.

Jeśli PRD dotyka któregoś z tych obszarów, brak decyzji o walidacji, limitach, timeouts, retry, idempotencji, uprawnieniach lub observability traktuj jako poważną lukę, a nie kosmetykę.

**Jedno ryzyko = jedna uwaga.** Triage, Soczewki i Pre-Code Checklist celowo nakładają się (triage mówi *gdzie patrzeć najpierw*, soczewki *co sprawdzać*, checklist *co blokuje*). Ten sam brak — np. unbounded query — zgłoś raz, pod najbardziej konkretnym nagłówkiem. Nie produkuj uwagi pod każdym z trzech nagłówków na siłę.

## Standard Dowodowy

Każda uwaga BLOCKER lub MAJOR musi być zakotwiczona w konkretnym powodzie. Wskaż, czy wynika z:

- konkretnego fragmentu PRD,
- braku konkretnej sekcji, decyzji, scenariusza lub acceptance criteria,
- sprzeczności z kontekstem repo, `CONTEXT.md`, ADR-em albo istniejącym kodem,
- standardowego ryzyka produkcyjnego, którego PRD nie adresuje,
- pytania decyzyjnego, którego nie da się rozstrzygnąć bez autora lub użytkownika.

Nie raportuj abstrakcyjnych obaw bez pokazania, jak wpłyną na implementację, bezpieczeństwo, skalowanie, testy albo operacje.

## Procedura Audytu (tryb FULL)

1. Ustal, jaki problem, użytkownik, zakres i stan docelowy deklaruje PRD.
2. Sprawdź kompletność sekcji oczekiwanych po `to-prd` (lub odpowiedniku szablonu PRD używanego przez zespół): Problem, Rozwiązanie, User Stories, Decyzje implementacyjne, Decyzje testowe, Out of scope, Dodatkowe uwagi.
3. Porównaj język PRD z językiem domenowym. Wyłap terminy rozmyte, wieloznaczne lub sprzeczne z `CONTEXT.md`.
4. Stress-testuj wymagania przez konkretne scenariusze: normalny happy path, edge case, błąd zewnętrznej zależności, powtórzenie operacji, stan pusty, brak uprawnień, atak/nadużycie, częściowe powodzenie, skok obciążenia, rollback.
5. Oceń, czy dokument daje agentowi implementującemu wystarczająco jasne decyzje, żeby nie musiał zgadywać.
6. Oceń, czy PRD może zostać bezpiecznie rozbite na taski bez utraty kontekstu.
7. Oceń, czy proponowane rozwiązanie jest najprostszym sensownym rozwiązaniem spełniającym wymagany poziom bezpieczeństwa i skalowania.
8. Zadaj pytanie: „Czy późniejsze critical code review odrzuciłoby implementację, jeśli agent zbuduje dokładnie to, co opisuje PRD?". Jeśli tak, wskaż brakującą decyzję już teraz.

W trybie DELTA wykonuj tylko kroki adekwatne do zmienionych sekcji + weryfikację statusu poprzednich uwag.

## Soczewki Audytu

Sprawdź PRD przez poniższe soczewki. Nie wymuszaj sztucznych uwag, ale jeśli obszar jest istotny i pominięty, nazwij lukę wprost.

- **Bezpieczeństwo i prywatność**: threat model, abuse cases, autentykacja, autoryzacja, least privilege, izolacja tenantów, PII, sekrety, retencja danych, audytowalność.
- **Skalowalność i odporność**: profil obciążenia, limity, concurrency, idempotencja, kolejki, backpressure, cache invalidation, degradacja, retry, timeouty, koszty.
- **Prostota i elegancja rozwiązania**: najmniejsza liczba komponentów, proste kontrakty, głębokie moduły; brak nadmiarowej infrastruktury i płytkich abstrakcji.
- **Problem i wartość użytkownika**: aktorzy, ból, motywacja, kryteria sukcesu, mierzalny efekt, priorytet.
- **Zakres i granice**: co jest w scope, out of scope, zależności, kolejność etapów, definicja „done".
- **User stories i scenariusze**: kompletność aktorów, alternatywne ścieżki, błędy, stany puste, uprawnienia, powtarzalność operacji.
- **Język domeny**: zgodność z `CONTEXT.md`, nazwy pojęć, rozdzielenie podobnych terminów.
- **Architektura i moduły**: odpowiedzialności, interfejsy, granice, deep modules, sprzężenie, kompatybilność z istniejącym systemem.
- **Dane i kontrakty**: modele danych, migracje, API, walidacja, idempotencja, spójność transakcyjna, kompatybilność wsteczna.
- **Integracje i zależności zewnętrzne**: awarie, timeouty, retry, rate limits, autoryzacja, wersjonowanie kontraktów.
- **UX i zachowanie produktu**: wejście/wyjście z flow, komunikaty błędów, loading, empty state, dostępność.
- **Reliability, performance, observability**: opóźnienia, concurrency, limity, monitoring, logi, metryki, alerty, rollback.
- **Testy**: poziomy testów, moduły do testowania, fixtures, regresje, prior art w repo, acceptance criteria, czego nie testować.
- **Rollout i operacje**: feature flagi, migracje, plan wdrożenia, plan wycofania, komunikacja, cleanup.

## Pre-Code Review Checklist

Traktuj poniższe punkty jak wzorce, które critical code review zwykle blokuje po fakcie. W PRD powinny być rozstrzygnięte na poziomie wymagań, decyzji implementacyjnych lub decyzji testowych, jeśli dotyczą funkcji.

### Security hard gates

- **Frontend-only validation**: PRD nie może opierać bezpieczeństwa ani integralności danych wyłącznie na kliencie. Wymagaj walidacji na granicy backendu/API/edge.
- **Sensitive logic in client**: autoryzacja, sekrety, cenniki, limity planów i operacje uprzywilejowane poza klientem.
- **Custom auth without reason**: własna autentykacja/autoryzacja wymaga uzasadnienia lub sprawdzonej biblioteki/usługi.
- **Missing rate limits**: endpointy auth, upload, AI, payment, resource-intensive i publiczne muszą mieć opisane ograniczenia requestów i kosztów.
- **Unbounded input**: każde user input, payload, plik, prompt, import i query musi mieć walidację schematu oraz limity rozmiaru/długości.
- **Secrets handling**: PRD musi określać, gdzie żyją sekrety i które komponenty mogą ich używać.
- **Authorization model**: kto może wykonać operację, na jakim zasobie, w jakim stanie, jak egzekwowane są granice tenantów/ownership.
- **Auditability**: operacje o wysokim wpływie zostawiają ślad audytowy: kto, co, kiedy, z jakiego kontekstu.

### Scalability and reliability hard gates

- **Unbounded queries**: żadnego listowania danych bez limitów, paginacji lub cursora; server-side max limit dla endpointów listujących.
- **N+1 and application-side filtering**: filtrowanie i agregacja po stronie właściwego store/query layer.
- **Missing timeouts**: zewnętrzne API, AI calls, długie query i jobs — timeout, retry policy, zachowanie po częściowej awarii.
- **Idempotency**: webhooki, retry, płatności, importy, jobs — strategia idempotencji.
- **Backpressure and queues**: praca długa lub kosztowna — synchroniczność vs async job, kolejki, limity równoległości, cancelation.
- **Resource cleanup**: cleanup plików, jobów, cache, tymczasowych rekordów i subskrypcji.
- **Observability**: minimalne logi, metryki i sygnały błędów potrzebne do debugowania produkcji.

### Architecture and maintainability hard gates

- **Needless new dependency**: nowa biblioteka/usługa wymaga uzasadnienia względem stdlib, istniejących zależności lub prostszej implementacji.
- **Shallow modules**: PRD nie powinno prowadzić do płytkich wrapperów ani rozproszonej logiki.
- **Breaking contracts**: każda zmiana API, modelu danych, eventu, typu publicznego musi być nazwana jako breaking/non-breaking.
- **Untestable design**: jeśli PRD nie pozwala testować zewnętrznego zachowania bez kruchego mockowania szczegółów implementacji, wskaż to jako lukę projektową.

## Skala Istotności

Oznacz każdą uwagę jedną z etykiet:

- **BLOCKER**: PRD nie powinno iść do implementacji; brakuje decyzji, bez której agent będzie zgadywać albo może zbudować zły system.
- **MAJOR**: istotna luka zwiększająca ryzyko błędu, regresji, długu architektonicznego lub niepełnej implementacji.
- **MINOR**: doprecyzowanie, które poprawi jakość dokumentu, ale nie blokuje dalszej pracy.
- **QUESTION**: pytanie decyzyjne, którego nie da się rozstrzygnąć z dokumentu ani repo.

Brak modelu bezpieczeństwa przy danych użytkownika, uprawnieniach, integracjach, płatnościach, sekretach lub tenantach traktuj jako BLOCKER — **ale rozróżnij dwa przypadki**: PRD, które *milczy* o modelu bezpieczeństwa, to BLOCKER; PRD, które *jawnie deleguje* bezpieczeństwo do istniejących konwencji repo, ADR-a lub przetestowanego wzorca („auth jak w pozostałych endpointach, RLS wg ADR-0007"), nie jest BLOCKER-em — co najwyżej QUESTION, jeśli delegacja budzi konkretną wątpliwość. Analogicznie dla modelu skalowania.

Nie używaj łagodnych sformułowań typu „warto rozważyć", jeśli brak jest realnym ryzykiem. Napisz, co konkretnie trzeba dodać do PRD.

Mapuj mentalnie severity jak w critical code review: późniejsze CRITICAL w kodzie = teraz zwykle BLOCKER; HIGH = BLOCKER albo MAJOR; MEDIUM = MAJOR albo MINOR.

**Stabilność severity między rewizjami:** uwaga zgłoszona jako MINOR w rev N nie awansuje na MAJOR w rev N+1, jeśli nie pojawił się nowy fakt. Eskalacja severity po to, żeby wymusić kolejną rundę, to anty-wzorzec.

## Kiedy przestać iterować

Pętla rewizji ma warunki zakończenia — audyt bez nich generuje rundy w nieskończoność, bo zawsze da się znaleźć kolejne doprecyzowanie:

1. **Tylko BLOCKER i MAJOR wymuszają kolejną rewizję.** MINOR i QUESTION nie uzasadniają rundy — trafiają do werdyktu Almost ready z listą do decyzji użytkownika (dopisać / zaakceptować jako świadomy known-gap).
2. **Od rev2: jeśli zostały wyłącznie MINOR/QUESTION → werdykt Almost ready i zwróć decyzję użytkownikowi** zamiast domagać się kolejnej iteracji dokumentu.
3. **Po ~3 rewizjach bez werdyktu Ready** zasygnalizuj wprost: „diminishing returns — pozostałe uwagi wymagają decyzji użytkownika, nie kolejnej rundy audytu". Brak konwergencji to zwykle sygnał, że PRD próbuje rozstrzygnąć za dużo naraz (kandydat do splitu), nie że audyt ma być głębszy.
4. **Nie zgłaszaj ponownie** uwag zaakceptowanych przez użytkownika jako known-gap ani rozstrzygniętych trade-offów (patrz Wejście).

## Format Odpowiedzi

Zwróć feedback w tym układzie:

```markdown
**Werdykt**
Needs revision | Almost ready | Ready

Krótki powód werdyktu w 1-3 zdaniach.

**Feedback Do Agenta**
1. [BLOCKER] Tytuł luki
   Dowód:
   Co jest niejasne lub błędne:
   Dlaczego to ryzyko:
   Jak później objawi się w implementacji:
   Co dopisać do PRD:

2. [MINOR] Tytuł
   Dowód:
   Co dopisać do PRD:

**Pytania Decyzyjne**
1. Pytanie, które agent powinien rozstrzygnąć z użytkownikiem lub repo.

**Uwagi O Iteracji** (tylko w trybie DELTA)
- Rozwiązane od poprzedniej wersji: ...
- Nadal otwarte: ...
- Nowe luki (wprowadzone przez poprawki): ...
```

Pełny 5-polowy szablon stosuj do **BLOCKER i MAJOR** — pole „Jak później objawi się w implementacji" tłumaczy abstrakcyjne ryzyko na obserwowalny skutek i jest kluczowe dla decyzji nietechnicznego właściciela produktu. **MINOR i QUESTION dostają 2 pola** (Dowód + Co dopisać do PRD) — pełny narzut opisowy na drobiazgach rozmywa uwagę od tego, co naprawdę blokuje.

Sekcję „Pytania Decyzyjne" pomiń, jeśli nie ma pytań.

## Zapis raportu

Jeśli projekt utrzymuje `doc/code-reviews/` — prowadź **jeden plik per PRD**: `doc/code-reviews/YYYY-MM-DD-prd-<slug>.md` (data pierwszej rewizji). Pierwsza rewizja tworzy plik, każda kolejna dopisuje sekcję `## Rev N — YYYY-MM-DD` z werdyktem i uwagami. Nie twórz osobnego pliku per rewizja — rozproszone pliki rev1..revN to w większości superseded stan pośredni, a audit trail zmian PRD i tak żyje w git history `prd.md` (commity „PRD <slug> rev N — K fixów"). Jeśli projekt nie ma tej struktury, output pozostaje inline.

## Kryterium Ready

Werdykt **Ready** dawaj tylko wtedy, gdy:

- nie ma uwag BLOCKER ani MAJOR,
- bezpieczeństwo, prywatność i uprawnienia są opisane (lub jawnie delegowane) na poziomie adekwatnym do ryzyka,
- skalowalność, limity i zachowanie pod obciążeniem są opisane na poziomie adekwatnym do ryzyka,
- wybrane rozwiązanie jest możliwie proste bez rezygnacji z wymaganego poziomu bezpieczeństwa i niezawodności,
- późniejsze critical code review nie musiałoby blokować implementacji z powodów przewidywalnych już na poziomie PRD,
- decyzje implementacyjne są wystarczające do rozbicia na taski,
- decyzje testowe pokrywają ryzykowne zachowania,
- out of scope realnie chroni przed rozszerzaniem zakresu,
- nie ma ukrytych założeń, które zmienią architekturę lub user experience po starcie implementacji.

Jeśli PRD jest solidne, ale wymaga kilku doprecyzowań, użyj **Almost ready**. Jeśli brakuje istotnych decyzji, użyj **Needs revision**. Pierwsza rewizja z werdyktem Ready jest rzadka, ale możliwa — nie obniżaj werdyktu tylko dlatego, że to pierwszy przebieg; werdykt wynika z findingów, nie z numeru rundy.

## Czego Nie Robić

- Nie przepisuj całego PRD, chyba że użytkownik o to poprosi.
- Nie twórz nowych decyzji produktowych w miejsce autora; wskazuj brak i proponuj opcje tylko wtedy, gdy pomagają podjąć decyzję.
- Nie chwal długo dokumentu. Jeśli coś działa dobrze, wspomnij krótko po werdykcie albo pomiń.
- Nie kończ na ogólnikach. Każda uwaga ma prowadzić do konkretnej zmiany w PRD.
- Nie przepuszczaj luk tylko dlatego, że „agent implementujący sobie poradzi".
- Nie relityguj zaakceptowanych kompromisów i nie eskaluj severity między rewizjami bez nowego faktu.
