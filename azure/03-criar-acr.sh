#!/usr/bin/env bash
# =============================================================================
# 03-criar-acr.sh - Cria o Azure Container Registry (ACR) onde as imagens
# do App e do Banco serao registradas.
# =============================================================================
set -euo pipefail
cd "$(dirname "$0")"
source ./00-variaveis.sh

az acr create \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${ACR_NAME}" \
  --sku Basic \
  --admin-enabled true \
  --output table

echo ""
echo "ACR criado: ${ACR_NAME}.azurecr.io"
