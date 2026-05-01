---
name: diagnose
description: Zdyscyplinowana pętla diagnostyczna dla trudnych bugów i regresji wydajnościowych. Reprodukcja → Minimalizacja → Hipotezy → Instrumentacja → Fix → Test regresji. Triggeruj na "diagnose", "debug", "zdiagnozuj", "broken", "throwing", "failing", "regression", "nie działa", "spadek wydajności".
---

# Diagnose

Dyscyplina dla trudnych bugów. Pomijaj fazy tylko z explicit uzasadnieniem.

W trakcie eksploracji kodu używaj słownika domeny (`CONTEXT.md`), żeby mieć jasny model mentalny relevantnych modułów, oraz sprawdź ADR-y w `doc/decisions/` (lub `docs/adr/`) w obszarach których dotykasz.

## Faza 1 — Zbuduj pętlę feedbacku

**TO JEST ten skill.** Wszystko inne jest mechaniczne. Jeśli masz **szybki, deterministyczny, agentowo-uruchamialny** sygnał pass/fail dla bugu — znajdziesz przyczynę. Bisekcja, testowanie hipotez i instrumentacja po prostu konsumują ten sygnał. Jeśli go nie masz — żadne wpatrywanie się w kod Cię nie uratuje.

Inwestuj nieproporcjonalny wysiłek **właśnie tutaj**. **Bądź agresywny. Bądź kreatywny. Nie poddawaj się.**

### Sposoby zbudowania pętli — wypróbuj w mniej-więcej tej kolejności

1. **Padający test** w jakimkolwiek seam, który dosięga buga — unit, integration, e2e.
2. **Curl / HTTP script** przeciwko działającemu dev serverowi.
3. **Wywołanie CLI** z fixture'em, diff stdout względem znanego dobrego snapshotu.
4. **Headless browser script** (Playwright / Puppeteer) — driver UI, asercje na DOM/console/network.
5. **Replay zapisanego trace'u.** Zapisz prawdziwy network request / payload / event log na dysk, replay go przez ścieżkę kodu w izolacji.
6. **Throwaway harness.** Spin up minimalny subset systemu (jeden serwis, mocked deps) który ćwiczy ścieżkę kodu buga jednym wywołaniem funkcji.
7. **Property / fuzz loop.** Jeśli bug to "czasem zły output" — odpal 1000 losowych inputów i szukaj failure mode.
8. **Bisection harness.** Jeśli bug pojawił się między dwoma znanymi stanami (commit, dataset, wersja), zautomatyzuj "boot at state X, check, repeat" tak żebyś mógł `git bisect run`.
9. **Differential loop.** Puść ten sam input przez starą-wersję vs nową-wersję (lub dwie konfiguracje) i diffuj outputy.
10. **HITL bash script.** Ostatnia deska ratunku. Jeśli człowiek MUSI klikać — driver _jego_ przez `scripts/hitl-loop.template.sh` żeby pętla była strukturalna. Captured output wraca do Ciebie.

Zbuduj właściwą pętlę feedbacku, a bug jest w 90% naprawiony.

### Iteruj na samej pętli

Traktuj pętlę jak produkt. Gdy masz _jakąkolwiek_ pętlę, zadaj:

- Czy mogę zrobić ją szybszą? (Cache setup, skip nierelevantnego inita, zawęź scope testu.)
- Czy mogę zrobić sygnał ostrzejszym? (Asercja na konkretny symptom, nie na "nie wybuchło".)
- Czy mogę zrobić ją bardziej deterministyczną? (Pin time, seed RNG, isolate filesystem, freeze network.)

30-sekundowa flaky pętla jest ledwie lepsza od żadnej. 2-sekundowa deterministyczna pętla = debuggingowa supermoc.

### Bugi non-deterministyczne

Cel to nie czysta reprodukcja, tylko **wyższy reproduction rate**. Loop trigger 100×, parallelize, dodaj stress, zawęź timing windows, inject sleeps. Bug 50%-flake jest debuggable; 1% nie jest — podnoś rate dopóki nie stanie się debuggable.

### Gdy genuinely nie umiesz zbudować pętli

Zatrzymaj się i powiedz to wprost. Wymień co próbowałeś. Zapytaj usera o: (a) dostęp do środowiska gdzie się reprodukuje, (b) zapisany artifact (HAR, log dump, core dump, screen recording z timestampami), albo (c) pozwolenie na dodanie tymczasowej production instrumentacji. **Nie** przechodź do hipotez bez pętli.

Nie przechodź do Fazy 2 dopóki nie masz pętli, w którą wierzysz.

