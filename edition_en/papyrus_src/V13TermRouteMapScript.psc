Scriptname V13TermRouteMapScript extends ObjectReference

Event OnActivate(ObjectReference akActionRef)
    Actor player = Game.GetPlayer()
    if akActionRef != player
        return
    endif

    Quest q1 = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as Quest
    Quest q2 = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as Quest
    Quest q3 = Game.GetFormFromFile(0x00006000, "Vault13Chronicles.esp") as Quest
    Quest q4 = Game.GetFormFromFile(0x00007000, "Vault13Chronicles.esp") as Quest
    Quest q5 = Game.GetFormFromFile(0x00008000, "Vault13Chronicles.esp") as Quest

    if q5 != None && q5.GetStage() >= 15 && q5.GetStage() < 30
        if q5.GetStage() < 20
            q5.SetStage(20)
        endif
        ObjectReference destCath = Game.GetFormFromFile(0x00002D02, "Vault13Chronicles.esp") as ObjectReference
        if destCath != None
            player.MoveTo(destCath, 0.0, 0.0, 0.0, true)
            return
        endif
    elseif q4 != None && q4.GetStage() >= 15 && q4.GetStage() < 30
        if q4.GetStage() < 20
            q4.SetStage(20)
        endif
        ObjectReference destMB = Game.GetFormFromFile(0x00002C02, "Vault13Chronicles.esp") as ObjectReference
        if destMB != None
            player.MoveTo(destMB, 0.0, 0.0, 0.0, true)
            return
        endif
    elseif q3 != None && q3.GetStage() >= 15 && q3.GetStage() < 30
        if q3.GetStage() < 20
            q3.SetStage(20)
        endif
        ObjectReference destLH = Game.GetFormFromFile(0x00002B02, "Vault13Chronicles.esp") as ObjectReference
        if destLH != None
            player.MoveTo(destLH, 0.0, 0.0, 0.0, true)
            return
        endif
    elseif q2 != None && q2.GetStage() >= 15 && q2.GetStage() < 30
        if q2.GetStage() < 20
            q2.SetStage(20)
        endif
        ObjectReference dest12 = Game.GetFormFromFile(0x00002A02, "Vault13Chronicles.esp") as ObjectReference
        if dest12 != None
            player.MoveTo(dest12, 0.0, 0.0, 0.0, true)
            return
        endif
    elseif q1 != None && q1.GetStage() >= 15 && q1.GetStage() < 30
        if q1.GetStage() < 20
            q1.SetStage(20)
        endif
        ObjectReference dest15 = Game.GetFormFromFile(0x00002502, "Vault13Chronicles.esp") as ObjectReference
        if dest15 != None
            player.MoveTo(dest15, 0.0, 0.0, 0.0, true)
            return
        endif
    endif

    ObjectReference destV13 = Game.GetFormFromFile(0x00002102, "Vault13Chronicles.esp") as ObjectReference
    if destV13 != None
        player.MoveTo(destV13, 0.0, 0.0, 0.0, true)
    endif
EndEvent
