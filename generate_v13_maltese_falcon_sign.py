"""Generador 3D del letrero del Bar de Decker (El Halcón Maltés / The Maltese Falcon).

Toma el NIF vanilla `Meshes\\Architecture\\DiamondCity\\Signs\\DiamondSignColonial01.nif` desde
`Fallout4 - Meshes.ba2`, conserva intactos el marco de rombo doble, la chapa trasera, la viga en I,
los pernos, los materiales `.bgsm` y la colisión Havok (`bhkPhysicsSystem`), y sustituye únicamente
las letras recortadas en relieve de ambos lados por:
  - Edición ES: "HALCÓN" / "MALTÉS"
  - Edición EN: "MALTESE" / "FALCON"

Uso directo:
    python generate_v13_maltese_falcon_sign.py
"""

from __future__ import annotations

import math
import struct
import zlib
from collections import defaultdict, deque
from pathlib import Path
from typing import Iterable

from fontTools.pens.recordingPen import DecomposingRecordingPen
from fontTools.ttLib import TTFont

THIS_DIR = Path(__file__).resolve().parent
SIGNS_OUT_DIR = THIS_DIR / "assets" / "meshes" / "v13chronicles" / "signs"
ES_NIF_PATH = SIGNS_OUT_DIR / "V13SignMalteseFalcon01_ES.nif"
EN_NIF_PATH = SIGNS_OUT_DIR / "V13SignMalteseFalcon01_EN.nif"

DEFAULT_FO4_MESHES_BA2 = [
    Path(r"C:\Program Files (x86)\Steam\steamapps\common\Fallout 4\Data\Fallout4 - Meshes.ba2"),
    Path(r"D:\SteamLibrary\steamapps\common\Fallout 4\Data\Fallout4 - Meshes.ba2"),
    Path(r"C:\Games\Fallout 4\Data\Fallout4 - Meshes.ba2"),
]

DEFAULT_FONT_PATHS = [
    Path(r"C:\Windows\Fonts\ROCKB.TTF"),
    Path(r"C:\Windows\Fonts\ROCK.TTF"),
    Path(r"C:\Windows\Fonts\arialbd.ttf"),
]

DIAMOND_SIGN_CENTER_X = -2.0
DIAMOND_SIGN_TILT_DEG = 4.2  # Caída izquierda->derecha fiel al rombo asimétrico original
FRONT_CAP_Y = -9.17
FRONT_BACK_Y = -7.16
BACK_ATTACH_Y = 3.16
BACK_CAP_Y = 5.18


def find_meshes_ba2() -> Path:
    for cand in DEFAULT_FO4_MESHES_BA2:
        if cand.exists():
            return cand
    raise FileNotFoundError("No se encontró Fallout4 - Meshes.ba2 en las rutas estándar.")


def find_sign_font() -> Path:
    for cand in DEFAULT_FONT_PATHS:
        if cand.exists():
            return cand
    raise FileNotFoundError("No se encontró fuente tipográfica adecuada (ROCKB.TTF / arialbd.ttf).")


def _f16(val: float) -> float:
    return struct.unpack("<e", struct.pack("<e", val))[0]


def extract_vanilla_colonial_sign_nif() -> bytes:
    ba2_path = find_meshes_ba2()
    target = "meshes\\architecture\\diamondcity\\signs\\diamondsigncolonial01.nif"
    with open(ba2_path, "rb") as f:
        magic, _ver, _typ = struct.unpack("<4sI4s", f.read(12))
        if magic != b"BTDX":
            raise ValueError(f"BA2 inválido: {magic!r}")
        num_files, name_off = struct.unpack("<IQ", f.read(12))
        entries = [struct.unpack("<I4sIIQIII", f.read(36)) for _ in range(num_files)]
        f.seek(name_off)
        for idx in range(num_files):
            nlen = struct.unpack("<H", f.read(2))[0]
            name = f.read(nlen).decode("utf-8", "replace").lower().replace("/", "\\")
            if name == target:
                _, _, _, _, off, psize, usize, _ = entries[idx]
                f.seek(off)
                raw = f.read(psize if psize else usize)
                return zlib.decompress(raw) if psize else raw
    raise FileNotFoundError(f"No se encontró {target} dentro de {ba2_path}")


# ---------------------------------------------------------------------------
# Geometría 2D de fuentes TrueType + puenteo de huecos + ear clipping
# ---------------------------------------------------------------------------

def _eval_quad(p0, p1, p2, t: float) -> tuple[float, float]:
    mt = 1.0 - t
    return (
        mt * mt * p0[0] + 2.0 * mt * t * p1[0] + t * t * p2[0],
        mt * mt * p0[1] + 2.0 * mt * t * p1[1] + t * t * p2[1],
    )


