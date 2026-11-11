# -*- coding: utf-8 -*-
"""
Synchronizes all 50 Papyrus scripts from `cronicas_refugio_13/papyrus_src/*.psc` into
`cronicas_refugio_13/edition_en/papyrus_src/*.psc` with 100% canonical Fallout 1 English strings,
and compiles all 50 `.psc` files into `cronicas_refugio_13/edition_en/papyrus_out/*.pex`.
"""

import os
import subprocess

THIS_DIR = os.path.dirname(os.path.abspath(__file__))
ES_ROOT_DIR = os.path.dirname(THIS_DIR)
ES_PSC_DIR = os.path.join(ES_ROOT_DIR, "papyrus_src")
EN_PSC_DIR = os.path.join(THIS_DIR, "papyrus_src")
EN_PEX_DIR = os.path.join(THIS_DIR, "papyrus_out")

FO4_ROOT = r"C:\Program Files (x86)\Steam\steamapps\common\Fallout 4"
FO4_DATA_DIR = os.path.join(FO4_ROOT, "Data")
PAPYRUS_COMPILER = os.path.join(FO4_ROOT, "Papyrus Compiler", "PapyrusCompiler.exe")

PSC_LINE_TRANSLATIONS: dict[str, str] = {
    # V13Act1QuestScript.psc
    'Debug.Notification("[Terminal de Seguridad] ¡Contraseña aceptada! Esclusas blindadas del sector Khan desbloqueadas y abiertas.")':
        'Debug.Notification("[Security Terminal] Password accepted! Khan sector reinforced blast doors unlocked and opened.")',
    'Debug.Notification("[Supervisor Jacoren]: \'Inserta la Holocinta Hidrológica del Refugio 15 en mi Consola de Mando para decodificar la red de Vault-Tec.\'")':
        'Debug.Notification("[Overseer Jacoren]: \'Insert the Vault 15 Hydrological Survey Holotape into my Command Console to decode the Vault-Tec network.\'")',
    'Debug.Notification("[Supervisor Jacoren]: \'¡La holocinta confirma que el Chip de Agua del Refugio 12 sigue activo bajo Bakersfield! Habla conmigo.\'")':
        'Debug.Notification("[Overseer Jacoren]: \'The holotape confirms Vault 12\'s Water Chip is still active beneath Bakersfield! Talk to me.\'")',
    'Debug.Notification("[Consola del Supervisor] Necesitas recuperar primero la Holocinta Hidrológica del Refugio 15.")':
        'Debug.Notification("[Overseer Console] You must first recover the Vault 15 Hydrological Survey Holotape.")',
    'Debug.Notification("[Consola del Supervisor] Holocinta del Refugio 15 ya decodificada: Coordenadas del Refugio 12 (Necrópolis) listas.")':
        'Debug.Notification("[Overseer Console] Vault 15 Holotape already decoded: Vault 12 (Necropolis) coordinates locked.")',
    'Debug.Notification("[Computadora Central del Refugio 13] ¡Holocinta Hidrológica del Refugio 15 leída! Triangulando la red regional de Vault-Tec...")':
        'Debug.Notification("[Vault 13 Mainframe] Vault 15 Hydrological Survey Holotape read! Triangulating regional Vault-Tec network...")',
    'Debug.Notification("[Telemetría Vault-Tec] ¡SEÑAL PORTADORA ACTIVA DETECTADA! Refugio 12 localizado bajo Bakersfield («Necrópolis»).")':
        'Debug.Notification("[Vault-Tec Telemetry] ACTIVE CARRIER SIGNAL DETECTED! Vault 12 located beneath Bakersfield (\'Necropolis\').")',
    'Debug.Notification("[Archivo Mnemosyne] ¡Puerta Dimensional/Temporal activada! Cruza la esclusa hacia el Refugio 13 (5 Dic 2161).")':
        'Debug.Notification("[Mnemosyne Archive] Dimensional/Temporal Bridge activated! Step through the airlock into Vault 13 (Dec 5, 2161).")',
    'Debug.Notification("[Refugio 15 - Diciembre de 2161] Has entrado en los niveles subterráneos del Refugio 15.")':
        'Debug.Notification("[Vault 15 - December 2161] You have entered the underground levels of Vault 15.")',
    'Debug.Notification("[Refugio 13 - 5 Dic 2161] Mono blindado del Refugio 13 y raciones de campaña entregados.")':
        'Debug.Notification("[Vault 13 - Dec 5, 2161] Armored Vault 13 Jumpsuit and field rations issued.")',
    'Debug.Notification("[Crónicas del Refugio 13] Núcleo hidrologístico del Refugio 15 analizado. ¡Pistola Colt 6520 de 10 mm desbloqueada!")':
        'Debug.Notification("[Vault 13 Chronicles] Vault 15 hydrological core analyzed. Colt 6520 10mm Pistol unlocked!")',
    'Debug.Notification("[Colt 6520 - 2161] ¡Ráfaga de 10 mm sobrecargada! (+25 PA)")':
        'Debug.Notification("[Colt 6520 - 2161] Overcharged 10mm burst! (+25 AP)")',
    'Debug.Notification("[Colt 6520 10 mm] Pistola reglamentaria del Refugio 13 lista: Descarga cinética cada 3 impactos (+25 PA)")':
        'Debug.Notification("[Colt 6520 10mm] Standard-issue Vault 13 sidearm ready: Kinetic discharge every 3 hits (+25 AP)")',
    'Debug.Notification("[Bláster Alienígena - Área 51] Arma extraterrestre de Fallout 1 activa: Sobrecarga de plasma cada 3 impactos (+35 PA / +25 PS)")':
        'Debug.Notification("[Alien Blaster - Area 51] Fallout 1 extraterrestrial weapon active: Plasma overload every 3 hits (+35 AP / +25 HP)")',
    'Debug.Notification("[Red Ryder LE BB Gun] Carabina de edición limitada de Bob lista: Impacto crítico perforante cada 4 disparos (+25 PA / +15 PS)")':
        'Debug.Notification("[Red Ryder LE BB Gun] Bob\'s limited-edition carbine ready: Armor-piercing critical strike every 4 shots (+25 AP / +15 HP)")',
    'Debug.Notification("[Pip-Boy 2000] Mapa del Sur de California (2161) activo. Viaje rápido habilitado entre localizaciones visitadas.")':
        'Debug.Notification("[Pip-Boy 2000] Southern California (2161) World Map active. Fast travel enabled between discovered locations.")',
    'Debug.Notification("[Archivo Mnemosyne - 2287] Has regresado a la Commonwealth. Tu progreso en 2161 se conserva intacto para cuando vuelvas.")':
        'Debug.Notification("[Mnemosyne Archive - 2287] You have returned to the Commonwealth. Your 2161 progress is preserved for whenever you return.")',

    # V13Act2QuestScript.psc
    'Debug.Notification("[Refugio 13] ¡Rebelión de Theresa calmada y crisis de agua de Cindy resuelta! Esclusa a Necrópolis desbloqueada (+200 PE).")':
        'Debug.Notification("[Vault 13] Theresa\'s mutiny calmed and Cindy\'s water crisis resolved! Airlock to Necropolis unlocked (+200 XP).")',
    'Debug.Notification("[Theresa]: \'¡Abrid la puerta del Refugio 13! ¡El Refugio 15 está en ruinas y no vamos a esperar aquí a morir de sed!\'")':
        'Debug.Notification("[Theresa]: \'Open the Vault 13 door! Vault 15 is in ruins and we aren\'t going to wait in here to die of thirst!\'")',
    'Debug.Notification("[Oficial Lyle]: \'¡Atrás, Theresa! ¡Y tú, Cindy, suelta esos frascos de agua robados del depósito! ¡Morador, ayúdame a calmarlas!\'")':
        'Debug.Notification("[Officer Lyle]: \'Stand back, Theresa! And you, Cindy, put down those stolen water flasks! Vault Dweller, help me calm them down!\'")',
    'Debug.Notification("[La Cuenca — Refugio 12] ¡Prisionero necrófago liberado tras neutralizar a Harry, Barry y Sally! (+Testimonio del Prisionero / +2 RadAway / +2 Estimulantes / +150 PE)")':
        'Debug.Notification("[The Watershed — Vault 12] Ghoul Prisoner freed after neutralizing Harry, Barry, and Sally! (+Prisoner\'s Testimony / +2 RadAway / +2 Stimpaks / +150 XP)")',
    'Debug.Notification("[Pacto Hidrológico de Necrópolis] ¡Dilema del Agua resuelto! Al reparar la Gran Bomba antes de extraer el Chip, has salvado tanto al Refugio 13 como a Necrópolis (+200 chapas / +200 PE).")':
        'Debug.Notification("[Necropolis Hydrological Pact] Water Dilemma resolved! By repairing the Great Water Pump before extracting the Chip, you saved both Vault 13 and Necropolis (+200 Caps / +200 XP).")',
    'Debug.Notification("[Refugio 12] ¡Chip de Purificación de Agua extraído! Sube por la Escalerilla de Salida al Yermo (aquí mismo) y regresa al Refugio 13.")':
        'Debug.Notification("[Vault 12] Water Purification Chip extracted! Climb the Surface Exit Ladder right here and return to Vault 13.")',
    'Debug.Notification("[Necrópolis] Has recuperado las Piezas Hidráulicas (Junk Parts). Dirígete a la Plaza de Bombeo de la Cuenca e instálalas en la Gran Bomba de Agua.")':
        'Debug.Notification("[Necropolis] You recovered the Hydraulic Junk Parts! Head to the Watershed Pumping Plaza and install them in the Great Water Pump.")',
    'Debug.Notification("[Alcantarillas de Necrópolis] Clave del Capataz Ezequiel obtenida: 2161-AGUA-12. Avanza hacia el Taller Hidráulico al oeste.")':
        'Debug.Notification("[Necropolis Sewers] Foreman Ezekiel\'s passcode obtained: 2161-WATER-12. Proceed to the Hydraulic Workshop to the west.")',
    'Debug.Notification("[Alcantarillas de Necrópolis] ¡Contraseña aceptada (2161-AGUA-12)! Taller Hidráulico desbloqueado.")':
        'Debug.Notification("[Necropolis Sewers] Passcode accepted (2161-WATER-12)! Hydraulic Workshop unlocked.")',
    'Debug.Notification("[Cuenca de Necrópolis] ¡GRAN BOMBA DE AGUA REPARADA! Esclusa de la Estación del Refugio 12 desbloqueada.")':
        'Debug.Notification("[Necropolis Watershed] GREAT WATER PUMP REPAIRED! Vault 12 Purification Station airlock unlocked.")',
    'Debug.Notification("[Moradores del Refugio 13]: \'¡Hurra! ¡Agua pura en los conductos! ¡Viva el Morador del Refugio!\'")':
        'Debug.Notification("[Vault 13 Dwellers]: \'Hooray! Pure water in the conduits! Long live the Vault Dweller!\'")',
    'Debug.Notification("[Procesador Central del Refugio 13] ¡CHIP DE AGUA ACOPLADO! ¡Las turbinas purificadoras vuelven a girar al 100% y el agua limpia fluye de nuevo!")':
        'Debug.Notification("[Vault 13 Central Processor] WATER CHIP INSTALLED! The purification turbines are spinning at 100% and clean water flows again!")',
    'Debug.Notification("[Refugio 12 — Supermutante Harry] \'¡Nadie toca el agua de Lou! ¡Aplastad al humano, muchachos!\'")':
        'Debug.Notification("[Vault 12 — Super Mutant Harry] \'Nobody touches Lou\'s water! Smash the human, boys!\'")',
    'Debug.Notification("[Refugio 12] ¡Patrulla de Harry, Barry y Sally neutralizada y Cámara del Procesador desbloqueada! (+300 chapas / +300 PE)")':
        'Debug.Notification("[Vault 12] Harry, Barry, and Sally\'s patrol neutralized and Processor Chamber unlocked! (+300 Caps / +300 XP)")',
    'Debug.Notification("[Refugio 12] ¡Cámara del Procesador Central desbloqueada! Extrae el Chip de Agua de la Computadora del Refugio 12.")':
        'Debug.Notification("[Vault 12] Central Processor Chamber unlocked! Extract the Water Chip from the Vault 12 Computer.")',
    'Debug.Notification("[Supermutante Harry]: \'¡Eh, tú! ¡Tú no eres un necrófago, eres un humano normal! ¡Habla con Harry ahora mismo antes de que Harry, Barry y Sally te aplasten!\'")':
        'Debug.Notification("[Super Mutant Harry]: \'Hey, you! You\'re not a ghoul, you\'re a normal human! Talk to Harry right now before Harry, Barry, and Sally smash you!\'")',
    'Debug.Notification("[Prisionero Necrófago de La Cuenca]: \'¡Psst, humano! Harry, Barry y Sally custodian la puerta del Refugio 12 por orden de Lou. ¡Engáñalos o derrótalos!\'")':
        'Debug.Notification("[Watershed Ghoul Prisoner]: \'Psst, normal! Harry, Barry, and Sally guard the Vault 12 door on Lou\'s orders. Trick them or take them down!\'")',
    'Debug.Notification("[Capataz Ezequiel]: \'¡Argh, mi costado...! ¡Un morador del Refugio! Habla conmigo, tengo la clave del Taller Hidráulico.\'")':
        'Debug.Notification("[Foreman Ezekiel]: \'Argh, my side...! A Vault Dweller! Talk to me, I have the passcode to the Hydraulic Workshop.\'")',
    'Debug.Notification("[Crónicas del Refugio 13] ¡Chip de Agua del Refugio 12 instalado! ¡Pistola \'.223\' desbloqueada!")':
        'Debug.Notification("[Vault 13 Chronicles] Vault 12 Water Chip installed! \'.223 Pistol\' unlocked!")',
    'Debug.Notification("[La Sala de los Muertos] ¡Garret ha desbloqueado el Baúl de Armería de Set! Recoge los suministros y sal hacia las alcantarillas.")':
        'Debug.Notification("[Hall of the Dead] Garret unlocked Set\'s Armory Chest! Collect the supplies and head into the sewers.")',
    'Debug.Notification("[Archivo Mnemosyne - 2287] Has regresado a la Commonwealth con el equipo y las reliquias de 2161.")':
        'Debug.Notification("[Mnemosyne Archive - 2287] You have returned to the Commonwealth with your 2161 gear and relics.")',
    'Debug.Notification("[Refugio 13] La Puerta Dimensional/Temporal en el Despacho del Supervisor queda abierta para regresar a la Commonwealth cuando quieras.")':
        'Debug.Notification("[Vault 13] The Dimensional/Temporal Bridge in the Overseer\'s Office remains open to return to the Commonwealth whenever you wish.")',
    'Debug.Notification("[Pistola .223] ¡Impacto perforante! (+30 PA / +15 PV)")':
        'Debug.Notification("[.223 Pistol] Armor-piercing round! (+30 AP / +15 HP)")',
    'Debug.Notification("[Pistola .223 - 2161] Revólver de rifle recortado activo: Derribo cada 3 impactos (+30 PA / +15 PV)")':
        'Debug.Notification("[.223 Pistol - 2161] Cut-down rifle revolver active: Knockdown every 3 hits (+30 AP / +15 HP)")',
    'Debug.Notification("[Cuenca de Necrópolis] Repara primero la Gran Bomba de Agua aquí fuera (junto a la consola de control) antes de entrar en la Estación de Purificación.")':
        'Debug.Notification("[Necropolis Watershed] First repair the Great Water Pump out here (next to the control console) before entering the Purification Station.")',
    'Debug.Notification("[Estación del Refugio 12] Los supermutantes Harry, Barry y Sally bloquean el paso. Habla con Harry o derrota a su patrulla para abrir la cámara del procesador.")':
        'Debug.Notification("[Vault 12 Station] Super Mutants Harry, Barry, and Sally block the way. Talk to Harry or defeat his patrol to open the processor chamber.")',
    'Debug.Notification("[Estación del Refugio 12] Extrae primero el Chip de Purificación de Agua de la Computadora del Refugio 12 antes de subir a la superficie.")':
        'Debug.Notification("[Vault 12 Station] First extract the Water Purification Chip from the Vault 12 Computer before climbing back to the surface.")',
    'Debug.Notification("[La Cuenca — Superficie] Has salido al Yermo del Sur de California con el Chip de Agua. Regresa al Refugio 13.")':
        'Debug.Notification("[The Watershed — Surface] You emerged into the Southern California Wasteland with the Water Chip. Return to Vault 13.")',
    'Debug.Notification("[Salto Directo QA] Acto II — Refugio 13 (Etapa 18: Crisis de Agua)")':
        'Debug.Notification("[QA Direct Jump] Act II — Vault 13 (Stage 18: Water Crisis)")',
    'Debug.Notification("[Salto Directo QA] Acto II — Entrada a Necrópolis (Etapa 20)")':
        'Debug.Notification("[QA Direct Jump] Act II — Necropolis Entrance (Stage 20)")',
    'Debug.Notification("[Salto Directo QA] Acto II — Junto a Set y Garret (Etapa 24: Rumbo a las Alcantarillas)")':
        'Debug.Notification("[QA Direct Jump] Act II — With Set & Garret (Stage 24: Bound for the Sewers)")',
    'Debug.Notification("[Salto Directo QA] Acto II — Junto a Ezequiel en las Alcantarillas (Etapa 24)")':
        'Debug.Notification("[QA Direct Jump] Act II — With Ezekiel in the Sewers (Stage 24)")',
    'Debug.Notification("[Salto Directo QA] Acto II — Gran Bomba de Agua con Piezas listas (Etapa 25)")':
        'Debug.Notification("[QA Direct Jump] Act II — Great Water Pump with Junk Parts ready (Stage 25)")',
    'Debug.Notification("[Salto Directo QA] Acto II — Estación del Refugio 12 frente a Harry (Etapa 26)")':
        'Debug.Notification("[QA Direct Jump] Act II — Vault 12 Station facing Harry (Stage 26)")',
    'Debug.Notification("[Salto Directo QA] Acto III — Lost Hills y Hermandad del Acero")':
        'Debug.Notification("[QA Direct Jump] Act III — Lost Hills & Brotherhood of Steel")',

    # V13Act3QuestScript.psc
    'Debug.Notification("[Crónicas del Refugio 13] ¡Holocinta de la escriba Vree decodificada! ¡Rifle láser Wattz 2000 desbloqueado!")':
        'Debug.Notification("[Vault 13 Chronicles] Scribe Vree\'s autopsy holotape decoded! Wattz 2000 Laser Rifle unlocked!")',
    'Debug.Notification("[Rifle láser Wattz 2000] ¡Sobrecarga óptica de Lost Hills! (+30 PA / +20 PV)")':
        'Debug.Notification("[Wattz 2000 Laser Rifle] Lost Hills optical overcharge! (+30 AP / +20 HP)")',
    'Debug.Notification("[Rifle láser Wattz 2000] Matriz óptica de Lost Hills activa: Sobrecarga cada 4 impactos (+30 PA / +20 PV)")':
        'Debug.Notification("[Wattz 2000 Laser Rifle] Lost Hills optical array active: Overcharge every 4 hits (+30 AP / +20 HP)")',

    # V13Act4QuestScript.psc
    'Debug.Notification("[Crónicas del Refugio 13] ¡Cubas VEF de Mariposa destruidas! ¡Rifle de plasma turbo Winchester P94 desbloqueado!")':
        'Debug.Notification("[Vault 13 Chronicles] Mariposa FEV Vats destroyed! Winchester P94 Turbo Plasma Rifle unlocked!")',
    'Debug.Notification("[Winchester P94] ¡Implosión de plasma turbo! (+35 PA / +25 PV)")':
        'Debug.Notification("[Winchester P94] Turbo plasma implosion! (+35 AP / +25 HP)")',
    'Debug.Notification("[Winchester P94] Lanzador de plasma turbo activo: Implosión toroidal cada 3 impactos (+35 PA / +25 PV)")':
        'Debug.Notification("[Winchester P94] Turbo plasma caster active: Toroidal implosion every 3 hits (+35 AP / +25 HP)")',

    # V13Act5QuestScript.psc
    'Debug.Notification("[Crónicas del Refugio 13] ¡Campaña completada! ¡Servoarmadura T-51f endurecida y Ametralladora Vindicator desbloqueadas!")':
        'Debug.Notification("[Vault 13 Chronicles] Campaign completed! Hardened T-51f Power Armor and Vindicator Minigun unlocked!")',
    'Debug.Notification("[Ametralladora Vindicator] ¡Onda de choque Rheinmetall! (+40 PA / +30 PV)")':
        'Debug.Notification("[Vindicator Minigun] Rheinmetall shockwave! (+40 AP / +30 HP)")',
    'Debug.Notification("[Ametralladora Vindicator - 2161] Supresor rotativo activo: Onda de choque cada 5 impactos (+40 PA / +30 PV)")':
        'Debug.Notification("[Vindicator Minigun - 2161] Rotary caseless suppressor active: Shockwave every 5 hits (+40 AP / +30 HP)")',

    # V13ChestAct2Script.psc, V13ItemRadscorpionGlandScript.psc, V13NecropolisWaterPumpScript.psc, V13RadioQuestScript.psc
    'Debug.Notification("[Refugio 12] ¡El Supermutante Harry custodia el Procesador Central! Habla con él o derrótalo primero.")':
        'Debug.Notification("[Vault 12] Super Mutant Harry guards the Central Processor! Talk to him or defeat him first.")',
    'Debug.Notification("«Un cuadro sobre terciopelo de \'El Rey\'. Verdaderamente una magnífica obra de arte.»")':
        'Debug.Notification("\'A velvet painting of The King. Truly a magnificent work of art.\'")',
    'Debug.Notification("[Cuenca de Necrópolis] Necesitas las Piezas Hidráulicas de Repuesto (\'Junk Parts\') perdidas en el tramo medio de las alcantarillas.")':
        'Debug.Notification("[Necropolis Watershed] You need the Spare Hydraulic Junk Parts lost in the middle section of the sewers.")',
    'Debug.Notification("[PIP-BOY 2000] Emisora activa: Radio El Eje — Nueva California (2161)")':
        'Debug.Notification("[PIP-BOY 2000] Active station: The Hub Radio — New California (2161)")',

    # V13SideQuestBoneyardScript.psc
    'Debug.Notification("Trasladado a Adytum y Gun Runners (El Boneyard, 2161). Habla con Gabriel, el armero Smitty o Nicole.")':
        'Debug.Notification("Traveled to Adytum & Gun Runners (The Boneyard, 2161). Speak with Gabriel, Smitty the gunsmith, or Nicole.")',
    'Debug.Notification("Misión Secundaria: El Nido de la Madre Sanguinario — Elimina a la Madre Sanguinario al norte de Adytum.")':
        'Debug.Notification("Side Quest: The Mother Deathclaw\'s Nest — Eliminate the Mother Deathclaw north of Adytum.")',
    'Debug.Notification("¡Madre Sanguinario abatida! Extrae la Garra Acorazada y el Huevo de su cadáver.")':
        'Debug.Notification("Mother Deathclaw slain! Extract the Armored Claw and Deathclaw Egg from her corpse.")',
    'Debug.Notification("Trofeo de la Madre Sanguinario obtenido. Entrégaselo al armero Smitty en Adytum.")':
        'Debug.Notification("Mother Deathclaw trophy obtained. Deliver it to Smitty the gunsmith in Adytum.")',
    'Debug.Notification("¡Smitty ha calibrado el rifle de plasma! Habla con Gabriel (Gun Runners) en Adytum.")':
        'Debug.Notification("Smitty calibrated the plasma rifle! Speak with Gabriel (Gun Runners) in Adytum.")',
    'Debug.Notification("¡Misión Secundaria completada: El Nido de la Madre Sanguinario! (+Rifle de Plasma Turbo P94, +600 Chapas y +400 XP)")':
        'Debug.Notification("Side Quest completed: The Mother Deathclaw\'s Nest! (+P94 Turbo Plasma Rifle, +600 Caps, and +400 XP)")',

    # V13SideQuestGlowScript.psc
    'Debug.Notification("Trasladado al Puesto Exterior de Lost Hills (2161). Habla con Cabbot o el Paladín Talus para la prueba de El Resplandor.")':
        'Debug.Notification("Traveled to the Lost Hills Surface Outpost (2161). Speak with Cabbot or Paladin Talus regarding the Trial of The Glow.")',
    'Debug.Notification("Misión Secundaria: El Resplandor (West Tek) — Destruye al Centinela ZAX-WT01 en el cráter al sur de Lost Hills.")':
        'Debug.Notification("Side Quest: The Glow (West Tek) — Destroy Sentinel ZAX-WT01 in the crater south of Lost Hills.")',
    'Debug.Notification("¡Centinela ZAX-WT01 abatido! Extrae el Holodisco del Sargento Dennis Allen de sus restos.")':
        'Debug.Notification("Sentinel ZAX-WT01 destroyed! Recover Sergeant Dennis Allen\'s Holodisk from its wreckage.")',
    'Debug.Notification("Holodisco del Sargento Allen recuperado. Entrégaselo al Paladín Talus en Lost Hills.")':
        'Debug.Notification("Sergeant Allen\'s Holodisk recovered. Deliver it to Paladin Talus at Lost Hills.")',
    'Debug.Notification("¡El Paladín Talus ha autenticado el holodisco! Habla con Cabbot en la entrada de Lost Hills.")':
        'Debug.Notification("Paladin Talus authenticated the holodisk! Speak with Cabbot at the Lost Hills entrance.")',
    'Debug.Notification("¡Misión Secundaria completada: La Prueba de El Resplandor! (+Rifle Láser Wattz 2000, Células, +500 Chapas y +350 XP)")':
        'Debug.Notification("Side Quest completed: The Trial of The Glow! (+Wattz 2000 Laser Rifle, Microfusion Cells, +500 Caps, and +350 XP)")',

    # V13SideQuestHubScript.psc
    'Debug.Notification("Trasladado a El Eje (The Hub, 2161). Habla con Irwin, el viejo Harold o Butch Harris.")':
        'Debug.Notification("Traveled to The Hub (2161). Speak with Irwin, Old Harold, or Butch Harris.")',
    'Debug.Notification("Misión Secundaria: La Granja de Irwin — Elimina al caudillo saqueador Krag al norte de El Eje.")':
        'Debug.Notification("Side Quest: Irwin\'s Farm — Eliminate Raider Chieftain Krag north of The Hub.")',
    'Debug.Notification("¡Caudillo Krag abatido! Extrae las Escrituras de la Granja de Irwin de su cadáver.")':
        'Debug.Notification("Chieftain Krag slain! Recover Irwin\'s Farm Deed from his corpse.")',
    'Debug.Notification("Escrituras de la Granja recuperadas. Registra la liberación con Butch Harris en El Eje.")':
        'Debug.Notification("Farm Deed recovered. Register the property liberation with Butch Harris in The Hub.")',
    'Debug.Notification("¡Butch Harris ha registrado la escritura! Habla con Irwin en El Eje para recibir \'Esa Arma\' (.223).")':
        'Debug.Notification("Butch Harris registered the deed! Speak with Irwin in The Hub to receive the \'.223 Pistol\'.")',
    'Debug.Notification("¡Misión Secundaria completada: La Granja de Irwin! (+Pistola del .223 \'Esa Arma\', +500 Chapas y +350 XP)")':
        'Debug.Notification("Side Quest completed: Irwin\'s Farm! (+\'.223 Pistol\', +500 Caps, and +350 XP)")',

    # V13SideQuestHubSyndicateScript.psc
    'Debug.Notification("¡Holodisco de Transmisiones Mutantes obtenido! Prueba de que patrullas supermutantes del norte asaltan las caravanas (+200 XP).")':
        'Debug.Notification("Mutant Transmissions Holodisk obtained! Proof that northern Super Mutant patrols are ambushing the caravans (+200 XP).")',
    'Debug.Notification("¡Libro Mayor del Submundo de Decker obtenido! Llévaselo al Sheriff Justin Greene en El Eje (+200 XP).")':
        'Debug.Notification("Decker\'s Underground Ledger obtained! Deliver it to Sheriff Justin Greene in The Hub (+200 XP).")',
    'Debug.Notification("La Caravana de Agua de Martha Rastello ya está contratada y suministrando agua al Refugio 13.")':
        'Debug.Notification("Martha Rastello\'s Water Caravan is already contracted and supplying water to Vault 13.")',
    'Debug.Notification("¡Caravana de los Mercaderes del Agua enviada al Refugio 13! (+100 días de reserva de agua, +10 Aguas Purificadas y +250 XP)")':
        'Debug.Notification("Water Merchants Caravan dispatched to Vault 13! (+100 days of water reserves, +10 Purified Water, and +250 XP)")',
    'Debug.Notification("Supervisor Jacoren: «Los barriles de los Mercaderes del Agua han dado 100 días de vida al Refugio 13, pero reza para que nadie haya seguido sus huellas.» (+150 XP)")':
        'Debug.Notification("Overseer Jacoren: \'The Water Merchants\' barrels have bought Vault 13 another 100 days, but pray nobody followed their tracks.\' (+150 XP)")',
    'Debug.Notification("¡Has abatido al Sanguinario de las Caravanas! Habla con el Supermutante Moribundo tendido junto a las rocas.")':
        'Debug.Notification("You slew the Caravan Deathclaw! Speak with the Dying Super Mutant lying beside the rocks.")',
    'Debug.Notification("Misión Secundaria: El Submundo y las Caravanas de El Eje — Investiga al Supermutante Moribundo en el Cruce del Oeste y desmantela el sindicato de Decker en El Halcón Maltés.")':
        'Debug.Notification("Side Quest: The Missing Caravans & The Hub Underground — Investigate the Dying Super Mutant at the Western Crossing and dismantle Decker\'s syndicate at The Maltese Falcon.")',
    'Debug.Notification("¡Decker y Kane han abierto fuego en El Halcón Maltés! Abátelos y recupera el Libro Mayor del Submundo.")':
        'Debug.Notification("Decker and Kane opened fire inside The Maltese Falcon! Take them down and recover the Underground Ledger.")',
    'Debug.Notification("¡Tienes el Holodisco de Transmisiones Mutantes y el Libro Mayor de Decker! Entrégaselos al Sheriff Justin Greene en El Eje.")':
        'Debug.Notification("You have both the Mutant Transmissions Holodisk and Decker\'s Ledger! Deliver them to Sheriff Justin Greene in The Hub.")',
    'Debug.Notification("¡Misión Secundaria completada: Las Caravanas Desaparecidas y el Submundo de El Eje! (+750 Chapas, Rifle, Munición .308 y +500 XP)")':
        'Debug.Notification("Side Quest completed: The Missing Caravans & The Hub Underground! (+750 Caps, Rifle, .308 Ammo, and +500 XP)")',

    # V13SideQuestJunktownScript.psc
    'Debug.Notification("Albóndiga (2161) ha dejado de ser tu compañero y ha regresado a Shady Sands.")':
        'Debug.Notification("Dogmeat (2161) has left your party and returned to Shady Sands.")',
    'Debug.Notification("Ian ha dejado de ser tu compañero y ha regresado a su puesto de guardia en Shady Sands.")':
        'Debug.Notification("Ian has left your party and returned to his guard post in Shady Sands.")',
    'Debug.Notification("El Ranger Tycho ha dejado de ser tu compañero y ha regresado a Junktown.")':
        'Debug.Notification("Ranger Tycho has left your party and returned to Junktown.")',
    'Debug.Notification("Albóndiga ha rastreado la zona y te ha traído 2 Estimulantes.")':
        'Debug.Notification("Dogmeat scouted the area and brought you 2 Stimpaks.")',
    'Debug.Notification("Albóndiga ha desenterrado 24 proyectiles de 10 mm.")':
        'Debug.Notification("Dogmeat dug up 24 rounds of 10mm ammunition.")',
    'Debug.Notification("Albóndiga ha encontrado 16 cartuchos del calibre .308.")':
        'Debug.Notification("Dogmeat found 16 rounds of .308 ammunition.")',
    'Debug.Notification("Albóndiga ha encontrado una bolsa con 65 chapas.")':
        'Debug.Notification("Dogmeat found a pouch with 65 Bottle Caps.")',
    'Debug.Notification("Ian ha compartido contigo 36 proyectiles del calibre 10 mm de su reserva de escolta.")':
        'Debug.Notification("Ian shared 36 rounds of 10mm ammunition from his caravan guard reserve.")',
    'Debug.Notification("Ian te ha entregado 2 Estimulantes del botiquín de las caravanas.")':
        'Debug.Notification("Ian handed you 2 Stimpaks from his caravan medkit.")',
    'Debug.Notification("Ian te ha pasado 28 cartuchos del calibre .38 recuperados en el desierto.")':
        'Debug.Notification("Ian passed you 28 rounds of .38 ammunition scavenged in the desert.")',
    'Debug.Notification("El Ranger Tycho te ha entregado 20 cartuchos de escopeta de los Rangers del Desierto.")':
        'Debug.Notification("Ranger Tycho handed you 20 Desert Ranger shotgun shells.")',
    'Debug.Notification("El Ranger Tycho ha compartido contigo 18 proyectiles del calibre .308.")':
        'Debug.Notification("Ranger Tycho shared 18 rounds of .308 ammunition with you.")',
    'Debug.Notification("El Ranger Tycho te ha dado 2 RadAway y 2 de Agua Purificada de su cantimplora.")':
        'Debug.Notification("Ranger Tycho gave you 2 RadAway and 2 Purified Water from his canteen.")',
    'Debug.Notification("¡Albóndiga (2161) se ha unido a ti! Pulsa [E]/[A] sobre él cuando quieras para darle órdenes o despedirlo.")':
        'Debug.Notification("Dogmeat (2161) has joined you! Press [E]/[A] on him anytime to issue commands or dismiss him.")',
    'Debug.Notification("Albóndiga (2161): Siguiéndote de cerca.")':
        'Debug.Notification("Dogmeat (2161): Following closely.")',
    'Debug.Notification("Albóndiga (2161): Esperando en esta posición.")':
        'Debug.Notification("Dogmeat (2161): Waiting at this position.")',
    'Debug.Notification("¡Ian se ha unido a tu grupo! Puedes viajar con Ian, Tycho y Albóndiga simultáneamente.")':
        'Debug.Notification("Ian has joined your party! You can travel with Ian, Tycho, and Dogmeat simultaneously.")',
    'Debug.Notification("¡Has convencido a Ian para unirse sin coste! Su pistola 10 mm cubrirá tu flanco.")':
        'Debug.Notification("You convinced Ian to join for free! His 10mm pistol will watch your flank.")',
    'Debug.Notification("Ian: «Fui escolta de las caravanas del Eje hasta que los Khans me hirieron. Junktown queda al sur y el Eje más allá.»")':
        'Debug.Notification("Ian: \'I used to guard Hub caravans until the Khans shot me up. Junktown lies south and The Hub beyond that.\'")',
    'Debug.Notification("Ian (Shady Sands): Cubriendo tu flanco de cerca.")':
        'Debug.Notification("Ian (Shady Sands): Covering your flank closely.")',
    'Debug.Notification("Ian (Shady Sands): Manteniendo posición aquí.")':
        'Debug.Notification("Ian (Shady Sands): Holding position here.")',
    'Debug.Notification("¡El Ranger Tycho se ha unido a tu grupo! Puedes viajar con Tycho, Ian y Albóndiga simultáneamente.")':
        'Debug.Notification("Ranger Tycho has joined your party! You can travel with Tycho, Ian, and Dogmeat simultaneously.")',
    'Debug.Notification("Ranger Tycho: En formación de escolta.")':
        'Debug.Notification("Ranger Tycho: In escort formation.")',
    'Debug.Notification("Ranger Tycho: Vigilando esta posición.")':
        'Debug.Notification("Ranger Tycho: Watching this position.")',
    'Debug.Notification("Ian: Siguiéndote de cerca.")':
        'Debug.Notification("Ian: Following closely.")',
    'Debug.Notification("Ranger Tycho: Siguiéndote de cerca.")':
        'Debug.Notification("Ranger Tycho: Following closely.")',
    'Debug.Notification("Ian: Esperando en esta posición.")':
        'Debug.Notification("Ian: Waiting at this position.")',
    'Debug.Notification("Ranger Tycho: Esperando en esta posición.")':
        'Debug.Notification("Ranger Tycho: Waiting at this position.")',
    'Debug.Notification("Trasladado a Junktown (2161). Habla con el alcalde Killian Darkwater, el capitán Lars o el Ranger Tycho.")':
        'Debug.Notification("Traveled to Junktown (2161). Speak with Mayor Killian Darkwater, Captain Lars, or Ranger Tycho.")',
    'Debug.Notification("Misión Secundaria: Justicia en Junktown — Elimina al sicario Kenji en el local de Gizmo al oeste.")':
        'Debug.Notification("Side Quest: Justice in Junktown — Eliminate Gizmo\'s hitman Kenji at Gizmo\'s casino to the west.")',
    'Debug.Notification("¡Kenji abatido! Extrae el Contrato y la Cinta de Confesión de Gizmo de su cadáver.")':
        'Debug.Notification("Kenji eliminated! Recover Gizmo\'s Contract and Confession Tape from his corpse.")',
    'Debug.Notification("Pruebas contra Gizmo obtenidas. Entrégaselas al Capitán Lars en Junktown.")':
        'Debug.Notification("Evidence against Gizmo obtained. Deliver it to Captain Lars in Junktown.")',
    'Debug.Notification("¡Lars ha incautado las pruebas contra Gizmo! Informa al alcalde Killian Darkwater en Junktown.")':
        'Debug.Notification("Lars impounded the evidence against Gizmo! Report to Mayor Killian Darkwater in Junktown.")',
    'Debug.Notification("Capitán Lars: «Ve al Almacén General e informa al alcalde Killian Darkwater para cobrar tu recompensa.»")':
        'Debug.Notification("Captain Lars: \'Head to the General Store and report to Mayor Killian Darkwater to collect your reward.\'")',
    'Debug.Notification("¡Misión Secundaria completada: Justicia en Junktown! (+500 Chapas, Escopeta de Combate, Cartuchos y +350 XP)")':
        'Debug.Notification("Side Quest completed: Justice in Junktown! (+500 Caps, Combat Shotgun, Shells, and +350 XP)")',

    # V13SideQuestJunktownSyndicateScript.psc
    'Debug.Notification("¡Has obtenido la Confesión Grabada de Gizmo! Entrégasela al Capitán Lars o a Neal en Junktown.")':
        'Debug.Notification("You obtained Gizmo\'s Recorded Confession! Deliver it to Captain Lars or Neal in Junktown.")',
    'Debug.Notification("¡Has recuperado la Urna Funeraria de la esposa de Neal! Devuélvesela al barman Neal en La Espumadera.")':
        'Debug.Notification("You recovered Neal\'s Wife\'s Memorial Urn! Return it to Neal the bartender at the Skum Pitt.")',
    'Debug.Notification("¡Has descubierto el secreto de Doc Morbid y sus envíos de «carne especial» a Iguana Bob en El Eje! (+250 chapas y suministros médicos)")':
        'Debug.Notification("You uncovered Doc Morbid\'s secret shipments of \'choice meat\' to Iguana Bob in The Hub! (+250 Caps and medical supplies)")',
    'Debug.Notification("Neal: «¡Me has devuelto la urna de mi esposa y has frenado a Vinnie! Toma 350 chapas y la mejor reserva de La Espumadera.»")':
        'Debug.Notification("Neal: \'You brought back my wife\'s urn and stopped Vinnie! Take 350 Caps and the Skum Pitt\'s finest reserve.\'")',
    'Debug.Notification("¡El sindicato de Gizmo y la banda de Los Cráneos han caído! La guardia de Lars y Neal te entregan 600 chapas y munición.")':
        'Debug.Notification("Gizmo\'s syndicate and the Skulz gang have fallen! Lars\'s guards and Neal award you 600 Caps and ammunition.")',
    'Debug.Notification("Doc Morbid ha curado tus heridas en silencio.")':
        'Debug.Notification("Doc Morbid patched up your wounds in silence.")',

    # V13SideQuestKhansScript.psc
    'Debug.Notification("Trasladado al Paso Oriental de los Khans (2161). Habla con las exploradoras Diana y Gwen.")':
        'Debug.Notification("Traveled to the Eastern Khan Pass (2161). Speak with scouts Diana and Gwen.")',
    'Debug.Notification("Misión Secundaria: Cautivos de los Khans — Elimina al carcelero Tolan en el campamento al norte.")':
        'Debug.Notification("Side Quest: Captives of the Khans — Eliminate Jailer Tolan at the northern Khan camp.")',
    'Debug.Notification("¡Carcelero Tolan abatido! Extrae la Llave Maestra y el Sello de Guerra de su cadáver.")':
        'Debug.Notification("Jailer Tolan slain! Recover the Master Key and Khan War Seal from his corpse.")',
    'Debug.Notification("Llave Maestra obtenida. Entrégasela a Gwen en el Puesto del Paso Oriental.")':
        'Debug.Notification("Master Key obtained. Deliver it to Gwen at the Eastern Pass Outpost.")',
    'Debug.Notification("¡Gwen ha liberado los cerrojos! Informa a Diana en el Puesto del Paso Oriental.")':
        'Debug.Notification("Gwen unlocked the shackles! Report to Diana at the Eastern Pass Outpost.")',
    'Debug.Notification("¡Misión Secundaria completada: Cautivos de los Khans! (+500 Chapas, Rifle de Caza, Munición .308 y +350 XP)")':
        'Debug.Notification("Side Quest completed: Captives of the Khans! (+500 Caps, Hunting Rifle, .308 Ammo, and +350 XP)")',

    # V13SideQuestShadySandsScript.psc
    'Debug.Notification("Trasladado a Shady Sands (2161). Habla con Aradesh, Seth o el Dr. Razlo, o pulsa [E] sobre Albóndiga para reclutarlo.")':
        'Debug.Notification("Traveled to Shady Sands (2161). Speak with Aradesh, Seth, or Dr. Razlo, or press [E] on Dogmeat to recruit him.")',
    'Debug.Notification("Misión Secundaria: Sombras sobre Shady Sands — Elimina al Mutascorpión Emperador en la guarida al norte.")':
        'Debug.Notification("Side Quest: Shadows Over Shady Sands — Eliminate the Emperor Radscorpion in the northern lair.")',
    'Debug.Notification("¡Mutascorpión Emperador abatido! Extrae la Glándula de Veneno de su cadáver.")':
        'Debug.Notification("Emperor Radscorpion slain! Extract the Venom Gland from its corpse.")',
    'Debug.Notification("Glándula de Veneno extraída. Entrégasela al Dr. Razlo en la Clínica de Shady Sands para curar a Jarvis.")':
        'Debug.Notification("Venom Gland extracted. Deliver it to Dr. Razlo at the Shady Sands Clinic to cure Jarvis.")',
    'Debug.Notification("¡El Dr. Razlo ha elaborado el antídoto y salvado a Jarvis! Informa a Aradesh en Shady Sands.")':
        'Debug.Notification("Dr. Razlo synthesized the antivenom and saved Jarvis! Report to Aradesh in Shady Sands.")',
    'Debug.Notification("¡Misión Secundaria completada: Sombras sobre Shady Sands! (+500 Chapas, Munición, Estimulantes y +350 XP)")':
        'Debug.Notification("Side Quest completed: Shadows Over Shady Sands! (+500 Caps, Ammunition, Stimpaks, and +350 XP)")',

    # V13SideQuestTandiRescueScript.psc
    'Debug.Notification("¡Petrox ha sido abatido! Liberas a Tandi de su celda en el campamento Khan.")':
        'Debug.Notification("Petrox has been slain! You free Tandi from her cell in the Khan camp.")',
    'Debug.Notification("¡Petrox ha caido! Liberas a Tandi de su celda en el campamento Khan.")':
        'Debug.Notification("Petrox has fallen! You free Tandi from her cell in the Khan camp.")',
    'Debug.Notification("¡Un comando superviviente de los Khans liderado por Petrox ha secuestrado a Tandi en venganza por la caida de Garl! Habla con Aradesh.")':
        'Debug.Notification("A surviving Khan warband led by Petrox has kidnapped Tandi in retaliation for Garl\'s fall! Speak with Aradesh.")',
    'Debug.Notification("¡Incursores Khans han secuestrado a Tandi en Arenas Sombrías! Habla con Aradesh de inmediato.")':
        'Debug.Notification("Khan raiders have kidnapped Tandi from Shady Sands! Speak with Aradesh immediately.")',
    'Debug.Notification("Dirigete al Campamento del Cañon de los Khans al noreste de Arenas Sombrías para rescatar a Tandi.")':
        'Debug.Notification("Head to the Khan Canyon Camp northeast of Shady Sands to rescue Tandi.")',
    'Debug.Notification("[Intimidacion Éxito] Al saber que abatiste a Garl Mano Muerta, Petrox cede y libera a Tandi sin luchar.")':
        'Debug.Notification("[Intimidation Success] Knowing you slew Garl Death-Hand, Petrox backs down and releases Tandi without a fight.")',
    'Debug.Notification("[Persuasion / Intimidacion Éxito] Convences a Petrox de que retener a Tandi destruira a su banda. Tandi queda libre.")':
        'Debug.Notification("[Speech / Intimidation Success] You convince Petrox that holding Tandi will destroy his warband. Tandi is freed.")',
    'Debug.Notification("[Rescate Pagado: 500 chapas] Petrox acepta el pago y entrega la llave de la celda de Tandi.")':
        'Debug.Notification("[Ransom Paid: 500 Caps] Petrox accepts the payment and hands over Tandi\'s cell key.")',
    'Debug.Notification("[Rescate Negociado: " + currentCaps + " chapas] Petrox acepta tus chapas y libera a Tandi.")':
        'Debug.Notification("[Negotiated Ransom: " + currentCaps + " Caps] Petrox accepts your caps and releases Tandi.")',
    'Debug.Notification("[Negociacion Tensada] Sin chapas suficientes, intimidas a Petrox para que abra el cerrojo de Tandi.")':
        'Debug.Notification("[Tense Negotiation] Short on caps, you intimidate Petrox into unlocking Tandi\'s cell.")',
    'Debug.Notification("¡Combate en el Cañon de los Khans! Abate a Petrox o abre el cerrojo de retencion para liberar a Tandi.")':
        'Debug.Notification("Combat in the Khan Canyon! Defeat Petrox or unlock the holding cell latch to free Tandi.")',
    'Debug.Notification("¡Tandi esta a salvo y ha regresado a Arenas Sombrías! Habla con Aradesh para recibir tu recompensa.")':
        'Debug.Notification("Tandi is safe and has returned to Shady Sands! Speak with Aradesh to claim your reward.")',
    'Debug.Notification("¡Tandi esta a salvo y regresara a Arenas Sombrías! Habla con Aradesh para recibir tu recompensa.")':
        'Debug.Notification("Tandi is safe and will return to Shady Sands! Speak with Aradesh to claim your reward.")',
    'Debug.Notification("Mision completada: El Rescate de Tandi (+1100 chapas incluyendo reembolso del rescate, suministros y +500 XP).")':
        'Debug.Notification("Quest completed: Rescue Tandi (+1100 Caps including ransom reimbursement, supplies, and +500 XP).")',
    'Debug.Notification("Mision completada: El Rescate de Tandi (+600 chapas, suministros de Arenas Sombrías y +500 XP).")':
        'Debug.Notification("Quest completed: Rescue Tandi (+600 Caps, Shady Sands supplies, and +500 XP).")',

    # V13SideQuestTardisScript.psc
    'Debug.Notification("Te encuentras ante un camión de Nuka-Cola abollado y volcado.")':
        'Debug.Notification("You come across a dented, overturned Nuka-Cola delivery truck.")',
    'Debug.Notification("«PROPIEDAD DEL ÁREA 51 — DEVOLVER SI SE ENCUENTRA»")':
        'Debug.Notification("\'PROPERTY OF AREA 51 — RETURN IF FOUND\'")',
    'Debug.Notification("«Ves una enorme huella hundida en el suelo del desierto.»")':
        'Debug.Notification("\'You see a gigantic footprint pressed deep into the desert floor.\'")',
    'Debug.Notification("«Te encuentras con el antiguo Concesionario de Coches Usados de Bob (Bob\'s Pre-Owned Car Mart).»")':
        'Debug.Notification("\'You come across Bob\'s Pre-Owned Car Mart.\'")',
    'Debug.Notification("«Ves a un viajero solitario junto al fuego: Patrick el Celta.» Habla con él para escuchar su balada tradicional (+1 Carisma).")':
        'Debug.Notification("\'You see a lone traveler by the campfire: Patrick the Celt.\' Speak with him to hear his traditional ballad (+1 Charisma).")',
    'Debug.Notification("Ves una antigua cabina telefónica de policía. Parece estar totalmente fuera de lugar...")':
        'Debug.Notification("You see an old British police call box. It looks completely out of place...")',
    'Debug.Notification("«Parece ser algún tipo de criatura extraña, incluso para el Yermo. Nadie vivo ha visto jamás nada parecido.»")':
        'Debug.Notification("\'It appears to be some sort of strange creature, even for the wastes. No one alive has ever seen anything like it.\'")',
    'Debug.Notification("«Ves el cuerpo aplastado de un viajero en el fondo de la Huella Gigante.»")':
        'Debug.Notification("\'You see the crushed body of a traveler at the bottom of the Giant Footprint.\'")',
    'Debug.Notification("[Sensor de Movimiento Pip-Boy] Sensor desconectado (-2 Percepción).")':
        'Debug.Notification("[Pip-Boy Motion Sensor] Sensor offline (-2 Perception).")',
    'Debug.Notification("[Sensor de Movimiento] ¡ALERTA RADAR! " + hostileCount + " enemigo(s) hostil(es) detectado(s) a " + minMeters + " m (marcados en rojo).")':
        'Debug.Notification("[Motion Sensor] RADAR ALERT! " + hostileCount + " hostile target(s) detected at " + minMeters + " m (highlighted in red).")',
    'Debug.Notification("[Sensor de Movimiento] Radar ultrasónico Pip-Boy 2000 activo (+2 PER). Sin amenazas en un radio de 65 m.")':
        'Debug.Notification("[Motion Sensor] Pip-Boy 2000 ultrasonic radar active (+2 PER). No threats within 65 m.")',
    'Debug.Notification("[Sensor de Movimiento] Perímetro despejado: sin amenazas hostiles en rango radar.")':
        'Debug.Notification("[Motion Sensor] Perimeter clear: no hostile threats within radar range.")',
    'string jumpNotice = "Trasladado al Encuentro Especial: La Cabina Telefónica Inusual (Desierto de Nueva California, 2161)."':
        'string jumpNotice = "Traveled to Special Encounter: The Unusual Call Box (New California Desert, 2161)."',
    'jumpNotice = "Trasladado al Encuentro Especial: El Camión de Nuka-Cola Volcado (Sureste de El Eje, 2161)."':
        'jumpNotice = "Traveled to Special Encounter: Overturned Nuka-Cola Truck (Southeast of The Hub, 2161)."',
    'jumpNotice = "Trasladado al Encuentro Especial: El Platillo Volante Estrellado — Propiedad del Área 51 (Sur de California, 2161)."':
        'jumpNotice = "Traveled to Special Encounter: Crashed Flying Saucer — Property of Area 51 (Southern California, 2161)."',
    'jumpNotice = "Trasladado al Encuentro Especial: La Huella Gigante de Godzilla (Norte de Arenas Sombrías, 2161)."':
        'jumpNotice = "Traveled to Special Encounter: Giant Godzilla Footprint (North of Shady Sands, 2161)."',
    'jumpNotice = "Trasladado al Encuentro Especial: El Concesionario de Coches Usados de Bob (Sureste de Ciudad Chatarra, 2161)."':
        'jumpNotice = "Traveled to Special Encounter: Bob\'s Pre-Owned Car Mart (Southeast of Junktown, 2161)."',
    'jumpNotice = "Trasladado al Encuentro Especial: Patrick el Celta, el Bardo Viajero (Ruta Central al Norte de El Eje, 2161)."':
        'jumpNotice = "Traveled to Special Encounter: Patrick the Celt, Traveling Bard (Central Route North of The Hub, 2161)."',
    'Debug.Notification("[Encuentro Especial] Te encuentras ante un camión de Nuka-Cola abollado y volcado.")':
        'Debug.Notification("[Special Encounter] You come across a dented, overturned Nuka-Cola delivery truck.")',
    'Debug.Notification("[Encuentro Especial] Ves una nave con forma de platillo que parece haberse estrellado en el desierto. Dos cuerpos calcinados yacen cerca.")':
        'Debug.Notification("[Special Encounter] You see a saucer-shaped craft that appears to have crashed in the desert. Two charred bodies lie nearby.")',
    'Debug.Notification("[Encuentro Especial] Ves una enorme huella hundida en el suelo del desierto.")':
        'Debug.Notification("[Special Encounter] You see a gigantic footprint pressed deep into the desert floor.")',
    'Debug.Notification("[Encuentro Especial] Te encuentras con el antiguo Concesionario de Coches Usados de Bob (Bob\'s Pre-Owned Car Mart).")':
        'Debug.Notification("[Special Encounter] You come across Bob\'s Pre-Owned Car Mart.")',
    'Debug.Notification("[Encuentro Especial] Ves a un viajero solitario junto al fuego: Patrick el Celta.")':
        'Debug.Notification("[Special Encounter] You see a lone traveler by the campfire: Patrick the Celt.")',
    'Debug.Notification("[Encuentro Especial] Ves una antigua cabina telefónica de policía. Parece estar totalmente fuera de lugar.")':
        'Debug.Notification("[Special Encounter] You see an old British police call box. It looks completely out of place.")',
    'Debug.Notification("Encuentro Especial: El Camión de Nuka-Cola Volcado — Examina el transporte volcado en las dunas.")':
        'Debug.Notification("Special Encounter: Overturned Nuka-Cola Truck — Examine the overturned transport in the dunes.")',
    'Debug.Notification("¡Has encontrado la Caja de Caudales del Camión de Nuka-Cola! Recoge el Albarán y el tesoro de chapas.")':
        'Debug.Notification("You found the Nuka-Cola Truck Lockbox! Collect the Shipping Manifest and the stash of Bottle Caps.")',
    'Debug.Notification("¡Encuentro Especial completado: El Camión de Nuka-Cola Volcado! (+" + targetCaps + " Chapas según tu Suerte y +350 XP)")':
        'Debug.Notification("Special Encounter completed: Overturned Nuka-Cola Truck! (+" + targetCaps + " Caps based on your Luck and +350 XP)")',
    'Debug.Notification("Encuentro Especial: El Platillo Volante Estrellado — Examina la nave del Área 51 y los dos cuerpos alienígenas.")':
        'Debug.Notification("Special Encounter: Crashed Flying Saucer — Examine the Area 51 craft and the two alien bodies.")',
    'Debug.Notification("«PROPIEDAD DEL ÁREA 51 — DEVOLVER SI SE ENCUENTRA». Registra los dos cuerpos alienígenas para recuperar el Bláster Alienígena y el Cuadro de «El Rey».")':
        'Debug.Notification("\'PROPERTY OF AREA 51 — RETURN IF FOUND\'. Search the two alien bodies to recover the Alien Blaster and the Velvet Elvis Painting.")',
    'Debug.Notification("¡Encuentro Especial completado: El Platillo Volante Estrellado! (+Bláster Alienígena, +Cuadro de Terciopelo de «El Rey» y +400 XP)")':
        'Debug.Notification("Special Encounter completed: Crashed Flying Saucer! (+Alien Blaster, +Velvet Painting of \'The King\', and +400 XP)")',
    'Debug.Notification("Encuentro Especial: La Huella Gigante de Godzilla — Examina la huella gigante al norte de Arenas Sombrías.")':
        'Debug.Notification("Special Encounter: Giant Godzilla Footprint — Examine the giant footprint north of Shady Sands.")',
    'Debug.Notification("Registra el cadáver aplastado en el centro de la Huella Gigante para recuperar el RobCo Stealth Boy 3001.")':
        'Debug.Notification("Search the crushed corpse in the center of the Giant Footprint to recover the RobCo Stealth Boy 3001.")',
    'Debug.Notification("¡Encuentro Especial completado: La Huella Gigante de Godzilla! (+RobCo Stealth Boy 3001, +2 Chicos Sigilosos y +350 XP)")':
        'Debug.Notification("Special Encounter completed: Giant Godzilla Footprint! (+RobCo Stealth Boy 3001, +2 Stealth Boys, and +350 XP)")',
    'Debug.Notification("Encuentro Especial: El Concesionario de Coches Usados de Bob — Examina la caseta de ventas y los vehículos de ocasión.")':
        'Debug.Notification("Special Encounter: Bob\'s Pre-Owned Car Mart — Examine the sales office and the used car lot.")',
    'Debug.Notification("Abre la Caja Fuerte de Exposición de Bob y recoge la legendaria carabina Red Ryder LE BB Gun.")':
        'Debug.Notification("Open Bob\'s Display Safe and collect the legendary Red Ryder LE BB Gun.")',
    'Debug.Notification("¡Encuentro Especial completado: Concesionario de Coches Usados de Bob! (+Carabina Red Ryder LE BB Gun, +120 Cartuchos y +400 XP)")':
        'Debug.Notification("Special Encounter completed: Bob\'s Pre-Owned Car Mart! (+Red Ryder LE BB Gun, +120 Rounds, and +400 XP)")',
    'Debug.Notification("Encuentro Especial: Patrick el Celta — Acércate a su hoguera al norte de El Eje y conversa con el bardo viajero.")':
        'Debug.Notification("Special Encounter: Patrick the Celt — Approach his campfire north of The Hub and speak with the traveling bard.")',
    'Debug.Notification("Habla con Patrick el Celta junto a su hoguera y pídele que cante su balada tradicional gaélica (+1 Carisma).")':
        'Debug.Notification("Speak with Patrick the Celt by his campfire and ask him to sing his traditional Gaelic ballad (+1 Charisma).")',
    'Debug.Notification("¡Encuentro Especial completado: Patrick el Celta! (+1 Carisma permanente por escuchar «Na Fianna», +Medallón Celta y +350 XP)")':
        'Debug.Notification("Special Encounter completed: Patrick the Celt! (+1 permanent Charisma from hearing \'Na Fianna\', +Celtic Medallion, and +350 XP)")',
    'Debug.Notification("Encuentro Especial: La Cabina Telefónica Inusual — Acércate y examina la cabina azul en mitad del desierto.")':
        'Debug.Notification("Special Encounter: The Unusual Call Box — Approach and examine the blue police box in the middle of the desert.")',
    'Debug.Notification("¡La cabina se ha desmaterializado en el espacio-tiempo! Recoge el Sensor de Movimiento que ha dejado atrás.")':
        'Debug.Notification("The police box dematerialized across space-time! Pick up the Motion Sensor left behind.")',
    'Debug.Notification("¡Encuentro Especial completado: La Cabina Telefónica Inusual! (+Sensor de Movimiento Pip-Boy 2000, +500 Chapas y +350 XP)")':
        'Debug.Notification("Special Encounter completed: The Unusual Call Box! (+Pip-Boy 2000 Motion Sensor, +500 Caps, and +350 XP)")',

    # V13TandiCellReleaseScript.psc
    'Debug.Notification("El cerrojo de retencion ya esta abierto y Tandi ha regresado a Arenas Sombrías.")':
        'Debug.Notification("The holding cell latch is already unlocked and Tandi has returned to Shady Sands.")',
    'Debug.Notification("Cerrojo de retencion de los Khans. No hay ningun prisionero encadenado aqui.")':
        'Debug.Notification("Khan holding cell latch. There is no prisoner chained here.")',
    'Debug.Notification("Abres los grilletes con la llave de Petrox y liberas a Tandi.")':
        'Debug.Notification("You unlock the shackles with Petrox\'s key and free Tandi.")',
    'Debug.Notification("Rompes el cerrojo de la celda tras abatir a los secuestradores y liberas a Tandi.")':
        'Debug.Notification("You break open the cell latch after defeating the kidnappers and free Tandi.")',
    'Debug.Notification("[Ganzua / Sigilo] Fuerzas el cerrojo con una horquilla y liberas a Tandi en silencio.")':
        'Debug.Notification("[Lockpick / Stealth] You pick the cell latch with a bobby pin and quietly free Tandi.")',
    'Debug.Notification("[Fuerza / Sigilo] Desencajas el pestillo oxidado de la celda y liberas a Tandi.")':
        'Debug.Notification("[Strength / Stealth] You wrench the rusted cell bolt free and release Tandi.")',

    # Terminals
    'Debug.Notification("[Computadora de Lost Hills] ¡Holocinta de autopsia de esterilidad VEF de la escriba Vree descargada!")':
        'Debug.Notification("[Lost Hills Computer] Scribe Vree\'s FEV sterility autopsy holotape downloaded!")',
    'Debug.Notification("[Control de Cubas de Mariposa] ¡Autodestrucción armada! ¡Códigos VEF y Anulador Psíquico adquiridos!")':
        'Debug.Notification("[Mariposa Vats Control] Self-destruct armed! FEV Codes and Psychic Nullifier acquired!")',
    'Debug.Notification("[El Maestro]: \'No puede ser... ¡Todos nuestros mutantes son estériles! Márchate ahora, mientras aún te quede esperanza...\'")':
        'Debug.Notification("[The Master]: \'It cannot be... All of our mutants are sterile! Leave now, while you still have hope...\'")',
    'Debug.Notification("[Ojiva de la Catedral] ¡Núcleo de detonación nuclear extraído! ¡Evacúa hacia el Refugio 13!")':
        'Debug.Notification("[Cathedral Warhead] Nuclear detonation core extracted! Evacuate to Vault 13!")',
    'Debug.Notification("[Computadora del Refugio 15] ¡Holocinta Hidrológica del Refugio 15 extraída! Regresa al Refugio 13.")':
        'Debug.Notification("[Vault 15 Computer] Vault 15 Hydrological Survey Holotape extracted! Return to Vault 13.")',

    # Latest QA & Bard & Companion Updates
    'Debug.Notification("Tug (Supermutante Moribundo): «Ugggh... esa cosa... el monstruo de garras... despedazó los carros... toma... nuestro holodisco...»")':
        'Debug.Notification("Tug (Dying Super Mutant): \'Ugggh... that thing... the clawed monster... tore the wagons apart... take... our holodisk...\'")',
    'Debug.Notification("Kane (Lugarteniente de Decker): «En El Halcón Maltés las órdenes las da el señor Decker. Habla con él si valoras tu pellejo.»")':
        'Debug.Notification("Kane (Decker\'s Lieutenant): \'Inside The Maltese Falcon, Mr. Decker gives the orders. Speak with him if you value your hide.\'")',
    'Debug.Notification("[Grupo de California] Tus compañeros de 2161 aguardan en Nueva California hasta tu regreso.")':
        'Debug.Notification("[California Party] Your 2161 companions are waiting in New California until your return.")',
    'Debug.Notification("[Grupo de California] Tus compañeros de 2161 se han reincorporado a tu grupo.")':
        'Debug.Notification("[California Party] Your 2161 companions have rejoined your party.")',
    'Debug.Notification("Izo (Guardaespaldas): «Si tienes negocios en el Casino, habla con el jefe Gizmo. Y mantén las manos lejos del arma.»")':
        'Debug.Notification("Izo (Bodyguard): \'If you have business at the Casino, speak with Boss Gizmo. And keep your hands away from your weapon.\'")',
    'Debug.Notification("[Patrick el Celta] ♪ Ballad of Na Fianna (The Wanderer of Vault Thirteen) ♪")':
        'Debug.Notification("[Patrick the Celt] Ballad of Na Fianna (The Wanderer of Vault Thirteen)")',
    'Debug.Notification("Neal: «¡Gracias por devolverme la urna! Ahora obtén la Confesión de Gizmo en el Casino del Oeste para acabar con su sindicato.»")':
        'Debug.Notification("Neal: \'Thank you for returning the urn! Now get Gizmo\'s Confession at the Westside Casino to bring down his syndicate.\'")',
    'Debug.Notification("Tug ha sucumbido a las heridas del Sanguinario tras entregarte el Holodisco. Investiga a Decker en El Halcón Maltés o informa al Sheriff Greene.")':
        'Debug.Notification("Tug succumbed to his Deathclaw wounds after handing you the Holodisk. Investigate Decker at The Maltese Falcon or report to Sheriff Greene.")',
}


