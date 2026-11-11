Scriptname V13ItemAct5Script extends ObjectReference

Event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)
    if akNewContainer == Game.GetPlayer()
        Quest q = Game.GetFormFromFile(0x00008000, "Vault13Chronicles.esp") as Quest
        if q != None && q.GetStage() >= 20 && q.GetStage() < 30
            q.SetStage(30)
        endif
    endif
EndEvent