def _eval_cubic(p0, p1, p2, p3, t: float) -> tuple[float, float]:
    mt = 1.0 - t
    return (
        mt**3 * p0[0] + 3.0 * mt**2 * t * p1[0] + 3.0 * mt * t**2 * p2[0] + t**3 * p3[0],
        mt**3 * p0[1] + 3.0 * mt**2 * t * p1[1] + 3.0 * mt * t**2 * p2[1] + t**3 * p3[1],
    )


def _signed_area(pts: list[tuple[float, float]]) -> float:
    area = 0.0
    n = len(pts)
    for i in range(n):
        x0, y0 = pts[i]
        x1, y1 = pts[(i + 1) % n]
        area += x0 * y1 - x1 * y0
    return 0.5 * area


def _point_in_poly(pt: tuple[float, float], poly: list[tuple[float, float]]) -> bool:
    x, y = pt
    inside = False
    n = len(poly)
    for i in range(n):
        x0, y0 = poly[i]
        x1, y1 = poly[(i + 1) % n]
        if ((y0 > y) != (y1 > y)) and (x < (x1 - x0) * (y - y0) / (y1 - y0 + 1e-18) + x0):
            inside = not inside
    return inside


def _dedup_ring(pts: list[tuple[float, float]], eps: float = 0.45) -> list[tuple[float, float]]:
    out: list[tuple[float, float]] = []
    for p in pts:
        if not out or math.hypot(p[0] - out[-1][0], p[1] - out[-1][1]) > eps:
            out.append(p)
    if len(out) >= 2 and math.hypot(out[0][0] - out[-1][0], out[0][1] - out[-1][1]) <= eps:
        out.pop()
    # Eliminar puntos prácticamente colineales para evitar astillas degeneradas tras cuantizar a float16
    cleaned: list[tuple[float, float]] = []
    n = len(out)
    for i in range(n):
        a = out[(i - 1) % n]
        b = out[i]
        c = out[(i + 1) % n]
        ab = math.hypot(b[0] - a[0], b[1] - a[1])
        bc = math.hypot(c[0] - b[0], c[1] - b[1])
        cross = abs((b[0] - a[0]) * (c[1] - b[1]) - (b[1] - a[1]) * (c[0] - b[0]))
        if ab < 1e-6 or bc < 1e-6:
            continue
        sin_ang = cross / (ab * bc)
        if sin_ang > 0.03 or ab > 4.0:
            cleaned.append(b)
    return cleaned if len(cleaned) >= 3 else out


def _flatten_pen_contours(ops: list[tuple[str, tuple]], curve_steps: int = 4) -> list[list[tuple[float, float]]]:
    contours: list[list[tuple[float, float]]] = []
    cur_ring: list[tuple[float, float]] = []
    cur_pt = (0.0, 0.0)

    for op, args in ops:
        if op == "moveTo":
            if len(cur_ring) >= 3:
                ded = _dedup_ring(cur_ring, eps=1.0)
                if len(ded) >= 3 and abs(_signed_area(ded)) > 1.0:
                    contours.append(ded)
            cur_pt = tuple(args[0])
            cur_ring = [cur_pt]
        elif op == "lineTo":
            cur_pt = tuple(args[0])
            cur_ring.append(cur_pt)
        elif op == "qCurveTo":
            pts = list(args)
            if pts and pts[-1] is None:
                n = len(pts) - 1
                qpts = pts[:-1]
                start = ((qpts[-1][0] + qpts[0][0]) * 0.5, (qpts[-1][1] + qpts[0][1]) * 0.5)
                cur_ring = [start]
                cur_pt = start
                for idx in range(n):
                    ctrl = qpts[idx]
                    nxt = qpts[(idx + 1) % n]
                    end = ((ctrl[0] + nxt[0]) * 0.5, (ctrl[1] + nxt[1]) * 0.5)
                    for s in range(1, curve_steps + 1):
                        cur_ring.append(_eval_quad(cur_pt, ctrl, end, s / curve_steps))
                    cur_pt = end
            else:
                i = 0
                while i < len(pts):
                    if i == len(pts) - 1:
                        cur_pt = tuple(pts[i])
                        cur_ring.append(cur_pt)
                        break
                    ctrl = pts[i]
                    if i + 1 == len(pts) - 1:
                        end = pts[i + 1]
                        i += 2
                    else:
                        end = ((ctrl[0] + pts[i + 1][0]) * 0.5, (ctrl[1] + pts[i + 1][1]) * 0.5)
                        i += 1
                    for s in range(1, curve_steps + 1):
                        cur_ring.append(_eval_quad(cur_pt, ctrl, end, s / curve_steps))
                    cur_pt = tuple(end)
        elif op == "curveTo":
            p1, p2, p3 = args
            for s in range(1, curve_steps + 1):
                cur_ring.append(_eval_cubic(cur_pt, p1, p2, p3, s / curve_steps))
            cur_pt = tuple(p3)
        elif op in ("closePath", "endPath"):
            if len(cur_ring) >= 3:
                ded = _dedup_ring(cur_ring, eps=1.0)
                if len(ded) >= 3 and abs(_signed_area(ded)) > 1.0:
                    contours.append(ded)
            cur_ring = []

    if len(cur_ring) >= 3:
        ded = _dedup_ring(cur_ring, eps=1.0)
        if len(ded) >= 3 and abs(_signed_area(ded)) > 1.0:
            contours.append(ded)
    return contours


