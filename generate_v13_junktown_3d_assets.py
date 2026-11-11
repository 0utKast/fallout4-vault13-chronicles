import math
import os
import struct
import subprocess
import sys
import zlib
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

THIS_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.dirname(THIS_DIR)
TEST_MESHES_DIR = os.path.join(ROOT_DIR, "tools_3d", "test_meshes")
FO4_DATA_DIR = r"C:\Program Files (x86)\Steam\steamapps\common\Fallout 4\Data"

JUNKTOWN_ASSETS_DIR = os.path.join(THIS_DIR, "assets", "junktown_3d")
TEX_OUT_DIR = os.path.join(JUNKTOWN_ASSETS_DIR, "Textures", "V13Chronicles", "Junktown")
MAT_OUT_DIR = os.path.join(JUNKTOWN_ASSETS_DIR, "Materials", "V13Chronicles", "Junktown")
MESH_OUT_DIR = os.path.join(JUNKTOWN_ASSETS_DIR, "Meshes", "V13Chronicles", "Junktown")

BLENDER_EXE = r"C:\Program Files\Blender Foundation\Blender 5.2\blender.exe"
PYNIFLY_DIR = r"C:\Users\educa\AppData\Roaming\Blender Foundation\Blender\5.2\scripts\addons\io_scene_nifly"


