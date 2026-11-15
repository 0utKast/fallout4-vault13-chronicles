"""Texture, BC3/DX10 encoder, and BGSM generator for Vault 13 Chronicles v1.2+."""

import io
import os
import struct
import zlib
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter

THIS_DIR = os.path.dirname(os.path.abspath(__file__))
FO4_DATA_DIR = r"C:\Program Files (x86)\Steam\steamapps\common\Fallout 4\Data"

ASSETS_TEX_ES = os.path.join(THIS_DIR, "assets", "textures")
ASSETS_MAT_DIR = os.path.join(THIS_DIR, "assets", "materials")
MON_TEX_DIR = os.path.join(THIS_DIR, "assets", "monuments_3d", "Textures", "V13Chronicles", "Monuments")
MON_MAT_DIR = os.path.join(THIS_DIR, "assets", "monuments_3d", "Materials", "V13Chronicles", "Monuments")


# ---------------------------------------------------------------------------
# Vectorized BC1 & BC3 (DXT5) encoders for arbitrary power-of-2 DDS textures
# ---------------------------------------------------------------------------
def _encode_bc1_blocks(rgb: np.ndarray) -> bytes:
    """Encodes (H, W, 3) uint8 RGB image (H, W >= 4 multiples of 4) to raw BC1 blocks."""
    h, w, _ = rgb.shape
    blocks = rgb.reshape(h // 4, 4, w // 4, 4, 3).transpose(0, 2, 1, 3, 4).reshape(-1, 16, 3).astype(np.float32)

    cmax = blocks.max(axis=1)
    cmin = blocks.min(axis=1)
    r0 = np.clip(np.round(cmax[:, 0] * 31.0 / 255.0), 0, 31).astype(np.uint16)
    g0 = np.clip(np.round(cmax[:, 1] * 63.0 / 255.0), 0, 63).astype(np.uint16)
    b0 = np.clip(np.round(cmax[:, 2] * 31.0 / 255.0), 0, 31).astype(np.uint16)
    c0_565 = (r0 << 11) | (g0 << 5) | b0

    r1 = np.clip(np.round(cmin[:, 0] * 31.0 / 255.0), 0, 31).astype(np.uint16)
    g1 = np.clip(np.round(cmin[:, 1] * 63.0 / 255.0), 0, 63).astype(np.uint16)
    b1 = np.clip(np.round(cmin[:, 2] * 31.0 / 255.0), 0, 31).astype(np.uint16)
    c1_565 = (r1 << 11) | (g1 << 5) | b1

    swap = c0_565 < c1_565
    c0_u = np.where(swap, c1_565, c0_565)
    c1_u = np.where(swap, c0_565, c1_565)
    eq = c0_u == c1_u

    def dec(c: np.ndarray) -> np.ndarray:
        rr = ((c >> 11) & 31) * 255.0 / 31.0
        gg = ((c >> 5) & 63) * 255.0 / 63.0
        bb = (c & 31) * 255.0 / 31.0
        return np.stack([rr, gg, bb], axis=1)

    p0 = dec(c0_u)
    p1 = dec(c1_u)
    p2 = (2.0 * p0 + p1) / 3.0
    p3 = (p0 + 2.0 * p1) / 3.0
    pal = np.stack([p0, p1, p2, p3], axis=1)  # (N, 4, 3)

    dists = ((blocks[:, :, None, :] - pal[:, None, :, :]) ** 2).sum(axis=3)
    idx = np.argmin(dists, axis=2).astype(np.uint32)
    idx = np.where(eq[:, None], 0, idx)

    shifts = (np.arange(16, dtype=np.uint32) * 2)[None, :]
    bits = (idx << shifts).sum(axis=1)

    out = np.empty((len(c0_u), 4), dtype="<u2")
    out[:, 0] = c0_u
    out[:, 1] = c1_u
    out[:, 2] = (bits & 0xFFFF).astype(np.uint16)
    out[:, 3] = ((bits >> 16) & 0xFFFF).astype(np.uint16)
    return out.tobytes()


def _encode_bc3_alpha_blocks(alpha: np.ndarray) -> np.ndarray:
    """Encodes (H, W) uint8 alpha channel to (N, 8) uint8 BC3 alpha blocks."""
    h, w = alpha.shape
    a_blk = alpha.reshape(h // 4, 4, w // 4, 4).transpose(0, 2, 1, 3).reshape(-1, 16).astype(np.int32)
    a0 = a_blk.max(axis=1)
    a1 = a_blk.min(axis=1)

    # Force 8-value interpolation (a0 > a1) when a0 != a1; if a0 == a1, all indices = 0
    span = np.maximum(a0 - a1, 1).astype(np.float32)
    pal = np.stack(
        [
            a0,
            a1,
            np.round((6 * a0 + 1 * a1) / 7.0),
            np.round((5 * a0 + 2 * a1) / 7.0),
            np.round((4 * a0 + 3 * a1) / 7.0),
            np.round((3 * a0 + 4 * a1) / 7.0),
            np.round((2 * a0 + 5 * a1) / 7.0),
            np.round((1 * a0 + 6 * a1) / 7.0),
        ],
        axis=1,
    )  # (N, 8)

    dists = np.abs(a_blk[:, :, None] - pal[:, None, :])
    idx = np.argmin(dists, axis=2).astype(np.uint64)
    idx = np.where((a0 == a1)[:, None], 0, idx)

    bits48 = np.zeros(len(a0), dtype=np.uint64)
    for k in range(16):
        bits48 |= (idx[:, k] & 0x7) << np.uint64(3 * k)

    out = np.empty((len(a0), 8), dtype=np.uint8)
    out[:, 0] = a0.astype(np.uint8)
    out[:, 1] = a1.astype(np.uint8)
    for bi in range(6):
        out[:, 2 + bi] = ((bits48 >> np.uint64(8 * bi)) & np.uint64(0xFF)).astype(np.uint8)
    return out


def encode_bc3_rgba_mips(im_rgba: Image.Image, mips: int) -> bytes:
    """Encodes an RGBA image with power-of-2 dimensions into BC3 (DXT5) mipmaps."""
    cur = im_rgba.convert("RGBA")
    out = bytearray()
    for m in range(mips):
        mw, mh = max(1, cur.width), max(1, cur.height)
        pad_w = max(4, mw)
        pad_h = max(4, mh)
        if cur.size != (pad_w, pad_h):
            # Replicate edge pixels up to 4x4 block for tiny 1x1 / 2x2 mips
            padded = Image.new("RGBA", (pad_w, pad_h))
            src_arr = np.asarray(cur, dtype=np.uint8)
            pad_arr = np.zeros((pad_h, pad_w, 4), dtype=np.uint8)
            for yy in range(pad_h):
                for xx in range(pad_w):
                    pad_arr[yy, xx] = src_arr[min(yy, mh - 1), min(xx, mw - 1)]
            arr = pad_arr
        else:
            arr = np.asarray(cur, dtype=np.uint8)

        ab = _encode_bc3_alpha_blocks(arr[:, :, 3])
        cb = np.frombuffer(_encode_bc1_blocks(arr[:, :, :3]), dtype=np.uint8).reshape(-1, 8)
        merged = np.concatenate([ab, cb], axis=1)
        out.extend(merged.tobytes())
        if m + 1 < mips:
            cur = cur.resize((max(1, cur.width // 2), max(1, cur.height // 2)), Image.Resampling.LANCZOS)
    return bytes(out)


def encode_bc1_rgb_mips(im_rgb: Image.Image, mips: int) -> bytes:
    """Encodes an RGB image into BC1 (DXT1) mipmaps for arbitrary power-of-2 sizes."""
    cur = im_rgb.convert("RGB")
    out = bytearray()
    for m in range(mips):
        mw, mh = max(1, cur.width), max(1, cur.height)
        pad_w, pad_h = max(4, mw), max(4, mh)
        if cur.size != (pad_w, pad_h):
            src_arr = np.asarray(cur, dtype=np.uint8)
            pad_arr = np.zeros((pad_h, pad_w, 3), dtype=np.uint8)
            for yy in range(pad_h):
                for xx in range(pad_w):
                    pad_arr[yy, xx] = src_arr[min(yy, mh - 1), min(xx, mw - 1)]
            arr = pad_arr
        else:
            arr = np.asarray(cur, dtype=np.uint8)
        out.extend(_encode_bc1_blocks(arr))
        if m + 1 < mips:
            cur = cur.resize((max(1, cur.width // 2), max(1, cur.height // 2)), Image.Resampling.LANCZOS)
    return bytes(out)


def write_dx10_dds_file(out_path: str, width: int, height: int, mips: int, dxgi_fmt: int, mips_payload: bytes) -> None:
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    bpp = 16 if dxgi_fmt in (77, 83) else 8
    pitch = max(1, (width + 3) // 4) * bpp
    hdr = b"DDS " + struct.pack(
        "<7I44s9I16s",
        124,
        0x000A1007,
        height,
        width,
        pitch,
        0,
        mips,
        b"\x00" * 44,
        32,
        0x04,
        int.from_bytes(b"DX10", "little"),
        0, 0, 0, 0, 0,
        0x00401008,
        b"\x00" * 16,
    ) + struct.pack("<5I", dxgi_fmt, 3, 0, 1, 0)
    with open(out_path, "wb") as wf:
        wf.write(hdr + mips_payload)


def _extract_fo4_dx10_image(ba2_filename: str, target_rel: str) -> Image.Image:
    ba2_path = os.path.join(FO4_DATA_DIR, ba2_filename)
    tgt = target_rel.lower().replace("/", "\\")
    with open(ba2_path, "rb") as f:
        _m, _v, _bt, n, nt_off = struct.unpack("<4sI4sIQ", f.read(24))
        ents = []
        for _ in range(n):
            eh = f.read(24)
            _nh, _ext, _dh, _u, nchk, _csz, h, w, nm, fmt, _ic = struct.unpack("<I4sIBBHHHBBH", eh)
            chks = [struct.unpack("<QIIHHI", f.read(24)) for _ in range(nchk)]
            ents.append((w, h, nm, fmt, chks))
        f.seek(nt_off)
        raw_nt = f.read()
        pos = 0
        for i in range(n):
            sl = struct.unpack_from("<H", raw_nt, pos)[0]
            pos += 2
            nm_s = raw_nt[pos : pos + sl].decode("latin1", "replace")
            pos += sl
            if nm_s.lower().replace("/", "\\") == tgt:
                w, h, nm, fmt, chks = ents[i]
                parts = []
                for ofs, psz, usz, _sm, _em, _al in chks:
                    f.seek(ofs)
                    rb = f.read(psz if psz > 0 else usz)
                    parts.append(zlib.decompress(rb) if psz > 0 else rb)
                bpp = 16 if fmt in (77, 83) else 8
                hdr = b"DDS " + struct.pack(
                    "<7I44s9I16s",
                    124, 0xA1007, h, w, max(1, (w + 3) // 4) * bpp, 0, nm, b"\x00" * 44,
                    32, 4, int.from_bytes(b"DX10", "little"), 0, 0, 0, 0, 0, 0x401008, b"\x00" * 16,
                ) + struct.pack("<5I", fmt, 3, 0, 1, 0)
                return Image.open(io.BytesIO(hdr + b"".join(parts))).convert("RGBA")
    raise FileNotFoundError(f"Could not find {target_rel} inside {ba2_filename}")


def _extract_fo4_bgsm(target_rel: str) -> bytes:
    ba2_path = os.path.join(FO4_DATA_DIR, "Fallout4 - Materials.ba2")
    tgt = target_rel.lower().replace("\\", "/")
    with open(ba2_path, "rb") as f:
        _m, _v, _bt, n, nt_off = struct.unpack("<4sI4sIQ", f.read(24))
        ents = [struct.unpack("<I4sIIQIII", f.read(36)) for _ in range(n)]
        f.seek(nt_off)
        raw_nt = f.read()
        pos = 0
        for i in range(n):
            sl = struct.unpack_from("<H", raw_nt, pos)[0]
            pos += 2
            nm_s = raw_nt[pos : pos + sl].decode("latin1", "replace").lower().replace("\\", "/")
            pos += sl
            if nm_s == tgt:
                _, _, _, _, off, psz, rsz, _ = ents[i]
                f.seek(off)
                rb = f.read(psz if psz > 0 else rsz)
                return zlib.decompress(rb) if psz > 0 else rb
    raise FileNotFoundError(f"Could not find {target_rel} inside Fallout4 - Materials.ba2")


def _patch_bgsm_textures(
    raw_bgsm: bytes,
    repl_by_slot: dict[int, str],
    two_sided: bool | None = None,
    alpha_blend: bool | None = None,
    alpha_test: bool | None = None,
    alpha_test_ref: int | None = None,
    emit_color: tuple[float, float, float] | None = None,
    emit_mult: float | None = None,
    zbuffer_write: bool | None = None,
    disable_envmap: bool = False,
    glowmap: bool | None = None,
) -> bytes:
    """Patches texture slots (0..8) and optional alpha/emittance flags in a Fallout 4 BGSM v2."""
    hdr = bytearray(raw_bgsm[:63])
    if alpha_blend is not None:
        hdr[32] = 1 if alpha_blend else 0
        struct.pack_into("<II", hdr, 33, 6, 7)
    if alpha_test_ref is not None:
        hdr[41] = alpha_test_ref
    if alpha_test is not None:
        hdr[42] = 1 if alpha_test else 0
    if zbuffer_write is not None:
        hdr[43] = 1 if zbuffer_write else 0
    if two_sided is not None:
        hdr[48] = 1 if two_sided else 0
    if disable_envmap:
        hdr[57] = 0
        struct.pack_into("<f", hdr, 58, 0.0)
    p = 63
    texs = []
    for slot in range(9):
        l = struct.unpack_from("<I", raw_bgsm, p)[0]
        p += 4
        s = raw_bgsm[p : p + l].rstrip(b"\x00").decode("latin1", "replace")
        p += l
        texs.append(repl_by_slot.get(slot, s))

    def lstr(s: str) -> bytes:
        b = (s.encode("ascii") + b"\x00") if s else b"\x00"
        return struct.pack("<I", len(b)) + b

    tex_block = b"".join(lstr(t) for t in texs)
    mid_and_root = bytearray(raw_bgsm[p : p + 64])
    p += 64
    rl = struct.unpack_from("<I", raw_bgsm, p)[0]
    root_bytes = raw_bgsm[p : p + 4 + rl]
    p += 4 + rl
    tail = bytearray(raw_bgsm[p:])
    if emit_color is not None and len(tail) >= 6:
        cur_emit = tail[1]
        if cur_emit == 0:
            new_tail = bytearray()
            new_tail.append(tail[0])
            new_tail.append(1)
            new_tail.extend(struct.pack("<fff", *emit_color))
            rest = bytearray(tail[2:])
            if emit_mult is not None and len(rest) >= 4:
                struct.pack_into("<f", rest, 0, emit_mult)
            new_tail.extend(rest)
            tail = new_tail
        else:
            if len(tail) >= 18:
                struct.pack_into("<fff", tail, 2, *emit_color)
                if emit_mult is not None:
                    struct.pack_into("<f", tail, 14, emit_mult)
    if glowmap is not None and len(tail) >= 27 and tail[1] == 1:
        tail[26] = 1 if glowmap else 0
    return bytes(hdr) + tex_block + bytes(mid_and_root) + root_bytes + bytes(tail)


# ---------------------------------------------------------------------------
# Font & visual helpers
# ---------------------------------------------------------------------------
def _font(name_candidates: tuple[str, ...], size: int) -> ImageFont.FreeTypeFont:
    for fn in name_candidates:
        fp = os.path.join("C:/Windows/Fonts", fn)
        if os.path.isfile(fp):
            try:
                return ImageFont.truetype(fp, size)
            except Exception:
                pass
    return ImageFont.load_default()


def _draw_centered_text_with_tracking(draw: ImageDraw.ImageDraw, cx: float, y: float, text: str, font: ImageFont.FreeTypeFont, fill, stroke_fill=None, stroke_width: int = 0) -> None:
    bbox = draw.textbbox((0, 0), text, font=font, stroke_width=stroke_width)
    tw = bbox[2] - bbox[0]
    draw.text((cx - tw / 2.0 - bbox[0], y), text, font=font, fill=fill, stroke_fill=stroke_fill, stroke_width=stroke_width)


# ---------------------------------------------------------------------------
# 1. Vault 13 Gear Door (81->13) + Welcome Sign (81->13)
# ---------------------------------------------------------------------------
def build_vault13_gear_and_sign_assets(lang: str = "ES", tex_root_dir: str | None = None) -> dict[str, str]:
    """Generates VaultNumber13Gear & VltSignWelcome13 DDS+BGSMs. Returns ba2_key->path."""
    out_tex_root = tex_root_dir or ASSETS_TEX_ES
    sub_tex = os.path.join(out_tex_root, "V13Chronicles", "Vault13Gear")
    sub_mat = os.path.join(ASSETS_MAT_DIR, "V13Chronicles", "Vault13Gear")
    os.makedirs(sub_tex, exist_ok=True)
    os.makedirs(sub_mat, exist_ok=True)

    # A. VaultNumber13Gear_d.dds (256x256 BC3 DXGI 77, 9 mips)
    gear_dds = os.path.join(sub_tex, "VaultNumber13Gear_d.dds")
    base_num_im = _extract_fo4_dx10_image("Fallout4 - Textures4.ba2", "Textures\\interiors\\Vault\\Vault111\\VaultNumber81_d.DDS")
    rng = np.random.default_rng(1313)
    # Build clean charcoal stencil canvas (RGB = 90,89,90, Alpha = 0)
    gear_im = Image.new("RGBA", (256, 256), (90, 89, 90, 0))
    mask = Image.new("L", (256, 256), 0)
    md = ImageDraw.Draw(mask)
    f_num = _font(("impact.ttf", "arialbd.ttf"), 118)
    _draw_centered_text_with_tracking(md, 128.0, 4.0, "13", f_num, fill=255)
    # Weather the stencil edges gently to match Fallout 4 steel paint wear
    m_arr = np.asarray(mask, dtype=np.float32)
    noise = rng.normal(1.0, 0.14, size=(256, 256))
    chips = (rng.uniform(0.0, 1.0, size=(256, 256)) > 0.035).astype(np.float32)
    m_arr = np.clip(m_arr * noise * chips, 0, 255).astype(np.uint8)
    rgb_arr = np.full((256, 256, 3), 89, dtype=np.uint8)
    # Keep slightly lighter warm highlight variation matching vanilla VaultNumber81
    shade = np.clip(89 + rng.normal(0.0, 4.5, size=(256, 256, 1)), 68, 112).astype(np.uint8)
    rgba_arr = np.concatenate([np.repeat(shade, 3, axis=2), m_arr[:, :, None]], axis=2)
    gear_final = Image.fromarray(rgba_arr, "RGBA")
    # Preserve minor corner paint speckles from base outside digit box [50..206, 0..145] if any
    write_dx10_dds_file(gear_dds, 256, 256, 9, 77, encode_bc3_rgba_mips(gear_final, 9))

    # B. VltSignWelcome13_d.dds (1024x256 BC3 DXGI 77, 11 mips)
    sign_dds = os.path.join(sub_tex, "VltSignWelcome13_d.dds")
    # Localized banner text matching exact vanilla bbox [66..883, 37..239]
    banner_txt = "REFUGIO 13" if lang.upper() == "ES" else "VAULT 13"
    sign_mask = Image.new("L", (1024, 256), 0)
    sd = ImageDraw.Draw(sign_mask)
    f_banner = _font(("impact.ttf", "arialbd.ttf"), 172 if lang.upper() == "ES" else 190)
    _draw_centered_text_with_tracking(sd, 480.0, 32.0, banner_txt, f_banner, fill=242)
    sm_arr = np.asarray(sign_mask, dtype=np.float32)
    # Light distress matching weathered Vault steel stencil
    streak = Image.fromarray(rng.uniform(180, 255, (16, 1024)).astype(np.uint8), "L").resize((1024, 256), Image.Resampling.BILINEAR)
    st_arr = np.asarray(streak, dtype=np.float32) / 255.0
    scratches = (rng.uniform(0.0, 1.0, (256, 1024)) > 0.02).astype(np.float32)
    sm_arr = np.clip(sm_arr * st_arr * scratches, 0, 255).astype(np.uint8)
    sign_rgb = np.full((256, 1024, 3), 248, dtype=np.uint8)
    sign_final = Image.fromarray(np.concatenate([sign_rgb, sm_arr[:, :, None]], axis=2), "RGBA")
    write_dx10_dds_file(sign_dds, 1024, 256, 11, 77, encode_bc3_rgba_mips(sign_final, 11))

    # C. Patch vanilla VaultNumber81 & VltSignWelcome03_81 BGSMs losslessly
    gear_bgsm = os.path.join(sub_mat, "VaultNumber13Gear.BGSM")
    raw_gear_bgsm = _extract_fo4_bgsm("materials/interiors/vault/vault111/vaultnumber81.bgsm")
    with open(gear_bgsm, "wb") as wf:
        wf.write(_patch_bgsm_textures(raw_gear_bgsm, {0: "V13Chronicles/Vault13Gear/VaultNumber13Gear_d.dds"}))

    sign_bgsm = os.path.join(sub_mat, "VltSignWelcome13.BGSM")
    raw_sign_bgsm = _extract_fo4_bgsm("materials/interiors/vault/vltsignwelcome03_81.bgsm")
    with open(sign_bgsm, "wb") as wf:
        wf.write(
            _patch_bgsm_textures(
                raw_sign_bgsm,
                {
                    0: "V13Chronicles/Vault13Gear/VltSignWelcome13_d.dds",
                    1: "Interiors/Vault/Vault111/V111Struct01_n.dds",
                    7: "Interiors/Vault/Vault111/V111Struct01_s.dds",
                },
            )
        )

    return {
        "textures\\v13chronicles\\vault13gear\\vaultnumber13gear_d.dds": gear_dds,
        "textures\\v13chronicles\\vault13gear\\vltsignwelcome13_d.dds": sign_dds,
        "materials\\v13chronicles\\vault13gear\\vaultnumber13gear.bgsm": gear_bgsm,
        "materials\\v13chronicles\\vault13gear\\vltsignwelcome13.bgsm": sign_bgsm,
    }


# ---------------------------------------------------------------------------
# 2. Cathedral & Master's Lair Custom Overhaul Textures (1024x1024 BC1)
# ---------------------------------------------------------------------------
def build_cathedral_and_master_textures() -> dict[str, str]:
    os.makedirs(MON_TEX_DIR, exist_ok=True)
    os.makedirs(MON_MAT_DIR, exist_ok=True)
    rng = np.random.default_rng(2161)

    def save_bc1_1024(im: Image.Image, fn: str) -> str:
        out_p = os.path.join(MON_TEX_DIR, fn)
        write_dx10_dds_file(out_p, 1024, 1024, 11, 71, encode_bc1_rgb_mips(im, 11))
        return out_p

    f_big = _font(("georgiab.ttf", "impact.ttf"), 56)
    f_med = _font(("consolab.ttf", "arialbd.ttf"), 32)
    f_sm = _font(("consolab.ttf", "arialbd.ttf"), 22)

    # 1) CathedralBanner_d.dds — Deep Tyrian Purple velvet + Sacred Flame gold chalice & border
    im_b = Image.new("RGB", (1024, 1024), (58, 16, 68))
    db = ImageDraw.Draw(im_b)
    # Velvet weave & subtle vertical shading
    weave = np.asarray(im_b, dtype=np.float32)
    stripe = (np.sin(np.arange(1024)[None, :] * 0.25) * 6.0)[:, :, None]
    grain = rng.normal(0.0, 5.0, (1024, 1024, 1))
    im_b = Image.fromarray(np.clip(weave + stripe + grain, 0, 255).astype(np.uint8), "RGB")
    db = ImageDraw.Draw(im_b)
    gold = (196, 158, 74)
    dark_gold = (122, 92, 38)
    db.rectangle([36, 36, 987, 987], outline=gold, width=12)
    db.rectangle([62, 62, 961, 961], outline=dark_gold, width=4)
    # Sacred Eye of Unity & Atomic Chalice Halo in the upper-center
    cx, cy = 512, 410
    for r in (210, 178, 132):
        db.ellipse([cx - r, cy - r, cx + r, cy + r], outline=gold, width=8 if r != 178 else 4)
    # 8 sacred sunburst rays
    import math
    for i in range(8):
        ang = i * math.pi / 4.0
        db.line([(cx + 138 * math.cos(ang), cy + 138 * math.sin(ang)), (cx + 255 * math.cos(ang), cy + 255 * math.sin(ang))], fill=gold, width=9)
    # Stylized Crimson Sacred Flame tongue in center
    db.polygon([(cx, cy - 115), (cx + 68, cy + 20), (cx + 38, cy + 95), (cx - 38, cy + 95), (cx - 68, cy + 20)], fill=(182, 42, 54), outline=gold)
    db.polygon([(cx, cy - 68), (cx + 34, cy + 28), (cx, cy + 78), (cx - 34, cy + 28)], fill=(232, 168, 56))
    _draw_centered_text_with_tracking(db, 512, 710, "UNITAS", f_big, fill=gold)
    _draw_centered_text_with_tracking(db, 512, 792, "PER IGNEM SACRUM", f_med, fill=(214, 186, 118))
    p_banner = save_bc1_1024(im_b, "CathedralBanner_d.dds")

    # 2) CathedralStainedGlass_d.dds — Gothic stained glass (self-illuminated glow!)
    im_g = Image.new("RGB", (1024, 1024), (16, 18, 28))
    dg = ImageDraw.Draw(im_g)
    # Mosaic tiled stained panes across background
    cols = [(44, 24, 96), (78, 24, 92), (24, 58, 118), (118, 26, 48), (62, 22, 86)]
    for row in range(16):
        for col in range(16):
            c = cols[(row * 5 + col * 3 + int(rng.integers(0, 3))) % len(cols)]
            c = tuple(int(np.clip(v + rng.integers(-12, 14), 10, 220)) for v in c)
            x0, y0 = col * 64, row * 64
            dg.rectangle([x0 + 3, y0 + 3, x0 + 60, y0 + 60], fill=c, outline=(12, 12, 16), width=5)
    # Central luminous Violet & Crimson Rose Mandala
    dg.ellipse([192, 162, 832, 802], fill=(82, 26, 108), outline=(18, 16, 22), width=16)
    for k in range(12):
        a0 = k * 30
        petal_col = (196, 52, 76) if k % 2 == 0 else (106, 62, 198)
        dg.pieslice([232, 202, 792, 762], start=a0, end=a0 + 28, fill=petal_col, outline=(16, 14, 20), width=8)
    dg.ellipse([362, 332, 662, 632], fill=(238, 178, 64), outline=(18, 16, 22), width=14)
    dg.ellipse([432, 402, 592, 562], fill=(255, 228, 152), outline=(120, 38, 28), width=10)
    dg = ImageDraw.Draw(im_g)
    dg.rectangle([0, 0, 1023, 1023], outline=(14, 14, 18), width=26)
    p_glass = save_bc1_1024(im_g, "CathedralStainedGlass_d.dds")

    # 3) CathedralAltarRelief_d.dds — Obsidian marble & gilt Unity relief
    im_a = Image.new("RGB", (1024, 1024), (28, 26, 30))
    da = ImageDraw.Draw(im_a)
    for _ in range(180):
        x0, y0 = rng.integers(0, 1024, 2)
        da.line([(x0, y0), (x0 + int(rng.integers(-140, 140)), y0 + int(rng.integers(-140, 140)))], fill=(44, 40, 48), width=2)
    da.rectangle([48, 48, 975, 975], outline=(156, 126, 64), width=14)
    da.rectangle([76, 76, 947, 947], outline=(98, 76, 38), width=5)
    da.ellipse([332, 160, 692, 520], outline=(176, 142, 70), width=10)
    da.polygon([(512, 190), (632, 340), (512, 490), (392, 340)], outline=(196, 158, 76), fill=(72, 22, 32))
    _draw_centered_text_with_tracking(da, 512, 590, "CATHEDRAL", f_big, fill=(188, 154, 82))
    _draw_centered_text_with_tracking(da, 512, 680, "LA LLAMA SAGRADA // 2161", f_med, fill=(158, 132, 74))
    _draw_centered_text_with_tracking(da, 512, 760, "UNITAS PER EVOLUTIONEM", f_sm, fill=(138, 114, 68))
    p_altar = save_bc1_1024(im_a, "CathedralAltarRelief_d.dds")

    # 4) MasterVaultPlaque_d.dds — Corroded L.A. Demonstration Vault Steel Bulkhead
    im_m = Image.new("RGB", (1024, 1024), (62, 68, 66))
    dm = ImageDraw.Draw(im_m)
    for y in (0, 864):
        dm.rectangle([0, y, 1023, y + 159], fill=(166, 126, 30))
        for off in range(-256, 1280, 96):
            dm.polygon([(off, y), (off + 48, y), (off - 72, y + 159), (off - 120, y + 159)], fill=(28, 28, 26))
    dm.rectangle([32, 180, 991, 840], fill=(48, 54, 52), outline=(140, 146, 136), width=8)
    _draw_centered_text_with_tracking(dm, 512, 240, "VAULT-TEC", f_big, fill=(214, 182, 72))
    _draw_centered_text_with_tracking(dm, 512, 345, "L.A. DEMONSTRATION VAULT", f_med, fill=(184, 198, 188))
    _draw_centered_text_with_tracking(dm, 512, 435, "SUB-LEVEL IV // COMMAND", f_med, fill=(156, 186, 162))
    dm.rectangle([130, 560, 894, 720], fill=(102, 30, 26), outline=(176, 136, 56), width=5)
    _draw_centered_text_with_tracking(dm, 512, 616, "FEV BIOMASS CONTAMINATION", f_med, fill=(224, 212, 186))
    p_plaque = save_bc1_1024(im_m, "MasterVaultPlaque_d.dds")

    # Write BGSMs (reusing vanilla templates so shaders & emissive work cleanly in FO4)
    base_bgsm = _extract_fo4_bgsm("materials/architecture/buildings/churchstonewall01.bgsm")
    emit_bgsm = _extract_fo4_bgsm("materials/animobjects/pipboy/pipboyscreen.bgsm")

    mats = {
        "CathedralBanner": _patch_bgsm_textures(
            base_bgsm,
            {
                0: "V13Chronicles/Monuments/CathedralBanner_d.dds",
                1: "Architecture/Buildings/ChurchStoneWall01_n.dds",
                7: "Architecture/Buildings/ChurchStoneWall01_s.dds",
            },
            two_sided=True,
        ),
        "CathedralStainedGlass": _patch_bgsm_textures(
            emit_bgsm,
            {
                0: "V13Chronicles/Monuments/CathedralStainedGlass_d.dds",
                1: "Architecture/Buildings/ChurchStoneWall01_n.dds",
                7: "Architecture/Buildings/ChurchStoneWall01_s.dds",
            },
            two_sided=True,
            emit_color=(0.82, 0.56, 0.96),
            emit_mult=2.2,
        ),
        "CathedralAltarRelief": _patch_bgsm_textures(
            base_bgsm,
            {
                0: "V13Chronicles/Monuments/CathedralAltarRelief_d.dds",
                1: "Architecture/Buildings/ChurchStoneWall01_n.dds",
                7: "Architecture/Buildings/ChurchStoneWall01_s.dds",
            },
        ),
        "MasterVaultPlaque": _patch_bgsm_textures(
            base_bgsm,
            {
                0: "V13Chronicles/Monuments/MasterVaultPlaque_d.dds",
                1: "Interiors/Vault/Vault111/V111Struct01_n.dds",
                7: "Interiors/Vault/Vault111/V111Struct01_s.dds",
            },
        ),
    }
    for stem, mbytes in mats.items():
        with open(os.path.join(MON_MAT_DIR, f"{stem}.BGSM"), "wb") as wf:
            wf.write(mbytes)

    return {
        "textures\\v13chronicles\\monuments\\cathedralbanner_d.dds": p_banner,
        "textures\\v13chronicles\\monuments\\cathedralstainedglass_d.dds": p_glass,
        "textures\\v13chronicles\\monuments\\cathedralaltarrelief_d.dds": p_altar,
        "textures\\v13chronicles\\monuments\\mastervaultplaque_d.dds": p_plaque,
    }


# ---------------------------------------------------------------------------
# 3. Ending Cinematic 3D Credit Cards (1024x512 BC3 Alpha-Blended Self-Lit)
# ---------------------------------------------------------------------------
CREDIT_CARDS_SPEC = {
    "ES": [
        (
            "CRÓNICAS DEL REFUGIO 13",
            "FALLOUT (1997) EN EL MOTOR DE FALLOUT 4",
            [
                "«La guerra... la guerra no cambia nunca.»",
                "Final del Viaje del Morador del Refugio",
            ],
        ),
        (
            "OBRA ORIGINAL",
            "UNIVERSO FALLOUT (1997) — INTERPLAY PRODUCTIONS",
            [
                "Creado por Tim Cain, Leonard Boyarsky,",
                "Jason Anderson, Christopher Taylor y Brian Fargo",
            ],
        ),
        (
            "DIRECCIÓN Y DESARROLLO DEL MOD",
            "PROYECTO 100% AUTÓNOMO Y DE PERMISOS ABIERTOS",
            [
                "Diseño integral, guión y arquitectura: 0utKast",
                "Motor gráfico, misiones, cinemáticas y 3D en Creation Engine",
            ],
        ),
        (
            "ATRIBUCIÓN DE RECURSOS Y VOCES",
            "OPEN MODDING POLICY — RECONOCIMIENTO EXPLÍCITO",
            [
                "Activos base: Fallout 4 (Bethesda Game Studios)",
                "Banda sonora clásica, foley y doblaje neural ElevenLabs / Qwen3",
            ],
        ),
        (
            "AGRADECIMIENTOS A LA COMUNIDAD",
            "NEXUS MODS Y VETERANOS DEL YERMO CALIFORNIANO",
            [
                "Gracias a todos los Moradores del Refugio",
                "que mantuvieron viva la leyenda desde 1997.",
            ],
        ),
        (
            "«QUIZÁS ALGÚN DÍA...»",
            "EL CAMINO DEL EXILIADO CONTINÚA HACIA ARROYO (2241)",
            [
                "FIN DE LAS CRÓNICAS DEL REFUGIO 13",
                "Mod gratuito • Sin Creation Club • Libre para la comunidad",
            ],
        ),
    ],
    "EN": [
        (
            "VAULT 13 CHRONICLES",
            "CLASSIC FALLOUT (1997) REBUILT IN FALLOUT 4",
            [
                "\"War... war never changes.\"",
                "End of the Vault Dweller's Journey",
            ],
        ),
        (
            "ORIGINAL WORK",
            "FALLOUT (1997) — INTERPLAY PRODUCTIONS",
            [
                "Created by Tim Cain, Leonard Boyarsky,",
                "Jason Anderson, Christopher Taylor & Brian Fargo",
            ],
        ),
        (
            "MOD DIRECTION & DEVELOPMENT",
            "100% STANDALONE • OPEN PERMISSIONS",
            [
                "Lead design, writing & architecture: 0utKast",
                "Quests, interiors, real-time cinematics & custom 3D",
            ],
        ),
        (
            "ASSET & VOICE ATTRIBUTION",
            "OPEN MODDING POLICY — EXPLICIT CREDITS",
            [
                "Base Assets: Fallout 4 (Bethesda Game Studios)",
                "Classic soundtrack, foley & neural voices (ElevenLabs / Qwen3)",
            ],
        ),
        (
            "COMMUNITY ACKNOWLEDGMENTS",
            "NEXUS MODS & VETERANS OF NEW CALIFORNIA",
            [
                "Dedicated to every Vault Dweller who",
                "walked the Wasteland since 1997.",
            ],
        ),
        (
            "\"PERHAPS SOMEDAY...\"",
            "THE EXILE'S TRAIL LEADS NORTH TO ARROYO (2241)",
            [
                "END OF VAULT 13 CHRONICLES",
                "100% Free • Zero Creation Club • Open to the Community",
            ],
        ),
    ],
}


def build_ending_credit_cards(lang: str = "ES", tex_root_dir: str | None = None) -> dict[str, str]:
    """Builds 6 crisp cinema-overlay 1024x512 BC3 credit cards + self-lit alpha BGSMs."""
    out_tex_root = tex_root_dir or ASSETS_TEX_ES
    sub_tex = os.path.join(out_tex_root, "V13Chronicles", "Credits")
    sub_mat = os.path.join(ASSETS_MAT_DIR, "V13Chronicles", "Credits")
    os.makedirs(sub_tex, exist_ok=True)
    os.makedirs(sub_mat, exist_ok=True)

    cards = CREDIT_CARDS_SPEC["ES" if lang.upper() == "ES" else "EN"]

    def _fit(cands: tuple[str, ...], start_sz: int, txt: str, sw: int, max_w: float = 840.0) -> ImageFont.FreeTypeFont:
        tmp = ImageDraw.Draw(Image.new("RGBA", (1, 1)))
        for sz in range(start_sz, 16, -2):
            f = _font(cands, sz)
            bb = tmp.textbbox((0, 0), txt, font=f, stroke_width=sw)
            if (bb[2] - bb[0]) <= max_w:
                return f
        return _font(cands, 16)

    emit_tpl = _extract_fo4_bgsm("materials/architecture/diamondcity/diamondsigns01alphaflatglow.bgsm")
    out_map: dict[str, str] = {}

    for idx, (title, subtitle, lines) in enumerate(cards, 1):
        # Crisp AlphaTest rounded cinema placard (alpha=255 inside, alpha=0 outside)
        alpha = Image.new("L", (1024, 512), 0)
        ad = ImageDraw.Draw(alpha)
        ad.rounded_rectangle([56, 40, 968, 472], radius=28, fill=255)

        rgb = Image.new("RGB", (1024, 512), (12, 11, 10))
        rgba = Image.merge("RGBA", (*rgb.split(), alpha))
        dr = ImageDraw.Draw(rgba)
        dr.rounded_rectangle([62, 46, 962, 466], radius=24, outline=(210, 165, 70, 255), width=3)

        gold = (242, 202, 108, 255)
        amber = (224, 172, 74, 255)
        cream = (246, 240, 224, 255)
        shadow = (0, 0, 0, 255)

        f_hdr = _fit(("georgiab.ttf", "arialbd.ttf"), 56, title, 3, max_w=820.0)
        f_sub = _fit(("consolab.ttf", "arialbd.ttf"), 30, subtitle, 2, max_w=830.0)

        dr.line([(160, 128), (864, 128)], fill=amber, width=3)
        _draw_centered_text_with_tracking(dr, 512, 56, title, f_hdr, fill=gold, stroke_fill=shadow, stroke_width=3)
        _draw_centered_text_with_tracking(dr, 512, 150, subtitle, f_sub, fill=amber, stroke_fill=shadow, stroke_width=2)
        for li, line in enumerate(lines):
            f_line = _fit(("georgia.ttf", "arial.ttf"), 32, line, 2, max_w=830.0)
            _draw_centered_text_with_tracking(dr, 512, 232 + li * 62, line, f_line, fill=cream, stroke_fill=shadow, stroke_width=2)
        dr.line([(260, 412), (764, 412)], fill=(210, 165, 70, 255), width=2)

        dds_fn = f"V13CreditCard{idx:02d}_d.dds"
        dds_path = os.path.join(sub_tex, dds_fn)
        write_dx10_dds_file(dds_path, 1024, 512, 11, 77, encode_bc3_rgba_mips(rgba, 11))

        bgsm_fn = f"V13CreditCard{idx:02d}.BGSM"
        bgsm_path = os.path.join(sub_mat, bgsm_fn)
        with open(bgsm_path, "wb") as wf:
            wf.write(
                _patch_bgsm_textures(
                    emit_tpl,
                    {
                        0: f"V13Chronicles/Credits/{dds_fn}",
                        1: "Shared/FlatFlat_n.dds",
                        2: "interiors/building/bldconcreteceilinggross01_s.dds",
                        4: "",
                        5: f"V13Chronicles/Credits/{dds_fn}",
                        7: "",
                    },
                    two_sided=True,
                    alpha_blend=False,
                    alpha_test=True,
                    alpha_test_ref=64,
                    zbuffer_write=True,
                    disable_envmap=True,
                    emit_color=(1.0, 0.96, 0.88),
                    emit_mult=0.85,
                    glowmap=True,
                )
            )
        out_map[f"textures\\v13chronicles\\credits\\{dds_fn.lower()}"] = dds_path
        out_map[f"materials\\v13chronicles\\credits\\{bgsm_fn.lower()}"] = bgsm_path
    return out_map


def generate_all_overhaul_textures_and_bgsms(lang: str = "ES", tex_root_dir: str | None = None) -> dict[str, str]:
    res = {}
    res.update(build_vault13_gear_and_sign_assets(lang=lang, tex_root_dir=tex_root_dir))
    res.update(build_cathedral_and_master_textures())
    res.update(build_ending_credit_cards(lang=lang, tex_root_dir=tex_root_dir))
    return res


if __name__ == "__main__":
    out = generate_all_overhaul_textures_and_bgsms("ES")
    print(f"[V13 Overhaul Assets ES] Generated {len(out)} files successfully.")
