#!/usr/bin/env bash
set -euo pipefail
# Deploy Azure Monitor Workbook for Sentinel KPIs
# Usage: scripts/deploy_workbook.sh <resource-group> <location> [display_name]
RG="${1:-ugr-sec-rg}"
LOC="${2:-eastus}"
NAME="${3:-UGR Lab Sentinel KPIs}"

FILE="sentinel/workbooks/ugr_lab_workbook.json"

echo "[*] Ensuring Azure CLI 'monitor' module is available..."
az -v >/dev/null

echo "[*] Creating workbook '$NAME' in RG '$RG' (location: $LOC)"
# Note: The command stores the workbook under Microsoft.Insights/workbooks
az monitor workbook create \
  --name "$NAME" \
  --resource-group "$RG" \
  --location "$LOC" \
  --display-name "$NAME" \
  --category "workbook" \
  --serialized-workbook @"$FILE"

echo "[✓] Workbook deployed. Open Azure Portal → Microsoft Sentinel → Workbooks."
