#!/usr/bin/env python3
# -*- coding: utf-8 -*-
r"""
Packages the Vortex / Mod Organizer 2 ready-to-upload Nexus Mods & GitHub release archives
for 'Vault 13 Chronicles / Crónicas del Refugio 13' (EN + ES) in:
  c:\proyectos_python\Mods_Fallout\cronicas_refugio_13_v09x\release_nexus\
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
VAULT 13 CHRONICLES (2161) - v0.9.3 Public Beta (English Standalone Edition)
Chapter 1: The Water Chip — Recreation of Fallout 1 (1997) Inside Fallout 4
GitHub: https://github.com/0utKast/fallout4-vault13-chronicles
===============================================================================

1. OVERVIEW & WHAT IS INCLUDED IN v0.9.3 (CHAPTER 1 COMPLETE)
-------------------------------------------------------------
Step into the Vault-Tec Mnemosyne Historical Archive in the Commonwealth and
cross the Temporal Bridge back to December 5, 2161 as the original Vault Dweller.

What's New in v0.9.3 Hotfix (100% Savegame Compatible with v0.9.0 - v0.9.2):
- Fixed Completed Quests Marked as "Fail Quest" in ESP / Quest Restart Loops:
  * Fixed 11 side quests and Special Encounters whose final stage QSDT flag was
    erroneously set to Fail Quest (0x02) instead of Complete Quest (0x01), which
    prevented IsCompleted() from becoming True and caused listener loops on
    save load or cell transitions to restart finished quests at Stage 10 and
    replay notifications (unrelated to TimeScale settings).
  * Added retroactive IsStageDone() / completion-proof guards so existing
    saves from v0.9.0-v0.9.2 cleanly lock finished quests as completed on load
    without re-firing notifications or duplicating completion rewards.
- Fixed Pip-Boy Motion Sensor ("Police Box") Notification Spam:
  * Moved Motion Sensor active/threat tracking into persistent quest variables
    and silenced idle "No threats" / "Perimeter clear" notifications so radar
    alerts now trigger ONLY when hostile enemies are actually detected nearby
    (with a 25-second cooldown unless additional hostiles enter range).
- Fixed Traders / NPCs Briefly Swimming in Mid-Air on Exterior Cell Load:
  * Enabled Has Water (0x0002) with safe dry default water height (-10000.0) on
    all Southern California dry exterior cells instead of empty flags with an
    uninitialized +3.4e38 water height, preventing persistent caravans/NPCs
    (such as Crimson Caravan / Water Merchants traders) from evaluating bogus
    underwater swimming on initial load.

Previous Hotfix v0.9.2:
- Fixed Human Companion Combat & High-Difficulty / Survival Scaling (Ian & Tycho):
  * Enabled 1.0x Player Level scaling (PC Level Mult, min level 12), companion
    perks (Sneak I-IV, Companion Inspirational, Radiation Immunity, Live & Love
    bonuses, abDogmeatHealthBonus), ranged companion CombatStyle, and high base
    Health (340+ HP) & Damage/Energy Resistance (95 DR / 85 ER) so Ian and Tycho
    no longer get one-shotted at fixed Level 2 / 60 HP on Very Hard or Survival.
  * Retroactive Savegame Upgrade: Existing saves dynamically scale Ian, Tycho,
    and Dogmeat's Health and Armor Resistance to your current character level.
  * Fixed Permanent Bleedout Lock on Survival / High Difficulty: Detached custom
    human companions from vanilla FollowersScript.Companion alias (which caused
    HC_ManagerScript to lock SetNoBleedoutRecovery(True) without vanilla Stimpak
    recovery), added automatic post-combat & timed bleedout recovery, and added
    instant one-press [E]/[A] field revival whenever a companion is downed.
  * Fixed Independent Target Acquisition & Brave AI (Confidence 3.0): Ian and
    Tycho now actively scan and engage hostiles even when Dogmeat is not in the
    party, and automatically keep their signature firearms equipped.

Previous Hotfix v0.9.1:
- Fixed Shady Sands perimeter walls so neither the player nor NPCs can walk
  through them (Havok-solid CovWall01/CovWallEndcap meshes + NavMesh cutouts).

Included & 100% Playable in v0.9.3 (Chapter 1: The Water Chip):
- Custom Southern California (2161) Open Worldspace (64 exterior cells) with a
  calibrated 2048x2048 Pip-Boy World Map, 23 Map Markers, quest tracking & fast travel.
- Complete Chapter 1 Main Campaign (Acts I & II): Vault 13 (Overseer Jacoren &
  internal Vault 13 subplots), Shady Sands, Vault 15 buried ruins & Garl Death-Hand,
  Junktown, The Hub, Necropolis Underground, Watershed (Harry, Barry & Sally + Great
  Water Pump moral choice), Vault 12 Water Chip extraction & Vault 13 finale.
- Multi-Path 1997 RPG Town Quests: 4-way Tandi Rescue, Gizmo's taped confession,
  Neal & The Skulz, Doc Morbid's clinic secret, Irwin's Farm (.223 Pistol), Water
  Merchants caravan contract, Missing Caravans Deathclaw & Tug, Sheriff Greene vs.
  Decker, plus frontier quests at Lost Hills Exterior / The Glow & L.A. Boneyard.
- 3 Simultaneous Classic Companions: Ian, Desert Ranger Tycho, and Dogmeat (2161)
  with classic loadouts and tactical command menus.
- Dedicated 2161 Radio Station — The Hub Radio (84.5 kHz): 24 original atomic-age
  songs + 24 voiced English DJ news broadcasts reacting to 2161 events.
- All 6 Classic 1997 Special Encounters: 1960s Police Box (TARDIS + working Pip-Boy
  Motion Sensor), Area 51 Crashed UFO (Alien Blaster + Elvis Velvet Painting),
  Overturned Nuka-Cola Truck, Giant Godzilla Footprint, Bob's Pre-Owned Car Mart
  (Red Ryder LE BB Gun), and Patrick the Celt (+1 Permanent Charisma).
- Over 1,060 AI-synthesized English voice lines (.xwm) across 43 dialogue wheels.

Roadmap for v1.0 (Chapter 2 — Mutant Army & The Master):
- Unlocking & expanding Acts III-V interiors (Lost Hills multi-level bunker & ZAX,
  Katja companion, Adytum civil conflict, Mariposa Military Base FEV Vats, The
  Cathedral's 3 canonical Master victory paths, and the May 10, 2162 Exile Epilogue).

2. UNIVERSAL COMPATIBILITY & ZERO RESTRICTIONS
----------------------------------------------
- Game Versions Supported Natively:
  * Fallout 4 v1.10.163 (Pre-Next-Gen / GOG / Downgraded)
  * Fallout 4 v1.10.980+ (Next-Gen / Anniversary Edition)
- Technical Standard:
  * Plugin Header: HEDR v1.00, all custom FormIDs >= 0x800
  * Archives: BTDX Version 1 (GNRL v1 & DX10 v1)
- Requirements:
  * Base Fallout4.esm ONLY.
  * ZERO Creation Club / Creations requirements.
  * ZERO DLC requirements & ZERO F4SE requirements.
  * ZERO external mod dependencies (100% Standalone All-in-One).

3. INSTALLATION (Vortex / Mod Organizer 2 / Manual)
---------------------------------------------------
- Mod Manager (Recommended): Install the .zip archive directly with Vortex or MO2
  and enable Vault13Chronicles.esp.
- Manual: Extract 'Vault13Chronicles.esp', 'Vault13Chronicles - Main.ba2', and
  'Vault13Chronicles - Textures.ba2' into your 'Fallout 4\\Data' folder and enable
  'Vault13Chronicles.esp'.

4. HOW TO START IN-GAME
-----------------------
Upon loading your save, the quest activates automatically and marks the
Vault-Tec Mnemosyne Historical Archive bunker in the Commonwealth on your Pip-Boy
map (northwest of Vault 111 / Sanctuary Hills). Enter the bunker and activate
the Neural Simulation Mainframe next to the Memory Pod to step into Vault 13 (2161).
You can freely travel back and forth between 2161 Southern California and 2287
Commonwealth at any time, keeping all unlocked classic weapons and gear.

5. OPEN MODDING POLICY & CREDITS
--------------------------------
- Author: 0utKast (https://github.com/0utKast/fallout4-vault13-chronicles)
- License: MIT & 100% Open Permissions. You are free to use, modify, translate,
  learn from, and redistribute this mod and its custom assets freely, with credit
  to the original author. Free forever — rejecting paid gating or artificial
  modding restrictions.
- Base Game Engine & Vanilla Assets: Bethesda Game Studios (Fallout4.esm)
- Fallout 1 (1997) Original Setting & Lore Inspiration: Interplay Productions /
  Tim Cain, Leonard Boyarsky, Jason Anderson, Chris Taylor & team.
- Custom 3D Meshes, Procedural BC1 Textures, Worldspace Heightmap, Papyrus State
  Machines, AI Voice Synthesis & Radio Soundtrack: Created from scratch by 0utKast.
"""

