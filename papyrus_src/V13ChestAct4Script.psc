Scriptname V13ChestAct4Script extends ObjectReference

Event OnActivate(ObjectReference akActionRef)
    Actor player = Game.GetPlayer()
    if akActionRef == player
        Quest q = Game.GetFormFromFile(0x00007000, "Vault13Chronicles.esp") as Quest
        Form mariposaCodes = Game.GetFormFromFile(0x00001114, "Vault13Chronicles.esp")
        Form report4 = Game.GetFormFromFile(0x00001144, "Vault13Chronicles.esp")
        if q != None && q.GetStage() >= 20 && q.GetStage() < 30
            if mariposaCodes != None && player.GetItemCount(mariposaCodes) == 0
                player.AddItem(mariposaCodes, 1, false)
            endif
            if report4 != None && player.GetItemCount(report4) == 0
                player.AddItem(report4, 1, false)
            endif
            q.SetStage(30)
        endif
    endif
EndEvent
