#!/bin/sh
set -eu

GBRAIN_DIR="${GBRAIN_HOME:-$HOME/.gbrain}"
CONFIG_FILE="$GBRAIN_DIR/config.json"

EMBEDDING_MODEL="${GBRAIN_EMBEDDING_MODEL:-ollama:qwen3-embedding:0.6b-q8_0}"
CHAT_MODEL="${GBRAIN_CHAT_MODEL:-ollama:qwen3:4b-instruct-2507-q8_0}"

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
        --pglite \
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

echo "[GBrain] Iniciando servidor MCP..."

exec gbrain serve \
    --http \
    --bind 0.0.0.0 \
    --port 8787
