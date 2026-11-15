Scriptname V13ItemAct5Script extends ObjectReference

Event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)
    if akNewContainer == Game.GetPlayer()
        Quest q = Game.GetFormFromFile(0x00008000, "Vault13Chronicles.esp") as Quest
        V13Act5QuestScript act5S = q as V13Act5QuestScript
        if q != None && q.GetStage() >= 20 && q.GetStage() < 30
            if act5S != None && !act5S.IsNuclearCountdownActive()
                act5S.StartCathedralNuclearCountdown(2)
            endif
        endif
    endif
EndEvent
