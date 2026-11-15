Scriptname V13Act3QuestScript extends Quest

int hitCounter = 0
bool introShown = false
bool rewardsGiven = false
bool bStage30Done = false
bool bStage40Rewarded = false
bool bApplyingAct3Stage = false
bool bLostHillsAdmitted = false
bool bVreeHoloObtained = false
bool bMaxsonCouncilDone = false
int vreeWaitTicks = 0
int maxsonWaitTicks = 0
int jacorenAct3WaitTicks = 0
bool bAct3BriefingAutoQueued = false
int lastAppliedAct3Stage = 0
bool bMaxsonScenePlayingSeen = false

Function SilenceMathiaIfTalking()
    if bMaxsonCouncilDone || Self.GetStage() >= 30
        return
    endif
    Topic stopTopic = Game.GetFormFromFile(0x00004003, "Vault13Chronicles.esp") as Topic
    Actor mathiaAct = Game.GetFormFromFile(0x00002B36, "Vault13Chronicles.esp") as Actor
    if stopTopic != None && mathiaAct != None && mathiaAct.IsTalking()
        mathiaAct.Say(stopTopic, None, false, None)
    endif
EndFunction

bool Function IsLegacyAct3Stub()
    Form stubF = Game.GetFormFromFile(0x00006000, "Vault13Chronicles.esp")
    return stubF != None && (Self as Form) == stubF
EndFunction

Function ForwardLegacyStubIfNeeded()
    Quest act2Q = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as Quest
    if act2Q != None && (act2Q.IsCompleted() || act2Q.GetStage() >= 40 || act2Q.IsStageDone(40))
        V13Act3QuestScript act3Live = Game.GetFormFromFile(0x00006002, "Vault13Chronicles.esp") as V13Act3QuestScript
        if act3Live != None
            act3Live.WakeUpAct3()
        endif
    endif
    CancelTimer(1)
    Self.Stop()
EndFunction

bool Function IsLostHillsAdmitted()
    Quest qGlow = Game.GetFormFromFile(0x00013000, "Vault13Chronicles.esp") as Quest
    if qGlow != None && qGlow.GetStage() >= 30
        bLostHillsAdmitted = true
    endif
    return bLostHillsAdmitted
EndFunction

Function NotifyLostHillsAdmitted()
    bLostHillsAdmitted = true
EndFunction

bool Function AreMariposaPaladinsAuthorized()
    Actor player = Game.GetPlayer()
    Form palOrder = Game.GetFormFromFile(0x00001522, "Vault13Chronicles.esp")
    if bMaxsonCouncilDone || (player != None && palOrder != None && player.GetItemCount(palOrder) > 0)
        return true
    endif
    return false
EndFunction

Function ForceQuestAlias(int aiAliasID, int aiFormID)
    ObjectReference targetRef = Game.GetFormFromFile(aiFormID, "Vault13Chronicles.esp") as ObjectReference
    ReferenceAlias al = Self.GetAlias(aiAliasID) as ReferenceAlias
    if al != None && targetRef != None
        if al.GetReference() != targetRef
            al.ForceRefTo(targetRef)
        endif
    endif
EndFunction

Function RegisterPlayerEvents()
    Actor player = Game.GetPlayer()
    Form vreeHolo = Game.GetFormFromFile(0x00001113, "Vault13Chronicles.esp")
    Self.RemoveAllInventoryEventFilters()
    if vreeHolo != None
        Self.AddInventoryEventFilter(vreeHolo)
    endif
    if player != None
        RegisterForRemoteEvent(player, "OnPlayerLoadGame")
        RegisterForRemoteEvent(player, "OnItemEquipped")
        RegisterForRemoteEvent(player, "OnLocationChange")
        if vreeHolo != None
            RegisterForRemoteEvent(player as ObjectReference, "OnItemAdded")
        endif
    endif
    ObjectReference vreeRef = Game.GetFormFromFile(0x00002B34, "Vault13Chronicles.esp") as ObjectReference
    if vreeRef != None
        RegisterForRemoteEvent(vreeRef, "OnActivate")
    endif
    ObjectReference maxsonRef = Game.GetFormFromFile(0x00002B35, "Vault13Chronicles.esp") as ObjectReference
    if maxsonRef != None
        RegisterForRemoteEvent(maxsonRef, "OnActivate")
    endif
    ObjectReference liftTo4Ref = Game.GetFormFromFile(0x00002B43, "Vault13Chronicles.esp") as ObjectReference
    if liftTo4Ref != None
        RegisterForRemoteEvent(liftTo4Ref, "OnActivate")
    endif
    ObjectReference liftTo3Ref = Game.GetFormFromFile(0x00002B44, "Vault13Chronicles.esp") as ObjectReference
    if liftTo3Ref != None
        RegisterForRemoteEvent(liftTo3Ref, "OnActivate")
    endif
EndFunction

