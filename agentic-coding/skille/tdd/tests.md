# Dobre i złe testy

## Dobre testy

**Integration-style**: Testują przez prawdziwe interfejsy, nie mocki wewnętrznych części.

```typescript
// DOBRZE: Testuje obserwowalne zachowanie
test("użytkownik może sfinalizować zakup z poprawnym koszykiem", async () => {
  const cart = createCart();
  cart.add(product);
  const result = await checkout(cart, paymentMethod);
  expect(result.status).toBe("confirmed");
});
```

Cechy:

- Testują zachowanie, na którym zależy użytkownikom/wywołującym
- Używają tylko publicznego API
- Przeżywają refactory wewnętrzne
- Opisują CO, nie JAK
- Jedna logiczna asercja na test

## Złe testy

**Testy szczegółów implementacyjnych**: Sprzężone z wewnętrzną strukturą.

```typescript
// ŹLE: Testuje szczegóły implementacyjne
test("checkout woła paymentService.process", async () => {
  const mockPayment = jest.mock(paymentService);
  await checkout(cart, payment);
  expect(mockPayment.process).toHaveBeenCalledWith(cart.total);
});
```

Czerwone flagi:

- Mockowanie wewnętrznych współpracowników
- Testowanie metod prywatnych
- Asercje na liczbie/kolejności wywołań
- Test pada przy refactorze bez zmiany zachowania
- Nazwa testu opisuje JAK, nie CO
- Weryfikacja przez zewnętrzne kanały zamiast interfejsu

```typescript
// ŹLE: Omija interfejs, żeby zweryfikować
test("createUser zapisuje do bazy", async () => {
  await createUser({ name: "Alice" });
  const row = await db.query("SELECT * FROM users WHERE name = ?", ["Alice"]);
  expect(row).toBeDefined();
});

// DOBRZE: Weryfikuje przez interfejs
test("createUser sprawia, że użytkownik jest pobieralny", async () => {
  const user = await createUser({ name: "Alice" });
  const retrieved = await getUser(user.id);
  expect(retrieved.name).toBe("Alice");
});
```
