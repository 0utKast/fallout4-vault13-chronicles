Scriptname V13RadscorpionNestScript extends ObjectReference

Event OnActivate(ObjectReference akActionRef)
    if akActionRef == Game.GetPlayer()
        Actor player = Game.GetPlayer()
        Form glandBase = Game.GetFormFromFile(0x00001116, "Vault13Chronicles.esp")
        if glandBase != None && player.GetItemCount(glandBase) == 0 && Self.GetItemCount(glandBase) == 0
            player.AddItem(glandBase, 1, False)
        endif
        Quest qSide = Game.GetFormFromFile(0x00009500, "Vault13Chronicles.esp") as Quest
        V13SideQuestShadySandsScript sideS = qSide as V13SideQuestShadySandsScript
        if sideS != None
            sideS.NotifyRadscorpionGlandRecovered()
        endif
    endif
EndEvent
