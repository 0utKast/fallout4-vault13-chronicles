# -*- coding: utf-8 -*-
"""
Single Source of Truth for the Expanded 20x20 Southern California (2161) Open Worldspace
(`WRLD 0x01003400`, `cx, cy in [-10..+9]`, `400` LAND/NAVM cells, `[-40960..+40960]` = 81,920 x 81,920 units).

Used by:
  - `build_cronicas_refugio_13.py` (WRLD, LAND, NAVM, NAVI, persistent doors/markers/actors, scenery)
  - `generate_v13_worldmap_dds.py` (Spanish 2048x2048 BC1 Pip-Boy 2000 World Map)
  - `edition_en/generate_v13_textures_en.py` (English 2048x2048 BC1 Pip-Boy 2000 World Map)
  - `audit_qa_cronicas_refugio_13.py` & `verify_v13_mod.py` (Automated QA & worldspace invariants)
"""

from __future__ import annotations

import math

CELL_MIN: int = -10
CELL_MAX: int = 9  # inclusive -> 20 x 20 = 400 exterior cells
CELL_STRIDE: int = CELL_MAX - CELL_MIN + 1  # 20
TOTAL_EXT_CELLS: int = CELL_STRIDE * CELL_STRIDE  # 400

WORLD_MIN: float = CELL_MIN * 4096.0          # -40960.0
WORLD_MAX: float = (CELL_MAX + 1) * 4096.0    # +40960.0
WORLD_SPAN: float = WORLD_MAX - WORLD_MIN     # 81920.0

MAP_MIN: float = WORLD_MIN
MAP_MAX: float = WORLD_MAX
MAP_SPAN: float = WORLD_SPAN

# Vanilla Fallout 4 16-byte .LOD header (<hhIII = minX, minY, stride, minLvl, maxLvl)
# Aligned to minLvl=4 and covering [-12 .. +19], enclosing all 400 cells [-10 .. +9].
LOD_SETTINGS_TUPLE: tuple[int, int, int, int, int] = (-12, -12, 32, 4, 32)

# Verified collision-free FormID blocks in Vault13Chronicles.esp for the 400-cell grid:
# Cell (0, 0) keeps its legacy FormID 0x01003402 (`V13SouthernCaliforniaSyncCell`).
EXT_CELL_FID_BASE: int = 0x010C0000  # 0x010C0000 .. 0x010C018F
EXT_LAND_FID_BASE: int = 0x010C1000  # 0x010C1000 .. 0x010C118F
EXT_NAVM_FID_BASE: int = 0x010C2000  # 0x010C2000 .. 0x010C218F


def _smoothstep(edge0: float, edge1: float, x: float) -> float:
    if x <= edge0:
        return 0.0
    if x >= edge1:
        return 1.0
    t = (x - edge0) / (edge1 - edge0)
    return t * t * (3.0 - 2.0 * t)


def cell_grid_index(cx: int, cy: int) -> int:
    assert CELL_MIN <= cx <= CELL_MAX and CELL_MIN <= cy <= CELL_MAX, f"Out of 20x20 bounds: ({cx}, {cy})"
    return (cy - CELL_MIN) * CELL_STRIDE + (cx - CELL_MIN)


def ext_cell_fid(cx: int, cy: int) -> int:
    if cx == 0 and cy == 0:
        return 0x01003402
    return EXT_CELL_FID_BASE + cell_grid_index(cx, cy)


def ext_land_fid(cx: int, cy: int) -> int:
    return EXT_LAND_FID_BASE + cell_grid_index(cx, cy)


def ext_navm_fid(cx: int, cy: int) -> int:
    return EXT_NAVM_FID_BASE + cell_grid_index(cx, cy)


def world_to_cell(wx: float, wy: float) -> tuple[int, int]:
    cx = max(CELL_MIN, min(CELL_MAX, int(math.floor(wx / 4096.0))))
    cy = max(CELL_MIN, min(CELL_MAX, int(math.floor(wy / 4096.0))))
    return cx, cy


