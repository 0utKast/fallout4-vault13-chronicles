Scriptname V13TermNecropolisScript extends ObjectReference

Event OnActivate(ObjectReference akActionRef)
    Actor player = Game.GetPlayer()
    if akActionRef != player
        return
    endif

    V13Act2QuestScript act2S = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as V13Act2QuestScript
    if act2S != None && !act2S.IsHarryResolved()
        act2S.ShowHarryIntercomDialog()
    endif
EndEvent
