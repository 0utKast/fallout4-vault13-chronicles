#!/usr/bin/env python3
# -*- coding: utf-8 -*-
r"""
Packages the Vortex / Mod Organizer 2 ready-to-upload Nexus Mods & GitHub release archives
for 'Vault 13 Chronicles / Crónicas del Refugio 13' (EN + ES) in:
  c:\proyectos_python\Mods_Fallout\cronicas_refugio_13\release_nexus\
"""

import os
import zipfile

THIS_DIR = os.path.dirname(os.path.abspath(__file__))
ES_BUILD_DIR = os.path.join(THIS_DIR, "release_out")
EN_BUILD_DIR = os.path.join(THIS_DIR, "edition_en", "release_out")
RELEASE_DIR = os.path.join(THIS_DIR, "release_nexus")

MOD_FILES = (
    "Vault13Chronicles.esp",
    "Vault13Chronicles - Main.ba2",
    "Vault13Chronicles - Textures.ba2",
)

README_EN = """===============================================================================
VAULT 13 CHRONICLES (2161) - v1.0.0 Complete Edition (English Standalone)
Chapters 1 & 2 Complete — Full Recreation of Fallout 1 (1997) in Fallout 4
===============================================================================

1. WHAT IS THIS MOD?
---------------------
Vault 13 Chronicles is a 100% standalone, full-campaign recreation of the
classic 1997 Fallout (Acts I-V & May 10, 2162 Exile) inside Fallout 4:
- Complete 5-Act Main Storyline: Mnemosyne Historical Archive (Commonwealth) ->
  Vault 13 & Overseer Jacoren -> Shady Sands & Vault 15 -> Necropolis, The Great
  Water Pump & Vault 12 Water Chip -> Multi-level Lost Hills Brotherhood Bunker
  & ZAX 1.2 inside The Glow -> Adytum Civil War & Forge -> Mariposa Military
  Base (FEV Vats & Lou) -> The Cathedral (Morpheus, Gideon & The Master's 3
  canonical endings with Tri-Voice synthesis) -> May 10, 2162 Exile Epilogue,
  Arroyo Pioneers Camp (Theresa & Lyle) & Dynamic Final Chronicle.
- 400 Custom Exterior LAND Cells (20x20 grid, 81,920 x 81,920 units) across
  2161 Southern California with calibrated 2048x2048 Pip-Boy World Map, native
  .lod bounds, and 32 discoverable MapMarkers.
- 28 Quests & Multi-Path 1997 RPG Design: 4-way Tandi Rescue, Junktown (Killian,
  Lars, Gizmo, Neal & Doc Morbid), The Hub (Water Caravans, Irwin's .223 Pistol,
  Decker & Sheriff Greene), Followers' Spy, Adytum Forge (Turbo Plasma Rifle &
  Hardened T-51b), Honor of Steel, Dynamic 1997 Mutant Invasion Calendar, and all
  6 classic 1997 Special Encounters (TARDIS/Motion Sensor, Area 51 Alien Blaster
  & Elvis, Nuka-Cola Truck, Godzilla Footprint, Bob's Car Mart & Patrick).
- 4 Simultaneous Classic Companions (Survival Ready, No Vanilla Slot Lost):
  Ian, Desert Ranger Tycho, Katja (Followers of the Apocalypse), and Dogmeat
  (2161) — featuring 1.0x level scaling, Survival bleedout-lock immunity, auto-
  recovery, instant field revival (E / A), tactical menus & Commonwealth sync.
- The Hub Radio (84.5 kHz): 41 original atomic-age songs, 18 vintage commercial
  jingles, 8 serialized radio dramas, and 110 reactive voiced DJ news broadcasts.
- 59 Compiled Papyrus Scripts, 1,544+ lip-synced .fuz dialogue lines across
  78 four-option dialogue wheels, 125 custom NPCs, 40 custom 3D .nif meshes
  (45 .bgsm/.bgem materials, 47 .dds textures).

2. UNIVERSAL COMPATIBILITY & REQUIREMENTS
------------------------------------------
- Fallout 4 Base Game ONLY (Fallout4.esm).
- ZERO Creation Club content, ZERO DLCs, ZERO F4SE, ZERO external dependencies.
- Native compatibility with BOTH Fallout 4 1.10.163 (Pre-Next-Gen / GOG) AND
  1.10.980+ (Next-Gen / Anniversary Edition): compiled as HEDR v1.00 and packed
  strictly as BTDX Version 1 BA2 archives (GNRL v1 & DX10 v1).
- IMPORTANT (SAVE COMPATIBILITY): v1.0.0 is NOT compatible with v0.9.x Beta saves
  due to the 6.25x worldspace rebuild (64 -> 400 cells). Start a fresh 2161
  playthrough (or load any Fallout 4 save that has NEVER had v0.9.x installed).
  Players finishing a v0.9.x run can keep using v0.9.3 from Nexus "Old Files"
  or the GitHub "release/v0.9.x" branch.

3. INSTALLATION (VORTEX / MOD ORGANIZER 2 OR MANUAL)
-----------------------------------------------------
Install via Vortex or Mod Organizer 2 (recommended), or extract all three plugin
files directly into your Fallout 4\\Data folder:
  - Vault13Chronicles.esp
  - Vault13Chronicles - Main.ba2
  - Vault13Chronicles - Textures.ba2
Enable Vault13Chronicles.esp. Load any clean save (without v0.9.x history)
after leaving Vault 111; the starting quest highlights the Vault-Tec Mnemosyne
Historical Archive bunker northwest of Vault 111 / Sanctuary Hills.

4. OPEN PERMISSIONS & CREDITS (MIT LICENSE)
--------------------------------------------
Author: 0utKast (https://github.com/0utKast/fallout4-vault13-chronicles)
Base Engine & Assets: Bethesda Game Studios (Fallout4.esm)
1997 Lore Inspiration: Interplay Productions (Tim Cain, Leonard Boyarsky,
Jason Anderson, Chris Taylor, Mark O'Green, Scott Campbell & original team).
No original 1997 Fallout files are included. 100% Free & Open Permissions.
===============================================================================
"""

