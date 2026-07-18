# Pogłębianie (Deepening)

Jak bezpiecznie pogłębiać klaster płytkich modułów, biorąc pod uwagę jego zależności. Zakłada słownictwo z [LANGUAGE.md](LANGUAGE.md) — **module**, **interface**, **seam**, **adapter**.

## Kategorie zależności

Oceniając kandydata do pogłębienia, sklasyfikuj jego zależności. Kategoria determinuje sposób testowania pogłębionego modułu po jego seamie.

### 1. In-process

Czysta kalkulacja, in-memory state, brak I/O. Zawsze pogłębialne — scal moduły i testuj przez nowy interfejs bezpośrednio. Adapter niepotrzebny.

### 2. Local-substitutable (Lokalnie zastępowalne)

Zależności, które mają lokalne test stand-iny (PGLite dla Postgresa, in-memory filesystem). Pogłębialne, jeśli stand-in istnieje. Pogłębiony moduł testowany ze stand-inem działającym w test suite. Seam jest wewnętrzny; brak portu na zewnętrznym interfejsie modułu.

### 3. Remote but owned (Ports & Adapters)

Twoje własne serwisy przez network boundary (microservices, internal APIs). Zdefiniuj **port** (interfejs) na seamie. Głęboki moduł posiada logikę; transport jest wstrzykiwany jako **adapter**. Testy używają adaptera in-memory. Produkcja używa adaptera HTTP/gRPC/queue.

Forma rekomendacji: *"Zdefiniuj port przy seamie, zaimplementuj adapter HTTP dla produkcji i adapter in-memory dla testów, tak żeby logika siedziała w jednym głębokim module mimo że jest deployowana przez sieć."*

### 4. True external (Mock)

Third-party services (Stripe, Twilio itp.), których nie kontrolujesz. Pogłębiony moduł przyjmuje zewnętrzną zależność jako wstrzyknięty port; testy dostarczają mock adapter.

## Dyscyplina seamu

- **Jeden adapter oznacza hipotetyczny seam. Dwa adaptery oznacza prawdziwy.** Nie wprowadzaj portu, dopóki co najmniej dwa adaptery nie są uzasadnione (zwykle produkcja + test). Single-adapter seam to tylko indirection.
- **Wewnętrzne seamy vs zewnętrzne seamy.** Głęboki moduł może mieć wewnętrzne seamy (prywatne dla swojej implementacji, używane przez własne testy) oraz zewnętrzny seam przy interfejsie. Nie wystawiaj wewnętrznych seamów przez interfejs tylko dlatego, że testy ich używają.

## Strategia testowa: zastępuj, nie warstwuj

- Stare unit testy płytkich modułów stają się waste'em gdy istnieją testy na interfejsie pogłębionego modułu — usuń je.
- Pisz nowe testy na interfejsie pogłębionego modułu. **Interfejs jest powierzchnią testową.**
- Testy asercjują na obserwowalne outcomes przez interfejs, nie na wewnętrzny stan.
- Testy powinny przeżyć refactory wewnętrzne — opisują zachowanie, nie implementację. Jeśli test musi się zmienić gdy implementacja się zmienia, testuje za interfejsem.
