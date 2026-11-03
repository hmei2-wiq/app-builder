#!/usr/bin/env bash
# shipworthy-scan.sh — passive security audit for a deployed web app.
#
# The free "Is your app Shipworthy?" scanner (top-of-funnel; see
# openspec/context/shipworthy-strategy.md). Given a URL, it performs PASSIVE,
# read-only checks for the failure modes that plague AI-generated apps:
#   - secrets leaked into the HTML/JS bundle (service_role JWT, sk_live, AWS, ...)
#   - Supabase tables readable with no auth (Row-Level Security disabled)
#   - API endpoints returning data with no auth
#   - exposed source maps
#   - missing transport / security headers
#
# It NEVER writes, mutates, exploits, or brute-forces. Every request is a
# single read-only GET. Run it ONLY on apps you own or are authorized to test.
#
# Usage:
#   scripts/shipworthy-scan.sh <url> [--json] [--no-active] [--timeout N]
#
#   --json        emit a machine-readable JSON report instead of the human one
#   --no-active   skip the bounded unauthenticated read probes (headers/secrets only)
#   --timeout N   per-request timeout in seconds (default 10)
#
# Exit codes: 0 = shipworthy (score >= 85), 1 = issues found, 2 = usage error.

set -uo pipefail

OUTPUT=human
ACTIVE=1
TIMEOUT=10
URL=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json)       OUTPUT=json; shift;;
    --no-active)  ACTIVE=0; shift;;
    --timeout)    TIMEOUT="${2:-10}"; shift 2;;
    -h|--help)    grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0;;
    -*)           echo "unknown arg: $1" >&2; exit 2;;
    *)            URL="$1"; shift;;
  esac
done

