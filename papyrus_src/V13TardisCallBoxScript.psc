Scriptname V13TardisCallBoxScript extends ObjectReference

Event OnActivate(ObjectReference akActionRef)
    if akActionRef != Game.GetPlayer()
        return
    endif
    Form myBase = Self.GetBaseObject()
    int qFid = 0x00015000
    if myBase == Game.GetFormFromFile(0x000011A7, "Vault13Chronicles.esp") || myBase == Game.GetFormFromFile(0x000011AB, "Vault13Chronicles.esp") || myBase == Game.GetFormFromFile(0x000011AC, "Vault13Chronicles.esp")
        qFid = 0x00016000
    elseif myBase == Game.GetFormFromFile(0x000011A8, "Vault13Chronicles.esp")
        qFid = 0x00017000
    elseif myBase == Game.GetFormFromFile(0x000011AF, "Vault13Chronicles.esp")
        qFid = 0x0001B000
    elseif myBase == Game.GetFormFromFile(0x000011B1, "Vault13Chronicles.esp")
        qFid = 0x0001C000
    elseif myBase == Game.GetFormFromFile(0x000011B5, "Vault13Chronicles.esp")
        qFid = 0x0001D000
    endif
    Quest qT = Game.GetFormFromFile(qFid, "Vault13Chronicles.esp") as Quest
    V13SideQuestTardisScript sT = qT as V13SideQuestTardisScript
    if sT != None
        sT.TriggerTardisDematerialization()
    endif
EndEvent
