# -*- coding: utf-8 -*-
"""
Generates the 2048x2048 BC1/DXT1 Pip-Boy World Map texture for Crónicas del Refugio 13:
  assets/textures/interface/pip-boy/V13CaliforniaWorldMap_d.dds
and provides the exact shared 3D heightfield `global_california_height(wx, wy)` used by
`build_cronicas_refugio_13.py` to generate the 64 exterior `LAND` records of
`WRLD 0x01003400` ("Sur de California (2161)").

Worldspace bounds:
  8x8 exterior cells: cx in [-4..3], cy in [-4..3]
  wx in [-16384.0 .. +16384.0], wy in [-16384.0 .. +16384.0]
"""

import math
import os
import struct
from PIL import Image, ImageDraw, ImageFilter, ImageFont

THIS_DIR = os.path.dirname(os.path.abspath(__file__))
OUT_DDS = os.path.join(THIS_DIR, "assets", "textures", "interface", "pip-boy", "V13CaliforniaWorldMap_d.dds")
PREVIEW_PNG = os.path.join(THIS_DIR, "assets", "textures", "interface", "pip-boy", "V13CaliforniaWorldMap_preview.png")

WORLD_MIN = -16384.0
WORLD_MAX = 16384.0
WORLD_SPAN = WORLD_MAX - WORLD_MIN  # 32768.0

# Pip-Boy World Map bounds matching WRLD 0x01003400 MNAM = (0, 0, -4, 4, 4, -4)
# (Fallout4.exe shifts MNAM shorts by << 12, so (-4, 4, 4, -4) = [-16384.0 .. +16384.0])
MAP_MIN = -16384.0
MAP_MAX = 16384.0
MAP_SPAN = MAP_MAX - MAP_MIN  # 32768.0


def world_to_px(wx: float, wy: float, size: int = 2048) -> tuple[float, float]:
    u = (wx - MAP_MIN) / MAP_SPAN
    v = (MAP_MAX - wy) / MAP_SPAN
    return (u * size, v * size)


def px_to_world(px: float, py: float, size: int = 2048) -> tuple[float, float]:
    wx = MAP_MIN + (px / size) * MAP_SPAN
    wy = MAP_MAX - (py / size) * MAP_SPAN
    return (wx, wy)


def _smoothstep(edge0: float, edge1: float, x: float) -> float:
    if x <= edge0:
        return 0.0
    if x >= edge1:
        return 1.0
    t = (x - edge0) / (edge1 - edge0)
    return t * t * (3.0 - 2.0 * t)


def _coastline_x(wy: float) -> float:
    """
    Returns the West-coast shoreline X coordinate for a given Y coordinate,
    faithfully following Fallout 1's Southern California coastline across the full
    [-16384..+16384] worldspace while keeping all western coastal locations inland.
    """
    if wy > 6500.0:
        # Far NW coast (Monterey / Big Sur, well west of Mariposa at -9800 and TARDIS at -11600)
        base = -14200.0 - (wy - 6500.0) * 0.08
    elif wy > -3500.0:
        # Central Coast (San Luis Obispo / Morro Bay / Point Conception, west of Irwin's Farm & Lost Hills)
        t = (6500.0 - wy) / 10000.0
        base = -14200.0 + t * 1400.0
    elif wy > -9500.0:
        # Santa Barbara curve eastward toward Ventura / Malibu (west of The Glow at -8400)
        t = (-3500.0 - wy) / 6000.0
        base = -12800.0 + t * 2000.0
    else:
        # Santa Monica Bay -> Palos Verdes -> San Pedro / Long Beach (well west of The Cathedral at -4800)
        t = (-9500.0 - wy) / 6884.0
        base = -10800.0 + t * 2400.0
    # Natural coastal coves and headlands
    ripple = 280.0 * math.sin(wy * 0.00075 + 0.8) + 160.0 * math.cos(wy * 0.0019 - 0.4)
    return base + ripple


