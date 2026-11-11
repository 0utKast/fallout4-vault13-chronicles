Scriptname V13ItemPumpPartsScript extends ObjectReference

Event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)
    if akNewContainer == Game.GetPlayer()
        Quest q2 = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as Quest
        V13Act2QuestScript act2S = q2 as V13Act2QuestScript
        if act2S != None
            act2S.OnPumpPartsRecovered()
        endif
    endif
EndEvent
