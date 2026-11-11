# -*- coding: utf-8 -*-
"""
Synthesizes all English voice clips (.xwm) and all 24 English 'The Hub Radio 84.5' DJ broadcasts (.xwm)
for Vault 13 Chronicles (2161) — 100% English Edition using ElevenLabs Pro + FFmpeg + xwmaencode.exe.
"""

import concurrent.futures
import json
import os
import re
import shutil
import struct
import subprocess
import sys
import time
import urllib.request
import wave
import zlib

sys.stdout.reconfigure(encoding="utf-8")

THIS_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.dirname(THIS_DIR)
sys.path.insert(0, ROOT_DIR)

import build_cronicas_refugio_13 as es_builder

FO4_ROOT = es_builder.FO4_ROOT
FFMPEG_BIN = es_builder.FFMPEG_BIN
XWMAENCODE_BIN = es_builder.XWMAENCODE_BIN
SFX_DIR = es_builder.SFX_DIR

VOICES_EN_DIR = os.path.join(THIS_DIR, "voices_en")
RADIO_DJ_EN_DIR = os.path.join(THIS_DIR, "assets", "radio_dj_en")
ESP_NAME = "Vault13Chronicles.esp"

# English Voice IDs (matching build_cronicas_refugio_13_en.py + build_cronicas_refugio_13.py)
VOICE_ID_MAP_EN = {
    "NPCMOverseerJacoren": "pqHfZKP75CvOlQylNhV4",       # Bill (authoritative Overseer)
    "PlayerVoiceMale01": "nPczCjzI2devNBz1zQrb",         # Brian (Male Vault Dweller)
    "PlayerVoiceFemale01": "EXAVITQu4vr4xnSDxMaL",       # Sarah (Female Vault Dweller)
    "NPCMVault13Resident": "onwK4e9ZLuTAKqWW03F9",       # Daniel
    "NPCFVault13Resident": "XrExE9yKIg1WjnnlVkGX",       # Matilda
    "NPCMUndergroundLeader": "N2lVS1w4EtoT3dr4eOWO",     # Callum (raspy Underground Ghoul / wasteland male)
    "NPCMSetNecropolis": "VR6AewLTigWG4xSOukaG",         # Arnold (deep gritty Set / Super Mutant)
    "V13HarrySuperMutantVoice": "VR6AewLTigWG4xSOukaG",  # Arnold + pitch-shifted Super Mutant filter
    "CrSuperMutant": "VR6AewLTigWG4xSOukaG",             # Arnold + pitch-shifted Super Mutant filter
}

RADIO_DJ_VOICE_ID = "JBFqnCBsd6RMkjVDRZzb"  # George (warm gravelly radio host)

