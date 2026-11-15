# docker-gbrain

Configuração Docker para o GBrain com llama.cpp e PostgreSQL + pgvector.

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
LLAMA_CPP_IMAGE=ghcr.io/ggml-org/llama.cpp:server
LLAMA_EMBEDDING_ALIAS=Qwen3-Embedding-0.6B
LLAMA_EMBEDDING_MODEL=Qwen/${LLAMA_EMBEDDING_ALIAS}-GGUF:Q8_0
LLAMA_CHAT_ALIAS=Qwen3-4B-Instruct-2507
LLAMA_CHAT_MODEL=ggml-org/${LLAMA_CHAT_ALIAS}-Q8_0-GGUF:Q8_0
LLAMA_RERANKER_ALIAS=Qwen3-Reranker-0.6B
LLAMA_RERANKER_MODEL=ggml-org/${LLAMA_RERANKER_ALIAS}-Q8_0-GGUF:Q8_0
```

Cada alias é definido uma única vez e usado pelo GBrain como identificador do
modelo. As variáveis `*_MODEL` formam o endereço completo no Hugging Face e são
usadas pelo `-hf`. Três processos `llama-server` carregam, respectivamente, os
modelos de embedding, chat e reranking. Os GGUFs são baixados automaticamente
no primeiro start e o cache é persistido em `~/.tmp/.llama`.

O processo de chat é apresentado ao GBrain pelo recipe OpenAI-compatible
`lmstudio`, apenas para permitir uma URL separada da URL de embedding. O
runtime continua sendo `llama-server`; nenhum serviço LM Studio é executado.

O `GBRAIN_ADMIN_BOOTSTRAP_TOKEN` é uma credencial de administrador. Não o
compartilhe, não o inclua em logs e não versione o arquivo `.env`.

Depois, inicie os serviços:

```sh
docker compose up -d --build
docker compose logs -f llama-embedding llama-chat llama-reranker gbrain
```

O primeiro start pode demorar enquanto os três modelos são baixados. O GBrain
só inicia depois que os três endpoints e o PostgreSQL estiverem saudáveis.

## Recriação após remover o Ollama

Trocar o provider de embedding altera a assinatura dos vetores. Para esta
instalação de testes, pare os serviços e mova o estado anterior antes de subir
a configuração nova:

```sh
docker compose down
mv ~/.tmp/.gbrain ~/.tmp/.gbrain-ollama-backup
mv ~/.tmp/.postgresql ~/.tmp/.postgresql-ollama-backup
docker compose up -d --build
```

Os diretórios anteriores ficam preservados como backup. O cache antigo do
Ollama em `~/.tmp/.ollama` não é usado pela configuração nova.

O PostgreSQL fica acessível somente aos containers da rede `local`; a porta
5432 não é publicada no host.

Para conferir o engine após a inicialização:

```sh
docker compose exec gbrain gbrain engine status
docker compose exec gbrain gbrain models doctor
docker compose exec gbrain gbrain doctor
```