def world_to_px(wx: float, wy: float, size: int = 2048) -> tuple[float, float]:
    u = (wx - MAP_MIN) / MAP_SPAN
    v = (MAP_MAX - wy) / MAP_SPAN
    return (u * size, v * size)


def px_to_world(px: float, py: float, size: int = 2048) -> tuple[float, float]:
    wx = MAP_MIN + (px / size) * MAP_SPAN
    wy = MAP_MAX - (py / size) * MAP_SPAN
    return (wx, wy)


def world_to_map_pixel(wx: float, wy: float, size: int = 2048) -> tuple[int, int]:
    px, py = world_to_px(wx, wy, size)
    return max(0, min(size - 1, int(round(px)))), max(0, min(size - 1, int(round(py))))


def coastline_x(wy: float) -> float:
    """
    Pacific Ocean coastline along the western edge of Southern California:
    curves smoothly from X ≈ -38,600 in the Northwest (Monterey/Mariposa coast)
    to X ≈ -25,400 in the Southwest (Santa Monica Bay / LA Boneyard coast).
    Water plane sits at XCLW = -20.0.
    """
    t = max(0.0, min(1.0, (WORLD_MAX - wy) / WORLD_SPAN))
    ripple = 650.0 * math.sin(wy / 5200.0 + 0.6) + 320.0 * math.cos(wy / 2700.0 - 0.3)
    return -38600.0 + 13200.0 * (t ** 1.35) + ripple


# Canonical 1997 Southern California Location Anchors:
# key -> (ax, ay, az, r_flat, r_blend, kind)
# Every az is an exact multiple of 8.0 (Creation Engine VHGT step) and matches the original Z height!
V13_WORLD_ANCHORS: dict[str, tuple[float, float, float, float, float, str]] = {
    # NW Military & Sci-Fi Sector
    "MARIPOSA":         (-31000.0,  31000.0, 280.0, 2600.0, 4600.0, "dungeon"),
    "TARDIS":           (-31500.0,  16500.0, 160.0, 1200.0, 2400.0, "special"),
    "ALIEN_SHIP":       (-20000.0,  19500.0, 160.0, 1400.0, 2600.0, "special"),

    # North-Central Sierra Nevada (Mount Whitney)
    "TEMPORAL_BRIDGE":  (-18000.0,  33500.0, 320.0, 1500.0, 2800.0, "settlement"),
    "VAULT_13":         ( -7000.0,  33000.0, 320.0, 2200.0, 4200.0, "settlement"),

    # NE Arid Plains — Expanded Shady Sands, Raiders, Khans & Vault 15
    "SHADY_SANDS":      (  6500.0,  23500.0, 160.0, 3800.0, 5800.0, "settlement"),
    "RADSCORPION_LAIR": ( 16000.0,  34500.0, 160.0, 1600.0, 3000.0, "hostile"),
    "PETROX_CAMP":      ( 26500.0,  33500.0, 200.0, 2000.0, 3600.0, "hostile"),
    "TOLAN_STRONGHOLD": ( 35000.0,  24500.0, 200.0, 1800.0, 3200.0, "hostile"),
    "DIANA_PASS":       ( 21500.0,  18500.0, 200.0, 1400.0, 2600.0, "settlement"),
    "VAULT_15":         ( 33500.0,  13500.0, 240.0, 2000.0, 3600.0, "dungeon"),

    # Central Valley — Expanded Junktown, Gizmo's District, Skulz, Irwin's Farm, Bob's & Patrick
    "JUNKTOWN":         (  7500.0,   5500.0,  80.0, 3600.0, 5600.0, "settlement"),
    "BOBS_CAR_MART":    ( 20500.0,   5000.0,  80.0, 1500.0, 2800.0, "special"),
    "PATRICK_CELT":     (  5500.0,  -4800.0,  80.0, 1200.0, 2400.0, "special"),
    "GIZMO_DISTRICT":   ( -4000.0,   2000.0,  80.0, 2200.0, 3800.0, "settlement"),
    "KENJI_HIDEOUT":    ( -5500.0,  13000.0,  80.0, 1500.0, 2800.0, "hostile"),
    "IRWIN_FARM":       (-18500.0,   6500.0,  80.0, 1600.0, 3000.0, "hostile"),

    # West-Central Foothills — Lost Hills (Brotherhood of Steel)
    "LOST_HILLS":       (-24500.0,  -7500.0, 120.0, 2600.0, 4600.0, "settlement"),

    # South-Central Merchant Crossroads — Expanded Hub, Missing Caravans & Nuka-Cola Wreck
    "THE_HUB":          ( -3500.0, -13500.0,  80.0, 3800.0, 5800.0, "settlement"),
    "CARAVAN_PASS":     (-15000.0, -18500.0,  96.0, 1600.0, 3000.0, "hostile"),
    "NUKA_TRUCK":       ( 10500.0, -15500.0,  48.0, 1400.0, 2600.0, "special"),

    # Eastern Ruined City Basin — Expanded Necropolis (Bakersfield / Vault 12, Z = 0.0)
    "NECROPOLIS_WATERSHED":   ( 29000.0,  -2000.0,   0.0, 2200.0, 4000.0, "dungeon"),
    "NECROPOLIS_UNDERGROUND": ( 28000.0,  -8000.0,   0.0, 2200.0, 4000.0, "dungeon"),
    "NECROPOLIS_HALL_DEAD":   ( 33500.0,  -7000.0,   0.0, 2200.0, 4000.0, "dungeon"),
    "NECROPOLIS_SEWERS":      ( 25500.0, -11500.0,   0.0, 2200.0, 4000.0, "dungeon"),

    # SW Coastal Ruins — Expanded LA Boneyard (La Catedral, Adytum/Gun Runners/Followers, Mother Deathclaw)
    "CATHEDRAL":        (-19500.0, -31500.0,  40.0, 3200.0, 5200.0, "dungeon"),
    "ADYTUM_BONEYARD":  ( -5600.0, -32200.0,  40.0, 3600.0, 5600.0, "settlement"),
    "MOTHER_DEATHCLAW": (  8500.0, -28000.0,  40.0, 2200.0, 3800.0, "hostile"),

    # SE Radioactive Wasteland — Canonical 1997 Position of The Glow (West Tek) & Godzilla Footprint
    "GODZILLA_FOOTPRINT": ( 20000.0, -33500.0, 160.0, 1600.0, 3000.0, "special"),
    "THE_GLOW":           ( 31500.0, -31500.0, 120.0, 2600.0, 4800.0, "hostile"),
}

