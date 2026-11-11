# Informe y Hoja de Ruta — Capítulo 1: *Crónicas del Refugio 13* (El Chip de Agua)

Documento de referencia y seguimiento para completar al 100 % el **Capítulo 1** del mod (`Vault13Chronicles.esp`, desde la salida del Refugio 13 el 5 de diciembre de 2161 hasta la entrega del Chip de Agua del Refugio 12 y la reparación de la planta purificadora), asegurando que no quede fuera ninguna trama, personaje, compañero ni encuentro especial de la primera mitad del **Fallout 1 (1997)** original.

---

## 0. Ajustes Previos de Base y Blindaje de Continuidad Narrativa
- [x] **Restaurar el aspecto original de Albóndiga (Dogmeat 2161)**:
  - Volver a la raza de **Perro de Presa (`RaiderDogRace` `0x00187AF9` + `SkinRaiderDog` `0x000B2BF1`)** equipado con **Arnés Canino de Cuero con Correas (`ClothesDog_ArmorMedium` `0x001C32C8`)** y **Collar Canino Reforzado (`ClothesDog_DogCollarReinforced` `0x001C67B2`)**, eliminando el aspecto de Pastor Alemán con pañuelo rojo de *Fallout 4* para que jamás se confundan ambos perros.
- [x] **Protección de NPCs Multi-Trama y Cierre de Interiores de Capítulos Posteriores**:
  - **Interiores de Capítulos Posteriores (`Lost Hills Interior 0x01003507`, `Base Militar de Mariposa 0x01003508`, `La Catedral 0x01003509`)**: Mantener sus puertas exteriores cerradas con cerrojo de seguridad (`LockLevel 253`) durante todo el Capítulo 1 y mantener **Initially Disabled (`0x00000C00`)** (y resucitar si hubieran muerto en una partida previa) al **Sumo Sacerdote Morpheus (`0x01002D12`)**, **El Maestro (`0x01002D11`)**, **El Teniente (`0x01002C11`)**, **Comandante Kragor (`0x01002B11`)** y sus escoltas hasta que comience su acto correspondiente.
  - **Separación y Reactividad entre Jefes de Trama Principal y Secundaria (Caso Khans / Garl Mano Muerta)**:
    - **Garl Mano Muerta (`0x01002559`)** es el caudillo del interior del Refugio 15 (Acto 1).
    - El **Secuestro de Tandi** en la superficie corre a cargo del campamento exterior de los Khans del Norte (**Tolan y su partida de asalto**): si el jugador ya abatió a Garl en el Refugio 15, el secuestro ocurre como **represalia de los Khans supervivientes** por la muerte de Garl (desbloqueando además la opción de intimidarlos recordándoles que tú mataste a Garl); si aún no ha ido al Refugio 15, ocurre bajo las órdenes de Garl sin interferir con el combate del Refugio 15.
  - **NPCs Aliados Esenciales**: Todos los personajes con nombre que intervienen en misiones presentes o futuras (**Aradesh**, **Tandi**, **Seth**, **Razlo**, **Jarvis**, **Ian**, **Albóndiga**, **Killian**, **Lars**, **Tycho**, **Irwin**, **Harold**, **Butch Harris**, **Diana**, **Gwen**, **Cabbot**, **Talus**, **Gabriel**, **Smitty**, **Nicole**, **Set**, **Garret**, **Líder Subterráneo**, **Jacoren** y residentes del Refugio 13) cuentan con flag **Essential (`0x02`) + Protected (`0x800`)**.

---

## 1. Lo que YA está implementado y operativo en el Capítulo 1
- [x] **Prólogo en el Archivo Mnemosyne y Refugio 13 (`CELL 0x01002000`, `0x01002100`, `0x01002200`)**:
  - Supervisor **Jacoren**, **Oficial Lyle**, **Ingeniero Calvin**, **Supervisora Cindy**, **Técnica Theresa**, **Oficial Médico** (comerciante), **Guardia Ed** y trabajadores del Atrio.
  - Cueva de salida con el cadáver del explorador **Ed** (*«Ed está muerto»*), ratas topo y mutarachas.
  - **Sub-tramas internas del Refugio 13**: La facción rebelde de **Theresa** («Salir a la superficie») y el robo de raciones de agua descubierto por **Cindy** y **Lyle**.
