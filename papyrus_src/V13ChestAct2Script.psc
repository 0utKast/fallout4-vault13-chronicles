Scriptname V13ChestAct2Script extends ObjectReference

Function SetupChestFilters()
    Self.RemoveAllInventoryEventFilters()
    Form waterChip = Game.GetFormFromFile(0x00001112, "Vault13Chronicles.esp")
    Form report2 = Game.GetFormFromFile(0x00001142, "Vault13Chronicles.esp")
    Form pistol223 = Game.GetFormFromFile(0x00001105, "Vault13Chronicles.esp")
    if waterChip != None
        Self.AddInventoryEventFilter(waterChip)
    endif
    if report2 != None
        Self.AddInventoryEventFilter(report2)
    endif
    if pistol223 != None
        Self.AddInventoryEventFilter(pistol223)
    endif
EndFunction

Event OnInit()
    SetupChestFilters()
EndEvent

Event OnReset()
    SetupChestFilters()
EndEvent

Event OnLoad()
    SetupChestFilters()
EndEvent

Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
    Actor player = Game.GetPlayer()
    if akDestContainer == player
        Quest q = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as Quest
        V13Act2QuestScript act2S = q as V13Act2QuestScript
        if act2S != None
            act2S.OnWaterChipExtracted()
        endif
    endif
EndEvent

Event OnOpen(ObjectReference akActionRef)
    Actor player = Game.GetPlayer()
    if akActionRef == player
        SetupChestFilters()
        Quest q = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as Quest
        V13Act2QuestScript act2S = q as V13Act2QuestScript
        if act2S != None
            act2S.OnWaterChipExtracted()
        endif
    endif
EndEvent

Event OnActivate(ObjectReference akActionRef)
    Actor player = Game.GetPlayer()
    if akActionRef == player
        SetupChestFilters()
        Quest q = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as Quest
        V13Act2QuestScript act2S = q as V13Act2QuestScript
        if act2S != None && !act2S.IsHarryResolved() && player.GetPositionX() < -150.0
            Self.BlockActivation(true, true)
            Debug.Notification("[Refugio 12] ¡El Supermutante Harry custodia el Procesador Central! Habla con él o derrótalo primero.")
            return
        endif
        Self.BlockActivation(false, false)
        if act2S != None
            act2S.OnWaterChipExtracted()
        endif
    endif
EndEvent
