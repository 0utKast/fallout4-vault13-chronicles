# -*- coding: utf-8 -*-
"""
Quest-Reactive Radio Broadcast Definitions (ES + EN) for Radio El Eje / The Hub Radio (84.5 kHz).

Adds 85 new ElevenLabs DJ broadcasts (v13_radio_dj_26 .. v13_radio_dj_110, FormIDs 0x010E0001..0x010E0055)
on top of the original 25 broadcasts (v13_radio_dj_01 .. v13_radio_dj_25, FormIDs 0x01008601..0x01008619),
and groups all 110 broadcasts into 38 mutually-exclusive, collectively-exhaustive SCEN Phase CTDA slots.
"""

from __future__ import annotations

NEW_RADIO_DJ_DEFS: list[dict] = [
    # --- Slot 01 victory ID ---
    {
        "name": "v13_radio_dj_26",
        "sndr_fid": 0x010E0001,
        "edid": "SNDRV13RadioDJ26",
        "tts_es": (
            "Aquí Radio El Eje, transmitiendo en ochenta y cuatro punto cinco kilociclos desde una Nueva California "
            "por fin libre de la sombra mutante. Se acerca el amanecer de veintiún sesenta y dos, las rutas del sur "
            "vuelven a respirar y las torres de agua bombean sin miedo. Sintonizad vuestros receptores y brindad con nosotros: "
            "esta noche, la música suena a victoria."
        ),
        "tts_en": (
            "This is The Hub Radio, broadcasting at eighty-four point five kilocycles from a New California "
            "at last free of the mutant shadow. The dawn of twenty-one sixty-two draws near, the southern trails "
            "can breathe again, and the water towers pump without fear. Tune your dials and raise a glass with us: "
            "tonight, the music carries the sound of victory."
        ),
    },
    # --- Slot 02 Legend of Vault 13 Dweller ---
    {
        "name": "v13_radio_dj_27",
        "sndr_fid": 0x010E0002,
        "edid": "SNDRV13RadioDJ27",
        "tts_es": (
            "¿Recordáis aquel viajero ingenuo del mono azul con el trece dorado a la espalda que salió de las montañas "
            "buscando un simple chip purificador? Ya nadie le llama novato. Quienes lo cruzan en los puestos de caravanas "
            "hablan de una mirada templada por el yermo, pólvora en las botas y un nombre que ya repiten hasta en la Hermandad. "
            "Si escuchas esta frecuencia, amigo del trece: todo el desierto sabe que has vuelto a salvar a tu gente."
        ),
        "tts_en": (
            "Remember that wide-eyed wanderer in the crisp blue jumpsuit with a gold thirteen on the back who climbed down from the peaks "
            "hunting for a single water purifier chip? Nobody calls them a rookie anymore. Folks who pass them at the caravan posts "
            "speak of steady wasteland eyes, powder stains on their boots, and a name repeated even inside the Brotherhood. "
            "If you hear my signal, friend from Thirteen: half of California knows you just saved your home."
        ),
    },
    {
        "name": "v13_radio_dj_28",
        "sndr_fid": 0x010E0003,
        "edid": "SNDRV13RadioDJ28",
        "tts_es": (
            "Nos llega desde los pasos del Monte Whitney una noticia amarga que encoge el corazón de todo El Eje. "
            "Aseguran que, tras destruir a los ejércitos que amenazaban el yermo, el Supervisor Jacoren cerró la compuerta de acero "
            "del Refugio trece en las narices del mismo héroe que lo salvó todo. Qué injusto es a veces el miedo de quienes gobiernan... "
            "Pero que sepa ese exiliado que en cada taberna y cada caravana de California siempre tendrá un hogar."
        ),
        "tts_en": (
            "Bitter word has come down from the passes of Mount Whitney, the kind of story that weighs heavy on all of The Hub. "
            "Scouts swear that after shattering the armies threatening the wasteland, Overseer Jacoren sealed the great steel gear door "
            "of Vault Thirteen right in the face of the very hero who saved them all. Fear makes cowards of men behind desks... "
            "But let that exile hear us loud and clear: every tavern and campfire in California will always save you a seat."
        ),
    },
    # --- Slot 03 Patrick the Celt post-encounter intro ---
    {
        "name": "v13_radio_dj_29",
        "sndr_fid": 0x010E0004,
        "edid": "SNDRV13RadioDJ29",
        "tts_es": (
            "Un saludo muy cálido llega desde las dunas al norte de la ciudad. El viejo bardo errante Patrick el Celta "
            "mandó recado con los últimos caravaneros de que hace poco compartió fogata, guiso y un viejo medallón de trébol "
            "con cierto peregrino vestido del trece. Dice Patrick que hacía décadas que nadie escuchaba sus versos con tanta nobleza. "
            "Para celebrar ese encuentro bajo las estrellas, aquí vuelve su voz: la Balada de Na Fianna."
        ),
        "tts_en": (
            "A warm greeting just rode in from the northern dunes above town. The wandering bard Patrick the Celt "
            "sent word with the morning caravan that he recently shared a campfire, a hot meal, and an old shamrock medallion "
            "with a certain pilgrim wearing a Vault Thirteen suit. Patrick says it's been decades since anyone listened to his verses with such heart. "
            "To toast that night beneath the stars, here he goes again: the Ballad of Na Fianna."
        ),
    },
    # --- Slot 04 Act I Vault 15 ---
    {
        "name": "v13_radio_dj_30",
        "sndr_fid": 0x010E0005,
        "edid": "SNDRV13RadioDJ30",
        "tts_es": (
            "Atención a los exploradores y carroñeros que pongan rumbo al este de Shady Sands: los cañones que rodean el sepultado Refugio quince "
            "están bajo el control de los Khans, la banda de saqueadores liderada por el temible Garl Mano Muerta. "
            "Sus centinelas vigilan los montacargas de la entrada día y noche y no dejan pasar ni a las moscas sin pagar tributo. "
            "Si bajáis a buscar piezas de preguerra en esos túneles, id bien armados o preparad vuestro mejor discurso."
        ),
        "tts_en": (
            "Heads up for any scavengers riding east of Shady Sands: the canyons ringing the buried ruins of Vault Fifteen "
            "are swarming with the Khans, the ruthless raider clan led by warlord Garl Death-Hand. "
            "Their lookouts watch the elevator shafts day and night, and nobody steps down there without paying in caps or lead. "
            "If you go poking around for pre-war Vault-Tec parts in those tunnels, pack plenty of ammo or bring a silver tongue."
        ),
    },
    {
        "name": "v13_radio_dj_31",
        "sndr_fid": 0x010E0006,
        "edid": "SNDRV13RadioDJ31",
        "tts_es": (
            "Últimos ecos desde el cañón del Refugio quince: corre por las cantinas una anécdota que cuesta creer. "
            "Dicen que el mismísimo Garl Mano Muerta y sus Khans cedieron el paso hasta las compuertas del antiguo refugio "
            "a un forastero solitario sin disparar una sola bala, convencidos a pura labia o temerosos de su reputación. "
            "A veces una palabra firme a tiempo pesa más que un cargador entero de diez milímetros."
        ),
        "tts_en": (
            "Strange whispers drifting in from the canyon of Vault Fifteen, and folks in the bars can barely believe it. "
            "Word is that Garl Death-Hand himself and his Khan cutthroats stepped aside and let a lone stranger descend "
            "into the buried bunker without firing a single shot, out-talked or stared down at gunpoint. "
            "Goes to show that the right word at the right second can hit harder than a full clip of ten millimeter."
        ),
    },
    {
        "name": "v13_radio_dj_32",
        "sndr_fid": 0x010E0007,
        "edid": "SNDRV13RadioDJ32",
        "tts_es": (
            "Se confirma lo que muchos técnicos veteranos de El Eje sospechaban desde hace décadas: los niveles inferiores del Refugio quince "
            "quedaron sepultados por un derrumbe sísmico imposible de despejar. Quien buscara allí sistemas de purificación intactos "
            "solo encontró escombros y viejas holocintas hidrológicas que apuntan mucho más al sur, hacia las ruinas calcinadas de Bakersfield. "
            "Ánimo a quien siga tras esa pista: la carretera hacia Necrópolis no perdona errores."
        ),
        "tts_en": (
            "Confirmed at last what old Hub engineers feared for years: the lower living quarters of Vault Fifteen "
            "were crushed flat by a cave-in decades ago. Whoever went hunting down there for working water purifiers "
            "found nothing but rubble and an old hydrological holotape pointing south toward the scorched ruins of Bakersfield. "
            "Whoever you are following that trail, keep your head down: the road to Necropolis shows no mercy."
        ),
    },
    # --- Slot 05 Shady Sands Radscorpions ---
    {
        "name": "v13_radio_dj_33",
        "sndr_fid": 0x010E0008,
        "edid": "SNDRV13RadioDJ33",
        "tts_es": (
            "Boletín de las rutas del norte: las aldeas de adobe de Shady Sands vuelven a pedir ayuda a los viajeros valientes. "
            "Las cuevas cercanas están infestadas de mutascorpiones gigantes que atacan los corrales de brahmanes al caer la tarde, "
            "y el doctor Razlo busca desesperadamente glándulas frescas de veneno para fabricar su suero antídoto. "
            "Si pasáis por la puerta de Aradesh y Seth, vigilad las sombras... esos aguijones atraviesan la armadura de cuero como mantequilla."
        ),
        "tts_en": (
            "Northern trail advisory: the adobe village of Shady Sands is calling on brave wanderers for help. "
            "Nearby caverns are crawling with giant radscorpions raiding their brahmin pens at dusk, "
            "and Doctor Razlo desperately needs fresh venom glands to brew his antivenom serum. "
            "If you pass through Aradesh and Seth's gate, keep an eye on the rocks... those stingers punch straight through leather armor."
        ),
    },
    {
        "name": "v13_radio_dj_34",
        "sndr_fid": 0x010E0009,
        "edid": "SNDRV13RadioDJ34",
        "tts_es": (
            "Urgente desde la clínica de Shady Sands: el joven Jarvis agoniza tras recibir la picadura de un mutascorpión colosal. "
            "El capitán Seth ha acordonado la entrada mientras el doctor Razlo lucha por mantenerlo con vida a la espera de que alguien "
            "se adentre en la cueva del norte y abata al mutascorpión emperador. "
            "Corred la voz entre los mercenarios de la ruta: cada minuto cuenta para salvar a ese muchacho."
        ),
        "tts_en": (
            "Urgent word from the Shady Sands clinic: young Jarvis is clinging to life after taking a sting from a colossal radscorpion. "
            "Captain Seth has posted extra guards at the gate while Doctor Razlo fights to stabilize him, praying someone "
            "dares enter the northern caves and bring down the Emperor Radscorpion for its venom sac. "
            "Pass the word along the northern trail: every minute counts for that boy."
        ),
    },
    # --- Slot 06 Act II Necropolis, Set Deal & Water Pump ---
    {
        "name": "v13_radio_dj_35",
        "sndr_fid": 0x010E000A,
        "edid": "SNDRV13RadioDJ35",
        "tts_es": (
            "Últimas noticias que traen los buscadores de chatarra desde la ruta de Bakersfield: dicen que el misterioso viajero del Refugio trece "
            "acaba de adentrarse en las calles fantasma de Necrópolis, donde los necrófagos subterráneos mueren de sed "
            "desde que falló su bomba de agua y las alcantarillas se llenaron de radiación. "
            "Entre el trono de Set en la Sala de los Muertos y las patrullas mutantes de la superficie, caminar por esa ciudad es bailar sobre dinamita."
        ),
        "tts_en": (
            "Fresh word from scavengers skirting the ruins of Bakersfield: they say the lone traveller from Vault Thirteen "
            "has just slipped into the ghost streets of Necropolis, where the Underground ghouls have been rationing every drop "
            "ever since their main pump failed and the sewers turned foul. "
            "Between Set's throne in the Hall of the Dead and mutant patrols up top, walking those ruins is dancing on dynamite."
        ),
    },
    {
        "name": "v13_radio_dj_36",
        "sndr_fid": 0x010E000B,
        "edid": "SNDRV13RadioDJ36",
        "tts_es": (
            "Un rumor eléctrico corre hoy desde Bakersfield hasta las tabernas de El Eje: aseguran que el viajero del Refugio trece "
            "ha subido vivo de la Sala de los Muertos tras cerrar un acuerdo cara a cara con el mismísimo Set. "
            "El trato está sobre la mesa: bajar a las cloacas infestadas de necrófagos feroces a buscar las piezas hidráulicas perdidas, "
            "reparar la gran bomba de agua y barrer a los gigantes verdes de la Cuenca a cambio del paso al Refugio doce. Si lo logra, hará historia."
        ),
        "tts_en": (
            "An electric rumor is racing today from Bakersfield all the way to the taverns of The Hub: scouts swear the Vault Thirteen wanderer "
            "walked back out of the Hall of the Dead after striking a bargain face to face with Set himself. "
            "The deal is on: crawl into the ghoul-infested sewers to recover the missing hydraulic pump parts, "
            "fix the Great Water Pump, and drive the green giants out of the Watershed for access to Vault Twelve. Pull that off, and it's history."
        ),
    },
    {
        "name": "v13_radio_dj_37",
        "sndr_fid": 0x010E000C,
        "edid": "SNDRV13RadioDJ37",
        "tts_es": (
            "¡Último parte desde el subsuelo de Necrópolis! Los necrófagos de la alcantarilla aseguran haber visto a un caminante "
            "salir del taller subterráneo cargando por fin las pesadas piezas hidráulicas de cobre y acero entre los escombros inundados. "
            "Ahora queda la parte más peligrosa: cruzar la superficie hasta la Cuenca del Agua, sortear al temible Harry y sus supermutantes "
            "y acoplar los engranajes en la gran bomba antes de que se apague la última esperanza de dos refugios."
        ),
        "tts_en": (
            "Latest report from beneath the streets of Necropolis! Sewer ghouls swear they spotted a drenched wanderer "
            "climbing out of the sunken workshop hauling the heavy brass and steel hydraulic pump parts at last. "
            "Now comes the deadly part: crossing top-side to the Watershed, getting past Harry and his laser-toting Super Mutants, "
            "and fitting those parts into the Great Water Pump before two separate communities run out of time."
        ),
    },
    {
        "name": "v13_radio_dj_38",
        "sndr_fid": 0x010E000D,
        "edid": "SNDRV13RadioDJ38",
        "tts_es": (
            "¡Extra, extra en toda Nueva California! Los ecos metálicos que llegaban esta mañana desde las ruinas de Bakersfield no eran disparos... "
            "¡era el rugido de la Gran Bomba de Agua de Necrópolis volviendo a girar tras años de silencio! "
            "El agua limpia vuelve a correr por las cañerías de la Ciudad de los Muertos, el trato con Set está cumplido "
            "y la vieja compuerta del Refugio doce ha quedado al fin abierta, aunque Harry y su guardia siguen custodiando la entrada."
        ),
        "tts_en": (
            "Stop the presses across New California! That thunderous iron clanking heard near Bakersfield this morning wasn't artillery... "
            "it was the Great Water Pump of Necropolis roaring back to life after years of dead silence! "
            "Clean water is surging through the mains of the City of the Dead, the bargain with Set has been honored, "
            "and the access door to Vault Twelve now stands wide open — though Harry's mutant squad still holds the Watershed."
        ),
    },
    {
        "name": "v13_radio_dj_39",
        "sndr_fid": 0x010E000E,
        "edid": "SNDRV13RadioDJ39",
        "tts_es": (
            "Actualización para los mercaderes que rodean Bakersfield: increíble pero cierto, la gran bomba hidráulica de la Cuenca de Necrópolis "
            "sigue funcionando como un reloj suizo día y noche. Hasta los necrófagos del subsuelo brindan con agua cristalina sin radiación excesiva, "
            "y Set ha dejado en paz los túneles tras cumplirse el pacto. Quién nos iba a decir hace un año "
            "que hasta la Ciudad de los Muertos tendría agua corriente antes que media California."
        ),
        "tts_en": (
            "Update for traders skirting the ruins of Bakersfield: believe it or not, the great hydraulic pump in the Necropolis Watershed "
            "is still humming day and night like pre-war clockwork. Even the Underground ghouls are raising tin cups of clean water, "
            "and Set has kept his word down in the sewers. Who would have bet a single bottle cap a year ago "
            "that the City of the Dead would get fresh running water?"
        ),
    },
    # --- Slot 07 Act II Harry & Vault 13 Water Chip ---
    {
        "name": "v13_radio_dj_40",
        "sndr_fid": 0x010E000F,
        "edid": "SNDRV13RadioDJ40",
        "tts_es": (
            "Recordatorio técnico de esta casa mientras suben las rachas de viento sobre el Desierto de Mojave: "
            "el polvo fino de álcali devora los percutores de las pistolas de diez milímetros y recalienta las baterías de microfusión en cuestión de horas. "
            "Limpiad vuestras armas antes de dormir junto a la hoguera, revisad el filtro de vuestro Pip-Boy "
            "y recordad que una recarga encasquillada en el desierto suele ser la última. Aquí sigue Radio El Eje."
        ),
        "tts_en": (
            "A quick maintenance note from the booth as gusts pick up across the Mojave sands: "
            "fine alkali dust chews through ten millimeter firing pins and fouls microfusion contacts faster than you think. "
            "Strip and oil your iron before turning in by the fire, check the gasket on your Pip-Boy, "
            "and remember that a jammed mag in bad country is usually your last. Keep tuned to The Hub Radio."
        ),
    },
    {
        "name": "v13_radio_dj_41",
        "sndr_fid": 0x010E0010,
        "edid": "SNDRV13RadioDJ41",
        "tts_es": (
            "¡Esta historia va directa al salón de la fama de los parlanchines del yermo! Cuentan los prisioneros liberados en Bakersfield "
            "que alguien logró convencer cara a cara al gigantón supermutante Harry de que todo aquello era un malentendido, "
            "y que el hombreton verde recogió sus rifles láser y se marchó silbando de la Cuenca sin pegar un solo tiro. "
            "Con la vía despejada y el Chip de Agua del Refugio doce en la mochila, ese viajero corre ahora de vuelta hacia las montañas."
        ),
        "tts_en": (
            "Put this one straight into the wasteland tall-tale hall of fame! Freed ghoul captives in Bakersfield swear "
            "that a fast-talking stranger looked three-hundred-pound Super Mutant Harry right in the eye, convinced him the whole post was a mix-up, "
            "and sent the big green lug marching out of the Watershed without firing a single laser bolt. "
            "With the road clear and the Vault Twelve Water Chip packed away, our hero is racing west back toward the mountains."
        ),
    },
    {
        "name": "v13_radio_dj_42",
        "sndr_fid": 0x010E0011,
        "edid": "SNDRV13RadioDJ42",
        "tts_es": (
            "¡Trueno de láser y plomo sobre Bakersfield! Los vigías de las dunas vieron anoche destellos verdes y ráfagas pesadas "
            "salir de la planta de agua de Necrópolis: el temido Harry y su escuadrón de supermutantes cayeron derrotados "
            "en la mismísima Cuenca del Agua, liberando al prisionero necrófago y dejando paso libre hasta el ordenador central del Refugio doce. "
            "El Chip de Agua ha sido rescatado de las garras de la Unidad, y el héroe del trece vuelve hacia el oeste."
        ),
        "tts_en": (
            "Thunder and laser fire shook old Bakersfield last night! Dune lookouts watched emerald bolts and heavy gunfire "
            "light up the Necropolis Watershed: the feared mutant Harry and his patrol lie defeated right beside the water tanks, "
            "their ghoul prisoner freed and the central computer of Vault Twelve cracked wide open. "
            "The Water Chip is out of the Unity's reach at last, and the wanderer from Thirteen is heading home."
        ),
    },
    {
        "name": "v13_radio_dj_43",
        "sndr_fid": 0x010E0012,
        "edid": "SNDRV13RadioDJ43",
        "tts_es": (
            "Rumores de celebración nos llegan desde las cumbres ocultas al oeste de Shady Sands: los pocos mercaderes que abastecen el norte "
            "aseguran que las turbinas purificadoras del legendario Refugio trece han vuelto a rugir después de instalar un nuevo Chip de Agua. "
            "El peligro de la sed ha terminado para esa comunidad oculta... pero no os engañéis, caminantes: "
            "las patrullas mutantes de las montañas ya saben que ahí bajo late vida humana intacta, y esta historia apenas está entrando en su capítulo más oscuro."
        ),
        "tts_en": (
            "Whispers of quiet celebration drift down from the hidden peaks west of Shady Sands: northern traders say "
            "the purification turbines deep inside legendary Vault Thirteen are humming smoothly again with a replacement Water Chip online. "
            "Thirst will not claim that hidden sanctuary after all... yet make no mistake, folks: "
            "the mutant warbands combing the northern range know full well there are pure humans behind that vault door, and the darkest chapter is just beginning."
        ),
    },
    # --- Slot 08 Water Merchants Convoy ---
    {
        "name": "v13_radio_dj_44",
        "sndr_fid": 0x010E0013,
        "edid": "SNDRV13RadioDJ44",
        "tts_es": (
            "Despacho comercial desde la Gran Torre de Agua de los Mercaderes del Agua: Martha Rastello acaba de sellar un contrato "
            "de mil chapas en mano para enviar una caravana de cisternas hacia las montañas del noroeste con cien días extra de agua pura. "
            "Un negocio brillante en tiempos difíciles... aunque algunos veteranos del gremio fruncen el ceño en voz baja "
            "pensando en las profundas roderas que esos carros van a dejar marcadas en la arena hacia cierto refugio secreto."
        ),
        "tts_en": (
            "A trade dispatch straight from the Great Water Tower: Martha Rastello has just signed off on a crisp one-thousand-cap contract "
            "sending heavy water wagons northwest into the mountains, buying a hidden vault a hundred extra days of clean supply. "
            "Fine business in dry times... though a few veteran guards down in the yard mutter under their breath "
            "about the deep wagon tracks those heavy wheels will carve across the sand straight toward a secret door."
        ),
    },
    {
        "name": "v13_radio_dj_45",
        "sndr_fid": 0x010E0014,
        "edid": "SNDRV13RadioDJ45",
        "tts_es": (
            "Aquí se respira respeto por la gente de palabra: los Mercaderes del Agua han despachado un convoy de auxilio hacia el norte "
            "respaldado únicamente por la intachable reputación de un cliente en las calles de El Eje, sin pedirle ni una chapa por adelantado. "
            "Las cisternas ya ruedan por los desfiladeros cargadas de agua limpia. Cuidado en la ruta, conductores: "
            "dicen que las huellas frescas de carreta atraen últimamente a ojos verdes entre las rocas."
        ),
        "tts_en": (
            "Word and reputation still buy weight in this town: the Water Merchants just dispatched an emergency water train north "
            "on nothing more than a trusted hero's name and standing here in The Hub, without taking a single cap upfront. "
            "The cistern wagons are already rolling through the mountain passes. Watch your flanks, drivers: "
            "fresh wagon ruts in the dunes have a habit lately of drawing tall green scouts down from the ridges."
        ),
    },
    # --- Slot 09 Tandi Kidnapping ---
    {
        "name": "v13_radio_dj_46",
        "sndr_fid": 0x010E0015,
        "edid": "SNDRV13RadioDJ46",
        "tts_es": (
            "Un vistazo rápido a los mercados del centro de El Eje: si necesitáis cuerdas, ganzúas, cantimploras o una buena mochila de lona, "
            "Mitch en su tienda general sigue ofreciendo los precios más honestos al sur de Ciudad Chatarra. "
            "Y si pasáis por la tienda de Beth frente al cruce de caravanas, recordad que suele enterarse antes que el propio sheriff "
            "de cualquier tiroteo o hallazgo raro entre las dunas. Más vale un oído atento que diez balas mal gastadas."
        ),
        "tts_en": (
            "A quick swing through The Hub's central market: if you need rope, lockpicks, spare canteens, or sturdy canvas packs, "
            "Mitch over at the General Store still runs the fairest counter south of Junktown. "
            "And if you step into Beth's weapon shop by the caravan yard, keep your ears open — she usually hears about every firefight "
            "or strange ruin before the sheriff even saddles up. Sharp ears save more lives than blind lead."
        ),
    },
    {
        "name": "v13_radio_dj_47",
        "sndr_fid": 0x010E0016,
        "edid": "SNDRV13RadioDJ47",
        "tts_es": (
            "Aviso urgente que nos llega por posta desde Shady Sands: los saqueadores Khans de la banda de Petrox han asaltado el poblado de noche "
            "y han secuestrado a Tandi, la joven hija del líder Aradesh, arrastrándola hacia el campamento del cañón noreste. "
            "El pueblo entero está en vela junto a las antorchas esperando que algún aliado valiente siga el rastro y la traiga sana y salva. "
            "Si estás escuchando cerca de las montañas, Aradesh recompensa cualquier ayuda para rescatar a su hija."
        ),
        "tts_en": (
            "Urgent alert arriving by express rider from Shady Sands: Khan raiders under warboss Petrox struck the village in the night "
            "and kidnapped Tandi, young daughter of town leader Aradesh, dragging her off to their canyon camp to the northeast. "
            "The whole settlement is standing watch by torchlight, praying a brave ally tracks those hoofprints and brings her home safe. "
            "If you are anywhere near the northern pass, Aradesh is calling for help to rescue his girl."
        ),
    },
    {
        "name": "v13_radio_dj_48",
        "sndr_fid": 0x010E0017,
        "edid": "SNDRV13RadioDJ48",
        "tts_es": (
            "Campanas de alivio en los muros de Shady Sands: ¡Tandi ha vuelto sana y salva a los brazos de su padre Aradesh! "
            "Y lo más asombroso que cuentan en la puerta del poblado es que su salvador logró sacarla del campamento de Petrox "
            "sin desencadenar una carnicería, a base de astucia, sigilo o pura negociación frente a frente con los Khans. "
            "Hoy vuelve a haber música y calma junto a los cultivos de maíz y las acequias del norte."
        ),
        "tts_en": (
            "Bells of relief ringing across the mud walls of Shady Sands: Tandi is home safe in her father Aradesh's arms! "
            "Even better, the folks at the front gate swear her rescuer pulled her out of Petrox's Khan compound "
            "without a bloodbath, using sheer nerve, stealth, or clever bargaining right in the raiders' teeth. "
            "Tonight the cornfields and irrigation ditches of the northern frontier are quiet once more."
        ),
    },
    {
        "name": "v13_radio_dj_49",
        "sndr_fid": 0x010E0018,
        "edid": "SNDRV13RadioDJ49",
        "tts_es": (
            "¡Noticias de pólvora y justicia desde las colinas del norte! El campamento de los Khans donde Petrox retenía a la joven Tandi "
            "ha quedado convertido en humo y chatarra después de un asalto fulminante que barrió a sus secuestradores. "
            "Tandi ya descansa a salvo junto a Aradesh y el capitán Seth en Shady Sands, "
            "y los saqueadores del cañón tardarán muchos meses en volver a atreverse a bajar del monte."
        ),
        "tts_en": (
            "Justice and gunpowder out in the northern hills! The Khan camp where Petrox held young Tandi captive "
            "was left in smoking ruins after a lightning assault swept the kidnappers off the canyon rim. "
            "Tandi is resting safely back home with Aradesh and Captain Seth in Shady Sands, "
            "and it'll be a long cold winter before the Khans dare raid that farming valley again."
        ),
    },
    # --- Slot 10 Khans Slaver Camp ---
    {
        "name": "v13_radio_dj_50",
        "sndr_fid": 0x010E0019,
        "edid": "SNDRV13RadioDJ50",
        "tts_es": (
            "Consejo para los escoltas novatos que contratan los mercaderes en el Paso Oriental: nunca dejéis vuestro flanco descubierto "
            "cuando crucéis las gargantas de roca roja pasadas las cinco de la tarde. La sombra alargada del cañón es el escondite favorito "
            "de francotiradores con rifles de caza y trampas de cuerda. Un par de segundos mirando las crestas altas vale más que diez estimulantes."
        ),
        "tts_en": (
            "A word to green caravan guards signing on through the Eastern Pass: never let your right flank hang open "
            "once afternoon shadows stretch across those red rock gorges. Long canyon shadows are a sniper's best friend, "
            "ideal for ambushers with hunting rifles and tripwire charges. Two seconds scanning the rimrocks saves ten stimpaks later."
        ),
    },
    {
        "name": "v13_radio_dj_51",
        "sndr_fid": 0x010E001A,
        "edid": "SNDRV13RadioDJ51",
        "tts_es": (
            "Llamamiento de urgencia desde el puesto del Paso Oriental: la exploradora Diana y su compañera Gwen buscan ayuda desesperadamente "
            "para asaltar el campamento esclavista del carcelero Tolan en el cañón del noreste. "
            "Varios inocentes siguen encadenados detrás de las empalizadas de los Khans esperando un rescate antes de ser vendidos hacia el sur. "
            "Si tenéis buena puntería y nervios de acero, pasad por el puesto de Diana antes de cruzar la cordillera."
        ),
        "tts_en": (
            "Distress call coming in from the Eastern Pass outpost: scout Diana and her partner Gwen are calling for brave hands "
            "to strike jailer Tolan's Khan slaver camp up in the northeast canyon. "
            "Innocent captives are still chained behind timber walls waiting to be sold south unless somebody stops them. "
            "If your trigger finger is steady and your heart is in the right place, stop by Diana's campfire."
        ),
    },
    {
        "name": "v13_radio_dj_52",
        "sndr_fid": 0x010E001B,
        "edid": "SNDRV13RadioDJ52",
        "tts_es": (
            "Buenas nuevas desde el Paso Oriental: las jaulas del campamento esclavista de Tolan han sido abiertas de par en par "
            "y los prisioneros que los Khans retenían en el cañón vuelven a caminar libres hacia los asentamientos del valle. "
            "Diana y Gwen han izado bandera de ruta segura en la garganta, y el sello de guerra de aquellos traficantes ya no asusta a nadie. "
            "Un brindis por quienes rompen cadenas en silencio."
        ),
        "tts_en": (
            "Good news out of the Eastern Pass tonight: the iron cages at Tolan's slaver compound stand empty and broken, "
            "and the captives held by those Khan thugs are walking free back down into the valley towns. "
            "Diana and Gwen have raised the all-clear signal at the gorge, and Tolan's war seal is nothing but scrap metal. "
            "Raise a glass to folks who break chains out in the dark."
        ),
    },
    # --- Slot 11 Junktown Kenji / Killian ---
    {
        "name": "v13_radio_dj_53",
        "sndr_fid": 0x010E001C,
        "edid": "SNDRV13RadioDJ53",
        "tts_es": (
            "Atención en las murallas de Ciudad Chatarra: los vigías del capitán Lars sospechan que un sicario profesional llamado Kenji "
            "ha montado campamento en los viejos puestos al oeste de la ciudad esperando la señal de Gizmo para atentar contra el alcalde Killian Darkwater. "
            "El aire en la plaza mayor se puede cortar con un cuchillo, y Lars busca pruebas firmes para frustrar el complot antes de que corra la sangre."
        ),
        "tts_en": (
            "Alert along the scrap walls of Junktown: Captain Lars's patrols have spotted a cold-blooded mercenary named Kenji "
            "lurking at the ruins west of town, waiting for casino boss Gizmo's word to assassinate Mayor Killian Darkwater. "
            "You could cut the air on Main Street with a Bowie knife, and Lars needs solid evidence to nail the plot before bullets fly."
        ),
    },
    {
        "name": "v13_radio_dj_54",
        "sndr_fid": 0x010E001D,
        "edid": "SNDRV13RadioDJ54",
        "tts_es": (
            "¡Se frustró el atentado en Ciudad Chatarra! Gracias a unas pruebas contundentes puestas directamente sobre el escritorio del capitán Lars, "
            "el contrato del sicario Kenji saltó por los aires y el alcalde Killian Darkwater sigue firme al frente de su tienda y de la ley local. "
            "Cuentan que el mismísimo Tycho brindó anoche junto a los guardias de la puerta norte. Buena limpieza en Junktown, señores."
        ),
        "tts_en": (
            "Assassination plot busted wide open in Junktown! Thanks to airtight evidence laid straight on Captain Lars's desk, "
            "hitman Kenji's contract fell apart and Mayor Killian Darkwater still stands tall behind the Darkwater general counter. "
            "Folks say even Desert Ranger Tycho raised a glass with the north-gate guards last night. Clean work in Junktown."
        ),
    },
    # --- Slot 12 Junktown Syndicate (Skulz / Neal / Gizmo) ---
    {
        "name": "v13_radio_dj_55",
        "sndr_fid": 0x010E001E,
        "edid": "SNDRV13RadioDJ55",
        "tts_es": (
            "Si buscáis una cama limpia y una cerveza bien tirada camino del norte, recordad las dos reglas de oro de Ciudad Chatarra: "
            "guardad vuestras armas en la funda al entrar y tratad con respeto la taberna de La Espumadera de Neal. "
            "El viejo Neal sirve las bebidas más frías al sur de Shady Sands, y el hotel de Marcelles sigue siendo el único sitio de diez millas "
            "donde no te despiertan los ratones topo mordiéndote las botas."
        ),
        "tts_en": (
            "Looking for a clean bunk and an honest pour on the northern road? Remember the two golden rules of Junktown: "
            "keep your iron holstered inside the gates and show some respect inside Neal's Skum Pitt tavern. "
            "Old Neal pours the coldest drinks south of Shady Sands, and Marcelles's Crash House is still the only inn for ten miles "
            "where you don't wake up with mole rats chewing your bootlaces."
        ),
    },
    {
        "name": "v13_radio_dj_56",
        "sndr_fid": 0x010E001F,
        "edid": "SNDRV13RadioDJ56",
        "tts_es": (
            "Malestar indignante en los barrios bajos de Ciudad Chatarra: la pandilla de Los Cráneos, encabezada por el matón Vinnie, "
            "ha cruzado todas las rayas al robar del mostrador de La Espumadera la urna con las cenizas de la difunta esposa de Neal. "
            "Mientras los matones se ríen junto al casino de Gizmo y amenazan la taberna, toda la ciudad espera que alguien devuelva esa urna "
            "y ponga freno de una vez a la chusma que ensucia las noches de Junktown."
        ),
        "tts_en": (
            "Disgraceful trouble in the back alleys of Junktown: the Skulz street gang under loudmouth Vinnie "
            "crossed every line in the book by stealing the urn holding Neal's late wife's ashes right off the bar at The Skum Pitt. "
            "While those punks laugh it up near Gizmo's casino and rattle the tavern doors, decent folks in town are waiting for someone "
            "to bring that urn home and clear out the thugs poisoning Junktown after dark."
        ),
    },
    {
        "name": "v13_radio_dj_57",
        "sndr_fid": 0x010E0020,
        "edid": "SNDRV13RadioDJ57",
        "tts_es": (
            "¡Gran golpe policial en Ciudad Chatarra! Una grabación secreta con la propia voz de Gizmo confesando sus crímenes "
            "ha cerrado para siempre su casino amañado sin que la calle principal acabara convertida en un cementerio. "
            "Además, Neal ha recuperado por fin la urna de su esposa y la banda de Los Cráneos ha quedado desmantelada. "
            "Killian ha prometido puertas abiertas y comercio limpio en Junktown desde hoy mismo."
        ),
        "tts_en": (
            "Masterstroke by the law in Junktown! A hidden tape recording featuring bloated casino boss Gizmo's own voice "
            "spilling his dirty schemes just shut his gambling hall down for good without turning Main Street into a slaughterhouse. "
            "Neal has his wife's urn resting safely behind the bar again, and the Skulz gang is finished. "
            "Killian promises clean trade and peaceful gates from here on out."
        ),
    },
    {
        "name": "v13_radio_dj_58",
        "sndr_fid": 0x010E0021,
        "edid": "SNDRV13RadioDJ58",
        "tts_es": (
            "El imperio criminal de Gizmo acaba de terminar entre estruendo de escopetas dentro del mismísimo casino de Ciudad Chatarra. "
            "El gordo cacique del juego y su guardaespaldas mudo Izo cayeron derrotados junto a las mesas de ruleta, "
            "y Los Cráneos de Vinnie huyeron despavoridos tras devolver la urna familiar a Neal en La Espumadera. "
            "Desde hoy se acabaron los chantajes y los sobornos nocturnos en Junktown."
        ),
        "tts_en": (
            "Gizmo's criminal empire just ended in a roar of shotgun blasts right inside Junktown's gambling hall. "
            "The bloated casino kingpin and his mute enforcer Izo fell beside the roulette tables, "
            "and Vinnie's Skulz scattergun punks fled town after surrendering Neal's family urn back to The Skum Pitt. "
            "Shakedowns and crooked bets in Junktown are over starting tonight."
        ),
    },
    # --- Slot 13 Doc Morbid & Iguana Bob ---
    {
        "name": "v13_radio_dj_59",
        "sndr_fid": 0x010E0022,
        "edid": "SNDRV13RadioDJ59",
        "tts_es": (
            "¡Alerta sanitaria y escándalo macabro entre Ciudad Chatarra y la plaza de El Eje! Alguien ha destapado la cámara refrigerada oculta "
            "en el sótano del doctor Morbid y su ayudante Gretch, confirmando los peores temores sobre los envíos secretos hacia Iguana Bob Frazier: "
            "¡aquellas brochetas especiales nunca llevaron carne de iguana! El puesto ha quedado vacío y apestado por la furia de los clientes... "
            "hoy más que nunca, revisad bien qué lleváis a la boca en las tabernas del camino."
        ),
        "tts_en": (
            "Public health alert and stomach-turning scandal stretching from Junktown to The Hub marketplace! Someone kicked open the cold cellar "
            "beneath Doctor Morbid's clinic and Gretch's chopping table, confirming the ugliest rumor about Bob Frazier's Iguana Bits shipments: "
            "those prime skewers never came from lizards! Customers have stormed away from the stand in disgust... "
            "today of all days, check twice before biting into mystery meat on the road."
        ),
    },
    # --- Slot 14 Hub Irwin Farm & .223 Pistol ---
    {
        "name": "v13_radio_dj_60",
        "sndr_fid": 0x010E0023,
        "edid": "SNDRV13RadioDJ60",
        "tts_es": (
            "Así palpita hoy El Eje, cruce de caminos donde convergen todas las rutas desde Oregón hasta los límites de México. "
            "Entre la Caravana Carmesí del irascible Demetre, los honestos Mercaderes de la Estrella Lejana de Butch Harris "
            "y el monopolio hidráulico de los Mercaderes del Agua, aquí nadie regala ni las buenas tardes. "
            "Pero recuerda: en estas calles puedes encontrar desde un fusil de combate nuevo hasta un rumor capaz de salvarte el pellejo."
        ),
        "tts_en": (
            "That is the heartbeat of The Hub tonight, the great crossroads where every trail meets from Oregon down to the Mexican borderlands. "
            "Between Demetre's reckless Crimson Caravan, Butch Harris's steady Far Go Traders, "
            "and the tight-fisted monopoly of the Water Merchants, nobody gives away so much as a smile for free here. "
            "Yet stick around these alleys long enough and you can trade for anything from a combat shotgun to a life-saving lead."
        ),
    },
    {
        "name": "v13_radio_dj_61",
        "sndr_fid": 0x010E0024,
        "edid": "SNDRV13RadioDJ61",
        "tts_es": (
            "Un vecino honrado de El Eje necesita una mano urgente: la banda de saqueadores del cabecilla Krag ha expulsado al pobre granjero Irwin "
            "de sus tierras al noroeste de la ciudad, apropiándose de su casa y de los títulos de propiedad. "
            "Sin ayuda armada o un buen negociador que eche a esa escoria de allí, Irwin lo perderá todo antes de que cambie el mes. "
            "Quienes le ayudan susurran que el viejo granjero esconde cierta arma legendaria digna de museo."
        ),
        "tts_en": (
            "An honest Hub neighbor needs backing in a hurry: warlord Krag's gang of thugs just ran old farmer Irwin off his homestead "
            "northwest of town, seizing his barns and locking up his land deeds. "
            "Unless somebody with steady nerves or heavy iron drives those squatters off his soil, Irwin loses everything before month's end. "
            "Folks who know the old man hint he keeps a one-of-a-kind sidearm locked away as thanks."
        ),
    },
    {
        "name": "v13_radio_dj_62",
        "sndr_fid": 0x010E0025,
        "edid": "SNDRV13RadioDJ62",
        "tts_es": (
            "¡Justicia rural al noroeste de El Eje! Los saqueadores de Krag salieron por piernas de la granja de Irwin, "
            "Butch Harris ya selló las escrituras oficiales devolviendo la tierra a su legítimo dueño, y corre el rumor entre los armeros "
            "de que Irwin ha recompensado a su salvador con su mítica pistola artesanal del calibre dos dos tres. "
            "Dicen que esa joya atraviesa blindajes pesados como si fueran papel de periódico."
        ),
        "tts_en": (
            "Frontier justice northwest of The Hub! Krag's squatters were sent packing off Irwin's farmstead, "
            "Butch Harris himself stamped the deeds restoring the land to its rightful owner, and gunsmiths down in Old Town are buzzing "
            "that Irwin handed over his legendary custom two-two-three pistol in gratitude. "
            "They say that little hand cannon punches straight through heavy armor like wet cardboard."
        ),
    },
    # --- Slot 15 Hub Missing Caravans, Tug & Decker ---
    {
        "name": "v13_radio_dj_63",
        "sndr_fid": 0x010E0026,
        "edid": "SNDRV13RadioDJ63",
        "tts_es": (
            "Novedades en la comisaría del sheriff Justin Greene aquí en El Eje: la investigación por los convoyes desaparecidos "
            "acaba de señalar hacia la vieja guarida del sanguinario al oeste de la ciudad y hacia los sótanos turbios del Halcón Maltés. "
            "Greene sospecha que detrás de las desapariciones en el norte hay algo mucho peor que simples bandidos del camino, "
            "y busca a un investigador valiente capaz de entrar en esa cueva y volver vivo para contarlo."
        ),
        "tts_en": (
            "Developing news out of Sheriff Justin Greene's station right here in The Hub: the probe into our missing caravans "
            "just pointed straight toward an old Deathclaw lair west of town and the shadowy back rooms beneath The Maltese Falcon. "
            "Greene suspects something far nastier than common highwaymen is snatching drivers off the northern routes, "
            "and he is looking for one fearless scout who can crawl into that cave and walk back out."
        ),
    },
    {
        "name": "v13_radio_dj_64",
        "sndr_fid": 0x010E0027,
        "edid": "SNDRV13RadioDJ64",
        "tts_es": (
            "¡Confirmado por los registros recuperados en la cueva oeste! Un informe de transmisiones arrancado al mutante moribundo Tug "
            "demuestra sin lugar a dudas que los supermutantes están secuestrando caravanas enteras vivas y llevándoselas al noroeste. "
            "El sheriff Justin Greene tiene ya media trama sobre la mesa, pero falta cerrar la boca al mayor traidor de la ciudad: "
            "el padrino Decker y su lugarteniente Kane siguen moviendo los hilos en el sótano del Halcón Maltés."
        ),
        "tts_en": (
            "Confirmed by encrypted logs pulled straight from the western cave! A transmission holodisk recovered from the dying mutant Tug "
            "proves beyond doubt that Super Mutants are kidnapping whole caravans alive and marching them northwest. "
            "Sheriff Justin Greene already has half the conspiracy pinned to his board, leaving just one snake to crush in town: "
            "crime boss Decker and his scarred right hand Kane down beneath The Maltese Falcon."
        ),
    },
    {
        "name": "v13_radio_dj_65",
        "sndr_fid": 0x010E0028,
        "edid": "SNDRV13RadioDJ65",
        "tts_es": (
            "¡Fin del imperio clandestino en El Eje! Tras caer en manos del sheriff Justin Greene el libro mayor secreto de Decker, "
            "obtenido con puro ingenio bajo las mismas narices de Kane, la comisaría ha clausurado las operaciones sucias del Halcón Maltés "
            "y detenido a toda la red de contrabandistas. Hoy las caravanas de la Estrella Lejana "
            "vuelven a dormir tranquilas sabiendo que nadie vende sus rutas desde dentro."
        ),
        "tts_en": (
            "Curtain call for the Hub's underworld tonight! After Sheriff Justin Greene got his hands on Decker's secret crime ledger, "
            "lifted right from under Kane's nose through sheer grit and bluffing, deputies locked down The Maltese Falcon back rooms "
            "and hauled the whole syndicate ring away in irons. Tonight the Far Go Traders "
            "can finally sleep knowing nobody in town is selling out their schedules."
        ),
    },
    {
        "name": "v13_radio_dj_66",
        "sndr_fid": 0x010E0029,
        "edid": "SNDRV13RadioDJ66",
        "tts_es": (
            "¡Tiroteo histórico bajo las tablas del Halcón Maltés! Los vecinos del centro aún comentan el estruendo que subió desde el sótano: "
            "el temido jefe criminal Decker y su guardaespaldas Kane cayeron abatidos en su propia guarida, "
            "y sus libros de cuentas ardieron ante el sheriff Greene destapando años de extorsiones y asesinatos. "
            "La ley del desierto ha hablado alto y claro en las calles de El Eje."
        ),
        "tts_en": (
            "Gunsmoke and reckoning beneath the floorboards of The Maltese Falcon! Shopkeepers downtown are still buzzing over the echoes "
            "that shook the basement last night: feared crime kingpin Decker and his enforcer Kane were gunned down in their own office, "
            "while their ledgers landed cleanly on Sheriff Greene's desk to bury years of extortion and blood. "
            "Law and order just spoke loud and clear in The Hub."
        ),
    },
    # --- Slot 16 The Glow / West Tek & Initiation ---
    {
        "name": "v13_radio_dj_67",
        "sndr_fid": 0x010E002A,
        "edid": "SNDRV13RadioDJ67",
        "tts_es": (
            "Boletín increíble desde las lindes del desierto sur: los vigías han visto a alguien descender por la grúa oxidada "
            "directamente al corazón radiactivo de El Resplandor, en las ruinas del viejo complejo West Tek, cargando píldoras contra la radiación "
            "para cumplir la prueba imposible que exige la Hermandad del Acero. "
            "Nadie que haya bajado solo a esos seis sótanos iluminados de verde ha regresado jamás... crucemos los dedos."
        ),
        "tts_en": (
            "Unbelievable report from the southern crater rim: lookouts swear someone actually rappelled down the rusted girder "
            "into the glowing radioactive throat of The Glow at old West Tek, popping Rad-X pills "
            "to satisfy the impossible trial demanded by the Brotherhood of Steel. "
            "Nobody who ever climbed down alone into those six sublevels came back breathing... keep your fingers crossed."
        ),
    },
    {
        "name": "v13_radio_dj_68",
        "sndr_fid": 0x010E002B,
        "edid": "SNDRV13RadioDJ68",
        "tts_es": (
            "¡Milagro en las colinas de Lost Hills! El forastero que descendió al infierno de El Resplandor ha regresado con vida, "
            "con la holocinta del difunto sargento Dennis Allen intacta y las historias imposibles de la supercomputadora Zax. "
            "Dicen que hasta el severo paladín Talus inclinó la cabeza al abrir la compuerta acorazada del búnker, "
            "admitiendo por primera vez en décadas a un caminante del yermo como Iniciado de pleno derecho de la Hermandad del Acero."
        ),
        "tts_en": (
            "A miracle out at the Lost Hills bunker! The lone wanderer who climbed down into the atomic furnace of The Glow walked back out alive, "
            "bearing the late Sergeant Dennis Allen's holotape intact along with wild tales of the ancient computer mainframe Zax. "
            "Word is even stony Paladin Talus bowed his head as the steel blast door rolled open, "
            "welcoming a wasteland outsider as a full Initiate of the Brotherhood of Steel for the first time in decades."
        ),
    },
    # --- Slot 17 Lost Hills T-51b Power Armor & Lorenzo ---
    {
        "name": "v13_radio_dj_69",
        "sndr_fid": 0x010E002C,
        "edid": "SNDRV13RadioDJ69",
        "tts_es": (
            "Ecos de intriga entre Lost Hills y el Casco Antiguo de El Eje: unos mercenarios sin escrúpulos retienen como rehén "
            "al joven Iniciado Lorenzo en los barracones viejos mientras, allá en el búnker, el caballero Kyle intenta poner a punto "
            "una imponente servoarmadura T cincuenta y uno B a falta de piezas sistólicas. "
            "Quien consiga rescatar al iniciado y devolver esa joya tecnológica al combate marcará la diferencia en la guerra que se avecina."
        ),
        "tts_en": (
            "Whispers of trouble linking Lost Hills and Old Town right here in The Hub: ruthless mercenaries are holding young Initiate Lorenzo "
            "captive in an old barracks shack, while back in the bunker Knight Kyle is wrenching on a scarred T-fifty-one B power armor frame "
            "missing its systolic motivator. Whoever pulls that kid free and gets that pre-war suit back online "
            "is going to tip the balance in the storm heading our way."
        ),
    },
    {
        "name": "v13_radio_dj_70",
        "sndr_fid": 0x010E002D,
        "edid": "SNDRV13RadioDJ70",
        "tts_es": (
            "Aviso entre asombrado y respetuoso de nuestros caravaneros del oeste: ya no ven solo un mono azul del Refugio trece "
            "cruzando las dunas al caer la tarde... sino una imponente silueta acorazada dentro de una reluciente servoarmadura "
            "T cincuenta y uno B entregada por la propia Hermandad del Acero tras liberar al Iniciado Lorenzo. "
            "Cuando escuches el zumbido de esos servomotores en el horizonte, saqueador, más te vale dar media vuelta y correr."
        ),
        "tts_en": (
            "Awe-struck reports coming in from our western caravan scouts: folks aren't just spotting a blue Vault Thirteen jumpsuit "
            "crossing the twilight dunes anymore... they're seeing a towering armored silhouette inside gleaming T-fifty-one B power armor, "
            "gifted by the Brotherhood itself after Initiate Lorenzo was brought home safe. "
            "If you're a raider and you hear those servos whine over the ridge, you'd better drop your gun and run."
        ),
    },
    # --- Slot 18 Act III Vree's Autopsy & Maxson's War ---
    {
        "name": "v13_radio_dj_71",
        "sndr_fid": 0x010E002E,
        "edid": "SNDRV13RadioDJ71",
        "tts_es": (
            "Revelación científica que corre como pólvora desde los archivos subterráneos de Lost Hills: la autopsia practicada por la escriba jefe Vree "
            "acaba de demostrar un secreto devastador sobre los gigantes del Virus de Evolución Forzada: ¡los supermutantes son totalmente estériles! "
            "Su supuesto ejército del futuro no puede reproducirse y está condenado a extinguirse si nadie les deja secuestrar más humanos puros. "
            "El arma más poderosa de esta guerra podría no ser un cañón láser, sino esa cinta médica."
        ),
        "tts_en": (
            "Explosive scientific news leaking out of the sublevels at Lost Hills: Head Scribe Vree's autopsy on captured mutants "
            "just uncovered a staggering secret about the Forced Evolutionary Virus: every Super Mutant is completely sterile! "
            "Their grand master race cannot breed at all, doomed to die out in one generation unless they keep abducting pure humans. "
            "The deadliest weapon in this coming war might not be a laser rifle at all — it might be Vree's medical holotape."
        ),
    },
    {
        "name": "v13_radio_dj_72",
        "sndr_fid": 0x010E002F,
        "edid": "SNDRV13RadioDJ72",
        "tts_es": (
            "El Consejo de Ancianos de la Hermandad del Acero y el Alto Anciano John Maxson han hablado al fin ante los paladines de Lost Hills. "
            "Con el informe de Vree sellado y el respaldo total desde las montañas del Refugio trece, la orden se moviliza "
            "para cortar de raíz las cubas mutágenas del norte y el santuario tenebroso del sur. "
            "Preparen sus corazones, caminantes: la batalla que decidirá si la humanidad sigue existiendo en California está a punto de comenzar."
        ),
        "tts_en": (
            "The Council of Elders and High Elder John Maxson have finally given the word inside Lost Hills. "
            "Backed by Scribe Vree's report and full authorization from distant Vault Thirteen, the Brotherhood paladins are gearing up "
            "to strike both the mutagenic vats up north and the dark sanctuary down south. "
            "Steel your nerves out there, listeners: the battle that decides whether humanity survives in California is about to ignite."
        ),
    },
    {
        "name": "v13_radio_dj_73",
        "sndr_fid": 0x010E0030,
        "edid": "SNDRV13RadioDJ73",
        "tts_es": (
            "Ahora que el humo de la gran guerra empieza a disiparse sobre California, dediquemos un aplauso sincero a las mentes brillantes "
            "que hicieron posible la victoria desde un laboratorio silencioso. Sin los estudios pacientes de la escriba jefe Vree en Lost Hills "
            "y el valor de los paladines que abrieron camino hacia las cubas, hoy estaríamos todos hablando ante altares de carne mutada. "
            "Por la ciencia puesta al servicio de la vida, vaya esta canción."
        ),
        "tts_en": (
            "Now that the smoke of war is finally lifting over California, let's tip our hats to the quiet minds "
            "who won half this fight inside an underground laboratory. Without Head Scribe Vree's tireless research at Lost Hills "
            "and the paladins who broke cover when it counted most, we'd all be kneeling before mutated altars tonight. "
            "To science used to defend life instead of twist it, here is the next song."
        ),
    },
    # --- Slot 19 Act IV Mariposa Preparing -> Assault -> Destroyed ---
    {
        "name": "v13_radio_dj_74",
        "sndr_fid": 0x010E0031,
        "edid": "SNDRV13RadioDJ74",
        "tts_es": (
            "Última hora en los puestos de vigilancia del noroeste: los rastreadores aseguran que el misterioso personaje del Refugio trece "
            "reúne munición pesada, estimulantes y células de microfusión mientras se prepara para atacar de frente la Base Militar de Mariposa. "
            "Todo El Eje contiene el aliento mientras la figura del trece marcha hacia las alambradas del norte donde el Teniente Lou aguarda con sus Nocturnos. "
            "Si escuchas esta emisión allá arriba entre las rocas... toda Nueva California reza por tu puntería."
        ),
        "tts_en": (
            "Breaking report from northwestern lookouts: scouts swear the mysterious wanderer from Vault Thirteen "
            "is stocking heavy ordnance, stimpaks, and microfusion cells right now, gearing up for a head-on assault against Mariposa Military Base. "
            "All of The Hub is holding its breath as the lone figure from Thirteen marches toward the northern wire where Lieutenant Lou waits with his Nightkin. "
            "If you hear our carrier wave up in those cold rocks... every soul in California is pulling for your aim."
        ),
    },
    {
        "name": "v13_radio_dj_75",
        "sndr_fid": 0x010E0032,
        "edid": "SNDRV13RadioDJ75",
        "tts_es": (
            "¡Alarma roja en las frecuencias militares del noroeste! Los equipos de radio interceptan sirenas de intrusión, estruendo de torretas "
            "y ráfagas de plasma resonando desde el mismísimo corazón de la Base de Mariposa. El asalto contra las cubas está en marcha "
            "y la guardia de Nocturnos invisibles ha saltado al combate junto al Teniente Lou. "
            "No os acerquéis a los valles del norte esta noche, caravanas: allá arriba se está librando un infierno."
        ),
        "tts_en": (
            "Red alert sweeping the northwestern radio bands! Signal monitors are picking up klaxon alarms, turret fire, "
            "and crackling plasma volleys echoing straight out of Mariposa Military Base. The strike on the vats is underway right now, "
            "with Lieutenant Lou and his cloaked Nightkin guard locked in desperate close-quarters battle. "
            "Steer every caravan well clear of the northern valleys tonight: absolute hell has broken loose up there."
        ),
    },
    {
        "name": "v13_radio_dj_76",
        "sndr_fid": 0x010E0033,
        "edid": "SNDRV13RadioDJ76",
        "tts_es": (
            "¡Noticia histórica de última hora en el ochenta y cuatro punto cinco! Hace apenas unas horas, el cielo del noroeste se iluminó "
            "con un rugido sísmico que sacudió las copas de nuestras torres de agua: ¡las Cubas de Virus de Evolución Forzada de Mariposa "
            "han saltado por los aires en una detonación subterránea imparable! Nunca volverán a sumergir a otro caminante en aquel líquido verde. "
            "Hoy el norte respira al fin sin pesadillas."
        ),
        "tts_en": (
            "Historic breaking news on eighty-four point five! Just hours ago the northwestern horizon lit up "
            "with a deep seismic boom that rattled the steel legs of our water towers: the Forced Evolutionary Virus vats inside Mariposa "
            "have been blown sky-high in a runaway underground blast! They will never dip another human soul into that green filth again. "
            "Tonight the northern trail breathes free of nightmares."
        ),
    },
    # --- Slot 20 Act IV Post-Mariposa Lou Fallen ---
    {
        "name": "v13_radio_dj_77",
        "sndr_fid": 0x010E0034,
        "edid": "SNDRV13RadioDJ77",
        "tts_es": (
            "¡Confirmado el golpe definitivo en el frente norte! El despiadado Teniente Lou cayó junto a sus comandos Nocturnos "
            "entre los pasillos metálicos de Mariposa antes de que los reactores borraran la base del mapa. "
            "En las oficinas de la Caravana Carmesí y la Estrella Lejana se descorchan botellas guardadas desde antes de la guerra: "
            "los convoyes al norte vuelven a rodar sin patrullas de monstruos al acecho."
        ),
        "tts_en": (
            "Final confirmation just arrived from the northern front! The ruthless mutant commander Lieutenant Lou fell alongside his Nightkin "
            "in the steel corridors of Mariposa just before the reactors wiped that base off the map. "
            "Down at Crimson Caravan and the Far Go Traders, folks are popping pre-war bottles they saved for twenty years: "
            "northern freight wagons can roll again without green giants hunting them down."
        ),
    },
    # --- Slot 21 Boneyard Mother Deathclaw & Gun Runners ---
    {
        "name": "v13_radio_dj_78",
        "sndr_fid": 0x010E0035,
        "edid": "SNDRV13RadioDJ78",
        "tts_es": (
            "Aviso de peligro extremo en el Osario de Los Ángeles: los armeros de los Contrabandistas de Armas ofrecen su mejor arsenal "
            "a quien logre cazar a la descomunal Madre Sanguinario que ha convertido la llanura central en un matadero lleno de huevos. "
            "Varios cazarrecompensas valientes han bajado ya a los almacenes derruidos sin volver a dar señales de vida. "
            "Quien se enfrente a esa bestia necesitará blindaje pesado y un arma capaz de detener un camión en seco."
        ),
        "tts_en": (
            "Extreme hazard warning across the Los Angeles Boneyard: Gabriel and his Gun Runners have put their finest heavy weapons on the table "
            "for anyone brave enough to hunt down the colossal Mother Deathclaw turning the central ruins into a bloody nesting ground. "
            "Several tough bounty hunters have vanished inside those shattered warehouses without a trace. "
            "Whoever walks into that nest had better wear heavy plate and pack something that can stop a charging truck."
        ),
    },
    {
        "name": "v13_radio_dj_79",
        "sndr_fid": 0x010E0036,
        "edid": "SNDRV13RadioDJ79",
        "tts_es": (
            "¡Se acabaron las garras en las avenidas centrales del Osario! Alguien abatió en su propio nido a la terrible Madre Sanguinario "
            "y destruyó hasta el último huevo, devolviendo las rutas de suministro a Gabriel y los Contrabandistas de Armas. "
            "Sus forjas junto al foso tóxico trabajan ya a pleno rendimiento distribuyendo rifles de plasma turbo "
            "entre quienes defienden el sur de California contra cualquier tiranía."
        ),
        "tts_en": (
            "No more monstrous claws stalking the central avenues of The Boneyard! Someone walked straight into the nest, dropped the Mother Deathclaw, "
            "and cleared out every last egg, opening the supply roads back up for Gabriel and the Gun Runners. "
            "Their factory benches inside the toxic moat are running hot again, turning out Turbo Plasma rifles "
            "for the defenders pushing back against the mutant threat in the south."
        ),
    },
    # --- Slot 22 Boneyard Adytum Civil War ---
    {
        "name": "v13_radio_dj_80",
        "sndr_fid": 0x010E0037,
        "edid": "SNDRV13RadioDJ80",
        "tts_es": (
            "¡Escándalo explosivo en las calles cercadas de Adytum! Ha salido a la luz un holodisco entregado por Razor que prueba más allá de toda duda "
            "que Caleb y sus Reguladores asesinaron al hijo del alcalde Jon Zimmerman para incriminar a Los Espadas y someter a todo el pueblo. "
            "Los ánimos están al rojo vivo tras las alambradas del sur mientras el viejo alcalde encara al fin la verdad... "
            "la batalla por el alma de Adytum ha estallado."
        ),
        "tts_en": (
            "Explosive scandal behind the razor wire fences of Adytum! A witness holodisk turned over by Razor just proved beyond a shadow of a doubt "
            "that Caleb and his crooked Regulators murdered Mayor Jon Zimmerman's son to frame The Blades and keep the town under their boot. "
            "Tempers are boiling over down in the Boneyard as the grieving mayor confronts the truth at last... "
            "the showdown for Adytum's freedom is underway."
        ),
    },
    {
        "name": "v13_radio_dj_81",
        "sndr_fid": 0x010E0038,
        "edid": "SNDRV13RadioDJ81",
        "tts_es": (
            "¡Adytum vuelve a respirar libertad! El tirano Caleb y la milicia corrupta de los Reguladores han sido expulsados o derrotados, "
            "y en un momento que parecía imposible en el Osario, el alcalde Jon Zimmerman y Razor, jefa de Los Espadas, "
            "han firmado la paz juntos junto a los muros de la ciudad. Por primera vez en años, "
            "los obreros de la fundición regresan a sus casas como ciudadanos libres, no como esclavos."
        ),
        "tts_en": (
            "Adytum is a free town tonight! Tyrant Caleb and his corrupt Regulator militia have been driven out or overthrown, "
            "and in a sight folks down in The Boneyard never dreamed they'd witness, Mayor Jon Zimmerman and Razor of The Blades "
            "just clasped hands and signed a lasting peace by the city gate. For the first time in years, "
            "foundry workers are walking home as free neighbors instead of prisoners."
        ),
    },
    # --- Slot 23 Adytum Forge (Miles & Smitty) ---
    {
        "name": "v13_radio_dj_82",
        "sndr_fid": 0x010E0039,
        "edid": "SNDRV13RadioDJ82",
        "tts_es": (
            "Para quienes piensan que en el desierto solo valen los cartuchos de escopeta: nunca subestiméis un buen libro antiguo de papel. "
            "Aquí en la biblioteca de la señora Stapleton, en el centro de El Eje, todavía se conservan manuales médicos, planos de electrónica "
            "y tratados de química de antes de las bombas que valen su peso en oro. Dicen que saber leer un buen esquema técnico "
            "abre puertas blindadas que ni diez granadas logran derribar."
        ),
        "tts_en": (
            "To anyone who thinks shotgun shells are the only thing worth carrying in the wastes: never underestimate an intact pre-war book. "
            "Right here in Mrs. Stapleton's library in downtown The Hub, you can still trade for medical journals, electronics manuals, "
            "and old chemistry textbooks worth their weight in gold. Knowing how to read a good schematic "
            "unlocks armored doors that ten frag grenades couldn't budge."
        ),
    },
    {
        "name": "v13_radio_dj_83",
        "sndr_fid": 0x010E003A,
        "edid": "SNDRV13RadioDJ83",
        "tts_es": (
            "Mensaje directo para los buscadores que viajan entre el Osario y El Eje: el químico Miles y el armero Smitty en Adytum "
            "trabajan a contrarreloj para recuperar las granjas hidropónicas que alimentan a la ciudad y mejorar las mejores armaduras del yermo. "
            "Necesitan reguladores hidráulicos perdidos y viejos tratados de química polimérica... "
            "quien les consiga esos materiales saldrá de su fragua protegido como un auténtico tanque."
        ),
        "tts_en": (
            "A message for travellers running between The Boneyard and The Hub: chemist Miles and gunsmith Smitty down in Adytum "
            "are racing to revive the town's failing hydroponic gardens while pushing wasteland armor-craft to its limit. "
            "They're hunting missing hydroponic regulators and rare polymer chemistry books... "
            "anyone who brings them what they need walks away wearing protection fit for a walking tank."
        ),
    },
    {
        "name": "v13_radio_dj_84",
        "sndr_fid": 0x010E003B,
        "edid": "SNDRV13RadioDJ84",
        "tts_es": (
            "Buenas nuevas desde las huertas y talleres de Adytum: gracias al empeño de Miles y los tratados químicos recuperados de El Eje, "
            "los cultivos hidropónicos vuelven a brotar verdes bajo las cúpulas de cristal dando cosechas frescas sin polvo ni ceniza. "
            "Y junto a los surcos, la fragua de Smitty ruge templando placas de servoarmadura endurecida capaces de rebotar el fuego más pesado del sur."
        ),
        "tts_en": (
            "Bright news out of Adytum's gardens and forge tonight: thanks to Miles's grit and pre-war chemistry journals hauled from The Hub, "
            "fresh green crops are blooming inside the hydroponic bays without a speck of ash. "
            "Right next door, Smitty's anvil is ringing hot, hardening pre-war power armor plating tough enough to shrug off the heaviest guns in California."
        ),
    },
    # --- Slot 24 Followers Spy Hunt ---
    {
        "name": "v13_radio_dj_85",
        "sndr_fid": 0x010E003C,
        "edid": "SNDRV13RadioDJ85",
        "tts_es": (
            "Alerta en voz baja para los amigos de la Biblioteca del Osario: Nicole y el atormentado Talius sospechan que alguien muy cercano "
            "está filtrando las rutas nocturnas de los Seguidores del Apocalipsis directamente a los inquisidores de Morfeo en la Catedral. "
            "Cada patrulla que sale hacia el sur cae en una emboscada sospechosamente precisa... "
            "si frecuentáis los muros de la Biblioteca, vigilad quién entra y quién anota de más en la garita norte."
        ),
        "tts_en": (
            "A quiet warning for friends of the Boneyard library: Nicole and scarred survivor Talius suspect a traitor inside their own walls "
            "is leaking the Followers' night patrol routes straight to High Priest Morpheus's inquisitors at the Cathedral. "
            "Every southern scouting party has walked straight into uncanny ambushes... "
            "if you pass through the Followers' yard, watch closely who keeps notes by the north watchpost."
        ),
    },
    {
        "name": "v13_radio_dj_86",
        "sndr_fid": 0x010E003D,
        "edid": "SNDRV13RadioDJ86",
        "tts_es": (
            "Se respiran alivio y prudencia en la Biblioteca del Osario: la fuga de información que amenazaba a los Seguidores del Apocalipsis "
            "acaba de ser neutralizada en el muro norte tras quedar descubierta la espía Heather. "
            "Con las patrullas a salvo y el contacto secreto de la Rosa Roja activo tras las líneas enemigas, "
            "Nicole y su gente vuelven a tener una oportunidad real de ayudar a quienes buscan entrar en la Catedral."
        ),
        "tts_en": (
            "Measured relief today inside the Boneyard library: the security leak bleeding the Followers of the Apocalypse "
            "was shut down clean at the north gate after mole Heather's game fell apart. "
            "With scouting squads safe once more and the Red Rose secret contact still active behind Cathedral robes, "
            "Nicole's people finally have a fighting chance to guide truth-seekers inside the southern temple."
        ),
    },
    # --- Slot 25 Act V Cathedral & Nuclear Destruction ---
    {
        "name": "v13_radio_dj_87",
        "sndr_fid": 0x010E003E,
        "edid": "SNDRV13RadioDJ87",
        "tts_es": (
            "Las sombras se alargan hoy alrededor de los capiteles negros de la Catedral del sur. Los exploradores que vigilan desde los escombros "
            "han visto doblar las guardias de los temibles Nocturnos invisibles en las puertas del templo, mientras Morfeo redobla sus sermones "
            "sobre la Unidad. Dicen que ese viajero legendario del Refugio trece acaba de cruzar las avenidas en ruinas rumbo al atrio... "
            "que la suerte o el destino acompañen a quien va a mirar cara a cara al Maestro."
        ),
        "tts_en": (
            "Long shadows are gathering tonight around the blackened spires of the southern Cathedral. Watchers tucked into the rubble "
            "report invisible Nightkin guards doubling at every temple arch while Morpheus's loudspeakers preach louder than ever about the Unity. "
            "Word is that lone traveller wearing the number thirteen just slipped down the ruined avenues toward the sanctuary steps... "
            "may fortune or fate ride with whoever marches down to face The Master."
        ),
    },
    {
        "name": "v13_radio_dj_88",
        "sndr_fid": 0x010E003F,
        "edid": "SNDRV13RadioDJ88",
        "tts_es": (
            "¡Atención toda Nueva California! ¡Aquí Radio El Eje en emisión extraordinaria desde el ochenta y cuatro punto cinco! "
            "Una columna de fuego atómico acaba de alzarse sobre las ruinas del extremo sur barriendo para siempre la Catedral "
            "y el oscuro Refugio subterráneo donde el Maestro tejía su monstruosa Unidad. Se apagaron para siempre las voces telepáticas "
            "y cayó el cerebro que quería borrar a la humanidad. ¡Estamos salvados, caminantes, somos libres!"
        ),
        "tts_en": (
            "Attention all of New California! This is The Hub Radio with an extraordinary emergency bulletin at eighty-four point five! "
            "A blinding atomic pillar just rose over the far southern ruins, vaporizing the Cathedral forever "
            "along with the sunken vault beneath it where The Master forged his monstrous Unity. Those psychic whispers are silenced for good "
            "and the twisted brain plotting humanity's end is gone. California is saved — we are free!"
        ),
    },
    # --- Slot 27 Epilogues / Late Night Reflections (dj_89, dj_91, dj_92) ---
    {
        "name": "v13_radio_dj_89",
        "sndr_fid": 0x010E0040,
        "edid": "SNDRV13RadioDJ89",
        "tts_es": (
            "Pasan las dos de la madrugada sobre el cielo despejado de Mojave, y aquí seguimos acompañando a los que hacen guardia junto al fuego. "
            "En noches así uno piensa en ese principiante del Refugio trece que salió por primera vez a ver la luz del sol con el tiempo contado "
            "para salvar a los suyos de morir de sed. El desierto es duro, amigo, pero hasta la semilla más pequeña rompe la piedra "
            "si no se rinde. Sigue caminando, que el yermo escucha tu historia."
        ),
        "tts_en": (
            "Two in the morning under a clear Mojave sky, and we're still spinning wax for every guard keeping watch by the embers. "
            "On quiet nights like this you can't help wondering about that rookie who stepped out of Vault Thirteen into real sunlight "
            "for the first time ever, racing a dying water clock to save their people. The desert is merciless, friend, "
            "yet even a single seed cracks granite if it won't quit. Keep walking — California is listening."
        ),
    },
    # --- Slot 26 Act V How the Master Fell (combat / nuke) ---
    {
        "name": "v13_radio_dj_90",
        "sndr_fid": 0x010E0041,
        "edid": "SNDRV13RadioDJ90",
        "tts_es": (
            "Poco a poco van llegando detalles de lo ocurrido bajo los escombros ardientes de la Catedral: aseguran los antiguos acólitos fugados "
            "que la batalla en el llamado Refugio del Futuro fue descomunal. Armas pesadas contra los pretorianos supermutantes y la cámara blindada "
            "del propio Maestro, culminando en una cuenta atrás nuclear que obligó al héroe del trece a correr por los pasillos "
            "un segundo antes de que todo aquel imperio de pesadilla volara en mil pedazos."
        ),
        "tts_en": (
            "Piece by piece, survivors fleeing the smoking crater of the southern Cathedral are telling what went down below ground. "
            "Defected acolytes swear the firefight inside the Vault of the Future shook the very bedrock: heavy guns blazing against "
            "Super Mutant Praetorians and The Master's own armored chamber, ending in a desperate sprint through collapsing corridors "
            "with a live nuclear countdown ticking down to zero."
        ),
    },
    {
        "name": "v13_radio_dj_91",
        "sndr_fid": 0x010E0042,
        "edid": "SNDRV13RadioDJ91",
        "tts_es": (
            "Con las cubas de Mariposa convertidas en polvo y el santuario de la Catedral borrado de la tierra, toda Nueva California "
            "mira hacia el horizonte del norte esperando ver regresar a casa al héroe del Refugio trece. "
            "Desde Shady Sands hasta Adytum, las tabernas brindan sin pagar por el caminante que nos devolvió el futuro. "
            "Que tengas un feliz regreso tras la gran puerta de acero, salvador... te has ganado cada segundo de paz."
        ),
        "tts_en": (
            "With the Mariposa vats turned to ash and the dark Cathedral wiped clean off the map, all of New California "
            "is looking north toward Mount Whitney to toast the Vault Thirteen hero walking home at last. "
            "From Shady Sands down to Adytum, tavern keepers are pouring free rounds in honor of the wanderer who gave us back tomorrow. "
            "Have a safe journey back behind that big steel gear door, savior... you earned every ounce of peace."
        ),
    },
    {
        "name": "v13_radio_dj_92",
        "sndr_fid": 0x010E0043,
        "edid": "SNDRV13RadioDJ92",
        "tts_es": (
            "Cuentan los exploradores que recorren los cañones del lejano norte que el héroe exiliado del Refugio trece no camina solo "
            "hacia su nuevo destino: le acompañan Theresa, Lyle y otros moradores que prefirieron la libertad incierta del sol "
            "antes que vivir encerrados bajo el miedo del Supervisor Jacoren. Dicen que marchan hacia las gargantas vírgenes del norte "
            "para fundar una aldea llamada Arroyo. Allí nacerá una nueva leyenda en veintiún sesenta y dos."
        ),
        "tts_en": (
            "Far-northern scouts report that the exiled savior of Vault Thirteen does not walk into the wilderness alone: "
            "Theresa, Lyle, and loyal dwellers who chose uncertain sunlight over living in fear behind Jacoren's blast door march beside them. "
            "Rumor says they are heading north toward untouched canyon rivers to build a new home called Arroyo. "
            "Out there in twenty-one sixty-two, a brand-new legend is about to begin."
        ),
    },
    # --- Slot 28 Desert Rangers Convoy Ambush ---
    {
        "name": "v13_radio_dj_93",
        "sndr_fid": 0x010E0044,
        "edid": "SNDRV13RadioDJ93",
        "tts_es": (
            "Para nuestros oyentes más jóvenes: ¿habéis oído hablar alguna vez de los Rangers del Desierto de Nevada? "
            "Cuentan los viejos que descienden de los antiguos exploradores y agentes de antes de la Gran Guerra, y que aún patrullan "
            "los páramos del este con gabardinas de cuero gastadas y viejos sombreros de ala ancha protegiendo a los inocentes "
            "de esclavistas y saqueadores. Pocos los ven entrar en las ciudades, pero cuando suenan sus rifles, los malvados tiemblan."
        ),
        "tts_en": (
            "For our younger listeners tuning in tonight: you ever hear stories about the Desert Rangers of Nevada? "
            "Old-timers say they trace their line straight back to pre-war Texas and frontier lawmen, still patrolling "
            "the eastern badlands in battered dusters and broad-brimmed hats to shield honest settlers from slavers and raiders. "
            "Rarely do they set foot inside city gates, yet when their hunting rifles crack at dusk, wicked men run."
        ),
    },
    {
        "name": "v13_radio_dj_94",
        "sndr_fid": 0x010E0045,
        "edid": "SNDRV13RadioDJ94",
        "tts_es": (
            "Parte de combate llegado desde la ruta del este: el veterano Ranger Ezequiel y un aliado del mono azul "
            "tendieron una emboscada impecable contra un convoy esclavista de la Unidad que marchaba con prisioneros encadenados hacia Mariposa. "
            "Los mutantes armados mordieron el polvo del cañón y los rehenes regresaron libres antes del anochecer. "
            "Que tiemblen los traficantes del desierto cuando los Rangers y el Refugio trece disparan codo con codo."
        ),
        "tts_en": (
            "Combat dispatch riding in from the eastern highway: veteran Desert Ranger Ezequiel and an ally in a blue jumpsuit "
            "sprang a textbook ambush on a Unity slaver convoy herding chained captives toward Mariposa. "
            "The mutant guards hit the canyon dirt and every last prisoner walked away free before sundown. "
            "Slave runners across the Mojave had better watch their backs when Rangers and Vault Thirteen share a ridge."
        ),
    },
    # --- Slot 29 Pacific Coast Old Fisherman ---
    {
        "name": "v13_radio_dj_95",
        "sndr_fid": 0x010E0046,
        "edid": "SNDRV13RadioDJ95",
        "tts_es": (
            "¿Alguien entre la audiencia ha llegado caminando hasta el borde mismo del Océano Pacífico por la vieja autopista uno? "
            "Los pocos exploradores que cruzan la costa más allá del Osario hablan de acantilados grises azotados por una bruma fría "
            "y olas espumosas que siguen rompiendo contra esqueletos de autopistas caídas igual que hace cien años. "
            "Un paisaje solitario y salvaje donde el mundo viejo se funde con el mar."
        ),
        "tts_en": (
            "Anybody out there ever walk all the way west to the edge of the Pacific Ocean down old Highway One? "
            "The few scouts who push past the coastal ruins of The Boneyard talk about gray cliffs wrapped in cold sea mist "
            "and foaming breakers pounding shattered highway overpasses just like they did a hundred years ago. "
            "Wild, lonely country out where the old world drops straight into the tide."
        ),
    },
    {
        "name": "v13_radio_dj_96",
        "sndr_fid": 0x010E0047,
        "edid": "SNDRV13RadioDJ96",
        "tts_es": (
            "Estampa entrañable llegada desde la costa del Pacífico: dicen los viajeros que vieron al viejo pescador solitario y al pequeño Billy "
            "compartiendo su hoguera de madera flotante junto al mar con cierto peregrino curioso del Refugio trece. "
            "Entre el rugir de las olas y algún que otro cangrejo gigante asado a la brasa, demostraron que todavía queda hospitalidad sincera "
            "en la última esquina del continente."
        ),
        "tts_en": (
            "A warm little postcard drifted up from the Pacific shore today: passersby spotted the weathered Old Fisherman and young Billy "
            "sharing their driftwood campfire beside the surf with a certain curious pilgrim from Vault Thirteen. "
            "With cold breakers rolling in and charred mirelurk meat sizzling on the spit, those three proved true hospitality still lives "
            "at the very edge of the continent."
        ),
    },
    # --- Slot 30 Special Encounters: Blue Police Box / Area 51 Saucer ---
    {
        "name": "v13_radio_dj_97",
        "sndr_fid": 0x010E0048,
        "edid": "SNDRV13RadioDJ97",
        "tts_es": (
            "¡Juramentos cruzados en las tabernas entre Ciudad Chatarra y El Eje! Un guardia de caravana que jura llevar tres semanas sobrio "
            "asegura haber visto una antigua cabina telefónica policial de color azul brillar, lanzar un zumbido imposible y desvanecerse en el aire "
            "justo delante de otro viajero... dejando sobre la arena un reluciente sensor de movimiento de RobCo como único testigo. "
            "A veces pienso que este desierto guarda secretos más grandes que todas nuestras bombas."
        ),
        "tts_en": (
            "Cross-my-heart oaths echoing through every bar between Junktown and The Hub tonight! A caravan guard who swears he's three weeks sober "
            "claims he watched an antique blue British police box flash its roof lamp, let out an unearthly grinding wheeze, and vanish into thin air "
            "right in front of another traveller... leaving a pristine RobCo motion sensor humming in the sand. "
            "Sometimes I reckon this desert hides mysteries bigger than all our old bombs put together."
        ),
    },
    {
        "name": "v13_radio_dj_98",
        "sndr_fid": 0x010E0049,
        "edid": "SNDRV13RadioDJ98",
        "tts_es": (
            "¿Verdad o insolación extrema en las dunas del sur? Varios buscadores cuentan que cierto explorador del Refugio trece volvió del páramo "
            "con un extraño desintegrador plateado que dispara rayos azules, un retrato en terciopelo de Elvis Presley perfectamente intacto "
            "y la historia delirante de un platillo volante estrellado con la marca de Área cincuenta y uno. "
            "No sé qué había en ese cráter... pero si veis al tipo del mono azul apuntar con ese cacharro, saludad con educación."
        ),
        "tts_en": (
            "Gospel truth or too much southern sunstroke? Scavengers swear a certain Vault Thirteen explorer strolled back from the southern flats "
            "packing a sleek silver blaster firing blue energy bolts, an untouched velvet painting of Elvis Presley, "
            "and a wild yarn about a crashed flying saucer stamped Property of Area Fifty-One. "
            "Don't know what fell out of the sky down there... but if that jumper aims a shiny zap gun your way, tip your hat politely."
        ),
    },
    # --- Slot 31 Special Encounters: Nuka-Cola Truck / Bob's Car Mart ---
    {
        "name": "v13_radio_dj_99",
        "sndr_fid": 0x010E004A,
        "edid": "SNDRV13RadioDJ99",
        "tts_es": (
            "Aviso curioso del gremio bancario de El Eje: los inspectores siguen persiguiendo viejas prensas clandestinas de chapas falsas, "
            "porque cada tapón auténtico de Nuka-Cola de antes de la guerra vale literalmente agua contante y sonante. "
            "Eso explica por qué medio desierto sueña todavía con tropezarse un buen día con un viejo camión repartidor sepultado bajo la arena... "
            "un solo remolque lleno compraría media calle mayor."
        ),
        "tts_en": (
            "An amusing bulletin from The Hub's merchant bankers: inspectors are still hunting down underground bottle-cap presses, "
            "since every genuine pre-war Nuka-Cola cap is literally backed by cold clean water from our towers. "
            "Explains why half the prospectors in California still dream of stumbling over a buried delivery rig in the dunes... "
            "one intact trailer full of caps could buy half of Main Street."
        ),
    },
    {
        "name": "v13_radio_dj_100",
        "sndr_fid": 0x010E004B,
        "edid": "SNDRV13RadioDJ100",
        "tts_es": (
            "¡Golpe de suerte legendario al sureste de El Eje! Un caminante con más fortuna que el mismísimo diablo acaba de toparse "
            "entre las dunas con un camión de reparto de Nuka-Cola volcado intacto y ha abierto su caja de caudales llena hasta los topes de chapas válidas. "
            "Si esta noche veis a alguien invitar a todo el mostrador de Mitch y reponer munición hasta las cejas sin regatear ni un segundo, "
            "ya sabéis de dónde salió el tesoro."
        ),
        "tts_en": (
            "Once-in-a-lifetime jackpot southeast of The Hub! A traveller carrying more luck than sense just stumbled across "
            "an overturned pre-war Nuka-Cola delivery truck in the dunes and cracked open its safe packed to the lid with crisp, legal bottle caps. "
            "If somebody strolls up to Mitch's counter tonight buying out every crate of ammo without blinking at the price, "
            "now you know which truck paid the tab."
        ),
    },
    {
        "name": "v13_radio_dj_101",
        "sndr_fid": 0x010E004C,
        "edid": "SNDRV13RadioDJ101",
        "tts_es": (
            "Anécdota simpática desde las ruinas de la vieja carretera al sureste de Ciudad Chatarra: alguien logró abrir la caja de exposición "
            "del antiguo Concesionario de Coches Usados de Bob y se llevó su famosa carabina de balines Red Ryder de edición limitada. "
            "Parece un juguete inofensivo de escaparate de feria... hasta que ves a un buen tirador acertar justo en el ojo "
            "a cincuenta pasos de distancia."
        ),
        "tts_en": (
            "Fun little tale from the ruined highway southeast of Junktown: someone finally cracked open the display safe "
            "inside old Bob's Used Car Mart and walked out cradling the legendary Red Ryder Limited Edition BB rifle. "
            "Looks like an innocent carnival toy off a dusty shelf... right up until a deadeye shooter puts one straight through a bullseye "
            "from fifty paces out."
        ),
    },
    # --- Slot 33 Pre-war Vault-Tec Lore ---
    {
        "name": "v13_radio_dj_102",
        "sndr_fid": 0x010E004D,
        "edid": "SNDRV13RadioDJ102",
        "tts_es": (
            "Antes de pasar al siguiente disco rescatado de las bóvedas, una reflexión curiosa sobre los viejos carteles amarillos de Vault-Tec "
            "que aún asoman bajo la arena. Prometían el futuro perfecto bajo tierra con lámparas solares y música ambiental interminable... "
            "pero olvidaron mencionar qué pasa cuando se estropea una sola placa de circuito ochenta años después. "
            "Aquí en la superficie no tendremos puertas blindadas, pero al menos nos queda la libertad del viento."
        ),
        "tts_en": (
            "Before we spin our next pre-war record rescued from the vaults, a quiet thought on those faded yellow Vault-Tec billboards "
            "still poking through the sand. They promised perfection underground with sunlamps and endless hi-fi music... "
            "never bothered mentioning what happens eighty years later when a single tiny circuit board gives out. "
            "Up here on top we don't have blast doors, friend, just the open wind and our own two feet."
        ),
    },
    # --- Slot 36 Evergreen Hub Cuisine & Tavern Life ---
    {
        "name": "v13_radio_dj_103",
        "sndr_fid": 0x010E004E,
        "edid": "SNDRV13RadioDJ103",
        "tts_es": (
            "¿Alguien más se pregunta qué cocinaban en los restaurantes elegantes de Los Ángeles antes del año dos mil setenta y siete? "
            "Hoy en las fogatas del Eje damos gracias por un buen filete de brahmán a la brasa bien pasado con sal del desierto "
            "y una Nuka-Cola tibia que aún conserva algo de gas después de un siglo. No será alta cocina de hotel, "
            "pero después de caminar cuarenta kilómetros entre geckos y saqueadores, sabe exactamente igual que la gloria."
        ),
        "tts_en": (
            "Anybody else ever wonder what folks ordered inside those fancy Los Angeles restaurants back before twenty seventy-seven? "
            "Around the campfires of The Hub tonight we give thanks for a charred brahmin steak dusted with desert salt "
            "and a warm Nuka-Cola that somehow kept half its fizz after a hundred years. Might not be white-tablecloth dining, "
            "yet after marching twenty miles past raiders and radscorpions, it tastes an awful lot like heaven."
        ),
    },
    # --- Slot 37 Evergreen 3 AM Night Watch ---
    {
        "name": "v13_radio_dj_104",
        "sndr_fid": 0x010E004F,
        "edid": "SNDRV13RadioDJ104",
        "tts_es": (
            "Son las tres de la madrugada aquí en lo alto de la Gran Torre de Agua de El Eje. Abajo las hogueras ya son brasas pálidas "
            "y el desierto entero parece contener la respiración bajo millones de estrellas limpias sin contaminación ni rascacielos. "
            "Si te toca hacer la última guardia antes del amanecer, prepárate un sorbo de agua fresca, mantén la radio bajita en el oído "
            "y deja que estas notas viejas te acompañen hasta que salga el sol."
        ),
        "tts_en": (
            "Three o'clock in the morning high atop the Great Water Tower of The Hub. Down below the caravan fires have burned to silver ash, "
            "and the whole desert holds its breath under a million clean stars with not a skyscraper left to block the view. "
            "If you drew the graveyard watch before dawn, take a slow sip from your canteen, keep your receiver low by your ear, "
            "and let these old songs ride beside you until first light."
        ),
    },
    # --- Slot 38 Crimson Caravan / Far Go Traders & Wasteland Medics ---
    {
        "name": "v13_radio_dj_105",
        "sndr_fid": 0x010E0050,
        "edid": "SNDRV13RadioDJ105",
        "tts_es": (
            "Chismorreo comercial del viernes en El Eje: la rivalidad entre la Caravana Carmesí y los Mercaderes de la Estrella Lejana "
            "anda más caliente que un reactor en verano. Demetre ofrece pagas dobles por atravesar zonas calientes en tiempo récord, "
            "mientras Butch y Rutger juran que prefieren llegar un día más tarde con todos sus guardias sanos y enteros. "
            "Si buscáis trabajo de escolta, elegid bien si preferís bolsas pesadas... o conservar las botas puestas al volver."
        ),
        "tts_en": (
            "Market gossip around The Hub tonight: the rivalry between Crimson Caravan and the Far Go Traders "
            "is running hotter than an overloaded reactor in July. Demetre offers double hazard pay to push freight through hot zones on tight deadlines, "
            "while Butch and Rutger swear they'd rather pull in a day late with every single guard still breathing. "
            "If you're signing onto a wagon train, ask yourself whether you want fast caps... or both boots still walking home."
        ),
    },
    {
        "name": "v13_radio_dj_106",
        "sndr_fid": 0x010E0051,
        "edid": "SNDRV13RadioDJ106",
        "tts_es": (
            "Llamamiento humanitario de los médicos de El Eje y la Biblioteca de los Seguidores del Apocalipsis: "
            "mientras crece la tensión militar en los frentes del norte, los hospitales de campaña necesitan urgentemente reservas de RadAway, "
            "Mentats y bolsas limpias de estimulantes. Cada frasco donado o vendido a precio justo salva hoy a un explorador herido "
            "en el camino hacia Mariposa. Aquí seguimos al pie del cañón, informando en el ochenta y cuatro punto cinco."
        ),
        "tts_en": (
            "Medical supply call from the Hub clinics and the Followers of the Apocalypse down in The Boneyard: "
            "with fighting heating up along the northern front, field aid stations are running dangerously low on RadAway, "
            "Mentats, and clean stimpak crates. Every dose donated or traded fairly today saves a wounded scout on the road north. "
            "We're staying right on the air with you, keeping watch at eighty-four point five."
        ),
    },
    # --- Slot 32 Special Encounter Giant Footprint ---
    {
        "name": "v13_radio_dj_107",
        "sndr_fid": 0x010E0052,
        "edid": "SNDRV13RadioDJ107",
        "tts_es": (
            "Noticias estrambóticas desde las salinas al norte de Shady Sands: un explorador que inspeccionó de cerca "
            "aquella gigantesca huella fosilizada de reptil de tres dedos ha vuelto con la sangre helada... "
            "¡y con un prototipo experimental de sigilo RobCo tres mil uno hallado junto a un desdichado caminante aplastado bajo la pisada! "
            "Sea lo que sea que dejó esa marca en el suelo, rezad para que siga dormido muy lejos de nuestras murallas."
        ),
        "tts_en": (
            "Strange report straight off the northern salt flats above Shady Sands: a brave scout who inspected "
            "that colossal three-toed reptile footprint up close walked back wide-eyed... "
            "clutching an experimental RobCo Stealth Boy three-thousand-and-one pulled from an unlucky traveller flattened inside the track! "
            "Whatever giant reptile left that print behind, let's pray it stays fast asleep far away from town walls."
        ),
    },
    {
        "name": "v13_radio_dj_108",
        "sndr_fid": 0x010E0053,
        "edid": "SNDRV13RadioDJ108",
        "tts_es": (
            "¿Espejismos de mediodía o verdad enterrada en la sal? Cada verano, cuando el calor reverbera sobre las salinas del norte, "
            "los conductores más curtidos juran ver figuras imposibles en el horizonte: caravanas fantasma, huellas gigantescas entre la costra blanca "
            "y destellos metálicos donde no hay ni una carretera marcada. Llevad siempre el doble de agua si salís de ruta al mediodía... "
            "el desierto californiano tiene sentido del humor, y suele gastar bromas pesadas."
        ),
        "tts_en": (
            "Heatstroke mirages or real wonders buried in the salt? Every dry spell, when noon heat shimmers across the northern salt flats, "
            "seasoned caravan drivers swear they see impossible things along the horizon: phantom wagons, gigantic tracks stamped in the white crust, "
            "and chrome glints miles from any paved road. Always pack double water if you march at high noon... "
            "the California desert has a wicked sense of humor."
        ),
    },
    # --- Slot 26 Master defeated via Vree's holotape persuasion ---
    {
        "name": "v13_radio_dj_109",
        "sndr_fid": 0x010E0054,
        "edid": "SNDRV13RadioDJ109",
        "tts_es": (
            "Un rumor asombroso corre hoy de boca en boca entre antiguos miembros de la Catedral que huyeron antes de la explosión: "
            "aseguran que el héroe del trece no derrotó al Maestro solo con plomo, sino poniéndole delante la holocinta médica de la escriba Vree "
            "para demostrarle que todos sus mutantes eran estériles. Desgarrado por su propia mentira, "
            "el mismísimo Maestro habría activado la autodestrucción nuclear para borrar su error de la historia."
        ),
        "tts_en": (
            "An astonishing story is spreading tonight among former Cathedral acolytes who fled before the blast: "
            "they swear the hero from Thirteen didn't break The Master with gunfire alone, but stood firm and proved with Scribe Vree's autopsy holotape "
            "that every Super Mutant was sterile. Shattered by the ruin of his own dream, "
            "The Master himself triggered the nuclear warhead to erase his mistake from history."
        ),
    },
    # --- Slot 26 Evergreen northern Vault City & Mojave tales ---
    {
        "name": "v13_radio_dj_110",
        "sndr_fid": 0x010E0055,
        "edid": "SNDRV13RadioDJ110",
        "tts_es": (
            "Mirando más allá de nuestras fronteras esta noche: cuentan los exploradores que llegan desde el lejano norte "
            "que existen otras tierras más allá de las montañas donde viejas comunidades salidas de refugios levantan muros blancos "
            "y caravanas aún más largas cruzan hacia Nevada. Quizá algún día el hombre vuelva a unir este país de costa a costa... "
            "mientras tanto, aquí seguimos cuidando la llama en el ochenta y cuatro punto cinco."
        ),
        "tts_en": (
            "Gazing past our valley ridges tonight: far-ranging scouts coming down from the northern frontier "
            "whisper about distant settlements beyond the peaks where sealed vault communities raise white walls "
            "and long wagon trains push east toward Nevada. Maybe one day folks will stitch this country back together coast to coast... "
            "until then, we'll keep the lamp lit right here at eighty-four point five."
        ),
    },
]


