# Format CONTEXT.md

## Struktura

```md
# {Nazwa kontekstu}

{Jedno- lub dwuzdaniowy opis tego, czym ten kontekst jest i dlaczego istnieje.}

## Język

**Order**:
{Zwięzła definicja terminu}
_Unikaj_: Purchase, transaction

**Invoice**:
Żądanie płatności wysłane do klienta po dostawie.
_Unikaj_: Bill, payment request

**Customer**:
Osoba lub organizacja, która składa zamówienia.
_Unikaj_: Client, buyer, account

## Relacje

- **Order** generuje jeden lub więcej **Invoice**
- **Invoice** należy do dokładnie jednego **Customer**

## Przykładowy dialog

> **Dev:** „Kiedy **Customer** składa **Order** — czy tworzymy **Invoice** od razu?"
> **Domain expert:** „Nie, **Invoice** powstaje dopiero po potwierdzeniu **Fulfillmentu**."

## Zaflagowane niejasności

- „account" było używane zarówno w znaczeniu **Customer**, jak i **User** — rozstrzygnięte: to są oddzielne pojęcia.
```

## Zasady

- **Bądź zdecydowany.** Kiedy istnieje wiele słów na to samo pojęcie — wybierz najlepsze i wymień pozostałe jako aliasy do unikania.
- **Konflikty flaguj eksplicytnie.** Jeśli termin jest używany dwuznacznie, zaznacz to w „Zaflagowanych niejasnościach" z jednoznacznym rozstrzygnięciem.
- **Definicje trzymaj zwięzłe.** Maksymalnie jedno zdanie. Definiuj, czym coś **jest**, nie co **robi**.
- **Pokazuj relacje.** Używaj pogrubionych nazw terminów i wyrażaj kardynalność tam, gdzie jest oczywista.
- **Uwzględniaj wyłącznie terminy specyficzne dla kontekstu projektu.** Ogólne pojęcia programistyczne (timeouty, typy błędów, wzorce util-owe) nie pasują, nawet jeśli projekt intensywnie ich używa. Zanim dodasz termin, zapytaj: czy to pojęcie unikalne dla tego kontekstu, czy ogólne pojęcie programistyczne? Tylko to pierwsze pasuje.
- **Grupuj terminy w podsekcjach** kiedy naturalnie wyłaniają się klastry. Jeśli wszystkie terminy należą do jednego spójnego obszaru — płaska lista wystarczy.
- **Napisz przykładowy dialog.** Rozmowa między devem a domain expertem, która pokazuje, jak terminy ze sobą współgrają, i wyjaśnia granice między pokrewnymi pojęciami.

## Repo z jednym kontra wieloma kontekstami

**Pojedynczy kontekst (większość repozytoriów):** Jeden `CONTEXT.md` w roocie.

**Wiele kontekstów:** `CONTEXT-MAP.md` w roocie wymienia konteksty, gdzie żyją i jak się ze sobą wiążą:

```md
# Mapa kontekstów

## Konteksty

- [Ordering](./src/ordering/CONTEXT.md) — przyjmuje i śledzi zamówienia klientów
- [Billing](./src/billing/CONTEXT.md) — generuje faktury i przetwarza płatności
- [Fulfillment](./src/fulfillment/CONTEXT.md) — zarządza kompletacją w magazynie i wysyłką

## Relacje

- **Ordering → Fulfillment**: Ordering emituje eventy `OrderPlaced`; Fulfillment je konsumuje, by rozpocząć kompletację
- **Fulfillment → Billing**: Fulfillment emituje eventy `ShipmentDispatched`; Billing je konsumuje, by wystawić faktury
- **Ordering ↔ Billing**: Współdzielone typy `CustomerId` i `Money`
```

Skill sam wnioskuje, która struktura obowiązuje:

- Jeśli istnieje `CONTEXT-MAP.md` — przeczytaj go, żeby znaleźć konteksty.
- Jeśli istnieje tylko root `CONTEXT.md` — pojedynczy kontekst.
- Jeśli nie ma żadnego — utwórz root `CONTEXT.md` leniwie, kiedy pierwszy termin zostanie ustalony.

Kiedy istnieje wiele kontekstów, wywnioskuj, którego dotyczy bieżący temat. Jeśli nie jest jasne — zapytaj.
