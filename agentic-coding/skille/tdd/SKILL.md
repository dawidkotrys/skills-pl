---
name: tdd
description: Test-Driven Development z pętlą red-green-refactor. Używaj kiedy budujesz feature lub naprawiasz bug w stylu TDD, padają słowa "red-green-refactor", "integration tests", "test-first", "vertical slice TDD". Triggeruj na "TDD", "test-first", "napisz testy najpierw", "red-green-refactor".
---

# Test-Driven Development

## Filozofia

**Zasada główna**: Testy weryfikują **zachowanie** przez publiczne interfejsy, nie szczegóły implementacyjne. Kod może się całkowicie zmienić; testy nie powinny.

**Dobre testy** są integration-style: korzystają z prawdziwych ścieżek kodu przez publiczne API. Opisują _co_ system robi, nie _jak_. Dobry test czyta się jak specyfikacja — *"użytkownik może sfinalizować zakup z poprawnym koszykiem"* mówi dokładnie jaka funkcjonalność istnieje. Te testy przeżywają refactory, bo nie obchodzi ich struktura wewnętrzna.

**Złe testy** są sprzężone z implementacją. Mockują wewnętrznych współpracowników, testują metody prywatne, weryfikują przez zewnętrzne kanały (np. odpytywanie bazy bezpośrednio zamiast użycia interfejsu). Ostrzeżenie: Twój test się psuje gdy refactorujesz, ale zachowanie się nie zmieniło. Jeśli zmieniasz nazwę wewnętrznej funkcji i testy padają — testowałeś implementację, nie zachowanie.

Zobacz [tests.md](tests.md) dla przykładów oraz [mocking.md](mocking.md) dla wytycznych mockowania.

## Anti-pattern: Slajsy poziome

**NIE pisz wszystkich testów najpierw, potem całej implementacji.** To jest "slajsowanie poziome" — traktowanie RED jako "napisz wszystkie testy" i GREEN jako "napisz cały kod".

To produkuje **gówniane testy**:

- Testy pisane hurtem testują _wyobrażone_ zachowanie, nie _rzeczywiste_
- Kończysz testując _kształt_ rzeczy (struktury danych, sygnatury funkcji) zamiast user-facing zachowania
- Testy stają się niewrażliwe na realne zmiany — przechodzą gdy zachowanie się psuje, padają gdy zachowanie jest OK
- Jedziesz na ślepo, commitując się do struktury testów zanim zrozumiesz implementację

**Poprawne podejście**: Wertykalne slajsy przez tracer bullets. **Jeden test → jedna implementacja → powtarzaj.** Każdy kolejny test reaguje na to, czego nauczyłeś się z poprzedniego cyklu. Skoro właśnie napisałeś kod, wiesz dokładnie jakie zachowanie ma znaczenie i jak je zweryfikować.

```
ŹLE (poziomo):
  RED:   test1, test2, test3, test4, test5
  GREEN: impl1, impl2, impl3, impl4, impl5

DOBRZE (wertykalnie):
  RED→GREEN: test1→impl1
  RED→GREEN: test2→impl2
  RED→GREEN: test3→impl3
  ...
```

## Workflow

### 1. Planowanie

W trakcie eksploracji kodu używaj słownika domeny projektu (`CONTEXT.md`), żeby nazwy testów i słownictwo interfejsów pasowały do języka projektu, oraz respektuj decyzje (`doc/decisions/` lub `docs/adr/`) w obszarach których dotykasz.

Przed napisaniem jakiegokolwiek kodu:

- [ ] Potwierdź z użytkownikiem jakie zmiany interfejsu są potrzebne
- [ ] Potwierdź z użytkownikiem które zachowania testować (priorytetyzuj)
- [ ] Zidentyfikuj okazje na [głębokie moduły](deep-modules.md) (mały interfejs, głęboka implementacja)
- [ ] Zaprojektuj interfejsy pod [testowalność](interface-design.md)
- [ ] Wypisz listę zachowań do przetestowania (nie kroków implementacji)
- [ ] Uzyskaj akceptację planu od użytkownika

Pytaj: *"Jak powinien wyglądać publiczny interfejs? Które zachowania są najważniejsze do testowania?"*

**Nie da się przetestować wszystkiego.** Potwierdź z użytkownikiem dokładnie które zachowania są najważniejsze. Skup wysiłek testowy na ścieżkach krytycznych i złożonej logice, nie na każdym możliwym edge case.

### 2. Tracer Bullet (pocisk smugowy)

Napisz JEDEN test, który potwierdza JEDNĄ rzecz o systemie:

```
RED:   Napisz test pierwszego zachowania → test pada
GREEN: Napisz minimalny kod, żeby przeszedł → test przechodzi
```

To jest Twój tracer bullet — udowadnia, że ścieżka działa end-to-end.

### 3. Pętla inkrementalna

Dla każdego kolejnego zachowania:

```
RED:   Napisz kolejny test → pada
GREEN: Minimalny kod, żeby przeszedł → przechodzi
```

Reguły:

- Jeden test naraz
- Tylko tyle kodu, ile potrzeba do przejścia bieżącego testu
- Nie antycypuj kolejnych testów
- Trzymaj testy skupione na obserwowalnym zachowaniu

### 4. Refactor

Po przejściu wszystkich testów, szukaj [kandydatów do refactoru](refactoring.md):

- [ ] Wyciągnij duplikację
- [ ] Pogłęb moduły (przenieś złożoność za prostsze interfejsy)
- [ ] Zastosuj zasady SOLID gdzie naturalne
- [ ] Rozważ co nowy kod ujawnia o istniejącym kodzie
- [ ] Uruchom testy po każdym kroku refactoru

**Nigdy nie refactoruj będąc w RED.** Najpierw doprowadź do GREEN.

## Checklista per cykl

```
[ ] Test opisuje zachowanie, nie implementację
[ ] Test używa tylko publicznego interfejsu
[ ] Test przeżyje refactor wewnętrzny
[ ] Kod jest minimalny dla tego testu
[ ] Brak spekulatywnych funkcji dorzuconych
```