# Scenic Roadside Waystation pads (Red Rocket / Drumlin Diner / Caravan Stops) along major highways
EXTRA_HIGHWAY_PLATEAUS: list[tuple[float, float, float, float, float]] = [
    (  -500.0,  28500.0, 240.0, 1200.0, 2400.0),  # Sierra Nevada Pass Red Rocket (between Vault 13 & Shady Sands)
    ( 14000.0,   5200.0,  80.0, 1200.0, 2400.0),  # Central Valley Service Station (between Junktown & Bob's)
    (-22500.0,   1200.0, 120.0, 1200.0, 2400.0),  # Western Highway Drumlin Diner (between Irwin's Farm & Lost Hills)
    (  2800.0, -13500.0,  80.0, 1400.0, 2600.0),  # Hub Old Town East Lockup (Initiate Lorenzo captive shack)
    (  1800.0, -29800.0,  40.0, 1500.0, 2800.0),  # East LA Ruined Suburb (between Adytum & Mother Deathclaw)
    (-26500.0,  23500.0, 240.0, 1200.0, 2200.0),  # 1. NW Mariposa Approach Homestead
    (-14500.0,  25500.0, 440.0, 1200.0, 2200.0),  # 2. High Sierra Prospectors Cabin
    ( 12500.0,  28500.0, 200.0, 1200.0, 2200.0),  # 3. NE Shady-Petrox Ridge Outpost
    ( 28500.0,  27500.0, 256.0, 1200.0, 2200.0),  # 4. Mojave Ridge Ruined Homestead
    (-11500.0,  18500.0, 392.0, 1200.0, 2200.0),  # 5. West Sierra Foothills Diner
    ( 15500.0,  12500.0, 136.0, 1200.0, 2200.0),  # 6. East Junktown-Vault 15 Red Rocket
    (-27500.0,  10500.0, 272.0, 1200.0, 2200.0),  # 7. Coastal Ridge Homestead
    (-12500.0,   -500.0, 128.0, 1200.0, 2200.0),  # 8. Central Crossroads Red Rocket
    ( 13500.0,  -4500.0,  88.0, 1200.0, 2200.0),  # 9. Bakersfield Approach Homestead
    ( 20500.0,  -6500.0,  72.0, 1200.0, 2200.0),  # 10. West Necropolis Super Duper Mart
    (-24500.0, -19500.0, 144.0, 1200.0, 2200.0),  # 11. Coastal Highway Diner (Lost Hills -> Cathedral)
    (-11500.0, -26500.0, 208.0, 1200.0, 2200.0),  # 12. North Boneyard Ridge Cabin
    (  3500.0, -21500.0, 200.0, 1200.0, 2200.0),  # 13. Hub-Adytum Caravan Rest Stop
    ( 17500.0, -21500.0,  96.0, 1200.0, 2200.0),  # 14. SE Desert Red Rocket & Homestead
    ( 29500.0, -20500.0,  96.0, 1200.0, 2200.0),  # 15. South Necropolis Waystation
    ( 14500.0, -33500.0,  96.0, 1200.0, 2200.0),  # 16. Southern Glow Trail Cabin
]

