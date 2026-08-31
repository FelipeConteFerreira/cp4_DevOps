# Projeto DimDim — Containers em Nuvem (Checkpoint)

Aplicação de exemplo (.NET 8 + PostgreSQL) containerizada e publicada no
**Azure Container Registry (ACR)** e executada em duas **Azure Container
Instances (ACI)** — uma para o App, outra para o Banco — com persistência
dos dados do banco em uma **Storage Account**.

> Este repositório é um **ponto de partida pronto para uso**: já implementa
> o CRUD completo, os Dockerfiles, os scripts Azure CLI e os arquivos de
> teste pedidos no checkpoint. Ajuste nomes, RM e credenciais conforme o seu
> grupo antes de gravar o vídeo de entrega.

## Arquitetura

```
                     ┌─────────────────────────────┐
                     │        Azure (nuvem)         │
                     │                               │
  docker build/push  │   ┌─────────┐    ┌─────────┐  │
  ────────────────►  │   │   ACR   │    │ Storage │  │
                     │   └────┬────┘    │ Account │  │
                     │        │         └────┬────┘  │
                     │        │ pull imagens  │volume │
                     │        ▼               ▼       │
                     │  ┌───────────┐   ┌───────────┐ │
   usuários ───────► │  │ ACI: App  │──►│ ACI: Banco│ │
                     │  │  (.NET)   │   │ (Postgres)│ │
                     │  └───────────┘   └───────────┘ │
                     └─────────────────────────────┘
```

## Estrutura do repositório

```
.
├── app/                    # Código-fonte da API .NET + Dockerfile do App
│   ├── Program.cs          # CRUD completo (GET/POST/PUT/DELETE)
│   ├── DimDimApi.csproj
│   └── Dockerfile          # Multi-stage, container roda sem privilégios de root
├── db/                     # Dockerfile do Banco (PostgreSQL) + script de init
│   ├── Dockerfile
│   └── init/01-ddl.sql
├── ddl/ddl.sql              # DDL das tabelas (entrega separada exigida no enunciado)
├── azure/                  # Scripts Azure CLI (ordem numerada) — todo recurso
│   ├── 00-variaveis.sh      # criado via CLI, nada pelo Portal
│   ├── 01-login.sh
│   ├── 02-criar-resource-group.sh
│   ├── 03-criar-acr.sh
│   ├── 04-build-push-imagens.sh
│   ├── 05-criar-storage-account.sh
│   ├── 06-criar-aci-banco.sh
│   ├── 07-criar-aci-app.sh
│   ├── 08-testar-nuvem.sh
│   └── 99-remover-recursos.sh
├── tests/                  # JSONs de teste (POST/PUT) + roteiro de testes
├── docker-compose.yml      # Build + execução LOCAL (antes de subir na nuvem)
├── .env.example            # Modelo de variáveis (copie para .env, não versionar)
```

## Pré-requisitos

