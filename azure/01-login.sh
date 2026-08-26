#!/usr/bin/env bash
# =============================================================================
# 01-login.sh - Autentica no Azure via CLI
# =============================================================================
set -euo pipefail

az login

# Se sua conta tiver mais de uma assinatura, descomente e ajuste:
# az account set --subscription "NOME_OU_ID_DA_ASSINATURA"

az account show --output table