README_ES = """===============================================================================
CRONICAS DEL REFUGIO 13 (2161) - v0.9.3 Beta Publica (Edicion en Espanol)
Capitulo 1: El Chip de Agua — Recreacion de Fallout 1 (1997) en Fallout 4
GitHub: https://github.com/0utKast/fallout4-vault13-chronicles
===============================================================================

1. DESCRIPCION GENERAL Y CONTENIDO DE v0.9.3 (CAPITULO 1 COMPLETO)
------------------------------------------------------------------
Adentrate en el Archivo Historico Mnemosyne de Vault-Tec en la Commonwealth y
cruza la Puerta Temporal hasta el 5 de diciembre de 2161 como el Morador del
Refugio original.

Novedades del Parche v0.9.3 (100% Compatible con Partidas de v0.9.0 - v0.9.2):
- Corregidas Misiones Secundarias Marcadas como Fallo ("Fail Quest") y Bucles de
  Repeticion de Mensajes:
  * Corregido el flag QSDT de etapa final en 11 misiones secundarias y
    Encuentros Especiales (de 0x02 Fail Quest a 0x01 Complete Quest), evitando
    que quedasen con IsCompleted() falso y se reiniciasen en la etapa 10 al
    cargar partida o cambiar de celda repitiendo notificaciones (independiente
    del TimeScale).
  * Anadidas guardas retroactivas con IsStageDone() y comprobacion de logro
    para sellar limpiamente las misiones ya terminadas en partidas de v0.9.0 a
    v0.9.2 sin repetir mensajes ni recompensas.
- Eliminado el Spam del Sensor de Movimiento Pip-Boy (Cabina de Policia):
  * Persistido el estado del radar en variables de mision y silenciados los
    avisos de "Sin amenazas" / "Perimetro despejado"; ahora solo muestra alerta
    cuando detecta enemigos hostiles cerca (con refresco cada 25 s o si sube
    el numero de hostiles).
- Corregida la Animacion Breve de "Nado en el Aire" de Comerciantes al Cargar:
  * Corregida la cabecera DATA (0x0002) y altura de agua (-10000.0) en las
    celdas exteriores secas del Sur de California (antes +3.4e38 sin definir),
    evitando que mercaderes y caravanas naden en el aire al cargar la celda.

Parche Anterior v0.9.2:
- Corregido el Escalado de Combate y Recuperacion en Dificultad Alta / Supervivencia
  para Companeros Humanos (Ian y el Ranger Tycho):
  * Activado escalado 1.0x al nivel del jugador (PC Level Mult, nivel minimo 12),
    extras oficiales de companero, estilo de combate a distancia, Salud base de
    340+ PV y Resistencia Balistica/Energetica (95 RD / 85 RE) para evitar que
    Ian y Tycho caigan de un disparo en Muy Dificil o Supervivencia.
  * Mejora Retroactiva en Partidas Guardadas: Las partidas ya iniciadas actualizan
    automaticamente la Salud y Resistencia de Ian, Tycho y Albondiga segun tu nivel.
  * Eliminado el bloqueo permanente en estado abatido (Bleedout) en Supervivencia:
    desvinculado el alias vanilla FollowersScript.Companion que activaba
    SetNoBleedoutRecovery(True), anadida recuperacion automatica tras el combate
    y reanimacion instantanea pulsando [E]/[A] sobre un companero abatido.
  * Escaneo autonomo de enemigos con Confianza Valiente (3.0) aunque Albondiga no
    forme parte del grupo activo, asegurando siempre el equipado de sus armas.

Parche Anterior v0.9.1:
- Corregidas las murallas perimetrales de Shady Sands con colision Havok solida
  y recortes de obstaculo en la NavMesh exterior.

Incluido y 100% Jugable en v0.9.3 (Capitulo 1: El Chip de Agua):
- Mundo Exterior Propio "Sur de California (2161)" (64 celdas exteriores) con
  Mapa Tactico del Pip-Boy 2048x2048 en espanol calibrado 1:1, 23 marcadores de
  mapa, seguimiento completo de misiones y viaje rapido.
- Campana Principal del Capitulo 1 Completa (Actos I y II): Refugio 13 (Supervisor
  Jacoren y subtramas internas del Refugio), Shady Sands, ruinas sepultadas del
  Refugio 15 y Garl Mano Muerta, Junktown, El Eje, Alcantarillas de Necropolis,
  La Cuenca (Harry, Barry y Sally + dilema moral de la Gran Bomba de Agua),
  extraccion del Chip de Agua en el Refugio 12 y regreso al Refugio 13.
- Misiones Secundarias Clasicas Multi-Via (Diseno RPG 1997): Rescate de Tandi por
  4 vias clasicas, confesion grabada de Gizmo, Neal y Los Craneos, secreto de Doc
  Morbid, Granja de Irwin (Pistola del .223), caravana de los Mercaderes del Agua,
  Caravanas Desaparecidas (Sanguinario y Tug), Sheriff Greene contra Decker, mas
  las misiones exteriores de Lost Hills / El Resplandor y El Boneyard de L.A.
- 3 Companeros Clasicos Simultaneos: Ian, el Ranger Tycho y Albondiga (2161) con
  su equipo iconico y menus tacticos de escuadron.
- Emisora Propia de 2161 — Radio El Eje (84.5 kHz): 24 canciones originales de la
  era atomica + 24 boletines doblados en espanol sobre los sucesos de 2161.
- Los 6 Encuentros Especiales Clasicos de 1997: Cabina Policial Britanica TARDIS
  (con Sensor de Movimiento funcional), OVNI Estrellado del Area 51 (Blaster
  Alienigena y Cuadro de Terciopelo de Elvis), Camion de Nuka-Cola Volcado, Huella
  Gigante de Godzilla, Concesionario de Coches de Bob (Red Ryder LE BB Gun) y
  Patrick el Celta (+1 Carisma permanente).
- Mas de 1.020 lineas de voz en espanol (.xwm) y 43 ruedas de dialogo.

Hoja de Ruta hacia v1.0 (Capitulo 2 — El Ejercito Mutante y El Maestro):
- Apertura y expansion profunda de los interiores de los Actos III, IV y V (Bunker
  multinivel de Lost Hills y ZAX, companera Katja, conflicto civil de Adytum,
  infiltracion en la Base Militar Mariposa, las 3 vias canonicas frente al Maestro
  en La Catedral y el Epilogo jugable del Exilio del 10 de mayo de 2162).

2. COMPATIBILIDAD UNIVERSAL Y CERO RESTRICCIONES
------------------------------------------------
- Versiones soportadas de forma nativa (mismo archivo sin parches):
  * Fallout 4 v1.10.163 (Pre-Next-Gen / GOG / Downgraded)
  * Fallout 4 v1.10.980+ (Next-Gen / Anniversary Edition)
- Estandar tecnico:
  * Cabecera .esp: HEDR v1.00 con todos los FormIDs propios >= 0x800
  * Archivos .ba2: BTDX Version 1 (GNRL v1 y DX10 v1)
- Requisitos:
  * Unicamente Fallout4.esm (juego base).
  * CERO contenido de Creation Club / Creations.
  * CERO DLCs y CERO F4SE requeridos.
  * CERO dependencias externas (100% Autonomo Todo-en-Uno).

3. INSTALACION (Vortex / Mod Organizer 2 / Manual)
--------------------------------------------------
- Gestor de mods (Recomendado): Instala el archivo .zip directamente con Vortex
  o Mod Organizer 2 y activa Vault13Chronicles.esp.
- Manual: Extrae 'Vault13Chronicles.esp', 'Vault13Chronicles - Main.ba2' y
  'Vault13Chronicles - Textures.ba2' dentro de 'Fallout 4\\Data' y activa el plugin.

4. COMO EMPEZAR EN EL JUEGO
---------------------------
Al cargar tu partida se activara automaticamente el marcador hacia el Bunker del
Archivo Mnemosyne de Vault-Tec (al noroeste del Refugio 111 / Sanctuary Hills).
Accede al terminal principal junto a la capsula neuronal para viajar al Refugio 13
(5 de diciembre de 2161). Puedes regresar a la Commonwealth de 2287 cuando quieras
conservando todas las armas y equipo clasico desbloqueado.

5. POLITICA DE MODDING ABIERTO Y CREDITOS
-----------------------------------------
- Autor: 0utKast (https://github.com/0utKast/fallout4-vault13-chronicles)
- Licencia: MIT y Permisos 100% Abiertos (Open Permissions). Cualquier miembro de
  la comunidad puede usar, modificar, traducir y redistribuir libremente este mod
  citando la autoria original. 100% gratuito y libre de limitaciones artificiales.
- Motor y activos base: Bethesda Game Studios (Fallout4.esm).
- Inspiracion e historia original de Fallout (1997): Interplay Productions.
- Modelos 3D propios, texturas DDS BC1, terreno exterior de California, scripts
  Papyrus, doblaje IA y banda sonora de radio: Desarrollados por 0utKast.
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
    en_zip = os.path.join(RELEASE_DIR, "Vault13Chronicles_EN_v0.9.3_Beta.zip")
    es_zip = os.path.join(RELEASE_DIR, "CronicasDelRefugio13_ES_v0.9.3_Beta.zip")
    build_zip(EN_BUILD_DIR, en_zip, "README_EN.txt", README_EN)
    build_zip(ES_BUILD_DIR, es_zip, "LEEME_ES.txt", README_ES)


if __name__ == "__main__":
    main()