# Flat settlement / dungeon entrance plateaus: (cx, cy, target_z, r_flat, r_blend)
# Every target_z is an exact multiple of 8.0 (Creation Engine VHGT vertex unit), and every r_flat
# encompasses 100% of all building footprints in that settlement/outpost.
LOCATION_PLATEAUS: list[tuple[float, float, float, float, float]] = [
    (-2950.0, 13350.0, 320.0, 1350.0, 2200.0),   # Refugio 13 & Cueva de Entrada (Mt. Whitney canyon)
    (-6200.0, 13600.0, 320.0, 1050.0, 2100.0),   # Puente Temporal (2287) canyon pass
    (-2500.0, 11800.0, 240.0, 900.0, 1450.0),    # Northern Pass Red Rocket Service Station
    (-220.0, 9760.0, 160.0, 920.0, 1450.0),      # Parada de Caravanas del Paso de Sierra Nevada
    (2400.0, 9600.0, 160.0, 2550.0, 3300.0),     # Shady Sands town & commercial outskirts
    (550.0, 9600.0, 160.0, 1200.0, 1950.0),      # Shady Sands Diner SO & House W
    (4000.0, 10150.0, 160.0, 900.0, 1400.0),     # Shady Sands Super Duper Mart NE & House E
    (6400.0, 13800.0, 160.0, 1450.0, 2500.0),    # Guarida Lejana del Mutascorpión Emperador
    (10400.0, 13400.0, 200.0, 1150.0, 2200.0),   # Campamento de Saqueadores de Petrox (Celda de Tandi)
    (14200.0, 10800.0, 200.0, 1650.0, 2800.0),   # Fortaleza Esclavista de los Khans del Norte (Tolan)
    (8250.0, 8020.0, 200.0, 900.0, 1500.0),      # Paso Oriental de los Khans (Refugio de Diana y Gwen)
    (12150.0, 7050.0, 240.0, 1650.0, 2800.0),    # Refugio 15 canyon & Khan Raider outpost
    (3550.0, 4150.0, 80.0, 1650.0, 2800.0),      # Junktown (Ciudad Chatarra) & Central Valley Waystation
    (6160.0, 1400.0, 80.0, 1150.0, 2100.0),      # Estación de Servicio y Talleres del Valle Central
    (8350.0, 3250.0, 80.0, 1250.0, 2200.0),      # Concesionario de Coches de Bob (Bob's Pre-Owned Car Mart)
    (1200.0, 3800.0, 80.0, 1050.0, 2200.0),      # Puesto de Caravanas del Valle Central
    (-2800.0, 5600.0, 80.0, 1350.0, 2400.0),     # Guarida de los Skulz (Kenji)
    (-1600.0, 1200.0, 80.0, 1350.0, 2400.0),     # Casino de Gizmo y Guarida de Vinnie
    (-11600.0, 7400.0, 160.0, 1050.0, 2100.0),   # Encuentro Especial: Cabina Telefónica Inusual (TARDIS)
    (-7400.0, 7600.0, 160.0, 850.0, 1800.0),     # Encuentro Especial: Platillo Volante Estrellado (Área 51)
    (-800.0, -3800.0, 80.0, 1450.0, 2500.0),     # El Eje (The Hub) — Mercado de Caravanas
    (4850.0, -5300.0, 48.0, 900.0, 1500.0),      # Encuentro Especial: Camión de Nuka-Cola Volcado
    (-4900.0, -6050.0, 96.0, 1550.0, 2450.0),    # Paso Rocoso de la Caravana Desaparecida (Sanguinario y Tug)
    (2600.0, -360.0, 80.0, 1050.0, 2100.0),      # Encuentro Especial: Patrick el Celta & Parada de Caravanas
    (-9200.0, 2350.0, 80.0, 1550.0, 2600.0),     # Complejo Agrícola de la Granja de Irwin (Krag)
    (-6950.0, 2625.0, 160.0, 1150.0, 2000.0),    # Western Highway Drumlin Diner & Waystation
    (-8600.0, 4800.0, 216.0, 1200.0, 1900.0),    # Campamento Militar Abandonado de la Costa Norte
    (-9800.0, -2600.0, 120.0, 1450.0, 2400.0),   # Lost Hills Brotherhood bunker & Cabbot Gate
    (-9200.0, -5550.0, 120.0, 1050.0, 2000.0),   # Puesto de Patrulla Sur de la Hermandad
    (-8375.0, -8450.0, 120.0, 1450.0, 2500.0),   # El Resplandor (The Glow — Complejo West Tek)
    (-9950.0, 13350.0, 280.0, 1400.0, 2100.0),   # Base Militar Mariposa
    (-4800.0, -12650.0, 40.0, 2050.0, 2850.0),   # La Catedral (El Boneyard / L.A. urban district + Super Duper Mart)
    (760.0, -12450.0, 40.0, 1350.0, 2250.0),     # Adytum — Fortaleza de los Gun Runners
    (3550.0, -11300.0, 40.0, 1550.0, 2500.0),    # Suburbio en Ruinas del Este de Los Ángeles (Boneyard Este)
    (2700.0, -11000.0, 40.0, 1150.0, 2000.0),    # Almacén Intermedio de Adytum
    (6700.0, -10400.0, 40.0, 2250.0, 3000.0),    # Distrito Industrial Este del Boneyard — Nido de la Madre Sanguinario
    (12400.0, -11800.0, 160.0, 1100.0, 2100.0),  # Encuentro Especial: La Huella Gigante de Godzilla (Desierto Suroriental)
]


