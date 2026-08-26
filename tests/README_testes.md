# Como usar estes arquivos de teste

A API do checkpoint (`GET`, `POST`, `PUT`, `DELETE` em `/api/transacoes`) usa
JSON no corpo da requisição para `POST` e `PUT`. `GET` e `DELETE` não
precisam de corpo — por isso não há arquivo JSON para eles, só o endpoint.

Substitua `<HOST>` pelo endereço da API (`localhost:8080` no teste local, ou
o FQDN público do ACI do App na nuvem).

```bash
# GET - listar todas
curl http://<HOST>:8080/api/transacoes

# GET - buscar uma por id
curl http://<HOST>:8080/api/transacoes/1

# POST - criar (usa post_transacao.json)
curl -X POST http://<HOST>:8080/api/transacoes \
  -H "Content-Type: application/json" \
  -d @post_transacao.json

# PUT - atualizar (troque o id, usa put_transacao.json)
curl -X PUT http://<HOST>:8080/api/transacoes/1 \
  -H "Content-Type: application/json" \
  -d @put_transacao.json

# DELETE - remover (troque o id)
curl -X DELETE http://<HOST>:8080/api/transacoes/1
```
