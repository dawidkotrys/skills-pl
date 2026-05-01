# plans-readme-template.md

Gdy tworzysz folder `doc/plans/` pierwszy raz (bo jeszcze nie istnieje), dodaj do niego README.md wyjaśniający przeznaczenie. Szablon poniżej — dostosuj nazwy/ścieżki do konwencji projektu.

```markdown
# Plany pracy — `doc/plans/`

Folder z **źródłami prawdy** dla subagentów pracujących na branchach i worktree'ach.

Każdy plik to plan pracy dla jednego brancha. Plan pisze Manager (skill `/code-manager`) przed rozpoczęciem pracy, subagent czyta go jako kontekst startowy, subagent aktualizuje status po zakończeniu.

## Relacja do innych folderów dokumentacji

| Folder | Zawiera | Kto pisze | Kiedy |
|--------|---------|-----------|-------|
| `doc/plans/` | **Kontrakt przed pracą** — co, dlaczego, acceptance, pitfalls | Manager | Przed startem subagenta |
| `doc/history/` | **Kronika po pracy** — co zrobiono, decyzje, trade-offy | Subagent (kronikarz) | Przed push |
| `doc/code-reviews/` | Raporty z `/critical-code-review` | Subagent (w trakcie pracy) | Po self-review, przed commit |
| `doc/design-reviews/` | Raporty z `/design-checker` | Subagent | Przed merge |
| `doc/backlog.md` + `doc/features/*/backlog.md` | Taski, bugi, pomysły — otwarte i ukończone | Manager + user | Na bieżąco |

## Nazewnictwo

- Nazwa pliku: `<branch-name-with-dashes>.md`
- Slashy w nazwie brancha zamieniamy na dashe: `feat/file-explorer-context-menu` → `feat-file-explorer-context-menu.md`

## Czas życia planu

- **Aktualny** — plan jest working document. Subagent może dopisać odchylenia, nowe decyzje, in-flight updates.
- **Po merge** — plan zostaje w folderze jako **artefakt historyczny** (obok kroniki). Nie kasujemy. Pomaga odtworzyć "co planowaliśmy vs co weszło".
- **Po dłuższym czasie** — jeśli folder puchnie, można archiwizować stare plany do `doc/plans/archive/YYYY/`. Nie robimy tego automatycznie.

## Konwencja języka

Po polsku, zgodnie z ogólną konwencją `doc/` w projekcie (patrz CLAUDE.md).
```

## Uwagi

- Jeśli projekt używa innej konwencji dokumentów (`docs/` zamiast `doc/`, angielski zamiast polskiego) — dostosuj szablon do tej konwencji. Manager **nie narzuca swojego standardu**, on wpisuje się w istniejący.
- Jeśli `doc/history/README.md` już istnieje z podobną tabelą — użyj jej jako wzoru zamiast narzucać ten format.
