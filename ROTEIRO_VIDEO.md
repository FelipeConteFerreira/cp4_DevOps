# Roteiro do Vídeo — Checkpoint Containers em Nuvem (Projeto DimDim)

Duração estimada: 8 a 12 minutos. Grave em pelo menos 720p, com áudio
claro e narrando (explicando em voz) tudo o que está acontecendo — isso
é regra explícita do enunciado e vale pontos (-30 se faltar).

Sugestão de ferramentas: OBS Studio, gravação de tela nativa do
Windows/Mac, ou Teams/Zoom gravando a própria tela. Confira a resolução
e teste o áudio antes de gravar a versão final.

---

## 0. Antes de apertar "gravar" (checklist de preparação)

- [ ] Todos os recursos Azure já criados (rode `azure/01` até `azure/07`)
- [ ] `azure/08-testar-nuvem.sh` já rodado uma vez para confirmar que a API
      na nuvem responde e o FQDN do App está anotado
- [ ] Terminal com fonte grande o suficiente para ler na gravação
- [ ] Repositório GitHub já com o push feito (código, Dockerfiles, scripts,
      DDL, JSONs de teste, README)
- [ ] Feche abas/apps com informação sensível (senhas, tokens, outras contas)
- [ ] Tenha à mão: portal do Azure aberto, terminal, editor com o código,
      e o arquivo `tests/*.json`

---

## 1. Abertura — Recursos criados no Azure (obrigatório ser a PRIMEIRA coisa do vídeo)

**Fala sugerida:** "Oi, esse é o vídeo de demonstração do checkpoint de
Containers em Nuvem do grupo SanSao, RM 562248. Vou começar
mostrando os recursos que criamos no Azure, todos via Azure CLI."

No **Portal do Azure** (só para visualizar — a criação foi via CLI),
mostre em sequência, apontando e falando o nome de cada um:

1. O **Resource Group** (`<rm>-dimdim-rg`)
2. O **Azure Container Registry** — entre nele e mostre as duas imagens
   registradas (`<rm>-dimdim-app` e `<rm>-dimdim-db`), com o prefixo do RM
   visível no nome
3. A **Storage Account** e o **File Share** usado para persistir os dados
   do banco
4. Os dois **Azure Container Instances** (`<rm>-dimdim-app` e
   `<rm>-dimdim-db`), mostrando que estão com status "Running"

---

## 2. Código-fonte e repositório GitHub

**Fala sugerida:** "Agora vou mostrar rapidamente a estrutura do projeto
no GitHub."

- Abra o repositório no navegador ou no editor
- Mostre rapidamente: `app/` (código .NET), `db/` (Dockerfile do banco),
  `ddl/ddl.sql`, `azure/` (scripts CLI), `tests/` (JSONs)
- Abra o `app/Dockerfile` e aponte a linha `USER dimdimuser`, explicando
  que o container do App **não roda como root/admin**
- Abra o `db/Dockerfile` e explique que o banco é PostgreSQL (não H2),
  com o DDL aplicado automaticamente na inicialização

---

## 3. Build e push das imagens (docker build / docker push)

**Fala sugerida:** "Esses foram os comandos usados para gerar as imagens
localmente e publicar no ACR."

- Abra `azure/04-build-push-imagens.sh` e mostre os comandos
  `docker build`, `docker tag` e `docker push`
- Se quiser, rode `docker images` no terminal para mostrar as imagens
  locais, ou re-execute o script ao vivo (não obrigatório, mas reforça a
  evidência)

---

## 4. Scripts Azure CLI usados para criar os recursos

**Fala sugerida:** "Todos os recursos foram criados via Azure CLI, sem
usar o Portal. Esses são os scripts, na ordem em que foram executados."

- Percorra rapidamente os arquivos em `azure/`: `02-criar-resource-group.sh`,
  `03-criar-acr.sh`, `05-criar-storage-account.sh`, `06-criar-aci-banco.sh`,
  `07-criar-aci-app.sh`