- [x] **Shady Sands — Parte 1: Los Mutascorpiones y el Antídoto de Jarvis (`V13SideQuestShadySandsScript.psc`)**:
  - **Aradesh**, **Tandi**, **Seth**, **Dr. Razlo** (médico y comerciante), **Jarvis** (envenenado), **Ian** y **Albóndiga (Dogmeat 2161)**.
  - Caza del **Mutascorpión Emperador**, síntesis del antídoto con el **Dr. Razlo**, curación de **Jarvis** y recompensa de **Aradesh**.
- [x] **Refugio 15 y Paso Oriental de los Khans (`V13Act1QuestScript.psc`, `V13SideQuestKhansScript.psc`)**:
  - Exploración de las ruinas subterráneas del Refugio 15, combate contra **Garl Mano Muerta** y recuperación de la **Holocinta Hidrológica del Refugio 15** (que triangula el **Refugio 12 en Necrópolis**).
  - Rescate de las exploradoras **Diana** y **Gwen** frente al carcelero Khan **Tolan**.
- [x] **Ciudad Chatarra / Junktown — Parte 1: El Sicario de Gizmo (`V13SideQuestJunktownScript.psc`)**:
  - Alcalde **Killian Darkwater** (comerciante), **Capitán Lars**, **Ranger Tycho** y el asesino **Kenji** con el contrato de Gizmo.
- [x] **El Eje / The Hub — Parte 1: La Granja de Irwin y Radio El Eje (`V13SideQuestHubScript.psc`)**:
  - **Irwin**, el viejo mutante **Harold**, **Butch Harris** (comerciante) y el caudillo saqueador **Krag**; recompensa de la mítica **Pistola del .223 («Esa Arma»)**.
  - **Radio El Eje (84.5 kHz)** con 12 boletines de noticias de 2161 y canciones clásicas.
- [x] **Necrópolis / Bakersfield y el Refugio 12 (`V13Act2QuestScript.psc`)**:
  - **Set** y **Garret** (comerciante) en La Sala de los Muertos; **Líder de los Subterráneos** y el mecánico **Ezequiel** en las Alcantarillas; reparación de la **Gran Bomba de Agua de Necrópolis**; confrontación con el supermutante **Harry** en La Cuenca (farol de humano puro, ciencia, intimidación o combate); extracción del **Chip de Agua** en el Refugio 12 y regreso triunfal al **Refugio 13**.
- [x] **Encuentros Especiales del Yermo (3 de 6 completados en `V13SideQuestTardisScript.psc`)**:
  - [x] **1. La TARDIS (Cabina Policial Británica)** -> Sensor de Movimiento.
  - [x] **2. El Camión de Nuka-Cola Volcado** -> Chapas según Suerte (`1000 + Luck * 976`).
  - [x] **3. El Platillo Volante Estrellado (OVNI del Área 51)** -> Bláster Alienígena y Cuadro de Terciopelo de **Elvis («El Rey»)**.

---

## 2. Bloques Pendientes por Añadir para Completar el Capítulo 1 al 100 %

### Bloque A — Shady Sands y los Khans: El Secuestro y Rescate de Tandi (`QUST 0x01018000` — COMPLETADO)
- [x] **Activación tras curar a Jarvis / limpiar los mutascorpiones (`V13SideQuestTandiRescueScript.psc`)**:
  - Al completar la misión de los mutascorpiones y salvar a Jarvis (`Stage 40` de `V13SideQuestShadySands`), se activa automáticamente `V13SideQuestTandiRescue` (`Stage 15`), trasladando a **Tandi (`0x010035A1`)** a la cabaña de detención del Campamento del Cañón de los Khans (`(6400, 11180, 206)`) bajo la vigilancia del **Lugarteniente Petrox (`0x010035D8`)** y dos escoltas (`0x010035D9`, `0x010035DA`), con reactividad total a si **Garl Mano Muerta (`0x01002559`)** ya fue eliminado en el Refugio 15 o sigue con vida.
