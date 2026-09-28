# Formularz bramki manualnej — jak raportować użytkownikowi poprawki

Reguła powstała 2026-08-22, po realnej stracie danych: bramka S0-S2 (24 scenariusze) została
wystawiona jako **artefakt online** z zapisem stanu „w stronie". użytkownik odhaczył wszystko
i wpisał uwagi. Serwerowa kopia artefaktu miała **zero zaznaczeń i puste pola uwag** —
zaznaczenia zostały w jego przeglądarce i nie dotarły do Managera. Odzyskane zostały tylko
te uwagi, które użytkownik ręcznie wkleił do czatu. **Werdykty pass/fail przepadły.**

## Twarda reguła

**Bramka manualna wychodzi jako lokalny plik HTML na Pulpicie. Nigdy jako artefakt online.**

```
~/Desktop/bramka-<slug>-<YYYY-MM-DD>.html
```

Po zapisaniu **powiedz użytkownikowi ścieżkę**. Nic więcej nie musi robić w trakcie — zaznaczenia
zapisują się same. Na końcu klika „Zbierz wynik", co pokazuje gotowy Markdown i pozwala go
zapisać jako plik `.md` albo skopiować do czatu.

Artefakt online jest OK **wyłącznie** dla dokumentów tylko-do-czytania (raport po fakcie,
podsumowanie, notatka strategiczna). W momencie, w którym strona ma **zbierać** od użytkownika
decyzje — plik lokalny, koniec dyskusji.

## Szablon

[`manual-gate-form-template.html`](manual-gate-form-template.html) — **wersja 3, kanon od 2026-09-03.**
Skopiuj na Pulpit i wypełnij **tylko dwie rzeczy** na dole pliku:

- **`GATE`** — klucz `localStorage`, nazwa pliku wyniku, tytuł, lead, `meta` (branch i ścieżki),
  bloki wstępu, pytanie karty końcowej.
- **`GROUPS`** — tablica grup, w każdej tablica scenariuszy.

Wszystko poniżej sekcji `SILNIK` jest gotowe. HTML kart generuje się z danych.

### Dlaczego v3 jest sterowana danymi

W v2 każda karta była pisana ręcznie i wymagała zgodności trójki `data-id` / `id="c-…"` /
`name="v-…"`. Rozjazd w tej trójce **cicho gubił werdykt** — kliknięcie działało, a wynik
nie zawierał scenariusza. W v3 identyfikator jest jeden: pole `id` w danych. Ta klasa błędu
przestała istnieć, nie została „ograniczona".

Wygląd wzięty z przeglądu copy ankiety v3 (3 września) — użytkownik wskazał go jako najczytelniejszy
dokument, jaki dostał: lewa szyna z krokami i licznikiem per grupa, karty z wyraźnym „działa jeśli /
nie działa jeśli", pasek postępu na dole, wynik zbierany w oknie modalnym.

### Pola scenariusza

| pole     | wymagane | co to jest                                                                    |
| -------- | -------- | ----------------------------------------------------------------------------- |
| `id`     | tak      | krótki, unikalny w całej bramce (`S1`). Trafia do wyniku.                      |
| `title`  | tak      | w języku użytkownika, nie w żargonie.                                               |
| `tag`    | nie      | jedna linia kontekstu pod tytułem.                                             |
| `note`   | nie      | co jest już przygotowane, skąd startujesz.                                     |
| `prompt` | nie      | string albo tablica stringów. Każdy dostaje własny przycisk „Kopiuj".          |
| `steps`  | nie      | tablica kroków do wyklikania ręcznie, gdy scenariusz nie jest promptem.        |
| `ok`     | tak      | obserwowalny skutek. Musi **rozróżniać** — na złym kodzie ma być czerwony.     |
| `fail`   | tak      | konkretny objaw awarii, nie „coś poszło źle".                                  |
| `trap`   | nie      | co wygląda na błąd, a błędem nie jest.                                         |

