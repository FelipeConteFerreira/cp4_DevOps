#!/usr/bin/env bash
# =============================================================================
# 07-criar-aci-app.sh - Cria o Azure Container Instance do APP (.NET) a
# partir da imagem registrada no ACR, apontando para o banco (script 06).
# =============================================================================
set -euo pipefail
cd "$(dirname "$0")"
source ./00-variaveis.sh

ACR_LOGIN_SERVER="${ACR_NAME}.azurecr.io"

ACR_USERNAME=$(az acr credential show --name "${ACR_NAME}" --query "username" -o tsv)
ACR_PASSWORD=$(az acr credential show --name "${ACR_NAME}" --query "passwords[0].value" -o tsv)

DB_FQDN=$(az container show \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${ACI_DB_NAME}" \
  --query "ipAddress.fqdn" -o tsv)

if [ -z "${DB_FQDN}" ]; then
  echo "Nao foi possivel obter o FQDN do ACI do banco. Rode 06-criar-aci-banco.sh primeiro." >&2
  exit 1
fi

CONNECTION_STRING="Host=${DB_FQDN};Port=5432;Database=dimdimdb;Username=${DB_USER};Password=${DB_PASSWORD}"

az container create \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${ACI_APP_NAME}" \
  --image "${ACR_LOGIN_SERVER}/${IMAGE_APP}:${IMAGE_TAG}" \
  --registry-login-server "${ACR_LOGIN_SERVER}" \
  --registry-username "${ACR_USERNAME}" \
  --registry-password "${ACR_PASSWORD}" \
  --os-type Linux \
  --cpu 1 \
  --memory 1 \
  --ports 8080 \
  --ip-address Public \
  --dns-name-label "${DNS_LABEL_APP}" \
  --secure-environment-variables DB_CONNECTION_STRING="${CONNECTION_STRING}" \
  --output table

APP_FQDN=$(az container show \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${ACI_APP_NAME}" \
  --query "ipAddress.fqdn" -o tsv)

echo ""
echo "ACI do App criado."
echo "API disponivel em: http://${APP_FQDN}:8080"
echo "Teste com:  curl http://${APP_FQDN}:8080/health"
