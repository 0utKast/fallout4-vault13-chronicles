# Engineering Status & Roadmap / Estado del Proyecto y Hoja de Ruta (`v0.9.0` → `v1.0`)

> **Transparency First / Transparencia Total:** This document details **everything already implemented, voiced, localized (EN + ES), and verified in `v0.9.0 Public Beta (Chapter 1: The Water Chip)`**, alongside **everything already scaffolded in the codebase and what remains to be expanded for `v1.0 (Chapter 2: The Mutant Army & The Master)`**.

---

## 🇺🇸 English — What Is Done vs. What Remains To Be Done

### ✅ Phase 1 — COMPLETED & PLAYABLE NOW (`v0.9.0` — *Chapter 1: The Water Chip*)

1. **Commonwealth Bridge & Hub Interiors (`2287 ↔ 2161`)**
   - [x] **Vault-Tec Mnemosyne Historical Archive (`CELL 0x01002000`)**: Bunker northwest of Vault 111 / Sanctuary Hills with Neural Simulation Mainframe, Memory Pod, and Trophy/Relic Display Hall allowing unrestricted two-way travel between 2287 Commonwealth and December 5, 2161 Southern California while retaining all unlocked classic gear.
   - [x] **Vault 13 Operations & Overseer Command (`CELL 0x01002100`) + Entrance Cavern (`CELL 0x01002200`)**: Overseer Jacoren's canonical Water Chip briefing (150-day reserve), Security Officer Lyle, Systems Engineer Calvin, Supervisor Cindy, Technician Theresa, Medical Officer (vendor), Guard Ed, the skeleton of Scout Ed in the rat-infested entrance cave (*"Ed's dead"*), Theresa's *"Leave the Vault"* rebel faction subplot, and the water-rationing theft investigation.

2. **Custom Southern California Worldspace (`WRLD 0x01003400`) & 1:1 Pip-Boy Map**
   - [x] **64 Custom Exterior `LAND` Cells (`8×8` grid, `32,768 × 32,768` units)**: Pacific coastline (Monterey/Big Sur down to Santa Monica/San Pedro), Sierra Nevada mountain passes, Central Valley highways, Mojave wasteland, and `36` mathematically leveled settlement plateaus (`VHGT` multiples of `8.0` units so zero buildings float or clip).
   - [x] **Custom `2048×2048` BC1 Pip-Boy Tactical Map (`V13CaliforniaWorldMap_d.dds`)**: Separate localized **English** and **Spanish** world maps calibrated 1:1 with `MNAM` bounds, `23` discoverable `MapMarkers`, live player Pip-Boy cursor, quest objective markers, and fast travel.

3. **Dedicated 2161 Radio Station — *The Hub Radio (84.5 kHz)* (`V13RadioQuestScript.psc`)**
   - [x] **24 Original Atomic-Age Songs + 24 Voiced DJ News Broadcasts**: Automatically activates upon entering 2161 Southern California, suppresses anachronistic 2287 Commonwealth radio stations while in 2161, and restores your exact 2287 radio configuration upon returning to the Commonwealth.

