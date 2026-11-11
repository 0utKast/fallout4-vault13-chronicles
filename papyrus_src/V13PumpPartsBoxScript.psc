Scriptname V13PumpPartsBoxScript extends ObjectReference

Function SetupBoxFilters()
    Self.RemoveAllInventoryEventFilters()
    Form pumpParts = Game.GetFormFromFile(0x0000111D, "Vault13Chronicles.esp")
    if pumpParts != None
        Self.AddInventoryEventFilter(pumpParts)
    endif
EndFunction

Event OnInit()
    SetupBoxFilters()
EndEvent

Event OnReset()
    SetupBoxFilters()
EndEvent

Event OnLoad()
    SetupBoxFilters()
EndEvent

Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
    Actor player = Game.GetPlayer()
    if akDestContainer == player
        Quest q2 = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as Quest
        V13Act2QuestScript act2S = q2 as V13Act2QuestScript
        if act2S != None
            act2S.OnPumpPartsRecovered()
        elseif q2 != None && q2.GetStage() >= 20 && q2.GetStage() < 25
            q2.SetStage(25)
        endif
    endif
EndEvent

Event OnOpen(ObjectReference akActionRef)
    Actor player = Game.GetPlayer()
    if akActionRef == player
        SetupBoxFilters()
        Quest q2 = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as Quest
        V13Act2QuestScript act2S = q2 as V13Act2QuestScript
        if act2S != None && !act2S.IsNecropolisPumpRepaired()
            act2S.OnPumpPartsRecovered()
        endif
    endif
EndEvent

Event OnActivate(ObjectReference akActionRef)
    Actor player = Game.GetPlayer()
    if akActionRef == player
        SetupBoxFilters()
        Quest q2 = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as Quest
        V13Act2QuestScript act2S = q2 as V13Act2QuestScript
        Form pumpParts = Game.GetFormFromFile(0x0000111D, "Vault13Chronicles.esp")
        if act2S != None && !act2S.IsNecropolisPumpRepaired()
            if pumpParts != None && player.GetItemCount(pumpParts) == 0
                player.AddItem(pumpParts, 1, false)
            endif
            act2S.OnPumpPartsRecovered()
        elseif q2 != None && q2.GetStage() >= 20 && q2.GetStage() < 26
            if pumpParts != None && player.GetItemCount(pumpParts) == 0
                player.AddItem(pumpParts, 1, false)
            endif
            if q2.GetStage() < 25
                q2.SetStage(25)
            endif
        endif
    endif
EndEvent
