#!/usr/bin/env bash
# =============================================================================
# 99-remover-recursos.sh - Remove TODOS os recursos criados (apaga o Resource
# Group inteiro). Use depois de gravar o video e finalizar a entrega, para
# nao continuar sendo cobrado pelo Azure.
# =============================================================================
set -euo pipefail
cd "$(dirname "$0")"
source ./00-variaveis.sh

read -p "Isso vai APAGAR o resource group '${RESOURCE_GROUP}' e tudo dentro dele. Confirma? (digite 'sim'): " CONFIRMA
if [ "${CONFIRMA}" != "sim" ]; then
  echo "Cancelado."
  exit 0
fi

az group delete --name "${RESOURCE_GROUP}" --yes --no-wait
echo "Remocao do resource group '${RESOURCE_GROUP}' foi disparada (rodando em background no Azure)."