## Faza 2 — Reprodukcja

Uruchom pętlę. Patrz jak bug się pojawia.

Potwierdź:

- [ ] Pętla produkuje dokładnie ten failure mode, który **user** opisał — nie inny failure który dzieje się obok. Zły bug = zły fix.
- [ ] Failure jest reprodukowalny przez wiele uruchomień (lub, dla bugów non-deterministycznych, reprodukowalny w wystarczająco wysokim rate żeby debuggować).
- [ ] Uchwyciłeś dokładny symptom (error message, zły output, slow timing) tak żeby później fazy mogły zweryfikować, że fix faktycznie go adresuje.

Nie przechodź dalej dopóki nie zreprodukujesz buga.

## Faza 3 — Hipotezy

Wygeneruj **3-5 rankingowanych hipotez** PRZED testowaniem którejkolwiek. Generowanie pojedynczej hipotezy zakotwicza Cię w pierwszym sensownym pomyśle.

Każda hipoteza musi być **falsyfikowalna** — sformułuj predykcję, którą robi.

> Format: "Jeśli <X> jest przyczyną, to <zmiana Y> sprawi że bug zniknie / <zmiana Z> sprawi że będzie gorzej."

Jeśli nie umiesz sformułować predykcji, hipoteza to vibe — odrzuć lub naostrz.

**Pokaż zranking userowi PRZED testowaniem.** Często mają domain knowledge które instantowo re-rankuje ("właśnie deployowaliśmy zmianę do #3"), albo wiedzą o hipotezach które już wykluczyli. Tani checkpoint, duża oszczędność czasu. Nie blokuj się — proceedwaj z Twoim rankingiem jeśli user jest AFK.

## Faza 4 — Instrumentacja

Każda sonda musi mapować się na konkretną predykcję z Fazy 3. **Zmieniaj jedną zmienną na raz.**

Tool preference:

1. **Debugger / REPL inspection** jeśli env wspiera. Jeden breakpoint > dziesięć logów.
2. **Targeted logi** na granicach które rozróżniają hipotezy.
3. Nigdy "loguj wszystko i grepuj".

**Oznacz każdy debug log unikalnym prefixem**, np. `[DEBUG-a4f2]`. Cleanup na końcu staje się jednym grep'em. Untagged logi przeżywają; tagged logi padają.

**Branch perfowy.** Dla regresji wydajnościowych logi są zwykle złe. Zamiast tego: ustaw baseline measurement (timing harness, `performance.now()`, profiler, query plan), potem bisect. Mierz najpierw, naprawiaj potem.

## Faza 5 — Fix + test regresji

Napisz test regresji **przed fixem** — ale tylko jeśli istnieje **poprawny seam** dla niego.

Poprawny seam to taki, gdzie test ćwiczy **prawdziwy wzorzec buga** tak jak występuje w call site. Jeśli jedyny dostępny seam jest zbyt płytki (single-caller test gdy bug wymaga wielu callerów, unit test który nie umie zreplikować chain trigger'ującego bug) — test regresji tam daje fałszywą pewność.

**Jeśli żaden poprawny seam nie istnieje — to samo w sobie jest finding'iem.** Zanotuj to. Architektura kodu uniemożliwia zablokowanie buga. Flaguj to dla następnej fazy.

Jeśli poprawny seam istnieje:

1. Zamień minimalizowaną reprodukcję w padający test w tym seamie.
2. Patrz jak pada.
3. Zastosuj fix.
4. Patrz jak przechodzi.
5. Re-runuj pętlę z Fazy 1 przeciwko oryginalnemu (nie-zminimalizowanemu) scenariuszowi.

## Faza 6 — Cleanup + post-mortem

Wymagane przed deklaracją "done":

- [ ] Oryginalna reprodukcja już się nie reprodukuje (re-runuj pętlę z Fazy 1)
- [ ] Test regresji przechodzi (lub brak seamu jest udokumentowany)
- [ ] Cała `[DEBUG-...]` instrumentacja usunięta (`grep` prefix)
- [ ] Throwaway prototypy usunięte (lub przeniesione do clearly-marked debug location)
- [ ] Hipoteza która okazała się prawidłowa jest stwierdzona w commit / PR message — żeby następny debugger się nauczył

**Potem zapytaj: co by zapobiegło temu bugowi?** Jeśli odpowiedź obejmuje zmianę architektoniczną (brak dobrego test seamu, splątani callerzy, ukryte coupling) — przekaż do `/improve-codebase-architecture` z konkretami. Rekomendację rób **po** wprowadzeniu fixu, nie przed — masz teraz więcej informacji niż na początku.
