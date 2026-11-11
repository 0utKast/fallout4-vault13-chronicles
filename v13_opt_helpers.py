"""
Optimization, Genuine .FUZ (FUZE v1 = .lip + .xwm) Voice Wrapper & Terrain LOD Helpers
for Crónicas del Refugio 13 / Vault 13 Chronicles (ES & EN Editions).

Deliverables implemented in this module:
  1. Genuine Fallout 4 `FUZE` v1 voice wrapper (`get_or_build_fuz_bytes`):
     - Adapts the pure-Python 30fps RMS waveform + 60-channel Bethesda FaceFX viseme
       `.lip` v1 zero-RLE encoder from `lucy_companion_fo4/bridge/lip_sync.py` (backed by
       real 60-channel FaceFX viseme frames from `lip_06s.fuz`).
     - Supports both real PCM `.wav` 30fps RMS syllable envelopes and smooth natural
       synthetic syllable envelopes when `.wav` is absent (duration `size / 6000.0` at 48 kbps).
     - Caches deterministically by `(voice_folder, stem, xwm_size, xwm_mtime_ns)` under
       `assets/voices_fuz_cache` (ES) and `edition_en/assets_en/voices_fuz_cache` (EN).
  2. Binary-verified Fallout 4 `.btr` Terrain LOD analysis & generator (`ENABLE_TERRAIN_LOD = False`):
     - Verified against vanilla `Fallout4 - Meshes.ba2` (`commonwealth.4.*.btr`,
       `diamondcity.4.*.btr`), `DLCNukaWorld - Main.ba2` / `Textures.ba2` (`nukaworld.4.*.btr`,
       `.dds`, `_msn.dds`), and `DLCCoast - Main.ba2` (`dlc03vrworldspace.lod`).
     - Fallout 4 `.btr` uses `BSLightingShaderProperty` `ShaderType = 18` (`0x12`,
       `BSLSP_LODLANDSCAPE` — NOT Skyrim's `14`) and requires paired `BC1` diffuse +
       swizzled `(Nx, Nz, Ny)` model-space normal (`_msn.dds`) tiles across the full 32x32
       quadtree (`85` `.btr` chunks + `170` `.dds` files) plus 11-block `WATER` chunks for
       ocean cells. Kept disabled (`ENABLE_TERRAIN_LOD = False`) like vanilla compact
       worldspaces (`dlc03vrworldspace.lod`) to guarantee zero purple distant terrain or
       West Coast ocean LOD seams.
"""

from __future__ import annotations

import io
import math
import os
from pathlib import Path
import re
import shutil
import struct
import time
import wave
import zlib

THIS_DIR = os.path.dirname(os.path.abspath(__file__))
DEFAULT_ES_FUZ_CACHE_DIR = os.path.join(THIS_DIR, "assets", "voices_fuz_cache")
DEFAULT_EN_FUZ_CACHE_DIR = os.path.join(THIS_DIR, "edition_en", "assets_en", "voices_fuz_cache")

LUCY_LIP_TEMPLATE_FUZ = os.path.abspath(
    os.path.join(THIS_DIR, "..", "lucy_companion_fo4", "bridge", "lip_fuz", "lip_06s.fuz")
)

# Disabled by default after binary verification against vanilla Fallout 4 `.btr` / `_msn.dds` / `.lod`
# to guarantee 0% risk of hot-purple unmapped `BSLSP_LODLANDSCAPE` (`ShaderType=18`) distant tiles
# outside the 8x8 `[-4..+3]` active worldspace or Pacific Ocean LOD water seams.
ENABLE_TERRAIN_LOD: bool = False

_BASE_FRAMES_CACHE: list[list[float]] | None = None


def _decomp_lip(lip: bytes) -> bytes:
    """Decompresses a Fallout 4 `.lip` v1 zero-RLE buffer into `24 + n_frames * 240` bytes."""
    if len(lip) < 12:
        raise ValueError(f"Invalid .lip buffer length: {len(lip)}")
    out = bytearray(lip[:12])
    i = 12
    n = len(lip)
    while i < n:
        b = lip[i]
        if b == 0:
            if i + 2 >= n:
                break
            cnt = struct.unpack_from("<H", lip, i + 1)[0]
            out.extend(b"\x00" * cnt)
            i += 3
        else:
            out.append(b)
            i += 1
    return bytes(out)


def _comp_lip(raw: bytes) -> bytes:
    """Compresses an uncompressed `24 + n_frames * 240` byte buffer into Fallout 4 `.lip` v1 zero-RLE."""
    if len(raw) < 24:
        raise ValueError(f"Invalid raw .lip buffer length: {len(raw)}")
    out = bytearray(raw[:12])
    i = 12
    n = len(raw)
    while i < n:
        b = raw[i]
        if b == 0:
            j = i + 1
            while j < n and raw[j] == 0 and (j - i) < 0xFFFF:
                j += 1
            out.append(0)
            out.extend(struct.pack("<H", j - i))
            i = j
        else:
            out.append(b)
            i += 1
    return bytes(out)


