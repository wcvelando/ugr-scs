#!/usr/bin/env bash
set -euo pipefail
# Usage: scripts/create_dummy_incidents.sh <resource-group> <workspace-name>
RG="${1:-ugr-sec-rg}"
LAW="${2:-ugr-sec-law}"
echo "[*] Ensuring Azure CLI Sentinel extension is installed..."
az extension add --name sentinel -y >/dev/null 2>&1 || true
declare -a TITLES=(
  "UGR Training: Suspicious Sign-in (Manual)"
  "UGR Training: Privilege Change Review"
  "UGR Training: Possible Exfil via Storage"
  "UGR Training: Multiple Delete Ops"
  "UGR Training: IOC Mention (APT29)"
)
declare -a SEVS=(High Medium Low Medium Informational)
for i in "${!TITLES[@]}"; do
  ID=$(uuidgen | tr '[:upper:]' '[:lower:]')
  TITLE="${TITLES[$i]}"
  SEV="${SEVS[$i]}"
  echo "[*] Creating incident $((i+1))/5: $TITLE (Severity: $SEV)"
  az sentinel incident create     --resource-group "$RG"     --workspace-name "$LAW"     --incident-id "$ID"     --name "$ID"     --title "$TITLE"     --description "Manual training incident generated for lab validation."     --severity "$SEV"     --status New     --labels key=Lab value=UGR key=Type value=Manual >/dev/null
done
echo "[✓] 5 training incidents created. Review them in Microsoft Sentinel → Incidents."
