Scriptname V13VindicatorEffect extends ActiveMagicEffect

Event OnEffectStart(Actor akTarget, Actor akCaster)
    V13Act5QuestScript qScript = Game.GetFormFromFile(0x00008000, "Vault13Chronicles.esp") as V13Act5QuestScript
    if qScript != None
        qScript.ProcessVindicatorHit(akTarget, akCaster)
    endif
EndEvent