- Não precisa reexecutar tudo ao vivo (levaria minutos) — mostrar o
  conteúdo dos scripts já é suficiente, já que os recursos foram exibidos
  rodando no passo 1

---

## 5. Testando a API pública na nuvem

**Fala sugerida:** "Agora vou testar a API que está rodando no ACI, já
acessível publicamente."

```bash
curl http://<DNS_LABEL_APP>.<regiao>.azurecontainer.io:8080/health
```

Mostre a resposta confirmando que a API e o banco estão de pé.

---

## 6. Demonstração individual de cada operação do CRUD (a parte mais importante)

Regra do enunciado: **demonstração detalhada e individual de todas as
operações do CRUD diretamente no Banco de Dados por SELECT.** Ou seja,
para CADA operação abaixo, faça a chamada na API e, na sequência, rode um
`SELECT` no banco mostrando o resultado. Não pule esse passo — é a maior
penalidade do checklist (-30 pontos se faltar evidência clara).

Comando para abrir o banco e rodar `SELECT` a qualquer momento:

```bash
az container exec --resource-group <RESOURCE_GROUP> --name <rm>-dimdim-db \
  --exec-command "psql -U dimdim -d dimdimdb -c 'SELECT * FROM transacoes;'"
```

### 6.1 GET (listar)

- Rode `curl http://<APP_FQDN>:8080/api/transacoes`
- Fale: "aqui temos a listagem atual das transações"
- Rode o `SELECT * FROM transacoes;` no banco e mostre que os dados batem
  com o retorno da API

### 6.2 POST (criar)

- Mostre o conteúdo de `tests/post_transacao.json`
- Rode:
  ```bash
  curl -X POST http://<APP_FQDN>:8080/api/transacoes \
    -H "Content-Type: application/json" \
    -d @tests/post_transacao.json
  ```
- Anote o `id` retornado
- Rode o `SELECT * FROM transacoes;` de novo e aponte a **nova linha**
  que acabou de aparecer — essa é a evidência de persistência

### 6.3 PUT (atualizar)

- Mostre o conteúdo de `tests/put_transacao.json`
- Rode (troque `{id}` pelo id criado no passo anterior):
  ```bash
  curl -X PUT http://<APP_FQDN>:8080/api/transacoes/{id} \
    -H "Content-Type: application/json" \
    -d @tests/put_transacao.json
  ```
- Rode o `SELECT` de novo e aponte a **linha alterada** (ex: campo
  `status` mudou de `PENDENTE` para `CONCLUIDA`)

### 6.4 DELETE (remover)

- Rode:
  ```bash
  curl -X DELETE http://<APP_FQDN>:8080/api/transacoes/{id}
  ```
- Rode o `SELECT` mais uma vez e mostre que a linha **sumiu** da tabela

---

## 7. Encerramento

**Fala sugerida:** "Com isso, demonstramos o CRUD completo rodando em
containers na nuvem, com o app e o banco publicados no ACR e executando
em ACIs separados, e os dados do banco persistidos na Storage Account.
Obrigado!"

- Repita rapidamente: nome do grupo, RM do representante, link do GitHub
  (aparece também na folha de rosto em PDF)

---

## Checklist final antes de exportar/enviar o vídeo

- [ ] Resolução mínima 720p
- [ ] Áudio audível do início ao fim
- [ ] Vídeo começa mostrando os recursos criados no Azure
- [ ] `docker build` / `docker push` aparecem no vídeo
- [ ] As 4 operações do CRUD foram demonstradas **individualmente**, cada
      uma seguida do `SELECT` correspondente no banco
- [ ] Nenhuma senha/token real aparece na tela (esconda se necessário)
- [ ] Link do vídeo funciona e o professor tem acesso (upload público ou
      permissão liberada — "professor sem acesso = nota zero")
