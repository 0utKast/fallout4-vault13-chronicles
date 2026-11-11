Scriptname V13Wattz2000Effect extends ActiveMagicEffect

Event OnEffectStart(Actor akTarget, Actor akCaster)
    V13Act3QuestScript qScript = Game.GetFormFromFile(0x00006000, "Vault13Chronicles.esp") as V13Act3QuestScript
    if qScript != None
        qScript.ProcessWattz2000Hit(akTarget, akCaster)
    endif
EndEvent
