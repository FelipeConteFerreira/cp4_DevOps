#!/usr/bin/env bash
# =============================================================================
# 06-criar-aci-banco.sh - Cria o Azure Container Instance do BANCO DE DADOS
# a partir da imagem registrada no ACR, com o volume da Storage Account
# montado no diretorio de dados do Postgres (persistencia).
# =============================================================================
set -euo pipefail
cd "$(dirname "$0")"
source ./00-variaveis.sh

ACR_LOGIN_SERVER="${ACR_NAME}.azurecr.io"

ACR_USERNAME=$(az acr credential show --name "${ACR_NAME}" --query "username" -o tsv)
ACR_PASSWORD=$(az acr credential show --name "${ACR_NAME}" --query "passwords[0].value" -o tsv)

STORAGE_KEY=$(az storage account keys list \
  --resource-group "${RESOURCE_GROUP}" \
  --account-name "${STORAGE_ACCOUNT}" \
  --query "[0].value" -o tsv)

az container create \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${ACI_DB_NAME}" \
  --image "${ACR_LOGIN_SERVER}/${IMAGE_DB}:${IMAGE_TAG}" \
  --registry-login-server "${ACR_LOGIN_SERVER}" \
  --registry-username "${ACR_USERNAME}" \
  --registry-password "${ACR_PASSWORD}" \
  --os-type Linux \
  --cpu 1 \
  --memory 1.5 \
  --ports 5432 \
  --ip-address Public \
  --dns-name-label "${DNS_LABEL_DB}" \
  --secure-environment-variables \
      POSTGRES_USER="${DB_USER}" \
      POSTGRES_PASSWORD="${DB_PASSWORD}" \
  --azure-file-volume-account-name "${STORAGE_ACCOUNT}" \
  --azure-file-volume-account-key "${STORAGE_KEY}" \
  --azure-file-volume-share-name "${STORAGE_SHARE}" \
  --azure-file-volume-mount-path "/var/lib/postgresql/data" \
  --output table

DB_FQDN=$(az container show \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${ACI_DB_NAME}" \
  --query "ipAddress.fqdn" -o tsv)

echo ""
echo "ACI do banco criado. FQDN: ${DB_FQDN}"
echo "Guarde esse valor - ele sera usado na connection string do App (script 07)."
