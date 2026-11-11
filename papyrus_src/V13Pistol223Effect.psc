Scriptname V13Pistol223Effect extends ActiveMagicEffect

Event OnEffectStart(Actor akTarget, Actor akCaster)
    V13Act2QuestScript qScript = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as V13Act2QuestScript
    if qScript != None
        qScript.ProcessPistol223Hit(akTarget, akCaster)
    endif
EndEvent
