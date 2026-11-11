Scriptname V13Colt6520Effect extends ActiveMagicEffect

Event OnEffectStart(Actor akTarget, Actor akCaster)
    V13Act1QuestScript qScript = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as V13Act1QuestScript
    if qScript != None
        qScript.ProcessColt6520Hit(akTarget, akCaster)
    endif
EndEvent