def _seg_intersect(a, b, c, d) -> bool:
    def orient(p, q, r):
        return (q[0] - p[0]) * (r[1] - p[1]) - (q[1] - p[1]) * (r[0] - p[0])

    o1, o2 = orient(a, b, c), orient(a, b, d)
    o3, o4 = orient(c, d, a), orient(c, d, b)
    return (o1 > 1e-9 and o2 < -1e-9 or o1 < -1e-9 and o2 > 1e-9) and (
        o3 > 1e-9 and o4 < -1e-9 or o3 < -1e-9 and o4 > 1e-9
    )


def _bridge_hole_into_outer(
    outer: list[tuple[float, float]], hole: list[tuple[float, float]]
) -> list[tuple[float, float]]:
    """Conecta un hueco interior (CW) al contorno exterior (CCW) por una diagonal visible."""
    if _signed_area(outer) < 0:
        outer = list(reversed(outer))
    if _signed_area(hole) > 0:
        hole = list(reversed(hole))

    h_idx = max(range(len(hole)), key=lambda i: (hole[i][0], -hole[i][1]))
    M = hole[h_idx]

    best_x = float("inf")
    best_edge = None
    n_o = len(outer)
    for i in range(n_o):
        a = outer[i]
        b = outer[(i + 1) % n_o]
        if (a[1] > M[1]) != (b[1] > M[1]):
            t = (M[1] - a[1]) / (b[1] - a[1])
            ix = a[0] + t * (b[0] - a[0])
            if ix >= M[0] - 1e-6 and ix < best_x:
                best_x = ix
                best_edge = i
        elif abs(a[1] - M[1]) <= 1e-6 and a[0] >= M[0] - 1e-6 and a[0] < best_x:
            best_x = a[0]
            best_edge = i

    cand_indices: list[int] = []
    if best_edge is not None:
        a_i = best_edge
        b_i = (best_edge + 1) % n_o
        p_idx = a_i if outer[a_i][0] >= outer[b_i][0] else b_i
        cand_indices.append(p_idx)
        for idx in range(n_o):
            if outer[idx][0] >= M[0] - 1e-5 and idx not in cand_indices:
                cand_indices.append(idx)
    else:
        cand_indices = list(range(n_o))

    chosen_idx = cand_indices[0]
    best_score = float("inf")
    all_edges = [(outer[i], outer[(i + 1) % n_o]) for i in range(n_o)] + [
        (hole[i], hole[(i + 1) % len(hole)]) for i in range(len(hole))
    ]
    for idx in cand_indices:
        V = outer[idx]
        blocked = False
        for e0, e1 in all_edges:
            if e0 == V or e1 == V or e0 == M or e1 == M:
                continue
            if _seg_intersect(M, V, e0, e1):
                blocked = True
                break
        if not blocked:
            dist = math.hypot(V[0] - M[0], V[1] - M[1])
            if dist < best_score:
                best_score = dist
                chosen_idx = idx
            if idx == cand_indices[0]:
                break

    reordered_hole = hole[h_idx:] + hole[:h_idx]
    return outer[: chosen_idx + 1] + reordered_hole + [hole[h_idx], outer[chosen_idx]] + outer[chosen_idx + 1 :]


