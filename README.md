# docker-gbrain

Configuração Docker para o GBrain com Ollama e PostgreSQL + pgvector.

## Configuração

Crie o arquivo `.env` a partir do exemplo:

```sh
cp .env.example .env
```

Gere dois segredos hexadecimais independentes, um para o PostgreSQL e outro
para a administração do GBrain:

```sh
# GBRAIN_POSTGRES_PASSWORD
openssl rand -hex 32

# GBRAIN_ADMIN_BOOTSTRAP_TOKEN
openssl rand -hex 32
```

Copie cada valor para a variável correspondente no `.env`:

```dotenv
GBRAIN_POSTGRES_PASSWORD=valor-do-primeiro-comando
GBRAIN_ADMIN_BOOTSTRAP_TOKEN=valor-do-segundo-comando
OLLAMA_EMBEDDING_MODEL=qwen3-embedding:0.6b-q8_0
OLLAMA_CHAT_MODEL=qwen3:4b-instruct-2507-q8_0
```

Cada modelo é definido uma única vez, sem o prefixo `ollama:`. O Compose usa o
mesmo valor para baixar o modelo no `pre_start` e adiciona o prefixo ao
repassá-lo para o GBrain.

O `GBRAIN_ADMIN_BOOTSTRAP_TOKEN` é uma credencial de administrador. Não o
compartilhe, não o inclua em logs e não versione o arquivo `.env`.

Depois, inicie os serviços:

```sh
docker compose up -d --build
docker compose logs -f gbrain
```

O PostgreSQL fica acessível somente aos containers da rede `local`; a porta
5432 não é publicada no host. Os dados são persistidos no volume nomeado
`gbrain-postgres-data`.

Para conferir o engine após a inicialização:

```sh
docker compose exec gbrain gbrain engine status
docker compose exec gbrain gbrain doctor
```
