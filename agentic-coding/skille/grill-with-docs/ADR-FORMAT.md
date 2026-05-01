# Format ADR

ADR-y żyją w `docs/adr/` i używają numeracji sekwencyjnej: `0001-slug.md`, `0002-slug.md`, itd.

Twórz katalog `docs/adr/` leniwie — dopiero kiedy potrzebny jest pierwszy ADR.

## Szablon

```md
# {Krótki tytuł decyzji}

{1-3 zdania: jaki jest kontekst, co zdecydowaliśmy i dlaczego.}
```

To wszystko. ADR może być pojedynczym akapitem. Wartość polega na zapisaniu *że* decyzja została podjęta i *dlaczego* — nie na wypełnianiu sekcji.

## Sekcje opcjonalne

Dodawaj je tylko wtedy, kiedy wnoszą realną wartość. Większość ADR-ów nie będzie ich potrzebować.

- Frontmatter **Status** (`proposed | accepted | deprecated | superseded by ADR-NNNN`) — przydatne, kiedy decyzje są rewidowane.
- **Considered Options** — tylko jeśli odrzucone alternatywy warto zapamiętać.
- **Consequences** — tylko jeśli trzeba wskazać nieoczywiste skutki uboczne.

## Numeracja

Przeskanuj `docs/adr/` w poszukiwaniu najwyższego istniejącego numeru i zwiększ o jeden.

## Kiedy proponować ADR

Wszystkie trzy warunki muszą być spełnione:

1. **Trudna do cofnięcia** — koszt zmiany decyzji w przyszłości jest znaczący.
2. **Zaskakująca bez kontekstu** — przyszły czytelnik spojrzy na kod i zapyta „dlaczego, na litość boską, zrobili to w ten sposób?".
3. **Wynik realnego trade-offu** — istniały realne alternatywy i wybraliście jedną z konkretnych powodów.

Jeśli decyzja jest łatwa do cofnięcia — pomiń, po prostu ją cofniesz. Jeśli nie jest zaskakująca — nikt nie zapyta dlaczego. Jeśli nie było realnej alternatywy — nie ma czego zapisywać poza „zrobiliśmy oczywistą rzecz".

### Co się kwalifikuje

- **Kształt architektoniczny.** „Używamy monorepo." „Write model jest event-sourced, read model jest projektowany do Postgresa."
- **Wzorce integracji między kontekstami.** „Ordering i Billing komunikują się przez domain events, nie synchroniczny HTTP."
- **Wybory technologiczne, które niosą lock-in.** Baza danych, message bus, dostawca auth, target deploymentu. Nie każda biblioteka — tylko te, których wymiana zajęłaby kwartał.
- **Decyzje o granicach i zakresie.** „Dane Customera są własnością kontekstu Customer; inne konteksty referują do nich tylko przez ID." Eksplicytne „nie" są tak samo wartościowe jak „tak".
- **Świadome odstępstwa od oczywistej ścieżki.** „Używamy ręcznego SQL zamiast ORM-a, ponieważ X." Wszystko, gdzie rozsądny czytelnik założyłby coś przeciwnego. To powstrzymuje następnego inżyniera przed „naprawianiem" czegoś, co było zamierzone.
- **Ograniczenia niewidoczne w kodzie.** „Nie możemy używać AWS-a ze względu na wymogi compliance." „Czasy odpowiedzi muszą być poniżej 200 ms ze względu na kontrakt z partnerem API."
- **Odrzucone alternatywy, gdy odrzucenie jest nieoczywiste.** Jeśli rozważaliście GraphQL i wybraliście REST z subtelnych powodów — zapiszcie to, inaczej za pół roku ktoś znowu zaproponuje GraphQL.