V13_RADIO_DJ_DEFS_EN = [
    {
        "name": "v13_radio_dj_01",
        "sndr_fid": 0x01008601,
        "edid": "SNDRV13RadioDJ01",
        "tts": (
            "This is The Hub Radio, broadcasting at eighty-four point five kilocycles from atop the Great Water Tower "
            "of the Water Merchants, right in the heart of New California. It is December of the year twenty-one sixty-one; "
            "if your Pip-Boy or vacuum-tube receiver picks up our carrier wave through the dust storms, you're not alone out there. "
            "Strap on your holsters, check your canteens, and turn up the dial... the music of the wasteland is on the air."
        ),
    },
    {
        "name": "v13_radio_dj_02",
        "sndr_fid": 0x01008602,
        "edid": "SNDRV13RadioDJ02",
        "tts": (
            "Caravaneers from the Far Go Traders bring a fascinating rumor down from the western peaks of Mount Whitney. "
            "They swear they spotted a lone traveller wearing a spotless blue jumpsuit with the number thirteen stitched in gold on the back, "
            "carrying a ten millimeter pistol and asking around for water purification parts. "
            "For eighty-four years we thought Vault Thirteen was just a pre-war legend... "
            "If you're listening to my voice, friend from number thirteen: welcome to the real world."
        ),
    },
    {
        "name": "v13_radio_dj_03",
        "sndr_fid": 0x01008603,
        "edid": "SNDRV13RadioDJ03",
        "tts": (
            "A bulletin for travellers on the northern road between the mountains and Vault Fifteen: the small farming community of Shady Sands, "
            "led by Aradesh and his daughter Tandi, is celebrating after the radscorpion caves threatening their brahmin herds were wiped out. "
            "Doctor Razlo is already distributing his antivenom serum, and word is the gunslinger Ian was seen at the gate "
            "before heading east. Fine work to whoever cleared out those nests."
        ),
    },
    {
        "name": "v13_radio_dj_04",
        "sndr_fid": 0x01008604,
        "edid": "SNDRV13RadioDJ04",
        "tts": (
            "Watch your step east of Shady Sands, in the canyon of old Vault Fifteen. The raider tribe calling itself the Khans, "
            "led by warlord Garl Death-Hand, has turned the upper levels of that buried bunker into their personal stronghold. "
            "If you venture into those galleries hunting for pre-war Vault-Tec relics, pack plenty of ammo and watch every corner... "
            "though rumor has it somebody just taught the Khans a lesson they won't soon forget."
        ),
    },
    {
        "name": "v13_radio_dj_05",
        "sndr_fid": 0x01008605,
        "edid": "SNDRV13RadioDJ05",
        "tts": (
            "News from Junktown, just north of The Hub: tensions between Mayor and Sheriff Killian Darkwater, grandson of the town's founder, "
            "and the bloated casino boss Gizmo are about to boil over. While Killian's guards keep order at the gates "
            "and a tough pitbull named Dogmeat roams the alleys looking for a new travelling partner, the Skulz gang is harassing The Skum Pitt tavern. "
            "And now, another musical gem rescued from the pre-war vaults."
        ),
    },
    {
        "name": "v13_radio_dj_06",
        "sndr_fid": 0x01008606,
        "edid": "SNDRV13RadioDJ06",
        "tts": (
            "A commercial reminder from the Water Merchants of The Hub: every single Nuka-Cola bottle cap is backed by an exact ration "
            "of clean drinking water from our towers. Don't let the Crimson Caravan lure you into reckless northern runs, "
            "and don't walk unescorted down the back room of The Maltese Falcon, where Kane and his boss Decker offer contracts no honest soul would touch. "
            "And don't mind old Harold in Old Town when he starts rambling about cranes and vats of green slime... or maybe we should be listening to him?"
        ),
    },
    {
        "name": "v13_radio_dj_07",
        "sndr_fid": 0x01008607,
        "edid": "SNDRV13RadioDJ07",
        "tts": (
            "East of here rise the scorched skeletons of old Bakersfield, known across the wasteland today as Necropolis: the City of the Dead. "
            "They say the blast door of Vault Twelve never closed in twenty seventy-seven, and its ghoul inhabitants answer to the ruthless Set "
            "inside the Hall of the Dead. Yet scouts report that towering green-skinned soldiers armed with laser rifles and flamers "
            "have seized the Watershed under a mutant named Harry. If you're looking for water in Necropolis, pray you have a silver tongue... or a two-two-three pistol."
        ),
    },
    {
        "name": "v13_radio_dj_08",
        "sndr_fid": 0x01008608,
        "edid": "SNDRV13RadioDJ08",
        "tts": (
            "Northwest of The Hub, in the hills of Lost Hills, the sentinels of the Brotherhood of Steel stand guard outside their armored bunker "
            "clad in gleaming T-fifty-one B power armor. High Elder John Maxson and Head Paladin Rhombus rarely open their doors "
            "to outsiders, and anyone knocking on their airlock is usually sent on a suicide run south to the radioactive crater of The Glow. "
            "Still, whispers say Head Scribe Vree has uncovered something unsettling in her laboratory... something that could change the fate of California."
        ),
    },
    {
        "name": "v13_radio_dj_09",
        "sndr_fid": 0x01008609,
        "edid": "SNDRV13RadioDJ09",
        "tts": (
            "A warning to southern scavengers: stay clear of the old West Tek Research Facility, known across the desert as The Glow. "
            "A direct nuclear strike in twenty seventy-seven left a glowing chasm where radiation eats through any armor without a heavy dose of Rad-X. "
            "Those who peered into its lower levels swear the security robots are still active and that an artificial intelligence mainframe "
            "named ZAX still waits in the dark, playing chess beside the classified archives of the Forced Evolutionary Virus."
        ),
    },
    {
        "name": "v13_radio_dj_10",
        "sndr_fid": 0x0100860A,
        "edid": "SNDRV13RadioDJ10",
        "tts": (
            "From the ruins of Los Angeles, in The Boneyard, word reaches us from the town of Adytum and from Nicole's library of the Followers of the Apocalypse. "
            "Gabriel's Gun Runners have set up their workshop inside the old factory surrounded by a toxic moat, ready to trade heavy weaponry "
            "to anyone who clears the Deathclaw nest on the central flats. And in Adytum's smithy, Master Gunsmith Smitty swears he can turn "
            "any Winchester P-ninety-four plasma rifle into a true Turbo Plasma caster."
        ),
    },
    {
        "name": "v13_radio_dj_11",
        "sndr_fid": 0x0100860B,
        "edid": "SNDRV13RadioDJ11",
        "tts": (
            "This is The Hub Radio, keeping the free voice of California alive. Every week we see more purple-robed preachers of the Children of the Cathedral "
            "preaching peace and the so-called Unity from their hospitals, under the watchful eye of High Priest Morpheus in his towering southern Cathedral. "
            "They speak of brotherhood and leaving human hatred behind, yet those who have looked behind the altars whisper that beneath the Cathedral "
            "beats something far darker and older than a simple church."
        ),
    },
    {
        "name": "v13_radio_dj_12",
        "sndr_fid": 0x0100860C,
        "edid": "SNDRV13RadioDJ12",
        "tts": (
            "We close this hour's bulletin with the gravest alert from the Water Merchants and the Far Go Traders: "
            "more than a dozen caravans have vanished without a trace in the northwestern mountain wastes near the old Mariposa Military Base. "
            "The few survivors speak of giant mutant patrols and invisible Nightkin striking in the dead of night to drag prisoners "
            "toward underground vats. Watch out for your people out there, keep your Pip-Boy tuned to eighty-four point five, "
            "and let the music of The Hub Radio ride with you across the desert."
        ),
    },
    {
        "name": "v13_radio_dj_13",
        "sndr_fid": 0x0100860D,
        "edid": "SNDRV13RadioDJ13",
        "tts": (
            "If you pass through Old Town in The Hub and spare a few caps for old Harold, listen closely to his story. "
            "Most folks think he's just a weathered ghoul beggar, but back in twenty-one oh-two he led an expedition northwest "
            "alongside Francine and a brilliant exiled doctor from Vault City named Richard Moreau, who went by the name Richard Grey. "
            "They were tracking the source of the mutant beasts attacking their caravans and stumbled into a military base filled with robotic cranes and vats of green slime. "
            "Harold woke up out in the desert already mutated... but Richard Grey fell straight into one of those vats. And what crawled out was no longer human."
        ),
    },
    {
        "name": "v13_radio_dj_14",
        "sndr_fid": 0x0100860E,
        "edid": "SNDRV13RadioDJ14",
        "tts": (
            "Why are Super Mutant patrols combing every canyon in California looking for sealed underground Vaults? "
            "According to intelligence leaked by the Followers of the Apocalypse, the Forced Evolutionary Virus in the Mariposa vats has a fatal flaw: "
            "when wastelanders exposed to decades of background radiation are dipped into the vats, the virus ravages their cerebral cortex "
            "and produces dim-witted brutes like Harry in Necropolis. To forge brilliant officers like Lieutenant Lou, their army needs "
            "genetically pure humans... like the dwellers sealed for eighty years beneath Mount Whitney in Vault Thirteen."
        ),
    },
    {
        "name": "v13_radio_dj_15",
        "sndr_fid": 0x0100860F,
        "edid": "SNDRV13RadioDJ15",
        "tts": (
            "A culinary tip for visitors to The Hub's central market: you might want to think twice before buying "
            "the famous skewers at Bob Frazier's Iguana Bits stand. Dark rumors are swirling around his secret shipments from Junktown, "
            "where Doctor Morbid and his assistant Gretch run a hidden basement laboratory beneath the clinic. "
            "Word is the prime cuts arriving on ice in The Hub aren't reptile meat at all... but lonely drifters "
            "who couldn't pay their medical bills. If you get hungry on the road, stick to a pre-war can of Pork and Beans."
        ),
    },
    {
        "name": "v13_radio_dj_16",
        "sndr_fid": 0x01008610,
        "edid": "SNDRV13RadioDJ16",
        "tts": (
            "The New California wasteland is unforgiving to those who walk alone, but taverns are already talking about an unforgettable squad of companions. "
            "In Shady Sands, veteran caravan guard Ian remains the fastest ten millimeter pistol in the north. In Junktown, Tycho, "
            "grandson of the legendary Nevada Desert Rangers, oils his combat shotgun while a loyal dog named Dogmeat "
            "follows anyone wearing a leather jacket. And in The Boneyard library, the agile scout Katja knows every passage through the ruins of Los Angeles."
        ),
    },
    {
        "name": "v13_radio_dj_17",
        "sndr_fid": 0x01008611,
        "edid": "SNDRV13RadioDJ17",
        "tts": (
            "For those wondering where the armored knights of Lost Hills came from, the story goes back to October twenty seventy-seven, "
            "just three days before the bombs fell. United States Army Captain Roger Maxson discovered that scientists inside Mariposa Military Base "
            "were experimenting on military prisoners in the FEV project vats. Maxson took command, broadcast his garrison's secession over the radio, "
            "and after the nuclear holocaust led his soldiers and their families across the desert to the Lost Hills bunker, founding the Brotherhood of Steel."
        ),
    },
    {
        "name": "v13_radio_dj_18",
        "sndr_fid": 0x01008612,
        "edid": "SNDRV13RadioDJ18",
        "tts": (
            "High tension in the Los Angeles Boneyard: behind the razor wire of Adytum, Mayor Jon Zimmerman remains blinded by the lies of Caleb "
            "and his Regulator militia. The Regulators accuse Razor and the Blades gang of murdering Zimmerman's son, "
            "yet everyone in the northern ruins knows Caleb staged the killing to keep Adytum's citizens working like slaves "
            "in the lead foundry. Word is the Gun Runners are only waiting for a spark to arm the Blades and liberate the town."
        ),
    },
    {
        "name": "v13_radio_dj_19",
        "sndr_fid": 0x01008613,
        "edid": "SNDRV13RadioDJ19",
        "tts": (
            "Intelligence reports from the north have put a name and face to the military commander of the mutant army: they call him The Lieutenant, "
            "though escaped prisoners know him as Lou. A former pre-war officer transformed by the Forced Evolutionary Virus, "
            "he pairs refined manners and cruel wit with monstrous strength. From the interrogation chambers of Mariposa Military Base "
            "he tortures captured scouts with a single obsession: tearing the exact coordinates of Vault Thirteen from their minds."
        ),
    },
    {
        "name": "v13_radio_dj_20",
        "sndr_fid": 0x01008614,
        "edid": "SNDRV13RadioDJ20",
        "tts": (
            "In the basement of the Boneyard library, under the protection of Nicole and the Followers of the Apocalypse, hides a living witness "
            "to the horror of Mariposa: his name is Talius. Once a human scout captured by northern patrols and exposed to the mutagenic virus, "
            "his transformation was left incomplete, turning him into a tormented creature who still keeps his human memories and an old flaming torch. "
            "His testimony confirms that the Children of the Cathedral and the Super Mutants of Mariposa serve the exact same master."
        ),
    },
    {
        "name": "v13_radio_dj_21",
        "sndr_fid": 0x01008615,
        "edid": "SNDRV13RadioDJ21",
        "tts": (
            "A look at the economic pulse of The Hub: while Martha Rastello and the Water Merchants council debate whether to dispatch relief caravans "
            "to the northern vaults — even at the risk of mutant spies tracking the wagon ruts across the desert — "
            "Butch Harris and his right-hand man Rutger at the Far Go Traders are desperately seeking someone to investigate their missing convoys. "
            "And if you need serious firepower before leaving town, stop by old Jacob's armory in Old Town or Beth's weapon shop."
        ),
    },
    {
        "name": "v13_radio_dj_22",
        "sndr_fid": 0x01008616,
        "edid": "SNDRV13RadioDJ22",
        "tts": (
            "Those who have managed to infiltrate beneath the southern Cathedral, past the chambers of High Priest Morpheus and Nightkin commander Lasher, "
            "speak of an old Vault-Tec demonstration vault rebuilt into a biological lair. They warn that the corridor leading to the central chamber "
            "is saturated by a lethal psychic wave that triggers hallucinations and shatters the mind of any intruder... "
            "unless you wear the strange psychic nullifier headset guarded by Gideon beside the vault's psychic prisoners."
        ),
    },
    {
        "name": "v13_radio_dj_23",
        "sndr_fid": 0x01008617,
        "edid": "SNDRV13RadioDJ23",
        "tts": (
            "We wrap up our round of curiosities with the wildest campfire tales from our caravan drivers. "
            "Some swear they stumbled across the fossilized footprint of a giant dinosaur out on the salt flats; others claim they watched "
            "an old blue British police call box vanish into thin air with a temporal wheeze; and a southern prospector brags "
            "about finding an overturned Nuka-Cola truck packed with thousands of intact bottle caps, and even a crashed flying saucer holding an otherworldly energy blaster. "
            "Just another day in the California desert... right here on The Hub Radio."
        ),
    },
    {
        "name": "v13_radio_dj_24",
        "sndr_fid": 0x01008618,
        "edid": "SNDRV13RadioDJ24",
        "tts": (
            "Night falls over the dunes of New California, and we're still with you at eighty-four point five on The Hub Radio. "
            "Sometimes you have to wonder about that lone dweller who walked out of Vault Thirteen with one hundred and fifty days to save his people from thirst, "
            "and now carries the war against the Mariposa vats and the horror beneath the Cathedral on his shoulders. "
            "When a hero walks through all the hell of the wasteland to save his home, can he ever lock himself back behind a steel door, "
            "or will Overseer Jacoren be too afraid that everyone else will follow his footsteps? Good night, wanderers... and good luck out there."
        ),
    },
    {
        "name": "v13_radio_dj_25",
        "sndr_fid": 0x01008619,
        "edid": "SNDRV13RadioDJ25",
        "tts": (
            "And now, wanderers, a very special story brought in from the campfires along the central trail north of the Hub. "
            "Caravan guards tell of a lone traveler who camps among the dunes by the name of Patrick the Celt: "
            "the last wandering bard of an Irish lineage that crossed the ocean before the world burned, "
            "passing down from father to son the ancient Gaelic ballads of Eire. "
            "Those who have sat beside his fire swear that hearing him sing at nightfall tempers the spirit and renews your courage to keep walking. "
            "Here is the recording one of our scouts brought back to the Great Water Tower: "
            "Patrick the Celt performing the Ballad of Na Fianna, The Wanderer of Vault Thirteen."
        ),
    },
]