# Combined list of (px, py, pz, r_flat, r_blend) plateaus for heightfield generation
LOCATION_PLATEAUS: list[tuple[float, float, float, float, float]] = [
    (ax, ay, az, rf, rb)
    for k, (ax, ay, az, rf, rb, _kind) in V13_WORLD_ANCHORS.items()
    if not k.startswith("NECROPOLIS_")
] + EXTRA_HIGHWAY_PLATEAUS

# Bakersfield / Necropolis flat urban basin rectangle (X in [23000..36000], Y in [-14000..+500], Z = 0.0)
NECROPOLIS_BASIN_BOUNDS: tuple[float, float, float, float] = (23000.0, 36000.0, -14000.0, 500.0)
BONEYARD_BASIN_BOUNDS: tuple[float, float, float, float] = (-9800.0, 3900.0, -37000.0, -29000.0)


def anchor_xyz(key: str) -> tuple[float, float, float]:
    ax, ay, az, _, _, _ = V13_WORLD_ANCHORS[key]
    return ax, ay, az


def global_california_height(wx: float, wy: float) -> float:
    """
    Continuous, deterministic 3D elevation function Z(wx, wy) across [-40960..+40960]^2:
      - Pacific Ocean shelf & Channel Islands off the West/SW coast (water level XCLW = -20.0)
      - Smooth IDW valley baseline so all routes between settlements are gently sloped & 100% walkable
      - Sierra Nevada / Mount Whitney, Mojave & San Gabriel mountain ridges away from basins
      - Exact flat, zero-tilt plateaus around all settlements, bunkers, craters & encounters
    """
    shore_x = coastline_x(wy)
    if wx < shore_x:
        depth_t = _smoothstep(0.0, 6500.0, shore_x - wx)
        # Channel Islands off Santa Barbara (-36800, -15500) and Catalina (-32200, -33500)
        d_isl1 = math.hypot((wx - (-36800.0)) * 0.75, (wy - (-15500.0)) * 1.25)
        d_isl2 = math.hypot((wx - (-32200.0)) * 0.80, (wy - (-33500.0)) * 1.20)
        isl_boost = 0.0
        if d_isl1 < 2600.0:
            isl_boost = max(isl_boost, 520.0 * (1.0 - _smoothstep(600.0, 2600.0, d_isl1)))
        if d_isl2 < 2400.0:
            isl_boost = max(isl_boost, 480.0 * (1.0 - _smoothstep(550.0, 2400.0, d_isl2)))
        return -520.0 * depth_t + isl_boost

    coastal_rise = _smoothstep(0.0, 2600.0, wx - shore_x)

    # Smooth IDW regional valley baseline interpolated from LOCATION_PLATEAUS & Necropolis
    w_sum = 0.0
    z_sum = 0.0
    basin_clear = 1.0
    for px, py, pz, r_flat, r_blend in LOCATION_PLATEAUS:
        d = math.hypot(wx - px, wy - py)
        w_idw = 1.0 / ((d * d) + (4200.0 * 4200.0))
        w_sum += w_idw
        z_sum += pz * w_idw
        if d < r_blend + 3200.0:
            c_loc = _smoothstep(r_flat + 400.0, r_blend + 3200.0, d)
            if c_loc < basin_clear:
                basin_clear = c_loc

    d_nec_center = math.hypot(wx - 29500.0, wy - (-6750.0))
    w_nec_idw = 2.0 / ((d_nec_center * d_nec_center) + (5500.0 * 5500.0))
    w_sum += w_nec_idw
    regional_valley_z = z_sum / w_sum if w_sum > 0.0 else 100.0

    # Gentle rolling desert dunes & arroyos (suppressed near settlement plateaus)
    n1 = math.sin(wx * 0.00022 + 0.3) * math.cos(wy * 0.00021 - 0.5)
    n2 = math.sin((wx + wy) * 0.00048) * math.cos((wx - wy) * 0.00043)
    n3 = math.sin(wx * 0.0011 - 1.2) * math.sin(wy * 0.0012 + 0.7)
    dunes = (28.0 * n1 + 14.0 * n2 + 6.0 * n3) * basin_clear

    # Orographic mountain ranges (suppressed inside valley basins & plateaus)
    d_sierra_n = math.hypot((wx - (-9500.0)) * 0.45, (wy - 38200.0) * 0.85)
    sierra_n = 320.0 * math.exp(-((d_sierra_n / 8500.0) ** 2))

    d_sierra_spine = math.hypot((wx - (-12500.0)) * 0.85, (wy - 22000.0) * 0.42)
    sierra_spine = 220.0 * math.exp(-((d_sierra_spine / 7200.0) ** 2))

    d_mojave_ne = math.hypot((wx - 37500.0) * 0.65, (wy - 37500.0) * 0.75)
    mojave_ne = 260.0 * math.exp(-((d_mojave_ne / 8200.0) ** 2))

    d_coast_range = math.hypot((wx - (-31500.0)) * 0.80, (wy - 3500.0) * 0.45)
    coast_range = 175.0 * math.exp(-((d_coast_range / 7000.0) ** 2))

    d_san_gabriel = math.hypot((wx - (-6500.0)) * 0.45, (wy - (-23200.0)) * 0.95)
    san_gabriel = 195.0 * math.exp(-((d_san_gabriel / 6800.0) ** 2))

    d_east_rim = max(0.0, wx - 37200.0)
    east_rim = 210.0 * _smoothstep(0.0, 3400.0, d_east_rim)

    mtn_sum = (sierra_n + sierra_spine + mojave_ne + coast_range + san_gabriel + east_rim) * basin_clear
    crag = (0.08 * mtn_sum) * (
        0.6 * math.sin(wx * 0.0009 + wy * 0.0007)
        + 0.4 * math.cos(wx * 0.0017 - wy * 0.0014)
    )
    z = (regional_valley_z + dunes + mtn_sum + crag) * coastal_rise

    # Flatten Bakersfield / Necropolis Open-Air Ruined City Basin -> exact Z = 0.0
    nx0, nx1, ny0, ny1 = NECROPOLIS_BASIN_BOUNDS
    dx_nec = 0.0 if nx0 <= wx <= nx1 else (nx0 - wx if wx < nx0 else wx - nx1)
    dy_nec = 0.0 if ny0 <= wy <= ny1 else (ny0 - wy if wy < ny0 else wy - ny1)
    d_nec = math.hypot(dx_nec, dy_nec)
    if d_nec < 3400.0:
        w_nec = _smoothstep(0.0, 3400.0, d_nec)
        z = z * w_nec

    # Flatten Expanded 7-District Adytum / Boneyard Basin -> exact Z = 40.0
    bx0, bx1, by0, by1 = BONEYARD_BASIN_BOUNDS
    dx_bon = 0.0 if bx0 <= wx <= bx1 else (bx0 - wx if wx < bx0 else wx - bx1)
    dy_bon = 0.0 if by0 <= wy <= by1 else (by0 - wy if wy < by0 else wy - by1)
    d_bon = math.hypot(dx_bon, dy_bon)
    if d_bon < 2600.0:
        w_bon = _smoothstep(0.0, 2600.0, d_bon)
        z = 40.0 + (z - 40.0) * w_bon

    # Flatten each Settlement / Surface Entrance Plateau LAST with rim-distance priority
    shore_blend = _smoothstep(0.0, 400.0, wx - shore_x)
    locked_pz: float | None = None
    blend_w_sum = 0.0
    blend_pz_sum = 0.0
    max_inf = 0.0
    for px, py, pz, r_flat, r_blend in LOCATION_PLATEAUS:
        d = math.hypot(wx - px, wy - py)
        if d <= r_flat:
            locked_pz = pz * shore_blend
            break
        if d < r_blend:
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
    if d_bon == 0.0:
        z = 40.0

    return z


