Scriptname V13TermLostHillsScript extends ObjectReference

bool bDownloaded = False

Event OnActivate(ObjectReference akActionRef)
    Actor player = Game.GetPlayer()
    if akActionRef == player
        Quest q3 = Game.GetFormFromFile(0x00006002, "Vault13Chronicles.esp") as Quest
        V13Act3QuestScript act3S = q3 as V13Act3QuestScript
        if act3S != None
            if !bDownloaded
                bDownloaded = True
                act3S.DownloadVreeAutopsyFromTerminal()
            endif
        endif
    endif
EndEvent
