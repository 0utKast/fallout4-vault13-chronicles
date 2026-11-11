Scriptname V13TermMnemosyneScript extends ObjectReference

Function RegisterMnemoMenuEvent()
    Terminal termBase = Self.GetBaseObject() as Terminal
    if termBase != None
        UnregisterForRemoteEvent(termBase, "OnMenuItemRun")
    endif
EndFunction

Event OnInit()
    RegisterMnemoMenuEvent()
EndEvent

Event OnLoad()
    RegisterMnemoMenuEvent()
EndEvent

Event OnActivate(ObjectReference akActionRef)
    RegisterMnemoMenuEvent()
    Actor player = Game.GetPlayer()
    if akActionRef != player
        return
    endif

    Quest q1 = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as Quest
    if q1 != None
        if !q1.IsRunning()
            q1.Start()
        endif
        if q1.GetStage() < 15
            q1.SetStage(15)
        endif
        V13Act1QuestScript act1S = q1 as V13Act1QuestScript
        if act1S != None
            act1S.RegisterPlayerEvents()
        endif
    endif

    Form v13Suit = Game.GetFormFromFile(0x00001307, "Vault13Chronicles.esp")
    if v13Suit != None && player.GetItemCount(v13Suit) == 0
        player.AddItem(v13Suit, 1, false)
    endif
EndEvent

Event Terminal.OnMenuItemRun(Terminal akSender, int auiMenuItemID, ObjectReference akTerminalRef)
    ; Handled centrally by V13Act1QuestScript and V13TermMnemosyneMenuScript to prevent triple dispatch
EndEvent