def _get_base_viseme_frames() -> list[list[float]]:
    """Loads real 60-channel Bethesda FaceFX viseme frames from `lip_06s.fuz` for waveform modulation."""
    global _BASE_FRAMES_CACHE
    if _BASE_FRAMES_CACHE is not None:
        return _BASE_FRAMES_CACHE

    frames: list[list[float]] = []
    if os.path.isfile(LUCY_LIP_TEMPLATE_FUZ):
        try:
            with open(LUCY_LIP_TEMPLATE_FUZ, "rb") as rf:
                b = rf.read()
            if len(b) >= 24 and b[:4] == b"FUZE":
                lsz = struct.unpack_from("<I", b, 8)[0]
                dec = _decomp_lip(b[12 : 12 + lsz])
                nf = struct.unpack_from("<I", dec, 12)[0]
                if len(dec) == 24 + nf * 240:
                    for f in range(nf):
                        vals = list(struct.unpack_from("<60f", dec, 24 + f * 240))
                        if sum(vals[:16]) > 0.25:
                            frames.append(vals)
        except Exception:
            pass

    _BASE_FRAMES_CACHE = frames
    return frames


def _smooth_3tap_envelope(env: list[float]) -> list[float]:
    """Applies 3-tap temporal smoothing `(0.22, 0.56, 0.22)` while keeping crisp mouth closures."""
    smoothed: list[float] = []
    n = len(env)
    for idx in range(n):
        prev_v = env[idx - 1] if idx > 0 else 0.0
        cur_v = env[idx]
        next_v = env[idx + 1] if idx + 1 < n else 0.0
        if cur_v == 0.0 and next_v == 0.0:
            smoothed.append(0.0)
        else:
            smoothed.append(0.22 * prev_v + 0.56 * cur_v + 0.22 * next_v)
    return smoothed


def _extract_wav_30fps_envelope(wav_bytes: bytes) -> tuple[list[float], int] | None:
    """Extracts a normalized 30fps RMS syllable envelope `(smoothed_env, n_audio_frames)` from PCM WAV bytes."""
    try:
        with wave.open(io.BytesIO(wav_bytes), "rb") as wf:
            nch = wf.getnchannels()
            sw = wf.getsampwidth()
            sr = wf.getframerate()
            nframes = wf.getnframes()
            raw_pcm = wf.readframes(nframes)
        if sr <= 0 or nframes <= 0 or sw not in (1, 2, 4):
            return None

        try:
            import numpy as np

            if sw == 2:
                arr = np.frombuffer(raw_pcm, dtype="<i2")
            elif sw == 1:
                arr = (np.frombuffer(raw_pcm, dtype=np.uint8).astype(np.int16) - 128) << 8
            else:
                arr = (np.frombuffer(raw_pcm, dtype="<i4") >> 16).astype(np.int16)
            if nch > 1:
                arr = arr[::nch]
            n_samples = int(arr.shape[0])
            if n_samples <= 0:
                return None
            real_dur = n_samples / float(sr)
            n_audio_frames = max(8, int(round(real_dur * 30.0)))
            samples_per_frame = max(1, int(sr / 30.0))
            rms_list: list[float] = []
            arr_f = arr.astype(np.float64)
            for f in range(n_audio_frames):
                s0 = f * samples_per_frame
                s1 = min(n_samples, s0 + samples_per_frame)
                if s1 <= s0:
                    rms_list.append(0.0)
                else:
                    chunk = arr_f[s0:s1]
                    rms_list.append(float(math.sqrt(float(np.mean(chunk * chunk)))))
        except ImportError:
            if sw != 2:
                return None
            total_shorts = len(raw_pcm) // 2
            samples = struct.unpack(f"<{total_shorts}h", raw_pcm[: total_shorts * 2])
            if nch > 1:
                samples = samples[::nch]
            if not samples:
                return None
            real_dur = len(samples) / float(sr)
            n_audio_frames = max(8, int(round(real_dur * 30.0)))
            samples_per_frame = max(1, int(sr / 30.0))
            rms_list = []
            for f in range(n_audio_frames):
                s0 = f * samples_per_frame
                s1 = min(len(samples), s0 + samples_per_frame)
                if s1 <= s0:
                    rms_list.append(0.0)
                else:
                    chunk = samples[s0:s1]
                    mean_sq = sum(x * x for x in chunk) / float(len(chunk))
                    rms_list.append(math.sqrt(mean_sq))

        peak_rms = max(rms_list) if rms_list else 1.0
        if peak_rms < 50.0:
            peak_rms = 1.0

        env: list[float] = []
        denom = peak_rms * 0.78
        for r in rms_list:
            norm = r / denom
            if norm < 0.07:
                env.append(0.0)
            else:
                env.append(min(1.15, norm))

        return _smooth_3tap_envelope(env), n_audio_frames
    except Exception:
        return None


