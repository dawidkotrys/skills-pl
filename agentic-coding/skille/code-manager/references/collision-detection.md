# Collision Detection — Deep Research przy równoległej pracy

Ten dokument precyzuje jak Manager sprawdza czy dwa taski mogą być realizowane równolegle bez konfliktów.

## Dlaczego deep research, nie intuicja

User explicitnie wyraził tę zasadę: "nie znam się na tym aż tak dobrze, więc bardziej bym chciał, że tutaj jest deep research plus przedstawienie mi opcji i wyjaśnienie". To znaczy, że nie wystarczy powiedzieć "chyba się nie kolidują". User oczekuje **dowodów** — mapy plików, overlap analysis, rekomendacji z uzasadnieniem.

Konsekwencja błędu: dwa subagenty piszą równolegle, merge konfliktują, traci się godziny na resolve albo (gorzej) mergeują bez konfliktu pliku ale z **semantycznym konfliktem** — dwa patterny rozwiązujące ten sam problem inaczej.

## Proces krok-po-kroku

### Krok 1: Zbierz kontekst obu tasków

Dla **każdego** z dwóch tasków (task A = już aktywny w innym worktree, task B = nowy kandydat):

**Pytania do rozwinięcia (jeśli z opisu nie wynika):**
- Jakie feature obszary dotyka? (file explorer, agent loop, chat UI, auth, db, build?)
- Jakie warstwy? (Rust tauri commands / TS hooks / React components / Zustand store / CSS tokens)
- Czy modyfikuje dane wspólne (store, globalne settings, design tokens)?
- Czy wprowadza nowe publiczne API (nowe commands, nowe store actions, nowe shared components)?

**Źródła odpowiedzi:**
- Backlog entry (jeśli ma szczegóły)
- Code review / kronika powiązana
- Grep nazw pewnych symboli jeśli wspominane
- `git log` brancha task A (jeśli już jest w worktree): `git -C <worktree-path> log develop..HEAD --stat`

### Krok 2: Zmapuj pliki dotykane przez task A

```bash
# Aktywny worktree task A
cd <worktree-path-of-A>
git diff --name-only develop..HEAD
# Plus uncommitted:
git status --short
```

Zrób listę zmienionych plików + folderów. Zapisz jako `files_A`.

### Krok 3: Oszacuj pliki które task B dotknie

To szacowanie, nie pewnik. Na podstawie opisu i architektury:

**Grep patterns które pomogą:**
```bash
# Jeśli task B dotyczy "context menu" — sprawdź które komponenty go używają
grep -rn "ContextMenu\|contextmenu" src/
# Jeśli task B to refactor storeu — znajdź wszystkie subscribery
grep -rn "useWorkspaceStore\|useAgentChatStore" src/
# Jeśli task B dotyka tauri commands — znajdź handlery + wrappery
grep -rn "invoke\b" src/lib/
```

**Glob patterns:**
- Feature = prefix: `src/components/agent/**` dla local agent, `src/components/chat/**` dla cloud chat
- Warstwa = typ pliku: `**/store/*.ts`, `src-tauri/src/*.rs`

Zapisz jako `files_B_estimated`.

### Krok 4: Policz overlap

```
overlap = files_A ∩ files_B_estimated
```

**Poziomy ryzyka:**

| Typ overlap | Ryzyko | Akcja |
|-------------|--------|-------|
| **File-level** (ten sam plik) | 🔴 Wysokie | Równolegle z rebase plan, albo sekwencyjnie |
| **Folder-level, różne pliki** | 🟡 Średnie | Równolegle OK, ale code review obu patrzy pod kątem spójności |
| **Architectural** (różne pliki, ta sama warstwa/pattern) | 🟡 Średnie | Równolegle OK jeśli pattern jest już ustalony; sekwencyjnie jeśli task zmienia pattern |
| **Zero overlap** | 🟢 Niskie | Równolegle bez problemu |

**Specjalna uwaga — shared resources:**
- `CLAUDE.md`, `tsconfig.json`, `package.json` — oba taski potencjalnie dotkną → konflikty merge nawet w izolowanych featureach
- Design tokens (`src/app/globals.css`) — jeśli oba taski dodają tokeny → merge wymaga manualnej inspekcji
- Migration files, schema files — absolutnie nie równolegle na tych samych

### Krok 5: Sprawdź kolizje semantyczne (nie tylko file-level)

**Red flags nawet gdy pliki różne:**

- **Identyczny problem z dwoch różnych stron.** Przykład: task A dodaje cache do `useAgentChatStore`, task B dodaje cache do `useWorkspaceStore`. Różne pliki, ale jeśli patterns są różne — mamy dwa różne cache patterny w codebase. Rozwiązanie: wymień refaktor na wspólny pattern najpierw, potem oba taski.
- **Zmiana semantyki propsów.** Task A zmienia `<Component prop={x}>` na `<Component prop={x, kind}>`. Task B dodaje nowy call site starej sygnatury. Post-merge type error lub bug.
- **Cross-cutting concerns.** Task A dodaje instrumentation/logging, task B refactoruje tę samą funkcję — konflikt nawet jeśli diffy rozłączne.

### Krok 6: Przedstaw userowi jako tabelę + rekomendację

**Format wymagany:**

```
## Analiza kolizji: `<branch-A>` vs `<branch-B-proposed>`

| Wymiar | task A tyka | task B będzie tykać | overlap | ryzyko |
|--------|-------------|---------------------|---------|--------|
| File-level | src/store/agent-chat-store.ts | src/store/workspace-store.ts | brak | 🟢 |
| Folder-level | src/store/ | src/store/ | jest | 🟡 |
| Pattern | split subscriptions | (do ustalenia) | zależne | 🟡 |
| Shared resources | brak | brak | brak | 🟢 |

## Rekomendacja

- **OK / ryzyko średnie / wysokie**
- **Uzasadnienie** (1-2 zdania)
- **Plan na merge** (kto merguje pierwszy, czy drugi rebase'uje, na co uważać)
- **Alternatywa** (jeśli ryzyko wysokie — sekwencyjnie, ze wskazaniem kolejności)
```

User decyduje. **Nie decydujesz Ty.**

## Przykłady historyczne

Do uzupełnienia po kilku sesjach — miejsce na przypadki z praktyki, gdy collision detection wyłapał (albo przepuścił) realny problem.
