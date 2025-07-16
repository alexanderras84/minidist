#!/bin/bash
set -e

echo "[INFO] Starting sing-box..."

# Validate required env vars
REQUIRED_VARS=("SUBDOMAIN" "RESOLVER_ID" "SMARTSTREAMING_DNS")
for var in "${REQUIRED_VARS[@]}"; do
  if [[ -z "${!var}" ]]; then
    echo "[ERROR] Missing required environment variable: $var"
    exit 1
  fi
done

# Build dynamic routing rules from env vars
RULES=""

# domain_suffix rules
if [[ -n "$PROXY_DOMAIN_SUFFIXES" ]]; then
  for sfx in $(echo "$PROXY_DOMAIN_SUFFIXES" | tr ',' ' '); do
    RULES="${RULES}    { \"domain_suffix\": [\"$sfx\"], \"outbound\": \"smartstreaming\" },\n"
  done
fi

# domain_keyword rules
if [[ -n "$PROXY_DOMAIN_KEYWORDS" ]]; then
  for kw in $(echo "$PROXY_DOMAIN_KEYWORDS" | tr ',' ' '); do
    RULES="${RULES}    { \"domain_keyword\": [\"$kw\"], \"outbound\": \"smartstreaming\" },\n"
  done
fi

# Fallback rule (ControlD)
RULES="${RULES}    { \"outbound\": \"controld\" }"

# Export variables for envsubst
export SUBDOMAIN
export RESOLVER_ID
export SMARTSTREAMING_DNS
export ROUTE_RULES="${RULES}"

# Substitute everything into config.json
envsubst < /singbox/config.template.json > /singbox/config.json

exec /singbox/sing-box run -c /singbox/config.json
