Scriptname V13TermMnemosyneScript extends ObjectReference

Function RegisterMnemoMenuEvent()
    Terminal termBase = Self.GetBaseObject() as Terminal
    if termBase != None
        UnregisterForRemoteEvent(termBase, "OnMenuItemRun")
    endif
EndFunction

Function HealDisplacedMnemosyneClutter()
    if !Self.Is3DLoaded()
        return
    endif
    ObjectReference radarScr = Game.GetFormFromFile(0x000901EE, "Vault13Chronicles.esp") as ObjectReference
    if radarScr != None && !radarScr.IsDisabled()
        radarScr.DisableNoWait(false)
    endif
    ObjectReference legacyDesk = Game.GetFormFromFile(0x00090097, "Vault13Chronicles.esp") as ObjectReference
    if legacyDesk != None && !legacyDesk.IsDisabled()
        legacyDesk.DisableNoWait(false)
    endif
    ObjectReference deskRef = Game.GetFormFromFile(0x00002037, "Vault13Chronicles.esp") as ObjectReference
    if deskRef != None
        if deskRef.IsDisabled()
            deskRef.EnableNoWait(false)
        endif
        if deskRef.Is3DLoaded()
            deskRef.SetMotionType(deskRef.Motion_Keyframed, false)
            float dxD = deskRef.GetPositionX() - (-305.2216)
            float dyD = deskRef.GetPositionY() - (-1013.4984)
            float dzD = deskRef.GetPositionZ() - 0.0
            float daD = Math.Abs(deskRef.GetAngleZ() - 171.41)
            if (dxD * dxD + dyD * dyD + dzD * dzD) > 4.0 || daD > 1.5
                deskRef.SetPosition(-305.2216, -1013.4984, 0.0)
                deskRef.SetAngle(0.0, 0.0, 171.41)
            endif
        endif
    endif
    ObjectReference mnemoLounger = Game.GetFormFromFile(0x00002036, "Vault13Chronicles.esp") as ObjectReference
    if mnemoLounger != None
        if mnemoLounger.IsDisabled()
            mnemoLounger.EnableNoWait(false)
        endif
    endif
EndFunction

Event OnInit()
    RegisterMnemoMenuEvent()
EndEvent

Event OnCellAttach()
    RegisterMnemoMenuEvent()
    HealDisplacedMnemosyneClutter()
    StartTimer(0.25, 1)
EndEvent

Event OnLoad()
    RegisterMnemoMenuEvent()
    HealDisplacedMnemosyneClutter()
    StartTimer(0.25, 1)
EndEvent

Event OnTimer(int aiTimerID)
    if aiTimerID == 1
        HealDisplacedMnemosyneClutter()
    endif
EndEvent

Event OnActivate(ObjectReference akActionRef)
    RegisterMnemoMenuEvent()
    HealDisplacedMnemosyneClutter()
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
