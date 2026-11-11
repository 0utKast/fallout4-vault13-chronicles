Scriptname V13TermVault15Script extends ObjectReference

bool bHydroExtracted = false

Event OnActivate(ObjectReference akActionRef)
    if bHydroExtracted
        return
    endif
    Actor player = Game.GetPlayer()
    if akActionRef == player
        bHydroExtracted = true
        Quest q1 = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as Quest
        Form hydroLog = Game.GetFormFromFile(0x00001110, "Vault13Chronicles.esp")
        Form report1 = Game.GetFormFromFile(0x00001141, "Vault13Chronicles.esp")
        if q1 != None && q1.GetStage() >= 20 && q1.GetStage() < 30
            if hydroLog != None && player.GetItemCount(hydroLog) == 0
                player.AddItem(hydroLog, 1, false)
            endif
            if report1 != None && player.GetItemCount(report1) == 0
                player.AddItem(report1, 1, false)
            endif
            q1.SetStage(30)
            Debug.Notification("[Computadora del Refugio 15] ¡Holocinta Hidrológica del Refugio 15 extraída! Regresa al Refugio 13.")
        else
            bHydroExtracted = false
        endif
    endif
EndEvent