- [x] **Las 4 vías clásicas de rescate de *Fallout 1* en el Campamento Khan (`(6400, 11000, 200)`)**:
  - [x] **1. Persuasión / Intimidación (`Stage 26`)**: Convencer o intimidar a Petrox en diálogo (con éxito inmediato y mensaje reactivo si ya abatiste a Garl Mano Muerta en el Refugio 15).
  - [x] **2. Pago de rescate de 500 chapas (`Stage 27`)**: Comprar pacíficamente la llave de la celda a Petrox (con reembolso íntegro de las 500 chapas + 600 chapas adicionales por parte de Aradesh al regresar).
  - [x] **3. Combate directo (`Stage 28`)**: Desafiar o abatir a Petrox y sus escoltas y tomar la **Llave de los Grilletes y Celda de Tandi (`0x01001459`)**.
  - [x] **4. Sigilo y Ganzúa (`Stage 29` — `V13TandiCellReleaseScript.psc`)**: Rodear la cabaña sin negociar y forzar el **Cerrojo de Retención de Tandi (`0x010035DB`)** con una horquilla para liberar a Tandi en silencio.

### Bloque B — Compañeros Reclutables Clásicos: *Ian* y *Tycho* (COMPLETADO)
- [x] **Reclutamiento de Ian en Shady Sands (`0x010035A4` — `MesgV13IanRecruitMenu` `0x010011C2` / `MesgV13IanCommandMenu` `0x010011C3`)**:
  - Contratación por **100 chapas** o persuasión gratuita; armado con su clásica **Pistola Colt 6520 de 10 mm (`0x01001102`)** y cazadora de cuero, con menú táctico completo (seguir de cerca, modo comando, compartir munición de 10 mm y suministros, inventario, esperar, regresar a Shady Sands).
- [x] **Reclutamiento del Ranger Tycho en Junktown (`0x010035C2` — `MesgV13TychoRecruitMenu` `0x010011C4` / `MesgV13TychoCommandMenu` `0x010011C5`)**:
  - Unión al grupo con su **Escopeta de Combate (`0x0014831C`)** y uniforme de **Ranger del Desierto**, manteniendo accesible su escena doblada sobre Junktown y permitiendo viajar simultáneamente con **Ian, Tycho y Albóndiga** en formación táctica sin solapamientos por todo el Sur de California y todos los interiores del mod.

### Bloque C — Ciudad Chatarra (Junktown): Gizmo en Persona, Los Cráneos (*The Skulz*) y Doc Morbid
- [x] **1. Gizmo en persona y la Confesión Grabada** (`QUST 0x01019000` `V13SideQuestJunktownSyndicate`, `V13SideQuestJunktownSyndicateScript.psc`):
  - Añadido el jefe mafioso **Gizmo (`0x010035DE`, `NPC_V13_GizmoBoss` `0x01001257`)** y su guardaespaldas **Izo (`0x010035DF`, `NPC_V13_IzoBodyguard` `0x01001258`)** en su despacho ejecutivo del Casino de Junktown (`SCEN 0x01019100`), permitiendo obtener la **Cinta de Confesión de Voz de Gizmo (`0x0100145A`)** por 3 vías clásicas: engañar a Gizmo para que confiese en voz alta ante el micrófono oculto (`Stage 26`), deslizar el micrófono oculto en sigilo en su escritorio (`Stage 27`), o enfrentarse a Gizmo e Izo en combate directo (`Stage 28`).
- [x] **2. La banda de Los Cráneos (*The Skulz*) y la urna de Neal**:
  - Añadidos el barman **Neal (`0x010035DC`, `NPC_V13_NealBartender` `0x01001259`)** en la taberna *La Espumadera (Skum Pitt)* (`SCEN 0x01019101`) y **Vinnie (`0x010035EC`, `NPC_V13_VinnieSkulzLeader` `0x0100125A`)**, líder de *Los Cráneos* (`SCEN 0x01019102`), permitiendo recuperar la **Urna de las Cenizas de la Esposa de Neal (`0x0100145B`)** y el **Expediente del Sindicato (`0x01001C83`)** por intimidación (`Stage 22`), infiltración/sigilo (`Stage 23`) o combate (`Stage 24`), y devolvérsela a Neal junto con la confesión de Gizmo (`Stage 40`, +650 chapas, munición y +450 XP).