- [.NET 8 SDK](https://dotnet.microsoft.com/download) (só necessário se quiser rodar a API fora de container)
- [Docker](https://www.docker.com/) com Docker Compose
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) (`az`) autenticado numa assinatura Azure
- Uma assinatura Azure ativa

---

## Parte 1 — Rodar e testar localmente

Esta é a etapa "Build das imagens localmente" + "Testar localmente" do
checkpoint, **antes** de subir qualquer coisa para a nuvem.

1. Copie o arquivo de variáveis de ambiente:

   ```bash
   cp .env.example .env
   # edite o .env e troque a senha padrão
   ```

2. Build das imagens e subida dos containers:

   ```bash
   docker compose build
   docker compose up -d
   ```

3. Verifique se subiu tudo:

   ```bash
   docker compose ps
   curl http://localhost:8080/health
   ```

4. Teste o CRUD completo:

   ```bash
   # Listar (deve vir a transação de exemplo inserida pelo DDL)
   curl http://localhost:8080/api/transacoes

   # Criar
   curl -X POST http://localhost:8080/api/transacoes \
     -H "Content-Type: application/json" \
     -d @tests/post_transacao.json

   # Atualizar (troque o id pelo id retornado no passo anterior)
   curl -X PUT http://localhost:8080/api/transacoes/2 \
     -H "Content-Type: application/json" \
     -d @tests/put_transacao.json

   # Remover
   curl -X DELETE http://localhost:8080/api/transacoes/2
   ```

5. Confirme a persistência **direto no banco**, com `SELECT` (é isso que o
   vídeo de entrega precisa mostrar, individualmente, para cada operação):

   ```bash
   docker exec -it dimdim-db-local psql -U dimdim -d dimdimdb -c "SELECT * FROM transacoes;"
   ```

Se tudo funcionou localmente, siga para a Parte 2.

---

## Parte 2 — Deploy na nuvem via Azure CLI

Todos os recursos abaixo são criados **exclusivamente via Azure CLI**
(nenhum passo pelo Portal), conforme exigido no checkpoint.

1. Abra `azure/00-variaveis.sh` e preencha o `RM` do representante do grupo.
   Depois, exporte a senha do banco (não fica salva em nenhum arquivo
   versionado) e faça login:

   ```bash
   export DB_PASSWORD='SanSao123!'
   cd azure
   ./01-login.sh
   ```

2. Crie o Resource Group:

   ```bash
   ./02-criar-resource-group.sh
   ```

3. Crie o Azure Container Registry (ACR):

   ```bash
   ./03-criar-acr.sh
   ```

4. Build local das imagens e push para o ACR
   (comandos `docker build` / `docker push` completos, conforme exigido):

   ```bash
   ./04-build-push-imagens.sh
   ```

5. Crie a Storage Account + File Share (persistência do banco):

   ```bash
   ./05-criar-storage-account.sh
   ```

6. Crie o ACI do Banco (imagem do ACR + volume da Storage Account montado):

   ```bash
   ./06-criar-aci-banco.sh
   ```

7. Crie o ACI do App (imagem do ACR + connection string apontando para o
   FQDN do banco criado no passo anterior):

   ```bash
   ./07-criar-aci-app.sh
   ```

8. Teste tudo já rodando na nuvem:

   ```bash
   ./08-testar-nuvem.sh
   ```

   Esse script chama a API pública do App e imprime o comando pronto para
   abrir um shell dentro do container do banco e rodar `SELECT` — grave essa
   parte no vídeo, para cada tabela/operação.

9. **Terminado o vídeo e a entrega**, remova os recursos para não continuar
   sendo cobrado:

   ```bash
   ./99-remover-recursos.sh
   ```

---

## Segurança / regras do checkpoint atendidas

- **Container do App não roda como root/admin**: o `app/Dockerfile` cria um
  usuário de sistema (`dimdimuser`) e troca para ele com `USER dimdimuser`
  antes do `ENTRYPOINT`.
- **Sem credenciais no código-fonte**: a connection string do banco vem
  exclusivamente da variável de ambiente `DB_CONNECTION_STRING`
  (`--secure-environment-variables` no ACI, `.env` — não versionado — no
  Docker Compose). O `.env` real está no `.gitignore`.
- **Banco não é H2**: PostgreSQL rodando em container próprio (`db/Dockerfile`).
- **DDL versionado**: `ddl/ddl.sql`, aplicado automaticamente pelo container
  do banco na primeira inicialização (`db/init/01-ddl.sql`).
- **Todos os recursos Azure criados via CLI**: scripts em `azure/`, nenhuma
  criação pelo Portal.

## O que gravar no vídeo (checklist)

1. Comece mostrando os recursos criados no Azure (Resource Group → ACR com
   as duas imagens → Storage Account/File Share → os dois ACIs rodando).
2. Mostre os comandos de `docker build` e `docker push` (podem ser
   reexecutados ao vivo ou mostrados no histórico do terminal).
3. Demonstre cada operação do CRUD (GET, POST, PUT, DELETE) chamando a API
   pública do App.
4. Para **cada** operação, mostre a evidência com `SELECT` direto no banco
   (via `az container exec` + `psql`), individualmente.
5. Explique tudo em voz, em pelo menos 720p.