def global_california_height(wx: float, wy: float) -> float:
    """
    Continuous, deterministic 3D elevation function Z(wx, wy) for Southern California (2161).
    Shared 1:1 between the 100 exterior LAND records and the 2048x2048 Pip-Boy World Map.
    Designed with wide, gentle valley basins and low-gradient hills so no settlement or
    objective is ever inside a steep crater and every route is 100% walkable without jumping.
    """
    # 1. Pacific Ocean shelf in the West / Southwest
    shore_x = _coastline_x(wy)
    if wx < shore_x:
        depth_t = _smoothstep(0.0, 3500.0, shore_x - wx)
        # Channel Islands off Santa Barbara (-14200, -6400) and Catalina (-12600, -11800)
        d_isl1 = math.hypot((wx - (-14200.0)) * 0.7, (wy - (-6400.0)) * 1.3)
        d_isl2 = math.hypot((wx - (-12600.0)) * 0.8, (wy - (-11800.0)) * 1.2)
        isl_boost = 0.0
        if d_isl1 < 1400.0:
            isl_boost = max(isl_boost, 520.0 * (1.0 - _smoothstep(320.0, 1400.0, d_isl1)))
        if d_isl2 < 1250.0:
            isl_boost = max(isl_boost, 480.0 * (1.0 - _smoothstep(280.0, 1250.0, d_isl2)))
        return -520.0 * depth_t + isl_boost

    coastal_rise = _smoothstep(0.0, 1600.0, wx - shore_x)

    # 2. Smooth regional valley baseline interpolated from LOCATION_PLATEAUS & Necropolis basin
    #    so the natural ground elevation around every settlement/objective already matches its target_z
    w_sum = 0.0
    z_sum = 0.0
    basin_clear = 1.0
    for px, py, pz, r_flat, r_blend in LOCATION_PLATEAUS:
        d = math.hypot(wx - px, wy - py)
        w_idw = 1.0 / ((d * d) + (1800.0 * 1800.0))
        w_sum += w_idw
        z_sum += pz * w_idw
        if d < r_blend + 1800.0:
            c_loc = _smoothstep(r_flat + 250.0, r_blend + 1800.0, d)
            if c_loc < basin_clear:
                basin_clear = c_loc

    # Include Necropolis basin center (12000, -1700, Z=0.0) in regional interpolation
    d_nec_center = math.hypot(wx - 12000.0, wy - (-1700.0))
    w_nec_idw = 1.8 / ((d_nec_center * d_nec_center) + (2400.0 * 2400.0))
    w_sum += w_nec_idw
    regional_valley_z = z_sum / w_sum if w_sum > 0.0 else 100.0

    # Gentle rolling desert dunes & arroyos (suppressed near flat settlement plateaus)
    n1 = math.sin(wx * 0.00045 + 0.3) * math.cos(wy * 0.00042 - 0.5)
    n2 = math.sin((wx + wy) * 0.00095) * math.cos((wx - wy) * 0.00085)
    n3 = math.sin(wx * 0.0021 - 1.2) * math.sin(wy * 0.0023 + 0.7)
    dunes = (22.0 * n1 + 11.0 * n2 + 5.0 * n3) * basin_clear

    # 3. Gentle, Walkable Orographic Ridges & Distant Perimeter Mountains (suppressed inside valley basins):
    # (a) Far Northern Sierra Rim (North-West of Vault 13)
    d_sierra_n = math.hypot((wx - (-4200.0)) * 0.55, (wy - 15400.0) * 0.85)
    sierra_n = 210.0 * math.exp(-((d_sierra_n / 4200.0) ** 2))

    # Low Tehachapi rolling hills
    d_sierra_s = math.hypot((wx - (-800.0)) * 0.70, (wy - 7400.0) * 0.70)
    sierra_s = 85.0 * math.exp(-((d_sierra_s / 3600.0) ** 2))

    # (b) Far North-East Mojave Rim
    d_mojave = math.hypot((wx - 14800.0) * 0.65, (wy - 14400.0) * 0.75)
    mojave_mtn = 180.0 * math.exp(-((d_mojave / 4200.0) ** 2))

    # (c) Coastal Hills (Northwest & Central Coast)
    d_coast_nw = math.hypot((wx - (-12800.0)) * 0.75, (wy - 11600.0) * 0.65)
    coast_nw = 160.0 * math.exp(-((d_coast_nw / 3800.0) ** 2))

    d_coast_mid = math.hypot((wx - (-11400.0)) * 0.8, (wy - 800.0) * 0.55)
    coast_mid = 110.0 * math.exp(-((d_coast_mid / 3600.0) ** 2))

    # (d) Gentle Transverse Hills
    d_transverse = math.hypot((wx - (-4200.0)) * 0.50, (wy - (-8800.0)) * 0.90)
    transverse = 95.0 * math.exp(-((d_transverse / 3800.0) ** 2))

    # (e) Far Eastern Mojave Rim (East of Necropolis)
    d_east_rim = max(0.0, wx - 15200.0)
    east_rim = 160.0 * _smoothstep(0.0, 2400.0, d_east_rim)

    mtn_sum = (sierra_n + sierra_s + mojave_mtn + coast_nw + coast_mid + transverse + east_rim) * basin_clear
    crag = (0.08 * mtn_sum) * (
        0.6 * math.sin(wx * 0.0017 + wy * 0.0013)
        + 0.4 * math.cos(wx * 0.0031 - wy * 0.0027)
    )
    z = (regional_valley_z + dunes + mtn_sum + crag) * coastal_rise

    # 4. Gentle pass corridors along main caravan highways so the player can walk comfortably
    #    North Road: Vault 13 (-3200, 13360) -> Shady Sands (2400, 9600) -> Vault 15 (12600, 6880)
    if -3800.0 <= wx <= 13200.0 and 6200.0 <= wy <= 14200.0:
        if wx < 2400.0:
            t_r = max(0.0, min(1.0, (wx - (-3200.0)) / 5600.0))
            road_y = 13360.0 * (1.0 - t_r) + 9600.0 * t_r
            z_pass = 320.0 * (1.0 - t_r) + 160.0 * t_r
        else:
            t_r = max(0.0, min(1.0, (wx - 2400.0) / 10200.0))
            road_y = 9600.0 * (1.0 - t_r) + 6880.0 * t_r
            z_pass = 160.0 * (1.0 - t_r) + 240.0 * t_r
        d_road = abs(wy - road_y)
        if d_road < 900.0:
            w_r = _smoothstep(260.0, 900.0, d_road)
            z = z_pass * (1.0 - w_r) + z * w_r

    # 5. Flatten Bakersfield / Necropolis Open-Air Ruined City Basin:
    #    X in [9400..14600], Y in [-5000..+1850] -> exact Z = 0.0
    dx_nec = 0.0
    if wx < 9400.0:
        dx_nec = 9400.0 - wx
    elif wx > 14600.0:
        dx_nec = wx - 14600.0
    dy_nec = 0.0
    if wy < -5000.0:
        dy_nec = -5000.0 - wy
    elif wy > 1850.0:
        dy_nec = wy - 1850.0
    d_nec = math.hypot(dx_nec, dy_nec)
    if d_nec < 2600.0:
        w_nec = _smoothstep(0.0, 2600.0, d_nec)
        z = 0.0 * (1.0 - w_nec) + z * w_nec

    # 6. Flatten each Settlement / Surface Entrance Plateau LAST so every complex sits on 100% flat ground
    #    Uses rim-distance priority so no plateau's transition apron (r_blend) can ever overwrite another plateau's r_flat.
    shore_blend = _smoothstep(0.0, 220.0, wx - shore_x)
    locked_pz: float | None = None
    blend_w_sum = 0.0
    blend_pz_sum = 0.0
    max_inf = 0.0
    for px, py, pz, r_flat, r_blend in LOCATION_PLATEAUS:
        d = math.hypot(wx - px, wy - py)
        if d <= r_flat:
            locked_pz = pz * shore_blend
            break
        elif d < r_blend:
            t_rim = (d - r_flat) / (r_blend - r_flat)
            inf = 1.0 - _smoothstep(0.0, 1.0, t_rim)
            if inf > max_inf:
                max_inf = inf
            w_p = (inf * inf) / (t_rim * t_rim + 1e-6)
            blend_w_sum += w_p
            blend_pz_sum += (pz * shore_blend) * w_p
    if locked_pz is not None:
        z = locked_pz
    elif max_inf > 0.0 and blend_w_sum > 0.0:
        avg_pz = blend_pz_sum / blend_w_sum
        z = avg_pz * max_inf + z * (1.0 - max_inf)
    if d_nec == 0.0:
        z = 0.0

    return z


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

    # 2. Pre-War Highways & Caravan Trails of Southern California (2161)
    roads = [
        # Northern Sierra Pass (CA-190 / US-395): Puente Temporal -> Refugio 13 -> Shady Sands -> Khans -> Refugio 15
        [
            (-6200, 13600), (-4600, 13480), (-3200, 13360), (-2600, 13160),
            (-2500, 11800), (-220, 9760), (2400, 9600),
            (5400, 8800), (8200, 7800), (10400, 7300), (12600, 6880),
        ],
        # North-East Raider Trail: Shady Sands -> Mutascorpion Lair -> Petrox Camp -> Tolan Stronghold -> Khans Pass
        [
            (2400, 9600), (6400, 13800), (10400, 13400), (14200, 10800), (8200, 7800),
        ],
        # Eastern Sierra & Kern Canyon Route: Shady Sands -> Junktown -> Bob's -> La Cuenca -> Necrópolis -> Huella Gigante
        [
            (2400, 9600), (3000, 6800), (3600, 3800), (8400, 3200),
            (12000, 800), (11850, -800), (11400, -2400),
            (10400, -4200), (11400, -8200), (12400, -11800),
        ],
        # Necropolis street branch to Sala de los Muertos
        [(11400, -2400), (12500, -2200), (13600, -2000)],
        # Western Military & Brotherhood Route: Mariposa -> TARDIS -> Irwin Farm -> Lost Hills -> El Resplandor -> La Catedral
        [
            (-6200, 13600), (-9800, 13400), (-11600, 7400), (-8600, 4800),
            (-9200, 2200), (-9800, -2600), (-9200, -5550), (-8400, -8600), (-4800, -13180),
        ],
        # Cross-Valley Caravan Network: Lost Hills -> Granja Irwin -> Kenji -> Junktown -> Gizmo -> El Eje -> Necrópolis
        [
            (-9800, -2600), (-4800, -6180), (-800, -3800), (2600, -400), (3600, 3800),
            (-2800, 5600), (-7400, 7600), (-9200, 2200), (-1600, 1200), (-800, -3800),
            (4800, -5400), (10400, -4200),
        ],
        # Southern Boneyard Highway: El Eje -> La Catedral -> Adytum -> Nido Madre Sanguinario
        [
            (-800, -3800), (-2600, -8400), (-4800, -13180), (600, -12800), (6800, -10400), (4800, -5400),
        ],
    ]
    for r in roads:
        r_px = [world_to_px(x, y, S) for x, y in r]
        draw.line(r_px, fill=28, width=7)
        draw.line(r_px, fill=98, width=3)

    # 3. Bakersfield / Necropolis Ruined Urban Street Grid on the map
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

    # 5. Cartographic headers & regional labels
    try:
        font_title = ImageFont.truetype("C:/Windows/Fonts/consolab.ttf", 28)
        font_reg = ImageFont.truetype("C:/Windows/Fonts/consola.ttf", 19)
    except Exception:
        font_title = ImageFont.load_default()
        font_reg = ImageFont.load_default()

    draw.text((76, 68), "VAULT-TEC // SUR DE CALIFORNIA [2161] — TOPOGRAFÍA SATELITAL", fill=106, font=font_title)
    draw.text((76, 102), "CUADRÍCULA REGIONAL 28x30 — REFUGIO 13 / SIERRA NEVADA / BONEYARD", fill=86, font=font_reg)

    region_labels = [
        (-11200, 14100, "BASE MILITAR MARIPOSA"),
        (-4800, 14200, "REFUGIO 13 / MT. WHITNEY"),
        (1600, 10300, "SHADY SANDS"),
        (5200, 14400, "GUARIDA MUTASCORPIÓN"),
        (9400, 14000, "CAMPAMENTO DE PETROX"),
        (11800, 11400, "FORTALEZA ESCLAVISTA (TOLAN)"),
        (6800, 8400, "PASO DE LOS KHANS"),
        (11200, 7600, "REFUGIO 15"),
        (-13200, 8000, "CABINA AZUL (TARDIS)"),
        (-8600, 8200, "PLATILLO VOLANTE"),
        (-3800, 6200, "GUARIDA SKULZ (KENJI)"),
        (2600, 4500, "JUNKTOWN"),
        (7200, 3900, "COCHES DE BOB"),
        (-10600, 2900, "GRANJA DE IRWIN"),
        (-2600, 1800, "CASINO DE GIZMO"),
        (1600, 250, "PATRICK EL CELTA"),
        (10600, 1500, "LA CUENCA (REFUGIO 12)"),
        (9800, -5100, "RUINAS DE NECRÓPOLIS"),
        (-11400, -1900, "LOST HILLS (H. DEL ACERO)"),
        (-1800, -3200, "EL EJE (THE HUB)"),
        (-6400, -5600, "CARAVANA DESAPARECIDA"),
        (3600, -4800, "CAMIÓN DE NUKA-COLA"),
        (-10000, -8000, "EL RESPLANDOR (WEST TEK)"),
        (-6200, -12500, "LA CATEDRAL"),
        (-400, -12200, "ADYTUM / BONEYARD"),
        (5200, -9800, "NIDO MADRE SANGUINARIO"),
        (10800, -11200, "HUELLA GIGANTE"),
        (-14800, -9800, "OCÉANO PACÍFICO"),
    ]
    for lx, ly, ltxt in region_labels:
        px_x, px_y = world_to_px(lx, ly, S)
        draw.text((px_x - 60, px_y), ltxt, fill=92, font=font_reg)

    # 6. Location survey rings at exact 3D Worldspace coordinates
    loc_coords = [
        (-6200, 13600),   # Puente Temporal (2287)
        (-3200, 13360),   # Refugio 13
        (-2600, 13160),   # Cueva de Entrada del Refugio 13
        (2400, 9600),     # Shady Sands
        (6400, 13800),    # Guarida del Mutascorpión Emperador
        (10400, 13400),   # Campamento de Saqueadores de Petrox (Tandi)
        (14200, 10800),   # Fortaleza Esclavista de los Khans (Tolan)
        (8200, 7800),     # Paso Oriental de los Khans
        (12600, 6880),    # Refugio 15
        (3600, 3800),     # Junktown (Ciudad Chatarra)
        (-2800, 5600),    # Guarida de los Skulz (Kenji)
        (-1600, 1200),    # Casino de Gizmo y Vinnie
        (8400, 3200),     # Encuentro Especial: Concesionario de Coches Usados de Bob
        (-11600, 7400),   # Encuentro Especial: Cabina Telefónica Inusual (TARDIS)
        (-7400, 7600),    # Encuentro Especial: Platillo Volante Estrellado
        (2600, -400),     # Encuentro Especial: Patrick el Celta (El Bardo Viajero)
        (-9200, 2200),    # Granja Ocupada de Irwin (Krag)
        (-800, -3800),    # El Eje (The Hub)
        (-4800, -6180),   # Paso Rocoso de la Caravana Desaparecida
        (4800, -5400),    # Encuentro Especial: Camión de Nuka-Cola Volcado
        (12000, 800),     # La Cuenca (Refugio 12)
        (11400, -2400),   # Necrópolis — Galerías Subterráneas
        (13600, -2000),   # Necrópolis — Sala de los Muertos
        (10400, -4200),   # Necrópolis — Alcantarillas
        (-9800, -2600),   # Lost Hills
        (-8400, -8600),   # El Resplandor (West Tek)
        (-9800, 13400),   # Base Militar Mariposa
        (-4800, -13180),  # La Catedral
        (600, -12800),    # Adytum — Fortaleza de los Gun Runners
        (6800, -10400),   # Nido Industrial de la Madre Sanguinario
        (12400, -11800),  # Encuentro Especial: La Huella Gigante de Godzilla
    ]
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
