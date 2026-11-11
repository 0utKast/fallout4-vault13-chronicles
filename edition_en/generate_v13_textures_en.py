# -*- coding: utf-8 -*-
"""
Generates all custom English (.dds) textures, signs, maps, and 3D decals for
'Vault 13 Chronicles (2161)' (English Edition) in `edition_en/assets/`:
  1. `V13CaliforniaWorldMap_d.dds` (2048x2048 BC1 Pip-Boy World Map in English)
  2. The 7 exterior/interior 1024x1024 BC1 (11-mipmap) location sign plaques in English:
     - `VltSignWatershed12_d.dds`
     - `VltSignNecropolis_d.dds`
     - `VltSignVault15Map_d.dds`
     - `VltSignLostHilMap_d.dds`
     - `VltSignMariposMap_d.dds`
     - `VltSignCathedrMap_d.dds`
     - `VltSignTemporaMap_d.dds`
  3. `GarageCabinet13_d.dds` (1024x1024 BC1 11-mipmap Vault 13 Quartermaster Cabinet in English)
  4. `ElvisVelvetPainting_d.dds` (1024x1024 BC1 11-mipmap Velvet Elvis Painting in English)
  5. Copies the language-neutral custom textures (`VltOverseerMaps13_d.dds`, `KillianHat_d.dds`,
     `LarsHelm_d.dds`, `TychoHelm_d.dds`, `TychoVisor_d.dds`, `TardisPoliceBox_d.dds`) into `edition_en/assets/`.
"""

import math
import os
import shutil
import struct
import sys
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

THIS_DIR = os.path.dirname(os.path.abspath(__file__))
ES_ROOT_DIR = os.path.dirname(THIS_DIR)
if ES_ROOT_DIR not in sys.path:
    sys.path.insert(0, ES_ROOT_DIR)

from generate_v13_worldmap_dds import (
    MAP_MAX,
    MAP_MIN,
    MAP_SPAN,
    _coastline_x,
    _draw_fitted_centered_text,
    encode_bc1_image,
    encode_bc1_rgb_mips,
    encode_bc1_worldmap_mips,
    global_california_height,
    world_to_px,
)


def _draw_gold_star(draw: ImageDraw.ImageDraw, cx: float, cy: float, r_outer: float, r_inner: float, fill: tuple[int, int, int]) -> None:
    pts = []
    for i in range(10):
        ang = math.radians(-90 + i * 36)
        r = r_outer if (i % 2 == 0) else r_inner
        pts.append((cx + r * math.cos(ang), cy + r * math.sin(ang)))
    draw.polygon(pts, fill=fill)


