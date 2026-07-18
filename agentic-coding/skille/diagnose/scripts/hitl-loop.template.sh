#!/usr/bin/env bash
# Pętla reprodukcji Human-in-the-Loop.
# Skopiuj ten plik, wyedytuj kroki poniżej i odpal.
# Agent uruchamia skrypt; user wykonuje prompty w terminalu.
#
# Użycie:
#   bash hitl-loop.template.sh
#
# Trzy helpery:
#   step "<instrukcja>"               → pokaż instrukcję, czekaj na Enter
#   capture VAR "<pytanie>"           → pokaż pytanie, zapisz jedną linię do VAR
#   capture_multiline VAR "<pytanie>" → zapisz wiele linii do VAR (koniec: samotna linia EOF)
#
# Na końcu, captured wartości są wypisane jako KEY=VALUE do parsowania przez agenta.

set -euo pipefail

step() {
  printf '\n>>> %s\n' "$1"
  read -r -p "    [Enter, gdy gotowe] " _
}

capture() {
  local var="$1" question="$2" answer
  printf '\n>>> %s\n' "$question"
  read -r -p "    > " answer
  printf -v "$var" '%s' "$answer"
}

capture_multiline() {
  # Czyta wiele linii aż do samotnej linii-sentinela "EOF".
  # Bezpieczne pod `set -euo pipefail`: warunek [[ ]] siedzi w `if`,
  # a `read` zwracające non-zero na Ctrl-D kończy pętlę bez wyjścia z shella.
  local var="$1" question="$2" line acc=""
  printf '\n>>> %s\n' "$question"
  printf '    (wklej treść; zakończ samotną linią: EOF)\n'
  while IFS= read -r line; do
    if [[ "$line" == "EOF" ]]; then
      break
    fi
    acc+="$line"$'\n'
  done
  printf -v "$var" '%s' "$acc"
}

# --- edytuj poniżej ---------------------------------------------------------

step "Otwórz aplikację na http://localhost:3000 i zaloguj się."

capture ERRORED "Kliknij przycisk 'Eksportuj'. Czy wyrzucił błąd? (y/n)"

capture_multiline ERROR_MSG "Wklej treść błędu (wieloliniowo, lub 'brak'):"

# --- edytuj powyżej ---------------------------------------------------------

printf '\n--- Captured ---\n'
printf 'ERRORED=%s\n' "$ERRORED"
printf 'ERROR_MSG=%s\n' "$ERROR_MSG"