def _triangulate_simple_ccw(poly: list[tuple[float, float]]) -> list[tuple[int, int, int]]:
    """Ear clipping eligiendo siempre la oreja de mejor calidad angular."""
    if _signed_area(poly) < 0:
        raise ValueError("Se esperaba polígono CCW positivo para ear clipping.")
    n = len(poly)
    if n < 3:
        return []
    if n == 3:
        return [(0, 1, 2)]

    def cross(a, b, c) -> float:
        return (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])

    def pt_in_tri(p, a, b, c) -> bool:
        c1 = cross(a, b, p)
        c2 = cross(b, c, p)
        c3 = cross(c, a, p)
        return c1 >= -1e-7 and c2 >= -1e-7 and c3 >= -1e-7

    rem = list(range(n))
    tris: list[tuple[int, int, int]] = []
    guard = 0
    while len(rem) > 3 and guard < n * n * 2:
        guard += 1
        m = len(rem)
        best_pos = -1
        best_quality = -1.0
        for pos in range(m):
            i0 = rem[(pos - 1) % m]
            i1 = rem[pos]
            i2 = rem[(pos + 1) % m]
            a, b, c = poly[i0], poly[i1], poly[i2]
            cr = cross(a, b, c)
            if cr <= 1e-7:
                continue
            contains_other = False
            for j in rem:
                if j in (i0, i1, i2):
                    continue
                pj = poly[j]
                if (abs(pj[0] - a[0]) < 1e-6 and abs(pj[1] - a[1]) < 1e-6) or (
                    abs(pj[0] - b[0]) < 1e-6 and abs(pj[1] - b[1]) < 1e-6
                ) or (abs(pj[0] - c[0]) < 1e-6 and abs(pj[1] - c[1]) < 1e-6):
                    continue
                if pt_in_tri(pj, a, b, c):
                    contains_other = True
                    break
            if not contains_other:
                p_len = (
                    math.hypot(b[0] - a[0], b[1] - a[1])
                    + math.hypot(c[0] - b[0], c[1] - b[1])
                    + math.hypot(a[0] - c[0], a[1] - c[1])
                )
                quality = cr / (p_len * p_len + 1e-12)
                if quality > best_quality:
                    best_quality = quality
                    best_pos = pos
        if best_pos >= 0:
            i0 = rem[(best_pos - 1) % m]
            i1 = rem[best_pos]
            i2 = rem[(best_pos + 1) % m]
            tris.append((i0, i1, i2))
            rem.pop(best_pos)
        else:
            break
    if len(rem) == 3 and cross(poly[rem[0]], poly[rem[1]], poly[rem[2]]) > 1e-6:
        tris.append((rem[0], rem[1], rem[2]))
    return tris


def _build_layout_polys(
    lines: list[str], tt: TTFont
) -> tuple[list[list[tuple[float, float]]], list[tuple[list[tuple[float, float]], list[tuple[int, int, int]]]]]:
    cmap = tt.getBestCmap()
    gset = tt.getGlyphSet()
    hmtx = tt["hmtx"].metrics
    kern_sub = tt["kern"].getkern(0) if "kern" in tt else None
    kern_tbl = kern_sub.kernTable if kern_sub is not None else {}

    # Dos líneas centradas con amplio margen dentro del rombo interior (Z ~ 261..375, X ~ -106..+102)
    raw_lines_specs = [
        {"text": lines[0], "target_h": 21.0, "max_w": 116.0, "y_offset_z": 324.0},
        {"text": lines[1], "target_h": 21.0, "max_w": 122.0, "y_offset_z": 286.0},
    ]

    tilt_rad = math.radians(DIAMOND_SIGN_TILT_DEG)
    cos_t = math.cos(tilt_rad)
    sin_t = math.sin(tilt_rad)

    all_wall_rings: list[list[tuple[float, float]]] = []
    cap_meshes: list[tuple[list[tuple[float, float]], list[tuple[int, int, int]]]] = []

    ref_glyph = cmap.get(ord("H"))
    ref_pen = DecomposingRecordingPen(gset)
    gset[ref_glyph].draw(ref_pen)
    ref_contours = _flatten_pen_contours(ref_pen.value, curve_steps=4)
    ref_zs = [pt[1] for ring in ref_contours for pt in ring]
    ref_cap_h = max(ref_zs) - min(ref_zs)

    for spec in raw_lines_specs:
        txt = spec["text"]
        pen_advance_x = 0.0
        line_shapes: list[list[list[tuple[float, float]]]] = []
        all_xs: list[float] = []

        prev_g = None
        for ch in txt:
            gname = cmap.get(ord(ch))
            if prev_g is not None and (prev_g, gname) in kern_tbl:
                pen_advance_x += kern_tbl[(prev_g, gname)]
            if ch != " ":
                pen = DecomposingRecordingPen(gset)
                gset[gname].draw(pen)
                contours = _flatten_pen_contours(pen.value, curve_steps=4)
                shifted = [[(pt[0] + pen_advance_x, pt[1]) for pt in ring] for ring in contours]
                line_shapes.append(shifted)
                for ring in shifted:
                    for x, _y in ring:
                        all_xs.append(x)
            adv_w, _ = hmtx[gname]
            pen_advance_x += adv_w * 0.96
            prev_g = gname

        min_x, max_x = min(all_xs), max(all_xs)
        raw_w = max_x - min_x
        scale_z = spec["target_h"] / ref_cap_h
        scale_x = min(scale_z * 0.88, spec["max_w"] / raw_w)
        cx_raw = 0.5 * (min_x + max_x)

        for glyph_rings in line_shapes:
            tr_rings: list[list[tuple[float, float]]] = []
            for ring in glyph_rings:
                pts_xz = []
                for px, pz in ring:
                    lx = (px - cx_raw) * scale_x
                    lz = pz * scale_z
                    rx = _f16(DIAMOND_SIGN_CENTER_X + lx * cos_t + lz * sin_t)
                    rz = _f16(spec["y_offset_z"] - lx * sin_t + lz * cos_t)
                    pts_xz.append((rx, rz))
                pts_xz = _dedup_ring(pts_xz, eps=0.55)
                if len(pts_xz) >= 3 and abs(_signed_area(pts_xz)) > 0.25:
                    tr_rings.append(pts_xz)

            n_r = len(tr_rings)
            depths = [0] * n_r
            parents = [-1] * n_r
            for i in range(n_r):
                probe = tr_rings[i][0]
                best_parent_area = float("inf")
                for j in range(n_r):
                    if i == j:
                        continue
                    if _point_in_poly(probe, tr_rings[j]):
                        depths[i] += 1
                        aj = abs(_signed_area(tr_rings[j]))
                        if aj < best_parent_area:
                            best_parent_area = aj
                            parents[i] = j

            holes_by_outer: dict[int, list[int]] = defaultdict(list)
            outers: list[int] = []
            for i in range(n_r):
                if depths[i] % 2 == 0:
                    outers.append(i)
                else:
                    holes_by_outer[parents[i]].append(i)

            for oi in outers:
                outer = list(tr_rings[oi])
                if _signed_area(outer) < 0:
                    outer.reverse()
                all_wall_rings.append(outer)

                merged = list(outer)
                for hi in holes_by_outer[oi]:
                    hole = list(tr_rings[hi])
                    if _signed_area(hole) > 0:
                        hole.reverse()
                    all_wall_rings.append(hole)
                    merged = _bridge_hole_into_outer(merged, hole)

                tris = _triangulate_simple_ccw(merged)
                if tris:
                    cap_meshes.append((merged, tris))

    return all_wall_rings, cap_meshes


