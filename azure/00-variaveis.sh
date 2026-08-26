#!/usr/bin/env bash
# =============================================================================
# 00-variaveis.sh - Variaveis usadas por todos os scripts desta pasta.
# Este script e "sourced" (nao executado diretamente) pelos demais:
#   source ./00-variaveis.sh
# =============================================================================
set -euo pipefail

# --------------------------- PREENCHA AQUI ----------------------------------
# RM do representante do grupo (usado como prefixo obrigatorio no nome das
# imagens e dos ACIs, conforme exigido no checkpoint).
export RM="562248"

# Nome do grupo (usado so para deixar os recursos identificaveis)
export NOME_GRUPO="dimdim"        # nome do projeto (tema do checkpoint); nome do grupo = SanSao (ver README/folha de rosto)

# Regiao do Azure (Brazil South e a mais proxima; troque se preferir outra)
export LOCATION="brazilsouth"
# -----------------------------------------------------------------------------

# --- Nomes derivados (normalmente nao precisam ser alterados) ---------------
RM_LOWER=$(echo "${RM}" | tr '[:upper:]' '[:lower:]')

export RESOURCE_GROUP="${RM_LOWER}-${NOME_GRUPO}-rg"

# Nome do ACR: apenas letras/numeros (sem hifen), 5-50 chars, globalmente unico
export ACR_NAME="${RM_LOWER}${NOME_GRUPO}acr"

# Nome da Storage Account: apenas letras minusculas/numeros, ate 24 chars, unico
export STORAGE_ACCOUNT="${RM_LOWER}${NOME_GRUPO}sa"
export STORAGE_SHARE="dbdata"

# Nomes das imagens (prefixo RM obrigatorio)
export IMAGE_APP="${RM_LOWER}-dimdim-app"
export IMAGE_DB="${RM_LOWER}-dimdim-db"
export IMAGE_TAG="1.0"

# Nomes dos Azure Container Instances (prefixo RM obrigatorio)
export ACI_APP_NAME="${RM_LOWER}-dimdim-app"
export ACI_DB_NAME="${RM_LOWER}-dimdim-db"

# DNS labels publicos (precisam ser unicos em toda a Azure - se der erro de
# "already in use", acrescente algo mais, ex: "${RM_LOWER}-dimdim-app-01")
export DNS_LABEL_APP="${RM_LOWER}-dimdim-app"
export DNS_LABEL_DB="${RM_LOWER}-dimdim-db"

# --- Credenciais do banco -----------------------------------------------------
# NUNCA deixe a senha real neste arquivo se ele for commitado.
# Prefira exportar via variavel de ambiente antes de rodar os scripts, ex:
#   export DB_USER=dimdim
#   export DB_PASSWORD='minhaSenhaForte123!'
#   source ./00-variaveis.sh
# Os valores abaixo so entram em vigor se voce NAO tiver exportado antes.
export DB_USER="${DB_USER:-dimdim}"
export DB_PASSWORD="${DB_PASSWORD:?Defina a variavel DB_PASSWORD antes de rodar os scripts (export DB_PASSWORD='...')}"

echo "Variaveis carregadas:"
echo "  RESOURCE_GROUP   = ${RESOURCE_GROUP}"
echo "  ACR_NAME         = ${ACR_NAME}"
echo "  STORAGE_ACCOUNT  = ${STORAGE_ACCOUNT}"
echo "  ACI_APP_NAME     = ${ACI_APP_NAME}"
echo "  ACI_DB_NAME      = ${ACI_DB_NAME}"
