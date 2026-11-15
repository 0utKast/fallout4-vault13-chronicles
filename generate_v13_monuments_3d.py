# -*- coding: utf-8 -*-
"""
Generates all 10 Custom Fallout 1 (1997) 3D Exterior Monuments & Architectural Settlement Kits
for Crónicas del Refugio 13 / Vault 13 Chronicles (`STAT 0x01001D00 .. 0x01001D09`):

  0x01001D00: V13CathedralMonument.nif      — La Catedral (1997 Gothic-Art-Deco Monument + Sacred Flame Rose Window)
  0x01001D01: V13LostHillsSurfaceBunker.nif — Búnker Exterior de Lost Hills (Hermandad del Acero)
  0x01001D02: V13MariposaBunkerFacade.nif   — Complejo Militar Blindado de Mariposa (U.S. Army VEF)
  0x01001D03: V13TheGlowCrater.nif          — Cráter Nuclear Vitrificado de El Resplandor (West Tek)
  0x01001D04: V13ShadySandsGateArch.nif     — Arco de Entrada de Adobe de Shady Sands
  0x01001D05: V13ShadySandsAdobeHall.nif    — Casa Comunal de Adobe de Shady Sands (Walk-in)
  0x01001D06: V13ShadySandsAdobeHouse.nif   — Vivienda / Clínica de Adobe de Shady Sands (Walk-in)
  0x01001D07: V13ShadySandsObelisk.nif      — Obelisco Fundacional de la Plaza de Shady Sands (2142)
  0x01001D08: V13JunktownScrapGate.nif      — Pórtico Acorazado de Coches y Chatarra de Junktown
  0x01001D09: V13HubWaterTower.nif          — Gran Torre de Agua Remachada de los Mercaderes del Agua (El Eje)

Every NIF is exported via Blender 5.2 LTS + PyNifly 30.2.0 with:
  - Genuine Fallout 4 `BSTriShape` + `BSLightingShaderProperty` + `BSShaderTextureSet`
  - Custom `Materials\\V13Chronicles\\Monuments\\*.BGSM` + 1024x1024 11-mip BC1 `*_d.dds`
  - Exact static Havok `bhkNPCollisionObject` + `bhkPhysicsSystem` (`compressed_mesh` + `BSXFlags = 0x82`)
    preserving walkable portals, doorways, stairs, and solid architectural walls.
"""

from __future__ import annotations

import glob
import json
import math
import os
import random
import struct
import subprocess
import sys
import tempfile
import zlib

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

THIS_DIR = os.path.dirname(os.path.abspath(__file__))
if THIS_DIR not in sys.path:
    sys.path.insert(0, THIS_DIR)

from generate_v13_worldmap_dds import encode_bc1_rgb_mips
from generate_v13_junktown_3d_assets import (
    BLENDER_EXE,
    FO4_DATA_DIR,
    PYNIFLY_DIR as PYNIFLY_ADDON_DIR,
    _build_texset_bytes,
    _intern_nif_string,
    _parse_fo4_nif,
    _serialize_fo4_nif,
    build_bgsm_v2_bytes,
)

ASSET_ROOT = os.path.join(THIS_DIR, "assets", "monuments_3d")
MESH_OUT_DIR = os.path.join(ASSET_ROOT, "Meshes", "V13Chronicles", "Monuments")
MAT_OUT_DIR = os.path.join(ASSET_ROOT, "Materials", "V13Chronicles", "Monuments")
TEX_OUT_DIR = os.path.join(ASSET_ROOT, "Textures", "V13Chronicles", "Monuments")
VANILLA_PREVIEW_DIR = os.path.join(ASSET_ROOT, "_vanilla_preview_tex")
MAT_SPECS_JSON = os.path.join(ASSET_ROOT, "_monument_mat_specs.json")
PREVIEW_SHEET_PNG = os.path.join(ASSET_ROOT, "monuments_preview_sheet.png")

DONOR_STATIC_NIF = os.path.join(
    THIS_DIR, "assets", "junktown_3d", "Meshes", "V13Chronicles", "Junktown", "TardisPoliceBox.nif"
)
DONOR_OPAQUE_BGSM = os.path.join(
    THIS_DIR, "assets", "junktown_3d", "Materials", "V13Chronicles", "Junktown", "TardisPoliceBox.BGSM"
)

MONUMENT_NIF_SPECS: list[tuple[int, str, str, str, str]] = [
    # (stat_fid, edid, nif_filename, primary_bgsm_stem, primary_dds_stem)
    (0x01001D00, "StatV13CathedralMonument",      "V13CathedralMonument.nif",      "CathedralMonument", "CathedralStone"),
    (0x01001D01, "StatV13LostHillsSurfaceBunker", "V13LostHillsSurfaceBunker.nif", "LostHillsBunker",   "LostHillsConcrete"),
    (0x01001D02, "StatV13MariposaBunkerFacade",   "V13MariposaBunkerFacade.nif",   "MariposaBunker",    "MariposaMilitary"),
    (0x01001D03, "StatV13TheGlowCrater",          "V13TheGlowCrater.nif",          "GlowCrater",        "GlowCrater"),
    (0x01001D04, "StatV13ShadySandsGateArch",     "V13ShadySandsGateArch.nif",     "ShadyAdobe",        "ShadyAdobe"),
    (0x01001D05, "StatV13ShadySandsAdobeHall",    "V13ShadySandsAdobeHall.nif",    "ShadyAdobe",        "ShadyAdobe"),
    (0x01001D06, "StatV13ShadySandsAdobeHouse",   "V13ShadySandsAdobeHouse.nif",   "ShadyAdobe",        "ShadyAdobe"),
    (0x01001D07, "StatV13ShadySandsObelisk",      "V13ShadySandsObelisk.nif",      "ShadyPlaque",       "ShadyPlaque"),
    (0x01001D08, "StatV13JunktownScrapGate",      "V13JunktownScrapGate.nif",      "JunktownGate",      "JunktownGate"),
    (0x01001D09, "StatV13HubWaterTower",          "V13HubWaterTower.nif",          "HubWaterTower",     "HubWaterTower"),
    (0x01001D0A, "StatV13MasterBiomechanicalThrone", "V13MasterBiomechanicalThrone.nif", "MasterThrone", "MasterThrone"),
    (0x01001D0D, "StatV13CathedralRuins",         "V13CathedralRuins.nif",         "CathedralMonument", "CathedralStone"),
    (0x01009920, "StatV13CathedralBannerTall",     "V13CathedralBannerTall.nif",     "CathedralBanner",       "CathedralBanner"),
    (0x01009921, "StatV13CathedralStainedGlass",   "V13CathedralStainedGlass.nif",   "CathedralStainedGlass", "CathedralStainedGlass"),
    (0x01009922, "StatV13CathedralAltarMonolith",  "V13CathedralAltarMonolith.nif",  "CathedralAltarRelief",  "CathedralAltarRelief"),
    (0x01009923, "StatV13MasterFleshArch",         "V13MasterFleshArch.nif",         "MasterFlesh",           "MasterFlesh"),
    (0x01009924, "StatV13MasterFleshWallCluster",  "V13MasterFleshWallCluster.nif",  "MasterFlesh",           "MasterFlesh"),
    (0x01009925, "StatV13MasterVaultPlaque",       "V13MasterVaultPlaque.nif",       "MasterVaultPlaque",     "MasterVaultPlaque"),
    (0x01009928, "StatV13EndingCreditCard01",      "V13EndingCreditCard01.nif",      "V13CreditCard01",       "V13CreditCard01"),
    (0x01009929, "StatV13EndingCreditCard02",      "V13EndingCreditCard02.nif",      "V13CreditCard02",       "V13CreditCard02"),
    (0x0100992A, "StatV13EndingCreditCard03",      "V13EndingCreditCard03.nif",      "V13CreditCard03",       "V13CreditCard03"),
    (0x0100992B, "StatV13EndingCreditCard04",      "V13EndingCreditCard04.nif",      "V13CreditCard04",       "V13CreditCard04"),
    (0x0100992C, "StatV13EndingCreditCard05",      "V13EndingCreditCard05.nif",      "V13CreditCard05",       "V13CreditCard05"),
    (0x0100992D, "StatV13EndingCreditCard06",      "V13EndingCreditCard06.nif",      "V13CreditCard06",       "V13CreditCard06"),
]

# Verified opaque (alpha=0, tile=3) native Fallout 4 .BGSM -> .dds mappings from Fallout4 - Materials.ba2
VANILLA_MAT_DEFS: dict[str, tuple[str, str, str, str, str]] = {
    # mat_key: (bgsm_path, diffuse_dds, normal_dds, spec_dds, env_dds)
    "corrugated": (
        r"Materials\Architecture\DiamondCity\CorrugatedMetal01.BGSM",
        r"Textures\architecture\diamondcity\corrugatedmetal01_d.dds",
        r"Textures\architecture\diamondcity\corrugatedmetal01_n.dds",
        r"Textures\architecture\diamondcity\corrugatedmetal01_s.dds",
        r"Textures\Shared\Cubemaps\mipblur_DefaultOutside1.dds",
    ),
    "shack_metal": (
        r"Materials\Architecture\Shacks\ShackMetal01NoAlpha.BGSM",
        r"Textures\architecture\shacks\shackmetal01_d.dds",
        r"Textures\architecture\shacks\shackmetal01_n.dds",
        r"Textures\architecture\shacks\shackmetal01_s.dds",
        r"Textures\Shared\Cubemaps\mipblur_DefaultOutside1.dds",
    ),
    "plywood": (
        r"Materials\Architecture\Shacks\ShackPlywood01.BGSM",
        r"Textures\architecture\shacks\shackplywood01_d.dds",
        r"Textures\architecture\shacks\shackplywood01_n.dds",
        r"Textures\architecture\shacks\shackplywood01_s.dds",
        "",
    ),
    "assorted_rust": (
        r"Materials\SetDressing\Boats\BoatBeamsRust01.BGSM",
        r"Textures\SetDressing\Boats\BoatBeamsRust01_d.dds",
        r"Textures\SetDressing\Boats\BoatBeamsRust01_n.dds",
        r"Textures\SetDressing\Boats\BoatBeamsRust01_s.dds",
        r"Textures\Shared\Cubemaps\mipblur_DefaultOutside1.dds",
    ),
    "catwalk_rust": (
        r"Materials\Architecture\Quarry\QuarryCatwalksRust01.BGSM",
        r"Textures\architecture\quarry\qrycatwalksrust01_d.dds",
        r"Textures\architecture\quarry\qrycatwalksrust01_n.dds",
        r"Textures\architecture\quarry\qrycatwalksrust01_s.dds",
        r"Textures\Shared\Cubemaps\mipblur_DefaultOutside1.dds",
    ),
    "tires": (
        r"Materials\SetDressing\Tires\tires01.bgsm",
        r"Textures\setdressing\tires\tires01_d.dds",
        r"Textures\setdressing\tires\tires01_n.dds",
        r"Textures\setdressing\tires\tires01_s.dds",
        "",
    ),
    "tarpaper": (
        r"Materials\Architecture\Warehouse\WrhsTarpaper.BGSM",
        r"Textures\architecture\warehouse\wrhsrooftarpaper01_d.dds",
        r"Textures\architecture\warehouse\wrhsrooftarpaper01_n.dds",
        r"Textures\architecture\warehouse\wrhsrooftarpaper01_s.dds",
        "",
    ),
    "bunker_conc1": (
        r"Materials\Architecture\Bunkers\BunConcrete01.BGSM",
        r"Textures\Architecture\Bunkers\BunConcrete01_d.dds",
        r"Textures\Architecture\Bunkers\BunConcrete01_n.dds",
        r"Textures\Architecture\Bunkers\BunConcrete01_s.dds",
        "",
    ),
    "bunker_conc2": (
        r"Materials\Architecture\Bunkers\BunConcrete02.BGSM",
        r"Textures\Architecture\Bunkers\BunConcrete02_d.dds",
        r"Textures\Architecture\Bunkers\BunConcrete02_n.dds",
        r"Textures\Architecture\Bunkers\BunConcrete02_s.dds",
        "",
    ),
    "diamond_pipes": (
        r"Materials\Architecture\DiamondCity\DiamondPipes01.BGSM",
        r"Textures\architecture\diamondcity\diamondpipes01_d.dds",
        r"Textures\architecture\diamondcity\diamondpipes01_n.dds",
        r"Textures\architecture\diamondcity\diamondpipes01_s.dds",
        r"Textures\Shared\Cubemaps\mipblur_DefaultOutside1.dds",
    ),
    "church_stone": (
        r"Materials\Architecture\Buildings\ChurchStoneWall01.BGSM",
        r"Textures\Architecture\Buildings\ChurchStoneWall01_d.dds",
        r"Textures\Architecture\Buildings\ChurchStoneWall01_n.dds",
        r"Textures\Architecture\Buildings\ChurchStoneWall01_s.dds",
        "",
    ),
    "concrete01": (
        r"Materials\Architecture\Buildings\Concrete01.BGSM",
        r"Textures\architecture\buildings\concrete01a_d.dds",
        r"Textures\Architecture\Buildings\Concrete01A_n.dds",
        r"Textures\architecture\buildings\concrete01a_s.dds",
        "",
    ),
    "concrete02": (
        r"Materials\Architecture\Buildings\Concrete02.BGSM",
        r"Textures\architecture\buildings\concrete02_d.dds",
        r"Textures\architecture\buildings\concrete02_n.dds",
        r"Textures\architecture\buildings\concrete02_s.dds",
        "",
    ),
    "roof_slate": (
        r"Materials\Architecture\Buildings\RoofSlate01.BGSM",
        r"Textures\architecture\buildings\roofslate01_d.dds",
        r"Textures\architecture\buildings\roofslate01_n.dds",
        r"Textures\architecture\buildings\roofslate01_s.dds",
        "",
    ),
    "adobe_plaster": (
        r"Materials\Architecture\Buildings\Plaster01.BGSM",
        r"Textures\architecture\buildings\plaster01_d.dds",
        r"Textures\architecture\buildings\plaster01_n.dds",
        r"Textures\architecture\buildings\plaster01_s.dds",
        "",
    ),
    "cracked_mud": (
        r"Materials\Landscape\Ground\GlowingSeaCrackedMud01.BGSM",
        r"Textures\Landscape\Ground\GlowingSeaCrackedMud01_d.dds",
        r"Textures\Landscape\Ground\GlowingSeaCrackedMud01_n.dds",
        r"Textures\Landscape\Ground\GlowingSeaCrackedMud01_s.dds",
        "",
    ),
    "corrosion": (
        r"Materials\Landscape\Ground\GlowingSeaCorrosion01.BGSM",
        r"Textures\Landscape\Ground\GlowingSeaCorrosion01_d.dds",
        r"Textures\Landscape\Ground\GlowingSeaCorrosion01_n.dds",
        r"Textures\Landscape\Ground\GlowingSeaCorrosion01_s.dds",
        r"Textures\Shared\Cubemaps\mipblur_DefaultOutside1.dds",
    ),
    "vault_blue": (
        r"Materials\Interiors\Vault\V111Struct01Blue.BGSM",
        r"Textures\interiors\vault\vstruct01blue_d.dds",
        r"Textures\interiors\vault\vault111\v111struct01_n.dds",
        r"Textures\interiors\vault\vault111\v111struct01_s.dds",
        r"Textures\Shared\Cubemaps\mipblur_DefaultOutside1.dds",
    ),
    "gore_meat": (
        r"Materials\Gore\GoreBaseBitsRed.BGSM",
        r"Textures\gore\gorebasebits_d.dds",
        r"Textures\gore\gorebasebits_n.dds",
        r"Textures\gore\gorebasebits_s.dds",
        "",
    ),
}

