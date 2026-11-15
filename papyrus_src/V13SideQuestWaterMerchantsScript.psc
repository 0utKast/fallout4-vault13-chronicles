Scriptname V13SideQuestWaterMerchantsScript extends Quest

bool bWaterCaravanHired = False
bool bJacorenWaterReactionShown = False
bool bStg15Done = False
bool bStg20Done = False
bool bStg21Done = False
int sceneWaitTicks = 0

Function ForceQuestAlias(int aiAliasID, int aiFormID)
    ObjectReference targetRef = Game.GetFormFromFile(aiFormID, "Vault13Chronicles.esp") as ObjectReference
    ReferenceAlias al = Self.GetAlias(aiAliasID) as ReferenceAlias
    if al != None && targetRef != None
        if al.GetReference() != targetRef
            al.ForceRefTo(targetRef)
        endif
    endif
EndFunction

Function ClearQuestAlias(int aiAliasID)
    ReferenceAlias al = Self.GetAlias(aiAliasID) as ReferenceAlias
    if al != None && al.GetReference() != None
        al.Clear()
    endif
EndFunction

bool Function IsWaterCaravanHired()
    if bWaterCaravanHired || Self.GetStageDone(21) || Self.GetStage() >= 21
        return True
    endif
    Actor player = Game.GetPlayer()
    Form contractBase = Game.GetFormFromFile(0x0000145D, "Vault13Chronicles.esp")
    if player != None && contractBase != None && player.GetItemCount(contractBase) > 0
        bWaterCaravanHired = True
        return True
    endif
    V13SideQuestHubSyndicateScript synS = Game.GetFormFromFile(0x0001A000, "Vault13Chronicles.esp") as V13SideQuestHubSyndicateScript
    if synS != None && synS.IsWaterCaravanHired()
        bWaterCaravanHired = True
        return True
    endif
    return False
EndFunction

bool Function IsWaterChipResolved()
    Quest act1Q = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as Quest
    if act1Q != None && (act1Q.GetStageDone(40) || act1Q.GetStage() >= 40)
        return True
    endif
    return False
EndFunction

Function SyncMarthaLayout()
    Actor pWM = Game.GetPlayer()
    WorldSpace caliWM = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if pWM == None || caliWM == None || pWM.GetWorldSpace() != caliWM
        return
    endif
    ObjectReference wmTerm = Game.GetFormFromFile(0x00003633, "Vault13Chronicles.esp") as ObjectReference
    if wmTerm != None && wmTerm.IsDisabled()
        wmTerm.EnableNoWait()
    endif
    Actor marthaAct = Game.GetFormFromFile(0x000035E6, "Vault13Chronicles.esp") as Actor
    if marthaAct != None && !marthaAct.IsDead()
        if marthaAct.IsDisabled()
            marthaAct.EnableNoWait()
        endif
        if marthaAct.Is3DLoaded() && !marthaAct.IsInCombat()
            Actor plRef = Game.GetPlayer()
            bool bSafeSwap = (plRef == None || marthaAct.GetDistance(plRef) > 2200.0) && !marthaAct.IsTalking() && !marthaAct.IsInDialogueWithPlayer()
            Outfit marthaOut = Game.GetFormFromFile(0x00001033, "Vault13Chronicles.esp") as Outfit
            Form wmSuit = Game.GetFormFromFile(0x001B5F1B, "Fallout4.esm")
            Form roadGoggles = Game.GetFormFromFile(0x000E5084, "Fallout4.esm")
            if !bSafeSwap
                marthaOut = None
                roadGoggles = None
            endif
            if marthaOut != None && wmSuit != None && !marthaAct.IsEquipped(wmSuit)
                marthaAct.SetOutfit(marthaOut, False)
                if marthaAct.GetItemCount(wmSuit) == 0
                    marthaAct.AddItem(wmSuit, 1, True)
                endif
                marthaAct.EquipItem(wmSuit, False, True)
                if roadGoggles != None
                    if marthaAct.GetItemCount(roadGoggles) == 0
                        marthaAct.AddItem(roadGoggles, 1, True)
                    endif
                    marthaAct.EquipItem(roadGoggles, False, True)
                endif
            endif
            marthaAct.AllowPCDialogue(True)
            marthaAct.BlockActivation(False, False)
            if !marthaAct.IsTalking() && (Math.Abs(marthaAct.GetPositionX() + 3500.0) > 45.0 || Math.Abs(marthaAct.GetPositionY() + 15750.0) > 45.0)
                marthaAct.SetPosition(-3500.0, -15750.0, 80.0)
                marthaAct.SetAngle(0.0, 0.0, 0.0)
                marthaAct.EvaluatePackage()
            endif
        endif
    endif
