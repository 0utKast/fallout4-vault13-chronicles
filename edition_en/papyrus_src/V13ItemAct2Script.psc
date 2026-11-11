Scriptname V13ItemAct2Script extends ObjectReference

Event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)
    if akNewContainer == Game.GetPlayer()
        Quest q = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as Quest
        V13Act2QuestScript act2S = q as V13Act2QuestScript
        if act2S != None
            if !act2S.IsWaterChipInstalledInPlant()
                act2S.OnWaterChipExtracted()
            endif
        endif
    endif
EndEvent
