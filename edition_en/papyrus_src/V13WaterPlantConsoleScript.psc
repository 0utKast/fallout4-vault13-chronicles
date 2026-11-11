Scriptname V13WaterPlantConsoleScript extends ObjectReference

Function RegisterConsoleTerminalEvents()
    Terminal termBase = Self.GetBaseObject() as Terminal
    if termBase != None
        UnregisterForRemoteEvent(termBase, "OnMenuItemRun")
    endif
EndFunction

Event OnInit()
    RegisterConsoleTerminalEvents()
EndEvent

Event OnLoad()
    RegisterConsoleTerminalEvents()
EndEvent

Event Terminal.OnMenuItemRun(Terminal akSender, int auiMenuItemID, ObjectReference akTerminalRef)
    ; Handled centrally by V13Act2QuestScript to prevent duplicate dispatch
EndEvent

Event OnActivate(ObjectReference akActionRef)
    Actor player = Game.GetPlayer()
    if akActionRef != player
        return
    endif

    RegisterConsoleTerminalEvents()

    Quest q2 = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as Quest
    V13Act2QuestScript act2S = q2 as V13Act2QuestScript
    if act2S != None && !act2S.IsWaterChipInstalledInPlant()
        act2S.OnWaterPlantConsoleActivated()
    endif
EndEvent
