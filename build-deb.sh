#!/bin/bash
set -e

# Nome do pacote e versão
PACKAGE_NAME="meu_pacote"
VERSION="0.1.0"
MAINTAINER="Seu Nome <seuemail@exemplo.com>"

# Caminho do projeto
PROJECT_DIR="$(pwd)"

# Diretório temporário de build
BUILD_DIR="$(mktemp -d)"
echo "Usando diretório temporário de build: $BUILD_DIR"

# 1️⃣ Instalar build e fpm se não estiverem instalados
if ! command -v python3 -m build &> /dev/null; then
    echo "Instalando build..."
    python3 -m pip install --upgrade build
fi

if ! command -v fpm &> /dev/null; then
    echo "Instalando fpm..."
    sudo apt-get update
    sudo apt-get install -y ruby ruby-dev build-essential
    sudo gem install --no-document fpm
fi

# 2️⃣ Gerar wheel e sdist
echo "Construindo wheel e sdist..."
python3 -m build --wheel --sdist --outdir "$BUILD_DIR"

# Encontrar o wheel gerado
WHEEL_FILE=$(ls "$BUILD_DIR"/*.whl | head -n 1)
echo "Wheel gerado: $WHEEL_FILE"

# 3️⃣ Criar diretório para instalação temporária
INSTALL_DIR="$BUILD_DIR/install"
mkdir -p "$INSTALL_DIR"

# 4️⃣ Instalar o pacote no diretório temporário
python3 -m pip install --prefix="$INSTALL_DIR" "$WHEEL_FILE"

# 5️⃣ Gerar o .deb com fpm
echo "Gerando .deb..."
fpm -s dir -t deb \
    -n "$PACKAGE_NAME" \
    -v "$VERSION" \
    --prefix=/usr/local \
    --maintainer "$MAINTAINER" \
    -C "$INSTALL_DIR" .

echo "Pacote .deb gerado com sucesso!"
