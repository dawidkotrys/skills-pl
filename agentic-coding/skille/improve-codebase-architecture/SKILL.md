---
name: improve-codebase-architecture
description: Znajdź okazje do pogłębienia (deepening) modułów w kodzie, korzystając ze słownika domeny w CONTEXT.md i decyzji w doc/decisions/. Używaj gdy user chce poprawić architekturę, znaleźć okazje do refactoru, skonsolidować ciasno sprzężone moduły lub uczynić codebase bardziej testowalnym i nawigowalnym dla AI. Triggeruj na "popraw architekturę", "refactor", "tech debt", "deepening", "deep modules", "kod robi się chaotyczny", "konsolidacja modułów".
---

# Improve Codebase Architecture

Wydobądź friction architektoniczny i zaproponuj **okazje do pogłębienia** (deepening opportunities) — refactory, które zamieniają płytkie moduły w głębokie. Cel: testowalność i nawigowalność dla AI.

## Słownik

Używaj tych terminów dokładnie w każdej sugestii. **Konsekwentny język to cały sens** — nie dryfuj w "komponent", "serwis", "API" czy "boundary". Pełne definicje w [LANGUAGE.md](LANGUAGE.md).

- **Module (Moduł)** — wszystko co ma interfejs i implementację (funkcja, klasa, package, slajs).
- **Interface (Interfejs)** — wszystko co caller musi wiedzieć żeby z modułu korzystać: typy, inwarianty, error modes, ordering, konfiguracja. Nie tylko sygnatura typu.
- **Implementation (Implementacja)** — kod wewnątrz.
- **Depth (Głębokość)** — leverage na interfejsie: dużo behaviour za małym interfejsem. **Deep** = wysoki leverage. **Shallow** = interfejs prawie tak skomplikowany jak implementacja.
- **Seam** — gdzie interfejs żyje; miejsce gdzie behaviour można zmienić bez edytowania w miejscu. (Używaj tego, nie "boundary".)
- **Adapter** — konkretna rzecz, która satysfakcjonuje interfejs przy seamie.
- **Leverage** — co dostają callerzy z głębi.
- **Locality** — co dostają maintainerzy z głębi: zmiany, bugi, wiedza skoncentrowane w jednym miejscu.

Kluczowe zasady (zobacz [LANGUAGE.md](LANGUAGE.md) dla pełnej listy):

- **Deletion test** (test usunięcia): wyobraź sobie usunięcie modułu. Jeśli złożoność znika — był pass-through. Jeśli złożoność pojawia się ponownie u N callerów — zarabiał na siebie.
- **Interfejs jest powierzchnią testową.**
- **Jeden adapter = hipotetyczny seam. Dwa adaptery = prawdziwy seam.**

Ten skill jest _informowany_ przez model domenowy projektu. Słownik domeny daje nazwy dobrym seamom; ADR-y zapisują decyzje, których skill nie powinien re-litygować.

## Proces

### 1. Eksploracja

Najpierw przeczytaj słownik domeny projektu i ADR-y w obszarze, którego dotykasz.

Potem użyj narzędzia Agent z `subagent_type=Explore` żeby przeszedł przez codebase. Nie podążaj za sztywnymi heurystykami — eksploruj organicznie i zanotuj gdzie czujesz friction:

- Gdzie zrozumienie jednego konceptu wymaga skakania między wieloma małymi modułami?
- Gdzie moduły są **płytkie** — interfejs prawie tak skomplikowany jak implementacja?
- Gdzie czyste funkcje zostały wyciągnięte tylko dla testowalności, ale prawdziwe bugi siedzą w sposobie ich wywoływania (brak **locality**)?
- Gdzie ciasno sprzężone moduły wyciekają przez seamy?
- Które części kodu są nieprzetestowane lub trudne do testowania przez ich obecny interfejs?

Zastosuj **deletion test** do wszystkiego, co podejrzewasz że jest płytkie: czy usunięcie skoncentrowałoby złożoność, czy tylko by ją przeniosło? "Tak, koncentruje" to sygnał, którego szukasz.

### 2. Przedstaw kandydatów

Przedstaw ponumerowaną listę okazji do pogłębienia. Dla każdego kandydata:

- **Pliki** — jakie pliki/moduły są w grze
- **Problem** — dlaczego obecna architektura powoduje friction
- **Rozwiązanie** — opis co by się zmieniło, prostym językiem
- **Korzyści** — wyjaśnione w terminach locality i leverage, oraz jak testy by się polepszyły

**Używaj słownika CONTEXT.md dla domeny i [LANGUAGE.md](LANGUAGE.md) dla architektury.** Jeśli `CONTEXT.md` definiuje "Order", mów o "module Order intake" — nie o "FooBarHandlerze" i nie o "Order service".

**Konflikty z ADR-ami:** jeśli kandydat sprzeczny z istniejącym ADR — pokazuj go tylko gdy friction jest dostatecznie realny żeby uzasadnić ponowne otwarcie ADR-a. Oznacz wyraźnie (np. _"sprzeczne z ADR-0007 — ale warte ponownego otwarcia bo…"_). Nie wymieniaj każdego teoretycznego refactoru, którego ADR zakazuje.

NIE proponuj jeszcze interfejsów. Zapytaj usera: "Którego z tych chcesz zgłębić?"

### 3. Pętla grillingowa

Gdy user wybierze kandydata, wskocz w grilling. Walk z nim po drzewie decyzyjnym — constrainty, dependencies, kształt pogłębionego modułu, co siedzi za seamem, jakie testy przeżyją.

Side effects dzieją się inline gdy decyzje krystalizują się:

- **Nazwa pogłębionego modułu po koncepcji której nie ma w `CONTEXT.md`?** Dorzuć termin do `CONTEXT.md` — ta sama dyscyplina co `/grill-with-docs` (zobacz [CONTEXT-FORMAT.md](../grill-with-docs/CONTEXT-FORMAT.md)). Stwórz plik leniwie jeśli nie istnieje.
- **Naostrzasz rozmyty termin podczas rozmowy?** Zaktualizuj `CONTEXT.md` od razu.
- **User odrzuca kandydata z load-bearing reason?** Zaproponuj ADR, sformułowane jako: _"Zapisać to jako ADR, żeby przyszłe architecture reviews nie sugerowały tego ponownie?"_ Tylko wtedy gdy reason byłby faktycznie potrzebny przyszłemu eksploratorowi żeby uniknąć re-suggesta — pomiń ephemeral reasons ("nie warto teraz") i self-evident.
- **Chcesz zbadać alternatywne interfejsy dla pogłębionego modułu?** Zobacz [INTERFACE-DESIGN.md](INTERFACE-DESIGN.md).

Zobacz też [DEEPENING.md](DEEPENING.md) dla strategii pogłębiania zgodnie z kategoriami zależności.