README_ES = """===============================================================================
CRÓNICAS DEL REFUGIO 13 (2161) - Edición Completa v1.0.0 (Español Autónomo)
Capítulos 1 y 2 Completos — Recreación de Fallout 1 (1997) en Fallout 4
===============================================================================

1. ¿QUÉ INCLUYE ESTA EDICIÓN COMPLETA v1.0.0?
----------------------------------------------
Crónicas del Refugio 13 es una recreación 100% autónoma de Fallout 1 (1997)
íntegramente dentro de Fallout 4 (Actos I-V y Epílogo del Exilio, 10 de mayo
de 2162):
- Campaña Principal Completa de 5 Actos: Archivo Histórico Mnemosyne (2287) ->
  Refugio 13 y Supervisor Jacoren -> Shady Sands y Refugio 15 -> Necrópolis,
  la Gran Bomba de Agua y el Chip de Agua del Refugio 12 -> Búnker multinivel
  de Lost Hills y ZAX 1.2 en El Resplandor -> Guerra civil y Forja de Adytum ->
  Base Militar Mariposa (Cubas VEF y El Teniente) -> La Catedral (Morpheus,
  Gideon y las 3 vías canónicas ante El Maestro con síntesis de Voz Triple) ->
  Despedida de Jacoren, Pioneros rumbo a Arroyo (Theresa y Lyle) y Crónica Final Dinámica.
- 400 Celdas Exteriores LAND (cuadrícula 20x20, 81.920 x 81.920 unidades) en
  «Sur de California (2161)», mapa del Pip-Boy en español (2048x2048) calibrado
  1:1 con archivos .lod nativos y 32 marcadores de viaje rápido.
- 28 Misiones RPG Multi-Vía al Estilo de 1997: Rescate de Tandi por 4 vías,
  Junktown (Killian, Lars, Gizmo, Neal y Doc Morbid), El Eje (Martha Rastello,
  Granja de Irwin con Pistola .223, Decker y Sheriff Greene), Espía de los
  Seguidores, Forja de Adytum (Rifle de Plasma Turbo y T-51b Endurecida),
  Honor de Acero, Calendario de Invasiones Mutantes (1997) y los 6 Encuentros
  Especiales (TARDIS / Sensor de Movimiento, Platillo del Área 51, Camión de
  Nuka-Cola, Huella de Godzilla, Concesionario de Bob y Patrick el Celta).
- 4 Compañeros Clásicos Simultáneos (Preparados para Supervivencia): Ian,
  Ranger Tycho, Katja (Seguidores del Apocalipsis) y Albóndiga (2161), con
  escalado 1.0x al nivel del jugador, inmunidad al bloqueo de abatimiento,
  recuperación automática, reanimación inmediata (E / A) y menú táctico propio.
- Radio El Eje (84.5 kHz): 41 canciones originales de la era atómica, 18 cuñas
  publicitarias, 8 radionovelas y 110 boletines informativos reactivos doblados.
- 59 Scripts Papyrus compilados, 1.544+ líneas dobladas con Lip-Sync (.fuz)
  en 78 ruedas de diálogo, 125 NPCs propios y 40 mallas 3D .nif (45 materiales
  y 47 texturas .dds).

2. COMPATIBILIDAD UNIVERSAL Y REQUISITOS
-----------------------------------------
- Requiere EXCLUSIVAMENTE Fallout 4 base (Fallout4.esm).
- CERO contenido del Creation Club, CERO DLCs, CERO F4SE y CERO dependencias.
- Compatible de forma nativa TANTO con Fallout 4 1.10.163 (GOG / Pre-Next-Gen)
  como con 1.10.980+ (Next-Gen / Anniversary Edition): cabecera HEDR v1.00 y
  archivos BA2 v1 (GNRL v1 y DX10 v1).
- IMPORTANTE (PARTIDAS GUARDADAS): La v1.0.0 NO es compatible con partidas
  guardadas de la Beta v0.9.x debido a la reconstrucción 6,25x del mundo
  exterior (64 -> 400 celdas). Inicia una partida nueva o carga un guardado de
  Fallout 4 donde NUNCA se haya activado la v0.9.x. Si quieres terminar antes
  tu campaña de la v0.9, tienes la v0.9.3 disponible en «Old Files» de Nexus
  Mods y en la rama «release/v0.9.x» de GitHub.

3. INSTALACIÓN (VORTEX / MOD ORGANIZER 2 O MANUAL)
---------------------------------------------------
Instálalo con Vortex o Mod Organizer 2 (recomendado), o copia estos tres
archivos dentro de tu carpeta Fallout 4\\Data:
  - Vault13Chronicles.esp
  - Vault13Chronicles - Main.ba2
  - Vault13Chronicles - Textures.ba2
Activa Vault13Chronicles.esp. Carga cualquier partida limpia (sin historial de
la Beta v0.9.x) tras salir del Refugio 111; se activará automáticamente la misión
inicial hacia el Archivo Histórico Mnemosyne, al noroeste del Refugio 111.

4. PERMISOS 100% ABIERTOS Y CRÉDITOS (LICENCIA MIT)
---------------------------------------------------
Autor: 0utKast (https://github.com/0utKast/fallout4-vault13-chronicles)
Motor y Activos Base: Bethesda Game Studios (Fallout4.esm)
Inspiración y Lore 1997: Interplay Productions (Tim Cain, Leonard Boyarsky,
Jason Anderson, Chris Taylor, Mark O'Green, Scott Campbell y equipo original).
No se redistribuye ningún archivo del juego de 1997. Permisos 100% Abiertos.
===============================================================================
"""


