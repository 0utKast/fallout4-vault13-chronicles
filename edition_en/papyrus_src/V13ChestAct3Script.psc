Scriptname V13ChestAct3Script extends ObjectReference

Event OnActivate(ObjectReference akActionRef)
    Actor player = Game.GetPlayer()
    if akActionRef == player
        Quest q = Game.GetFormFromFile(0x00006002, "Vault13Chronicles.esp") as Quest
        V13Act3QuestScript act3S = q as V13Act3QuestScript
        if act3S != None
            act3S.GrantVreeAutopsyHolodisk()
        endif
    endif
EndEvent
