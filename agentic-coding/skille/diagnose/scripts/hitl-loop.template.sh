#!/usr/bin/env bash
# Pętla reprodukcji Human-in-the-Loop.
# Skopiuj ten plik, wyedytuj kroki poniżej i odpal.
# Agent uruchamia skrypt; user wykonuje prompty w terminalu.
#
# Użycie:
#   bash hitl-loop.template.sh
#
# Dwa helpery:
#   step "<instrukcja>"          → pokaż instrukcję, czekaj na Enter
#   capture VAR "<pytanie>"      → pokaż pytanie, zapisz odpowiedź do VAR
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

# --- edytuj poniżej ---------------------------------------------------------

step "Otwórz aplikację na http://localhost:3000 i zaloguj się."

capture ERRORED "Kliknij przycisk 'Eksportuj'. Czy wyrzucił błąd? (y/n)"

capture ERROR_MSG "Wklej treść błędu (lub 'brak'):"

# --- edytuj powyżej ---------------------------------------------------------

printf '\n--- Captured ---\n'
printf 'ERRORED=%s\n' "$ERRORED"
printf 'ERROR_MSG=%s\n' "$ERROR_MSG"