def build_zip(src_dir: str, zip_path: str, readme_name: str, readme_body: str) -> None:
    esp_path = os.path.join(src_dir, "Vault13Chronicles.esp")
    if not os.path.exists(esp_path):
        raise FileNotFoundError(
            f"Missing public release ESP: {esp_path}. Run build scripts with --public-release first."
        )
    with open(esp_path, "rb") as ef:
        esp_bytes = ef.read()
    for forbidden_marker in (b"[SALTO DIRECTO", b"[DIRECT JUMP"):
        if forbidden_marker in esp_bytes:
            raise RuntimeError(
                f"ABORTED: Public release {esp_path} still contains QA debug jump marker {forbidden_marker!r}!"
            )
    os.makedirs(os.path.dirname(zip_path), exist_ok=True)
    with zipfile.ZipFile(zip_path, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=6) as zf:
        for fn in MOD_FILES:
            full_p = os.path.join(src_dir, fn)
            if not os.path.exists(full_p):
                raise FileNotFoundError(f"Missing build file: {full_p}")
            zf.write(full_p, arcname=fn)
        zf.writestr(readme_name, readme_body)
    sz_mb = os.path.getsize(zip_path) / (1024 * 1024)
    print(f"[OK] Packaged {zip_path} ({sz_mb:.2f} MB)")


def main() -> None:
    en_zip = os.path.join(RELEASE_DIR, "Vault13Chronicles_EN_v1.0.0.zip")
    es_zip = os.path.join(RELEASE_DIR, "CronicasDelRefugio13_ES_v1.0.0.zip")
    build_zip(EN_BUILD_DIR, en_zip, "README_EN.txt", README_EN)
    build_zip(ES_BUILD_DIR, es_zip, "LEEME_ES.txt", README_ES)


if __name__ == "__main__":
    main()