def build_reactive_radio_slots(make_ctda_getstage, make_ctda_getstagedone) -> list[dict]:
    """
    Return the 38 ordered DJ Slot Groups for SCEN 0x01008511 (V13RadioHubBroadcastScene).

    CRITICAL INVARIANT: Every slot's variant list strictly partitions all possible
    savegame states into mutually-exclusive, collectively-exhaustive CTDA clauses
    so that at runtime, Fallout 4 ALWAYS executes 1 and ONLY 1 variant per slot.
    """
    Q_ACT1 = 0x01004000
    Q_ACT2 = 0x01005000
    Q_ACT3 = 0x01006002
    Q_ACT4 = 0x01007000
    Q_ACT5 = 0x01008000
    Q_SHADY = 0x01009500
    Q_JUNKTOWN = 0x01010000
    Q_HUB = 0x01011000
    Q_KHANS = 0x01012000
    Q_GLOW = 0x01013000
    Q_BONEYARD = 0x01014000
    Q_TARDIS = 0x01015000
    Q_NUKA = 0x01016000
    Q_ALIEN = 0x01017000
    Q_TANDI = 0x01018000
    Q_JUNK_SYN = 0x01019000
    Q_HUB_SYN = 0x0101A000
    Q_FOOTPRINT = 0x0101B000
    Q_BOBS = 0x0101C000
    Q_PATRICK = 0x0101D000
    Q_WATER_MERCH = 0x0101E000
    Q_LH_PA = 0x010D1000
    Q_ADY_WAR = 0x010D2000
    Q_ADY_FORGE = 0x010D3000
    Q_FOLL_SPY = 0x010D4000
    Q_INVASION = 0x010D5000

    # OP bytes in CTDA: 0x60 = >=, 0x80 = <, 0x00 = == (paired via AND across list)
    ge = lambda fid, s: make_ctda_getstage(0x60, float(s), fid)
    lt = lambda fid, s: make_ctda_getstage(0x80, float(s), fid)
    done = lambda fid, s, val=True: make_ctda_getstagedone(fid, int(s), val)

    def dj(num: int) -> int:
        if 1 <= num <= 25:
            return 0x01008600 + num
        if 26 <= num <= 110:
            return 0x010E0000 + (num - 25)
        raise ValueError(f"Unknown radio DJ index: {num}")

    return [
        # Slot 01: Station ID
        {
            "id": "slot_01_station_id",
            "variants": [
                {"fid": dj(1), "ctdas": [lt(Q_ACT5, 35)]},
                {"fid": dj(26), "ctdas": [ge(Q_ACT5, 35)]},
            ],
        },
        # Slot 02: Legend of Vault 13 Dweller -> Post-Chip Veteran -> Exile Epilogue 1
        {
            "id": "slot_02_vault13_legend",
            "variants": [
                {"fid": dj(2), "ctdas": [lt(Q_ACT2, 38), lt(Q_ACT5, 40)]},
                {"fid": dj(27), "ctdas": [ge(Q_ACT2, 38), lt(Q_ACT5, 40)]},
                {"fid": dj(28), "ctdas": [ge(Q_ACT5, 40)]},
            ],
        },
        # Slot 03: Patrick the Celt intro (ALWAYS paired right before Ballad of Na Fianna)
        {
            "id": "slot_03_patrick_celt",
            "variants": [
                {"fid": dj(25), "ctdas": [lt(Q_PATRICK, 30)]},
                {"fid": dj(29), "ctdas": [ge(Q_PATRICK, 30)]},
            ],
        },
        # Slot 04: Act I — Vault 15 & Garl's Khans
        {
            "id": "slot_04_act1_vault15",
            "variants": [
                {"fid": dj(30), "ctdas": [lt(Q_ACT1, 22)]},
                {"fid": dj(31), "ctdas": [ge(Q_ACT1, 22), lt(Q_ACT1, 30), done(Q_ACT1, 24, False)]},
                {"fid": dj(4), "ctdas": [ge(Q_ACT1, 22), lt(Q_ACT1, 30), done(Q_ACT1, 24, True)]},
                {"fid": dj(32), "ctdas": [ge(Q_ACT1, 30)]},
            ],
        },
        # Slot 05: Shady Sands Radscorpions
        {
            "id": "slot_05_shady_sands",
            "variants": [
                {"fid": dj(33), "ctdas": [lt(Q_SHADY, 20)]},
                {"fid": dj(34), "ctdas": [ge(Q_SHADY, 20), lt(Q_SHADY, 30)]},
                {"fid": dj(3), "ctdas": [ge(Q_SHADY, 30)]},
            ],
        },
        # Slot 06: Act II Part A — Necropolis, Set Agreement, Hydraulic Parts, Pump Repaired
        {
            "id": "slot_06_act2_necropolis_pump",
            "variants": [
                {"fid": dj(7), "ctdas": [lt(Q_ACT2, 20)]},
                {"fid": dj(35), "ctdas": [ge(Q_ACT2, 20), lt(Q_ACT2, 23)]},
                {"fid": dj(36), "ctdas": [ge(Q_ACT2, 23), lt(Q_ACT2, 25)]},
                {"fid": dj(37), "ctdas": [ge(Q_ACT2, 25), lt(Q_ACT2, 26)]},
                {"fid": dj(38), "ctdas": [ge(Q_ACT2, 26), lt(Q_ACT2, 30)]},
                {"fid": dj(39), "ctdas": [ge(Q_ACT2, 30)]},
            ],
        },
        # Slot 07: Act II Part B — Harry Persuasion vs Combat & Vault 13 Water Chip Installed
        {
            "id": "slot_07_act2_harry_chip",
            "variants": [
                {"fid": dj(40), "ctdas": [lt(Q_ACT2, 27)]},
                {"fid": dj(41), "ctdas": [ge(Q_ACT2, 27), lt(Q_ACT2, 38), done(Q_ACT2, 27, True)]},
                {"fid": dj(42), "ctdas": [ge(Q_ACT2, 27), lt(Q_ACT2, 38), done(Q_ACT2, 27, False)]},
                {"fid": dj(43), "ctdas": [ge(Q_ACT2, 38)]},
            ],
        },
        # Slot 08: Water Merchants Relief Convoy
        {
            "id": "slot_08_water_merchants",
            "variants": [
                {"fid": dj(21), "ctdas": [lt(Q_WATER_MERCH, 21)]},
                {"fid": dj(44), "ctdas": [ge(Q_WATER_MERCH, 21), done(Q_WATER_MERCH, 22, False)]},
                {"fid": dj(45), "ctdas": [ge(Q_WATER_MERCH, 21), done(Q_WATER_MERCH, 22, True)]},
            ],
        },
        # Slot 09: Tandi Kidnapping & Rescue
        {
            "id": "slot_09_tandi_rescue",
            "variants": [
                {"fid": dj(46), "ctdas": [lt(Q_TANDI, 15)]},
                {"fid": dj(47), "ctdas": [ge(Q_TANDI, 15), lt(Q_TANDI, 30)]},
                {"fid": dj(48), "ctdas": [ge(Q_TANDI, 30), done(Q_TANDI, 28, False)]},
                {"fid": dj(49), "ctdas": [ge(Q_TANDI, 30), done(Q_TANDI, 28, True)]},
            ],
        },
        # Slot 10: Khans Slaver Camp
        {
            "id": "slot_10_khans_slavers",
            "variants": [
                {"fid": dj(50), "ctdas": [lt(Q_KHANS, 20)]},
                {"fid": dj(51), "ctdas": [ge(Q_KHANS, 20), lt(Q_KHANS, 30)]},
                {"fid": dj(52), "ctdas": [ge(Q_KHANS, 30)]},
            ],
        },
        # Slot 11: Junktown Part A — Killian vs Kenji
        {
            "id": "slot_11_junktown_kenji",
            "variants": [
                {"fid": dj(5), "ctdas": [lt(Q_JUNKTOWN, 20)]},
                {"fid": dj(53), "ctdas": [ge(Q_JUNKTOWN, 20), lt(Q_JUNKTOWN, 30)]},
                {"fid": dj(54), "ctdas": [ge(Q_JUNKTOWN, 30)]},
            ],
        },
        # Slot 12: Junktown Part B — Skulz, Neal's Urn & Gizmo
        {
            "id": "slot_12_junktown_syndicate",
            "variants": [
                {"fid": dj(55), "ctdas": [lt(Q_JUNK_SYN, 15)]},
                {"fid": dj(56), "ctdas": [ge(Q_JUNK_SYN, 15), lt(Q_JUNK_SYN, 30)]},
                {"fid": dj(57), "ctdas": [ge(Q_JUNK_SYN, 30), done(Q_JUNK_SYN, 28, False)]},
                {"fid": dj(58), "ctdas": [ge(Q_JUNK_SYN, 30), done(Q_JUNK_SYN, 28, True)]},
            ],
        },
        # Slot 13: Doc Morbid & Iguana Bob
        {
            "id": "slot_13_doc_morbid",
            "variants": [
                {"fid": dj(15), "ctdas": [done(Q_JUNK_SYN, 25, False)]},
                {"fid": dj(59), "ctdas": [done(Q_JUNK_SYN, 25, True)]},
            ],
        },
        # Slot 14: Hub Part A — Irwin's Farm & .223 Pistol
        {
            "id": "slot_14_hub_irwin",
            "variants": [
                {"fid": dj(60), "ctdas": [lt(Q_HUB, 11)]},
                {"fid": dj(61), "ctdas": [ge(Q_HUB, 11), lt(Q_HUB, 30)]},
                {"fid": dj(62), "ctdas": [ge(Q_HUB, 30)]},
            ],
        },
        # Slot 15: Hub Part B — Missing Caravans, Tug & Decker
        {
            "id": "slot_15_hub_syndicate",
            "variants": [
                {"fid": dj(6), "ctdas": [lt(Q_HUB_SYN, 20)]},
                {"fid": dj(63), "ctdas": [ge(Q_HUB_SYN, 20), lt(Q_HUB_SYN, 25)]},
                {"fid": dj(64), "ctdas": [ge(Q_HUB_SYN, 25), lt(Q_HUB_SYN, 30)]},
                {"fid": dj(65), "ctdas": [ge(Q_HUB_SYN, 30), done(Q_HUB_SYN, 28, False)]},
                {"fid": dj(66), "ctdas": [ge(Q_HUB_SYN, 30), done(Q_HUB_SYN, 28, True)]},
            ],
        },
        # Slot 16: The Glow & West Tek Initiation
        {
            "id": "slot_16_the_glow",
            "variants": [
                {"fid": dj(9), "ctdas": [lt(Q_GLOW, 20)]},
                {"fid": dj(67), "ctdas": [ge(Q_GLOW, 20), lt(Q_GLOW, 30)]},
                {"fid": dj(68), "ctdas": [ge(Q_GLOW, 30)]},
            ],
        },
        # Slot 17: Lost Hills T-51b Power Armor & Initiate Lorenzo
        {
            "id": "slot_17_lost_hills_pa",
            "variants": [
                {"fid": dj(17), "ctdas": [lt(Q_LH_PA, 12)]},
                {"fid": dj(69), "ctdas": [ge(Q_LH_PA, 12), lt(Q_LH_PA, 40)]},
                {"fid": dj(70), "ctdas": [ge(Q_LH_PA, 40)]},
            ],
        },
        # Slot 18: Act III — Vree's FEV Sterility Autopsy & Maxson's War Council
        {
            "id": "slot_18_act3_lost_hills",
            "variants": [
                {"fid": dj(8), "ctdas": [lt(Q_ACT3, 25)]},
                {"fid": dj(71), "ctdas": [ge(Q_ACT3, 25), lt(Q_ACT3, 30)]},
                {"fid": dj(72), "ctdas": [ge(Q_ACT3, 30), lt(Q_ACT5, 35)]},
                {"fid": dj(73), "ctdas": [ge(Q_ACT3, 30), ge(Q_ACT5, 35)]},
            ],
        },
        # Slot 19: Act IV Part A — Preparing & Assaulting Mariposa -> Destroyed
        {
            "id": "slot_19_act4_mariposa",
            "variants": [
                {"fid": dj(12), "ctdas": [lt(Q_ACT4, 15)]},
                {"fid": dj(74), "ctdas": [ge(Q_ACT4, 15), lt(Q_ACT4, 22)]},
                {"fid": dj(75), "ctdas": [ge(Q_ACT4, 22), lt(Q_ACT4, 30)]},
                {"fid": dj(76), "ctdas": [ge(Q_ACT4, 30)]},
            ],
        },
        # Slot 20: Act IV Part B — Lieutenant Lou & Northern Caravan Routes
        {
            "id": "slot_20_act4_lou",
            "variants": [
                {"fid": dj(19), "ctdas": [lt(Q_ACT4, 30)]},
                {"fid": dj(77), "ctdas": [ge(Q_ACT4, 30)]},
            ],
        },
        # Slot 21: Boneyard Part A — Mother Deathclaw & Gun Runners
        {
            "id": "slot_21_boneyard_deathclaw",
            "variants": [
                {"fid": dj(10), "ctdas": [lt(Q_BONEYARD, 20)]},
                {"fid": dj(78), "ctdas": [ge(Q_BONEYARD, 20), lt(Q_BONEYARD, 30)]},
                {"fid": dj(79), "ctdas": [ge(Q_BONEYARD, 30)]},
            ],
        },
        # Slot 22: Boneyard Part B — Adytum Civil War (Zimmerman vs Caleb)
        {
            "id": "slot_22_adytum_war",
            "variants": [
                {"fid": dj(18), "ctdas": [lt(Q_ADY_WAR, 25)]},
                {"fid": dj(80), "ctdas": [ge(Q_ADY_WAR, 25), lt(Q_ADY_WAR, 35)]},
                {"fid": dj(81), "ctdas": [ge(Q_ADY_WAR, 35)]},
            ],
        },
        # Slot 23: Boneyard Part C — Miles's Hydroponics & Smitty's Hardened Forge
        {
            "id": "slot_23_adytum_forge",
            "variants": [
                {"fid": dj(82), "ctdas": [lt(Q_ADY_FORGE, 20)]},
                {"fid": dj(83), "ctdas": [ge(Q_ADY_FORGE, 20), lt(Q_ADY_FORGE, 40)]},
                {"fid": dj(84), "ctdas": [ge(Q_ADY_FORGE, 40)]},
            ],
        },
        # Slot 24: Followers Spy Hunt (Heather & Red Rose)
        {
            "id": "slot_24_followers_spy",
            "variants": [
                {"fid": dj(20), "ctdas": [lt(Q_FOLL_SPY, 20)]},
                {"fid": dj(85), "ctdas": [ge(Q_FOLL_SPY, 20), lt(Q_FOLL_SPY, 30)]},
                {"fid": dj(86), "ctdas": [ge(Q_FOLL_SPY, 30)]},
            ],
        },
        # Slot 25: Act V Part A — Cathedral Approach, Infiltration & Atomic Blast
        {
            "id": "slot_25_act5_cathedral",
            "variants": [
                {"fid": dj(11), "ctdas": [lt(Q_ACT5, 15)]},
                {"fid": dj(87), "ctdas": [ge(Q_ACT5, 15), lt(Q_ACT5, 22)]},
                {"fid": dj(22), "ctdas": [ge(Q_ACT5, 22), lt(Q_ACT5, 30)]},
                {"fid": dj(88), "ctdas": [ge(Q_ACT5, 30)]},
            ],
        },
        # Slot 26: Act V Part B — How the Master Fell (Sterility Proof vs Combat)
        {
            "id": "slot_26_act5_master_outcome",
            "variants": [
                {"fid": dj(110), "ctdas": [lt(Q_ACT5, 30)]},
                {"fid": dj(109), "ctdas": [ge(Q_ACT5, 30), done(Q_ACT5, 26, True)]},
                {"fid": dj(90), "ctdas": [ge(Q_ACT5, 30), done(Q_ACT5, 26, False)]},
            ],
        },
        # Slot 27: Night Reflections -> Part 2 War -> Both Destroyed -> Arroyo Exile Epilogue 2
        {
            "id": "slot_27_night_and_epilogue",
            "variants": [
                {"fid": dj(89), "ctdas": [lt(Q_ACT5, 35), lt(Q_ACT3, 20)]},
                {"fid": dj(24), "ctdas": [lt(Q_ACT5, 35), ge(Q_ACT3, 20)]},
                {"fid": dj(91), "ctdas": [ge(Q_ACT5, 35), lt(Q_ACT5, 40)]},
                {"fid": dj(92), "ctdas": [ge(Q_ACT5, 40)]},
            ],
        },
        # Slot 28: Desert Rangers Convoy Ambush
        {
            "id": "slot_28_desert_rangers",
            "variants": [
                {"fid": dj(93), "ctdas": [done(Q_INVASION, 14, False)]},
                {"fid": dj(94), "ctdas": [done(Q_INVASION, 14, True)]},
            ],
        },
        # Slot 29: Pacific Coast Old Fisherman
        {
            "id": "slot_29_pacific_fisherman",
            "variants": [
                {"fid": dj(95), "ctdas": [done(Q_INVASION, 16, False)]},
                {"fid": dj(96), "ctdas": [done(Q_INVASION, 16, True)]},
            ],
        },
        # Slot 30: Special Encounters — Blue Police Box & Area 51 Saucer
        {
            "id": "slot_30_special_tardis_alien",
            "variants": [
                {"fid": dj(23), "ctdas": [lt(Q_TARDIS, 30), lt(Q_ALIEN, 30)]},
                {"fid": dj(97), "ctdas": [ge(Q_TARDIS, 30), lt(Q_ALIEN, 30)]},
                {"fid": dj(98), "ctdas": [ge(Q_ALIEN, 30)]},
            ],
        },
        # Slot 31: Special Encounters — Nuka-Cola Truck & Bob's Used Car Mart
        {
            "id": "slot_31_special_nuka_bobs",
            "variants": [
                {"fid": dj(99), "ctdas": [lt(Q_NUKA, 30), lt(Q_BOBS, 30)]},
                {"fid": dj(100), "ctdas": [ge(Q_NUKA, 30), lt(Q_BOBS, 30)]},
                {"fid": dj(101), "ctdas": [ge(Q_BOBS, 30)]},
            ],
        },
        # Slot 32: Special Encounter — Giant Godzilla Footprint
        {
            "id": "slot_32_special_footprint",
            "variants": [
                {"fid": dj(108), "ctdas": [lt(Q_FOOTPRINT, 30)]},
                {"fid": dj(107), "ctdas": [ge(Q_FOOTPRINT, 30)]},
            ],
        },
        # Slot 33: FEV Genetics vs Pre-war Vault-Tec Lore
        {
            "id": "slot_33_fev_vs_vaulttec",
            "variants": [
                {"fid": dj(102), "ctdas": [lt(Q_ACT2, 20)]},
                {"fid": dj(14), "ctdas": [ge(Q_ACT2, 20)]},
            ],
        },
        # Slot 34: Harold's 2102 Expedition Lore
        {
            "id": "slot_34_harold_lore",
            "variants": [
                {"fid": dj(13), "ctdas": []},
            ],
        },
        # Slot 35: Companions of New California
        {
            "id": "slot_35_companions",
            "variants": [
                {"fid": dj(16), "ctdas": []},
            ],
        },
        # Slot 36: Evergreen Caravan Cuisine & Hub Taverns
        {
            "id": "slot_36_hub_cuisine",
            "variants": [
                {"fid": dj(103), "ctdas": []},
            ],
        },
        # Slot 37: Evergreen 3 AM Night Watch Atop the Great Water Tower
        {
            "id": "slot_37_night_watch",
            "variants": [
                {"fid": dj(104), "ctdas": []},
            ],
        },
        # Slot 38: Crimson Caravan vs Far Go Traders -> Medics Alert
        {
            "id": "slot_38_caravan_rivalry_medics",
            "variants": [
                {"fid": dj(105), "ctdas": [lt(Q_ACT4, 20)]},
                {"fid": dj(106), "ctdas": [ge(Q_ACT4, 20)]},
            ],
        },
    ]


