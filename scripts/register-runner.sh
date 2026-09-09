#!/usr/bin/env bash
#
# Registra esta máquina como um Self-Hosted Runner no repositório GitHub do IrisOS
#

set -e

REPO="miguel7435987984/IrisOS"
RUNNER_DIR="$HOME/actions-runner"

echo "==> [IrisOS Runner] Obtendo token de registro via GitHub CLI..."
TOKEN=$(gh api --method POST -H "Accept: application/vnd.github+json" /repos/${REPO}/actions/runners/registration-token --jq .token)

if [ -z "$TOKEN" ]; then
    echo "Erro: Não foi possível obter o token de registro do runner."
    exit 1
fi

mkdir -p "$RUNNER_DIR"
cd "$RUNNER_DIR"

if [ ! -f "config.sh" ]; then
    echo "==> [IrisOS Runner] Baixando binário do GitHub Actions Runner..."
    RUNNER_VERSION="2.322.0"
    curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
    tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
fi

echo "==> [IrisOS Runner] Configurando o runner para o repositório ${REPO}..."
./config.sh --url "https://github.com/${REPO}" --token "${TOKEN}" --name "irisos-builder-pc" --labels "self-hosted,linux,x64" --unattended --replace

echo "==> [IrisOS Runner] Configuração concluída!"
echo "Para iniciar o runner e deixá-lo aguardando jobs de compilação, execute:"
echo "  cd $RUNNER_DIR && ./run.sh"
echo ""
echo "Ou instale como serviço do sistema para rodar em segundo plano:"
echo "  sudo $RUNNER_DIR/svc.sh install && sudo $RUNNER_DIR/svc.sh start"
