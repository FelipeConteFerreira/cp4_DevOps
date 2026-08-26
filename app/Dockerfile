# =============================================================================
# Dockerfile - App .NET (DimDim API)
# Build multi-stage: compila em uma imagem "sdk" e roda em uma imagem "runtime"
# menor. O container final NAO roda como root/admin (requisito do checkpoint).
# =============================================================================

# ---------- Etapa 1: build ----------
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY DimDimApi.csproj ./
RUN dotnet restore

COPY . .
RUN dotnet publish -c Release -o /app/publish --no-restore

# ---------- Etapa 2: runtime (imagem final, enxuta) ----------
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final

# Cria um usuario e grupo dedicados, sem privilegios administrativos
RUN addgroup --system dimdim \
    && adduser --system --ingroup dimdim --no-create-home dimdimuser

WORKDIR /app
COPY --from=build /app/publish .

# Garante que o usuario nao-root tenha permissao de leitura/execucao
RUN chown -R dimdimuser:dimdim /app

ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

# A partir daqui o processo passa a rodar como usuario comum, sem privilegios de root
USER dimdimuser

ENTRYPOINT ["dotnet", "DimDimApi.dll"]
