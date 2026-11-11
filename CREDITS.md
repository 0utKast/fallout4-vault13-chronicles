# Credits, Licenses & Open Modding Policy / Créditos, Licencias y Política de Modding Abierto

## 1. Open Modding Commitment / Compromiso de Modding Abierto (100% Open Permissions)
**Vault 13 Chronicles / Crónicas del Refugio 13 (2161)** (both the **English Standalone Edition** and the **Spanish Standalone Edition**) is released under the **MIT License** and **100% Open Modding Permissions**:
- **Modification, Asset Use, Translation & Redistribution:** Explicitly **OPEN**. Any member of the community may inspect, study, modify, translate, port, integrate, or redistribute this mod, its Python binary compilers, Papyrus scripts, custom 3D `.nif` meshes, procedural `.dds` textures, and original radio tracks freely, provided credit to the original author (`0utKast`) is included.
- **Zero Creation Club / Zero DLC / Zero F4SE / Universal Compatibility (`1.10.163` + Next-Gen/AE):** Built natively with **`HEDR v1.00`** (`FormIDs >= 0x800`) and **`BTDX BA2 v1`** (`GNRL v1` & `DX10 v1`), requiring strictly base `Fallout4.esm`. This project firmly rejects artificial version lock-outs, paid *Creations* gating, or closed modding ecosystems.
- **100% Standalone (Zero Third-Party Mod Dependencies):** Every custom interior, exterior worldspace cell, 3D mesh, texture, script, and audio track was built from scratch or uses base `Fallout4.esm` records, requiring zero external downloads.

---

## 2. Full Attribution Table / Tabla Completa de Reconocimiento y Autoría

| Component / Componente | Author / Autor Original | License / Permisos | Notes & Reference / Notas y Referencia |
| :--- | :--- | :--- | :--- |
| **Mod Architecture, Custom Worldspace (`WRLD 0x01003400`), Binary `.esp`/`.ba2` Compiler, 50 Papyrus Scripts & 21-Check QA Suite** | **OutKast (`0utKast`)** | **MIT License (100% Open Permissions)** | https://github.com/0utKast/fallout4-vault13-chronicles |
| **Custom 3D Meshes (`.nif`), Procedural `BC1` Textures (`.dds`) & `2048×2048` Pip-Boy Tactical Map (EN & ES)** | **OutKast (`0utKast`)** | **MIT License (100% Open Permissions)** | Generated procedurally via `generate_v13_worldmap_dds.py`, `generate_v13_junktown_3d_assets.py` & `edition_en/generate_v13_textures_en.py`. |
| **Original Setting, Characters, Quests & Historical Canon (*Fallout: A Post Nuclear Role Playing Game*, 1997)** | **Interplay Productions** (*Tim Cain, Leonard Boyarsky, Jason Anderson, Chris Taylor, Mark O'Green, Scott Campbell & team*) | Tribute / Canonical Recreation | Faithful non-commercial community recreation honoring the 1997 classic RPG and the *Vault Dweller's Memoirs*. |
| **Base Game Engine, Vanilla Architectural Kits & Base Records (`Fallout4.esm`)** | **Bethesda Game Studios** | Official Base Game (`Fallout4.esm` required) | Zero Creation Club (`cc*`) and zero DLC assets used; 100% base-game record references. |
| **AI Voice Synthesis (`1,020+` ES & `1,061` EN `.xwm` Dialogue & Radio DJ Clips) & Sound Effects** | **Synthesized by `0utKast`** (via ElevenLabs Multilingual v2 / Turbo v2.5 + `ffmpeg` + `xwmaencode`) | **100% Open Redistribution in Mod** | Custom voice acting across 9 distinct voice types + Radio DJ broadcasts in both Spanish and English. |
| **Original Atomic-Age Radio Soundtrack (*The Hub Radio / Radio El Eje 84.5 kHz*, 24 Songs)** | **Created & Curated by `0utKast`** (AI-composed vintage 1940s/1950s atomic-age swing & Gaelic ballad *Ballad of Na Fianna*) | **100% Open Permissions** | Processed with vintage vacuum-tube EQ & packaged natively in `.xwm` inside `Main.ba2` + source `.mp3` in `radio_music/`. |
