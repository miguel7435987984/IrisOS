#!/usr/bin/env bash
#
# Script para executar o IrisOS PC no QEMU sem instalar nada no disco físico
#

set -e

ISO_PATH="${1}"

# Procurar automaticamente pela ISO se nenhum caminho for fornecido
if [ -z "$ISO_PATH" ]; then
    FOUND_ISO=$(find "$HOME/android/irisos/out/target/product" -name "*.iso" 2>/dev/null | head -n 1)
    if [ -n "$FOUND_ISO" ]; then
        ISO_PATH="$FOUND_ISO"
    elif [ -f "IrisOS-x86_64.iso" ]; then
        ISO_PATH="IrisOS-x86_64.iso"
    fi
fi

if [ -z "$ISO_PATH" ] || [ ! -f "$ISO_PATH" ]; then
    echo "=========================================================="
    echo "  [IrisOS QEMU Runner] Nenhuma imagem ISO encontrada!"
    echo "=========================================================="
    echo "Uso: bash scripts/run-qemu.sh <caminho_para_a_iso>"
    echo "Exemplo: bash scripts/run-qemu.sh ~/Downloads/IrisOS-x86_64.iso"
    exit 1
fi

echo "=========================================================="
echo "  Iniciando IrisOS PC no QEMU (Modo Live / Sem Instalação)"
echo "=========================================================="
echo "  Imagem ISO:   ${ISO_PATH}"
echo "  Aceleração:   KVM (Hardware nativo)"
echo "  Memória RAM:  4096 MB (4 GB)"
echo "  Processador:  4 vCPUs"
echo "  Gráficos:     VirtIO GPU (3D acelerado)"
echo "=========================================================="
echo "Dica: Na tela de boot do GRUB, escolha 'Live CD - Run IrisOS without installation'"
echo ""

# Flags com aceleração VirtIO GPU OpenGL para interface fluida
QEMU_FLAGS=(
    -enable-kvm
    -cpu host
    -smp 4
    -m 4096
    -cdrom "${ISO_PATH}"
    -boot d
    -device virtio-vga-gl
    -display gtk,gl=on
    -device AC97
    -net nic,model=virtio-net-pci
    -net user,hostfwd=tcp::5555-:5555
    -usb
    -device usb-tablet
)

# Se falhar com virtio-vga-gl (ex: sessão sem OpenGL), usa fallback seguro
if ! qemu-system-x86_64 "${QEMU_FLAGS[@]}" 2>/dev/null; then
    echo "Aviso: Modo VirtIO-GL indisponível na sessão gráfica. Iniciando com fallback VirtIO padrão..."
    qemu-system-x86_64 \
        -enable-kvm \
        -cpu host \
        -smp 4 \
        -m 4096 \
        -cdrom "${ISO_PATH}" \
        -boot d \
        -vga virtio \
        -device AC97 \
        -net nic,model=virtio-net-pci \
        -net user,hostfwd=tcp::5555-:5555 \
        -usb \
        -device usb-tablet
fi
