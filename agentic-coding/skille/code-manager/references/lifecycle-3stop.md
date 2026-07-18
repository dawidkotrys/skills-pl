# Lifecycle 3-STOP — kanoniczna sekwencja końca pracy

Jedyne źródło prawdy dla sekwencji executor ↔ user ↔ Manager po implementacji. Plany (Tryb 4A/4B) i briefingi umieszczają **digest (~8 linii) + link tutaj** — nigdy pełną kopię (kopie driftują i pożerają budżet planu).

## Digest do wklejenia w plan

```markdown
## Koniec pracy (3-STOP — pełna specyfikacja: ~/.claude/skills/code-manager/references/lifecycle-3stop.md)

1. STOP #1 user QA: /kronikarz live → scenariusze inline (co klikasz → czego oczekujesz) → user testuje; poprawki = fix in-branch + ponowny STOP #1.
2. STOP #2 review: NIE odpalasz /critical-code-review — raportujesz Managerowi; Manager robi review, user decyduje FIX/BACKLOG/SKIP; fixy in-branch + SKIP template.
3. STOP #3 re-test (tylko jeśli były FIXy): user re-testuje scenariusze dotknięte zmianami.
4. Raport końcowy do Managera („zlecam /kronikarz close"). NIE pushujesz, NIE mergujesz — Manager owner of remote/main.
```

## Pełna sekwencja

**Dlaczego ten gate istnieje:** bez 3-STOP executor decyduje za usera (naruszenie zasady #1), kronika pisana przed decyzjami dezaktualizuje się, a user traci okno na „ten LOW jest dla mnie ważniejszy niż myślisz". Manual QA = **imposing taste** (zasada #9) — user dotyka realnego produktu, nie raportu o nim.

### STOP #1 — user QA

1. Executor: implementacja → `/kronikarz live` per faza → scenariusze testowe inline na czat. Reguły scenariuszy: format „co user klika → czego oczekuje", język nie-techniczny; bez DevTools/Profilera — jeśli pomiar jest techniczny, oznacz „Pomijalne dla użytkownika — Manager zweryfikuje pomiarowo"; komendy zawsze do skopiowania 1:1; grupuj 3 scenariusze MUST + reszta opcjonalna (całość ~10 min); scenariusze idą inline na czat ZAWSZE (ADR-0010) + duplikat do sekcji `## 🧪 Testy` kroniki.
2. User klika, czyta, dotyka realnej aplikacji:
   - ✅ ok → executor raportuje do Managera (dalej STOP #2),
   - ⚠️ poprawki → fixy in-branch (commit `fix per user QA`) + `/kronikarz live` update + **ponowny STOP #1**. Cap: po 3 cyklach bez progresu Manager proponuje scope-down/split (patrz manager-values), nie „spróbuj jeszcze raz",
   - ❌ broken → eskalacja do Managera z opisem co executor odkrył.

### STOP #2 — external review

3. Executor **NIE odpala** `/critical-code-review` — reviewer musi być kimś innym niż autor (autor broni własnych decyzji zamiast je kwestionować; ADR-0002 metodologii). Executor kończy turę raportem dla Managera: TL;DR + status brancha + link do kroniki (tryb autonomiczny: raport wraca do Managera bezpośrednio; wariant dwóch okien: przekazuje go user).
4. Manager odpala `/critical-code-review` (runda 1 = full), tłumaczy findings na human language, user decyduje per-finding: **FIX / BACKLOG / SKIP**.
5. Executor: fixy dla FIX + SKIP entries z templatem (Impact / Koszt / Rationale / Re-evaluate gdy) + `/kronikarz live` update.
6. Manager: weryfikacja fixów przez `/critical-code-review` w **trybie re-review** (diff + blast radius + status poprzednich findingów — nie pełny re-hunt). **Budżet: max 2 rundy re-review** — po 2. bez APPROVE decyzja usera (scope-down / known-gap), nie trzecia runda. Nowy CRITICAL wprowadzony przez fix = pełnoprawna runda (nadal re-review). Werdykt NEEDS PRODUCT DECISION = pauza na decyzję usera. Fixów nie weryfikuje ich autor (self-verify daje fałszywe APPROVE).

### STOP #3 — re-test (tylko jeśli były FIXy)

7. User re-testuje **scenariusze, których dotykały zmiany z review** — nie pełny rerun. Zero FIXów (wszystko BACKLOG/SKIP) → STOP #3 pomijany.

### Close + merge (Manager)

8. Executor: raport końcowy do Managera — „wszystko ✅, zlecam `/kronikarz close`".
9. Manager: sanity check kroniki → `/kronikarz close` (Digest kroniki, sekcja Manager close, update backlog + indeks, commit).
10. **Autonomy gate:** Manager pyta „merge?" i czeka na explicit „akcept" — merge to akcja trudno odwracalna, więc zawsze human-in-the-loop (ADR-0001 metodologii). Po akcept: `git push` + merge + wpisanie merge SHA do kroniki. Jeśli to ostatni slice inicjatywy → Tryb 5D archive.

## Ownership dokumentów i twarde zakazy per rola

- **Executor OWNS (per-branch, edytuje in-branch):** `doc/history/YYYY-MM-DD-<branch>.md` (kronika live), `doc/plans/<branch>.md` / bridge plan (update przy zmianie scope), wpisy przygotowane do backlogu (jako propozycje w raporcie).
- **Executor NIE DOTYKA (shared, single-writer = Manager post-merge):** `doc/backlog.md`, `doc/history/README.md`, `doc/plans/README.md` — dwa równoległe branche edytujące te pliki = gwarantowany konflikt. *Wyjątek solo-work:* gdy Manager explicit napisze „nie ma równoległych branchy, możesz updatować backlog in-branch" — wtedy wolno.
- **Executor:** nie odpala `/critical-code-review`, nie pushuje, nie merguje, nie robi `/kronikarz close`, nie weryfikuje własnych fixów jako „re-review".
- **Manager:** nie modyfikuje kodu produktowego (każdy fix idzie przez executora), nie merguje bez „akcept", nie zleca 3. rundy re-review zamiast decyzji usera.