# Custom weathered signage / plaque / rose-window / CRT materials paired with real Fallout 4 _n.dds & _s.dds maps
CUSTOM_MONUMENT_MAT_DEFS: dict[str, tuple[str, str, str, str, str, float, float, float]] = {
    # mat_key: (bgsm_stem, dds_stem, normal_no_tex_prefix, spec_no_tex_prefix, env_no_tex_prefix, env_scale, spec_mult, smoothness)
    "custom_cathedral": (
        "CathedralMonument",
        "CathedralStone",
        "Architecture/Buildings/ChurchStoneWall01_n.dds",
        "Architecture/Buildings/ChurchStoneWall01_s.dds",
        "Shared/Cubemaps/mipblur_DefaultOutside1.dds",
        0.18,
        0.45,
        0.55,
    ),
    "custom_losthills": (
        "LostHillsBunker",
        "LostHillsConcrete",
        "Architecture/Bunkers/BunConcrete01_n.dds",
        "Architecture/Bunkers/BunConcrete01_s.dds",
        "Shared/Cubemaps/mipblur_DefaultOutside1.dds",
        0.22,
        0.55,
        0.65,
    ),
    "custom_mariposa": (
        "MariposaBunker",
        "MariposaMilitary",
        "SetDressing/Boats/BoatBeamsRust01_n.dds",
        "SetDressing/Boats/BoatBeamsRust01_s.dds",
        "Shared/Cubemaps/mipblur_DefaultOutside1.dds",
        0.28,
        0.65,
        0.70,
    ),
    "custom_glow": (
        "GlowCrater",
        "GlowCrater",
        "Landscape/Ground/GlowingSeaCorrosion01_n.dds",
        "Landscape/Ground/GlowingSeaCorrosion01_s.dds",
        "",
        0.0,
        0.40,
        0.45,
    ),
    "custom_shady_adobe": (
        "ShadyAdobe",
        "ShadyAdobe",
        "architecture/buildings/plaster01_n.dds",
        "architecture/buildings/plaster01_s.dds",
        "",
        0.0,
        0.25,
        0.38,
    ),
    "custom_shady_plaque": (
        "ShadyPlaque",
        "ShadyPlaque",
        "Architecture/Buildings/Concrete01A_n.dds",
        "architecture/buildings/concrete01a_s.dds",
        "Shared/Cubemaps/mipblur_DefaultOutside1.dds",
        0.25,
        0.72,
        0.75,
    ),
    "custom_junktown_gate": (
        "JunktownGate",
        "JunktownGate",
        "SetDressing/Boats/BoatBeamsRust01_n.dds",
        "SetDressing/Boats/BoatBeamsRust01_s.dds",
        "Shared/Cubemaps/mipblur_DefaultOutside1.dds",
        0.25,
        0.65,
        0.65,
    ),
    "custom_hub_tower": (
        "HubWaterTower",
        "HubWaterTower",
        "SetDressing/Boats/BoatBeamsRust01_n.dds",
        "SetDressing/Boats/BoatBeamsRust01_s.dds",
        "Shared/Cubemaps/mipblur_DefaultOutside1.dds",
        0.30,
        0.68,
        0.68,
    ),
    "custom_master": (
        "MasterThrone",
        "MasterThrone",
        "interiors/vault/vault111/v111struct01_n.dds",
        "interiors/vault/vault111/v111struct01_s.dds",
        "Shared/Cubemaps/mipblur_DefaultOutside1.dds",
        0.35,
        0.80,
        0.85,
    ),
}

# Overhaul & Ending Credit Card materials generated cleanly via generate_v13_overhaul_assets.py
# mat_key: (bgsm_rel, diff_rel, norm_rel, spec_rel, env_rel, preview_dds_abs, alpha_blend)
OVERHAUL_MAT_DEFS: dict[str, tuple[str, str, str, str, str, str, bool]] = {
    "custom_cathedral_banner": (
        r"Materials\V13Chronicles\Monuments\CathedralBanner.BGSM",
        r"Textures\V13Chronicles\Monuments\CathedralBanner_d.dds",
        r"Textures\Architecture\Buildings\ChurchStoneWall01_n.dds",
        r"Textures\Architecture\Buildings\ChurchStoneWall01_s.dds",
        "",
        os.path.join(TEX_OUT_DIR, "CathedralBanner_d.dds"),
        False,
    ),
    "custom_stained_glass": (
        r"Materials\V13Chronicles\Monuments\CathedralStainedGlass.BGSM",
        r"Textures\V13Chronicles\Monuments\CathedralStainedGlass_d.dds",
        r"Textures\Architecture\Buildings\ChurchStoneWall01_n.dds",
        r"Textures\Architecture\Buildings\ChurchStoneWall01_s.dds",
        "",
        os.path.join(TEX_OUT_DIR, "CathedralStainedGlass_d.dds"),
        False,
    ),
    "custom_altar_relief": (
        r"Materials\V13Chronicles\Monuments\CathedralAltarRelief.BGSM",
        r"Textures\V13Chronicles\Monuments\CathedralAltarRelief_d.dds",
        r"Textures\Architecture\Buildings\ChurchStoneWall01_n.dds",
        r"Textures\Architecture\Buildings\ChurchStoneWall01_s.dds",
        "",
        os.path.join(TEX_OUT_DIR, "CathedralAltarRelief_d.dds"),
        False,
    ),
    "custom_master_plaque": (
        r"Materials\V13Chronicles\Monuments\MasterVaultPlaque.BGSM",
        r"Textures\V13Chronicles\Monuments\MasterVaultPlaque_d.dds",
        r"Textures\Interiors\Vault\Vault111\V111Struct01_n.dds",
        r"Textures\Interiors\Vault\Vault111\V111Struct01_s.dds",
        "",
        os.path.join(TEX_OUT_DIR, "MasterVaultPlaque_d.dds"),
        False,
    ),
    **{
        f"custom_credit_card_{i:02d}": (
            f"Materials\\V13Chronicles\\Credits\\V13CreditCard{i:02d}.BGSM",
            f"Textures\\V13Chronicles\\Credits\\V13CreditCard{i:02d}_d.dds",
            r"Textures\Shared\FlatFlat_n.dds",
            r"Textures\interiors\building\bldconcreteceilinggross01_s.dds",
            "",
            os.path.join(THIS_DIR, "assets", "textures", "V13Chronicles", "Credits", f"V13CreditCard{i:02d}_d.dds"),
            True,
        )
        for i in range(1, 7)
    },
}


def _all_material_lookup() -> dict[str, tuple[str, str, str, str, str]]:
    """Returns lowercased bgsm_path -> (canonical_bgsm, diffuse, normal, spec, env)."""
    out: dict[str, tuple[str, str, str, str, str]] = {}
    for _mk, tup in VANILLA_MAT_DEFS.items():
        out[tup[0].lower()] = tup
    out[r"materials\architecture\warehouse\wrhsassortedrust01.bgsm"] = VANILLA_MAT_DEFS["assorted_rust"]
    for _mk, (bgsm_stem, dds_stem, nrm, spc, env, _es, _sm, _sh) in CUSTOM_MONUMENT_MAT_DEFS.items():
        bgsm_rel = f"Materials\\V13Chronicles\\Monuments\\{bgsm_stem}.BGSM"
        out[bgsm_rel.lower()] = (
            bgsm_rel,
            f"Textures\\V13Chronicles\\Monuments\\{dds_stem}_d.dds",
            "Textures\\" + nrm.replace("/", "\\"),
            "Textures\\" + spc.replace("/", "\\"),
            ("Textures\\" + env.replace("/", "\\")) if env else "",
        )
    for _mk, (bgsm_rel, diff_rel, norm_rel, spec_rel, env_rel, _prev, _ab) in OVERHAUL_MAT_DEFS.items():
        out[bgsm_rel.lower()] = (bgsm_rel, diff_rel, norm_rel, spec_rel, env_rel)
    return out


def _material_key_info(mat_key: str) -> tuple[str, str, str, str, str]:
    if mat_key in VANILLA_MAT_DEFS:
        return VANILLA_MAT_DEFS[mat_key]
    if mat_key in OVERHAUL_MAT_DEFS:
        return OVERHAUL_MAT_DEFS[mat_key][:5]
    bgsm_stem, dds_stem, nrm, spc, env, _es, _sm, _sh = CUSTOM_MONUMENT_MAT_DEFS[mat_key]
    return (
        f"Materials\\V13Chronicles\\Monuments\\{bgsm_stem}.BGSM",
        f"Textures\\V13Chronicles\\Monuments\\{dds_stem}_d.dds",
        "Textures\\" + nrm.replace("/", "\\"),
        "Textures\\" + spc.replace("/", "\\"),
        ("Textures\\" + env.replace("/", "\\")) if env else "",
    )


def _write_bc1_dds_1024(im_rgb: Image.Image, out_path: str) -> None:
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    im_1024 = im_rgb.convert("RGB").resize((1024, 1024), Image.Resampling.LANCZOS)
    mips_payload = encode_bc1_rgb_mips(im_1024, mips=11)
    dds_hdr = struct.pack(
        "<4s7I44s9I16s",
        b"DDS ", 124, 0x000A1007, 1024, 1024, 524288, 0, 11,
        b"\x00" * 44,
        32, 0x04, int.from_bytes(b"DXT1", "little"), 0, 0, 0, 0, 0, 0x00401008,
        b"\x00" * 16,
    )
    with open(out_path, "wb") as wf:
        wf.write(dds_hdr + mips_payload)


def _add_grain(im: Image.Image, strength: float = 10.0, seed: int = 13) -> Image.Image:
    rng = np.random.default_rng(seed)
    arr = np.asarray(im, dtype=np.float32)
    noise = rng.normal(0.0, strength, size=(arr.shape[0], arr.shape[1], 1))
    arr = np.clip(arr + noise, 0.0, 255.0).astype(np.uint8)
    return Image.fromarray(arr, mode="RGB")


def _load_fonts() -> tuple[ImageFont.FreeTypeFont, ImageFont.FreeTypeFont, ImageFont.FreeTypeFont]:
    try:
        return (
            ImageFont.truetype("C:/Windows/Fonts/impact.ttf", 48),
            ImageFont.truetype("C:/Windows/Fonts/consolab.ttf", 30),
            ImageFont.truetype("C:/Windows/Fonts/consolab.ttf", 20),
        )
    except Exception:
        f = ImageFont.load_default()
        return f, f, f


def _weather_panel(
    im: Image.Image,
    seed: int = 13,
    rust_amount: float = 0.30,
    grime_amount: float = 0.28,
    edge_vignette: float = 0.35,
    chip_speckles: int = 240,
) -> Image.Image:
    """Adds Fallout-authentic multi-scale weathering, vertical rust/rain streaks, edge grime, and paint chips."""
    rng = np.random.default_rng(seed)
    h, w = im.height, im.width
    arr = np.asarray(im, dtype=np.float32)

    # Low-frequency cloudy mottling (32x32 upsampled) + medium dirt (128x128)
    n_lo = Image.fromarray(rng.uniform(0, 255, (24, 24)).astype(np.uint8), "L").resize((w, h), Image.Resampling.BICUBIC)
    n_md = Image.fromarray(rng.uniform(0, 255, (96, 96)).astype(np.uint8), "L").resize((w, h), Image.Resampling.BILINEAR)
    # Vertical streak map (water/rust runoff)
    streak = rng.uniform(0.0, 1.0, (16, w))
    n_st = Image.fromarray((streak * 255).astype(np.uint8), "L").resize((w, h), Image.Resampling.BILINEAR)

    m_lo = np.asarray(n_lo, dtype=np.float32) / 255.0
    m_md = np.asarray(n_md, dtype=np.float32) / 255.0
    m_st = np.asarray(n_st, dtype=np.float32) / 255.0

    # Grime modulation across whole panel
    dirty_factor = 1.0 - grime_amount * (0.55 * m_lo + 0.45 * m_md) * 0.65
    arr *= dirty_factor[..., None]

    # Oxidized rust / water-stain patches concentrated in low noise + vertical streaks
    if rust_amount > 0.0:
        rust_mask = np.clip((m_lo * 0.65 + m_st * 0.55 - 0.52) * 2.2, 0.0, 1.0) * rust_amount
        rust_col = np.array([78.0, 42.0, 24.0], dtype=np.float32)
        arr = arr * (1.0 - rust_mask[..., None]) + rust_col * rust_mask[..., None]

    # Border ambient-occlusion grime
    if edge_vignette > 0.0:
        yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
        dx = np.abs(xx / w - 0.5) * 2.0
        dy = np.abs(yy / h - 0.5) * 2.0
        edge = np.clip(np.maximum(dx, dy) ** 3.2, 0.0, 1.0) * edge_vignette
        arr *= (1.0 - edge[..., None])

    out = Image.fromarray(np.clip(arr, 0.0, 255.0).astype(np.uint8), mode="RGB")
    if chip_speckles > 0:
        dr = ImageDraw.Draw(out)
        py_rng = random.Random(seed + 77)
        for _ in range(chip_speckles):
            cx = py_rng.randint(12, w - 12)
            cy = py_rng.randint(12, h - 12)
            rx = py_rng.randint(2, 9)
            ry = py_rng.randint(1, 5)
            col = (py_rng.randint(44, 68), py_rng.randint(36, 54), py_rng.randint(28, 44))
            dr.ellipse([cx - rx, cy - ry, cx + rx, cy + ry], fill=col)
    return _add_grain(out, strength=10.5, seed=seed + 31)


