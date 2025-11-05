#!/usr/bin/env bash
set -euo pipefail
# Usage: scripts/import_watchlist.sh <resource-group> <workspace-name> [csv_path]
RG="${1:-ugr-sec-rg}"
LAW="${2:-ugr-sec-law}"
CSV_PATH="${3:-osint/osint_watchlist.csv}"
ALIAS="osint_apt_watchlist"
echo "[*] Ensuring Azure CLI Sentinel extension is installed..."
az extension add --name sentinel -y >/dev/null 2>&1 || true
echo "[*] Creating/Updating watchlist '$ALIAS' from CSV '$CSV_PATH'"
az sentinel watchlist create   --resource-group "$RG"   --workspace-name "$LAW"   --name "$ALIAS"   --watchlist-alias "$ALIAS"   --display-name "OSINT APT Watchlist"   --provider Microsoft   --items-search-key SearchKey   --content-type text/csv   --source "$CSV_PATH"
echo "[✓] Watchlist '$ALIAS' loaded into workspace '$LAW'."