# ---------------------------------------------------------------------------
# Empaquetado binario NIF FO4 BSTriShape (vf=0x0001b00000430205)
# ---------------------------------------------------------------------------

def _pack_u8_dir(val: float) -> int:
    return max(0, min(255, int(round((val + 1.0) * 127.5))))


def _pack_vertex_fo4(
    x: float,
    y: float,
    z: float,
    u: float,
    v: float,
    normal: tuple[float, float, float],
    tangent: tuple[float, float, float],
    bitangent: tuple[float, float, float],
) -> bytes:
    nx, ny, nz = normal
    tx, ty, tz = tangent
    bx, by, bz = bitangent
    return struct.pack(
        "<4e2e4B4B",
        x,
        y,
        z,
        bx,
        u,
        v,
        _pack_u8_dir(nx),
        _pack_u8_dir(ny),
        _pack_u8_dir(nz),
        _pack_u8_dir(by),
        _pack_u8_dir(tx),
        _pack_u8_dir(ty),
        _pack_u8_dir(tz),
        _pack_u8_dir(bz),
    )


def _compute_bounding_sphere(pts: Iterable[tuple[float, float, float]]) -> tuple[float, float, float, float]:
    pts_list = list(pts)
    xs = [p[0] for p in pts_list]
    ys = [p[1] for p in pts_list]
    zs = [p[2] for p in pts_list]
    cx = 0.5 * (min(xs) + max(xs))
    cy = 0.5 * (min(ys) + max(ys))
    cz = 0.5 * (min(zs) + max(zs))
    rad = max(math.sqrt((p[0] - cx) ** 2 + (p[1] - cy) ** 2 + (p[2] - cz) ** 2) for p in pts_list)
    return (cx, cy, cz, rad)


def _mirror_ring_x(ring: list[tuple[float, float]], cx: float = DIAMOND_SIGN_CENTER_X) -> list[tuple[float, float]]:
    return [(_f16(2.0 * cx - x), z) for x, z in ring]


