#!/usr/bin/env bash
# Officina — fail-to-pass. Dimostra che i test aggiunti/modificati dalla PR rilevano il difetto:
# devono FALLIRE sul codice base e PASSARE sul candidato. Dalla copia fidata.
# Uso: f2p.sh <dir_base> <dir_candidato> <base_sha> <head_sha> <comando_test_fidato> <enforce|report>
# enforce sui branch agent/fix-* (una correzione deve dimostrare il difetto); report altrove (refactor, nuove funzioni).
set -uo pipefail
basedir="$1"; cand="$2"; base="$3"; head="$4"; cmd="$5"; mode="${6:-report}"
mapfile -t tests < <(git -C "$cand" diff --name-only --no-renames --diff-filter=AM "$base" "$head" -- ':(glob,icase)tests/**' ':(glob,icase)**/*.test.*')
if [ "${#tests[@]}" -eq 0 ]; then
  if [ "$mode" = "enforce" ]; then echo "F2P: FAIL correzione senza test che riproduca il difetto"; exit 1; fi
  echo "F2P: NOT APPLICABLE (nessun test aggiunto o modificato)"; exit 0; fi
for t in "${tests[@]}"; do mkdir -p "$basedir/$(dirname "$t")"; cp "$cand/$t" "$basedir/$t"; done
(cd "$basedir" && eval "$cmd ${tests[*]}") >/dev/null 2>&1; onbase=$?
(cd "$cand" && eval "$cmd ${tests[*]}") >/dev/null 2>&1; oncand=$?
echo "F2P: test=${tests[*]} exit_base=$onbase exit_candidato=$oncand"
if [ "$onbase" -ne 0 ] && [ "$oncand" -eq 0 ]; then echo "F2P: PASS"; exit 0; fi
[ "$oncand" -ne 0 ] && echo "F2P: FAIL i nuovi test non passano sul candidato"
[ "$onbase" -eq 0 ] && echo "F2P: FAIL i nuovi test passano gia' sul codice base: non dimostrano il difetto"
[ "$mode" = "enforce" ] && exit 1
echo "F2P: (solo segnalazione, mode=$mode)"; exit 0