def generate_monument_textures_and_bgsms(force: bool = False) -> None:
    os.makedirs(TEX_OUT_DIR, exist_ok=True)
    os.makedirs(MAT_OUT_DIR, exist_ok=True)
    f_big, f_med, f_sm = _load_fonts()

    # 1. CathedralStone_d.dds (TL: Stained-glass Sacred Flame Rose Window; BR: Iron-studded Sanctuary Oak Doors)
    p_cath = os.path.join(TEX_OUT_DIR, "CathedralStone_d.dds")
    if force or not os.path.isfile(p_cath):
        im = Image.new("RGB", (1024, 1024), (42, 34, 38))
        dr = ImageDraw.Draw(im)
        # Top-Left (0..511, 0..511): Sacred Flame Stained-Glass Rose Window (leaded mullion stone ring)
        cx, cy = 256, 256
        for r, col in ((240, (46, 36, 44)), (214, (84, 30, 88)), (178, (124, 38, 102)), (136, (162, 54, 78)), (92, (194, 114, 48)), (50, (224, 178, 86))):
            dr.ellipse([cx - r, cy - r, cx + r, cy + r], fill=col, outline=(24, 20, 26), width=5)
        for k in range(16):
            ang = k * (math.pi / 8.0)
            dr.line([(cx, cy), (cx + 228 * math.cos(ang), cy + 228 * math.sin(ang))], fill=(26, 22, 28), width=6)
        dr.polygon([(cx, cy - 116), (cx + 42, cy - 18), (cx + 24, cy + 68), (cx, cy + 40), (cx - 24, cy + 68), (cx - 42, cy - 18)], fill=(236, 178, 68), outline=(72, 20, 38))
        # Bottom-Right (512..1023, 512..1023): Heavy Oak & Iron-Studded Sanctuary Doors
        dr.rectangle([512, 512, 1023, 1023], fill=(48, 34, 26))
        for x in range(524, 1012, 62):
            dr.rectangle([x, 526, x + 50, 1008], fill=(56, 40, 30), outline=(28, 20, 16), width=4)
            for ry in range(560, 990, 90):
                dr.ellipse([x + 20, ry - 5, x + 30, ry + 5], fill=(92, 82, 68))
        for by in (640, 880):
            dr.rectangle([520, by, 1015, by + 26], fill=(38, 38, 40), outline=(78, 72, 64), width=2)
        _write_bc1_dds_1024(_weather_panel(im, seed=101, rust_amount=0.18, grime_amount=0.35, chip_speckles=160), p_cath)

    # 2. LostHillsConcrete_d.dds (Full 1024x1024 weathered Brotherhood of Steel steel insignia plate)
    p_lh = os.path.join(TEX_OUT_DIR, "LostHillsConcrete_d.dds")
    if force or not os.path.isfile(p_lh):
        im = Image.new("RGB", (1024, 1024), (82, 84, 80))
        dr = ImageDraw.Draw(im)
        dr.rectangle([18, 18, 1005, 1005], fill=(88, 90, 84), outline=(42, 46, 48), width=14)
        for rx in range(48, 990, 96):
            for ry in (44, 978):
                dr.ellipse([rx - 8, ry - 8, rx + 8, ry + 8], fill=(52, 54, 56), outline=(112, 114, 110), width=2)
        cx, cy = 512, 430
        for sgn in (-1, 1):
            for wi in range(5):
                wy0 = cy - 110 + wi * 48
                dr.polygon([
                    (cx + sgn * 64, wy0),
                    (cx + sgn * (330 - wi * 38), wy0 - 28),
                    (cx + sgn * (300 - wi * 38), wy0 + 26),
                    (cx + sgn * 64, wy0 + 34),
                ], fill=(50, 56, 62), outline=(30, 34, 38))
        dr.ellipse([cx - 108, cy - 108, cx + 108, cy + 108], fill=(134, 112, 58), outline=(36, 34, 30), width=6)
        dr.ellipse([cx - 54, cy - 54, cx + 54, cy + 54], fill=(88, 90, 84))
        dr.polygon([(cx - 20, cy - 280), (cx + 20, cy - 280), (cx + 24, cy + 225), (cx, cy + 295), (cx - 24, cy + 225)], fill=(158, 162, 166), outline=(36, 38, 42))
        dr.rectangle([cx - 98, cy - 164, cx + 98, cy - 134], fill=(142, 118, 60), outline=(34, 32, 28), width=3)
        dr.text((190, 825), "LOST HILLS // BUNKER 01", fill=(32, 36, 38), font=f_big)
        dr.text((295, 900), "BROTHERHOOD OF STEEL", fill=(54, 58, 60), font=f_med)
        _write_bc1_dds_1024(_weather_panel(im, seed=102, rust_amount=0.28, grime_amount=0.34, chip_speckles=280), p_lh)

    # 3. MariposaMilitary_d.dds (Full 1024x1024 weathered U.S. Army Mariposa biohazard armor billboard)
    p_mar = os.path.join(TEX_OUT_DIR, "MariposaMilitary_d.dds")
    if force or not os.path.isfile(p_mar):
        im = Image.new("RGB", (1024, 1024), (62, 68, 52))
        dr = ImageDraw.Draw(im)
        # Hazard chevron top & bottom strips
        for y0 in (0, 874):
            dr.rectangle([0, y0, 1023, y0 + 149], fill=(158, 122, 34))
            for off in range(-256, 1280, 96):
                dr.polygon([(off, y0), (off + 48, y0), (off - 72, y0 + 149), (off - 120, y0 + 149)], fill=(30, 30, 28))
        dr.rectangle([28, 175, 995, 848], fill=(60, 66, 50), outline=(146, 140, 108), width=6)
        dr.text((120, 230), "U.S. ARMY", fill=(178, 172, 138), font=f_big)
        dr.text((120, 330), "MARIPOSA MILITARY BASE", fill=(178, 172, 138), font=f_big)
        dr.text((120, 460), "FEV BIO-RESEARCH SECTOR // RESTRICTED", fill=(166, 132, 46), font=f_med)
        dr.text((120, 535), "AUTHORIZED CLEARANCE ONLY", fill=(162, 156, 124), font=f_med)
        dr.rectangle([120, 645, 900, 775], fill=(122, 38, 30), outline=(44, 22, 18), width=4)
        dr.text((225, 690), "LETHAL FORCE AUTHORIZED", fill=(214, 208, 190), font=f_med)
        _write_bc1_dds_1024(_weather_panel(im, seed=103, rust_amount=0.34, grime_amount=0.35, chip_speckles=320), p_mar)

    # 4. GlowCrater_d.dds (Weathered West Tek shaft caution collar fallback)
    p_glow = os.path.join(TEX_OUT_DIR, "GlowCrater_d.dds")
    if force or not os.path.isfile(p_glow):
        im = Image.new("RGB", (1024, 1024), (72, 70, 64))
        dr = ImageDraw.Draw(im)
        dr.rectangle([0, 0, 1023, 180], fill=(142, 114, 38))
        dr.text((110, 62), "WEST TEK RESEARCH // ELEVATOR SHAFT 01", fill=(28, 26, 24), font=f_med)
        _write_bc1_dds_1024(_weather_panel(im, seed=104, rust_amount=0.40, grime_amount=0.42, chip_speckles=360), p_glow)

    # 5. ShadyAdobe_d.dds (Top half: weathered timber Shady Sands gate banner; Bottom-left: Dark shuttered window)
    p_shady = os.path.join(TEX_OUT_DIR, "ShadyAdobe_d.dds")
    if force or not os.path.isfile(p_shady):
        im = Image.new("RGB", (1024, 1024), (76, 52, 34))
        dr = ImageDraw.Draw(im)
        # Top half (0..1023, 0..511): Weathered hand-painted timber lintel sign "SHADY SANDS • FOUNDED 2142"
        dr.rectangle([0, 0, 1023, 511], fill=(82, 54, 34))
        for y in range(18, 505, 42):
            dr.line([(0, y), (1023, y)], fill=(54, 36, 22), width=3)
        dr.rectangle([28, 28, 995, 483], outline=(168, 142, 102), width=6)
        dr.text((245, 130), "SHADY SANDS", fill=(208, 184, 142), font=f_big)
        dr.text((290, 265), "FOUNDED 2142 // VAULT 15", fill=(182, 152, 110), font=f_med)
        # Bottom-Left (0..511, 512..1023): Dark weathered timber shuttered window
        dr.rectangle([0, 512, 511, 1023], fill=(58, 40, 26))
        dr.rectangle([42, 554, 469, 981], fill=(28, 24, 20), outline=(94, 66, 40), width=14)
        dr.line([(256, 554), (256, 981)], fill=(94, 66, 40), width=12)
        dr.line([(42, 768), (469, 768)], fill=(94, 66, 40), width=12)
        _write_bc1_dds_1024(_weather_panel(im, seed=105, rust_amount=0.14, grime_amount=0.38, chip_speckles=220), p_shady)

    # 5B. ShadyPlaque_d.dds (Oxidized desert-patina bronze plaque for Shady Sands Obelisk)
    p_plaque = os.path.join(TEX_OUT_DIR, "ShadyPlaque_d.dds")
    if force or not os.path.isfile(p_plaque):
        im = Image.new("RGB", (1024, 1024), (108, 88, 56))
        dr = ImageDraw.Draw(im)
        dr.rectangle([48, 48, 975, 975], fill=(96, 82, 56), outline=(58, 48, 32), width=16)
        dr.rectangle([82, 82, 941, 941], outline=(146, 126, 84), width=6)
        for bx in (106, 916):
            for by in (106, 916):
                dr.ellipse([bx - 16, by - 16, bx + 16, by + 16], fill=(64, 96, 78), outline=(42, 36, 26), width=3)
        dr.text((215, 210), "SHADY SANDS", fill=(184, 158, 102), font=f_big)
        dr.text((195, 360), "SURVIVORS OF VAULT 15", fill=(164, 142, 92), font=f_med)
        dr.text((315, 470), "FOUNDED  2142", fill=(186, 162, 108), font=f_med)
        dr.line([(180, 575), (844, 575)], fill=(138, 118, 76), width=4)
        dr.text((225, 650), "ARADESH • FIRST ELDER", fill=(156, 138, 90), font=f_med)
        dr.text((205, 760), "G.E.C.K. FERTILITY CHARTER", fill=(138, 124, 82), font=f_sm)
        _write_bc1_dds_1024(_weather_panel(im, seed=109, rust_amount=0.22, grime_amount=0.35, chip_speckles=240), p_plaque)

    # 6. JunktownGate_d.dds (Full 1024x1024 heavily weathered scrap-steel Junktown billboard)
    p_junk = os.path.join(TEX_OUT_DIR, "JunktownGate_d.dds")
    if force or not os.path.isfile(p_junk):
        im = Image.new("RGB", (1024, 1024), (86, 62, 42))
        dr = ImageDraw.Draw(im)
        # Welded scrap steel plank seams & riveted frame
        for y in (256, 512, 768):
            dr.line([(0, y), (1023, y)], fill=(44, 30, 20), width=8)
            dr.line([(0, y + 6), (1023, y + 6)], fill=(116, 88, 62), width=3)
        dr.rectangle([24, 24, 999, 999], outline=(42, 30, 20), width=18)
        for rx in range(56, 980, 92):
            for ry in (52, 970):
                dr.ellipse([rx - 7, ry - 7, rx + 7, ry + 7], fill=(48, 36, 26), outline=(120, 92, 64), width=2)
        dr.text((255, 110), "JUNKTOWN", fill=(208, 184, 128), font=f_big)
        dr.rectangle([110, 275, 910, 395], fill=(118, 36, 28), outline=(44, 22, 16), width=4)
        dr.text((195, 315), "HOLSTER ALL WEAPONS", fill=(214, 198, 162), font=f_med)
        dr.text((155, 485), "DARKWATER'S GENERAL STORE  -->", fill=(196, 184, 152), font=f_med)
        dr.text((160, 600), "<-- GIZMO'S CASINO & SKULZ", fill=(192, 144, 58), font=f_med)
        dr.text((210, 795), "ENFORCED BY CAPT. LARS' GUARD", fill=(38, 28, 20), font=f_sm)
        _write_bc1_dds_1024(_weather_panel(im, seed=106, rust_amount=0.44, grime_amount=0.40, chip_speckles=420), p_junk)

    # 7. HubWaterTower_d.dds (Weathered riveted teal/cream steel cylinder tank for Water Merchants)
    p_hub = os.path.join(TEX_OUT_DIR, "HubWaterTower_d.dds")
    if force or not os.path.isfile(p_hub):
        im = Image.new("RGB", (1024, 1024), (58, 92, 96))
        dr = ImageDraw.Draw(im)
        dr.rectangle([0, 290, 1023, 730], fill=(178, 166, 138))
        for y in (140, 290, 730, 880):
            dr.line([(0, y), (1023, y)], fill=(42, 54, 56), width=6)
            for x in range(16, 1024, 32):
                dr.ellipse([x - 4, y - 10, x + 4, y - 2], fill=(96, 62, 38))
        for x in range(0, 1024, 128):
            dr.line([(x, 0), (x, 1023)], fill=(44, 60, 62), width=4)
        dr.text((78, 375), "THE HUB  •  WATER MERCHANTS", fill=(34, 62, 70), font=f_big)
        dr.text((225, 535), "CARAVAN WATER RESERVE • EST. 2093", fill=(116, 56, 38), font=f_med)
        _write_bc1_dds_1024(_weather_panel(im, seed=107, rust_amount=0.42, grime_amount=0.38, chip_speckles=360), p_hub)

    # 8. MasterThrone_d.dds (Glowing cracked phosphor-green Unity CRT Telemetry Bezel)
    p_mthr = os.path.join(TEX_OUT_DIR, "MasterThrone_d.dds")
    if force or not os.path.isfile(p_mthr):
        im = Image.new("RGB", (1024, 1024), (22, 26, 26))
        dr = ImageDraw.Draw(im)
        for sy0, sy1, hdr, l1, l2 in (
            (48, 480, "UNITY NEURAL CORTEX // ONLINE", "PSYCHIC CORRIDOR: ACTIVE", "VOICE MATRIX: MALE / FEM / AI"),
            (540, 976, "FEV-II VAT TELEMETRY // SYNC", "LA VAULT REACTOR: NOMINAL", "EVOLUTION ENGINE: ARMED"),
        ):
            dr.rectangle([42, sy0, 980, sy1], fill=(14, 44, 22), outline=(66, 78, 72), width=14)
            for ly in range(sy0 + 14, sy1 - 12, 8):
                dr.line([(56, ly), (966, ly)], fill=(20, 60, 28), width=2)
            dr.text((88, sy0 + 48), hdr, fill=(104, 226, 108), font=f_big)
            dr.text((88, sy0 + 168), l1, fill=(82, 198, 88), font=f_med)
            dr.text((88, sy0 + 278), l2, fill=(148, 232, 134), font=f_med)
        _write_bc1_dds_1024(_weather_panel(im, seed=108, rust_amount=0.06, grime_amount=0.22, chip_speckles=90), p_mthr)

    # Write all custom .BGSM materials paired with REAL Fallout 4 vanilla _n.dds & _s.dds maps
    for _mk, (bgsm_stem, dds_stem, normal_rel, spec_rel, env_rel, env_scale, spec_mult, smoothness) in CUSTOM_MONUMENT_MAT_DEFS.items():
        bgsm_path = os.path.join(MAT_OUT_DIR, f"{bgsm_stem}.BGSM")
        bgsm_bytes = build_bgsm_v2_bytes(
            diffuse_path=f"V13Chronicles/Monuments/{dds_stem}_d.dds",
            normal_path=normal_rel,
            specular_path=spec_rel,
            envmap_path=env_rel,
            root_material="template/defaultTemplate_wet.bgsm",
            envmap_scale=env_scale,
            specular_mult=spec_mult,
            smoothness=smoothness,
            enable_envmap=(1 if env_rel else 0),
        )
        with open(bgsm_path, "wb") as wf:
            wf.write(bgsm_bytes)

    # Ensure Cathedral / Master's Lair / Ending Credit Cards DDS+BGSMs exist (never clobbered by loop above)
    from generate_v13_overhaul_assets import generate_all_overhaul_textures_and_bgsms
    need_overhaul = force or not all(
        os.path.isfile(prev_p)
        for _mk, (_b, _d, _n, _s, _e, prev_p, _ab) in OVERHAUL_MAT_DEFS.items()
    )
    if need_overhaul:
        generate_all_overhaul_textures_and_bgsms(lang="ES")