RADIO_JINGLE_DEFS: list[dict] = [
    {"name": "v13_radio_jingle_01", "sndr_fid": 0x010E0101, "edid": "SNDRV13RadioJingle01", "file": "Jingle - Ice Cold Nuka-Cola (1).mp3"},
    {"name": "v13_radio_jingle_02", "sndr_fid": 0x010E0102, "edid": "SNDRV13RadioJingle02", "file": "Jingle - Corvega Atomic V8 (1).mp3"},
    {"name": "v13_radio_jingle_03", "sndr_fid": 0x010E0103, "edid": "SNDRV13RadioJingle03", "file": "Jingle - Vault-Tec Vault of Tomorrow (1).mp3"},
    {"name": "v13_radio_jingle_04", "sndr_fid": 0x010E0104, "edid": "SNDRV13RadioJingle04", "file": "Jingle - General Atomics Mister Handy (1).mp3"},
    {"name": "v13_radio_jingle_05", "sndr_fid": 0x010E0105, "edid": "SNDRV13RadioJingle05", "file": "Jingle - Radiation King (1).mp3"},
    {"name": "v13_radio_jingle_06", "sndr_fid": 0x010E0106, "edid": "SNDRV13RadioJingle06", "file": "Jingle - Ice Cold Nuka-Cola (2).mp3"},
    {"name": "v13_radio_jingle_07", "sndr_fid": 0x010E0107, "edid": "SNDRV13RadioJingle07", "file": "Jingle - Corvega Atomic V8 (2).mp3"},
    {"name": "v13_radio_jingle_08", "sndr_fid": 0x010E0108, "edid": "SNDRV13RadioJingle08", "file": "Jingle - Vault-Tec Vault of Tomorrow (2).mp3"},
    {"name": "v13_radio_jingle_09", "sndr_fid": 0x010E0109, "edid": "SNDRV13RadioJingle09", "file": "Jingle - General Atomics Mister Handy (2).mp3"},
    {"name": "v13_radio_jingle_10", "sndr_fid": 0x010E010A, "edid": "SNDRV13RadioJingle10", "file": "Jingle - Radiation King (2).mp3"},
    {"name": "v13_radio_jingle_11", "sndr_fid": 0x010E010B, "edid": "SNDRV13RadioJingle11", "file": "Jingle - Ice Cold Nuka-Cola (3).mp3"},
    {"name": "v13_radio_jingle_12", "sndr_fid": 0x010E010C, "edid": "SNDRV13RadioJingle12", "file": "Jingle - Corvega Atomic V8 (3).mp3"},
    {"name": "v13_radio_jingle_13", "sndr_fid": 0x010E010D, "edid": "SNDRV13RadioJingle13", "file": "Jingle - Vault-Tec Vault of Tomorrow (3).mp3"},
    {"name": "v13_radio_jingle_14", "sndr_fid": 0x010E010E, "edid": "SNDRV13RadioJingle14", "file": "Jingle - General Atomics Mister Handy (3).mp3"},
    {"name": "v13_radio_jingle_15", "sndr_fid": 0x010E010F, "edid": "SNDRV13RadioJingle15", "file": "Jingle - Radiation King (3).mp3"},
    {"name": "v13_radio_jingle_16", "sndr_fid": 0x010E0110, "edid": "SNDRV13RadioJingle16", "file": "Jingle - Corvega Atomic V8 (4).mp3"},
    {"name": "v13_radio_jingle_17", "sndr_fid": 0x010E0111, "edid": "SNDRV13RadioJingle17", "file": "Jingle - Vault-Tec Vault of Tomorrow (4).mp3"},
    {"name": "v13_radio_jingle_18", "sndr_fid": 0x010E0112, "edid": "SNDRV13RadioJingle18", "file": "Jingle - General Atomics Mister Handy (4).mp3"},
]


