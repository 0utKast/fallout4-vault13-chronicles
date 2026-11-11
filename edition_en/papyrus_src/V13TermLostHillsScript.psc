Scriptname V13TermLostHillsScript extends ObjectReference

bool bDownloaded = False

Event OnActivate(ObjectReference akActionRef)
    if bDownloaded
        return
    endif
    Actor player = Game.GetPlayer()
    if akActionRef == player
        bDownloaded = True
        Quest q3 = Game.GetFormFromFile(0x00006000, "Vault13Chronicles.esp") as Quest
        Form vreeHolo = Game.GetFormFromFile(0x00001113, "Vault13Chronicles.esp")
        Form report3 = Game.GetFormFromFile(0x00001143, "Vault13Chronicles.esp")
        if q3 != None && q3.GetStage() >= 20 && q3.GetStage() < 30
            if vreeHolo != None && player.GetItemCount(vreeHolo) == 0
                player.AddItem(vreeHolo, 1, false)
            endif
            if report3 != None && player.GetItemCount(report3) == 0
                player.AddItem(report3, 1, false)
            endif
            q3.SetStage(30)
            Debug.Notification("[Lost Hills Computer] Scribe Vree's FEV sterility autopsy holotape downloaded!")
        else
            bDownloaded = False
        endif
    endif
EndEvent
