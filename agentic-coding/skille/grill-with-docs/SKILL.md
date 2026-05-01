---
name: grill-with-docs
description: Sesja przesłuchania, która konfrontuje twój plan z istniejącym modelem domenowym, doprecyzowuje terminologię i aktualizuje dokumentację (CONTEXT.md, ADR-y) na bieżąco, w miarę krystalizowania się decyzji. Używaj, kiedy użytkownik chce stress-testować plan względem języka projektu i udokumentowanych decyzji.
disable-model-invocation: true
---

Przesłuchuj mnie bezlitośnie na temat każdego aspektu tego planu, aż osiągniemy wspólne zrozumienie. Przejdź przez każdą gałąź drzewa decyzyjnego, rozwiązując zależności między decyzjami pojedynczo. Dla każdego pytania podaj swoją rekomendowaną odpowiedź.

Zadawaj pytania pojedynczo, czekając na feedback do każdego, zanim przejdziesz dalej.

Jeśli pytanie można rozstrzygnąć przez eksplorację kodu — eksploruj kod zamiast pytać.

## Świadomość domeny

W trakcie eksploracji kodu szukaj też istniejącej dokumentacji.

### Struktura plików

Większość repozytoriów ma jeden kontekst:

```
/
├── CONTEXT.md
├── docs/
│   └── adr/
│       ├── 0001-event-sourced-orders.md
│       └── 0002-postgres-for-write-model.md
└── src/
```

Jeśli w roocie istnieje `CONTEXT-MAP.md`, repo ma wiele kontekstów. Mapa wskazuje, gdzie każdy z nich się znajduje:

```
/
├── CONTEXT-MAP.md
├── docs/
│   └── adr/                          ← decyzje obejmujące cały system
├── src/
│   ├── ordering/
│   │   ├── CONTEXT.md
│   │   └── docs/adr/                 ← decyzje specyficzne dla kontekstu
│   └── billing/
│       ├── CONTEXT.md
│       └── docs/adr/
```

Twórz pliki leniwie — dopiero kiedy masz coś do zapisania. Jeśli `CONTEXT.md` nie istnieje, utwórz go, kiedy pierwszy termin zostanie ustalony. Jeśli `docs/adr/` nie istnieje, utwórz katalog, kiedy pojawi się pierwsza ADR.

## W trakcie sesji

### Konfrontuj ze słowniczkiem

Kiedy użytkownik używa terminu, który koliduje z istniejącym językiem w `CONTEXT.md` — wskaż to natychmiast. „Twój słowniczek definiuje 'cancellation' jako X, ale ty masz na myśli Y — które obowiązuje?"

### Doprecyzuj rozmyte słownictwo

Kiedy użytkownik używa nieprecyzyjnych lub przeładowanych znaczeniowo terminów — zaproponuj precyzyjny termin kanoniczny. „Mówisz 'account' — masz na myśli Customera czy Usera? To są różne rzeczy."

### Omawiaj konkretne scenariusze

Kiedy dyskutujecie o relacjach domenowych, stress-testuj je konkretnymi scenariuszami. Wymyślaj scenariusze, które badają edge case'y i zmuszają użytkownika do precyzji w kwestii granic między koncepcjami.

### Krzyżowo weryfikuj z kodem

Kiedy użytkownik mówi, jak coś działa — sprawdź, czy kod się z tym zgadza. Jeśli znajdziesz sprzeczność, ujawnij ją: „Twój kod anuluje całe Ordery, ale właśnie powiedziałeś, że anulowanie częściowe jest możliwe — co jest prawdą?"

### Aktualizuj `CONTEXT.md` na bieżąco

Kiedy termin zostaje ustalony — zaktualizuj `CONTEXT.md` od razu. Nie batchuj tego na koniec, zapisuj na bieżąco. Format opisany w [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md).

Nie wiąż `CONTEXT.md` ze szczegółami implementacyjnymi. Uwzględniaj tylko terminy znaczące dla domain expertów.

### Proponuj ADR-y oszczędnie

Proponuj utworzenie ADR-a tylko wtedy, gdy spełnione są wszystkie trzy warunki:

1. **Trudna do cofnięcia** — koszt zmiany decyzji w przyszłości jest znaczący.
2. **Zaskakująca bez kontekstu** — przyszły czytelnik zapyta „dlaczego to zrobili w ten sposób?".
3. **Wynik realnego trade-offu** — istniały realne alternatywy i wybraliście jedną z konkretnych powodów.

Jeśli któregokolwiek z trzech brakuje — pomiń ADR. Format opisany w [ADR-FORMAT.md](./ADR-FORMAT.md).