def verify_world_layout_invariants() -> None:
    """Asserts world bounds, 8.0-step Z heights, coastline dryness, and >= 9,500-unit quest isolation."""
    for key, (ax, ay, az, r_flat, r_blend, _kind) in V13_WORLD_ANCHORS.items():
        assert abs(az % 8.0) < 1e-6, f"{key} Z={az} is not an exact multiple of 8.0!"
        assert WORLD_MIN + 4200.0 <= ax <= WORLD_MAX - 4200.0, f"{key} X too close to world edge: {ax}"
        assert WORLD_MIN + 4200.0 <= ay <= WORLD_MAX - 4200.0, f"{key} Y too close to world edge: {ay}"
        coast_clear = (ax - r_flat) - coastline_x(ay)
        assert coast_clear >= 1200.0, f"{key} plateau overlaps Pacific coastline (clearance={coast_clear:.1f})"
        sampled_z = global_california_height(ax, ay)
        assert abs(sampled_z - az) < 0.01, f"{key} height mismatch: got {sampled_z}, expected {az}"
        # Also verify flatness at 8 perimeter points on r_flat * 0.95
        for k_ang in range(8):
            ang = k_ang * (math.pi / 4.0)
            tx = ax + (r_flat * 0.95) * math.cos(ang)
            ty = ay + (r_flat * 0.95) * math.sin(ang)
            tz = global_california_height(tx, ty)
            assert abs(tz - az) < 0.01, f"{key} rim point ({tx:.0f},{ty:.0f}) not flat: got {tz}, expected {az}"

    keys = list(V13_WORLD_ANCHORS.keys())
    min_dist = 1e9
    min_pair = ("", "")
    for i in range(len(keys)):
        for j in range(i + 1, len(keys)):
            k1, k2 = keys[i], keys[j]
            if k1.startswith("NECROPOLIS_") and k2.startswith("NECROPOLIS_"):
                continue
            x1, y1, *_ = V13_WORLD_ANCHORS[k1]
            x2, y2, *_ = V13_WORLD_ANCHORS[k2]
            dist = math.hypot(x1 - x2, y2 - y1)
            if dist < min_dist:
                min_dist = dist
                min_pair = (k1, k2)
            assert dist >= 9500.0, f"Locations {k1} and {k2} are too close: {dist:.1f} < 9500.0 units!"

    gx, gy, _ = anchor_xyz("THE_GLOW")
    assert gx > 25000.0 and gy < -25000.0, f"THE_GLOW must be in canonical SE corner, got ({gx}, {gy})"

    print(
        f"[OK] v13_world_layout verified: {TOTAL_EXT_CELLS} cells ({CELL_STRIDE}x{CELL_STRIDE}, "
        f"[{WORLD_MIN:.0f}..+{WORLD_MAX:.0f}]), {len(V13_WORLD_ANCHORS)} anchors 100% flat & dry, "
        f"minimum inter-location clearance = {min_dist:.1f} units ({min_pair[0]} <-> {min_pair[1]})."
    )


if __name__ == "__main__":
    verify_world_layout_invariants()