BLENDER_MONUMENTS_SCRIPT = r"""
import json
import math
import os
import sys
from collections import defaultdict
import bpy
import bmesh
from mathutils import Vector

DONOR_NIF = r"__DONOR_NIF__"
OUT_DIR = r"__OUT_DIR__"
TEX_DIR = r"__TEX_DIR__"
MAT_SPECS_PATH = r"__MAT_SPECS_JSON__"
PREVIEW_PNG = r"__PREVIEW_PNG__"
PYNIFLY_DIR = r"__PYNIFLY_DIR__"

with open(MAT_SPECS_PATH, "r", encoding="utf-8") as _mf:
    MAT_SPECS = json.load(_mf)

if PYNIFLY_DIR not in sys.path:
    sys.path.insert(0, PYNIFLY_DIR)


def clear_scene():
    for obj in list(bpy.data.objects):
        bpy.data.objects.remove(obj, do_unlink=True)
    for m in list(bpy.data.meshes):
        bpy.data.meshes.remove(m)
    for mat in list(bpy.data.materials):
        bpy.data.materials.remove(mat)


def enable_pynifly():
    import addon_utils
    for mod in addon_utils.modules():
        if "nifly" in mod.__name__.lower():
            addon_utils.enable(mod.__name__, default_set=True)
            break


def recompute_sharp_or_smooth_normals(mesh_obj, crease_cos: float = 0.65):
    bm = bmesh.new()
    bm.from_mesh(mesh_obj.data)
    bm.verts.ensure_lookup_table()
    bm.faces.ensure_lookup_table()
    bm.normal_update()

    pos_groups = defaultdict(list)
    for v in bm.verts:
        k = (round(v.co.x, 2), round(v.co.y, 2), round(v.co.z, 2))
        pos_groups[k].append(v)

    new_cn = [Vector((0.0, 0.0, 1.0))] * len(mesh_obj.data.loops)
    for f in bm.faces:
        fn = f.normal
        for l in f.loops:
            k = (round(l.vert.co.x, 2), round(l.vert.co.y, 2), round(l.vert.co.z, 2))
            acc = Vector((0.0, 0.0, 0.0))
            for ov in pos_groups[k]:
                for of in ov.link_faces:
                    if fn.dot(of.normal) >= crease_cos:
                        acc += of.normal * max(of.calc_area(), 1e-4)
            new_cn[l.index] = acc.normalized() if acc.length > 1e-6 else fn

    bm.to_mesh(mesh_obj.data)
    mesh_obj.data.update()
    mesh_obj.data.normals_split_custom_set(new_cn)
    bm.free()


class MultiMeshBuilder:
    def __init__(self, single_mesh: bool = False):
        self.single_mesh = single_mesh
        self._parts = {}

    def _get(self, mat_key: str):
        key = "_col" if self.single_mesh else mat_key
        if key not in self._parts:
            bm = bmesh.new()
            uv = bm.loops.layers.uv.new("UVMap")
            self._parts[key] = (bm, uv)
        return self._parts[key]

    @staticmethod
    def uv_tiled(mat_key: str, tile_scale: float = 256.0):
        return (mat_key, float(tile_scale))

    @staticmethod
    def uv_rect(mat_key: str, u0: float = 0.02, v0: float = 0.02, u1: float = 0.98, v1: float = 0.98):
        return (mat_key, float(u0), float(v0), float(u1), float(v1))

    @staticmethod
    def _triplanar_uv(p, n: Vector, tile_scale: float):
        nx, ny, nz = abs(n.x), abs(n.y), abs(n.z)
        if nz >= nx and nz >= ny:
            return (p[0] / tile_scale, p[1] / tile_scale)
        if ny >= nx:
            return (p[0] / tile_scale, p[2] / tile_scale)
        return (p[1] / tile_scale, p[2] / tile_scale)

    def quad(self, p0, p1, p2, p3, uv_spec):
        bm, uv = self._get(uv_spec[0])
        v0 = bm.verts.new(p0)
        v1 = bm.verts.new(p1)
        v2 = bm.verts.new(p2)
        v3 = bm.verts.new(p3)
        f = bm.faces.new((v0, v1, v2, v3))
        if len(uv_spec) == 2:
            ts = uv_spec[1]
            e1 = Vector(p1) - Vector(p0)
            e2 = Vector(p3) - Vector(p0)
            n = e1.cross(e2)
            for lp, pt in zip(f.loops, (p0, p1, p2, p3)):
                lp[uv].uv = self._triplanar_uv(pt, n, ts)
        else:
            _, u0, t0, u1, t1 = uv_spec
            f.loops[0][uv].uv = (u0, t0)
            f.loops[1][uv].uv = (u1, t0)
            f.loops[2][uv].uv = (u1, t1)
            f.loops[3][uv].uv = (u0, t1)
        return f

    def tri_uv(self, p0, p1, p2, uv_spec, uv0, uv1, uv2):
        bm, uv = self._get(uv_spec[0])
        f = bm.faces.new((bm.verts.new(p0), bm.verts.new(p1), bm.verts.new(p2)))
        f.loops[0][uv].uv = uv0
        f.loops[1][uv].uv = uv1
        f.loops[2][uv].uv = uv2
        return f

    def poly_world(self, pts, uv_spec):
        bm, uv = self._get(uv_spec[0])
        verts = [bm.verts.new(p) for p in pts]
        f = bm.faces.new(verts)
        if len(uv_spec) == 2:
            ts = uv_spec[1]
            n = (Vector(pts[1]) - Vector(pts[0])).cross(Vector(pts[2]) - Vector(pts[0]))
            for lp, pt in zip(f.loops, pts):
                lp[uv].uv = self._triplanar_uv(pt, n, ts)
        else:
            _, u0, t0, u1, t1 = uv_spec
            cu, cv = 0.5 * (u0 + u1), 0.5 * (t0 + t1)
            for lp in f.loops:
                lp[uv].uv = (cu, cv)
        return f

    def box(self, x0, x1, y0, y1, z0, z1, uv_sides, uv_top=None, uv_front=None, skip_bottom=False):
        ut = uv_top or uv_sides
        uf = uv_front or uv_sides
        # Front (-Y)
        self.quad((x0, y0, z0), (x1, y0, z0), (x1, y0, z1), (x0, y0, z1), uf)
        # Back (+Y)
        self.quad((x1, y1, z0), (x0, y1, z0), (x0, y1, z1), (x1, y1, z1), uv_sides)
        # Left (-X)
        self.quad((x0, y1, z0), (x0, y0, z0), (x0, y0, z1), (x0, y1, z1), uv_sides)
        # Right (+X)
        self.quad((x1, y0, z0), (x1, y1, z0), (x1, y1, z1), (x1, y0, z1), uv_sides)
        # Top (+Z)
        self.quad((x0, y0, z1), (x1, y0, z1), (x1, y1, z1), (x0, y1, z1), ut)
        if not skip_bottom:
            self.quad((x0, y1, z0), (x1, y1, z0), (x1, y0, z0), (x0, y0, z0), ut)

    def frustum(self, bx0, bx1, by0, by1, tx0, tx1, ty0, ty1, z0, z1, uv_sides, uv_top=None, uv_front=None):
        ut = uv_top or uv_sides
        uf = uv_front or uv_sides
        self.quad((bx0, by0, z0), (bx1, by0, z0), (tx1, ty0, z1), (tx0, ty0, z1), uf)
        self.quad((bx1, by1, z0), (bx0, by1, z0), (tx0, ty1, z1), (tx1, ty1, z1), uv_sides)
        self.quad((bx0, by1, z0), (bx0, by0, z0), (tx0, ty0, z1), (tx0, ty1, z1), uv_sides)
        self.quad((bx1, by0, z0), (bx1, by1, z0), (tx1, ty1, z1), (tx1, ty0, z1), uv_sides)
        self.quad((tx0, ty0, z1), (tx1, ty0, z1), (tx1, ty1, z1), (tx0, ty1, z1), ut)
        self.quad((bx0, by1, z0), (bx1, by1, z0), (bx1, by0, z0), (bx0, by0, z0), ut)

    def cylinder(self, cx, cy, z0, z1, r0, r1, sides, uv_side, uv_cap=None, rot_x=False):
        uc = uv_cap or uv_side
        bm_s, uv_s = self._get(uv_side[0])
        ring0, ring1 = [], []
        for i in range(sides):
            a = (2.0 * math.pi * i) / sides
            ca, sa = math.cos(a), math.sin(a)
            if rot_x:
                ring0.append(bm_s.verts.new((cx, z0 + r0 * ca, z1 + r0 * sa)))
                ring1.append(bm_s.verts.new((cy, z0 + r1 * ca, z1 + r1 * sa)))
            else:
                ring0.append(bm_s.verts.new((cx + r0 * ca, cy + r0 * sa, z0)))
                ring1.append(bm_s.verts.new((cx + r1 * ca, cy + r1 * sa, z1)))

        if len(uv_side) == 2:
            ts = uv_side[1]
            circ = 2.0 * math.pi * max(0.5 * (r0 + r1), 1.0)
            u_tiles = max(round(circ / ts), 1.0)
            v_span = abs((cy - cx) if rot_x else (z1 - z0)) / ts
            u0, t0, u1, t1 = 0.0, 0.0, u_tiles, v_span
        else:
            _, u0, t0, u1, t1 = uv_side

        for i in range(sides):
            ni = (i + 1) % sides
            ua = u0 + (u1 - u0) * (i / sides)
            ub = u0 + (u1 - u0) * ((i + 1) / sides)
            f = bm_s.faces.new((ring0[i], ring0[ni], ring1[ni], ring1[i]))
            f.loops[0][uv_s].uv = (ua, t0)
            f.loops[1][uv_s].uv = (ub, t0)
            f.loops[2][uv_s].uv = (ub, t1)
            f.loops[3][uv_s].uv = (ua, t1)

        # Caps can live on a different material (e.g. corrugated roof vs concrete footing vs riveted tank)!
        pts0 = [(cx, z0 + r0 * math.cos(2.0 * math.pi * i / sides), z1 + r0 * math.sin(2.0 * math.pi * i / sides)) if rot_x
                else (cx + r0 * math.cos(2.0 * math.pi * i / sides), cy + r0 * math.sin(2.0 * math.pi * i / sides), z0)
                for i in range(sides)]
        pts1 = [(cy, z0 + r1 * math.cos(2.0 * math.pi * i / sides), z1 + r1 * math.sin(2.0 * math.pi * i / sides)) if rot_x
                else (cx + r1 * math.cos(2.0 * math.pi * i / sides), cy + r1 * math.sin(2.0 * math.pi * i / sides), z1)
                for i in range(sides)]
        c0 = (cx, z0, z1) if rot_x else (cx, cy, z0)
        c1 = (cy, z0, z1) if rot_x else (cx, cy, z1)

        bm_c, uv_c = self._get(uc[0])
        vc0 = bm_c.verts.new(c0)
        vc1 = bm_c.verts.new(c1)
        cr0 = [bm_c.verts.new(p) for p in pts0]
        cr1 = [bm_c.verts.new(p) for p in pts1]
        for i in range(sides):
            ni = (i + 1) % sides
            ft = bm_c.faces.new((vc1, cr1[i], cr1[ni]))
            fb = bm_c.faces.new((vc0, cr0[ni], cr0[i]))
            if len(uc) == 2:
                ts_c = uc[1]
                nt = (Vector(pts1[i]) - Vector(c1)).cross(Vector(pts1[ni]) - Vector(c1))
                nb = (Vector(pts0[ni]) - Vector(c0)).cross(Vector(pts0[i]) - Vector(c0))
                for lp, pt in zip(ft.loops, (c1, pts1[i], pts1[ni])):
                    lp[uv_c].uv = self._triplanar_uv(pt, nt, ts_c)
                for lp, pt in zip(fb.loops, (c0, pts0[ni], pts0[i])):
                    lp[uv_c].uv = self._triplanar_uv(pt, nb, ts_c)
            else:
                _, cu0, ct0, cu1, ct1 = uc
                cu = 0.5 * (cu0 + cu1)
                cv = 0.5 * (ct0 + ct1)
                ru = 0.45 * (cu1 - cu0)
                rv = 0.45 * (ct1 - ct0)
                a0 = (2.0 * math.pi * i) / sides
                a1 = (2.0 * math.pi * ni) / sides
                ft.loops[0][uv_c].uv = (cu, cv)
                ft.loops[1][uv_c].uv = (cu + ru * math.cos(a0), cv + rv * math.sin(a0))
                ft.loops[2][uv_c].uv = (cu + ru * math.cos(a1), cv + rv * math.sin(a1))
                fb.loops[0][uv_c].uv = (cu, cv)
                fb.loops[1][uv_c].uv = (cu + ru * math.cos(a1), cv + rv * math.sin(a1))
                fb.loops[2][uv_c].uv = (cu + ru * math.cos(a0), cv + rv * math.sin(a0))

    def part_keys(self):
        return list(self._parts.keys())

    def finish_part_to_mesh(self, mat_key: str, mesh_obj, compute_normals: bool = True):
        bm, _uv = self._parts.pop(mat_key)
        bmesh.ops.triangulate(bm, faces=list(bm.faces))
        bm.to_mesh(mesh_obj.data)
        bm.free()
        mesh_obj.data.update()
        if compute_normals:
            recompute_sharp_or_smooth_normals(mesh_obj)

    def free_all(self):
        for bm, _uv in self._parts.values():
            bm.free()
        self._parts.clear()


def build_cathedral(vis: MultiMeshBuilder, col: MultiMeshBuilder):
    UV_STONE = MultiMeshBuilder.uv_tiled("church_stone", 320.0)
    UV_FLUTE = MultiMeshBuilder.uv_tiled("concrete02", 220.0)
    UV_STEPS = MultiMeshBuilder.uv_tiled("concrete01", 256.0)
    UV_ROOF  = MultiMeshBuilder.uv_tiled("roof_slate", 220.0)
    UV_ROSE  = MultiMeshBuilder.uv_rect("custom_cathedral", 0.02, 0.50, 0.48, 0.98)
    UV_DOOR  = MultiMeshBuilder.uv_rect("custom_cathedral", 0.51, 0.01, 0.99, 0.49)

    vis.box(-860, -220, -340, 60, -8, 18, UV_STEPS)
    vis.box( 220,  860, -340, 60, -8, 18, UV_STEPS)
    col.box(-860, -220, -340, 60, -8, 18, UV_STEPS)
    col.box( 220,  860, -340, 60, -8, 18, UV_STEPS)

    vis.box(-480, 480, 48, 1240, -8, 1120, UV_STONE)
    col.box(-480, 480, 48, 1240, -8, 1120, UV_STONE)
    for sgn in (-1, 1):
        for step_i in range(3):
            x_in = 112 + step_i * 38
            x_out = x_in + 42
            y0 = -76 + step_i * 22
            x0, x1 = (-x_out, -x_in) if sgn < 0 else (x_in, x_out)
            vis.box(x0, x1, y0, 56, -8, 320 - step_i * 18, UV_FLUTE)
        cx0, cx1 = (-250, -110) if sgn < 0 else (110, 250)
        col.box(cx0, cx1, -76, 56, -8, 320, UV_FLUTE)
    vis.frustum(-250, 250, -78, 56, -90, 90, -54, 56, 252, 460, UV_FLUTE, uv_front=UV_DOOR)
    col.box(-250, 250, -78, 56, 252, 460, UV_FLUTE)

    vis.frustum(-500, 500, 36, 1255, -24, 24, 36, 1255, 1120, 1480, UV_ROOF)
    col.frustum(-500, 500, 36, 1255, -24, 24, 36, 1255, 1120, 1480, UV_ROOF)

    r_outer, r_glass = 215.0, 185.0
    n_seg = 20
    cu = 0.5 * (UV_ROSE[1] + UV_ROSE[3])
    cv = 0.5 * (UV_ROSE[2] + UV_ROSE[4])
    ru = 0.47 * (UV_ROSE[3] - UV_ROSE[1])
    rv = 0.47 * (UV_ROSE[4] - UV_ROSE[2])
    for i in range(n_seg):
        a0 = (2.0 * math.pi * i) / n_seg
        a1 = (2.0 * math.pi * (i + 1)) / n_seg
        x0o, z0o = r_outer * math.cos(a0), 760.0 + r_outer * math.sin(a0)
        x1o, z1o = r_outer * math.cos(a1), 760.0 + r_outer * math.sin(a1)
        x0i, z0i = r_glass * math.cos(a0), 760.0 + r_glass * math.sin(a0)
        x1i, z1i = r_glass * math.cos(a1), 760.0 + r_glass * math.sin(a1)
        vis.quad((x0o, 18.0, z0o), (x1o, 18.0, z1o), (x1i, 26.0, z1i), (x0i, 26.0, z0i), UV_FLUTE)
        vis.quad((x0o, 48.0, z0o), (x1o, 48.0, z1o), (x1o, 18.0, z1o), (x0o, 18.0, z0o), UV_FLUTE)
        vis.tri_uv(
            (0.0, 30.0, 760.0), (x1i, 30.0, z1i), (x0i, 30.0, z0i),
            UV_ROSE,
            (cu, cv),
            (cu + ru * math.cos(a1), cv + rv * math.sin(a1)),
            (cu + ru * math.cos(a0), cv + rv * math.sin(a0)),
        )

    for sgn, top_z in ((-1, 1920.0), (1, 1580.0)):
        tcx = sgn * 660.0
        vis.box(tcx - 210, tcx + 210, -140, 280, -8, 1180, UV_STONE, uv_front=UV_FLUTE)
        col.box(tcx - 210, tcx + 210, -140, 280, -8, 1180, UV_STONE)
        vis.cylinder(tcx, 70.0, 1180.0, 1460.0, 185.0, 165.0, 8, UV_FLUTE, uv_cap=UV_ROOF)
        col.box(tcx - 165, tcx + 165, -95, 235, 1180, 1460, UV_FLUTE)
        r_top = 18.0 if sgn < 0 else 95.0
        vis.cylinder(tcx, 70.0, 1460.0, top_z, 160.0, r_top, 8, UV_ROOF, uv_cap=UV_STONE)

    for by in (380.0, 620.0, 860.0, 1100.0):
        for sgn in (-1, 1):
            px0 = sgn * 580.0
            px1 = sgn * 740.0
            bx0, bx1 = (min(px0, px1), max(px0, px1))
            vis.box(bx0, bx1, by - 46, by + 46, -8, 780, UV_STONE)
            col.box(bx0, bx1, by - 46, by + 46, -8, 780, UV_STONE)
            ix0, ix1 = (sgn * 470.0, sgn * 590.0)
            vis.frustum(min(ix0, ix1), max(ix0, ix1), by - 36, by + 36,
                        min(sgn * 470.0, sgn * 490.0), max(sgn * 470.0, sgn * 490.0), by - 36, by + 36,
                        700.0, 980.0, UV_FLUTE)


def build_cathedral_ruins(vis: MultiMeshBuilder, col: MultiMeshBuilder):
    '''Post-detonation shattered Gothic Cathedral ruins on the exact V13CathedralMonument footprint.'''
    UV_STONE = MultiMeshBuilder.uv_tiled("church_stone", 320.0)
    UV_FLUTE = MultiMeshBuilder.uv_tiled("concrete02", 220.0)
    UV_STEPS = MultiMeshBuilder.uv_tiled("concrete01", 256.0)
    UV_ROOF  = MultiMeshBuilder.uv_tiled("roof_slate", 220.0)
    UV_STEEL = MultiMeshBuilder.uv_tiled("assorted_rust", 160.0)
    UV_CRAT  = MultiMeshBuilder.uv_tiled("corrosion", 340.0)
    UV_ASH   = MultiMeshBuilder.uv_tiled("cracked_mud", 380.0)

    # 1. Fractured front stone courtyard steps
    vis.box(-860, -230, -340, 60, -8, 16, UV_STEPS)
    vis.box( 230,  860, -340, 60, -8, 14, UV_STEPS)
    col.box(-860, -230, -340, 60, -8, 16, UV_STEPS)
    col.box( 230,  860, -340, 60, -8, 14, UV_STEPS)

    # 2. Scorched mud skirt and vitrified atomic crater rim across gutted nave floor
    vis.box(-520, 520, 20, 1270, -8, 18, UV_ASH)
    col.box(-520, 520, 20, 1270, -8, 18, UV_ASH)
    n_c = 24
    c_radii = [95.0, 210.0, 340.0, 445.0]
    c_heights = [14.0, 24.0, 62.0, 18.0]
    cy_mid = 640.0
    for B, step_n in ((vis, n_c), (col, 12)):
        rings = []
        for ri, rr in enumerate(c_radii):
            ring = []
            for ai in range(step_n):
                ang = (2.0 * math.pi * ai) / step_n
                jag = (10.0 * math.sin(4.0 * ang + ri) + 6.0 * math.cos(7.0 * ang)) if ri >= 1 else 0.0
                ring.append((rr * math.cos(ang), cy_mid + 1.18 * rr * math.sin(ang), c_heights[ri] + jag))
            rings.append(ring)
        for ri in range(len(c_radii) - 1):
            uv_r = UV_ASH if ri == len(c_radii) - 2 else UV_CRAT
            for ai in range(step_n):
                nai = (ai + 1) % step_n
                B.quad(rings[ri][ai], rings[ri + 1][ai], rings[ri + 1][nai], rings[ri][nai], uv_r)
        B.poly_world(rings[0], UV_CRAT)

    # 3. Blasted portal jamb piers & V-breached front nave wall (Rose Window blown apart)
    for sgn, pier_h in ((-1, 295.0), (1, 225.0)):
        for si in range(3):
            x_in = 112 + si * 38
            x_out = x_in + 42
            y0 = -76 + si * 22
            x0, x1 = (-x_out, -x_in) if sgn < 0 else (x_in, x_out)
            h_s = max(95.0, pier_h - si * 34.0)
            vis.box(x0, x1, y0, 56, -8, h_s, UV_FLUTE)
        cx0, cx1 = (-250, -110) if sgn < 0 else (110, 250)
        col.box(cx0, cx1, -76, 56, -8, pier_h, UV_FLUTE)

    # Left & Right front facade jagged flanks leaving huge open breach through the nave
    facade_segs = [
        (-480, -340, 48, 124, 645, UV_STONE),
        (-340, -210, 48, 118, 495, UV_STONE),
        (-210, -105, 48, 114, 345, UV_FLUTE),
        ( 120,  225, 48, 114, 290, UV_FLUTE),
        ( 225,  355, 48, 118, 420, UV_STONE),
        ( 355,  480, 48, 124, 530, UV_STONE),
    ]
    for fx0, fx1, fy0, fy1, fz1, fuv in facade_segs:
        vis.frustum(fx0, fx1, fy0, fy1, fx0 + 18, fx1 - 18, fy0 + 6, fy1 - 6, -8, fz1, fuv)
        col.box(fx0, fx1, fy0, fy1, -8, fz1, fuv)

    # Remnant lower arc segments of the broken stained-glass ring & twisted tracery
    for k in range(5):
        a0 = math.radians(198.0 + k * 28.0)
        ox = 185.0 * math.cos(a0)
        oz = 610.0 + 140.0 * math.sin(a0)
        if abs(ox) > 95.0 and oz > 310.0:
            vis.frustum(ox - 24, ox + 24, 30, 74, ox - 14, ox + 14, 42, 68, oz - 28, oz + 36, UV_FLUTE)

    # 4. Shattered Twin-Spire Stumps at (-660, 70) and (+660, 70) with protruding bent I-beams
    spire_specs = [
        (-660.0, [585.0, 695.0, 520.0, 630.0], [790.0, 865.0, 745.0, 810.0]),
        ( 660.0, [410.0, 495.0, 540.0, 365.0], [615.0, 675.0, 640.0, 560.0]),
    ]
    for tcx, corner_hs, beam_hs in spire_specs:
        # Solid lower tower plinth
        vis.box(tcx - 210, tcx + 210, -140, 280, -8, 340, UV_STONE, uv_front=UV_FLUTE)
        col.box(tcx - 210, tcx + 210, -140, 280, -8, 340, UV_STONE)
        # Inner scorched rubble fill inside broken tower shaft
        vis.frustum(tcx - 165, tcx + 165, -95, 235, tcx - 110, tcx + 110, -35, 175, 330, 415, UV_ASH)
        # 4 Jagged corner stone tower piers
        corners = [
            (tcx - 210, tcx - 65, -140, 45),
            (tcx + 65, tcx + 210, -140, 45),
            (tcx - 210, tcx - 65, 95, 280),
            (tcx + 65, tcx + 210, 95, 280),
        ]
        for (cx0, cx1, cy0, cy1), ch, bh in zip(corners, corner_hs, beam_hs):
            vis.frustum(cx0, cx1, cy0, cy1, cx0 + 22, cx1 - 22, cy0 + 22, cy1 - 22, 340, ch, UV_STONE)
            col.box(cx0, cx1, cy0, cy1, 340, ch, UV_STONE)
            # Bent rusted steel reinforcement I-beams erupting from shattered spire top
            mx, my = 0.5 * (cx0 + cx1), 0.5 * (cy0 + cy1)
            lean_x = -26.0 if mx < tcx else 26.0
            lean_y = -18.0 if my < 70.0 else 18.0
            vis.frustum(mx - 14, mx + 14, my - 14, my + 14, mx + lean_x - 8, mx + lean_x + 8, my + lean_y - 8, my + lean_y + 8, ch - 20.0, bh, UV_STEEL)

    # Toppled slate steeple crown fallen beside the East tower
    vis.frustum(745, 1020, -240, 45, 815, 960, -195, -5, -8, 175, UV_ROOF, uv_front=UV_STONE)
    col.box(745, 1020, -240, 45, -8, 175, UV_ROOF)

    # 5. Jagged collapsed side nave walls (left & right bays blown open mid-nave)
    side_bays = [
        ( 120.0, 360.0, 495.0, 440.0),
        ( 360.0, 620.0, 260.0, 210.0),
        ( 620.0, 890.0, 145.0, 120.0),
        ( 890.0, 1240.0, 390.0, 470.0),
    ]
    for y0, y1, h_w, h_e in side_bays:
        for sgn, bh in ((-1, h_w), (1, h_e)):
            wx0, wx1 = (-480, -405) if sgn < 0 else (405, 480)
            vis.frustum(wx0, wx1, y0, y1, wx0 + 12, wx1 - 12, y0 + 18, y1 - 18, -8, bh, UV_STONE)
            col.box(wx0, wx1, y0, y1, -8, bh, UV_STONE)

    # Dangling charred roof rafters canted inward on surviving rear & front wall tops
    for ry, rx_sgn, top_h in ((210.0, -1, 475.0), (240.0, 1, 420.0), (1050.0, -1, 380.0), (1120.0, 1, 455.0)):
        bx0, bx1 = (-440, -370) if rx_sgn < 0 else (370, 440)
        tx0, tx1 = (-195, -145) if rx_sgn < 0 else (145, 195)
        vis.frustum(bx0, bx1, ry - 20, ry + 20, tx0, tx1, ry - 14, ry + 14, top_h, top_h - 145.0, UV_STEEL)

    # 6. Broken back apse wall (open V-gap facing North)
    for ax0, ax1, ah in ((-480, -165, 535), (165, 480, 465)):
        vis.frustum(ax0, ax1, 1160, 1245, ax0 + 20, ax1 - 20, 1168, 1235, -8, ah, UV_STONE)
        col.box(ax0, ax1, 1160, 1245, -8, ah, UV_STONE)

    # 7. Snapped flying buttress stumps (by = 380, 620, 860, 1100)
    for bi, by in enumerate((380.0, 620.0, 860.0, 1100.0)):
        for sgn in (-1, 1):
            px0 = sgn * 580.0
            px1 = sgn * 740.0
            bx0, bx1 = (min(px0, px1), max(px0, px1))
            bh = 250.0 + ((bi + (0 if sgn < 0 else 1)) % 3) * 95.0
            vis.frustum(bx0, bx1, by - 46, by + 46, bx0 + 18, bx1 - 18, by - 36, by + 36, -8, bh, UV_STONE)
            col.box(bx0, bx1, by - 46, by + 46, -8, bh, UV_STONE)
            if bh > 320.0:
                vis.frustum(bx0 + 35, bx1 - 35, by - 14, by + 14, sgn * 510.0 - 10, sgn * 510.0 + 10, by - 10, by + 10, bh - 30, bh + 85, UV_STEEL)

    # 8. Heavy fallen masonry chunks & blasted concrete blocks around portal and nave wings
    debris_chunks = [
        (-420, -240, -290, -130, -8, 68, UV_STONE),
        ( 260,  460, -270, -110, -8, 54, UV_FLUTE),
        (-360, -230,  220,  390, 14, 96, UV_STONE),
        ( 240,  370,  460,  620, 14, 88, UV_ROOF),
        (-280, -140,  890, 1060, 14, 102, UV_STONE),
        ( 160,  310,  940, 1110, 14, 92, UV_FLUTE),
    ]
    for dx0, dx1, dy0, dy1, dz0, dz1, duv in debris_chunks:
        vis.frustum(dx0, dx1, dy0, dy1, dx0 + 24, dx1 - 24, dy0 + 24, dy1 - 24, dz0, dz1, duv)
        col.box(dx0, dx1, dy0, dy1, dz0, dz1, duv)


def build_lost_hills_bunker(vis: MultiMeshBuilder, col: MultiMeshBuilder):
    UV_CONC  = MultiMeshBuilder.uv_tiled("bunker_conc1", 256.0)
    UV_CONC2 = MultiMeshBuilder.uv_tiled("bunker_conc2", 256.0)
    UV_STEEL = MultiMeshBuilder.uv_tiled("assorted_rust", 180.0)
    UV_BOS   = MultiMeshBuilder.uv_rect("custom_losthills", 0.02, 0.02, 0.98, 0.98)

    for sgn in (-1, 1):
        bx0, bx1 = (-640, -115) if sgn < 0 else (115, 640)
        tx0, tx1 = (-490, -115) if sgn < 0 else (115, 490)
        vis.frustum(bx0, bx1, -80, 860, tx0, tx1, 60, 760, -8, 380, UV_CONC, uv_top=UV_CONC2, uv_front=UV_CONC2)
        col.frustum(bx0, bx1, -80, 860, tx0, tx1, 60, 760, -8, 380, UV_CONC)
        cx0, cx1 = (-480, -240) if sgn < 0 else (240, 480)
        vis.box(cx0, cx1, -95, 60, 110, 230, UV_STEEL)
        col.box(cx0, cx1, -95, 60, 110, 230, UV_STEEL)

    vis.frustum(-125, 125, 48, 860, -125, 125, 60, 760, -8, 380, UV_CONC)
    col.box(-125, 125, 48, 860, -8, 380, UV_CONC)

    vis.box(-230, 230, -155, 65, 246, 365, UV_CONC2, uv_front=UV_BOS)
    col.box(-230, 230, -155, 65, 246, 365, UV_CONC2)
    vis.cylinder(0.0, 420.0, 380.0, 475.0, 155.0, 125.0, 8, UV_STEEL, uv_cap=UV_CONC)
    col.box(-150, 150, 270, 570, 380, 475, UV_STEEL)


def build_mariposa_bunker(vis: MultiMeshBuilder, col: MultiMeshBuilder):
    UV_CONC   = MultiMeshBuilder.uv_tiled("bunker_conc2", 280.0)
    UV_ARMOR  = MultiMeshBuilder.uv_tiled("assorted_rust", 220.0)
    UV_HAZARD = MultiMeshBuilder.uv_rect("custom_mariposa", 0.02, 0.86, 0.98, 0.99)
    UV_SIGN   = MultiMeshBuilder.uv_rect("custom_mariposa", 0.02, 0.02, 0.98, 0.98)

    for sgn in (-1, 1):
        bx0, bx1 = (-860, -125) if sgn < 0 else (125, 860)
        tx0, tx1 = (-720, -125) if sgn < 0 else (125, 720)
        vis.frustum(bx0, bx1, -90, 940, tx0, tx1, 40, 840, -8, 540, UV_CONC, uv_front=UV_ARMOR)
        col.frustum(bx0, bx1, -90, 940, tx0, tx1, 40, 840, -8, 540, UV_CONC)
        hx0, hx1 = (-235, -120) if sgn < 0 else (120, 235)
        vis.frustum(hx0, hx1, -185, 50, hx0, hx1, -90, 50, -8, 340, UV_HAZARD)
        col.box(hx0, hx1, -185, 50, -8, 340, UV_HAZARD)
        px0, px1 = (-680, -380) if sgn < 0 else (380, 680)
        vis.box(px0, px1, -135, 90, 250, 420, UV_ARMOR)
        col.box(px0, px1, -135, 90, 250, 420, UV_ARMOR)

    vis.box(-130, 130, 48, 940, -8, 540, UV_CONC)
    col.box(-130, 130, 48, 940, -8, 540, UV_CONC)
    vis.box(-235, 235, -165, 55, 248, 340, UV_HAZARD)
    vis.box(-280, 280, -130, 60, 340, 520, UV_ARMOR, uv_front=UV_SIGN)
    col.box(-280, 280, -165, 60, 248, 520, UV_ARMOR)


def build_glow_crater(vis: MultiMeshBuilder, col: MultiMeshBuilder):
    UV_GLASS  = MultiMeshBuilder.uv_tiled("corrosion", 360.0)
    UV_SAND   = MultiMeshBuilder.uv_tiled("cracked_mud", 420.0)
    UV_IBEAM  = MultiMeshBuilder.uv_tiled("assorted_rust", 180.0)
    UV_SHAFT  = MultiMeshBuilder.uv_tiled("concrete02", 180.0)
    UV_WARN   = MultiMeshBuilder.uv_rect("custom_glow", 0.02, 0.83, 0.98, 0.99)

    n_ang = 36
    radii = [180.0, 260.0, 440.0, 640.0, 780.0, 960.0, 1160.0, 1360.0]
    heights = [18.0,   6.0,  10.0,  58.0, 126.0,  82.0,  22.0,  -8.0]

    for Builder, ang_step in ((vis, n_ang), (col, 18)):
        pts_rings = []
        for ri, r in enumerate(radii):
            ring = []
            for ai in range(ang_step):
                a = (2.0 * math.pi * ai) / ang_step
                jag = (14.0 * math.sin(5.0 * a + ri) + 8.0 * math.cos(9.0 * a)) if 2 <= ri <= 5 else 0.0
                ring.append((r * math.cos(a), r * math.sin(a), heights[ri] + jag))
            pts_rings.append(ring)
        for ri in range(len(radii) - 1):
            uvr = UV_SAND if ri >= 5 else UV_GLASS
            for ai in range(ang_step):
                nai = (ai + 1) % ang_step
                Builder.quad(pts_rings[ri][ai], pts_rings[ri + 1][ai], pts_rings[ri + 1][nai], pts_rings[ri][nai], uvr)
        Builder.poly_world(pts_rings[0], UV_SHAFT)

    for k in range(10):
        a0 = math.radians(-55.0 + k * 29.0)
        a1 = math.radians(-55.0 + (k + 0.85) * 29.0)
        cx = 220.0 * math.cos(0.5 * (a0 + a1))
        cy = 220.0 * math.sin(0.5 * (a0 + a1))
        vis.box(cx - 34, cx + 34, cy - 34, cy + 34, 2.0, 64.0 + (k % 3) * 14.0, UV_SHAFT)
        col.box(cx - 34, cx + 34, cy - 34, cy + 34, 2.0, 68.0, UV_SHAFT)

    beam_angles = [0.35, 1.15, 2.05, 2.95, 3.85, 5.15]
    for bi, ba in enumerate(beam_angles):
        bx = 560.0 * math.cos(ba)
        by = 560.0 * math.sin(ba)
        tx = 360.0 * math.cos(ba + 0.08)
        ty = 360.0 * math.sin(ba + 0.08)
        top_z = 185.0 + (bi % 3) * 42.0
        vis.frustum(bx - 22, bx + 22, by - 22, by + 22, tx - 16, tx + 16, ty - 16, ty + 16, 12.0, top_z, UV_IBEAM)
        col.frustum(bx - 22, bx + 22, by - 22, by + 22, tx - 16, tx + 16, ty - 16, ty + 16, 12.0, top_z, UV_IBEAM)
    vis.box(-26, 26, -420, 95, 148, 178, UV_IBEAM, uv_front=UV_WARN)
    vis.box(-34, 34, -430, -370, 6.0, 152, UV_IBEAM, uv_front=UV_WARN)
    col.box(-26, 26, -420, 95, 148, 178, UV_IBEAM)
    col.box(-34, 34, -430, -370, 6.0, 152, UV_IBEAM)


def build_shady_gate_arch(vis: MultiMeshBuilder, col: MultiMeshBuilder):
    UV_ADOBE = MultiMeshBuilder.uv_tiled("adobe_plaster", 260.0)
    UV_WOOD  = MultiMeshBuilder.uv_tiled("plywood", 160.0)
    UV_SIGN  = MultiMeshBuilder.uv_rect("custom_shady_adobe", 0.02, 0.51, 0.98, 0.98)

    for sgn in (-1, 1):
        bx0, bx1 = (-540, -210) if sgn < 0 else (210, 540)
        tx0, tx1 = (-495, -215) if sgn < 0 else (215, 495)
        vis.frustum(bx0, bx1, -135, 135, tx0, tx1, -110, 110, -8, 430, UV_ADOBE)
        col.frustum(bx0, bx1, -135, 135, tx0, tx1, -110, 110, -8, 430, UV_ADOBE)
        vis.box(tx0 + 18, tx1 - 18, -108, 108, 430, 468, UV_ADOBE)

    vis.box(-225, 225, -105, 105, 315, 415, UV_ADOBE)
    vis.box(-215, 215, -116, -98, 326, 398, UV_SIGN)
    vis.box(-215, 215,  98, 116, 326, 398, UV_SIGN)
    col.box(-225, 225, -105, 105, 315, 415, UV_ADOBE)
    for vx in range(-450, 451, 90):
        vis.box(vx - 9, vx + 9, -142, 142, 380, 398, UV_WOOD)


def build_shady_adobe_hall(vis: MultiMeshBuilder, col: MultiMeshBuilder):
    UV_ADOBE  = MultiMeshBuilder.uv_tiled("adobe_plaster", 260.0)
    UV_WOOD   = MultiMeshBuilder.uv_tiled("plywood", 160.0)
    UV_WIN    = MultiMeshBuilder.uv_rect("custom_shady_adobe", 0.02, 0.02, 0.48, 0.48)
    UV_AWNING = MultiMeshBuilder.uv_tiled("tarpaper", 160.0)
    UV_FLOOR  = MultiMeshBuilder.uv_tiled("concrete01", 220.0)

    vis.box(-520, 520, -380, 380, -8, 3, UV_FLOOR)
    col.box(-520, 520, -380, 380, -8, 3, UV_FLOOR)
    for (x0, x1, y0, y1) in (
        (-520,  520,  334,  380),
        (-520, -474, -380,  380),
        ( 474,  520, -380,  380),
        (-520, -105, -380, -334),
        ( 105,  520, -380, -334),
    ):
        vis.frustum(x0, x1, y0, y1, x0 + 6, x1 - 6, y0 + 4, y1 - 4, 3, 340, UV_ADOBE)
        col.box(x0, x1, y0, y1, 3, 340, UV_ADOBE)
    vis.box(-110, 110, -380, -334, 236, 340, UV_ADOBE)
    vis.box(-126, 126, -388, -328, 224, 240, UV_WOOD)
    col.box(-110, 110, -380, -334, 236, 340, UV_ADOBE)
    for wx in (-310.0, 310.0):
        vis.box(wx - 68, wx + 68, -386, -330, 96, 212, UV_WIN)
    vis.box(-514, 514, -374, 374, 304, 336, UV_ADOBE)
    col.box(-514, 514, -374, 374, 304, 336, UV_ADOBE)
    for vx in range(-440, 441, 88):
        vis.box(vx - 8, vx + 8, -408, 408, 286, 302, UV_WOOD)
    vis.frustum(-380, 380, -540, -375, -380, 380, -540, -375, 224, 236, UV_AWNING)
    for px in (-360.0, 360.0):
        vis.box(px - 10, px + 10, -532, -512, -4, 228, UV_WOOD)
        col.box(px - 10, px + 10, -532, -512, -4, 228, UV_WOOD)


def build_shady_adobe_house(vis: MultiMeshBuilder, col: MultiMeshBuilder):
    UV_ADOBE  = MultiMeshBuilder.uv_tiled("adobe_plaster", 260.0)
    UV_WOOD   = MultiMeshBuilder.uv_tiled("plywood", 160.0)
    UV_WIN    = MultiMeshBuilder.uv_rect("custom_shady_adobe", 0.02, 0.02, 0.48, 0.48)
    UV_AWNING = MultiMeshBuilder.uv_tiled("tarpaper", 160.0)
    UV_FLOOR  = MultiMeshBuilder.uv_tiled("concrete01", 220.0)

    vis.box(-350, 350, -290, 290, -8, 3, UV_FLOOR)
    col.box(-350, 350, -290, 290, -8, 3, UV_FLOOR)
    for (x0, x1, y0, y1) in (
        (-350,  350,  248,  290),
        (-350, -308, -290,  290),
        ( 308,  350, -290,  290),
        (-350,  -90, -290, -248),
        (  90,  350, -290, -248),
    ):
        vis.frustum(x0, x1, y0, y1, x0 + 5, x1 - 5, y0 + 4, y1 - 4, 3, 306, UV_ADOBE)
        col.box(x0, x1, y0, y1, 3, 306, UV_ADOBE)
    vis.box(-95, 95, -290, -248, 226, 306, UV_ADOBE)
    vis.box(-110, 110, -296, -242, 214, 228, UV_WOOD)
    col.box(-95, 95, -290, -248, 226, 306, UV_ADOBE)
    for wx in (-215.0, 215.0):
        vis.box(wx - 52, wx + 52, -295, -244, 92, 196, UV_WIN)
    vis.box(-344, 344, -284, 284, 276, 302, UV_ADOBE)
    col.box(-344, 344, -284, 284, 276, 302, UV_ADOBE)
    for vx in range(-280, 281, 80):
        vis.box(vx - 7, vx + 7, -316, 316, 260, 274, UV_WOOD)
    vis.frustum(-220, 220, -415, -285, -220, 220, -415, -285, 212, 222, UV_AWNING)


def build_shady_obelisk(vis: MultiMeshBuilder, col: MultiMeshBuilder):
    UV_ADOBE  = MultiMeshBuilder.uv_tiled("adobe_plaster", 200.0)
    UV_STEPS  = MultiMeshBuilder.uv_tiled("concrete01", 200.0)
    UV_PLAQUE = MultiMeshBuilder.uv_rect("custom_shady_plaque", 0.02, 0.02, 0.98, 0.98)

    vis.box(-135, 135, -135, 135, -8, 28, UV_STEPS)
    vis.box(-102, 102, -102, 102, 28, 68, UV_ADOBE)
    vis.frustum(-72, 72, -72, 72, -44, 44, -44, 44, 68, 375, UV_ADOBE, uv_front=UV_PLAQUE)
    vis.frustum(-44, 44, -44, 44, -3, 3, -3, 3, 375, 438, UV_ADOBE)
    col.box(-125, 125, -125, 125, -8, 438, UV_ADOBE)


def build_junktown_scrap_gate(vis: MultiMeshBuilder, col: MultiMeshBuilder):
    UV_IRON    = MultiMeshBuilder.uv_tiled("corrugated", 180.0)
    UV_CAR     = MultiMeshBuilder.uv_tiled("assorted_rust", 200.0)
    UV_SHACK   = MultiMeshBuilder.uv_tiled("shack_metal", 180.0)
    UV_CATWALK = MultiMeshBuilder.uv_tiled("catwalk_rust", 140.0)
    UV_TIRE    = MultiMeshBuilder.uv_tiled("tires", 96.0)
    UV_SIGN    = MultiMeshBuilder.uv_rect("custom_junktown_gate", 0.01, 0.01, 0.99, 0.99)

    for sgn in (-1, 1):
        bx0, bx1 = (-620, -220) if sgn < 0 else (220, 620)
        vis.box(bx0, bx1, -155, 155, -8, 145, UV_CAR)
        vis.box(bx0 + 18, bx1 - 12, -135, 135, 145, 430, UV_IRON)
        col.box(bx0, bx1, -155, 155, -8, 430, UV_IRON)
        for tz in (0.0, 42.0, 84.0):
            vis.cylinder(sgn * 265.0, -172.0, tz, tz + 40.0, 42.0, 42.0, 12, UV_TIRE)
        for sx in range(int(bx0) + 45, int(bx1) - 35, 65):
            vis.frustum(sx - 5, sx + 5, -138, -126, sx - 1, sx + 1, -134, -130, 430, 495, UV_CAR)

    vis.box(-240, 240, -120, 120, 320, 352, UV_CATWALK)
    vis.box(-230, 230, -132, -112, 352, 472, UV_SHACK, uv_front=UV_SIGN)
    vis.box(-230, 230,  112,  132, 352, 472, UV_SHACK)
    col.box(-240, 240, -130, 130, 320, 472, UV_IRON)


def build_hub_water_tower(vis: MultiMeshBuilder, col: MultiMeshBuilder):
    UV_TANK_FULL = MultiMeshBuilder.uv_rect("custom_hub_tower", 0.0, 0.01, 1.0, 0.99)
    UV_STEEL     = MultiMeshBuilder.uv_tiled("shack_metal", 192.0)
    UV_CATWALK   = MultiMeshBuilder.uv_tiled("catwalk_rust", 160.0)
    UV_ROOF      = MultiMeshBuilder.uv_tiled("corrugated", 180.0)
    UV_CONC      = MultiMeshBuilder.uv_tiled("concrete01", 160.0)

    legs = [(-1, -1), (1, -1), (1, 1), (-1, 1)]
    for sx, sy in legs:
        bx, by = sx * 290.0, sy * 290.0
        tx, ty = sx * 195.0, sy * 195.0
        vis.frustum(bx - 22, bx + 22, by - 22, by + 22, tx - 18, tx + 18, ty - 18, ty + 18, -8, 740, UV_STEEL)
        col.frustum(bx - 24, bx + 24, by - 24, by + 24, tx - 20, tx + 20, ty - 20, ty + 20, -8, 740, UV_STEEL)
        vis.box(bx - 38, bx + 38, by - 38, by + 38, -12, 34, UV_CONC)
        col.box(bx - 38, bx + 38, by - 38, by + 38, -12, 34, UV_CONC)

    for gz, gr in ((260.0, 256.0), (520.0, 224.0)):
        vis.box(-gr, gr, -gr - 10, -gr + 10, gz, gz + 18, UV_STEEL)
        vis.box(-gr, gr,  gr - 10,  gr + 10, gz, gz + 18, UV_STEEL)
        vis.box(-gr - 10, -gr + 10, -gr, gr, gz, gz + 18, UV_STEEL)
        vis.box( gr - 10,  gr + 10, -gr, gr, gz, gz + 18, UV_STEEL)

    vis.cylinder(0.0, 0.0, -8.0, 745.0, 38.0, 38.0, 12, UV_STEEL)
    col.box(-40, 40, -40, 40, -8, 745, UV_STEEL)

    vis.cylinder(0.0, 0.0, 735.0, 752.0, 295.0, 295.0, 20, UV_CATWALK, uv_cap=UV_CATWALK)
    vis.cylinder(0.0, 0.0, 752.0, 1115.0, 245.0, 245.0, 24, UV_TANK_FULL, uv_cap=UV_ROOF)
    vis.cylinder(0.0, 0.0, 1115.0, 1280.0, 262.0, 10.0, 24, UV_ROOF, uv_cap=UV_ROOF)
    col.box(-255, 255, -255, 255, 735, 1280, UV_STEEL)


def build_master_throne(vis: MultiMeshBuilder, col: MultiMeshBuilder):
    UV_POD   = MultiMeshBuilder.uv_tiled("vault_blue", 160.0)
    UV_FLESH = MultiMeshBuilder.uv_tiled("gore_meat", 110.0)
    UV_CRT_U = MultiMeshBuilder.uv_rect("custom_master", 0.03, 0.52, 0.97, 0.97)
    UV_CRT_L = MultiMeshBuilder.uv_rect("custom_master", 0.03, 0.03, 0.97, 0.48)
    UV_CABLE = MultiMeshBuilder.uv_tiled("diamond_pipes", 140.0)

    vis.frustum(-175, 175, 12, 98, -155, 155, 18, 92, -4, 28, UV_POD, uv_top=UV_POD)
    col.box(-175, 175, 18, 96, -4, 270, UV_POD)

    vis.frustum(-135, 135, -24, 88, -95, 95, 6, 78, -2, 16, UV_FLESH, uv_top=UV_FLESH)
    for sgn in (-1.0, 1.0):
        vis.frustum(sgn * 58 - 34, sgn * 58 + 34, -44, 24, sgn * 48 - 18, sgn * 48 + 18, -18, 22, -2, 12, UV_FLESH)
        vis.cylinder(sgn * 74.0, 28.0, 10.0, 168.0, 28.0, 19.0, 12, UV_FLESH, uv_cap=UV_FLESH)

    vis.frustum(-88, 88, 22, 86, -72, 72, 28, 82, 24, 196, UV_POD, uv_front=UV_POD)
    vis.frustum(-64, 64, 26, 82, -42, 42, 32, 76, 196, 276, UV_POD, uv_front=UV_CRT_U)
    vis.cylinder(0.0, 24.0, 38.0, 178.0, 52.0, 38.0, 14, UV_FLESH, uv_cap=UV_FLESH)
    vis.cylinder(0.0, 20.0, 178.0, 232.0, 34.0, 22.0, 12, UV_FLESH, uv_cap=UV_FLESH)

    for sgn in (-1.0, 1.0):
        x_in = sgn * 90.0
        x_out = sgn * 182.0
        xa, xb = (x_out, x_in) if sgn < 0 else (x_in, x_out)
        vis.box(xa, xb, -30, 74, -4, 78, UV_POD, uv_top=UV_POD, uv_front=UV_POD)
        vis.frustum(xa + 4, xb - 4, -28, 68, xa + 10, xb - 10, -18, 64, 78, 152, UV_POD, uv_front=UV_CRT_L)
        vis.frustum(xa + 10, xb - 10, -18, 64, xa + 18, xb - 18, -8, 58, 152, 212, UV_POD, uv_front=UV_CRT_U)
        vis.cylinder(sgn * 138.0, 44.0, 68.0, 196.0, 32.0, 18.0, 10, UV_FLESH, uv_cap=UV_FLESH)
        col.box(xa, xb, -30, 74, -4, 212, UV_POD)

    for cx_off, r_pipe, z_top in ((-112.0, 15.0, 305.0), (-54.0, 18.0, 318.0), (54.0, 18.0, 318.0), (112.0, 15.0, 305.0)):
        vis.cylinder(cx_off, 68.0, 24.0, z_top, r_pipe, r_pipe * 0.85, 10, UV_CABLE, uv_cap=UV_CABLE)
    vis.box(-136, 136, 36, 62, 248, 274, UV_CABLE, uv_front=UV_POD)


def build_cathedral_banner_tall(vis: MultiMeshBuilder, col: MultiMeshBuilder):
    # Tall Tyrian Purple Cathedral banner (2:1 Gothic velvet + Sacred Flame emblem), walk-through.
    UV_STONE = MultiMeshBuilder.uv_tiled("church_stone", 160.0)
    UV_TRIM  = MultiMeshBuilder.uv_tiled("diamond_pipes", 120.0)
    UV_BAN   = MultiMeshBuilder.uv_rect("custom_cathedral_banner", 0.01, 0.01, 0.99, 0.99)
    UV_TIP   = MultiMeshBuilder.uv_rect("custom_cathedral_banner", 0.08, 0.01, 0.92, 0.07)

    # Top crossbar & gilded brackets (Z=356..378)
    vis.box(-88, 88, -8, 8, 358, 376, UV_STONE)
    vis.cylinder(-90.0, 0.0, 352.0, 384.0, 11.0, 6.0, 8, UV_TRIM, uv_cap=UV_TRIM)
    vis.cylinder(90.0, 0.0, 352.0, 384.0, 11.0, 6.0, 8, UV_TRIM, uv_cap=UV_TRIM)
    # Main hanging velvet tapestry (double-sided visual thickness +/-3 units)
    vis.box(-68, 68, -3, 3, 40, 358, UV_TRIM, uv_top=UV_TRIM, uv_front=UV_BAN)
    vis.quad((68, 3, 40), (-68, 3, 40), (-68, 3, 358), (68, 3, 358), UV_BAN)
    # Swallow-tail heraldic bottom apron (Z=0..40)
    vis.frustum(-68, 68, -3, 3, -68, -6, -3, 3, 0, 40, UV_TIP, uv_front=UV_TIP)
    vis.frustum(6, 68, -3, 3, 6, 68, -3, 3, 0, 40, UV_TIP, uv_front=UV_TIP)
    # Micro off-plane Havok shape so prop stays 100% walk-through
    col.box(-0.5, 0.5, -0.5, 0.5, -2000.0, -1999.0, UV_STONE)


def build_cathedral_stained_glass(vis: MultiMeshBuilder, col: MultiMeshBuilder):
    # Self-lit Gothic lancet rose stained-glass window in heavy stone casing.
    UV_STONE = MultiMeshBuilder.uv_tiled("church_stone", 160.0)
    UV_IRON  = MultiMeshBuilder.uv_tiled("bunker_conc2", 140.0)
    UV_GLASS = MultiMeshBuilder.uv_rect("custom_stained_glass", 0.01, 0.01, 0.99, 0.99)

    # Side jambs, sill, Gothic crown lintel & mullion tracery
    vis.box(-98, -78, -10, 10, 0, 256, UV_STONE)
    vis.box(78, 98, -10, 10, 0, 256, UV_STONE)
    vis.box(-98, 98, -10, 10, 0, 18, UV_STONE)
    vis.frustum(-98, 98, -10, 10, -44, 44, -10, 10, 256, 294, UV_STONE)
    vis.box(-78, 78, -5, 5, 132, 140, UV_IRON)
    vis.box(-4, 4, -5, 5, 18, 256, UV_IRON)
    # Emissive stained-glass sheet visible from both sides
    vis.quad((-78, -2, 18), (78, -2, 18), (78, -2, 256), (-78, -2, 256), UV_GLASS)
    vis.quad((78, 2, 18), (-78, 2, 18), (-78, 2, 256), (78, 2, 256), UV_GLASS)
    col.box(-0.5, 0.5, -0.5, 0.5, -2000.0, -1999.0, UV_STONE)


def build_cathedral_altar_monolith(vis: MultiMeshBuilder, col: MultiMeshBuilder):
    # Stepped obsidian & gilt Cathedral Unity Altar Monolith with glowing Flame gem.
    UV_STONE = MultiMeshBuilder.uv_tiled("church_stone", 160.0)
    UV_TRIM  = MultiMeshBuilder.uv_tiled("bunker_conc2", 140.0)
    UV_REL   = MultiMeshBuilder.uv_rect("custom_altar_relief", 0.02, 0.02, 0.98, 0.98)
    UV_GEM   = MultiMeshBuilder.uv_rect("custom_stained_glass", 0.30, 0.30, 0.70, 0.70)

    vis.box(-114, 114, -58, 58, 0, 18, UV_STONE)
    vis.box(-98, 98, -48, 48, 18, 36, UV_TRIM)
    vis.box(-84, 84, -40, 40, 36, 136, UV_STONE, uv_front=UV_REL)
    vis.quad((84, 40.5, 36), (-84, 40.5, 36), (-84, 40.5, 136), (84, 40.5, 136), UV_REL)
    for sx in (-88, 72):
        vis.box(sx, sx + 16, -44, 44, 36, 152, UV_TRIM)
    vis.frustum(-56, 56, -28, 28, -24, 24, -14, 14, 136, 246, UV_STONE)
    vis.box(-18, 18, -16, 16, 162, 206, UV_GEM)
    col.box(-102, 102, -50, 50, 0, 144, UV_STONE)


def build_master_flesh_arch(vis: MultiMeshBuilder, col: MultiMeshBuilder):
    # Biomechanical Corridor-of-Flesh rib arch spanning a clean 248-unit-wide, 222-unit-tall walkway.
    UV_VLT  = MultiMeshBuilder.uv_tiled("vault_blue", 160.0)
    UV_RUST = MultiMeshBuilder.uv_tiled("assorted_rust", 140.0)
    UV_PIPE = MultiMeshBuilder.uv_tiled("diamond_pipes", 140.0)
    UV_MEAT = MultiMeshBuilder.uv_tiled("gore_meat", 110.0)

    # Reinforced L.A. Vault side piers (walkway X in [-124..+124] stays completely open)
    for sx0, sx1 in ((-208, -128), (128, 208)):
        vis.box(sx0, sx1, -52, 52, 0, 232, UV_VLT)
        vis.box(sx0 + 6, sx1 - 6, -56, 56, 0, 26, UV_RUST)
        cx_in = sx1 + 10.0 if sx0 < 0 else sx0 - 10.0
        vis.cylinder(cx_in, 0.0, 18.0, 228.0, 16.0, 11.0, 10, UV_MEAT, uv_cap=UV_MEAT)
        vis.cylinder(sx0 * 0.5 + sx1 * 0.5, -24.0, 28.0, 240.0, 10.0, 10.0, 8, UV_PIPE)

    # Overhead bulkhead lintel + neural biomass tendrils + conduit ribs
    vis.box(-208, 208, -52, 52, 224, 298, UV_VLT)
    vis.frustum(-172, 172, -56, 56, -138, 138, -42, 42, 298, 326, UV_RUST)
    for ox in (-78, -26, 26, 78):
        vis.cylinder(float(ox), 0.0, 214.0, 270.0, 18.0, 12.0, 10, UV_MEAT, uv_cap=UV_MEAT)
    vis.box(-128, 128, -46, 46, 218, 236, UV_MEAT)
    # Keep collision strictly to the side piers & lintel above Z=224 so actors never snag
    col.box(-208, -126, -54, 54, 0, 236, UV_VLT)
    col.box(126, 208, -54, 54, 0, 236, UV_VLT)
    col.box(-208, 208, -54, 54, 224, 306, UV_VLT)


def build_master_flesh_wall_cluster(vis: MultiMeshBuilder, col: MultiMeshBuilder):
    # Organic FEV biomass tumor + neural pipe wall overlay (walk-through NavMesh safe).
    UV_MEAT = MultiMeshBuilder.uv_tiled("gore_meat", 100.0)
    UV_CORR = MultiMeshBuilder.uv_tiled("corrosion", 140.0)
    UV_PIPE = MultiMeshBuilder.uv_tiled("diamond_pipes", 120.0)

    vis.box(-88, 88, -6, 12, 8, 168, UV_CORR)
    for cx, cz, r0, r1, h in (
        (-52.0, 24.0, 28.0, 16.0, 118.0),
        (0.0,   12.0, 36.0, 20.0, 152.0),
        (54.0,  28.0, 26.0, 14.0, 110.0),
    ):
        vis.cylinder(cx, -12.0, cz, cz + h, r0, r1, 10, UV_MEAT, uv_cap=UV_MEAT)
    for px in (-72.0, -24.0, 28.0, 74.0):
        vis.cylinder(px, -4.0, 4.0, 174.0, 7.0, 6.0, 8, UV_PIPE, uv_cap=UV_PIPE)
    col.box(-0.5, 0.5, -0.5, 0.5, -2000.0, -1999.0, UV_CORR)


def build_master_vault_plaque(vis: MultiMeshBuilder, col: MultiMeshBuilder):
    # Heavy L.A. Demonstration Vault bulkhead plaque mounted in Master's Lair.
    UV_VLT  = MultiMeshBuilder.uv_tiled("vault_blue", 150.0)
    UV_RUST = MultiMeshBuilder.uv_tiled("assorted_rust", 140.0)
    UV_PLQ  = MultiMeshBuilder.uv_rect("custom_master_plaque", 0.01, 0.01, 0.99, 0.99)

    vis.box(-98, 98, -8, 8, 0, 194, UV_VLT, uv_front=UV_RUST)
    vis.box(-104, 104, -10, 10, 180, 198, UV_RUST)
    vis.box(-104, 104, -10, 10, 0, 14, UV_RUST)
    vis.quad((-86, -8.5, 16), (86, -8.5, 16), (86, -8.5, 178), (-86, -8.5, 178), UV_PLQ)
    vis.quad((86, 8.5, 16), (-86, 8.5, 16), (-86, 8.5, 178), (86, 8.5, 178), UV_PLQ)
    col.box(-0.5, 0.5, -0.5, 0.5, -2000.0, -1999.0, UV_VLT)


def _make_credit_card_builder(card_idx: int):
    def _build(vis: MultiMeshBuilder, col: MultiMeshBuilder):
        UV_CARD = MultiMeshBuilder.uv_rect(f"custom_credit_card_{card_idx:02d}", 0.0, 0.0, 1.0, 1.0)
        UV_ZERO = MultiMeshBuilder.uv_tiled("bunker_conc1", 128.0)
        # Double-sided back-to-back 2:1 quads (-Y faces camera when AngleZ == camYaw, +Y backs it up)
        vis.quad((-88.0, -0.25, -44.0), (88.0, -0.25, -44.0), (88.0, -0.25, 44.0), (-88.0, -0.25, 44.0), UV_CARD)
        vis.quad((88.0, 0.25, -44.0), (-88.0, 0.25, -44.0), (-88.0, 0.25, 44.0), (88.0, 0.25, 44.0), UV_CARD)
        col.box(-0.5, 0.5, -0.5, 0.5, -2000.0, -1999.0, UV_ZERO)
    return _build


BUILDERS = [
    ("V13CathedralMonument.nif",         build_cathedral),
    ("V13CathedralRuins.nif",            build_cathedral_ruins),
    ("V13LostHillsSurfaceBunker.nif",    build_lost_hills_bunker),
    ("V13MariposaBunkerFacade.nif",      build_mariposa_bunker),
    ("V13TheGlowCrater.nif",             build_glow_crater),
    ("V13ShadySandsGateArch.nif",        build_shady_gate_arch),
    ("V13ShadySandsAdobeHall.nif",       build_shady_adobe_hall),
    ("V13ShadySandsAdobeHouse.nif",      build_shady_adobe_house),
    ("V13ShadySandsObelisk.nif",         build_shady_obelisk),
    ("V13JunktownScrapGate.nif",         build_junktown_scrap_gate),
    ("V13HubWaterTower.nif",             build_hub_water_tower),
    ("V13MasterBiomechanicalThrone.nif", build_master_throne),
    ("V13CathedralBannerTall.nif",       build_cathedral_banner_tall),
    ("V13CathedralStainedGlass.nif",     build_cathedral_stained_glass),
    ("V13CathedralAltarMonolith.nif",    build_cathedral_altar_monolith),
    ("V13MasterFleshArch.nif",           build_master_flesh_arch),
    ("V13MasterFleshWallCluster.nif",    build_master_flesh_wall_cluster),
    ("V13MasterVaultPlaque.nif",         build_master_vault_plaque),
    ("V13EndingCreditCard01.nif",        _make_credit_card_builder(1)),
    ("V13EndingCreditCard02.nif",        _make_credit_card_builder(2)),
    ("V13EndingCreditCard03.nif",        _make_credit_card_builder(3)),
    ("V13EndingCreditCard04.nif",        _make_credit_card_builder(4)),
    ("V13EndingCreditCard05.nif",        _make_credit_card_builder(5)),
    ("V13EndingCreditCard06.nif",        _make_credit_card_builder(6)),
]


def _configure_pynifly_mat(mat, mat_key: str):
    info = MAT_SPECS[mat_key]
    mat["BS_Shader_Block_Name"] = "BSLightingShaderProperty"
    mat["BSLSP_Shader_Name"] = info["bgsm"]
    mat["BSShaderTextureSet_Diffuse"] = info["diffuse"]
    mat["BSShaderTextureSet_Normal"] = info["normal"]
    mat["BSShaderTextureSet_Specular"] = info["spec"]
    for k in [
        "pyn_synthetic_alpha_from_bgsm",
        "NiAlphaProperty_flags",
        "NiAlphaProperty_threshold",
        "BSShaderTextureSet_EnvMap",
        "BSShaderTextureSet_EnvMapMask",
        "BSLSP_Shader_Type",
    ]:
        if k in mat:
            del mat[k]
    if info["env"]:
        mat["BSShaderTextureSet_EnvMap"] = info["env"]
    if info.get("alpha_blend"):
        mat["NiAlphaProperty_flags"] = 4844
        mat["NiAlphaProperty_threshold"] = 0


def export_all_monuments():
    os.makedirs(OUT_DIR, exist_ok=True)
    clear_scene()
    enable_pynifly()

    for nif_fn, build_fn in BUILDERS:
        clear_scene()
        bpy.ops.import_scene.pynifly(
            filepath=DONOR_NIF,
            import_cutpoints=False,
            import_tris=False,
            import_collisions=True,
        )
        vis_objs = [o for o in bpy.data.objects if o.type == "MESH" and not o.name.startswith("bhk")]
        col_objs = [o for o in bpy.data.objects if o.type == "MESH" and o.name.startswith("bhk")]
        vis_obj = vis_objs[0]
        col_obj = col_objs[0]
        base_mat = vis_obj.data.materials[0]
        root_parent = vis_obj.parent

        vis_b = MultiMeshBuilder(single_mesh=False)
        col_b = MultiMeshBuilder(single_mesh=True)
        build_fn(vis_b, col_b)

        col_b.finish_part_to_mesh("_col", col_obj, compute_normals=False)
        col_obj["pynRigidBody"] = "bhkPhysicsSystem"
        col_obj["pynCollisionShapeType"] = "compressed_mesh"

        part_keys = vis_b.part_keys()
        exported_vis_objs = []
        for idx, mk in enumerate(part_keys):
            if idx == 0:
                part_obj = vis_obj
                part_mat = base_mat
                part_obj.name = f"{nif_fn[:-4]}_{mk}"
            else:
                part_mesh = bpy.data.meshes.new(f"{nif_fn[:-4]}_{mk}_Mesh")
                part_obj = vis_obj.copy()
                part_obj.data = part_mesh
                part_obj.name = f"{nif_fn[:-4]}_{mk}"
                part_obj.parent = root_parent
                bpy.context.scene.collection.objects.link(part_obj)
                part_mat = base_mat.copy()
                part_mat.name = f"Mat_{nif_fn[:-4]}_{mk}"
                part_obj.data.materials.clear()
                part_obj.data.materials.append(part_mat)

            vis_b.finish_part_to_mesh(mk, part_obj, compute_normals=True)
            _configure_pynifly_mat(part_mat, mk)
            exported_vis_objs.append(part_obj)

        vis_b.free_all()
        col_b.free_all()

        dst_path = os.path.join(OUT_DIR, nif_fn)
        bpy.ops.object.select_all(action="DESELECT")
        for vo in exported_vis_objs:
            vo.select_set(True)
        bpy.context.view_layer.objects.active = exported_vis_objs[0]
        bpy.ops.export_scene.pynifly(filepath=dst_path, target_game="FO4")
        print(f"[Monument Exported] {nif_fn} ({len(exported_vis_objs)} shapes, {os.path.getsize(dst_path)} bytes)")

    # Render a 1920x1080 PBR showcase sheet of all 11 monuments using actual FO4 diffuse textures!
    clear_scene()
    scene = bpy.context.scene
    scene.render.engine = "BLENDER_EEVEE"
    scene.render.resolution_x = 1920
    scene.render.resolution_y = 1080

    sun_data = bpy.data.lights.new("SunKey", type="SUN")
    sun_data.energy = 3.8
    sun_obj = bpy.data.objects.new("SunKey", sun_data)
    bpy.context.scene.collection.objects.link(sun_obj)
    sun_obj.rotation_euler = (math.radians(52.0), math.radians(-18.0), math.radians(32.0))

    fill_data = bpy.data.lights.new("SunFill", type="SUN")
    fill_data.energy = 1.6
    fill_obj = bpy.data.objects.new("SunFill", fill_data)
    bpy.context.scene.collection.objects.link(fill_obj)
    fill_obj.rotation_euler = (math.radians(65.0), math.radians(25.0), math.radians(-135.0))

    if scene.world is None:
        scene.world = bpy.data.worlds.new("PreviewWorld")
    scene.world.use_nodes = True
    bg_node = scene.world.node_tree.nodes.get("Background")
    if bg_node:
        bg_node.inputs[0].default_value = (0.14, 0.15, 0.17, 1.0)
        bg_node.inputs[1].default_value = 1.0

    preview_mat_cache = {}
    for mk, info in MAT_SPECS.items():
        pmat = bpy.data.materials.new(f"Prev_{mk}")
        pmat.use_nodes = True
        nt = pmat.node_tree
        bsdf = nt.nodes.get("Principled BSDF")
        bsdf.inputs["Roughness"].default_value = 0.84
        dds_path = info.get("preview_dds", "")
        if dds_path and os.path.isfile(dds_path):
            tex_node = nt.nodes.new("ShaderNodeTexImage")
            tex_node.image = bpy.data.images.load(dds_path, check_existing=True)
            nt.links.new(tex_node.outputs["Color"], bsdf.inputs["Base Color"])
        preview_mat_cache[mk] = pmat

    for idx, (nif_fn, build_fn) in enumerate(BUILDERS):
        vb = MultiMeshBuilder(single_mesh=False)
        cb = MultiMeshBuilder(single_mesh=True)
        build_fn(vb, cb)
        cb.free_all()
        pkeys = vb.part_keys()

        # Merge all sub-meshes into a normalized preview parent empty or calculate group scale
        part_objs = []
        bmin = [1e9, 1e9, 1e9]
        bmax = [-1e9, -1e9, -1e9]
        for mk in pkeys:
            m_data = bpy.data.meshes.new(f"PrevMesh_{idx}_{mk}")
            m_obj = bpy.data.objects.new(f"PrevObj_{idx}_{mk}", m_data)
            bpy.context.scene.collection.objects.link(m_obj)
            vb.finish_part_to_mesh(mk, m_obj, compute_normals=True)
            m_obj.data.materials.append(preview_mat_cache[mk])
            for v in m_obj.data.vertices:
                bmin[0] = min(bmin[0], v.co.x); bmax[0] = max(bmax[0], v.co.x)
                bmin[1] = min(bmin[1], v.co.y); bmax[1] = max(bmax[1], v.co.y)
                bmin[2] = min(bmin[2], v.co.z); bmax[2] = max(bmax[2], v.co.z)
            part_objs.append(m_obj)
        vb.free_all()

        max_d = max(bmax[0] - bmin[0], bmax[1] - bmin[1], bmax[2] - bmin[2], 1.0)
        scl = 7.5 / max_d
        col_i = idx % 6
        row_i = idx // 6
        root = bpy.data.objects.new(f"PrevRoot_{idx}", None)
        bpy.context.scene.collection.objects.link(root)
        root.scale = (scl, scl, scl)
        root.location = ((col_i - 2.5) * 9.5, row_i * 11.5, 0.0)
        root.rotation_euler = (0.0, 0.0, math.radians(-22.0))
        for po in part_objs:
            po.parent = root

    cam_data = bpy.data.cameras.new("PrevCam")
    cam_data.lens = 25.0
    cam_obj = bpy.data.objects.new("PrevCam", cam_data)
    bpy.context.scene.collection.objects.link(cam_obj)
    cam_obj.location = (0.0, -34.0, 26.0)
    cam_obj.rotation_euler = (math.radians(56.0), 0.0, 0.0)
    scene.camera = cam_obj
    scene.render.filepath = PREVIEW_PNG
    bpy.ops.render.render(write_still=True)
    print(f"[Monument Preview Sheet Rendered] {PREVIEW_PNG}")


export_all_monuments()
"""


