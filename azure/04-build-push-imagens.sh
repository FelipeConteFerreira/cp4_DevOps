#!/usr/bin/env bash
# =============================================================================
# 04-build-push-imagens.sh - Build LOCAL das imagens (docker build) e envio
# para o ACR em nuvem (docker push). Etapas 3, 4 e 6 do checkpoint.
#
# Pre-requisito: ja ter testado localmente com "docker compose up" (ver README)
# antes de subir para a nuvem.
# =============================================================================
set -euo pipefail
cd "$(dirname "$0")"
source ./00-variaveis.sh

RAIZ_PROJETO="$(cd .. && pwd)"
ACR_LOGIN_SERVER="${ACR_NAME}.azurecr.io"

echo ">>> Autenticando o Docker no ACR..."
az acr login --name "${ACR_NAME}"

# --------------------------- Imagem do APP ----------------------------------
echo ""
echo ">>> docker build - App (.NET)"
docker build -t "${IMAGE_APP}:${IMAGE_TAG}" "${RAIZ_PROJETO}/app"

echo ">>> docker tag - App"
docker tag "${IMAGE_APP}:${IMAGE_TAG}" "${ACR_LOGIN_SERVER}/${IMAGE_APP}:${IMAGE_TAG}"

echo ">>> docker push - App"
docker push "${ACR_LOGIN_SERVER}/${IMAGE_APP}:${IMAGE_TAG}"

# --------------------------- Imagem do BANCO --------------------------------
echo ""
echo ">>> docker build - Banco (PostgreSQL)"
docker build -t "${IMAGE_DB}:${IMAGE_TAG}" "${RAIZ_PROJETO}/db"

echo ">>> docker tag - Banco"
docker tag "${IMAGE_DB}:${IMAGE_TAG}" "${ACR_LOGIN_SERVER}/${IMAGE_DB}:${IMAGE_TAG}"

echo ">>> docker push - Banco"
docker push "${ACR_LOGIN_SERVER}/${IMAGE_DB}:${IMAGE_TAG}"

echo ""
echo ">>> Imagens registradas no ACR:"
az acr repository list --name "${ACR_NAME}" --output table
