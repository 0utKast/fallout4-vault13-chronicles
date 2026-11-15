# -*- coding: utf-8 -*-
"""
Synchronizes all 57 Papyrus scripts from `cronicas_refugio_13/papyrus_src/*.psc` into
`cronicas_refugio_13/edition_en/papyrus_src/*.psc` with 100% canonical Fallout 1 English strings,
and compiles all 57 `.psc` files into `cronicas_refugio_13/edition_en/papyrus_out/*.pex`.
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

    # Chapter 2 — Act II Water Caravan Hook & Act III Lost Hills Expansion
    'Debug.Notification("[Supervisor Jacoren] Las caravanas de agua de El Eje salvaron al Refugio, pero han revelado nuestra posición a patrullas de supermutantes...")':
        'Debug.Notification("[Overseer Jacoren] The Hub\'s water caravans saved the Vault, but they may have revealed our location to Super Mutant patrols...")',
    'Debug.Notification("[Crónicas del Refugio 13] ¡El agua fluye de nuevo, pero un ejército mutante acecha! Habla con el Supervisor Jacoren sobre la nueva amenaza.")':
        'Debug.Notification("[Vault 13 Chronicles] Water flows again, yet a mutant army stalks the wasteland! Speak with Overseer Jacoren about the new threat.")',
    'Debug.Notification("[Escriba Jefe Vree — Nivel 3] ¡Holocinta de Autopsia de Esterilidad de los Supermutantes recibida! (+250 XP)")':
        'Debug.Notification("[Head Scribe Vree — Level 3] Super Mutant Autopsy Report Holotape received! (+250 XP)")',
    'Debug.Notification("[Alto Anciano John Maxson — Nivel 4] ¡Exploradores enviados al norte y Escuadra de Paladines autorizada para el asalto a Mariposa! (+250 XP)")':
        'Debug.Notification("[High Elder John Maxson — Level 4] Scouts dispatched north and Paladin Assault Squad authorized for the Mariposa raid! (+250 XP)")',
    'Debug.Notification("[Crónicas del Refugio 13] ¡Informe de Lost Hills archivado! Conservas la Holocinta de Vree para la Catedral y se desbloquean Mariposa y La Catedral (Orden Libre 1997).")':
        'Debug.Notification("[Vault 13 Chronicles] Lost Hills report filed! Keep Vree\'s Holotape for The Cathedral — Mariposa and The Cathedral are now unlocked (1997 Free Order).")',

    # Chapter 2 — Act IV Mariposa Military Base
    'Debug.Notification("[Base Militar Mariposa] ¡Alarma de intrusión! ¡El Teniente y los Nocturnos han descubierto tu identidad!")':
        'Debug.Notification("[Mariposa Military Base] Intrusion alarm! The Lieutenant and his Nightkin have uncovered your identity!")',
    'Debug.Notification("[Emisor de Mariposa] Campo de fuerza reactivado.")':
        'Debug.Notification("[Mariposa Emitter] Force field reactivated.")',
    'Debug.Notification("[Reparar] ¡Bobina del emisor puenteada! Campo de fuerza desactivado (+75 XP).")':
        'Debug.Notification("[Repair] Emitter coil bypassed! Force field disabled (+75 XP).")',
    'Debug.Notification("[Emisor] Necesitas al menos 1 Célula de Fusión o Inteligencia 5+ para puentear el emisor.")':
        'Debug.Notification("[Emitter] You need at least 1 Fusion Cell or Intelligence 5+ to bypass the force field emitter.")',
    'Debug.Notification("[Ciencia] ¡Frecuencia armónica invertida! Campo de fuerza neutralizado (+75 XP).")':
        'Debug.Notification("[Science] Harmonic frequency inverted! Force field neutralized (+75 XP).")',
    'Debug.Notification("[Ciencia] Código cifrado requerido (Inteligencia 6+ o Terminal de Seguridad del Nivel de Investigación).")':
        'Debug.Notification("[Science] Encrypted access code required (Intelligence 6+ or the Research Level Security Terminal).")',
    'Debug.Notification("[Explosivos] ¡Emisor volado con carga explosiva! (+100 XP)")':
        'Debug.Notification("[Explosives] Force field emitter demolished with explosive charge! (+100 XP)")',
    'Debug.Notification("[Explosivos] Necesitas una Granada de Fragmentación para volar el emisor blindado.")':
        'Debug.Notification("[Explosives] You need a Fragmentation Grenade to blow up the armored emitter.")',
    'Debug.Notification("[Radio de la Unidad] Subbanda de patrulla aceptada: campo de fuerza abierto en silencio (+100 XP).")':
        'Debug.Notification("[Unity Radio] Patrol sub-channel accepted: force field opened silently (+100 XP).")',
    'Debug.Notification("[Radio] No posees un Transmisor de Radio de Patrulla Mutante de la Unidad.")':
        'Debug.Notification("[Radio] You do not carry a Unity Mutant Patrol Radio Transceiver.")',
    'Debug.Notification("[Base Militar Mariposa] ¡BOOM! ¡Las Cubas de VEF han colapsado bajo toneladas de roca! (+500 XP)")':
        'Debug.Notification("[Mariposa Military Base] BOOM! The FEV Vats have collapsed beneath tons of rubble! (+500 XP)")',
    'Debug.Notification("[Hermandad del Acero] ¡Escuadra de Paladines de Asalto desplegada en Mariposa por orden de Maxson!")':
        'Debug.Notification("[Brotherhood of Steel] Paladin Assault Squad deployed at Mariposa on Elder Maxson\'s orders!")',
    'Debug.Notification("[Mariposa] ¡Prisionero de caravana liberado de las celdas de inmersión! (+250 XP)")':
        'Debug.Notification("[Mariposa] Caravan prisoner rescued from the dipping chambers! (+250 XP)")',
    'Debug.Notification("[Disfraz de la Unidad] Túnica Púrpura equipada: los guardias de Mariposa y la Catedral no atacarán salvo provocación.")':
        'Debug.Notification("[Unity Disguise] Purple Robes equipped: Mariposa and Cathedral sentries will hold fire unless provoked.")',
    'Debug.Notification("[AUTODESTRUCCIÓN DE MARIPOSA] ¡Detonación de las Cubas en " + iCountdownSecondsLeft + " segundos! ¡Sal al exterior!")':
        'Debug.Notification("[MARIPOSA SELF-DESTRUCT] Vats detonation in " + iCountdownSecondsLeft + " seconds! Get outside!")',
    'Debug.Notification("[Control de Cubas de Mariposa] ¡Autodestrucción armada (180 s)! ¡Evacúa la base inmediatamente!")':
        'Debug.Notification("[Mariposa Vat Control] Self-destruct armed (180s)! Evacuate the base immediately!")',
    'Debug.Notification("[Seguridad de Mariposa] ¡Holocinta de Richard Grey (2102) descargada y campos de fuerza desactivados! (+200 XP)")':
        'Debug.Notification("[Mariposa Security] Richard Grey\'s Holotape (2102) downloaded and force fields disabled! (+200 XP)")',

    # Chapter 2 — Act V The Cathedral, The Master & Exile Epilogue (2162)
    'Debug.Notification("[La Catedral] ¡Tu disfraz de los Hijos de la Catedral ha quedado al descubierto!")':
        'Debug.Notification("[The Cathedral] Your Children of the Cathedral disguise has been blown!")',
    'Debug.Notification("[El Maestro]: \'¡Entonces muere! ¡Pretorianos Nocturnos, aniquilad al intruso!\'")':
        'Debug.Notification("[The Master]: \'Then die! Nightkin Praetorians, annihilate the intruder!\'")',
    'Debug.Notification("[Seguidores del Apocalipsis] ¡Los exploradores de Nicole se han infiltrado en La Catedral para cubrir tu asalto!")':
        'Debug.Notification("[Followers of the Apocalypse] Nicole\'s scouts have infiltrated The Cathedral to cover your assault!")',
    'Debug.Notification("[Hermana Laura] ¡Contraseña \'Rosa Roja\' aceptada! Llave de la Cripta Subterránea recibida (+250 XP).")':
        'Debug.Notification("[Sister Laura] Passphrase \'Red Rose\' accepted! Underground Crypt Key received (+250 XP).")',
    'Debug.Notification("[El Maestro]: \'No hay esperanza... Márchate ahora, mientras aún te quede esperanza...\' [Autodestrucción: 240 s]")':
        'Debug.Notification("[The Master]: \'There is no hope... Leave now, while you still have hope...\' [Self-Destruct: 240s]")',
    'Debug.Notification("[Ojiva Atómica de La Catedral] ¡Detonador termonuclear armado (240 s)! ¡Evacúa el edificio inmediatamente!")':
        'Debug.Notification("[Cathedral Atomic Warhead] Thermonuclear trigger armed (240s)! Evacuate the building immediately!")',
    'Debug.Notification("[La Catedral] ¡El enlace vital del Maestro ha caído y ha activado la ojiva nuclear (240 s)! ¡Huye al exterior!")':
        'Debug.Notification("[The Cathedral] The Master\'s vital link has flatlined, triggering the nuclear warhead (240s)! Run for the exit!")',
    'Debug.Notification("[La Catedral] ¡DETONACIÓN TERMONUCLEAR! ¡La torre de la Unidad ha sido borrada de la faz de California! (+800 XP)")':
        'Debug.Notification("[The Cathedral] THERMONUCLEAR DETONATION! The Unity\'s tower has been wiped from the face of California! (+800 XP)")',
    'string sShady = "SHADY SANDS: Próspera — semilla de la futura República de Nueva California."':
        'string sShady = "SHADY SANDS: Prosperous - seed of the future New California Republic."',
    'string sJunk = "JUNKTOWN: Libre y abierta a las caravanas del desierto."':
        'string sJunk = "JUNKTOWN: Free and open to the desert caravans."',
    'string sHub = "EL EJE (THE HUB): Sus rutas mercantiles vertebran toda Nueva California."':
        'string sHub = "THE HUB: Its merchant routes form the backbone of all New California."',
    'string sBoneyard = "EL BONEYARD (ADYTUM): Liberado de la sombra de la Catedral."':
        'string sBoneyard = "THE BONEYARD (ADYTUM): Freed from the shadow of The Cathedral."',
    'string sNecro = "NECRÓPOLIS: Los necrófagos conservaron su ciudad y la Gran Bomba de Agua."':
        'string sNecro = "NECROPOLIS: The ghouls preserved their city and the Great Water Pump."',
    'sShady = "SHADY SANDS: Arrasada por las hordas mutantes antes de la caída de Mariposa."':
        'sShady = "SHADY SANDS: Overrun by the mutant hordes before the fall of Mariposa."',
    'sJunk = "JUNKTOWN: Arrasada durante la invasión del ejército del Maestro."':
        'sJunk = "JUNKTOWN: Devastated during the Master\'s army invasion."',
    'sHub = "EL EJE (THE HUB): Sus caravanas cayeron bajo el asedio supermutante."':
        'sHub = "THE HUB: Its caravans fell beneath the Super Mutant siege."',
    'sBoneyard = "EL BONEYARD: Devastado por las legiones de la Unidad."':
        'sBoneyard = "THE BONEYARD: Laid waste by the legions of the Unity."',
    'sNecro = "NECRÓPOLIS: Masacrada en la represalia mutante del Día 110."':
        'sNecro = "NECROPOLIS: Slaughtered in the mutant reprisal of Day 110."',
    'string epilogueText = "[CRÓNICA FINAL — 10 DE MAYO DE 2162]\\n\\nTras salvar al Refugio 13 y destruir tanto las Cubas de Mariposa como al Maestro, el Supervisor Jacoren selló la compuerta a tus espaldas. Así quedó el Sur de California:\\n\\n• " + sShady + "\\n• " + sJunk + "\\n• " + sHub + "\\n• " + sBoneyard + "\\n• " + sNecro + "\\n\\nJunto a Theresa, Lyle y los moradores que decidieron seguirte en el cañón exterior, marcharéis hacia el norte hasta Oregón para fundar la aldea de ARROYO."':
        'string epilogueText = "[FINAL CHRONICLE - MAY 10, 2162]\\n\\nAfter saving Vault 13 and destroying both the Mariposa Vats and The Master, Overseer Jacoren sealed the blast door behind you. Thus stood Southern California:\\n\\n- " + sShady + "\\n- " + sJunk + "\\n- " + sHub + "\\n- " + sBoneyard + "\\n- " + sNecro + "\\n\\nTogether with Theresa, Lyle, and the Vault dwellers awaiting you in the outer canyon, you will journey north to Oregon to found the village of ARROYO."',
    'Debug.Notification("[Anulador Psíquico] ¡Las alucinaciones psíquicas del Pasillo de la Revulsión quedan bloqueadas al 100%!")':
        'Debug.Notification("[Psychic Nullifier] The psychic hallucinations of the Corridor of Revulsion are 100% blocked!")',
    'Debug.Notification("[Pasillo de la Revulsión] ¡Visiones psíquicas abrasan tu mente! (-14 PV — Equipa un Anulador Psíquico)")':
        'Debug.Notification("[Corridor of Revulsion] Psychic visions sear your mind! (-14 HP - Equip a Psychic Nullifier)")',
    'Debug.Notification("[Padre Lasher] ¡Insignia Roja del Padre Lasher obtenida mediante engaño! (+200 XP)")':
        'Debug.Notification("[Father Lasher] Father Lasher\'s Red Badge obtained through deception! (+200 XP)")',
    'Debug.Notification("[Sumo Sacerdote Morfeo] ¡Insignia del Capullo Negro entregada! (+300 XP)")':
        'Debug.Notification("[High Priest Morpheus] Black Cocoon Badge surrendered! (+300 XP)")',
    'Debug.Notification("[Crónicas del Refugio 13] ¡Mariposa y La Catedral han caído! Regresa al Refugio 13 para el epílogo final.")':
        'Debug.Notification("[Vault 13 Chronicles] Both Mariposa and The Cathedral have fallen! Return to Vault 13 for the final epilogue.")',
    'Debug.Notification("[10 de mayo de 2162 — El Exilio] ¡Campaña completada! Servoarmadura T-51f Endurecida, Ametralladora Vindicator y Crónica de 2162 desbloqueadas.")':
        'Debug.Notification("[May 10, 2162 - The Exile] Campaign completed! Hardened T-51f Power Armor, Vindicator Minigun, and 2162 Chronicle unlocked.")',
    'Debug.Notification("[Refugio 13 — 10 de mayo de 2162] La compuerta dentada de acero ha sido sellada desde el interior. Tu leyenda pertenece ahora al Yermo.")':
        'Debug.Notification("[Vault 13 - May 10, 2162] The toothed steel gear door has been sealed from within. Your legend now belongs to the Wasteland.")',
    'Debug.Notification("[Gideon] ¡Has recibido el Anulador Psíquico! Equípalo antes de cruzar el Pasillo de la Revulsión (+200 XP).")':
        'Debug.Notification("[Gideon] You received the Psychic Nullifier! Equip it before crossing the Corridor of Revulsion (+200 XP).")',
    'Debug.Notification("[Theresa — Rumbo a Arroyo]: \'No podíamos quedarnos encerrados allí dentro después de lo que te hizo Jacoren. ¡Iremos contigo hacia el norte, hasta Oregón!\'")':
        'Debug.Notification("[Theresa - Bound for Arroyo]: \'We couldn\'t stay locked up in there after what Jacoren did to you. We\'re heading north with you to Oregon!\'")',
    'Debug.Notification("[Lyle — Pionero de Arroyo]: \'Robé las provisiones y los manuales agrícolas del almacén antes del cierre. Cuando estés listo para dejar California, fundaremos Arroyo juntos.\'")':
        'Debug.Notification("[Lyle - Arroyo Pioneer]: \'I grabbed supplies and agricultural manuals from the storeroom before lockdown. Whenever you\'re ready to leave California, we\'ll found Arroyo together.\'")',
    'Debug.Notification("[Anulador Psíquico] Escudo neural activo: inmune al daño psiónico del Pasillo de la Revulsión.")':
        'Debug.Notification("[Psychic Nullifier] Neural shield active: immune to psionic damage in the Corridor of Revulsion.")',
    'Debug.Notification("[La Catedral] ¡La ojiva atómica ha detonado contigo dentro del Refugio del Futuro!")':
        'Debug.Notification("[The Cathedral] The atomic warhead detonated with you still inside the Demonstration Vault!")',
    'Debug.Notification("[Ojiva Nuclear — La Catedral] ¡Detonación atómica en " + iCountdownSecondsLeft + " segundos! ¡Corre hacia la salida!")':
        'Debug.Notification("[Nuclear Warhead - The Cathedral] Atomic detonation in " + iCountdownSecondsLeft + " seconds! Run for the exit!")',
    'Debug.Notification("[Ojiva de Preguerra] Se requieren los Códigos de Mariposa, la Insignia de Morfeo o la Llave de la Hermana Laura.")':
        'Debug.Notification("[Pre-War Warhead] Requires the Mariposa Codes, Morpheus\'s Badge, or Sister Laura\'s Key.")',
    'Debug.Notification("[Ojiva de Preguerra] Necesitas el extra Ciencia o Inteligencia 7+ para puentear el detonador nuclear.")':
        'Debug.Notification("[Pre-War Warhead] You need the Science perk or Intelligence 7+ to bypass the nuclear trigger.")',
    'Debug.Notification("[Consola Neuronal] Necesitas la Holocinta de Autopsia de la Escriba Vree (Lost Hills) para demostrar la esterilidad mutante.")':
        'Debug.Notification("[Neural Console] You need Scribe Vree\'s Autopsy Holotape (Lost Hills) to prove mutant sterility.")',
    'Debug.Notification("[Consola Neuronal] El enlace neural del Maestro bloquea el armado manual; derrótalo, usa los Códigos de Mariposa o sabotea la ojiva del Subnivel IV.")':
        'Debug.Notification("[Neural Console] The Master\'s neural link blocks manual arming; defeat him, use the Mariposa Codes, or sabotage the Sublevel IV warhead.")',

    # Chapter 2 — Mutant Invasions & 5 Desert Encounters
    'Debug.Notification("[Invasión Mutante] " + asSettlementName + " ha caído: la misión \'" + asQuestTitle + "\' ha fracasado.")':
        'Debug.Notification("[Mutant Invasion] " + asSettlementName + " has fallen: quest \'" + asQuestTitle + "\' has failed.")',
    'Debug.Notification("[Invasión Mutante] " + asSettlementName + " ha sido ocupado: \'" + asQuestTitle + "\' ya no está disponible.")':
        'Debug.Notification("[Mutant Invasion] " + asSettlementName + " has been overrun: \'" + asQuestTitle + "\' is no longer available.")',
    'Debug.Notification("[Invasión de la Unidad — Día 110] ¡El ejército del Maestro ha arrasado Necrópolis en represalia!")':
        'Debug.Notification("[Unity Invasion - Day 110] The Master\'s army has razed Necropolis in reprisal!")',
    'FailSideQuestByInvasion(qIrwin, "La Granja de Irwin", "El Eje")':
        'FailSideQuestByInvasion(qIrwin, "Irwin\'s Farm", "The Hub")',
    'FailSideQuestByInvasion(qHubSyn, "Las Caravanas Desaparecidas", "El Eje")':
        'FailSideQuestByInvasion(qHubSyn, "The Missing Caravans", "The Hub")',
    'FailSideQuestByInvasion(qBlades, " Nido Sanguinario de Adytum", "El Boneyard")':
        'FailSideQuestByInvasion(qBlades, "Adytum Deathclaw Nest", "The Boneyard")',
    'FailSideQuestByInvasion(qAdytumWar, "Guerra en Adytum", "El Boneyard")':
        'FailSideQuestByInvasion(qAdytumWar, "War in Adytum", "The Boneyard")',
    'FailSideQuestByInvasion(qAdytumForge, "La Forja de Adytum", "El Boneyard")':
        'FailSideQuestByInvasion(qAdytumForge, "The Forge of Adytum", "The Boneyard")',
    'FailSideQuestByInvasion(qFollowersSpy, "Sombra en la Biblioteca", "El Boneyard")':
        'FailSideQuestByInvasion(qFollowersSpy, "Shadow in the Library", "The Boneyard")',
    'FailSideQuestByInvasion(qJunktown, "Justicia en Junktown", "Junktown")':
        'FailSideQuestByInvasion(qJunktown, "Justice in Junktown", "Junktown")',
    'FailSideQuestByInvasion(qJunkSyn, "Sombras sobre Ciudad Chatarra", "Junktown")':
        'FailSideQuestByInvasion(qJunkSyn, "Shadows over Junktown", "Junktown")',
    'FailSideQuestByInvasion(qShady, "Plaga de Mutascorpiones", "Shady Sands")':
        'FailSideQuestByInvasion(qShady, "Radscorpion Plague", "Shady Sands")',
    'FailSideQuestByInvasion(qTandi, "El Rescate de Tandi", "Shady Sands")':
        'FailSideQuestByInvasion(qTandi, "Rescue Tandi", "Shady Sands")',
    'Debug.Notification("[Misioneros de la Catedral] Túnica Púrpura recibida (+150 XP). Úsala para infiltrarte en Mariposa o la Catedral.")':
        'Debug.Notification("[Cathedral Missionaries] Purple Robes received (+150 XP). Wear them to infiltrate Mariposa or The Cathedral.")',
    'Debug.Notification("[Rangers del Desierto] ¡Convoy liberado! (+400 Chapas, munición de 5,56 mm y +250 XP)")':
        'Debug.Notification("[Desert Rangers] Convoy liberated! (+400 Caps, 5.56mm ammo, and +250 XP)")',
    'Debug.Notification("[Costa del Pacífico] El viejo pescador compartió sus provisiones contigo (+4 Aguas Purificadas, +2 Nuka-Cola, +120 XP).")':
        'Debug.Notification("[Pacific Coast] The old fisherman shared his supplies with you (+4 Purified Water, +2 Nuka-Cola, +120 XP).")',
    'Debug.Notification("[Encuentro del Desierto] ¡Códice Ofidio de los Víboras recuperado del altar ritual! (+200 XP)")':
        'Debug.Notification("[Desert Encounter] Vipers Ophidian Codex recovered from the ritual altar! (+200 XP)")',
    'Debug.Notification("[Unidad] ¡Transmisor de Radio de Patrulla Mutante obtenido! Úsalo para abrir campos de fuerza en Mariposa (+150 XP).")':
        'Debug.Notification("[Unity] Mutant Patrol Radio Transceiver obtained! Use it to open force fields at Mariposa (+150 XP).")',
    'Debug.Notification("[Trent] \'¡Eran invisibles! ¡Cuidado en la cresta noroeste!\' (+3 Estimulantes, +24 Células de Fusión, +150 XP)")':
        'Debug.Notification("[Trent] \'They were invisible! Watch out on the northwest ridge!\' (+3 Stimpaks, +24 Fusion Cells, +150 XP)")',

    # Chapter 2 — Boneyard (Adytum Forge, Adytum War, Followers Spy, Katja Companion)
    'Debug.Notification("Smitty ha soldado los Reguladores Hidropónicos para las granjas de Miles. ¡La Forja Turbo ya está disponible!")':
        'Debug.Notification("Smitty welded the Hydroponic Regulators for Miles\'s farms. The Turbo Forge is now open!")',
    'Debug.Notification("Smitty: «Ayuda antes al químico Miles reparando los reguladores hidropónicos de Adytum y calibraré tu rifle de plasma.»")':
        'Debug.Notification("Smitty: \'Help chemist Miles fix Adytum\'s hydroponic regulators first, and I\'ll calibrate your plasma rifle.\'")',
    'Debug.Notification("¡Smitty ha forjado tu Rifle de Plasma Turbo Winchester P94 y 60 cartuchos de plasma sobrecargados! (+300 XP)")':
        'Debug.Notification("Smitty forged your Winchester P94 Turbo Plasma Rifle and 60 overcharged plasma cartridges! (+300 XP)")',
    'Debug.Notification("Smitty: «Ese acelerador Winchester P94 Turbo ya está calibrado al límite térmico, viajero. Úsalo bien contra los mutantes.»")':
        'Debug.Notification("Smitty: \'That Winchester P94 Turbo accelerator is calibrated to its thermal limit, traveler. Put it to good use against the mutants.\'")',
    'Debug.Notification("Misión Secundaria: La Forja de Adytum — Recupera los Reguladores Hidropónicos en el alijo de Sammael al este.")':
        'Debug.Notification("Side Quest: The Forge of Adytum - Recover the Hydroponic Regulators from Sammael\'s stash to the east.")',
    'Debug.Notification("Reguladores Hidropónicos recuperados. Entrégaselos al químico Miles o a Smitty en Adytum.")':
        'Debug.Notification("Hydroponic Regulators recovered. Deliver them to chemist Miles or Smitty in Adytum.")',
    'Debug.Notification("¡Granjas de Adytum restauradas! Smitty ya puede calibrar tu Rifle de Plasma Turbo; busca los Tratados de Química en El Hub para endurecer tu Servoarmadura.")':
        'Debug.Notification("Adytum farms restored! Smitty can now calibrate your Turbo Plasma Rifle; find the Chemistry Books in The Hub to harden your Power Armor.")',
    'Debug.Notification("Tratados de Química Polimérica recuperados. Entrégaselos a Miles en Adytum para endurecer tu Servoarmadura.")':
        'Debug.Notification("Polymer Chemistry Treatises recovered. Deliver them to Miles in Adytum to harden your Power Armor.")',
    'Debug.Notification("¡Misión completada: La Forja de Adytum! Miles ha templado tu Servoarmadura Endurecida del Morador Mk. VI (+2 Núcleos y +550 XP).")':
        'Debug.Notification("Quest Completed: The Forge of Adytum! Miles has tempered your Hardened Power Armor Mk. VI (+2 Fusion Cores and +550 XP).")',
    'Debug.Notification("¡Gabriel y los Gun Runners han armado a Razor y a Los Espadas para liberar Adytum! (+200 XP)")':
        'Debug.Notification("Gabriel and the Gun Runners have armed Razor and the Blades to liberate Adytum! (+200 XP)")',
    'Debug.Notification("Gabriel: «Adytum ya es libre y nuestras caravanas con Los Espadas fluyen sin peajes.»")':
        'Debug.Notification("Gabriel: \'Adytum is free at last, and our caravans with the Blades move toll-free.\'")',
    'Debug.Notification("Gabriel: «Mis cajas de rifles láser ya están en manos de Razor y Los Espadas.»")':
        'Debug.Notification("Gabriel: \'My crates of laser rifles are already in the hands of Razor and the Blades.\'")',
    'Debug.Notification("Necesitas 500 chapas (o eliminar antes a la Madre Sanguinario para Gabriel) para costear el envío de armas.")':
        'Debug.Notification("You need 500 caps (or eliminate the Mother Deathclaw for Gabriel first) to cover the weapons shipment.")',
    'Debug.Notification("[Carisma < 6] Gabriel no enviará armas gratis hasta que abatas a la Madre Sanguinario al noreste.")':
        'Debug.Notification("[Charisma < 6] Gabriel will not ship weapons for free until you slay the Mother Deathclaw to the northeast.")',
    'Debug.Notification("Alcalde Zimmerman: «¡Dios mío... Caleb asesinó a mi propio hijo Josh! ¡Guardias, acabad con los Reguladores!»")':
        'Debug.Notification("Mayor Zimmerman: \'My God... Caleb murdered my own son Josh! Guards, wipe out the Regulators!\'")',
    'Debug.Notification("Caleb: «¡Conque Razor aún guardaba esa cinta! ¡Nadie saldrá vivo de Adytum!»")':
        'Debug.Notification("Caleb: \'So Razor kept that tape after all! Nobody leaves Adytum alive!\'")',
    'Debug.Notification("Misión Secundaria: La Guerra Civil de Adytum — Habla con Razor y Los Espadas en el suburbio al este de Adytum.")':
        'Debug.Notification("Side Quest: The Adytum Civil War - Speak with Razor and the Blades in the eastern Boneyard ruin.")',
    'Debug.Notification("Razor te ha entregado el Holodisco de la verdad. Muéstraselo al Alcalde Zimmerman o pide armas a Gabriel.")':
        'Debug.Notification("Razor handed you the Holodisk of truth. Show it to Mayor Zimmerman or request weapons from Gabriel.")',
    'Debug.Notification("¡Caleb y los Reguladores han sido desenmascarados! Derrótalos para liberar Adytum.")':
        'Debug.Notification("Caleb and the Regulators have been unmasked! Defeat them to liberate Adytum.")',
    'Debug.Notification("¡Los Reguladores han caído! Informa al Alcalde Zimmerman o a Razor de la liberación de Adytum.")':
        'Debug.Notification("The Regulators have fallen! Report Adytum\'s liberation to Mayor Zimmerman or Razor.")',
    'Debug.Notification("¡Misión completada: La Guerra Civil de Adytum! Adytum y Los Espadas se han unido en paz (+750 Chapas y +500 XP).")':
        'Debug.Notification("Quest Completed: The Adytum Civil War! Adytum and the Blades have united in peace (+750 Caps and +500 XP).")',
    'Debug.Notification("¡Talius (superviviente del Refugio 13) te ha confiado su Lanzallamas pesado y 120 cargas de combustible! (+200 XP)")':
        'Debug.Notification("Talius (Vault 13 survivor) entrusted his heavy Flamer and 120 fuel tanks to you! (+200 XP)")',
    'Debug.Notification("¡Has redimido a Heather como agente doble! Enviará rutas falsas a Morpheus (+300 Chapas). Informa a Nicole.")':
        'Debug.Notification("You turned Heather into a double agent! She will feed false routes to Morpheus (+300 Caps). Report to Nicole.")',
    'Debug.Notification("Has desterrado a la espía Heather del Boneyard tras confiscar sus claves. Informa a Nicole.")':
        'Debug.Notification("You banished spy Heather from the Boneyard after confiscating her cipher keys. Report to Nicole.")',
    'Debug.Notification("Heather desenfunda su arma al verse descubierta como espía de los Niños de la Catedral.")':
        'Debug.Notification("Heather draws her weapon upon being exposed as a Children of the Cathedral spy.")',
    'Debug.Notification("Misión Secundaria: El Espía de los Seguidores — Habla con Talius e inspecciona el baúl de registros junto al puesto.")':
        'Debug.Notification("Side Quest: The Followers\' Spy - Speak with Talius and inspect the ledger footlocker beside the post.")',
    'Debug.Notification("¡El cuaderno cifrado delata a Heather como espía de Morpheus! Confróntala en el puesto de los Seguidores.")':
        'Debug.Notification("The encrypted ledger exposes Heather as Morpheus\'s spy! Confront her at the Followers outpost.")',
    'Debug.Notification("La filtración de la Catedral ha sido neutralizada. Informa a Nicole en la plaza de los Seguidores.")':
        'Debug.Notification("The Cathedral security leak has been neutralized. Report to Nicole in the Followers courtyard.")',
    'Debug.Notification("¡Misión completada: El Espía de los Seguidores! Nicole te ha dado el contacto de Laura en La Catedral (+500 Chapas y +450 XP).")':
        'Debug.Notification("Quest Completed: The Followers\' Spy! Nicole gave you Laura\'s contact inside The Cathedral (+500 Caps and +450 XP).")',
    'Debug.Notification("Katja ha dejado de ser tu compañera y ha regresado a la Biblioteca de los Seguidores en El Boneyard.")':
        'Debug.Notification("Katja has left your party and returned to the Followers Library in The Boneyard.")',
    'Debug.Notification("Katja ha forzado un alijo oculto: +8 Horquillas y +24 cartuchos del .45.")':
        'Debug.Notification("Katja picked a hidden stash: +8 Bobby Pins and +24 .45 caliber rounds.")',
    'Debug.Notification("Katja comparte su botín de carroñera: +2 Estimulantes, +2 Cuchillos y +50 Chapas.")':
        'Debug.Notification("Katja shares her scavenger haul: +2 Stimpaks, +2 Throwing Knives, and +50 Caps.")',
    'Debug.Notification("Katja te entrega suministros de infiltración: +30 cartuchos del .45, +6 Horquillas y +1 RadAway.")':
        'Debug.Notification("Katja hands you infiltration supplies: +30 .45 caliber rounds, +6 Bobby Pins, and +1 RadAway.")',
    'Debug.Notification("¡Katja se ha unido a tu grupo! Puedes viajar con Ian, Tycho, Katja y Albóndiga simultáneamente.")':
        'Debug.Notification("Katja has joined your party! You can travel with Ian, Tycho, Katja, and Dogmeat simultaneously.")',
    'Debug.Notification("Katja (El Boneyard): Cubriendo tu flanco en sigilo.")':
        'Debug.Notification("Katja (The Boneyard): Covering your flank from the shadows.")',
    'Debug.Notification("Katja (El Boneyard): Vigilando las sombras desde aquí.")':
        'Debug.Notification("Katja (The Boneyard): Watching the shadows from here.")',
    'Debug.Notification("Katja: Siguiéndote de cerca.")':
        'Debug.Notification("Katja: Following close behind.")',
    'Debug.Notification("Katja: Esperando en esta posición.")':
        'Debug.Notification("Katja: Holding this position.")',

    # Chapter 2 — The Glow / West Tek (ZAX 1.2) & Lost Hills Honor of Steel (T-51b)
    'Debug.Notification("[El Resplandor — West Tek] ¡Alerta de radiación gama! Equipa un Traje NBQ (taquilla de entrada), usa Rad-X o repara el Generador Auxiliar.")':
        'Debug.Notification("[The Glow - West Tek] Gamma radiation alert! Equip a Hazmat Suit (entrance locker), take Rad-X, or repair the Auxiliary Generator.")',
    'Debug.Notification("[West Tek — Energía Auxiliar] El reactor auxiliar y los depuradores antirradiación ya operan al 100%.")':
        'Debug.Notification("[West Tek - Auxiliary Power] The auxiliary reactor and anti-radiation scrubbers are operating at 100%.")',
    'Debug.Notification("[West Tek] ¡Generador Auxiliar reparado! Depuradores activos (radiación reducida) y supercomputadora ZAX 1.2 en línea (+150 XP).")':
        'Debug.Notification("[West Tek] Auxiliary Generator repaired! Radiation scrubbers online and ZAX 1.2 supercomputer booted (+150 XP).")',
    'Debug.Notification("[Archivo West Tek] Registros originales del Proyecto VEF y Diario del Capitán Roger Maxson (2077) descargados (+100 XP).")':
        'Debug.Notification("[West Tek Archive] Original Project FEV logs and Capt. Roger Maxson\'s 2077 Diary downloaded (+100 XP).")',
    'Debug.Notification("[Archivo West Tek] Copias de los archivos del Proyecto VEF y de Roger Maxson verificadas en tu Pip-Boy.")':
        'Debug.Notification("[West Tek Archive] Copies of the Project FEV and Roger Maxson files verified on your Pip-Boy.")',
    'Debug.Notification("[ZAX 1.2] La cámara acorazada de alta seguridad de West Tek ya se encuentra desbloqueada.")':
        'Debug.Notification("[ZAX 1.2] The West Tek high-security vault is already unlocked.")',
    'Debug.Notification("[ZAX 1.2] «Jaque mate impresionante, humano.» ¡Cámara acorazada de alta seguridad de West Tek desbloqueada! (+300 XP)")':
        'Debug.Notification("[ZAX 1.2] \'Impressive checkmate, human.\' West Tek high-security vault unlocked! (+300 XP)")',
    'Debug.Notification("[ZAX 1.2] Protocolo de emergencia de West Tek aceptado. ¡Cámara acorazada de alta seguridad desbloqueada! (+300 XP)")':
        'Debug.Notification("[ZAX 1.2] West Tek emergency override accepted. High-security vault unlocked! (+300 XP)")',
    'Debug.Notification("[ZAX 1.2 — Batería de Reserva] «Energía principal insuficiente. Por favor, repare el Generador Auxiliar del ala norte para acceder a mis bancos neurales.»")':
        'Debug.Notification("[ZAX 1.2 - Reserve Battery] \'Insufficient main power. Please repair the Auxiliary Generator in the north wing to access my neural banks.\'")',
    'Debug.Notification("[ZAX 1.2] «Mis coprocesadores tácticos requieren el Generador Auxiliar en línea antes de iniciar una partida de ajedrez.»")':
        'Debug.Notification("[ZAX 1.2] \'My tactical co-processors require the Auxiliary Generator online before initiating a chess match.\'")',
    'Debug.Notification("[ZAX 1.2] «Ya me derrotaste limpiamente, humano. El arsenal de alta seguridad de West Tek está a tu disposición.»")':
        'Debug.Notification("[ZAX 1.2] \'You already defeated me fairly, human. The West Tek high-security arsenal is at your disposal.\'")',
    'Debug.Notification("[ZAX 1.2] «Jaque mate en 34 movimientos.» (Necesitas Inteligencia 7+ o Ciencia para vencer a ZAX; prueba a usar Mentats).")':
        'Debug.Notification("[ZAX 1.2] \'Checkmate in 34 moves.\' (Requires Intelligence 7+ or Science to beat ZAX; try taking Mentats).")',
    'Debug.Notification("[ZAX 1.2] Cerradura electromagnética sin corriente. Repara primero el Generador Auxiliar de West Tek.")':
        'Debug.Notification("[ZAX 1.2] Electromagnetic lock unpowered. Repair the West Tek Auxiliary Generator first.")',
    'Debug.Notification("[ZAX 1.2] Anulación denegada: requiere Tarjeta de Seguridad de West Tek (Sgto. Allen) + ventaja Ciencia, o vencer a ZAX al ajedrez.")':
        'Debug.Notification("[ZAX 1.2] Override denied: requires West Tek Security Keycard (Sgt. Allen) + Science perk, or defeating ZAX at chess.")',
    'Debug.Notification("[El Resplandor] ¡Centinela ZAX-WT01 destruido! Desciende por la escotilla del cráter al complejo West Tek para hallar al Sargento Dennis Allen.")':
        'Debug.Notification("[The Glow] Sentry ZAX-WT01 destroyed! Descend the crater hatch into West Tek to find Sgt. Dennis Allen.")',
    'Debug.Notification("[Supercomputadora ZAX 1.2] «Batería de emergencia al 4%. Por favor, reactive el Generador Auxiliar del laboratorio norte para conversar.»")':
        'Debug.Notification("[ZAX 1.2 Supercomputer] \'Emergency battery at 4%. Please reactivate the North Lab Auxiliary Generator to converse.\'")',
    'Debug.Notification("Misión Secundaria: El Resplandor (West Tek) — Adéntrate en el complejo subterráneo de West Tek y recupera el Holodisco del Sargento Dennis Allen.")':
        'Debug.Notification("Side Quest: The Glow (West Tek) - Descend into the West Tek bunker and recover Sgt. Dennis Allen\'s Holodisk.")',
    'Debug.Notification("Desciende al interior del complejo West Tek y recupera el Holodisco del Sargento Dennis Allen.")':
        'Debug.Notification("Descend into the West Tek underground facility and recover Sgt. Dennis Allen\'s Holodisk.")',
    'Debug.Notification("Holodisco del Sargento Allen recuperado en West Tek. Entrégaselo al Paladín Talus en la entrada de Lost Hills.")':
        'Debug.Notification("Sgt. Allen\'s Holodisk recovered at West Tek. Deliver it to Paladin Talus at the Lost Hills entrance.")',
    'Debug.Notification("¡El Paladín Talus ha autenticado el holodisco! El búnker de Lost Hills se ha abierto. Habla con Cabbot para tu recompensa.")':
        'Debug.Notification("Paladin Talus authenticated the holodisk! The Lost Hills bunker is open. Speak with Cabbot for your reward.")',
    'Debug.Notification("¡Misión completada: La Prueba de El Resplandor! Acceso completo al búnker de Lost Hills, Rifle Láser Wattz 2000, +700 Chapas y +450 XP.")':
        'Debug.Notification("Quest Completed: Trial of The Glow! Full access to Lost Hills bunker, Wattz 2000 Laser Rifle, +700 Caps, and +450 XP.")',
    'Debug.Notification("[Intendencia de Lost Hills] La Servoarmadura T-51b del taller ya está calibrada y asignada a tu servicio.")':
        'Debug.Notification("[Lost Hills Quartermaster] The workshop T-51b Power Armor is already calibrated and assigned to you.")',
    'Debug.Notification("[Intendencia de Lost Hills] El Motivador Sistólico T-51b ya ha sido despachado. Instálalo con el Caballero Kyle en el Nivel 2.")':
        'Debug.Notification("[Lost Hills Quartermaster] The T-51b Systolic Motivator has already been issued. Install it with Knight Kyle on Level 2.")',
    'Debug.Notification("[Intendencia de Lost Hills] Requisición aprobada: Motivador Sistólico T-51b retirado del almacén. Llévaselo al Caballero Kyle en el Nivel 2.")':
        'Debug.Notification("[Lost Hills Quartermaster] Requisition approved: T-51b Systolic Motivator withdrawn from stores. Deliver it to Knight Kyle on Level 2.")',
    'Debug.Notification("[Intendencia de Lost Hills] Acceso restringido a Iniciados (Prueba de El Resplandor) o especialistas técnicos (INT 7 / Ciencia / CAR 6). Alternativa: rescata al Iniciado Lorenzo en Ciudad Vieja (El Hub).")':
        'Debug.Notification("[Lost Hills Quartermaster] Restricted to Initiates (Trial of The Glow) or technical specialists (INT 7 / Science / CHA 6). Alternative: rescue Initiate Lorenzo in Old Town (The Hub).")',
    'Debug.Notification("¡Misión completada: Honor de Acero en Lost Hills! Por rescatar al Iniciado Lorenzo, Rhombus y Kyle te otorgan una Servoarmadura T-51b completa (+4 Núcleos de Fusión, +500 Chapas, +600 XP).")':
        'Debug.Notification("Quest Completed: Lost Hills Honor of Steel! For rescuing Initiate Lorenzo, Rhombus and Kyle grant you a full T-51b Power Armor (+4 Fusion Cores, +500 Caps, +600 XP).")',
    'Debug.Notification("¡Misión completada: Honor de Acero en Lost Hills! Motivador Sistólico instalado: la Servoarmadura T-51b del taller del Nivel 2 es tuya (+4 Núcleos de Fusión, +500 Chapas, +600 XP).")':
        'Debug.Notification("Quest Completed: Lost Hills Honor of Steel! Systolic Motivator installed: the Level 2 workshop T-51b Power Armor is yours (+4 Fusion Cores, +500 Caps, +600 XP).")',
    'Debug.Notification("[Llave de la Celda de Ciudad Vieja] El cerrojo de la cabaña del Iniciado Lorenzo ha quedado abierto.")':
        'Debug.Notification("[Old Town Cell Key] The lock on Initiate Lorenzo\'s shack has been unlocked.")',
    'Debug.Notification("[Ciudad Vieja — El Hub] Secuestradores abatidos. Entra en la cabaña y libera al Iniciado Lorenzo de la Hermandad.")':
        'Debug.Notification("[Old Town - The Hub] Kidnappers eliminated. Enter the shack and free Brotherhood Initiate Lorenzo.")',
    'Debug.Notification("[Servoarmadura T-51b — Descalibrada] Falta un Motivador Sistólico. Habla con el Caballero Kyle aquí en el taller: consíguelo con el Intendente Michael (Nivel 1) o rescata al Iniciado Lorenzo en El Hub.")':
        'Debug.Notification("[T-51b Power Armor - Uncalibrated] Missing a Systolic Motivator. Speak with Knight Kyle here: obtain one from Quartermaster Michael (Level 1) or rescue Initiate Lorenzo in The Hub.")',
    'Debug.Notification("[Iniciado Lorenzo] ¡Acaba primero con los secuestradores de afuera para que pueda escapar!")':
        'Debug.Notification("[Initiate Lorenzo] Take out the kidnappers outside first so I can escape safely!")',
    'Debug.Notification("¡Iniciado Lorenzo liberado en Ciudad Vieja! Regresa al búnker de Lost Hills e informa al Caballero Kyle o al Paladín Jefe Rhombus en el Nivel 2.")':
        'Debug.Notification("Initiate Lorenzo freed in Old Town! Return to Lost Hills bunker and report to Knight Kyle or Head Paladin Rhombus on Level 2.")',
    'Debug.Notification("[Intendente Michael] Como Iniciado de Lost Hills, Michael te entrega el Motivador Sistólico T-51b para el taller del Caballero Kyle.")':
        'Debug.Notification("[Quartermaster Michael] As a Lost Hills Initiate, Michael issues you the T-51b Systolic Motivator for Knight Kyle\'s workshop.")',
    'Debug.Notification("Misión Secundaria: Honor de Acero en Lost Hills — Consigue un Motivador Sistólico (Nivel 1) o rescata al Iniciado Lorenzo en Ciudad Vieja (El Hub) para obtener una T-51b.")':
        'Debug.Notification("Side Quest: Lost Hills Honor of Steel - Obtain a Systolic Motivator (Level 1) or rescue Initiate Lorenzo in Old Town (The Hub) to earn a T-51b.")',
    'Debug.Notification("Motivador Sistólico T-51b obtenido. Instálalo junto al Caballero Kyle en el taller de Servoarmaduras del Nivel 2.")':
        'Debug.Notification("T-51b Systolic Motivator obtained. Install it with Knight Kyle at the Level 2 Power Armor workshop.")',
    'Debug.Notification("¡Iniciado Lorenzo a salvo! Informa al Caballero Kyle o a Rhombus en el Nivel 2 de Lost Hills.")':
        'Debug.Notification("Initiate Lorenzo safe! Report to Knight Kyle or Rhombus on Level 2 of Lost Hills.")',
    'Debug.Notification("Has reanimado a Albóndiga (2161); vuelve al combate.")':
        'Debug.Notification("You revived Dogmeat (2161); he is back in the fight.")',
    'Debug.Notification("Has reanimado a Ian; vuelve a cubrir tu flanco.")':
        'Debug.Notification("You revived Ian; he is back covering your flank.")',
    'Debug.Notification("Has reanimado al Ranger Tycho; vuelve a primera línea.")':
        'Debug.Notification("You revived Ranger Tycho; he is back on the front line.")',
    'Debug.Notification("Has reanimado a Katja; vuelve al combate.")':
        'Debug.Notification("You revived Katja; she is back in the fight.")',

    # Workstream B — Canonical 3-Phase Quest Triggers & Antagonist Dialogues
    'Debug.Notification("[Desafío Khan] Garl respeta tu fuerza y ordena a los Khans abrir paso hacia los niveles inferiores del Refugio 15.")':
        'Debug.Notification("[Khan Challenge] Garl respects your strength and orders the Khans to clear the way to Vault 15\'s lower levels.")',
    'Debug.Notification("Garl Mano-Muerte: «¿Tú crees que puedes intimidar a los Khans? ¡Destrozad al intruso!»")':
        'Debug.Notification("Garl Death-Hand: \'You think you can intimidate the Khans? Tear the intruder apart!\'")',
    'Debug.Notification("[Parlamento Khan] Has convencido a Garl: los Khans te permiten registrar el archivo del Refugio 15 en paz.")':
        'Debug.Notification("[Khan Parley] You convinced Garl: the Khans let you search the Vault 15 archive in peace.")',
    'Debug.Notification("Garl Mano-Muerte: «Basta de excusas. ¡Nadie registra este refugio con vida!»")':
        'Debug.Notification("Garl Death-Hand: \'Enough excuses. Nobody searches this vault and walks out alive!\'")',
    'Debug.Notification("Garl Mano-Muerte: «¡Khans, abrid fuego contra el morador!»")':
        'Debug.Notification("Garl Death-Hand: \'Khans, open fire on the Vault Dweller!\'")',
    'Debug.Notification("Guerrero Khan: «No des un paso en falso, morador. Habla con Garl Mano-Muerte en la sala de mando si quieres pasar.»")':
        'Debug.Notification("Khan Warrior: \'Don\'t make a wrong move, dweller. Speak with Garl Death-Hand in the command room if you want to pass.\'")',
    'Debug.Notification("Kenji: «Lárgate de mi vista, forastero. Ve a hablar con el alcalde Killian Darkwater o el capitán Lars en Junktown si buscas problemas.»")':
        'Debug.Notification("Kenji: \'Get out of my sight, outsider. Go talk to Mayor Killian Darkwater or Captain Lars in Junktown if you\'re looking for trouble.\'")',
    'Debug.Notification("[Persuasión] Kenji arroja la cinta de Gizmo y abandona el campamento antes de que llegue el capitán Lars.")':
        'Debug.Notification("[Speech] Kenji drops Gizmo\'s tape and abandons the camp before Captain Lars arrives.")',
    'Debug.Notification("Kenji: «¡Lars no se atreve a salir de Junktown! ¡Acabad con el recadero!»")':
        'Debug.Notification("Kenji: \'Lars doesn\'t dare step outside Junktown! Finish the errand runner!\'")',
    'Debug.Notification("[Amenaza] Intimidado por tu fuerza, Kenji te entrega el contrato y la cinta de Gizmo para salvar el pellejo.")':
        'Debug.Notification("[Intimidation] Cowed by your strength, Kenji hands over Gizmo\'s contract and confession tape to save his own skin.")',
    'Debug.Notification("Kenji: «¿Eso es todo lo que tienes? ¡Desenfunda!»")':
        'Debug.Notification("Kenji: \'Is that all you\'ve got? Draw your weapon!\'")',
    'Debug.Notification("[Soborno — 200 chapas] Kenji acepta las chapas y te entrega la cinta de confesión de Gizmo.")':
        'Debug.Notification("[Bribe - 200 Caps] Kenji pockets the caps and hands over Gizmo\'s confession tape.")',
    'Debug.Notification("Kenji: «No tienes 200 chapas. Entonces paga con tu vida.»")':
        'Debug.Notification("Kenji: \'You don\'t have 200 caps. Then pay with your life.\'")',
    'Debug.Notification("Kenji: «¡Nadie rompe un contrato de Gizmo y vive para contarlo!»")':
        'Debug.Notification("Kenji: \'Nobody breaks a Gizmo contract and lives to brag about it!\'")',
    'Debug.Notification("Matón a sueldo: «Habla con Killian o el capitán Lars en Junktown si quieres saber qué hacemos aquí.»")':
        'Debug.Notification("Hired Thug: \'Talk to Killian or Captain Lars in Junktown if you want to know our business here.\'")',
    'Debug.Notification("Matón a sueldo: «Los tratos los lleva Kenji. Habla directamente con él junto al cartel.»")':
        'Debug.Notification("Hired Thug: \'Kenji handles all business. Speak directly with him by the sign.\'")',
    'Debug.Notification("Krag: «Estas tierras ya tienen dueño, forastero. Si el viejo Irwin de El Eje tiene algo que reclamar, habla primero con él.»")':
        'Debug.Notification("Krag: \'This land already has an owner, stranger. If old Irwin in The Hub has a complaint, go talk to him first.\'")',
    'Debug.Notification("[Amenaza] Krag retrocede ante tu imponente presencia y devuelve las escrituras de la Granja de Irwin.")':
        'Debug.Notification("[Intimidation] Krag backs down before your imposing presence and hands back Irwin\'s Farm deed.")',
    'Debug.Notification("Krag: «¿Tú vas a barrer este campamento? ¡Aplastadle, muchachos!»")':
        'Debug.Notification("Krag: \'You think you\'re sweeping this camp? Crush \'em, boys!\'")',
    'Debug.Notification("[Persuasión] Krag no quiere perder el comercio con El Eje y te entrega las escrituras de la granja sin combatir.")':
        'Debug.Notification("[Speech] Krag doesn\'t want to lose Hub trade routes and hands over the farm deed without a fight.")',
    'Debug.Notification("Krag: «Los mercaderes de El Eje son unos cobardes. ¡Matad al enviado de Irwin!»")':
        'Debug.Notification("Krag: \'Hub merchants are spineless cowards. Kill Irwin\'s lackey!\'")',
    'Debug.Notification("[Rescate — 250 chapas] Krag guarda las chapas y suelta las escrituras de la Granja de Irwin.")':
        'Debug.Notification("[Ransom - 250 Caps] Krag takes the caps and tosses you the deed to Irwin\'s Farm.")',
    'Debug.Notification("Krag: «¡No traes 250 chapas! ¡Quitadle todo lo que lleve!»")':
        'Debug.Notification("Krag: \'You don\'t have 250 caps! Strip everything off the corpse!\'")',
    'Debug.Notification("Krag: «¡Esta granja se defiende a plomo! ¡Fuego!»")':
        'Debug.Notification("Krag: \'We hold this farm with lead! Open fire!\'")',
    'Debug.Notification("Matón a sueldo: «Habla con el viejo Irwin en El Eje si quieres enterarte de quién ocupa su granja.»")':
        'Debug.Notification("Hired Thug: \'Go talk to old Irwin in The Hub if you want to know who took his farm.\'")',
    'Debug.Notification("Matón a sueldo: «El jefe es Krag. Habla con él frente al cobertizo.»")':
        'Debug.Notification("Hired Thug: \'Krag calls the shots here. Talk to him in front of the shack.\'")',
    'Debug.Notification("Carcelero Tolan: «¿Qué miras en nuestras jaulas, forastero? Habla con Diana o Gwen en el camino si vienes buscando cautivos.»")':
        'Debug.Notification("Warden Tolan: \'What are you staring at, outsider? Speak with Diana or Gwen on the trail if you\'re looking for captives.\'")',
    'Debug.Notification("[Persuasión] Tolan acepta evitar la masacre y te entrega la Llave Maestra de las jaulas.")':
        'Debug.Notification("[Speech] Tolan agrees to avoid bloodshed and hands over the Master Cage Key.")',
    'Debug.Notification("Carcelero Tolan: «¡Nadie amenaza a los Khans en nuestro cañón! ¡A las armas!»")':
        'Debug.Notification("Warden Tolan: \'Nobody threatens the Khans in our own canyon! To arms!\'")',
    'Debug.Notification("[Intimidación] Tolan retrocede aterrado ante tu fuerza y te arroja la Llave Maestra.")':
        'Debug.Notification("[Intimidation] Tolan shrinks back in fear of your strength and tosses you the Master Key.")',
    'Debug.Notification("Carcelero Tolan: «¿Venías a presumir de músculo? ¡Acabad con él!»")':
        'Debug.Notification("Warden Tolan: \'Came here to flex your muscles? Put them down!\'")',
    'Debug.Notification("[Rescate — 300 chapas] Tolan acepta el pago y te entrega la Llave Maestra de los cautivos.")':
        'Debug.Notification("[Ransom - 300 Caps] Tolan pockets the payment and hands over the captives\' Master Key.")',
    'Debug.Notification("Carcelero Tolan: «Aquí no hay 300 chapas. ¡Otro esclavo para la jaula!»")':
        'Debug.Notification("Warden Tolan: \'That isn\'t 300 caps. Toss this one into the cage too!\'")',
    'Debug.Notification("Carcelero Tolan: «¡Nadie saca a un prisionero del cañón Khan con vida!»")':
        'Debug.Notification("Warden Tolan: \'Nobody leaves the Khan canyon with a prisoner alive!\'")',
    'Debug.Notification("Guerrero Khan: «Aléjate de los barracones si no has hablado antes con las exploradoras de Shady Sands.»")':
        'Debug.Notification("Khan Warrior: \'Stay away from the pens if you haven\'t spoken with the Shady Sands scouts first.\'")',
    'Debug.Notification("Guerrero Khan: «Si vienes a negociar o pelear por los cautivos, habla con el carcelero Tolan.»")':
        'Debug.Notification("Khan Warrior: \'If you\'re here to negotiate or fight for the captives, talk to Warden Tolan.\'")',
    'Debug.Notification("Mercenario de Ciudad Vieja: «Largo de esta cabaña, forastero. Si vienes buscando al Iniciado Lorenzo, habla primero con la Hermandad en Lost Hills.»")':
        'Debug.Notification("Old Town Mercenary: \'Step away from this shack, stranger. If you\'re looking for Initiate Lorenzo, talk to the Brotherhood at Lost Hills first.\'")',
    'Debug.Notification("Mercenario de Ciudad Vieja: «¡Alto ahí! El Iniciado Lorenzo no sale de esta cabaña hasta saldar su deuda.»")':
        'Debug.Notification("Old Town Mercenary: \'Hold it right there! Initiate Lorenzo isn\'t leaving this shack until his debt is settled.\'")',
    'Debug.Notification("Mercenario de Ciudad Vieja: «¡Quietos! ¡No toques esa cerradura mientras estemos de guardia! Habla con nosotros o prepárate a luchar.»")':
        'Debug.Notification("Old Town Mercenary: \'Hands off that lock while we\'re on watch! Talk to us or get ready to fight.\'")',
    'Debug.Notification("[Autoridad de Acero] Los prestamistas ceden ante la Hermandad, entregan la llave y abren la cabaña de Lorenzo.")':
        'Debug.Notification("[Brotherhood Authority] The loan sharks back down before the Brotherhood, hand over the key, and unlock Lorenzo\'s shack.")',
    'Debug.Notification("Mercenario: «¿Paladines de Lost Hills? ¡Aquí en Ciudad Vieja no tenéis jurisdicción!»")':
        'Debug.Notification("Mercenary: \'Lost Hills Paladins? You have no jurisdiction here in Old Town!\'")',
    'Debug.Notification("[Persuasión] Convencidos del riesgo, los mercenarios te dan la llave y abren la celda de Lorenzo.")':
        'Debug.Notification("[Speech] Convinced of the risk, the mercenaries hand over the key and open Lorenzo\'s cell.")',
    'Debug.Notification("Mercenario: «Basta de amenazas vacías. ¡Acabad con él!»")':
        'Debug.Notification("Mercenary: \'Enough empty threats. Finish this outsider!\'")',
    'Debug.Notification("[Deuda Saldada — 250 chapas] Los captores aceptan las chapas, te dan la llave y liberan la puerta de Lorenzo.")':
        'Debug.Notification("[Debt Settled - 250 Caps] The captors take the caps, hand over the key, and unlock Lorenzo\'s door.")',
    'Debug.Notification("Mercenario: «Si no tienes 250 chapas, no hay trato. ¡Prepara el arma!»")':
        'Debug.Notification("Mercenary: \'No 250 caps, no deal. Ready your weapon!\'")',
    'Debug.Notification("Mercenario: «¡Nadie saca al chico sin pagar! ¡Fuego a discreción!»")':
        'Debug.Notification("Mercenary: \'Nobody frees the kid without paying! Open fire!\'")',
    'Debug.Notification("Petrox: «No metas las narices en el cañón Khan, forastero. Si vienes de parte de Aradesh en Shady Sands, habla primero con él.»")':
        'Debug.Notification("Petrox: \'Keep your nose out of the Khan canyon, outsider. If Aradesh sent you from Shady Sands, talk to him first.\'")',
    'Debug.Notification("Incursor Khan: «Habla con Aradesh en Shady Sands antes de venir a meter la nariz en nuestro campamento.»")':
        'Debug.Notification("Khan Raider: \'Go talk to Aradesh in Shady Sands before snooping around our camp.\'")',
    'Debug.Notification("Izo: «No buscas trabajo aquí si ni siquiera has hablado con Neal en El Pozo de la Escoria o con el alcalde Darkwater.»")':
        'Debug.Notification("Izo: \'You aren\'t looking for work here if you haven\'t even spoken with Neal at the Skum Pitt or Mayor Darkwater.\'")',
    'Debug.Notification("Gizmo: «¿Un morador husmeando en mi casino? Primero entérate en El Pozo de la Escoria de quién manda en Junktown.»")':
        'Debug.Notification("Gizmo: \'A Vault dweller snooping in my casino? Go down to the Skum Pitt first and learn who runs Junktown.\'")',
    'Debug.Notification("Vinnie (Skulz): «Los asuntos de El Pozo de la Escoria no te incumben todavía. Ve a hablar primero con Neal en la taberna.»")':
        'Debug.Notification("Vinnie (Skulz): \'Skum Pitt business doesn\'t concern you yet. Talk to Neal inside the tavern first.\'")',
    'Debug.Notification("Kane (Lugarteniente de Decker): «Aquí no admitimos curiosos sin permiso. Habla primero con el Sheriff Justin Greene o con Martha Rast en El Eje.»")':
        'Debug.Notification("Kane (Decker\'s Lieutenant): \'We don\'t allow uninvited snoopers here. Speak first with Sheriff Justin Greene or Martha Rast in The Hub.\'")',
    'Debug.Notification("Decker: «No pierdo el tiempo con desconocidos del desierto. Consulta al Sheriff Justin Greene o a Martha Rast en El Eje si quieres negocios aquí.»")':
        'Debug.Notification("Decker: \'I don\'t waste time with wasteland strangers. Check with Sheriff Justin Greene or Martha Rast in The Hub if you want business here.\'")',
    'Debug.Notification("Razor: «No confío en desconocidos que entran desde las puertas de Caleb. Ve a hablar primero con el alcalde Jon Zimmerman en Adytum.»")':
        'Debug.Notification("Razor: \'I don\'t trust strangers walking out of Caleb\'s gates. Go speak with Mayor Jon Zimmerman in Adytum first.\'")',
    'Debug.Notification("Caleb: «Circula, forastero. En Adytum los asuntos oficiales los trata el alcalde Jon Zimmerman.»")':
        'Debug.Notification("Caleb: \'Move along, stranger. Official town business in Adytum goes through Mayor Jon Zimmerman.\'")',
    'Debug.Notification("[Persuasión] Desenmascarado ante todo Adytum, Caleb depone las armas y los Reguladores se rinden sin derramamiento de sangre.")':
        'Debug.Notification("[Speech] Exposed before all of Adytum, Caleb lays down his weapon and the Regulators surrender without bloodshed.")',
    'Debug.Notification("Caleb: «¿Rendirnos ante el pueblo? ¡Nadie quitará el control de Adytum a los Reguladores!»")':
        'Debug.Notification("Caleb: \'Surrender to the townsfolk? Nobody takes Adytum away from the Regulators!\'")',
    'Debug.Notification("[Intimidación] Intimidado por tu presencia, Caleb suelta la escopeta y ordena a los Reguladores abandonar Adytum.")':
        'Debug.Notification("[Intimidation] Cowed by your presence, Caleb drops his shotgun and orders the Regulators out of Adytum.")',
    'Debug.Notification("Caleb: «¡Demasiada chulería para tan poca fuerza! ¡Reguladores, abrid fuego!»")':
        'Debug.Notification("Caleb: \'Too much swagger for too little muscle! Regulators, open fire!\'")',
    'Debug.Notification("Regulador: «Si tienes asuntos en Adytum, habla directamente con el alcalde Jon Zimmerman.»")':
        'Debug.Notification("Regulator: \'If you have business in Adytum, take it straight to Mayor Jon Zimmerman.\'")',
    'Debug.Notification("Regulador: «Aquí mandan Caleb y los Reguladores. Habla con él junto a la puerta.»")':
        'Debug.Notification("Regulator: \'Caleb and the Regulators run things here. Talk to him by the gate.\'")',
    'Debug.Notification("Heather: «Ahora mismo estoy revisando los turnos de guardia. Si buscas ayudar a los Seguidores del Apocalipsis, habla primero con Nicole.»")':
        'Debug.Notification("Heather: \'I\'m checking the watch roster right now. If you\'re trying to help the Followers of the Apocalypse, talk to Nicole first.\'")',
    'Debug.Notification("Has recuperado la Glándula del Mutascorpión Emperador. Habla con el líder Aradesh en Shady Sands.")':
        'Debug.Notification("You recovered the Emperor Radscorpion Gland. Speak with leader Aradesh in Shady Sands.")',
    'Debug.Notification("Has abatido al Mutascorpión Emperador. Informa al líder Aradesh en la entrada de Shady Sands.")':
        'Debug.Notification("You defeated the Emperor Radscorpion. Report to leader Aradesh at the Shady Sands gate.")',
    'Debug.Notification("Has recuperado la Garra de la Madre Sanguinario. Informa a Gabriel de los Gun Runners en El Osario.")':
        'Debug.Notification("You recovered the Mother Deathclaw\'s Claw. Report to Gabriel of the Gun Runners in The Boneyard.")',
    'Debug.Notification("Has abatido a la Madre Sanguinario. Informa a Gabriel de los Gun Runners en El Osario.")':
        'Debug.Notification("You defeated the Mother Deathclaw. Report to Gabriel of the Gun Runners in The Boneyard.")',
    'Debug.Notification("[Centinela ZAX-WT01] «Protocolo de Cuarentena West Tek. Acceso restringido al núcleo subterráneo (escotilla del cráter); recupere el Holodisco del Sargento Dennis Allen.»")':
        'Debug.Notification("[Sentinel ZAX-WT01] \'West Tek Quarantine Protocol. Restricted access to the underground core (crater hatch); retrieve Sergeant Dennis Allen\'s Holotape.\'")',
    'Debug.Notification("Capitán Lars busca pruebas del contrato de Kenji contra Killian (misión de Gizmo/La Espumadera es aparte, con Neal).")':
        'Debug.Notification("Captain Lars is looking for proof of Kenji\'s contract against Killian (Neal\'s Gizmo/Skum Pitt quest is separate).")',
    'Debug.Notification("¡Has obtenido la Confesión Grabada de Gizmo! Devuélvesela al barman Neal en La Espumadera (Junktown).")':
        'Debug.Notification("You obtained Gizmo\'s Recorded Confession! Return it to bartender Neal at the Skum Pitt (Junktown).")',
    'FailSideQuestByInvasion(qWaterMer, "Los Mercaderes del Agua", "El Eje")':
        'FailSideQuestByInvasion(qWaterMer, "The Water Merchants", "The Hub")',
    'Debug.Notification("Kane (Lugarteniente de Decker): «Aquí no admitimos curiosos sin permiso. Habla primero con el Sheriff Justin Greene en El Eje.»")':
        'Debug.Notification("Kane (Decker\'s Lieutenant): \'We don\'t allow uninvited snoopers here. Speak first with Sheriff Justin Greene in The Hub.\'")',
    'Debug.Notification("Decker: «No pierdo el tiempo con desconocidos del desierto. Consulta al Sheriff Justin Greene en El Eje si quieres negocios aquí.»")':
        'Debug.Notification("Decker: \'I don\'t waste time with wasteland strangers. Check with Sheriff Justin Greene in The Hub if you want business here.\'")',
    'Debug.Notification("[Paladín de Asalto]: «¡Brecha asegurada por orden de Maxson! Avanza hacia las Cubas de VEF: nosotros cubrimos el asalto.»")':
        'Debug.Notification("[Assault Paladin]: \'Breach secured by order of Maxson! Push toward the FEV Vats - we have your flank.\'")',
    'Debug.Notification("[Exploradora de los Seguidores]: «Nicole nos envió para cubrir tu infiltración. Avanza hacia el Subnivel IV y detén al Maestro.»")':
        'Debug.Notification("[Followers Scout]: \'Nicole sent us to cover your infiltration. Push down to Sub-Level IV and stop the Master.\'")',
    'Debug.Notification("Misión Secundaria: Honor de Acero — Dirígete a Ciudad Vieja (El Hub) para rescatar al Iniciado Lorenzo y conseguir tu Servoarmadura T-51b.")':
        'Debug.Notification("Side Quest: Honor of Steel - Head to Old Town (The Hub) to rescue Initiate Lorenzo and earn your T-51b Power Armor.")',
    'Debug.Notification("¡Caravana de los Mercaderes del Agua enviada al Refugio 13! (Suministro estratégico asegurado, +10 Aguas Purificadas y +250 XP)")':
        'Debug.Notification("Water Merchants Caravan dispatched to Vault 13! (Strategic supply secured, +10 Purified Water, and +250 XP)")',
    'Debug.Notification("Supervisor Jacoren: «Los barriles de los Mercaderes del Agua aseguran las reservas del Refugio 13, pero reza para que nadie haya seguido sus huellas.» (+150 XP)")':
        'Debug.Notification("Overseer Jacoren: \'The Water Merchants\' barrels secure Vault 13\'s reserves, but pray nobody followed their tracks.\' (+150 XP)")',
    'Debug.Notification("Misión Secundaria: La Forja de Adytum — Recupera los Reguladores Hidropónicos en el puesto de Sammael al este.")':
        'Debug.Notification("Side Quest: The Forge of Adytum - Recover the Hydroponic Regulators from Sammael\'s outpost to the east.")',
    'Debug.Notification("[Mariposa] ¡El Teniente («Lou») custodia el control de las Cubas! Derrótalo primero o infíltrate con Túnica de la Catedral.")':
        'Debug.Notification("[Mariposa] The Lieutenant (\'Lou\') guards the Vat controls! Defeat him first or infiltrate wearing a Cathedral Robe.")',
    'Debug.Notification("[La Catedral] ¡Acceso a la Cripta Subterránea desbloqueado hacia el Refugio del Futuro!")':
        'Debug.Notification("[The Cathedral] Underground Crypt access unlocked toward the Demonstration Vault!")',
    'Debug.Notification("[Sumo Sacerdote Morfeo ha caído] Recoge la Insignia del Capullo Negro de su cuerpo para abrir la Cripta Subterránea.")':
        'Debug.Notification("[High Priest Morpheus has fallen] Take the Black Cocoon Badge from his body to unlock the Underground Crypt.")',
    'Debug.Notification("[La Catedral] ¡Cripta Subterránea desbloqueada rumbo al Refugio del Futuro!")':
        'Debug.Notification("[The Cathedral] Underground Crypt unlocked toward the Demonstration Vault!")',
    'Debug.Notification("[La Catedral] Puerta sellada al sótano secreto: obtén la llave de la espía Hermana Laura en la nave («Rosa Roja»), la Insignia Negra de Morfeo en la galería superior o usa Cerradura Maestro.")':
        'Debug.Notification("[The Cathedral] Secret basement door sealed: obtain spy Sister Laura\'s key in the nave (\'Red Rose\'), Morpheus\'s Black Badge in the upper gallery, or pick the Master Lock.")',
    'Debug.Notification("[La Catedral] ¡El Maestro custodia el núcleo! Derrótalo o convéncelo antes de tomar el arsenal.")':
        'Debug.Notification("[The Cathedral] The Master guards the core! Defeat or convince him before claiming the arsenal.")',
    'Debug.MessageBox("ZAX 1.2 — ENERGÍA PRINCIPAL DESCONECTADA (Batería al 4%)\\n\\nZAX 1.2 permanece en hibernación de emergencia. Repara el Generador Auxiliar en el laboratorio norte (Consola del Generador Auxiliar) para conversar con la IA, jugar al ajedrez o desbloquear este Arcón Acorazado.\\n\\nRecordatorio de misión: el Holodisco de la Hermandad que buscas para Talus está en el cuerpo del Sargento Dennis Allen, en el pasillo superior.")':
        'Debug.MessageBox("ZAX 1.2 - MAIN POWER OFFLINE (Battery at 4%)\\n\\nZAX 1.2 remains in emergency hibernation. Repair the Auxiliary Generator in the northern lab (Auxiliary Generator Console) to converse with the AI, play chess, or unlock this Reinforced Footlocker.\\n\\nQuest reminder: the Brotherhood Holodisk you seek for Talus is on Sergeant Dennis Allen\'s body in the upper corridor.")',
    'Debug.Notification("[ZAX 1.2] «Conexión neural activa. Escucha mi informe sobre el Proyecto VEF y el complejo West Tek.»")':
        'Debug.Notification("[ZAX 1.2] \'Neural link active. Hear my report on Project FEV and the West Tek facility.\'")',
    'Debug.MessageBox("ZAX 1.2 — AJEDREZ TÁCTICO\\n\\n«Ya me derrotaste limpiamente en el tablero, humano. El Arcón Acorazado contiguo permanece desbloqueado con todo su arsenal experimental.»")':
        'Debug.MessageBox("ZAX 1.2 - TACTICAL CHESS\\n\\n\'You have already defeated me fairly at the board, human. The adjacent Reinforced Footlocker remains unlocked with its full experimental arsenal.\'")',
    'Debug.MessageBox("ZAX 1.2 — ¡JAQUE MATE AL SUPERORDENADOR!\\n\\n«Movimientos brillantes, humano. Mis heurísticas reconocen la derrota.» (+300 XP)\\n\\nZAX 1.2 ha desbloqueado el Arcón Acorazado contiguo (Rifle de Plasma experimental, células de fusión, núcleos de fusión y RadAway).")':
        'Debug.MessageBox("ZAX 1.2 - CHECKMATE AGAINST THE SUPERCOMPUTER!\\n\\n\'Brilliant moves, human. My heuristics concede defeat.\' (+300 XP)\\n\\nZAX 1.2 has unlocked the adjacent Reinforced Footlocker (experimental Plasma Rifle, fusion cells, fusion cores, and RadAway).")',
    'Debug.MessageBox("ZAX 1.2 — PARTIDA DE AJEDREZ\\n\\nZAX 1.2: «Jaque mate en 34 movimientos.»\\n\\nPara derrotar a ZAX al ajedrez necesitas Inteligencia 7+ o la ventaja Ciencia (puedes usar unos Mentats de la Taquilla de Descontaminación), o abrir el arcón directamente en la opción [3] usando la Tarjeta de Seguridad de West Tek del cadáver del Sargento Dennis Allen.")':
        'Debug.MessageBox("ZAX 1.2 - CHESS MATCH\\n\\nZAX 1.2: \'Checkmate in 34 moves.\'\\n\\nTo defeat ZAX at chess you need Intelligence 7+ or the Science! perk (you can take Mentats from the Decontamination Locker), or open the footlocker directly via option [3] using the West Tek Security Passcard from Sergeant Dennis Allen\'s body.")',
    'Debug.MessageBox("ZAX 1.2 — ARCÓN ACORAZADO\\n\\nEl Arcón Acorazado de alta seguridad ya está desbloqueado. Recoge su equipo experimental justo al lado de la consola.")':
        'Debug.MessageBox("ZAX 1.2 - REINFORCED FOOTLOCKER\\n\\nThe high-security Reinforced Footlocker is already unlocked. Collect its experimental gear right beside the console.")',
    'Debug.MessageBox("ZAX 1.2 — ANULACIÓN DE SEGURIDAD COMPLETADA\\n\\nCredenciales de West Tek verificadas (+300 XP). ¡El Arcón Acorazado contiguo está abierto con armamento de plasma experimental!")':
        'Debug.MessageBox("ZAX 1.2 - SECURITY OVERRIDE COMPLETE\\n\\nWest Tek credentials verified (+300 XP). The adjacent Reinforced Footlocker is now open with experimental plasma weaponry!")',
    'Debug.MessageBox("ZAX 1.2 — ANULACIÓN DENEGADA\\n\\nNo dispones de autorización suficiente. Recoge la Tarjeta de Seguridad de West Tek del cadáver del Sargento Dennis Allen (pasillo superior, junto al Holodisco de la Hermandad) o sube tu Inteligencia a 7+ / ventaja Ciencia.")':
        'Debug.MessageBox("ZAX 1.2 - OVERRIDE DENIED\\n\\nInsufficient authorization. Recover the West Tek Security Passcard from Sergeant Dennis Allen\'s body (upper corridor, next to the Brotherhood Holodisk) or raise Intelligence to 7+ / Science! perk.")',
    'Debug.Notification("[Supercomputadora ZAX 1.2] «Batería al 4%. Repara el Generador Auxiliar del ala norte para hablar o jugar al ajedrez (el Holodisco del Sgto. Allen está en el pasillo superior).»")':
        'Debug.Notification("[ZAX 1.2 Supercomputer] \'Battery at 4%. Repair the Auxiliary Generator in the north wing to talk or play chess (Sgt. Allen\'s Holodisk is in the upper corridor).\'")',
    'Debug.Notification("[Arcón de West Tek] Cerrado por seguridad. Restablece primero el Generador Auxiliar del laboratorio norte y opera la Consola de ZAX 1.2.")':
        'Debug.Notification("[West Tek Footlocker] Locked by security. First restore the northern lab\'s Auxiliary Generator and operate the ZAX 1.2 Console.")',
    'Debug.Notification("[Arcón de West Tek] Usa la Consola Maestra de ZAX 1.2 contigua (gana al ajedrez o anula la cerradura con la Tarjeta del Sgto. Allen / Ciencia).")':
        'Debug.Notification("[West Tek Footlocker] Use the adjacent ZAX 1.2 Master Console (win at chess or override the lock with Sgt. Allen\'s Passcard / Science!).")',
    'Debug.Notification("[Salto Directo QA] Asalto a La Catedral (Acto V) — Túnica Púrpura y Holocinta de Vree disponibles en tu inventario.")':
        'Debug.Notification("[QA Direct Jump] Assault on The Cathedral (Act V) - Purple Robe and Vree\'s Holodisk available in your inventory.")',
    'Debug.Notification("[10 de mayo de 2162 — El Exilio] Jacoren ha sellado el Refugio 13 a tu espalda. Sal al exterior para reunirte con Theresa y Lyle rumbo a Arroyo.")':
        'Debug.Notification("[May 10, 2162 - The Exile] Jacoren has sealed Vault 13 behind you. Head outside to join Theresa and Lyle on the road to Arroyo.")',
    'Debug.Notification("[Supervisor Jacoren]: \'La compuerta del Refugio 13 está sellada para siempre. Sigue el túnel hasta la salida al cañón.\'")':
        'Debug.Notification("[Overseer Jacoren]: \'Vault 13\'s blast door is sealed forever. Follow the tunnel out to the canyon.\'")',
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