def _build_dx10_dds_bytes(w: int, h: int, nmips: int, dxgi_fmt: int, is_cubemap: int, payload: bytes) -> bytes:
    """Reconstructs a valid DX10-extended DDS file from BA2 DX10 header + chunk payload."""
    # 124-byte DDS_HEADER + 20-byte DDS_HEADER_DXT10 (148 bytes total with magic)
    ddpf = struct.pack("<8I", 32, 0x4, int.from_bytes(b"DX10", "little"), 0, 0, 0, 0, 0)
    caps2 = 0xFE00 if is_cubemap == 2049 else 0
    hdr = struct.pack(
        "<4s7I44s",
        b"DDS ",
        124,
        0x000A1007,
        h,
        w,
        0,
        0,
        nmips,
        b"\x00" * 44,
    ) + ddpf + struct.pack("<5I", 0x00401008, caps2, 0, 0, 0)
    dx10 = struct.pack("<5I", dxgi_fmt, 3, 0x4 if is_cubemap == 2049 else 0, 1, 0)
    return hdr + dx10 + payload


def _extract_vanilla_preview_dds() -> dict[str, str]:
    """Extracts the 19 vanilla diffuse _d.dds files into _vanilla_preview_tex for Blender Eevee rendering."""
    os.makedirs(VANILLA_PREVIEW_DIR, exist_ok=True)
    needed: dict[str, str] = {}
    out_paths: dict[str, str] = {}
    for mk, (_bgsm, diff_rel, _nrm, _spc, _env) in VANILLA_MAT_DEFS.items():
        local_fn = os.path.join(VANILLA_PREVIEW_DIR, f"{mk}_d.dds")
        out_paths[mk] = local_fn
        if not os.path.isfile(local_fn):
            needed[diff_rel.lower().replace("/", "\\")] = local_fn
    if not needed:
        return out_paths

    for ba2_path in sorted(glob.glob(os.path.join(FO4_DATA_DIR, "Fallout4 - Textures*.ba2"))):
        if not needed:
            break
        with open(ba2_path, "rb") as f:
            hdr = f.read(24)
            if len(hdr) < 24:
                continue
            _magic, _ver, mtype, nfiles, ntbl = struct.unpack("<4sI4sIQ", hdr)
            if mtype != b"DX10":
                continue
            f.seek(ntbl)
            hit_indices: dict[int, str] = {}
            for i in range(nfiles):
                nlen = struct.unpack("<H", f.read(2))[0]
                name = f.read(nlen).decode("utf-8", "replace").lower().replace("/", "\\")
                if name in needed:
                    hit_indices[i] = needed.pop(name)
            if not hit_indices:
                continue
            max_idx = max(hit_indices.keys())
            f.seek(24)
            for i in range(max_idx + 1):
                entry_hdr = f.read(24)
                _nh, _ext, _dh, _unk, nchk, _chksz, h, w, nmips, fmt, is_cube = struct.unpack("<I4sIBBHHHBBH", entry_hdr)
                chunks = [struct.unpack("<QIIHHI", f.read(24)) for _ in range(nchk)]
                if i in hit_indices:
                    pos_save = f.tell()
                    parts = []
                    for ofs, psz, usz, _sm, _em, _al in chunks:
                        f.seek(ofs)
                        raw = f.read(psz) if psz > 0 else f.read(usz)
                        parts.append(zlib.decompress(raw) if psz > 0 else raw)
                    f.seek(pos_save)
                    dds_bytes = _build_dx10_dds_bytes(w, h, nmips, fmt, is_cube, b"".join(parts))
                    with open(hit_indices[i], "wb") as wf:
                        wf.write(dds_bytes)
    return out_paths


