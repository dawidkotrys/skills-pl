# 03. Pliki projektu — co żyje na dysku

Metodologia trzyma wszystko ważne w plikach na dysku, nie w pamięci rozmowy (model nie pamięta poprzedniej sesji — pliki pamiętają). Ten dokument mówi, **co masz w projekcie, gdzie to leży i kto to pisze**. Formatów nie musisz znać na pamięć — agent zna je ze skilli i tworzy pliki za Ciebie.

## Mapa plików

| Plik / folder | Co zawiera | Kto pisze |
|---|---|---|
| `CLAUDE.md` (root) | Konwencje repo: stack, styl kodu, komendy, quality bar | Ty / `/repo-onboarding` |
| `CONTEXT.md` (root) | Słownik domeny — język projektu | `/grill` (na bieżąco) |
| `doc/plans/<slug>/prd.md` | Dokument docelowy dużej inicjatywy | `/to-prd` |
| `doc/plans/<slug>/backlog.md` | Etapy inicjatywy rozpisane na zadania | `/to-prd` + `/to-tasks` |
| `doc/plans/<branch>.md` | Plan pojedynczego małego taska | Manager |
| `doc/decisions/NNNN-*.md` | Decyzje architektoniczne (ADR) | `/grill` (rzadko) |
| `doc/backlog.md` | Lista zadań, pomysłów, bugów | Manager + Ty |
| `doc/history/YYYY-MM-DD-*.md` | Kroniki zmian per branch | Executor (live) + Manager (close) |
| `doc/code-reviews/*.md` | Raporty z przeglądów kodu | Manager |
| `doc/session/*.md` | Zapis kontekstu przed `/clear` (poza gitem) | komendy save/restore |

## CLAUDE.md — konwencje repo

Plik w katalogu głównym, który agent wczytuje **automatycznie** na starcie każdej sesji. Trzyma to, co specyficzne dla tego repo: stack i wersje, styl kodu, komendy (build, test, dev), quality bar. Może być na kilku poziomach — bardziej szczegółowy `CLAUDE.md` w podkatalogu (np. dla systemu designu) uzupełnia ten z roota. Tu **nie** trzymasz słownika domeny (to `CONTEXT.md`), decyzji architektonicznych (to `doc/decisions/`) ani listy zadań (to `doc/backlog.md`).

## CONTEXT.md — słownik domeny

Język projektu, nie opis techniczny. Terminy biznesowe, ich znaczenia, aliasy których unikać, relacje między pojęciami. Agent czyta go na początku każdej sesji, żeby mówić Twoim językiem i nie mylić pojęć. Rośnie w trakcie pracy — gdy w rozmowie pojawia się nowy termin, `/grill` dopisuje go do słownika. Na start wystarczy 5-10 terminów.

## doc/plans/ — plany pracy

Mały task dostaje jeden plik `doc/plans/<branch>.md` z planem od Managera. Duża inicjatywa dostaje własny folder `doc/plans/<slug>/` z dwoma plikami: `prd.md` (dokument docelowy — cel i podział na etapy) i `backlog.md` (etapy rozpisane na konkretne zadania). Zadania kolejnego etapu rozpisuje się dopiero, gdy poprzedni jest gotowy — nie wszystko z góry. Po zakończeniu całości Manager przenosi folder do `doc/plans/archive/` (zawartość zostaje nietknięta jako ślad).

## doc/decisions/ — decyzje architektoniczne (ADR)

Krótkie notatki o decyzjach, które są **trudne do cofnięcia**, **zaskakujące bez kontekstu** i **wynikają z realnego wyboru** między opcjami. ADR może być jednym akapitem — jego wartość to zapis, **że** decyzja zapadła i **dlaczego**, żeby za pół roku nikt nie „naprawiał" czegoś, co jest celowe. Zwykłe, oczywiste albo łatwo odwracalne decyzje nie są ADR-ami — wystarczy commit. Folder tworzy się **leniwie** — dopiero przy pierwszym ADR-ze.

## doc/backlog.md — lista zadań

Jeden plik w repo zamiast zewnętrznego narzędzia (bez Jira / Linear / GitHub Issues). Zadania, pomysły, bugi, tech debt — pogrupowane, z aktywnymi sekcjami na górze i archiwum na dole. Zasady: **daty zawsze pełne** (`2026-04-29`, nigdy „w czwartek" — bo następna sesja nie zna kontekstu), **zależności wypisane wprost** („blokuje X", „wymaga Y"), a w sekcji ukończonych **trzymaj tylko 10 ostatnich** — starsze usuwaj albo przenoś do changelogu, żeby plik nie puchł.

## doc/history/ — kroniki zmian

Każdy branch dostaje kronikę: co i dlaczego zrobiono, jakie decyzje zapadły, wyniki testów. Agent wykonawczy prowadzi ją **na bieżąco** w trakcie pracy (tryb live), a Manager **domyka** ją przed scaleniem (tryb close): podpis, aktualizacja listy zadań i indeksu kronik. Dzięki temu następna sesja (albo następny agent) wie, skąd wzięło się rozwiązanie, i nie analizuje wszystkiego od nowa.

## doc/session/ — zapis kontekstu przed czyszczeniem

Ulotny folder (poza kontrolą wersji), używany tylko wtedy, gdy długa praca wymaga wyczyszczenia rozmowy (`/clear`) w połowie. Komendy `/save-session-*` zrzucają do pliku **samą deltę** — ustalenia jeszcze nigdzie niezapisane i wskaźnik następnego kroku, nie kopię tego, co już jest w kronice czy planie. Po wyczyszczeniu `/restore-session-*` wczytuje plik, a po udanym odzyskaniu **archiwizuje go** (przenosi do `doc/session/archive/`, nie kasuje — zostaje ślad na wypadek problemu).

## Nowe repo?

Zanim zaczniesz pracę w repo, sprawdź, czy ma `CLAUDE.md`, `CONTEXT.md`, `doc/decisions/` i `doc/backlog.md`, i czy testy biegną szybko. Jeśli czegoś brakuje — odpal `/repo-onboarding`, który zakłada tę strukturę i dopasowuje ją do projektu.