- [x] **3. Doc Morbid y el secreto de *Bob's Iguana Bits***:
  - Añadido **Doc Morbid (`0x010035DD`, `NPC_V13_DocMorbid` `0x0100125B`)** en la Clínica Sur de Junktown (`SCEN 0x01019103`) junto a su **Arcón Frigorífico Clandestino (`0x010035E5`, `ContV13DocMorbidCooler` `0x0100117F`)** con el **Libro de Envíos Clandestinos (`0x0100145C`)** y el **Albarán de Suministro Especial para Iguana Bob (`0x01001C84`)**, ofreciendo tanto curación médica completa como la vía opcional de confrontarlo por su tráfico de «carne especial» hacia El Eje (`Stage 25`, +250 chapas, Estimulantes, RadAway y +200 XP).

### Bloque D — El Eje (The Hub): Mercaderes del Agua, Caravanas Desaparecidas y el Submundo (`QUST 0x0101A000` — COMPLETADO)
- [x] **1. Los Mercaderes del Agua (*Water Merchants*) — Enviar Caravana de Agua al Refugio 13**:
  - Añadida la **Maestra del Agua Martha Rastello (`0x010035E6`, `NPC_V13_MarthaRastello` `0x0100125C`)** junto a la Torre de los Mercaderes del Agua en El Eje (`SCEN 0x0101A100`), permitiendo contratar una caravana cisterna de emergencia (o negociar descuento tras ayudar a Butch Harris) y obtener el **Contrato de Caravana de Agua al Refugio 13 (`0x0100145D`)** y su **Albarán Oficial (`0x01001C85`)** (`Stage 21`, +100 días de reserva con advertencia estratégica sobre la seguridad del Refugio 13).
- [x] **2. Las Caravanas Desaparecidas: La Guarida del Sanguinario y el Supermutante Moribundo**:
  - Añadida la **Guarida del Sanguinario de las Caravanas Perdidas (`0x010035EA`, `NPC_V13_HubCaravanDeathclaw` `0x0100125D`)** en el paso rocoso al oeste de El Eje y el supermutante agonizante **Tug (`0x010035EB`, `NPC_V13_DyingSuperMutant` `0x0100125E`)** (`SCEN 0x0101A101`), de quien se obtiene el **Holodisco de Transmisiones Mutantes (`0x0100145E`)** y su **Transcripción (`0x01001C86`)** (`Stage 25`, primer gran indicio del ejército de la Unidad y las cubas del norte).
- [x] **3. El Submundo de El Eje: *Decker* y *Kane* vs. el *Sheriff Justin Greene***:
  - Añadidos el **Sheriff Justin Greene (`0x010035E7`, `NPC_V13_SheriffJustinGreene` `0x0100125F`)** en la plaza central de El Eje (`SCEN 0x0101A102`), el jefe criminal **Decker (`0x010035E8`, `NPC_V13_DeckerBoss` `0x01001260`)** (`SCEN 0x0101A103`) y su lugarteniente **Kane (`0x010035E9`, `NPC_V13_KaneEnforcer` `0x01001261`)** en *El Halcón Maltés*, permitiendo recuperar el **Libro Mayor del Submundo de Decker (`0x0100145F`)** y su **Dossier (`0x01001C87`)** por infiltración/engaño (`Stage 26`, +300 chapas de adelanto), chantaje policial (`Stage 27`) o combate (`Stage 28`), y entregar ambas pruebas al Sheriff Greene (`Stage 40`, +700 chapas, munición y +500 XP).