def build_caps_block4_payload(
    template_block4: bytes,
    cap_meshes: list[tuple[list[tuple[float, float]], list[tuple[int, int, int]]]],
) -> tuple[bytes, list[tuple[float, float, float]]]:
    v_bytes = bytearray()
    t_bytes = bytearray()
    all_pts: list[tuple[float, float, float]] = []
    v_count = 0
    t_count = 0

    def map_uv_cap(x: float, z: float) -> tuple[float, float]:
        u = max(0.03, min(0.97, 0.5 + (x - DIAMOND_SIGN_CENTER_X) / 180.0))
        v = max(0.53, min(0.76, 0.645 + (320.0 - z) / 420.0))
        return u, v

    n_front = (0.0, -1.0, 0.0)
    t_front = (-0.333, 0.0, -0.943)
    b_front = (0.943, 0.0, -0.333)
    yf = _f16(FRONT_CAP_Y)
    for poly, tris in cap_meshes:
        base_idx = v_count
        q_poly = [(_f16(x), _f16(z)) for x, z in poly]
        for x, z in q_poly:
            u, v = map_uv_cap(x, z)
            v_bytes.extend(_pack_vertex_fo4(x, yf, z, u, v, n_front, t_front, b_front))
            all_pts.append((x, yf, z))
            v_count += 1
        for i0, i1, i2 in tris:
            p0, p1, p2 = q_poly[i0], q_poly[i1], q_poly[i2]
            area2 = (p1[0] - p0[0]) * (p2[1] - p0[1]) - (p1[1] - p0[1]) * (p2[0] - p0[0])
            if abs(area2) <= 1e-5:
                continue  # Colineal exacto tras cuantización float16
            if area2 < 0:
                i1, i2 = i2, i1
            t_bytes.extend(struct.pack("<3H", base_idx + i0, base_idx + i1, base_idx + i2))
            t_count += 1

    n_back = (0.0, 1.0, 0.0)
    t_back = (0.333, 0.0, -0.943)
    b_back = (-0.943, 0.0, -0.333)
    yb = _f16(BACK_CAP_Y)
    for poly, tris in cap_meshes:
        mpoly = [(_f16(x), _f16(z)) for x, z in _mirror_ring_x(poly)]
        base_idx = v_count
        for x, z in mpoly:
            u, v = map_uv_cap(x, z)
            v_bytes.extend(_pack_vertex_fo4(x, yb, z, u, v, n_back, t_back, b_back))
            all_pts.append((x, yb, z))
            v_count += 1
        for i0, i1, i2 in tris:
            p0, p1, p2 = mpoly[i0], mpoly[i1], mpoly[i2]
            area2 = (p1[0] - p0[0]) * (p2[1] - p0[1]) - (p1[1] - p0[1]) * (p2[0] - p0[0])
            if abs(area2) <= 1e-5:
                continue
            if area2 > 0:
                i1, i2 = i2, i1
            t_bytes.extend(struct.pack("<3H", base_idx + i0, base_idx + i1, base_idx + i2))
            t_count += 1

    dsz = len(v_bytes) + len(t_bytes)
    hdr = bytearray(template_block4[:118])
    cx, cy, cz, rad = _compute_bounding_sphere(all_pts)
    struct.pack_into("<4f", hdr, 72, cx, cy, cz, rad)
    struct.pack_into("<IHI", hdr, 108, t_count, v_count, dsz)
    return bytes(hdr) + bytes(v_bytes) + bytes(t_bytes), all_pts


def _extract_vanilla_frame_components(block8: bytes) -> tuple[list[bytes], list[tuple[int, int, int]], list[tuple[float, float, float]]]:
    nt8, nv8, _ = struct.unpack_from("<IHI", block8, 108)
    vbase = 118
    tbase = 118 + nv8 * 20
    verts_raw = [block8[vbase + i * 20 : vbase + (i + 1) * 20] for i in range(nv8)]
    pos = [struct.unpack_from("<3e", vr, 0) for vr in verts_raw]
    tris = [struct.unpack_from("<3H", block8, tbase + i * 6) for i in range(nt8)]

    adj = defaultdict(set)
    pmap = defaultdict(list)
    for vi, (x, y, z) in enumerate(pos):
        pmap[(round(x, 1), round(y, 1), round(z, 1))].append(vi)
    for grp in pmap.values():
        for a in grp[1:]:
            adj[grp[0]].add(a)
            adj[a].add(grp[0])
    for a, b, c in tris:
        adj[a].update((b, c))
        adj[b].update((a, c))
        adj[c].update((a, b))

    seen = set()
    comps = []
    for vi in range(nv8):
        if vi in seen:
            continue
        q = deque([vi])
        seen.add(vi)
        comp = []
        while q:
            u = q.popleft()
            comp.append(u)
            for w in adj[u]:
                if w not in seen:
                    seen.add(w)
                    q.append(w)
        comps.append(comp)

    comps.sort(key=lambda c: -len(c))
    frame_vset = set(comps[0]) | set(comps[1])
    sorted_old = sorted(frame_vset)
    old_to_new = {old: new for new, old in enumerate(sorted_old)}

    kept_verts = [verts_raw[old] for old in sorted_old]
    kept_pts = [pos[old] for old in sorted_old]
    kept_tris = [
        (old_to_new[a], old_to_new[b], old_to_new[c])
        for a, b, c in tris
        if a in frame_vset and b in frame_vset and c in frame_vset
    ]
    return kept_verts, kept_tris, kept_pts