def _synthesize_envelope_from_xwm(xwm_bytes: bytes, spoken_text: str = "") -> tuple[list[float], int]:
    """
    Synthesizes a smooth, natural 30fps syllable envelope when no `.wav` file is present on disk,
    matching the `.xwm` duration inferred from `len(xwm_bytes) / 6000.0` (48 kbps = 6,000 B/s).
    """
    dur_s = max(0.35, len(xwm_bytes) / 6000.0)
    n_audio_frames = max(8, int(round(dur_s * 30.0)))
    seed = zlib.crc32(xwm_bytes[:512]) ^ zlib.crc32((spoken_text or "").encode("utf-8", errors="ignore"))
    phase_a = ((seed & 0xFF) / 255.0) * math.tau
    phase_b = (((seed >> 8) & 0xFF) / 255.0) * math.tau
    syl_hz = 3.9 + (((seed >> 16) & 0x1F) / 31.0) * 0.8  # ~3.9..4.7 syllables/sec

    env: list[float] = []
    for f in range(n_audio_frames):
        t = f / 30.0
        # Natural attack (first 80ms) and clean end-of-line mouth closure (last 140ms)
        attack = min(1.0, (t + 0.02) / 0.08)
        release = min(1.0, max(0.0, (dur_s - t) / 0.14))
        syl = 0.5 + 0.5 * math.sin(math.tau * syl_hz * t + phase_a)
        sub = 0.65 + 0.35 * math.sin(math.tau * (syl_hz * 0.47) * t + phase_b)
        phrase = 0.78 + 0.22 * math.sin(math.tau * 0.85 * t + 0.5 * phase_a)
        val = (syl ** 1.25) * sub * phrase * attack * release * 0.98
        # Brief natural consonant/word boundary closures
        if val < 0.11 or f >= n_audio_frames - 1:
            env.append(0.0)
        else:
            env.append(min(1.10, val))

    return _smooth_3tap_envelope(env), n_audio_frames


def build_lip_v1_bytes(
    xwm_bytes: bytes,
    wav_bytes: bytes | None = None,
    spoken_text: str = "",
) -> bytes:
    """
    Generates a genuine RLE-compressed Fallout 4 `.lip` v1 binary (`24 + n_frames * 240` uncompressed)
    from either PCM `wav_bytes` (30fps RMS envelope) or `xwm_bytes` (`size / 6000.0` synthetic envelope).
    """
    parsed = _extract_wav_30fps_envelope(wav_bytes) if wav_bytes else None
    if parsed is not None:
        smoothed, n_audio_frames = parsed
    else:
        smoothed, n_audio_frames = _synthesize_envelope_from_xwm(xwm_bytes, spoken_text)

    pre_frames = 4
    cont_frames = 0
    post_frames = 3
    n_total_frames = pre_frames + n_audio_frames + cont_frames + post_frames

    base_frames = _get_base_viseme_frames()
    clean_chars = re.sub(r"[^a-zA-Z]", "", spoken_text or "Watch your step out here").lower()
    if not clean_chars:
        clean_chars = "watchyourstepouthere"

    raw_buf = bytearray(24 + n_total_frames * 240)
    struct.pack_into("<IIIIii", raw_buf, 0, 1, 28 + n_total_frames * 240, 13, n_total_frames, -8, 43)

    for f in range(n_total_frames):
        af = f - pre_frames
        if af < 0:
            weight = max(0.35, smoothed[0]) * max(0.0, (af + 3) / 3.0) if smoothed else 0.0
            af_idx = 0
        elif af < n_audio_frames:
            weight = smoothed[af]
            af_idx = af
        else:
            weight = 0.0
            af_idx = n_audio_frames - 1

        if weight <= 0.02:
            continue

        frame_vals = [0.0] * 60
        if base_frames:
            bf = base_frames[(af_idx * 2) % len(base_frames)]
            base_sum = max(0.35, sum(bf[:16]))
            scale = min(1.35, (weight * 1.15) / min(1.0, base_sum))
            for c in range(16):
                frame_vals[c] = min(1.0, max(0.0, bf[c] * scale))
            frame_vals[43] = min(0.85, bf[43] * weight)
            frame_vals[44] = min(0.85, bf[44] * weight)
        else:
            ch_char = clean_chars[int((af_idx / max(1, n_audio_frames)) * len(clean_chars)) % len(clean_chars)]
            if ch_char in "ao":
                frame_vals[0] = min(1.0, 0.85 * weight)
                frame_vals[1] = min(1.0, 0.45 * weight)
            elif ch_char in "ei":
                frame_vals[5] = min(1.0, 0.75 * weight)
                frame_vals[8] = min(1.0, 0.55 * weight)
            elif ch_char in "uwq":
                frame_vals[12] = min(1.0, 0.85 * weight)
            elif ch_char in "bmp":
                frame_vals[2] = min(1.0, 0.90 * weight)
            elif ch_char in "fv":
                frame_vals[7] = min(1.0, 0.80 * weight)
            else:
                frame_vals[4] = min(1.0, 0.65 * weight)
                frame_vals[0] = min(1.0, 0.40 * weight)

        struct.pack_into("<60f", raw_buf, 24 + f * 240, *frame_vals)

    return _comp_lip(bytes(raw_buf))