def _write_mat_specs_json() -> None:
    vanilla_previews = _extract_vanilla_preview_dds()
    specs: dict[str, dict[str, object]] = {}
    for mk, (bgsm_rel, diff_rel, nrm_rel, spc_rel, env_rel) in VANILLA_MAT_DEFS.items():
        specs[mk] = {
            "bgsm": bgsm_rel,
            "diffuse": diff_rel,
            "normal": nrm_rel,
            "spec": spc_rel,
            "env": env_rel,
            "preview_dds": vanilla_previews.get(mk, ""),
            "alpha_blend": False,
        }
    for mk, (bgsm_stem, dds_stem, nrm, spc, env, _es, _sm, _sh) in CUSTOM_MONUMENT_MAT_DEFS.items():
        specs[mk] = {
            "bgsm": f"Materials\\V13Chronicles\\Monuments\\{bgsm_stem}.BGSM",
            "diffuse": f"Textures\\V13Chronicles\\Monuments\\{dds_stem}_d.dds",
            "normal": "Textures\\" + nrm.replace("/", "\\"),
            "spec": "Textures\\" + spc.replace("/", "\\"),
            "env": ("Textures\\" + env.replace("/", "\\")) if env else "",
            "preview_dds": os.path.join(TEX_OUT_DIR, f"{dds_stem}_d.dds"),
            "alpha_blend": False,
        }
    for mk, (bgsm_rel, diff_rel, norm_rel, spec_rel, env_rel, prev_abs, ab) in OVERHAUL_MAT_DEFS.items():
        specs[mk] = {
            "bgsm": bgsm_rel,
            "diffuse": diff_rel,
            "normal": norm_rel,
            "spec": spec_rel,
            "env": env_rel,
            "preview_dds": prev_abs,
            "alpha_blend": ab,
        }
    with open(MAT_SPECS_JSON, "w", encoding="utf-8") as wf:
        json.dump(specs, wf, indent=2)