def build_walls_block8_payload(
    template_block8: bytes,
    wall_rings: list[list[tuple[float, float]]],
) -> tuple[bytes, list[tuple[float, float, float]]]:
    frame_verts_raw, frame_tris, all_pts = _extract_vanilla_frame_components(template_block8)
    v_bytes = bytearray(b"".join(frame_verts_raw))
    t_bytes = bytearray()
    for a, b, c in frame_tris:
        t_bytes.extend(struct.pack("<3H", a, b, c))

    v_count = len(frame_verts_raw)
    t_count = len(frame_tris)

    def append_extruded_rings(rings: list[list[tuple[float, float]]], y0: float, y1: float) -> None:
        nonlocal v_count, t_count
        qy0, qy1 = _f16(y0), _f16(y1)
        for ring in rings:
            qring = [(_f16(p[0]), _f16(p[1])) for p in ring]
            n_pts = len(qring)
            arc_u = 0.0
            for i in range(n_pts):
                p0 = qring[i]
                p1 = qring[(i + 1) % n_pts]
                dx = p1[0] - p0[0]
                dz = p1[1] - p0[1]
                seg_len = math.hypot(dx, dz)
                if seg_len < 0.05:
                    continue
                nx, nz = dz / seg_len, -dx / seg_len
                tx, tz = -dx / seg_len, -dz / seg_len
                normal = (nx, 0.0, nz)
                tangent = (tx, 0.0, tz)
                bitan = (0.0, 1.0, 0.0)

                u0 = 0.22 + (arc_u % 40.0) / 80.0
                u1 = 0.22 + ((arc_u % 40.0) + min(seg_len, 18.0)) / 80.0
                arc_u += seg_len
                v_f, v_b = 0.505, 0.545

                idx = v_count
                pts_q = [
                    (p0[0], qy0, p0[1], u0, v_f),
                    (p0[0], qy1, p0[1], u0, v_b),
                    (p1[0], qy1, p1[1], u1, v_b),
                    (p1[0], qy0, p1[1], u1, v_f),
                ]
                for x, y, z, u, v in pts_q:
                    v_bytes.extend(_pack_vertex_fo4(x, y, z, u, v, normal, tangent, bitan))
                    all_pts.append((x, y, z))
                v_count += 4

                t_bytes.extend(struct.pack("<3H", idx + 0, idx + 1, idx + 2))
                t_bytes.extend(struct.pack("<3H", idx + 0, idx + 2, idx + 3))
                t_count += 2

    append_extruded_rings(wall_rings, FRONT_CAP_Y, FRONT_BACK_Y)

    back_rings: list[list[tuple[float, float]]] = []
    for ring in wall_rings:
        back_rings.append(list(reversed(_mirror_ring_x(ring))))
    append_extruded_rings(back_rings, BACK_ATTACH_Y, BACK_CAP_Y)

    dsz = len(v_bytes) + len(t_bytes)
    hdr = bytearray(template_block8[:118])
    cx, cy, cz, rad = _compute_bounding_sphere(all_pts)
    struct.pack_into("<4f", hdr, 72, cx, cy, cz, rad)
    struct.pack_into("<IHI", hdr, 108, t_count, v_count, dsz)
    return bytes(hdr) + bytes(v_bytes) + bytes(t_bytes), all_pts


def rebuild_nif_with_custom_text(vanilla_nif: bytes, lines: list[str], tt: TTFont) -> tuple[bytes, dict]:
    pos = vanilla_nif.find(b"\n") + 1
    _ver_int, _endian, _u1, nb, _u2 = struct.unpack_from("<IBIII", vanilla_nif, pos)
    pos += 17
    for _ in range(4):
        pos += 1 + vanilla_nif[pos]
    num_btypes = struct.unpack_from("<H", vanilla_nif, pos)[0]
    pos += 2
    for _ in range(num_btypes):
        pos += 4 + struct.unpack_from("<I", vanilla_nif, pos)[0]
    pos += 2 * nb
    bsizes_pos = pos
    bsizes = list(struct.unpack_from(f"<{nb}I", vanilla_nif, bsizes_pos))
    pos += 4 * nb
    num_strs, _max_slen = struct.unpack_from("<II", vanilla_nif, pos)
    pos += 8
    for _ in range(num_strs):
        pos += 4 + struct.unpack_from("<I", vanilla_nif, pos)[0]
    num_groups = struct.unpack_from("<I", vanilla_nif, pos)[0]
    pos += 4 + 4 * num_groups

    data_start = pos
    blocks: list[bytes] = []
    boff = data_start
    for sz in bsizes:
        blocks.append(vanilla_nif[boff : boff + sz])
        boff += sz
    trailing = vanilla_nif[boff:]

    wall_rings, cap_meshes = _build_layout_polys(lines, tt)
    new_b4, pts4 = build_caps_block4_payload(blocks[4], cap_meshes)
    new_b8, pts8 = build_walls_block8_payload(blocks[8], wall_rings)

    blocks[4] = new_b4
    blocks[8] = new_b8
    bsizes[4] = len(new_b4)
    bsizes[8] = len(new_b8)

    out_hdr = bytearray(vanilla_nif[:data_start])
    struct.pack_into(f"<{nb}I", out_hdr, bsizes_pos, *bsizes)
    rebuilt = bytes(out_hdr) + b"".join(blocks) + trailing

    stats = {
        "lines": lines,
        "block4_verts": struct.unpack_from("<H", new_b4, 112)[0],
        "block4_tris": struct.unpack_from("<I", new_b4, 108)[0],
        "block8_verts": struct.unpack_from("<H", new_b8, 112)[0],
        "block8_tris": struct.unpack_from("<I", new_b8, 108)[0],
        "pts4": pts4,
        "pts8": pts8,
        "caps": cap_meshes,
        "blocks": blocks,
    }
    return rebuilt, stats


