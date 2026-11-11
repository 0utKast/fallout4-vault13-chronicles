Scriptname V13TermMasterScript extends ObjectReference

bool bMasterMenuBusy = False

Event OnActivate(ObjectReference akActionRef)
    if bMasterMenuBusy
        return
    endif
    Actor player = Game.GetPlayer()
    if akActionRef != player
        return
    endif
    bMasterMenuBusy = True

    Quest q5 = Game.GetFormFromFile(0x00008000, "Vault13Chronicles.esp") as Quest
    Actor theMaster = Game.GetFormFromFile(0x00002D11, "Vault13Chronicles.esp") as Actor
    Actor morpheus = Game.GetFormFromFile(0x00002D12, "Vault13Chronicles.esp") as Actor
    Actor praet1 = Game.GetFormFromFile(0x00002D20, "Vault13Chronicles.esp") as Actor
    Actor praet2 = Game.GetFormFromFile(0x00002D21, "Vault13Chronicles.esp") as Actor
    Form masterCore = Game.GetFormFromFile(0x00001115, "Vault13Chronicles.esp")
    Form report5 = Game.GetFormFromFile(0x00001145, "Vault13Chronicles.esp")
    Form pulseExpl = Game.GetFormFromFile(0x000C32DA, "Fallout4.esm")

    Utility.Wait(0.8)

    Message masterMenu = Game.GetFormFromFile(0x00001159, "Vault13Chronicles.esp") as Message
    if masterMenu != None
        int choice = masterMenu.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        if choice == 0
            if theMaster != None && !theMaster.IsDead()
                if pulseExpl != None
                    theMaster.PlaceAtMe(pulseExpl, 1, false, false)
                endif
                theMaster.KillEssential(None)
            endif
            if morpheus != None && !morpheus.IsDead()
                morpheus.Kill(None)
            endif
            if praet1 != None && !praet1.IsDead()
                praet1.Kill(None)
            endif
            if praet2 != None && !praet2.IsDead()
                praet2.Kill(None)
            endif
            player.StopCombatAlarm()
            if masterCore != None && player.GetItemCount(masterCore) == 0
                player.AddItem(masterCore, 1, false)
            endif
            if report5 != None && player.GetItemCount(report5) == 0
                player.AddItem(report5, 1, false)
            endif
            if q5 != None && q5.GetStage() < 30
                q5.SetStage(30)
            endif
            Debug.Notification("[The Master]: 'It cannot be... All of our mutants are sterile! Leave now, while you still have hope...'")
        elseif choice == 1
            if masterCore != None && player.GetItemCount(masterCore) == 0
                player.AddItem(masterCore, 1, false)
            endif
            if report5 != None && player.GetItemCount(report5) == 0
                player.AddItem(report5, 1, false)
            endif
            if q5 != None && q5.GetStage() < 30
                q5.SetStage(30)
            endif
            Debug.Notification("[Cathedral Warhead] Nuclear detonation core extracted! Evacuate to Vault 13!")
        endif
    endif
    bMasterMenuBusy = False
EndEvent
