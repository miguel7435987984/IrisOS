#!/usr/bin/env bash
#
# Script mestre de compilação do IrisOS (Mobile & PC)
#

set -e

TARGET="${1:-garnet}"
VARIANT="${2:-userdebug}"
WORKDIR="${WORKDIR:-$HOME/android/irisos}"

echo "=============================================="
echo "    Iniciando Pipeline de Build do IrisOS     "
echo "=============================================="
echo "  Alvo:          ${TARGET}"
echo "  Variante:      ${VARIANT}"
echo "  Diretório:     ${WORKDIR}"
echo "=============================================="

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# 1. Inicializar repositório base com --depth=1 (economia de espaço)
if [ ! -d ".repo" ]; then
    echo "==> Inicializando manifesto do LineageOS 21.0..."
    repo init -u https://github.com/LineageOS/android.git -b lineage-21.0 --git-lfs --depth=1
fi

# 2. Configurar manifesto local para o alvo selecionado
mkdir -p .repo/local_manifests
rm -f .repo/local_manifests/*.xml

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

case "${TARGET}" in
    garnet)
        echo "==> Configurando manifesto para Redmi Note 13 Pro 5G (garnet)..."
        cp "${SCRIPT_DIR}/manifests/garnet.xml" .repo/local_manifests/
        LUNCH_TARGET="lineage_garnet-${VARIANT}"
        BUILD_COMMAND="m bacon"
        ;;
    pc-x86_64)
        echo "==> Configurando manifesto para PC (x86_64 ISO)..."
        cp "${SCRIPT_DIR}/manifests/pc_x86_64.xml" .repo/local_manifests/
        LUNCH_TARGET="android_x86_64-${VARIANT}"
        BUILD_COMMAND="m iso_img"
        ;;
    gsi-arm64)
        echo "==> Configurando manifesto para GSI (Treble ARM64)..."
        cp "${SCRIPT_DIR}/manifests/gsi.xml" .repo/local_manifests/
        LUNCH_TARGET="lineage_arm64_bgN-${VARIANT}"
        BUILD_COMMAND="m systemimage"
        ;;
    *)
        echo "Erro: Alvo desconhecido '${TARGET}'! Use: garnet, pc-x86_64 ou gsi-arm64"
        exit 1
        ;;
esac

# 3. Sincronizar código-fonte
echo "==> Sincronizando código-fonte (repo sync)..."
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags

# 4. Injetar a camada vendor/iris (identidade, branding e props)
echo "==> Injetando vendor/iris..."
mkdir -p vendor/iris
cp -r "${SCRIPT_DIR}/vendor_iris/"* vendor/iris/

# 5. Configurar ambiente de build do Android
echo "==> Carregando ambiente de build (envsetup.sh)..."
source build/envsetup.sh

# 6. Escolher o alvo de compilação
echo "==> Executando lunch ${LUNCH_TARGET}..."
lunch "${LUNCH_TARGET}"

# 7. Compilar
echo "==> Compilando IrisOS com comando '${BUILD_COMMAND}'..."
${BUILD_COMMAND} -j$(nproc --all)

echo "=============================================="
echo "  Build do IrisOS finalizado com sucesso!     "
echo "  Artefatos gerados em: ${WORKDIR}/out/target/product/"
echo "=============================================="
