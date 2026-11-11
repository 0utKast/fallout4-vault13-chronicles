Scriptname V13TermWaterPlantMenuScript extends ObjectReference

Function RegisterTerminalMenuEvent()
    Terminal termBase = Self.GetBaseObject() as Terminal
    if termBase != None
        UnregisterForRemoteEvent(termBase, "OnMenuItemRun")
    endif
EndFunction

Event OnInit()
    RegisterTerminalMenuEvent()
EndEvent

Event OnLoad()
    RegisterTerminalMenuEvent()
EndEvent

Event Terminal.OnMenuItemRun(Terminal akSender, int auiMenuItemID, ObjectReference akTerminalRef)
    ; Handled centrally by V13Act2QuestScript to prevent duplicate dispatch
EndEvent
