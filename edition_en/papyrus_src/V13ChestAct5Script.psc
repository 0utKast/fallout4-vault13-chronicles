Scriptname V13ChestAct5Script extends ObjectReference

Event OnActivate(ObjectReference akActionRef)
    Actor player = Game.GetPlayer()
    if akActionRef == player
        Quest q = Game.GetFormFromFile(0x00008000, "Vault13Chronicles.esp") as Quest
        V13Act5QuestScript act5S = q as V13Act5QuestScript
        Actor theMaster = Game.GetFormFromFile(0x00002D11, "Vault13Chronicles.esp") as Actor
        if q != None && q.GetStage() >= 20 && q.GetStage() < 30
            if theMaster != None && !theMaster.IsDead() && q.GetStage() < 26 && (act5S == None || !act5S.IsNuclearCountdownActive())
                if act5S != None
                    act5S.BeginMasterBossFight()
                endif
                Debug.Notification("[The Cathedral] The Master guards the core! Defeat or convince him before claiming the arsenal.")
                return
            endif
            Form masterCore = Game.GetFormFromFile(0x00001115, "Vault13Chronicles.esp")
            Form report5 = Game.GetFormFromFile(0x00001145, "Vault13Chronicles.esp")
            Form extraRelic = Game.GetFormFromFile(0x0000110E, "Vault13Chronicles.esp")
            if masterCore != None && player.GetItemCount(masterCore) == 0
                player.AddItem(masterCore, 1, false)
            endif
            if report5 != None && player.GetItemCount(report5) == 0
                player.AddItem(report5, 1, false)
            endif
            if extraRelic != None && player.GetItemCount(extraRelic) == 0
                player.AddItem(extraRelic, 1, false)
            endif
            if act5S != None && !act5S.IsNuclearCountdownActive()
                act5S.StartCathedralNuclearCountdown(2)
            endif
        endif
    endif
EndEvent