def _render_preview_png(stats: dict, out_png: Path, title: str) -> None:
    import matplotlib.pyplot as plt
    from matplotlib.patches import Polygon as MplPolygon

    fig, ax = plt.subplots(figsize=(8, 5.2), dpi=140)
    ax.set_facecolor("#1e2022")

    for bidx, col, alpha in [(6, "#3a403a", 0.35), (8, "#6a7b78", 0.5)]:
        b = stats["blocks"][bidx]
        nt, nv, _ = struct.unpack_from("<IHI", b, 108)
        verts = [struct.unpack_from("<3e", b, 118 + i * 20) for i in range(nv)]
        if bidx == 8:
            verts_plot = [(verts[i][0], verts[i][2]) for i in range(min(1056, nv))]
        else:
            verts_plot = [(v[0], v[2]) for v in verts]
        ax.scatter([p[0] for p in verts_plot], [p[1] for p in verts_plot], s=4, c=col, alpha=alpha)

    b4 = stats["blocks"][4]
    nt4, nv4, _ = struct.unpack_from("<IHI", b4, 108)
    verts4 = [struct.unpack_from("<3e", b4, 118 + i * 20) for i in range(nv4)]
    tris4 = [struct.unpack_from("<3H", b4, 118 + nv4 * 20 + i * 6) for i in range(nt4)]
    for i0, i1, i2 in tris4:
        if verts4[i0][1] < 0:  # Solo frente (Y < 0)
            tri_xy = [(verts4[i0][0], verts4[i0][2]), (verts4[i1][0], verts4[i1][2]), (verts4[i2][0], verts4[i2][2])]
            ax.add_patch(MplPolygon(tri_xy, closed=True, facecolor="#d6d0b8", edgecolor="#8d8773", linewidth=0.25))

    ax.set_aspect("equal")
    ax.set_xlim(-132, 128)
    ax.set_ylim(242, 394)
    ax.set_title(title, color="#f0e8d0", fontsize=12)
    ax.tick_params(colors="#a0a0a0")
    fig.tight_layout()
    out_png.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(out_png)
    plt.close(fig)


def ensure_maltese_falcon_sign_nifs(preview_dir: Path | None = None) -> tuple[Path, Path]:
    SIGNS_OUT_DIR.mkdir(parents=True, exist_ok=True)
    vanilla_nif = extract_vanilla_colonial_sign_nif()
    tt = TTFont(str(find_sign_font()))

    es_bytes, es_stats = rebuild_nif_with_custom_text(vanilla_nif, ["HALCÓN", "MALTÉS"], tt)
    ES_NIF_PATH.write_bytes(es_bytes)

    en_bytes, en_stats = rebuild_nif_with_custom_text(vanilla_nif, ["MALTESE", "FALCON"], tt)
    EN_NIF_PATH.write_bytes(en_bytes)

    if preview_dir is not None:
        _render_preview_png(es_stats, preview_dir / "preview_sign_es.png", "ES: HALCÓN MALTÉS")
        _render_preview_png(en_stats, preview_dir / "preview_sign_en.png", "EN: MALTESE FALCON")

    print(
        f"[Sign 3D] ES={ES_NIF_PATH.name} (caps {es_stats['block4_verts']}v/{es_stats['block4_tris']}t, walls+frame {es_stats['block8_verts']}v/{es_stats['block8_tris']}t) | "
        f"EN={EN_NIF_PATH.name} (caps {en_stats['block4_verts']}v/{en_stats['block4_tris']}t, walls+frame {en_stats['block8_verts']}v/{en_stats['block8_tris']}t)"
    )
    return ES_NIF_PATH, EN_NIF_PATH


if __name__ == "__main__":
    scratch = Path(r"C:\Users\educa\.gemini\antigravity\brain\0a71dc6f-ab64-4266-86fa-dad0a7c2d9fc\scratch")
    ensure_maltese_falcon_sign_nifs(preview_dir=scratch)
