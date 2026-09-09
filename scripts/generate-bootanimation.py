#!/usr/bin/env python3
"""
Gerador oficial da animação de boot (bootanimation.zip) do IrisOS.
Gera os quadros vetoriais/rasterizados do emblema IrisOS com anéis giratórios e núcleo pulsante.
"""

import os
import math
import shutil
import zipfile
from PIL import Image, ImageDraw, ImageFilter, ImageFont

def hex_to_rgb(hex_str):
    hex_str = hex_str.lstrip('#')
    return tuple(int(hex_str[i:i+2], 16) for i in (0, 2, 4))

BG_COLOR = hex_to_rgb("#05080E")
CYAN = hex_to_rgb("#38BDF8")
INDIGO = hex_to_rgb("#818CF8")
PURPLE = hex_to_rgb("#C084FC")
WHITE = (255, 255, 255)

def draw_iris_frame(width, height, angle_deg, pulse_factor, intro_progress=1.0):
    """
    Desenha um único quadro do emblema IrisOS.
    """
    img = Image.new("RGB", (width, height), BG_COLOR)
    draw = ImageDraw.Draw(img)

    cx, cy = width // 2, height // 2 - int(40 * intro_progress)
    base_scale = min(width, height) / 720.0

    # Escala e opacidade do efeito de introdução
    scale = base_scale * (0.3 + 0.7 * intro_progress)
    alpha_factor = intro_progress

    # 1. Brilho ambiente no fundo (Nebula radial)
    ambient_radius = int(220 * scale * (0.9 + 0.1 * pulse_factor))
    glow_img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow_img)
    glow_draw.ellipse(
        [cx - ambient_radius, cy - ambient_radius, cx + ambient_radius, cy + ambient_radius],
        fill=(99, 102, 241, int(45 * alpha_factor))
    )
    glow_img = glow_img.filter(ImageFilter.GaussianBlur(int(40 * scale)))
    img.paste(Image.alpha_composite(Image.new("RGBA", (width, height), (*BG_COLOR, 255)), glow_img), (0, 0))
    draw = ImageDraw.Draw(img)

    # 2. Anel orbital externo pontilhado (Gira 360°)
    outer_r = int(115 * scale)
    outer_width = max(2, int(4 * scale))
    dash_count = 12
    for i in range(dash_count):
        dash_angle = angle_deg + i * (360 / dash_count)
        start_a = dash_angle
        end_a = dash_angle + (180 / dash_count)
        draw.arc(
            [cx - outer_r, cy - outer_r, cx + outer_r, cy + outer_r],
            start=start_a, end=end_a, fill=CYAN, width=outer_width
        )

    # 3. Anel intermediário contínuo (Cyan)
    mid_r = int(80 * scale)
    mid_width = max(3, int(6 * scale))
    draw.ellipse(
        [cx - mid_r, cy - mid_r, cx + mid_r, cy + mid_r],
        outline=CYAN, width=mid_width
    )

    # 4. Anel interno (Violeta/Púrpura)
    inner_r = int(50 * scale)
    inner_width = max(2, int(4 * scale))
    draw.ellipse(
        [cx - inner_r, cy - inner_r, cx + inner_r, cy + inner_r],
        outline=PURPLE, width=inner_width
    )

    # 5. Núcleo central pulsante (Esfera com brilho)
    core_r = int((24 + 5 * pulse_factor) * scale)
    draw.ellipse(
        [cx - core_r, cy - core_r, cx + core_r, cy + core_r],
        fill=WHITE
    )

    # Camada de brilho suave ao redor do núcleo
    core_glow = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    cg_draw = ImageDraw.Draw(core_glow)
    cg_r = int(core_r * 1.8)
    cg_draw.ellipse(
        [cx - cg_r, cy - cg_r, cx + cg_r, cy + cg_r],
        fill=(56, 189, 248, int(160 * alpha_factor))
    )
    core_glow = core_glow.filter(ImageFilter.GaussianBlur(int(8 * scale)))
    img = Image.alpha_composite(img.convert("RGBA"), core_glow).convert("RGB")
    draw = ImageDraw.Draw(img)

    # 6. Texto tipográfico "IrisOS" (fade-in na introdução)
    if intro_progress > 0.4:
        text_alpha = min(1.0, (intro_progress - 0.4) / 0.6)
        text_y = cy + int(160 * scale)

        # Letras desenhadas
        font_size = int(48 * scale)
        try:
            # Tenta carregar fonte do sistema
            font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", font_size)
            font_os = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", font_size)
        except Exception:
            font = ImageFont.load_default()
            font_os = font

        # Calcular posição centralizada
        text_full = "IrisOS"
        bbox = draw.textbbox((0, 0), text_full, font=font)
        tw = bbox[2] - bbox[0]
        start_x = cx - tw // 2

        # Desenhar "Iris" em branco e "OS" em Cyan
        draw.text((start_x, text_y), "Iris", fill=WHITE, font=font)
        iris_w = draw.textbbox((0, 0), "Iris", font=font)[2]
        draw.text((start_x + iris_w, text_y), "OS", fill=CYAN, font=font_os)

    return img

