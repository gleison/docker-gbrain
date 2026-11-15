#!/bin/sh
set -eu

GBRAIN_DIR="${GBRAIN_HOME:-$HOME/.gbrain}"
CONFIG_FILE="$GBRAIN_DIR/config.json"

EMBEDDING_MODEL="${GBRAIN_EMBEDDING_MODEL:-}"
CHAT_MODEL="${GBRAIN_CHAT_MODEL:-}"
GBRAIN_DB_URL="${GBRAIN_DATABASE_URL:-}"

if [ -z "$EMBEDDING_MODEL" ]; then
    echo "[ERRO] GBRAIN_EMBEDDING_MODEL não foi definida."
    exit 1
fi

if [ -z "$CHAT_MODEL" ]; then
    echo "[ERRO] GBRAIN_CHAT_MODEL não foi definida."
    exit 1
fi

if [ -z "$GBRAIN_DB_URL" ]; then
    echo "[ERRO] GBRAIN_DATABASE_URL não foi definida."
    exit 1
fi

echo "[GBrain] Verificando configuração..."

if [ ! -f "$CONFIG_FILE" ]; then
    if [ -d "$GBRAIN_DIR" ] &&
       [ -n "$(ls -A "$GBRAIN_DIR")" ]; then
        echo "[ERRO] Configuração ausente, mas o diretório contém dados."
        echo "[ERRO] Verifique o volume antes de inicializar."
        exit 1
    fi

    echo "[GBrain] Primeira inicialização..."

    gbrain init \
        --url "$GBRAIN_DB_URL" \
        --embedding-model "$EMBEDDING_MODEL" \
        --embedding-dimensions 1024 \
        --non-interactive
else

    echo "[GBrain] Configuração existente encontrada."

    if [ ! -s "$CONFIG_FILE" ]; then

        echo "[ERRO] Arquivo de configuração vazio."

        exit 1
    fi
fi

gbrain config set memory.auto_writeback salient
gbrain config set models.chat "$CHAT_MODEL"
gbrain config set facts.extraction_model "$CHAT_MODEL"
gbrain config set models.expansion "$CHAT_MODEL"
gbrain config set agent.use_gateway_loop true
gbrain config set search.reranker.enabled false
gbrain config set embedding_query_prefix $'Instruct: Given a web search query, retrieve relevant passages that answer the query\nQuery:'

echo "[GBrain] Iniciando servidor MCP..."

exec gbrain serve \
    --http \
    --bind 0.0.0.0 \
    --port 8787
