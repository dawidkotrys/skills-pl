# Projektowanie interfejsów pod testowalność

Dobre interfejsy sprawiają, że testowanie jest naturalne:

1. **Przyjmuj zależności, nie twórz ich**

   ```typescript
   // Testowalne
   function processOrder(order, paymentGateway) {}

   // Trudne do testowania
   function processOrder(order) {
     const gateway = new StripeGateway();
   }
   ```

2. **Zwracaj wyniki, nie produkuj efektów ubocznych**

   ```typescript
   // Testowalne
   function calculateDiscount(cart): Discount {}

   // Trudne do testowania
   function applyDiscount(cart): void {
     cart.total -= discount;
   }
   ```

3. **Mała powierzchnia interfejsu**
   - Mniej metod = mniej testów do napisania
   - Mniej parametrów = prostszy setup testów
