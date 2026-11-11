Scriptname V13TermMariposaScript extends ObjectReference

bool bArmed = False

Event OnActivate(ObjectReference akActionRef)
    if bArmed
        return
    endif
    Actor player = Game.GetPlayer()
    if akActionRef == player
        bArmed = True
        Quest q4 = Game.GetFormFromFile(0x00007000, "Vault13Chronicles.esp") as Quest
        Form mariposaCodes = Game.GetFormFromFile(0x00001114, "Vault13Chronicles.esp")
        Form report4 = Game.GetFormFromFile(0x00001144, "Vault13Chronicles.esp")
        if q4 != None && q4.GetStage() >= 20 && q4.GetStage() < 30
            if mariposaCodes != None && player.GetItemCount(mariposaCodes) == 0
                player.AddItem(mariposaCodes, 1, false)
            endif
            if report4 != None && player.GetItemCount(report4) == 0
                player.AddItem(report4, 1, false)
            endif
            q4.SetStage(30)
            Debug.Notification("[Mariposa Vats Control] Self-destruct armed! FEV Codes and Psychic Nullifier acquired!")
        else
            bArmed = False
        endif
    endif
EndEvent