### Bloque E — Necrópolis: Barry, Sally, el Prisionero Necrófago y el Dilema de la Bomba (COMPLETADO)
- [x] **Barry, Sally y el Prisionero Necrófago en La Cuenca** (`CELL 0x01002900`, `V13Act2QuestScript.psc`):
  - Añadidos con nombre propio y atributos dedicados los dos compañeros supermutantes clásicos de Harry en La Cuenca: **Barry (`0x01002A12`, `NPC_V13_BarrySuperMutant` `0x01001262`)** y **Sally (`0x01002A20`, `NPC_V13_SallySuperMutant` `0x01001263`)**, junto al **Prisionero Necrófago de La Cuenca (`0x01002918`, `NPC_V13_WatershedGhoulPrisoner` `0x01001264`)** retenido en la estación de bombeo, quien advierte al jugador en voz baja sobre las órdenes del Teniente Lou (`INFO 0x0100502C`) y, al neutralizar o engañar a Harry, Barry y Sally, queda libre y entrega su **Testimonio del Prisionero (`0x01001C88`)**, RadAway, Estimulantes y +150 XP (`INFO 0x0100502D`, `DIAL 0x0100504F`).
- [x] **Reconocimiento del Dilema de la Gran Bomba de Agua**:
  - Añadidos el reconocimiento explícito de los necrófagos de Necrópolis (`INFO 0x0100502E`) y el documento **Pacto Hidrológico de Necrópolis: Dos Refugios Salvados (`0x01001C89`)** (+200 chapas, Agua Purificada y +200 XP) al reparar la Gran Bomba de Agua de La Cuenca antes de extraer el Chip de Agua del Refugio 12, resolviendo el dilema moral clásico de *Fallout 1* para que Necrópolis no muera de sed tras la partida del Morador del Refugio.

### Bloque F — Los 3 Encuentros Especiales Restantes de *Fallout 1* (6 de 6 — COMPLETADO)
- [x] **4. La Huella Gigante de Godzilla (*Giant Footprint*, `QUST 0x0101B000` `V13SideQuestGiantFootprint`)**:
  - Gran huella prehistórica hundida en el desierto al norte de Arenas Sombrías (`0x01003561`, `ActiV13GiantFootprint` `0x010011AF`, marcador de mapa `0x01003424`) con el cadáver aplastado de un viajero (`0x01003560`, `NPC_V13_FootprintVictim` `0x01001265`) que porta un **RobCo Stealth Boy 3001 (`0x01001460`)**, dos Chicos Sigilosos operativos (`0x0004F4A6`), el **Diario Aplastado de la Huella Gigante (`0x01001C8A`)** y el **Terminal de Prospección Paleontológica (`0x01003562`, `TermV13GiantFootprintDesk` `0x010011B0`)** (+350 XP).