W tekstach działa `` `kod` ``, `**pogrubienie**` i `*kursywa*`.

## Czego formularz musi mieć

Nienegocjowalne. Każdy punkt ma za sobą realną stratę albo realny fałszywy alarm.

1. **Zapis stanu przy każdym kliknięciu i każdej literze.** Bez debounce'u i bez przycisku
   „zapisz stan". użytkownik zamyka kartę bez ostrzeżenia; każde okno opóźnienia to okno na stratę.
2. **Ciche przywrócenie przy otwarciu.** Żadnego bannera „znaleziono wersję roboczą, przywrócić?" —
   plik po prostu otwiera się w stanie, w którym został zostawiony.
3. **`GATE.key` unikalny per bramka.** Dwie bramki z tym samym kluczem `localStorage` nadpisują
   sobie stan. To jedyna rzecz w szablonie, której pominięcie kasuje dane po cichu.
4. **Werdykt i uwaga to dwie osobne rzeczy.** Trzy werdykty — *Działa / Nie działa / Pominięte* —
   plus **osobny przełącznik „Mam uwagę"**, który otwiera pole tekstowe i **nie rusza werdyktu**.
   Uwaga do scenariusza, który działa, jest tak samo cenna jak awaria, a jednocześnie nie może
   zabrudzić listy tego, co realnie pęka. Podsumowanie raportuje to wprost:
   `działa: 18 (w tym 3 z uwagą)`.
5. **Pola uwag nie da się zwinąć, gdy coś w nim jest.** Ponowne kliknięcie „Mam uwagę" przy
   niepustym polu tylko ustawia w nim kursor. Zwijanie z tekstem w środku ukrywałoby dane.
6. **Wynik to MARKDOWN, nie HTML.** Podsumowanie liczbowe, werdykt i uwaga per scenariusz.
   To jest kanał odczytu dla Ciebie — czytasz go wprost, bez parsera. Awaria jest pisana
   wielkimi literami (`**NIE DZIAŁA**`), żeby nie dało się jej przeoczyć przy skanowaniu.
7. **Zapis pliku i kopiowanie obok siebie** w oknie wyniku. użytkownik czasem wkleja do czatu zamiast
   wrzucać plik. Kopiowanie ma fallback na `document.execCommand`, bo `navigator.clipboard`
   w stronie otwartej z `file://` bywa zablokowane.
8. **Przycisk „Kopiuj" przy każdym promptcie.** Prompt gotowy do wklejenia agentowi, z pełnymi
   ścieżkami. użytkownik nie ma nic dopisywać ani sklejać z dwóch miejsc.
9. **Lewa szyna z licznikiem per grupa, pasek postępu i „Pierwszy niewypełniony".** Przy 20+
   scenariuszach powrót po przerwie bez tego przycisku to przewijanie na oko. Grupa z awarią
   ma licznik na czerwono — widać ją bez wchodzenia.
10. **Ekran „Zanim zaczniesz"** z trzema blokami: jak to działa, **uwaga ≠ werdykt**, oraz
    **czego nie liczyć jako błąd** (znane ograniczenie środowiska). Ten trzeci ratuje bramkę
    przed fałszywym FAIL-em za każdym razem, gdy dev build czegoś nie umie.
11. **Karta końcowa „Na koniec"** z jednym konkretnym pytaniem produktowym. Wyłączona z licznika
    i z podsumowania, ląduje w wyniku jako osobna sekcja.
12. **„Reszta tutaj działa"** wypełnia **tylko puste** werdykty. Nigdy nie nadpisuje tego,
    co użytkownik już zaznaczył.

## Jak czytać wynik

Struktura jest stała:

```markdown
# Wynik bramki: Bramka manualna — Inbox first command

- data: 2026-09-03 21:40
- branch: `fix/inbox-first-command`

## Podsumowanie

- działa: 18 (w tym 3 z uwagą)
- NIE DZIAŁA: 1
- pominięte: 0
- bez werdyktu: 2

## Krok A — Pierwsza komenda

### S5 — Pierwsze wysłanie na GitHuba
- werdykt: **działa**
- uwaga: pokazały się trzy karty, nie cztery
```

**„Bez werdyktu" czytaj jak `fail` do wyjaśnienia, nie jak `pass`.** Puste znaczy, że nie wiesz —
albo użytkownik nie doszedł, albo scenariusz nie dał się rozstrzygnąć. Jedno i drugie wymaga pytania.

## Uwagi użytkownika to nie „komentarz do werdyktu"

Trzy z czterech uwag z bramki S0-S2 nie były raportami defektu — były **zmianami zakresu**
(„te ustawienia powinny być gdzie indziej", „wzoruj się na innej aplikacji", „usuwamy ten model").
Scenariusz mógł być technicznie `działa` i jednocześnie nieść uwagę, która przewraca projekt UI.
Dlatego uwaga ma w v3 własny przełącznik, a podsumowanie liczy `działa (w tym N z uwagą)`.

Konsekwencja dla Ciebie: **po każdej bramce przejedź uwagi osobno od werdyktów.** Dla każdej
uwagi ustal, czy to (a) defekt do fixu w tym slice, (b) zmiana zakresu → nowy task/slice,
(c) rzecz już zapisana w PRD (wtedy powiedz gdzie — użytkownik nie musi tego pamiętać). Nie
wrzucaj uwag hurtem do backlogu bez tej klasyfikacji.

## Czego dev build NIE potrafi — sprawdź przed napisaniem scenariusza

Scenariusz, którego środowisko bramki nie umie odtworzyć, wraca jako „bez werdyktu"
i zjada czas użytkownika bez żadnego sygnału. Utrzymuj tu listę znanych ograniczeń środowiska
testowego swojego projektu, np.:

- integracje, które nie startują w buildzie deweloperskim (np. przez inne ścieżki zasobów
  niż w buildzie produkcyjnym) — scenariusz wymagający takiej integracji opieraj na narzędziu
  lokalnym albo odłóż do buildu produkcyjnego;
- narzędzia deweloperskie (konsola, inspektor) dostępne tylko pod dodatkową flagą — odpal tę
  wersję, zanim wystawisz bramkę, jeśli scenariusz każe coś odczytać z konsoli;
- ograniczenie do jednej instancji serwera deweloperskiego naraz (stały port) — dwie gałęzie
  do przetestowania to dwa przebiegi sekwencyjnie, nie równolegle;
- przeładowanie frontu to nie restart aplikacji — scenariusz o odzyskiwaniu po restarcie
  wymaga pełnego zamknięcia i ponownego otwarcia;
- build deweloperski, który koliduje z zainstalowaną wersją produkcyjną (globalne skróty,
  procesy w tle) — uprzedź użytkownika albo ubij dev, gdy bramka się skończy.

## Czego nie robić

- Nie proś użytkownika o przepisywanie wyników do czatu. Formularz istnieje właśnie po to.
- Nie zakładaj, że skoro pole „uwagi" jest puste, to scenariusz przeszedł. Puste = nie wiesz.
- Nie wystawiaj bramki, dopóki nie przejrzysz scenariuszy pod kątem **fałszywego alarmu**
  (za ciasny próg, wartość czytana tam, gdzie z definicji jest zero, notka „nie zgłaszaj"
  opisująca stan sprzed fixu). Złapane trzy razy w jednej bramce.
- Nie przepisuj silnika szablonu „przy okazji". Jeśli musisz go dotknąć, sprawdź go najpierw
  na mutacjach: zepsuj po kolei zwijanie pola uwag, niezależność uwagi od werdyktu i „tylko
  puste" w bulk — i upewnij się, że **każda** z tych trzech mutacji daje czerwony wynik.
  Zielony przebieg sam z siebie niczego nie dowodzi.