def verify_and_postprocess_monument_nifs() -> None:
    """Verifies BSXFlags=0x82, bhkNPCollisionObject + bhkPhysicsSystem, NiAlphaProperty (credit cards), and canonical multi-material BGSM/DDS bindings."""
    mat_lookup = _all_material_lookup()
    for _fid, _edid, nif_fn, _bgsm_stem, _dds_stem in MONUMENT_NIF_SPECS:
        nif_path = os.path.join(MESH_OUT_DIR, nif_fn)
        if not os.path.isfile(nif_path):
            raise RuntimeError(f"Missing exported monument NIF: {nif_path}")
        with open(nif_path, "rb") as rf:
            nif = _parse_fo4_nif(rf.read())

        has_coll_obj = False
        has_phys_sys = False
        has_bsx = False
        has_alpha_prop = False
        shader_bgsms: list[str] = []
        changed = False

        for bi, (bt, blk) in enumerate(nif["blocks"]):
            if bt == "BSXFlags" and len(blk) >= 8:
                has_bsx = True
                cur_val = struct.unpack_from("<I", blk, 4)[0]
                if cur_val != 0x82:
                    struct.pack_into("<I", blk, 4, 0x82)
                    changed = True
            elif bt == "bhkNPCollisionObject":
                has_coll_obj = True
            elif bt == "bhkPhysicsSystem" and len(blk) > 64:
                has_phys_sys = True
            elif bt == "NiAlphaProperty":
                has_alpha_prop = True
                if nif_fn.startswith("V13EndingCreditCard") and len(blk) >= 15:
                    if struct.unpack_from("<HB", blk, 12) != (4844, 64):
                        ba_alpha = bytearray(blk)
                        struct.pack_into("<HB", ba_alpha, 12, 4844, 64)
                        nif["blocks"][bi] = ("NiAlphaProperty", bytes(ba_alpha))
                        changed = True
            elif bt == "BSLightingShaderProperty":
                cur_idx = struct.unpack_from("<i", blk, 4)[0]
                cur_name = nif["strings"][cur_idx] if 0 <= cur_idx < len(nif["strings"]) else ""
                match = mat_lookup.get(cur_name.strip().lower())
                if match is None:
                    raise AssertionError(
                        f"{nif_fn}: BSLightingShaderProperty[{bi}] has unknown BGSM '{cur_name}'"
                    )
                canon_bgsm, diff_dds, norm_dds, spec_dds, env_dds = match
                shader_bgsms.append(canon_bgsm)
                bgsm_idx = _intern_nif_string(nif["strings"], canon_bgsm)
                if cur_idx != bgsm_idx:
                    struct.pack_into("<i", blk, 4, bgsm_idx)
                    changed = True
                glow_dds = ""
                if nif_fn.startswith("V13EndingCreditCard"):
                    glow_dds = diff_dds
                    sf2 = struct.unpack_from("<I", blk, 20)[0]
                    if (sf2 & 0x00000010) == 0:
                        struct.pack_into("<I", blk, 20, sf2 | 0x00000010)
                        changed = True
                tex_list = [diff_dds, norm_dds, "", "", env_dds, glow_dds, "", spec_dds, "", ""]
                expected_tex_bytes = _build_texset_bytes(tex_list)
                tref = struct.unpack_from("<i", blk, 40)[0]
                if 0 <= tref < len(nif["blocks"]) and nif["blocks"][tref][0] == "BSShaderTextureSet":
                    if nif["blocks"][tref][1] != expected_tex_bytes:
                        nif["blocks"][tref] = ("BSShaderTextureSet", expected_tex_bytes)
                        changed = True

        if nif_fn.startswith("V13EndingCreditCard") and not has_alpha_prop:
            alpha_blk_idx = len(nif["blocks"])
            nif["blocks"].append(("NiAlphaProperty", bytearray(struct.pack("<iIiHB", -1, 0, -1, 4844, 64))))
            for _sbi, (sbt, sblk) in enumerate(nif["blocks"]):
                if sbt == "BSTriShape" and len(sblk) >= 100 and struct.unpack_from("<i", sblk, 96)[0] == -1:
                    struct.pack_into("<i", sblk, 96, alpha_blk_idx)
            has_alpha_prop = True
            changed = True

        if changed:
            with open(nif_path, "wb") as wf:
                wf.write(_serialize_fo4_nif(nif))

        assert has_bsx and has_coll_obj and has_phys_sys and shader_bgsms, (
            f"{nif_fn} missing FO4 Havok static collision or shaders "
            f"(bsx={has_bsx}, coll={has_coll_obj}, phys={has_phys_sys}, shaders={len(shader_bgsms)})"
        )
        if nif_fn.startswith("V13EndingCreditCard"):
            assert has_alpha_prop, f"{nif_fn} missing NiAlphaProperty for transparent scrim blending"
        print(f"  [Verified FO4 Multi-Mat Static NIF + Havok] {nif_fn} -> {len(shader_bgsms)} shapes: {', '.join(shader_bgsms)}")


