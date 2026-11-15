# -*- coding: utf-8 -*-
"""
Generates the 2048x2048 BC1/DXT1 Pip-Boy World Map texture for Crónicas del Refugio 13:
  assets/textures/interface/pip-boy/V13CaliforniaWorldMap_d.dds
and re-exports the exact shared 3D heightfield `global_california_height(wx, wy)` from
`v13_world_layout.py` used by `build_cronicas_refugio_13.py` to generate the 400 exterior
`LAND` records of `WRLD 0x01003400` ("Sur de California (2161)").

Worldspace bounds:
  20x20 exterior cells: cx in [-10..9], cy in [-10..9] (400 LAND cells)
  wx in [-40960.0 .. +40960.0], wy in [-40960.0 .. +40960.0] (81,920 x 81,920 units)
"""

import math
import os
import struct
import sys
from PIL import Image, ImageDraw, ImageFilter, ImageFont

THIS_DIR = os.path.dirname(os.path.abspath(__file__))
if THIS_DIR not in sys.path:
    sys.path.insert(0, THIS_DIR)

from v13_world_layout import (
    LOCATION_PLATEAUS,
    MAP_MAX,
    MAP_MIN,
    MAP_SPAN,
    NECROPOLIS_BASIN_BOUNDS,
    V13_WORLD_ANCHORS,
    WORLD_MAX,
    WORLD_MIN,
    WORLD_SPAN,
    _smoothstep,
    coastline_x as _coastline_x,
    global_california_height,
    px_to_world,
    world_to_px,
)

OUT_DDS = os.path.join(THIS_DIR, "assets", "textures", "interface", "pip-boy", "V13CaliforniaWorldMap_d.dds")
PREVIEW_PNG = os.path.join(THIS_DIR, "assets", "textures", "interface", "pip-boy", "V13CaliforniaWorldMap_preview.png")