4. **Classic Simultaneous Party Companions (3 of 4 Complete)**
   - [x] **Ian (Shady Sands)**: Hired for 100 caps or Speech check; armed with his classic **Colt 6520 10mm Pistol** and leather jacket; full tactical command menu (follow distance, commando mode, ammo/supply sharing, inventory, wait, dismiss).
   - [x] **Desert Ranger Tycho (Junktown)**: Recruited with his **Combat Shotgun** and **Desert Ranger Armor**; full tactical command menu.
   - [x] **Dogmeat 2161 / Albóndiga**: Distinct **Raider Dog** breed with reinforced leather harness and collar (never confused with Fallout 4's German Shepherd); travels simultaneously alongside Ian and Tycho across exterior and interior cells.

5. **Main Campaign Acts I & II + Multi-Path Town Side Quests**
   - [x] **Shady Sands & Northern Khans**: Emperor Radscorpion hunt & Dr. Razlo's antidote for Jarvis; rescuing **Diana & Gwen** from Warden Tolan; **Rescuing Tandi (`QUST 0x01018000`) via all 4 classic 1997 paths** (1. Speech/Intimidation with dynamic reactivity if Garl Death-Hand was already killed in Vault 15, 2. 500-cap ransom with full Aradesh reimbursement, 3. Direct combat against Lt. Petrox, 4. Stealth lockpicking of the rear cell latch).
   - [x] **Act I — Vault 15 Buried Ruins (`CELL 0x01002500`)**: Subterranean exploration, boss fight against **Garl Death-Hand**, discovering the rockslide crushing Vault 15's water computer, and recovering the Hydrological Holotape pointing to Vault 12 in Necropolis.
   - [x] **Junktown (`V13SideQuestJunktown` & `V13SideQuestJunktownSyndicate`)**: Stopping Gizmo's hitman **Kenji** to protect Mayor **Killian Darkwater** & **Captain Lars**; confronting crime boss **Gizmo & Izo** (3 ways to secure Gizmo's voice confession: dialogue trap, stealth bug planting, or combat); **Neal & Vinnie's Skulz gang** at the Skum Pitt (3 ways to recover Neal's wife's urn); and **Doc Morbid's Clinic** + clandestine *Bob's Iguana Bits* cooler investigation.
   - [x] **The Hub (`V13SideQuestHub` & `V13SideQuestHubSyndicate`)**: Liberating **Irwin's Farm** from Krag's raiders (rewarding the iconic **.223 Pistol — "That Gun"**), meeting **Harold** & **Butch Harris**; **Water Master Martha Rastello** (emergency water caravan contract to Vault 13: +100 days vs strategic security risk); **Missing Caravans** (Deathclaw canyon & dying Super Mutant **Tug**'s holodisk); and **The Hub Underground** (**Sheriff Justin Greene** vs **Decker & Kane** via undercover infiltration, blackmail, or combat).
   - [x] **Act II — Necropolis, Underground, Watershed & Vault 12 (`CELL 0x01002900`, `0x01002A00`)**: **Set** & **Garret** in the Hall of the Dead; peaceful **Underground Ghouls** & **Ezekiel**; repairing the **Great Water Pump** (earning the *Necropolis Hydrological Pact* so Bakersfield's ghouls don't die of thirst); confronting Super Mutants **Harry, Barry & Sally** + freeing the Ghoul Prisoner at the Watershed (bluff, science, intimidation, or combat); extracting the **Vault 12 Water Chip**; and restoring Vault 13's Purification Plant.
   - [x] **Playable Frontier Exterior Quests**: **Lost Hills Exterior & The Glow Crater (`V13SideQuestGlow`)** (**Cabbot**, **Paladin Talus**, Sgt. Dennis Allen's holodisk & **Wattz 2000 Laser Rifle**) and **L.A. Boneyard Exterior (`V13SideQuestBoneyard`)** (**Gabriel**'s Gun Runners, **Smitty**, **Nicole** & the Deathclaw Mother nest).

6. **All 6 Classic 1997 Special Encounters (6/6 Complete)**
   - [x] **1. Unusual 1960s British Police Box (TARDIS)** → Working **Pip-Boy Motion Sensor** highlighting nearby hostiles.
   - [x] **2. Overturned Nuka-Cola Truck** → Luck-scaled bottlecap fortune (`1000 + Luck × 976`).
   - [x] **3. Crashed Area 51 Flying Saucer** → **Alien Blaster** & custom 3D **Elvis ("The King") Velvet Painting**.
   - [x] **4. Giant Godzilla Footprint** → Crushed stealth traveler, **RobCo Stealth Boy 3001** & paleontology terminal.
   - [x] **5. Bob's Pre-Owned Car Mart** → Desert Corvega lot & legendary **Red Ryder LE BB Gun**.
   - [x] **6. Patrick the Celt** → Voiced campfire dialogue wheel, traditional Gaelic ballad *Ballad of Na Fianna*, Gaelic Medallion & **+1 Permanent Charisma**.

7. **Dual Standalone Localization (EN + ES) & 21-Check Automated Binary QA**
   - [x] `36,249` custom `.esp` records (`HEDR v1.00`), `50` compiled Papyrus scripts, `1,020+` Spanish & `1,061` English `.xwm` voice files, `43` 4-option dialogue wheels (`SCEN`), `5` merchant factions, custom 3D `.nif`/`.dds` assets, and **`20/20` (ES) + `21/21` (EN) QA checks passed with `0` warnings and `0` errors**.

---

### 🚧 Phase 2 — PENDING FOR `v1.0` (*Chapter 2: The Mutant Army & The Master*)

> **Technical Note:** The exterior locations, base interior cells (`Lost Hills 0x01002B00`, `Mariposa Military Base 0x01002C00`, `The Cathedral 0x01002D00`), boss actors (`Commander Kragor`, `The Lieutenant`, `Morpheus`, `The Master`), classic endgame weapons (`Winchester P94`, `Vindicator Minigun`, `Hardened T-51f Power Armor`), and core state scripts (`V13Act3QuestScript`, `V13Act4QuestScript`, `V13Act5QuestScript`) are **already built in the plugin and intentionally locked (`LockLevel 253` / gated in `WakeUpAct3..5`)** while we expand them to the same deep multi-path RPG standard as Chapter 1:

- [ ] **1. Act III Expansion — Multi-Level Lost Hills Bunker & ZAX 1.2 Inside The Glow**:
  - Unlocking Lost Hills interior levels with full voiced dialogue wheels for **High Elder John Maxson**, **Head Paladin Rhombus**, **Head Scribe Vree** (delivering the canonical **Super Mutant Autopsy Holotape** proving 100% FEV gamete sterility), and **Kyle/Michael** (T-51b Power Armor restoration).
  - Adding the subterranean West Tek research interior at **The Glow** featuring interactive philosophical/scientific dialogue and chess challenge with supercomputer **ZAX 1.2**.
- [ ] **2. Classic Companion #4 — *Katja* (Followers of the Apocalypse)**:
  - Full recruitment, voiced dialogue, throwing/SMG loadout, and tactical squad integration for **Katja** at the L.A. Boneyard Library alongside **Nicole**, completing the 4-companion roster (*Ian, Tycho, Katja, Dogmeat*).
- [ ] **3. Act IV Expansion — Adytum Civil War & Mariposa Military Base Infiltration**:
  - Multi-faction questline in **Adytum**: **Jon Zimmerman**, **Caleb's Regulators** vs. **Razor's Blades**, **Smitty**'s *Winchester P94 Turbo Plasma Rifle* upgrade, and **Miles**'s *Hardened Power Armor* chemical treatment.
  - Unlocking & expanding **Mariposa Military Base (`CELL 0x01002C00`)**: Children of the Cathedral robe disguise, forcefield emitter hacking/disablement, Nightkin patrols, voiced confrontation with **The Lieutenant ("Lou")**, and interactive **FEV Control Computer self-destruct escape sequence**.
- [ ] **4. Act V Expansion — The Cathedral, Demonstration Vault, The Master's 3 Canonical Endings & Exile Epilogue**:
  - Expanding **The Cathedral & Demonstration Vault (`CELL 0x01002D00`)**: **High Priest Morpheus**, **Lasher**, and the psychic prisoners (**Gideon, Moore, Lucy, Wiggum**) granting the **Psychic Nullifier** to survive the Neural Corridor.
  - Full implementation of **all 3 canonical 1997 victory paths against The Master (Richard Grey)** (with alternating male/female/electronic multi-voice synthesis):
    1. **Diplomatic / Scientific Proof**: Presenting **Vree's Autopsy Holotape** to prove Super Mutant sterility so The Master triggers self-destruction in despair.
    2. **Military Showdown**: Direct boss combat against The Master and Nightkin Praetorians.
    3. **Nuclear Sabotage**: Infiltrating Level 4 to manually arm the nuclear warhead (Lockpick/Science or Cathedral key) with a 4-minute escape countdown.
  - **Playable May 10, 2162 Exile Epilogue**: Returning outside Vault 13's blast door for Overseer Jacoren's canonical farewell (*"You're a hero... and you have to leave"*) as the Vault Dweller walks out into the wasteland toward Arroyo.

---
---

## 🇪🇸 Español — Qué Está Hecho y Qué Queda por Hacer

### ✅ Fase 1 — COMPLETADO Y 100% JUGABLE AHORA (`v0.9.0` — *Capítulo 1: El Chip de Agua*)

1. **Puente Temporal desde la Commonwealth e Interiores Base (`2287 ↔ 2161`)**
   - [x] **Archivo Histórico Mnemosyne de Vault-Tec (`CELL 0x01002000`)**: Búnker al noroeste del Refugio 111 / Sanctuary Hills con terminal neuronal, cápsula de memoria y Sala de Trofeos/Reliquias que permite viajar libremente de ida y vuelta entre 2287 y el 5 de diciembre de 2161 conservando todo el armamento clásico desbloqueado.
   - [x] **Refugio 13 (`CELL 0x01002100`) y Cueva de Salida (`CELL 0x01002200`)**: Despacho del Supervisor **Jacoren** (encargo secreto con 150 días de agua), Oficial **Lyle**, Ingeniero **Calvin**, Supervisora **Cindy**, Técnica **Theresa**, Oficial Médico (comerciante), esqueleto del explorador **Ed** en la caverna (*«Ed está muerto»*), subtrama rebelde de **Theresa** y robo de raciones de agua.

2. **Mundo Exterior Propio «Sur de California (2161)» (`WRLD 0x01003400`) Seguible 1:1 en el Pip-Boy**
   - [x] **64 Celdas Exteriores `LAND` (`8×8`, `32.768 × 32.768` unidades)**: Costa del Pacífico (de Monterey/Big Sur a Santa Mónica/San Pedro), pasos de Sierra Nevada, Valle Central, desierto del Mojave y `36` mesetas niveladas al milímetro (`VHGT`) para que ningún edificio flote ni quede enterrado.
   - [x] **Mapa Táctico `2048×2048` BC1 en el Pip-Boy (`V13CaliforniaWorldMap_d.dds`)**: Versiones independientes en **español** e **inglés** calibradas 1:1 con el terreno real, `23` `MapMarkers` descubribles, cursor del jugador en vivo, marcadores de misión y viaje rápido.

3. **Emisora Propia de 2161 — *Radio El Eje (84.5 kHz)* (`V13RadioQuestScript.psc`)**
   - [x] **24 Canciones de la Era Atómica + 24 Boletines Doblados**: Sintonización automática al entrar en 2161, silenciamiento limpio de las emisoras de 2287 mientras estás en Nueva California y restauración exacta al regresar a la Commonwealth.

4. **Compañeros Clásicos Reclutables en Escuadrón Simultáneo (3 de 4 Completados)**
   - [x] **Ian (Shady Sands)**: Contratable por 100 chapas o persuasión, con su **Pistola Colt 6520 de 10 mm** y menú táctico completo.
   - [x] **Ranger Tycho (Junktown)**: Equipado con **Escopeta de Combate** y uniforme de **Ranger del Desierto**, con menú táctico completo.
   - [x] **Albóndiga 2161 (Dogmeat)**: Raza de **Perro de Presa** con arnés de cuero y collar reforzado (diferenciado del Pastor Alemán de Fallout 4), pudiendo viajar con **Ian, Tycho y Albóndiga a la vez** por exteriores e interiores.

5. **Campaña Principal del Capítulo 1 (Actos I y II) + Tramas Secundarias Multi-Vía**
   - [x] **Shady Sands y los Khans**: Caza del Mutascorpión Emperador y antídoto del Dr. Razlo para Jarvis; rescate de **Diana y Gwen** frente a Tolan; **Rescate de Tandi (`QUST 0x01018000`) con las 4 vías clásicas de 1997** (persuasión/intimidación reactiva a la muerte de Garl, rescate de 500 chapas reembolsables, combate directo contra Petrox o sigilo y ganzúa por la parte trasera).
   - [x] **Acto I — Ruinas Sepultadas del Refugio 15 (`CELL 0x01002500`)**: Combate contra **Garl Mano Muerta**, derrumbe sísmico de la sala de mando y Holocinta Hidrológica hacia el Refugio 12.
   - [x] **Junktown / Ciudad Chatarra**: Sicario **Kenji**, Alcalde **Killian Darkwater** y **Capitán Lars**; **Gizmo e Izo** en el Casino (3 vías para obtener la confesión grabada); **Neal y Los Cráneos (Vinnie)** en *La Espumadera* (3 vías para recuperar la urna); y **Doc Morbid** + el secreto frigorífico de *Bob's Iguana Bits*.
   - [x] **El Eje / The Hub**: **Granja de Irwin** y recompensa de la mítica **Pistola del .223 («Esa Arma»)**, **Harold** y **Butch Harris**; **Martha Rastello** y los Mercaderes del Agua (contrato de caravana al Refugio 13); **Caravanas Desaparecidas** (Sanguinario y el supermutante moribundo **Tug**); y el **Submundo de El Eje** (**Sheriff Justin Greene** frente a **Decker y Kane**).
   - [x] **Acto II — Necrópolis, Subterráneos, La Cuenca y el Refugio 12**: **Set** y **Garret**; **Subterráneos** y **Ezequiel**; reparación de la **Gran Bomba de Agua** (*Pacto Hidrológico de Necrópolis* para salvar de la sed a los necrófagos); confrontación con **Harry, Barry y Sally** + liberación del Prisionero Necrófago; extracción del **Chip de Agua** en el Refugio 12 y reparación de la planta purificadora del Refugio 13.
   - [x] **Misiones Exteriores de Frontera Ya Operativas**: **Exterior de Lost Hills y El Resplandor (`V13SideQuestGlow`)** (**Cabbot**, **Paladín Talus**, holodisco de Dennis Allen y **Rifle Láser Wattz 2000**) y **Exterior de El Boneyard / Adytum (`V13SideQuestBoneyard`)** (**Gabriel**, **Smitty**, **Nicole** y nido de la Madre Sanguinario).

6. **Los 6 Encuentros Especiales Clásicos de 1997 (6/6 Completados)**
   - [x] **1. Cabina Policial Británica (TARDIS)** → **Sensor de Movimiento** funcional para el Pip-Boy.
   - [x] **2. Camión de Nuka-Cola Volcado** → Alijo de chapas escalado por Suerte (`1000 + Luck × 976`).
   - [x] **3. Platillo Volante Estrellado del Área 51** → **Bláster Alienígena** y **Cuadro de Terciopelo de Elvis («El Rey»)**.
   - [x] **4. La Huella Gigante de Godzilla** → Viajero aplastado, **RobCo Stealth Boy 3001** y terminal paleontológico.
   - [x] **5. El Concesionario de Coches Usados de Bob** → Lote de Corvegas y la legendaria **Red Ryder LE BB Gun**.
   - [x] **6. Patrick el Celta** → Conversación doblada junto a la hoguera, balada gaélica *Na Fianna*, Medallón Gaélico y **+1 Carisma permanente**.

7. **Doble Edición Autónoma (ES + EN) y Auditoría Automatizada de 21 Checks**
   - [x] `36.249` registros propios (`HEDR v1.00`), `50` scripts Papyrus compilados, `1.020+` voces en español y `1.061` en inglés (`.xwm`), `43` ruedas de diálogo (`SCEN`), `5` facciones de comerciantes y **`20/20` (ES) + `21/21` (EN) comprobaciones QA superadas (`0` advertencias, `0` errores)**.

---

### 🚧 Fase 2 — PENDIENTE PARA `v1.0` (*Capítulo 2: El Ejército Mutante y El Maestro*)

> **Nota Técnica:** Los exteriores, celdas interiores base (`Lost Hills 0x01002B00`, `Base Militar Mariposa 0x01002C00`, `La Catedral 0x01002D00`), jefes (`Comandante Kragor`, `El Teniente`, `Morpheus`, `El Maestro`), armas legendarias finales (`Winchester P94`, `Ametralladora Vindicator`, `Servoarmadura T-51f Endurecida`) y scripts base (`V13Act3..5QuestScript`) **ya existen en el código y están cerrados deliberadamente (`LockLevel 253` / congelados en `WakeUpAct3..5`)** mientras los expandimos con la misma riqueza RPG multi-vía del Capítulo 1:

- [ ] **1. Expansión del Acto III — Interior Multinivel de Lost Hills e Interior de El Resplandor (`ZAX 1.2`)**:
  - Apertura del búnker de la Hermandad del Acero con diálogos completos para **John Maxson**, **Rhombus**, la **Escriba Jefe Vree** (entrega e inspección de la **Holocinta de Autopsia de Supermutantes** sobre la esterilidad por VEF) y reparación de la Servoarmadura T-51b, además del interior de West Tek con la supercomputadora **ZAX 1.2**.
- [ ] **2. Cuarta Compañera Clásica — *Katja* (Seguidores del Apocalipsis)**:
  - Reclutamiento completo, diálogos doblados y menú táctico para **Katja** en la Biblioteca de El Boneyard junto a **Nicole**, completando el cuarteto clásico (*Ian, Tycho, Katja y Albóndiga*).
- [ ] **3. Expansión del Acto IV — Conflicto Civil de Adytum e Infiltración en la Base Militar Mariposa**:
  - Trama de **Jon Zimmerman**, los **Reguladores de Caleb** frente a **las Cuchillas de Razor**, mejora a **Rifle de Plasma Turbo Winchester P94** con **Smitty** y endurecimiento químico de Servoarmadura con **Miles**.
  - Infiltración multi-vía en **Mariposa** (túnicas de la Catedral, desactivación de campos de fuerza, patrullas de Nocturnos, enfrentamiento doblado con **El Teniente «Lou»** y secuencia de autodestrucción de las Cubas de VEF).
- [ ] **4. Expansión del Acto V — La Catedral, el Refugio de Demostración, las 3 Vías Canónicas frente al Maestro y Epílogo del Exilio**:
  - Infiltración ante **Morpheus** y **Lasher**, obtención del **Anulador Psíquico** con los prisioneros psíquicos (**Gideon, Moore, Lucy, Wiggum**) para cruzar el Corredor Neural.
  - Las **3 vías canónicas de victoria de 1997 frente al Maestro (Richard Grey)** con síntesis multivoz alternante:
    1. **Victoria Diplomática / Científica** (mostrar la **Holocinta de Autopsia de Vree** demostrando la esterilidad supermutante).
    2. **Victoria Militar** (combate directo contra El Maestro y sus pretorianos Nocturnos).
    3. **Sabotaje Nuclear** (armar manualmente la ojiva nuclear del Nivel 4 con cuenta atrás de 4 minutos).
  - **Epílogo Jugable del Exilio (10 de mayo de 2162)**: Escena final en el exterior de la compuerta del Refugio 13 con el Supervisor Jacoren (*«Eres un héroe... y tienes que marcharte»*).
