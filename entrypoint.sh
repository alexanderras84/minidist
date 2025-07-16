#!/bin/bash
set -e

echo "[INFO] Starting sing-box with dynamic config"

ROUTE_RULES=""

# Add domain_suffix rules
if [[ -n "$PROXY_DOMAIN_SUFFIXES" ]]; then
  for sfx in $(echo "$PROXY_DOMAIN_SUFFIXES" | tr ',' ' '); do
    ROUTE_RULES="${ROUTE_RULES}    { \"domain_suffix\": [\"$sfx\"], \"outbound\": \"smartstreaming\" },\n"
  done
fi

# Add domain_keyword rules
if [[ -n "$PROXY_DOMAIN_KEYWORDS" ]]; then
  for kw in $(echo "$PROXY_DOMAIN_KEYWORDS" | tr ',' ' '); do
    ROUTE_RULES="${ROUTE_RULES}    { \"domain_keyword\": [\"$kw\"], \"outbound\": \"smartstreaming\" },\n"
  done
fi

# Fallback rule
ROUTE_RULES="${ROUTE_RULES}    { \"outbound\": \"controld\" }"

# Fill in the template
envsubst < /singbox/config.template.json > /singbox/config.pre.json

# Inject rules into config.json
awk -v rules="$ROUTE_RULES" '
  /__ROUTE_RULES__/ { gsub(/__ROUTE_RULES__/, ""); print rules; next }
  { print }
' /singbox/config.pre.json > /singbox/config.json

exec /singbox/sing-box run -c /singbox/config.json