def encode_bc1_block_array(rgb_arr: np.ndarray) -> bytes:
    """Codifica un array RGB uint8 (H, W, 3) en bloques BC1 (DXT1) de 8 bytes vectorizados con NumPy."""
    h, w, _ = rgb_arr.shape
    pad_h = (4 - (h % 4)) % 4
    pad_w = (4 - (w % 4)) % 4
    if pad_h or pad_w:
        rgb_arr = np.pad(rgb_arr, ((0, pad_h), (0, pad_w), (0, 0)), mode="edge")
        h, w, _ = rgb_arr.shape

    blocks = (
        rgb_arr.reshape(h // 4, 4, w // 4, 4, 3)
        .transpose(0, 2, 1, 3, 4)
        .reshape(-1, 16, 3)
        .astype(np.float32)
    )
    n_blk = blocks.shape[0]

    lum = blocks[:, :, 0] * 0.299 + blocks[:, :, 1] * 0.587 + blocks[:, :, 2] * 0.114
    max_idx = np.argmax(lum, axis=1)
    min_idx = np.argmin(lum, axis=1)
    ar = np.arange(n_blk)
    c_max = blocks[ar, max_idx]
    c_min = blocks[ar, min_idx]

    def to_rgb565(rgb):
        r = np.clip(np.round(rgb[:, 0] * (31.0 / 255.0)), 0, 31).astype(np.uint16)
        g = np.clip(np.round(rgb[:, 1] * (63.0 / 255.0)), 0, 63).astype(np.uint16)
        b = np.clip(np.round(rgb[:, 2] * (31.0 / 255.0)), 0, 31).astype(np.uint16)
        return (r << 11) | (g << 5) | b, np.stack(
            [r * (255.0 / 31.0), g * (255.0 / 63.0), b * (255.0 / 31.0)], axis=1
        )

    c0_16, c0_rgb = to_rgb565(c_max)
    c1_16, c1_rgb = to_rgb565(c_min)

    swap = c0_16 < c1_16
    c0_16_s = np.where(swap, c1_16, c0_16)
    c1_16_s = np.where(swap, c0_16, c1_16)
    c0_rgb_s = np.where(swap[:, None], c1_rgb, c0_rgb)
    c1_rgb_s = np.where(swap[:, None], c0_rgb, c1_rgb)

    eq = c0_16_s == c1_16_s
    c0_16_s = np.where(eq & (c0_16_s < 0xFFFF), c0_16_s + 1, c0_16_s)
    c1_16_s = np.where(eq & (c0_16_s == 0xFFFF), c1_16_s - 1, c1_16_s)

    p0 = c0_rgb_s[:, None, :]
    p1 = c1_rgb_s[:, None, :]
    p2 = (2.0 * p0 + p1) / 3.0
    p3 = (p0 + 2.0 * p1) / 3.0

    d0 = np.sum((blocks - p0) ** 2, axis=2)
    d1 = np.sum((blocks - p1) ** 2, axis=2)
    d2 = np.sum((blocks - p2) ** 2, axis=2)
    d3 = np.sum((blocks - p3) ** 2, axis=2)

    dists = np.stack([d0, d1, d2, d3], axis=2)
    indices = np.argmin(dists, axis=2).astype(np.uint32)

    shifts = (np.arange(16, dtype=np.uint32) * 2)[None, :]
    idx_32 = np.sum(indices << shifts, axis=1, dtype=np.uint32)

    out = np.empty(n_blk, dtype=[("c0", "<u2"), ("c1", "<u2"), ("idx", "<u4")])
    out["c0"] = c0_16_s
    out["c1"] = c1_16_s
    out["idx"] = idx_32
    return out.tobytes()


def encode_dds_1024_with_11_mips(im: Image.Image) -> list[bytes]:
    mips = []
    cur = im.convert("RGB")
    w, h = 1024, 1024
    for _ in range(11):
        if cur.size != (w, h):
            cur = cur.resize((w, h), Image.Resampling.LANCZOS)
        arr = np.asarray(cur)
        mips.append(encode_bc1_block_array(arr))
        w = max(1, w // 2)
        h = max(1, h // 2)
    return mips


def write_dds_1024_file(dst_path: str, mips: list[bytes]) -> None:
    os.makedirs(os.path.dirname(dst_path), exist_ok=True)
    flags = 0x00000001 | 0x00000002 | 0x00000004 | 0x00001000 | 0x00020000 | 0x00080000
    height, width = 1024, 1024
    pitch_or_linear = len(mips[0])
    mip_count = len(mips)
    pf = struct.pack("<II4sIIIII", 32, 0x00000004, b"DXT1", 0, 0, 0, 0, 0)
    caps = 0x00001000 | 0x00000008 | 0x00400000
    hdr = struct.pack(
        "<4sIIIIIII44s32sIIIII",
        b"DDS ",
        124,
        flags,
        height,
        width,
        pitch_or_linear,
        0,
        mip_count,
        b"\x00" * 44,
        pf,
        caps,
        0,
        0,
        0,
        0,
    )
    with open(dst_path, "wb") as wf:
        wf.write(hdr)
        for m in mips:
            wf.write(m)


def grade_texture_palette(
    src_dds_path: str,
    base_rgb: tuple[float, float, float],
    detail_gain: float = 0.65,
    macro_gain: float = 0.25,
    min_clamp: float = 10.0,
    max_clamp: float = 140.0,
) -> Image.Image:
    im = Image.open(src_dds_path).convert("RGB")
    if im.size != (1024, 1024):
        im = im.resize((1024, 1024), Image.Resampling.LANCZOS)
    blur_im = im.filter(ImageFilter.GaussianBlur(radius=18))

    arr = np.asarray(im).astype(np.float32)
    barr = np.asarray(blur_im).astype(np.float32)

    lum = 0.299 * arr[:, :, 0] + 0.587 * arr[:, :, 1] + 0.114 * arr[:, :, 2]
    blum = 0.299 * barr[:, :, 0] + 0.587 * barr[:, :, 1] + 0.114 * barr[:, :, 2]

    high_pass = np.clip(lum - blum, -35.0, 35.0) * detail_gain
    p50 = float(np.median(lum))
    macro_var = np.clip((blum - p50) * macro_gain, -18.0, 18.0)

    mod = high_pass + macro_var
    out = np.empty((1024, 1024, 3), dtype=np.float32)
    out[:, :, 0] = base_rgb[0] + mod * 1.05
    out[:, :, 1] = base_rgb[1] + mod * 0.95
    out[:, :, 2] = base_rgb[2] + mod * 0.82

    return Image.fromarray(np.clip(out, min_clamp, max_clamp).astype(np.uint8))


def build_killian_hat_texture() -> Image.Image:
    """Cuero curtido marrón rojizo del desierto con herrajes de latón envejecido para el sombrero de Killian Darkwater."""
    return grade_texture_palette(
        os.path.join(TEST_MESHES_DIR, "Mac_d.dds"),
        base_rgb=(68.0, 44.0, 28.0),
        detail_gain=0.72,
        macro_gain=0.28,
        min_clamp=14.0,
        max_clamp=132.0,
    )


def build_lars_helm_texture() -> Image.Image:
    """Acero pavonado azul-grisáceo y bronce oxidado para el casco táctico con cresta del Capitán Lars."""
    return grade_texture_palette(
        os.path.join(TEST_MESHES_DIR, "CombatArmor_Helmet_d.dds"),
        base_rgb=(46.0, 52.0, 58.0),
        detail_gain=0.78,
        macro_gain=0.30,
        min_clamp=12.0,
        max_clamp=124.0,
    )


def build_tycho_helm_texture() -> Image.Image:
    """Verde oliva árido y arena del Mojave para el casco de Ranger del Desierto de Tycho."""
    return grade_texture_palette(
        os.path.join(TEST_MESHES_DIR, "Helmet_02_d.dds"),
        base_rgb=(58.0, 56.0, 42.0),
        detail_gain=0.68,
        macro_gain=0.24,
        min_clamp=14.0,
        max_clamp=118.0,
    )


def build_tycho_visor_texture() -> Image.Image:
    """Lente óptica ámbar-bronce anti-tormentas de arena para el visor del casco de Ranger del Desierto de Tycho."""
    yy, xx = np.mgrid[0:1024, 0:1024].astype(np.float32)
    u_norm = np.clip((xx - 10.0) / (464.0 - 10.0), 0.0, 1.0)
    v_norm = np.clip((yy - 401.0) / (673.0 - 401.0), 0.0, 1.0)

    radial = np.exp(-(((u_norm - 0.50) / 0.48) ** 2 + ((v_norm - 0.46) / 0.52) ** 2))
    edge_dist = np.minimum(
        np.minimum(v_norm / 0.055, (1.0 - v_norm) / 0.060),
        np.minimum(u_norm / 0.045, (1.0 - u_norm) / 0.045),
    )
    gasket = np.clip(edge_dist, 0.0, 1.0) ** 0.75

    base_r = 34.0 + (42.0 + 18.0 * radial) * gasket
    base_g = 24.0 + (26.0 + 12.0 * radial) * gasket
    base_b = 12.0 + (10.0 + 5.0 * radial) * gasket

    out = np.stack([base_r, base_g, base_b], axis=2)
    return Image.fromarray(np.clip(out, 10.0, 96.0).astype(np.uint8))


def build_tardis_police_box_texture() -> Image.Image:
    """
    Construye el atlas de textura 1024x1024 de la Cabina Telefónica Inusual (Fallout 1, 1997 / 1960s Police Box):
      - Zona A (x: 0..512, y: 0..512   | u: 0.00..0.50, v: 0.50..1.00): Madera azul de Prusia con veta vertical y pátina del desierto
      - Zona B (x: 512..1024, y: 0..320 | u: 0.50..1.00, v: 0.6875..1.00): Ventana dividida 3x2 con marcos blancos y cristal esmerilado
      - Zona C (x: 512..1024, y: 320..448 | u: 0.50..1.00, v: 0.5625..0.6875): Cartel superior 'POLICE • PUBLIC CALL BOX'
      - Zona D (x: 512..768, y: 448..768 | u: 0.50..0.75, v: 0.25..0.5625): Placa blanca 'POLICE TELEPHONE / FREE FOR USE OF PUBLIC / PULL TO OPEN'
      - Zona E (x: 768..1024, y: 448..768 | u: 0.75..1.00, v: 0.25..0.5625): Panel azul con emblema circular St. John y cerradura
      - Zona F (x: 0..512, y: 512..1024  | u: 0.00..0.50, v: 0.00..0.50): Paneles cofre hundidos (azul de Prusia con bisel sombreado)
      - Zona G (x: 512..1024, y: 768..1024 | u: 0.50..1.00, v: 0.00..0.25): Lámpara Fresnel superior (x:512..768) y plinto de hormigón (x:768..1024)
    """
    yy, xx = np.mgrid[0:1024, 0:1024].astype(np.float32)
    grain = (
        np.sin(xx * 0.45 + np.sin(yy * 0.04) * 2.5) * 4.5
        + np.cos(yy * 0.18 + xx * 0.03) * 2.5
        + np.sin(xx * 1.15) * 1.8
    )
    base_r = np.clip(18.0 + grain * 0.7, 8.0, 42.0)
    base_g = np.clip(50.0 + grain * 1.1, 24.0, 86.0)
    base_b = np.clip(106.0 + grain * 1.8, 58.0, 152.0)

    # Fluting vertical subtle stripes in Zone A
    flute = np.sin(xx * (2.0 * math.pi / 32.0)) * 5.0
    mask_a = (xx < 512) & (yy < 512)
    base_r = np.where(mask_a, np.clip(base_r + flute * 0.5, 8.0, 48.0), base_r)
    base_g = np.where(mask_a, np.clip(base_g + flute * 0.9, 22.0, 92.0), base_g)
    base_b = np.where(mask_a, np.clip(base_b + flute * 1.5, 52.0, 160.0), base_b)

    # Zone F (x: 0..512, y: 512..1024): Recessed bevelled coffered panel texture
    uf = (xx % 256.0) / 256.0
    vf = ((yy - 512.0) % 256.0) / 256.0
    edge_f = np.minimum(np.minimum(uf, 1.0 - uf), np.minimum(vf, 1.0 - vf))
    bevel = np.where((edge_f > 0.06) & (edge_f < 0.14), -14.0, np.where(edge_f >= 0.14, 4.0, 0.0))
    mask_f = (xx < 512) & (yy >= 512)
    base_r = np.where(mask_f, np.clip(base_r + bevel * 0.5, 6.0, 45.0), base_r)
    base_g = np.where(mask_f, np.clip(base_g + bevel * 0.9, 18.0, 88.0), base_g)
    base_b = np.where(mask_f, np.clip(base_b + bevel * 1.5, 42.0, 155.0), base_b)

    # Zone G right (x: 768..1024, y: 768..1024): Dark weathered desert stone/timber plinth
    mask_plinth = (xx >= 768) & (yy >= 768)
    noise_p = np.sin(xx * 0.31 + yy * 0.29) * 5.0 + np.cos(xx * 0.17 - yy * 0.23) * 4.0
    base_r = np.where(mask_plinth, np.clip(54.0 + noise_p, 35.0, 78.0), base_r)
    base_g = np.where(mask_plinth, np.clip(58.0 + noise_p, 38.0, 82.0), base_g)
    base_b = np.where(mask_plinth, np.clip(66.0 + noise_p, 44.0, 92.0), base_b)

    # Zone G left (x: 512..768, y: 768..1024): Fresnel Beacon Lamp (warm/cyan glowing ribbed glass)
    mask_lamp = (xx >= 512) & (xx < 768) & (yy >= 768)
    fresnel_rib = np.sin((yy - 768.0) * (2.0 * math.pi / 16.0)) * 18.0
    lamp_glow = np.exp(-(((yy - 896.0) / 95.0) ** 2))
    base_r = np.where(mask_lamp, np.clip(175.0 + 65.0 * lamp_glow + fresnel_rib, 120.0, 252.0), base_r)
    base_g = np.where(mask_lamp, np.clip(225.0 + 28.0 * lamp_glow + fresnel_rib * 0.7, 175.0, 255.0), base_g)
    base_b = np.where(mask_lamp, np.clip(245.0 + 10.0 * lamp_glow + fresnel_rib * 0.4, 210.0, 255.0), base_b)

    rgb = np.stack([base_r, base_g, base_b], axis=2).astype(np.uint8)
    im = Image.fromarray(rgb)
    draw = ImageDraw.Draw(im)

    def load_font(sz: int, bold: bool = True):
        for cand in (
            r"C:\Windows\Fonts\arialbd.ttf" if bold else r"C:\Windows\Fonts\arial.ttf",
            r"C:\Windows\Fonts\calibrib.ttf",
            r"C:\Windows\Fonts\segoeui.ttf",
        ):
            if os.path.exists(cand):
                try:
                    return ImageFont.truetype(cand, sz)
                except Exception:
                    pass
        return ImageFont.load_default()

    # Zone B (x: 512..1024, y: 0..320): 3x2 Divided Window Panes with White Frames
    draw.rectangle([512, 0, 1023, 319], fill=(232, 236, 240), outline=(24, 52, 98), width=8)
    pane_w = (512 - 48) // 3
    pane_h = (320 - 40) // 2
    for row in range(2):
        for col in range(3):
            px0 = 512 + 16 + col * (pane_w + 8)
            py0 = 14 + row * (pane_h + 12)
            px1 = px0 + pane_w
            py1 = py0 + pane_h
            # Classic TARDIS: upper row + lower side panes bright frosted glass, center-lower slightly darker/amber tint
            if row == 0 or col != 1:
                glass_col = (182, 212, 232)
                inner_col = (208, 232, 246)
            else:
                glass_col = (145, 178, 204)
                inner_col = (168, 198, 220)
            draw.rectangle([px0, py0, px1, py1], fill=glass_col, outline=(110, 128, 146), width=3)
            draw.rectangle([px0 + 8, py0 + 8, px1 - 8, py1 - 8], fill=inner_col)

    # Zone C (x: 512..1024, y: 320..448): Top Sign Lintel "POLICE • PUBLIC CALL BOX"
    draw.rectangle([512, 320, 1023, 447], fill=(14, 18, 26), outline=(218, 224, 232), width=6)
    draw.rectangle([522, 330, 1013, 437], fill=(10, 13, 20), outline=(160, 172, 188), width=2)
    f_police = load_font(44, bold=True)
    f_sub = load_font(18, bold=True)
    draw.text((542, 360), "POLICE", fill=(246, 248, 252), font=f_police)
    draw.text((738, 358), "PUBLIC", fill=(238, 242, 248), font=f_sub)
    draw.text((736, 384), "CALL", fill=(238, 242, 248), font=f_sub)
    draw.text((838, 360), "BOX", fill=(246, 248, 252), font=f_police)

    # Zone D (x: 512..768, y: 448..768): White Door Instruction Plaque ("PULL TO OPEN")
    draw.rectangle([512, 448, 767, 767], fill=(18, 48, 102))
    draw.rectangle([528, 464, 751, 751], fill=(238, 240, 242), outline=(20, 24, 32), width=5)
    draw.rectangle([536, 472, 743, 743], outline=(40, 46, 58), width=2)
    f_plaque_h = load_font(19, bold=True)
    f_plaque_m = load_font(14, bold=True)
    f_plaque_s = load_font(11, bold=False)
    plaque_lines = [
        ("POLICE TELEPHONE", f_plaque_h, 484),
        ("FREE", f_plaque_h, 514),
        ("FOR USE OF", f_plaque_m, 542),
        ("PUBLIC", f_plaque_h, 562),
        ("ADVICE & ASSISTANCE", f_plaque_s, 594),
        ("OBTAINABLE IMMEDIATELY", f_plaque_s, 612),
        ("OFFICERS & CARS", f_plaque_s, 636),
        ("RESPOND TO ALL CALLS", f_plaque_s, 654),
        ("PULL TO OPEN", f_plaque_h, 694),
    ]
    for txt, fnt, py in plaque_lines:
        bbox = draw.textbbox((0, 0), txt, font=fnt)
        tw = bbox[2] - bbox[0]
        tx = 640 - tw // 2
        draw.text((tx, py), txt, fill=(16, 20, 28), font=fnt)

    # Zone E (x: 768..1024, y: 448..768): Right Door Panel with St. John Ambulance Circular Badge
    draw.rectangle([768, 448, 1023, 767], fill=(18, 48, 102), outline=(10, 28, 64), width=8)
    cx, cy = 896, 608
    draw.ellipse([cx - 68, cy - 68, cx + 68, cy + 68], fill=(16, 20, 28), outline=(235, 238, 242), width=5)
    draw.ellipse([cx - 48, cy - 48, cx + 48, cy + 48], fill=(16, 20, 28), outline=(235, 238, 242), width=3)
    # Maltese cross in center
    draw.polygon([(cx, cy - 6), (cx - 18, cy - 34), (cx + 18, cy - 34)], fill=(238, 240, 244))
    draw.polygon([(cx, cy + 6), (cx - 18, cy + 34), (cx + 18, cy + 34)], fill=(238, 240, 244))
    draw.polygon([(cx - 6, cy), (cx - 34, cy - 18), (cx - 34, cy + 18)], fill=(238, 240, 244))
    draw.polygon([(cx + 6, cy), (cx + 34, cy - 18), (cx + 34, cy + 18)], fill=(238, 240, 244))
    # Silver Yale door lock escutcheon on the left edge of Zone E
    draw.ellipse([782, 594, 806, 618], fill=(195, 202, 210), outline=(60, 68, 78), width=2)
    draw.rectangle([792, 601, 796, 611], fill=(24, 28, 34))

    return im.filter(ImageFilter.SMOOTH_MORE)


def build_elvis_velvet_painting_texture() -> Image.Image:
    """
    Construye el atlas 1024x1024 del Cuadro de Terciopelo de «El Rey» (Elvis Presley — Fallout 1 'Fuzzy Painting'):
      - Zona A (x: 0..512, y: 0..640): Lienzo de terciopelo negro con el retrato de Elvis ('THE KING • VIVA LAS VEGAS')
      - Zona B (x: 512..1024, y: 0..640): Reverso de madera y lienzo con sello de autenticidad del Área 51 / Graceland
      - Zona C (x: 0..1024, y: 640..1024): Moldura de marco de madera tallada y pan de oro envejecido
    """
    yy, xx = np.mgrid[0:1024, 0:1024].astype(np.float32)

    # Base: Zone C (y >= 640) ornate warm gold-leaf & walnut wood frame
    wood_grain = np.sin(xx * 0.22 + np.sin(yy * 0.05) * 2.0) * 10.0 + np.cos(yy * 0.35) * 6.0
    base_r = np.clip(168.0 + wood_grain * 1.1, 90.0, 225.0)
    base_g = np.clip(126.0 + wood_grain * 0.9, 64.0, 182.0)
    base_b = np.clip(48.0 + wood_grain * 0.5, 20.0, 92.0)

    # Zone A (x < 512, y < 640): Deep black-indigo velvet canvas with subtle plush radial glow
    mask_velvet = (xx < 512) & (yy < 640)
    rad_glow = np.exp(-(((xx - 256.0) / 165.0) ** 2 + ((yy - 300.0) / 195.0) ** 2))
    velvet_fuzz = (np.sin(xx * 1.7) * np.cos(yy * 1.7)) * 3.0
    vel_r = np.clip(12.0 + 48.0 * rad_glow + velvet_fuzz, 6.0, 74.0)
    vel_g = np.clip(10.0 + 18.0 * rad_glow + velvet_fuzz, 5.0, 42.0)
    vel_b = np.clip(22.0 + 64.0 * rad_glow + velvet_fuzz, 10.0, 98.0)
    base_r = np.where(mask_velvet, vel_r, base_r)
    base_g = np.where(mask_velvet, vel_g, base_g)
    base_b = np.where(mask_velvet, vel_b, base_b)

    # Zone B (x >= 512, y < 640): Aged canvas & timber backing
    mask_back = (xx >= 512) & (yy < 640)
    canvas_tex = np.sin(xx * 0.8) * 3.5 + np.cos(yy * 0.8) * 3.5
    base_r = np.where(mask_back, np.clip(124.0 + canvas_tex, 95.0, 152.0), base_r)
    base_g = np.where(mask_back, np.clip(104.0 + canvas_tex, 78.0, 132.0), base_g)
    base_b = np.where(mask_back, np.clip(76.0 + canvas_tex, 54.0, 102.0), base_b)

    rgb = np.stack([base_r, base_g, base_b], axis=2).astype(np.uint8)
    im = Image.fromarray(rgb)
    draw = ImageDraw.Draw(im)

    def load_font(sz: int, bold: bool = True):
        for cand in (
            r"C:\Windows\Fonts\arialbd.ttf" if bold else r"C:\Windows\Fonts\arial.ttf",
            r"C:\Windows\Fonts\georgia.ttf",
            r"C:\Windows\Fonts\calibrib.ttf",
        ):
            if os.path.exists(cand):
                try:
                    return ImageFont.truetype(cand, sz)
                except Exception:
                    pass
        return ImageFont.load_default()

    # Ornate inner gold border on Zone A velvet canvas
    draw.rectangle([16, 16, 495, 623], outline=(214, 168, 68), width=6)
    draw.rectangle([28, 28, 483, 611], outline=(142, 96, 36), width=2)

    # Radiant Vegas Starburst behind Elvis on the velvet canvas
    cx, cy = 256, 290
    for ang_deg in range(0, 360, 15):
        rad = math.radians(ang_deg)
        r_len = 165 if (ang_deg % 30 == 0) else 115
        x_end = cx + int(r_len * math.cos(rad))
        y_end = cy + int(r_len * math.sin(rad))
        draw.line([(cx, cy), (x_end, y_end)], fill=(96, 42, 118), width=3)
    draw.ellipse([cx - 125, cy - 125, cx + 125, cy + 125], fill=(28, 16, 46), outline=(228, 178, 72), width=3)

    # High-collared White Vegas Jumpsuit (Aloha / American Eagle style)
    # High collar wings behind neck
    draw.polygon([(148, 340), (195, 285), (317, 285), (364, 340), (340, 440), (172, 440)], fill=(238, 236, 230), outline=(210, 172, 74), width=3)
    # Shoulders & Torso of white jumpsuit
    draw.polygon([(84, 515), (148, 365), (364, 365), (428, 515)], fill=(242, 240, 235), outline=(212, 174, 72), width=4)
    # Deep V-neck chest & red silk scarf
    draw.polygon([(216, 355), (296, 355), (256, 475)], fill=(186, 34, 38), outline=(224, 180, 74), width=2)
    draw.polygon([(234, 355), (278, 355), (256, 435)], fill=(198, 142, 108))
    # Gold & Ruby Eagle Lapel Studs on Jumpsuit
    for stud_y in (395, 430, 465, 495):
        off_x = int((stud_y - 360) * 0.38)
        for sx in (202 - off_x, 310 + off_x):
            draw.ellipse([sx - 7, stud_y - 7, sx + 7, stud_y + 7], fill=(238, 192, 68), outline=(178, 32, 36), width=2)

    # Elvis Neck & Face
    draw.rectangle([222, 315, 290, 375], fill=(214, 158, 122))
    draw.ellipse([188, 185, 324, 348], fill=(224, 168, 132), outline=(168, 114, 84), width=2)

    # Iconic Jet-Black Pompadour Hair & Mutton-Chop Sideburns
    draw.ellipse([172, 126, 342, 238], fill=(16, 18, 26))
    draw.ellipse([190, 110, 352, 212], fill=(22, 26, 38))
    # Forehead curl wave highlight
    draw.arc([202, 124, 332, 200], start=200, end=340, fill=(68, 78, 108), width=5)
    # Left & Right Sideburns ("Patillas del Rey")
    draw.polygon([(184, 210), (206, 215), (204, 302), (186, 294)], fill=(18, 20, 28))
    draw.polygon([(328, 210), (306, 215), (308, 302), (326, 294)], fill=(18, 20, 28))

    # Gold-Rimmed TCB Aviator Sunglasses
    draw.rounded_rectangle([200, 232, 250, 268], radius=8, fill=(58, 38, 22), outline=(238, 196, 78), width=4)
    draw.rounded_rectangle([262, 232, 312, 268], radius=8, fill=(58, 38, 22), outline=(238, 196, 78), width=4)
    draw.line([(248, 242), (264, 242)], fill=(238, 196, 78), width=4)
    draw.line([(188, 244), (200, 244)], fill=(238, 196, 78), width=3)
    draw.line([(312, 244), (324, 244)], fill=(238, 196, 78), width=3)
    # Lens sheen
    draw.line([(210, 240), (228, 258)], fill=(245, 215, 130), width=3)
    draw.line([(272, 240), (290, 258)], fill=(245, 215, 130), width=3)

    # Nose & Trademark Half-Smile + Microphone
    draw.line([(256, 252), (252, 284), (264, 286)], fill=(172, 116, 86), width=3)
    draw.arc([228, 288, 288, 322], start=10, end=165, fill=(168, 64, 64), width=5)
    # Vintage chrome stage microphone at lower right
    draw.line([(315, 345), (355, 495)], fill=(190, 198, 208), width=6)
    draw.ellipse([296, 318, 332, 358], fill=(210, 218, 226), outline=(90, 98, 110), width=3)

    # Banner & Typography on Zone A Velvet Canvas
    f_title = load_font(44, bold=True)
    f_sub = load_font(22, bold=True)
    draw.text((256, 68), "THE KING", font=f_title, fill=(246, 204, 78), anchor="mm")
    for star_cx in (118.0, 394.0):
        star_pts = []
        for si in range(10):
            s_ang = math.radians(-90 + si * 36)
            s_r = 16.0 if (si % 2 == 0) else 7.0
            star_pts.append((star_cx + s_r * math.cos(s_ang), 66.0 + s_r * math.sin(s_ang)))
        draw.polygon(star_pts, fill=(246, 204, 78))
    draw.rectangle([56, 522, 456, 592], fill=(24, 14, 36), outline=(228, 182, 68), width=3)
    draw.text((256, 545), "ELVIS • VIVA LAS VEGAS", font=f_sub, fill=(248, 214, 96), anchor="mm")
    draw.text((256, 574), "TERCIOPELO DE COLECCIÓN — FALLOUT 1997", font=load_font(15, bold=True), fill=(214, 168, 224), anchor="mm")

    # Zone B (x: 512..1024, y: 0..640): Back of Framed Canvas + Area 51 / Graceland Label
    draw.rectangle([528, 16, 1007, 623], outline=(78, 54, 28), width=18)
    draw.rectangle([600, 160, 936, 460], fill=(228, 216, 188), outline=(92, 68, 42), width=3)
    draw.text((768, 205), "PROPIEDAD DEL ÁREA 51", font=load_font(22, bold=True), fill=(156, 28, 28), anchor="mm")
    draw.text((768, 245), "ARTEFACTO TERRESTRE #01-ELVIS", font=load_font(17, bold=True), fill=(42, 36, 28), anchor="mm")
    draw.text((768, 295), "«Un cuadro sobre terciopelo de 'El Rey'.", font=load_font(16, bold=False), fill=(52, 44, 34), anchor="mm")
    draw.text((768, 322), "Verdaderamente una magnífica obra de arte.»", font=load_font(16, bold=False), fill=(52, 44, 34), anchor="mm")
    draw.text((768, 380), "HALLADO EN PLATILLO VOLANTE ESTRELLADO", font=load_font(14, bold=True), fill=(98, 42, 32), anchor="mm")
    draw.text((768, 415), "SUR DE CALIFORNIA — AÑO 2161", font=load_font(15, bold=True), fill=(42, 36, 28), anchor="mm")

    # Zone C (y: 640..1024): Carved Gilded Frame Molding Stripes
    for y_band in (664, 720, 790, 860, 930, 985):
        draw.line([(0, y_band), (1023, y_band)], fill=(238, 198, 88), width=6)
        draw.line([(0, y_band + 8), (1023, y_band + 8)], fill=(96, 64, 22), width=4)

    return im.filter(ImageFilter.SMOOTH_MORE)


def build_giant_footprint_texture() -> Image.Image:
    """
    Construye el atlas 1024x1024 de la Huella Gigante de Godzilla (Fallout 1 'Giant Footprint'):
      - Mapeo 1:1 en planta con la malla 3D GiantGodzillaFootprint.nif (dx en [-540..+540], dy en [-436..+644])
      - Exterior fundido con el color exacto de la arena del desierto de Nueva California
      - Reborde elevado de barro/tierra desplazada con grietas radiales de impacto sísmico
      - Paredes interiores en sombra pronunciada y fondo hundido con textura de escamas reptilianas colosales
      - Tres surcos profundos de garras en las puntas de los tres dedos
    """
    yy, xx = np.mgrid[0:1024, 0:1024].astype(np.float32)
    u_img = xx / 1024.0
    v_img = 1.0 - (yy / 1024.0)
    dx = ((u_img - 0.02) / 0.96) * 1080.0 - 540.0
    dy = ((v_img - 0.02) / 0.96) * 1080.0 - 436.0

    def seg_sdf_np(px, py, ax, ay, bx, by, ra, rb):
        vx, vy = bx - ax, by - ay
        wx, wy = px - ax, py - ay
        t = np.clip((wx * vx + wy * vy) / (vx * vx + vy * vy + 1e-8), 0.0, 1.0)
        dist = np.hypot(wx - t * vx, wy - t * vy)
        rad = ra + t * (rb - ra)
        return dist - rad

    def smin_np(a, b, k):
        h = np.clip(0.5 + 0.5 * (b - a) / k, 0.0, 1.0)
        return b * (1.0 - h) + a * h - k * h * (1.0 - h)

    d_sole = seg_sdf_np(dx, dy, 0.0, -160.0, 0.0, 10.0, 115.0, 180.0)
    d_toe_l = seg_sdf_np(dx, dy, -95.0, 15.0, -290.0, 295.0, 105.0, 58.0)
    d_toe_m = seg_sdf_np(dx, dy, 0.0, 25.0, 0.0, 375.0, 116.0, 62.0)
    d_toe_r = seg_sdf_np(dx, dy, 95.0, 15.0, 290.0, 295.0, 105.0, 58.0)
    d_toes = np.minimum(np.minimum(d_toe_l, d_toe_m), d_toe_r)
    d_body = smin_np(d_sole, d_toes, 16.0)

    d_claw_l = seg_sdf_np(dx, dy, -290.0, 295.0, -362.0, 385.0, 38.0, 12.0)
    d_claw_m = seg_sdf_np(dx, dy, 0.0, 375.0, 0.0, 472.0, 42.0, 12.0)
    d_claw_r = seg_sdf_np(dx, dy, 290.0, 295.0, 362.0, 385.0, 38.0, 12.0)
    d_claws = np.minimum(np.minimum(d_claw_l, d_claw_m), d_claw_r)
    d_fp = np.minimum(d_body, d_claws)

    # Fine desert sand grain & rock noise
    grain = (
        np.sin(dx * 0.19 + dy * 0.17) * 5.0
        + np.cos(dx * 0.43 - dy * 0.37) * 3.5
        + np.sin(dx * 0.89 + dy * 0.83) * 2.5
    )

    # Reptilian hexagonal scale pattern impressed into the deep sole & toes (d_fp < -14)
    sx = dx / 22.0
    sy = dy / 22.0
    hex_pat = (
        np.cos(sx * math.pi)
        * np.cos((0.5 * sx + 0.866 * sy) * math.pi)
        * np.cos((0.5 * sx - 0.866 * sy) * math.pi)
    )
    scale_groove = np.where(np.abs(hex_pat) < 0.16, -14.0, 8.0 * np.abs(hex_pat))
    # Concentric pressure rings inside the sole & toes
    pressure_rings = np.sin(d_fp * 0.24) * 5.0

    # Radial seismic cracks across the raised mud rim (-8 <= d_fp <= 68)
    ang = np.arctan2(dy - 40.0, dx)
    radial_crack = np.where(
        (d_fp >= -8.0) & (d_fp <= 68.0) & (np.abs(np.sin(ang * 22.0 + np.sin(d_fp * 0.09) * 1.6)) > 0.94),
        -24.0,
        0.0,
    )

    # 1. Outer dark brown rocky earth base (calibrated to Fallout4.esm LTEX desert soil RGB ~ 76, 58, 38 + grey pebbles)
    pebble_field = np.sin(dx * 0.73 + dy * 0.61) * np.cos(dx * 0.59 - dy * 0.83)
    pebble_mask = np.where(pebble_field > 0.72, (pebble_field - 0.72) / 0.28, 0.0)
    r_sand = (74.0 + grain * 1.1) * (1.0 - pebble_mask) + 104.0 * pebble_mask
    g_sand = (56.0 + grain * 0.85) * (1.0 - pebble_mask) + 98.0 * pebble_mask
    b_sand = (37.0 + grain * 0.60) * (1.0 - pebble_mask) + 88.0 * pebble_mask

    # 2. Raised displaced mud/earth rim (0 <= d_fp <= 84): churned dark rocky ridge with radial cracks & stones
    rim_arch = np.exp(-(((d_fp - 14.0) / 24.0) ** 2))
    r_rim = (84.0 * rim_arch + r_sand * (1.0 - rim_arch)) + radial_crack * 0.85
    g_rim = (64.0 * rim_arch + g_sand * (1.0 - rim_arch)) + radial_crack * 0.65
    b_rim = (42.0 * rim_arch + b_sand * (1.0 - rim_arch)) + radial_crack * 0.45

    # 3. Steep inner wall shadow (-18 <= d_fp <= 12): dark sheared earth wall so footprint outline pops dramatically
    wall_t = np.clip((d_fp - (-18.0)) / 30.0, 0.0, 1.0)
    r_wall = 30.0 + 48.0 * (wall_t ** 1.5) + grain * 0.5
    g_wall = 22.0 + 36.0 * (wall_t ** 1.5) + grain * 0.4
    b_wall = 14.0 + 24.0 * (wall_t ** 1.5) + grain * 0.3

    # 4. Deep compressed Godzilla sole & three toe pads (d_fp < -18): dark compacted mud with reptilian scale imprints
    r_sole = 42.0 + scale_groove * 0.85 + pressure_rings * 0.7 + grain * 0.4
    g_sole = 31.0 + scale_groove * 0.65 + pressure_rings * 0.55 + grain * 0.3
    b_sole = 20.0 + scale_groove * 0.45 + pressure_rings * 0.4 + grain * 0.2

    # Blend smoothly across zones
    w_inner = np.clip((d_fp - (-22.0)) / 10.0, 0.0, 1.0)
    w_rim = np.clip((d_fp - 4.0) / 10.0, 0.0, 1.0)
    w_outer = np.clip((d_fp - 44.0) / 28.0, 0.0, 1.0)

    r = r_sole * (1.0 - w_inner) + r_wall * w_inner
    g = g_sole * (1.0 - w_inner) + g_wall * w_inner
    b = b_sole * (1.0 - w_inner) + b_wall * w_inner

    r = r * (1.0 - w_rim) + r_rim * w_rim
    g = g * (1.0 - w_rim) + g_rim * w_rim
    b = b * (1.0 - w_rim) + b_rim * w_rim

    r = r * (1.0 - w_outer) + r_sand * w_outer
    g = g * (1.0 - w_outer) + g_sand * w_outer
    b = b * (1.0 - w_outer) + b_sand * w_outer

    # 5. Deepest claw trenches (d_claws < -4): near-black gouged earth
    claw_mask = np.clip((-4.0 - d_claws) / 16.0, 0.0, 1.0)
    r = r * (1.0 - 0.55 * claw_mask)
    g = g * (1.0 - 0.58 * claw_mask)
    b = b * (1.0 - 0.60 * claw_mask)

    rgb = np.stack([
        np.clip(r, 12.0, 235.0),
        np.clip(g, 10.0, 215.0),
        np.clip(b, 8.0, 185.0),
    ], axis=2).astype(np.uint8)
    return Image.fromarray(rgb)


def ensure_cabinet_donor_nif() -> str:
    """Extrae meshes\\setdressing\\garage\\cabinetgarage02.nif de Fallout4 - Meshes.ba2 si no existe en TEST_MESHES_DIR."""
    os.makedirs(TEST_MESHES_DIR, exist_ok=True)
    donor_path = os.path.join(TEST_MESHES_DIR, "CabinetGarage02.nif")
    if os.path.exists(donor_path):
        return donor_path
    meshes_ba2 = os.path.join(FO4_DATA_DIR, "Fallout4 - Meshes.ba2")
    with open(meshes_ba2, "rb") as f:
        hdr = f.read(24)
        _magic, _ver, _mtype, num_files, name_tbl_ofs = struct.unpack("<4sI4sIQ", hdr)
        f.seek(name_tbl_ofs)
        target_idx = None
        for i in range(num_files):
            nlen = struct.unpack("<H", f.read(2))[0]
            name = f.read(nlen).decode("utf-8", "replace").lower().replace("/", "\\")
            if name == "meshes\\setdressing\\garage\\cabinetgarage02.nif":
                target_idx = i
                break
        if target_idx is None:
            raise RuntimeError("No se encontró CabinetGarage02.nif en Fallout4 - Meshes.ba2")
        f.seek(24 + target_idx * 36)
        _nh, _ext, _dh, _unk, ofs, packed_sz, unpacked_sz, _align = struct.unpack("<I4sIIQIII", f.read(36))
        f.seek(ofs)
        raw_nif = zlib.decompress(f.read(packed_sz)) if packed_sz > 0 else f.read(unpacked_sz)
    with open(donor_path, "wb") as wf:
        wf.write(raw_nif)
    return donor_path


def build_bgsm_v2_bytes(
    diffuse_path: str,
    normal_path: str,
    specular_path: str,
    envmap_path: str = "Shared/Cubemaps/mipblur_DefaultOutside1.dds",
    root_material: str = "template/ArmorTemplate_Wet.bgsm",
    envmap_scale: float = 0.65,
    specular_color: tuple[float, float, float] = (0.90, 0.88, 0.82),
    specular_mult: float = 0.95,
    smoothness: float = 1.05,
    subsurface_lighting: int = 0,
    subsurface_rolloff: float = 0.0,
    enable_envmap: int | None = None,
) -> bytes:
    with open(os.path.join(TEST_MESHES_DIR, "syntharmorblack.bgsm"), "rb") as rf:
        tpl = rf.read()

    hdr = bytearray(tpl[:63])
    hdr[57] = (0 if envmap_scale <= 0.0 else 1) if enable_envmap is None else int(bool(enable_envmap))
    struct.pack_into("<f", hdr, 58, envmap_scale)
    hdr[62] = 0

    def pack_lstr(s: str) -> bytes:
        b = s.encode("ascii") + b"\x00"
        return struct.pack("<I", len(b)) + b

    tex_block = (
        pack_lstr(diffuse_path)
        + pack_lstr(normal_path)
        + pack_lstr(specular_path)
        + pack_lstr("")
        + pack_lstr(envmap_path)
        + pack_lstr("")
        + pack_lstr("")
        + pack_lstr("")
        + pack_lstr("")
    )

    mid_64 = struct.pack(
        "<BBffBfBffffffffffff",
        0,
        0,
        2.0,
        0.0,
        subsurface_lighting,
        subsurface_rolloff,
        1,
        specular_color[0],
        specular_color[1],
        specular_color[2],
        specular_mult,
        smoothness,
        5.0,
        -1.0,
        -1.0,
        -1.0,
        -1.0,
        -1.0,
        -1.0,
    )

    root_block = pack_lstr(root_material)
    tail_59 = tpl[-59:]
    return bytes(hdr) + tex_block + mid_64 + root_block + tail_59


BLENDER_EXPORT_SCRIPT = r"""
import math
import os
import sys
from collections import defaultdict, deque
import bpy
import bmesh
from mathutils import Vector

TEST_DIR = r"__TEST_DIR__"
OUT_DIR = r"__OUT_DIR__"
PYNIFLY_DIR = r"__PYNIFLY_DIR__"

if PYNIFLY_DIR not in sys.path:
    sys.path.insert(0, PYNIFLY_DIR)
from pyn import pynifly


def clear_scene():
    for obj in list(bpy.data.objects):
        bpy.data.objects.remove(obj, do_unlink=True)
    for m in list(bpy.data.meshes):
        bpy.data.meshes.remove(m)
    for mat in list(bpy.data.materials):
        bpy.data.materials.remove(mat)


def assign_shader_on_material(mat, bgsm_path: str, diffuse_dds: str, normal_dds: str, spec_dds: str, env_dds: str = r"textures\Shared\Cubemaps\mipblur_DefaultOutside1.dds"):
    mat["BS_Shader_Block_Name"] = "BSLightingShaderProperty"
    mat["BSLSP_Shader_Name"] = bgsm_path
    mat["BSShaderTextureSet_Diffuse"] = diffuse_dds
    mat["BSShaderTextureSet_Normal"] = normal_dds
    mat["BSShaderTextureSet_Specular"] = spec_dds
    mat["BSShaderTextureSet_EnvMap"] = env_dds
    for k in ["NiAlphaProperty_flags", "NiAlphaProperty_threshold", "BSShaderTextureSet_EnvMapMask", "BSLSP_Shader_Type"]:
        if k in mat:
            del mat[k]
    if hasattr(mat, "pyn_shader"):
        mat.pyn_shader.Shader_Type = ""
    if mat.node_tree:
        for n in mat.node_tree.nodes:
            if n.bl_idname == "ShaderNodeTexImage":
                n.image = None
        bsdf = mat.node_tree.nodes.get("Principled BSDF")
        if bsdf and "Alpha" in bsdf.inputs:
            for l in list(bsdf.inputs["Alpha"].links):
                mat.node_tree.links.remove(l)
            bsdf.inputs["Alpha"].default_value = 1.0


def recompute_welded_normals(mesh_obj):
    bm = bmesh.new()
    bm.from_mesh(mesh_obj.data)
    bm.verts.ensure_lookup_table()
    bm.faces.ensure_lookup_table()
    bm.normal_update()

    pos_groups = defaultdict(list)
    vert_to_key = {}
    for v in bm.verts:
        k = (round(v.co.x, 3), round(v.co.y, 3), round(v.co.z, 3))
        pos_groups[k].append(v)
        vert_to_key[v.index] = k

    welded_n = {}
    for k, vlist in pos_groups.items():
        fn_sum = Vector((0.0, 0.0, 0.0))
        for v in vlist:
            for f in v.link_faces:
                fn_sum += f.normal * max(f.calc_area(), 1e-5)
        welded_n[k] = fn_sum.normalized() if fn_sum.length > 1e-6 else Vector((0.0, 0.0, 1.0))

    new_cn = [Vector((0.0, 0.0, 1.0))] * len(mesh_obj.data.loops)
    for f in bm.faces:
        for l in f.loops:
            new_cn[l.index] = welded_n[vert_to_key[l.vert.index]]

    bm.to_mesh(mesh_obj.data)
    mesh_obj.data.update()
    mesh_obj.data.normals_split_custom_set(new_cn)
    bm.free()


def sculpt_killian_frontier_hat(hat_obj):
    # Esculpe en Blender el sombrero de Killian Darkwater:
    # - Ensancha el ala frontal/lateral (+16%) con curvatura vaquera ascendente en los flancos
    # - Eleva y estiliza la corona frontal (+1.4 unidades) con hendidura de sheriff en la cima
    bm = bmesh.new()
    bm.from_mesh(hat_obj.data)
    bm.verts.ensure_lookup_table()

    mw = hat_obj.matrix_world
    inv_mw = mw.inverted()
    wcoords = [mw @ v.co for v in bm.verts]
    if not wcoords:
        bm.free()
        return
    z_min = min(c.z for c in wcoords)
    z_max = max(c.z for c in wcoords)
    z_span = max(z_max - z_min, 1.0)
    cx = 0.5 * (min(c.x for c in wcoords) + max(c.x for c in wcoords))
    cy = 0.5 * (min(c.y for c in wcoords) + max(c.y for c in wcoords))

    for v in bm.verts:
        wco = mw @ v.co
        tz = (wco.z - z_min) / z_span
        dx = wco.x - cx
        dy = wco.y - cy
        rad = math.hypot(dx, dy)
        # Ensanchar el ala exterior y curvar los bordes laterales hacia arriba (estilo sombrero fronterizo)
        if rad > 5.2 and tz < 0.58:
            brim_t = min(1.0, (rad - 5.2) / 4.5)
            wco.x = cx + dx * (1.0 + 0.16 * brim_t)
            wco.y = cy + dy * (1.0 + 0.12 * brim_t)
            side_curl = min(1.0, (abs(dx) / 7.5) ** 1.6)
            wco.z += 0.95 * brim_t * side_curl
        # Elevar la corona superior con pellizco frontal de alcalde/sheriff
        if tz > 0.55:
            crown_t = (tz - 0.55) / 0.45
            pinch = math.cos(min(1.0, abs(dx) / 4.8) * 0.5 * math.pi) ** 2
            wco.z += 1.35 * crown_t * (0.45 + 0.55 * pinch)
        v.co = inv_mw @ wco

    bm.to_mesh(hat_obj.data)
    hat_obj.data.update()
    bm.free()
    recompute_welded_normals(hat_obj)


def sculpt_lars_tactical_crest_helmet(helm_obj):
    # Esculpe en Blender el casco táctico de la Guardia de Ciudad Chatarra del Capitán Lars:
    # - Añade una cresta dorsal blindada a lo largo del eje central superior del casco
    # - Proyecta la visera frontal hacia delante e inclina las placas laterales de protección
    bm = bmesh.new()
    bm.from_mesh(helm_obj.data)
    bm.verts.ensure_lookup_table()

    mw = helm_obj.matrix_world
    inv_mw = mw.inverted()
    wcoords = [mw @ v.co for v in bm.verts]
    if not wcoords:
        bm.free()
        return
    z_min = min(c.z for c in wcoords)
    z_max = max(c.z for c in wcoords)
    z_span = max(z_max - z_min, 1.0)
    cx = 0.5 * (min(c.x for c in wcoords) + max(c.x for c in wcoords))

    for v in bm.verts:
        wco = mw @ v.co
        tz = (wco.z - z_min) / z_span
        dx = abs(wco.x - cx)
        # Cresta dorsal táctica en la bóveda superior
        if tz > 0.62 and dx < 2.6:
            crest_x = math.cos((dx / 2.6) * 0.5 * math.pi) ** 2
            crest_z = min(1.0, (tz - 0.62) / 0.30)
            wco.z += 1.55 * crest_x * crest_z
        # Visera frontal reforzada
        if 0.35 < tz < 0.68 and wco.y < -4.0:
            brow_t = min(1.0, (-4.0 - wco.y) / 4.5)
            wco.y -= 0.85 * brow_t
            wco.z -= 0.25 * brow_t
        v.co = inv_mw @ wco

    bm.to_mesh(helm_obj.data)
    helm_obj.data.update()
    bm.free()
    recompute_welded_normals(helm_obj)


def filter_mesh_islands(mesh_obj, keep_predicate):
    bm = bmesh.new()
    bm.from_mesh(mesh_obj.data)
    bm.verts.ensure_lookup_table()

    visited = set()
    to_delete = []
    for v in bm.verts:
        if v.index in visited:
            continue
        q = deque([v])
        visited.add(v.index)
        comp = []
        while q:
            cur = q.popleft()
            comp.append(cur)
            for e in cur.link_edges:
                nb = e.other_vert(cur)
                if nb.index not in visited:
                    visited.add(nb.index)
                    q.append(nb)
        coords = [mesh_obj.matrix_world @ cv.co for cv in comp]
        if not keep_predicate(coords, len(comp)):
            to_delete.extend(comp)

    if to_delete:
        bmesh.ops.delete(bm, geom=to_delete, context="VERTS")
        bm.to_mesh(mesh_obj.data)
        mesh_obj.data.update()
    bm.free()


def is_rear_patch_island(coords, n):
    max_y = max(c.y for c in coords)
    min_abs_x = min(abs(c.x) for c in coords)
    dz = max(c.z for c in coords) - min(c.z for c in coords)
    if max_y < -6.5:
        if n == 20:
            return True
        if n == 10 and (min_abs_x > 2.40 or dz < 0.5):
            return True
        if n in (9, 8, 6) and min_abs_x > 2.40:
            return True
        if n == 4 and min_abs_x > 2.40 and dz < 0.5:
            return True
    return False


def keep_tycho_desert_ranger_helmet(coords, n):
    min_x = min(c.x for c in coords)
    if n == 102 and min_x > 0.4:
        return False
    if n in (115, 101, 90, 72, 68, 57, 46, 35):
        return True
    if is_rear_patch_island(coords, n):
        return True
    return False


def sculpt_tycho_ranger_helmet(helm_obj):
    # Esculpe el casco de Ranger del Desierto de Tycho:
    # - Cierra el domo occipital posterior y proyecta una visera parasol sobre los lentes ópticos
    bm = bmesh.new()
    bm.from_mesh(helm_obj.data)
    bm.verts.ensure_lookup_table()
    mw = helm_obj.matrix_world
    inv_mw = mw.inverted()
    for v in bm.verts:
        wco = mw @ v.co
        # Visera parasol de Ranger sobre la parte superior de la lente frontal
        if 121.0 < wco.z < 125.5 and wco.y > 4.2:
            visor_t = min(1.0, (wco.y - 4.2) / 5.0) * math.cos(min(1.0, abs(wco.x) / 6.8) * 0.5 * math.pi)
            wco.y += 1.25 * visor_t
            wco.z += 0.35 * visor_t
        v.co = inv_mw @ wco
    bm.to_mesh(helm_obj.data)
    helm_obj.data.update()
    bm.free()
    recompute_welded_normals(helm_obj)


def process_and_export(src_nif: str, dst_nif: str, transform_fn, import_collisions: bool = True):
    clear_scene()
    bpy.ops.object.select_all(action="DESELECT")
    bpy.context.view_layer.objects.active = None
    src_path = os.path.join(TEST_DIR, src_nif)
    dst_path = os.path.join(OUT_DIR, dst_nif)
    bpy.ops.import_scene.pynifly(
        filepath=src_path,
        import_cutpoints=False,
        import_tris=False,
        import_collisions=import_collisions,
    )
    meshes = [o for o in bpy.data.objects if o.type == "MESH" and not o.name.startswith("bhk")]
    transform_fn(meshes)
    meshes = [o for o in bpy.data.objects if o.type == "MESH" and not o.name.startswith("bhk")]

    bpy.ops.object.select_all(action="DESELECT")
    for m in meshes:
        m.select_set(True)
    bpy.context.view_layer.objects.active = meshes[0]
    bpy.ops.export_scene.pynifly(filepath=dst_path, target_game="FO4")
    print(f"[Exported V13 Junktown NIF] {dst_nif}")


def main():
    os.makedirs(OUT_DIR, exist_ok=True)

    # 1. Sombrero de Alcalde Fronterizo de Killian Darkwater (Masculino, Femenino y GO)
    def xf_killian_hat(meshes):
        for obj in meshes:
            sculpt_killian_frontier_hat(obj)
            for mat in obj.data.materials:
                assign_shader_on_material(
                    mat,
                    r"Materials\V13Chronicles\Junktown\KillianHat.BGSM",
                    r"textures\V13Chronicles\Junktown\KillianHat_d.dds",
                    r"textures\Armor\MacCready\Mac_n.dds",
                    r"textures\Armor\MacCready\Mac_s.dds",
                )

    process_and_export("MacHatM.nif", "KillianMayorHatM.nif", xf_killian_hat)
    process_and_export("MacHatF.nif", "KillianMayorHatF.nif", xf_killian_hat)
    process_and_export("HatGO.nif", "KillianMayorHatGO.nif", xf_killian_hat, import_collisions=True)

    # 2. Casco Táctico con Cresta del Capitán Lars (Masculino, Femenino y GO)
    def xf_lars_helmet(meshes):
        for obj in list(meshes):
            if "HelmetLight" in obj.name or "Light" in obj.name:
                bpy.data.objects.remove(obj, do_unlink=True)
                continue
            sculpt_lars_tactical_crest_helmet(obj)
            for mat in obj.data.materials:
                assign_shader_on_material(
                    mat,
                    r"Materials\V13Chronicles\Junktown\LarsHelm.BGSM",
                    r"textures\V13Chronicles\Junktown\LarsHelm_d.dds",
                    r"textures\Armor\CombatArmor\CombatArmor_Helmet_n.dds",
                    r"textures\Armor\CombatArmor\CombatArmor_Helmet_s.dds",
                )

    process_and_export("M_Helmet.nif", "LarsGuardHelmetM.nif", xf_lars_helmet)
    process_and_export("F_Helmet.nif", "LarsGuardHelmetF.nif", xf_lars_helmet)
    process_and_export("GO_Helmet.nif", "LarsGuardHelmetGO.nif", xf_lars_helmet, import_collisions=True)

    # 3. Casco de Ranger del Desierto de Tycho con Visor Óptico Ámbar-Bronce
    def xf_tycho_helmet(meshes):
        shell_objs = [o for o in meshes if ":1" not in o.name]
        visor_objs = [o for o in meshes if ":1" in o.name]
        for obj in shell_objs:
            filter_mesh_islands(obj, keep_tycho_desert_ranger_helmet)
            sculpt_tycho_ranger_helmet(obj)
            assign_shader_on_material(
                obj.data.materials[0],
                r"Materials\V13Chronicles\Junktown\TychoHelm.BGSM",
                r"textures\V13Chronicles\Junktown\TychoHelm_d.dds",
                r"textures\Armor\FlightHelmet\Helmet_02_n.dds",
                r"textures\Armor\FlightHelmet\Helmet_02_s.dds",
            )
        for obj in visor_objs:
            recompute_welded_normals(obj)
            visor_mat = shell_objs[0].data.materials[0].copy()
            visor_mat.name = "TychoVisor_OpaqueMTS"
            obj.data.materials.clear()
            obj.data.materials.append(visor_mat)
            obj.active_material = visor_mat
            assign_shader_on_material(
                visor_mat,
                r"Materials\V13Chronicles\Junktown\TychoVisor.BGSM",
                r"textures\V13Chronicles\Junktown\TychoVisor_d.dds",
                r"textures\Armor\FlightHelmet\Helmet_02_n.dds",
                r"textures\Armor\FlightHelmet\Helmet_02_s.dds",
                env_dds=r"textures\Shared\Cubemaps\shinyglass_e.dds",
            )

    process_and_export("FlightHelmet02.nif", "TychoRangerHelmet.nif", xf_tycho_helmet)
    process_and_export("helmet02go.nif", "TychoRangerHelmetGO.nif", xf_tycho_helmet, import_collisions=True)

    # 4. Cabina Telefónica Inusual de Fallout 1 (1997) — 1960s British Police Call Box (TARDIS)
    def build_tardis_geometry_on_object(mesh_obj):
        bm = bmesh.new()
        bm.from_mesh(mesh_obj.data)
        uv_layer = bm.loops.layers.uv.active
        if uv_layer is None:
            uv_layer = bm.loops.layers.uv.new("UVMap")
        bmesh.ops.delete(bm, geom=list(bm.verts), context="VERTS")

        def uv_rect(px0, py0, px1, py1):
            return (
                px0 / 1024.0,
                1.0 - (py1 / 1024.0),
                px1 / 1024.0,
                1.0 - (py0 / 1024.0),
            )

        UV_TIMBER = uv_rect(24, 24, 488, 488)
        UV_PILLAR = uv_rect(16, 16, 144, 496)
        UV_WINDOW = uv_rect(516, 4, 1020, 316)
        UV_SIGN = uv_rect(516, 324, 1020, 444)
        UV_PLAQUE = uv_rect(524, 460, 755, 755)
        UV_BADGE = uv_rect(772, 452, 1020, 764)
        UV_PANEL = uv_rect(12, 524, 244, 756)
        UV_LAMP = uv_rect(520, 776, 760, 1016)
        UV_PLINTH = uv_rect(776, 776, 1016, 1016)

        def add_quad(p0, p1, p2, p3, uv_box):
            u0, v0_uv, u1, v1_uv = uv_box
            verts = [bm.verts.new(p0), bm.verts.new(p1), bm.verts.new(p2), bm.verts.new(p3)]
            f = bm.faces.new(verts)
            f.material_index = 0
            f.loops[0][uv_layer].uv = (u0, v0_uv)
            f.loops[1][uv_layer].uv = (u1, v0_uv)
            f.loops[2][uv_layer].uv = (u1, v1_uv)
            f.loops[3][uv_layer].uv = (u0, v1_uv)

        def add_box(x0, x1, y0, y1, z0, z1, uv_front, uv_back=None, uv_left=None, uv_right=None, uv_top=None, uv_bot=None):
            uv_back = uv_back or uv_front
            uv_left = uv_left or uv_front
            uv_right = uv_right or uv_front
            uv_top = uv_top or uv_front
            uv_bot = uv_bot or uv_front
            # Front (-Y)
            add_quad((x0, y0, z0), (x1, y0, z0), (x1, y0, z1), (x0, y0, z1), uv_front)
            # Back (+Y)
            add_quad((x1, y1, z0), (x0, y1, z0), (x0, y1, z1), (x1, y1, z1), uv_back)
            # Left (-X)
            add_quad((x0, y1, z0), (x0, y0, z0), (x0, y0, z1), (x0, y1, z1), uv_left)
            # Right (+X)
            add_quad((x1, y0, z0), (x1, y1, z0), (x1, y1, z1), (x1, y0, z1), uv_right)
            # Top (+Z)
            add_quad((x0, y0, z1), (x1, y0, z1), (x1, y1, z1), (x0, y1, z1), uv_top)
            # Bottom (-Z)
            add_quad((x0, y1, z0), (x1, y1, z0), (x1, y0, z0), (x0, y0, z0), uv_bot)

        # 1. Stepped Base Plinth (Z: 0..10)
        add_box(-62.0, 62.0, -62.0, 62.0, 0.0, 6.0, UV_PLINTH)
        add_box(-58.0, 58.0, -58.0, 58.0, 6.0, 10.0, UV_TIMBER)

        # 2. 4 Fluted Corner Pillars (Z: 10..216)
        for sx in (-1.0, 1.0):
            for sy in (-1.0, 1.0):
                cx, cy = sx * 50.0, sy * 50.0
                add_box(cx - 7.5, cx + 7.5, cy - 7.5, cy + 7.5, 10.0, 216.0, UV_PILLAR, uv_top=UV_TIMBER)
                # Outer trim flute strip on each pillar
                add_box(cx - 5.5, cx + 5.5, cy - 8.5, cy + 8.5, 12.0, 214.0, UV_PILLAR, uv_top=UV_TIMBER)
                add_box(cx - 8.5, cx + 8.5, cy - 5.5, cy + 5.5, 12.0, 214.0, UV_PILLAR, uv_top=UV_TIMBER)

        # 3. Inner Recessed Core Box (Z: 10..202) — provides the recessed panel & window backdrops
        # We build each of the 4 sides explicitly so each panel & window has exact UVs!
        w_in = 43.0
        # Core interior backing block behind stiles/rails
        add_box(-w_in, w_in, -w_in, w_in, 10.0, 202.0, UV_TIMBER)

        # Helper to build the framed stiles, rails, 3x2 recessed panels, and 2x1 upper windows on all 4 sides
        z_rails = [
            (10.0, 16.0),
            (52.0, 58.0),
            (94.0, 100.0),
            (136.0, 144.0),
            (194.0, 202.0),
        ]
        z_panel_rows = [
            (16.0, 52.0),   # Row 0 (bottom)
            (58.0, 94.0),   # Row 1 (middle: plaque & badge on front!)
            (100.0, 136.0), # Row 2 (upper-middle)
        ]
        z_win = (144.0, 194.0)

        # Front (-Y) and Back (+Y) stiles & rails
        for side_y, is_front in ((-1.0, True), (1.0, False)):
            y_base = side_y * 43.0
            y_out = side_y * 46.5
            y0, y1 = (y_out, y_base) if is_front else (y_base, y_out)
            # Left stile (-43..-37), Center mullion (-3..+3), Right stile (+37..+43)
            for sx0, sx1 in ((-43.0, -37.0), (-3.5, 3.5), (37.0, 43.0)):
                add_box(sx0, sx1, y0, y1, 10.0, 202.0, UV_TIMBER)
            # Horizontal rails
            for rz0, rz1 in z_rails:
                add_box(-37.0, -3.5, y0, y1, rz0, rz1, UV_TIMBER)
                add_box(3.5, 37.0, y0, y1, rz0, rz1, UV_TIMBER)
            # Recessed panels (y slightly proud of y_base)
            yp_out = side_y * 43.8
            py0, py1 = (yp_out, y_base) if is_front else (y_base, yp_out)
            for r_idx, (pz0, pz1) in enumerate(z_panel_rows):
                # Left column (-37..-3.5) and Right column (+3.5..+37)
                if is_front and r_idx == 2:
                    # Front upper-middle left: Raised white instruction plaque ("PULL TO OPEN")
                    add_box(-35.5, -5.0, -45.2, y_base, pz0 + 1.5, pz1 - 1.5, UV_PLAQUE, uv_back=UV_TIMBER, uv_left=UV_TIMBER, uv_right=UV_TIMBER, uv_top=UV_TIMBER, uv_bot=UV_TIMBER)
                    # Small brass/silver door pull handle next to plaque
                    add_box(-2.8, -1.2, -47.8, -45.0, pz0 + 12.0, pz0 + 22.0, UV_PLINTH)
                    # Front upper-middle right: St. John Ambulance Circular Crest + Yale Lock
                    add_box(3.5, 37.0, py0, py1, pz0, pz1, UV_BADGE)
                else:
                    add_box(-37.0, -3.5, py0, py1, pz0, pz1, UV_PANEL)
                    add_box(3.5, 37.0, py0, py1, pz0, pz1, UV_PANEL)
            # Upper windows (Z: 144..194)
            add_box(-37.0, -3.5, py0, py1, z_win[0], z_win[1], UV_WINDOW)
            add_box(3.5, 37.0, py0, py1, z_win[0], z_win[1], UV_WINDOW)

        # Left (-X) and Right (+X) stiles & rails
        for side_x, is_left in ((-1.0, True), (1.0, False)):
            x_base = side_x * 43.0
            x_out = side_x * 46.5
            x0, x1 = (x_out, x_base) if is_left else (x_base, x_out)
            for sy0, sy1 in ((-43.0, -37.0), (-3.5, 3.5), (37.0, 43.0)):
                add_box(x0, x1, sy0, sy1, 10.0, 202.0, UV_TIMBER)
            for rz0, rz1 in z_rails:
                add_box(x0, x1, -37.0, -3.5, rz0, rz1, UV_TIMBER)
                add_box(x0, x1, 3.5, 37.0, rz0, rz1, UV_TIMBER)
            xp_out = side_x * 43.8
            px0, px1 = (xp_out, x_base) if is_left else (x_base, xp_out)
            for pz0, pz1 in z_panel_rows:
                add_box(px0, px1, -37.0, -3.5, pz0, pz1, UV_PANEL)
                add_box(px0, px1, 3.5, 37.0, pz0, pz1, UV_PANEL)
            add_box(px0, px1, -37.0, -3.5, z_win[0], z_win[1], UV_WINDOW)
            add_box(px0, px1, 3.5, 37.0, z_win[0], z_win[1], UV_WINDOW)

        # 4. Overhanging Top Sign Boxes ("POLICE • PUBLIC CALL BOX", Z: 200..216)
        # Main sign fascia block
        add_box(-54.0, 54.0, -54.0, 54.0, 200.0, 216.0, UV_TIMBER)
        # Front & Back projecting sign lintels
        add_box(-48.0, 48.0, -58.5, -53.5, 201.5, 214.5, UV_SIGN, uv_back=UV_TIMBER, uv_left=UV_TIMBER, uv_right=UV_TIMBER, uv_top=UV_TIMBER, uv_bot=UV_TIMBER)
        add_box(-48.0, 48.0, 53.5, 58.5, 201.5, 214.5, UV_TIMBER, uv_back=UV_SIGN, uv_left=UV_TIMBER, uv_right=UV_TIMBER, uv_top=UV_TIMBER, uv_bot=UV_TIMBER)
        # Left & Right projecting sign lintels
        add_box(-58.5, -53.5, -48.0, 48.0, 201.5, 214.5, UV_TIMBER, uv_back=UV_TIMBER, uv_left=UV_SIGN, uv_right=UV_TIMBER, uv_top=UV_TIMBER, uv_bot=UV_TIMBER)
        add_box(53.5, 58.5, -48.0, 48.0, 201.5, 214.5, UV_TIMBER, uv_back=UV_TIMBER, uv_left=UV_TIMBER, uv_right=UV_SIGN, uv_top=UV_TIMBER, uv_bot=UV_TIMBER)

        # 5. Stepped Pyramidal Roof (Z: 216..242)
        add_box(-52.0, 52.0, -52.0, 52.0, 216.0, 223.0, UV_TIMBER)
        add_box(-45.0, 45.0, -45.0, 45.0, 223.0, 229.0, UV_TIMBER)
        # Sloped pyramidal roof cap from +-44 (Z=229) to +-11 (Z=241)
        rb0, rb1, rt0, rt1, rz0, rz1 = -44.0, 44.0, -11.0, 11.0, 229.0, 241.0
        add_quad((rb0, rb0, rz0), (rb1, rb0, rz0), (rt1, rt0, rz1), (rt0, rt0, rz1), UV_TIMBER)
        add_quad((rb1, rb1, rz0), (rb0, rb1, rz0), (rt0, rt1, rz1), (rt1, rt1, rz1), UV_TIMBER)
        add_quad((rb0, rb1, rz0), (rb0, rb0, rz0), (rt0, rt0, rz1), (rt0, rt1, rz1), UV_TIMBER)
        add_quad((rb1, rb0, rz0), (rb1, rb1, rz0), (rt1, rt1, rz1), (rt1, rt0, rz1), UV_TIMBER)
        add_quad((rt0, rt0, rz1), (rt1, rt0, rz1), (rt1, rt1, rz1), (rt0, rt1, rz1), UV_TIMBER)

        # 6. Top Fresnel Beacon Lamp (Z: 241..268)
        # Base collar
        add_box(-9.5, 9.5, -9.5, 9.5, 241.0, 246.0, UV_PLINTH)
        # Octagonal/12-sided cylindrical Fresnel glass lantern (Z: 246..261, radius 7.2)
        n_sides = 12
        r_lamp = 7.2
        r_cap = 9.0
        for i in range(n_sides):
            a0 = (2.0 * math.pi * i) / n_sides
            a1 = (2.0 * math.pi * (i + 1)) / n_sides
            x0_l, y0_l = r_lamp * math.cos(a0), r_lamp * math.sin(a0)
            x1_l, y1_l = r_lamp * math.cos(a1), r_lamp * math.sin(a1)
            add_quad((x0_l, y0_l, 246.0), (x1_l, y1_l, 246.0), (x1_l, y1_l, 261.0), (x0_l, y0_l, 261.0), UV_LAMP)
            # Conical lamp cap (Z: 261..267)
            x0_c, y0_c = r_cap * math.cos(a0), r_cap * math.sin(a0)
            x1_c, y1_c = r_cap * math.cos(a1), r_cap * math.sin(a1)
            x0_t, y0_t = 1.8 * math.cos(a0), 1.8 * math.sin(a0)
            x1_t, y1_t = 1.8 * math.cos(a1), 1.8 * math.sin(a1)
            add_quad((x0_c, y0_c, 261.0), (x1_c, y1_c, 261.0), (x1_t, y1_t, 267.0), (x0_t, y0_t, 267.0), UV_PLINTH)
        add_box(-8.5, 8.5, -8.5, 8.5, 260.2, 261.5, UV_PLINTH)
        # 4 Protective vertical cage struts around the beacon lamp
        for ang_deg in (45.0, 135.0, 225.0, 315.0):
            rad = math.radians(ang_deg)
            sx, sy = 8.0 * math.cos(rad), 8.0 * math.sin(rad)
            add_box(sx - 0.7, sx + 0.7, sy - 0.7, sy + 0.7, 245.0, 262.0, UV_PLINTH)

        bmesh.ops.triangulate(bm, faces=list(bm.faces))
        bm.to_mesh(mesh_obj.data)
        bm.free()
        mesh_obj.data.update()
        recompute_welded_normals(mesh_obj)

    def xf_tardis_box(meshes):
        main_obj = meshes[0]
        for extra in list(meshes[1:]):
            bpy.data.objects.remove(extra, do_unlink=True)
        if main_obj.parent and main_obj.parent.type == "ARMATURE":
            arm_obj = main_obj.parent
            main_obj.parent = arm_obj.parent
            bpy.data.objects.remove(arm_obj, do_unlink=True)
        for obj in list(bpy.data.objects):
            if obj.type == "ARMATURE":
                bpy.data.objects.remove(obj, do_unlink=True)
        main_obj.modifiers.clear()
        main_obj.vertex_groups.clear()
        build_tardis_geometry_on_object(main_obj)
        for mat in main_obj.data.materials:
            assign_shader_on_material(
                mat,
                r"Materials\V13Chronicles\Junktown\TardisPoliceBox.BGSM",
                r"textures\V13Chronicles\Junktown\TardisPoliceBox_d.dds",
                r"textures\Shared\FlatFlat_n.dds",
                r"textures\interiors\vault\VltNULLforSWAP_s.dds",
            )

    process_and_export("CabinetGarage02.nif", "TardisPoliceBox.nif", xf_tardis_box, import_collisions=True)

    # 5. Cuadro de Terciopelo de «El Rey» (Elvis Presley — Fallout 1 'Fuzzy Painting' en el Platillo Volante)
    def build_elvis_painting_geometry_on_object(mesh_obj):
        bm = bmesh.new()
        bm.from_mesh(mesh_obj.data)
        uv_layer = bm.loops.layers.uv.active
        if uv_layer is None:
            uv_layer = bm.loops.layers.uv.new("UVMap")
        bmesh.ops.delete(bm, geom=list(bm.verts), context="VERTS")

        def uv_rect(px0, py0, px1, py1):
            return (
                px0 / 1024.0,
                1.0 - (py1 / 1024.0),
                px1 / 1024.0,
                1.0 - (py0 / 1024.0),
            )

        UV_FRONT = uv_rect(8, 8, 504, 632)
        UV_BACK = uv_rect(520, 8, 1016, 632)
        UV_FRAME_H = uv_rect(24, 656, 1000, 1000)
        UV_FRAME_V = uv_rect(24, 656, 480, 1000)

        def add_quad(p0, p1, p2, p3, uv_box):
            u0, v0_uv, u1, v1_uv = uv_box
            verts = [bm.verts.new(p0), bm.verts.new(p1), bm.verts.new(p2), bm.verts.new(p3)]
            f = bm.faces.new(verts)
            f.material_index = 0
            f.loops[0][uv_layer].uv = (u0, v0_uv)
            f.loops[1][uv_layer].uv = (u1, v0_uv)
            f.loops[2][uv_layer].uv = (u1, v1_uv)
            f.loops[3][uv_layer].uv = (u0, v1_uv)

        def add_box(x0, x1, y0, y1, z0, z1, uv_front, uv_back=None, uv_left=None, uv_right=None, uv_top=None, uv_bot=None):
            uv_back = uv_back or uv_front
            uv_left = uv_left or uv_front
            uv_right = uv_right or uv_front
            uv_top = uv_top or uv_front
            uv_bot = uv_bot or uv_front
            add_quad((x0, y0, z0), (x1, y0, z0), (x1, y0, z1), (x0, y0, z1), uv_front)
            add_quad((x1, y1, z0), (x0, y1, z0), (x0, y1, z1), (x1, y1, z1), uv_back)
            add_quad((x0, y1, z0), (x0, y0, z0), (x0, y0, z1), (x0, y1, z1), uv_left)
            add_quad((x1, y0, z0), (x1, y1, z0), (x1, y1, z1), (x1, y0, z1), uv_right)
            add_quad((x0, y0, z1), (x1, y0, z1), (x1, y1, z1), (x0, y1, z1), uv_top)
            add_quad((x0, y1, z0), (x1, y1, z0), (x1, y0, z0), (x0, y0, z0), uv_bot)

        # Recessed Velvet Portrait Canvas & Backboard (X: -12.5..12.5, Y: -1.1..1.1, Z: 3.0..33.0)
        add_box(-12.5, 12.5, -1.1, 1.1, 3.0, 33.0, UV_FRONT, uv_back=UV_BACK, uv_left=UV_FRAME_V, uv_right=UV_FRAME_V, uv_top=UV_FRAME_H, uv_bot=UV_FRAME_H)
        # Carved Gilded Wooden Frame (Bottom, Top, Left, Right rails + Inner lip)
        add_box(-15.5, 15.5, -2.2, 2.0, 0.0, 3.5, UV_FRAME_H)
        add_box(-15.5, 15.5, -2.2, 2.0, 32.5, 36.0, UV_FRAME_H)
        add_box(-15.5, -12.0, -2.2, 2.0, 3.5, 32.5, UV_FRAME_V)
        add_box(12.0, 15.5, -2.2, 2.0, 3.5, 32.5, UV_FRAME_V)
        # Inner gold bevel molding
        add_box(-12.8, 12.8, -1.6, -1.0, 2.8, 3.8, UV_FRAME_H)
        add_box(-12.8, 12.8, -1.6, -1.0, 32.2, 33.2, UV_FRAME_H)
        add_box(-12.8, -11.6, -1.6, -1.0, 3.8, 32.2, UV_FRAME_V)
        add_box(11.6, 12.8, -1.6, -1.0, 3.8, 32.2, UV_FRAME_V)

        bmesh.ops.triangulate(bm, faces=list(bm.faces))
        bm.to_mesh(mesh_obj.data)
        bm.free()
        mesh_obj.data.update()
        recompute_welded_normals(mesh_obj)

    def xf_elvis_painting(meshes):
        main_obj = meshes[0]
        for extra in list(meshes[1:]):
            bpy.data.objects.remove(extra, do_unlink=True)
        if main_obj.parent and main_obj.parent.type == "ARMATURE":
            arm_obj = main_obj.parent
            main_obj.parent = arm_obj.parent
            bpy.data.objects.remove(arm_obj, do_unlink=True)
        for obj in list(bpy.data.objects):
            if obj.type == "ARMATURE":
                bpy.data.objects.remove(obj, do_unlink=True)
        main_obj.modifiers.clear()
        main_obj.vertex_groups.clear()
        build_elvis_painting_geometry_on_object(main_obj)
        for mat in main_obj.data.materials:
            assign_shader_on_material(
                mat,
                r"Materials\V13Chronicles\Junktown\ElvisVelvetPainting.BGSM",
                r"textures\V13Chronicles\Junktown\ElvisVelvetPainting_d.dds",
                r"textures\Shared\FlatFlat_n.dds",
                r"textures\interiors\vault\VltNULLforSWAP_s.dds",
            )

    process_and_export("HatGO.nif", "ElvisVelvetPainting.nif", xf_elvis_painting, import_collisions=True)

    # 6. Huella Gigante de Godzilla (Fallout 1 'Giant Footprint' — Cráter de Tres Dedos con Garras en el Desierto)
    def build_giant_footprint_geometry_on_object(mesh_obj):
        bm = bmesh.new()
        bm.from_mesh(mesh_obj.data)
        uv_layer = bm.loops.layers.uv.active
        if uv_layer is None:
            uv_layer = bm.loops.layers.uv.new("UVMap")
        bmesh.ops.delete(bm, geom=list(bm.verts), context="VERTS")

        def seg_sdf(px, py, ax, ay, bx, by, ra, rb):
            vx, vy = bx - ax, by - ay
            wx, wy = px - ax, py - ay
            t = max(0.0, min(1.0, (wx * vx + wy * vy) / (vx * vx + vy * vy + 1e-8)))
            dist = math.hypot(wx - t * vx, wy - t * vy)
            rad = ra + t * (rb - ra)
            return dist - rad

        def smin_f(a, b, k):
            h = max(0.0, min(1.0, 0.5 + 0.5 * (b - a) / k))
            return b * (1.0 - h) + a * h - k * h * (1.0 - h)

        def sstep_f(e0, e1, x):
            t = max(0.0, min(1.0, (x - e0) / (e1 - e0)))
            return t * t * (3.0 - 2.0 * t)

        N_GRID = 76
        v_grid = [[None] * N_GRID for _ in range(N_GRID)]
        uv_grid = [[(0.0, 0.0)] * N_GRID for _ in range(N_GRID)]
        dfp_grid = [[0.0] * N_GRID for _ in range(N_GRID)]

        for ir in range(N_GRID):
            ty = ir / (N_GRID - 1.0)
            dy = -436.0 + ty * 1080.0
            for ic in range(N_GRID):
                tx = ic / (N_GRID - 1.0)
                dx = -540.0 + tx * 1080.0

                d_sole = seg_sdf(dx, dy, 0.0, -160.0, 0.0, 10.0, 115.0, 180.0)
                d_toe_l = seg_sdf(dx, dy, -95.0, 15.0, -290.0, 295.0, 105.0, 58.0)
                d_toe_m = seg_sdf(dx, dy, 0.0, 25.0, 0.0, 375.0, 116.0, 62.0)
                d_toe_r = seg_sdf(dx, dy, 95.0, 15.0, 290.0, 295.0, 105.0, 58.0)
                d_toes = min(d_toe_l, d_toe_m, d_toe_r)
                d_body = smin_f(d_sole, d_toes, 16.0)

                d_claw_l = seg_sdf(dx, dy, -290.0, 295.0, -362.0, 385.0, 38.0, 12.0)
                d_claw_m = seg_sdf(dx, dy, 0.0, 375.0, 0.0, 472.0, 42.0, 12.0)
                d_claw_r = seg_sdf(dx, dy, 290.0, 295.0, 362.0, 385.0, 38.0, 12.0)
                d_claws = min(d_claw_l, d_claw_m, d_claw_r)
                d_fp = min(d_body, d_claws)
                dfp_grid[ir][ic] = d_fp

                # Local Z relative to flat ground Z_world = 160.0 (so z_loc = 0.0 is Z = 160.0):
                # - Inside sole & toes (d_fp < -18): compressed floor at z_loc = 1.6 (claw gouges at 0.7), right above Z=160 LAND
                # - Inner crater wall (-18 <= d_fp < 12): steep 22.4-unit sheared mud wall rising from 1.6 up to 24.0
                # - Outer displaced mud rim (12 <= d_fp <= 88): slopes down from 24.0 through 0.0 (at d_fp=64) to -6.0 (buried underground)
                rim_rock = 1.8 * math.sin(dx * 0.045 + dy * 0.038) + 1.1 * math.cos(dx * 0.082 - dy * 0.071)
                if d_fp < -18.0:
                    z_loc = 1.6 + 0.45 * math.sin(dx * 0.065) * math.cos(dy * 0.065)
                    if d_claws < -4.0:
                        claw_w = sstep_f(-4.0, -18.0, d_claws)
                        z_loc = z_loc * (1.0 - claw_w) + 0.7 * claw_w
                elif d_fp < 12.0:
                    w_wall = sstep_f(-18.0, 12.0, d_fp)
                    z_loc = 1.6 * (1.0 - w_wall) + (24.0 + rim_rock) * w_wall
                else:
                    w_out = sstep_f(12.0, 86.0, d_fp)
                    z_loc = (24.0 + rim_rock * (1.0 - w_out)) * (1.0 - w_out) + (-6.0) * w_out

                v_grid[ir][ic] = bm.verts.new((dx, dy, z_loc))
                uv_grid[ir][ic] = (0.02 + 0.96 * tx, 0.02 + 0.96 * ty)

        # Contour-trim the mesh to the three-toed Godzilla footprint rim (d_fp <= 78.0):
        # zero outer square apron, and every boundary edge is at z_loc ~ -5.0..-6.0 (buried beneath Z=160.0 LAND)
        for ir in range(N_GRID - 1):
            for ic in range(N_GRID - 1):
                if min(
                    dfp_grid[ir][ic],
                    dfp_grid[ir][ic + 1],
                    dfp_grid[ir + 1][ic + 1],
                    dfp_grid[ir + 1][ic],
                ) > 78.0:
                    continue
                v00 = v_grid[ir][ic]
                v10 = v_grid[ir][ic + 1]
                v11 = v_grid[ir + 1][ic + 1]
                v01 = v_grid[ir + 1][ic]
                f = bm.faces.new((v00, v10, v11, v01))
                f.material_index = 0
                f.loops[0][uv_layer].uv = uv_grid[ir][ic]
                f.loops[1][uv_layer].uv = uv_grid[ir][ic + 1]
                f.loops[2][uv_layer].uv = uv_grid[ir + 1][ic + 1]
                f.loops[3][uv_layer].uv = uv_grid[ir + 1][ic]

        loose_verts = [v for v in bm.verts if not v.link_faces]
        if loose_verts:
            bmesh.ops.delete(bm, geom=loose_verts, context="VERTS")

        bmesh.ops.triangulate(bm, faces=list(bm.faces))
        bm.to_mesh(mesh_obj.data)
        bm.free()
        mesh_obj.data.update()
        recompute_welded_normals(mesh_obj)

    def xf_giant_footprint(meshes):
        main_obj = meshes[0]
        for extra in list(meshes[1:]):
            bpy.data.objects.remove(extra, do_unlink=True)
        if main_obj.parent and main_obj.parent.type == "ARMATURE":
            arm_obj = main_obj.parent
            main_obj.parent = arm_obj.parent
            bpy.data.objects.remove(arm_obj, do_unlink=True)
        for obj in list(bpy.data.objects):
            if obj.type == "ARMATURE":
                bpy.data.objects.remove(obj, do_unlink=True)
        main_obj.modifiers.clear()
        main_obj.vertex_groups.clear()
        build_giant_footprint_geometry_on_object(main_obj)
        for mat in main_obj.data.materials:
            assign_shader_on_material(
                mat,
                r"Materials\V13Chronicles\Junktown\GiantFootprint.BGSM",
                r"textures\V13Chronicles\Junktown\GiantFootprint_d.dds",
                r"textures\Shared\FlatFlat_n.dds",
                r"textures\interiors\vault\VltNULLforSWAP_s.dds",
            )

    process_and_export("CabinetGarage02.nif", "GiantGodzillaFootprint.nif", xf_giant_footprint, import_collisions=False)


if __name__ == "__main__":
    main()
"""


def _extract_ba2_gnrl_entry(ba2_path: str, target_rel_lower: str) -> bytes | None:
    if not os.path.isfile(ba2_path):
        return None
    norm_target = target_rel_lower.lower().replace("/", "\\")
    with open(ba2_path, "rb") as f:
        hdr = f.read(24)
        if len(hdr) < 24:
            return None
        _magic, _ver, _mtype, num_files, name_tbl_ofs = struct.unpack("<4sI4sIQ", hdr)
        f.seek(name_tbl_ofs)
        target_idx = None
        for i in range(num_files):
            nlen = struct.unpack("<H", f.read(2))[0]
            name = f.read(nlen).decode("utf-8", "replace").lower().replace("/", "\\")
            if name == norm_target:
                target_idx = i
                break
        if target_idx is None:
            return None
        f.seek(24 + target_idx * 36)
        _nh, _ext, _dh, _unk, ofs, packed_sz, unpacked_sz, _align = struct.unpack("<I4sIIQIII", f.read(36))
        f.seek(ofs)
        return zlib.decompress(f.read(packed_sz)) if packed_sz > 0 else f.read(unpacked_sz)


def _parse_fo4_nif(raw: bytes) -> dict:
    nl = raw.index(b"\n")
    header_line = raw[: nl + 1]
    pos = nl + 1
    ver, endian, uv1, nblocks, uv2 = struct.unpack_from("<IBIII", raw, pos)
    pos += 17
    exp_start = pos
    n_exp = 4 if uv2 >= 130 else 3
    for _ in range(n_exp):
        slen = raw[pos]
        pos += 1 + slen
    export_blob = raw[exp_start:pos]
    nbtypes = struct.unpack_from("<H", raw, pos)[0]
    pos += 2
    btypes: list[str] = []
    for _ in range(nbtypes):
        tl = struct.unpack_from("<I", raw, pos)[0]
        pos += 4
        btypes.append(raw[pos : pos + tl].decode("latin1"))
        pos += tl
    btype_idx = list(struct.unpack_from(f"<{nblocks}H", raw, pos))
    pos += 2 * nblocks
    bsizes = list(struct.unpack_from(f"<{nblocks}I", raw, pos))
    pos += 4 * nblocks
    nstrings, _max_slen = struct.unpack_from("<II", raw, pos)
    pos += 8
    strings: list[str] = []
    for _ in range(nstrings):
        sl = struct.unpack_from("<I", raw, pos)[0]
        pos += 4
        strings.append(raw[pos : pos + sl].decode("latin1"))
        pos += sl
    num_groups = struct.unpack_from("<I", raw, pos)[0]
    pos += 4
    groups_blob = raw[pos : pos + 4 * num_groups]
    pos += 4 * num_groups
    blocks: list[tuple[str, bytearray]] = []
    cur = pos
    for bi in range(nblocks):
        blocks.append((btypes[btype_idx[bi]], bytearray(raw[cur : cur + bsizes[bi]])))
        cur += bsizes[bi]
    footer = raw[cur:]
    return {
        "header_line": header_line,
        "ver": ver,
        "endian": endian,
        "uv1": uv1,
        "uv2": uv2,
        "export_blob": export_blob,
        "strings": strings,
        "num_groups": num_groups,
        "groups_blob": groups_blob,
        "blocks": blocks,
        "footer": footer,
    }


def _serialize_fo4_nif(nif: dict) -> bytes:
    blocks: list[tuple[str, bytearray]] = nif["blocks"]
    strings: list[str] = nif["strings"]
    btypes: list[str] = []
    btype_map: dict[str, int] = {}
    btype_idx: list[int] = []
    bsizes: list[int] = []
    for bt, bdata in blocks:
        if bt not in btype_map:
            btype_map[bt] = len(btypes)
            btypes.append(bt)
        btype_idx.append(btype_map[bt])
        bsizes.append(len(bdata))

    out = bytearray()
    out.extend(nif["header_line"])
    out.extend(struct.pack("<IBIII", nif["ver"], nif["endian"], nif["uv1"], len(blocks), nif["uv2"]))
    out.extend(nif["export_blob"])
    out.extend(struct.pack("<H", len(btypes)))
    for bt in btypes:
        bb = bt.encode("latin1")
        out.extend(struct.pack("<I", len(bb)) + bb)
    out.extend(struct.pack(f"<{len(blocks)}H", *btype_idx))
    out.extend(struct.pack(f"<{len(blocks)}I", *bsizes))
    enc_strings = [s.encode("latin1") for s in strings]
    max_slen = max((len(sb) for sb in enc_strings), default=0)
    out.extend(struct.pack("<II", len(enc_strings), max_slen))
    for sb in enc_strings:
        out.extend(struct.pack("<I", len(sb)) + sb)
    out.extend(struct.pack("<I", nif["num_groups"]) + nif["groups_blob"])
    for _bt, bdata in blocks:
        out.extend(bdata)
    out.extend(nif["footer"])
    return bytes(out)


def _build_texset_bytes(tex_paths: list[str]) -> bytearray:
    padded = (list(tex_paths) + [""] * 10)[:10]
    buf = bytearray(struct.pack("<I", 10))
    for tp in padded:
        tb = tp.encode("latin1")
        buf.extend(struct.pack("<I", len(tb)) + tb)
    return buf


def _intern_nif_string(strings: list[str], val: str) -> int:
    if val in strings:
        return strings.index(val)
    strings.append(val)
    return len(strings) - 1


def postprocess_junktown_nifs(mesh_out_dir: str = MESH_OUT_DIR) -> None:
    """
    Applies deterministic post-export binary fixes to Junktown 3D NIFs:
      1. Grafts genuine Fallout 4 BSLightingShaderProperty + BSShaderTextureSet from vanilla
         Combat Armor Helmet (f_helmet.nif / go_helmet.nif) onto LarsGuardHelmetF.nif,
         LarsGuardHelmetM.nif, and LarsGuardHelmetGO.nif where PyNifly dropped shader_ref = -1.
      2. Sets BSXFlags = 0x00 and clears cubemap slot on GiantGodzillaFootprint.nif (0 collision, 0 controllers).
      3. Transplants full-height (Z=0..256) static Havok column collision from vanilla
         utilsmroompillarbg01.nif onto TardisPoliceBox.nif with clean BSXFlags = 0x82.
      4. Removes stray HatGO alpha-blending NiAlphaProperty from opaque ElvisVelvetPainting.nif.
    """
    meshes_ba2 = os.path.join(FO4_DATA_DIR, "Fallout4 - Meshes.ba2")

    f_helm_raw = _extract_ba2_gnrl_entry(meshes_ba2, r"meshes\armor\combatarmor\f_helmet.nif")
    if f_helm_raw is None and os.path.isfile(os.path.join(TEST_MESHES_DIR, "F_Helmet.nif")):
        with open(os.path.join(TEST_MESHES_DIR, "F_Helmet.nif"), "rb") as rf:
            f_helm_raw = rf.read()

    go_helm_raw = _extract_ba2_gnrl_entry(meshes_ba2, r"meshes\armor\combatarmor\go_helmet.nif")
    if go_helm_raw is None and os.path.isfile(os.path.join(TEST_MESHES_DIR, "GO_Helmet.nif")):
        with open(os.path.join(TEST_MESHES_DIR, "GO_Helmet.nif"), "rb") as rf:
            go_helm_raw = rf.read()

    if f_helm_raw is None or go_helm_raw is None:
        raise RuntimeError("Missing vanilla CombatArmor f_helmet.nif / go_helmet.nif shader donor.")

    f_donor = _parse_fo4_nif(f_helm_raw)
    go_donor = _parse_fo4_nif(go_helm_raw)
    skinned_shd_tpl = bytes(next(b for bt, b in reversed(f_donor["blocks"]) if bt == "BSLightingShaderProperty"))
    unskinned_shd_tpl = bytes(next(b for bt, b in reversed(go_donor["blocks"]) if bt == "BSLightingShaderProperty"))

    lars_bgsm_str = r"Materials\V13Chronicles\Junktown\LarsGuardHelmet.BGSM"
    lars_tex_list = [
        r"Textures\V13Chronicles\Junktown\LarsGuardHelmet_d.dds",
        r"Textures\Armor\CombatArmor\CombatArmor_Helmet_n.dds",
        "",
        "",
        r"Textures\Shared\Cubemaps\mipblur_DefaultOutside1.dds",
        "",
        "",
        r"Textures\Armor\CombatArmor\CombatArmor_Helmet_s.dds",
        "",
        "",
    ]

    for fn, is_skinned in (
        ("LarsGuardHelmetF.nif", True),
        ("LarsGuardHelmetM.nif", True),
        ("LarsGuardHelmetGO.nif", False),
    ):
        nif_path = os.path.join(mesh_out_dir, fn)
        if not os.path.isfile(nif_path):
            continue
        with open(nif_path, "rb") as rf:
            nif = _parse_fo4_nif(rf.read())

        patched = False
        for bi, (bt, blk) in enumerate(list(nif["blocks"])):
            if bt not in ("BSTriShape", "BSSubIndexTriShape"):
                continue
            n_ex = struct.unpack_from("<I", blk, 4)[0]
            shd_ofs = 8 + 4 * n_ex + 84
            shd_ref = struct.unpack_from("<i", blk, shd_ofs)[0]
            if shd_ref == -1:
                bgsm_str_idx = _intern_nif_string(nif["strings"], lars_bgsm_str)
                shd_idx = len(nif["blocks"])
                tex_idx = shd_idx + 1
                shd_buf = bytearray(skinned_shd_tpl if is_skinned else unskinned_shd_tpl)
                # Set name_ref to LarsGuardHelmet.BGSM, clear Greyscale_To_PaletteColor (0x10), set texset_ref & root_material=-1
                struct.pack_into("<i", shd_buf, 4, bgsm_str_idx)
                sf1 = struct.unpack_from("<I", shd_buf, 16)[0] & ~0x00000010
                struct.pack_into("<I", shd_buf, 16, sf1)
                struct.pack_into("<i", shd_buf, 40, tex_idx)
                struct.pack_into("<i", shd_buf, 60, -1)
                tex_buf = _build_texset_bytes(lars_tex_list)

                nif["blocks"].append(("BSLightingShaderProperty", shd_buf))
                nif["blocks"].append(("BSShaderTextureSet", tex_buf))
                struct.pack_into("<i", blk, shd_ofs, shd_idx)
                patched = True
            else:
                shd_bt, shd_buf = nif["blocks"][shd_ref]
                if shd_bt == "BSLightingShaderProperty":
                    bgsm_str_idx = _intern_nif_string(nif["strings"], lars_bgsm_str)
                    struct.pack_into("<i", shd_buf, 4, bgsm_str_idx)
                    tref = struct.unpack_from("<i", shd_buf, 40)[0]
                    if 0 <= tref < len(nif["blocks"]) and nif["blocks"][tref][0] == "BSShaderTextureSet":
                        nif["blocks"][tref] = ("BSShaderTextureSet", _build_texset_bytes(lars_tex_list))
                    patched = True

        if patched:
            with open(nif_path, "wb") as wf:
                wf.write(_serialize_fo4_nif(nif))
            print(f"  [NIF Patcher] Grafted BSLightingShaderProperty + BSShaderTextureSet onto {fn}")

    # GiantGodzillaFootprint.nif: BSXFlags -> 0x00, strip cubemap from fallback BSShaderTextureSet
    fp_path = os.path.join(mesh_out_dir, "GiantGodzillaFootprint.nif")
    if os.path.isfile(fp_path):
        with open(fp_path, "rb") as rf:
            fp_nif = _parse_fo4_nif(rf.read())
        fp_changed = False
        for bi, (bt, blk) in enumerate(fp_nif["blocks"]):
            if bt == "BSXFlags":
                cur_fl = struct.unpack_from("<I", blk, 4)[0]
                if cur_fl != 0:
                    struct.pack_into("<I", blk, 4, 0)
                    fp_changed = True
            elif bt == "BSShaderTextureSet":
                clean_fp_tex = _build_texset_bytes(
                    [
                        r"textures\V13Chronicles\Junktown\GiantFootprint_d.dds",
                        r"textures\Shared\FlatFlat_n.dds",
                        "",
                        "",
                        "",
                        "",
                        "",
                        r"textures\interiors\vault\VltNULLforSWAP_s.dds",
                        "",
                        "",
                    ]
                )
                if blk != clean_fp_tex:
                    fp_nif["blocks"][bi] = ("BSShaderTextureSet", clean_fp_tex)
                    fp_changed = True
        if fp_changed:
            with open(fp_path, "wb") as wf:
                wf.write(_serialize_fo4_nif(fp_nif))
            print("  [NIF Patcher] Cleaned GiantGodzillaFootprint.nif (BSXFlags=0x00, matte texture set)")

    # TardisPoliceBox.nif: Transplant full-height static Havok column collision + BSXFlags=0x82
    tardis_path = os.path.join(mesh_out_dir, "TardisPoliceBox.nif")
    pillar_raw = _extract_ba2_gnrl_entry(meshes_ba2, r"meshes\interiors\utility\smroom\utilsmroompillarbg01.nif")
    if os.path.isfile(tardis_path) and pillar_raw is not None:
        pillar_nif = _parse_fo4_nif(pillar_raw)
        pillar_phys = next((b for bt, b in pillar_nif["blocks"] if bt == "bhkPhysicsSystem"), None)
        with open(tardis_path, "rb") as rf:
            t_nif = _parse_fo4_nif(rf.read())
        if pillar_phys is not None:
            col_idx = next((i for i, (bt, _) in enumerate(t_nif["blocks"]) if bt == "bhkNPCollisionObject"), -1)
            phys_idx = next((i for i, (bt, _) in enumerate(t_nif["blocks"]) if bt == "bhkPhysicsSystem"), -1)
            if col_idx >= 0 and phys_idx >= 0:
                for bi, (bt, blk) in enumerate(t_nif["blocks"]):
                    if bt == "BSXFlags":
                        struct.pack_into("<I", blk, 4, 0x82)
                    elif bt == "NiNode":
                        n_ex = struct.unpack_from("<I", blk, 4)[0]
                        col_ofs = 8 + 4 * n_ex + 60
                        struct.pack_into("<i", blk, col_ofs, col_idx if bi == 0 else -1)
                t_nif["blocks"][col_idx] = (
                    "bhkNPCollisionObject",
                    bytearray(struct.pack("<iHII", 0, 0x0080, phys_idx, 0)),
                )
                t_nif["blocks"][phys_idx] = ("bhkPhysicsSystem", bytearray(pillar_phys))
                with open(tardis_path, "wb") as wf:
                    wf.write(_serialize_fo4_nif(t_nif))
                print("  [NIF Patcher] Updated TardisPoliceBox.nif (BSXFlags=0x82, full-height 256u Havok column)")

    # ElvisVelvetPainting.nif: Remove stray HatGO NiAlphaProperty on opaque framed canvas
    elvis_path = os.path.join(mesh_out_dir, "ElvisVelvetPainting.nif")
    if os.path.isfile(elvis_path):
        with open(elvis_path, "rb") as rf:
            e_nif = _parse_fo4_nif(rf.read())
        if e_nif["blocks"] and e_nif["blocks"][-1][0] == "NiAlphaProperty":
            alp_idx = len(e_nif["blocks"]) - 1
            for _bt, blk in e_nif["blocks"]:
                if _bt in ("BSTriShape", "BSSubIndexTriShape"):
                    n_ex = struct.unpack_from("<I", blk, 4)[0]
                    alp_ofs = 8 + 4 * n_ex + 88
                    if struct.unpack_from("<i", blk, alp_ofs)[0] == alp_idx:
                        struct.pack_into("<i", blk, alp_ofs, -1)
            e_nif["blocks"].pop()
            with open(elvis_path, "wb") as wf:
                wf.write(_serialize_fo4_nif(e_nif))
            print("  [NIF Patcher] Removed stray NiAlphaProperty from ElvisVelvetPainting.nif")


def ensure_junktown_3d_assets(force_rebuild: bool = False) -> tuple[dict[str, str], list[tuple[str, str]]]:
    """
    Asegura que las texturas DDS 1024x1024 BC1 (11 mipmaps), los materiales .BGSM
    y los 11 modelos 3D .NIF esculpidos en Blender 5.2 para Killian Darkwater,
    el Capitán Lars, el Ranger Tycho, la Cabina Telefónica Inusual (TARDIS), el
    Cuadro de Terciopelo de «El Rey» (Elvis) y la Huella Gigante de Godzilla estén generados.
    Devuelve (main_ba2_map, tex_dds_list).
    """
    os.makedirs(TEX_OUT_DIR, exist_ok=True)
    os.makedirs(MAT_OUT_DIR, exist_ok=True)
    os.makedirs(MESH_OUT_DIR, exist_ok=True)
    ensure_cabinet_donor_nif()

    tex_builders = [
        ("KillianHat_d.dds", build_killian_hat_texture),
        ("LarsHelm_d.dds", build_lars_helm_texture),
        ("LarsGuardHelmet_d.dds", build_lars_helm_texture),
        ("TychoHelm_d.dds", build_tycho_helm_texture),
        ("TychoVisor_d.dds", build_tycho_visor_texture),
        ("TardisPoliceBox_d.dds", build_tardis_police_box_texture),
        ("ElvisVelvetPainting_d.dds", build_elvis_velvet_painting_texture),
        ("GiantFootprint_d.dds", build_giant_footprint_texture),
    ]
    tex_dds_list: list[tuple[str, str]] = []
    en_tex_out_dir = os.path.join(
        THIS_DIR, "edition_en", "assets", "junktown_3d", "textures", "v13chronicles", "junktown"
    )
    for fn, builder_fn in tex_builders:
        dst_dds = os.path.join(TEX_OUT_DIR, fn)
        if force_rebuild or not os.path.exists(dst_dds):
            im = builder_fn()
            mips = encode_dds_1024_with_11_mips(im)
            write_dds_1024_file(dst_dds, mips)
            print(f"  [Textura Junktown 3D] Generada {fn} (1024x1024 BC1, 11 mipmaps)")
        if fn in ("GiantFootprint_d.dds", "LarsGuardHelmet_d.dds") and os.path.isdir(os.path.dirname(en_tex_out_dir)):
            os.makedirs(en_tex_out_dir, exist_ok=True)
            en_dst = os.path.join(en_tex_out_dir, fn)
            if force_rebuild or not os.path.exists(en_dst):
                with open(dst_dds, "rb") as rf, open(en_dst, "wb") as wf:
                    wf.write(rf.read())
        tex_dds_list.append((f"Textures\\V13Chronicles\\Junktown\\{fn[:-4]}.DDS", dst_dds))

    mat_specs = [
        (
            "KillianHat.BGSM",
            build_bgsm_v2_bytes(
                diffuse_path="V13Chronicles/Junktown/KillianHat_d.dds",
                normal_path="Armor/MacCready/Mac_n.dds",
                specular_path="Armor/MacCready/Mac_s.dds",
                envmap_path="Shared/Cubemaps/mipblur_DefaultOutside1.dds",
                root_material="template/ArmorTemplate_Wet.bgsm",
                envmap_scale=0.35,
                specular_color=(0.86, 0.72, 0.54),
                specular_mult=0.75,
                smoothness=0.85,
            ),
        ),
        (
            "LarsHelm.BGSM",
            build_bgsm_v2_bytes(
                diffuse_path="V13Chronicles/Junktown/LarsHelm_d.dds",
                normal_path="Armor/CombatArmor/CombatArmor_Helmet_n.dds",
                specular_path="Armor/CombatArmor/CombatArmor_Helmet_s.dds",
                envmap_path="Shared/Cubemaps/mipblur_DefaultOutside1.dds",
                root_material="template/ArmorTemplate_Wet.bgsm",
                envmap_scale=0.75,
                specular_color=(0.82, 0.88, 0.95),
                specular_mult=1.10,
                smoothness=1.15,
            ),
        ),
        (
            "LarsGuardHelmet.BGSM",
            build_bgsm_v2_bytes(
                diffuse_path="V13Chronicles/Junktown/LarsGuardHelmet_d.dds",
                normal_path="Armor/CombatArmor/CombatArmor_Helmet_n.dds",
                specular_path="Armor/CombatArmor/CombatArmor_Helmet_s.dds",
                envmap_path="Shared/Cubemaps/mipblur_DefaultOutside1.dds",
                root_material="template/ArmorTemplate_Wet.bgsm",
                envmap_scale=0.75,
                specular_color=(0.82, 0.88, 0.95),
                specular_mult=1.10,
                smoothness=1.15,
            ),
        ),
        (
            "TychoHelm.BGSM",
            build_bgsm_v2_bytes(
                diffuse_path="V13Chronicles/Junktown/TychoHelm_d.dds",
                normal_path="Armor/FlightHelmet/Helmet_02_n.dds",
                specular_path="Armor/FlightHelmet/Helmet_02_s.dds",
                envmap_path="Shared/Cubemaps/mipblur_DefaultOutside1.dds",
                root_material="template/ArmorTemplate_Wet.bgsm",
                envmap_scale=0.55,
                specular_color=(0.88, 0.84, 0.72),
                specular_mult=0.95,
                smoothness=1.05,
            ),
        ),
        (
            "TychoVisor.BGSM",
            build_bgsm_v2_bytes(
                diffuse_path="V13Chronicles/Junktown/TychoVisor_d.dds",
                normal_path="Armor/FlightHelmet/Helmet_02_n.dds",
                specular_path="Armor/FlightHelmet/Helmet_02_s.dds",
                envmap_path="Shared/Cubemaps/shinyglass_e.dds",
                root_material="template/defaultTemplate_wet.bgsm",
                envmap_scale=2.20,
                specular_color=(1.00, 0.82, 0.45),
                specular_mult=2.00,
                smoothness=2.35,
                subsurface_lighting=0,
                subsurface_rolloff=0.0,
            ),
        ),
        (
            "TardisPoliceBox.BGSM",
            build_bgsm_v2_bytes(
                diffuse_path="V13Chronicles/Junktown/TardisPoliceBox_d.dds",
                normal_path="Shared/FlatFlat_n.dds",
                specular_path="interiors/vault/VltNULLforSWAP_s.dds",
                envmap_path="Shared/Cubemaps/mipblur_DefaultOutside1.dds",
                root_material="template/defaultTemplate_wet.bgsm",
                envmap_scale=0.35,
                specular_color=(0.78, 0.86, 0.96),
                specular_mult=0.80,
                smoothness=0.90,
                subsurface_lighting=0,
                subsurface_rolloff=0.0,
            ),
        ),
        (
            "ElvisVelvetPainting.BGSM",
            build_bgsm_v2_bytes(
                diffuse_path="V13Chronicles/Junktown/ElvisVelvetPainting_d.dds",
                normal_path="Shared/FlatFlat_n.dds",
                specular_path="interiors/vault/VltNULLforSWAP_s.dds",
                envmap_path="Shared/Cubemaps/mipblur_DefaultOutside1.dds",
                root_material="template/defaultTemplate_wet.bgsm",
                envmap_scale=0.45,
                specular_color=(0.94, 0.82, 0.52),
                specular_mult=0.85,
                smoothness=0.95,
                subsurface_lighting=0,
                subsurface_rolloff=0.0,
            ),
        ),
        (
            "GiantFootprint.BGSM",
            build_bgsm_v2_bytes(
                diffuse_path="V13Chronicles/Junktown/GiantFootprint_d.dds",
                normal_path="Shared/FlatFlat_n.dds",
                specular_path="interiors/vault/VltNULLforSWAP_s.dds",
                envmap_path="",
                root_material="template/defaultTemplate_wet.bgsm",
                envmap_scale=0.00,
                specular_color=(0.35, 0.28, 0.20),
                specular_mult=0.04,
                smoothness=0.15,
                subsurface_lighting=0,
                subsurface_rolloff=0.0,
                enable_envmap=0,
            ),
        ),
    ]
    for mat_fn, mat_bytes in mat_specs:
        dst_mat = os.path.join(MAT_OUT_DIR, mat_fn)
        existing = open(dst_mat, "rb").read() if os.path.exists(dst_mat) else None
        if force_rebuild or existing != mat_bytes:
            with open(dst_mat, "wb") as wf:
                wf.write(mat_bytes)
            print(f"  [Material Junktown 3D] Generado {mat_fn} ({len(mat_bytes)} bytes)")

    expected_nifs = [
        "KillianMayorHatM.nif",
        "KillianMayorHatF.nif",
        "KillianMayorHatGO.nif",
        "LarsGuardHelmetM.nif",
        "LarsGuardHelmetF.nif",
        "LarsGuardHelmetGO.nif",
        "TychoRangerHelmet.nif",
        "TychoRangerHelmetGO.nif",
        "TardisPoliceBox.nif",
        "ElvisVelvetPainting.nif",
        "GiantGodzillaFootprint.nif",
    ]
    if force_rebuild or any(not os.path.exists(os.path.join(MESH_OUT_DIR, fn)) for fn in expected_nifs):
        script_path = os.path.join(JUNKTOWN_ASSETS_DIR, "_run_blender_export_junktown.py")
        script_code = (
            BLENDER_EXPORT_SCRIPT.replace("__TEST_DIR__", TEST_MESHES_DIR)
            .replace("__OUT_DIR__", MESH_OUT_DIR)
            .replace("__PYNIFLY_DIR__", PYNIFLY_DIR)
        )
        with open(script_path, "w", encoding="utf-8") as wf:
            wf.write(script_code)

        print("  [Blender 5.2 + PyNifly] Esculpiendo y exportando las 11 mallas .NIF personalizadas de Crónicas del Refugio 13...")
        subprocess.run(
            [BLENDER_EXE, "--background", "--python", script_path],
            check=True,
        )

    postprocess_junktown_nifs(MESH_OUT_DIR)

    main_ba2_map: dict[str, str] = {}
    for fn in sorted(os.listdir(MAT_OUT_DIR)):
        if fn.lower().endswith((".bgsm", ".bgem")):
            main_ba2_map[f"materials\\v13chronicles\\junktown\\{fn.lower()}"] = os.path.join(MAT_OUT_DIR, fn)
    for fn in sorted(os.listdir(MESH_OUT_DIR)):
        if fn.lower().endswith((".nif", ".ssf")):
            main_ba2_map[f"meshes\\v13chronicles\\junktown\\{fn.lower()}"] = os.path.join(MESH_OUT_DIR, fn)

    return main_ba2_map, tex_dds_list


if __name__ == "__main__":
    force = "--rebuild" in sys.argv
    ensure_junktown_3d_assets(force_rebuild=force)
