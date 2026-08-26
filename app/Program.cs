using Npgsql;

var builder = WebApplication.CreateBuilder(args);

// ---------------------------------------------------------------------------
// Connection string: NUNCA hardcoded. Vem de variavel de ambiente.
// Local (docker compose):        definida no arquivo .env (nao versionado)
// Nuvem (Azure Container Instance): definida como env var segura no az container create
// ---------------------------------------------------------------------------
var connectionString = Environment.GetEnvironmentVariable("DB_CONNECTION_STRING");

if (string.IsNullOrWhiteSpace(connectionString))
{
    throw new InvalidOperationException(
        "Variavel de ambiente DB_CONNECTION_STRING nao foi definida. " +
        "Configure-a antes de iniciar a aplicacao (veja README.md).");
}

var dataSource = NpgsqlDataSource.Create(connectionString);
builder.Services.AddSingleton(dataSource);

// A API escuta na porta 8080 dentro do container (ver Dockerfile / ASPNETCORE_URLS).
var app = builder.Build();

// -------------------------- Health check simples ---------------------------
app.MapGet("/", () => Results.Ok(new
{
    app = "DimDim API",
    status = "online",
    timestampUtc = DateTime.UtcNow
}));

app.MapGet("/health", async (NpgsqlDataSource db) =>
{
    try
    {
        await using var conn = await db.OpenConnectionAsync();
        return Results.Ok(new { database = "ok" });
    }
    catch (Exception ex)
    {
        return Results.Problem($"Falha ao conectar no banco: {ex.Message}");
    }
});

// ------------------------------ CRUD Transacoes -----------------------------
// Tabela: transacoes (id, descricao, valor, remetente, destinatario, status, data_transacao)
// DDL completo em: ddl/ddl.sql (tambem aplicado automaticamente pelo container do banco)

var grupo = app.MapGroup("/api/transacoes");

// READ (lista todas)
grupo.MapGet("/", async (NpgsqlDataSource db) =>
{
    var lista = new List<TransacaoOutput>();

    await using var cmd = db.CreateCommand(
        "SELECT id, descricao, valor, remetente, destinatario, status, data_transacao " +
        "FROM transacoes ORDER BY id");

    await using var reader = await cmd.ExecuteReaderAsync();
    while (await reader.ReadAsync())
    {
        lista.Add(LerTransacao(reader));
    }

    return Results.Ok(lista);
});

// READ (busca por id)
grupo.MapGet("/{id:int}", async (int id, NpgsqlDataSource db) =>
{
    await using var cmd = db.CreateCommand(
        "SELECT id, descricao, valor, remetente, destinatario, status, data_transacao " +
        "FROM transacoes WHERE id = $1");
    cmd.Parameters.AddWithValue(id);

    await using var reader = await cmd.ExecuteReaderAsync();
    if (!await reader.ReadAsync())
    {
        return Results.NotFound(new { mensagem = $"Transacao {id} nao encontrada." });
    }

    return Results.Ok(LerTransacao(reader));
});

// CREATE
grupo.MapPost("/", async (TransacaoInput input, NpgsqlDataSource db) =>
{
    if (string.IsNullOrWhiteSpace(input.Descricao) || input.Valor <= 0 ||
        string.IsNullOrWhiteSpace(input.Remetente) || string.IsNullOrWhiteSpace(input.Destinatario))
    {
        return Results.BadRequest(new { mensagem = "Descricao, valor (>0), remetente e destinatario sao obrigatorios." });
    }

    await using var cmd = db.CreateCommand(
        "INSERT INTO transacoes (descricao, valor, remetente, destinatario, status) " +
        "VALUES ($1, $2, $3, $4, $5) " +
        "RETURNING id, descricao, valor, remetente, destinatario, status, data_transacao");

    cmd.Parameters.AddWithValue(input.Descricao);
    cmd.Parameters.AddWithValue(input.Valor);
    cmd.Parameters.AddWithValue(input.Remetente);
    cmd.Parameters.AddWithValue(input.Destinatario);
    cmd.Parameters.AddWithValue(input.Status ?? "PENDENTE");

    await using var reader = await cmd.ExecuteReaderAsync();
    await reader.ReadAsync();
    var criada = LerTransacao(reader);

    return Results.Created($"/api/transacoes/{criada.Id}", criada);
});

// UPDATE
grupo.MapPut("/{id:int}", async (int id, TransacaoInput input, NpgsqlDataSource db) =>
{
    await using var cmd = db.CreateCommand(
        "UPDATE transacoes SET descricao=$1, valor=$2, remetente=$3, destinatario=$4, status=$5 " +
        "WHERE id=$6 " +
        "RETURNING id, descricao, valor, remetente, destinatario, status, data_transacao");

    cmd.Parameters.AddWithValue(input.Descricao);
    cmd.Parameters.AddWithValue(input.Valor);
    cmd.Parameters.AddWithValue(input.Remetente);
    cmd.Parameters.AddWithValue(input.Destinatario);
    cmd.Parameters.AddWithValue(input.Status ?? "PENDENTE");
    cmd.Parameters.AddWithValue(id);

    await using var reader = await cmd.ExecuteReaderAsync();
    if (!await reader.ReadAsync())
    {
        return Results.NotFound(new { mensagem = $"Transacao {id} nao encontrada." });
    }

    return Results.Ok(LerTransacao(reader));
});

// DELETE
grupo.MapDelete("/{id:int}", async (int id, NpgsqlDataSource db) =>
{
    await using var cmd = db.CreateCommand("DELETE FROM transacoes WHERE id = $1");
    cmd.Parameters.AddWithValue(id);

    var linhasAfetadas = await cmd.ExecuteNonQueryAsync();
    if (linhasAfetadas == 0)
    {
        return Results.NotFound(new { mensagem = $"Transacao {id} nao encontrada." });
    }

    return Results.NoContent();
});

app.Run();

// ----------------------------- Tipos auxiliares -----------------------------

static TransacaoOutput LerTransacao(NpgsqlDataReader reader) => new(
    Id: reader.GetInt32(0),
    Descricao: reader.GetString(1),
    Valor: reader.GetDecimal(2),
    Remetente: reader.GetString(3),
    Destinatario: reader.GetString(4),
    Status: reader.GetString(5),
    DataTransacao: reader.GetDateTime(6)
);

record TransacaoInput(string Descricao, decimal Valor, string Remetente, string Destinatario, string? Status);

record TransacaoOutput(
    int Id,
    string Descricao,
    decimal Valor,
    string Remetente,
    string Destinatario,
    string Status,
    DateTime DataTransacao);