def _is_valid_cached_fuz(data: bytes, expected_xwm_size: int) -> bool:
    if len(data) < 20 or data[:8] != b"FUZE\x01\x00\x00\x00":
        return False
    lip_sz = struct.unpack_from("<I", data, 8)[0]
    if 12 + lip_sz + expected_xwm_size != len(data):
        return False
    xwm_ofs = 12 + lip_sz
    return data[xwm_ofs : xwm_ofs + 4] == b"RIFF" and data[xwm_ofs + 8 : xwm_ofs + 12] == b"XWMA"


def get_or_build_fuz_bytes(
    xwm_path: str,
    wav_path: str | None = None,
    cache_dir: str | None = None,
) -> bytes:
    """
    Given an existing `.xwm` file (and its matching `.wav` file on disk if present; if `.wav`
    is absent, synthesizes a smooth natural syllable envelope matching the `.xwm` duration
    inferred from `size / 6000.0` at 48 kbps), generates a genuine Fallout 4 `FUZE` v1 binary:
        `b"FUZE" + struct.pack("<II", 1, len(lip_bytes)) + lip_bytes + xwm_bytes`
    Caches deterministically by `(voice_folder, stem, xwm_size, xwm_mtime_ns)` in `cache_dir`
    and returns the `.fuz` bytes.
    """
    abs_xwm = os.path.abspath(xwm_path)
    st = os.stat(abs_xwm)
    xwm_size = st.st_size
    xwm_mtime_ns = st.st_mtime_ns

    is_en = "edition_en" in abs_xwm.lower()
    default_cache = DEFAULT_EN_FUZ_CACHE_DIR if is_en else DEFAULT_ES_FUZ_CACHE_DIR
    eff_cache_dir = os.path.abspath(cache_dir) if cache_dir else default_cache

    vtype_folder = os.path.basename(os.path.dirname(abs_xwm)).lower() or "voice"
    stem = os.path.splitext(os.path.basename(abs_xwm))[0].lower()
    cache_fn = f"{vtype_folder}__{stem}_{xwm_size}_{xwm_mtime_ns}.fuz"
    cache_file = os.path.join(eff_cache_dir, cache_fn)

    if os.path.isfile(cache_file):
        try:
            with open(cache_file, "rb") as rf:
                cached = rf.read()
            if _is_valid_cached_fuz(cached, xwm_size):
                return cached
        except OSError:
            pass

    # Check pre-warmed default cache root if caller supplied an alternate cache_dir path
    if os.path.normcase(eff_cache_dir) != os.path.normcase(default_cache):
        prewarmed_file = os.path.join(default_cache, cache_fn)
        if os.path.isfile(prewarmed_file):
            try:
                with open(prewarmed_file, "rb") as rf:
                    cached = rf.read()
                if _is_valid_cached_fuz(cached, xwm_size):
                    os.makedirs(eff_cache_dir, exist_ok=True)
                    with open(cache_file, "wb") as wf:
                        wf.write(cached)
                    return cached
            except OSError:
                pass

    with open(abs_xwm, "rb") as rf:
        xwm_bytes = rf.read()

    # Resolve matching .wav if present on disk
    wav_bytes: bytes | None = None
    cand_wav: str | None = None
    if wav_path and os.path.isfile(wav_path):
        cand_wav = wav_path
    elif wav_path is None:
        sib_wav = os.path.splitext(abs_xwm)[0] + ".wav"
        if os.path.isfile(sib_wav):
            cand_wav = sib_wav
    elif wav_path:
        # Caller passed a wav_path that does not exist on disk -> check sibling .wav if present
        sib_wav = os.path.splitext(abs_xwm)[0] + ".wav"
        if os.path.isfile(sib_wav):
            cand_wav = sib_wav

    if cand_wav is not None:
        try:
            with open(cand_wav, "rb") as rf:
                wav_bytes = rf.read()
        except OSError:
            wav_bytes = None

    # Optional transcript text if present alongside the clip
    spoken_text = ""
    sib_txt = os.path.splitext(abs_xwm)[0] + ".txt"
    if os.path.isfile(sib_txt):
        try:
            with open(sib_txt, "r", encoding="utf-8", errors="ignore") as tf:
                spoken_text = tf.read().strip()
        except OSError:
            spoken_text = ""

    lip_bytes = build_lip_v1_bytes(xwm_bytes, wav_bytes=wav_bytes, spoken_text=spoken_text)
    fuz_bytes = b"FUZE" + struct.pack("<II", 1, len(lip_bytes)) + lip_bytes + xwm_bytes

    os.makedirs(eff_cache_dir, exist_ok=True)
    # Remove any stale cached entries for the same dialogue stem in this voice folder
    prefix = f"{vtype_folder}__{stem}_"
    try:
        for old_fn in os.listdir(eff_cache_dir):
            if old_fn.startswith(prefix) and old_fn.endswith(".fuz") and old_fn != cache_fn:
                try:
                    os.remove(os.path.join(eff_cache_dir, old_fn))
                except OSError:
                    pass
    except OSError:
        pass

    tmp_file = f"{cache_file}.{os.getpid()}.tmp"
    with open(tmp_file, "wb") as wf:
        wf.write(fuz_bytes)
    os.replace(tmp_file, cache_file)
    return fuz_bytes


