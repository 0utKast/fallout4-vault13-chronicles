Scriptname V13TermMariposaSecurityScript extends ObjectReference

bool bGreyLogsDownloaded = False

Event OnActivate(ObjectReference akActionRef)
    Actor player = Game.GetPlayer()
    if akActionRef == player && player != None
        Form greyHolo = Game.GetFormFromFile(0x00001565, "Vault13Chronicles.esp")
        if greyHolo != None && player.GetItemCount(greyHolo) == 0
            player.AddItem(greyHolo, 1, false)
        endif
        V13Act4QuestScript act4S = Game.GetFormFromFile(0x00007000, "Vault13Chronicles.esp") as V13Act4QuestScript
        if act4S != None
            act4S.DeactivateMariposaSecurityGrid()
        endif
        if !bGreyLogsDownloaded
            bGreyLogsDownloaded = True
            Game.RewardPlayerXP(200, false)
            Debug.Notification("[Mariposa Security] Richard Grey's Holotape (2102) downloaded and force fields disabled! (+200 XP)")
        endif
    endif
EndEvent
