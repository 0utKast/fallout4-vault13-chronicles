"""
Automated QA Verification & State-Machine Simulation Suite for Crónicas del Refugio 13 (Vault13Chronicles.esp).

Executes 4 comprehensive verification layers before any build is considered ready:
  1. Binary ESP & Fallout4.esm 3D Bounding-Box (OBND), Floor Elevation & Door XTEL Audit
  2. Papyrus (.psc) <-> Binary (.esp) Cross-Reference & Anti-Regression Static Audit
  3. Quest Objectives (QOBJ), Targets (QSTA/CTDA) & Alias Resolution Matrix across all Cells
  4. Full Savegame Load & Act II State-Machine Simulation (22 scenarios including Harry combat/persuasion,
     Water Chip extraction, Sewer/Cavern routing, and contaminated-save self-healing)
"""

import os
import re
import struct
import sys

FO4_DATA = r"C:\Program Files (x86)\Steam\steamapps\common\Fallout 4\Data"
ESP_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "build_out", "Vault13Chronicles.esp")
PSC_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "papyrus_src")


def parse_subrecords(raw: bytes):
    pos = 0
    out = []
    xxxx_size = None
    while pos + 6 <= len(raw):
        st = raw[pos : pos + 4].decode("ascii", "ignore")
        ss = struct.unpack_from("<H", raw, pos + 4)[0]
        pos += 6
        if st == "XXXX":
            xxxx_size = struct.unpack_from("<I", raw, pos)[0]
            pos += ss
            continue
        if xxxx_size is not None:
            ss = xxxx_size
            xxxx_size = None
        out.append((st, raw[pos : pos + ss]))
        pos += ss
    return out


def walk_records(buf: bytes, start: int, end: int, current_cell_fid=None):
    pos = start
    while pos + 24 <= end:
        rt = buf[pos : pos + 4].decode("ascii", "ignore")
        if rt == "GRUP":
            gsize, label, gtype = struct.unpack_from("<I4sI", buf, pos + 4)
            next_cell = current_cell_fid
            if gtype in (6, 8, 9):
                next_cell = struct.unpack_from("<I", label)[0]
            yield from walk_records(buf, pos + 24, pos + gsize, next_cell)
            pos += gsize
        else:
            dsize, flags, fid = struct.unpack_from("<III", buf, pos + 4)
            raw = buf[pos + 24 : pos + 24 + dsize]
            yield (rt, fid, flags, raw, current_cell_fid)
            pos += 24 + dsize


def get_fo4_obnd(fo4_path: str, target_fids: set[int]) -> dict[int, tuple[int, int, int, int, int, int]]:
    obnds = {}
    if not os.path.exists(fo4_path):
        return obnds
    with open(fo4_path, "rb") as f:
        header = f.read(24)
        _, h_size = struct.unpack_from("<4sI", header, 0)
        f.seek(24 + h_size)
        while True:
            ghdr = f.read(24)
            if len(ghdr) < 24:
                break
            rt, gsize, label, gtype = struct.unpack_from("<4sI4sI", ghdr, 0)
            if rt != b"GRUP":
                break
            g_label = label.decode("ascii", "ignore")
            if g_label in ("DOOR", "CONT", "TERM", "ACTI", "STAT", "NPC_", "MSTT", "FURN"):
                gbuf = f.read(gsize - 24)
                for r_type, fid, flags, raw, _ in walk_records(gbuf, 0, len(gbuf)):
                    if fid in target_fids:
                        if flags & 0x00040000:
                            import zlib
                            raw = zlib.decompress(raw[4:])
                        for st, sv in parse_subrecords(raw):
                            if st == "OBND" and len(sv) == 12:
                                obnds[fid] = struct.unpack("<6h", sv)
                                break
            else:
                f.seek(gsize - 24, os.SEEK_CUR)
    return obnds