def _sanitize_en_psc_line(line: str) -> str:
    return (
        line.replace("\u00e2\u20ac\u201d", " - ")
        .replace("\u2014", "-")
        .replace("\u2013", "-")
        .replace("\u266a", "")
        .replace("\u00ab", "'")
        .replace("\u00bb", "'")
    )


def sync_and_compile_papyrus_en() -> None:
    os.makedirs(EN_PSC_DIR, exist_ok=True)
    os.makedirs(EN_PEX_DIR, exist_ok=True)

    es_files = sorted(f for f in os.listdir(ES_PSC_DIR) if f.endswith(".psc"))
    untranslated = []
    translated_count = 0

    for fn in es_files:
        src_path = os.path.join(ES_PSC_DIR, fn)
        dst_path = os.path.join(EN_PSC_DIR, fn)
        with open(src_path, "r", encoding="utf-8") as rf:
            lines = rf.readlines()

        out_lines = []
        for idx, line in enumerate(lines, 1):
            stripped = line.strip()
            if stripped in PSC_LINE_TRANSLATIONS:
                indent = line[: len(line) - len(line.lstrip())]
                out_lines.append(indent + _sanitize_en_psc_line(PSC_LINE_TRANSLATIONS[stripped]) + "\n")
                translated_count += 1
            else:
                if (
                    '"' in stripped
                    and "GetFormFromFile" not in stripped
                    and "RegisterForRemoteEvent" not in stripped
                    and "UnregisterForRemoteEvent" not in stripped
                    and "PlayIdle" not in stripped
                ):
                    untranslated.append((fn, idx, stripped))
                out_lines.append(_sanitize_en_psc_line(line))

        with open(dst_path, "w", encoding="utf-8") as wf:
            wf.writelines(out_lines)

    if untranslated:
        print("[ERROR] Untranslated Papyrus lines found:")
        for u in untranslated:
            print("  ", u)
        raise RuntimeError("Untranslated Papyrus lines found!")

    print(f"[Papyrus EN] Synchronized {len(es_files)} .psc files ({translated_count} lines translated to English).")

    base_scripts = os.path.join(FO4_DATA_DIR, "Scripts", "Source", "Base")
    import_arg = f"{EN_PSC_DIR};{base_scripts}"
    flags_file = os.path.join(base_scripts, "Institute_Papyrus_Flags.flg")

    compiled = 0
    for fn in es_files:
        cmd = [
            PAPYRUS_COMPILER,
            fn,
            f"-f={flags_file}",
            f"-i={import_arg}",
            f"-o={EN_PEX_DIR}",
        ]
        res = subprocess.run(cmd, cwd=EN_PSC_DIR, capture_output=True, text=True)
        if res.returncode != 0:
            raise RuntimeError(f"Error compiling {fn}:\n{res.stdout}\n{res.stderr}")
        compiled += 1

    print(f"[Papyrus EN] Compiled {compiled}/{len(es_files)} .pex scripts successfully into {EN_PEX_DIR}")


if __name__ == "__main__":
    sync_and_compile_papyrus_en()