RADIO_DRAMA_DEFS: list[dict] = [
    {
        "name": "v13_radio_drama_01",
        "sndr_fid": 0x010E0201,
        "edid": "SNDRV13RadioDrama01",
        "file_es": "Aviso - Mercaderes del Agua Martha Rastello ES (1).mp3",
        "file_en": "Aviso - Water Merchants Martha Rastello EN (1).mp3",
        "ctda_mode": "pre_epilogue",
    },
    {
        "name": "v13_radio_drama_02",
        "sndr_fid": 0x010E0202,
        "edid": "SNDRV13RadioDrama02",
        "file_es": "Cronica - Superviviente Caravana Ruta del Norte ES (1).mp3",
        "file_en": "Chronicle - Caravan Survivor Northern Trail EN (1).mp3",
        "ctda_mode": "pre_mariposa",
    },
    {
        "name": "v13_radio_drama_03",
        "sndr_fid": 0x010E0203,
        "edid": "SNDRV13RadioDrama03",
        "file_es": "Emision - Seguidores Nicole Osario ES (1).mp3",
        "file_en": "Broadcast - Followers Nicole Boneyard EN (1).mp3",
        "ctda_mode": "pre_epilogue",
    },
    {
        "name": "v13_radio_drama_04",
        "sndr_fid": 0x010E0204,
        "edid": "SNDRV13RadioDrama04",
        "file_es": "Sermon - Hijos de la Catedral ES (1).mp3",
        "file_en": "Sermon - Children of the Cathedral EN (1).mp3",
        "ctda_mode": "pre_cathedral",
    },
    {
        "name": "v13_radio_drama_05",
        "sndr_fid": 0x010E0205,
        "edid": "SNDRV13RadioDrama05",
        "file_es": "Aviso - Mercaderes del Agua Martha Rastello ES (2).mp3",
        "file_en": "Aviso - Water Merchants Martha Rastello EN (2).mp3",
        "ctda_mode": "pre_epilogue",
    },
    {
        "name": "v13_radio_drama_06",
        "sndr_fid": 0x010E0206,
        "edid": "SNDRV13RadioDrama06",
        "file_es": "Cronica - Superviviente Caravana Ruta del Norte ES (2).mp3",
        "file_en": "Chronicle - Caravan Survivor Northern Trail EN (2).mp3",
        "ctda_mode": "pre_mariposa",
    },
    {
        "name": "v13_radio_drama_07",
        "sndr_fid": 0x010E0207,
        "edid": "SNDRV13RadioDrama07",
        "file_es": "Emision - Seguidores Nicole Osario ES (2).mp3",
        "file_en": "Broadcast - Followers Nicole Boneyard EN (2).mp3",
        "ctda_mode": "pre_epilogue",
    },
    {
        "name": "v13_radio_drama_08",
        "sndr_fid": 0x010E0208,
        "edid": "SNDRV13RadioDrama08",
        "file_es": "Sermon - Hijos de la Catedral ES (2).mp3",
        "file_en": "Sermon - Children of the Cathedral EN (2).mp3",
        "ctda_mode": "pre_cathedral",
    },
]


def build_radio_drama_entries(make_ctda_getstage) -> list[tuple[int, list[bytes]]]:
    """Return ordered (sndr_fid, ctdas) entries for the 8 localized 2161 Suno Speech dramatizations."""
    Q_ACT4 = 0x01007000
    Q_ACT5 = 0x01008000

    entries: list[tuple[int, list[bytes]]] = []
    for d in RADIO_DRAMA_DEFS:
        mode = d["ctda_mode"]
        if mode == "pre_mariposa":
            ctdas = [make_ctda_getstage(0x80, 30.0, Q_ACT4)]  # < 30 (stops once Mariposa Vats destroyed)
        elif mode == "pre_cathedral":
            ctdas = [make_ctda_getstage(0x80, 30.0, Q_ACT5)]  # < 30 (pirate Cathedral signal stops once Cathedral nuked)
        else:
            ctdas = [make_ctda_getstage(0x80, 35.0, Q_ACT5)]  # < 35 (stops in post-war Epilogue)
        entries.append((d["sndr_fid"], ctdas))
    return entries
