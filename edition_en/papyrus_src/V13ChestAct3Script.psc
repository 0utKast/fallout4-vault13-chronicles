Scriptname V13ChestAct3Script extends ObjectReference

Event OnActivate(ObjectReference akActionRef)
    Actor player = Game.GetPlayer()
    if akActionRef == player
        Quest q = Game.GetFormFromFile(0x00006000, "Vault13Chronicles.esp") as Quest
        Form vreeHolo = Game.GetFormFromFile(0x00001113, "Vault13Chronicles.esp")
        Form report3 = Game.GetFormFromFile(0x00001143, "Vault13Chronicles.esp")
        if q != None && q.GetStage() >= 20 && q.GetStage() < 30
            if vreeHolo != None && player.GetItemCount(vreeHolo) == 0
                player.AddItem(vreeHolo, 1, false)
            endif
            if report3 != None && player.GetItemCount(report3) == 0
                player.AddItem(report3, 1, false)
            endif
            q.SetStage(30)
        endif
    endif
EndEvent