[[ -z "$URL" ]] && { echo "ERROR: <url> required" >&2; echo "usage: $0 <url> [--json] [--no-active] [--timeout N]" >&2; exit 2; }
[[ "$URL" =~ ^https?:// ]] || URL="https://$URL"
URL="${URL%/}"

# ---- findings accumulator (newline-delimited JSON in a temp file) ----
FINDINGS="$(mktemp "${TMPDIR:-/tmp}/shipworthy.XXXXXX")"
trap 'rm -f "$FINDINGS" "$BODY" "$HDRS" 2>/dev/null' EXIT
BODY="$(mktemp "${TMPDIR:-/tmp}/shipworthy-body.XXXXXX")"
HDRS="$(mktemp "${TMPDIR:-/tmp}/shipworthy-hdrs.XXXXXX")"

# add_finding <severity> <code> <message>
add_finding() {
  jq -nc --arg sev "$1" --arg code "$2" --arg msg "$3" \
    '{severity:$sev, code:$code, message:$msg}' >>"$FINDINGS"
}

CURL=(curl -sS -L --max-time "$TIMEOUT" -A "shipworthy-scan/1.0 (+security audit)")

# ---- fetch root page + headers ----
HTTP_CODE="$("${CURL[@]}" -o "$BODY" -D "$HDRS" -w '%{http_code}' "$URL" 2>/dev/null)" || HTTP_CODE=000
EFFECTIVE_SCHEME="${URL%%://*}"

if [[ "$HTTP_CODE" == "000" ]]; then
  add_finding HIGH unreachable "Could not fetch $URL (timeout, DNS, or TLS failure)."
fi

# ---- check 1: transport security ----
if [[ "$EFFECTIVE_SCHEME" != "https" ]]; then
  add_finding HIGH no_https "Site served over plain HTTP — traffic and cookies are interceptable."
fi

# ---- check 2: security headers ----
hdr() { grep -i "^$1:" "$HDRS" 2>/dev/null | tail -1; }
[[ -z "$(hdr strict-transport-security)" && "$EFFECTIVE_SCHEME" == "https" ]] && \
  add_finding LOW no_hsts "Missing Strict-Transport-Security header."
[[ -z "$(hdr content-security-policy)" ]] && \
  add_finding MEDIUM no_csp "Missing Content-Security-Policy header (XSS exposure)."
[[ -z "$(hdr x-frame-options)$(hdr content-security-policy | grep -i frame-ancestors)" ]] && \
  add_finding LOW no_xfo "Missing X-Frame-Options / frame-ancestors (clickjacking exposure)."
[[ -z "$(hdr x-content-type-options)" ]] && \
  add_finding LOW no_xcto "Missing X-Content-Type-Options: nosniff."
[[ -z "$(hdr referrer-policy)" ]] && \
  add_finding LOW no_referrer "Missing Referrer-Policy header."

# ---- gather JS bundle text (root page + linked scripts, bounded) ----
ASSETS="$(mktemp "${TMPDIR:-/tmp}/shipworthy-assets.XXXXXX")"
cat "$BODY" >"$ASSETS" 2>/dev/null
# extract up to 12 script srcs
mapfile -t SCRIPTS < <(grep -oiE 'src="[^"]+\.js[^"]*"' "$BODY" 2>/dev/null | sed -E 's/^src="//; s/"$//' | head -12)
for s in "${SCRIPTS[@]:-}"; do
  [[ -z "$s" ]] && continue
  case "$s" in
    http*) asset_url="$s";;
    //*)   asset_url="${EFFECTIVE_SCHEME}:$s";;
    /*)    asset_url="${URL}${s}";;
    *)     asset_url="${URL}/${s}";;
  esac
  "${CURL[@]}" "$asset_url" 2>/dev/null >>"$ASSETS" || true
done

# ---- check 3: leaked secrets ----
scan_secret() { # <regex> <severity> <code> <human label>
  if grep -aoiE "$1" "$ASSETS" >/dev/null 2>&1; then
    add_finding "$2" "$3" "Possible $4 exposed in client-side bundle."
  fi
}
scan_secret 'sk_live_[0-9a-zA-Z]{16,}'        CRITICAL secret_stripe   "Stripe live secret key"
scan_secret 'rk_live_[0-9a-zA-Z]{16,}'        CRITICAL secret_stripe_rk "Stripe restricted live key"
scan_secret 'AKIA[0-9A-Z]{16}'                CRITICAL secret_aws      "AWS access key id"
scan_secret 'AIza[0-9A-Za-z_-]{35}'           HIGH     secret_gcp      "Google API key"
scan_secret 'ghp_[0-9A-Za-z]{36}'             CRITICAL secret_github   "GitHub personal access token"
scan_secret 'xox[baprs]-[0-9A-Za-z-]{10,}'    CRITICAL secret_slack    "Slack token"
scan_secret 'sk-(proj-)?[A-Za-z0-9_-]{20,}'   HIGH     secret_openai   "OpenAI API key"
scan_secret 'BEGIN [A-Z ]*PRIVATE KEY'        CRITICAL secret_pem      "PEM private key"

# JWT scan: decode payloads, flag any service_role token (Supabase admin key leak)
mapfile -t JWTS < <(grep -aoE 'eyJ[A-Za-z0-9_-]+\.eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+' "$ASSETS" 2>/dev/null | sort -u | head -20)
SUPA_URL=""; SUPA_ANON=""
b64url_decode() { local s="${1//-/+}"; s="${s//_//}"; local pad=$(( ${#s} % 4 )); [[ $pad -gt 0 ]] && s="$s$(printf '=%.0s' $(seq $((4-pad))))"; printf '%s' "$s" | base64 -d 2>/dev/null; }
for jwt in "${JWTS[@]:-}"; do
  [[ -z "$jwt" ]] && continue
  mid="$(printf '%s' "$jwt" | cut -d. -f2)"
  payload="$(b64url_decode "$mid" | head -c 4000)"
  role="$(printf '%s' "$payload" | jq -r '.role // empty' 2>/dev/null)"
  ref="$(printf '%s' "$payload" | jq -r '.ref // empty' 2>/dev/null)"
  if [[ "$role" == "service_role" ]]; then
    add_finding CRITICAL secret_service_role "Supabase service_role key (full DB admin) exposed in client bundle."
  fi
  if [[ "$role" == "anon" && -n "$ref" && -z "$SUPA_ANON" ]]; then
    SUPA_ANON="$jwt"; SUPA_URL="https://${ref}.supabase.co"
  fi
done
# fall back: explicit supabase URL in bundle
[[ -z "$SUPA_URL" ]] && SUPA_URL="$(grep -aoE 'https://[a-z0-9]+\.supabase\.co' "$ASSETS" 2>/dev/null | head -1)"

# ---- check 4: exposed source maps ----
mapfile -t MAPS < <(grep -aoE 'sourceMappingURL=[^ "'"'"']+\.map' "$ASSETS" 2>/dev/null | sed 's/sourceMappingURL=//' | head -5)
for m in "${MAPS[@]:-}"; do
  [[ -z "$m" ]] && continue
  case "$m" in http*) mu="$m";; /*) mu="${URL}${m}";; *) mu="${URL}/${m}";; esac
  mc="$("${CURL[@]}" -o /dev/null -w '%{http_code}' "$mu" 2>/dev/null)" || mc=000
  if [[ "$mc" == "200" ]]; then
    add_finding MEDIUM sourcemap "Source map reachable ($m) — leaks original source code."
    break
  fi
done

# ---- check 5 (active): Supabase RLS probe ----
if [[ "$ACTIVE" == "1" && -n "$SUPA_URL" && -n "$SUPA_ANON" ]]; then
  for tbl in users profiles customers accounts orders payments subscriptions posts messages todos; do
    resp="$("${CURL[@]}" -o - -w $'\n%{http_code}' \
      -H "apikey: $SUPA_ANON" -H "Authorization: Bearer $SUPA_ANON" \
      "$SUPA_URL/rest/v1/$tbl?select=*&limit=1" 2>/dev/null)" || resp=$'\n000'
    code="${resp##*$'\n'}"; data="${resp%$'\n'*}"
    if [[ "$code" == "200" ]]; then
      rows="$(printf '%s' "$data" | jq 'if type=="array" then length else 0 end' 2>/dev/null || echo 0)"
      if [[ "${rows:-0}" -gt 0 ]]; then
        add_finding CRITICAL rls_off "Table '$tbl' is readable with no auth (RLS disabled) — user data is public."
      else
        add_finding MEDIUM rls_open_empty "Table '$tbl' is queryable unauthenticated (empty now, but RLS likely off)."
      fi
    fi
  done
fi

# ---- check 6 (active): open API endpoints leaking data ----
if [[ "$ACTIVE" == "1" ]]; then
  for ep in /api/users /api/me /api/admin /api/customers /api/orders; do
    resp="$("${CURL[@]}" -o - -w $'\n%{http_code}' "$URL$ep" 2>/dev/null)" || resp=$'\n000'
    code="${resp##*$'\n'}"; data="${resp%$'\n'*}"
    if [[ "$code" == "200" ]]; then
      leaky="$(printf '%s' "$data" | jq -e 'if type=="array" then length>0 elif type=="object" then (keys|length)>0 else false end' >/dev/null 2>&1 && echo yes || echo no)"
      [[ "$leaky" == "yes" ]] && add_finding HIGH open_api "Endpoint $ep returns data with no authentication."
    fi
  done
fi

# ---- score ----
weight() { case "$1" in CRITICAL) echo 40;; HIGH) echo 20;; MEDIUM) echo 10;; LOW) echo 4;; *) echo 0;; esac; }
SCORE=100
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  sev="$(printf '%s' "$line" | jq -r '.severity')"
  SCORE=$(( SCORE - $(weight "$sev") ))
done < "$FINDINGS"
[[ $SCORE -lt 0 ]] && SCORE=0

if   [[ $SCORE -ge 85 ]]; then VERDICT="SHIPWORTHY"; EXIT=0
elif [[ $SCORE -ge 60 ]]; then VERDICT="NEEDS WORK"; EXIT=1
else                           VERDICT="NOT SHIPWORTHY"; EXIT=1
fi

N_CRIT="$(grep -c '"severity":"CRITICAL"' "$FINDINGS" 2>/dev/null || true)"; N_CRIT="${N_CRIT:-0}"
[[ "$N_CRIT" -gt 0 ]] && EXIT=1

# ---- emit ----
if [[ "$OUTPUT" == "json" ]]; then
  jq -s --arg url "$URL" --argjson score "$SCORE" --arg verdict "$VERDICT" \
    '{url:$url, score:$score, verdict:$verdict, findings:., counts:(group_by(.severity)|map({(.[0].severity):length})|add)}' \
    "$FINDINGS"
else
  echo "═══════════════════════════════════════════════════════════"
  echo "  Is your app Shipworthy?   $URL"
  echo "═══════════════════════════════════════════════════════════"
  printf "  Score: %s/100   Verdict: %s\n" "$SCORE" "$VERDICT"
  echo "───────────────────────────────────────────────────────────"
  if [[ -s "$FINDINGS" ]]; then
    for sev in CRITICAL HIGH MEDIUM LOW; do
      while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        msg="$(printf '%s' "$line" | jq -r '.message')"
        printf "  [%-8s] %s\n" "$sev" "$msg"
      done < <(grep "\"severity\":\"$sev\"" "$FINDINGS" 2>/dev/null)
    done
  else
    echo "  No issues detected by passive checks. (Not a guarantee — get a"
    echo "  full audit before trusting real user data to it.)"
  fi
  echo "═══════════════════════════════════════════════════════════"
fi

exit $EXIT
