# Projektowanie interfejsu

Gdy user chce zbadać alternatywne interfejsy dla wybranego kandydata do pogłębienia, użyj tego wzorca paralelnych sub-agentów. Bazuje na "Design It Twice" (Ousterhout) — Twój pierwszy pomysł rzadko jest najlepszy.

Używa słownictwa z [LANGUAGE.md](LANGUAGE.md) — **module**, **interface**, **seam**, **adapter**, **leverage**.

## Proces

### 1. Sformuuj przestrzeń problemu

Przed spawnowaniem sub-agentów napisz user-facing wyjaśnienie przestrzeni problemu dla wybranego kandydata:

- Constrainty, które każdy nowy interfejs musiałby spełnić
- Zależności, na których by się opierał, i do której kategorii należą (zobacz [DEEPENING.md](DEEPENING.md))
- Surowy ilustracyjny szkic kodu żeby ugruntować constrainty — nie propozycja, tylko sposób na ukonkretnienie ograniczeń

Pokaż to userowi, potem natychmiast przejdź do Kroku 2. User czyta i myśli, gdy sub-agenty pracują paralelnie.

### 2. Spawnuj sub-agentów

Spawnuj 3+ sub-agentów paralelnie używając narzędzia Agent. Każdy musi wyprodukować **radykalnie inny** interfejs dla pogłębionego modułu.

Każdy sub-agent dostaje osobny brief techniczny (file paths, szczegóły coupling, kategoria zależności z [DEEPENING.md](DEEPENING.md), co siedzi za seamem). Brief jest niezależny od user-facing wyjaśnienia z Kroku 1. Dla każdego agenta inny constraint designerski:

- Agent 1: "Minimalizuj interfejs — celuj w 1-3 entry points max. Maksymalizuj leverage per entry point."
- Agent 2: "Maksymalizuj elastyczność — wspieraj wiele use case'ów i extension."
- Agent 3: "Optymalizuj pod najczęstszego callera — case domyślny ma być trywialny."
- Agent 4 (jeśli applicable): "Zaprojektuj wokół ports & adapters dla zależności cross-seam."

Włącz w briefie zarówno słownik z [LANGUAGE.md](LANGUAGE.md) jak i CONTEXT.md, żeby każdy sub-agent nazywał rzeczy konsekwentnie z językiem architektury i językiem domeny projektu.

Każdy sub-agent zwraca:

1. Interfejs (typy, metody, params — plus inwarianty, kolejność, error modes)
2. Przykład użycia pokazujący jak callerzy z niego korzystają
3. Co implementacja ukrywa za seamem
4. Strategia zależności i adaptery (zobacz [DEEPENING.md](DEEPENING.md))
5. Trade-offs — gdzie leverage jest wysoki, gdzie cienki

### 3. Przedstaw i porównaj

Przedstaw designy sekwencyjnie żeby user mógł przyswoić każdy z osobna, potem porównaj je prozą. Kontrastuj przez **głębokość** (leverage przy interfejsie), **locality** (gdzie zmiana się koncentruje) i **umiejscowienie seamu**.

Po porównaniu daj własną rekomendację: który design uważasz za najmocniejszy i dlaczego. Jeśli elementy z różnych designów dobrze by się kompinowały — zaproponuj hybrydę. Bądź opinionated — user chce mocny read, nie menu.
