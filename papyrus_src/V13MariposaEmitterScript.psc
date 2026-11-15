Scriptname V13MariposaEmitterScript extends ObjectReference

Event OnActivate(ObjectReference akActionRef)
    if akActionRef == Game.GetPlayer()
        V13Act4QuestScript act4S = Game.GetFormFromFile(0x00007000, "Vault13Chronicles.esp") as V13Act4QuestScript
        if act4S != None
            act4S.HandleForcefieldEmitterActivate(Self)
        endif
    endif
EndEvent
