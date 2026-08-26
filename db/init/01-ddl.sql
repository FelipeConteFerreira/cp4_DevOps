-- =============================================================================
-- Projeto DimDim - Checkpoint Containers em Nuvem
-- DDL da(s) tabela(s) utilizadas no banco de dados relacional (PostgreSQL)
-- =============================================================================
-- Este mesmo script e copiado automaticamente para dentro da imagem do banco
-- (ver db/Dockerfile e db/init/01-ddl.sql) e executado pelo Postgres na
-- primeira inicializacao do container, criando a tabela "transacoes".
-- =============================================================================

CREATE TABLE IF NOT EXISTS transacoes (
    id              SERIAL PRIMARY KEY,
    descricao       VARCHAR(200)     NOT NULL,
    valor           NUMERIC(12, 2)   NOT NULL CHECK (valor > 0),
    remetente       VARCHAR(100)     NOT NULL,
    destinatario    VARCHAR(100)     NOT NULL,
    status          VARCHAR(20)      NOT NULL DEFAULT 'PENDENTE',
    data_transacao  TIMESTAMP        NOT NULL DEFAULT NOW()
);

-- Indice auxiliar para consultas por status (ex: relatorios de pendencias)
CREATE INDEX IF NOT EXISTS idx_transacoes_status ON transacoes (status);

-- Dado de exemplo opcional (comente/apague se nao quiser dado inicial)
INSERT INTO transacoes (descricao, valor, remetente, destinatario, status)
VALUES ('Transacao de teste inicial', 10.00, 'conta_a', 'conta_b', 'CONCLUIDA')
ON CONFLICT DO NOTHING;
