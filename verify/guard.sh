#!/usr/bin/env bash
# Officina — controllo dei percorsi protetti. Eseguito SEMPRE dalla copia fidata (branch base),
# mai dalla copia candidata. Uso: guard.sh <base_sha> <head_sha> <agent:true|false> <dir_config_fidata>
# Esce con 1 se una PR dell'agente modifica cio' che determina l'esito della verifica.
set -euo pipefail
base="$1"; head="$2"; agent="$3"; cfg="$4"

pathspecs() { # una riga per pattern; commenti e righe vuote ignorati; confronto case-insensitive
  grep -v '^[[:space:]]*#' "$1" | sed '/^[[:space:]]*$/d' | sed 's/^/:(glob,icase)/'
}
mapfile -t immutable < <(pathspecs "$cfg/protected.txt")    # verificatore, CI, config: nessuna modifica
mapfile -t appendonly < <(pathspecs "$cfg/append-only.txt") # attesi e gold set: solo aggiunte di file regolari

violations=()
if [ "$agent" = "true" ]; then
  while IFS=$'\t' read -r status path; do
    [ -n "$path" ] && violations+=("IMMUTABILE $status $path")
  done < <(git diff --name-status --no-renames "$base" "$head" -- "${immutable[@]}")

  while IFS=$'\t' read -r status path; do
    [ -z "$path" ] && continue
    if [ "$status" != "A" ]; then violations+=("SOLO-AGGIUNTA $status $path"); continue; fi
    mode=$(git ls-tree "$head" -- "$path" | awk '{print $1}')
    [ "$mode" = "100644" ] || violations+=("SOLO-AGGIUNTA modo=$mode (link o eseguibile) $path")
  done < <(git diff --name-status --no-renames "$base" "$head" -- "${appendonly[@]}")
fi

# Informativo per il revisore umano: test esistenti modificati/rimossi, dipendenze cambiate.
mapfile -t attention < <(pathspecs "$cfg/attention.txt")
git diff --name-status --no-renames "$base" "$head" -- "${attention[@]}"   | awk -F'	' '$1!="A" || $2 ~ /lock/ {print "ATTENZIONE " $1 " " $2}' || true

if [ "${#violations[@]}" -gt 0 ]; then
  printf 'OFFICINA GUARD: FAIL\n'; printf '  %s\n' "${violations[@]}"
  printf 'Una modifica a verificatore, CI o attesi richiede una PR del responsabile.\n'
  exit 1
fi
echo "OFFICINA GUARD: PASS (agent=$agent)"
