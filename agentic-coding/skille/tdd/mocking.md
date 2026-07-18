# Kiedy mockować

Mockuj wyłącznie na **granicach systemu**:

- Zewnętrzne API (płatności, email itp.)
- Bazy danych (czasem — preferuj testową bazę)
- Czas / losowość
- System plików (czasem)

Nie mockuj:

- Własnych klas/modułów
- Wewnętrznych współpracowników
- Niczego nad czym masz kontrolę

## Projektowanie pod mockowalność

Na granicach systemu projektuj interfejsy, które są łatwe do zamockowania:

**1. Używaj dependency injection**

Przekazuj zewnętrzne zależności jako argumenty zamiast tworzyć je wewnątrz:

```typescript
// Łatwe do zamockowania
function processPayment(order, paymentClient) {
  return paymentClient.charge(order.total);
}

// Trudne do zamockowania
function processPayment(order) {
  const client = new StripeClient(process.env.STRIPE_KEY);
  return client.charge(order.total);
}
```

**2. Preferuj interfejsy SDK-style nad generyczne fetchery**

Twórz konkretne funkcje dla każdej zewnętrznej operacji zamiast jednej generycznej funkcji z conditional logic:

```typescript
// DOBRZE: Każda funkcja jest niezależnie mockowalna
const api = {
  getUser: (id) => fetch(`/users/${id}`),
  getOrders: (userId) => fetch(`/users/${userId}/orders`),
  createOrder: (data) => fetch('/orders', { method: 'POST', body: data }),
};

// ŹLE: Mockowanie wymaga conditional logic wewnątrz mocka
const api = {
  fetch: (endpoint, options) => fetch(endpoint, options),
};
```

Podejście SDK-style oznacza:
- Każdy mock zwraca jeden konkretny kształt
- Brak conditional logic w setupie testów
- Łatwiej zobaczyć, których endpointów dotyka test
- Type safety per endpoint
