# Język

Wspólne słownictwo dla każdej sugestii tego skilla. Używaj tych terminów dokładnie — nie podstawiaj "komponent", "serwis", "API" czy "boundary". Konsekwentny język to cały sens.

## Terminy

**Module (Moduł)**
Wszystko co ma interfejs i implementację. Świadomie skali-agnostyczne — odnosi się równie dobrze do funkcji, klasy, packagu, czy slajsu obejmującego wiele warstw.
_Unikaj_: unit, component, service.

**Interface (Interfejs)**
Wszystko co caller musi wiedzieć żeby z modułu korzystać poprawnie. Obejmuje sygnaturę typu, ale też inwarianty, constraints kolejności, error modes, wymaganą konfigurację, i charakterystyki wydajności.
_Unikaj_: API, signature (zbyt wąskie — odnoszą się tylko do powierzchni typu).

**Implementation (Implementacja)**
To co jest wewnątrz modułu — body kodu. Różni się od **Adaptera**: rzecz może być małym adapterem z dużą implementacją (Postgres repo) albo dużym adapterem z małą implementacją (in-memory fake). Sięgaj po "adapter" gdy seam jest tematem; "implementacja" w innych przypadkach.

**Depth (Głębokość)**
Leverage przy interfejsie — ilość behaviour, którą caller (lub test) może ćwiczyć na jednostkę interfejsu, której musi się nauczyć. Moduł jest **deep** gdy duża ilość behaviour siedzi za małym interfejsem. Moduł jest **shallow** gdy interfejs jest prawie tak skomplikowany jak implementacja.

**Seam** _(od Michaela Feathersa)_
Miejsce, gdzie możesz zmienić behaviour bez edytowania w tym miejscu. *Lokalizacja* gdzie interfejs modułu żyje. Wybór gdzie postawić seam to osobna decyzja designerska, różna od tego co za nim siedzi.
_Unikaj_: boundary (przeładowane z DDD bounded context).

**Adapter**
Konkretna rzecz, która satysfakcjonuje interfejs przy seamie. Opisuje *rolę* (jaki slot wypełnia), nie substancję (co jest w środku).

**Leverage**
Co callerzy dostają z głębi. Więcej zdolności na jednostkę interfejsu, której muszą się nauczyć. Jedna implementacja zwraca się przez N call sites i M testów.

**Locality**
Co maintainerzy dostają z głębi. Zmiany, bugi, wiedza i weryfikacja koncentrują się w jednym miejscu zamiast rozprzestrzeniać się po callerach. Napraw raz, naprawione wszędzie.

## Zasady

- **Głębokość to właściwość interfejsu, nie implementacji.** Głęboki moduł może być wewnętrznie skomponowany z małych, mockowalnych, wymienialnych części — po prostu nie są one częścią interfejsu. Moduł może mieć **wewnętrzne seamy** (prywatne dla swojej implementacji, używane przez własne testy) oraz **zewnętrzny seam** przy swoim interfejsie.
- **Test usunięcia (deletion test).** Wyobraź sobie usunięcie modułu. Jeśli złożoność znika — moduł nic nie ukrywał (był pass-through). Jeśli złożoność pojawia się ponownie u N callerów — moduł zarabiał na siebie.
- **Interfejs jest powierzchnią testową.** Callerzy i testy przechodzą przez ten sam seam. Jeśli chcesz testować *za* interfejsem — moduł prawdopodobnie ma zły kształt.
- **Jeden adapter = hipotetyczny seam. Dwa adaptery = prawdziwy.** Nie wprowadzaj seamu, dopóki coś faktycznie nie waria między nim.

## Relacje

- **Module** ma dokładnie jeden **Interface** (powierzchnię, którą prezentuje callerom i testom).
- **Depth** to właściwość **Module**, mierzona względem jego **Interface**.
- **Seam** to miejsce gdzie żyje **Interface** **Module**.
- **Adapter** siedzi przy **Seamie** i satysfakcjonuje **Interface**.
- **Depth** produkuje **Leverage** dla callerów i **Locality** dla maintainerów.

## Odrzucone framowania

- **Depth jako stosunek linii implementacji do linii interfejsu** (Ousterhout): nagradza rozdmuchanie implementacji. Używamy depth-as-leverage zamiast tego.
- **"Interface" jako keyword TypeScript `interface` lub publiczne metody klasy**: zbyt wąskie — interface tutaj obejmuje każdy fakt, który caller musi wiedzieć.
- **"Boundary"**: przeładowane z DDD bounded context. Mów **seam** lub **interface**.
