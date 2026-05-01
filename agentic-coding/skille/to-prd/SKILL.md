---
name: to-prd
description: Zamień bieżący kontekst rozmowy na PRD i opublikuj go w trackerze projektu. Używaj kiedy chcesz utrwalić ustalenia z grillingu/rozmowy jako "destination document" — szczególnie przy dużych inicjatywach przed rozbiciem na issues. Triggeruj na "napisz PRD", "stwórz PRD", "PRD z naszej rozmowy", "destination document".
---

# To PRD — Konwersacja → PRD

Ten skill bierze bieżący kontekst rozmowy i zrozumienie kodu, i produkuje PRD. **NIE przesłuchuj użytkownika** — po prostu zsyntetyzuj to, co już wiesz.

Tracker projektu i słownik etykiet triage powinny być Ci podane — jeśli nie, uruchom `/setup-matt-pocock-skills` lub sprawdź konwencje projektu w `CLAUDE.md` / `doc/`.

## Proces

1. **Eksploruj repo**, żeby zrozumieć obecny stan kodu, jeśli jeszcze tego nie zrobiłeś. Używaj słownika domeny (`CONTEXT.md`) konsekwentnie w całym PRD i respektuj decyzje z `doc/decisions/` (lub `docs/adr/`) w obszarach których dotykasz.

2. **Zarysuj główne moduły**, które trzeba zbudować lub zmodyfikować. Aktywnie szukaj okazji do wyodrębnienia **głębokich modułów** (deep modules), które mogą być testowane w izolacji.

   Głęboki moduł (w przeciwieństwie do płytkiego) to taki, który enkapsuluje dużo funkcjonalności w prostym, testowalnym interfejsie, który rzadko się zmienia.

   Skonfrontuj te moduły z użytkownikiem — czy odpowiadają jego oczekiwaniom? Zapytaj, dla których modułów chce mieć napisane testy.

3. **Napisz PRD** używając poniższego szablonu, a następnie opublikuj go w trackerze projektu. Zastosuj etykietę `needs-triage`, żeby trafił do normalnego flow triage'u.

<prd-template>

## Problem

Problem, z którym mierzy się użytkownik, z perspektywy użytkownika.

## Rozwiązanie

Rozwiązanie problemu, z perspektywy użytkownika.

## User Stories

DŁUGA, ponumerowana lista user stories. Każda w formacie:

1. Jako <aktor>, chcę <funkcjonalność>, żeby <korzyść>

<user-story-example>
1. Jako klient bankowości mobilnej, chcę widzieć saldo na moich kontach, żebym mógł podejmować bardziej świadome decyzje finansowe.
</user-story-example>

Lista user stories powinna być wyczerpująca i pokrywać wszystkie aspekty funkcji.

## Decyzje implementacyjne

Lista decyzji implementacyjnych, które zostały podjęte. Może obejmować:

- Moduły, które zostaną zbudowane/zmodyfikowane
- Interfejsy tych modułów, które zostaną zmodyfikowane
- Doprecyzowania techniczne od dewelopera
- Decyzje architektoniczne
- Zmiany schematu bazy
- Kontrakty API
- Konkretne interakcje

NIE umieszczaj konkretnych ścieżek plików ani fragmentów kodu — szybko się dezaktualizują.

## Decyzje testowe

Lista decyzji testowych. Uwzględnij:

- Opis tego, co stanowi dobry test (testuj zewnętrzne zachowanie, nie szczegóły implementacyjne)
- Które moduły będą testowane
- Prior art dla testów (podobne typy testów już istniejące w kodzie)

## Out of scope

Opis rzeczy, które są **poza zakresem** tego PRD. Ta sekcja jest kluczowa dla jasnej definicji "done".

## Dodatkowe uwagi

Wszelkie dalsze notatki dotyczące funkcji.

</prd-template>