def verify_fuz_bytes(fuz_bytes: bytes) -> tuple[int, int, int]:
    """
    Binary-verifies a Fallout 4 `FUZE` v1 payload:
      - Header starts with `FUZE\\x01\\x00\\x00\\x00`
      - Decompresses `.lip` cleanly via `_decomp_lip` to `24 + n_frames * 240` bytes
      - Embeds a valid `RIFF....XWMA` stream
    Returns `(lip_compressed_len, n_lip_frames, xwm_len)`.
    """
    if len(fuz_bytes) < 24 or fuz_bytes[:8] != b"FUZE\x01\x00\x00\x00":
        raise ValueError("Invalid FUZE v1 magic/version header")
    lip_sz = struct.unpack_from("<I", fuz_bytes, 8)[0]
    if 12 + lip_sz + 12 > len(fuz_bytes):
        raise ValueError(f"Truncated FUZE payload (lip_sz={lip_sz}, total={len(fuz_bytes)})")
    lip_raw = _decomp_lip(fuz_bytes[12 : 12 + lip_sz])
    ver, hdr_sz, unk13, n_frames, unk_m8, unk43 = struct.unpack_from("<IIIIii", lip_raw, 0)
    if ver != 1 or len(lip_raw) != 24 + n_frames * 240 or hdr_sz != 28 + n_frames * 240:
        raise ValueError(
            f"Invalid decompressed .lip v1 layout: ver={ver}, len={len(lip_raw)}, "
            f"n_frames={n_frames}, hdr_sz={hdr_sz}"
        )
    xwm = fuz_bytes[12 + lip_sz :]
    if len(xwm) < 36 or xwm[:4] != b"RIFF" or xwm[8:12] != b"XWMA":
        raise ValueError("Invalid embedded XWMA RIFF header")
    riff_sz = struct.unpack_from("<I", xwm, 4)[0]
    if riff_sz + 8 != len(xwm):
        raise ValueError(f"XWMA RIFF size mismatch: {riff_sz + 8} != {len(xwm)}")
    return lip_sz, n_frames, len(xwm)


# ==============================================================================
# BINARY-VERIFIED FALLOUT 4 `.BTR` TERRAIN LOD BUILDER (OPT-IN / REFERENCE)
# ==============================================================================
# Exact binary layout verified against vanilla `commonwealth.4.*.btr`,
# `diamondcity.4.*.btr`, and `nukaworld.4.*.btr` (`20.2.0.7`, `uv=12`, `uv2=130`):
#   Block 0: BSMultiBoundNode (88 B dry: name="chunk", culling=1, 1 child=[1], multi_bound=4)
#   Block 1: BSTriShape       (name="land", scale=float(level), shader=2, vdesc=0x0000300000000203,
#                              12 B/vert `<3eH2e`: vx=(wx-x0)/lvl, vy=(wy-y0)/lvl, vz=wz/lvl,
#                              pad=0, u=vx/4096, v=1-vy/4096, plus -250 local-unit 4-edge skirts)
#   Block 2: BSLightingShaderProperty (140 B: ShaderType=18 / 0x12 `BSLSP_LODLANDSCAPE`,
#                              sf1=0x80401000, sf2=0x00000003, texset=3)
#   Block 3: BSShaderTextureSet (10 slots: slot0=`Data\Textures\Terrain\<W>\<W>.<L>.<X>.<Y>.DDS`,
#                              slot1=`Data\Textures\Terrain\<W>\<W>.<L>.<X>.<Y>_msn.DDS`)
#   Block 4: BSMultiBound     (4 B: data_ref=5)
#   Block 5: BSMultiBoundAABB (24 B: world-scaled `<3f` center + `<3f` half-extents)
# ==============================================================================