EndFunction

Function FinalizeWaterMerchantsQuestCleanly()
    SetObjectiveCompleted(15, True)
    SetObjectiveCompleted(20, True)
    Self.CompleteAllObjectives()
    ClearQuestAlias(9)
    if !Self.IsCompleted()
        Self.CompleteQuest()
    endif
EndFunction

Function BindWaterMerchantsListeners(bool abRefreshLayout = True)
    Actor player = Game.GetPlayer()
    Form contractBase = Game.GetFormFromFile(0x0000145D, "Vault13Chronicles.esp")
    Self.RemoveAllInventoryEventFilters()
    if contractBase != None
        Self.AddInventoryEventFilter(contractBase)
    endif
    if player != None
        RegisterForRemoteEvent(player, "OnPlayerLoadGame")
        RegisterForRemoteEvent(player, "OnLocationChange")
        if contractBase != None
            RegisterForRemoteEvent(player as ObjectReference, "OnItemAdded")
        endif
        if !bWaterCaravanHired && contractBase != None && player.GetItemCount(contractBase) > 0
            bWaterCaravanHired = True
        endif
    endif
    if !bWaterCaravanHired
        V13SideQuestHubSyndicateScript synS = Game.GetFormFromFile(0x0001A000, "Vault13Chronicles.esp") as V13SideQuestHubSyndicateScript
        if synS != None && synS.IsWaterCaravanHired()
            bWaterCaravanHired = True
        endif
    endif
    if bWaterCaravanHired || Self.GetStage() >= 21 || Self.IsCompleted()
        FinalizeWaterMerchantsQuestCleanly()
    else
        ForceQuestAlias(9, 0x000035E6)
    endif
    ForceQuestAlias(2, 0x00003005)
    ForceQuestAlias(3, 0x00002003)
    ForceQuestAlias(5, 0x00002101)
    ForceQuestAlias(6, 0x00003501)
    ForceQuestAlias(7, 0x00002701)
    if abRefreshLayout
        SyncMarthaLayout()
    endif
    ObjectReference marthaRef = Game.GetFormFromFile(0x000035E6, "Vault13Chronicles.esp") as ObjectReference
    if marthaRef != None
        RegisterForRemoteEvent(marthaRef, "OnActivate")
    endif
EndFunction

Function HireWaterCaravanToVault13(int aiCostCaps)
    if bWaterCaravanHired
        FinalizeWaterMerchantsQuestCleanly()
        return
    endif
    bWaterCaravanHired = True
    Actor player = Game.GetPlayer()
    Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
    Form contractBase = Game.GetFormFromFile(0x0000145D, "Vault13Chronicles.esp")
    Form docBase = Game.GetFormFromFile(0x00001C85, "Vault13Chronicles.esp")
    Form pureWater = Game.GetFormFromFile(0x000366C0, "Fallout4.esm")
    if player != None
        if caps != None && aiCostCaps > 0
            int haveCaps = player.GetItemCount(caps)
            if haveCaps >= aiCostCaps
                player.RemoveItem(caps, aiCostCaps, False, None)
            elseif haveCaps > 0
                player.RemoveItem(caps, haveCaps, False, None)
            endif
        endif
        if contractBase != None && player.GetItemCount(contractBase) == 0
            player.AddItem(contractBase, 1, False)
        endif
        if docBase != None && player.GetItemCount(docBase) == 0
            player.AddItem(docBase, 1, False)
        endif
        if pureWater != None
            player.AddItem(pureWater, 10, False)
        endif
    endif
    Game.RewardPlayerXP(250)
    if IsWaterChipResolved()
        Debug.Notification("¡Caravana de los Mercaderes del Agua enviada al Refugio 13! (Suministro estratégico asegurado, +10 Aguas Purificadas y +250 XP)")
    else
        Debug.Notification("¡Caravana de los Mercaderes del Agua enviada al Refugio 13! (+100 días de reserva de agua, +10 Aguas Purificadas y +250 XP)")
    endif
    FinalizeWaterMerchantsQuestCleanly()
EndFunction

Event OnInit()
    BindWaterMerchantsListeners(False)
    Actor player = Game.GetPlayer()
    WorldSpace caliWorld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if player != None && caliWorld != None && player.GetWorldSpace() == caliWorld
        StartTimer(2.5, 822)
    endif
EndEvent

Event OnQuestInit()
    BindWaterMerchantsListeners(False)
    Actor player = Game.GetPlayer()
    WorldSpace caliWorld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if player != None && caliWorld != None && player.GetWorldSpace() == caliWorld
        StartTimer(2.5, 822)
    endif
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
    BindWaterMerchantsListeners(False)
    Actor player = Game.GetPlayer()
    WorldSpace caliWorld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if player != None && caliWorld != None && player.GetWorldSpace() == caliWorld
        StartTimer(2.5, 822)
    endif
