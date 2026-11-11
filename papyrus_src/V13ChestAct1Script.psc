Scriptname V13ChestAct1Script extends ObjectReference

Event OnActivate(ObjectReference akActionRef)
    Actor player = Game.GetPlayer()
    if akActionRef == player
        Quest q = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as Quest
        Form hydroLog = Game.GetFormFromFile(0x00001110, "Vault13Chronicles.esp")
        Form report1 = Game.GetFormFromFile(0x00001141, "Vault13Chronicles.esp")
        if q != None && q.GetStage() >= 20 && q.GetStage() < 30
            if hydroLog != None && player.GetItemCount(hydroLog) == 0
                player.AddItem(hydroLog, 1, false)
            endif
            if report1 != None && player.GetItemCount(report1) == 0
                player.AddItem(report1, 1, false)
            endif
            q.SetStage(30)
        endif
    endif
EndEvent
