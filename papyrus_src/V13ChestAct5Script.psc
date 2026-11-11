Scriptname V13ChestAct5Script extends ObjectReference

Event OnActivate(ObjectReference akActionRef)
    Actor player = Game.GetPlayer()
    if akActionRef == player
        Quest q = Game.GetFormFromFile(0x00008000, "Vault13Chronicles.esp") as Quest
        Form masterCore = Game.GetFormFromFile(0x00001115, "Vault13Chronicles.esp")
        Form report5 = Game.GetFormFromFile(0x00001145, "Vault13Chronicles.esp")
        if q != None && q.GetStage() >= 20 && q.GetStage() < 30
            if masterCore != None && player.GetItemCount(masterCore) == 0
                player.AddItem(masterCore, 1, false)
            endif
            if report5 != None && player.GetItemCount(report5) == 0
                player.AddItem(report5, 1, false)
            endif
            q.SetStage(30)
        endif
    endif
EndEvent