def generate_all_monuments_3d(force: bool = False) -> None:
    generate_monument_textures_and_bgsms(force=force)
    _write_mat_specs_json()
    need_blender = force or not all(
        os.path.isfile(os.path.join(MESH_OUT_DIR, fn)) for _f, _e, fn, _b, _d in MONUMENT_NIF_SPECS
    )
    if need_blender:
        script_src = (
            BLENDER_MONUMENTS_SCRIPT
            .replace("__DONOR_NIF__", DONOR_STATIC_NIF)
            .replace("__OUT_DIR__", MESH_OUT_DIR)
            .replace("__TEX_DIR__", TEX_OUT_DIR)
            .replace("__MAT_SPECS_JSON__", MAT_SPECS_JSON)
            .replace("__PREVIEW_PNG__", PREVIEW_SHEET_PNG)
            .replace("__PYNIFLY_DIR__", PYNIFLY_ADDON_DIR)
        )
        with tempfile.NamedTemporaryFile("w", suffix="_v13_monuments.py", delete=False, encoding="utf-8") as tf:
            tf.write(script_src)
            tmp_script = tf.name
        try:
            proc = subprocess.run(
                [BLENDER_EXE, "--background", "--python", tmp_script],
                capture_output=True,
                text=True,
                encoding="utf-8",
                errors="replace",
                check=False,
            )
            if proc.returncode != 0:
                print(proc.stdout[-3000:])
                print(proc.stderr[-3000:])
                raise RuntimeError(f"Blender 5.2 monument export failed with code {proc.returncode}")
        finally:
            try:
                os.remove(tmp_script)
            except OSError:
                pass
    verify_and_postprocess_monument_nifs()


def ensure_monuments_3d_assets() -> tuple[dict[str, str], dict[str, str]]:
    """Returns (main_ba2_entries, textures_ba2_entries) for Vault13Chronicles Main.ba2 & Textures.ba2."""
    generate_all_monuments_3d(force=False)
    main_map: dict[str, str] = {}
    tex_map: dict[str, str] = {}

    for _fid, _edid, nif_fn, _bgsm_stem, _dds_stem in MONUMENT_NIF_SPECS:
        main_map[f"meshes\\v13chronicles\\monuments\\{nif_fn.lower()}"] = os.path.join(MESH_OUT_DIR, nif_fn)
    for _mk, (bgsm_stem, dds_stem, _nrm, _spc, _env, _es, _sm, _sh) in CUSTOM_MONUMENT_MAT_DEFS.items():
        main_map[f"materials\\v13chronicles\\monuments\\{bgsm_stem.lower()}.bgsm"] = os.path.join(
            MAT_OUT_DIR, f"{bgsm_stem}.BGSM"
        )
        tex_map[f"textures\\v13chronicles\\monuments\\{dds_stem.lower()}_d.dds"] = os.path.join(
            TEX_OUT_DIR, f"{dds_stem}_d.dds"
        )
    for _mk, (bgsm_rel, diff_rel, _n, _s, _e, prev_abs, _ab) in OVERHAUL_MAT_DEFS.items():
        bgsm_disk = (
            os.path.join(ASSET_ROOT, bgsm_rel)
            if "\\monuments\\" in bgsm_rel.lower()
            else os.path.join(THIS_DIR, "assets", bgsm_rel)
        )
        main_map[bgsm_rel.lower()] = bgsm_disk
        tex_map[diff_rel.lower()] = prev_abs
    for gear_bgsm in ("VaultNumber13Gear.BGSM", "VltSignWelcome13.BGSM"):
        main_map[f"materials\\v13chronicles\\vault13gear\\{gear_bgsm.lower()}"] = os.path.join(
            THIS_DIR, "assets", "materials", "V13Chronicles", "Vault13Gear", gear_bgsm
        )
    return main_map, tex_map


if __name__ == "__main__":
    generate_all_monuments_3d(force="--force" in sys.argv)