def build_bootanimation(width, height, fps, output_zip_path):
    """
    Gera as pastas part0 (intro) e part1 (loop) e empacota em zip sem compressão (STORED).
    """
    temp_dir = "/tmp/iris_bootanim_build"
    if os.path.exists(temp_dir):
        shutil.rmtree(temp_dir)

    part0_dir = os.path.join(temp_dir, "part0")
    part1_dir = os.path.join(temp_dir, "part1")
    os.makedirs(part0_dir)
    os.makedirs(part1_dir)

    print(f"==> Gerando bootanimation ({width}x{height} @ {fps}fps) -> {output_zip_path}")

    # 1. Introdução (part0): 24 quadros (0.8s) - Abertura e ignição dos anéis
    intro_frames = 24
    for i in range(intro_frames):
        progress = (i + 1) / intro_frames
        # Interpolação ease-out suave
        ease_progress = math.sin(progress * (math.pi / 2))
        pulse = math.sin(progress * math.pi)
        angle = ease_progress * 120
        frame = draw_iris_frame(width, height, angle, pulse, intro_progress=ease_progress)
        frame.save(os.path.join(part0_dir, f"{i:04d}.png"))

    # 2. Loop contínuo (part1): 30 quadros (1.0s) - Rotação fluida 360° perfeita
    loop_frames = 30
    for i in range(loop_frames):
        cycle = i / loop_frames
        angle = cycle * 360.0
        pulse = math.sin(cycle * 2 * math.pi)
        frame = draw_iris_frame(width, height, angle, pulse, intro_progress=1.0)
        frame.save(os.path.join(part1_dir, f"{i:04d}.png"))

    # 3. Criar desc.txt com padrão obrigatório do Android (terminando em LF e linha vazia)
    desc_content = f"{width} {height} {fps}\np 1 0 part0\np 0 0 part1\n"
    desc_path = os.path.join(temp_dir, "desc.txt")
    with open(desc_path, "wb") as f:
        f.write(desc_content.encode("utf-8"))

    # 4. Empacotar em ZIP usando compressão ZERO (ZIP_STORED)
    os.makedirs(os.path.dirname(output_zip_path), exist_ok=True)
    if os.path.exists(output_zip_path):
        os.remove(output_zip_path)

    with zipfile.ZipFile(output_zip_path, "w", compression=zipfile.ZIP_STORED) as zipf:
        zipf.write(desc_path, "desc.txt")
        for f in sorted(os.listdir(part0_dir)):
            zipf.write(os.path.join(part0_dir, f), f"part0/{f}")
        for f in sorted(os.listdir(part1_dir)):
            zipf.write(os.path.join(part1_dir, f), f"part1/{f}")

    print(f"  ✓ Concluído com sucesso! Tamanho: {os.path.getsize(output_zip_path) / (1024*1024):.2f} MB")
    shutil.rmtree(temp_dir)

if __name__ == "__main__":
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    out_dir = os.path.join(repo_root, "vendor_iris", "bootanimation")

    # 1. Mobile (720x1600 @ 30fps) - Otimizado para telas 20:9 AMOLED como a do Redmi Note 13 Pro
    mobile_zip = os.path.join(out_dir, "bootanimation_mobile.zip")
    build_bootanimation(720, 1600, 30, mobile_zip)

    # 2. PC (1280x720 @ 30fps) - Otimizado para telas Widescreen 16:9
    pc_zip = os.path.join(out_dir, "bootanimation_pc.zip")
    build_bootanimation(1280, 720, 30, pc_zip)