- [x] **5. El Concesionario de Coches Usados de Bob (*Bob's Pre-Owned Car Mart*, `QUST 0x0101C000` `V13SideQuestBobsCarMart`)**:
  - Desguace-concesionario abandonado en el desierto al sureste de Ciudad Chatarra (`0x01003565`, `ActiV13BobsCarMartSign` `0x010011B1`, marcador de mapa `0x01003425`) con vehículos Corvega de ocasión, la **Caja Fuerte de Exposición de Bob (`0x01003566`, `ContV13BobsRedRyderCase` `0x010011B4`)**, el **Terminal Comercial (`0x01003567`, `TermV13BobsCarMartDesk` `0x010011B2`)**, el **Catálogo del Concesionario (`0x01001C8B`)** y la legendaria carabina **Red Ryder LE BB Gun (`0x0100356A`, `WeapV13RedRyderLEBBGun` `0x01001117`)** (+350 chapas, munición y +400 XP).
- [x] **6. Patrick el Celta (*El Bardo Viajero*, `QUST 0x0101D000` `V13SideQuestPatrickCelt`)**:
  - Viajero solitario (`0x01003570`, `NPC_V13_PatrickTheCelt` `0x01001266`) junto a su hoguera en el desierto al norte de El Eje (`0x01003571`, `ActiV13PatrickCeltCamp` `0x010011B5`, marcador de mapa `0x01003426`) que conversa en una rueda de diálogo doblada (`SCEN 0x0101D100`, `DIAL 0x0101D001`) sobre las rutas de Nueva California, entona la balada tradicional gaélica de *Na Fianna*, entrega su **Medallón Gaélico (`0x01001462`)** y su **Cancionero (`0x01001C8C`)**, y otorga **+1 Carisma permanente** (+350 XP).

---

### Auditoría Automatizada de Calidad (QA) — Pre-Lanzamiento y Pre-Traducción EN
- [x] **Batería de 6 Módulos de Auditoría (`audit_qa_cronicas_refugio_13.py`) — 20/20 Checks Superados (`0` Advertencias, `0` Errores)**:
  - **Módulo 1 (Integridad Binaria `.esp` y Punteros Cruzados)**: Cabecera `TES4` (`HEDR v1.00`, `MAST = ['Fallout4.esm']`), `0` colisiones entre `36.249` registros propios (`>= 0x01000800`) y `100%` de referencias cruzadas válidas contra los `1.549.277` registros de `Fallout4.esm` (corregidos 2 `STAT` de escenario en el huerto de Shady Sands y la caseta del Concesionario de Bob).
  - **Módulo 2 (Lógica de Misiones `QUST` y Sincronización con Papyrus)**: `21` misiones con todos sus Alias Forzados (`ALFR`) apuntando a referencias `Persistent` (`0x0400`) y `50` scripts `.psc`/`.pex` con `1.851` llamadas (`GetFormFromFile`, `SetStage`, `SetObjective`, `ForceQuestAlias`) sincronizadas 1:1.
  - **Módulo 3 (Interacciones con NPCs, Ruedas `SCEN` y Voces `.xwm`)**: `43` escenas de rueda de diálogo (`PTOP`/`NTOP`/`NETO`/`QTOP` + `NPOT`/`NNGT`/`NNUT`/`NQUT` + `RNAM`), `1.020` clips de voz `.xwm` verificados 1:1 en `Main.ba2` con cabecera `RIFF/XWMA` íntegra, `79` registros `NPC_` propios y `5` facciones de comerciantes (`FACT`/`VENC`).
  - **Módulo 4 (Geometría 3D, Terreno `LAND` y Zonas Seguras)**: `64/64` celdas exteriores con terreno `LAND` (`VHGT`/`VNML`), `23` `MapMarkers`, `83` actores exteriores alineados con el terreno (`0` flotando/enterrados y `0` solapamientos `< 65` uds), `12` terminales y `11` documentos apoyados sobre sus escritorios, y `27` criaturas errantes fuera del radio de seguridad (`> 1.150` uds) de asentamientos.
  - **Módulo 5 (Archivos `.ba2` v1 y Cadena `NIF -> BGSM/BGEM -> DDS`)**: `Main.ba2` (`1.222` archivos, `BTDX v1 GNRL`) y `Textures.ba2` (`30` texturas DDS, `BTDX v1 DX10`) verificados sin activos huérfanos.
  - **Módulo 6 (Diagnóstico de `Papyrus.0.log`)**: `0` errores de ejecución en scripts de `Vault13Chronicles.esp`.

---

### Edición Completa 100% en Inglés (`edition_en/build_out/`) — Texturas, Carteles, Scripts, Textos y Voces
- [x] **1. Texturas, Mapas, Carteles y Calcomanías 3D en Inglés (`edition_en/generate_v13_textures_en.py`)**:
  - **Mapa Táctico del Sur de California para el Pip-Boy (`V13CaliforniaWorldMap_d.dds`, `2048x2048` BC1)**: Cabecera en inglés (*`VAULT-TEC INDUSTRIES — SOUTHERN CALIFORNIA TACTICAL MAP (2161)`*) y las 19 etiquetas geográficas/regionales traducidas al inglés canónico de *Fallout 1*.
  - **7 Placas y Carteles de Localizaciones 3D (`1024x1024` BC1, 11 mipmaps)**: `VltSignWatershed12_d.dds` (*`THE WATERSHED — VAULT 12 PURIFICATION STATION`*), `VltSignNecropolis_d.dds` (*`NECROPOLIS — CITY OF THE DEAD`*), `VltSignVault15Map_d.dds` (*`VAULT 15 — KHAN TERRITORY & BURIED RUINS`*), `VltSignLostHilMap_d.dds` (*`LOST HILLS — BROTHERHOOD OF STEEL BUNKER`*), `VltSignMariposMap_d.dds` (*`MARIPOSA — MILITARY BASE & FEV VATS`*), `VltSignCathedrMap_d.dds` (*`THE CATHEDRAL — CHILDREN OF THE CATHEDRAL`*) y `VltSignTemporaMap_d.dds` (*`VAULT 111 (2287) — MNEMOSYNE TEMPORAL BRIDGE`*).
  - **Armario de Intendencia del Refugio 13 (`GarageCabinet13_d.dds`, `1024x1024` BC1, 11 mipmaps)**: Rótulos horizontales y verticales de puertas y cajones traducidos íntegramente al inglés (*`VAULT 13`, `QUARTERMASTER`, `WATER SUPPLY`, `RATIONING`, `10MM AMMO`, `STIMPAKS`, `RADAWAY`, `PURIFICATION CHIPS`*).
  - **Cuadro de Terciopelo de «El Rey» (`ElvisVelvetPainting_d.dds`, `1024x1024` BC1, 11 mipmaps)**: Leyenda frontal (*`THE KING — ELVIS (LAS VEGAS • 2077)`*), estrellas doradas de 5 puntas y sello trasero del Área 51 en inglés (*`VELVET PAINTING OF THE KING — AREA 51 PROPERTY (1997)`*).
- [x] **2. Compilación de los 50 Scripts Papyrus en Inglés (`edition_en/sync_papyrus_en.py` -> `edition_en/papyrus_out/*.pex`)**:
  - Sincronizados los 50 archivos `.psc` (`218` cadenas de notificación y avisos en pantalla traducidas al inglés canónico de *Fallout 1*) y compilados los `50/50` binarios `.pex` con `PapyrusCompiler.exe` (`0` errores).
- [x] **3. Traducción Completa del Plugin `Vault13Chronicles.esp` (`edition_en/translations_en.json` + `edition_en/build_cronicas_refugio_13_en.py`)**:
  - Traducidos al inglés canónico de *Fallout 1 (1997)* los `2.299` subregistros de texto del plugin (`TES4 SNAM`, `ACTI FULL/ATTX`, `ARMO FULL/DESC`, `BOOK FULL/DESC`, `CELL FULL`, `CONT FULL`, `DIAL FULL`, `DOOR FULL`, `ENCH FULL`, `INFO NAM1/RNAM`, `LCTN FULL`, `MESG FULL/DESC/ITXT`, `MGEF FULL`, `MISC FULL`, `NPC_ FULL/SHRT`, `QUST FULL/CNAM/NNAM`, `REFR FULL`, `TERM FULL/NAM0/WNAM/ITXT/RNAM/UNAM`, `WEAP FULL/DESC`, `WRLD FULL`), manteniendo paridad binaria 100% exacta en FormIDs, celdas, NavMeshes y lógica de misiones respecto a la edición en español.
- [x] **4. Síntesis Completa de Voces en Inglés y *The Hub Radio (84.5)* (`edition_en/synthesize_voices_and_radio_en.py`)**:
  - Generados y empaquetados los **1.061 archivos de voz en inglés (`.xwm`)** con ElevenLabs Pro a través de los 9 tipos de voz (`NPCMOverseerJacoren`, `PlayerVoiceMale01`, `PlayerVoiceFemale01`, `NPCMVault13Resident`, `NPCFVault13Resident`, `NPCMUndergroundLeader`, `NPCMSetNecropolis`, `V13HarrySuperMutantVoice` / `CrSuperMutant`), incluyendo las mezclas de efectos de sonido de las turbinas/bombas de agua y el procesado vocal de supermutante para Harry.
  - Generadas las **24 locuciones en inglés de *The Hub Radio (84.5)* (`v13_radio_dj_01..24.xwm`)** e integradas junto con las 23 canciones en `edition_en/build_out/Vault13Chronicles - Main.ba2`.
- [x] **5. Auditoría QA Dual Superada (`audit_qa_cronicas_refugio_13.py` y `audit_qa_cronicas_refugio_13.py --en`)**:
  - **Edición en Español (`build_out/`)**: `20/20` Checks Superados, `0` Advertencias, `0` Errores.
  - **Edición en Inglés (`edition_en/build_out/`)**: `21/21` Checks Superados (incluyendo el Check 21 de Integridad de Localización Inglesa sobre los `2.299` subregistros de texto y `50` scripts `.pex`), `0` Advertencias, `0` Errores.

