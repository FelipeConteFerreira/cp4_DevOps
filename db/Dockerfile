# =============================================================================
# Dockerfile - Banco de Dados (PostgreSQL) - Projeto DimDim
# Estende a imagem oficial do Postgres apenas para embutir o script de DDL,
# que e executado automaticamente pelo entrypoint oficial na 1a inicializacao
# (mecanismo padrao do Postgres: arquivos .sql em /docker-entrypoint-initdb.d/).
# =============================================================================
FROM postgres:16-alpine

# Nome do banco criado automaticamente no primeiro start.
# Usuario e senha NAO sao definidos aqui (nao expor credenciais no codigo-fonte);
# sao passados como variaveis de ambiente no momento de rodar o container
# (docker run / docker compose / az container create).
ENV POSTGRES_DB=dimdimdb

# Script de criacao das tabelas (DDL) - roda automaticamente no 1o start
COPY init/01-ddl.sql /docker-entrypoint-initdb.d/01-ddl.sql

EXPOSE 5432
