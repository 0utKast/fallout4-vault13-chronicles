Scriptname V13TandiCellReleaseScript extends ObjectReference

bool bActivating = False

Event OnActivate(ObjectReference akActionRef)
    If bActivating
        Return
    EndIf
    bActivating = True
    Actor player = Game.GetPlayer()
    If akActionRef != player
        bActivating = False
        Return
    EndIf

    Quest rescueQ = Game.GetFormFromFile(0x00018000, "Vault13Chronicles.esp") as Quest
    If rescueQ == None
        bActivating = False
        Return
    EndIf

    int st = rescueQ.GetStage()
    If st >= 30
        Debug.Notification("The holding cell latch is already unlocked and Tandi has returned to Shady Sands.")
        bActivating = False
        Return
    EndIf

    If !rescueQ.IsRunning() || st < 15
        Debug.Notification("Khan holding cell latch. There is no prisoner chained here.")
        bActivating = False
        Return
    EndIf

    Form keyForm = Game.GetFormFromFile(0x0001459, "Vault13Chronicles.esp")
    Form bobbyPin = Game.GetFormFromFile(0x0000000A, "Fallout4.esm")
    Actor petrox = Game.GetFormFromFile(0x000035D8, "Vault13Chronicles.esp") as Actor

    If keyForm != None && player.GetItemCount(keyForm) > 0
        Debug.Notification("You unlock the shackles with Petrox's key and free Tandi.")
    ElseIf petrox != None && petrox.IsDead()
        Debug.Notification("You break open the cell latch after defeating the kidnappers and free Tandi.")
    ElseIf bobbyPin != None && player.GetItemCount(bobbyPin) > 0
        Debug.Notification("[Lockpick / Stealth] You pick the cell latch with a bobby pin and quietly free Tandi.")
    Else
        Debug.Notification("[Strength / Stealth] You wrench the rusted cell bolt free and release Tandi.")
    EndIf

    If st < 26
        rescueQ.SetStage(29)
    Else
        rescueQ.SetStage(30)
    EndIf
    bActivating = False
EndEvent
