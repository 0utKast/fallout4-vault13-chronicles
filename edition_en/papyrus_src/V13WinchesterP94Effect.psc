Scriptname V13WinchesterP94Effect extends ActiveMagicEffect

Event OnEffectStart(Actor akTarget, Actor akCaster)
    V13Act4QuestScript qScript = Game.GetFormFromFile(0x00007000, "Vault13Chronicles.esp") as V13Act4QuestScript
    if qScript != None
        qScript.ProcessWinchesterP94Hit(akTarget, akCaster)
    endif
EndEvent
