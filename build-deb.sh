#!/bin/bash
set -e

PACKAGE_NAME="meu_pacote"
VERSION="0.1.0"
MAINTAINER="Seu Nome <seuemail@exemplo.com>"

PROJECT_DIR="$(pwd)"
BUILD_DIR="$(mktemp -d)"
echo "Usando diretório temporário de build: $BUILD_DIR"

# 1️⃣ Garantir que pip e build estejam instalados
python3 -m ensurepip --upgrade || true
python3 -m pip install --upgrade pip
python3 -m pip install --upgrade build wheel

# 2️⃣ Gerar wheel e sdist
echo "Construindo wheel e sdist..."
python3 -m build --wheel --sdist --outdir "$BUILD_DIR"

WHEEL_FILE=$(ls "$BUILD_DIR"/*.whl | head -n 1)
echo "Wheel gerado: $WHEEL_FILE"

# 3️⃣ Diretório temporário para instalar o pacote
INSTALL_DIR="$BUILD_DIR/install"
mkdir -p "$INSTALL_DIR"

# 4️⃣ Instalar o pacote no diretório temporário
python3 -m pip install --prefix="$INSTALL_DIR" "$WHEEL_FILE"

# 5️⃣ Gerar o .deb com fpm
if ! command -v fpm &> /dev/null; then
    echo "Instalando fpm..."
    sudo apt-get update
    sudo apt-get install -y ruby ruby-dev build-essential
    sudo gem install --no-document fpm
fi

echo "Gerando .deb..."
fpm -s dir -t deb \
    -n "$PACKAGE_NAME" \
    -v "$VERSION" \
    --prefix=/usr/local \
    --maintainer "$MAINTAINER" \
    -C "$INSTALL_DIR" .

echo "Pacote .deb gerado com sucesso!"
