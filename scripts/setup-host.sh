#!/usr/bin/env bash
#
# Script de configuração de ambiente para compilação do IrisOS (Android 14)
#

set -e

echo "==> [IrisOS] Verificando e instalando ferramentas essenciais de compilação..."

PACKAGES=(
    bc bison build-essential ccache curl flex g++-multilib gcc-multilib
    git git-lfs gnupg gperf imagemagick lib32readline-dev lib32z1-dev
    libelf-dev liblz4-tool libncurses-dev libssl-dev libxml2 libxml2-utils
    lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev
)

if command -v apt-get &>/dev/null; then
    sudo apt-get update -y
    sudo apt-get install -y "${PACKAGES[@]}" || true
fi

# Configurar ccache para acelerar recompilações futuras
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
ccache -M 50G || true

# Configurar limites do sistema para compilação AOSP
if [ -f /etc/security/limits.conf ]; then
    echo "* soft nofile 65536" | sudo tee -a /etc/security/limits.conf > /dev/null || true
    echo "* hard nofile 65536" | sudo tee -a /etc/security/limits.conf > /dev/null || true
fi

echo "==> [IrisOS] Ambiente de compilação configurado com sucesso!"