def build_worldmap() -> None:
    os.makedirs(os.path.dirname(OUT_DDS), exist_ok=True)
    S = 2048

    # Sample the exact 3D heightfield on a 512x512 grid across [MAP_MIN..MAP_MAX] and upscale to 2048x2048
    G = 512
    h_grid = [[0.0] * G for _ in range(G)]
    lo_pixels = bytearray(G * G)

    for gy in range(G):
        wy = MAP_MAX - ((gy + 0.5) / G) * MAP_SPAN
        row_h = h_grid[gy]
        for gx in range(G):
            wx = MAP_MIN + ((gx + 0.5) / G) * MAP_SPAN
            z = global_california_height(wx, wy)
            row_h[gx] = z

    # Compute shaded relief + elevation contour bands in Pip-Boy luminance range (14..108)
    for gy in range(G):
        wy = MAP_MAX - ((gy + 0.5) / G) * MAP_SPAN
        shore_x = _coastline_x(wy)
        row_h = h_grid[gy]
        row_up = h_grid[max(0, gy - 1)]
        row_dn = h_grid[min(G - 1, gy + 1)]
        base_idx = gy * G
        for gx in range(G):
            wx = MAP_MIN + ((gx + 0.5) / G) * MAP_SPAN
            z = row_h[gx]
            dz_dx = (row_h[min(G - 1, gx + 1)] - row_h[max(0, gx - 1)]) / 96.0
            dz_dy = (row_up[gx] - row_dn[gx]) / 96.0

            if z < -15.0 and wx < shore_x + 400.0:
                # Pacific Ocean bathymetry & wave scanlines
                depth_norm = min(1.0, abs(z) / 520.0)
                val = int(22.0 - 7.0 * depth_norm)
                # Subtle Fallout 1 CRT ocean scanlines near coast
                if abs(wx - shore_x) < 1600.0 and (gy % 3 == 0):
                    val += 5
            else:
                # Landmass elevation + NW hillshade
                elev_norm = max(0.0, min(1.0, (z + 20.0) / 1450.0))
                shade = (-dz_dx * 0.72 + dz_dy * 0.68)
                val_f = 44.0 + elev_norm * 46.0 + shade * 14.0
                # Topographical contour lines every 160 Z units
                z_mod = abs((z + 800.0) % 160.0)
                if z > 90.0 and (z_mod < 11.0 or z_mod > 149.0):
                    val_f -= 12.0
                val = max(28, min(102, int(val_f)))

            lo_pixels[base_idx + gx] = val

    im_low = Image.frombytes("L", (G, G), bytes(lo_pixels))
    im = im_low.resize((S, S), Image.Resampling.BILINEAR)
    im = im.filter(ImageFilter.GaussianBlur(radius=1.5))
    draw = ImageDraw.Draw(im)

    # 1. Crisp Pacific Ocean coastline border
    coast_pts = []
    for step_y in range(0, 257):
        wy = MAP_MAX - (step_y / 256.0) * MAP_SPAN
        wx = _coastline_x(wy)
        coast_pts.append(world_to_px(wx, wy, S))
    draw.line(coast_pts, fill=10, width=6)
    draw.line(coast_pts, fill=88, width=2)

    # 2. Pre-War Highways & Caravan Trails of Southern California (2161, 20x20 Scale)
    roads = [
        # Northern Sierra Pass (CA-190 / US-395): Puente Temporal -> Refugio 13 -> Shady Sands -> Paso Khans -> Refugio 15
        [
            (-18000, 33500), (-12500, 33300), (-7000, 33000), (-500, 28500),
            (6500, 23500), (14500, 21000), (21500, 18500), (27500, 16000), (33500, 13500),
        ],
        # North-East Raider Trail: Shady Sands -> Mutascorpion Lair -> Petrox Camp -> Tolan Stronghold -> Paso Khans
        [
            (6500, 23500), (16000, 34500), (26500, 33500), (35000, 24500), (21500, 18500),
        ],
        # Eastern Sierra & Kern Canyon Route: Shady Sands -> Junktown -> Bob's -> Necrópolis -> Huella -> El Resplandor (SE)
        [
            (6500, 23500), (7000, 14500), (7500, 5500), (14000, 5200), (20500, 5000),
            (29000, -2000), (28000, -8000), (25500, -11500), (20000, -33500), (31500, -31500),
        ],
        # Necropolis street branch to Sala de los Muertos
        [(28000, -8000), (30800, -7500), (33500, -7000)],
        # Western Military & Brotherhood Route: Puente Temporal -> Mariposa -> TARDIS -> Irwin Farm -> Lost Hills -> Caravana -> La Catedral
        [
            (-18000, 33500), (-31000, 31000), (-31500, 16500), (-20000, 19500),
            (-18500, 6500), (-22500, 1200), (-24500, -7500), (-15000, -18500), (-19500, -31500),
        ],
        # Cross-Valley Caravan Network: Lost Hills -> Caravana -> El Eje -> Patrick -> Junktown -> Kenji -> Irwin -> Gizmo -> El Eje -> Nuka-Cola -> Necrópolis
        [
            (-24500, -7500), (-15000, -18500), (-3500, -13500), (5500, -4800), (7500, 5500),
            (-5500, 13000), (-18500, 6500), (-4000, 2000), (-3500, -13500),
            (10500, -15500), (25500, -11500),
        ],
        # Southern Boneyard & Glow Expedition Highway: El Eje -> La Catedral -> Adytum -> Nido Madre Sanguinario -> Huella -> El Resplandor
        [
            (-3500, -13500), (-11500, -22500), (-19500, -31500), (-5600, -32200),
            (8500, -28000), (20000, -33500), (31500, -31500),
        ],
    ]
    for r in roads:
        r_px = [world_to_px(x, y, S) for x, y in r]
        draw.line(r_px, fill=28, width=7)
        draw.line(r_px, fill=98, width=3)

    # 3. Bakersfield / Necropolis Ruined Urban Street Grid + The Glow Crater Rings on the map
    for ux in range(24000, 35500, 1800):
        p0 = world_to_px(ux, 0, S)
        p1 = world_to_px(ux, -13200, S)
        draw.line([p0, p1], fill=62, width=1)
    for uy in range(-13000, 200, 1800):
        p0 = world_to_px(23800, uy, S)
        p1 = world_to_px(35200, uy, S)
        draw.line([p0, p1], fill=62, width=1)
    gx_px, gy_px = world_to_px(31500, -31500, S)
    for rad_px in (28, 46, 66):
        draw.ellipse([gx_px - rad_px, gy_px - rad_px, gx_px + rad_px, gy_px + rad_px], outline=76, width=2)

    # 4. Authentic Fallout 1 Sector Grid (28 columns x 30 rows CRT World Map overlay)
    margin = 48
    grid_w = S - 2 * margin
    grid_h = S - 2 * margin
    for col in range(29):
        gx = int(round(margin + col * (grid_w / 28.0)))
        draw.line([(gx, margin), (gx, S - margin)], fill=34, width=1)
    for row in range(31):
        gy = int(round(margin + row * (grid_h / 30.0)))
        draw.line([(margin, gy), (S - margin, gy)], fill=34, width=1)

    draw.rectangle([margin - 6, margin - 6, S - margin + 6, S - margin + 6], outline=86, width=2)
    step_dash = 32
    for pos_d in range(margin, S - margin, step_dash * 2):
        draw.line([(pos_d, margin), (min(pos_d + step_dash, S - margin), margin)], fill=108, width=4)
        draw.line([(pos_d, S - margin), (min(pos_d + step_dash, S - margin), S - margin)], fill=108, width=4)
        draw.line([(margin, pos_d), (margin, min(pos_d + step_dash, S - margin))], fill=108, width=4)
        draw.line([(S - margin, pos_d), (S - margin, min(pos_d + step_dash, S - margin))], fill=108, width=4)

    # 5. Cartographic headers & regional labels
    try:
        font_title = ImageFont.truetype("C:/Windows/Fonts/consolab.ttf", 28)
        font_reg = ImageFont.truetype("C:/Windows/Fonts/consola.ttf", 19)
    except Exception:
        font_title = ImageFont.load_default()
        font_reg = ImageFont.load_default()

    draw.text((76, 68), "VAULT-TEC // SUR DE CALIFORNIA [2161] — TOPOGRAFÍA SATELITAL", fill=106, font=font_title)
    draw.text((76, 102), "CUADRÍCULA REGIONAL 28x30 — REFUGIO 13 / SIERRA NEVADA / BONEYARD / EL RESPLANDOR", fill=86, font=font_reg)

    region_labels = [
        (-34500, 32800, "BASE MILITAR MARIPOSA"),
        (-10200, 34800, "REFUGIO 13 / MT. WHITNEY"),
        (3800, 25600, "SHADY SANDS"),
        (12800, 36200, "GUARIDA MUTASCORPIÓN"),
        (23600, 35200, "CAMPAMENTO DE PETROX"),
        (29200, 26200, "FORTALEZA ESCLAVISTA (TOLAN)"),
        (18200, 20200, "PASO DE LOS KHANS"),
        (30500, 15200, "REFUGIO 15"),
        (-34800, 18200, "CABINA AZUL (TARDIS)"),
        (-23200, 21200, "PLATILLO VOLANTE"),
        (-8600, 14800, "GUARIDA SKULZ (KENJI)"),
        (4800, 7600, "JUNKTOWN"),
        (17600, 6800, "COCHES DE BOB"),
        (-21800, 8200, "GRANJA DE IRWIN"),
        (-7000, 3800, "CASINO DE GIZMO"),
        (2600, -3000, "PATRICK EL CELTA"),
        (25600, -200, "LA CUENCA (REFUGIO 12)"),
        (24800, -13200, "RUINAS DE NECRÓPOLIS"),
        (-28500, -5600, "LOST HILLS (H. DEL ACERO)"),
        (-6200, -11400, "EL EJE (THE HUB)"),
        (-18800, -16800, "CARAVANA DESAPARECIDA"),
        (7400, -13800, "CAMIÓN DE NUKA-COLA"),
        (-22800, -29600, "LA CATEDRAL"),
        (-7800, -29600, "ADYTUM / BONEYARD"),
        (5200, -26200, "NIDO MADRE SANGUINARIO"),
        (16800, -31800, "HUELLA GIGANTE"),
        (26800, -29400, "EL RESPLANDOR (WEST TEK)"),
        (-36500, -22500, "OCÉANO PACÍFICO"),
    ]
    for lx, ly, ltxt in region_labels:
        px_x, px_y = world_to_px(lx, ly, S)
        draw.text((px_x - 60, px_y), ltxt, fill=92, font=font_reg)

    # 6. Location survey rings at exact 3D Worldspace coordinates
    loc_coords = [(int(ax), int(ay)) for (ax, ay, *_rest) in V13_WORLD_ANCHORS.values()]
    for cx, cy in loc_coords:
        x0, y0 = world_to_px(cx, cy, S)
        draw.ellipse([x0 - 15, y0 - 15, x0 + 15, y0 + 15], outline=106, width=2)
        draw.ellipse([x0 - 4, y0 - 4, x0 + 4, y0 + 4], fill=112)

    im.resize((512, 512)).save(PREVIEW_PNG)

    top_mip_pitch = (S // 4) * (S // 4) * 8
    bc1_payload = encode_bc1_worldmap_mips(im, mips=12)
    dds_hdr = struct.pack(
        "<4s7I44s9I16s",
        b"DDS ", 124, 0x000A1007, S, S, top_mip_pitch, 0, 12,
        b"\x00" * 44,
        32, 0x04, int.from_bytes(b"DXT1", "little"), 0, 0, 0, 0, 0, 0x00401008,
        b"\x00" * 16,
    )
    with open(OUT_DDS, "wb") as wf:
        wf.write(dds_hdr + bc1_payload)
    print(f"[WorldMap DDS] Generated {OUT_DDS} ({len(dds_hdr) + len(bc1_payload)} bytes, 12 mipmaps)")
    build_location_signs()


def _encode_bc1_gray_array(gray_arr) -> bytes:
    """Vectorized BC1 (DXT1) 4x4 opaque block encoder for a 2D uint8 grayscale array."""
    import numpy as np

    h, w = gray_arr.shape
    pad_h = max(0, 4 - h) if h < 4 else ((4 - (h % 4)) % 4)
    pad_w = max(0, 4 - w) if w < 4 else ((4 - (w % 4)) % 4)
    if pad_h or pad_w:
        gray_arr = np.pad(gray_arr, ((0, pad_h), (0, pad_w)), mode="edge")
        h, w = gray_arr.shape

    blocks = (
        gray_arr.reshape(h // 4, 4, w // 4, 4)
        .transpose(0, 2, 1, 3)
        .reshape(-1, 16)
        .astype(np.float32)
    )
    n_blk = blocks.shape[0]
    hi = np.max(blocks, axis=1)
    lo = np.min(blocks, axis=1)

    def _gray_to_rgb565(g_val):
        r5 = np.clip(np.round(g_val * (31.0 / 255.0)), 0, 31).astype(np.uint16)
        g6 = np.clip(np.round(g_val * (63.0 / 255.0)), 0, 63).astype(np.uint16)
        b5 = r5
        c16 = (r5 << 11) | (g6 << 5) | b5
        lum_rec = 0.299 * (r5 * (255.0 / 31.0)) + 0.587 * (g6 * (255.0 / 63.0)) + 0.114 * (b5 * (255.0 / 31.0))
        return c16, lum_rec

    c0_16, l0 = _gray_to_rgb565(hi)
    c1_16, l1 = _gray_to_rgb565(lo)

    swap = c0_16 < c1_16
    c0_s = np.where(swap, c1_16, c0_16)
    c1_s = np.where(swap, c0_16, c1_16)
    l0_s = np.where(swap, l1, l0)
    l1_s = np.where(swap, l0, l1)

    eq = c0_s == c1_s

    p0 = l0_s[:, None]
    p1 = l1_s[:, None]
    p2 = (2.0 * p0 + p1) / 3.0
    p3 = (p0 + 2.0 * p1) / 3.0

    dists = np.stack(
        [(blocks - p0) ** 2, (blocks - p1) ** 2, (blocks - p2) ** 2, (blocks - p3) ** 2],
        axis=2,
    )
    indices = np.argmin(dists, axis=2).astype(np.uint32)
    indices = np.where(eq[:, None], 0, indices)

    shifts = (np.arange(16, dtype=np.uint32) * 2)[None, :]
    idx_32 = np.bitwise_or.reduce(indices << shifts, axis=1)

    out = np.empty(n_blk, dtype=[("c0", "<u2"), ("c1", "<u2"), ("idx", "<u4")])
    out["c0"] = c0_s
    out["c1"] = c1_s
    out["idx"] = idx_32
    return out.tobytes()


def encode_bc1_worldmap_mips(im: Image.Image, mips: int = 12) -> bytes:
    """
    Generates a full 12-level box-downsampled BC1 (DXT1) mipmap chain (2048x2048 -> 1x1)
    so the 3D Pip-Boy CRT screen renders crisp, moiré-free cartography at every viewing angle.
    """
    im_l = im.convert("L")
    w, h = im_l.size
    out = bytearray()
    try:
        import numpy as np

        cur_arr = np.frombuffer(im_l.tobytes(), dtype=np.uint8).reshape((h, w))
        for m in range(mips):
            if m > 0:
                nh = max(1, cur_arr.shape[0] // 2)
                nw = max(1, cur_arr.shape[1] // 2)
                if cur_arr.shape[0] >= 2 and cur_arr.shape[1] >= 2:
                    cur_arr = (
                        (
                            cur_arr[0::2, 0::2].astype(np.uint16)
                            + cur_arr[0::2, 1::2].astype(np.uint16)
                            + cur_arr[1::2, 0::2].astype(np.uint16)
                            + cur_arr[1::2, 1::2].astype(np.uint16)
                            + 2
                        )
                        >> 2
                    ).astype(np.uint8)
                else:
                    cur_arr = np.asarray(
                        Image.fromarray(cur_arr).resize((nw, nh), Image.Resampling.BOX),
                        dtype=np.uint8,
                    )
            out.extend(_encode_bc1_gray_array(cur_arr))
        return bytes(out)
    except ImportError:
        cur_im = im_l
        for m in range(mips):
            if m > 0:
                nw = max(1, cur_im.size[0] // 2)
                nh = max(1, cur_im.size[1] // 2)
                cur_im = cur_im.resize((nw, nh), Image.Resampling.BOX)
            pad_im = cur_im if (cur_im.size[0] >= 4 and cur_im.size[1] >= 4) else cur_im.resize((4, 4), Image.Resampling.NEAREST)
            out.extend(encode_bc1_image(pad_im))
        return bytes(out)


def _encode_bc1_rgb_single(im_rgb: Image.Image) -> bytes:
    """Fast BC1 (DXT1) 4x4 block encoder for RGB images."""
    w, h = im_rgb.size
    if w < 4 or h < 4:
        im_rgb = im_rgb.resize((max(4, w), max(4, h)), Image.Resampling.BILINEAR)
        w, h = im_rgb.size
    try:
        import numpy as np
        arr = np.frombuffer(im_rgb.convert("RGB").tobytes(), dtype=np.uint8).reshape((h, w, 3))
        bh, bw = h // 4, w // 4
        blocks = arr.reshape((bh, 4, bw, 4, 3)).transpose(0, 2, 1, 3, 4).reshape((-1, 16, 3)).astype(np.int32)
        lum = blocks[:, :, 0] * 77 + blocks[:, :, 1] * 150 + blocks[:, :, 2] * 29
        max_idx = np.argmax(lum, axis=1)
        min_idx = np.argmin(lum, axis=1)
        n_blk = blocks.shape[0]
        b_arange = np.arange(n_blk)
        c_hi = blocks[b_arange, max_idx]
        c_lo = blocks[b_arange, min_idx]
        c0 = ((c_hi[:, 0] >> 3) << 11) | ((c_hi[:, 1] >> 2) << 5) | (c_hi[:, 2] >> 3)
        c1 = ((c_lo[:, 0] >> 3) << 11) | ((c_lo[:, 1] >> 2) << 5) | (c_lo[:, 2] >> 3)
        swap = c0 < c1
        if np.any(swap):
            c0_s = np.where(swap, c1, c0)
            c1_s = np.where(swap, c0, c1)
            c0, c1 = c0_s, c1_s
            l_hi = lum[b_arange, max_idx]
            l_lo = lum[b_arange, min_idx]
            l0 = np.where(swap, l_lo, l_hi)[:, None]
            l1 = np.where(swap, l_hi, l_lo)[:, None]
        else:
            l0 = lum[b_arange, max_idx][:, None]
            l1 = lum[b_arange, min_idx][:, None]
        span = l0 - l1
        span_abs = np.where(span == 0, 1, np.abs(span))
        rel = np.abs(lum - l1) * 6
        codes = np.zeros_like(lum, dtype=np.uint32)
        codes = np.where(rel >= span_abs * 5, 0, np.where(rel >= span_abs * 3, 2, np.where(rel >= span_abs * 1, 3, 1)))
        codes = np.where((c0 == c1)[:, None], 0, codes)
        shifts = (np.arange(16, dtype=np.uint32) * 2)[None, :]
        idx_bits = np.bitwise_or.reduce(codes << shifts, axis=1)
        out = np.empty((n_blk, 2), dtype=np.uint32)
        out[:, 0] = (c0.astype(np.uint32) & 0xFFFF) | ((c1.astype(np.uint32) & 0xFFFF) << 16)
        out[:, 1] = idx_bits
        return out.tobytes()
    except ImportError:
        return encode_bc1_image(im_rgb)


def encode_bc1_rgb_mips(im_rgb: Image.Image, mips: int = 11) -> bytes:
    out = bytearray()
    w0, h0 = im_rgb.size
    for m in range(mips):
        mw = max(1, w0 >> m)
        mh = max(1, h0 >> m)
        im_m = im_rgb if m == 0 else im_rgb.resize((mw, mh), Image.Resampling.LANCZOS)
        out.extend(_encode_bc1_rgb_single(im_m))
    return bytes(out)


def _draw_fitted_centered_text(
    draw: ImageDraw.ImageDraw,
    text: str,
    font_path: str,
    max_size: int,
    min_x: int,
    max_x: int,
    center_y: int,
    fill: tuple[int, int, int],
    outline: tuple[int, int, int] | None = None,
    outline_w: int = 2,
    shadow: tuple[int, int, int] | None = None,
    shadow_off: tuple[int, int] = (4, 4),
) -> None:
    max_w = max_x - min_x
    sz = max_size
    font = ImageFont.load_default()
    while sz >= 14:
        try:
            font = ImageFont.truetype(font_path, sz)
        except Exception:
            font = ImageFont.load_default()
            break
        bbox = draw.textbbox((0, 0), text, font=font)
        tw = bbox[2] - bbox[0]
        if tw <= max_w:
            break
        sz -= 2
    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    tx = (min_x + max_x - tw) // 2 - bbox[0]
    ty = center_y - th // 2 - bbox[1]
    if shadow is not None:
        draw.text((tx + shadow_off[0], ty + shadow_off[1]), text, font=font, fill=shadow)
    if outline is not None and outline_w > 0:
        for ox in range(-outline_w, outline_w + 1):
            for oy in range(-outline_w, outline_w + 1):
                if ox * ox + oy * oy <= outline_w * outline_w + 1:
                    draw.text((tx + ox, ty + oy), text, font=font, fill=outline)
    draw.text((tx, ty), text, font=font, fill=fill)


def build_location_signs() -> None:
    """
    Generates all 7 exterior/interior 1024x1024 BC1 (11-mipmap) location sign plaque DDS textures
    for the Southern California (2161) surface bunkers and interior stations.
    """
    vault_tex_dir = os.path.join(THIS_DIR, "assets", "textures", "interiors", "vault")
    os.makedirs(vault_tex_dir, exist_ok=True)

    sign_specs = [
        (
            "VltSignWatershed12_d.dds",
            "blue",
            "LA CUENCA DE NECRÓPOLIS — VAULT-TEC",
            "REFUGIO 12",
            "ESTACIÓN DE PURIFICACIÓN • PUESTO DE HARRY",
        ),
        (
            "VltSignNecropolis_d.dds",
            "bronze",
            "ANTIGUA BAKERSFIELD — REFUGIO 12",
            "NECRÓPOLIS",
            "CIUDAD DE LOS MUERTOS • DOMINIO DE SET",
        ),
        (
            "VltSignVault15Map_d.dds",
            "blue",
            "CAÑÓN ORIENTAL — CORPORACIÓN VAULT-TEC",
            "REFUGIO 15",
            "INSTALACIÓN SUBTERRÁNEA • GUARIDA KHAN",
        ),
        (
            "VltSignLostHilMap_d.dds",
            "steel",
            "HERMANDAD DEL ACERO — CALIFORNIA SUR",
            "LOST HILLS",
            "BÚNKER DE ALTA SEGURIDAD • ARCHIVO DE VREE",
        ),
        (
            "VltSignMariposMap_d.dds",
            "olive",
            "EJÉRCITO DE EE. UU. — PROYECTO V.E.F.",
            "BASE MARIPOSA",
            "COMPLEJO MILITAR • CUBAS BIOQUÍMICAS",
        ),
        (
            "VltSignCathedrMap_d.dds",
            "crimson",
            "EL BONEYARD (LOS ÁNGELES) — LA UNIDAD",
            "LA CATEDRAL",
            "SANTUARIO DE MORPHEUS • TRONO DEL MAESTRO",
        ),
        (
            "VltSignTemporaMap_d.dds",
            "blue",
            "ENLACE CUÁNTICO MNEMOSYNE — VAULT-TEC",
            "AÑO 2287",
            "PUENTE TEMPORAL • RETORNO A COMMONWEALTH",
        ),
    ]

    palettes = {
        "blue": {
            "bg": (22, 39, 58),
            "panel": (14, 26, 40),
            "gold": (214, 166, 62),
            "inner": (92, 128, 162),
            "top_txt": (236, 198, 96),
            "main_txt": (255, 246, 202),
            "main_out": (196, 142, 42),
            "bot_txt": (162, 218, 248),
        },
        "bronze": {
            "bg": (46, 30, 16),
            "panel": (30, 18, 8),
            "gold": (198, 142, 54),
            "inner": (132, 92, 42),
            "top_txt": (228, 184, 96),
            "main_txt": (255, 240, 196),
            "main_out": (184, 114, 32),
            "bot_txt": (234, 182, 82),
        },
        "steel": {
            "bg": (34, 42, 48),
            "panel": (22, 28, 34),
            "gold": (194, 168, 98),
            "inner": (120, 138, 152),
            "top_txt": (222, 204, 136),
            "main_txt": (244, 248, 252),
            "main_out": (148, 126, 64),
            "bot_txt": (182, 212, 232),
        },
        "olive": {
            "bg": (36, 44, 26),
            "panel": (24, 30, 16),
            "gold": (198, 166, 64),
            "inner": (112, 128, 84),
            "top_txt": (228, 202, 104),
            "main_txt": (248, 246, 208),
            "main_out": (156, 128, 42),
            "bot_txt": (198, 224, 154),
        },
        "crimson": {
            "bg": (48, 22, 24),
            "panel": (32, 12, 14),
            "gold": (212, 158, 62),
            "inner": (148, 84, 78),
            "top_txt": (236, 192, 102),
            "main_txt": (255, 242, 204),
            "main_out": (186, 112, 38),
            "bot_txt": (242, 186, 152),
        },
    }

    font_bold = "C:/Windows/Fonts/arialbd.ttf"
    font_impact = "C:/Windows/Fonts/impact.ttf"
    if not os.path.exists(font_impact):
        font_impact = font_bold

    for fn, theme_key, top_line, main_line, bot_line in sign_specs:
        pal = palettes[theme_key]
        im_s = Image.new("RGB", (1024, 1024), pal["bg"])
        dr = ImageDraw.Draw(im_s)

        for y_off in (0, 512):
            # Subtle weathered horizontal striations
            for sy in range(y_off + 16, y_off + 496, 8):
                c_mod = -4 if ((sy // 8) % 2 == 0) else 4
                c_line = (
                    max(0, min(255, pal["bg"][0] + c_mod)),
                    max(0, min(255, pal["bg"][1] + c_mod)),
                    max(0, min(255, pal["bg"][2] + c_mod)),
                )
                dr.line([(16, sy), (1008, sy)], fill=c_line, width=2)

            # Outer heavy gold/brass frame + inner bevel
            dr.rectangle([14, y_off + 14, 1010, y_off + 498], outline=pal["gold"], width=6)
            dr.rectangle([26, y_off + 26, 998, y_off + 486], outline=pal["gold"], width=3)
            dr.rectangle([34, y_off + 34, 990, y_off + 478], outline=pal["inner"], width=2)

            # Corner & midpoint rivets
            for rx, ry in [
                (20, y_off + 20), (512, y_off + 20), (1004, y_off + 20),
                (20, y_off + 492), (512, y_off + 492), (1004, y_off + 492),
            ]:
                dr.ellipse([rx - 5, ry - 5, rx + 5, ry + 5], fill=pal["gold"])

            # Top header banner box
            dr.rectangle([48, y_off + 48, 976, y_off + 116], fill=pal["panel"], outline=pal["gold"], width=2)
            # Bottom subheader banner box
            dr.rectangle([48, y_off + 380, 976, y_off + 458], fill=pal["panel"], outline=pal["gold"], width=2)

            # Render 3 text bands guaranteed to fit inside [64..960]
            _draw_fitted_centered_text(
                dr, top_line, font_bold, 34, 68, 956, y_off + 82,
                fill=pal["top_txt"], shadow=(8, 8, 8), shadow_off=(2, 2),
            )
            _draw_fitted_centered_text(
                dr, main_line, font_impact, 152, 68, 956, y_off + 246,
                fill=pal["main_txt"], outline=pal["main_out"], outline_w=3,
                shadow=(8, 8, 8), shadow_off=(6, 6),
            )
            _draw_fitted_centered_text(
                dr, bot_line, font_bold, 34, 68, 956, y_off + 419,
                fill=pal["bot_txt"], shadow=(8, 8, 8), shadow_off=(2, 2),
            )

        mips_payload = encode_bc1_rgb_mips(im_s, mips=11)
        dds_hdr_11 = struct.pack(
            "<4s7I44s9I16s",
            b"DDS ", 124, 0x000A1007, 1024, 1024, 524288, 0, 11,
            b"\x00" * 44,
            32, 0x04, int.from_bytes(b"DXT1", "little"), 0, 0, 0, 0, 0, 0x00401008,
            b"\x00" * 16,
        )
        out_path = os.path.join(vault_tex_dir, fn)
        with open(out_path, "wb") as wf:
            wf.write(dds_hdr_11 + mips_payload)
        print(f"[Sign DDS] Generated {fn} ({len(dds_hdr_11) + len(mips_payload)} bytes)")


def encode_bc1_image(im_rgb: Image.Image) -> bytes:
    """Fast, clean BC1 (DXT1) 4x4 block encoder for grayscale/monochrome Pip-Boy map textures."""
    w, h = im_rgb.size
    px = im_rgb.convert("L").tobytes()
    out = bytearray((w // 4) * (h // 4) * 8)
    pos = 0
    for by in range(0, h, 4):
        r0 = by * w
        r1 = (by + 1) * w
        r2 = (by + 2) * w
        r3 = (by + 3) * w
        for bx in range(0, w, 4):
            b = (
                px[r0 + bx], px[r0 + bx + 1], px[r0 + bx + 2], px[r0 + bx + 3],
                px[r1 + bx], px[r1 + bx + 1], px[r1 + bx + 2], px[r1 + bx + 3],
                px[r2 + bx], px[r2 + bx + 1], px[r2 + bx + 2], px[r2 + bx + 3],
                px[r3 + bx], px[r3 + bx + 1], px[r3 + bx + 2], px[r3 + bx + 3],
            )
            lo = min(b)
            hi = max(b)
            c0 = ((hi >> 3) << 11) | ((hi >> 2) << 5) | (hi >> 3)
            c1 = ((lo >> 3) << 11) | ((lo >> 2) << 5) | (lo >> 3)
            if c0 == c1:
                struct.pack_into("<HHI", out, pos, c0, c1, 0)
            else:
                if c0 < c1:
                    c0, c1 = c1, c0
                    hi, lo = lo, hi
                span = hi - lo
                t_hi = lo + (span * 5) // 6
                t_mid = lo + (span * 3) // 6
                t_lo = lo + (span * 1) // 6
                idx_bits = 0
                shift = 0
                for v in b:
                    if v >= t_hi:
                        code = 0
                    elif v >= t_mid:
                        code = 2
                    elif v >= t_lo:
                        code = 3
                    else:
                        code = 1
                    idx_bits |= (code << shift)
                    shift += 2
                struct.pack_into("<HHI", out, pos, c0, c1, idx_bits)
            pos += 8
    return bytes(out)


if __name__ == "__main__":
    build_worldmap()
