Scriptname V13TermOverseerScript extends ObjectReference

Function RegisterOverseerTermMenuEvent()
    Terminal termBase = Self.GetBaseObject() as Terminal
    if termBase != None
        UnregisterForRemoteEvent(termBase, "OnMenuItemRun")
    endif
EndFunction

Event OnInit()
    RegisterOverseerTermMenuEvent()
EndEvent

Event OnLoad()
    RegisterOverseerTermMenuEvent()
EndEvent

Event OnActivate(ObjectReference akActionRef)
    Actor player = Game.GetPlayer()
    if akActionRef != player
        return
    endif

    RegisterOverseerTermMenuEvent()

    Form v13Suit = Game.GetFormFromFile(0x00001307, "Vault13Chronicles.esp")
    if v13Suit != None && player.GetItemCount(v13Suit) == 0
        player.AddItem(v13Suit, 1, false)
    endif
EndEvent

Event Terminal.OnMenuItemRun(Terminal akSender, int auiMenuItemID, ObjectReference akTerminalRef)
    ; Handled centrally by V13Act1QuestScript to prevent duplicate dispatch
EndEvent
