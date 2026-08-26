#!/usr/bin/env bash
# =============================================================================
# 02-criar-resource-group.sh - Cria o Resource Group que vai agrupar todos
# os recursos do checkpoint (ACR, Storage Account, ACIs).
# =============================================================================
set -euo pipefail
cd "$(dirname "$0")"
source ./00-variaveis.sh

az group create \
  --name "${RESOURCE_GROUP}" \
  --location "${LOCATION}" \
  --output table