def build_worldmap_en() -> str:
    out_dds = os.path.join(THIS_DIR, "assets", "textures", "interface", "pip-boy", "V13CaliforniaWorldMap_d.dds")
    preview_png = os.path.join(THIS_DIR, "assets", "textures", "interface", "pip-boy", "V13CaliforniaWorldMap_preview.png")
    os.makedirs(os.path.dirname(out_dds), exist_ok=True)
    S = 2048

    G = 512
    h_grid = [[0.0] * G for _ in range(G)]
    lo_pixels = bytearray(G * G)

    for gy in range(G):
        wy = MAP_MAX - ((gy + 0.5) / G) * MAP_SPAN
        row_h = h_grid[gy]
        for gx in range(G):
            wx = MAP_MIN + ((gx + 0.5) / G) * MAP_SPAN
            row_h[gx] = global_california_height(wx, wy)

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
                depth_norm = min(1.0, abs(z) / 520.0)
                val = int(22.0 - 7.0 * depth_norm)
                if abs(wx - shore_x) < 1600.0 and (gy % 3 == 0):
                    val += 5
            else:
                elev_norm = max(0.0, min(1.0, (z + 20.0) / 1450.0))
                shade = (-dz_dx * 0.72 + dz_dy * 0.68)
                val_f = 44.0 + elev_norm * 46.0 + shade * 14.0
                z_mod = abs((z + 800.0) % 160.0)
                if z > 90.0 and (z_mod < 11.0 or z_mod > 149.0):
                    val_f -= 12.0
                val = max(28, min(102, int(val_f)))

            lo_pixels[base_idx + gx] = val

    im_low = Image.frombytes("L", (G, G), bytes(lo_pixels))
    im = im_low.resize((S, S), Image.Resampling.BILINEAR)
    im = im.filter(ImageFilter.GaussianBlur(radius=1.5))
    draw = ImageDraw.Draw(im)

    # 1. Pacific Ocean coastline border
    coast_pts = []
    for step_y in range(0, 257):
        wy = MAP_MAX - (step_y / 256.0) * MAP_SPAN
        wx = _coastline_x(wy)
        coast_pts.append(world_to_px(wx, wy, S))
    draw.line(coast_pts, fill=10, width=6)
    draw.line(coast_pts, fill=88, width=2)

    # 2. Pre-War Highways & Caravan Trails of Southern California (2161)
    roads = [
        [
            (-6200, 13600), (-4600, 13480), (-3200, 13360), (-2600, 13160),
            (-2500, 11800), (-220, 9760), (2400, 9600),
            (5400, 8800), (8200, 7800), (10400, 7300), (12600, 6880),
        ],
        [
            (2400, 9600), (6400, 13800), (10400, 13400), (14200, 10800), (8200, 7800),
        ],
        [
            (2400, 9600), (3000, 6800), (3600, 3800), (8400, 3200),
            (12000, 800), (11850, -800), (11400, -2400),
            (10400, -4200), (11400, -8200), (12400, -11800),
        ],
        [(11400, -2400), (12500, -2200), (13600, -2000)],
        [
            (-6200, 13600), (-9800, 13400), (-11600, 7400), (-8600, 4800),
            (-9200, 2200), (-9800, -2600), (-9200, -5550), (-8400, -8600), (-4800, -13180),
        ],
        [
            (-9800, -2600), (-4800, -6180), (-800, -3800), (2600, -400), (3600, 3800),
            (-2800, 5600), (-7400, 7600), (-9200, 2200), (-1600, 1200), (-800, -3800),
            (4800, -5400), (10400, -4200),
        ],
        [
            (-800, -3800), (-2600, -8400), (-4800, -13180), (600, -12800), (6800, -10400), (4800, -5400),
        ],
    ]
    for r in roads:
        r_px = [world_to_px(x, y, S) for x, y in r]
        draw.line(r_px, fill=28, width=7)
        draw.line(r_px, fill=98, width=3)

    # 3. Bakersfield / Necropolis Ruined Urban Street Grid
    for ux in range(9800, 14400, 900):
        p0 = world_to_px(ux, 1400, S)
        p1 = world_to_px(ux, -4600, S)
        draw.line([p0, p1], fill=62, width=1)
    for uy in range(-4400, 1600, 900):
        p0 = world_to_px(9600, uy, S)
        p1 = world_to_px(14200, uy, S)
        draw.line([p0, p1], fill=62, width=1)

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

    # 5. English Cartographic headers & regional labels
    try:
        font_title = ImageFont.truetype("C:/Windows/Fonts/consolab.ttf", 28)
        font_reg = ImageFont.truetype("C:/Windows/Fonts/consola.ttf", 19)
    except Exception:
        font_title = ImageFont.load_default()
        font_reg = ImageFont.load_default()

    draw.text((76, 68), "VAULT-TEC // SOUTHERN CALIFORNIA [2161] — SATELLITE TOPOGRAPHY", fill=106, font=font_title)
    draw.text((76, 102), "REGIONAL GRID 28x30 — VAULT 13 / SIERRA NEVADA / THE BONEYARD", fill=86, font=font_reg)

    region_labels_en = [
        (-11200, 14100, "MARIPOSA MILITARY BASE"),
        (-4800, 14200, "VAULT 13 / MT. WHITNEY"),
        (1600, 10300, "SHADY SANDS"),
        (5200, 14400, "RADSCORPION LAIR"),
        (9400, 14000, "PETROX'S RAIDER CAMP"),
        (11800, 11400, "KHAN SLAVER STRONGHOLD"),
        (6800, 8400, "KHAN CANYON PASS"),
        (11200, 7600, "VAULT 15 CANYON"),
        (-13200, 8000, "BLUE POLICE BOX (TARDIS)"),
        (-8600, 8200, "CRASHED FLYING SAUCER"),
        (-3800, 6200, "SKULZ HIDEOUT (KENJI)"),
        (2600, 4500, "JUNKTOWN"),
        (7200, 3900, "BOB'S USED CARS"),
        (-10600, 2900, "IRWIN'S OCCUPIED FARM"),
        (-2600, 1800, "GIZMO'S CASINO"),
        (1600, 250, "PATRICK THE CELT"),
        (10600, 1500, "THE WATERSHED (VAULT 12)"),
        (9800, -5100, "BAKERSFIELD / NECROPOLIS"),
        (-11400, -1900, "LOST HILLS (BROTHERHOOD)"),
        (-1800, -3200, "THE HUB"),
        (-6400, -5600, "MISSING CARAVAN PASS"),
        (3600, -4800, "NUKA-COLA TRUCK"),
        (-10000, -8000, "THE GLOW (WEST TEK)"),
        (-6200, -12500, "THE CATHEDRAL"),
        (-400, -12200, "ADYTUM / THE BONEYARD"),
        (5200, -9800, "MOTHER DEATHCLAW NEST"),
        (10800, -11200, "GIANT FOOTPRINT"),
        (-14800, -9800, "PACIFIC OCEAN"),
    ]
    for lx, ly, ltxt in region_labels_en:
        px_x, px_y = world_to_px(lx, ly, S)
        draw.text((px_x - 60, px_y), ltxt, fill=92, font=font_reg)

    # 6. Location survey rings at exact 3D Worldspace coordinates
    loc_coords = [
        (-6200, 13600),
        (-3200, 13360),
        (-2600, 13160),
        (2400, 9600),
        (6400, 13800),
        (10400, 13400),
        (14200, 10800),
        (8200, 7800),
        (12600, 6880),
        (3600, 3800),
        (-2800, 5600),
        (-1600, 1200),
        (8400, 3200),
        (-11600, 7400),
        (-7400, 7600),
        (2600, -400),
        (-9200, 2200),
        (-800, -3800),
        (-4800, -6180),
        (4800, -5400),
        (12000, 800),
        (11400, -2400),
        (13600, -2000),
        (10400, -4200),
        (-9800, -2600),
        (-8400, -8600),
        (-9800, 13400),
        (-4800, -13180),
        (600, -12800),
        (6800, -10400),
        (12400, -11800),
    ]
    for cx, cy in loc_coords:
        x0, y0 = world_to_px(cx, cy, S)
        draw.ellipse([x0 - 15, y0 - 15, x0 + 15, y0 + 15], outline=106, width=2)
        draw.ellipse([x0 - 4, y0 - 4, x0 + 4, y0 + 4], fill=112)

    im.resize((512, 512)).save(preview_png)

    top_mip_pitch = (S // 4) * (S // 4) * 8
    bc1_payload = encode_bc1_worldmap_mips(im, mips=12)
    dds_hdr = struct.pack(
        "<4s7I44s9I16s",
        b"DDS ", 124, 0x000A1007, S, S, top_mip_pitch, 0, 12,
        b"\x00" * 44,
        32, 0x04, int.from_bytes(b"DXT1", "little"), 0, 0, 0, 0, 0, 0x00401008,
        b"\x00" * 16,
    )
    with open(out_dds, "wb") as wf:
        wf.write(dds_hdr + bc1_payload)
    print(f"[WorldMap DDS EN] Generated {out_dds} ({len(dds_hdr) + len(bc1_payload)} bytes, 12 mipmaps)")
    return out_dds


def build_location_signs_en() -> None:
    vault_tex_dir = os.path.join(THIS_DIR, "assets", "textures", "interiors", "vault")
    os.makedirs(vault_tex_dir, exist_ok=True)

    sign_specs_en = [
        (
            "VltSignWatershed12_d.dds",
            "blue",
            "NECROPOLIS WATERSHED — VAULT-TEC",
            "VAULT 12",
            "PURIFICATION STATION • HARRY'S POST",
        ),
        (
            "VltSignNecropolis_d.dds",
            "bronze",
            "OLD BAKERSFIELD — VAULT 12",
            "NECROPOLIS",
            "CITY OF THE DEAD • SET'S DOMAIN",
        ),
        (
            "VltSignVault15Map_d.dds",
            "blue",
            "EASTERN CANYON — VAULT-TEC CORP.",
            "VAULT 15",
            "UNDERGROUND FACILITY • KHAN LAIR",
        ),
        (
            "VltSignLostHilMap_d.dds",
            "steel",
            "BROTHERHOOD OF STEEL — SO. CALIFORNIA",
            "LOST HILLS",
            "HIGH-SECURITY BUNKER • VREE'S ARCHIVE",
        ),
        (
            "VltSignMariposMap_d.dds",
            "olive",
            "U.S. ARMY — PROJECT F.E.V.",
            "MARIPOSA BASE",
            "MILITARY COMPLEX • BIOCHEMICAL VATS",
        ),
        (
            "VltSignCathedrMap_d.dds",
            "crimson",
            "THE BONEYARD (LOS ANGELES) — THE UNITY",
            "THE CATHEDRAL",
            "SANCTUARY OF MORPHEUS • MASTER'S LAIR",
        ),
        (
            "VltSignTemporaMap_d.dds",
            "blue",
            "MNEMOSYNE QUANTUM LINK — VAULT-TEC",
            "YEAR 2287",
            "TEMPORAL BRIDGE • COMMONWEALTH RETURN",
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

    for fn, theme_key, top_line, main_line, bot_line in sign_specs_en:
        pal = palettes[theme_key]
        im_s = Image.new("RGB", (1024, 1024), pal["bg"])
        dr = ImageDraw.Draw(im_s)

        for y_off in (0, 512):
            for sy in range(y_off + 16, y_off + 496, 8):
                c_mod = -4 if ((sy // 8) % 2 == 0) else 4
                c_line = (
                    max(0, min(255, pal["bg"][0] + c_mod)),
                    max(0, min(255, pal["bg"][1] + c_mod)),
                    max(0, min(255, pal["bg"][2] + c_mod)),
                )
                dr.line([(16, sy), (1008, sy)], fill=c_line, width=2)

            dr.rectangle([14, y_off + 14, 1010, y_off + 498], outline=pal["gold"], width=6)
            dr.rectangle([26, y_off + 26, 998, y_off + 486], outline=pal["gold"], width=3)
            dr.rectangle([34, y_off + 34, 990, y_off + 478], outline=pal["inner"], width=2)

            for rx, ry in [
                (20, y_off + 20), (512, y_off + 20), (1004, y_off + 20),
                (20, y_off + 492), (512, y_off + 492), (1004, y_off + 492),
            ]:
                dr.ellipse([rx - 5, ry - 5, rx + 5, ry + 5], fill=pal["gold"])

            dr.rectangle([48, y_off + 48, 976, y_off + 116], fill=pal["panel"], outline=pal["gold"], width=2)
            dr.rectangle([48, y_off + 380, 976, y_off + 458], fill=pal["panel"], outline=pal["gold"], width=2)

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
        print(f"[Sign DDS EN] Generated {fn} ({len(dds_hdr_11) + len(mips_payload)} bytes)")


def build_garage_cabinet13_en_dds() -> str:
    """
    Loads the Spanish `GarageCabinet13_d.dds` base (preserving 100% of the brushed Vault-Tec steel,
    rivets, gears, shelves, and borders), cleanly refills each label's interior background, and renders
    crisp English typography for all horizontal and vertical panels.
    """
    es_dds = os.path.join(ES_ROOT_DIR, "assets", "textures", "setdressing", "garage", "GarageCabinet13_d.dds")
    out_dds = os.path.join(THIS_DIR, "assets", "textures", "setdressing", "garage", "GarageCabinet13_d.dds")
    os.makedirs(os.path.dirname(out_dds), exist_ok=True)

    im = Image.open(es_dds).convert("RGB")
    draw = ImageDraw.Draw(im)
    font_bold = "C:/Windows/Fonts/arialbd.ttf"

    # 1. Top-Left Box next to Gear 13 (x=107..227, y=135..218)
    draw.rectangle([107, 135, 227, 218], fill=(33, 52, 82))
    _draw_fitted_centered_text(draw, "VAULT-TEC", font_bold, 16, 109, 225, 149, fill=(239, 186, 66))
    _draw_fitted_centered_text(draw, "VAULT 13", font_bold, 20, 109, 225, 175, fill=(245, 247, 250))
    _draw_fitted_centered_text(draw, "QUARTERMASTER", font_bold, 13, 109, 225, 199, fill=(239, 186, 66))

    # 2. Mid-Left Box 1 Header (x=27..229, y=257..285) & Body (x=22..234, y=288..365)
    draw.rectangle([27, 257, 229, 285], fill=(24, 38, 56))
    _draw_fitted_centered_text(draw, "FIELD SUPPLIES", font_bold, 15, 31, 225, 271, fill=(239, 186, 66))
    draw.rectangle([22, 288, 234, 365], fill=(33, 52, 74))
    _draw_fitted_centered_text(draw, "AUTHORIZED ISSUE", font_bold, 14, 28, 228, 309, fill=(245, 247, 250))
    _draw_fitted_centered_text(draw, "OVERSEER V-13", font_bold, 13, 28, 228, 331, fill=(195, 214, 236))
    draw.line([(56, 342), (200, 342)], fill=(107, 138, 173), width=1)

    # 3. Mid-Left Box 2 (x=28..228, y=381..476)
    draw.rectangle([28, 381, 228, 476], fill=(41, 60, 90))
    _draw_fitted_centered_text(draw, "STRATEGIC RESERVE", font_bold, 14, 32, 224, 402, fill=(239, 186, 66))
    _draw_fitted_centered_text(draw, "SURFACE EXPEDITION", font_bold, 14, 32, 224, 427, fill=(245, 247, 250))
    _draw_fitted_centered_text(draw, "COMMAND SECTOR 13", font_bold, 12, 32, 224, 450, fill=(239, 186, 66))

    # Helper to draw rotated (+90 deg, bottom-to-top) centered vertical text onto `im`
    def draw_vertical_box_text(
        bx0: int, by0: int, bx1: int, by1: int,
        bg_col: tuple[int, int, int],
        lines_spec: list[tuple[str, int, tuple[int, int, int], int]],
    ) -> None:
        bw = bx1 - bx0 + 1
        bh = by1 - by0 + 1
        sub = Image.new("RGB", (bh, bw), bg_col)
        sdraw = ImageDraw.Draw(sub)
        for txt, max_sz, col, cy_local in lines_spec:
            _draw_fitted_centered_text(sdraw, txt, font_bold, max_sz, 8, bh - 8, cy_local, fill=col)
        rot = sub.rotate(90, expand=True)
        im.paste(rot, (bx0, by0))

    # 4. Vertical Strip 1 (x=278..346, y=454..661)
    draw_vertical_box_text(
        278, 454, 346, 661,
        (16, 32, 49),
        [
            ("VAULT-TEC INDUSTRIES", 15, (239, 186, 66), 17),
            ("OPERATIONS DIVISION", 13, (220, 232, 246), 51),
        ],
    )
    draw.line([(310, 464), (310, 651)], fill=(214, 166, 62), width=1)

    # 5. Vertical Strip 2 next to large Gear 13 (x=496..596, y=452..656)
    draw_vertical_box_text(
        496, 452, 596, 656,
        (24, 44, 66),
        [
            ("VAULT 13", 26, (239, 186, 66), 21),
            ("OVERSEER", 15, (245, 247, 250), 62),
            ("QUARTERMASTER", 15, (245, 247, 250), 82),
        ],
    )
    draw.line([(546, 464), (546, 646)], fill=(214, 166, 62), width=2)

    # 6. Vertical Strip 3 (x=612..804, y=454..661)
    # 6a: Dark left header bar (x=612..648, y=454..661)
    draw_vertical_box_text(
        612, 454, 648, 661,
        (18, 30, 46),
        [
            ("SUPPLY CABINET", 15, (239, 186, 66), 18),
        ],
    )
    # 6b: Middle description area (x=649..704, y=454..661)
    draw_vertical_box_text(
        649, 454, 704, 661,
        (41, 65, 90),
        [
            ("EXPEDITION GEAR", 14, (245, 247, 250), 18),
            ("& SURFACE SURVIVAL", 13, (205, 222, 240), 38),
        ],
    )
    # 6c: 3 bordered sub-rows (x=705..804, y=454..661)
    draw.rectangle([705, 454, 804, 661], fill=(41, 65, 90))
    draw_vertical_box_text(
        706, 460, 790, 654,
        (33, 52, 74),
        [
            ("ISSUE: RATIONS / AMMO", 12, (239, 186, 66), 14),
            ("ACCESS: AUTHORIZED STAFF", 11, (224, 234, 246), 42),
            ("REGISTRY: V13-QM-SEC-03", 11, (195, 214, 236), 70),
        ],
    )
    draw.rectangle([706, 460, 790, 654], outline=(107, 142, 181), width=1)
    draw.line([(734, 460), (734, 654)], fill=(107, 142, 181), width=1)
    draw.line([(762, 460), (762, 654)], fill=(107, 142, 181), width=1)

    # 7. Vertical Strip 4 on rightmost louver panel (x=952..988, y=460..655)
    draw_vertical_box_text(
        952, 460, 988, 655,
        (16, 32, 49),
        [
            ("PROPERTY OF VAULT-TEC", 11, (239, 186, 66), 10),
            ("COMMAND POST - VAULT 13", 10, (224, 234, 246), 26),
        ],
    )

    # 8. Bottom Drawer Box (x=204..369, y=901..964)
    draw.rectangle([204, 901, 369, 964], fill=(16, 32, 49))
    _draw_fitted_centered_text(draw, "VAULT 13", font_bold, 19, 208, 365, 919, fill=(239, 186, 66))
    _draw_fitted_centered_text(draw, "QUARTERMASTER", font_bold, 13, 208, 365, 945, fill=(245, 247, 250))

    # 9. Bottom Right Maintenance Header Box (x=802..968, y=732..776)
    draw.rectangle([802, 732, 968, 776], fill=(16, 32, 49))
    _draw_fitted_centered_text(draw, "VAULT 13", font_bold, 17, 806, 964, 745, fill=(239, 186, 66))
    _draw_fitted_centered_text(draw, "MAINTENANCE", font_bold, 12, 806, 964, 764, fill=(245, 247, 250))

    mips_payload = encode_bc1_rgb_mips(im, mips=11)
    dds_hdr_11 = struct.pack(
        "<4s7I44s9I16s",
        b"DDS ", 124, 0x000A1007, 1024, 1024, 524288, 0, 11,
        b"\x00" * 44,
        32, 0x04, int.from_bytes(b"DXT1", "little"), 0, 0, 0, 0, 0, 0x00401008,
        b"\x00" * 16,
    )
    with open(out_dds, "wb") as wf:
        wf.write(dds_hdr_11 + mips_payload)
    print(f"[Cabinet DDS EN] Generated {out_dds} ({len(dds_hdr_11) + len(mips_payload)} bytes)")
    return out_dds


def build_elvis_velvet_painting_en_dds() -> str:
    """
    Generates the 1024x1024 BC1 (11-mipmap) English texture for the Velvet Elvis Painting
    (Fallout 1 'Fuzzy Painting' in the Area 51 Crashed Flying Saucer encounter).
    """
    out_dds = os.path.join(
        THIS_DIR, "assets", "junktown_3d", "Textures", "V13Chronicles", "Junktown", "ElvisVelvetPainting_d.dds"
    )
    os.makedirs(os.path.dirname(out_dds), exist_ok=True)

    yy, xx = np.mgrid[0:1024, 0:1024].astype(np.float32)

    wood_grain = np.sin(xx * 0.22 + np.sin(yy * 0.05) * 2.0) * 10.0 + np.cos(yy * 0.35) * 6.0
    base_r = np.clip(168.0 + wood_grain * 1.1, 90.0, 225.0)
    base_g = np.clip(126.0 + wood_grain * 0.9, 64.0, 182.0)
    base_b = np.clip(48.0 + wood_grain * 0.5, 20.0, 92.0)

    mask_velvet = (xx < 512) & (yy < 640)
    rad_glow = np.exp(-(((xx - 256.0) / 165.0) ** 2 + ((yy - 300.0) / 195.0) ** 2))
    velvet_fuzz = (np.sin(xx * 1.7) * np.cos(yy * 1.7)) * 3.0
    vel_r = np.clip(12.0 + 48.0 * rad_glow + velvet_fuzz, 6.0, 74.0)
    vel_g = np.clip(10.0 + 18.0 * rad_glow + velvet_fuzz, 5.0, 42.0)
    vel_b = np.clip(22.0 + 64.0 * rad_glow + velvet_fuzz, 10.0, 98.0)
    base_r = np.where(mask_velvet, vel_r, base_r)
    base_g = np.where(mask_velvet, vel_g, base_g)
    base_b = np.where(mask_velvet, vel_b, base_b)

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

    draw.rectangle([16, 16, 495, 623], outline=(214, 168, 68), width=6)
    draw.rectangle([28, 28, 483, 611], outline=(142, 96, 36), width=2)

    cx, cy = 256, 290
    for ang_deg in range(0, 360, 15):
        rad = math.radians(ang_deg)
        r_len = 165 if (ang_deg % 30 == 0) else 115
        x_end = cx + int(r_len * math.cos(rad))
        y_end = cy + int(r_len * math.sin(rad))
        draw.line([(cx, cy), (x_end, y_end)], fill=(96, 42, 118), width=3)
    draw.ellipse([cx - 125, cy - 125, cx + 125, cy + 125], fill=(28, 16, 46), outline=(228, 178, 72), width=3)

    draw.polygon([(148, 340), (195, 285), (317, 285), (364, 340), (340, 440), (172, 440)], fill=(238, 236, 230), outline=(210, 172, 74), width=3)
    draw.polygon([(84, 515), (148, 365), (364, 365), (428, 515)], fill=(242, 240, 235), outline=(212, 174, 72), width=4)
    draw.polygon([(216, 355), (296, 355), (256, 475)], fill=(186, 34, 38), outline=(224, 180, 74), width=2)
    draw.polygon([(234, 355), (278, 355), (256, 435)], fill=(198, 142, 108))
    for stud_y in (395, 430, 465, 495):
        off_x = int((stud_y - 360) * 0.38)
        for sx in (202 - off_x, 310 + off_x):
            draw.ellipse([sx - 7, stud_y - 7, sx + 7, stud_y + 7], fill=(238, 192, 68), outline=(178, 32, 36), width=2)

    draw.rectangle([222, 315, 290, 375], fill=(214, 158, 122))
    draw.ellipse([188, 185, 324, 348], fill=(224, 168, 132), outline=(168, 114, 84), width=2)

    draw.ellipse([172, 126, 342, 238], fill=(16, 18, 26))
    draw.ellipse([190, 110, 352, 212], fill=(22, 26, 38))
    draw.arc([202, 124, 332, 200], start=200, end=340, fill=(68, 78, 108), width=5)
    draw.polygon([(184, 210), (206, 215), (204, 302), (186, 294)], fill=(18, 20, 28))
    draw.polygon([(328, 210), (306, 215), (308, 302), (326, 294)], fill=(18, 20, 28))

    draw.rounded_rectangle([200, 232, 250, 268], radius=8, fill=(58, 38, 22), outline=(238, 196, 78), width=4)
    draw.rounded_rectangle([262, 232, 312, 268], radius=8, fill=(58, 38, 22), outline=(238, 196, 78), width=4)
    draw.line([(248, 242), (264, 242)], fill=(238, 196, 78), width=4)
    draw.line([(188, 244), (200, 244)], fill=(238, 196, 78), width=3)
    draw.line([(312, 244), (324, 244)], fill=(238, 196, 78), width=3)
    draw.line([(210, 240), (228, 258)], fill=(245, 215, 130), width=3)
    draw.line([(272, 240), (290, 258)], fill=(245, 215, 130), width=3)

    draw.line([(256, 252), (252, 284), (264, 286)], fill=(172, 116, 86), width=3)
    draw.arc([228, 288, 288, 322], start=10, end=165, fill=(168, 64, 64), width=5)
    draw.line([(315, 345), (355, 495)], fill=(190, 198, 208), width=6)
    draw.ellipse([296, 318, 332, 358], fill=(210, 218, 226), outline=(90, 98, 110), width=3)

    # Banner & Typography on Zone A Velvet Canvas with real 5-point gold star polygons
    f_title = load_font(44, bold=True)
    f_sub = load_font(22, bold=True)
    draw.text((256, 68), "THE KING", font=f_title, fill=(246, 204, 78), anchor="mm")
    _draw_gold_star(draw, 118.0, 66.0, 16.0, 7.0, (246, 204, 78))
    _draw_gold_star(draw, 394.0, 66.0, 16.0, 7.0, (246, 204, 78))
    draw.rectangle([56, 522, 456, 592], fill=(24, 14, 36), outline=(228, 182, 68), width=3)
    draw.text((256, 545), "ELVIS • VIVA LAS VEGAS", font=f_sub, fill=(248, 214, 96), anchor="mm")
    draw.text((256, 574), "COLLECTOR'S VELVET EDITION — FALLOUT 1997", font=load_font(14, bold=True), fill=(214, 168, 224), anchor="mm")

    # Zone B (x: 512..1024, y: 0..640): Back of Framed Canvas + English Area 51 / Graceland Label
    draw.rectangle([528, 16, 1007, 623], outline=(78, 54, 28), width=18)
    draw.rectangle([600, 160, 936, 460], fill=(228, 216, 188), outline=(92, 68, 42), width=3)
    draw.text((768, 205), "PROPERTY OF AREA 51", font=load_font(22, bold=True), fill=(156, 28, 28), anchor="mm")
    draw.text((768, 245), "TERRESTRIAL ARTIFACT #01-ELVIS", font=load_font(17, bold=True), fill=(42, 36, 28), anchor="mm")
    draw.text((768, 295), '"A velvet painting of \'The King\'.', font=load_font(16, bold=False), fill=(52, 44, 34), anchor="mm")
    draw.text((768, 322), 'Truly a magnificent work of art."', font=load_font(16, bold=False), fill=(52, 44, 34), anchor="mm")
    draw.text((768, 380), "RECOVERED FROM CRASHED FLYING SAUCER", font=load_font(13, bold=True), fill=(98, 42, 32), anchor="mm")
    draw.text((768, 415), "SOUTHERN CALIFORNIA — YEAR 2161", font=load_font(15, bold=True), fill=(42, 36, 28), anchor="mm")

    # Zone C (y: 640..1024): Carved Gilded Frame Molding Stripes
    for y_band in (664, 720, 790, 860, 930, 985):
        draw.line([(0, y_band), (1023, y_band)], fill=(238, 198, 88), width=6)
        draw.line([(0, y_band + 8), (1023, y_band + 8)], fill=(96, 64, 22), width=4)

    im = im.filter(ImageFilter.SMOOTH_MORE)
    mips_payload = encode_bc1_rgb_mips(im, mips=11)
    dds_hdr_11 = struct.pack(
        "<4s7I44s9I16s",
        b"DDS ", 124, 0x000A1007, 1024, 1024, 524288, 0, 11,
        b"\x00" * 44,
        32, 0x04, int.from_bytes(b"DXT1", "little"), 0, 0, 0, 0, 0, 0x00401008,
        b"\x00" * 16,
    )
    with open(out_dds, "wb") as wf:
        wf.write(dds_hdr_11 + mips_payload)
    print(f"[Elvis DDS EN] Generated {out_dds} ({len(dds_hdr_11) + len(mips_payload)} bytes)")
    return out_dds


def copy_shared_dds_textures() -> None:
    """Copies the language-neutral custom DDS textures into `edition_en/assets/`."""
    pairs = [
        (
            os.path.join(ES_ROOT_DIR, "assets", "textures", "interiors", "vault", "VltOverseerMaps13_d.dds"),
            os.path.join(THIS_DIR, "assets", "textures", "interiors", "vault", "VltOverseerMaps13_d.dds"),
        ),
    ]
    for fn in [
        "KillianHat_d.dds",
        "LarsHelm_d.dds",
        "LarsGuardHelmet_d.dds",
        "TychoHelm_d.dds",
        "TychoVisor_d.dds",
        "TardisPoliceBox_d.dds",
        "GiantFootprint_d.dds",
    ]:
        pairs.append(
            (
                os.path.join(ES_ROOT_DIR, "assets", "junktown_3d", "Textures", "V13Chronicles", "Junktown", fn),
                os.path.join(THIS_DIR, "assets", "junktown_3d", "Textures", "V13Chronicles", "Junktown", fn),
            )
        )
    for src, dst in pairs:
        if os.path.exists(src):
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            shutil.copyfile(src, dst)
            print(f"[Shared DDS EN] Copied {os.path.basename(dst)}")


def generate_all_english_textures() -> None:
    copy_shared_dds_textures()
    build_worldmap_en()
    build_location_signs_en()
    build_garage_cabinet13_en_dds()
    build_elvis_velvet_painting_en_dds()


if __name__ == "__main__":
    generate_all_english_textures()