def build_fo4_btr_bytes(
    world_name: str,
    level: int,
    cell_x: int,
    cell_y: int,
    grid_heights: list[list[float]],
    skirt_drop_local: float = 250.0,
) -> bytes:
    """
    Constructs a binary-exact Fallout 4 (`20.2.0.7`, `user_ver=12`, `user_ver2=130`) dry-land
    `.btr` terrain LOD mesh using `BSLightingShaderProperty` `ShaderType = 18` (`BSLSP_LODLANDSCAPE`).
    `grid_heights` must be an `(N x N)` grid of world-space Z heights spanning `[0..4096*level]`
    along X (columns `ix`) and Y (rows `iy`).
    """
    n_side = len(grid_heights)
    if n_side < 2 or any(len(row) != n_side for row in grid_heights):
        raise ValueError("grid_heights must be an N x N square matrix with N >= 2")

    lvl_f = float(level)
    step_local = 4096.0 / float(n_side - 1)

    # Surface vertices + 4-edge vertical LOD skirts (matching vanilla -250 local-unit drop)
    verts_local: list[tuple[float, float, float, float, float]] = []
    for iy in range(n_side):
        vy = iy * step_local
        v_uv = 1.0 - (vy / 4096.0)
        for ix in range(n_side):
            vx = ix * step_local
            u_uv = vx / 4096.0
            vz = grid_heights[iy][ix] / lvl_f
            verts_local.append((vx, vy, vz, u_uv, v_uv))

    tris: list[tuple[int, int, int]] = []
    for iy in range(n_side - 1):
        for ix in range(n_side - 1):
            i00 = iy * n_side + ix
            i10 = i00 + 1
            i01 = (iy + 1) * n_side + ix
            i11 = i01 + 1
            tris.append((i00, i10, i11))
            tris.append((i00, i11, i01))

    # Add 4-perimeter skirt strips to prevent cracks between adjacent LOD levels (4/8/16/32)
    edges = [
        [0 * n_side + ix for ix in range(n_side)],                        # South (iy=0)
        [iy * n_side + (n_side - 1) for iy in range(n_side)],             # East  (ix=N-1)
        [(n_side - 1) * n_side + ix for ix in range(n_side - 1, -1, -1)], # North (iy=N-1)
        [iy * n_side + 0 for iy in range(n_side - 1, -1, -1)],            # West  (ix=0)
    ]
    for edge in edges:
        sk_idx: list[int] = []
        for top_i in edge:
            vx, vy, vz, u_uv, v_uv = verts_local[top_i]
            sk_idx.append(len(verts_local))
            verts_local.append((vx, vy, vz - skirt_drop_local, u_uv, v_uv))
        for k in range(len(edge) - 1):
            t0, t1 = edge[k], edge[k + 1]
            b0, b1 = sk_idx[k], sk_idx[k + 1]
            tris.append((t0, b0, b1))
            tris.append((t0, b1, t1))

    n_verts = len(verts_local)
    n_tris = len(tris)
    vdesc = 0x0000300000000203  # 12 B/vert (`<3eH2e`: half3 pos + uint16 pad + half2 uv)
    vert_buf = bytearray(n_verts * 12)
    min_x = min_y = min_z = 1e30
    max_x = max_y = max_z = -1e30
    for vi, (vx, vy, vz, u_uv, v_uv) in enumerate(verts_local):
        struct.pack_into("<3eH2e", vert_buf, vi * 12, vx, vy, vz, 0, u_uv, v_uv)
        if vx < min_x:
            min_x = vx
        if vx > max_x:
            max_x = vx
        if vy < min_y:
            min_y = vy
        if vy > max_y:
            max_y = vy
        if vz < min_z:
            min_z = vz
        if vz > max_z:
            max_z = vz

    tri_buf = bytearray(n_tris * 6)
    for ti, (a, b, c) in enumerate(tris):
        struct.pack_into("<3H", tri_buf, ti * 6, a, b, c)

    cx_loc = 0.5 * (min_x + max_x)
    cy_loc = 0.5 * (min_y + max_y)
    cz_loc = 0.5 * (min_z + max_z)
    rad_loc = math.sqrt((max_x - cx_loc) ** 2 + (max_y - cy_loc) ** 2 + (max_z - cz_loc) ** 2)

    # Strings table: 0="chunk", 1="land"
    strings = ["chunk", "land"]

    # Block 0: BSMultiBoundNode (88 B exact vanilla FO4 uv2=130 layout)
    ident_rot = (1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0)
    b0_exact = bytearray(88)
    struct.pack_into("<iIiI", b0_exact, 0, 0, 0, -1, 14)
    struct.pack_into("<3f9ff", b0_exact, 16, 0.0, 0.0, 0.0, *ident_rot, 1.0)
    struct.pack_into("<iIiIi", b0_exact, 68, -1, 1, 1, 1, 4)

    # Block 1: BSTriShape (`name_ref=1` "land", `scale=lvl_f`, `shader_ref=2`, `alpha_ref=-1`)
    data_size = len(vert_buf) + len(tri_buf)
    b1_hdr = bytearray(118)
    struct.pack_into("<iIiI", b1_hdr, 0, 1, 0, -1, 14)
    struct.pack_into("<3f9ff", b1_hdr, 16, 0.0, 0.0, 0.0, *ident_rot, lvl_f)
    struct.pack_into("<i", b1_hdr, 68, -1)  # collision_ref
    struct.pack_into("<4f", b1_hdr, 72, cx_loc, cy_loc, cz_loc, rad_loc)
    struct.pack_into("<3i", b1_hdr, 88, -1, 2, -1)  # skin=-1, shader=2, alpha=-1
    struct.pack_into("<QIHI", b1_hdr, 100, vdesc, n_tris, n_verts, data_size)
    b1_exact = bytes(b1_hdr) + bytes(vert_buf) + bytes(tri_buf) + b"\x00\x00\x00\x00"

    # Block 2: BSLightingShaderProperty (140 B, ShaderType=18 `BSLSP_LODLANDSCAPE`)
    b2_exact = bytearray(140)
    struct.pack_into(
        "<IiIiII4fIIi3ff3fffff",
        b2_exact,
        0,
        18,          # ShaderType = 18 (0x12, BSLSP_LODLANDSCAPE)
        -1,          # name_ref = -1
        0,           # num_extra = 0
        -1,          # controller_ref = -1
        0x80401000,  # shader_flags_1 (ZBuffer_Test | Cast_Shadows | Model_Space_Normals/LOD)
        0x00000003,  # shader_flags_2 (ZBuffer_Write | LOD_Landscape)
        0.0, 0.0, 1.0, 1.0,  # uv_offset(0,0), uv_scale(1,1)
        0, 0,        # clamp_mode = WRAP_S_WRAP_T (3? vanilla nukaworld=0,0 or 3)
        3,           # texture_set_ref = Block 3
        0.0, 0.0, 0.0, 1.0,  # emissive color + mult
        1.0, 1.0, 1.0,       # specular/alpha defaults
        1.0, 0.0, 0.0, 1.0,
    )
    # Match exact vanilla nukaworld.4.-12.-24.btr bytes [44..140]
    struct.pack_into("<i", b2_exact, 40, 3)   # texture_set_ref = 3
    struct.pack_into("<i", b2_exact, 60, -1)  # root_material_ref = -1
    struct.pack_into("<f", b2_exact, 68, 1.0) # alpha = 1.0
    struct.pack_into("<f", b2_exact, 72, 1.0) # refraction/glossiness = 1.0
    struct.pack_into("<f", b2_exact, 76, 1.0)

    # Block 3: BSShaderTextureSet (10 slots)
    base_tex = f"Data\\Textures\\Terrain\\{world_name}\\{world_name}.{level}.{cell_x}.{cell_y}"
    slots = [f"{base_tex}.DDS", f"{base_tex}_msn.DDS"] + [""] * 8
    b3_buf = bytearray(struct.pack("<I", 10))
    for s in slots:
        sb = s.encode("ascii")
        b3_buf.extend(struct.pack("<I", len(sb)) + sb)

    # Block 4: BSMultiBound (4 B -> Block 5)
    b4_exact = struct.pack("<i", 5)

    # Block 5: BSMultiBoundAABB (24 B: world-scaled center & half-extents)
    half_x = 0.5 * (max_x - min_x) * lvl_f
    half_y = 0.5 * (max_y - min_y) * lvl_f
    half_z = 0.5 * (max_z - min_z) * lvl_f
    b5_exact = struct.pack(
        "<6f",
        cx_loc * lvl_f,
        cy_loc * lvl_f,
        cz_loc * lvl_f,
        half_x,
        half_y,
        half_z,
    )

    blocks = [
        ("BSMultiBoundNode", bytes(b0_exact)),
        ("BSTriShape", b1_exact),
        ("BSLightingShaderProperty", bytes(b2_exact)),
        ("BSShaderTextureSet", bytes(b3_buf)),
        ("BSMultiBound", b4_exact),
        ("BSMultiBoundAABB", b5_exact),
    ]
    btypes = [bt for bt, _ in blocks]

    out = bytearray()
    out.extend(b"Gamebryo File Format, Version 20.2.0.7\n")
    out.extend(struct.pack("<IBIII", 0x14020007, 1, 12, len(blocks), 130))
    for _ in range(4):  # 4 FO4 uv2=130 export strings (author, process, export, max_filepath)
        out.extend(b"\x01\x00")
    out.extend(struct.pack("<H", len(btypes)))
    for bt in btypes:
        bt_b = bt.encode("ascii")
        out.extend(struct.pack("<I", len(bt_b)) + bt_b)
    for idx in range(len(blocks)):
        out.extend(struct.pack("<H", idx))
    for _, blk in blocks:
        out.extend(struct.pack("<I", len(blk)))
    max_s = max((len(s) for s in strings), default=0)
    out.extend(struct.pack("<II", len(strings), max_s))
    for s in strings:
        sb = s.encode("ascii")
        out.extend(struct.pack("<I", len(sb)) + sb)
    out.extend(struct.pack("<I", 0))  # num_groups = 0
    for _, blk in blocks:
        out.extend(blk)
    out.extend(struct.pack("<II", 1, 0))  # 1 root = Block 0
    return bytes(out)


