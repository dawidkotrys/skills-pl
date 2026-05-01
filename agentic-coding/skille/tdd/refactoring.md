# Kandydaci do refactoru

Po cyklu TDD szukaj:

- **Duplikacja** → wyciągnij funkcję/klasę
- **Długie metody** → rozbij na prywatne helpery (testy zostają na publicznym interfejsie)
- **Płytkie moduły** → scal lub pogłęb
- **Feature envy** → przenieś logikę tam, gdzie żyją dane
- **Primitive obsession** → wprowadź value objects
- **Istniejący kod** który nowy kod ujawnia jako problematyczny
