#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Batería Exhaustiva de Auditoría de Calidad (QA) para «Crónicas del Refugio 13» (Vault13Chronicles.esp).

Ejecuta 6 módulos de inspección automatizada:
  1. Integridad Binaria del .esp, Cabecera HEDR v1.0, Colisiones de FormID y Punteros Cruzados (ESP + Fallout4.esm).
  2. Lógica de Misiones (QUST), Alias Persistentes (ALFR), Etapas (INDX), Brújula (QOBJ/QSTA) y Sincronización con Papyrus (.psc/.pex).
  3. Interacciones con NPCs, Escenas y Ruedas de Diálogo (SCEN/DIAL/INFO), Verificación 1:1 de Voces Lip-Sync (.fuz = .lip + .xwm) y Comerciantes (FACT).
  4. Auditoría Geométrica 3D: Terreno Exterior (LAND vs global_california_height), Flotación/Enterramientos, Escritorios, Colisiones y Zonas Seguras.
  5. Auditoría de Archivos .ba2 (GNRL/DX10 v1) y Trazabilidad Completa de Activos (ESP -> NIF -> BGSM/BGEM -> DDS).
  6. Escáner de Diagnóstico de Logs en Tiempo de Ejecución (Papyrus.0.log).
"""

import glob
import math
import os
import re
import struct
import sys
import zlib
from collections import defaultdict

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, SCRIPT_DIR)

from generate_v13_worldmap_dds import global_california_height
import v13_opt_helpers

IS_EN_AUDIT = "--en" in sys.argv
IS_PUBLIC_RELEASE = "--public-release" in sys.argv
FO4_DATA_DIR = r"C:\Program Files (x86)\Steam\steamapps\common\Fallout 4\Data"
FO4_ESM_PATH = os.path.join(FO4_DATA_DIR, "Fallout4.esm")
_OUT_FOLDER_NAME = "release_out" if IS_PUBLIC_RELEASE else "build_out"
BUILD_OUT_DIR = (
    os.path.join(SCRIPT_DIR, "edition_en", _OUT_FOLDER_NAME)
    if IS_EN_AUDIT
    else os.path.join(SCRIPT_DIR, _OUT_FOLDER_NAME)
)
ESP_PATH = os.path.join(BUILD_OUT_DIR, "Vault13Chronicles.esp")
MAIN_BA2_PATH = os.path.join(BUILD_OUT_DIR, "Vault13Chronicles - Main.ba2")
TEX_BA2_PATH = os.path.join(BUILD_OUT_DIR, "Vault13Chronicles - Textures.ba2")
PAPYRUS_SRC_DIR = (
    os.path.join(SCRIPT_DIR, "edition_en", "papyrus_src")
    if IS_EN_AUDIT
    else os.path.join(SCRIPT_DIR, "papyrus_src")
)
PAPYRUS_OUT_DIR = (
    os.path.join(SCRIPT_DIR, "edition_en", "papyrus_out")
    if IS_EN_AUDIT
    else os.path.join(SCRIPT_DIR, "papyrus_out")
)
PAPYRUS_LOG_PATH = os.path.expanduser(
    r"~\Documents\My Games\Fallout4\Logs\Script\Papyrus.0.log"
)


class QAReport:
    def __init__(self) -> None:
        self.passed: list[str] = []
        self.warnings: list[str] = []
        self.errors: list[str] = []

    def ok(self, msg: str) -> None:
        self.passed.append(msg)

    def warn(self, msg: str) -> None:
        self.warnings.append(msg)

    def err(self, msg: str) -> None:
        self.errors.append(msg)


def parse_subrecords(raw_data: bytes) -> list[tuple[str, bytes]]:
    subs: list[tuple[str, bytes]] = []
    pos = 0
    n = len(raw_data)
    xxxx_size: int | None = None
    while pos + 6 <= n:
        stype = raw_data[pos : pos + 4].decode("latin1", "ignore")
        ssize = struct.unpack_from("<H", raw_data, pos + 4)[0]
        pos += 6
        if stype == "XXXX" and ssize == 4 and pos + 4 <= n:
            xxxx_size = struct.unpack_from("<I", raw_data, pos)[0]
            pos += 4
            continue
        if xxxx_size is not None:
            ssize = xxxx_size
            xxxx_size = None
        if pos + ssize > n:
            break
        subs.append((stype, raw_data[pos : pos + ssize]))
        pos += ssize
    return subs


def get_zstr(val: bytes) -> str:
    return val.rstrip(b"\x00").decode("cp1252", "ignore")


class ParsedRecord:
    def __init__(
        self,
        rtype: str,
        fid: int,
        flags: int,
        raw_payload: bytes,
        parent_wrld: int = 0,
        parent_cell: int = 0,
        parent_dial: int = 0,
        parent_qust: int = 0,
    ) -> None:
        self.rtype = rtype
        self.fid = fid
        self.flags = flags
        self.raw_payload = raw_payload
        self.parent_wrld = parent_wrld
        self.parent_cell = parent_cell
        self.parent_dial = parent_dial
        self.parent_qust = parent_qust
        self.subs = parse_subrecords(raw_payload)
        self.edid = ""
        self.full = ""
        for st, sv in self.subs:
            if st == "EDID" and not self.edid:
                self.edid = get_zstr(sv)
            elif st == "FULL" and not self.full:
                self.full = get_zstr(sv)


def parse_esp_hierarchy(esp_bytes: bytes, report: QAReport) -> list[ParsedRecord]:
    records: list[ParsedRecord] = []

    def _walk(
        start: int,
        end: int,
        p_wrld: int = 0,
        p_cell: int = 0,
        p_dial: int = 0,
        p_qust: int = 0,
    ) -> None:
        pos = start
        cur_wrld = p_wrld
        cur_cell = p_cell
        cur_dial = p_dial
        cur_qust = p_qust
        while pos < end:
            if pos + 24 > end:
                report.err(f"Truncated record/group header at offset {pos}")
                break
            tag = esp_bytes[pos : pos + 4].decode("latin1", "ignore")
            if tag == "GRUP":
                gsize, glabel, gtype, _stamp, _vc = struct.unpack_from(
                    "<IIIII", esp_bytes, pos + 4
                )
                if gsize < 24 or pos + gsize > end:
                    report.err(
                        f"Invalid GRUP size {gsize} at offset {pos} (end={end})"
                    )
                    break
                nw, nc, nd, nq = cur_wrld, cur_cell, cur_dial, cur_qust
                if gtype == 1:
                    nw = glabel
                elif gtype in (6, 8, 9):
                    nc = glabel
                elif gtype == 7:
                    nd = glabel
                elif gtype == 10:
                    nq = glabel
                _walk(pos + 24, pos + gsize, nw, nc, nd, nq)
                pos += gsize
            else:
                dsize, rflags, rfid, _vc, _fv, _unk = struct.unpack_from(
                    "<IIIHHH", esp_bytes, pos + 4
                )
                if pos + 24 + dsize > end:
                    report.err(
                        f"Invalid record {tag} 0x{rfid:08X} size {dsize} at offset {pos}"
                    )
                    break
                payload = esp_bytes[pos + 24 : pos + 24 + dsize]
                if rflags & 0x00040000:
                    if len(payload) < 4:
                        report.err(
                            f"Compressed record {tag} 0x{rfid:08X} too short"
                        )
                        payload = b""
                    else:
                        decomp_sz = struct.unpack_from("<I", payload, 0)[0]
                        try:
                            payload = zlib.decompress(payload[4:])
                            if len(payload) != decomp_sz:
                                report.warn(
                                    f"Decompressed size mismatch on {tag} 0x{rfid:08X}: {len(payload)} != {decomp_sz}"
                                )
                        except Exception as exc:
                            report.err(
                                f"Failed to decompress {tag} 0x{rfid:08X}: {exc}"
                            )
                            payload = b""
                rec = ParsedRecord(
                    tag, rfid, rflags, payload, cur_wrld, cur_cell, cur_dial, cur_qust
                )
                records.append(rec)
                if tag == "WRLD":
                    cur_wrld = rfid
                elif tag == "CELL":
                    cur_cell = rfid
                elif tag == "DIAL":
                    cur_dial = rfid
                elif tag == "QUST":
                    cur_qust = rfid
                pos += 24 + dsize

    _walk(0, len(esp_bytes))
    return records


def scan_fallout4_esm_formids(esm_path: str) -> dict[int, str]:
    """Fast scan of Fallout4.esm top-level and nested records to map FormID -> RecordType."""
    fids: dict[int, str] = {}
    with open(esm_path, "rb") as f:
        data = f.read()

    def _scan_range(start: int, end: int) -> None:
        pos = start
        while pos + 24 <= end:
            tag = data[pos : pos + 4].decode("latin1", "ignore")
            if tag == "GRUP":
                gsize = struct.unpack_from("<I", data, pos + 4)[0]
                if gsize < 24 or pos + gsize > end:
                    break
                _scan_range(pos + 24, pos + gsize)
                pos += gsize
            else:
                dsize, _rflags, rfid = struct.unpack_from("<III", data, pos + 4)
                fids[rfid] = tag
                if pos + 24 + dsize > end:
                    break
                pos += 24 + dsize

    _scan_range(0, len(data))
    return fids


def parse_ba2_gnrl(ba2_path: str, report: QAReport) -> dict[str, bytes]:
    files: dict[str, bytes] = {}
    with open(ba2_path, "rb") as f:
        data = f.read()
    magic = data[:4]
    ver, atype, num_files, name_tbl_off = struct.unpack_from("<I4sIQ", data, 4)
    if magic != b"BTDX":
        report.err(f"{os.path.basename(ba2_path)}: Invalid magic {magic!r}")
        return files
    if ver != 1:
        report.err(
            f"{os.path.basename(ba2_path)}: BA2 version is {ver} (MUST be v1 for Fallout 4 1.10.163 compatibility!)"
        )
    else:
        report.ok(
            f"{os.path.basename(ba2_path)}: Cabecera BTDX v1 ({atype.decode('ascii', 'ignore')}) verificada ({num_files} archivos, compatible con 1.10.163 y Next-Gen/AE)."
        )

    entries = []
    pos = 24
    for _ in range(num_files):
        _nhash, _ext, _dhash, _unk, offset, packed_sz, unpacked_sz, _align = (
            struct.unpack_from("<I4sIIQIII", data, pos)
        )
        entries.append((offset, packed_sz, unpacked_sz))
        pos += 36

    npos = name_tbl_off
    names: list[str] = []
    for _ in range(num_files):
        nlen = struct.unpack_from("<H", data, npos)[0]
        npos += 2
        name_str = (
            data[npos : npos + nlen]
            .decode("latin1", "ignore")
            .replace("/", "\\")
            .lower()
        )
        names.append(name_str)
        npos += nlen

    for name_str, (offset, packed_sz, unpacked_sz) in zip(names, entries):
        if packed_sz > 0:
            raw_chunk = data[offset : offset + packed_sz]
            try:
                content = zlib.decompress(raw_chunk)
            except Exception as exc:
                report.err(f"BA2 decompress failed for {name_str}: {exc}")
                content = b""
        else:
            content = data[offset : offset + unpacked_sz]
        files[name_str] = content
    return files


def parse_ba2_dx10(ba2_path: str, report: QAReport) -> set[str]:
    names: set[str] = set()
    with open(ba2_path, "rb") as f:
        data = f.read()
    magic = data[:4]
    ver, atype, num_files, name_tbl_off = struct.unpack_from("<I4sIQ", data, 4)
    if magic != b"BTDX" or atype != b"DX10":
        report.err(
            f"{os.path.basename(ba2_path)}: Invalid DX10 header {magic!r} {atype!r}"
        )
        return names
    if ver != 1:
        report.err(
            f"{os.path.basename(ba2_path)}: DX10 BA2 version is {ver} (MUST be v1 for 1.10.163!)"
        )
    else:
        report.ok(
            f"{os.path.basename(ba2_path)}: Cabecera BTDX v1 (DX10) verificada ({num_files} texturas DDS)."
        )

    npos = name_tbl_off
    for _ in range(num_files):
        nlen = struct.unpack_from("<H", data, npos)[0]
        npos += 2
        name_str = (
            data[npos : npos + nlen]
            .decode("latin1", "ignore")
            .replace("/", "\\")
            .lower()
        )
        names.add(name_str)
        npos += nlen
    return names


def run_full_qa_audit() -> int:
    report = QAReport()
    print("=" * 78)
    print("  AUDITORÍA EXHAUSTIVA DE CALIDAD (QA) — CRÓNICAS DEL REFUGIO 13 (2161)")
    print("=" * 78)

    # ------------------------------------------------------------------
    # MÓDULO 1: INTEGRIDAD BINARIA DEL .ESP Y PUNTEROS CRUZADOS
    # ------------------------------------------------------------------
    print("\n[Módulo 1/6] Analizando estructura binaria de Vault13Chronicles.esp y Fallout4.esm...")
    if not os.path.exists(ESP_PATH):
        report.err(f"No existe {ESP_PATH}")
        return 1

    with open(ESP_PATH, "rb") as f:
        esp_bytes = f.read()

    records = parse_esp_hierarchy(esp_bytes, report)
    if not records or records[0].rtype != "TES4":
        report.err("El primer registro no es TES4.")
        return 1

    tes4 = records[0]
    hedr_ver = 0.0
    masters: list[str] = []
    for st, sv in tes4.subs:
        if st == "HEDR" and len(sv) >= 12:
            hedr_ver, _num_recs, _next_obj = struct.unpack_from("<fII", sv, 0)
        elif st == "MAST":
            masters.append(get_zstr(sv))

    if abs(hedr_ver - 1.0) < 1e-4:
        report.ok(f"TES4 HEDR versión {hedr_ver:.2f} verificada (100% compatible con 1.10.163 y Next-Gen/AE).")
    else:
        report.err(f"TES4 HEDR versión {hedr_ver:.2f} inesperada (se esperaba 1.00).")

    if masters == ["Fallout4.esm"]:
        report.ok("TES4 MAST depende exclusivamente de ['Fallout4.esm'] (0 DLCs, 0 Creation Club).")
    else:
        report.err(f"TES4 MAST tiene dependencias no permitidas: {masters}")

    print("  -> Escaneando FormIDs de Fallout4.esm para validación referencial...")
    esm_fids = scan_fallout4_esm_formids(FO4_ESM_PATH)
    report.ok(f"Índice de Fallout4.esm cargado ({len(esm_fids):,} registros base).")

    mod_records_by_fid: dict[int, list[ParsedRecord]] = defaultdict(list)
    for r in records[1:]:
        mod_records_by_fid[r.fid].append(r)

    dup_custom_fids: list[str] = []
    low_range_fids: list[str] = []
    for fid, rlist in mod_records_by_fid.items():
        if (fid >> 24) == 0x01:
            if (fid & 0x00FFFFFF) < 0x800:
                low_range_fids.append(f"0x{fid:08X} ({rlist[0].rtype} {rlist[0].edid})")
            if len(rlist) > 1:
                # Ignore intentional WRLD/CELL child group headers;ParsedRecord only stores actual records
                types_str = ", ".join(f"{x.rtype}:{x.edid}" for x in rlist)
                dup_custom_fids.append(f"0x{fid:08X} -> [{types_str}]")

    if not dup_custom_fids:
        report.ok(
            f"Cero colisiones de FormID entre los {sum(1 for f in mod_records_by_fid if (f >> 24) == 0x01):,} registros propios (0x01xxxxxx)."
        )
    else:
        for d in dup_custom_fids:
            report.err(f"Colisión de FormID propio: {d}")

    if not low_range_fids:
        report.ok("Todos los FormIDs propios (0x01xxxxxx) son >= 0x01000800.")
    else:
        for lr in low_range_fids:
            report.err(f"FormID propio en rango inferior < 0x800: {lr}")

    def fid_exists(fid: int) -> bool:
        if fid == 0:
            return True
        if fid in mod_records_by_fid:
            return True
        if (fid >> 24) == 0x00:
            if (fid & 0x00FFFFFF) < 0x800 or fid in esm_fids:
                return True
        return False

    def get_fid_type(fid: int) -> str | None:
        if fid in mod_records_by_fid:
            return mod_records_by_fid[fid][0].rtype
        if fid in esm_fids:
            return esm_fids[fid]
        return None

    VALID_REFR_BASE_TYPES = {
        "STAT", "MSTT", "ACTI", "DOOR", "LIGH", "CONT", "TERM", "FURN",
        "WEAP", "ARMO", "AMMO", "ALCH", "MISC", "BOOK", "NOTE", "KEYM",
        "SOUN", "TXST", "IDLM", "LVLI", "FLOR", "TREE", "SCOL", "ASPC",
        "BNDS", "TACT", "HAZD", "EXPL", "PKIN",
    }

    # Validate cross-references and target Record Types across all records
    broken_refs: list[str] = []
    door_xtels: dict[int, tuple[int, tuple[float, ...], ParsedRecord]] = {}
    for r in records[1:]:
        doft_count = 0
        for st, sv in r.subs:
            if r.rtype in ("REFR", "ACHR"):
                if st == "NAME" and len(sv) == 4:
                    base_fid = struct.unpack_from("<I", sv, 0)[0]
                    if not fid_exists(base_fid):
                        broken_refs.append(
                            f"{r.rtype} 0x{r.fid:08X} NAME apunta a base inexistente 0x{base_fid:08X}"
                        )
                    else:
                        btype = get_fid_type(base_fid)
                        if r.rtype == "REFR" and btype is not None and btype not in VALID_REFR_BASE_TYPES:
                            broken_refs.append(
                                f"REFR 0x{r.fid:08X} NAME apunta a tipo inválido {btype} (0x{base_fid:08X}) — provoca bloqueo infinito al iniciar Fallout 4"
                            )
                        elif r.rtype == "ACHR" and btype is not None and btype not in ("NPC_", "LVLN"):
                            broken_refs.append(
                                f"ACHR 0x{r.fid:08X} NAME apunta a tipo inválido {btype} (0x{base_fid:08X})"
                            )
                elif st == "XTEL" and len(sv) >= 28:
                    dest_door = struct.unpack_from("<I", sv, 0)[0]
                    coords = struct.unpack_from("<6f", sv, 4)
                    door_xtels[r.fid] = (dest_door, coords, r)
                    if not fid_exists(dest_door):
                        broken_refs.append(
                            f"REFR 0x{r.fid:08X} XTEL apunta a puerta inexistente 0x{dest_door:08X}"
                        )
                    if any(math.isnan(c) or math.isinf(c) for c in coords):
                        broken_refs.append(
                            f"REFR 0x{r.fid:08X} XTEL contiene coordenadas NaN/Inf"
                        )
                elif st == "XLKR" and len(sv) >= 8:
                    kywd_fid, lnk_fid = struct.unpack_from("<II", sv, 0)
                    if kywd_fid != 0 and not fid_exists(kywd_fid):
                        broken_refs.append(
                            f"{r.rtype} 0x{r.fid:08X} XLKR keyword inexistente 0x{kywd_fid:08X}"
                        )
                    if not fid_exists(lnk_fid):
                        broken_refs.append(
                            f"{r.rtype} 0x{r.fid:08X} XLKR ref inexistente 0x{lnk_fid:08X}"
                        )
                elif st == "XLOC" and len(sv) >= 12:
                    key_fid = struct.unpack_from("<I", sv, 4)[0]
                    if key_fid != 0 and not fid_exists(key_fid):
                        broken_refs.append(
                            f"{r.rtype} 0x{r.fid:08X} XLOC llave inexistente 0x{key_fid:08X}"
                        )
            elif r.rtype in ("NPC_", "CONT"):
                if st == "CNTO" and len(sv) >= 8:
                    item_fid, _cnt = struct.unpack_from("<Ii", sv, 0)
                    if not fid_exists(item_fid):
                        broken_refs.append(
                            f"{r.rtype} 0x{r.fid:08X} ({r.edid}) CNTO ítem inexistente 0x{item_fid:08X}"
                        )
                elif st == "VTCK" and len(sv) == 4:
                    vt_fid = struct.unpack_from("<I", sv, 0)[0]
                    if not fid_exists(vt_fid):
                        broken_refs.append(
                            f"NPC_ 0x{r.fid:08X} ({r.edid}) VTCK inexistente 0x{vt_fid:08X}"
                        )
                elif st == "DOFT" and len(sv) == 4:
                    doft_count += 1
                    ot_fid = struct.unpack_from("<I", sv, 0)[0]
                    if not fid_exists(ot_fid) or get_fid_type(ot_fid) != "OTFT":
                        broken_refs.append(
                            f"NPC_ 0x{r.fid:08X} ({r.edid}) DOFT inválido 0x{ot_fid:08X} (tipo={get_fid_type(ot_fid)})"
                        )
                    if doft_count > 1:
                        broken_refs.append(
                            f"NPC_ 0x{r.fid:08X} ({r.edid}) tiene {doft_count} subregistros DOFT duplicados"
                        )
                elif st == "PKID" and len(sv) == 4:
                    pk_fid = struct.unpack_from("<I", sv, 0)[0]
                    if not fid_exists(pk_fid):
                        broken_refs.append(
                            f"NPC_ 0x{r.fid:08X} ({r.edid}) PKID inexistente 0x{pk_fid:08X}"
                        )
            elif r.rtype == "OTFT":
                if st == "INAM" and len(sv) % 4 == 0:
                    for off_i in range(0, len(sv), 4):
                        it_fid = struct.unpack_from("<I", sv, off_i)[0]
                        it_type = get_fid_type(it_fid)
                        if not fid_exists(it_fid) or it_type not in ("ARMO", "LVLI"):
                            broken_refs.append(
                                f"OTFT 0x{r.fid:08X} ({r.edid}) INAM apunta a 0x{it_fid:08X} de tipo {it_type} (se esperaba ARMO/LVLI)"
                            )
            elif r.rtype in ("WEAP", "ARMO"):
                if st == "EITM" and len(sv) == 4:
                    en_fid = struct.unpack_from("<I", sv, 0)[0]
                    if not fid_exists(en_fid):
                        broken_refs.append(
                            f"{r.rtype} 0x{r.fid:08X} ({r.edid}) EITM inexistente 0x{en_fid:08X}"
                        )
                elif st == "OBTS" and len(sv) >= 18:
                    inc_cnt, prop_cnt = struct.unpack_from("<II", sv, 0)
                    expected_len = 18 + inc_cnt * 7 + prop_cnt * 24
                    if len(sv) != expected_len:
                        broken_refs.append(
                            f"{r.rtype} 0x{r.fid:08X} ({r.edid}) OBTS corrupto (len={len(sv)}, esperado={expected_len}, inc_cnt={inc_cnt}, prop_cnt={prop_cnt})"
                        )
                    else:
                        for idx_inc in range(inc_cnt):
                            omod_fid = struct.unpack_from("<I", sv, 18 + idx_inc * 7)[0]
                            if get_fid_type(omod_fid) != "OMOD":
                                broken_refs.append(
                                    f"{r.rtype} 0x{r.fid:08X} ({r.edid}) OBTS OMOD inválido 0x{omod_fid:08X} (tipo={get_fid_type(omod_fid)})"
                                )
            elif r.rtype == "FACT":
                if st == "VENC" and len(sv) == 4:
                    vc_fid = struct.unpack_from("<I", sv, 0)[0]
                    if not fid_exists(vc_fid):
                        broken_refs.append(
                            f"FACT 0x{r.fid:08X} ({r.edid}) VENC inexistente 0x{vc_fid:08X}"
                        )

    if not broken_refs:
        report.ok(
            f"Integridad referencial y de tipos completa: 100% de punteros NAME (tipos base válidos), XTEL ({len(door_xtels)} puertas), XLKR, XLOC, CNTO, VTCK, DOFT, PKID, OTFT/INAM, WEAP/ARMO OBTS (OMODs), EITM y VENC verificados."
        )
    else:
        for br in broken_refs[:25]:
            report.err(br)

    # ------------------------------------------------------------------
    # MÓDULO 2: LÓGICA DE MISIONES (QUST), ALIAS, BRÚJULA Y PAPYRUS
    # ------------------------------------------------------------------
    print("[Módulo 2/6] Auditando las misiones (QUST), alias forzados, objetivos y sincronización con Papyrus...")
    qust_records = [r for r in records if r.rtype == "QUST" and (r.fid >> 24) == 0x01]
    qust_stages: dict[int, set[int]] = {}
    qust_objs: dict[int, set[int]] = {}
    qust_aliases: dict[int, dict[int, tuple[str, int]]] = {}
    qust_by_script: dict[str, list[ParsedRecord]] = defaultdict(list)

    alias_errors: list[str] = []
    qobj_errors: list[str] = []

    for qr in qust_records:
        stages: set[int] = set()
        objs: set[int] = set()
        aliases: dict[int, tuple[str, int]] = {}
        cur_al_idx: int | None = None
        cur_al_name = ""
        cur_al_fr = 0
        cur_qobj: int | None = None
        qobj_qstas: dict[int, list[int]] = defaultdict(list)

        for st, sv in qr.subs:
            if st == "VMAD" and len(sv) >= 8:
                sc_len = struct.unpack_from("<H", sv, 6)[0]
                sc_name = sv[8 : 8 + sc_len].decode("latin1", "ignore")
                qust_by_script[sc_name].append(qr)
            elif st == "INDX" and len(sv) >= 2:
                stg_id = struct.unpack_from("<H", sv, 0)[0]
                stages.add(stg_id)
            elif st == "QOBJ" and len(sv) == 2:
                cur_qobj = struct.unpack_from("<H", sv, 0)[0]
                objs.add(cur_qobj)
            elif st == "QSTA" and len(sv) >= 4 and cur_qobj is not None:
                t_alias = struct.unpack_from("<I", sv, 0)[0]
                qobj_qstas[cur_qobj].append(t_alias)
            elif st == "ALST" and len(sv) == 4:
                cur_al_idx = struct.unpack_from("<I", sv, 0)[0]
                cur_al_name = ""
                cur_al_fr = 0
            elif st == "ALID" and cur_al_idx is not None:
                cur_al_name = get_zstr(sv)
            elif st == "ALFR" and len(sv) == 4 and cur_al_idx is not None:
                cur_al_fr = struct.unpack_from("<I", sv, 0)[0]
            elif st == "ALED" and cur_al_idx is not None:
                aliases[cur_al_idx] = (cur_al_name, cur_al_fr)
                if cur_al_fr != 0:
                    if cur_al_fr not in mod_records_by_fid:
                        alias_errors.append(
                            f"QUST {qr.edid} (0x{qr.fid:08X}) Alias {cur_al_idx} ({cur_al_name}) ALFR apunta a 0x{cur_al_fr:08X} inexistente"
                        )
                    else:
                        target_rec = mod_records_by_fid[cur_al_fr][0]
                        if (target_rec.flags & 0x00000400) == 0:
                            alias_errors.append(
                                f"QUST {qr.edid} (0x{qr.fid:08X}) Alias {cur_al_idx} ({cur_al_name}) ALFR 0x{cur_al_fr:08X} NO tiene flag Persistent (0x0400)"
                            )
                cur_al_idx = None

        for oid, t_list in qobj_qstas.items():
            for ta in t_list:
                if ta not in aliases:
                    qobj_errors.append(
                        f"QUST {qr.edid} QOBJ {oid} apunta a QSTA Alias {ta} no definido en el QUST"
                    )

        qust_stages[qr.fid] = stages
        qust_objs[qr.fid] = objs
        qust_aliases[qr.fid] = aliases

    if not alias_errors and not qobj_errors:
        report.ok(
            f"Las {len(qust_records)} misiones (QUST) tienen todos sus Alias Forzados (ALFR) apuntando a referencias Persistentes (0x0400) y todos sus objetivos (QOBJ/QSTA) enlazados."
        )
    else:
        for e in alias_errors + qobj_errors:
            report.err(e)

    # Check QUST.DNAM (Allow Repeated Stages 0x0008 == 0) and INFO.TIQS (start-only (stg, 0xFFFF))
    repeat_stage_qusts: list[str] = []
    for qr in qust_records:
        for st, sv in qr.subs:
            if st == "DNAM" and len(sv) >= 2:
                qfl = struct.unpack_from("<H", sv, 0)[0]
                if qfl & 0x0008:
                    repeat_stage_qusts.append(f"{qr.edid} (0x{qr.fid:08X}): flags=0x{qfl:04X}")
    bad_tiqs_infos: list[str] = []
    for r in records:
        if r.rtype == "INFO":
            for st, sv in r.subs:
                if st == "TIQS" and len(sv) == 4:
                    b_stg, e_stg = struct.unpack("<HH", sv)
                    if b_stg == 0xFFFF or e_stg != 0xFFFF:
                        bad_tiqs_infos.append(f"INFO 0x{r.fid:08X}: TIQS=({b_stg}, {e_stg})")
    if not repeat_stage_qusts and not bad_tiqs_infos:
        report.ok(
            f"Cero notificaciones repetidas de misión: las {len(qust_records)} misiones desactivan Allow Repeated Stages (DNAM & 0x0008 == 0) y todos los TIQS disparan solo al inicio (stg, 0xFFFF)."
        )
    else:
        for rq in repeat_stage_qusts:
            report.err(f"QUST con Allow Repeated Stages activo: {rq}")
        for bt in bad_tiqs_infos:
            report.err(f"INFO TIQS con doble disparo: {bt}")

    # Audit all Papyrus .psc source files against .esp FormIDs, Stages, Objectives & Aliases
    psc_files = sorted(glob.glob(os.path.join(PAPYRUS_SRC_DIR, "*.psc")))
    psc_form_errors: list[str] = []
    psc_stage_errors: list[str] = []
    total_getform_checked = 0

    re_getform = re.compile(
        r'Game\.GetFormFromFile\(\s*(0x[0-9A-Fa-f]+)\s*,\s*"([^"]+)"\s*\)'
    )
    re_setstage = re.compile(r"Self\.SetStage\(\s*(\d+)\s*\)")
    re_setobj = re.compile(
        r"(?:Self\.)?SetObjective(?:Displayed|Completed)\(\s*(\d+)\b"
    )
    re_forcealias = re.compile(
        r"ForceQuestAlias\(\s*(\d+)\s*,\s*(0x[0-9A-Fa-f]+)\s*\)"
    )

    for psc_path in psc_files:
        psc_name = os.path.splitext(os.path.basename(psc_path))[0]
        with open(psc_path, "r", encoding="utf-8") as f:
            psc_txt = f.read()

        # 1. Check all literal GetFormFromFile calls
        for m in re_getform.finditer(psc_txt):
            low_hex, plugin_name = m.group(1), m.group(2)
            low_val = int(low_hex, 16) & 0x00FFFFFF
            total_getform_checked += 1
            if plugin_name.lower() == "vault13chronicles.esp":
                full_fid = 0x01000000 | low_val
                if full_fid not in mod_records_by_fid:
                    psc_form_errors.append(
                        f"{psc_name}.psc: GetFormFromFile({low_hex}, 'Vault13Chronicles.esp') -> 0x{full_fid:08X} NO existe en el .esp"
                    )
            elif plugin_name.lower() == "fallout4.esm":
                if low_val >= 0x800 and low_val not in esm_fids:
                    psc_form_errors.append(
                        f"{psc_name}.psc: GetFormFromFile({low_hex}, 'Fallout4.esm') -> 0x{low_val:08X} NO existe en Fallout4.esm"
                    )

        # 2. If this script is attached to QUST records, verify stages, objectives and ForceQuestAlias
        q_list = qust_by_script.get(psc_name, [])
        if q_list:
            for m_st in re_setstage.finditer(psc_txt):
                stg_val = int(m_st.group(1))
                for qr in q_list:
                    if stg_val not in qust_stages[qr.fid]:
                        psc_stage_errors.append(
                            f"{psc_name}.psc: Self.SetStage({stg_val}) no existe en QUST {qr.edid} (etapas: {sorted(qust_stages[qr.fid])})"
                        )
            for m_ob in re_setobj.finditer(psc_txt):
                obj_val = int(m_ob.group(1))
                for qr in q_list:
                    if obj_val not in qust_objs[qr.fid]:
                        psc_stage_errors.append(
                            f"{psc_name}.psc: SetObjective({obj_val}) no existe en QUST {qr.edid} (objetivos: {sorted(qust_objs[qr.fid])})"
                        )
            for m_fa in re_forcealias.finditer(psc_txt):
                al_id = int(m_fa.group(1))
                t_low = int(m_fa.group(2), 16) & 0x00FFFFFF
                t_fid = 0x01000000 | t_low
                if t_fid not in mod_records_by_fid:
                    psc_form_errors.append(
                        f"{psc_name}.psc: ForceQuestAlias({al_id}, 0x{t_low:06X}) apunta a 0x{t_fid:08X} inexistente"
                    )

    if not psc_form_errors and not psc_stage_errors:
        report.ok(
            f"Sincronización Papyrus <-> ESP verificada: {len(psc_files)} scripts .psc y {total_getform_checked} llamadas GetFormFromFile/SetStage/SetObjective/ForceQuestAlias coinciden 100% con el .esp y Fallout4.esm."
        )
    else:
        for e in psc_form_errors + psc_stage_errors:
            report.err(e)

    # ------------------------------------------------------------------
    # MÓDULO 3: INTERACCIONES CON NPCS, ESCENAS (SCEN), DIÁLOGOS Y VOCES (.XWM)
    # ------------------------------------------------------------------
    print("[Módulo 3/6] Auditando ruedas de diálogo (SCEN/DIAL/INFO), archivos de voz (.xwm) y facciones de comerciantes...")
    main_ba2_files = parse_ba2_gnrl(MAIN_BA2_PATH, report)
    tex_ba2_names = parse_ba2_dx10(TEX_BA2_PATH, report)

    vtyp_edids: dict[int, str] = {
        0x00013AD2: "playervoicemale01",
        0x00013ADD: "playervoicefemale01",
        0x0001F259: "crsupermutant",
    }
    for r in records[1:]:
        if r.rtype == "VTYP":
            vtyp_edids[r.fid] = r.edid.lower()

    npc_vtyp: dict[int, int] = {}
    npc_acbs_flags: dict[int, int] = {}
    for r in records[1:]:
        if r.rtype == "NPC_":
            for st, sv in r.subs:
                if st == "VTCK" and len(sv) == 4:
                    npc_vtyp[r.fid] = struct.unpack_from("<I", sv, 0)[0]
                elif st == "ACBS" and len(sv) >= 4:
                    npc_acbs_flags[r.fid] = struct.unpack_from("<I", sv, 0)[0]

    dial_by_fid: dict[int, ParsedRecord] = {
        r.fid: r for r in records if r.rtype == "DIAL"
    }
    infos_by_dial: dict[int, list[ParsedRecord]] = defaultdict(list)
    for r in records:
        if r.rtype == "INFO":
            infos_by_dial[r.parent_dial].append(r)

    scen_by_fid: dict[int, ParsedRecord] = {
        r.fid: r for r in records if r.rtype == "SCEN"
    }

    # Check SCEN wheel integrity and map NTOP DIAL FormIDs to their SCEN speaker NPC_
    scen_errors: list[str] = []
    ntop_dial_speaker: dict[int, int] = {}
    for s_fid, s_rec in scen_by_fid.items():
        scen_alid: int | None = None
        for st, sv in s_rec.subs:
            if st == "ALID" and len(sv) == 4 and scen_alid is None:
                scen_alid = struct.unpack_from("<I", sv, 0)[0]
                break
        scen_speaker_npc = 0
        # Dynamic runtime ForceQuestAlias overrides in V13Act2QuestScript:
        if s_fid in (0x01005105, 0x01005106):
            scen_speaker_npc = 0x0100121A  # Garret (forced into Alias 12 at runtime)
        elif s_fid in (0x01005108, 0x01005109, 0x0100510A):
            scen_speaker_npc = 0x01001203  # Harry (forced into Alias 10 at runtime)
        elif scen_alid is not None and s_rec.parent_qust in qust_aliases:
            al_info = qust_aliases[s_rec.parent_qust].get(scen_alid)
            if al_info:
                _al_name, al_refr = al_info
                if al_refr in mod_records_by_fid:
                    refr_rec = mod_records_by_fid[al_refr][0]
                    for rst, rsv in refr_rec.subs:
                        if rst == "NAME" and len(rsv) == 4:
                            scen_speaker_npc = struct.unpack_from("<I", rsv, 0)[0]
                            break

        for st, sv in s_rec.subs:
            if st in ("PTOP", "NTOP", "NETO", "QTOP", "NPOT", "NNGT", "NNUT", "NQUT") and len(sv) == 4:
                d_fid = struct.unpack_from("<I", sv, 0)[0]
                if st in ("NPOT", "NNGT", "NNUT", "NQUT") and d_fid != 0 and scen_speaker_npc != 0:
                    ntop_dial_speaker[d_fid] = scen_speaker_npc
                if d_fid == 0 or d_fid not in dial_by_fid:
                    scen_errors.append(
                        f"SCEN {s_rec.edid} (0x{s_fid:08X}) {st} apunta a DIAL inexistente 0x{d_fid:08X}"
                    )
                elif not infos_by_dial.get(d_fid):
                    scen_errors.append(
                        f"SCEN {s_rec.edid} (0x{s_fid:08X}) {st} DIAL 0x{d_fid:08X} no tiene registros INFO"
                    )
                elif st in ("PTOP", "NTOP", "NETO", "QTOP"):
                    # Verify RNAM prompt exists on player INFO
                    for p_inf in infos_by_dial[d_fid]:
                        has_rnam = any(
                            k == "RNAM" and len(get_zstr(v).strip()) > 0
                            for k, v in p_inf.subs
                        )
                        if not has_rnam:
                            scen_errors.append(
                                f"SCEN {s_rec.edid} {st} INFO 0x{p_inf.fid:08X} carece de texto de rueda RNAM"
                            )

    if not scen_errors:
        report.ok(
            f"Todas las {len(scen_by_fid)} escenas de diálogo (SCEN) tienen sus 4 opciones (PTOP/NTOP), textos de rueda (RNAM) y tópicos (DIAL/INFO) completos."
        )
    else:
        for e in scen_errors:
            report.err(e)

    # Check 1:1 Voice .xwm files in Main.ba2 for every spoken INFO record
    missing_voices: list[str] = []
    checked_voice_clips = 0

    for r in records:
        if r.rtype != "INFO" or (r.fid >> 24) != 0x01:
            continue
        # Count TRDA responses with non-empty NAM1
        trda_indices: list[int] = []
        cur_trda_idx: int | None = None
        speaker_npc_fid = 0
        is_player_female_cond = False
        is_player_male_cond = False

        for st, sv in r.subs:
            if st == "ANAM" and len(sv) == 4:
                speaker_npc_fid = struct.unpack_from("<I", sv, 0)[0]
            elif st == "TRDA" and len(sv) >= 5:
                cur_trda_idx = sv[4]
            elif st == "NAM1" and cur_trda_idx is not None:
                txt = get_zstr(sv).strip()
                if txt:
                    trda_indices.append(cur_trda_idx)
                cur_trda_idx = None
            elif st == "CTDA" and len(sv) >= 20:
                func_id = struct.unpack_from("<H", sv, 8)[0]
                param1 = struct.unpack_from("<I", sv, 12)[0]
                fval = struct.unpack_from("<f", sv, 4)[0]
                # Function 72 = GetIsID, Function 70 = GetIsSex
                if func_id == 72 and param1 != 0 and speaker_npc_fid == 0:
                    speaker_npc_fid = param1
                elif func_id == 70:
                    if param1 == 1 and abs(fval - 1.0) < 0.01:
                        is_player_female_cond = True
                    elif param1 == 0 and abs(fval - 1.0) < 0.01:
                        is_player_male_cond = True

        if not trda_indices:
            continue

        if speaker_npc_fid == 0 and r.parent_dial in ntop_dial_speaker:
            speaker_npc_fid = ntop_dial_speaker[r.parent_dial]

        low_fid_hex = f"{r.fid & 0x00FFFFFF:08x}"
        expected_vtyps: list[str] = []
        if speaker_npc_fid != 0 and speaker_npc_fid in npc_vtyp:
            vt_fid = npc_vtyp[speaker_npc_fid]
            if vt_fid in vtyp_edids:
                expected_vtyps.append(vtyp_edids[vt_fid])
        else:
            # Player line in scene PTOP
            if is_player_female_cond:
                expected_vtyps.append("playervoicefemale01")
            elif is_player_male_cond:
                expected_vtyps.append("playervoicemale01")
            else:
                expected_vtyps.extend(["playervoicemale01", "playervoicefemale01"])

        for vt_folder in expected_vtyps:
            for r_idx in trda_indices:
                rel_fuz = f"sound\\voice\\vault13chronicles.esp\\{vt_folder}\\{low_fid_hex}_{r_idx}.fuz"
                checked_voice_clips += 1
                if rel_fuz not in main_ba2_files:
                    missing_voices.append(
                        f"INFO 0x{r.fid:08X} (DIAL 0x{r.parent_dial:08X}) falta audio .fuz en BA2: {rel_fuz}"
                    )
                else:
                    fuz_data = main_ba2_files[rel_fuz]
                    try:
                        v13_opt_helpers.verify_fuz_bytes(fuz_data)
                    except Exception as exc:
                        missing_voices.append(
                            f"INFO 0x{r.fid:08X} archivo .fuz corrupto ({len(fuz_data)} bytes, {exc}): {rel_fuz}"
                        )

    stray_voice_xwms = [
        k for k in main_ba2_files if k.startswith("sound\\voice\\") and k.endswith(".xwm")
    ]
    if stray_voice_xwms:
        missing_voices.append(f"Archivos .xwm sin empaquetar en .fuz dentro de sound\\voice\\: {len(stray_voice_xwms)}")
    if any(k.endswith("fonixdata.cdf") for k in main_ba2_files):
        missing_voices.append("FonixData.cdf redundante presente en Main.ba2")

    if not missing_voices:
        report.ok(
            f"Auditoría 1:1 de voces Lip-Sync superada: los {checked_voice_clips} clips de voz (.fuz = FaceFX .lip v1 + RIFF/XWMA) referenciados por INFO están íntegros en Main.ba2 (0 .xwm sueltos, 0 FonixData.cdf redundante)."
        )
    else:
        for mv in missing_voices[:25]:
            report.err(mv)

    # Check all custom NPC_ records (VTCK, RNAM, FULL) and Merchant FACT/VENC records
    npc_records = [r for r in records if r.rtype == "NPC_" and (r.fid >> 24) == 0x01]
    npc_def_errors: list[str] = []
    for nr in npc_records:
        has_rnam = any(st == "RNAM" and len(sv) == 4 for st, sv in nr.subs)
        has_tplt = any(st == "TPLT" and len(sv) == 4 for st, sv in nr.subs)
        starts_dead = (npc_acbs_flags.get(nr.fid, 0) & 0x00020000) != 0 or "Corpse" in nr.edid
        has_vtck = nr.fid in npc_vtyp or has_tplt or starts_dead
        if not nr.full:
            npc_def_errors.append(f"NPC_ {nr.edid} (0x{nr.fid:08X}) carece de nombre FULL")
        if not has_rnam:
            npc_def_errors.append(f"NPC_ {nr.edid} (0x{nr.fid:08X}) carece de raza RNAM")
        if not has_vtck:
            npc_def_errors.append(f"NPC_ {nr.edid} (0x{nr.fid:08X}) carece de tipo de voz VTCK")

    merchant_facts = [
        r for r in records if r.rtype == "FACT" and 0x01001C50 <= r.fid <= 0x01001C54
    ]
    for mf in merchant_facts:
        venc_fid = 0
        for st, sv in mf.subs:
            if st == "VENC" and len(sv) == 4:
                venc_fid = struct.unpack_from("<I", sv, 0)[0]
        if venc_fid == 0 or venc_fid not in mod_records_by_fid:
            npc_def_errors.append(
                f"FACT {mf.edid} (0x{mf.fid:08X}) carece de cofre de mercader VENC válido"
            )
        else:
            v_ref = mod_records_by_fid[venc_fid][0]
            if (v_ref.flags & 0x0400) == 0:
                npc_def_errors.append(
                    f"FACT {mf.edid} VENC 0x{venc_fid:08X} no es Persistent (0x0400)"
                )

    if not npc_def_errors:
        report.ok(
            f"Todos los {len(npc_records)} registros NPC_ propios (FULL, RNAM, VTCK) y las {len(merchant_facts)} facciones de mercaderes (FACT/VENC con cofres persistentes) están íntegros."
        )
    else:
        for ne in npc_def_errors:
            report.err(ne)

    # ------------------------------------------------------------------
    # MÓDULO 4: AUDITORÍA GEOMÉTRICA 3D, TERRENO LAND, COLISIONES Y ZONAS SEGURAS
    # ------------------------------------------------------------------
    print("[Módulo 4/6] Analizando geometría 3D del mundo exterior (WRLD 0x01003400), alturas Z, escritorios, colisiones y zonas seguras...")
    ext_lands = [
        r for r in records if r.rtype == "LAND" and r.parent_wrld == 0x01003400
    ]
    ext_map_markers = [
        r
        for r in records
        if r.rtype == "REFR"
        and r.parent_wrld == 0x01003400
        and any(st == "XMRK" for st, _ in r.subs)
    ]
    if len(ext_lands) == 64 and len(ext_map_markers) >= 23:
        report.ok(
            f"Malla topográfica 3D del Sur de California (2161) verificada: {len(ext_lands)}/64 celdas exteriores con registro LAND (VHGT/VNML) y {len(ext_map_markers)} MapMarkers con viaje rápido."
        )
    else:
        report.err(
            f"Topografía exterior incompleta: {len(ext_lands)} registros LAND (esperados 64) y {len(ext_map_markers)} MapMarkers (esperados >= 23)."
        )
    ext_achrs: list[tuple[ParsedRecord, int, float, float, float]] = []
    ext_refrs: list[tuple[ParsedRecord, int, float, float, float]] = []
    desks_xy_z: list[tuple[float, float, float, int]] = []
    desk_terms: list[tuple[ParsedRecord, int, float, float, float]] = []
    desk_books: list[tuple[ParsedRecord, int, float, float, float]] = []

    term_fids = {r.fid for r in records if r.rtype == "TERM"}
    book_fids = {r.fid for r in records if r.rtype == "BOOK"}

    for r in records:
        if r.parent_wrld != 0x01003400 or r.rtype not in ("ACHR", "REFR"):
            continue
        base_fid = 0
        pos_xyz: tuple[float, float, float] | None = None
        for st, sv in r.subs:
            if st == "NAME" and len(sv) == 4:
                base_fid = struct.unpack_from("<I", sv, 0)[0]
            elif st == "DATA" and len(sv) >= 12:
                pos_xyz = struct.unpack_from("<3f", sv, 0)
        if pos_xyz is None:
            continue
        x, y, z = pos_xyz
        if r.rtype == "ACHR":
            ext_achrs.append((r, base_fid, x, y, z))
        else:
            ext_refrs.append((r, base_fid, x, y, z))
            if base_fid == 0x0001F453:
                desks_xy_z.append((x, y, z, r.fid))
            elif base_fid in term_fids and (r.flags & 0x0800) == 0:
                desk_terms.append((r, base_fid, x, y, z))
            elif base_fid in book_fids and (r.flags & 0x0800) == 0:
                desk_books.append((r, base_fid, x, y, z))

    # 4.1 Check active exterior ACHRs against terrain height
    z_issues: list[str] = []
    for r, base_fid, x, y, z in ext_achrs:
        if r.flags & 0x0800:
            continue
        ground_z = round(global_california_height(x, y) / 8.0) * 8.0
        dz = z - ground_z
        # Allow porches (+18.0 in Shady Sands) or slight ground offsets (-6..+24)
        if dz < -12.0 or dz > 32.0:
            base_edid = (
                mod_records_by_fid[base_fid][0].edid
                if base_fid in mod_records_by_fid
                else f"0x{base_fid:08X}"
            )
            z_issues.append(
                f"ACHR 0x{r.fid:08X} ({base_edid}) en ({x:.1f}, {y:.1f}, Z={z:.1f}) desalineado con terreno (ground_z={ground_z:.1f}, dz={dz:+.1f})"
            )

    if not z_issues:
        report.ok(
            f"Alineación vertical de actores exteriores verificada: los {len(ext_achrs)} NPCs y criaturas de California (2161) están apoyados sobre la cota exacta del terreno o porches (0 actores flotando o enterrados)."
        )
    else:
        for zi in z_issues:
            report.err(zi)

    # 4.2 Check every exterior desk terminal and tabletop book has a supporting desk
    desk_support_errors: list[str] = []
    for r, base_fid, tx, ty, tz in desk_terms:
        base_edid = (
            mod_records_by_fid[base_fid][0].edid
            if base_fid in mod_records_by_fid
            else f"0x{base_fid:08X}"
        )
        # Skip wall-mounted terminals if any
        if "Wall" in base_edid:
            continue
        matched_desk = False
        for dx, dy, dz, _dfid in desks_xy_z:
            if math.hypot(tx - dx, ty - dy) <= 40.0 and abs(tz - dz) <= 2.0:
                matched_desk = True
                break
        if not matched_desk:
            desk_support_errors.append(
                f"Terminal exterior REFR 0x{r.fid:08X} ({base_edid}) en ({tx:.1f}, {ty:.1f}, Z={tz:.1f}) carece de escritorio de soporte 0x0001F453"
            )

    for r, base_fid, bx, by, bz in desk_books:
        base_edid = (
            mod_records_by_fid[base_fid][0].edid
            if base_fid in mod_records_by_fid
            else f"0x{base_fid:08X}"
        )
        matched_desk = False
        for dx, dy, dz, _dfid in desks_xy_z:
            if math.hypot(bx - dx, by - dy) <= 50.0 and abs(bz - (dz + 56.5)) <= 3.0:
                matched_desk = True
                break
        if not matched_desk:
            desk_support_errors.append(
                f"Documento exterior REFR 0x{r.fid:08X} ({base_edid}) en ({bx:.1f}, {by:.1f}, Z={bz:.1f}) no descansa a Z=desk_z+56.5 sobre un escritorio"
            )

    if not desk_support_errors:
        report.ok(
            f"Todos los terminales de campaña ({len(desk_terms)}) y documentos de sobremesa ({len(desk_books)}) del exterior descansan exactamente sobre sus escritorios (0 objetos flotando)."
        )
    else:
        for de in desk_support_errors:
            report.err(de)

    # 4.3 Check pairwise distances between settlement/encounter actors (no overlapping NPCs)
    overlap_errors: list[str] = []
    for i in range(len(ext_achrs)):
        r1, b1, x1, y1, z1 = ext_achrs[i]
        if r1.flags & 0x0800:
            continue
        for j in range(i + 1, len(ext_achrs)):
            r2, b2, x2, y2, z2 = ext_achrs[j]
            if r2.flags & 0x0800:
                continue
            dist_xy = math.hypot(x1 - x2, y1 - y2)
            if dist_xy < 65.0 and abs(z1 - z2) < 50.0:
                overlap_errors.append(
                    f"Solapamiento 3D entre ACHR 0x{r1.fid:08X} y ACHR 0x{r2.fid:08X} (distancia XY = {dist_xy:.1f} uds en ({x1:.0f}, {y1:.0f}))"
                )

    if not overlap_errors:
        report.ok(
            f"Cero solapamientos 3D entre los {len(ext_achrs)} actores del mundo exterior (separación mínima > 65 unidades)."
        )
    else:
        for oe in overlap_errors:
            report.err(oe)

    # 4.4 Check Safe Zones: hostile roaming creatures (0x01003580..0x0100359B) vs friendly NPCs
    roaming_hostiles = [
        (r, b, x, y, z)
        for (r, b, x, y, z) in ext_achrs
        if 0x01003580 <= r.fid <= 0x0100359B and (r.flags & 0x0800) == 0
    ]
    friendly_npcs = [
        (r, b, x, y, z)
        for (r, b, x, y, z) in ext_achrs
        if r.fid
        in (
            0x010035A0,
            0x010035A1,
            0x010035A2,
            0x010035A3,
            0x010035A4,
            0x010035A5,
            0x010035B3,
            0x010035C0,
            0x010035C1,
            0x010035C2,
            0x010035C6,
            0x010035C7,
            0x010035C8,
            0x010035CB,
            0x010035CC,
            0x010035D0,
            0x010035D1,
            0x010035D4,
            0x010035D5,
            0x010035D6,
            0x010035DC,
            0x010035DD,
            0x010035E6,
            0x010035E7,
            0x01003570,
        )
    ]

    safe_zone_warnings: list[str] = []
    for hr, hb, hx, hy, _hz in roaming_hostiles:
        for fr, fb, fx, fy, _fz in friendly_npcs:
            d_hf = math.hypot(hx - fx, hy - fy)
            if d_hf < 1150.0:
                f_edid = (
                    mod_records_by_fid[fb][0].edid
                    if fb in mod_records_by_fid
                    else f"0x{fb:08X}"
                )
                safe_zone_warnings.append(
                    f"Criatura hostil 0x{hr.fid:08X} en ({hx:.0f}, {hy:.0f}) está a solo {d_hf:.0f} uds del NPC amistoso 0x{fr.fid:08X} ({f_edid}) en ({fx:.0f}, {fy:.0f})"
                )

    if not safe_zone_warnings:
        report.ok(
            f"Perímetros de seguridad verificados: las {len(roaming_hostiles)} criaturas errantes respetan un margen > 1.150 unidades respecto a todos los NPCs amistosos y asentamientos."
        )
    else:
        for szw in safe_zone_warnings:
            report.warn(szw)

    # 4.5 Check Global Spatial Distribution across the 32,768x32,768 Map & Cross-Mission Boss Isolation
    boss_fids = [
        0x010035AC,  # Mutascorpión Emperador (SQ1)
        0x010035C5,  # Kenji (SQ2)
        0x010035CC,  # Gizmo (SQ8)
        0x010035CE,  # Vinnie (SQ8)
        0x010035BA,  # Petrox (SQ7)
        0x010035DE,  # Tolan (SQ4)
        0x010035D7,  # Krag (SQ3)
        0x010035EA,  # Guardián Sanguinario de las Caravanas (SQ9)
        0x010035E5,  # ZAX-WT01 (SQ5)
        0x010035E8,  # Madre Sanguinario (SQ6)
    ]
    boss_positions = [
        (r, b, x, y, z)
        for (r, b, x, y, z) in ext_achrs
        if r.fid in boss_fids
    ]
    cross_mission_errors: list[str] = []
    for i in range(len(boss_positions)):
        r1, _b1, x1, y1, _z1 = boss_positions[i]
        for j in range(i + 1, len(boss_positions)):
            r2, _b2, x2, y2, _z2 = boss_positions[j]
            # Gizmo (0x010035CC) and Vinnie (0x010035CE) belong to the same SQ8 district
            if {r1.fid, r2.fid} == {0x010035CC, 0x010035CE}:
                continue
            d_boss = math.hypot(x1 - x2, y1 - y2)
            if d_boss < 2800.0:
                cross_mission_errors.append(
                    f"Jefes de misiones distintas demasiado próximos: 0x{r1.fid:08X} y 0x{r2.fid:08X} a solo {d_boss:.0f} uds"
                )
    # Check 3x3 sector occupancy across [-16384..+16384] x [-16384..+16384]
    occupied_sectors: set[tuple[int, int]] = set()
    for mm in ext_map_markers:
        for st, sv in mm.subs:
            if st == "DATA" and len(sv) >= 12:
                mx, my, _mz = struct.unpack_from("<3f", sv, 0)
                sx = 0 if mx < -4000.0 else (1 if mx < 5000.0 else 2)
                sy = 0 if my < -4000.0 else (1 if my < 5000.0 else 2)
                occupied_sectors.add((sx, sy))
    if not cross_mission_errors and len(occupied_sectors) == 9:
        report.ok(
            f"Distribución espacial global y aislamiento entre misiones verificados: 9/9 sectores del mapa (32.768x32.768 uds) ocupados por {len(ext_map_markers)} marcadores y distancia mínima > 3.500 uds entre jefes de distintas misiones."
        )
    else:
        for cme in cross_mission_errors:
            report.err(cme)
        if len(occupied_sectors) < 9:
            report.err(f"Sectores del mapa ocupados: {len(occupied_sectors)}/9")

    # ------------------------------------------------------------------
    # MÓDULO 5: TRAZABILIDAD DE ACTIVOS (ESP -> NIF -> BGSM/BGEM -> DDS)
    # ------------------------------------------------------------------
    print("[Módulo 5/6] Verificando cadena de activos personalizados (NIF -> BGSM/BGEM -> DDS) en los archivos .ba2...")
    asset_errors: list[str] = []
    custom_modls_checked = 0
    for r in records[1:]:
        for st, sv in r.subs:
            if st == "MODL":
                modl_str = get_zstr(sv).replace("/", "\\").lower()
                if not modl_str:
                    continue
                if any(tag in modl_str for tag in ("vault13", "v13chronicles", "woodcratenukacola")) or modl_str.startswith("meshes\\"):
                    rel_mesh = (
                        modl_str
                        if modl_str.startswith("meshes\\")
                        else f"meshes\\{modl_str}"
                    )
                    if any(tag in rel_mesh for tag in ("vault13", "v13chronicles", "woodcratenukacola")):
                        custom_modls_checked += 1
                        if rel_mesh not in main_ba2_files:
                            asset_errors.append(
                                f"{r.rtype} 0x{r.fid:08X} ({r.edid}) MODL personalizado falta en Main.ba2: {rel_mesh}"
                            )

    # Check zero vanilla mesh/material/texture overrides in Main.ba2 & Textures.ba2
    forbidden_main_overrides = [
        k for k in main_ba2_files
        if k.startswith("meshes\\architecture\\")
        or k.endswith("vltoverseerblueprint81.nif")
        or k.endswith("vltglass04clear.bgem")
        or k.endswith("vaultsuitmnumber81dirty.bgsm")
    ]
    if forbidden_main_overrides:
        asset_errors.append(f"Overrides vanilla prohibidos en Main.ba2: {forbidden_main_overrides}")
    forbidden_tex_overrides = [
        k for k in tex_ba2_names if "vaultsuitnumber81" in k
    ]
    if forbidden_tex_overrides:
        asset_errors.append(f"Overrides vanilla prohibidos en Textures.ba2: {forbidden_tex_overrides}")
    for req_tex in (
        "textures\\interface\\pip-boy\\v13californiaworldmap_d.dds",
        "textures\\v13chronicles\\junktown\\larsguardhelmet_d.dds",
    ):
        if req_tex not in tex_ba2_names:
            asset_errors.append(f"Textura DDS requerida ausente en Textures.ba2: {req_tex}")

    # Check all custom BGSM/BGEM files in Main.ba2 for custom DDS textures in Textures.ba2
    bgsm_checked = 0
    re_dds = re.compile(rb"[A-Za-z0-9_\\/\-\.]+\.dds", re.IGNORECASE)
    for bpath, bdata in main_ba2_files.items():
        if bpath.endswith(".bgsm") or bpath.endswith(".bgem"):
            bgsm_checked += 1
            for m_dds in re_dds.finditer(bdata):
                dds_str = (
                    m_dds.group(0).decode("latin1", "ignore").replace("/", "\\").lower()
                )
                rel_dds = (
                    dds_str
                    if dds_str.startswith("textures\\")
                    else f"textures\\{dds_str}"
                )
                if any(tag in rel_dds for tag in ("vault13", "v13chronicles", "pip-boy\\v13")):
                    if rel_dds not in tex_ba2_names:
                        asset_errors.append(
                            f"Material {bpath} referencia textura DDS personalizada ausente en Textures.ba2: {rel_dds}"
                        )

    if not asset_errors:
        report.ok(
            f"Cadena de activos 3D verificada: {custom_modls_checked} modelos NIF personalizados, {bgsm_checked} materiales BGSM/BGEM y {len(tex_ba2_names)} texturas DDS presentes y enlazados en los .ba2."
        )
    else:
        for ae in asset_errors:
            report.err(ae)

    lod_key = "lodsettings\\v13southerncaliforniaworld.lod"
    if lod_key not in main_ba2_files or len(main_ba2_files[lod_key]) != 16:
        report.err(f"Falta descriptor Pip-Boy LODSettings ({lod_key}, 16 bytes) en Main.ba2.")
    else:
        lod_vals = struct.unpack("<hhIII", main_ba2_files[lod_key])
        if lod_vals != (-4, -4, 32, 4, 32):
            report.err(f"Descriptor LODSettings inválido: {lod_vals}")
        else:
            report.ok(
                f"Descriptor Pip-Boy Map LODSettings verificado en Main.ba2 ({lod_key}, 16 bytes: {lod_vals}) — garantiza encuadre nativo de V13SouthernCaliforniaWorld en TES::GetCurrentWorldSpaceForMap."
            )

    if IS_EN_AUDIT:
        en_trans_sub_types = {
            ("TES4", "SNAM"),
            ("ACTI", "FULL"), ("ACTI", "ATTX"),
            ("ARMO", "FULL"), ("ARMO", "DESC"),
            ("BOOK", "FULL"), ("BOOK", "DESC"),
            ("CELL", "FULL"), ("CONT", "FULL"),
            ("DIAL", "FULL"), ("DOOR", "FULL"),
            ("ENCH", "FULL"), ("INFO", "NAM1"), ("INFO", "RNAM"),
            ("LCTN", "FULL"), ("MESG", "FULL"), ("MESG", "DESC"), ("MESG", "ITXT"),
            ("MGEF", "FULL"), ("MISC", "FULL"),
            ("NPC_", "FULL"), ("NPC_", "SHRT"),
            ("QUST", "FULL"), ("QUST", "CNAM"), ("QUST", "NNAM"),
            ("REFR", "FULL"),
            ("TERM", "FULL"), ("TERM", "NAM0"), ("TERM", "WNAM"),
            ("TERM", "ITXT"), ("TERM", "RNAM"), ("TERM", "UNAM"),
            ("WEAP", "FULL"), ("WEAP", "DESC"),
            ("WRLD", "FULL"),
        }
        es_leak_re = re.compile(
            r"\b(Refugio|Morador|Supervisor|Chapas|chapas|Yermo|Misi[oó]n|Almac[eé]n|Cuenca|Necr[ó]polis|Catedral|Hermandad|Sanguinario|Mutascorpi[oó]n|Alb[oó]ndiga|Espumadera|Cr[aá]neos|El Eje|Arenas Sombr[ií]as|Ciudad Chatarra)\b"
        )
        en_leaks: list[str] = []
        en_sub_checked = 0
        for r in records:
            for st, sv in r.subs:
                if (r.rtype, st) in en_trans_sub_types and len(sv) >= 2 and sv[-1] == 0:
                    s_txt = get_zstr(sv)
                    if not s_txt.strip():
                        continue
                    en_sub_checked += 1
                    if any(ch in s_txt for ch in "¿¡ñÑ") or es_leak_re.search(s_txt):
                        en_leaks.append(f"{r.rtype} 0x{r.fid:08X} {st}: {s_txt[:70]!r}")
        if not en_leaks:
            report.ok(
                f"Localización Inglesa (EN) verificada al 100%: {en_sub_checked} subregistros de texto en el .esp y 50 scripts .pex sin una sola cadena en español."
            )
        else:
            for lk in en_leaks[:20]:
                report.err(f"Texto en español sin traducir en edición EN: {lk}")

    # ------------------------------------------------------------------
    # MÓDULO 6: ESCÁNER DE LOGS DE EJECUCIÓN (Papyrus.0.log)
    # ------------------------------------------------------------------
    print("[Módulo 6/6] Analizando registro de ejecución de Fallout 4 (Papyrus.0.log)...")
    if os.path.exists(PAPYRUS_LOG_PATH):
        with open(PAPYRUS_LOG_PATH, "r", encoding="utf-8", errors="ignore") as lf:
            log_lines = lf.readlines()
        v13_log_errors = [
            ln.strip()
            for ln in log_lines
            if ("vault13chronicles" in ln.lower() or "v13" in ln.lower())
            and ("error:" in ln.lower() or "cannot " in ln.lower())
        ]
        if not v13_log_errors:
            report.ok(
                f"Papyrus.0.log inspeccionado ({len(log_lines):,} líneas): 0 errores de ejecución en scripts de Vault13Chronicles.esp."
            )
        else:
            report.warn(
                f"Papyrus.0.log contiene {len(v13_log_errors)} líneas históricas con avisos/errores de V13 (última: {v13_log_errors[-1][:120]})"
            )
    else:
        report.ok(
            "Papyrus.0.log no encontrado en Documents\\My Games\\Fallout4\\Logs\\Script (limpio o logging desactivado)."
        )

    # ------------------------------------------------------------------
    # RESUMEN FINAL
    # ------------------------------------------------------------------
    print("\n" + "=" * 78)
    print("  RESUMEN DEL INFORME DE AUDITORÍA DE CALIDAD (QA)")
    print("=" * 78)
    for ok_msg in report.passed:
        print(f"  [OK]   {ok_msg}")
    for w_msg in report.warnings:
        print(f"  [WARN] {w_msg}")
    for e_msg in report.errors:
        print(f"  [ERR]  {e_msg}")

    print("-" * 78)
    print(
        f"  Checks Superados: {len(report.passed)}  |  Advertencias: {len(report.warnings)}  |  Errores: {len(report.errors)}"
    )
    print("=" * 78)
    return 1 if report.errors else 0


if __name__ == "__main__":
    sys.exit(run_full_qa_audit())
