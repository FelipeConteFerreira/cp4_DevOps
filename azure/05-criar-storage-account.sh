#!/usr/bin/env bash
# =============================================================================
# 05-criar-storage-account.sh - Cria a Conta de Armazenamento (Storage Account)
# e o File Share que serao usados para persistir os dados do banco (volume
# montado no ACI do banco), conforme exigido no checkpoint.
# =============================================================================
set -euo pipefail
cd "$(dirname "$0")"
source ./00-variaveis.sh

az storage account create \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${STORAGE_ACCOUNT}" \
  --location "${LOCATION}" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --output table

STORAGE_KEY=$(az storage account keys list \
  --resource-group "${RESOURCE_GROUP}" \
  --account-name "${STORAGE_ACCOUNT}" \
  --query "[0].value" -o tsv)

az storage share create \
  --name "${STORAGE_SHARE}" \
  --account-name "${STORAGE_ACCOUNT}" \
  --account-key "${STORAGE_KEY}" \
  --quota 5 \
  --output table

echo ""
echo "Storage Account criada: ${STORAGE_ACCOUNT}  |  File Share: ${STORAGE_SHARE}"
