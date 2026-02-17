#!/usr/bin/env bash
set -Eeuo pipefail

# ==================================================
# ReconSubFinder v5.1 – Smart Subdomain Enumeration Framework
# Author: EthicalHackerJagadeesh
# ==================================================

VERSION="5.1"
PRG="ReconSubFinder"

# ---------------- COLORS ----------------
BOLD="\e[1m"
RED="\e[31m"
GREEN="\e[32m"
CYAN="\e[36m"
NC="\e[0m"

# ---------------- LOAD CONFIG ----------------
CONFIG_FILE="config.txt"
[[ -f "$CONFIG_FILE" ]] || { echo -e "${RED}[!] Missing config.txt${NC}"; exit 1; }
source "$CONFIG_FILE"

# ---------------- TEMP DIR ----------------
TMPDIR="$(mktemp -d)"
cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT

# ---------------- FLAGS ----------------
DOMAIN=""
SILENT=false
PARALLEL=false
HTTP_PROBE=false
OUTFILE=""

log() { $SILENT || echo -e "${GREEN}[+]${NC} $1"; }

# ---------------- SPINNER ----------------
spinner() {
  local msg="$1"
  while :; do
    for c in / - \\ \|; do
      printf "\r[%s] %s" "$c" "$msg"
      sleep 0.15
    done
  done
}

# ---------------- SMART ENV CHECK ----------------
RESOLVERS="$(realpath "$RESOLVERS" 2>/dev/null || true)"
WORDLIST_BIG="$HOME/best-dns-wordlist.txt"
WORDLIST_SMALL="$HOME/dns-small.txt"

RESOLVER_COUNT=0
[[ -f "$RESOLVERS" ]] && RESOLVER_COUNT=$(grep -E '^[0-9]+\.' "$RESOLVERS" | wc -l)

ENABLE_PUREDNS=false
PUREDNS_RATE=0
PUREDNS_TRUSTED=""

if [[ "$RESOLVER_COUNT" -eq 0 ]]; then
  ENABLE_PUREDNS=false
elif [[ "$RESOLVER_COUNT" -lt 3 ]]; then
  ENABLE_PUREDNS=true
  WORDLISTS="$WORDLIST_SMALL"
  PUREDNS_RATE=30
  PUREDNS_TRUSTED="--trusted-only"
elif [[ "$RESOLVER_COUNT" -lt 10 ]]; then
  ENABLE_PUREDNS=true
  WORDLISTS="$WORDLIST_SMALL"
  PUREDNS_RATE=80
else
  ENABLE_PUREDNS=true
  WORDLISTS="$WORDLIST_BIG"
  PUREDNS_RATE=300
fi

# ---------------- RUNNER ----------------
run() {
  local name="$1"; shift
  local outfile="$TMPDIR/$name.txt"

  if $SILENT; then
    "$@" >> "$OUTFILE" 2>/dev/null || true
    return
  fi

  spinner "$name" & local spid=$!
  "$@" > "$outfile" 2>/dev/null || true
  kill "$spid" 2>/dev/null || true
  printf "\r%-50s\n" " "
  echo -e "${BOLD}[*] $name${NC}: $(wc -l < "$outfile")"
}

# ---------------- TOOLS ----------------
Subfinder()   { run subfinder   subfinder -silent -d "$DOMAIN"; }
Amass()       { run amass       amass enum -passive -norecursive -d "$DOMAIN"; }
Assetfinder() { run assetfinder assetfinder --subs-only "$DOMAIN"; }
Chaos()       { run chaos       chaos -silent -key "$CHAOS_API_KEY" -d "$DOMAIN"; }
Findomain()   { run findomain   findomain -q -t "$DOMAIN"; }
Gau()         { run gau         bash -c "gau --subs $DOMAIN | unfurl -u domains"; }
Crtsh()       { run crtsh       bash -c "curl -sk 'https://crt.sh/?q=%.$DOMAIN&output=json' | jq -r '.[].name_value' | sed 's/\*\.//g'"; }

Puredns() {
  [[ "$ENABLE_PUREDNS" != true ]] && {
    echo -e "${RED}[!] Puredns skipped (no valid resolvers)${NC}"
    return
  }

  [[ ! -f "$WORDLISTS" ]] && {
    echo -e "${RED}[!] Wordlist missing: $WORDLISTS${NC}"
    return
  }

  run puredns puredns bruteforce "$WORDLISTS" "$DOMAIN" \
    --resolvers "$RESOLVERS" \
    --rate-limit "$PUREDNS_RATE" \
    $PUREDNS_TRUSTED
}

TOOLS=(
  Subfinder
  Amass
  Assetfinder
  Chaos
  Findomain
  Gau
  Crtsh
  Puredns
)

# ---------------- OUTPUT ----------------
finalize() {
  OUTFILE="${OUTFILE:-$DOMAIN-$(date +%F_%H%M).txt}"
  sort -u "$TMPDIR"/*.txt > "$OUTFILE"
  log "Final subdomains: $(wc -l < "$OUTFILE")"

  if $HTTP_PROBE; then
    httpx -silent -l "$OUTFILE" > "alive-$OUTFILE"
    log "Alive hosts: $(wc -l < "alive-$OUTFILE")"
  fi
}

# ---------------- ARGS ----------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--domain) DOMAIN="$2"; shift ;;
    -o|--output) OUTFILE="$2"; shift ;;
    -s|--silent) SILENT=true ;;
    -p|--parallel) PARALLEL=true ;;
    -hp|--http-probe) HTTP_PROBE=true ;;
    -v|--version) echo "ReconSubFinder v$VERSION | Author: EthicalHackerJagadeesh"; exit 0 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
  shift
done

[[ -z "$DOMAIN" ]] && { echo -e "${RED}[!] Domain required (-d)${NC}"; exit 1; }

# ---------------- BANNER ----------------
$SILENT || echo -e "${CYAN}
  ____                           _____       __     
 |  _ \\ ___  ___ ___  _ __      / ___/__  __/ /_ ___
 | |_) / _ \\/ __/ _ \\| '_ \\     \\__ \\/ / / / __/ _ \\
 |  _ <  __/ (_| (_) | | | |    ___/ / /_/ / /_/  __/
 |_| \\_\\___|\\___\\___/|_| |_|   /____/\\__,_/\\__/\\___/ v$VERSION

 ReconSubFinder – Advanced Subdomain Enumeration
 Author: EthicalHackerJagadeesh
${NC}"

echo -e "${CYAN}[i] Resolvers detected : $RESOLVER_COUNT${NC}"
echo -e "${CYAN}[i] Puredns enabled   : $ENABLE_PUREDNS${NC}"
echo -e "${CYAN}[i] Wordlist in use  : ${WORDLISTS:-N/A}${NC}"
echo -e "${CYAN}[i] Rate limit       : ${PUREDNS_RATE:-N/A}${NC}"

# ---------------- RUN ----------------
log "Target: $DOMAIN"

if $PARALLEL; then
  export -f "${TOOLS[@]}" run spinner
  export DOMAIN TMPDIR RESOLVERS WORDLISTS PUREDNS_RATE ENABLE_PUREDNS PUREDNS_TRUSTED
  parallel ::: "${TOOLS[@]}"
else
  for t in "${TOOLS[@]}"; do $t; done
fi

finalize
