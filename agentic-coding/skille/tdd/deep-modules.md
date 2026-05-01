# Głębokie moduły (Deep Modules)

Z "A Philosophy of Software Design" Johna Ousterhouta:

**Głęboki moduł** = mały interfejs + dużo implementacji

```
┌─────────────────────┐
│   Mały interfejs    │  ← Mało metod, proste parametry
├─────────────────────┤
│                     │
│                     │
│  Głęboka implem.    │  ← Złożona logika ukryta
│                     │
│                     │
└─────────────────────┘
```

**Płytki moduł** = duży interfejs + mało implementacji (unikaj)

```
┌─────────────────────────────────┐
│       Duży interfejs            │  ← Wiele metod, złożone parametry
├─────────────────────────────────┤
│  Cienka implementacja           │  ← Tylko przepuszcza dalej
└─────────────────────────────────┘
```

Projektując interfejsy, zadawaj pytania:

- Czy mogę zredukować liczbę metod?
- Czy mogę uprościć parametry?
- Czy mogę ukryć więcej złożoności w środku?