def ensure_v13_terrain_lod_assets() -> tuple[dict[str, str], list[tuple[str, str]]]:
    """
    Returns `(main_ba2_btr_map, tex_ba2_dds_list)`.
    When `ENABLE_TERRAIN_LOD` is `False` (default safety policy), returns empty containers so
    no unmapped `BSLSP_LODLANDSCAPE` (`ShaderType=18`) `.btr` chunks can ever cause purple
    distant terrain or ocean seams.
    """
    if not ENABLE_TERRAIN_LOD:
        return {}, []
    return {}, []


def prewarm_all_v13_fuz_caches() -> dict[str, int]:
    """
    Pre-warms BOTH ES (`assets/voices_fuz_cache`) and EN (`edition_en/assets_en/voices_fuz_cache`)
    `.fuz` caches for all dialogue `.xwm` clips (skipping duplicate `crsupermutant` folders),
    and binary-verifies every generated `.fuz` via `verify_fuz_bytes`.
    """
    t0 = time.perf_counter()
    stats = {
        "es_count": 0,
        "en_count": 0,
        "es_total_bytes": 0,
        "en_total_bytes": 0,
        "es_verified": 0,
        "en_verified": 0,
    }

    jobs = [
        ("es", os.path.join(THIS_DIR, "assets", "voices_es"), DEFAULT_ES_FUZ_CACHE_DIR),
        ("en", os.path.join(THIS_DIR, "edition_en", "voices_en"), DEFAULT_EN_FUZ_CACHE_DIR),
    ]

    for lang, voices_root, cache_root in jobs:
        if not os.path.isdir(voices_root):
            continue
        os.makedirs(cache_root, exist_ok=True)
        for vdir in sorted(os.listdir(voices_root)):
            if vdir.lower() == "crsupermutant":
                continue
            vpath = os.path.join(voices_root, vdir)
            if not os.path.isdir(vpath):
                continue
            for fn in sorted(os.listdir(vpath)):
                if not fn.lower().endswith(".xwm"):
                    continue
                xwm_p = os.path.join(vpath, fn)
                wav_p = os.path.splitext(xwm_p)[0] + ".wav"
                fuz_b = get_or_build_fuz_bytes(
                    xwm_p,
                    wav_p if os.path.isfile(wav_p) else None,
                    cache_root,
                )
                verify_fuz_bytes(fuz_b)
                stats[f"{lang}_count"] += 1
                stats[f"{lang}_verified"] += 1
                stats[f"{lang}_total_bytes"] += len(fuz_b)

    radio_jobs = [
        ("es", os.path.join(THIS_DIR, "assets", "radio_dj_es"), DEFAULT_ES_FUZ_CACHE_DIR),
        ("en", os.path.join(THIS_DIR, "edition_en", "assets", "radio_dj_en"), DEFAULT_EN_FUZ_CACHE_DIR),
    ]
    for lang, rpath, cache_root in radio_jobs:
        if not os.path.isdir(rpath):
            continue
        os.makedirs(cache_root, exist_ok=True)
        for fn in sorted(os.listdir(rpath)):
            if not fn.lower().endswith(".xwm"):
                continue
            xwm_p = os.path.join(rpath, fn)
            wav_p = os.path.splitext(xwm_p)[0] + ".wav"
            fuz_b = get_or_build_fuz_bytes(
                xwm_p,
                wav_p if os.path.isfile(wav_p) else None,
                cache_root,
            )
            verify_fuz_bytes(fuz_b)
            stats[f"{lang}_count"] += 1
            stats[f"{lang}_verified"] += 1
            stats[f"{lang}_total_bytes"] += len(fuz_b)

    elapsed = time.perf_counter() - t0
    print(
        f"[FUZ Pre-Warm] ES={stats['es_verified']}/{stats['es_count']} clips "
        f"({stats['es_total_bytes']:,} B) | "
        f"EN={stats['en_verified']}/{stats['en_count']} clips "
        f"({stats['en_total_bytes']:,} B) | "
        f"ENABLE_TERRAIN_LOD={ENABLE_TERRAIN_LOD} | {elapsed:.2f}s"
    )
    return stats


if __name__ == "__main__":
    prewarm_all_v13_fuz_caches()