def clean_tts_text_en(txt: str) -> str:
    """Prepare subtitle text for natural English TTS pronunciation."""
    t = txt.replace("\r\n", " ").replace("\n", " ").strip()
    t = re.sub(r"\.223\b", "two-two-three", t)
    t = re.sub(r"\b10mm\b", "ten millimeter", t)
    t = re.sub(r"\b10 mm\b", "ten millimeter", t)
    t = re.sub(r"\bVault 13\b", "Vault Thirteen", t)
    t = re.sub(r"\bVault 15\b", "Vault Fifteen", t)
    t = re.sub(r"\bVault 12\b", "Vault Twelve", t)
    t = re.sub(r"\b2161\b", "twenty-one sixty-one", t)
    t = re.sub(r"\b2162\b", "twenty-one sixty-two", t)
    t = re.sub(r"\b2141\b", "twenty-one forty-one", t)
    t = re.sub(r"\b2142\b", "twenty-one forty-two", t)
    t = re.sub(r"\b2127\b", "twenty-one twenty-seven", t)
    t = re.sub(r"\b2102\b", "twenty-one oh-two", t)
    t = re.sub(r"\b2077\b", "twenty seventy-seven", t)
    t = re.sub(r"\b2287\b", "twenty-two eighty-seven", t)
    return t


