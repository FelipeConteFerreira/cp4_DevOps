#!/usr/bin/env bash
# =============================================================================
# 08-testar-nuvem.sh - Ajuda a testar a solucao ja rodando na nuvem:
#  - Chama a API publica (App)
#  - Abre um shell dentro do container do Banco para rodar SELECT direto
#    (evidencia de persistencia pedida no checkpoint)
# =============================================================================
set -euo pipefail
cd "$(dirname "$0")"
source ./00-variaveis.sh

APP_FQDN=$(az container show \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${ACI_APP_NAME}" \
  --query "ipAddress.fqdn" -o tsv)

echo "==> Health check"
curl -s "http://${APP_FQDN}:8080/health"; echo

echo ""
echo "==> Listar transacoes (GET)"
curl -s "http://${APP_FQDN}:8080/api/transacoes"; echo

echo ""
echo "==> Criar transacao (POST) usando tests/post_transacao.json"
curl -s -X POST "http://${APP_FQDN}:8080/api/transacoes" \
  -H "Content-Type: application/json" \
  -d @../tests/post_transacao.json; echo

echo ""
echo "==> Para conferir diretamente no banco com SELECT, abra um shell no"
echo "    container do banco e rode o psql (use no video de evidencia):"
echo ""
echo "    az container exec --resource-group ${RESOURCE_GROUP} --name ${ACI_DB_NAME} --exec-command \"psql -U ${DB_USER} -d dimdimdb -c 'SELECT * FROM transacoes;'\""