Function SetLostHillsState(bool abEnabled)
    ObjectReference vreeChest = Game.GetFormFromFile(0x00002B10, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference termVreeLegacy = Game.GetFormFromFile(0x00002B30, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference d2B01 = Game.GetFormFromFile(0x00002B01, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference d2B03 = Game.GetFormFromFile(0x00002B03, "Vault13Chronicles.esp") as ObjectReference

    ; Keep old greybox hostile raid actors (0x00002B11..2B26) permanently disabled in canonical Lost Hills
    ObjectReference kragor = Game.GetFormFromFile(0x00002B11, "Vault13Chronicles.esp") as ObjectReference
    if kragor != None && !kragor.IsDisabled()
        kragor.Disable(false)
    endif
    ObjectReference g1 = Game.GetFormFromFile(0x00002B12, "Vault13Chronicles.esp") as ObjectReference
    if g1 != None && !g1.IsDisabled()
        g1.Disable(false)
    endif
    int bIdx = 0
    while bIdx < 7
        ObjectReference bExtra = Game.GetFormFromFile(0x00002B20 + bIdx, "Vault13Chronicles.esp") as ObjectReference
        if bExtra != None && !bExtra.IsDisabled()
            bExtra.Disable(false)
        endif
        bIdx += 1
    endwhile

    ; Enable canonical 4-level Brotherhood NPCs and stations regardless of Act 3 stage (in case player enters via Glow / Lockpick early)
    if d2B01 != None
        if d2B01.IsDisabled()
            d2B01.Enable(false)
        endif
        if d2B01.IsLocked()
            d2B01.Lock(false, false)
        endif
    endif
    if d2B03 != None && !d2B03.IsDisabled()
        d2B03.DisableNoWait(false)
    endif
    ObjectReference plugL3 = Game.GetFormFromFile(0x00060498, "Vault13Chronicles.esp") as ObjectReference
    if plugL3 != None && !plugL3.IsDisabled()
        plugL3.DisableNoWait(false)
    endif
    ObjectReference plugL4 = Game.GetFormFromFile(0x00060495, "Vault13Chronicles.esp") as ObjectReference
    if plugL4 != None && !plugL4.IsDisabled()
        plugL4.DisableNoWait(false)
    endif
    if vreeChest != None && vreeChest.IsDisabled()
        vreeChest.EnableNoWait(false)
    endif
    if termVreeLegacy != None && !termVreeLegacy.IsDisabled()
        termVreeLegacy.DisableNoWait(false)
    endif
    ObjectReference termLegacy1 = Game.GetFormFromFile(0x00002B38, "Vault13Chronicles.esp") as ObjectReference
    if termLegacy1 != None && !termLegacy1.IsDisabled()
        termLegacy1.DisableNoWait(false)
    endif
    ObjectReference termLegacy2 = Game.GetFormFromFile(0x00002B39, "Vault13Chronicles.esp") as ObjectReference
    if termLegacy2 != None && !termLegacy2.IsDisabled()
        termLegacy2.DisableNoWait(false)
    endif

    int[] bosFids = new int[6]
    float[] bosX = new float[6]
    float[] bosY = new float[6]
    float[] bosZ = new float[6]
    float[] bosAng = new float[6]
    bosFids[0] = 0x00002B31
    bosX[0] = -625.0
    bosY[0] = 95.0
    bosZ[0] = 7.4
    bosAng[0] = 180.0
    bosFids[1] = 0x00002B32
    bosX[1] = 1115.0
    bosY[1] = -385.0
    bosZ[1] = -212.0
    bosAng[1] = 270.0
    bosFids[2] = 0x00002B33
    bosX[2] = 1023.6
    bosY[2] = -375.7
    bosZ[2] = -214.0
    bosAng[2] = 270.0
    bosFids[3] = 0x00002B34
    bosX[3] = -255.0
    bosY[3] = -45.0
    bosZ[3] = -470.1
    bosAng[3] = 134.6
    bosFids[4] = 0x00002B35
    bosX[4] = 2035.0
    bosY[4] = -2540.0
    bosZ[4] = -577.6
    bosAng[4] = 255.68
    bosFids[5] = 0x00002B36
    bosX[5] = 2185.0
    bosY[5] = -2685.0
    bosZ[5] = -577.6
    bosAng[5] = 315.0

    int bNpcIdx = 0
    while bNpcIdx < 6
        Actor bosNpc = Game.GetFormFromFile(bosFids[bNpcIdx], "Vault13Chronicles.esp") as Actor
        if bosNpc != None
            if bosNpc.IsDisabled()
                bosNpc.EnableNoWait(false)
            endif
            if bosNpc.Is3DLoaded()
                if bosNpc.IsDead()
                    bosNpc.Resurrect()
                endif
                if !bosNpc.IsInCombat() && !bosNpc.IsTalking() && !bosNpc.IsInDialogueWithPlayer()
                    if Math.Abs(bosNpc.GetPositionX() - bosX[bNpcIdx]) > 25.0 || Math.Abs(bosNpc.GetPositionY() - bosY[bNpcIdx]) > 25.0 || Math.Abs(bosNpc.GetPositionZ() - bosZ[bNpcIdx]) > 25.0
                        bosNpc.SetPosition(bosX[bNpcIdx], bosY[bNpcIdx], bosZ[bNpcIdx])
                        bosNpc.SetAngle(0.0, 0.0, bosAng[bNpcIdx])
                        bosNpc.EvaluatePackage()
                    endif
                endif
            endif
        endif
        bNpcIdx += 1
    endwhile

    Actor player = Game.GetPlayer()
    Cell lostHillsCell = Game.GetFormFromFile(0x00002B00, "Vault13Chronicles.esp") as Cell
    bool inLostHills = (player != None && lostHillsCell != None && player.GetParentCell() == lostHillsCell)

    int[] propFids = new int[10]
    propFids[0] = 0x00002B40
    propFids[1] = 0x00002B41
    propFids[2] = 0x00002B42
    propFids[3] = 0x00002B43
    propFids[4] = 0x00002B44
    propFids[5] = 0x00002B45
    propFids[6] = 0x00002B46
    propFids[7] = 0x00002B47
    propFids[8] = 0x00002B48
    propFids[9] = 0x00002B49
    int pIdx = 0
    while pIdx < 10
        ObjectReference bosObj = Game.GetFormFromFile(propFids[pIdx], "Vault13Chronicles.esp") as ObjectReference
        if bosObj != None
            if bosObj.IsDisabled()
                bosObj.EnableNoWait(false)
            endif
            if inLostHills && bosObj.Is3DLoaded() && bosObj.GetParentCell() == lostHillsCell
                if (propFids[pIdx] == 0x00002B43 || propFids[pIdx] == 0x00002B44 || propFids[pIdx] == 0x00002B47 || propFids[pIdx] == 0x00002B48) && bosObj.IsLocked()
                    bosObj.Lock(false, false)
                endif
                if propFids[pIdx] == 0x00002B40
                    if Math.Abs(bosObj.GetPositionX() - (-685.0)) > 25.0 || Math.Abs(bosObj.GetPositionY() - 155.0) > 25.0 || Math.Abs(bosObj.GetPositionZ() - 7.4) > 25.0
                        bosObj.SetPosition(-685.0, 155.0, 7.4)
                        bosObj.SetAngle(0.0, 0.0, 0.0)
                    endif
                elseif propFids[pIdx] == 0x00002B43
                    if Math.Abs(bosObj.GetPositionX() - (-550.830)) > 5.0 || Math.Abs(bosObj.GetPositionY() - 4.746) > 5.0 || Math.Abs(bosObj.GetAngleZ() - 75.68) > 5.0
                        bosObj.SetPosition(-550.830, 4.746, -470.128)
                        bosObj.SetAngle(0.0, 0.0, 75.68)
                    endif
                elseif propFids[pIdx] == 0x00002B44
                    if Math.Abs(bosObj.GetPositionX() - 1694.802) > 5.0 || Math.Abs(bosObj.GetPositionY() - (-2452.053)) > 5.0 || Math.Abs(bosObj.GetAngleZ() - 255.68) > 5.0
                        bosObj.SetPosition(1694.802, -2452.053, -578.231)
                        bosObj.SetAngle(0.0, 0.0, 255.68)
                    endif
                elseif propFids[pIdx] == 0x00002B49
                    if Math.Abs(bosObj.GetPositionX() - (-550.830)) > 5.0 || Math.Abs(bosObj.GetPositionY() - 4.746) > 5.0 || Math.Abs(bosObj.GetAngleZ() - 345.68) > 5.0
                        bosObj.SetPosition(-550.830, 4.746, -470.128)
                        bosObj.SetAngle(0.0, 0.0, 345.68)
                    endif
                endif
            endif
        endif
        pIdx += 1
    endwhile

    if inLostHills
        Form deskForm = Game.GetFormFromFile(0x000BD538, "Fallout4.esm")
        if deskForm != None
            ObjectReference d0 = Game.FindClosestReferenceOfType(deskForm, -24.0, -326.8, -462.0, 180.0)
            if d0 != None && !d0.IsDisabled()
                d0.DisableNoWait(false)
            endif
            ObjectReference d1 = Game.FindClosestReferenceOfType(deskForm, 1193.2, -1899.8, -66.2, 220.0)
            if d1 != None && !d1.IsDisabled()
                d1.DisableNoWait(false)
            endif
            ObjectReference d2 = Game.FindClosestReferenceOfType(deskForm, 1260.0, -1750.0, -66.2, 180.0)
            if d2 != None && !d2.IsDisabled()
                d2.DisableNoWait(false)
            endif
        endif
        Form tripwireForm = Game.GetFormFromFile(0x00083F22, "Fallout4.esm")
        if tripwireForm != None
            int twIdx = 0
            while twIdx < 12
                ObjectReference twRef = Game.FindRandomReferenceOfType(tripwireForm, 0.0, 0.0, -250.0, 3500.0)
                if twRef != None && !twRef.IsDisabled()
                    twRef.DisableNoWait(false)
                endif
                twIdx += 1
            endwhile
        endif
    endif

    V13Act1QuestScript act1S = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as V13Act1QuestScript
    if act1S != None
        act1S.SyncVault13ExpeditionDoors()
    endif
    V13SideQuestGlowScript glowS = Game.GetFormFromFile(0x00013000, "Vault13Chronicles.esp") as V13SideQuestGlowScript
    if glowS != None
        glowS.RefreshGlowSettlementLayout()
    endif
EndFunction

Function GrantVreeAutopsyHolodisk()
    Actor player = Game.GetPlayer()
    Form vreeHolo = Game.GetFormFromFile(0x00001113, "Vault13Chronicles.esp")
    Form report3 = Game.GetFormFromFile(0x00001143, "Vault13Chronicles.esp")
    if player != None
        if vreeHolo != None && player.GetItemCount(vreeHolo) == 0
            player.AddItem(vreeHolo, 1, false)
        endif
        if report3 != None && player.GetItemCount(report3) == 0
            player.AddItem(report3, 1, false)
        endif
    endif
    if !bVreeHoloObtained
        bVreeHoloObtained = true
        Game.RewardPlayerXP(250, false)
        Debug.Notification("[Head Scribe Vree - Level 3] Super Mutant Autopsy Report Holotape received! (+250 XP)")
    endif
    AdvanceLostHillsCouncilProgress()
EndFunction

Function DownloadVreeAutopsyFromTerminal()
    GrantVreeAutopsyHolodisk()
EndFunction

Function AuthorizeMaxsonCouncilSupport()
    Actor player = Game.GetPlayer()
    Form palOrder = Game.GetFormFromFile(0x00001522, "Vault13Chronicles.esp")
    if player != None && palOrder != None && player.GetItemCount(palOrder) == 0
        player.AddItem(palOrder, 1, false)
    endif
    ObjectReference pal1 = Game.GetFormFromFile(0x00002C36, "Vault13Chronicles.esp") as ObjectReference
    if pal1 != None && pal1.IsDisabled()
        pal1.EnableNoWait()
    endif
    ObjectReference pal2 = Game.GetFormFromFile(0x00002C37, "Vault13Chronicles.esp") as ObjectReference
    if pal2 != None && pal2.IsDisabled()
        pal2.EnableNoWait()
    endif
    if !bMaxsonCouncilDone
        bMaxsonCouncilDone = true
        Game.RewardPlayerXP(250, false)
        Debug.Notification("[High Elder John Maxson - Level 4] Scouts dispatched north and Paladin Assault Squad authorized for the Mariposa raid! (+250 XP)")
    endif
    AdvanceLostHillsCouncilProgress()
EndFunction

Function AdvanceLostHillsCouncilProgress()
    ForceAllAct3Aliases()
    int curStg = Self.GetStage()
    if curStg < 15
        return
    endif
    bool vreeReady = bVreeHoloObtained || (curStg >= 25)
    if vreeReady && bMaxsonCouncilDone
        if curStg < 30
            Self.SetStage(30)
        endif
    elseif vreeReady && !bMaxsonCouncilDone
        if curStg >= 20 && curStg < 25
            Self.SetStage(25)
        endif
    endif
EndFunction

Function GiveAct3CompletionRewards()
    if rewardsGiven
        return
    endif
    rewardsGiven = true
    Actor player = Game.GetPlayer()
    Form vreeHolo = Game.GetFormFromFile(0x00001113, "Vault13Chronicles.esp")
    Form wattz2000 = Game.GetFormFromFile(0x00001108, "Vault13Chronicles.esp")
    ObjectReference vreeChest = Game.GetFormFromFile(0x00002B10, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference relicDisplay3 = Game.GetFormFromFile(0x00002033, "Vault13Chronicles.esp") as ObjectReference
    Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
    Form stimpak = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
    Form fusionCell = Game.GetFormFromFile(0x000C1897, "Fallout4.esm")

    if player != None
        ; CRITICAL CANON: Keep 1 copy of Vree's Sterility Autopsy Holodisk (0x00001113) in player inventory for the Master in Act V!
        if vreeHolo != None
            if player.GetItemCount(vreeHolo) == 0
                player.AddItem(vreeHolo, 1, true)
            elseif player.GetItemCount(vreeHolo) > 1
                player.RemoveItem(vreeHolo, player.GetItemCount(vreeHolo) - 1, true, None)
            endif
            if vreeChest != None && vreeChest.GetItemCount(vreeHolo) > 0
                vreeChest.RemoveItem(vreeHolo, vreeChest.GetItemCount(vreeHolo), true, None)
            endif
        endif
        if wattz2000 != None
            if player.GetItemCount(wattz2000) == 0
                player.AddItem(wattz2000, 1, false)
            elseif player.GetItemCount(wattz2000) > 1
                player.RemoveItem(wattz2000, player.GetItemCount(wattz2000) - 1, true, None)
            endif
        endif
        if caps != None
            player.AddItem(caps, 1000, false)
        endif
        if stimpak != None
            player.AddItem(stimpak, 6, false)
        endif
        if fusionCell != None
            player.AddItem(fusionCell, 80, false)
        endif
    endif

    if relicDisplay3 != None
        relicDisplay3.Enable(false)
    endif

    Game.RewardPlayerXP(800, false)
    Debug.Notification("[Vault 13 Chronicles] Lost Hills report filed! Keep Vree's Holotape for The Cathedral - Mariposa and The Cathedral are now unlocked (1997 Free Order).")
EndFunction

Function ForceAllAct3Aliases()
    Actor lhPlayer = Game.GetPlayer()
    Cell lhCell = Game.GetFormFromFile(0x00002B00, "Vault13Chronicles.esp") as Cell
    ForceQuestAlias(0, 0x00002110)
    if !bVreeHoloObtained && Self.GetStage() < 25
        ForceQuestAlias(1, 0x00002B34) ; Head Scribe Vree (Level 3)
    elseif !bMaxsonCouncilDone && Self.GetStage() < 30
        if lhPlayer != None && lhCell != None && lhPlayer.GetParentCell() == lhCell && lhPlayer.GetPositionX() < 1200.0
            ForceQuestAlias(1, 0x00002B43) ; Direct Lift (Level 3 -> Level 4)
        else
            ForceQuestAlias(1, 0x00002B35) ; High Elder John Maxson (Level 4)
        endif
    else
        ForceQuestAlias(1, 0x00002110) ; Return to Overseer Jacoren
    endif
    ForceQuestAlias(2, 0x00003005)
    ForceQuestAlias(3, 0x00002003)
    if IsLostHillsAdmitted()
        ForceQuestAlias(4, 0x00003507) ; Admitted: Lost Hills Surface Bunker Door
    else
        Quest qGlow = Game.GetFormFromFile(0x00013000, "Vault13Chronicles.esp") as Quest
        if qGlow != None && qGlow.GetStage() >= 20 && qGlow.GetStage() < 25
            ForceQuestAlias(4, 0x00003601) ; Trial of The Glow: West Tek Crater Hatch
        else
            ForceQuestAlias(4, 0x000035D0) ; Guard Cabbot at Lost Hills gate
        endif
    endif
    V13Act1QuestScript act1DoorS = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as V13Act1QuestScript
    if act1DoorS != None
        ForceQuestAlias(5, act1DoorS.GetEnabledVault13ExitDoorFid(0x00002143))
    else
        ForceQuestAlias(5, 0x00002143)
    endif
    ForceQuestAlias(6, 0x00003501)
    if lhPlayer != None && lhCell != None && lhPlayer.GetParentCell() == lhCell && lhPlayer.GetPositionX() > 1200.0
        ForceQuestAlias(7, 0x00002B47)
    else
        ForceQuestAlias(7, 0x00002B48)
    endif
    ForceQuestAlias(9, 0x00002B34)  ; Scribe Vree
    ForceQuestAlias(10, 0x00002B35) ; High Elder Maxson
EndFunction

Function ApplyV13Act3Stage(int auiStage)
    if IsLegacyAct3Stub()
        ForwardLegacyStubIfNeeded()
        return
    endif
    if bApplyingAct3Stage
        return
    endif
    bApplyingAct3Stage = true

    V13Act1QuestScript act1S = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as V13Act1QuestScript
    bool inDial = (act1S != None && act1S.IsJacorenInDialogueOrScene())

    if auiStage < 15
        ForceAllAct3Aliases()
        bApplyingAct3Stage = false
        return
    endif

    if !inDial
        SetLostHillsState(true)
    elseif act1S != None
        act1S.SyncVault13ExpeditionDoors()
    endif
    ForceAllAct3Aliases()

    introShown = true

    if auiStage == 15
        if !Self.IsObjectiveDisplayed(15)
            Self.SetObjectiveDisplayed(15, true, false)
            Self.SetActive(true)
        endif
    elseif auiStage >= 20 && auiStage < 25
        if !Self.IsObjectiveCompleted(15)
            Self.SetObjectiveCompleted(15, true)
        endif
        if Self.IsObjectiveDisplayed(15)
            Self.SetObjectiveDisplayed(15, false, false)
        endif
        if bVreeHoloObtained && bMaxsonCouncilDone
            lastAppliedAct3Stage = auiStage
            bApplyingAct3Stage = false
            Self.SetStage(30)
            return
        elseif bVreeHoloObtained
            lastAppliedAct3Stage = auiStage
            bApplyingAct3Stage = false
            Self.SetStage(25)
            return
        endif
        Actor player = Game.GetPlayer()
        WorldSpace ws2161 = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
        Cell lostHillsCell = Game.GetFormFromFile(0x00002B00, "Vault13Chronicles.esp") as Cell
        bool inWastelandOrDungeon = (player != None && ((ws2161 != None && player.GetWorldSpace() == ws2161) || (lostHillsCell != None && player.GetParentCell() == lostHillsCell)))
        if inWastelandOrDungeon || Self.IsObjectiveCompleted(20)
            if !Self.IsObjectiveCompleted(20)
                Self.SetObjectiveCompleted(20, true)
            endif
            if Self.IsObjectiveDisplayed(20)
                Self.SetObjectiveDisplayed(20, false, false)
            endif
            if !Self.IsObjectiveDisplayed(21)
                Self.SetObjectiveDisplayed(21, true, false)
                Self.SetActive(true)
            endif
        else
            bool obj20WasOff = !Self.IsObjectiveDisplayed(20)
            if Self.IsObjectiveDisplayed(20) && lastAppliedAct3Stage < 20
                Self.SetObjectiveDisplayed(20, false, false)
            endif
            if !Self.IsObjectiveDisplayed(20)
                Self.SetObjectiveDisplayed(20, true, false)
                if obj20WasOff
                    Self.SetActive(true)
                endif
            endif
        endif
    elseif auiStage >= 25 && auiStage < 30
        if !bVreeHoloObtained
            GrantVreeAutopsyHolodisk()
        endif
        ForceAllAct3Aliases()
        if !Self.IsObjectiveCompleted(15)
            Self.SetObjectiveCompleted(15, true)
        endif
        if Self.IsObjectiveDisplayed(15)
            Self.SetObjectiveDisplayed(15, false, false)
        endif
        if !Self.IsObjectiveCompleted(20)
            Self.SetObjectiveCompleted(20, true)
        endif
        if Self.IsObjectiveDisplayed(20)
            Self.SetObjectiveDisplayed(20, false, false)
        endif
        if !Self.IsObjectiveCompleted(21)
            Self.SetObjectiveCompleted(21, true)
        endif
        if Self.IsObjectiveDisplayed(21)
            Self.SetObjectiveDisplayed(21, false, false)
        endif
        if bMaxsonCouncilDone
            lastAppliedAct3Stage = auiStage
            bApplyingAct3Stage = false
            Self.SetStage(30)
            return
        endif
        if !Self.IsObjectiveDisplayed(25)
            Self.SetObjectiveDisplayed(25, true, false)
            Self.SetActive(true)
        endif
    elseif auiStage >= 30 && auiStage < 40
        if !bVreeHoloObtained
            GrantVreeAutopsyHolodisk()
        endif
        if !bMaxsonCouncilDone
            AuthorizeMaxsonCouncilSupport()
        endif
        ForceAllAct3Aliases()
        bStage30Done = true
        if !Self.IsObjectiveCompleted(15)
            Self.SetObjectiveCompleted(15, true)
        endif
        if Self.IsObjectiveDisplayed(15)
            Self.SetObjectiveDisplayed(15, false, false)
        endif
        if !Self.IsObjectiveCompleted(20)
            Self.SetObjectiveCompleted(20, true)
        endif
        if Self.IsObjectiveDisplayed(20)
            Self.SetObjectiveDisplayed(20, false, false)
        endif
        if !Self.IsObjectiveCompleted(21)
            Self.SetObjectiveCompleted(21, true)
        endif
        if Self.IsObjectiveDisplayed(21)
            Self.SetObjectiveDisplayed(21, false, false)
        endif
        if !Self.IsObjectiveCompleted(25)
            Self.SetObjectiveCompleted(25, true)
        endif
        if Self.IsObjectiveDisplayed(25)
            Self.SetObjectiveDisplayed(25, false, false)
        endif
        if !Self.IsObjectiveDisplayed(30)
            Self.SetObjectiveDisplayed(30, true, false)
            Self.SetActive(true)
        endif
    elseif auiStage >= 40
        if inDial && auiStage < 45
            bApplyingAct3Stage = false
            StartTimer(0.2, 1)
            return
        endif
        if !bStage40Rewarded
            bStage40Rewarded = true
            GiveAct3CompletionRewards()
        endif
        if !Self.IsObjectiveCompleted(15)
            Self.SetObjectiveCompleted(15, true)
        endif
        if Self.IsObjectiveDisplayed(15)
            Self.SetObjectiveDisplayed(15, false, false)
        endif
        if !Self.IsObjectiveCompleted(20)
            Self.SetObjectiveCompleted(20, true)
        endif
        if Self.IsObjectiveDisplayed(20)
            Self.SetObjectiveDisplayed(20, false, false)
        endif
        if !Self.IsObjectiveCompleted(21)
            Self.SetObjectiveCompleted(21, true)
        endif
        if Self.IsObjectiveDisplayed(21)
            Self.SetObjectiveDisplayed(21, false, false)
        endif
        if Self.IsObjectiveDisplayed(25) && !Self.IsObjectiveCompleted(25)
            Self.SetObjectiveCompleted(25, true)
        endif
        if !Self.IsObjectiveCompleted(30)
            Self.SetObjectiveCompleted(30, true)
        endif
        if !Self.IsCompleted()
            Self.CompleteAllObjectives()
            Self.CompleteQuest()
        endif
        ; Unlock Act IV (Mariposa Military Base); Act V (The Cathedral) unlocks after Mariposa (or upon entering Cathedral cell directly)
        Quest act4Quest = Game.GetFormFromFile(0x00007000, "Vault13Chronicles.esp") as Quest
        if act4Quest != None
            if !act4Quest.IsRunning()
                act4Quest.Start()
            endif
            if act4Quest.GetStage() < 20
                act4Quest.SetStage(20)
            endif
        endif
        V13Act4QuestScript act4S = act4Quest as V13Act4QuestScript
        if act4S != None
            act4S.WakeUpAct4()
        endif
    endif
    lastAppliedAct3Stage = auiStage
    bApplyingAct3Stage = false
EndFunction

Function WakeUpAct3()
    if IsLegacyAct3Stub()
        ForwardLegacyStubIfNeeded()
        return
    endif
    RegisterPlayerEvents()
    CheckProgressionAndLevelGate()
    if Self.IsRunning()
        StartTimer(2.5, 1)
    endif
EndFunction

Function BeginAct3FromJacoren(bool abAutoOpenScene = true)
    if IsLegacyAct3Stub()
        V13Act3QuestScript act3Live = Game.GetFormFromFile(0x00006002, "Vault13Chronicles.esp") as V13Act3QuestScript
        if act3Live != None
            act3Live.BeginAct3FromJacoren(abAutoOpenScene)
        endif
        CancelTimer(1)
        Self.Stop()
        return
    endif
    RegisterPlayerEvents()
    if !Self.IsRunning() && !Self.IsCompleted()
        Self.Start()
    endif
    ForceAllAct3Aliases()
    if Self.GetStage() < 15
        Self.SetStage(15)
    endif
    ApplyV13Act3Stage(Self.GetStage())
    if abAutoOpenScene && Self.GetStage() == 15 && !bAct3BriefingAutoQueued
        bAct3BriefingAutoQueued = true
        jacorenAct3WaitTicks = 0
        StartTimer(0.5, 95)
    endif
    if Self.IsRunning()
        StartTimer(2.5, 1)
    endif
EndFunction

Function CheckProgressionAndLevelGate()
    if IsLegacyAct3Stub()
        ForwardLegacyStubIfNeeded()
        return
    endif
    Actor player = Game.GetPlayer()
    if player == None
        return
    endif
    Cell lostHillsCell = Game.GetFormFromFile(0x00002B00, "Vault13Chronicles.esp") as Cell
    if lostHillsCell != None && player.GetParentCell() == lostHillsCell
        bLostHillsAdmitted = true
        if !Utility.IsInMenuMode()
            SetLostHillsState(true)
        endif
        if player.GetPositionX() > 1200.0
            SilenceMathiaIfTalking()
        endif
        Scene lhMaxsonScene = Game.GetFormFromFile(0x00006103, "Vault13Chronicles.esp") as Scene
        if lhMaxsonScene != None && lhMaxsonScene.IsPlaying()
            bMaxsonScenePlayingSeen = true
            SilenceMathiaIfTalking()
        elseif bMaxsonScenePlayingSeen && !bMaxsonCouncilDone
            AuthorizeMaxsonCouncilSupport()
        endif
        if Self.GetStage() >= 15 && Self.GetStage() < 40
            ForceAllAct3Aliases()
        endif
    endif

    Form vreeHolo = Game.GetFormFromFile(0x00001113, "Vault13Chronicles.esp")
    if vreeHolo != None && player.GetItemCount(vreeHolo) > 0
        bVreeHoloObtained = true
    endif

    Quest act2Quest = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as Quest
    if act2Quest == None || (!act2Quest.IsCompleted() && act2Quest.GetStage() < 40 && !act2Quest.IsStageDone(40))
        return
    endif

    int curStage = Self.GetStage()
    if Self.IsCompleted() || Self.IsStageDone(40) || bStage40Rewarded
        curStage = 40
    endif
    if curStage < 15
        if !Self.IsRunning()
            Self.Start()
        endif
        Self.SetStage(15)
        ApplyV13Act3Stage(15)
        return
    endif

    introShown = true

    if curStage >= 20 && curStage < 30
        AdvanceLostHillsCouncilProgress()
    endif

    if (curStage == 15 && !Self.IsObjectiveDisplayed(15)) || (curStage >= 20 && curStage < 25 && (Self.IsObjectiveDisplayed(15) || (!Self.IsObjectiveDisplayed(20) && !Self.IsObjectiveDisplayed(21)))) || (curStage >= 25 && curStage < 30 && (Self.IsObjectiveDisplayed(21) || !Self.IsObjectiveDisplayed(25))) || (curStage >= 30 && curStage < 40 && (Self.IsObjectiveDisplayed(25) || !Self.IsObjectiveDisplayed(30))) || (curStage >= 40 && (!rewardsGiven || !Self.IsCompleted()))
        ApplyV13Act3Stage(curStage)
    endif
EndFunction

Function ProcessWattz2000Hit(Actor akTarget, Actor akCaster)
    if akTarget == None || akCaster == None
        return
    endif

    EffectShader fireFX = Game.GetFormFromFile(0x0006F122, "Fallout4.esm") as EffectShader
    if fireFX != None
        fireFX.Play(akTarget, 2.0)
    endif

    Actor player = Game.GetPlayer()
    if akCaster == player
        hitCounter += 1
        if hitCounter >= 4 || akTarget.IsDead()
            hitCounter = 0
            ActorValue apAV = Game.GetFormFromFile(0x000002D5, "Fallout4.esm") as ActorValue
            ActorValue hpAV = Game.GetFormFromFile(0x000002D4, "Fallout4.esm") as ActorValue
            if apAV != None
                player.RestoreValue(apAV, 30.0)
            endif
            if hpAV != None
                player.RestoreValue(hpAV, 20.0)
            endif
            Debug.Notification("[Wattz 2000 Laser Rifle] Lost Hills optical overcharge! (+30 AP / +20 HP)")
        endif
    endif
EndFunction

Event ObjectReference.OnItemAdded(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    Form vreeHolo = Game.GetFormFromFile(0x00001113, "Vault13Chronicles.esp")
    if akBaseItem == vreeHolo
        bVreeHoloObtained = true
        AdvanceLostHillsCouncilProgress()
    endif
EndEvent

Event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
    if IsLegacyAct3Stub() || akActionRef != Game.GetPlayer()
        return
    endif
    ObjectReference vreeRef = Game.GetFormFromFile(0x00002B34, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference maxsonRef = Game.GetFormFromFile(0x00002B35, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference liftTo4Ref = Game.GetFormFromFile(0x00002B43, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference liftTo3Ref = Game.GetFormFromFile(0x00002B44, "Vault13Chronicles.esp") as ObjectReference
    if akSender == vreeRef
        if !Self.IsRunning() && !Self.IsCompleted()
            Self.Start()
            if Self.GetStage() < 20
                Self.SetStage(20)
            endif
        endif
        ForceAllAct3Aliases()
        StartTimer(1.2, 91)
    elseif akSender == maxsonRef
        if !Self.IsRunning() && !Self.IsCompleted()
            Self.Start()
            if Self.GetStage() < 20
                Self.SetStage(20)
            endif
        endif
        SilenceMathiaIfTalking()
        ForceAllAct3Aliases()
        StartTimer(1.2, 92)
    elseif akSender == liftTo4Ref || akSender == liftTo3Ref
        StartTimer(0.6, 97)
    endif
EndEvent

Event OnInit()
    if IsLegacyAct3Stub()
        ForwardLegacyStubIfNeeded()
        return
    endif
    RegisterPlayerEvents()
    StartTimer(2.5, 1)
EndEvent

Event OnQuestInit()
    if IsLegacyAct3Stub()
        ForwardLegacyStubIfNeeded()
        return
    endif
    RegisterPlayerEvents()
    StartTimer(2.5, 1)
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
    if IsLegacyAct3Stub()
        ForwardLegacyStubIfNeeded()
        return
    endif
    RegisterPlayerEvents()
    StartTimer(2.5, 1)
EndEvent

Event Actor.OnItemEquipped(Actor akSender, Form akBaseObject, ObjectReference akReference)
    Form wattz2000 = Game.GetFormFromFile(0x00001108, "Vault13Chronicles.esp")
    if akBaseObject == wattz2000 && wattz2000 != None
        Debug.Notification("[Wattz 2000 Laser Rifle] Lost Hills optical array active: Overcharge every 4 hits (+30 AP / +20 HP)")
    endif
EndEvent

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
    if IsLegacyAct3Stub()
        ForwardLegacyStubIfNeeded()
        return
    endif
    CheckProgressionAndLevelGate()
    if Self.GetStage() >= 15 && Self.GetStage() < 40
        ApplyV13Act3Stage(Self.GetStage())
    endif
EndEvent

Event OnStageSet(int auiStageID, int auiItemID)
    if IsLegacyAct3Stub()
        ForwardLegacyStubIfNeeded()
        return
    endif
    ApplyV13Act3Stage(auiStageID)
    if Self.IsRunning()
        StartTimer(0.2, 1)
    endif
EndEvent

Event OnTimer(int aiTimerID)
    if IsLegacyAct3Stub()
        ForwardLegacyStubIfNeeded()
        return
    endif
    if aiTimerID == 1
        CheckProgressionAndLevelGate()
        if Self.GetStage() >= 40
            V13Act4QuestScript act4S = Game.GetFormFromFile(0x00007000, "Vault13Chronicles.esp") as V13Act4QuestScript
            if act4S != None
                act4S.WakeUpAct4()
            endif
        endif
        if !Self.IsRunning()
            CancelTimer(1)
            return
        endif
        Quest act2Quest = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as Quest
        if (Self.GetStage() >= 15 && (Self.GetStage() < 40 || !rewardsGiven || !Self.IsCompleted())) || (act2Quest != None && act2Quest.GetStage() >= 40 && Self.GetStage() < 40)
            StartTimer(2.5, 1)
        endif
    elseif aiTimerID == 91
        Scene vreeScene = Game.GetFormFromFile(0x00006102, "Vault13Chronicles.esp") as Scene
        Actor vreeAct = Game.GetFormFromFile(0x00002B34, "Vault13Chronicles.esp") as Actor
        if Self.IsRunning() && vreeScene != None && !bVreeHoloObtained && !vreeScene.IsPlaying() && !Utility.IsInMenuMode()
            if vreeAct == None || (!vreeAct.IsInDialogueWithPlayer() && !vreeAct.IsTalking())
                ForceAllAct3Aliases()
                vreeScene.Start()
            endif
        endif
    elseif aiTimerID == 92
        Scene maxsonScene = Game.GetFormFromFile(0x00006103, "Vault13Chronicles.esp") as Scene
        Actor maxsonAct = Game.GetFormFromFile(0x00002B35, "Vault13Chronicles.esp") as Actor
        if Self.IsRunning() && maxsonScene != None && !bMaxsonCouncilDone && !maxsonScene.IsPlaying() && !Utility.IsInMenuMode()
            if maxsonAct == None || (!maxsonAct.IsInDialogueWithPlayer() && !maxsonAct.IsTalking())
                ForceAllAct3Aliases()
                maxsonScene.Start()
            endif
        endif
    elseif aiTimerID == 93
        Scene vreeSc93 = Game.GetFormFromFile(0x00006102, "Vault13Chronicles.esp") as Scene
        Actor vreeAct93 = Game.GetFormFromFile(0x00002B34, "Vault13Chronicles.esp") as Actor
        if (vreeSc93 != None && vreeSc93.IsPlaying()) || Utility.IsInMenuMode() || (vreeAct93 != None && (vreeAct93.IsInDialogueWithPlayer() || vreeAct93.IsTalking()))
            StartTimer(3.0, 93)
            return
        endif
        if !bVreeHoloObtained
            GrantVreeAutopsyHolodisk()
        endif
    elseif aiTimerID == 94
        Scene maxsonSc94 = Game.GetFormFromFile(0x00006103, "Vault13Chronicles.esp") as Scene
        Actor maxsonAct94 = Game.GetFormFromFile(0x00002B35, "Vault13Chronicles.esp") as Actor
        if (maxsonSc94 != None && maxsonSc94.IsPlaying()) || Utility.IsInMenuMode() || (maxsonAct94 != None && (maxsonAct94.IsInDialogueWithPlayer() || maxsonAct94.IsTalking()))
            StartTimer(3.0, 94)
            return
        endif
        if !bMaxsonCouncilDone
            AuthorizeMaxsonCouncilSupport()
        endif
    elseif aiTimerID == 97
        ForceAllAct3Aliases()
    elseif aiTimerID == 95
        if Self.GetStage() != 15
            return
        endif
        Actor player95 = Game.GetPlayer()
        Cell v13Cell95 = Game.GetFormFromFile(0x00002100, "Vault13Chronicles.esp") as Cell
        Actor jac95 = Game.GetFormFromFile(0x00002110, "Vault13Chronicles.esp") as Actor
        Scene introSc95 = Game.GetFormFromFile(0x00006100, "Vault13Chronicles.esp") as Scene
        if player95 == None || v13Cell95 == None || player95.GetParentCell() != v13Cell95 || jac95 == None || jac95.IsDead()
            return
        endif
        if jac95.GetDistance(player95) > 900.0
            return
        endif
        if (introSc95 != None && introSc95.IsPlaying()) || jac95.IsInDialogueWithPlayer()
            return
        endif
        if Utility.IsInMenuMode() || jac95.IsTalking()
            if jacorenAct3WaitTicks < 12
                jacorenAct3WaitTicks += 1
                StartTimer(0.4, 95)
            endif
            return
        endif
        Topic act3GreetTopic = Game.GetFormFromFile(0x00006001, "Vault13Chronicles.esp") as Topic
        if act3GreetTopic != None
            jac95.Say(act3GreetTopic, player95, false)
        endif
        jacorenAct3WaitTicks = 0
        StartTimer(0.6, 96)
    elseif aiTimerID == 96
        if Self.GetStage() != 15
            return
        endif
        Actor player96 = Game.GetPlayer()
        Cell v13Cell96 = Game.GetFormFromFile(0x00002100, "Vault13Chronicles.esp") as Cell
        Actor jac96 = Game.GetFormFromFile(0x00002110, "Vault13Chronicles.esp") as Actor
        Scene introSc96 = Game.GetFormFromFile(0x00006100, "Vault13Chronicles.esp") as Scene
        if player96 == None || v13Cell96 == None || player96.GetParentCell() != v13Cell96 || jac96 == None || jac96.IsDead() || introSc96 == None
            return
        endif
        if introSc96.IsPlaying() || jac96.IsInDialogueWithPlayer()
            return
        endif
        if Utility.IsInMenuMode() || jac96.IsTalking()
            if jacorenAct3WaitTicks < 40
                jacorenAct3WaitTicks += 1
                StartTimer(0.4, 96)
            endif
            return
        endif
        ForceAllAct3Aliases()
        introSc96.Start()
    endif
EndEvent

Function SilentCompleteAct3ForJump()
    introShown = true
    bVreeHoloObtained = true
    bMaxsonCouncilDone = true
    rewardsGiven = true
    bStage40Rewarded = true
    if !Self.IsRunning() && !Self.IsCompleted()
        Self.Start()
    endif
    Self.SetObjectiveDisplayed(15, false, false)
    Self.SetObjectiveDisplayed(20, false, false)
    Self.SetObjectiveDisplayed(21, false, false)
    Self.SetObjectiveDisplayed(25, false, false)
    Self.SetObjectiveDisplayed(30, false, false)
    bApplyingAct3Stage = true
    Self.SetStage(40)
    bApplyingAct3Stage = false
    Self.CompleteAllObjectives()
    Self.CompleteQuest()
EndFunction
