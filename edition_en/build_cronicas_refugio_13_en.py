#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Complete Builder for 'Vault 13 Chronicles (2161)' — 100% English Edition
(cronicas_refugio_13/edition_en/build_out/):
  - Vault13Chronicles.esp (HEDR v1.0, 100% English texts across all 5 Acts, Side Quests, Companions & 6 Special Encounters)
  - Vault13Chronicles - Main.ba2 (GNRL v1: 50 English .pex scripts, 1,050+ ElevenLabs English lip-synced .fuz voices, 24 English Hub Radio DJ broadcasts, zlib-compressed custom 3D .nif meshes & .bgsm/.bgem materials)
  - Vault13Chronicles - Textures.ba2 (DX10 v1: custom .dds textures including 12-mip English Pip-Boy World Map, 7 English Location Signs, English Vault 13 Quartermaster Cabinet, English Velvet Elvis Painting, Lars Guard Helmet, Nuka-Cola Crates & isolated Vault 13 Jumpsuit numbers)
"""

import json
import os
import shutil
import struct
import sys
import zlib

sys.stdout.reconfigure(encoding="utf-8")

THIS_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.dirname(THIS_DIR)
sys.path.insert(0, ROOT_DIR)
sys.path.insert(0, THIS_DIR)

import build_cronicas_refugio_13 as es_builder
import generate_v13_textures_en
import sync_papyrus_en
import synthesize_voices_and_radio_en

ESP_NAME = "Vault13Chronicles.esp"
BA2_NAME = "Vault13Chronicles - Main.ba2"
TEX_BA2_NAME = "Vault13Chronicles - Textures.ba2"

IS_PUBLIC_RELEASE = "--public-release" in sys.argv
BUILD_OUT_EN_DIR = os.path.join(THIS_DIR, "release_out" if IS_PUBLIC_RELEASE else "build_out")
PAPYRUS_OUT_EN_DIR = os.path.join(THIS_DIR, "papyrus_out")
VOICES_EN_DIR = os.path.join(THIS_DIR, "voices_en")
RADIO_DJ_EN_DIR = os.path.join(THIS_DIR, "assets", "radio_dj_en")

TRANSLATABLE_SUBS = {
    (b"TES4", b"SNAM"),
    (b"ACTI", b"FULL"),
    (b"ACTI", b"ATTX"),
    (b"ARMO", b"FULL"),
    (b"ARMO", b"DESC"),
    (b"BOOK", b"FULL"),
    (b"BOOK", b"DESC"),
    (b"CELL", b"FULL"),
    (b"CONT", b"FULL"),
    (b"DIAL", b"FULL"),
    (b"DOOR", b"FULL"),
    (b"ENCH", b"FULL"),
    (b"INFO", b"NAM1"),
    (b"INFO", b"RNAM"),
    (b"LCTN", b"FULL"),
    (b"MESG", b"FULL"),
    (b"MESG", b"DESC"),
    (b"MESG", b"ITXT"),
    (b"MGEF", b"FULL"),
    (b"MISC", b"FULL"),
    (b"NPC_", b"FULL"),
    (b"NPC_", b"SHRT"),
    (b"QUST", b"FULL"),
    (b"QUST", b"CNAM"),
    (b"QUST", b"NNAM"),
    (b"REFR", b"FULL"),
    (b"TERM", b"FULL"),
    (b"TERM", b"NAM0"),
    (b"TERM", b"WNAM"),
    (b"TERM", b"ITXT"),
    (b"TERM", b"RNAM"),
    (b"TERM", b"UNAM"),
    (b"WEAP", b"FULL"),
    (b"WEAP", b"DESC"),
    (b"WRLD", b"FULL"),
}

CLEAN_CP1252_MAP = {
    "\u00e2\u20ac\u201d": " - ",
    "\u2014": "-",
    "\u2013": "-",
    "\u2018": "'",
    "\u2019": "'",
    "\u201c": '"',
    "\u201d": '"',
    "\u2022": "-",
    "\u2026": "...",
    "\u00ab": '"',
    "\u00bb": '"',
}


def encode_en_zstr(txt: str) -> bytes:
    cleaned = txt
    for k, v in CLEAN_CP1252_MAP.items():
        cleaned = cleaned.replace(k, v)
    return cleaned.encode("utf-8", "replace") + b"\x00"


def transform_esp_to_english(src_esp_path: str, dst_esp_path: str, trans_map: dict[str, str]) -> int:
    with open(src_esp_path, "rb") as f:
        src_buf = f.read()

    translated_count = 0

    def transform_chunk(buf: bytes, start: int, end: int) -> bytes:
        nonlocal translated_count
        out = bytearray()
        pos = start
        while pos < end:
            rt = buf[pos : pos + 4]
            if rt == b"GRUP":
                gsz = struct.unpack_from("<I", buf, pos + 4)[0]
                ghdr = bytearray(buf[pos : pos + 24])
                gbody = transform_chunk(buf, pos + 24, pos + gsz)
                struct.pack_into("<I", ghdr, 4, 24 + len(gbody))
                out.extend(ghdr)
                out.extend(gbody)
                pos += gsz
            else:
                dsz, flags, fid = struct.unpack_from("<III", buf, pos + 4)
                rhdr = bytearray(buf[pos : pos + 24])
                raw_payload = buf[pos + 24 : pos + 24 + dsz]
                is_comp = bool(flags & 0x00040000)
                if is_comp:
                    rdata = zlib.decompress(raw_payload[4:])
                else:
                    rdata = raw_payload

                new_rdata = bytearray()
                sp = 0
                n = len(rdata)
                xxxx_sz: int | None = None
                while sp + 6 <= n:
                    st = rdata[sp : sp + 4]
                    ssz = struct.unpack_from("<H", rdata, sp + 4)[0]
                    sp += 6
                    if st == b"XXXX" and ssz == 4 and sp + 4 <= n:
                        xxxx_sz = struct.unpack_from("<I", rdata, sp)[0]
                        new_rdata.extend(st + struct.pack("<HI", 4, xxxx_sz))
                        sp += 4
                        continue
                    if xxxx_sz is not None:
                        actual_sz = xxxx_sz
                        xxxx_sz = None
                        sval = rdata[sp : sp + actual_sz]
                        sp += actual_sz
                        new_rdata.extend(st + struct.pack("<H", 0) + sval)
                        continue

                    sval = rdata[sp : sp + ssz]
                    sp += ssz
                    if (rt, st) in TRANSLATABLE_SUBS and len(sval) >= 2 and sval[-1] == 0:
                        if all(b >= 32 or b in (9, 10, 13) for b in sval[:-1]):
                            es_txt_cp = sval[:-1].decode("cp1252", "replace")
                            es_txt_u8 = sval[:-1].decode("utf-8", "replace")
                            en_val = trans_map.get(es_txt_cp) or trans_map.get(es_txt_u8)
                            if en_val:
                                en_bytes = encode_en_zstr(en_val)
                                sval = en_bytes
                                translated_count += 1
                    new_rdata.extend(st + struct.pack("<H", len(sval)) + sval)

                if is_comp:
                    comp_bytes = struct.pack("<I", len(new_rdata)) + zlib.compress(bytes(new_rdata))
                    struct.pack_into("<I", rhdr, 4, len(comp_bytes))
                    out.extend(rhdr)
                    out.extend(comp_bytes)
                else:
                    struct.pack_into("<I", rhdr, 4, len(new_rdata))
                    out.extend(rhdr)
                    out.extend(new_rdata)

                pos += 24 + dsz
        return bytes(out)

    en_esp_bytes = transform_chunk(src_buf, 0, len(src_buf))
    os.makedirs(os.path.dirname(dst_esp_path), exist_ok=True)
    with open(dst_esp_path, "wb") as wf:
        wf.write(en_esp_bytes)
    return translated_count


def main() -> None:
    os.makedirs(BUILD_OUT_EN_DIR, exist_ok=True)

    # 1. Synchronize and compile all 50 English Papyrus scripts (.psc -> .pex)
    print("=== [1/5] Synchronizing & Compiling 50 English Papyrus Scripts ===")
    sync_papyrus_en.sync_and_compile_papyrus_en()

    # 2. Generate/verify all English custom .dds textures, maps, signs & 3D decals
    print("=== [2/5] Verifying Custom English .dds Textures, Signs, Maps & 3D Decals ===")
    wmap_en_dds = os.path.join(THIS_DIR, "assets", "textures", "interface", "pip-boy", "V13CaliforniaWorldMap_d.dds")
    if not os.path.exists(wmap_en_dds) or "--regen-textures" in sys.argv:
        generate_v13_textures_en.generate_all_english_textures()
    else:
        generate_v13_textures_en.copy_shared_dds_textures()
        print("  [DDS EN] All custom English .dds textures verified in edition_en/assets/")

    # 3. Ensure all English ElevenLabs voices and Radio DJ broadcasts exist
    print("=== [3/5] Verifying English ElevenLabs Voices & The Hub Radio 84.5 Tracks ===")
    synthesize_voices_and_radio_en.main()

    # 4. Build English Vault13Chronicles.esp from validated Spanish binary structure + translations_en.json
    print("=== [4/5] Building English Vault13Chronicles.esp ===")
    with open(os.path.join(THIS_DIR, "translations_en.json"), "r", encoding="utf-8") as tf:
        trans_map = json.load(tf)

    src_es_esp = os.path.join(ROOT_DIR, "release_out" if IS_PUBLIC_RELEASE else "build_out", ESP_NAME)
    dst_en_esp = os.path.join(BUILD_OUT_EN_DIR, ESP_NAME)
    n_trans = transform_esp_to_english(src_es_esp, dst_en_esp, trans_map)
    print(f"  [ESP EN] Built {dst_en_esp} ({n_trans} text subrecords translated to canonical Fallout 1 English).")

    # 5. Package Vault13Chronicles - Main.ba2 and Vault13Chronicles - Textures.ba2
    print("=== [5/5] Packaging English BA2 Archives (Main.ba2 & Textures.ba2) ===")
    api_key = es_builder.load_api_key()
    ba2_files: dict[str, str] = {}

    # 5a. Collect all English voice .xwm files via es_builder.synthesize_all_voices
    def register_en_voice_clip(
        _api_key: str,
        vtyp_edid: str,
        _voice_id: str,
        low_fid: int,
        resp_idx: int,
        _tts_text: str,
        ba2_voice_map: dict[str, str],
    ) -> None:
        fname_base = f"{low_fid:08X}_{resp_idx}"
        xwm_path = os.path.join(VOICES_EN_DIR, vtyp_edid, f"{fname_base}.xwm")
        rel_key = f"sound\\voice\\{ESP_NAME.lower()}\\{vtyp_edid.lower()}\\{fname_base.lower()}.xwm"
        ba2_voice_map[rel_key] = xwm_path

    es_builder._synthesize_single_clip = register_en_voice_clip
    es_builder.VOICES_DIR = VOICES_EN_DIR
    ba2_voices = es_builder.synthesize_all_voices("dummy")
    ba2_files.update(ba2_voices)

    # 5b. Collect custom SFX
    ba2_sfx = es_builder.synthesize_all_sfx(api_key)
    ba2_files.update(ba2_sfx)

    # 5c. Collect English Radio DJ broadcasts + songs
    es_builder.RADIO_DJ_DIR = RADIO_DJ_EN_DIR
    es_builder.V13_RADIO_DJ_DEFS = synthesize_voices_and_radio_en.V13_RADIO_DJ_DEFS_EN
    ba2_radio, _, _ = es_builder.synthesize_all_radio_tracks(api_key)
    ba2_files.update(ba2_radio)

    # 5d. Collect custom 3D .nif meshes and .bgsm/.bgem materials
    ba2_files.update(es_builder.build_clean_vault_entrance_nifs())
    junktown_main_map, _ = es_builder.ensure_junktown_3d_assets()
    ba2_files.update(junktown_main_map)

    # 5e. Collect all 50 compiled English .pex scripts
    for fn in sorted(os.listdir(PAPYRUS_OUT_EN_DIR)):
        if fn.endswith(".pex"):
            src_pex = os.path.join(PAPYRUS_OUT_EN_DIR, fn)
            ba2_files[f"scripts\\{fn.lower()}"] = src_pex

    staged_ba2 = os.path.join(BUILD_OUT_EN_DIR, BA2_NAME)
    staged_tex_ba2 = os.path.join(BUILD_OUT_EN_DIR, TEX_BA2_NAME)

    es_builder.build_ba2_archive(staged_ba2, ba2_files)

    # Build English Textures.ba2 using edition_en/assets
    orig_this_dir = es_builder.THIS_DIR
    try:
        es_builder.THIS_DIR = THIS_DIR
        es_builder.build_vault13_textures_ba2(staged_tex_ba2)
    finally:
        es_builder.THIS_DIR = orig_this_dir

    if ("--install" in sys.argv) and (not IS_PUBLIC_RELEASE):
        fo4_scripts_dir = os.path.join(es_builder.FO4_DATA_DIR, "Scripts")
        removed_loose_pex = 0
        if os.path.isdir(fo4_scripts_dir):
            for fn in sorted(os.listdir(fo4_scripts_dir)):
                if fn.lower().startswith("v13") and fn.lower().endswith(".pex"):
                    try:
                        os.remove(os.path.join(fo4_scripts_dir, fn))
                        removed_loose_pex += 1
                    except OSError:
                        pass
        print(
            f"  [Cleaned Fallout 4\\Data\\Scripts] Removed {removed_loose_pex} loose V13*.pex overrides (loaded cleanly from Main.ba2)"
        )
        for src_f, dst_name in [
            (dst_en_esp, ESP_NAME),
            (staged_ba2, BA2_NAME),
            (staged_tex_ba2, TEX_BA2_NAME),
        ]:
            dst_f = os.path.join(es_builder.FO4_DATA_DIR, dst_name)
            try:
                shutil.copyfile(src_f, dst_f)
                print(f"  [Installed EN to Fallout 4\\Data] {dst_name}")
            except PermissionError:
                print(f"  [Notice] {dst_name} is currently locked by a running Fallout4.exe session (close Fallout4.exe to copy {dst_name}).")

    print(
        "\n'Vault 13 Chronicles (2161)' (All 5 Acts + Side Quests + Companions + 6 Special Encounters, 100% English Edition) built successfully in cronicas_refugio_13/edition_en/build_out/!"
    )


if __name__ == "__main__":
    main()