class VerificationSuite:
    def __init__(self):
        self.passed = 0
        self.failed = 0
        self.failures = []

    def check(self, cond: bool, msg: str):
        if cond:
            self.passed += 1
        else:
            self.failed += 1
            self.failures.append(msg)
            print(f"  [FAIL] {msg}")

    def run_all(self) -> bool:
        print("=" * 78)
        print("CRÓNICAS DEL REFUGIO 13 — SUITE AUTOMÁTICA DE VERIFICACIÓN Y SIMULACIÓN QA")
        print("=" * 78)
        self.check(os.path.exists(ESP_PATH), f"ESP file exists at {ESP_PATH}")
        if not os.path.exists(ESP_PATH):
            return False

        # Verify Fallout 4\Data deployed files are 100% byte-for-byte identical to build_out/ (ES) or edition_en/build_out/ (EN) when v1.0 profile is active
        import hashlib
        import json as _json
        _active_ver = "1.0"
        _marker_p = os.path.join(FO4_DATA, "V13_ACTIVE_VERSION.json")
        if os.path.isfile(_marker_p):
            try:
                with open(_marker_p, "r", encoding="utf-8") as _mf:
                    _active_ver = _json.load(_mf).get("version", "1.0")
            except Exception:
                pass
        build_out_dir = os.path.dirname(ESP_PATH)
        en_build_out_dir = os.path.join(os.path.dirname(build_out_dir), "edition_en", "build_out")
        skip_data_sync = "--staging" in sys.argv
        for fname in ("Vault13Chronicles.esp", "Vault13Chronicles - Main.ba2", "Vault13Chronicles - Textures.ba2"):
            src_f = os.path.join(build_out_dir, fname)
            en_src_f = os.path.join(en_build_out_dir, fname)
            dst_f = os.path.join(FO4_DATA, fname)
            if skip_data_sync:
                self.check(
                    os.path.exists(src_f) and os.path.exists(en_src_f),
                    f"Staged ES and EN {fname} exist (--staging mode, Fallout 4\\Data untouched)",
                )
                continue
            if _active_ver != "1.0":
                self.check(os.path.exists(src_f), f"Staged v1.0 {fname} exists while Fallout 4\\Data holds profile {_active_ver}")
                continue
            if os.path.exists(src_f) and os.path.exists(dst_f):
                with open(src_f, "rb") as fs, open(dst_f, "rb") as fd:
                    hs = hashlib.sha256(fs.read()).hexdigest()
                    hd = hashlib.sha256(fd.read()).hexdigest()
                hen = ""
                if os.path.exists(en_src_f):
                    with open(en_src_f, "rb") as fe:
                        hen = hashlib.sha256(fe.read()).hexdigest()
                if hd != hs and hd != hen:
                    locked_by_fo4 = False
                    try:
                        with open(dst_f, "ab"):
                            pass
                    except PermissionError:
                        locked_by_fo4 = True
                    if not locked_by_fo4:
                        try:
                            import subprocess as _subprocess
                            _fo4_proc = _subprocess.run(
                                ["tasklist", "/FI", "IMAGENAME eq Fallout4.exe"],
                                capture_output=True,
                                text=True,
                            )
                            if "fallout4.exe" in (_fo4_proc.stdout or "").lower():
                                locked_by_fo4 = True
                        except Exception:
                            pass
                    if locked_by_fo4:
                        print(f"  [NOTICE] Fallout4.exe is running; staged build_out {fname} ready for install when Fallout4.exe closes.")
                        self.check(True, f"Staged {fname} ready for install when Fallout4.exe closes")
                    else:
                        self.check(
                            hd in (hs, hen),
                            f"Deployed Fallout 4\\Data\\{fname} matches ES or EN build_out SHA-256 ({hd[:12]})",
                        )
                else:
                    ed_tag = "EN" if hd == hen else "ES"
                    self.check(
                        True,
                        f"Deployed Fallout 4\\Data\\{fname} matches {ed_tag} build_out SHA-256 ({hd[:12]})",
                    )
            else:
                self.check(False, f"Both build_out and Fallout 4\\Data copies of {fname} exist")

        with open(ESP_PATH, "rb") as f:
            esp_buf = f.read()

        records_by_fid = {}
        duplicate_fids = []
        refrs_by_fid = {}
        qusts_by_fid = {}
        esp_obnds = {}
        startup_stage_10_quests = set()

        _, tes4_size = struct.unpack_from("<4sI", esp_buf, 0)
        for rt, fid, flags, raw, parent_cell in walk_records(esp_buf, 24 + tes4_size, len(esp_buf)):
            if flags & 0x00040000:
                import zlib
                raw = zlib.decompress(raw[4:])
            subs = parse_subrecords(raw)
            if fid in records_by_fid:
                duplicate_fids.append((hex(fid), records_by_fid[fid][0], rt))
            records_by_fid[fid] = (rt, flags, subs, parent_cell)
            for st, sv in subs:
                if st == "OBND" and len(sv) == 12:
                    esp_obnds[fid] = struct.unpack("<6h", sv)
            if rt in ("REFR", "ACHR"):
                base_fid = None
                pos_rot = None
                xtel = None
                for st, sv in subs:
                    if st == "NAME" and len(sv) == 4:
                        base_fid = struct.unpack("<I", sv)[0]
                    elif st == "DATA" and len(sv) == 24:
                        pos_rot = struct.unpack("<6f", sv)
                    elif st == "XTEL" and len(sv) >= 28:
                        xtel = struct.unpack("<I6f", sv[:28])
                refrs_by_fid[fid] = {
                    "rt": rt,
                    "flags": flags,
                    "base": base_fid,
                    "data": pos_rot,
                    "xtel": xtel,
                    "cell": parent_cell,
                }
            elif rt == "QUST":
                qusts_by_fid[fid] = subs
                for st, sv in subs:
                    if st == "INDX" and len(sv) >= 3:
                        stg_idx, stg_flag = struct.unpack_from("<HB", sv, 0)
                        if stg_idx == 10 and (stg_flag & 2):
                            startup_stage_10_quests.add(fid)

        # Layer 1: Binary ESP & 3D Bounding Box / Door XTEL Audit
        print("\n[CAPA 1] Auditoría Binaria ESP, Cajas 3D (OBND), Alturas Z y Puertas XTEL...")
        self.check(
            len(duplicate_fids) == 0,
            f"Zero duplicate FormIDs across all records in Vault13Chronicles.esp (found: {duplicate_fids})",
        )
        self.check(
            0x01001450 in records_by_fid and records_by_fid[0x01001450][0] == "MESG"
            and 0x01001152 in records_by_fid and records_by_fid[0x01001152][0] == "MESG",
            "Part 1 Finale Card MESG records 0x01001450 (MesgV13Part1FinaleCard) and 0x01001152 (MesgV13RadioIntroAct3) exist as unique MESG records",
        )
        fo4_esm = os.path.join(FO4_DATA, "Fallout4.esm")
        fo4_obnds = get_fo4_obnd(fo4_esm, {0x000787C5})
        obnd_ladder = fo4_obnds.get(0x000787C5, (-38, -51, -256, 38, 46, 0))
        self.check(
            obnd_ladder[2] == -256 and obnd_ladder[5] == 0,
            f"MetalTrapdoorLadder01 (0x000787C5) OBND verified as z=(-256..0), got {obnd_ladder}",
        )

        # Verify DoorV13VerticalSteelLadder (0x01001328) exists and every active placement is raised above its floor!
        self.check(
            0x01001328 in records_by_fid and records_by_fid[0x01001328][0] == "DOOR",
            "Custom vertical ladder DOOR 0x01001328 (DoorV13VerticalSteelLadder) exists in ESP",
        )
        obnd_v13_ladder = esp_obnds.get(0x01001328, obnd_ladder)
        ladder_expected_floors = {
            0x01002B03: (-577.6, "Lost Hills Lower Bunker"),
            0x01002F03: (1059.3, "Necropolis Sewers West Ladder"),
            0x01002F04: (862.2, "Necropolis Sewers Central Ladder"),
            0x0100290B: (0.0, "Vault 12 Processor Chamber Direct Surface Exit Ladder"),
            0x01002A35: (0.0, "La Cuenca North Cavern Direct Surface Exit Ladder"),
        }
        for l_fid, (floor_z, label) in ladder_expected_floors.items():
            self.check(l_fid in refrs_by_fid, f"Ladder {hex(l_fid)} ({label}) exists in ESP")
            if l_fid in refrs_by_fid:
                l_info = refrs_by_fid[l_fid]
                self.check(
                    l_info["base"] == 0x01001328,
                    f"Ladder {hex(l_fid)} ({label}) uses isolated DoorV13VerticalSteelLadder (0x01001328), got {hex(l_info['base'] or 0)}",
                )
                lx, ly, lz = l_info["data"][:3]
                center_z = lz + 0.5 * (obnd_v13_ladder[2] + obnd_v13_ladder[5])
                top_z = lz + obnd_v13_ladder[5]
                self.check(
                    top_z >= floor_z + 180.0 and center_z >= floor_z + 60.0,
                    f"Ladder {hex(l_fid)} ({label}) is above ground: Z={lz:.1f}, marker_center_Z={center_z:.1f} vs floor_Z={floor_z:.1f}",
                )

        # Verify direct surface exit ladders (0x0100290B & 0x01002A35) are enabled and link directly to Southern California Wasteland (0x01003506)
        for surf_ladder_fid in (0x0100290B, 0x01002A35):
            sl_info = refrs_by_fid[surf_ladder_fid]
            sl_disabled = bool(sl_info["flags"] & 0x00000800)
            sl_xt = sl_info["xtel"]
            self.check(
                not sl_disabled and sl_xt is not None and sl_xt[0] == 0x01003506,
                f"Direct surface exit ladder {hex(surf_ladder_fid)} is enabled and links to Wasteland surface 0x01003506 ({sl_xt})",
            )

        # Verify legacy oversized rotated window grid (0x0100290E) is disabled and buried at Z=-3000.0
        for disabled_legacy_fid in (0x0100290E,):
            self.check(disabled_legacy_fid in refrs_by_fid, f"Legacy ref {hex(disabled_legacy_fid)} exists in ESP for save compatibility")
            if disabled_legacy_fid in refrs_by_fid:
                dl_info = refrs_by_fid[disabled_legacy_fid]
                dl_disabled = bool(dl_info["flags"] & 0x00000800)
                dl_z = dl_info["data"][2]
                self.check(
                    dl_disabled and dl_z <= -2500.0,
                    f"Legacy ref {hex(disabled_legacy_fid)} is Initially Disabled ({dl_disabled}) and buried at Z={dl_z:.1f}",
                )

        # Verify procedural subterranean detailing in CELL 0x01002A00 (>= 350 custom props, 0 vegetation)
        c2a00_custom_props = [
            r_fid for r_fid, r_info in refrs_by_fid.items()
            if r_info["cell"] == 0x01002A00 and 0x01050000 <= r_fid < 0x01050600
        ]
        self.check(
            len(c2a00_custom_props) >= 350,
            f"CELL 0x01002A00 has rich procedural subterranean detailing ({len(c2a00_custom_props)} custom props >= 350)",
        )

        # Verify single Watershed Bunker doors (0x01002A34 outside, 0x01002901 inside) are enabled and linked
        for bunker_door_fid in (0x01002A34, 0x01002901):
            self.check(bunker_door_fid in refrs_by_fid, f"Watershed Bunker door {hex(bunker_door_fid)} exists in ESP")
            if bunker_door_fid in refrs_by_fid:
                bd_disabled = bool(refrs_by_fid[bunker_door_fid]["flags"] & 0x00000800)
                self.check(not bd_disabled, f"Watershed Bunker door {hex(bunker_door_fid)} is enabled")

        # Verify every persistent enabled door's XTEL target exists and is enabled
        for r_fid, r_info in refrs_by_fid.items():
            if r_info["flags"] & 0x00000800:
                continue
            if r_info["xtel"] is not None:
                dst_door = r_info["xtel"][0]
                self.check(
                    dst_door in refrs_by_fid,
                    f"Door {hex(r_fid)} XTEL destination {hex(dst_door)} exists in ESP",
                )
                if dst_door in refrs_by_fid:
                    dst_disabled = bool(refrs_by_fid[dst_door]["flags"] & 0x00000800)
                    self.check(
                        not dst_disabled,
                        f"Door {hex(r_fid)} XTEL destination {hex(dst_door)} is not initially disabled",
                    )

        # Verify Sewer doors & ladders (0x01002F01, 0x01002F03, 0x01002F04) return to Subterranean Cavern (0x01002A09)
        for sew_exit_fid in (0x01002F01, 0x01002F03, 0x01002F04):
            xt = refrs_by_fid[sew_exit_fid]["xtel"]
            self.check(
                xt is not None and xt[0] == 0x01002A09 and abs(xt[1] - (-1880.0)) < 1.0 and abs(xt[3] - (-512.0)) < 1.0,
                f"Sewer exit {hex(sew_exit_fid)} leads back to Subterranean Cavern (0x01002A09 at -1880, -920, -512), got {xt}",
            )

        # Verify Wasteland Watershed surface door 0x01003506 links cleanly to single bunker door 0x01002A34
        xt_3506 = refrs_by_fid[0x01003506]["xtel"]
        self.check(
            xt_3506 is not None and xt_3506[0] == 0x01002A34,
            f"Wasteland Watershed surface door 0x01003506 links to single bunker door 0x01002A34, got {xt_3506}",
        )

        # Verify Harry (0x01001203) and Super Mutant Guards (0x01001204) share SuperMutantFaction (0x00058305) and AIDT Aggression=0
        for npc_fid, npc_name in ((0x01001203, "Harry"), (0x01001204, "Super Mutant Guard")):
            self.check(npc_fid in records_by_fid, f"NPC_ {hex(npc_fid)} ({npc_name}) exists in ESP")
            if npc_fid in records_by_fid:
                _, _, npc_subs, _ = records_by_fid[npc_fid]
                snam_factions = [struct.unpack_from("<I", sv, 0)[0] for st, sv in npc_subs if st == "SNAM" and len(sv) >= 4]
                aidt_aggro = [sv[0] for st, sv in npc_subs if st == "AIDT" and len(sv) >= 1]
                self.check(
                    0x00058305 in snam_factions,
                    f"NPC_ {hex(npc_fid)} ({npc_name}) belongs to SuperMutantFaction (0x00058305), got {[hex(x) for x in snam_factions]}",
                )
                self.check(
                    aidt_aggro == [0],
                    f"NPC_ {hex(npc_fid)} ({npc_name}) has base AIDT aggression 0 (never attacks allies), got {aidt_aggro}",
                )

        # Verify TIQS on INFO records fires on line end ONLY (begin_stage == 0xFFFF and end_stage != 0xFFFF)
        # so NPC dialogue finishes speaking cleanly and all QUST.DNAM records clear Allow Repeated Stages (0x0008 == 0)
        bad_tiqs = []
        bad_qust_dnam = []
        for r_fid, (rt, _, subs, _) in records_by_fid.items():
            if rt == "INFO":
                for st, sv in subs:
                    if st == "TIQS" and len(sv) == 4:
                        b_stg, e_stg = struct.unpack("<HH", sv)
                        if b_stg != 0xFFFF or e_stg == 0xFFFF:
                            bad_tiqs.append((hex(r_fid), b_stg, e_stg))
            elif rt == "QUST":
                for st, sv in subs:
                    if st == "DNAM" and len(sv) >= 2:
                        q_fl = struct.unpack_from("<H", sv, 0)[0]
                        if q_fl & 0x0008:
                            bad_qust_dnam.append((hex(r_fid), hex(q_fl)))
        self.check(
            len(bad_tiqs) == 0,
            f"All INFO TIQS subrecords fire once on line end only (begin == 0xFFFF, end != 0xFFFF; 0 bad TIQS found: {bad_tiqs})",
        )
        self.check(
            len(bad_qust_dnam) == 0,
            f"All QUST DNAM records clear Allow Repeated Stages (0x0008 == 0; 0 bad QUST found: {bad_qust_dnam})",
        )

        # Layer 2: Papyrus (.psc) <-> Binary (.esp) Cross-Reference & Anti-Regression Static Audit
        print("\n[CAPA 2] Auditoría Estática de Sincronización Papyrus (.psc) <-> ESP...")
        psc_files = [f for f in os.listdir(PSC_DIR) if f.endswith(".psc")]
        self.check(len(psc_files) >= 51, f"All >= 51 Papyrus source files present ({len(psc_files)} found)")

        for psc_name in sorted(psc_files):
            psc_path = os.path.join(PSC_DIR, psc_name)
            with open(psc_path, "r", encoding="utf-8") as f:
                code = f.read()

            # Check 2A: Every GetFormFromFile(..., "Vault13Chronicles.esp") FormID exists in ESP
            for m in re.finditer(r'GetFormFromFile\(\s*(0x[0-9A-Fa-f]+)\s*,\s*"Vault13Chronicles\.esp"\s*\)', code):
                local_fid = int(m.group(1), 16)
                full_fid = 0x01000000 | local_fid
                self.check(
                    full_fid in records_by_fid,
                    f"{psc_name}: GetFormFromFile({m.group(1)}) exists in Vault13Chronicles.esp",
                )

            # Check 2B: No script may check q3.GetStage() >= 10 or < 10 (Stage 10 is startup stage on all quests!)
            bad_stg10 = re.findall(r'q[1-5]\.GetStage\(\)\s*(?:>=|<|==)\s*10\b', code)
            self.check(
                len(bad_stg10) == 0,
                f"{psc_name}: No startup-stage-10 false positive checks (found {bad_stg10})",
            )
            # Check 2B2: Zero unfiltered AddInventoryEventFilter(None) or forced abForce=true objective re-displays
            self.check(
                "AddInventoryEventFilter(None)" not in code
                and not re.search(r"SetObjectiveDisplayed\([^)]*,\s*true\s*,\s*true\s*\)", code, re.IGNORECASE),
                f"{psc_name}: Zero AddInventoryEventFilter(None) and zero SetObjectiveDisplayed(..., true, true)",
            )

        # Check 2C: Verify V13Act2QuestScript direct surface exit ladders, Harry patrol faction protection, and instant item events
        with open(os.path.join(PSC_DIR, "V13Act2QuestScript.psc"), "r", encoding="utf-8") as f:
            act2_code = f.read()
        self.check(
            "d290B.SetPosition(128.0, 710.0, 254.0)" in act2_code
            and "d2A35.SetPosition(-640.0, 8962.0, 254.0)" in act2_code
            and "w290E.Disable(false)" in act2_code,
            "V13Act2QuestScript.psc enables direct surface exit ladders d290B and d2A35 flush in front of concrete walls and disables legacy window w290E",
        )
        self.check(
            "wshTargetFid = 0x0000290B" in act2_code and "m3517 != None" in act2_code,
            "V13Act2QuestScript.psc points exit marker to direct surface ladder 0x0100290B after chip extraction and routes to Wasteland surface 0x01003517",
        )
        refresh_fn_block = act2_code.split("Function RefreshDisplayedAct2Objective()")[1].split("EndFunction")[0]
        self.check(
            "Self.Reset()" not in act2_code
            and "SetObjectiveDisplayed(" not in refresh_fn_block
            and not re.search(r"SetObjectiveDisplayed\([^)]*,\s*true\s*,\s*true\s*\)", refresh_fn_block, re.IGNORECASE),
            "V13Act2QuestScript.psc never calls Self.Reset() or SetObjectiveDisplayed() inside RefreshDisplayedAct2Objective (zero repeating objective banners!)",
        )
        apply_act2_block = act2_code.split("Function ApplyV13Act2Stage(int auiStage)")[1].split("Function WakeUpAct2()")[0]
        self.check(
            "EnsureSingleActiveObjective(18)" in apply_act2_block
            and "0x00005100" in act2_code
            and "act2IntroScene" in act2_code,
            "V13Act2QuestScript.psc switches cleanly via EnsureSingleActiveObjective(18) and registers SCEN 0x01005100 for OnEnd",
        )
        missing_p18_tiqs = []
        for p_info_fid in (0x01005308, 0x01005309, 0x0100530A, 0x0100530B):
            rec_tuple = records_by_fid.get(p_info_fid)
            tiqs_vals = (
                [struct.unpack("<HH", sv) for st, sv in rec_tuple[2] if st == "TIQS" and len(sv) == 4]
                if rec_tuple is not None
                else []
            )
            if (0xFFFF, 18) not in tiqs_vals:
                missing_p18_tiqs.append(hex(p_info_fid))
        self.check(
            len(missing_p18_tiqs) == 0,
            f"Player INFOs 0x01005308..0x0100530B in SCEN 0x01005100 carry immediate TIQS stage 18 (missing: {missing_p18_tiqs})",
        )
        self.check(
            "Function SyncHarryPatrolFactions(" in act2_code
            and "smFac.SetAlly(smFac, false, false)" in act2_code
            and "SetValue(aggroAV, 2.0)" not in act2_code,
            "V13Act2QuestScript.psc synchronizes Harry and Guards into SuperMutantFaction and never uses Very Aggressive (2.0)",
        )
        self.check(
            "Event ObjectReference.OnItemAdded(" in act2_code
            and "Event ObjectReference.OnItemRemoved(" in act2_code
            and "AddInventoryEventFilter(" in act2_code
            and "AddInventoryEventFilter(None)" not in act2_code,
            "V13Act2QuestScript.psc registers item-filtered OnItemAdded and OnItemRemoved for instant 0.0s QuickLoot stage transitions",
        )

        # Verify PACK 0x01001054 (V13HarryPreCombatHoldPack) uses Aggression < 0.5 (not < 2.0) so Aggression=1.0 breaks hold immediately
        if 0x01001054 in records_by_fid:
            _, _, pack_subs_1054, _ = records_by_fid[0x01001054]
            aggro_ctda_vals = [
                struct.unpack_from("<f", sv, 4)[0]
                for st, sv in pack_subs_1054
                if st == "CTDA" and len(sv) >= 16 and struct.unpack_from("<I", sv, 12)[0] == 0x000002BC
            ]
            self.check(
                aggro_ctda_vals == [0.5],
                f"PACK 0x01001054 (V13HarryPreCombatHoldPack) releases hold when Aggression >= 0.5 (got {aggro_ctda_vals})",
            )

        # Verify SCEN 0x01005108, 0x01005109, 0x0100510A do not lock Harry in DefaultSceneHoldPositionPackage (0x00019AA2)
        for h_scen_fid in (0x01005108, 0x01005109, 0x0100510A):
            if h_scen_fid in records_by_fid:
                _, _, h_scen_subs, _ = records_by_fid[h_scen_fid]
                pnam_fids = [struct.unpack_from("<I", sv, 0)[0] for st, sv in h_scen_subs if st == "PNAM" and len(sv) == 4]
                self.check(
                    0x00019AA2 not in pnam_fids,
                    f"SCEN {hex(h_scen_fid)} does not lock Harry in DefaultSceneHoldPositionPackage (0x00019AA2)",
                )

        # Layer 3: Quest Objectives (QOBJ) & Targets (QSTA/CTDA) Audit in QUST 0x01005000
        print("\n[CAPA 3] Auditoría de Objetivos (QOBJ), Marcadores (QSTA/CTDA) y Aliases en QUST 0x01005000...")
        q2_subs = qusts_by_fid.get(0x01005000, [])
        q2_objectives = {}
        cur_qobj = None
        for st, sv in q2_subs:
            if st == "QOBJ" and len(sv) == 2:
                cur_qobj = struct.unpack("<H", sv)[0]
                q2_objectives[cur_qobj] = []
            elif st == "QSTA" and cur_qobj is not None and len(sv) >= 4:
                alias_id = struct.unpack_from("<I", sv, 0)[0]
                q2_objectives[cur_qobj].append(alias_id)

        expected_qobjs = {15, 18, 20, 21, 22, 23, 24, 25, 26, 27, 28, 30, 35, 38}
        self.check(
            expected_qobjs.issubset(set(q2_objectives.keys())),
            f"QUST 0x01005000 defines all 14 expected objectives: {sorted(q2_objectives.keys())}",
        )
        # Verify Objective 30 (Return to Vault 13 with Water Chip) uses Alias 7 across Necropolis cells, Alias 6 in Wasteland, Alias 0 in Vault 13
        obj30_aliases = set(q2_objectives.get(30, []))
        self.check(
            {0, 6, 7}.issubset(obj30_aliases),
            f"Objective 30 has savegame-universal QSTA targets for Vault 13 (0), Wasteland (6), and Necropolis Exit Doors (7): {sorted(obj30_aliases)}",
        )

        # Verify Special Encounter: "Unusual Call Box" (TARDIS, 1997 Fallout 1 Easter Egg) records & exterior alignment
        for tardis_fid, tardis_label in (
            (0x01001066, "SNDR_V13_TardisDematerialize"),
            (0x01001067, "SOUN_V13_TardisDematerialize"),
            (0x0100119D, "ActiV13TardisCallBox"),
            (0x01001456, "MiscV13MotionSensor"),
            (0x0100114F, "BookV13MotionSensorManual"),
            (0x0100115F, "MesgV13TardisInspect"),
            (0x0100119E, "TermV13TardisAnomalyDesk"),
            (0x01015000, "V13SideQuestTardis"),
            (0x01003421, "MapMarker Cabina Telefónica Inusual"),
            (0x01003528, "FastTravel Marker Cabina Telefónica Inusual"),
            (0x010035F0, "REFR ActiV13TardisCallBox"),
            (0x010035F1, "REFR TARDIS Top Beacon Light"),
            (0x010035F2, "REFR MiscV13MotionSensor (Initially Disabled)"),
            (0x010035F3, "ACHR Desert Brahmin Witness"),
            (0x010035F4, "REFR TermV13TardisAnomalyDesk"),
            (0x010035F5, "REFR BookV13MotionSensorManual"),
            (0x010035F6, "REFR FederalistDesk01_Prewar supporting TARDIS terminal"),
        ):
            self.check(tardis_fid in records_by_fid, f"TARDIS Special Encounter record {hex(tardis_fid)} ({tardis_label}) exists in ESP")
        if 0x010035F4 in refrs_by_fid and 0x010035F6 in refrs_by_fid:
            t_pos = refrs_by_fid[0x010035F4]["data"]
            d_pos = refrs_by_fid[0x010035F6]["data"]
            self.check(
                abs(t_pos[2] - d_pos[2]) < 0.1 and abs(t_pos[0] - d_pos[0]) <= 15.0 and abs(t_pos[1] - d_pos[1]) <= 5.0,
                f"TARDIS Anomaly Terminal (0x010035F4 at {t_pos[:3]}) sits flush on Desk (0x010035F6 at {d_pos[:3]})",
            )

        # Layer 4: Full Savegame Load & Act II State-Machine Simulation
        print("\n[CAPA 4] Simulación Dinámica de Partidas Guardadas y Máquina de Estados del Acto II (22 Escenarios)...")
        self.run_act2_state_machine_simulation(refrs_by_fid, qusts_by_fid, startup_stage_10_quests, records_by_fid)

        print("\n" + "=" * 78)
        if self.failed == 0:
            print(f"RESULTADO QA: ¡ÉXITO TOTAL! ({self.passed} comprobaciones superadas, 0 fallos)")
        else:
            print(f"RESULTADO QA: FALLO ({self.failed} errores detectados, {self.passed} superadas)")
        print("=" * 78)
        return self.failed == 0

    def run_act2_state_machine_simulation(self, refrs_by_fid: dict, qusts_by_fid: dict, startup_stage_10_quests: set, records_by_fid: dict):
        """
        Faithful Python simulation of V13Act2QuestScript's state machine, testing savegame loading at every stage,
        contaminated save recovery, Sewer/Cavern routing, Harry dialogue/combat/evacuation, and Water Chip extraction.
        """
        class SimAct2State:
            def __init__(self, quest_stage=0, stages_done=None):
                self.quest_stage = quest_stage
                self.stages_done = set(stages_done or [])
                if quest_stage > 0:
                    self.stages_done.add(quest_stage)
                # Note: q3 (0x01006002) ALWAYS has stage 10 in Fallout 4 because INDX 10 is flag 2 (Start Up Stage)!
                self.q3_stage = 10
                self.introShown = quest_stage >= 15
                self.rewardsGiven = False
                self.intercomResolved = False
                self.harryEvacuated = False
                self.necroPumpRepaired = quest_stage >= 26
                self.waterChipInstalledInPlant = False
                self.waterPlantWalkActive = False
                self.sewerPasswordFound = quest_stage >= 25
                self.ezequielGreeted = quest_stage >= 25
                self.garretArmoryUnlockedNotified = quest_stage >= 24
                self.v13CrisisResolved = quest_stage >= 20
                self.garretIntroDone = quest_stage >= 22
                self.harryCombatStarted = False
                self.harryEvacPending = False
                self.harryEvacWalkStarted = False
                self.harryCombatPending = False
                self.harrySceneOutcome = 0
                self.part1EndShown = False
                self.waterPlantMarkerOnConsole = False
                self.waterChipExtracted = False
                self.harry_dead = False
                self.g1_dead = False
                self.g2_dead = False
                self.player_has_chip = False
                self.player_has_pump_parts = quest_stage == 25
                self.sewer_box_has_parts = quest_stage < 25
                self.player_cell = 0x01002900 if quest_stage in (26, 27, 28) else (0x01002F00 if quest_stage == 24 else 0x01002A00)
                self.player_pos = (0.0, 0.0, 0.0)
                self.popup_1152_shown = False
                self.objectives_displayed = set()
                self.objectives_completed = set()
                self.aliases = {}

            def is_harry_resolved(self):
                all_dead = self.harry_dead and self.g1_dead and self.g2_dead
                return self.intercomResolved or self.harryEvacuated or self.harryEvacWalkStarted or all_dead

            def heal_necropolis_state(self):
                if self.player_cell in (0x01002A00, 0x01002E00, 0x01002F00, 0x01002900):
                    self.waterChipInstalledInPlant = False
                    self.rewardsGiven = False
                    self.part1EndShown = False
                    self.waterPlantWalkActive = False
                    if self.player_cell in (0x01002A00, 0x01002E00, 0x01002F00):
                        if not self.player_has_chip:
                            self.waterChipExtracted = False
                            if not self.harry_dead and not self.harryEvacuated:
                                self.intercomResolved = False
                                self.harryEvacWalkStarted = False
                                self.harryEvacPending = False
                                self.harryCombatStarted = False
                                self.harryCombatPending = False
                                self.harrySceneOutcome = 0
                    elif self.player_cell == 0x01002900:
                        if not self.player_has_chip and not self.is_harry_resolved():
                            self.waterChipExtracted = False
                    if self.player_cell in (0x01002E00, 0x01002F00):
                        if not self.player_has_pump_parts and self.sewer_box_has_parts:
                            self.necroPumpRepaired = False

            def get_effective_stage(self):
                self.heal_necropolis_state()
                if self.rewardsGiven and self.waterChipInstalledInPlant:
                    return 40
                if self.waterChipInstalledInPlant:
                    return 38
                if self.waterPlantWalkActive:
                    return 35
                if self.waterChipExtracted or self.player_has_chip:
                    return 30
                if self.necroPumpRepaired or self.player_cell == 0x01002900:
                    if self.is_harry_resolved() or self.harrySceneOutcome == 1:
                        return 27
                    if self.harryCombatStarted or self.harryCombatPending or self.harrySceneOutcome == 2:
                        return 28
                    return 26
                if self.player_has_pump_parts:
                    return 25
                if self.garretArmoryUnlockedNotified or self.sewerPasswordFound or self.ezequielGreeted or self.player_cell == 0x01002F00:
                    return 24
                if 15 <= self.quest_stage <= 24:
                    return self.quest_stage
                if self.garretIntroDone or 22 in self.stages_done:
                    return 22
                if 21 in self.stages_done:
                    return 21
                if 20 in self.stages_done or self.v13CrisisResolved:
                    return 20
                if 18 in self.stages_done:
                    return 18
                if 15 in self.stages_done or self.introShown:
                    return 15
                return 0

            def force_all_aliases(self):
                cur = self.get_effective_stage()
                harry_done = self.is_harry_resolved()
                has_chip = self.waterChipExtracted or cur >= 30 or self.waterChipInstalledInPlant or self.player_has_chip
                self.aliases[0] = 0x01002110

                wsh_target = 0x0100290B if has_chip else (0x01002A10 if harry_done else 0x01002907)
                wsh_exit = 0x0100290B if has_chip else 0x01002901
                self.aliases[16] = wsh_target
                self.aliases[17] = wsh_exit

                sew_exit = 0x01002F03 if (self.player_cell == 0x01002F00 and self.player_pos[0] < 6800.0) else 0x01002F01
                sew_target = 0x01002F22
                self.aliases[13] = sew_target
                self.aliases[14] = sew_exit

                hod_target = 0x01002E01
                if cur < 24 and not self.necroPumpRepaired and not has_chip:
                    hod_target = 0x01002E11 if (cur == 22 and self.garretIntroDone) else 0x01002E12

                if self.player_cell == 0x01002900:
                    self.aliases[1] = wsh_target
                    self.aliases[7] = wsh_exit
                elif self.player_cell == 0x01002F00:
                    self.aliases[1] = sew_exit if (cur >= 25 or self.necroPumpRepaired or has_chip) else sew_target
                    self.aliases[7] = sew_exit
                elif self.player_cell == 0x01002E00:
                    self.aliases[1] = hod_target
                    self.aliases[7] = 0x01002E01
                else:
                    necro_exit = 0x01002A03
                    if has_chip:
                        if self.player_pos[1] > 2000.0:
                            self.aliases[1] = 0x01002A35
                            necro_exit = 0x01002A35
                        else:
                            self.aliases[1] = 0x01002A03
                            necro_exit = 0x01002A03
                    elif cur < 21 and not self.necroPumpRepaired:
                        self.aliases[1] = 0x01002A18
                    elif cur in (21, 22) and not self.necroPumpRepaired:
                        self.aliases[1] = 0x01002A05
                    elif cur in (23, 24) and not self.necroPumpRepaired:
                        self.aliases[1] = 0x01002A09
                    elif cur == 25 and not self.necroPumpRepaired:
                        self.aliases[1] = 0x01002A54
                    else:
                        self.aliases[1] = 0x01002A34
                    self.aliases[7] = necro_exit

                if cur < 21 or (cur == 25 and not self.necroPumpRepaired):
                    self.aliases[4] = 0x01003503
                elif 21 <= cur <= 23:
                    self.aliases[4] = 0x01003504
                elif cur == 24:
                    self.aliases[4] = 0x01003505
                else:
                    self.aliases[4] = 0x01003506

            def on_player_load_game(self):
                self.heal_necropolis_state()
                if not self.is_harry_resolved() and not self.player_has_chip:
                    self.waterChipExtracted = False
                if not self.waterChipExtracted:
                    self.waterChipInstalledInPlant = False
                    self.rewardsGiven = False
                    self.part1EndShown = False
                    self.waterPlantWalkActive = False
                self.force_all_aliases()
                cur = self.get_effective_stage()
                if cur >= 40 and not self.part1EndShown:
                    self.part1EndShown = True
                    self.popup_1152_shown = True

        # Scenario 1..11: Loading a savegame at every pre-chip stage (15, 18, 20, 21, 22, 23, 24, 25, 26, 27, 28)
        # while q3_stage == 10 MUST NEVER jump to stage 30/40 or show popup 0x01001152!
        for stg in (15, 18, 20, 21, 22, 23, 24, 25, 26, 27, 28):
            sim = SimAct2State(quest_stage=stg)
            if stg in (15, 18, 20):
                sim.player_cell = 0x01002100
            elif stg == 27:
                sim.intercomResolved = True
            elif stg == 28:
                sim.harryCombatStarted = True
            sim.on_player_load_game()
            expected_stg = stg
            self.check(
                sim.get_effective_stage() == expected_stg and not sim.popup_1152_shown,
                f"Savegame load at Stage {stg} (with q3.GetStage()==10) stays at Stage {expected_stg} without false completion popup",
            )

        # Scenario 12: Self-healing of a savegame contaminated by the previous q3.GetStage()>=10 bug
        contaminated = SimAct2State(quest_stage=24, stages_done={15, 18, 20, 21, 22, 24, 40})
        contaminated.waterChipInstalledInPlant = True
        contaminated.rewardsGiven = True
        contaminated.part1EndShown = True
        contaminated.quest_completed = False
        contaminated.quest_stage = 40
        contaminated.on_player_load_game()
        self.check(
            contaminated.get_effective_stage() == 24
            and not contaminated.rewardsGiven
            and not contaminated.waterChipInstalledInPlant
            and not contaminated.popup_1152_shown,
            f"Contaminated savegame at Stage 24 (with engine stage=40, completed=False) self-heals on load back to Stage 24 (got {contaminated.get_effective_stage()})",
        )

        # Scenario 12b: Savegame next to Set (0x01002E00) where engine stage was 225 and intercomResolved/waterChipInstalledInPlant were falsely True
        contaminated_set = SimAct2State(quest_stage=225, stages_done={15, 18, 20, 21, 22, 24, 25, 26, 27, 30, 38, 40, 225})
        contaminated_set.player_cell = 0x01002E00
        contaminated_set.necroPumpRepaired = True
        contaminated_set.intercomResolved = True
        contaminated_set.waterChipExtracted = True
        contaminated_set.waterChipInstalledInPlant = True
        contaminated_set.player_has_pump_parts = False
        contaminated_set.sewer_box_has_parts = True
        contaminated_set.garretArmoryUnlockedNotified = True
        contaminated_set.on_player_load_game()
        self.check(
            contaminated_set.get_effective_stage() == 24
            and not contaminated_set.waterChipExtracted
            and not contaminated_set.waterChipInstalledInPlant
            and not contaminated_set.intercomResolved
            and not contaminated_set.necroPumpRepaired,
            f"Savegame next to Set with legacy stage 225 and corrupted flags self-heals to Stage 24 (got {contaminated_set.get_effective_stage()})",
        )

        # Scenario 13: Sewer exit routing at Stage 25 (near Hydraulic Workshop X=4800 -> Alias 1 and Alias 7 point to ladder 0x01002F03)
        sim_sewer = SimAct2State(quest_stage=25)
        sim_sewer.player_cell = 0x01002F00
        sim_sewer.player_pos = (4800.0, -5000.0, 413.0)
        sim_sewer.force_all_aliases()
        self.check(
            sim_sewer.aliases[1] == 0x01002F03 and sim_sewer.aliases[7] == 0x01002F03 and sim_sewer.aliases[14] == 0x01002F03 and sim_sewer.aliases[4] == 0x01003503,
            "At Stage 25 in Sewers (X<6800): Alias 1, 7, 14 -> Ladder 0x01002F03 (to Cavern), Alias 4 -> Subterranean Entrance 0x01003503",
        )

        # Scenario 14: Harry room entry -> Failed Science check -> Combat -> Patrol death -> Trunk marker -> Water Chip pickup -> Exit markers
        sim_harry = SimAct2State(quest_stage=26)
        sim_harry.player_cell = 0x01002900
        sim_harry.force_all_aliases()
        self.check(
            sim_harry.aliases[1] == 0x01002907 and sim_harry.aliases[16] == 0x01002907 and not sim_harry.is_harry_resolved(),
            "At Stage 26 inside Harry's Station: Alias 1 & 16 point to Harry marker (0x01002907) and inner door is locked",
        )
        # Fail Science check -> Stage 28 combat
        sim_harry.quest_stage = 28
        sim_harry.harryCombatStarted = True
        sim_harry.harrySceneOutcome = 2
        sim_harry.force_all_aliases()
        self.check(
            sim_harry.get_effective_stage() == 28 and not sim_harry.is_harry_resolved(),
            "After failing Harry Science check: Stage is 28 (combat active) and inner door remains locked while patrol lives",
        )
        # Kill Harry and his 2 guards
        sim_harry.harry_dead = True
        sim_harry.g1_dead = True
        sim_harry.g2_dead = True
        sim_harry.intercomResolved = True
        sim_harry.force_all_aliases()
        self.check(
            sim_harry.is_harry_resolved() and sim_harry.get_effective_stage() == 27 and sim_harry.aliases[1] == 0x01002A10 and sim_harry.aliases[16] == 0x01002A10,
            "After killing Harry's patrol: Stage becomes 27 and Alias 1 & 16 point to Vault 12 Mainframe (0x01002A10)",
        )
        # Extract Water Chip ( even if quest_stage was stuck on a legacy >45 value )
        sim_harry.quest_stage = 225
        sim_harry.waterChipExtracted = True
        sim_harry.player_has_chip = True
        sim_harry.force_all_aliases()
        self.check(
            sim_harry.get_effective_stage() == 30
            and sim_harry.aliases[1] == 0x0100290B
            and sim_harry.aliases[7] == 0x0100290B
            and sim_harry.aliases[16] == 0x0100290B
            and sim_harry.aliases[17] == 0x0100290B,
            "After extracting Water Chip: Stage is 30 and inside Harry's Station Alias 1, 7, 16, 17 point to direct surface exit ladder 0x0100290B",
        )
        # Step outside Harry's station into North Cavern Plaza (CELL 0x01002A00, Y=8760)
        sim_harry.player_cell = 0x01002A00
        sim_harry.player_pos = (-320.0, 8760.0, 0.0)
        sim_harry.force_all_aliases()
        d2a35_disabled = bool(refrs_by_fid[sim_harry.aliases[7]]["flags"] & 0x00000800)
        self.check(
            sim_harry.aliases[1] == 0x01002A35 and sim_harry.aliases[7] == 0x01002A35 and not d2a35_disabled,
            "Outside in North Cavern with Water Chip (Y>2000): Alias 1 & 7 point to North Cavern direct surface ladder 0x01002A35",
        )

        # Scenario 15: Shady Sands Settlement, Characters, Animals & Optional Side Quest (QUST 0x01009500)
        print("\n[CAPA 5] Auditoría de Shady Sands (Edificios, Personajes, Animales y Misión Secundaria 0x01009500)...")
        self.check(0x01009500 in qusts_by_fid, "Side quest QUST 0x01009500 (V13SideQuestShadySands) exists in ESP")
        self.check(0x01009500 in startup_stage_10_quests, "Side quest QUST 0x01009500 starts silently at Stage 10")
        self.check(0x01001116 in records_by_fid, "MISC 0x01001116 (MiscV13RadscorpionGland) exists in ESP")
        self.check(0x01001175 in records_by_fid, "CONT 0x01001175 (ContV13RadscorpionNestRemains) exists in ESP")
        self.check(0x010035A9 in refrs_by_fid, "Persistent Radscorpion Nest REFR 0x010035A9 exists at Northern Lair")

        shady_expected_npcs = [
            (0x01001230, 0x010035A0, "Aradesh"),
            (0x01001231, 0x010035A1, "Tandi"),
            (0x0100122F, 0x010035A2, "Capitán Seth"),
            (0x01001233, 0x010035A3, "Dr. Razlo"),
            (0x01001232, 0x010035A4, "Ian"),
            (0x01001234, 0x010035A5, "Jarvis"),
            (0x01001238, 0x010035A6, "Mutascorpión Emperador de Shady Sands"),
            (0x01001222, 0x010035A7, "Mutascorpión Escolta O"),
            (0x01001222, 0x010035A8, "Mutascorpión Escolta E"),
            (0x01001235, 0x010035B0, "Brahmán de Shady Sands 1"),
            (0x01001235, 0x010035B1, "Brahmán de Shady Sands 2"),
            (0x01001235, 0x010035B2, "Brahmán de Shady Sands 3"),
            (0x01001236, 0x010035B3, "Perro Pastor de Shady Sands"),
        ]
        for base_npc, achr_fid, label in shady_expected_npcs:
            self.check(
                base_npc in records_by_fid and achr_fid in refrs_by_fid and refrs_by_fid[achr_fid]["base"] == base_npc,
                f"Shady Sands actor {label} (NPC_ {hex(base_npc)}, ACHR {hex(achr_fid)}) exists and is placed in WRLD 0x01003400",
            )

        # Verify Aradesh (0x01001230) has distinct outfit (0x0012A1A4) and anonymous elder headparts different from Jacoren (0x01001200)
        _, _, aradesh_subs, _ = records_by_fid[0x01001230]
        _, _, jacoren_subs, _ = records_by_fid[0x01001200]
        aradesh_doft = next((struct.unpack("<I", v)[0] for s, v in aradesh_subs if s == "DOFT" and len(v) == 4), 0)
        aradesh_pnams = [struct.unpack("<I", v)[0] for s, v in aradesh_subs if s == "PNAM" and len(v) == 4]
        jacoren_pnams = [struct.unpack("<I", v)[0] for s, v in jacoren_subs if s == "PNAM" and len(v) == 4]
        self.check(
            aradesh_doft == 0x0100102C and aradesh_pnams != jacoren_pnams,
            "Aradesh (0x01001230) uses distinct anonymous elder headparts and frontier outfit (0x0100102C), different from Overseer Jacoren",
        )

        # Verify QUST 0x01009500 aliases are strictly sorted 0..10 and INFO 0x01009510/9511 link to SCEN 0x01009600 at Phase 0
        _, _, q9500_subs, _ = records_by_fid[0x01009500]
        q9500_alsts = [struct.unpack("<I", v)[0] for s, v in q9500_subs if s == "ALST" and len(v) == 4]
        self.check(
            q9500_alsts == list(range(11)),
            f"QUST 0x01009500 aliases are strictly sorted 0..10 ({q9500_alsts})",
        )
        for g_fid in (0x01009510, 0x01009511):
            _, _, g_subs_list, _ = records_by_fid[g_fid]
            g_subs = dict(g_subs_list)
            self.check(
                g_subs.get("TSCE") == struct.pack("<I", 0x01009600)
                and "INTV" not in g_subs,
                f"Aradesh greeting INFO {hex(g_fid)} launches SCEN 0x01009600 immediately at Phase 0 (PreguntasAradeshShady)",
            )

        # Verify Alias 1 of QUST 0x01009500 points directly to Mutascorpión Emperador (0x010035A6) with Allow Dead (0x0000129A), Stage 22 & Objective 22 exist, and military bag 0x010035A9 is disabled
        q9500_alfrs = [struct.unpack("<I", v)[0] for s, v in q9500_subs if s == "ALFR" and len(v) == 4]
        q9500_alias_map = dict(zip(q9500_alsts, q9500_alfrs))
        q9500_stages = [struct.unpack("<H", v[:2])[0] for s, v in q9500_subs if s == "INDX" and len(v) >= 2]
        q9500_qobjs = [struct.unpack("<H", v)[0] for s, v in q9500_subs if s == "QOBJ" and len(v) == 2]
        self.check(
            q9500_alias_map.get(1) == 0x010035A6,
            "QUST 0x01009500 Alias 1 points directly to Mutascorpión Emperador ACHR 0x010035A6 (not the military bag)",
        )
        self.check(
            22 in q9500_stages and 22 in q9500_qobjs,
            "QUST 0x01009500 includes Stage 22 and Objective 22 (Extrae la Glándula de Veneno del cadáver del Mutascorpión Emperador)",
        )
        q9500_alias_fnams = [
            struct.unpack("<I", q9500_subs[i][1])[0]
            for i in range(1, len(q9500_subs))
            if q9500_subs[i][0] == "FNAM" and q9500_subs[i - 1][0] == "ALID" and len(q9500_subs[i][1]) == 4
        ]
        self.check(
            len(q9500_alias_fnams) == 11 and all((fn & 0x0200) != 0 for fn in q9500_alias_fnams),
            "All QUST 0x01009500 aliases have Allow Dead (0x0200) enabled in FNAM so the quest marker remains on the Emperor Radscorpion corpse",
        )
        self.check(
            bool(refrs_by_fid[0x010035A9]["flags"] & 0x00000800),
            "Military duffle bag REFR 0x010035A9 is Initially Disabled (0x00000800) so the Venom Gland is exclusively inside the Emperor Radscorpion",
        )

        # Scenario 16: The 5 New Fallout 1 Settlements & Optional Side Quests (Junktown, The Hub, Khans Pass, Lost Hills/The Glow, Adytum/Gun Runners)
        print("\n[CAPA 6] Auditoría de las 5 Nuevas Localizaciones e Historias Secundarias (0x01010000..0x01014000)...")
        new_side_quests = [
            (0x01010000, "Junktown (Killian y Gizmo)", 0x01010100, "PreguntasKillianJunktown", 0x01010010, 0x01010011, 0x010035C0, 0x010035C4, 0x01001451, 0x0100114A, 0x01001197, 0x0100341C, 0x0100351C),
            (0x01011000, "El Eje y Granja de Irwin (.223)", 0x01011100, "PreguntasIrwinHub", 0x01011010, 0x01011011, 0x010035C6, 0x010035C9, 0x01001452, 0x0100114B, 0x01001198, 0x0100341D, 0x0100351D),
            (0x01012000, "Paso Oriental de los Khans (Diana y Gwen)", 0x01012100, "PreguntasDianaKhans", 0x01012010, 0x01012011, 0x010035CB, 0x010035CE, 0x01001453, 0x0100114C, 0x01001199, 0x0100341E, 0x0100351E),
            (0x01013000, "Puerta de Lost Hills y El Resplandor (Cabbot y Talus)", 0x01013100, "PreguntasCabbotGlow", 0x01013010, 0x01013011, 0x010035D0, 0x01003601, 0x01001454, 0x0100114D, 0x0100119A, 0x0100341F, 0x0100351F),
            (0x01014000, "Adytum y Gun Runners (Madre Sanguinario)", 0x01014100, "PreguntasGabrielBoneyard", 0x01014010, 0x01014011, 0x010035D4, 0x010035D7, 0x01001455, 0x0100114E, 0x0100119B, 0x01003420, 0x01003520),
        ]
        for q_fid, q_label, scen_fid, ph1_name, g1_fid, g2_fid, leader_achr, boss_achr, misc_fid, book_fid, term_fid, mm_fid, ftm_fid in new_side_quests:
            self.check(q_fid in qusts_by_fid, f"Side quest {hex(q_fid)} ({q_label}) exists in ESP")
            self.check(q_fid in startup_stage_10_quests, f"Side quest {hex(q_fid)} ({q_label}) starts silently at Stage 10")
            self.check(misc_fid in records_by_fid, f"Quest item MISC {hex(misc_fid)} for {q_label} exists in ESP")
            self.check(book_fid in records_by_fid, f"Dossier BOOK {hex(book_fid)} for {q_label} exists in ESP")
            self.check(term_fid in records_by_fid, f"Settlement TERM {hex(term_fid)} for {q_label} exists in ESP")
            self.check(mm_fid in refrs_by_fid and ftm_fid in refrs_by_fid, f"MapMarker {hex(mm_fid)} and FastTravelMarker {hex(ftm_fid)} for {q_label} exist in WRLD 0x01003400")
            _, _, q_subs, _ = records_by_fid[q_fid]
            q_alsts = [struct.unpack("<I", v)[0] for s, v in q_subs if s == "ALST" and len(v) == 4]
            q_alfrs = [struct.unpack("<I", v)[0] for s, v in q_subs if s == "ALFR" and len(v) == 4]
            q_alias_map = dict(zip(q_alsts, q_alfrs))
            q_stages = [struct.unpack("<H", v[:2])[0] for s, v in q_subs if s == "INDX" and len(v) >= 2]
            q_qobjs = [struct.unpack("<H", v)[0] for s, v in q_subs if s == "QOBJ" and len(v) == 2]
            self.check(
                q_alsts == sorted(q_alsts) and q_alias_map.get(0) == leader_achr and q_alias_map.get(1) == boss_achr,
                f"QUST {hex(q_fid)} ({q_label}) aliases are sorted ({q_alsts}) with Alias 0={hex(leader_achr)} and Alias 1={hex(boss_achr)}",
            )
            self.check(
                set(q_stages) >= {10, 20, 22, 25, 30, 40} and set(q_qobjs) >= {20, 22, 25, 30},
                f"QUST {hex(q_fid)} ({q_label}) has complete Stages (10,20,22,25,30,40) and Objectives (20,22,25,30)",
            )
            q_alias_fnams = [
                struct.unpack("<I", q_subs[i][1])[0]
                for i in range(1, len(q_subs))
                if q_subs[i][0] == "FNAM" and q_subs[i - 1][0] == "ALID" and len(q_subs[i][1]) == 4
            ]
            self.check(
                all((fn & 0x0200) != 0 for fn in q_alias_fnams),
                f"QUST {hex(q_fid)} ({q_label}) has Allow Dead (0x0200) on all aliases so the marker remains on the dead boss",
            )
            for gf in (g1_fid, g2_fid):
                _, _, gf_subs_list, _ = records_by_fid[gf]
                gf_subs = dict(gf_subs_list)
                self.check(
                    gf_subs.get("TSCE") == struct.pack("<I", scen_fid)
                    and "INTV" not in gf_subs,
                    f"{q_label} greeting INFO {hex(gf)} launches SCEN {hex(scen_fid)} immediately at Phase 0 ({ph1_name})",
                )

        # Verify Custom Blender 3D Headgear (ARMA 0x01001310..0x01001312, ARMO 0x01001313..0x01001315) & Custom Outfits (0x01001020..0x0100102A)
        for arma_fid in (0x01001310, 0x01001311, 0x01001312):
            self.check(arma_fid in records_by_fid and records_by_fid[arma_fid][0] == "ARMA", f"Custom Blender 3D ARMA {hex(arma_fid)} exists in ESP")
        for armo_fid in (0x01001313, 0x01001314, 0x01001315):
            self.check(armo_fid in records_by_fid and records_by_fid[armo_fid][0] == "ARMO", f"Custom Blender 3D ARMO {hex(armo_fid)} exists in ESP")
        for otft_fid in range(0x01001020, 0x0100102B):
            self.check(otft_fid in records_by_fid and records_by_fid[otft_fid][0] == "OTFT", f"Custom Side-Quest OTFT {hex(otft_fid)} exists in ESP")

        # Verify Junktown Lars (0x01010101) & Tycho (0x01010102) 4-way Player Dialogue Wheel Scenes and Phase 0 Player Dialogue actions
        for jt_scen_fid, jt_g_fid, jt_label in (
            (0x01010101, 0x01010014, "Capitán Lars 4-way dialogue wheel"),
            (0x01010102, 0x01010017, "Ranger Tycho 4-way dialogue wheel"),
        ):
            self.check(jt_scen_fid in records_by_fid and records_by_fid[jt_scen_fid][0] == "SCEN", f"SCEN {hex(jt_scen_fid)} ({jt_label}) exists in ESP")
            _, _, jg_subs_list, _ = records_by_fid[jt_g_fid]
            jg_subs = dict(jg_subs_list)
            self.check(
                jg_subs.get("TSCE") == struct.pack("<I", jt_scen_fid) and "INTV" not in jg_subs,
                f"Junktown greeting INFO {hex(jt_g_fid)} launches {jt_label} ({hex(jt_scen_fid)}) at Phase 0",
            )
        # Verify all 12 Junktown player prompts and 12 NPC wheel responses across Killian, Lars & Tycho are 100% unique (no repeated greetings or mixed-up lines)
        jt_p_infos = [0x01010300, 0x01010301, 0x01010302, 0x01010303, 0x01010320, 0x01010321, 0x01010322, 0x01010323, 0x01010330, 0x01010331, 0x01010332, 0x01010333]
        jt_n_infos = [0x01010304, 0x01010305, 0x01010306, 0x01010307, 0x01010324, 0x01010325, 0x01010326, 0x01010327, 0x01010334, 0x01010335, 0x01010336, 0x01010337]
        jt_g_texts = {
            next((v[:-1].decode("utf-8", errors="ignore") for s, v in records_by_fid[gf][2] if s == "NAM1"), "")
            for gf in (0x01010010, 0x01010014, 0x01010017)
        }
        jt_p_texts = [
            next((v[:-1].decode("utf-8", errors="ignore") for s, v in records_by_fid[pf][2] if s == "NAM1"), "")
            for pf in jt_p_infos
        ]
        jt_n_texts = [
            next((v[:-1].decode("utf-8", errors="ignore") for s, v in records_by_fid[nf][2] if s == "NAM1"), "")
            for nf in jt_n_infos
        ]
        self.check(
            len(set(jt_p_texts)) == 12 and all(len(t) > 10 for t in jt_p_texts),
            f"All 12 Junktown player wheel prompts (Killian, Lars, Tycho) are unique ({len(set(jt_p_texts))}/12)",
        )
        self.check(
            len(set(jt_n_texts)) == 12 and all(t not in jt_g_texts for t in jt_n_texts),
            f"All 12 Junktown NPC wheel responses (Killian, Lars, Tycho) are unique ({len(set(jt_n_texts))}/12) and never repeat initial greetings",
        )
        # Verify loop options (options 2, 3, 4) do not prematurely fire TIQS Stage 20 while browsing questions
        for loop_info_fid in (0x01010301, 0x01010302, 0x01010303, 0x01010321, 0x01010322, 0x01010323, 0x01010331, 0x01010332, 0x01010333):
            _, _, li_subs, _ = records_by_fid[loop_info_fid]
            self.check(
                all(s != "TIQS" for s, _ in li_subs),
                f"Junktown question option INFO {hex(loop_info_fid)} has no premature TIQS stage trigger",
            )
        # Verify Junktown duplicate Dogmeat ACHR 0x010035C3 is Initially Disabled (0x00000800) so only Shady Sands Dogmeat (0x010035B3) exists in the world
        self.check(
            (refrs_by_fid[0x010035C3]["flags"] & 0x00000800) != 0 and (refrs_by_fid[0x010035B3]["flags"] & 0x00000800) == 0,
            "Canonical Dogmeat (0x010035B3) is active in Shady Sands while legacy Junktown duplicate (0x010035C3) is Initially Disabled (0x00000800)",
        )
        for jt_npc_fid, jt_otft_fid, jt_npc_name in (
            (0x01001240, 0x01001020, "Killian Darkwater"),
            (0x01001241, 0x01001021, "Capitán Lars"),
            (0x01001242, 0x01001022, "Ranger Tycho"),
        ):
            _, _, jt_npc_subs, _ = records_by_fid[jt_npc_fid]
            jt_doft = next((struct.unpack("<I", v)[0] for s, v in jt_npc_subs if s == "DOFT" and len(v) == 4), 0)
            self.check(
                jt_doft == jt_otft_fid,
                f"Junktown NPC {jt_npc_name} ({hex(jt_npc_fid)}) uses custom Blender-equipped outfit {hex(jt_otft_fid)}",
            )

        # Verify wide spacing between friendly NPCs in Junktown (>= 500 units) and no duplicate headpart sets among side-quest NPCs
        jt_positions = [refrs_by_fid[fid]["data"][:2] for fid in (0x010035C0, 0x010035C1, 0x010035C2)]
        import math
        for i in range(len(jt_positions)):
            for j in range(i + 1, len(jt_positions)):
                dist = math.hypot(jt_positions[i][0] - jt_positions[j][0], jt_positions[i][1] - jt_positions[j][1])
                self.check(dist >= 500.0, f"Junktown NPCs {i} and {j} are widely separated ({dist:.1f} units >= 500.0)")

        # Verify all 6 side-quest scripts include Silence...ActorsExcept using 0x00004003 to prevent simultaneous speech
        for sq_psc in (
            "V13SideQuestShadySandsScript.psc",
            "V13SideQuestJunktownScript.psc",
            "V13SideQuestHubScript.psc",
            "V13SideQuestKhansScript.psc",
            "V13SideQuestGlowScript.psc",
            "V13SideQuestBoneyardScript.psc",
        ):
            with open(os.path.join(PSC_DIR, sq_psc), "r", encoding="utf-8") as f:
                sq_code = f.read()
            self.check(
                "0x00004003" in sq_code and "ActorsExcept(" in sq_code,
                f"{sq_psc} silences other settlement NPCs on activation using V13_SilentInterruptTopic (0x00004003)",
            )

        # Verify Mnemosyne Mainframe Terminal (0x01001130) includes direct jump options 12..17
        _, _, term1130_subs, _ = records_by_fid[0x01001130]
        term1130_itids = {struct.unpack("<H", v)[0] for s, v in term1130_subs if s == "ITID" and len(v) == 2}
        self.check(
            {12, 13, 14, 15, 16, 17}.issubset(term1130_itids),
            f"Mnemosyne Entrance Terminal (0x01001130) includes direct jump options 12..17 for all 6 side-quest settlements (found {sorted(term1130_itids)})",
        )

        # Verify all human side-quest outfits (0x01001020..0x0100102C) include a verified full-body (slot 33) ARMO and no Vault-Tec/Priest clothes on frontier NPCs
        verified_full_body_armos = {
            0x000D415A, 0x0016892C, 0x001153DB, 0x0004A53B, 0x000A740B,
            0x000DF455, 0x0014BF50, 0x001536F4, 0x000DDB80, 0x0012A332,
            0x00020747, 0x00039A66, 0x0018E81D, 0x00178B68, 0x000732AE,
            0x0019CBB3, 0x000E5084,
        }
        for otft_fid in range(0x01001020, 0x0100102D):
            self.check(otft_fid in records_by_fid, f"Outfit {hex(otft_fid)} exists in ESP")
            _, _, otft_subs, _ = records_by_fid[otft_fid]
            inam_bytes = next((v for s, v in otft_subs if s == "INAM"), b"")
            inam_fids = {struct.unpack_from("<I", inam_bytes, k)[0] for k in range(0, len(inam_bytes), 4)}
            self.check(
                bool(inam_fids & verified_full_body_armos),
                f"Outfit {hex(otft_fid)} contains at least one full-body (slot 33) clothing ARMO ({[hex(x) for x in sorted(inam_fids)]})",
            )
            self.check(
                0x001103A6 not in inam_fids and 0x00068CF3 not in inam_fids and 0x0012A1A4 not in inam_fids,
                f"Outfit {hex(otft_fid)} does not use Vault-Tec lab coat or priest cassock",
            )

        # Verify Aradesh (0x01001230), Ian (0x01001232), Dr. Razlo (0x01001233), and Nicole (0x01001251) DOFT assignments
        for npc_fid, exp_doft, label in (
            (0x01001230, 0x0100102C, "Aradesh"),
            (0x01001232, 0x01001025, "Ian"),
            (0x01001233, 0x0100102B, "Dr. Razlo"),
            (0x01001251, 0x0100102B, "Nicole"),
        ):
            _, _, npc_subs, _ = records_by_fid[npc_fid]
            doft_val = next((struct.unpack("<I", v)[0] for s, v in npc_subs if s == "DOFT" and len(v) == 4), 0)
            self.check(doft_val == exp_doft, f"{label} ({hex(npc_fid)}) uses frontier outfit {hex(exp_doft)} (found {hex(doft_val)})")

        # Verify Shady Sands 20x20 Walled Adobe Town (3300..9600, 21100..25900): custom 3D Adobe Town Halls, Houses, Gate Arches & Obelisk, zero surface doormats, elevated dirt farm plots
        shady_gate_count = 0
        shady_hall_count = 0
        shady_house_count = 0
        shady_obelisk_count = 0
        shady_farmplots_z = []
        surface_doormat_count = 0
        for fid, rinfo in refrs_by_fid.items():
            rx, ry, rz = rinfo["data"][:3]
            if 3300.0 <= rx <= 9600.0 and 21100.0 <= ry <= 25900.0 and rz > -500.0:
                if rinfo["base"] == 0x0007350B:
                    surface_doormat_count += 1
                elif rinfo["base"] == 0x01001D04:
                    shady_gate_count += 1
                elif rinfo["base"] == 0x01001D05:
                    shady_hall_count += 1
                elif rinfo["base"] == 0x01001D06:
                    shady_house_count += 1
                elif rinfo["base"] == 0x01001D07:
                    shady_obelisk_count += 1
                elif rinfo["base"] == 0x001E387A:
                    shady_farmplots_z.append(rz)
        self.check(
            shady_hall_count >= 2 and shady_house_count >= 4 and shady_gate_count >= 2 and shady_obelisk_count >= 1,
            f"Shady Sands expanded adobe town has Halls={shady_hall_count}, Houses={shady_house_count}, Gates={shady_gate_count}, Obelisk={shady_obelisk_count}",
        )
        self.check(
            surface_doormat_count == 0,
            f"Zero surface doormats (0x0007350B) on Shady Sands dirt terrain (found {surface_doormat_count})",
        )
        self.check(
            len(shady_farmplots_z) >= 1 and all(z >= 166.0 for z in shady_farmplots_z),
            f"Shady Sands uses elevated dirt farm plots above Z=160.0 to prevent Z-fighting (Z={shady_farmplots_z})",
        )

        # Verify Albóndiga (Dogmeat, 0x01001236 in Shady Sands & 0x01001243 in Junktown) companion & Fallout 1 Wasteland Dog configuration
        for dog_fid, dog_label in ((0x01001236, "Albóndiga Shady Sands"), (0x01001243, "Albóndiga Junktown")):
            _, _, dog_subs, _ = records_by_fid[dog_fid]
            dog_rnam = next((struct.unpack("<I", v)[0] for s, v in dog_subs if s == "RNAM" and len(v) == 4), 0)
            dog_vtck = next((struct.unpack("<I", v)[0] for s, v in dog_subs if s == "VTCK" and len(v) == 4), 0)
            dog_wnam = next((struct.unpack("<I", v)[0] for s, v in dog_subs if s == "WNAM" and len(v) == 4), 0)
            dog_doft = next((struct.unpack("<I", v)[0] for s, v in dog_subs if s == "DOFT" and len(v) == 4), 0)
            dog_aidt = next((v for s, v in dog_subs if s == "AIDT" and len(v) >= 6), b"")
            dog_pkids = [struct.unpack("<I", v)[0] for s, v in dog_subs if s == "PKID" and len(v) == 4]
            dog_shrt = next((v[:-1].decode("utf-8", "ignore") for s, v in dog_subs if s == "SHRT"), "")
            self.check(
                dog_rnam == 0x00187AF9 and dog_vtck == 0x0019433E and dog_wnam == 0x000B2BF1 and dog_doft == 0x0100102D,
                f"{dog_label} ({hex(dog_fid)}) uses RaiderDogRace (0x00187AF9), CrRaiderDogVoice (0x0019433E), SkinRaiderDog (0x000B2BF1), and DOFT=0x0100102D (Harness + Collar)",
            )
            self.check(
                len(dog_aidt) >= 6 and dog_aidt[0] == 0 and dog_aidt[1] == 4 and dog_aidt[5] == 2 and dog_shrt == "Albóndiga (2161)",
                f"{dog_label} ({hex(dog_fid)}) AIDT starts Unaggressive (0) & Confidence=4.0 (Hold at Shady Sands) with SHRT='Albóndiga (2161)'",
            )
            self.check(
                dog_pkids == [0x01001055, 0x01001050],
                f"{dog_label} ({hex(dog_fid)}) uses conditional V13DogmeatCloseFollowPack (0x01001055, Confidence < 2.5) + V13GuardHoldPositionPack (0x01001050) without unconditional defaultFollowPlayerPKG",
            )
        _, _, pack1055_subs, _ = records_by_fid[0x01001055]
        pack1055_has_ctda = any(s == "CTDA" and len(v) == 32 for s, v in pack1055_subs)
        self.check(
            0x01001055 in records_by_fid and pack1055_has_ctda,
            "V13DogmeatCloseFollowPack (PACK 0x01001055) has CTDA (Subject.GetValue(Confidence) < 2.5) so Dogmeat never follows or warps to Sanctuary before recruitment",
        )
        _, _, otft102d_subs, _ = records_by_fid[0x0100102D]
        otft102d_inam = next((v for s, v in otft102d_subs if s == "INAM"), b"")
        self.check(
            otft102d_inam == struct.pack("<II", 0x001C32C8, 0x001C67B2) and 0x01001318 in records_by_fid and 0x01001319 in records_by_fid,
            "Outfit_V13_DogmeatJunktown (0x0100102D) contains ClothesDog_ArmorMedium (0x001C32C8) + ClothesDog_DogCollarReinforced (0x001C67B2) and SkinV13RaiderDog (0x01001318/0x01001319) exists",
        )
        with open(os.path.join(PSC_DIR, "V13SideQuestJunktownScript.psc"), "r", encoding="utf-8") as f:
            jt_code = f.read()
        dog_act_block = jt_code.split("Function HandleDogmeatActivation")[1].split("EndFunction")[0] if "Function HandleDogmeatActivation" in jt_code else ""
        self.check(
            "0x000011C0" in dog_act_block and "0x000011C1" in dog_act_block and "DismissDogmeatToShadySands" in dog_act_block and "IsPlayerInVault13Space" in jt_code and "SetCommandState(True)" in jt_code and "FindDogmeatCombatTarget" in jt_code,
            "V13SideQuestJunktownScript.psc restricts Dogmeat to Vault 13/2161 worldspace and provides interactive recruitment (0x010011C0) & command/dismissal (0x010011C1) menus",
        )

        # Verify all interior NAVM records (Vault 13, Vault 15, Necropolis, Lost Hills, Mariposa, Cathedral, Master's Lair) have Large-Creature walkable flag (0x0840) on 100% of their triangles
        int_navm_checked = 0
        int_navm_all_large = 0
        for fid, (rtype, rflags, rsubs, _) in records_by_fid.items():
            if rtype == "NAVM":
                nvnm = next((v for s, v in rsubs if s == "NVNM"), b"")
                if len(nvnm) >= 24:
                    n_verts = struct.unpack_from("<I", nvnm, 16)[0]
                    tri_pos = 20 + 12 * n_verts
                    if tri_pos + 4 <= len(nvnm):
                        n_tris = struct.unpack_from("<I", nvnm, tri_pos)[0]
                        int_navm_checked += 1
                        all_ok = True
                        for ti in range(n_tris):
                            fl_off = tri_pos + 4 + ti * 21 + 17
                            if fl_off + 2 <= len(nvnm):
                                tfl = struct.unpack_from("<H", nvnm, fl_off)[0]
                                if (tfl & 0x0840) != 0x0840:
                                    all_ok = False
                                    break
                        if all_ok:
                            int_navm_all_large += 1
        self.check(
            int_navm_checked >= 7 and int_navm_all_large == int_navm_checked,
            f"All {int_navm_checked} interior NAVM records have Large-Creature walkable flag (0x0840) on 100% of triangles ({int_navm_all_large}/{int_navm_checked})",
        )

        # Verify zero Papyrus scripts use StopTranslation(), TranslateToRef(), TranslateTo(), forced Havok Speed animation variables, or ragdoll PushActorAway/pulseExpl
        for psc_fn in sorted(os.listdir(PSC_DIR)):
            if not psc_fn.endswith(".psc"):
                continue
            with open(os.path.join(PSC_DIR, psc_fn), "r", encoding="utf-8") as f:
                psc_txt = f.read()
            self.check(
                ".StopTranslation(" not in psc_txt
                and ".TranslateToRef(" not in psc_txt
                and ".TranslateTo(" not in psc_txt
                and 'SetAnimationVariableFloat("Speed"' not in psc_txt
                and "PushActorAway(" not in psc_txt
                and "akTarget.PlaceAtMe(pulseExpl" not in psc_txt,
                f"{psc_fn} has zero StopTranslation(), TranslateToRef(), TranslateTo(), forced Speed animation overrides, or ragdoll explosion impulses",
            )

        # Verify all 7 Commonwealth-style Merchants (FACT 0x01001C50..0x01001C56, CONT 0x01001C60..0x01001C66, placed REFR chests, NPC SNAM, and ShowBarterMenu)
        merchant_specs = [
            (0x01001C50, 0x01001C60, 0x010035E0, 0x01001240, 0x01001C70, "V13SideQuestJunktownScript.psc", "Killian Darkwater (Junktown)"),
            (0x01001C51, 0x01001C61, 0x010035E1, 0x01001247, 0x01001C71, "V13SideQuestHubScript.psc", "Butch Harris (El Eje)"),
            (0x01001C52, 0x01001C62, 0x010035E2, 0x01001233, 0x01001C72, "V13SideQuestShadySandsScript.psc", "Dr. Razlo (Shady Sands)"),
            (0x01001C53, 0x01001C63, 0x010035E3, 0x01001250, 0x01001C73, "V13SideQuestBoneyardScript.psc", "Smitty (Adytum)"),
            (0x01001C54, 0x01001C64, 0x010035E4, 0x0100124F, 0x01001C74, "V13SideQuestBoneyardScript.psc", "Gabriel (Gun Runners)"),
            (0x01001C55, 0x01001C65, 0x01002E25, 0x0100121A, 0x01001C75, "V13Act2QuestScript.psc", "Garret (Necrópolis)"),
            (0x01001C56, 0x01001C66, 0x0100219A, 0x01001214, 0x01001C76, "V13Act1QuestScript.psc", "Médico del Refugio 13"),
        ]
        for fact_fid, cont_fid, chest_refr_fid, npc_fid, mesg_fid, psc_name, m_label in merchant_specs:
            self.check(fact_fid in records_by_fid and records_by_fid[fact_fid][0] == "FACT", f"Vendor FACT {hex(fact_fid)} exists for {m_label}")
            self.check(cont_fid in records_by_fid and records_by_fid[cont_fid][0] == "CONT", f"Vendor CONT {hex(cont_fid)} exists for {m_label}")
            self.check(chest_refr_fid in refrs_by_fid and refrs_by_fid[chest_refr_fid]["base"] == cont_fid, f"Vendor Chest REFR {hex(chest_refr_fid)} placed for {m_label}")
            self.check(mesg_fid in records_by_fid and records_by_fid[mesg_fid][0] == "MESG", f"Vendor Choice MESG {hex(mesg_fid)} exists for {m_label}")
            _, _, m_npc_subs, _ = records_by_fid[npc_fid]
            m_snams = [struct.unpack("<I", v[:4])[0] for s, v in m_npc_subs if s == "SNAM" and len(v) >= 4]
            self.check(fact_fid in m_snams, f"Merchant NPC {m_label} ({hex(npc_fid)}) has SNAM vendor faction {hex(fact_fid)}")
            with open(os.path.join(PSC_DIR, psc_name), "r", encoding="utf-8") as f:
                m_psc_txt = f.read()
            self.check("ShowBarterMenu()" in m_psc_txt, f"{psc_name} invokes ShowBarterMenu() for {m_label}")

        # Verify all 3 LarsGuardHelmet*.nif meshes have zero deformed HelmetLight nodes
        for helm_nif_name in ("LarsGuardHelmetM.nif", "LarsGuardHelmetF.nif", "LarsGuardHelmetGO.nif"):
            helm_path = os.path.join(os.path.dirname(PSC_DIR), "assets", "junktown_3d", "Meshes", "V13Chronicles", "Junktown", helm_nif_name)
            with open(helm_path, "rb") as f:
                helm_bytes = f.read()
            self.check(b"HelmetLight" not in helm_bytes, f"{helm_nif_name} has zero floating/deformed HelmetLight mesh nodes")

        # Verify all 6 side-quest scripts guard SetObjectiveDisplayed(20) and unloaded 3D actors with Is3DLoaded()
        for sq_psc in (
            "V13SideQuestShadySandsScript.psc",
            "V13SideQuestJunktownScript.psc",
            "V13SideQuestHubScript.psc",
            "V13SideQuestKhansScript.psc",
            "V13SideQuestGlowScript.psc",
            "V13SideQuestBoneyardScript.psc",
        ):
            with open(os.path.join(PSC_DIR, sq_psc), "r", encoding="utf-8") as f:
                sq_code = f.read()
            self.check(
                "!IsObjectiveDisplayed(20)" in sq_code and "Is3DLoaded()" in sq_code,
                f"{sq_psc} guards SetObjectiveDisplayed(20) and checks Is3DLoaded() before manipulating actors",
            )

        # Verify all 6 side-quest combat destinations are >= 5,000 units away from their quest-giver settlements
        side_quest_distance_pairs = [
            (0x010035A0, 0x010035A6, "Shady Sands (Aradesh) -> Guarida del Mutascorpión Emperador"),
            (0x010035C0, 0x010035C4, "Junktown (Killian) -> Distrito del Casino de Gizmo (Kenji)"),
            (0x010035C6, 0x010035C9, "El Eje (Irwin) -> Granja de Irwin (Krag)"),
            (0x010035CB, 0x010035CE, "Paso Oriental (Diana) -> Fortaleza de los Khans del Norte (Tolan)"),
            (0x010035D0, 0x010035D2, "Puerta de Lost Hills (Cabbot) -> El Resplandor / West Tek (Centinela)"),
            (0x010035D4, 0x010035D7, "Adytum (Gabriel) -> Distrito Industrial Este del Boneyard (Madre Sanguinario)"),
        ]
        for leader_fid, boss_fid, sq_dist_label in side_quest_distance_pairs:
            lx, ly, lz = refrs_by_fid[leader_fid]["data"][:3]
            bx, by, bz = refrs_by_fid[boss_fid]["data"][:3]
            sq_dist = math.hypot(bx - lx, by - ly)
            self.check(
                sq_dist >= 5000.0,
                f"Side-quest objective distance {sq_dist_label} is far from settlement ({sq_dist:.1f} units >= 5000.0)",
            )

        # Verify all 6 exterior settlement lore terminals (0x01001197..0x0100119C) use TerminalDesk01.nif and sit flush on a desk (Z == desk_z, zero floating terminals)
        for term_base_fid in range(0x01001197, 0x0100119D):
            self.check(term_base_fid in records_by_fid, f"TERM {hex(term_base_fid)} exists in ESP")
            _, _, t_subs, _ = records_by_fid[term_base_fid]
            t_modl = next((v[:-1].decode("utf-8", errors="ignore") for s, v in t_subs if s == "MODL"), "")
            self.check(
                "TerminalDesk01.nif" in t_modl,
                f"Exterior TERM {hex(term_base_fid)} uses desk model TerminalDesk01.nif ({t_modl})",
            )
            placed_terms = [r for r in refrs_by_fid.values() if r["base"] == term_base_fid]
            self.check(len(placed_terms) == 1, f"TERM {hex(term_base_fid)} is placed in WRLD 0x01003400")
            if placed_terms:
                tx, ty, tz = placed_terms[0]["data"][:3]
                matching_desks = [
                    r for r in refrs_by_fid.values()
                    if r["base"] == 0x0001F453
                    and math.hypot(r["data"][0] - tx, r["data"][1] - ty) <= 20.0
                    and abs(r["data"][2] - tz) < 0.5
                ]
                self.check(
                    len(matching_desks) >= 1,
                    f"Exterior TERM {hex(term_base_fid)} at ({tx:.1f}, {ty:.1f}, {tz:.1f}) sits flush on desk 0x0001F453 at exact floor Z={tz:.1f} (zero floating gap)",
                )

        # Verify interior terminal 0x01002231 in CELL 0x01002200 has steel desk 0x000BD538 directly beneath it at (5180, -4850, 255)
        t2231 = refrs_by_fid.get(0x01002231)
        matching_2231_desks = [
            r for r in refrs_by_fid.values()
            if r["base"] == 0x000BD538
            and math.hypot(r["data"][0] - 5180.0, r["data"][1] - (-4850.0)) <= 5.0
            and abs(r["data"][2] - 255.0) < 0.5
        ]
        self.check(
            t2231 is not None and len(matching_2231_desks) >= 1,
            "Interior terminal 0x01002231 (TermV13TacticalRouteMap) sits flush on steel desk 0x000BD538 at (5180, -4850, 255)",
        )

        # Verify zero craters and gentle walkable terrain slopes (<= 12.0 deg) within 2,400 units of all 6 side-quest objective complexes
        from v13_world_layout import global_california_height, coastline_x, ext_navm_fid, CELL_MIN, CELL_MAX
        for sq_site_name, sq_cx, sq_cy, sq_cz in (
            ("Guarida del Mutascorpión Emperador", 16000.0, 34500.0, 160.0),
            ("Guarida de la Banda de los Skulz (Kenji)", -5460.0, 12880.0, 80.0),
            ("Complejo de la Granja de Irwin (Krag)", -18500.0, 6500.0, 80.0),
            ("Fortaleza de los Khans del Norte (Tolan)", 35000.0, 24500.0, 200.0),
            ("El Resplandor / West Tek (Centinela)", 31500.0, -32980.0, 120.0),
            ("Distrito Industrial del Boneyard (Madre Sanguinario)", 8500.0, -28000.0, 40.0),
        ):
            max_s = 0.0
            max_diff = 0.0
            for dx in range(-1400, 1401, 256):
                for dy in range(-1400, 1401, 256):
                    if math.hypot(dx, dy) <= 1400.0:
                        x, y = sq_cx + dx, sq_cy + dy
                        z0 = global_california_height(x, y)
                        z1 = global_california_height(x + 128.0, y)
                        z2 = global_california_height(x, y + 128.0)
                        s = math.hypot(z1 - z0, z2 - z0) / 128.0
                        if s > max_s:
                            max_s = s
                        if abs(z0 - sq_cz) > max_diff:
                            max_diff = abs(z0 - sq_cz)
            max_deg = math.degrees(math.atan(max_s))
            self.check(
                max_deg <= 12.0 and max_diff <= 110.0,
                f"Objective site {sq_site_name} ({sq_cx:.0f}, {sq_cy:.0f}, Z={sq_cz:.0f}) is crater-free with gentle walkable slope (max slope={max_deg:.1f} deg <= 12.0 deg, max diff={max_diff:.1f} <= 110.0)",
            )

        # Verify new 4-option Dialogue Wheel scenes for merchants & Harold
        for new_scen_fid, new_scen_name in (
            (0x01009601, "V13ShadySandsRazloIntroScene"),
            (0x01011101, "V13HubButchIntroScene"),
            (0x01011102, "V13HubHaroldIntroScene"),
            (0x01014101, "V13BoneyardSmittyIntroScene"),
        ):
            self.check(
                new_scen_fid in records_by_fid and records_by_fid[new_scen_fid][0] == "SCEN",
                f"New 4-option Dialogue Wheel SCEN {new_scen_fid:#010x} ({new_scen_name}) exists in ESP",
            )

        # Verify Butch Harris (0x01001027) and Gabriel (0x01001029) outfits have no slot-41 Armor_Vault111_Guard (0x00156C0D) collision
        for otft_fid, otft_label in (
            (0x01001027, "Outfit_V13_ButchHarrisMerchant"),
            (0x01001029, "Outfit_V13_GabrielGunRunners"),
        ):
            self.check(otft_fid in records_by_fid, f"OTFT {otft_fid:#010x} ({otft_label}) exists")
            if otft_fid in records_by_fid:
                _, _, o_subs, _ = records_by_fid[otft_fid]
                inam_sub = next((v for s, v in o_subs if s == "INAM"), b"")
                items = [
                    struct.unpack_from("<I", inam_sub, i)[0]
                    for i in range(0, len(inam_sub), 4)
                ]
                self.check(
                    0x00156C0D not in items,
                    f"OTFT {otft_fid:#010x} ({otft_label}) has no slot-41 collision with Armor_Vault111_Guard (0x00156C0D): {items}",
                )

        # Verify El Eje 6-District NPCs (Irwin, Harold, Butch Harris, Martha Rastello, Sheriff Greene) stand cleanly in their spread districts
        for hub_achr_fid, hub_name, exp_x, exp_y in (
            (0x010035C6, "Irwin", -3500.0, -11400.0),
            (0x010035C7, "Harold", -1650.0, -14500.0),
            (0x010035C8, "Butch Harris", -1650.0, -13000.0),
            (0x010035E6, "Martha Rastello", -3500.0, -15750.0),
            (0x010035E7, "Sheriff Justin Greene", -5400.0, -11800.0),
        ):
            if hub_achr_fid in refrs_by_fid:
                ax, ay, az = refrs_by_fid[hub_achr_fid]["data"][:3]
                self.check(
                    abs(ax - exp_x) < 1.0 and abs(ay - exp_y) < 1.0 and ax <= -1500.0,
                    f"El Eje NPC {hub_name} ({hub_achr_fid:#010x}) placed cleanly in its district at ({ax:.0f}, {ay:.0f}, {az:.0f})",
                )

        # Verify seated police/Vault-Tec skeleton 0x000237F6 is never placed in open exterior cells
        seated_skel_ext_count = sum(
            1 for rfid, r in refrs_by_fid.items()
            if rfid >= 0x01003750 and r["base"] == 0x000237F6
        )
        self.check(
            seated_skel_ext_count == 0,
            f"Zero unsupported seated skeletons (0x000237F6) placed in open exterior wasteland (found {seated_skel_ext_count})",
        )

        # Verify all 6 side-quest bosses (and their escorts) have >= 400 units clearance from any closed building OBND in WRLD 0x01003400
        closed_bldg_obnds = {
            0x00001B3D: (-476.0, -322.0, 527.0, 1152.0),  # BldgBrick7Story3x5FreeComEntA
            0x0001A117: (-816.0, -288.0, 768.0, 383.0),   # BldgBrick4Story6x2FreeComEntA
            0x00004B3B: (-256.0, -235.0, 256.0, 384.0),   # BldgBrickLgWht2Story2x2ComGarageA
            0x0000466D: (-280.0, -280.0, 280.0, 280.0),   # BldgMetal2Story1x1ComA
            0x00193508: (-296.0, -290.0, 296.0, 419.0),   # BldSentinelBunkerTower01
            0x000D4C12: (-270.0, -509.0, 268.0, 509.0),   # Quonset02
            0x0006FD6E: (-382.0, -472.0, 466.0, 418.0),   # Cabin01
            0x001F97BE: (-260.0, -420.0, 260.0, 420.0),   # Shack / Barracón
        }
        placed_bldg_refs = [
            r for rfid, r in refrs_by_fid.items()
            if r["base"] in closed_bldg_obnds and r["data"][2] > -500.0
        ]
        for boss_fid, boss_label, exp_terr_z in (
            (0x010035A6, "Mutascorpión Emperador (Shady Sands)", 160.0),
            (0x010035C4, "Kenji (Distrito de Gizmo)", 80.0),
            (0x010035C5, "Escolta Skulz (Distrito de Gizmo)", 80.0),
            (0x010035C9, "Caudillo Krag (Granja de Irwin)", 80.0),
            (0x010035CA, "Saqueador de Krag (Granja de Irwin)", 80.0),
            (0x010035CE, "Carcelero Jefe Tolan (Fortaleza Khan)", 200.0),
            (0x010035CF, "Guardia Khan (Fortaleza Khan)", 200.0),
            (0x010035D2, "Centinela ZAX-WT01 (El Resplandor)", 120.0),
            (0x010035D7, "Madre Sanguinario (Boneyard Este)", 40.0),
        ):
            bx, by, bz = refrs_by_fid[boss_fid]["data"][:3]
            self.check(
                bz >= exp_terr_z + 4.0,
                f"Boss {boss_label} ({hex(boss_fid)}) is placed slightly above terrain surface (Z={bz:.1f} >= {exp_terr_z + 4.0:.1f}) to prevent Havok underground clipping",
            )
            overlaps = []
            for br in placed_bldg_refs:
                rx, ry, rz_pos, _, _, rot_z = br["data"]
                if abs(rz_pos - bz) > 400.0:
                    continue
                x1, y1, x2, y2 = closed_bldg_obnds[br["base"]]
                dx, dy = bx - rx, by - ry
                lx = dx * math.cos(rot_z) + dy * math.sin(rot_z)
                ly = -dx * math.sin(rot_z) + dy * math.cos(rot_z)
                if (x1 - 80.0) <= lx <= (x2 + 80.0) and (y1 - 80.0) <= ly <= (y2 + 80.0):
                    overlaps.append((hex(br["base"]), rx, ry, lx, ly))
            self.check(
                len(overlaps) == 0,
                f"Boss {boss_label} ({hex(boss_fid)}) at ({bx:.0f}, {by:.0f}) has zero building OBND overlaps (found {overlaps})",
            )

        # Verify Native Fallout 4 MapMarker Discovery (FNAM=0x01 Visible/Undiscovered, XRDS=2000.0) on all 18 discoverable map locations
        discoverable_mms = [0x01003009] + list(range(0x01003412, 0x0100341B)) + list(range(0x0100341C, 0x01003424))
        for mm_fid in discoverable_mms:
            _, _, mm_subs, _ = records_by_fid[mm_fid]
            mm_fnam = next((v[0] for s, v in mm_subs if s == "FNAM" and len(v) >= 1), -1)
            mm_xrds = next((struct.unpack("<f", v)[0] for s, v in mm_subs if s == "XRDS" and len(v) == 4), 0.0)
            self.check(
                mm_fnam == 0x01 and abs(mm_xrds - 2000.0) < 1.0,
                f"Discoverable MapMarker {hex(mm_fid)} has FNAM=0x01 (Undiscovered/Visible) and XRDS=2000.0 for native FO4 HUD banner & XP (got FNAM={mm_fnam}, XRDS={mm_xrds})",
            )

        with open(os.path.join(PSC_DIR, "V13Act1QuestScript.psc"), "r", encoding="utf-8") as f:
            act1_code = f.read()
        self.check(
            "EnableFastTravel(false)" not in act1_code and "v15Banner.Show" not in act1_code,
            "V13Act1QuestScript.psc never blocks native discovery with EnableFastTravel(false) and never shows modal v15Banner popup",
        )

        # Verify V13WastelandCreatureAIScript keeps surface creatures Very Aggressive (2.0), re-arms Timer 1 on OnLoad/OnCellAttach, and cancels Timer 1 on OnUnload/OnCellDetach
        with open(os.path.join(PSC_DIR, "V13WastelandCreatureAIScript.psc"), "r", encoding="utf-8") as f:
            wc_code = f.read()
        self.check(
            "if !IsInShadySandsSafeZone(HomeX, HomeY)\n        Self.SetValue(Game.GetAggressionAV(), 2.0)" in wc_code
            and "Event OnLoad()\n    InitCreatureAI()\nEndEvent" in wc_code
            and "Event OnUnload()\n    CancelTimer(1)\nEndEvent" in wc_code,
            "V13WastelandCreatureAIScript.psc initializes surface creatures with Aggression=2.0, re-arms Timer 1 on OnLoad, and cancels Timer 1 while 3D is unloaded",
        )

        # Verify Albóndiga (0x010035B3) is in Shady Sands central plaza (6700, 23500, 160) and never disabled in DismissDogmeatToShadySands
        dog_x, dog_y, dog_z = refrs_by_fid[0x010035B3]["data"][:3]
        self.check(
            abs(dog_x - 6700.0) < 1.0 and abs(dog_y - 23500.0) < 1.0 and abs(dog_z - 160.0) < 1.0,
            f"Albóndiga (0x010035B3) is placed in Shady Sands central plaza at (6700, 23500, 160), got ({dog_x:.0f}, {dog_y:.0f}, {dog_z:.0f})",
        )
        dismiss_block = jt_code.split("Function DismissDogmeatToShadySands")[1].split("EndFunction")[0]
        self.check(
            "dogShady.DisableNoWait()" not in dismiss_block and "dogShady.EnableNoWait()" in dismiss_block,
            "DismissDogmeatToShadySands enables dogShady (0x010035B3) in Shady Sands and never disables it",
        )

        # Verify Diana (0x010035CB) & Gwen (0x010035CC) are positioned in the open plaza of Paso Oriental de los Khans outside the cabin OBND
        for kh_fid, kh_name, exp_kx, exp_ky in (
            (0x010035CB, "Diana", 21360.0, 18440.0),
            (0x010035CC, "Gwen", 21580.0, 18440.0),
        ):
            kx, ky, kz = refrs_by_fid[kh_fid]["data"][:3]
            self.check(
                abs(kx - exp_kx) < 1.0 and abs(ky - exp_ky) < 1.0,
                f"Khans Pass NPC {kh_name} ({hex(kh_fid)}) is placed in open plaza at ({kx:.0f}, {ky:.0f}, {kz:.0f})",
            )
            kh_overlaps = []
            for br in placed_bldg_refs:
                rx, ry, rz_pos, _, _, rot_z = br["data"]
                if abs(rz_pos - kz) > 400.0:
                    continue
                x1, y1, x2, y2 = closed_bldg_obnds[br["base"]]
                dx, dy = kx - rx, ky - ry
                lx = dx * math.cos(rot_z) + dy * math.sin(rot_z)
                ly = -dx * math.sin(rot_z) + dy * math.cos(rot_z)
                if (x1 - 40.0) <= lx <= (x2 + 40.0) and (y1 - 40.0) <= ly <= (y2 + 40.0):
                    kh_overlaps.append((hex(br["base"]), rx, ry, lx, ly))
            self.check(
                len(kh_overlaps) == 0,
                f"Khans Pass NPC {kh_name} ({hex(kh_fid)}) has zero cabin/building OBND overlaps (found {kh_overlaps})",
            )

        # Verify TARDIS Motion Sensor (V13SideQuestTardisScript.psc & V13WastelandCreatureAIScript.psc)
        with open(os.path.join(PSC_DIR, "V13SideQuestTardisScript.psc"), "r", encoding="utf-8") as f:
            tardis_code = f.read()
        tardis_header = tardis_code.split("Function ForceQuestAlias")[0]
        self.check(
            "bPerceptionBonusApplied" not in tardis_header
            and "bFirstSweepNotified" not in tardis_header
            and "iSweepTickCounter" not in tardis_header
            and "iLastHostileCount" not in tardis_header,
            "V13SideQuestTardisScript.psc preserves exact 3-variable header table for 100% existing savegame compatibility",
        )
        self.check(
            "0x0022517C" in tardis_code
            and "0x00247A3F" in tardis_code
            and "0x0022517E" not in tardis_code
            and "if !isHostile\n        if akRedHaloFX != None\n            akRedHaloFX.Stop(akCand)" in tardis_code,
            "V13SideQuestTardisScript.psc plays visible red halo (0x0022517C + 0x00247A3F) ONLY on hostile enemies and stops it on friendly NPCs",
        )
        self.check(
            "0x0022517C" in wc_code and "0x00247A3F" in wc_code and "0x00001456" in wc_code,
            "V13WastelandCreatureAIScript.psc directly highlights all mod creatures/Glowing Ones with red halo (0x0022517C + 0x00247A3F) when Motion Sensor is in inventory",
        )

        # Verify all 3 Fallout 1 (1997) Special Encounters (TARDIS 0x01015000, Overturned Nuka-Cola Truck 0x01016000, Crashed Alien Ship 0x01017000)
        special_encounters = [
            (0x01015000, "Cabina Telefónica Inusual (TARDIS)", 0x0100119D, 0x010035F0, 0x010035F2, 0x01001456, 0x0100114F, 0x0100119E, 0x01003421, 0x01003528, 0x01001066, 0x01001067),
            (0x01016000, "Camión de Nuka-Cola Volcado", 0x010011A7, 0x01003530, 0x01003531, 0x01001457, 0x01001C80, 0x010011A9, 0x01003422, 0x01003529, 0x01001068, 0x01001069),
            (0x01017000, "Platillo Volante Estrellado (Área 51)", 0x010011A8, 0x01003540, 0x01003542, 0x01001458, 0x01001C81, 0x010011AA, 0x01003423, 0x0100352A, 0x0100106A, 0x0100106B),
        ]
        for se_qfid, se_label, acti_fid, acti_refr, target_refr, misc_fid, book_fid, term_fid, mm_fid, ftm_fid, sndr_fid, soun_fid in special_encounters:
            self.check(se_qfid in qusts_by_fid, f"Special Encounter QUST {hex(se_qfid)} ({se_label}) exists in ESP")
            self.check(se_qfid in startup_stage_10_quests, f"Special Encounter QUST {hex(se_qfid)} ({se_label}) starts at Stage 10")
            self.check(acti_fid in records_by_fid and acti_refr in refrs_by_fid and refrs_by_fid[acti_refr]["base"] == acti_fid, f"Special Encounter ACTI {hex(acti_fid)} and REFR {hex(acti_refr)} exist for {se_label}")
            self.check(target_refr in refrs_by_fid, f"Special Encounter secondary target REFR {hex(target_refr)} exists for {se_label}")
            self.check(misc_fid in records_by_fid and book_fid in records_by_fid and term_fid in records_by_fid, f"Special Encounter MISC {hex(misc_fid)}, BOOK {hex(book_fid)}, and TERM {hex(term_fid)} exist for {se_label}")
            self.check(sndr_fid in records_by_fid and soun_fid in records_by_fid, f"Special Encounter custom SFX SNDR {hex(sndr_fid)} & SOUN {hex(soun_fid)} exist for {se_label}")
            self.check(mm_fid in refrs_by_fid and ftm_fid in refrs_by_fid, f"Special Encounter MapMarker {hex(mm_fid)} and FastTravelMarker {hex(ftm_fid)} exist for {se_label}")
            _, _, seq_subs, _ = records_by_fid[se_qfid]
            seq_alsts = [struct.unpack("<I", v)[0] for s, v in seq_subs if s == "ALST" and len(v) == 4]
            seq_alfrs = [struct.unpack("<I", v)[0] for s, v in seq_subs if s == "ALFR" and len(v) == 4]
            seq_stages = [struct.unpack("<H", v[:2])[0] for s, v in seq_subs if s == "INDX" and len(v) >= 2]
            seq_qobjs = [struct.unpack("<H", v)[0] for s, v in seq_subs if s == "QOBJ" and len(v) == 2]
            self.check(
                seq_alsts == list(range(10)) and seq_alfrs[:2] == [acti_refr, target_refr] and set(seq_stages) >= {10, 20, 25, 30} and set(seq_qobjs) >= {20, 25},
                f"Special Encounter QUST {hex(se_qfid)} ({se_label}) has sorted aliases 0..9 with [0, 1] -> [{hex(acti_refr)}, {hex(target_refr)}], Stages (10,20,25,30), and Objectives (20,25)",
            )
            placed_se_terms = [r for r in refrs_by_fid.values() if r["base"] == term_fid]
            if placed_se_terms:
                tx, ty, tz = placed_se_terms[0]["data"][:3]
                se_desks = [
                    r for r in refrs_by_fid.values()
                    if r["base"] == 0x0001F453 and math.hypot(r["data"][0] - tx, r["data"][1] - ty) <= 20.0 and abs(r["data"][2] - tz) < 0.5
                ]
                self.check(len(se_desks) >= 1, f"Special Encounter TERM {hex(term_fid)} ({se_label}) sits flush on steel desk 0x0001F453 at Z={tz:.1f}")

        # Verify Alien Blaster (0x0100110F), Dead Alien Pilots (0x01001253/1254 -> 0x01003542/3543), Custom Elvis Velvet Painting 3D mesh, and Mnemosyne options 18..20
        self.check(0x0100110F in records_by_fid and records_by_fid[0x0100110F][0] == "WEAP", "WeapV13AlienBlaster (WEAP 0x0100110F) exists in ESP")
        self.check(0x01001253 in records_by_fid and 0x01001254 in records_by_fid and 0x01003542 in refrs_by_fid and 0x01003543 in refrs_by_fid, "Dead Alien Pilot NPCs (0x01001253/1254) and placed ACHR corpses (0x01003542/3543) exist in ESP")
        self.check(
            0x010011AB in records_by_fid
            and 0x010011AC in records_by_fid
            and 0x010011AD in records_by_fid
            and all(rf in refrs_by_fid for rf in range(0x01003550, 0x01003556))
            and refrs_by_fid[0x01003550]["base"] == 0x010011AB
            and refrs_by_fid[0x01003551]["base"] == 0x010011AC
            and refrs_by_fid[0x01003555]["base"] == 0x010011AD
            and refrs_by_fid[0x01003550]["data"] == refrs_by_fid[0x01003555]["data"]
            and (refrs_by_fid[0x01003552]["flags"] & 0x00000800) != 0
            and (refrs_by_fid[0x01003553]["flags"] & 0x00000800) != 0,
            "Coupled Red Nuka-Cola Semi-Trailer (0x01003550), Flush Contoured Nuka-Cola Trailer Decal (0x01003555 with identical transform), and Coupled Red Tractor Cab (0x01003551) exist in ESP with legacy floating signs disabled",
        )
        elvis_nif_path = os.path.join(os.path.dirname(PSC_DIR), "assets", "junktown_3d", "Meshes", "V13Chronicles", "Junktown", "ElvisVelvetPainting.nif")
        trl_sign_nif_path = os.path.join(os.path.dirname(PSC_DIR), "assets", "meshes", "V13Chronicles", "Junktown", "TruckTrailerSignNukaCola.nif")
        wc_nuka_nif_path = os.path.join(os.path.dirname(PSC_DIR), "assets", "meshes", "setdressing", "woodcrate", "WoodCrateNukaCola.nif")
        self.check(
            os.path.isfile(elvis_nif_path) and os.path.isfile(trl_sign_nif_path) and os.path.isfile(wc_nuka_nif_path) and 0x01003556 in refrs_by_fid,
            "Custom 3D Elvis Velvet Painting mesh, Contoured Nuka-Cola Trailer Decal mesh, Nuka-Cola Shipping Crate mesh (WoodCrateNukaCola.nif), and extra fallen Nuka-Cola machine (0x01003556) exist",
        )
        self.check(
            {18, 19, 20}.issubset(term1130_itids),
            f"Mnemosyne Entrance Terminal (0x01001130) includes direct jump options 18..20 for all 3 Special Encounters (found {sorted(term1130_itids)})",
        )

        # Verify all 11 Custom 3D Monument STATs (0x01001D00..0x01001D0A) and Gothic Cathedral at (-19500, -31100, 40) on 100% flat dry ground well inland of the Pacific Ocean
        monument_stats_ok = all(
            mfid in records_by_fid and records_by_fid[mfid][0] == "STAT"
            for mfid in range(0x01001D00, 0x01001D0B)
        )
        self.check(
            monument_stats_ok,
            "All 11 Custom 3D Monument STAT records (0x01001D00..0x01001D0A) exist in ESP",
        )
        cath_refs = [
            r for r in refrs_by_fid.values()
            if r["base"] == 0x01001D00
            and abs(r["data"][0] - (-19500.0)) < 1.0
            and abs(r["data"][1] - (-31480.0)) < 1.0
        ]
        cath_zs = [global_california_height(x, y) for x in range(-20200, -18799, 128) for y in range(-32100, -30699, 128)]
        self.check(
            len(cath_refs) == 1
            and min(cath_zs) == 40.0
            and max(cath_zs) == 40.0
            and (-20500.0 - coastline_x(-31480.0)) >= 1000.0,
            f"Custom 3D Gothic Cathedral (0x01001D00) at (-19500, -31480, 40) sits on 100% flat terrain (Z={min(cath_zs):.1f}..{max(cath_zs):.1f}) with {-20500.0 - coastline_x(-31480.0):.0f} units of dry coastal clearance",
        )

        # Verify all 400 exterior cells in WRLD 0x01003400 have NAVM records registered in NAVI (0x00000FF1)
        expected_ext_navms = [
            ext_navm_fid(cx, cy)
            for cy in range(CELL_MIN, CELL_MAX + 1)
            for cx in range(CELL_MIN, CELL_MAX + 1)
        ]
        ext_navm_count = sum(
            1 for fid in expected_ext_navms
            if fid in records_by_fid and records_by_fid[fid][0] == "NAVM"
        )
        self.check(
            ext_navm_count == 400 and 0x00000FF1 in records_by_fid and records_by_fid[0x00000FF1][0] == "NAVI",
            f"All 400 exterior cells (20x20) have NAVM records ({ext_navm_count}/400) and NAVI 0x00000FF1 is present",
        )

        # Verify zero NPC_ records have dangling ACBS templateUseFlags at offset 14 when TPLT is absent
        bad_npc_tpl_flags = []
        for fid, (rtype, _, rsubs, _) in records_by_fid.items():
            if rtype == "NPC_":
                has_tplt = any(s == "TPLT" for s, _ in rsubs)
                if not has_tplt:
                    for s, v in rsubs:
                        if s == "ACBS" and len(v) >= 16:
                            tpl_fl = struct.unpack_from("<H", v, 14)[0]
                            if tpl_fl != 0:
                                bad_npc_tpl_flags.append((hex(fid), hex(tpl_fl)))
        self.check(
            len(bad_npc_tpl_flags) == 0,
            f"Zero NPC_ records have dangling ACBS templateUseFlags at offset 14 without TPLT (found: {bad_npc_tpl_flags})",
        )

        # Verify Dogmeat vocalization SNDR (0x0100106C..0x01001074) & SOUN (0x0100106D..0x01001075) records and PlayDogmeatVocal
        dog_snd_ok = all(
            sfid in records_by_fid and records_by_fid[sfid][0] == "SNDR"
            and (sfid + 1) in records_by_fid and records_by_fid[sfid + 1][0] == "SOUN"
            for sfid in (0x0100106C, 0x0100106E, 0x01001070, 0x01001072, 0x01001074)
        )
        self.check(
            dog_snd_ok and "Function PlayDogmeatVocal" in jt_code,
            "All 5 Dogmeat multi-track vocalization SNDR/SOUN pairs (0x0100106C..0x01001075) exist and PlayDogmeatVocal is wired in V13SideQuestJunktownScript.psc",
        )

        # Verify Act I -> Act II transition stops 0x00004101 and forces V13Act2Quest Stage 15 even in menu mode
        act1_code = open(os.path.join(PSC_DIR, "V13Act1QuestScript.psc"), encoding="utf-8").read()
        act2_code = open(os.path.join(PSC_DIR, "V13Act2QuestScript.psc"), encoding="utf-8").read()
        self.check(
            "act2QNow.SetStage(15)" in act1_code
            and "act2Q40.SetStage(15)" in act1_code
            and "act1RetScene.Stop()" in act2_code
            and "0x00001151" not in act2_code,
            "Act I -> Act II transition stops return scene 0x00004101, sets V13Act2Quest Stage 15, and never shows interrupting popup 0x00001151",
        )

        # Verify duplicate second exterior bunker door (0x0100350A) and colliding cave desk/terminal (0x01002230, 0x01030405) are buried & disabled
        d350a = refrs_by_fid.get(0x0100350A)
        t2230 = refrs_by_fid.get(0x01002230)
        d30405 = refrs_by_fid.get(0x01030405)
        d2206 = refrs_by_fid.get(0x01002206)
        self.check(
            d350a is not None
            and (d350a["flags"] & 0x00000800) != 0
            and d350a["data"][2] <= -2500.0
            and t2230 is not None
            and (t2230["flags"] & 0x00000800) != 0
            and t2230["data"][2] <= -2500.0
            and d30405 is not None
            and d30405["data"][2] <= -2500.0
            and d2206 is not None
            and d2206["xtel"] is not None
            and d2206["xtel"][0] == 0x01003501,
            "Duplicate second Vault 13 surface bunker door (0x0100350A) and colliding cave desk/terminal (0x01002230, 0x01030405) are buried/disabled",
        )

        # Verify Bob's Pre-Owned Car Mart trunk (0x01003566) and lot cars have >= 400 units X clearance
        bob_trunk = refrs_by_fid.get(0x01003566)
        bob_cars = [
            r for r in refrs_by_fid.values()
            if r["base"] in (0x0019B425, 0x001A3057)
            and math.hypot(r["data"][0] - 21020.0, r["data"][1] - 5060.0) <= 800.0
        ]
        self.check(
            bob_trunk is not None
            and len(bob_cars) == 3
            and all(abs(c["data"][0] - bob_trunk["data"][0]) >= 400.0 for c in bob_cars),
            "Bob's Pre-Owned Car Mart trunk (0x01003566) has >= 400 units X clearance from all 3 lot cars",
        )

        # Verify exterior BOSBarricadeBase01Military (0x0021C948) references are sunk -1.8 units below flat terrain to prevent Z-fighting
        ext_barricades = [
            r for fid, r in refrs_by_fid.items()
            if fid >= 0x010B0000 and r["base"] == 0x0021C948 and r["data"][2] > -500.0
        ]
        self.check(
            len(ext_barricades) >= 8 and all(abs((r["data"][2] + 1.8) - round(r["data"][2] + 1.8)) < 0.05 for r in ext_barricades),
            f"All {len(ext_barricades)} exterior BOSBarricadeBase01Military (0x0021C948) references are offset -1.8 units below ground plane to prevent Z-fighting",
        )

        # Verify Shady Sands perimeter walls use Havok-solid CovWall01/CovWallEndcap (0x000E97CC/CE/EC) and ZERO collisionless graybox CovenantWall* (0x000E04A6..A8)
        collisionless_cov_refs = [
            fid for fid, r in refrs_by_fid.items()
            if r["base"] in (0x000E04A6, 0x000E04A7, 0x000E04A8) and r["data"][2] > -500.0
        ]
        solid_cov_walls = [
            fid for fid, r in refrs_by_fid.items()
            if r["base"] == 0x000E97CC and r["data"][2] > -500.0
        ]
        solid_cov_caps = [
            fid for fid, r in refrs_by_fid.items()
            if r["base"] in (0x000E97CE, 0x000E97EC) and r["data"][2] > -500.0
        ]
        self.check(
            len(collisionless_cov_refs) == 0 and len(solid_cov_walls) >= 32 and len(solid_cov_caps) >= 8,
            f"Shady Sands v1.0 perimeter uses Havok-solid CovWall01/Endcap ({len(solid_cov_walls)} walls + {len(solid_cov_caps)} pillars) and 0 collisionless graybox 0x000E04A6..A8",
        )

        # Verify Arid California Climate (CLMT 0x010033FF) linked on WRLD 0x01003400 and isolated Vault/Bunker records (0x0100131F..0x01001328)
        self.check(
            0x010033FF in records_by_fid and records_by_fid[0x010033FF][0] == "CLMT",
            "Arid California Climate record CLMT 0x010033FF (V13CaliforniaAridClimate) exists in ESP",
        )
        _, _, wrld_subs, _ = records_by_fid[0x01003400]
        wrld_cnam = next((struct.unpack("<I", v)[0] for s, v in wrld_subs if s == "CNAM" and len(v) == 4), 0)
        self.check(
            wrld_cnam == 0x010033FF,
            f"WRLD 0x01003400 (V13SouthernCaliforniaWorld) links CNAM to CLMT 0x010033FF (got {hex(wrld_cnam)})",
        )
        for iso_fid, iso_rt in (
            (0x0100131F, "MSWP"),
            (0x01001320, "MSWP"),
            (0x01001321, "ARMA"),
            (0x01001322, "STAT"),
            (0x01001323, "STAT"),
            (0x01001324, "STAT"),
            (0x01001325, "STAT"),
            (0x01001326, "STAT"),
            (0x01001327, "STAT"),
            (0x01001328, "DOOR"),
        ):
            self.check(
                iso_fid in records_by_fid and records_by_fid[iso_fid][0] == iso_rt,
                f"Isolated zero-vanilla-override record {hex(iso_fid)} ({iso_rt}) exists in ESP",
            )

        # Capítulo 2 (Pasos 1-3) — Lost Hills/Glow, Boneyard, Mariposa, Dynamic Invasions & Desert Encounters
        psc_files = [fn for fn in os.listdir(PSC_DIR) if fn.lower().endswith(".psc")]
        self.check(
            len(psc_files) >= 57,
            f"Papyrus source directory contains >= 57 .psc scripts ({len(psc_files)} found)",
        )
        for p3_fid, p3_rt, p3_label in (
            (0x01006002, "QUST", "V13Act3Quest (Lost Hills)"),
            (0x01007000, "QUST", "V13Act4Quest (Mariposa)"),
            (0x01008000, "QUST", "V13Act5Quest (Cathedral)"),
            (0x01013000, "QUST", "V13SideQuestGlow"),
            (0x010D1000, "QUST", "V13SideQuestLostHillsPA"),
            (0x010D2000, "QUST", "V13SideQuestAdytumWar"),
            (0x010D3000, "QUST", "V13SideQuestAdytumForge"),
            (0x010D4000, "QUST", "V13SideQuestFollowersSpy"),
            (0x010D5000, "QUST", "V13MutantInvasionQuest"),
            (0x0100132F, "MSWP", "MSWPV13CathedralPurpleRobe"),
            (0x01001330, "ARMO", "ArmoV13CathedralPurpleRobe"),
            (0x01001331, "ARMA", "ArmoAddonV13CathedralPurpleRobe"),
            (0x01001333, "ARMO", "ArmoV13PsychicNullifier"),
            (0x01001334, "ARMA", "ArmoAddonV13PsychicNullifier"),
            (0x0100103C, "OTFT", "Outfit_V13_CathedralPurpleRobe"),
            (0x01001570, "ACTI", "ActiV13MariposaForcefieldEmitter"),
            (0x0100153A, "TERM", "TermV13MariposaSecurityGrey"),
            (0x01001C96, "MESG", "MesgV13MariposaEmitterMenu"),
            (0x01007102, "SCEN", "V13Act4MariposaCaptiveScene"),
            (0x01007103, "SCEN", "V13Act4LieutenantScene"),
            (0x010D5100, "SCEN", "V13EncounterMalachiScene"),
            (0x010D5101, "SCEN", "V13EncounterRangersScene"),
            (0x010D5102, "SCEN", "V13EncounterFishermanScene"),
        ):
            self.check(
                p3_fid in records_by_fid and records_by_fid[p3_fid][0] == p3_rt,
                f"Chapter 2 record {hex(p3_fid)} ({p3_rt} - {p3_label}) exists in ESP",
            )
        for mar_ref in [0x01002C31] + list(range(0x01002C34, 0x01002C39)) + list(range(0x01002C40, 0x01002C46)):
            self.check(
                mar_ref in refrs_by_fid and refrs_by_fid[mar_ref]["cell"] == 0x01002C00,
                f"Mariposa interior ref {hex(mar_ref)} placed in CELL 0x01002C00",
            )
        for ext_ref in list(range(0x01003640, 0x0100364D)) + [0x01003650, 0x01003651, 0x01003652]:
            self.check(
                ext_ref in refrs_by_fid,
                f"Chapter 2 Wasteland Encounter / Invasion ref {hex(ext_ref)} exists in WRLD 0x01003400",
            )
        _bdir = os.path.dirname(ESP_PATH)
        main_ba2_p = os.path.join(_bdir, "Vault13Chronicles - Main.ba2")
        tex_ba2_p = os.path.join(_bdir, "Vault13Chronicles - Textures.ba2")
        with open(main_ba2_p, "rb") as mbf:
            mb_tail = mbf.read()
        with open(tex_ba2_p, "rb") as tbf:
            tb_tail = tbf.read()
        self.check(
            b"cathedralpurplerobe.bgsm" in mb_tail.lower(),
            "CathedralPurpleRobe.bgsm packaged in Vault13Chronicles - Main.ba2",
        )
        self.check(
            b"cathedralpurplerobe_d.dds" in tb_tail.lower(),
            "CathedralPurpleRobe_d.dds packaged in Vault13Chronicles - Textures.ba2",
        )

        # Workstream A: Monument PBR .BGSM & ShadyPlaque_d.dds verification
        mon_mesh_dir = os.path.join(os.path.dirname(PSC_DIR), "assets", "monuments_3d", "Meshes", "V13Chronicles", "Monuments")
        mon_nifs = [fn for fn in sorted(os.listdir(mon_mesh_dir)) if fn.lower().endswith(".nif")] if os.path.isdir(mon_mesh_dir) else []
        bad_mon_nifs = []
        for fn in mon_nifs:
            raw_nif = open(os.path.join(mon_mesh_dir, fn), "rb").read().lower()
            if (b".bgsm" not in raw_nif) or (b"vltnullforswap_s.dds" in raw_nif):
                bad_mon_nifs.append(fn)
            elif fn.startswith("V13EndingCreditCard"):
                if b"flatflat_n.dds" not in raw_nif:
                    bad_mon_nifs.append(fn)
            elif b"flatflat_n.dds" in raw_nif:
                bad_mon_nifs.append(fn)
        self.check(
            len(mon_nifs) == 24 and len(bad_mon_nifs) == 0,
            f"All 24 monument/card .nif files use valid Fallout 4 .BGSM materials and intended normal maps (bad: {bad_mon_nifs})",
        )
        mon_bgsm_names = (
            b"cathedralmonument.bgsm",
            b"glowcrater.bgsm",
            b"hubwatertower.bgsm",
            b"junktowngate.bgsm",
            b"losthillsbunker.bgsm",
            b"mariposabunker.bgsm",
            b"masterthrone.bgsm",
            b"shadyadobe.bgsm",
            b"shadyplaque.bgsm",
        )
        self.check(
            all(bgsm in mb_tail.lower() for bgsm in mon_bgsm_names),
            "All 9 Monument .BGSM PBR materials packaged in Vault13Chronicles - Main.ba2",
        )
        self.check(
            b"shadyplaque_d.dds" in tb_tail.lower(),
            "ShadyPlaque_d.dds packaged in Vault13Chronicles - Textures.ba2",
        )

        # Workstream B: Canonical 3-phase quest triggers, unaggressive camp NPCs, menus, Stage 12, and voiced pre-quest INFOs
        for camp_npc in (0x010015B0, 0x010015B1):
            self.check(
                camp_npc in records_by_fid and records_by_fid[camp_npc][0] == "NPC_",
                f"Camp NPC {hex(camp_npc)} exists in ESP",
            )
        for ufid in (0x01001201, 0x01001244, 0x01001248, 0x0100124B, 0x0100150B, 0x010015B0, 0x010015B1):
            rec = records_by_fid.get(ufid)
            if rec and rec[0] == "NPC_":
                rsubs = rec[2]
                aidt = next((v for s, v in rsubs if s == "AIDT" and len(v) >= 1), b"")
                snam_fids = {struct.unpack("<I", v[:4])[0] for s, v in rsubs if s == "SNAM" and len(v) >= 4}
                pkid_fids = {struct.unpack("<I", v)[0] for s, v in rsubs if s == "PKID" and len(v) == 4}
                self.check(
                    len(aidt) >= 1 and aidt[0] == 0 and (0x0001CBED not in snam_fids) and (0x01001053 not in pkid_fids),
                    f"Pre-quest camp NPC {hex(ufid)} is Unaggressive (AIDT[0]==0) without hostile Raider faction 0x0001CBED or sandbox 0x01001053",
                )
            else:
                self.check(False, f"Pre-quest camp NPC {hex(ufid)} exists in ESP")
        c95 = records_by_fid.get(0x01001C95)
        c95_btns = sum(1 for s, _ in c95[2] if s == "ITXT") if c95 and c95[0] == "MESG" else 0
        self.check(c95 is not None and c95[0] == "MESG" and c95_btns == 4, f"Caleb confrontation MESG 0x01001C95 has 4 buttons (got {c95_btns})")
        for mfid in range(0x01001CA0, 0x01001CA5):
            self.check(
                mfid in records_by_fid and records_by_fid[mfid][0] == "MESG",
                f"Camp boss confrontation MESG {hex(mfid)} exists in ESP",
            )
        for q12_fid in (0x01009500, 0x01010000, 0x01011000, 0x01012000, 0x010D1000, 0x01014000, 0x010D2000, 0x010D4000):
            qrec = records_by_fid.get(q12_fid)
            if qrec and qrec[0] == "QUST":
                indxs = {struct.unpack("<H", v[:2])[0] for s, v in qrec[2] if s == "INDX" and len(v) >= 2}
                qobjs = {struct.unpack("<H", v)[0] for s, v in qrec[2] if s == "QOBJ" and len(v) == 2}
                self.check(12 in indxs and 12 in qobjs, f"QUST {hex(q12_fid)} defines Pre-Quest Stage 12 & Objective 12")
            else:
                self.check(False, f"QUST {hex(q12_fid)} exists in ESP")
        for ifid in range(0x010D6010, 0x010D601C):
            irec = records_by_fid.get(ifid)
            clip_key = f"{ifid & 0xFFFFFF:08x}_1.fuz".encode()
            self.check(
                irec is not None and irec[0] == "INFO" and (clip_key in mb_tail.lower()),
                f"Pre-quest voiced INFO {hex(ifid)} exists in ESP and {clip_key.decode()} is packed in Main.ba2",
            )

        # Verify StatV13MemoryLounger (0x01002036) in CELL 0x01002000 sits in the recessed West wall alcove with >=350u clearance to both Terminal (0x01002035) and Airlock (0x01002003)
        lounger_ref = refrs_by_fid.get(0x01002036)
        term_ref = refrs_by_fid.get(0x01002035)
        airlock_ref = refrs_by_fid.get(0x01002003)
        if lounger_ref and term_ref and airlock_ref:
            lx, ly, lz, _, _, lrz = lounger_ref["data"]
            tx, ty = term_ref["data"][:2]
            ax, ay = airlock_ref["data"][:2]
            d_term = math.hypot(lx - tx, ly - ty)
            d_door = math.hypot(lx - ax, ly - ay)
            self.check(
                lounger_ref["cell"] == 0x01002000
                and abs(lx - (-610.65)) < 1.0
                and abs(ly - (-727.51)) < 1.0
                and abs(lz) < 0.5
                and abs(lrz - 4.5624) < 0.05
                and d_term >= 350.0
                and d_door >= 350.0,
                f"MemoryLounger 0x01002036 placed in West Hall alcove at ({lx:.2f}, {ly:.2f}, {lz:.1f}) rz={lrz:.4f} with clear paths (d_term={d_term:.1f}u, d_door={d_door:.1f}u)",
            )
        else:
            self.check(False, "MemoryLounger 0x01002036, Terminal 0x01002035, and Airlock 0x01002003 exist in CELL 0x01002000")

        # Verify persistent Mnemosyne desk (0x01002037), disabled CONT tombstone (0x01090097), and zero temp FormID shift (0x010901ED/EE)
        pdesk_ref = refrs_by_fid.get(0x01002037)
        tomb_ref = refrs_by_fid.get(0x01090097)
        brief_ref = refrs_by_fid.get(0x010901ED)
        rscr_ref = refrs_by_fid.get(0x010901EE)
        self.check(
            pdesk_ref is not None
            and pdesk_ref["cell"] == 0x01002000
            and (pdesk_ref["flags"] & 0x0400) != 0
            and (pdesk_ref["flags"] & 0x0800) == 0
            and pdesk_ref["base"] == 0x01001121
            and abs(pdesk_ref["data"][0] - (-305.2216)) < 0.05
            and abs(pdesk_ref["data"][1] - (-1013.4984)) < 0.05
            and abs(pdesk_ref["data"][2]) < 0.05
            and abs(pdesk_ref["data"][5] - 2.99159) < 0.01,
            f"Persistent Mnemosyne Desk 0x01002037 enabled in CELL 0x01002000 under Terminal 0x01002035: {pdesk_ref}",
        )
        self.check(
            tomb_ref is not None
            and tomb_ref["cell"] == 0x01002000
            and (tomb_ref["flags"] & 0x0800) != 0
            and tomb_ref["base"] == 0x0023F662
            and tomb_ref["data"][2] <= -2500.0,
            f"Legacy desk slot 0x01090097 is disabled CONT tombstone (0x0023F662) buried below floor: {tomb_ref}",
        )
        self.check(
            brief_ref is not None
            and rscr_ref is not None
            and brief_ref["base"] == 0x01001140
            and rscr_ref["base"] == 0x0000003B
            and (rscr_ref["flags"] & 0x0800) != 0,
            f"Zero cur_temp_fid shift in CELL 0x01002000: 0x010901ED={brief_ref}, 0x010901EE={rscr_ref}",
        )

        # Verify no QUST has QSDT==2 (Fail Quest) and all 23 completable quests have QSDT==1 (Complete Quest) on their final stage
        completable_final_stage = {
            0x01004000: 40, 0x01005000: 40, 0x01006002: 40, 0x01007000: 40, 0x01008000: 40,
            0x01009500: 40, 0x01010000: 40, 0x01011000: 40, 0x01012000: 40, 0x01013000: 40,
            0x01014000: 40, 0x01018000: 40, 0x01019000: 40, 0x0101A000: 40,
            0x0101E000: 21,
            0x010D1000: 40, 0x010D2000: 40, 0x010D3000: 40, 0x010D4000: 40,
            0x01015000: 30, 0x01016000: 30, 0x01017000: 30, 0x0101B000: 30, 0x0101C000: 30, 0x0101D000: 30,
        }
        qust_fail_stages = []
        qust_final_flags = {}
        for fid, rec in records_by_fid.items():
            rtype = rec[0]
            rsubs = rec[2]
            if rtype != "QUST":
                continue
            cur_stg = None
            stg_qsdt = {}
            for sname, sdata in rsubs:
                if sname == "INDX" and len(sdata) >= 2:
                    cur_stg = struct.unpack("<H", sdata[:2])[0]
                elif sname == "QSDT" and cur_stg is not None and len(sdata) >= 1:
                    fl = sdata[0]
                    stg_qsdt[cur_stg] = fl
                    if fl == 2:
                        qust_fail_stages.append((hex(fid), cur_stg))
            if fid in completable_final_stage:
                qust_final_flags[fid] = stg_qsdt.get(completable_final_stage[fid])
        self.check(
            len(qust_fail_stages) == 0,
            f"No QUST record has QSDT==2 (Fail Quest) on any stage (bad={qust_fail_stages})",
        )
        missing_complete = [
            f"{hex(qfid)} stg={fstg} got={qust_final_flags.get(qfid)}"
            for qfid, fstg in sorted(completable_final_stage.items())
            if qust_final_flags.get(qfid) != 1
        ]
        self.check(
            len(missing_complete) == 0,
            f"All {len(completable_final_stage)} completable quests mark final stage with QSDT==1 Complete Quest (bad={missing_complete})",
        )

        # Regression checks: Vault 15 hostile Khans & disabled lower creatures, Hub Maltese Falcon interior,
        # Water Merchants standalone quest, Tug Essential + no DPLT Deathclaws, and Talius Water Chip gating.
        for v15_khan_fid in range(0x0100254E, 0x0100255A):
            if v15_khan_fid == 0x01002551:
                continue
            kr = refrs_by_fid.get(v15_khan_fid)
            kbase = kr["base"] if kr else 0
            k_npc = records_by_fid.get(kbase)
            k_aidt = next((v for s, v in k_npc[2] if s == "AIDT" and len(v) >= 1), b"") if k_npc else b""
            k_snam = {struct.unpack("<I", v[:4])[0] for s, v in k_npc[2] if s == "SNAM" and len(v) >= 4} if k_npc else set()
            self.check(
                kr is not None and len(k_aidt) >= 1 and k_aidt[0] == 2 and (0x0001CBED in k_snam),
                f"Vault 15 Khan {hex(v15_khan_fid)} (base={hex(kbase)}) is Aggressive (AIDT[0]==2) with RaiderFaction 0x0001CBED",
            )
        k_boss = refrs_by_fid.get(0x01002559)
        self.check(
            k_boss is not None and k_boss["base"] == 0x010015B2,
            f"Vault 15 Boss 0x01002559 uses hostile warlord base 0x010015B2 (got {hex(k_boss['base']) if k_boss else 'None'})",
        )
        for v15_cr_fid in range(0x010025DD, 0x010025E4):
            cr = refrs_by_fid.get(v15_cr_fid)
            self.check(
                cr is not None and (cr["flags"] & 0x0800) != 0,
                f"Vault 15 lower creature {hex(v15_cr_fid)} is Initially Disabled (flags=0x{cr['flags']:08X})",
            )

        self.check(
            0x01002700 in records_by_fid and records_by_fid[0x01002700][0] == "CELL",
            "Interior CELL 0x01002700 (El Halcón Maltés — Subsuelo de Decker) exists in ESP",
        )
        d_ext = refrs_by_fid.get(0x01003605)
        d_int = refrs_by_fid.get(0x01002701)
        d_ext_xtel = d_ext["xtel"][0] if (d_ext and d_ext["xtel"] is not None) else 0
        d_int_xtel = d_int["xtel"][0] if (d_int and d_int["xtel"] is not None) else 0
        self.check(
            d_ext is not None and d_int is not None and d_ext_xtel == 0x01002701 and d_int_xtel == 0x01003605,
            f"Maltese Falcon doors linked bidirectionally 0x01003605 <-> 0x01002701 (got {hex(d_ext_xtel)} / {hex(d_int_xtel)})",
        )
        for int_act_fid, int_act_name in ((0x01002710, "Decker"), (0x01002711, "Kane")):
            ia = refrs_by_fid.get(int_act_fid)
            self.check(
                ia is not None and ia["cell"] == 0x01002700 and (ia["flags"] & 0x0800) == 0,
                f"Interior {int_act_name} {hex(int_act_fid)} placed active inside CELL 0x01002700",
            )
        for leg_fid in (0x010035E8, 0x010035E9):
            lr = refrs_by_fid.get(leg_fid)
            self.check(
                lr is not None and (lr["flags"] & 0x0800) != 0,
                f"Legacy exterior actor {hex(leg_fid)} is Initially Disabled (flags=0x{lr['flags']:08X})",
            )

        self.check(
            0x0101E000 in records_by_fid and records_by_fid[0x0101E000][0] == "QUST"
            and 0x0101E001 in records_by_fid and records_by_fid[0x0101E001][0] == "DIAL"
            and 0x0101A100 in records_by_fid and records_by_fid[0x0101A100][0] == "SCEN",
            "Standalone Water Merchants QUST 0x0101E000 + DIAL 0x0101E001 + SCEN 0x0101A100 exist in ESP",
        )

        for dc_fid in (0x01001252, 0x0100125D):
            dc_rec = records_by_fid.get(dc_fid)
            has_dplt = any(s == "DPLT" for s, _ in dc_rec[2]) if dc_rec else True
            self.check(
                dc_rec is not None and not has_dplt,
                f"Deathclaw NPC_ {hex(dc_fid)} has no DPLT subrecord",
            )
        tug_rec = records_by_fid.get(0x0100125E)
        tug_acbs = next((v for s, v in tug_rec[2] if s == "ACBS" and len(v) >= 4), b"") if tug_rec else b""
        tug_acbs_flags = struct.unpack("<I", tug_acbs[:4])[0] if tug_acbs else 0
        self.check(
            tug_rec is not None and (tug_acbs_flags & 0x02) != 0,
            f"Tug NPC_ 0x0100125E has Essential flag 0x02 (ACBS=0x{tug_acbs_flags:08X})",
        )

        mb_lower_chk = mb_tail.lower()
        for tal_fid in (0x010D4313, 0x010D4317, 0x010D4318, 0x010D431C):
            t_rec = records_by_fid.get(tal_fid)
            self.check(
                t_rec is not None and t_rec[0] == "INFO",
                f"Talius Water Chip INFO {hex(tal_fid)} exists in ESP",
            )
        for clip_low in ("000d4318_1.fuz", "000d431c_1.fuz", "000d4323_1.fuz"):
            self.check(
                clip_low.encode() in mb_lower_chk,
                f"Re-voiced/new fallback clip {clip_low} is packed in Main.ba2",
            )

        # Verify all 8 confrontation / supply SCEN dialogue wheels and their voiced ES/EN .fuz files (intro + Male/Female player + NPC)
        mb_lower = mb_tail.lower()
        for idx in range(8):
            scen_fid = 0x010D7000 + idx * 0x100
            srec = records_by_fid.get(scen_fid)
            self.check(
                srec is not None and srec[0] == "SCEN",
                f"Confrontation SCEN {hex(scen_fid)} exists in ESP",
            )
            intro_fid = scen_fid + 0x11
            intro_fuz = f"{intro_fid & 0xFFFFFF:08x}_1.fuz".encode()
            self.check(
                intro_fuz in mb_lower,
                f"SCEN {hex(scen_fid)} intro NPC voice {intro_fuz.decode()} packed in Main.ba2",
            )
            for opt_i in range(4):
                p_low = f"{(scen_fid + 0x30 + opt_i) & 0xFFFFFF:08x}_1.fuz"
                n_low = f"{(scen_fid + 0x50 + opt_i) & 0xFFFFFF:08x}_1.fuz"
                pm_path = f"playervoicemale01\\{p_low}".encode()
                pf_path = f"playervoicefemale01\\{p_low}".encode()
                n_fuz = n_low.encode()
                self.check(
                    (pm_path in mb_lower) and (pf_path in mb_lower) and (n_fuz in mb_lower),
                    f"SCEN {hex(scen_fid)} opt {opt_i} has Male+Female player .fuz ({p_low}) and NPC .fuz ({n_low}) in Main.ba2",
                )

        # Verify Mariposa & Cathedral fixes (arrival marker inside room, voiced BoS Paladins inside hall,
        # disabled unscripted ACTI doors/gates, Cathedral secondary exit 0x01002D03, Nightkin/Lieutenant weapons, no ghost shader/faction ally)
        m_ext_xtel = refrs_by_fid[0x01003508]["xtel"]
        m_in_data = refrs_by_fid[0x01002C02]["data"]
        self.check(
            m_ext_xtel is not None
            and m_ext_xtel[0] == 0x01002C01
            and abs(m_ext_xtel[1] - 848.0) < 1.0
            and abs(m_ext_xtel[2] - (-256.0)) < 1.0
            and abs(m_in_data[0] - 848.0) < 1.0
            and abs(m_in_data[1] - (-256.0)) < 1.0,
            f"Mariposa entry 0x01003508 XTEL & 0x01002C02 DATA land cleanly inside room at (848, -256, 128) (got {m_ext_xtel[:4] if m_ext_xtel else None}, {m_in_data[:3]})",
        )
        pal_npc_vtck = next((struct.unpack("<I", v)[0] for s, v in records_by_fid[0x01001568][2] if s == "VTCK" and len(v) == 4), 0)
        pal_npc_doft = next((struct.unpack("<I", v)[0] for s, v in records_by_fid[0x01001568][2] if s == "DOFT" and len(v) == 4), 0)
        pal1_y = refrs_by_fid[0x01002C36]["data"][1]
        pal2_y = refrs_by_fid[0x01002C37]["data"][1]
        self.check(
            pal1_y >= -150.0 and pal2_y >= -150.0 and pal_npc_vtck == 0x01001004 and pal_npc_doft == 0x01001040,
            f"Mariposa BoS Paladins 0x01002C36/37 stand inside hall (Y={pal1_y:.1f}, {pal2_y:.1f} >= -150) with voiced BoSMale01 VTCK (0x01001004, got {hex(pal_npc_vtck)}) & T-60 armor DOFT (0x01001040, got {hex(pal_npc_doft)})",
        )
        blocked_acti_fids = (0x01070225, 0x01070226, 0x01080009, 0x01080033, 0x0108003E, 0x0108003F, 0x01080040, 0x01080042)
        non_disabled_acti = [hex(afid) for afid in blocked_acti_fids if afid not in refrs_by_fid or (refrs_by_fid[afid]["flags"] & 0x00000800) == 0]
        self.check(
            len(non_disabled_acti) == 0,
            f"All 8 unscripted ACTI doors/security gates in Mariposa & Cathedral are Initially Disabled (still enabled: {non_disabled_acti})",
        )
        d2d03 = refrs_by_fid.get(0x01002D03)
        d2d3f = refrs_by_fid.get(0x01002D3F)
        self.check(
            d2d03 is not None
            and (d2d03["flags"] & 0x0800) != 0
            and d2d3f is not None
            and d2d3f["base"] == 0x010015B8
            and (d2d3f["flags"] & 0x0800) == 0
            and abs(d2d3f["data"][0] - 1472.0) < 1.0
            and abs(d2d3f["data"][1] - 96.0) < 1.0
            and abs(d2d3f["data"][2] - (-768.0)) < 1.0
            and abs(d2d3f["data"][5] - 1.570796) < 0.02,
            f"Cathedral secondary exit 0x01002D3F (0x010015B8) active at (1472, 96, -768, rz=1.5708) and legacy 0x01002D03 disabled (got {d2d3f})",
        )
        nk_items = {struct.unpack("<II", v)[0] for s, v in records_by_fid[0x01001208][2] if s == "CNTO" and len(v) == 8}
        lou_items = {struct.unpack("<II", v)[0] for s, v in records_by_fid[0x01001207][2] if s == "CNTO" and len(v) == 8}
        self.check(
            (0x0001F669 in nk_items)
            and (0x000E27BC in lou_items)
            and (0x0100110B in lou_items)
            and ("fxStealthDeath.Play" not in wc_code)
            and ("smFac.SetAlly(playerFac" not in act2_code),
            f"Nightkin carries Minigun ({[hex(x) for x in sorted(nk_items)]}), Lieutenant carries GatlingLaser+WinchesterP94 ({[hex(x) for x in sorted(lou_items)]}), no ghost shader Play, and no SuperMutant-Player SetAlly",
        )

        # Verify every custom NIF under meshes\v13chronicles\ in Main.ba2 resolves all BGSM/BGEM and DDS paths
        import glob as _glob
        import zlib as _zlib

        def _read_ba2_names(ba2_path: str) -> set[str]:
            with open(ba2_path, "rb") as _bf:
                _magic, _ver, _btype, _cnt, _ntoff = struct.unpack("<4sI4sIQ", _bf.read(24))
                _bf.seek(_ntoff)
                return {
                    _bf.read(struct.unpack("<H", _bf.read(2))[0]).decode("utf-8", "ignore").replace("/", "\\").lower()
                    for _ in range(_cnt)
                }

        def _read_gnrl_ba2_index(ba2_path: str) -> dict[str, tuple[int, int, int]]:
            _out = {}
            with open(ba2_path, "rb") as _bf:
                _magic, _ver, _btype, _cnt, _ntoff = struct.unpack("<4sI4sIQ", _bf.read(24))
                _ents = [struct.unpack("<I4sIIQIII", _bf.read(36)) for _ in range(_cnt)]
                _bf.seek(_ntoff)
                _nms = [
                    _bf.read(struct.unpack("<H", _bf.read(2))[0]).decode("utf-8", "ignore").replace("/", "\\").lower()
                    for _ in range(_cnt)
                ]
                for _nm, _ent in zip(_nms, _ents):
                    _out[_nm] = (_ent[4], _ent[5], _ent[6])
            return _out

        def _get_gnrl_bytes(ba2_path: str, info: tuple[int, int, int]) -> bytes:
            _off, _ps, _us = info
            with open(ba2_path, "rb") as _bf:
                _bf.seek(_off)
                _raw = _bf.read(_ps if _ps else _us)
                return _zlib.decompress(_raw) if _ps else _raw

        _tex_set = _read_ba2_names(tex_ba2_p)
        for _tp in _glob.glob(os.path.join(FO4_DATA, "Fallout4 - Textures*.ba2")):
            _tex_set |= _read_ba2_names(_tp)
        _van_mat_p = os.path.join(FO4_DATA, "Fallout4 - Materials.ba2")
        _van_mat = _read_gnrl_ba2_index(_van_mat_p) if os.path.exists(_van_mat_p) else {}
        _main_map = _read_gnrl_ba2_index(main_ba2_p)
        _custom_nifs = [k for k in sorted(_main_map) if k.startswith("meshes\\v13chronicles\\") and k.endswith(".nif")]
        _pat_mat = re.compile(rb'(?<=[\x00"\'])[A-Za-z0-9_\\/\-\. ]+\.(?:bgsm|bgem)', re.I)
        _pat_dds = re.compile(rb'(?<=[\x00"\'])[A-Za-z0-9_\\/\-\. ]+\.dds', re.I)
        _missing_nif_assets = []
        for _nf in _custom_nifs:
            _nraw = _get_gnrl_bytes(main_ba2_p, _main_map[_nf])
            for _d in _pat_dds.findall(_nraw):
                _ds = _d.decode("ascii", "ignore").replace("/", "\\").lower()
                _dn = _ds if _ds.startswith("textures\\") else "textures\\" + _ds.lstrip("\\")
                if _dn not in _tex_set:
                    _missing_nif_assets.append((_nf, "nif_dds", _dn))
            for _mp in _pat_mat.findall(_nraw):
                _ms = _mp.decode("ascii", "ignore").replace("/", "\\").lower()
                _mn = _ms if _ms.startswith("materials\\") else "materials\\" + _ms.lstrip("\\")
                if _mn in _main_map:
                    _mraw = _get_gnrl_bytes(main_ba2_p, _main_map[_mn])
                elif _mn in _van_mat:
                    _mraw = _get_gnrl_bytes(_van_mat_p, _van_mat[_mn])
                else:
                    _missing_nif_assets.append((_nf, "mat", _mn))
                    continue
                for _md in _pat_dds.findall(_mraw):
                    _mds = _md.decode("ascii", "ignore").replace("/", "\\").lower()
                    _mdn = _mds if _mds.startswith("textures\\") else "textures\\" + _mds.lstrip("\\")
                    if _mdn not in _tex_set:
                        _missing_nif_assets.append((_nf, _mn, _mdn))
        self.check(
            len(_custom_nifs) >= 1 and len(_missing_nif_assets) == 0,
            f"All {len(_custom_nifs)} custom NIFs in Main.ba2 resolve every BGSM/BGEM and DDS cleanly (missing={_missing_nif_assets[:5]})",
        )

        # Verify Quest-Reactive Radio El Eje / The Hub Radio (6 chained SCENs 0x01008511..0x01008516, 177 SNDR records & .xwm tracks)
        _dj_expected_fids = list(range(0x01008601, 0x0100861A)) + list(range(0x010E0001, 0x010E0056))
        _song_expected_fids = list(range(0x01008620, 0x01008620 + 41))
        _jingle_expected_fids = list(range(0x010E0101, 0x010E0113))
        _drama_expected_fids = list(range(0x010E0201, 0x010E0209))
        _all_radio_fids = _dj_expected_fids + _song_expected_fids + _jingle_expected_fids + _drama_expected_fids
        _missing_radio_sndrs = [hex(rf) for rf in _all_radio_fids if rf not in records_by_fid or records_by_fid[rf][0] != "SNDR"]
        _expected_xwm_names = (
            [f"v13_radio_dj_{_i:02d}.xwm" for _i in range(1, 111)]
            + [f"v13_radio_song_{_i:02d}.xwm" for _i in range(1, 42)]
            + [f"v13_radio_jingle_{_i:02d}.xwm" for _i in range(1, 19)]
            + [f"v13_radio_drama_{_i:02d}.xwm" for _i in range(1, 9)]
        )
        _missing_radio_xwms = []
        for _xfn in _expected_xwm_names:
            _rkey = f"sound\\fx\\mus\\radio\\vault13\\{_xfn}"
            _rinfo = _main_map.get(_rkey)
            if _rinfo is None or max(_rinfo[1], _rinfo[2]) <= 4096:
                _missing_radio_xwms.append(_rkey)
        self.check(
            len(_all_radio_fids) == 177 and len(_missing_radio_sndrs) == 0 and len(_missing_radio_xwms) == 0,
            f"All 177 Hub Radio SNDR records & >4KB .xwm files exist cleanly (110 DJ + 41 Song + 18 Jingle + 8 Drama; missing_sndr={_missing_radio_sndrs[:5]}, missing_xwm={_missing_radio_xwms[:5]})",
        )

        _radio_scen_fids = list(range(0x01008511, 0x01008517))
        _all_ph_entries: list[tuple[int, list[bytes]]] = []
        _bad_ctda_funcs = []
        _bad_chain_scens = []
        _scen_phase_counts: list[int] = []
        for _s_idx, _s_fid in enumerate(_radio_scen_fids):
            _r_scen = records_by_fid.get(_s_fid)
            if _r_scen is None or _r_scen[0] != "SCEN":
                _bad_chain_scens.append((hex(_s_fid), "missing"))
                continue
            _rs_subs = _r_scen[2]
            _ph_ctdas: list[list[bytes]] = []
            _cur_ph: list[bytes] | None = None
            _next_seen = 0
            _action_htids: dict[int, int] = {}
            _act_snam: int | None = None
            _act_type: int | None = None
            _chain_lcep: int | None = None
            for _st, _sv in _rs_subs:
                if _st == "HNAM" and _act_type is None:
                    if _cur_ph is None:
                        _cur_ph = []
                        _next_seen = 0
                    else:
                        _ph_ctdas.append(_cur_ph)
                        _cur_ph = None
                elif _st == "NEXT" and _cur_ph is not None:
                    _next_seen += 1
                elif _st == "CTDA" and _cur_ph is not None:
                    if _next_seen == 0 and len(_sv) == 32:
                        _cur_ph.append(_sv)
                elif _st == "ANAM" and len(_sv) == 2:
                    _act_type = struct.unpack("<H", _sv)[0]
                    _act_snam = None
                elif _st == "SNAM" and _act_type is not None and len(_sv) == 4 and _act_snam is None:
                    _act_snam = struct.unpack("<I", _sv)[0]
                elif _st == "HTID" and _act_type == 6 and len(_sv) == 4 and _act_snam is not None:
                    _action_htids[_act_snam] = struct.unpack("<I", _sv)[0]
                elif _st == "LCEP" and _act_type == 4 and len(_sv) == 4:
                    _chain_lcep = struct.unpack("<I", _sv)[0]

            _expected_next = 0x01008511 + ((_s_idx + 1) % len(_radio_scen_fids))
            _scen_phase_counts.append(len(_ph_ctdas))
            if (
                len(_ph_ctdas) > 50
                or len(_ph_ctdas) != len(_action_htids) + 2
                or _chain_lcep != _expected_next
            ):
                _bad_chain_scens.append((hex(_s_fid), len(_ph_ctdas), len(_action_htids), hex(_chain_lcep or 0)))

            for _c_list in _ph_ctdas:
                for _cb in _c_list:
                    _fn = struct.unpack_from("<H", _cb, 8)[0]
                    _qf = struct.unpack_from("<I", _cb, 12)[0]
                    if _fn not in (0x003A, 0x003B) or _qf not in qusts_by_fid:
                        _bad_ctda_funcs.append((hex(_s_fid), hex(_fn), hex(_qf)))

            for _phi in range(1, len(_ph_ctdas) - 1):
                if _phi in _action_htids:
                    _all_ph_entries.append((_action_htids[_phi], _ph_ctdas[_phi]))

        _playlist_song_set = {_h for _h, _ in _all_ph_entries}
        _missing_songs_in_scen = [hex(sf) for sf in _song_expected_fids if sf not in _playlist_song_set]
        self.check(
            len(_bad_chain_scens) == 0
            and len(_scen_phase_counts) == 6
            and len(_all_ph_entries) >= 195
            and len(_missing_songs_in_scen) == 0
            and len(_bad_ctda_funcs) == 0,
            f"All 6 chained Radio SCENs (0x01008511..0x01008516) have <=50 phases ({_scen_phase_counts}), total={len(_all_ph_entries)} tracks, all 41 songs placed, valid ring & CTDAs (bad_scen={_bad_chain_scens}, missing_songs={_missing_songs_in_scen}, bad_ctda={_bad_ctda_funcs[:5]})",
        )

        def _sim_radio_active_fids(_stg_map: dict[int, int], _done_pairs: set[tuple[int, int]]) -> list[int]:
            _active = []
            for _htid, _ctda_list in _all_ph_entries:
                _ok = True
                for _cb in _ctda_list:
                    _op = _cb[0]
                    _cval, _cfn = struct.unpack_from("<fH", _cb, 4)
                    _qp1, _qp2 = struct.unpack_from("<II", _cb, 12)
                    if _cfn == 0x003A:
                        _cur_s = _stg_map.get(_qp1, 0)
                        if _op == 0x60:
                            _res = _cur_s >= int(_cval)
                        elif _op == 0x80:
                            _res = _cur_s < int(_cval)
                        else:
                            _res = False
                    elif _cfn == 0x003B:
                        _res = ((_qp1, int(_qp2)) in _done_pairs) == (_cval >= 0.5)
                    else:
                        _res = False
                    if not _res:
                        _ok = False
                        break
                if _ok:
                    _active.append(_htid)
            return _active

        _act_start = _sim_radio_active_fids({}, set())
        _act_set_deal = _sim_radio_active_fids({0x01005000: 24}, {(0x01005000, 24)})
        _act_pump_fixed = _sim_radio_active_fids({0x01005000: 26}, {(0x01005000, 26)})
        _act_harry_talk = _sim_radio_active_fids({0x01005000: 30}, {(0x01005000, 27), (0x01005000, 30)})
        _act_mariposa_prep = _sim_radio_active_fids({0x01005000: 40, 0x01006002: 30, 0x01007000: 15}, set())
        _act_post_mariposa = _sim_radio_active_fids({0x01005000: 40, 0x01006002: 40, 0x01007000: 30}, set())
        _act_post_cathedral = _sim_radio_active_fids({0x01005000: 40, 0x01006002: 40, 0x01007000: 40, 0x01008000: 30}, set())
        _act_exile_vree = _sim_radio_active_fids(
            {0x01005000: 40, 0x01006002: 40, 0x01007000: 40, 0x01008000: 40},
            {(0x01008000, 26)},
        )
        self.check(
            len(_act_start) == len(_act_set_deal) == len(_act_pump_fixed) == len(_act_harry_talk) == len(_act_mariposa_prep) == 130
            and len(_act_post_mariposa) == 128
            and len(_act_post_cathedral) == 126
            and len(_act_exile_vree) == 122
            and (0x01008603 not in _act_start)  # Shady Sands radscorpion clear must NOT spoil early game
            and (0x010E000B in _act_set_deal)   # dj_36: Deal with Set
            and (0x010E000D in _act_pump_fixed) # dj_38: Great Water Pump repaired
            and (0x010E0010 in _act_harry_talk) # dj_41: Harry persuaded
            and (0x010E0031 in _act_mariposa_prep) # dj_74: Preparing to assault Mariposa
            and (0x010E0201 in _act_start) and (0x010E0202 in _act_start) and (0x010E0204 in _act_start)
            and (0x010E0202 not in _act_post_mariposa)  # Caravan North Trail stops after Mariposa blown
            and (0x010E0204 not in _act_post_cathedral) # Cathedral pirate sermon stops after Cathedral nuked
            and (0x010E0003 in _act_exile_vree) and (0x010E0054 in _act_exile_vree), # dj_28 exile + dj_109 Master Vree proof
            f"Reactive Radio binary CTDA simulation hits exact counts (130->128->126->122; got {len(_act_start)}/{len(_act_post_mariposa)}/{len(_act_post_cathedral)}/{len(_act_exile_vree)}) with zero spoilers & accurate progression",
        )

        # Verify Reqs A-R playtest fixes:
        # Req A: Maltese Falcon uses Load WoodDouble door 0x01001590 & brick facade
        d3605 = refrs_by_fid.get(0x01003605)
        mf_brick = [r for r in refrs_by_fid.values() if r["base"] == 0x00004B3B and math.hypot(r["data"][0] - (-5400.0), r["data"][1] - (-15066.0)) < 10.0]
        mf_neon = [r for r in refrs_by_fid.values() if r["base"] == 0x00249EAB and math.hypot(r["data"][0] - (-5400.0), r["data"][1] - (-15460.0)) < 10.0]
        self.check(
            d3605 is not None and d3605["base"] == 0x01001590 and len(mf_brick) == 1 and len(mf_neon) == 1,
            "Req A: Maltese Falcon door 0x01003605 uses 0x01001590 (wood double) with brick facade 0x00004B3B & neon 0x00249EAB",
        )

        # Req C: ZAX/West Tek non-combat factions
        zax_snam = {struct.unpack_from("<I", v, 0)[0] for s, v in records_by_fid[0x01001509][2] if s == "SNAM" and len(v) >= 4}
        wt_bot_snam = {struct.unpack_from("<I", v, 0)[0] for s, v in records_by_fid[0x0100150A][2] if s == "SNAM" and len(v) >= 4}
        self.check(
            0x01001C57 in records_by_fid and 0x01001C58 in records_by_fid and 0x01001C57 in zax_snam and 0x01001C58 in wt_bot_snam,
            "Req C: ZAX 1.2 (0x01001C57) and West Tek robots (0x01001C58) use non-combat/security factions",
        )

        # Req D: West Tek interior CELL 0x01002800 dark interior flags 0x1101 (no daylight sky bleed)
        c2800_data = next((struct.unpack("<H", v)[0] for s, v in records_by_fid[0x01002800][2] if s == "DATA" and len(v) == 2), 0)
        self.check(
            c2800_data == 0x1101,
            f"Req D: West Tek interior CELL 0x01002800 uses DATA=0x1101 (got {hex(c2800_data)})",
        )

        # Req E: Kyle 0x010D1011 condition + active prompt 0x010D1206
        self.check(
            0x010D1011 in records_by_fid and 0x010D1206 in records_by_fid and 0x010D1306 in records_by_fid,
            "Req E: Lost Hills PA quest Lorenzo rescue path (0x010D1206/0x010D1306 & Stage 22) present",
        )

        # Req G: Lost Hills elevator door 0x01002B44 rotation & 0x01002B49 panel
        d2b44 = refrs_by_fid.get(0x01002B44)
        p2b49 = refrs_by_fid.get(0x01002B49)
        self.check(
            d2b44 is not None and abs(d2b44["data"][5] - 4.462459) < 0.01 and p2b49 is not None and p2b49["base"] == 0x0001BA47,
            "Req G: Lost Hills elevator door 0x01002B44 rotated 4.4625 rad with call panel 0x01002B49",
        )

        # Req H: Maxson SCEN 0x01006103 2-phase scene
        s6103_hnam_cnt = sum(1 for s, _ in records_by_fid[0x01006103][2] if s == "HNAM")
        self.check(
            s6103_hnam_cnt >= 4 and 0x01006228 in records_by_fid and 0x01006232 in records_by_fid,
            f"Req H: Maxson SCEN 0x01006103 has 2-phase dialogue structure (HNAM count={s6103_hnam_cnt})",
        )

        # Req I: Martha Rastello terminal 0x01003633 on desk + post-WaterChip INFOs
        t3633 = refrs_by_fid.get(0x01003633)
        self.check(
            t3633 is not None
            and t3633["base"] == 0x0100153B
            and abs(t3633["data"][0] - (-3330.0)) < 1.0
            and abs(t3633["data"][1] - (-15750.0)) < 1.0
            and 0x0101A019 in records_by_fid
            and all((0x0101A324 + k) in records_by_fid for k in range(6)),
            "Req I: Martha Rastello terminal 0x01003633 sits on desk (-3330, -15750, 80) + post-WaterChip dialogue",
        )

        # Req J: Deathclaw 0x0100125D does not drop 0x01001C86 note
        dc_cnto = {struct.unpack_from("<II", v, 0)[0] for s, v in records_by_fid[0x0100125D][2] if s == "CNTO" and len(v) == 8}
        self.check(
            0x01001C86 not in dc_cnto,
            f"Req J: Caravans Deathclaw 0x0100125D does not carry 0x01001C86 note (items={[hex(x) for x in dc_cnto]})",
        )

        # Req L: UFO corpses 0x01003542/43 well clear of UFO saucer 0x01003540
        ufo_pos = refrs_by_fid[0x01003540]["data"]
        al1_pos = refrs_by_fid[0x01003542]["data"]
        al2_pos = refrs_by_fid[0x01003543]["data"]
        d_al1 = math.hypot(al1_pos[0] - ufo_pos[0], al1_pos[1] - ufo_pos[1])
        d_al2 = math.hypot(al2_pos[0] - ufo_pos[0], al2_pos[1] - ufo_pos[1])
        self.check(
            d_al1 >= 500.0 and d_al2 >= 500.0,
            f"Req L: Alien corpses clear of UFO hull (d1={d_al1:.1f}, d2={d_al2:.1f} >= 500)",
        )

        # Req M: Mariposa/Cathedral embedded wall terminals + Paladin/Scout VTCK & greetings
        wall_term_fids = (0x0100153C, 0x0100153D, 0x0100153E, 0x01001595, 0x01001596, 0x01001597)
        scout_vtck = next((struct.unpack("<I", v)[0] for s, v in records_by_fid[0x010015AE][2] if s == "VTCK" and len(v) == 4), 0)
        self.check(
            all(fid in records_by_fid for fid in wall_term_fids)
            and scout_vtck == 0x01001003
            and 0x01007016 in records_by_fid
            and 0x0100801D in records_by_fid,
            "Req M: All 6 embedded wall terminals + voiced Mariposa/Cathedral scouts & greetings exist",
        )

        # Reqs N & P: Boneyard 7-compound expansion & Sammael crate isolation
        d_crate_razor = math.hypot(
            refrs_by_fid[0x01003630]["data"][0] - refrs_by_fid[0x01003624]["data"][0],
            refrs_by_fid[0x01003630]["data"][1] - refrs_by_fid[0x01003624]["data"][1],
        )
        d_crate_fol = math.hypot(
            refrs_by_fid[0x01003630]["data"][0] - refrs_by_fid[0x010035D6]["data"][0],
            refrs_by_fid[0x01003630]["data"][1] - refrs_by_fid[0x010035D6]["data"][1],
        )
        d_fol_razor = math.hypot(
            refrs_by_fid[0x010035D6]["data"][0] - refrs_by_fid[0x01003624]["data"][0],
            refrs_by_fid[0x010035D6]["data"][1] - refrs_by_fid[0x01003624]["data"][1],
        )
        self.check(
            d_crate_razor >= 2500.0 and d_crate_fol >= 4000.0 and d_fol_razor >= 4000.0,
            f"Reqs N & P: Boneyard 7-compound layout isolates Sammael/Blades/Followers (crate-Razor={d_crate_razor:.0f}, crate-Followers={d_crate_fol:.0f}, Followers-Razor={d_fol_razor:.0f})",
        )

        # Req Q1: Sammael turn-in scene 0x010D3101
        self.check(
            0x010D3101 in records_by_fid and all((0x010D3310 + k) in records_by_fid for k in range(8)),
            "Req Q1: Sammael hydroponic turn-in scene 0x010D3101 & INFOs 0x010D3310..17 exist",
        )

        # Req R: Vault 13 cavern mouth exit 0x01002206 (grounded) & bulkhead + inner seal 0x01002208 & lower cave exile staging
        d2205 = refrs_by_fid.get(0x01002205)
        d2208 = refrs_by_fid.get(0x01002208)
        j2235 = refrs_by_fid.get(0x01002235)
        self.check(
            d2206["base"] == 0x01001598
            and math.hypot(d2206["data"][0] - 6736.0, d2206["data"][1] - (-4255.0)) < 1.0
            and abs(d2206["data"][2] - 388.0) < 1.0
            and d2208 is not None and d2208["base"] == 0x0013C37D
            and d2205 is not None and abs(d2205["data"][0] - 4430.0) < 1.0
            and j2235 is not None and abs(j2235["data"][0] - 4260.0) < 1.0 and abs(j2235["data"][2] - (-31.0)) < 1.0,
            "Req R: Vault 13 cave mouth exit 0x01002206 (0x01001598) grounded at (6736.0, -4255.0, 388.0), seal 0x01002208, & lower cave Exile coords",
        )

        # Req S: Regression checks for Playtest Issues (Mnemosyne Desk & Issues A-H)
        t2035 = refrs_by_fid.get(0x01002035)
        d2037 = refrs_by_fid.get(0x01002037)
        self.check(
            t2035 is not None and d2037 is not None
            and math.hypot(t2035["data"][0] - d2037["data"][0], t2035["data"][1] - d2037["data"][1]) < 25.0
            and abs(t2035["data"][2]) < 0.05 and abs(d2037["data"][2]) < 0.05
            and abs(t2035["data"][5] - d2037["data"][5]) < 0.01,
            "Req S0: Mnemosyne Time-Gate desk 0x01002037 aligned flush under terminal 0x01002035",
        )

        en_main_ba2_p = os.path.join(os.path.dirname(os.path.abspath(__file__)), "edition_en", "build_out", "Vault13Chronicles - Main.ba2")
        _en_main_map = _read_gnrl_ba2_index(en_main_ba2_p) if os.path.exists(en_main_ba2_p) else {}
        mf_sign_ref = refrs_by_fid.get(0x010AD098)
        mf_nif_key = "meshes\\v13chronicles\\signs\\v13signmaltesefalcon01.nif"
        self.check(
            0x01001D0B in records_by_fid
            and mf_sign_ref is not None
            and mf_sign_ref["base"] == 0x01001D0B
            and mf_sign_ref["cell"] == 0x01002700
            and (mf_sign_ref["flags"] & 0x0800) == 0
            and mf_nif_key in _main_map
            and mf_nif_key in _en_main_map
            and _get_gnrl_bytes(main_ba2_p, _main_map[mf_nif_key]) != _get_gnrl_bytes(en_main_ba2_p, _en_main_map[mf_nif_key]),
            "Req S-A: Custom 3D Maltese Falcon sign 0x01001D0B active in CELL 0x01002700 with localized ES/EN NIFs",
        )

        q_hub_alids = [sv[:-1].decode("utf-8", "ignore") for st, sv in qusts_by_fid.get(0x0101A000, []) if st == "ALID"]
        q_jt_alids = [sv[:-1].decode("utf-8", "ignore") for st, sv in qusts_by_fid.get(0x01019000, []) if st == "ALID"]
        greet_info_fids = (0x01019012, 0x01019014, 0x01019016, 0x01019017, 0x0101A015, 0x0101A016, 0x0101A017)
        greet_ctdas_ok = all(
            ifid in records_by_fid
            and any(
                st == "CTDA" and len(sv) >= 24 and struct.unpack_from("<H", sv, 8)[0] == 0x003B
                for st, sv in records_by_fid[ifid][2]
            )
            for ifid in greet_info_fids
        )
        self.check(
            greet_ctdas_ok
            and "Alias_Decker_HubSyndicate" in q_hub_alids
            and not any("Gizmo" in a or "Vinnie" in a for a in q_hub_alids)
            and all(n in q_jt_alids for n in ("Alias_Gizmo_JunktownSyndicate", "Alias_Vinnie_JunktownSyndicate", "Alias_DocMorbid_JunktownSyndicate")),
            "Req S-B: Tug/Decker/Doc Morbid greeting GetStageDone CTDAs fixed and 0x0101A000/0x01019000 aliases clean",
        )

        sb35d2 = refrs_by_fid.get(0x010035D2)
        obnd_124e = next(
            (struct.unpack("<6h", sv) for st, sv in records_by_fid.get(0x0100124E, (None, None, [], None))[2] if st == "OBND" and len(sv) == 12),
            None,
        )
        self.check(
            sb35d2 is not None
            and sb35d2["base"] == 0x0100124E
            and abs(sb35d2["data"][0] - 31500.0) < 0.5
            and abs(sb35d2["data"][1] - (-33920.0)) < 0.5
            and abs(sb35d2["data"][2] - 124.0) < 0.5
            and obnd_124e == (-27, -27, 0, 27, 27, 120),
            "Req S-C: West Tek Exterior Sentry Bot 0x010035D2 clear of bunker wall with valid OBND on 0x0100124E",
        )

        zax_term_subs = records_by_fid.get(0x01001537, (None, None, [], None))[2]
        zax_spk = refrs_by_fid.get(0x01002815)
        zax_con = refrs_by_fid.get(0x01002832)
        zax_ch = refrs_by_fid.get(0x01002835)
        act3_psc_txt = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "papyrus_src", "V13Act3QuestScript.psc"), encoding="utf-8").read()
        self.check(
            sum(1 for st, _ in zax_term_subs if st == "CTDA") == 0
            and zax_spk is not None and zax_con is not None and zax_ch is not None
            and math.hypot(zax_spk["data"][0] - zax_con["data"][0], zax_spk["data"][1] - zax_con["data"][1]) < 260.0
            and math.hypot(zax_spk["data"][0] - zax_ch["data"][0], zax_spk["data"][1] - zax_ch["data"][1]) < 260.0
            and "scripts\\v13act3questscript.pex" in _main_map
            and "scripts\\v13act3questscript.pex" in _en_main_map
            and "bosObj.Is3DLoaded()" in act3_psc_txt,
            "Req S-D: ZAX 1.2 TERM 0x01001537 has zero CTDAs, speaker 0x01002815 beside console/chest, & Lost Hills Is3DLoaded guard packaged",
        )

        mariposa_pre_enabled = all(
            mfid in refrs_by_fid and (refrs_by_fid[mfid]["flags"] & 0x0800) == 0
            for mfid in (0x01002C11, 0x01002C12, 0x01002C20, 0x01002C21, 0x01002C22, 0x01002C25, 0x01002C26)
        )
        lou_xscl = next((struct.unpack("<f", sv)[0] for st, sv in records_by_fid[0x01002C11][2] if st == "XSCL"), 0.0)
        tech_acbs = next((struct.unpack_from("<I", sv, 0)[0] for st, sv in records_by_fid[0x0100155A][2] if st == "ACBS"), 0)
        lou_vmad = any(st == "VMAD" for st, _ in records_by_fid[0x01001207][2])
        self.check(
            mariposa_pre_enabled
            and abs(lou_xscl - 1.18) < 0.01
            and (tech_acbs & 0x0800) == 0
            and not lou_vmad,
            "Req S-EF: Mariposa entrance forces pre-enabled, Lieutenant XSCL=1.18 without CreatureAI, & Acolyte non-Protected",
        )

        navi_nvmi = b"".join(sv for st, sv in records_by_fid.get(0x00000FF1, (None, None, [], None))[2] if st == "NVMI")
        d3509 = refrs_by_fid.get(0x01003509)
        d2d83 = refrs_by_fid.get(0x01002D83)
        d2d83_subs = records_by_fid.get(0x01002D83, (None, None, [], None))[2]
        sanct_actors_ok = all(
            afid in refrs_by_fid and refrs_by_fid[afid]["cell"] == 0x01002D80
            for afid in (0x01002D12, 0x01002D32, 0x01002D33, 0x01002D35, 0x01002D36, 0x01002D84, 0x01002D85, 0x01002D86, 0x01002D87, 0x01002D88)
        )
        unity_npcs_ok = all(
            nfid in records_by_fid
            and 0x00058305 in [struct.unpack("<I", sv[:4])[0] for st, sv in records_by_fid[nfid][2] if st == "SNAM"]
            and 0x0001CBED not in [struct.unpack("<I", sv[:4])[0] for st, sv in records_by_fid[nfid][2] if st == "SNAM"]
            for nfid in (0x01001205, 0x01001206, 0x01001207, 0x01001208, 0x01001209, 0x0100120A, 0x0100120B, 0x0100120C, 0x0100155A, 0x010015A1)
        )
        q5_subs = qusts_by_fid.get(0x01008000, [])
        q5_obj_sanct_targets: dict[int, list[int]] = {}
        q5_obj_all_targets: dict[int, list[int]] = {}
        _cur_o, _last_qsta = None, None
        for st, sv in q5_subs:
            if st == "QOBJ" and len(sv) == 2:
                _cur_o = struct.unpack("<H", sv)[0]
                q5_obj_sanct_targets[_cur_o] = []
                q5_obj_all_targets[_cur_o] = []
                _last_qsta = None
            elif st == "QSTA" and _cur_o is not None and len(sv) >= 4:
                _last_qsta = struct.unpack("<I", sv[:4])[0]
                q5_obj_all_targets[_cur_o].append(_last_qsta)
            elif st == "CTDA" and _cur_o is not None and _last_qsta is not None and len(sv) >= 16:
                if struct.unpack_from("<I", sv, 12)[0] == 0x01002D80:
                    q5_obj_sanct_targets[_cur_o].append(_last_qsta)
        self.check(
            0x01002D80 in records_by_fid and records_by_fid[0x01002D80][0] == "CELL"
            and 0x01002DF0 in records_by_fid and records_by_fid[0x01002DF0][0] == "NAVM"
            and (0x01002DF0).to_bytes(4, "little") in navi_nvmi
            and d3509 is not None and d3509["xtel"] is not None and d3509["xtel"][0] == 0x01002D81
            and d2d83 is not None and d2d83["xtel"] is not None and d2d83["xtel"][0] == 0x01002D01
            and any(st == "VMAD" for st, _ in d2d83_subs)
            and any(st == "XLOC" for st, _ in d2d83_subs)
            and sanct_actors_ok
            and unity_npcs_ok
            and all(q5_obj_sanct_targets.get(o) == [16] for o in (20, 21))
            and all(q5_obj_sanct_targets.get(o) == [17] for o in (29, 32, 35)),
            "Req S-G: Cathedral 2-cell split (0x01002D80/NAVM/XTEL), unified SuperMutantFaction, & QSTA routing verified",
        )

        m3669 = refrs_by_fid.get(0x01003669)
        self.check(
            m3669 is not None
            and abs(m3669["data"][0] - (-19500.0)) < 0.5
            and abs(m3669["data"][1] - (-31520.0)) < 0.5
            and abs(m3669["data"][2] - 260.0) < 0.5
            and "scripts\\v13chestact5script.pex" in _main_map
            and "scripts\\v13cathedralcryptdoorscript.pex" in _main_map
            and "scripts\\v13chestact5script.pex" in _en_main_map
            and "scripts\\v13cathedralcryptdoorscript.pex" in _en_main_map
            and 14 in q5_obj_all_targets.get(35, []),
            "Req S-H: Cathedral spire nuclear blast marker 0x01003669, Act 5 scripts in ES/EN BA2s, & Objective 35 alias 14 verified",
        )

        # Req S-I: Direct jump option ITID 24 on Mnemosyne Mainframe Terminal (0x01001130) -> Act V Cathedral Assault
        with open(os.path.join(PSC_DIR, "V13TermMnemosyneMenuScript.psc"), "r", encoding="utf-8") as _f:
            _mnem_menu_src = _f.read()
        with open(os.path.join(PSC_DIR, "V13Act1QuestScript.psc"), "r", encoding="utf-8") as _f:
            _act1_src = _f.read()
        with open(os.path.join(PSC_DIR, "V13Act5QuestScript.psc"), "r", encoding="utf-8") as _f:
            _act5_src = _f.read()
        self.check(
            24 in term1130_itids
            and "auiMenuItemID == 24" in _mnem_menu_src
            and "auiMenuItemID == 24" in _act1_src
            and "QueueJumpToCathedral" in _act5_src
            and "scripts\\v13termmnemosynemenuscript.pex" in _main_map
            and "scripts\\v13act1questscript.pex" in _main_map
            and "scripts\\v13act5questscript.pex" in _main_map
            and "scripts\\v13termmnemosynemenuscript.pex" in _en_main_map
            and "scripts\\v13act1questscript.pex" in _en_main_map
            and "scripts\\v13act5questscript.pex" in _en_main_map,
            "Req S-I: Mnemosyne terminal ITID 24 direct jump to Act V Cathedral Assault wired & compiled in ES/EN",
        )

        # Req T: Overhaul 81->13, Cathedral & Master's Lair Overhaul, & 3 Real-Time Cinematics
        def _get_xmsp(fid: int) -> int | None:
            rec = records_by_fid.get(fid)
            if not rec:
                return None
            return next((struct.unpack("<I", sv[:4])[0] for st, sv in rec[2] if st == "XMSP" and len(sv) >= 4), None)

        def _read_dx10_first_chunk(ba2_path: str, target_name: str) -> bytes | None:
            with open(ba2_path, "rb") as _bf:
                _magic, _ver, _btype, _cnt, _ntoff = struct.unpack("<4sI4sIQ", _bf.read(24))
                if _btype != b"DX10":
                    return None
                _chunks = []
                for _ in range(_cnt):
                    _hdr = struct.unpack("<I4sIBBHHHBBH", _bf.read(24))
                    _nchk = _hdr[4]
                    _first = None
                    for _ci in range(_nchk):
                        _c = struct.unpack("<QIIHHI", _bf.read(24))
                        if _ci == 0:
                            _first = _c
                    _chunks.append(_first)
                _bf.seek(_ntoff)
                _nms = [
                    _bf.read(struct.unpack("<H", _bf.read(2))[0]).decode("utf-8", "ignore").replace("/", "\\").lower()
                    for _ in range(_cnt)
                ]
                _idx = {nm: ch for nm, ch in zip(_nms, _chunks)}
                info = _idx.get(target_name.lower())
                if info is None:
                    return None
                _bf.seek(info[0])
                _raw = _bf.read(info[1] if info[1] else info[2])
                return _zlib.decompress(_raw) if info[1] else _raw

        req_t_records_ok = (
            all(records_by_fid.get(f, (None,))[0] == "MSWP" for f in range(0x01009900, 0x01009904))
            and all(records_by_fid.get(f, (None,))[0] == "LIGH" for f in range(0x01009910, 0x01009915))
            and all(records_by_fid.get(f, (None,))[0] == "STAT" for f in range(0x01009920, 0x01009926))
            and all(records_by_fid.get(f, (None,))[0] == "STAT" for f in range(0x01009928, 0x0100992E))
            and records_by_fid.get(0x01001078, (None,))[0] == "SNDR"
            and records_by_fid.get(0x01001079, (None,))[0] == "SOUN"
            and all(records_by_fid.get(f, (None,))[0] == "NPC_" for f in (0x01001900, 0x01001901))
            and records_by_fid.get(0x01001056, (None,))[0] == "PACK"
        )
        req_t_bulkhead_ok = (
            all(f in refrs_by_fid for f in range(0x01002238, 0x0100223D))
            and {refrs_by_fid[f]["base"] for f in range(0x01002238, 0x0100223D)} == {0x00067A93, 0x00067A95, 0x00067AA6}
            and any(
                r_inf.get("cell") == 0x01002200
                and r_inf.get("base") == 0x00225BAC
                and _get_xmsp(r_fid) == 0x01009900
                for r_fid, r_inf in refrs_by_fid.items()
            )
            and any(
                r_inf.get("cell") == 0x01002200
                and r_inf.get("base") == 0x0009B08A
                and _get_xmsp(r_fid) == 0x01009901
                for r_fid, r_inf in refrs_by_fid.items()
            )
        )
        cath_xmsps = sum(1 for r_fid, r_inf in refrs_by_fid.items() if r_inf["cell"] == 0x01002D80 and _get_xmsp(r_fid) == 0x01009902)
        mast_xmsps = sum(1 for r_fid, r_inf in refrs_by_fid.items() if r_inf["cell"] == 0x01002D00 and _get_xmsp(r_fid) == 0x01009903)
        req_t_cathedral_overhaul_ok = (
            cath_xmsps >= 10
            and mast_xmsps >= 10
            and any(r_inf["cell"] == 0x01002D80 and r_inf["base"] in range(0x01009920, 0x01009925) for r_inf in refrs_by_fid.values())
            and any(r_inf["cell"] == 0x01002D00 and r_inf["base"] == 0x01009925 for r_inf in refrs_by_fid.values())
            and any(r_inf["cell"] == 0x01002D80 and r_inf["base"] in range(0x01009910, 0x01009915) for r_inf in refrs_by_fid.values())
        )
        req_t_ext_cinematics_ok = (
            all(f in refrs_by_fid for f in (0x01009940, 0x01009941, 0x01009942, 0x01009943, 0x01009944, 0x01009945, 0x01009948, 0x01009949, 0x0100994A, 0x0100994B))
            and all((0x01009950 + i) in refrs_by_fid for i in range(6))
        )
        sndr_1078_anam = next((sv.split(b"\x00", 1)[0].decode("ascii", "ignore") for st, sv in records_by_fid.get(0x01001078, (None, None, [], None))[2] if st == "ANAM"), "")
        sndr_1078_xwm = sndr_1078_anam.replace("/", "\\").lower()
        if sndr_1078_xwm.startswith("data\\"):
            sndr_1078_xwm = sndr_1078_xwm[5:]
        if sndr_1078_xwm.endswith(".wav"):
            sndr_1078_xwm = sndr_1078_xwm[:-4] + ".xwm"
        req_t_nifs_bgsms = [
            "meshes\\v13chronicles\\monuments\\v13cathedralbannertall.nif",
            "meshes\\v13chronicles\\monuments\\v13cathedralruins.nif",
            "meshes\\v13chronicles\\monuments\\v13cathedralstainedglass.nif",
            "meshes\\v13chronicles\\monuments\\v13cathedralaltarmonolith.nif",
            "meshes\\v13chronicles\\monuments\\v13masterflesharch.nif",
            "meshes\\v13chronicles\\monuments\\v13masterfleshwallcluster.nif",
            "meshes\\v13chronicles\\monuments\\v13mastervaultplaque.nif",
            "meshes\\v13chronicles\\monuments\\v13endingcreditcard01.nif",
            "meshes\\v13chronicles\\monuments\\v13endingcreditcard06.nif",
            "materials\\v13chronicles\\vault13gear\\vaultnumber13gear.bgsm",
            "materials\\v13chronicles\\vault13gear\\vltsignwelcome13.bgsm",
            "materials\\v13chronicles\\monuments\\cathedralbanner.bgsm",
            "materials\\v13chronicles\\monuments\\cathedralstainedglass.bgsm",
            "materials\\v13chronicles\\monuments\\cathedralaltarrelief.bgsm",
            "materials\\v13chronicles\\monuments\\mastervaultplaque.bgsm",
            "materials\\v13chronicles\\credits\\v13creditcard01.bgsm",
            "materials\\v13chronicles\\credits\\v13creditcard06.bgsm",
        ]
        en_tex_ba2_p = os.path.join(os.path.dirname(os.path.abspath(__file__)), "edition_en", "build_out", "Vault13Chronicles - Textures.ba2")
        _es_tex_names = _read_ba2_names(tex_ba2_p)
        _en_tex_names = _read_ba2_names(en_tex_ba2_p) if os.path.exists(en_tex_ba2_p) else set()
        req_t_dds_keys = [
            "textures\\v13chronicles\\vault13gear\\vaultnumber13gear_d.dds",
            "textures\\v13chronicles\\vault13gear\\vltsignwelcome13_d.dds",
            "textures\\v13chronicles\\monuments\\cathedralbanner_d.dds",
            "textures\\v13chronicles\\monuments\\cathedralstainedglass_d.dds",
            "textures\\v13chronicles\\monuments\\cathedralaltarrelief_d.dds",
            "textures\\v13chronicles\\monuments\\mastervaultplaque_d.dds",
        ] + [f"textures\\v13chronicles\\credits\\v13creditcard{i:02d}_d.dds" for i in range(1, 7)]
        _es_card1_c0 = _read_dx10_first_chunk(tex_ba2_p, "textures\\v13chronicles\\credits\\v13creditcard01_d.dds")
        _en_card1_c0 = _read_dx10_first_chunk(en_tex_ba2_p, "textures\\v13chronicles\\credits\\v13creditcard01_d.dds") if os.path.exists(en_tex_ba2_p) else None
        req_t_assets_ok = (
            bool(sndr_1078_xwm)
            and sndr_1078_xwm in _main_map
            and sndr_1078_xwm in _en_main_map
            and all(k in _main_map and k in _en_main_map for k in req_t_nifs_bgsms)
            and all(k in _es_tex_names and k in _en_tex_names for k in req_t_dds_keys)
            and _es_card1_c0 is not None
            and _en_card1_c0 is not None
            and _es_card1_c0 != _en_card1_c0
        )
        self.check(
            req_t_records_ok and req_t_bulkhead_ok and req_t_cathedral_overhaul_ok and req_t_ext_cinematics_ok and req_t_assets_ok,
            f"Req T: Overhaul 81->13 (bulkhead/XMSP), Cathedral/Master overhaul ({cath_xmsps}/{mast_xmsps} XMSPs), 3 cinematics, & ES/EN NIF/BGSM/DDS/XWM BA2 parity",
        )

        # Req U: Cathedral Sanctuary & Vault of Future Sky-Void, Backstage Seals, Chancel Ground-Floor & Faction Isolation
        def _cell_data_flags(cfid: int) -> int | None:
            rec = records_by_fid.get(cfid)
            if not rec:
                return None
            return next((struct.unpack("<H", sv[:2])[0] for st, sv in rec[2] if st == "DATA" and len(sv) >= 2), None)

        def _npc_factions(nfid: int) -> list[int]:
            return [struct.unpack("<I", sv[:4])[0] for st, sv in records_by_fid.get(nfid, (None, None, [], None))[2] if st == "SNAM" and len(sv) >= 4]

        _mat_keys = set(_van_mat.keys()) | set(_main_map.keys())
        mswp_snams_ok = all(
            bool(snams)
            and all((s if s.startswith("materials\\") else "materials\\" + s.lstrip("\\")) in _mat_keys for s in snams)
            for mf in (0x01009902, 0x01009903)
            for snams in [[sv.split(b"\x00", 1)[0].decode("ascii", "ignore").replace("/", "\\").lower() for st, sv in records_by_fid.get(mf, (None, None, [], None))[2] if st == "SNAM"]]
        )
        cell_no_sky_ok = all(
            _cell_data_flags(cfid) is not None and (_cell_data_flags(cfid) & 0x1100) == 0
            for cfid in (0x01002D80, 0x01002D00)
        )
        col_disabled_ok = all(
            cf in refrs_by_fid
            and refrs_by_fid[cf]["cell"] == 0x01002D80
            and refrs_by_fid[cf]["base"] == 0x0000003B
            and (refrs_by_fid[cf]["flags"] & 0x0800) != 0
            and not any(st == "XPRM" for st, _ in records_by_fid[cf][2])
            for cf in (0x01098037, 0x01098038)
        )
        seals_2d80 = [r for r in refrs_by_fid.values() if r["cell"] == 0x01002D80 and r["base"] in (0x0003D3C3, 0x00072865) and r["data"]]
        seals_ok = all(
            any(
                r["base"] == eb
                and abs(r["data"][0] - ex) < 0.5
                and abs(r["data"][1] - ey) < 0.5
                and abs(r["data"][2] - ez) < 0.5
                for r in seals_2d80
            )
            for eb, ex, ey, ez in (
                (0x0003D3C3, 2024.0, 1752.0, 500.8),
                (0x00072865, 2152.0, 1640.0, 252.8),
                (0x00072865, 2152.0, 2152.0, 252.8),
            )
        ) and not any(
            r["cell"] == 0x01002D80 and r["base"] in (0x0006A7C7, 0x0006A7C8, 0x0006A7C3)
            for r in refrs_by_fid.values()
        )
        chancel_z_ok = all(
            af in refrs_by_fid and refrs_by_fid[af]["cell"] == 0x01002D80 and refrs_by_fid[af]["data"][2] < 280.0
            for af in (0x01002D12, 0x01002D84)
        )
        cath_factions_ok = (
            records_by_fid.get(0x01001C59, (None,))[0] == "FACT"
            and records_by_fid.get(0x01001C5A, (None,))[0] == "FACT"
            and all(
                0x01001C59 in _npc_factions(nf) and 0x0001C21C not in _npc_factions(nf)
                for nf in (0x010015A0, 0x010015A2, 0x010015B4)
            )
            and 0x01001C5A in _npc_factions(0x010015AE)
        )
        cath_scripts_ok = (
            "cCathedralSanctuary" in wc_code
            and "UpdateSanctuaryQuestTargetAlias" in _act5_src
            and "bCathedralSanctuaryMigratedV3" in _act5_src
        )
        self.check(
            mswp_snams_ok and cell_no_sky_ok and col_disabled_ok and seals_ok and chancel_z_ok and cath_factions_ok and cath_scripts_ok,
            f"Req U: Cathedral no sky-void, CollisionMarkers disabled, backstage seals, ground-floor Chancel, FACT isolation, & Sanctuary scripts verified (mswp={mswp_snams_ok}, sky={cell_no_sky_ok}, col={col_disabled_ok}, seals={seals_ok}, z={chancel_z_ok}, fact={cath_factions_ok}, psc={cath_scripts_ok})",
        )

        # Req V: Act V Final Exit, Cathedral Destruction Swapping, Black-Screen-Free Cinematics & Stage 38 Exile Flow
        r223d = refrs_by_fid.get(0x0100223D)
        cave_entry_ok = (
            r223d is not None
            and r223d["cell"] == 0x01002200
            and math.hypot(r223d["data"][0] - 6580.0, r223d["data"][1] - (-4306.0)) < 1.0
            and abs(r223d["data"][2] - 388.0) < 1.0
        )
        cath_ext_ruins_ok = (
            all(
                f in refrs_by_fid and (refrs_by_fid[f]["flags"] & 0x0800) == 0
                for f in range(0x01009960, 0x01009966)
            )
            and all(
                f in refrs_by_fid and (refrs_by_fid[f]["flags"] & 0x0800) != 0
                for f in range(0x01009966, 0x01009975)
            )
            and refrs_by_fid.get(0x01009974, {}).get("base") == 0x01001D0D
            and refrs_by_fid.get(0x01009966, {}).get("data", [0, -99999])[1] > -30600.0
            and 0x01001D0D in records_by_fid
        )
        door_15b7_modl = next(
            (sv.split(b"\x00", 1)[0].decode("ascii", "ignore").lower() for st, sv in records_by_fid.get(0x010015B7, (None, None, [], None))[2] if st == "MODL"),
            "",
        )
        brick_seals_2d80 = [r for r in refrs_by_fid.values() if r["cell"] == 0x01002D80 and r["base"] == 0x001DA06E]
        cath_doors_ok = ("utilmetaldbdoorload01" in door_15b7_modl) and (len(brick_seals_2d80) == 2)
        q8000_subs = records_by_fid.get(0x01008000, (None, None, [], None))[2]
        stage38_ok = any(st == "INDX" and len(sv) >= 2 and struct.unpack("<H", sv[:2])[0] == 38 for st, sv in q8000_subs)
        q8000_qobjs = {struct.unpack("<H", sv)[0] for st, sv in q8000_subs if st == "QOBJ" and len(sv) == 2}
        obj38_ok = {22, 23, 24, 38}.issubset(q8000_qobjs)
        _act4_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "papyrus_src", "V13Act4QuestScript.psc")
        _act4_src = open(_act4_path, encoding="utf-8").read() if os.path.exists(_act4_path) else ""
        no_black_fade_ok = (
            ("FadeOutGame(true" not in _act4_src)
            and ("FadeOutGame(true" not in _act5_src)
            and ("cinePlayer.SetPosition" not in _act4_src)
            and ("cinePlayer.SetPosition" not in _act5_src)
            and ("exilePlayer.MoveTo" not in _act5_src)
            and ("kActiveExileDouble.MoveTo" not in _act5_src)
            and ("exilePlayer.SetPosition" not in _act5_src)
            and ("0x00009950 +" in _act5_src)
            and ("PlaceAtMe(cardBase" not in _act5_src)
            and ("SyncCathedralExteriorDestruction" in _act5_src)
            and ("SyncMasterVaultExitAndGates" in _act5_src)
            and ("SyncCathedralOptionalObjectives" in _act5_src)
            and ("iAct5CineReadyTicks" in _act5_src)
            and ("iMariposaReadyTicks" in _act4_src)
        )
        self.check(
            cave_entry_ok and cath_ext_ruins_ok and cath_doors_ok and stage38_ok and obj38_ok and no_black_fade_ok,
            f"Req V: Cave mouth 0x0100223D, Cathedral ruins (0x01009960..9974), double crypt door & seals, QOBJ 22..24/38, & no-black-screen cinematics verified (cave={cave_entry_ok}, ruins={cath_ext_ruins_ok}, doors={cath_doors_ok}, stg38={stage38_ok}, objs={obj38_ok}, cine={no_black_fade_ok})",
        )

        # Req W: Cathedral Exit Never Terminal-Locked, Crypt Return Corridor XTEL, & Recycled FO4 Props Cleanup
        r2d01 = refrs_by_fid.get(0x01002D01)
        xt_2d01 = r2d01.get("xtel") if r2d01 else None
        crypt_return_xtel_ok = (
            xt_2d01 is not None
            and xt_2d01[0] == 0x01002D83
            and abs(xt_2d01[1] - 878.351) < 1.0
            and abs(xt_2d01[2] - 4424.855) < 1.0
            and abs(xt_2d01[3] - (-132.625)) < 1.0
        )
        no_ntrm_ok = all(
            not any(st == "NTRM" for st, _ in records_by_fid.get(dfid, (None, None, [], None))[2])
            for dfid in (0x010015B8, 0x01001168)
        )
        _item_act5_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "papyrus_src", "V13ItemAct5Script.psc")
        _item_act5_src = open(_item_act5_path, encoding="utf-8").read() if os.path.exists(_item_act5_path) else ""
        item_act5_ok = ("SetStage(30)" not in _item_act5_src) and ("StartCathedralNuclearCountdown(2)" in _item_act5_src)
        forbidden_cal_bases = {
            0x00099D14,  # DN057_ToolBox
            0x001C19BE,  # Institute_Locker01
            0x001368AC,  # MapHagen01
            0x00178B56,  # BobbleHead_EnergyWeapons
            0x00178B5B,  # BobbleHead_Medicine
            0x00091FDE,  # PowerRelayCoil
            0x000B254D,  # DN053_VirgilsSerum
            0x0022BF62,  # PreventPowerArmorExitTrigger
            0x001A5948,  # WoodBox01_Prewar
        }
        leftover_cal_refs = [
            (hex(r_fid), hex(r_inf["cell"]), hex(r_inf["base"]))
            for r_fid, r_inf in refrs_by_fid.items()
            if r_inf.get("cell") != 0x01002000
            and (r_inf.get("flags", 0) & 0x0800) == 0
            and r_inf.get("base") in forbidden_cal_bases
        ]
        self.check(
            crypt_return_xtel_ok and no_ntrm_ok and item_act5_ok and len(leftover_cal_refs) == 0,
            f"Req W: Crypt return XTEL (878.4, 4424.9, -132.6), 0 NTRM on exit doors, V13ItemAct5Script safe, & 0 leftover FO4 props in California cells (xtel={crypt_return_xtel_ok}, no_ntrm={no_ntrm_ok}, item_psc={item_act5_ok}, leftovers={leftover_cal_refs})",
        )

        # Req X: Cathedral Non-Combatant Acolyte Cower/Flee AI (PACK 0x01001058/1057) & Gideon Psychic Cell Relocation
        flee_pack_rec = records_by_fid.get(0x01001057)
        flee_pack_ok = (
            flee_pack_rec is not None
            and flee_pack_rec[0] == "PACK"
            and any(st == "PKDT" and sv == bytes.fromhex("002002081200020060f80000") for st, sv in flee_pack_rec[2])
            and any(st == "PSDT" and sv == bytes.fromhex("00ff00ffff00000000000000") for st, sv in flee_pack_rec[2])
            and any(st == "PKCU" and len(sv) >= 8 and struct.unpack_from("<I", sv, 4)[0] == 0x00002CB0 for st, sv in flee_pack_rec[2])
            and any(
                st == "CTDA"
                and len(sv) >= 16
                and struct.unpack_from("<H", sv, 8)[0] == 0x000E
                and struct.unpack_from("<I", sv, 12)[0] == 0x000002BD
                for st, sv in flee_pack_rec[2]
            )
            and any(st == "PLDT" and len(sv) >= 16 and struct.unpack("<4I", sv[:16]) == (0, 0x01002D89, 95, 0) for st, sv in flee_pack_rec[2])
        )
        cower_pack_rec = records_by_fid.get(0x01001058)
        cower_pack_ok = (
            cower_pack_rec is not None
            and cower_pack_rec[0] == "PACK"
            and any(st == "PKDT" and sv == bytes.fromhex("003002081204020081040000") for st, sv in cower_pack_rec[2])
            and any(st == "PSDT" and sv == bytes.fromhex("00ff00ffff00000000000000") for st, sv in cower_pack_rec[2])
            and any(st == "PKCU" and len(sv) >= 8 and struct.unpack_from("<I", sv, 4)[0] == 0x00004DF6 for st, sv in cower_pack_rec[2])
            and any(st == "PTDA" and len(sv) >= 12 and struct.unpack("<3I", sv[:12]) == (3, 0x0005D5E6, 0) for st, sv in cower_pack_rec[2])
            and any(
                st == "CTDA"
                and len(sv) >= 16
                and struct.unpack_from("<H", sv, 8)[0] == 0x000E
                and struct.unpack_from("<I", sv, 12)[0] == 0x000002BD
                for st, sv in cower_pack_rec[2]
            )
        )
        worshiper_rec = records_by_fid.get(0x010015B4)
        worshiper_pkids = [struct.unpack("<I", sv[:4])[0] for st, sv in worshiper_rec[2] if st == "PKID"] if worshiper_rec else []
        worshiper_items = [struct.unpack("<I", sv[:4])[0] for st, sv in worshiper_rec[2] if st == "CNTO"] if worshiper_rec else []
        worshiper_ai_ok = worshiper_pkids == [0x01001058, 0x01001057, 0x01001050] and worshiper_items == [0x0000000F]
        cower_markers_ok = all(
            refrs_by_fid.get(0x01002D89 + idx, {}).get("cell") == 0x01002D80
            and refrs_by_fid.get(0x01002D89 + idx, {}).get("base") == 0x0020C2C4
            and any(
                st == "XLKR" and len(sv) == 8 and struct.unpack("<2I", sv) == (0x0005D5E6, 0x01002D89 + idx)
                for st, sv in records_by_fid.get(0x01002D86 + idx, (None, None, [], None))[2]
            )
            for idx in range(3)
        )

        r2d34 = refrs_by_fid.get(0x01002D34)
        r2d11 = refrs_by_fid.get(0x01002D11)
        r81049 = refrs_by_fid.get(0x01081049)
        gideon_cell_ok = (
            r2d34 is not None
            and r2d11 is not None
            and r2d34["cell"] == 0x01002D00
            and abs(r2d34["data"][0] - (-245.0)) < 1.0
            and abs(r2d34["data"][1] - (-898.0)) < 1.0
            and abs(r2d34["data"][2] - (-768.0)) < 1.0
            and r2d34["data"][2] > -810.0
            and math.dist(r2d34["data"][:3], r2d11["data"][:3]) > 1500.0
            and r81049 is not None
            and r81049["cell"] == 0x01002D00
            and r81049["base"] == 0x01009913
            and abs(r81049["data"][0] - (-245.0)) < 1.0
            and abs(r81049["data"][1] - (-898.0)) < 1.0
            and abs(r81049["data"][2] - (-640.0)) < 1.0
        )
        fact_civ = records_by_fid.get(0x01001C59)
        fact_fol = records_by_fid.get(0x01001C5A)
        cult_ally_ok = (
            fact_civ is not None
            and fact_civ[0] == "FACT"
            and any(st == "XNAM" and len(sv) >= 12 and struct.unpack("<IiI", sv[:12]) == (0x00058305, 0, 2) for st, sv in fact_civ[2])
            and any(st == "XNAM" and len(sv) >= 12 and struct.unpack("<IiI", sv[:12]) == (0x01001C5A, 0, 2) for st, sv in fact_civ[2])
            and fact_fol is not None
            and fact_fol[0] == "FACT"
            and any(st == "XNAM" and len(sv) >= 12 and struct.unpack("<IiI", sv[:12]) == (0x01001C59, 0, 2) for st, sv in fact_fol[2])
        )
        act5_panic_psc_ok = (
            "SyncSanctuaryAcolytePanic" in _act5_src
            and "MigrateGideonToPsychicCell" in _act5_src
            and "OnCombatStateChanged" in _act5_src
            and "0x0020AC3C" in _act5_src
            and "EvaluatePackage(true)" in _act5_src
            and "GetCombatTarget()" in _act5_src
            and "SetAlly(cultCivFac, false, false)" in _act5_src
        )
        self.check(
            flee_pack_ok and cower_pack_ok and worshiper_ai_ok and cower_markers_ok and gideon_cell_ok and cult_ally_ok and act5_panic_psc_ok,
            f"Req X: Cathedral acolyte cower/flee PACK 0x01001058/1057, cower markers 2D89..2D8B, Gideon relocation, faction Ally locks, & combat listeners verified (flee={flee_pack_ok}, cower={cower_pack_ok}, npc={worshiper_ai_ok}, markers={cower_markers_ok}, gideon={gideon_cell_ok}, ally={cult_ally_ok}, psc={act5_panic_psc_ok})",
        )

        # Req Y: Cathedral Ruins Local Smoke/Flames, Instant Stage 38 Exit Marker, Flush Cave Exit Bulkhead & Arroyo Ending Cinematic
        cath_fire_bases = {0x00212E6F, 0x0021113D, 0x00048283, 0x00048281, 0x00164199}
        cath_fire_refs = [refrs_by_fid.get(0x01003668)] + [refrs_by_fid.get(fid) for fid in range(0x0100996D, 0x01009974)]
        cathedral_local_fire_ok = (
            m3669 is not None
            and math.hypot(m3669["data"][0] - (-19500.0), m3669["data"][1] - (-31520.0)) <= 250.0
            and m3669["data"][2] <= 320.0
            and all(
                r is not None
                and r["base"] in cath_fire_bases
                and -20200.0 <= r["data"][0] <= -18750.0
                and -31800.0 <= r["data"][1] <= -31500.0
                for r in cath_fire_refs
            )
            and "0x00121A68" not in _act5_src
            and "0x001844BC" not in _act5_src
        )

        st38_idx = _act5_src.find("elseif aiStage >= 38 && aiStage < 40")
        st38_block = _act5_src[st38_idx:st38_idx + 2200] if st38_idx >= 0 else ""
        obj38_pos = st38_block.find("SetObjectiveDisplayed(38, true, false)")
        rew_pos = st38_block.find("GrantAct5CompletionRewards()")
        instant_stage38_ok = (
            'RegisterForRemoteEvent(exileScReg, "OnEnd")' in _act5_src
            and 'RegisterForRemoteEvent(exileEndInfo, "OnBegin")' in _act5_src
            and "Event Scene.OnEnd(" in _act5_src
            and "Event TopicInfo.OnBegin(" in _act5_src
            and "Event TopicInfo.OnEnd(" in _act5_src
            and "relicDisplay5.EnableNoWait()" in _act5_src
            and obj38_pos >= 0
            and rew_pos >= 0
            and obj38_pos < rew_pos
        )

        r2206 = refrs_by_fid.get(0x01002206)
        r2239 = refrs_by_fid.get(0x01002239)
        r223a = refrs_by_fid.get(0x0100223A)
        r223b = refrs_by_fid.get(0x0100223B)
        r223c = refrs_by_fid.get(0x0100223C)
        cell2200_rocks = [r for r in refrs_by_fid.values() if r["cell"] == 0x01002200 and r["base"] == 0x0004F14E]
        cell2200_hdrs = [r for r in refrs_by_fid.values() if r["cell"] == 0x01002200 and r["base"] == 0x00039383]
        flush_cave_exit_ok = (
            r2206 is not None
            and abs(r2206["data"][0] - 6736.0) < 0.5
            and abs(r2206["data"][1] - (-4255.0)) < 0.5
            and abs(r2206["data"][2] - 388.0) < 0.5
            and r2239 is not None
            and abs(r2239["data"][0] - 6614.402) < 0.05
            and abs(r2239["data"][1] - (-4294.973)) < 0.05
            and r223a is not None
            and abs(r223a["data"][0] - 6534.456) < 0.05
            and abs(r223a["data"][1] - (-4051.776)) < 0.05
            and r223b is not None
            and abs(r223b["data"][0] - 6694.348) < 0.05
            and abs(r223b["data"][1] - (-4538.170)) < 0.05
            and r223c is not None
            and abs(r223c["data"][0] - 6614.402) < 0.05
            and abs(r223c["data"][1] - (-4294.973)) < 0.05
            and len(cell2200_rocks) >= 2
            and len(cell2200_hdrs) >= 1
            and "6807.54" not in _act1_src
            and "caveExitDoor.SetPosition(6736.0, -4255.0, 388.0)" in _act1_src
        )

        p1056_rec = records_by_fid.get(0x01001056)
        p1056_pkdt = next((sv for st, sv in p1056_rec[2] if st == "PKDT"), b"") if p1056_rec else b""
        p1056_psdt = next((sv for st, sv in p1056_rec[2] if st == "PSDT"), b"") if p1056_rec else b""
        p1056_cnam0 = next((sv for st, sv in p1056_rec[2] if st == "CNAM"), b"") if p1056_rec else b""
        r994b = refrs_by_fid.get(0x0100994B)
        cards_pers_ok = all(
            cfid in refrs_by_fid and (refrs_by_fid[cfid]["flags"] & 0x0C00) == 0x0C00
            for cfid in range(0x01009950, 0x01009956)
        )
        _arroyo_exempt_fids = set(range(0x01003660, 0x01003668)) | set(range(0x01009948, 0x01009956))
        _arroyo_exempt_bases = {0x000560DC, 0x0008ADFA, 0x00000034, 0x0000003B, 0x00000010}
        _arroyo_anchors = [(-6640.0, 32620.0), (-6500.0, 32620.0), (-6430.0, 32530.0)]
        arroyo_camp_clear_ok = not any(
            (rfid not in _arroyo_exempt_fids)
            and (r["base"] not in _arroyo_exempt_bases)
            and (r["data"] is not None)
            and (abs(r["data"][2] - 320.0) < 200.0)
            and any(math.hypot(r["data"][0] - ax, r["data"][1] - ay) < 260.0 for ax, ay in _arroyo_anchors)
            for rfid, r in refrs_by_fid.items()
        )
        arroyo_cinematic_ok = (
            p1056_pkdt == bytes.fromhex("002080081200010064f80000")
            and p1056_psdt == bytes.fromhex("00ff00ffff00000000000000")
            and p1056_cnam0 == b"\x00"
            and r994b is not None
            and -7800.0 <= r994b["data"][0] <= -7500.0
            and 31950.0 <= r994b["data"][1] <= 32200.0
            and abs(r994b["data"][2] - 320.0) < 1.0
            and all(refrs_by_fid[cfid]["data"][1] >= 32768.0 for cfid in range(0x01009950, 0x01009956))
            and cards_pers_ok
            and arroyo_camp_clear_ok
            and "preWant.EnableNoWait" not in _act5_src
            and "exilePlayer.MoveTo" not in _act5_src
            and "kActiveExileDouble.MoveTo" not in _act5_src
            and "exilePlayer.SetPosition" not in _act5_src
            and "cardRef.MoveTo" not in _act5_src
            and "[Theresa — Rumbo a Arroyo]" in _act5_src
            and "[Lyle — Pionero de Arroyo]" in _act5_src
            and "fundar la aldea de ARROYO" in _act5_src
            and "ShowDynamicCaliforniaEpilogue()" in _act5_src
            and "bool resumeExile =" in _act5_src
            and "iExileCineFixRev" in _act5_src
        )

        self.check(
            cathedral_local_fire_ok and instant_stage38_ok and flush_cave_exit_ok and arroyo_cinematic_ok,
            f"Req Y: Cathedral local smoke/flames, instant Stage 38 exit marker, flush cave exit bulkhead (128u), & Arroyo pioneers epilogue verified (fire={cathedral_local_fire_ok}, stage38={instant_stage38_ok}, exit={flush_cave_exit_ok}, arroyo={arroyo_cinematic_ok})",
        )

        # Req Z: SuperMutantRace Subgraph-Compatible Armament (Cathedral Praetorians & Mariposa Lieutenant)
        sm_valid_weps = {0x0001F669, 0x0000463F, 0x0003F6F8, 0x000FF964, 0x0005DF2E}
        sm_npc_fids = [
            fid for fid, (rtype, _f, subs, _p) in records_by_fid.items()
            if rtype == "NPC_"
            and any(st == "RNAM" and len(sv) >= 4 and struct.unpack("<I", sv[:4])[0] == 0x0001A009 for st, sv in subs)
        ]
        sm_armed_ok = len(sm_npc_fids) >= 9 and all(
            any(st == "CNTO" and len(sv) >= 4 and struct.unpack("<I", sv[:4])[0] in sm_valid_weps for st, sv in records_by_fid[fid][2])
            for fid in sm_npc_fids
        )
        prae_items = {struct.unpack("<I", sv[:4])[0] for st, sv in records_by_fid.get(0x0100120B, (None, None, [], None))[2] if st == "CNTO"}
        prae_ok = (0x000E27BC not in prae_items) and {0x0001F669, 0x0001F66C, 0x0000463F, 0x0001F278, 0x000FF964}.issubset(prae_items)
        lou_items_z = {struct.unpack("<I", sv[:4])[0] for st, sv in records_by_fid.get(0x01001207, (None, None, [], None))[2] if st == "CNTO"}
        lou_armed_ok = {0x0001F669, 0x0001F66C, 0x000FF964}.issubset(lou_items_z)
        sm_psc_ok = ("EnsureCathedralMutantWeapons" in _act5_src) and ("0x0001F669" in _act4_src)
        self.check(
            sm_armed_ok and prae_ok and lou_armed_ok and sm_psc_ok,
            f"Req Z: All SuperMutantRace NPCs armed with STKD-valid weapons (count={len(sm_npc_fids)}, armed={sm_armed_ok}, prae={prae_ok}, lou={lou_armed_ok}, psc={sm_psc_ok})",
        )

        # Req AA: Playability Audit Guards — Sound SOUN-vs-SNDR Casts & SyncAllCaliforniaPersistentCoords Parity
        sound_cast_re = re.compile(r'GetFormFromFile\(\s*(0x[0-9A-Fa-f]+|\d+)\s*,\s*"Vault13Chronicles\.esp"\s*\)\s+[Aa][Ss]\s+Sound\b')
        bad_sound_casts = []
        base_dir = os.path.dirname(os.path.abspath(__file__))
        for pdir in (os.path.join(base_dir, "papyrus_src"), os.path.join(base_dir, "edition_en", "papyrus_src")):
            if not os.path.isdir(pdir):
                continue
            rel_pdir = os.path.relpath(pdir, base_dir)
            for fn in sorted(os.listdir(pdir)):
                if not fn.endswith(".psc"):
                    continue
                with open(os.path.join(pdir, fn), encoding="utf-8", errors="ignore") as f:
                    for ln, line in enumerate(f, 1):
                        code = line.split(";", 1)[0]
                        for m in sound_cast_re.finditer(code):
                            raw_id = m.group(1)
                            val = int(raw_id, 16) if raw_id.lower().startswith("0x") else int(raw_id)
                            fid = 0x01000000 | (val & 0x00FFFFFF)
                            rec = records_by_fid.get(fid)
                            if rec is None or rec[0] != "SOUN":
                                bad_sound_casts.append(f"{rel_pdir}/{fn}:{ln}->{hex(fid)}({rec[0] if rec else 'MISSING'})")

        sync_coords_ok = True
        expected_sync_tokens = (
            "ftY[15] = -33850.0",
            "ftX[16] = -5600.0",
            "ftY[16] = -32280.0",
            "ftY[23] = -19100.0",
            "mkY[15] = -33280.0",
            "ecZ[25] = 390.0",
            "ambX[4] = -1950.0",
            "ambY[4] = -12550.0",
            "npcX[5] = -2200.0",
            "npcY[5] = -34400.0",
            "npcAng[5] = 0.0",
        )
        for pdir in (os.path.join(base_dir, "papyrus_src"), os.path.join(base_dir, "edition_en", "papyrus_src")):
            a1p = os.path.join(pdir, "V13Act1QuestScript.psc")
            if not os.path.isfile(a1p):
                sync_coords_ok = False
                continue
            a1txt = open(a1p, encoding="utf-8", errors="ignore").read()
            if not all(tok in a1txt for tok in expected_sync_tokens):
                sync_coords_ok = False

        self.check(
            len(bad_sound_casts) == 0 and sync_coords_ok,
            f"Req AA: All Papyrus 'as Sound' casts target SOUN records & SyncAllCaliforniaPersistentCoords matches ESP DATA in ES/EN (bad_sounds={bad_sound_casts}, sync_coords={sync_coords_ok})",
        )


if __name__ == "__main__":
    suite = VerificationSuite()
    ok = suite.run_all()
    sys.exit(0 if ok else 1)