EndEvent

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
    SyncMarthaLayout()
    Actor player = Game.GetPlayer()
    if player != None && IsWaterCaravanHired() && !bJacorenWaterReactionShown
        Cell v13Cell = Game.GetFormFromFile(0x00002100, "Vault13Chronicles.esp") as Cell
        if v13Cell != None && player.GetParentCell() == v13Cell
            bJacorenWaterReactionShown = True
            Form pureWater = Game.GetFormFromFile(0x000366C0, "Fallout4.esm")
            if pureWater != None
                player.AddItem(pureWater, 6, False)
            endif
            Game.RewardPlayerXP(150)
            if IsWaterChipResolved()
                Debug.Notification("Supervisor Jacoren: «Los barriles de los Mercaderes del Agua aseguran las reservas del Refugio 13, pero reza para que nadie haya seguido sus huellas.» (+150 XP)")
            else
                Debug.Notification("Supervisor Jacoren: «Los barriles de los Mercaderes del Agua han dado 100 días de vida al Refugio 13, pero reza para que nadie haya seguido sus huellas.» (+150 XP)")
            endif
        endif
    endif
EndEvent

Event ObjectReference.OnItemAdded(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    Form contractBase = Game.GetFormFromFile(0x0000145D, "Vault13Chronicles.esp")
    if contractBase != None && akBaseItem == contractBase
        if Self.GetStage() < 21
            Self.SetStage(21)
        else
            HireWaterCaravanToVault13(0)
        endif
    endif
EndEvent

Event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
    if akActionRef != Game.GetPlayer()
        return
    endif
    ObjectReference marthaRef = Game.GetFormFromFile(0x000035E6, "Vault13Chronicles.esp") as ObjectReference
    if marthaRef == None || akSender != marthaRef
        return
    endif
    BindWaterMerchantsListeners()
    Actor marthaAct = marthaRef as Actor
    if marthaAct != None && !marthaAct.IsDead()
        if !bWaterCaravanHired && Self.GetStage() < 20
            Self.SetStage(20)
        endif
        ForceQuestAlias(9, 0x000035E6)
        Scene marthaScn = Game.GetFormFromFile(0x0001A100, "Vault13Chronicles.esp") as Scene
        if !IsWaterCaravanHired() && marthaScn != None && !marthaScn.IsPlaying()
            sceneWaitTicks = 0
            StartTimer(1.2, 821)
        endif
    endif
EndEvent

Event OnTimer(int aiTimerID)
    if aiTimerID == 821
        Actor marthaAct = Game.GetFormFromFile(0x000035E6, "Vault13Chronicles.esp") as Actor
        Scene marthaScn = Game.GetFormFromFile(0x0001A100, "Vault13Chronicles.esp") as Scene
        if marthaScn != None && !marthaScn.IsPlaying()
            if !Utility.IsInMenuMode() && (marthaAct == None || (!marthaAct.IsInDialogueWithPlayer() && !marthaAct.IsTalking()))
                ForceQuestAlias(9, 0x000035E6)
                marthaScn.Start()
            elseif sceneWaitTicks < 4
                sceneWaitTicks += 1
                Self.StartTimer(2.0, 821)
            endif
        endif
    elseif aiTimerID == 822
        SyncMarthaLayout()
    endif
EndEvent

Event OnStageSet(int auiStageID, int auiItemID)
    if auiStageID == 15
        if bStg15Done
            return
        endif
        bStg15Done = True
        BindWaterMerchantsListeners()
        if !IsWaterCaravanHired() && !Self.IsObjectiveDisplayed(15)
            ForceQuestAlias(9, 0x000035E6)
            Self.SetObjectiveDisplayed(15, True, False)
        endif
    elseif auiStageID == 20
        if bStg20Done
            return
        endif
        bStg20Done = True
        SetObjectiveCompleted(15, True)
        if !IsWaterCaravanHired() && !Self.IsObjectiveDisplayed(20)
            ForceQuestAlias(9, 0x000035E6)
            Self.SetObjectiveDisplayed(20, True, False)
            Self.SetActive(True)
        endif
    elseif auiStageID == 21
        if bStg21Done
            FinalizeWaterMerchantsQuestCleanly()
            return
        endif
        bStg21Done = True
        HireWaterCaravanToVault13(1000)
    elseif auiStageID == 22
        if bStg21Done
            FinalizeWaterMerchantsQuestCleanly()
            return
        endif
        bStg21Done = True
        HireWaterCaravanToVault13(0)
    endif
EndEvent