def synthesize_clip_worker(task: tuple) -> str:
    api_key, vtyp_edid, voice_id, low_fid, resp_idx, tts_text = task
    vtyp_cache_dir = os.path.join(VOICES_EN_DIR, vtyp_edid)
    os.makedirs(vtyp_cache_dir, exist_ok=True)

    fname_base = f"{low_fid:08X}_{resp_idx}"
    mp3_path = os.path.join(vtyp_cache_dir, f"{fname_base}.mp3")
    wav_path = os.path.join(vtyp_cache_dir, f"{fname_base}.wav")
    xwm_path = os.path.join(vtyp_cache_dir, f"{fname_base}.xwm")
    txt_cache = os.path.join(vtyp_cache_dir, f"{fname_base}.txt")

    sfx_mix_FNAME_SET = {
        "00005033_1",
        "00005031_1",
        "00005030_1",
        "00005035_1",
        "00005015_1",
        "00005032_1",
    }
    cache_sig = f"{tts_text}|sfx_mix_v2" if fname_base in sfx_mix_FNAME_SET else tts_text

    if os.path.exists(xwm_path) and os.path.getsize(xwm_path) > 100:
        return fname_base

    # Synthesize MP3 via ElevenLabs with retry
    if not os.path.exists(mp3_path) or os.path.getsize(mp3_path) < 100:
        url = f"https://api.elevenlabs.io/v1/text-to-speech/{voice_id}?output_format=mp3_44100_128"
        payload = {
            "text": clean_tts_text_en(tts_text),
            "model_id": "eleven_turbo_v2_5",
            "voice_settings": {
                "stability": 0.60,
                "similarity_boost": 0.82,
                "style": 0.16,
                "use_speaker_boost": True,
            },
        }
        for attempt in range(4):
            try:
                req = urllib.request.Request(
                    url,
                    data=json.dumps(payload).encode("utf-8"),
                    headers={
                        "xi-api-key": api_key,
                        "Content-Type": "application/json",
                        "Accept": "audio/mpeg",
                    },
                    method="POST",
                )
                with urllib.request.urlopen(req, timeout=60) as resp:
                    with open(mp3_path, "wb") as wf:
                        wf.write(resp.read())
                break
            except Exception as e:
                if attempt == 3:
                    raise
                time.sleep(1.5 * (attempt + 1))

    s_turb = os.path.join(SFX_DIR, "sfx_water_turbine_startup.mp3")
    s_cheer = os.path.join(SFX_DIR, "sfx_vault_residents_cheer.mp3")
    s_pump = os.path.join(SFX_DIR, "sfx_necropolis_pump_repair.mp3")

    if fname_base in ("00005033_1", "00005031_1", "00005030_1", "00005035_1") and os.path.exists(s_turb) and os.path.exists(s_cheer):
        if fname_base == "00005033_1":
            fc = (
                "[0:a]highpass=f=85,lowpass=f=7800,acompressor=threshold=-16dB:ratio=2.5:makeup=4dB,volume=1.55,adelay=1500|1500[v];"
                "[1:a]volume=1.40[t];"
                "[2:a]adelay=1100|1100,volume=1.30[c];"
                "[v][t][c]amix=inputs=3:duration=longest:dropout_transition=0:normalize=0,alimiter=limit=0.96"
            )
        elif fname_base in ("00005031_1", "00005030_1"):
            fc = (
                "[0:a]highpass=f=85,lowpass=f=7800,acompressor=threshold=-16dB:ratio=2.5:makeup=4dB,volume=1.55,adelay=550|550[v];"
                "[1:a]volume=0.90[t];"
                "[2:a]volume=1.35[c];"
                "[v][t][c]amix=inputs=3:duration=longest:dropout_transition=0:normalize=0,alimiter=limit=0.96"
            )
        else:
            fc = (
                "[0:a]highpass=f=85,lowpass=f=7800,acompressor=threshold=-16dB:ratio=2.5:makeup=4dB,volume=1.55,adelay=400|400[v];"
                "[1:a]volume=1.05[t];"
                "[2:a]volume=1.15[c];"
                "[v][t][c]amix=inputs=3:duration=longest:dropout_transition=0:normalize=0,alimiter=limit=0.96"
            )
        subprocess.run(
            [
                FFMPEG_BIN, "-y", "-loglevel", "error",
                "-i", mp3_path, "-i", s_turb, "-i", s_cheer,
                "-filter_complex", fc,
                "-bitexact", "-map_metadata", "-1",
                "-ar", "44100", "-ac", "1", "-sample_fmt", "s16",
                wav_path,
            ],
            check=True,
        )
    elif fname_base == "00005015_1" and os.path.exists(s_turb):
        fc = (
            "[0:a]highpass=f=85,lowpass=f=7800,acompressor=threshold=-16dB:ratio=2.5:makeup=4dB,volume=1.55[v];"
            "[1:a]volume=0.95[t];"
            "[v][t]amix=inputs=2:duration=first:dropout_transition=0:normalize=0,alimiter=limit=0.96"
        )
        subprocess.run(
            [
                FFMPEG_BIN, "-y", "-loglevel", "error",
                "-i", mp3_path, "-i", s_turb,
                "-filter_complex", fc,
                "-bitexact", "-map_metadata", "-1",
                "-ar", "44100", "-ac", "1", "-sample_fmt", "s16",
                wav_path,
            ],
            check=True,
        )
    elif fname_base == "00005032_1" and os.path.exists(s_pump):
        fc = (
            "[0:a]highpass=f=85,lowpass=f=7800,acompressor=threshold=-16dB:ratio=2.5:makeup=4dB,volume=1.55,adelay=1100|1100[v];"
            "[1:a]volume=1.35[p];"
            "[v][p]amix=inputs=2:duration=longest:dropout_transition=0:normalize=0,alimiter=limit=0.96"
        )
        subprocess.run(
            [
                FFMPEG_BIN, "-y", "-loglevel", "error",
                "-i", mp3_path, "-i", s_pump,
                "-filter_complex", fc,
                "-bitexact", "-map_metadata", "-1",
                "-ar", "44100", "-ac", "1", "-sample_fmt", "s16",
                wav_path,
            ],
            check=True,
        )
    else:
        if vtyp_edid in ("CrSuperMutant", "V13HarrySuperMutantVoice"):
            af_filter = (
                "asetrate=44100*0.80,aresample=44100,atempo=1.18,"
                "highpass=f=60,lowpass=f=6500,"
                "acompressor=threshold=-16dB:ratio=3.0:makeup=4dB,volume=1.35"
            )
        else:
            af_filter = (
                "highpass=f=85,lowpass=f=7800,"
                "acompressor=threshold=-16dB:ratio=2.5:makeup=3dB,volume=1.25"
            )
        subprocess.run(
            [
                FFMPEG_BIN, "-y", "-loglevel", "error",
                "-i", mp3_path,
                "-af", af_filter,
                "-bitexact", "-map_metadata", "-1",
                "-ar", "44100", "-ac", "1", "-sample_fmt", "s16",
                wav_path,
            ],
            check=True,
        )

    subprocess.run(
        [XWMAENCODE_BIN, "-b", "48000", wav_path, xwm_path],
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    with open(txt_cache, "w", encoding="utf-8") as tf:
        tf.write(cache_sig)
    return fname_base


def synthesize_radio_dj_en(api_key: str) -> None:
    os.makedirs(RADIO_DJ_EN_DIR, exist_ok=True)
    dj_filter_ver = "v2_loud"
    for dj in V13_RADIO_DJ_DEFS_EN:
        fname = dj["name"]
        tts_text = dj["tts"]
        cache_key = f"{tts_text}|{dj_filter_ver}"
        mp3_path = os.path.join(RADIO_DJ_EN_DIR, f"{fname}.mp3")
        wav_path = os.path.join(RADIO_DJ_EN_DIR, f"{fname}.wav")
        xwm_path = os.path.join(RADIO_DJ_EN_DIR, f"{fname}.xwm")
        txt_cache = os.path.join(RADIO_DJ_EN_DIR, f"{fname}.txt")

        cached_txt = None
        if os.path.exists(txt_cache):
            with open(txt_cache, "r", encoding="utf-8") as tf:
                cached_txt = tf.read()

        if not os.path.exists(xwm_path) or cached_txt != cache_key:
            if not os.path.exists(mp3_path) or cached_txt != cache_key:
                print(f"  [ElevenLabs EN Radio DJ] {fname}: {tts_text[:68]}...")
                url = f"https://api.elevenlabs.io/v1/text-to-speech/{RADIO_DJ_VOICE_ID}?output_format=mp3_44100_128"
                payload = {
                    "text": tts_text,
                    "model_id": "eleven_turbo_v2_5",
                    "voice_settings": {
                        "stability": 0.58,
                        "similarity_boost": 0.82,
                        "style": 0.28,
                        "use_speaker_boost": True,
                    },
                }
                req = urllib.request.Request(
                    url,
                    data=json.dumps(payload).encode("utf-8"),
                    headers={
                        "xi-api-key": api_key,
                        "Content-Type": "application/json",
                        "Accept": "audio/mpeg",
                    },
                    method="POST",
                )
                with urllib.request.urlopen(req, timeout=90) as resp:
                    with open(mp3_path, "wb") as wf:
                        wf.write(resp.read())

            af_radio_dj = (
                "highpass=f=140,lowpass=f=5600,"
                "acompressor=threshold=-20dB:ratio=4.0:makeup=7dB,"
                "alimiter=limit=0.96,volume=1.55"
            )
            subprocess.run(
                [
                    FFMPEG_BIN, "-y", "-loglevel", "error",
                    "-i", mp3_path, "-af", af_radio_dj,
                    "-ar", "44100", "-ac", "1", "-sample_fmt", "s16",
                    wav_path,
                ],
                check=True,
            )
            subprocess.run(
                [XWMAENCODE_BIN, "-b", "48000", wav_path, xwm_path],
                check=True,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            with open(txt_cache, "w", encoding="utf-8") as tf:
                tf.write(cache_key)


def main() -> None:
    api_key = es_builder.load_api_key()
    with open(os.path.join(THIS_DIR, "translations_en.json"), "r", encoding="utf-8") as f:
        trans = json.load(f)

    # Extract NAM1 from Spanish ESP by (low_fid, resp_idx) -> English text
    with open(os.path.join(ROOT_DIR, "build_out", "Vault13Chronicles.esp"), "rb") as f:
        esp_bytes = f.read()

    info_nam1_en: dict[tuple[int, int], str] = {}

    def walk(buf: bytes, start: int, end: int) -> None:
        pos = start
        while pos < end:
            rt = buf[pos : pos + 4]
            if rt == b"GRUP":
                gsz = struct.unpack_from("<I", buf, pos + 4)[0]
                walk(buf, pos + 24, pos + gsz)
                pos += gsz
            else:
                dsz, flags, fid = struct.unpack_from("<III", buf, pos + 4)
                if rt == b"INFO":
                    rdata = buf[pos + 24 : pos + 24 + dsz]
                    if flags & 0x00040000:
                        rdata = zlib.decompress(rdata[4:])
                    sp = 0
                    idx = 0
                    while sp < len(rdata):
                        st = rdata[sp : sp + 4]
                        ssz = struct.unpack_from("<H", rdata, sp + 4)[0]
                        sval = rdata[sp + 6 : sp + 6 + ssz]
                        sp += 6 + ssz
                        if st == b"NAM1":
                            idx += 1
                            txt = sval[:-1].decode("cp1252", "replace")
                            info_nam1_en[(fid & 0xFFFFFF, idx)] = trans.get(txt, txt)
                pos += 24 + dsz

    walk(esp_bytes, 0, len(esp_bytes))

    # 1. Synthesize 24 Radio DJ broadcasts
    print("=== Step 1: Synthesizing 24 English Radio DJ Broadcasts (The Hub Radio 84.5) ===")
    synthesize_radio_dj_en(api_key)

    # 2. Collect all voice clip tasks via es_builder.synthesize_all_voices hook
    print("=== Step 2: Collecting English Dialogue Voice Clip Tasks ===")
    raw_tasks: list[tuple[str, str, int, int, str]] = []

    def collect_clip(
        _api_key: str,
        vtyp_edid: str,
        _voice_id: str,
        low_fid: int,
        resp_idx: int,
        tts_text_es: str,
        ba2_voice_map: dict[str, str],
    ) -> None:
        en_txt = info_nam1_en.get((low_fid, resp_idx))
        if not en_txt:
            en_txt = trans.get(tts_text_es, tts_text_es)
        vid = VOICE_ID_MAP_EN.get(vtyp_edid, _voice_id)
        raw_tasks.append((vtyp_edid, vid, low_fid, resp_idx, en_txt))

    es_builder._synthesize_single_clip = collect_clip
    es_builder.VOICES_DIR = VOICES_EN_DIR
    es_builder.synthesize_all_voices("dummy")

    # Filter out mirrored Harry wheel duplicates (000053B0..53CE, 0000503A..503E) so we synthesize 000053A0..53AE once and copy
    mirror_skip_fids = (
        set(range(0x000053B0, 0x000053BF))
        | set(range(0x000053C0, 0x000053CF))
        | {0x0000503A, 0x0000503B, 0x0000503C, 0x0000503D, 0x0000503E}
    )

    to_synth = []
    seen_keys = set()
    for vtyp, vid, lfid, ridx, en_txt in raw_tasks:
        if lfid in mirror_skip_fids:
            continue
        # If CrSuperMutant and V13HarrySuperMutantVoice share a clip, synthesize V13HarrySuperMutantVoice once and mirror
        if vtyp == "CrSuperMutant":
            vtyp = "V13HarrySuperMutantVoice"
            vid = VOICE_ID_MAP_EN[vtyp]
        key = (vtyp, lfid, ridx)
        if key in seen_keys:
            continue
        seen_keys.add(key)
        xwm_p = os.path.join(VOICES_EN_DIR, vtyp, f"{lfid:08X}_{ridx}.xwm")
        if not os.path.exists(xwm_p) or os.path.getsize(xwm_p) < 100:
            to_synth.append((api_key, vtyp, vid, lfid, ridx, en_txt))

    print(f"Clips needing synthesis (after deduplicating mirrors): {len(to_synth)}")
    done_count = 0
    with concurrent.futures.ThreadPoolExecutor(max_workers=5) as ex:
        futures = {ex.submit(synthesize_clip_worker, t): t for t in to_synth}
        for fut in concurrent.futures.as_completed(futures):
            fname = fut.result()
            done_count += 1
            if done_count % 25 == 0 or done_count == len(to_synth):
                print(f"  [Voices EN Progress] {done_count}/{len(to_synth)} clips synthesized (latest: {fname})")

    # 3. Perform all mirror copies (Jacoren 00004013_1 -> 00004015_1, Harry wheel mirrors, CrSuperMutant <-> V13HarrySuperMutantVoice, resident helo_act2/3)
    jac_dir = os.path.join(VOICES_EN_DIR, "NPCMOverseerJacoren")
    for ext in (".mp3", ".wav", ".xwm", ".txt"):
        sp = os.path.join(jac_dir, f"00004013_1{ext}")
        dp = os.path.join(jac_dir, f"00004015_1{ext}")
        if os.path.exists(sp) and not os.path.exists(dp):
            shutil.copy2(sp, dp)

    harry_dir = os.path.join(VOICES_EN_DIR, "V13HarrySuperMutantVoice")
    sm_dir = os.path.join(VOICES_EN_DIR, "CrSuperMutant")
    os.makedirs(harry_dir, exist_ok=True)
    os.makedirs(sm_dir, exist_ok=True)

    for v_folder, id_range in (
        ("PlayerVoiceMale01", range(0x000053A0, 0x000053A4)),
        ("PlayerVoiceFemale01", range(0x000053A4, 0x000053A8)),
        ("V13HarrySuperMutantVoice", range(0x000053A8, 0x000053AF)),
    ):
        vf_dir = os.path.join(VOICES_EN_DIR, v_folder)
        for src_id in id_range:
            for offset_val in (0x10, 0x20):
                dst_id = src_id + offset_val
                for ext in (".mp3", ".wav", ".xwm", ".txt"):
                    s_p = os.path.join(vf_dir, f"{src_id:08X}_1{ext}")
                    d_p = os.path.join(vf_dir, f"{dst_id:08X}_1{ext}")
                    if os.path.exists(s_p):
                        shutil.copy2(s_p, d_p)

    for src_id, dst_id in (
        (0x000053A8, 0x0000503A),
        (0x000053A9, 0x0000503B),
        (0x000053AA, 0x0000503C),
        (0x000053AB, 0x0000503D),
        (0x000053AE, 0x0000503E),
    ):
        for ext in (".mp3", ".wav", ".xwm", ".txt"):
            s_p = os.path.join(harry_dir, f"{src_id:08X}_1{ext}")
            d_p = os.path.join(harry_dir, f"{dst_id:08X}_1{ext}")
            if os.path.exists(s_p):
                shutil.copy2(s_p, d_p)

    # Mirror V13HarrySuperMutantVoice <-> CrSuperMutant
    for fn in os.listdir(harry_dir):
        s_p = os.path.join(harry_dir, fn)
        d_p = os.path.join(sm_dir, fn)
        if os.path.isfile(s_p):
            shutil.copy2(s_p, d_p)

    # Mirror V13_RESIDENT_DEFS helo_act2_fid and helo_act3_fid
    for rdef in es_builder.V13_RESIDENT_DEFS:
        v_edid = rdef["vtyp_edid"]
        v_cache_dir = os.path.join(VOICES_EN_DIR, v_edid)
        h_base_low = rdef["helo_info_fid"] & 0x00FFFFFF
        for h_copy_key in ("helo_act2_fid", "helo_act3_fid"):
            h_low = rdef[h_copy_key] & 0x00FFFFFF
            for ext in (".mp3", ".wav", ".xwm", ".txt"):
                s_p = os.path.join(v_cache_dir, f"{h_base_low:08X}_1{ext}")
                d_p = os.path.join(v_cache_dir, f"{h_low:08X}_1{ext}")
                if os.path.exists(s_p):
                    shutil.copy2(s_p, d_p)

    # Generate 0.05s silent audio clip 0000407F_1 for DIAL 0x01004003 (V13Act1ResidentStopTopic)
    stop_fname = "0000407F_1"
    for stop_vtyp in (
        "NPCMVault13Resident",
        "NPCFVault13Resident",
        "NPCMOverseerJacoren",
        "NPCMUndergroundLeader",
        "NPCMSetNecropolis",
    ):
        stop_vdir = os.path.join(VOICES_EN_DIR, stop_vtyp)
        os.makedirs(stop_vdir, exist_ok=True)
        stop_wav = os.path.join(stop_vdir, f"{stop_fname}.wav")
        stop_xwm = os.path.join(stop_vdir, f"{stop_fname}.xwm")
        if not os.path.exists(stop_xwm):
            with wave.open(stop_wav, "wb") as wf:
                wf.setnchannels(1)
                wf.setsampwidth(2)
                wf.setframerate(44100)
                wf.writeframes(b"\x00\x00" * 2205)
            subprocess.run(
                [XWMAENCODE_BIN, "-b", "48000", stop_wav, stop_xwm],
                check=True,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )

    print("=== Step 3: All English Voices and Radio DJ Tracks Synthesized Successfully! ===")


if __name__ == "__main__":
    main()
