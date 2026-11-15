Scriptname V13Act5QuestScript extends Quest

int hitCounter = 0
bool introShown = false
bool rewardsGiven = false
bool bVindicatorPreGranted = false
bool bStage30Done = false
bool bStage35Ready = false
bool bStage40Rewarded = false
bool bApplyingAct5Stage = false
bool bCathedralDisguiseBlown = false
bool bLauraKeyGiven = false
bool bLasherBadgeGiven = false
bool bMorpheusBadgeGiven = false
bool bGideonNullifierGiven = false
bool bFollowersStrikeDeployed = false
bool bPsychicShieldNotified = false
bool bMorpheusHostile = false
bool bLasherHostile = false
bool bMasterHostile = false
bool bMasterConfronted = false
bool bCountdownActive = false
bool bCathedralDetonated = false
bool bExileSceneTriggered = false
bool bDynamicEndingShown = false
bool bCathedralSanctuaryMigratedV2 = false
bool bCryptDoorAutoUnlocked = false
int iCountdownSecondsLeft = 240
int iPendingSceneID = 0
int iSceneRetryTicks = 0
int iPendingActSceneID = 0
int lastAppliedAct5Stage = 0
bool bCathedralJumpBusy = false
bool bPendingCathedralArrival = false
int iCathedralJumpRetries = 0
bool bCathedralCinematicActive = false
int iCathedralCinePhase = 0
InputEnableLayer kAct5CineLayer
int iAct5SirenInstance = -1
int iEndingMusicInstance = -1
bool bExileEndingCinematicActive = false
bool bExileEndingPlayed = false
bool bPendingExileEndingOnExit = false
int iExileCinePhase = 0
Actor kActiveExileDouble = None
bool bCathedralSanctuaryMigratedV3 = false
int iAct5CineReadyTicks = 0
ObjectReference kActiveCreditCardRef = None
bool bMasterLairExitMigratedV4 = false
int iExileCineFixRev = 0

bool Function IsNuclearCountdownActive()
    return bCountdownActive
EndFunction

bool Function IsPlayerInCathedral(Actor akPlayer)
    if akPlayer == None
        return false
    endif
    Cell pCell = akPlayer.GetParentCell()
    if pCell == None
        return false
    endif
    Cell cVault = Game.GetFormFromFile(0x00002D00, "Vault13Chronicles.esp") as Cell
    Cell cSanc = Game.GetFormFromFile(0x00002D80, "Vault13Chronicles.esp") as Cell
    return (cVault != None && pCell == cVault) || (cSanc != None && pCell == cSanc)
EndFunction

Function UpdateSanctuaryQuestTargetAlias()
    ObjectReference cryptDoor = Game.GetFormFromFile(0x00002D83, "Vault13Chronicles.esp") as ObjectReference
    Form lauraKey = Game.GetFormFromFile(0x000015A7, "Vault13Chronicles.esp")
    Form morphBadge = Game.GetFormFromFile(0x000015A8, "Vault13Chronicles.esp")
    Actor player = Game.GetPlayer()
    bool hasCryptAccess = bCryptDoorAutoUnlocked || (cryptDoor != None && !cryptDoor.IsLocked()) || (player != None && ((lauraKey != None && player.GetItemCount(lauraKey) > 0) || (morphBadge != None && player.GetItemCount(morphBadge) > 0)))
    if hasCryptAccess
        ForceQuestAlias(16, 0x00002D83)
        return
    endif
    Quest qSpy = Game.GetFormFromFile(0x000D4000, "Vault13Chronicles.esp") as Quest
    V13SideQuestFollowersSpyScript spyS = qSpy as V13SideQuestFollowersSpyScript
    Actor laura = Game.GetFormFromFile(0x00002D32, "Vault13Chronicles.esp") as Actor
    if !bLauraKeyGiven && spyS != None && spyS.AreFollowersSupportingCathedral() && laura != None && !laura.IsDead()
        ForceQuestAlias(16, 0x00002D32)
        return
    endif
    Actor morpheus = Game.GetFormFromFile(0x00002D12, "Vault13Chronicles.esp") as Actor
    if morpheus != None && (!morpheus.IsDead() || (morphBadge != None && morpheus.GetItemCount(morphBadge) > 0))
        ForceQuestAlias(16, 0x00002D12)
    else
        ForceQuestAlias(16, 0x00002D83)
    endif
EndFunction

Function SyncCathedralOptionalObjectives()
    int stg = Self.GetStage()
    if stg < 20 || stg >= 29 || bCountdownActive || bCathedralDetonated
        if Self.IsObjectiveDisplayed(22)
            Self.SetObjectiveDisplayed(22, false, false)
        endif
        if Self.IsObjectiveDisplayed(23)
            Self.SetObjectiveDisplayed(23, false, false)
        endif
        if Self.IsObjectiveDisplayed(24)
            Self.SetObjectiveDisplayed(24, false, false)
        endif
        return
    endif
    Actor player = Game.GetPlayer()
    if player == None
        return
    endif
    Cell pCell = player.GetParentCell()
    Cell vaultCell = Game.GetFormFromFile(0x00002D00, "Vault13Chronicles.esp") as Cell
    Cell sanctCell = Game.GetFormFromFile(0x00002D80, "Vault13Chronicles.esp") as Cell
    bool inVault = (vaultCell != None && pCell == vaultCell)
    bool inSanct = (sanctCell != None && pCell == sanctCell)

    Form psyNull = Game.GetFormFromFile(0x00001333, "Vault13Chronicles.esp")
    Actor gideon = Game.GetFormFromFile(0x00002D34, "Vault13Chronicles.esp") as Actor
    if bGideonNullifierGiven || (psyNull != None && player.GetItemCount(psyNull) > 0)
        if Self.IsObjectiveDisplayed(22)
            Self.SetObjectiveCompleted(22, true)
            Self.SetObjectiveDisplayed(22, false, false)
        endif
    elseif gideon != None && gideon.IsDead()
        if Self.IsObjectiveDisplayed(22)
            Self.SetObjectiveDisplayed(22, false, false)
        endif
    elseif bLauraKeyGiven || inVault
        if !Self.IsObjectiveDisplayed(22)
            Self.SetObjectiveDisplayed(22, true, false)
        endif
    endif

    if bLauraKeyGiven || inVault
        if !Self.IsObjectiveDisplayed(23)
            Self.SetObjectiveDisplayed(23, true, false)
        endif
    endif

    Form morphBadge = Game.GetFormFromFile(0x000015A8, "Vault13Chronicles.esp")
    Actor morpheus = Game.GetFormFromFile(0x00002D12, "Vault13Chronicles.esp") as Actor
    bool hasBadge = (morphBadge != None && player.GetItemCount(morphBadge) > 0)
    if bMorpheusBadgeGiven || bMasterConfronted || hasBadge
        if Self.IsObjectiveDisplayed(24)
            Self.SetObjectiveCompleted(24, true)
            Self.SetObjectiveDisplayed(24, false, false)
        endif
    elseif inVault || (morpheus != None && morpheus.IsDead() && !hasBadge)
        if Self.IsObjectiveDisplayed(24)
            Self.SetObjectiveDisplayed(24, false, false)
        endif
    elseif inSanct && bLauraKeyGiven
        if !Self.IsObjectiveDisplayed(24)
            Self.SetObjectiveDisplayed(24, true, false)
        endif
    endif
EndFunction

Function TryUnlockCathedralCryptDoor(bool abNotify)
    ObjectReference cryptDoor = Game.GetFormFromFile(0x00002D83, "Vault13Chronicles.esp") as ObjectReference
    if cryptDoor != None && cryptDoor.IsLocked()
        cryptDoor.Lock(false, false)
        bCryptDoorAutoUnlocked = true
        if abNotify
            Debug.Notification("[La Catedral] ¡Acceso a la Cripta Subterránea desbloqueado hacia el Refugio del Futuro!")
        endif
    elseif cryptDoor != None && !cryptDoor.IsLocked()
        bCryptDoorAutoUnlocked = true
    endif
    UpdateSanctuaryQuestTargetAlias()
EndFunction

Function MigrateCathedralSanctuaryLiveSave()
    if bCathedralSanctuaryMigratedV3
        return
    endif
    ObjectReference sanctAnchor = Game.GetFormFromFile(0x00002D82, "Vault13Chronicles.esp") as ObjectReference
    if sanctAnchor == None
        return
    endif
    bCathedralSanctuaryMigratedV2 = true

    Faction raiderFact = Game.GetFormFromFile(0x0001CBED, "Fallout4.esm") as Faction
    Faction smFact = Game.GetFormFromFile(0x00058305, "Fallout4.esm") as Faction
    Faction playerFac = Game.GetFormFromFile(0x0001C21C, "Fallout4.esm") as Faction
    Faction cultCivFac = Game.GetFormFromFile(0x00001C59, "Vault13Chronicles.esp") as Faction
    Faction folStrikeFac = Game.GetFormFromFile(0x00001C5A, "Vault13Chronicles.esp") as Faction
    if smFact != None
        smFact.SetAlly(smFact, false, false)
        if cultCivFac != None
            smFact.SetAlly(cultCivFac, false, false)
        endif
    endif
    if folStrikeFac != None && cultCivFac != None
        folStrikeFac.SetAlly(cultCivFac, false, false)
    endif

    int[] unityFids = new int[10]
    unityFids[0] = 0x00002D11
    unityFids[1] = 0x00002D12
    unityFids[2] = 0x00002D33
    unityFids[3] = 0x00002D20
    unityFids[4] = 0x00002D21
    unityFids[5] = 0x00002D22
    unityFids[6] = 0x00002D25
    unityFids[7] = 0x00002D26
    unityFids[8] = 0x00002D84
    unityFids[9] = 0x00002D85
    int uIdx = 0
    while uIdx < 10
        Actor uAct = Game.GetFormFromFile(unityFids[uIdx], "Vault13Chronicles.esp") as Actor
        if uAct != None
            if raiderFact != None && uAct.IsInFaction(raiderFact)
                uAct.RemoveFromFaction(raiderFact)
            endif
            if smFact != None && !uAct.IsInFaction(smFact)
                uAct.AddToFaction(smFact)
            endif
        endif
        uIdx += 1
    endwhile

    int[] civFids = new int[5]
    civFids[0] = 0x00002D32
    civFids[1] = 0x00002D34
    civFids[2] = 0x00002D86
    civFids[3] = 0x00002D87
    civFids[4] = 0x00002D88
    bool bPanicInit = bCathedralDisguiseBlown || bLasherHostile || bMorpheusHostile || bCountdownActive
    int cvIdx = 0
    while cvIdx < 5
        Actor civAct = Game.GetFormFromFile(civFids[cvIdx], "Vault13Chronicles.esp") as Actor
        if civAct != None
            if cvIdx >= 2 && civAct.IsDead()
                civAct.Resurrect()
            endif
            if playerFac != None && civAct.IsInFaction(playerFac)
                civAct.RemoveFromFaction(playerFac)
            endif
            if cultCivFac != None && !civAct.IsInFaction(cultCivFac)
                civAct.AddToFaction(cultCivFac)
            endif
            if civAct.IsInCombat()
                civAct.StopCombat()
            endif
            civAct.SetValue(Game.GetAggressionAV(), 0.0)
            if cvIdx < 2
                civAct.SetValue(Game.GetConfidenceAV(), 2.0)
            elseif bPanicInit
                civAct.SetValue(Game.GetConfidenceAV(), 0.0)
            else
                civAct.SetValue(Game.GetConfidenceAV(), 2.0)
            endif
            civAct.EvaluatePackage()
        endif
        cvIdx += 1
    endwhile

    int[] fScoutFids = new int[2]
    fScoutFids[0] = 0x00002D35
    fScoutFids[1] = 0x00002D36
    int fsIdx = 0
    while fsIdx < 2
        Actor fsAct = Game.GetFormFromFile(fScoutFids[fsIdx], "Vault13Chronicles.esp") as Actor
        if fsAct != None
            if folStrikeFac != None && !fsAct.IsInFaction(folStrikeFac)
                fsAct.AddToFaction(folStrikeFac)
            endif
            if !bCathedralDisguiseBlown && playerFac != None && fsAct.IsInFaction(playerFac)
                fsAct.RemoveFromFaction(playerFac)
            endif
            fsAct.EvaluatePackage()
        endif
        fsIdx += 1
    endwhile

    Cell vaultCell = Game.GetFormFromFile(0x00002D00, "Vault13Chronicles.esp") as Cell
    Cell sanctCell = Game.GetFormFromFile(0x00002D80, "Vault13Chronicles.esp") as Cell
    if vaultCell != None
        Actor laura = Game.GetFormFromFile(0x00002D32, "Vault13Chronicles.esp") as Actor
        if laura != None && !laura.IsDead() && laura.GetParentCell() == vaultCell
            laura.MoveTo(sanctAnchor, 0.0, 0.0, 0.0, true)
            laura.SetPosition(1635.0, 5210.0, 252.8)
            laura.SetAngle(0.0, 0.0, 90.0)
            laura.EvaluatePackage()
        endif
        Actor f1 = Game.GetFormFromFile(0x00002D35, "Vault13Chronicles.esp") as Actor
        if f1 != None && !f1.IsDead() && f1.GetParentCell() == vaultCell
            f1.MoveTo(sanctAnchor, 0.0, 0.0, 0.0, true)
            f1.SetPosition(2410.0, 5140.0, 252.8)
            f1.SetAngle(0.0, 0.0, 14.3)
            f1.EvaluatePackage()
        endif
        Actor f2 = Game.GetFormFromFile(0x00002D36, "Vault13Chronicles.esp") as Actor
        if f2 != None && !f2.IsDead() && f2.GetParentCell() == vaultCell
            f2.MoveTo(sanctAnchor, 0.0, 0.0, 0.0, true)
            f2.SetPosition(2595.0, 5140.0, 252.8)
            f2.SetAngle(0.0, 0.0, 343.8)
            f2.EvaluatePackage()
        endif
    endif
    Actor lasher = Game.GetFormFromFile(0x00002D33, "Vault13Chronicles.esp") as Actor
    if lasher != None && !lasher.IsDead() && ((vaultCell != None && lasher.GetParentCell() == vaultCell) || (sanctCell != None && lasher.GetParentCell() == sanctCell && (lasher.GetPositionZ() > 350.0 || lasher.GetPositionY() < 2900.0)))
        lasher.MoveTo(sanctAnchor, 0.0, 0.0, 0.0, true)
        lasher.SetPosition(2240.0, 3100.0, 253.1)
        lasher.SetAngle(0.0, 0.0, 0.0)
        lasher.EvaluatePackage()
    endif
    Actor morpheus = Game.GetFormFromFile(0x00002D12, "Vault13Chronicles.esp") as Actor
    if morpheus != None && !morpheus.IsDead() && Self.GetStage() != 24 && ((vaultCell != None && morpheus.GetParentCell() == vaultCell) || (sanctCell != None && morpheus.GetParentCell() == sanctCell && morpheus.GetPositionZ() > 350.0))
        morpheus.MoveTo(sanctAnchor, 0.0, 0.0, 0.0, true)
        morpheus.SetPosition(2172.8, 2710.3, 254.3)
        morpheus.SetAngle(0.0, 0.0, 0.0)
        morpheus.EvaluatePackage()
    endif
    Actor guard84 = Game.GetFormFromFile(0x00002D84, "Vault13Chronicles.esp") as Actor
    if guard84 != None && !guard84.IsDead() && ((vaultCell != None && guard84.GetParentCell() == vaultCell) || (sanctCell != None && guard84.GetParentCell() == sanctCell && guard84.GetPositionZ() > 350.0))
        guard84.MoveTo(sanctAnchor, 0.0, 0.0, 0.0, true)
        guard84.SetPosition(1995.0, 2660.0, 268.0)
        guard84.SetAngle(0.0, 0.0, 14.32)
        guard84.EvaluatePackage()
    endif

    Actor player = Game.GetPlayer()
    if player != None && sanctCell != None && player.GetParentCell() == sanctCell
        ObjectReference col37 = Game.GetFormFromFile(0x00098037, "Vault13Chronicles.esp") as ObjectReference
        if col37 != None
            col37.DisableNoWait()
        endif
        ObjectReference col38 = Game.GetFormFromFile(0x00098038, "Vault13Chronicles.esp") as ObjectReference
        if col38 != None
            col38.DisableNoWait()
        endif
        if player.GetPositionX() > 915.0 && player.GetPositionX() < 1100.0 && player.GetPositionY() > 4360.0 && player.GetPositionY() < 4580.0 && player.GetPositionZ() < -40.0
            player.SetPosition(878.35, 4424.85, -132.62)
            player.SetAngle(0.0, 0.0, 184.3)
        endif
        bCathedralSanctuaryMigratedV3 = true
    endif
    SyncCathedralMutantHostility()
    SyncSanctuaryAcolytePanic()
    MigrateGideonToPsychicCell()
    UpdateSanctuaryQuestTargetAlias()
EndFunction

Function MigrateGideonToPsychicCell()
    Actor gideon = Game.GetFormFromFile(0x00002D34, "Vault13Chronicles.esp") as Actor
    if gideon == None
        return
    endif
    if !bCountdownActive && !bCathedralDetonated && gideon.IsDead() && !bGideonNullifierGiven
        gideon.Resurrect()
    endif
    gideon.SetValue(Game.GetAggressionAV(), 0.0)
    gideon.SetValue(Game.GetConfidenceAV(), 2.0)
    if !gideon.IsDead() && (gideon.GetPositionZ() < -810.0 || gideon.GetPositionY() > -400.0)
        if gideon.IsInCombat()
            gideon.StopCombat()
        endif
        gideon.SetPosition(-245.0, -898.0, -768.0)
        gideon.SetAngle(0.0, 0.0, 270.0)
        gideon.EvaluatePackage()
    endif
    ObjectReference psyCellLight = Game.GetFormFromFile(0x00081049, "Vault13Chronicles.esp") as ObjectReference
    if psyCellLight != None && (psyCellLight.GetPositionZ() < -700.0 || psyCellLight.GetPositionY() > -400.0)
        psyCellLight.SetPosition(-245.0, -898.0, -640.0)
    endif
EndFunction

Function SyncSanctuaryAcolytePanic()
    bool bPanic = bCathedralDisguiseBlown || bLasherHostile || bMorpheusHostile || bCountdownActive
    Actor player = Game.GetPlayer()
    Cell sanctCell = Game.GetFormFromFile(0x00002D80, "Vault13Chronicles.esp") as Cell
    Actor f1 = Game.GetFormFromFile(0x00002D35, "Vault13Chronicles.esp") as Actor
    Actor f2 = Game.GetFormFromFile(0x00002D36, "Vault13Chronicles.esp") as Actor
    if !bPanic && player != None && sanctCell != None && player.GetParentCell() == sanctCell
        Actor g84 = Game.GetFormFromFile(0x00002D84, "Vault13Chronicles.esp") as Actor
        Actor g85 = Game.GetFormFromFile(0x00002D85, "Vault13Chronicles.esp") as Actor
        Actor lash = Game.GetFormFromFile(0x00002D33, "Vault13Chronicles.esp") as Actor
        Actor morph = Game.GetFormFromFile(0x00002D12, "Vault13Chronicles.esp") as Actor
        if (g84 != None && !g84.IsDead() && g84.IsInCombat()) || (g85 != None && !g85.IsDead() && g85.IsInCombat()) || (lash != None && !lash.IsDead() && lash.IsInCombat()) || (morph != None && !morph.IsDead() && morph.IsInCombat()) || (bFollowersStrikeDeployed && ((f1 != None && !f1.IsDead() && f1.IsInCombat()) || (f2 != None && !f2.IsDead() && f2.IsInCombat())))
            bPanic = true
            if !bCathedralDisguiseBlown
                bCathedralDisguiseBlown = true
                if bFollowersStrikeDeployed
                    Faction playerFac = Game.GetFormFromFile(0x0001C21C, "Fallout4.esm") as Faction
                    if playerFac != None
                        if f1 != None && !f1.IsDead() && !f1.IsInFaction(playerFac)
                            f1.AddToFaction(playerFac)
                            f1.EvaluatePackage()
                        endif
                        if f2 != None && !f2.IsDead() && !f2.IsInFaction(playerFac)
                            f2.AddToFaction(playerFac)
                            f2.EvaluatePackage()
                        endif
                    endif
                endif
            endif
        elseif player.IsInCombat()
            bPanic = true
        endif
    endif
    ActorValue confAV = Game.GetConfidenceAV()
    ActorValue fleeAV = Game.GetFormFromFile(0x00214027, "Fallout4.esm") as ActorValue
    Keyword kwLink01 = Game.GetFormFromFile(0x0005D5E6, "Fallout4.esm") as Keyword
    Idle cowerIdle = Game.GetFormFromFile(0x0020AC3C, "Fallout4.esm") as Idle
    ObjectReference mk2D89 = Game.GetFormFromFile(0x00002D89, "Vault13Chronicles.esp") as ObjectReference
    int wIdx = 0
    while wIdx < 3
        Actor wAct = Game.GetFormFromFile(0x00002D86 + wIdx, "Vault13Chronicles.esp") as Actor
        if wAct != None && !wAct.IsDead()
            bool bEval = false
            if !bPanic && wIdx == 2 && wAct.Is3DLoaded() && Math.abs(wAct.GetPositionY() - 3260.0) < 45.0
                wAct.SetPosition(2120.0, 3850.0, 253.9)
                wAct.SetAngle(0.0, 0.0, 180.0)
                bEval = true
            endif
            ObjectReference wantMk = Game.GetFormFromFile(0x00002D89 + wIdx, "Vault13Chronicles.esp") as ObjectReference
            if kwLink01 != None && wantMk != None
                if wantMk.IsDisabled()
                    wantMk.EnableNoWait()
                endif
                if wAct.GetLinkedRef(kwLink01) != wantMk
                    wAct.SetLinkedRef(wantMk, kwLink01)
                    bEval = true
                endif
            endif
            float curConf = wAct.GetValue(confAV)
            float curFlee = 0.0
            if fleeAV != None
                curFlee = wAct.GetValue(fleeAV)
            endif
            if bPanic
                if fleeAV != None && curFlee < 0.5
                    wAct.SetValue(fleeAV, 1.0)
                    bEval = true
                endif
                if curConf > 0.5
                    wAct.SetValue(confAV, 0.0)
                    curConf = 0.0
                    bEval = true
                endif
                if wAct.IsInCombat()
                    wAct.StopCombat()
                    bEval = true
                endif
            else
                if fleeAV != None && curFlee > 0.5
                    wAct.SetValue(fleeAV, 0.0)
                    bEval = true
                endif
                if curConf < 1.5
                    wAct.SetValue(confAV, 2.0)
                    curConf = 2.0
                    bEval = true
                endif
            endif
            if bEval
                wAct.EvaluatePackage(true)
            endif
            if bPanic && curConf <= 0.5 && wAct.Is3DLoaded() && cowerIdle != None
                float startX = 1975.0
                float startY = 3610.0
                if wIdx == 1
                    startX = 2240.0
                    startY = 3610.0
                elseif wIdx == 2
                    startX = 2120.0
                    startY = 3850.0
                endif
                float dxS = wAct.GetPositionX() - startX
                float dyS = wAct.GetPositionY() - startY
                bool bNearCover = (wantMk != None && wAct.GetDistance(wantMk) <= 155.0) || (mk2D89 != None && wAct.GetDistance(mk2D89) <= 155.0)
                if !bEval && (bNearCover || (dxS * dxS + dyS * dyS) <= 625.0)
                    wAct.PlayIdle(cowerIdle)
                endif
            endif
        endif
        wIdx += 1
    endwhile
EndFunction

bool Function IsPlayerDisguisedAsCathedral()
    if bCathedralDisguiseBlown
        return false
    endif
    Actor player = Game.GetPlayer()
    Form purpleRobe = Game.GetFormFromFile(0x00001330, "Vault13Chronicles.esp")
    if player != None && purpleRobe != None && player.IsEquipped(purpleRobe)
        return true
    endif
    return false
EndFunction

Function SyncCathedralMutantHostility()
    Faction smFac = Game.GetFormFromFile(0x00058305, "Fallout4.esm") as Faction
    Faction playerFac = Game.GetFormFromFile(0x0001C21C, "Fallout4.esm") as Faction
    Faction raiderFac = Game.GetFormFromFile(0x0001CBED, "Fallout4.esm") as Faction
    Faction cultCivFac = Game.GetFormFromFile(0x00001C59, "Vault13Chronicles.esp") as Faction
    Faction folStrikeFac = Game.GetFormFromFile(0x00001C5A, "Vault13Chronicles.esp") as Faction
    Cell wshCell = Game.GetFormFromFile(0x00002900, "Vault13Chronicles.esp") as Cell
    Actor player = Game.GetPlayer()
    if smFac != None
        smFac.SetAlly(smFac, false, false)
        if cultCivFac != None
            smFac.SetAlly(cultCivFac, false, false)
        endif
    endif
    if folStrikeFac != None && cultCivFac != None
        folStrikeFac.SetAlly(cultCivFac, false, false)
    endif
    if !bFollowersStrikeDeployed
        int fIdx = 0
        while fIdx < 2
            Actor fScout = Game.GetFormFromFile(0x00002D35 + fIdx, "Vault13Chronicles.esp") as Actor
            if fScout != None
                if fScout.IsInCombat()
                    fScout.StopCombat()
                endif
                if !fScout.IsDisabled()
                    fScout.DisableNoWait()
                endif
            endif
            fIdx += 1
        endwhile
    endif
    bool bDisguiseOk = false
    if smFac != None && playerFac != None && player != None
        if IsPlayerInCathedral(player) && IsPlayerDisguisedAsCathedral()
            bDisguiseOk = true
            smFac.SetEnemy(playerFac, true, true)
        elseif wshCell == None || player.GetParentCell() != wshCell
            smFac.SetEnemy(playerFac, false, false)
        endif
    endif
    int[] uFids = new int[10]
    uFids[0] = 0x00002D11
    uFids[1] = 0x00002D12
    uFids[2] = 0x00002D33
    uFids[3] = 0x00002D20
    uFids[4] = 0x00002D21
    uFids[5] = 0x00002D22
    uFids[6] = 0x00002D25
    uFids[7] = 0x00002D26
    uFids[8] = 0x00002D84
    uFids[9] = 0x00002D85
    int uIdx = 0
    while uIdx < 10
        int uFid = uFids[uIdx]
        Actor uAct = Game.GetFormFromFile(uFid, "Vault13Chronicles.esp") as Actor
        if uAct != None && !uAct.IsDead()
            if raiderFac != None && uAct.IsInFaction(raiderFac)
                uAct.RemoveFromFaction(raiderFac)
            endif
            if playerFac != None && uAct.IsInFaction(playerFac)
                uAct.RemoveFromFaction(playerFac)
            endif
            if smFac != None && !uAct.IsInFaction(smFac)
                uAct.AddToFaction(smFac)
            endif
            if uAct.IsInCombat()
                Actor cTgt = uAct.GetCombatTarget()
                bool bFriendlyTgt = (cTgt != None && cTgt != player && ((smFac != None && cTgt.IsInFaction(smFac)) || (cultCivFac != None && cTgt.IsInFaction(cultCivFac))))
                if bDisguiseOk && (uFid == 0x00002D84 || uFid == 0x00002D85 || (uFid == 0x00002D33 && !bLasherHostile) || (uFid == 0x00002D12 && !bMorpheusHostile))
                    if cTgt == None || cTgt == player || bFriendlyTgt
                        uAct.StopCombat()
                    endif
                elseif bFriendlyTgt
                    uAct.StopCombat()
                    if !bDisguiseOk && player != None && uAct.GetParentCell() == player.GetParentCell()
                        if (uFid != 0x00002D11 && uFid != 0x00002D12 && uFid != 0x00002D33) || (uFid == 0x00002D33 && (bLasherHostile || bCathedralDisguiseBlown || bCountdownActive)) || (uFid == 0x00002D12 && (bMorpheusHostile || bCathedralDisguiseBlown || bCountdownActive))
                            uAct.StartCombat(player)
                        endif
                    endif
                endif
            endif
        endif
        uIdx += 1
    endwhile
    EnsureCathedralMutantWeapons()
EndFunction

Function EnsureCathedralMutantWeapons()
    Form wGat = Game.GetFormFromFile(0x000E27BC, "Fallout4.esm")
    Weapon wMinigun = Game.GetFormFromFile(0x0001F669, "Fallout4.esm") as Weapon
    Ammo a5mm = Game.GetFormFromFile(0x0001F66C, "Fallout4.esm") as Ammo
    Weapon wAssault = Game.GetFormFromFile(0x0000463F, "Fallout4.esm") as Weapon
    Ammo a556 = Game.GetFormFromFile(0x0001F278, "Fallout4.esm") as Ammo
    Weapon wSledge = Game.GetFormFromFile(0x000FF964, "Fallout4.esm") as Weapon
    int[] praeFids = new int[5]
    praeFids[0] = 0x00002D84
    praeFids[1] = 0x00002D85
    praeFids[2] = 0x00002D20
    praeFids[3] = 0x00002D21
    praeFids[4] = 0x00002D22
    int mIdx = 0
    while mIdx < 5
        Actor smAct = Game.GetFormFromFile(praeFids[mIdx], "Vault13Chronicles.esp") as Actor
        if smAct != None && !smAct.IsDead()
            if wGat != None && smAct.GetItemCount(wGat) > 0
                smAct.RemoveItem(wGat, smAct.GetItemCount(wGat), true)
            endif
            if wSledge != None && smAct.GetItemCount(wSledge) < 1
                smAct.AddItem(wSledge, 1, true)
            endif
            Weapon prefWep = wMinigun
            if (mIdx % 2) == 1 && wAssault != None
                prefWep = wAssault
            endif
            if wMinigun != None && smAct.GetItemCount(wMinigun) < 1
                smAct.AddItem(wMinigun, 1, true)
            endif
            if a5mm != None && smAct.GetItemCount(a5mm) < 120
                smAct.AddItem(a5mm, 300 - smAct.GetItemCount(a5mm), true)
            endif
            if wAssault != None && smAct.GetItemCount(wAssault) < 1
                smAct.AddItem(wAssault, 1, true)
            endif
            if a556 != None && smAct.GetItemCount(a556) < 80
                smAct.AddItem(a556, 160 - smAct.GetItemCount(a556), true)
            endif
            if smAct.Is3DLoaded() && prefWep != None && !smAct.IsEquipped(prefWep)
                smAct.EquipItem(prefWep, false, true)
            endif
        endif
        mIdx += 1
    endwhile
EndFunction

Function BlowCathedralDisguise()
    if !bCathedralDisguiseBlown
        bCathedralDisguiseBlown = true
        Debug.Notification("[La Catedral] ¡Tu disfraz de los Hijos de la Catedral ha quedado al descubierto!")
    endif
    if bFollowersStrikeDeployed
        Faction playerFac = Game.GetFormFromFile(0x0001C21C, "Fallout4.esm") as Faction
        Actor f1 = Game.GetFormFromFile(0x00002D35, "Vault13Chronicles.esp") as Actor
        Actor f2 = Game.GetFormFromFile(0x00002D36, "Vault13Chronicles.esp") as Actor
        if playerFac != None
            if f1 != None && !f1.IsDead() && !f1.IsInFaction(playerFac)
                f1.AddToFaction(playerFac)
                f1.EvaluatePackage()
            endif
            if f2 != None && !f2.IsDead() && !f2.IsInFaction(playerFac)
                f2.AddToFaction(playerFac)
                f2.EvaluatePackage()
            endif
        endif
    endif
    SyncCathedralMutantHostility()
    SyncSanctuaryAcolytePanic()
EndFunction

bool Function IsPlayerWearingPsychicNullifier()
    Actor player = Game.GetPlayer()
    Form psyNull = Game.GetFormFromFile(0x00001333, "Vault13Chronicles.esp")
    if player != None && psyNull != None && player.IsEquipped(psyNull)
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

Function SyncMasterVaultExitAndGates()
    int[] gateFids = new int[10]
    gateFids[0] = 0x00080009
    gateFids[1] = 0x00080033
    gateFids[2] = 0x0008003E
    gateFids[3] = 0x0008003F
    gateFids[4] = 0x00080040
    gateFids[5] = 0x00080042
    gateFids[6] = 0x00080D15
    gateFids[7] = 0x00080D16
    gateFids[8] = 0x00080D17
    gateFids[9] = 0x00080D18
    int gIdx = 0
    while gIdx < 10
        ObjectReference gateRef = Game.GetFormFromFile(gateFids[gIdx], "Vault13Chronicles.esp") as ObjectReference
        if gateRef != None && !gateRef.IsDisabled()
            gateRef.DisableNoWait()
        endif
        gIdx += 1
    endwhile
    ObjectReference d2D03 = Game.GetFormFromFile(0x00002D03, "Vault13Chronicles.esp") as ObjectReference
    if d2D03 != None
        d2D03.SetLockLevel(0)
        d2D03.Lock(false, false)
        if !d2D03.IsDisabled()
            d2D03.DisableNoWait()
        endif
    endif
    ObjectReference d2D3F = Game.GetFormFromFile(0x00002D3F, "Vault13Chronicles.esp") as ObjectReference
    if d2D3F != None
        if d2D3F.IsDisabled()
            d2D3F.EnableNoWait()
        endif
        d2D3F.SetLockLevel(0)
        d2D3F.Lock(false, false)
    endif
    ObjectReference d2D01 = Game.GetFormFromFile(0x00002D01, "Vault13Chronicles.esp") as ObjectReference
    if d2D01 != None
        if d2D01.IsDisabled()
            d2D01.EnableNoWait()
        endif
        d2D01.SetLockLevel(0)
        d2D01.Lock(false, false)
    endif
    if !bCathedralDetonated
        ObjectReference d2D81 = Game.GetFormFromFile(0x00002D81, "Vault13Chronicles.esp") as ObjectReference
        if d2D81 != None
            if d2D81.IsDisabled()
                d2D81.EnableNoWait()
            endif
            d2D81.SetLockLevel(0)
            d2D81.Lock(false, false)
        endif
        ObjectReference cathDoor = Game.GetFormFromFile(0x00003509, "Vault13Chronicles.esp") as ObjectReference
        if cathDoor != None
            if cathDoor.IsDisabled()
                cathDoor.EnableNoWait()
            endif
            cathDoor.SetLockLevel(0)
            cathDoor.Lock(false, false)
        endif
    endif

    int[] junkFids = new int[5]
    junkFids[0] = 0x000804F1
    junkFids[1] = 0x00080217
    junkFids[2] = 0x00080D6A
    junkFids[3] = 0x0008000C
    junkFids[4] = 0x000804DA
    int jfIdx = 0
    while jfIdx < 5
        ObjectReference jfRef = Game.GetFormFromFile(junkFids[jfIdx], "Vault13Chronicles.esp") as ObjectReference
        if jfRef != None && !jfRef.IsDisabled()
            jfRef.DisableNoWait()
        endif
        jfIdx += 1
    endwhile

    int[] keyFids = new int[3]
    keyFids[0] = 0x00099D3E
    keyFids[1] = 0x000A02D8
    keyFids[2] = 0x00099770
    Actor playerClean = Game.GetPlayer()
    ObjectReference tb807D2 = Game.GetFormFromFile(0x000807D2, "Vault13Chronicles.esp") as ObjectReference
    int kfIdx = 0
    while kfIdx < 3
        Form keyForm = Game.GetFormFromFile(keyFids[kfIdx], "Fallout4.esm")
        if keyForm != None
            if playerClean != None && playerClean.GetItemCount(keyForm) > 0
                playerClean.RemoveItem(keyForm, playerClean.GetItemCount(keyForm), true, None)
            endif
            if tb807D2 != None && tb807D2.GetItemCount(keyForm) > 0
                tb807D2.RemoveItem(keyForm, tb807D2.GetItemCount(keyForm), true, None)
            endif
        endif
        kfIdx += 1
    endwhile

    MigrateGideonToPsychicCell()
    bMasterLairExitMigratedV4 = true
EndFunction

Function SyncCathedralExteriorDestruction(bool abDestroyed)
    Actor playerChk = Game.GetPlayer()
    if abDestroyed && ((playerChk != None && IsPlayerInCathedral(playerChk)) || (bCountdownActive && !bCathedralDetonated))
        abDestroyed = false
    endif
    ObjectReference cathDoor = Game.GetFormFromFile(0x00003509, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference craterSmoke = Game.GetFormFromFile(0x00003668, "Vault13Chronicles.esp") as ObjectReference
    if abDestroyed
        if cathDoor != None
            cathDoor.SetLockLevel(253)
            cathDoor.Lock(true, false)
            if !cathDoor.IsDisabled()
                cathDoor.DisableNoWait()
            endif
        endif
        int iIntact = 0
        while iIntact < 6
            ObjectReference intactRef = Game.GetFormFromFile(0x00009960 + iIntact, "Vault13Chronicles.esp") as ObjectReference
            if intactRef != None && !intactRef.IsDisabled()
                intactRef.DisableNoWait()
            endif
            iIntact += 1
        endwhile
        if craterSmoke != None
            if craterSmoke.IsDisabled()
                craterSmoke.EnableNoWait()
            endif
            if craterSmoke.Is3DLoaded()
                if Math.abs(craterSmoke.GetPositionX() - (-18880.0)) > 5.0 || Math.abs(craterSmoke.GetPositionY() - (-31650.0)) > 5.0 || Math.abs(craterSmoke.GetPositionZ() - 26.0) > 5.0
                    craterSmoke.SetPosition(-18880.0, -31650.0, 26.0)
                endif
            endif
        endif
        int iRuin = 0
        while iRuin < 15
            ObjectReference ruinRef = Game.GetFormFromFile(0x00009966 + iRuin, "Vault13Chronicles.esp") as ObjectReference
            if ruinRef != None
                if ruinRef.IsDisabled()
                    ruinRef.EnableNoWait()
                endif
                if ruinRef.Is3DLoaded()
                    float rTargetX = 0.0
                    float rTargetY = 0.0
                    float rTargetZ = 0.0
                    bool hasRuinPos = true
                    if iRuin == 7
                        rTargetX = -19500.0
                        rTargetY = -31620.0
                        rTargetZ = 58.0
                    elseif iRuin == 8
                        rTargetX = -20040.0
                        rTargetY = -31580.0
                        rTargetZ = 55.0
                    elseif iRuin == 9
                        rTargetX = -18880.0
                        rTargetY = -31600.0
                        rTargetZ = 55.0
                    elseif iRuin == 10
                        rTargetX = -19500.0
                        rTargetY = -31650.0
                        rTargetZ = 26.0
                    elseif iRuin == 11
                        rTargetX = -20020.0
                        rTargetY = -31650.0
                        rTargetZ = 26.0
                    elseif iRuin == 12
                        rTargetX = -19500.0
                        rTargetY = -31720.0
                        rTargetZ = 180.0
                    elseif iRuin == 13
                        rTargetX = -19980.0
                        rTargetY = -31700.0
                        rTargetZ = 170.0
                    else
                        hasRuinPos = false
                    endif
                    if hasRuinPos && (Math.abs(ruinRef.GetPositionX() - rTargetX) > 5.0 || Math.abs(ruinRef.GetPositionY() - rTargetY) > 5.0 || Math.abs(ruinRef.GetPositionZ() - rTargetZ) > 5.0)
                        ruinRef.SetPosition(rTargetX, rTargetY, rTargetZ)
                    endif
                endif
            endif
            iRuin += 1
        endwhile
    else
        if cathDoor != None
            if cathDoor.IsDisabled()
                cathDoor.EnableNoWait()
            endif
            cathDoor.SetLockLevel(0)
            cathDoor.Lock(false, false)
        endif
        ObjectReference sanctDoor = Game.GetFormFromFile(0x00002D81, "Vault13Chronicles.esp") as ObjectReference
        if sanctDoor != None
            if sanctDoor.IsDisabled()
                sanctDoor.EnableNoWait()
            endif
            sanctDoor.SetLockLevel(0)
            sanctDoor.Lock(false, false)
        endif
        int iIntactEn = 0
        while iIntactEn < 6
            ObjectReference intactRefEn = Game.GetFormFromFile(0x00009960 + iIntactEn, "Vault13Chronicles.esp") as ObjectReference
            if intactRefEn != None && intactRefEn.IsDisabled()
                intactRefEn.EnableNoWait()
            endif
            iIntactEn += 1
        endwhile
        if craterSmoke != None && !craterSmoke.IsDisabled()
            craterSmoke.DisableNoWait()
        endif
        int iRuinDis = 0
        while iRuinDis < 15
            ObjectReference ruinRefDis = Game.GetFormFromFile(0x00009966 + iRuinDis, "Vault13Chronicles.esp") as ObjectReference
            if ruinRefDis != None && !ruinRefDis.IsDisabled()
                ruinRefDis.DisableNoWait()
            endif
            iRuinDis += 1
        endwhile
    endif
EndFunction

Function ForceAllAct5Aliases()
    ForceQuestAlias(0, 0x00002110)
    Actor theMaster = Game.GetFormFromFile(0x00002D11, "Vault13Chronicles.esp") as Actor
    if theMaster != None && !theMaster.IsDead() && !bCountdownActive
        ForceQuestAlias(1, 0x00002D11)
    else
        ForceQuestAlias(1, 0x00002D10)
    endif
    ForceQuestAlias(2, 0x00003005)
    ForceQuestAlias(3, 0x00002003)
    ForceQuestAlias(4, 0x00003509)
    V13Act1QuestScript act1DoorS = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as V13Act1QuestScript
    if act1DoorS != None
        ForceQuestAlias(5, act1DoorS.GetEnabledVault13ExitDoorFid(0x00002145))
    else
        ForceQuestAlias(5, 0x00002145)
    endif
    ForceQuestAlias(6, 0x00003501)
    ForceQuestAlias(7, 0x00002D3F)
    ForceQuestAlias(8, 0x00002D38)
    ForceQuestAlias(9, 0x00002D32)
    ForceQuestAlias(10, 0x00002D12)
    ForceQuestAlias(11, 0x00002D34)
    ForceQuestAlias(12, 0x00002D11)
    ForceQuestAlias(13, 0x00002D33)
    ForceQuestAlias(14, 0x00002235)
    ForceQuestAlias(15, 0x00003508)
    UpdateSanctuaryQuestTargetAlias()
    ForceQuestAlias(17, 0x00002D81)
    ForceQuestAlias(18, 0x00002206)
    ForceQuestAlias(19, 0x00003660)
EndFunction

Function StopCathedralScenes(int aiKeepFormID = 0)
    int[] scenIDs = new int[6]
    scenIDs[0] = 0x00008102
    scenIDs[1] = 0x00008103
    scenIDs[2] = 0x00008104
    scenIDs[3] = 0x00008105
    scenIDs[4] = 0x00008106
    scenIDs[5] = 0x00008107
    int idx = 0
    while idx < 6
        if scenIDs[idx] != aiKeepFormID
            Scene sc = Game.GetFormFromFile(scenIDs[idx], "Vault13Chronicles.esp") as Scene
            if sc != None && sc.IsPlaying()
                sc.Stop()
            endif
        endif
        idx += 1
    endwhile
EndFunction

Actor Function GetCathedralSceneSpeaker(int aiSceneFormID)
    if aiSceneFormID == 0x00008102
        return Game.GetFormFromFile(0x00002D32, "Vault13Chronicles.esp") as Actor
    elseif aiSceneFormID == 0x00008107
        return Game.GetFormFromFile(0x00002D33, "Vault13Chronicles.esp") as Actor
    elseif aiSceneFormID == 0x00008103
        return Game.GetFormFromFile(0x00002D12, "Vault13Chronicles.esp") as Actor
    elseif aiSceneFormID == 0x00008104
        return Game.GetFormFromFile(0x00002D34, "Vault13Chronicles.esp") as Actor
    elseif aiSceneFormID == 0x00008105
        return Game.GetFormFromFile(0x00002D11, "Vault13Chronicles.esp") as Actor
    elseif aiSceneFormID == 0x00008106
        return Game.GetFormFromFile(0x00002235, "Vault13Chronicles.esp") as Actor
    endif
    return None
EndFunction

Function QueueCathedralActivateFallback(int aiSceneFormID)
    ForceAllAct5Aliases()
    iPendingActSceneID = aiSceneFormID
    StartTimer(1.2, 83)
EndFunction

Function QueueCathedralScene(int aiSceneFormID)
    ForceAllAct5Aliases()
    iPendingActSceneID = 0
    iPendingSceneID = aiSceneFormID
    iSceneRetryTicks = 0
    Actor spk = GetCathedralSceneSpeaker(aiSceneFormID)
    Topic greetTopic = Game.GetFormFromFile(0x00008001, "Vault13Chronicles.esp") as Topic
    if spk != None && greetTopic != None && !spk.IsDead() && !spk.IsInDialogueWithPlayer() && !spk.IsTalking()
        spk.Say(greetTopic, None, false, None)
    endif
    StartTimer(0.25, 81)
EndFunction

Function RegisterPlayerEvents()
    Actor player = Game.GetPlayer()
    if player != None
        Form lauraKey = Game.GetFormFromFile(0x000015A7, "Vault13Chronicles.esp")
        Form morphBadge = Game.GetFormFromFile(0x000015A8, "Vault13Chronicles.esp")
        if lauraKey != None
            Self.AddInventoryEventFilter(lauraKey)
        endif
        if morphBadge != None
            Self.AddInventoryEventFilter(morphBadge)
        endif
        RegisterForRemoteEvent(player, "OnPlayerLoadGame")
        RegisterForRemoteEvent(player, "OnItemEquipped")
        RegisterForRemoteEvent(player, "OnItemUnequipped")
        RegisterForRemoteEvent(player as ObjectReference, "OnItemAdded")
        RegisterForRemoteEvent(player, "OnLocationChange")
        RegisterForRemoteEvent(player, "OnCombatStateChanged")
    endif

    ObjectReference lauraRef = Game.GetFormFromFile(0x00002D32, "Vault13Chronicles.esp") as ObjectReference
    if lauraRef != None
        RegisterForRemoteEvent(lauraRef, "OnActivate")
    endif
    ObjectReference lasherRef = Game.GetFormFromFile(0x00002D33, "Vault13Chronicles.esp") as ObjectReference
    if lasherRef != None
        RegisterForRemoteEvent(lasherRef, "OnActivate")
        Actor lasherAct = lasherRef as Actor
        if lasherAct != None
            RegisterForHitEvent(lasherAct)
            RegisterForRemoteEvent(lasherAct, "OnCombatStateChanged")
        endif
    endif
    ObjectReference morphRef = Game.GetFormFromFile(0x00002D12, "Vault13Chronicles.esp") as ObjectReference
    if morphRef != None
        RegisterForRemoteEvent(morphRef, "OnActivate")
        Actor morphAct = morphRef as Actor
        if morphAct != None
            RegisterForRemoteEvent(morphAct, "OnDeath")
            RegisterForHitEvent(morphAct)
            RegisterForRemoteEvent(morphAct, "OnCombatStateChanged")
        endif
    endif
    ObjectReference gideonRef = Game.GetFormFromFile(0x00002D34, "Vault13Chronicles.esp") as ObjectReference
    if gideonRef != None
        RegisterForRemoteEvent(gideonRef, "OnActivate")
    endif
    int sIdx = 0
    while sIdx < 5
        int sFid = 0x00002D84 + sIdx
        if sIdx >= 2
            sFid = 0x00002D86 + (sIdx - 2)
        endif
        Actor sAct = Game.GetFormFromFile(sFid, "Vault13Chronicles.esp") as Actor
        if sAct != None && !sAct.IsDead()
            RegisterForHitEvent(sAct)
            RegisterForRemoteEvent(sAct, "OnCombatStateChanged")
        endif
        sIdx += 1
    endwhile
    ObjectReference masterRef = Game.GetFormFromFile(0x00002D11, "Vault13Chronicles.esp") as ObjectReference
    if masterRef != None
        RegisterForRemoteEvent(masterRef, "OnActivate")
        Actor masterAct = masterRef as Actor
        if masterAct != None
            RegisterForRemoteEvent(masterAct, "OnDeath")
            RegisterForHitEvent(masterAct)
        endif
    endif
    ObjectReference exileJacRef = Game.GetFormFromFile(0x00002235, "Vault13Chronicles.esp") as ObjectReference
    if exileJacRef != None
        RegisterForRemoteEvent(exileJacRef, "OnActivate")
    endif
    ObjectReference v13GearDoor = Game.GetFormFromFile(0x00002201, "Vault13Chronicles.esp") as ObjectReference
    if v13GearDoor != None
        RegisterForRemoteEvent(v13GearDoor, "OnActivate")
    endif
    ObjectReference v13InnerDoor = Game.GetFormFromFile(0x00002208, "Vault13Chronicles.esp") as ObjectReference
    if v13InnerDoor != None
        RegisterForRemoteEvent(v13InnerDoor, "OnActivate")
    endif
    ObjectReference v13SurfDoor = Game.GetFormFromFile(0x00003501, "Vault13Chronicles.esp") as ObjectReference
    if v13SurfDoor != None
        RegisterForRemoteEvent(v13SurfDoor, "OnActivate")
    endif
    ObjectReference exTheresa = Game.GetFormFromFile(0x00003660, "Vault13Chronicles.esp") as ObjectReference
    if exTheresa != None
        RegisterForRemoteEvent(exTheresa, "OnActivate")
    endif
    ObjectReference exLyle = Game.GetFormFromFile(0x00003661, "Vault13Chronicles.esp") as ObjectReference
    if exLyle != None
        RegisterForRemoteEvent(exLyle, "OnActivate")
    endif
    ObjectReference fol1Ref = Game.GetFormFromFile(0x00002D35, "Vault13Chronicles.esp") as ObjectReference
    if fol1Ref != None
        RegisterForRemoteEvent(fol1Ref, "OnActivate")
        Actor fol1Act = fol1Ref as Actor
        if fol1Act != None
            RegisterForHitEvent(fol1Act)
            RegisterForRemoteEvent(fol1Act, "OnCombatStateChanged")
        endif
    endif
    ObjectReference fol2Ref = Game.GetFormFromFile(0x00002D36, "Vault13Chronicles.esp") as ObjectReference
    if fol2Ref != None
        RegisterForRemoteEvent(fol2Ref, "OnActivate")
        Actor fol2Act = fol2Ref as Actor
        if fol2Act != None
            RegisterForHitEvent(fol2Act)
            RegisterForRemoteEvent(fol2Act, "OnCombatStateChanged")
        endif
    endif
    ObjectReference d2D3FReg = Game.GetFormFromFile(0x00002D3F, "Vault13Chronicles.esp") as ObjectReference
    if d2D3FReg != None
        RegisterForRemoteEvent(d2D3FReg, "OnActivate")
    endif
    ObjectReference d2D03Reg = Game.GetFormFromFile(0x00002D03, "Vault13Chronicles.esp") as ObjectReference
    if d2D03Reg != None
        RegisterForRemoteEvent(d2D03Reg, "OnActivate")
    endif
    ObjectReference d2D81Reg = Game.GetFormFromFile(0x00002D81, "Vault13Chronicles.esp") as ObjectReference
    if d2D81Reg != None
        RegisterForRemoteEvent(d2D81Reg, "OnActivate")
    endif
    ObjectReference d2D01Reg = Game.GetFormFromFile(0x00002D01, "Vault13Chronicles.esp") as ObjectReference
    if d2D01Reg != None
        RegisterForRemoteEvent(d2D01Reg, "OnActivate")
    endif
    ObjectReference d2206Reg = Game.GetFormFromFile(0x00002206, "Vault13Chronicles.esp") as ObjectReference
    if d2206Reg != None
        RegisterForRemoteEvent(d2206Reg, "OnActivate")
    endif
    Scene exileScReg = Game.GetFormFromFile(0x00008106, "Vault13Chronicles.esp") as Scene
    if exileScReg != None
        RegisterForRemoteEvent(exileScReg, "OnEnd")
    endif
    TopicInfo exileEndInfo = Game.GetFormFromFile(0x00008385, "Vault13Chronicles.esp") as TopicInfo
    if exileEndInfo != None
        RegisterForRemoteEvent(exileEndInfo, "OnBegin")
        RegisterForRemoteEvent(exileEndInfo, "OnEnd")
    endif
EndFunction

Function MakeActorHostileToPlayer(Actor akTarget)
    if akTarget == None || akTarget.IsDead()
        return
    endif
    Faction raiderFact = Game.GetFormFromFile(0x0001CBED, "Fallout4.esm") as Faction
    if raiderFact != None && akTarget.IsInFaction(raiderFact)
        akTarget.RemoveFromFaction(raiderFact)
    endif
    Faction smFact = Game.GetFormFromFile(0x00058305, "Fallout4.esm") as Faction
    if smFact != None && !akTarget.IsInFaction(smFact)
        akTarget.AddToFaction(smFact)
    endif
    akTarget.SetValue(Game.GetAggressionAV(), 1.0)
    akTarget.EvaluatePackage()
    Actor player = Game.GetPlayer()
    if player != None
        akTarget.StartCombat(player)
    endif
EndFunction

Function BeginLasherFight()
    if bLasherHostile
        return
    endif
    bLasherHostile = true
    BlowCathedralDisguise()
    StopCathedralScenes(0)
    Actor lasher = Game.GetFormFromFile(0x00002D33, "Vault13Chronicles.esp") as Actor
    MakeActorHostileToPlayer(lasher)
EndFunction

Function BeginMorpheusFight()
    if bMorpheusHostile
        return
    endif
    bMorpheusHostile = true
    BlowCathedralDisguise()
    StopCathedralScenes(0)
    Actor morpheus = Game.GetFormFromFile(0x00002D12, "Vault13Chronicles.esp") as Actor
    MakeActorHostileToPlayer(morpheus)
    Actor morpheusGuard = Game.GetFormFromFile(0x00002D84, "Vault13Chronicles.esp") as Actor
    MakeActorHostileToPlayer(morpheusGuard)
EndFunction

Function BeginMasterBossFight()
    if bMasterHostile
        return
    endif
    bMasterHostile = true
    bMasterConfronted = true
    BlowCathedralDisguise()
    StopCathedralScenes(0)
    Actor theMaster = Game.GetFormFromFile(0x00002D11, "Vault13Chronicles.esp") as Actor
    MakeActorHostileToPlayer(theMaster)
    int pIdx = 0
    while pIdx < 3
        Actor praet = Game.GetFormFromFile(0x00002D20 + pIdx, "Vault13Chronicles.esp") as Actor
        MakeActorHostileToPlayer(praet)
        pIdx += 1
    endwhile
    Debug.Notification("[El Maestro]: '¡Entonces muere! ¡Pretorianos Nocturnos, aniquilad al intruso!'")
EndFunction

Function DeployFollowersStrikeTeam()
    if bFollowersStrikeDeployed
        return
    endif
    Quest qSpy = Game.GetFormFromFile(0x000D4000, "Vault13Chronicles.esp") as Quest
    V13SideQuestFollowersSpyScript spyS = qSpy as V13SideQuestFollowersSpyScript
    if spyS != None && spyS.AreFollowersSupportingCathedral()
        bFollowersStrikeDeployed = true
        Faction playerFac = Game.GetFormFromFile(0x0001C21C, "Fallout4.esm") as Faction
        Actor f1 = Game.GetFormFromFile(0x00002D35, "Vault13Chronicles.esp") as Actor
        Actor f2 = Game.GetFormFromFile(0x00002D36, "Vault13Chronicles.esp") as Actor
        if f1 != None
            f1.EnableNoWait()
            if bCathedralDisguiseBlown && playerFac != None && !f1.IsInFaction(playerFac)
                f1.AddToFaction(playerFac)
            endif
            f1.EvaluatePackage()
        endif
        if f2 != None
            f2.EnableNoWait()
            if bCathedralDisguiseBlown && playerFac != None && !f2.IsInFaction(playerFac)
                f2.AddToFaction(playerFac)
            endif
            f2.EvaluatePackage()
        endif
        Debug.Notification("[Seguidores del Apocalipsis] ¡Los exploradores de Nicole se han infiltrado en La Catedral para cubrir tu asalto!")
    endif
EndFunction

Function GrantSisterLauraAid()
    Actor player = Game.GetPlayer()
    if player == None
        return
    endif
    if !bLauraKeyGiven
        bLauraKeyGiven = true
        Form subKey = Game.GetFormFromFile(0x000015A7, "Vault13Chronicles.esp")
        if subKey != None && player.GetItemCount(subKey) == 0
            player.AddItem(subKey, 1, false)
        endif
        Game.RewardPlayerXP(250, false)
        Debug.Notification("[Hermana Laura] ¡Contraseña 'Rosa Roja' aceptada! Llave de la Cripta Subterránea recibida (+250 XP).")
    endif
    TryUnlockCathedralCryptDoor(true)
    DeployFollowersStrikeTeam()
    ForceAllAct5Aliases()
    UpdateSanctuaryQuestTargetAlias()
    SyncCathedralOptionalObjectives()
EndFunction

Function StartCathedralNuclearCountdown(int aiReason)
    if bCountdownActive || bCathedralDetonated
        return
    endif
    bCountdownActive = true
    iCountdownSecondsLeft = 240
    BlowCathedralDisguise()
    StopCathedralScenes(0)
    if (aiReason == 1 || aiReason == 2) && Self.IsObjectiveDisplayed(23)
        Self.SetObjectiveCompleted(23, true)
    endif
    SyncCathedralOptionalObjectives()

    Actor player = Game.GetPlayer()
    Actor theMaster = Game.GetFormFromFile(0x00002D11, "Vault13Chronicles.esp") as Actor
    Actor morpheus = Game.GetFormFromFile(0x00002D12, "Vault13Chronicles.esp") as Actor
    Form masterCore = Game.GetFormFromFile(0x00001115, "Vault13Chronicles.esp")
    Form report5 = Game.GetFormFromFile(0x00001145, "Vault13Chronicles.esp")
    Form vindicator = Game.GetFormFromFile(0x0000110E, "Vault13Chronicles.esp")
    Form pulseExpl = Game.GetFormFromFile(0x000C32DA, "Fallout4.esm")

    if aiReason == 1
        ; Canonical Speech / Vree's Autopsy Holodisk Victory: The Master self-destructs his pod
        if theMaster != None && !theMaster.IsDead()
            if pulseExpl != None
                theMaster.PlaceAtMe(pulseExpl, 1, false, false)
            endif
            theMaster.KillEssential(None)
        endif
        if morpheus != None && !morpheus.IsDead()
            morpheus.Kill(None)
        endif
        int kIdx = 0
        while kIdx < 3
            Actor pr = Game.GetFormFromFile(0x00002D20 + kIdx, "Vault13Chronicles.esp") as Actor
            if pr != None && !pr.IsDead()
                pr.Kill(None)
            endif
            kIdx += 1
        endwhile
        if player != None
            player.StopCombatAlarm()
        endif
        Debug.Notification("[El Maestro]: 'No hay esperanza... Márchate ahora, mientras aún te quede esperanza...' [Autodestrucción: 240 s]")
    elseif aiReason == 2
        Debug.Notification("[Ojiva Atómica de La Catedral] ¡Detonador termonuclear armado (240 s)! ¡Evacúa el edificio inmediatamente!")
    else
        Debug.Notification("[La Catedral] ¡El enlace vital del Maestro ha caído y ha activado la ojiva nuclear (240 s)! ¡Huye al exterior!")
    endif

    if player != None
        Game.ShakeCamera(player, 0.65, 2.2)
        if masterCore != None && player.GetItemCount(masterCore) == 0
            player.AddItem(masterCore, 1, false)
        endif
        if report5 != None && player.GetItemCount(report5) == 0
            player.AddItem(report5, 1, false)
        endif
        if vindicator != None && player.GetItemCount(vindicator) == 0
            player.AddItem(vindicator, 1, false)
            bVindicatorPreGranted = true
        endif
    endif

    if Self.GetStage() < 29
        Self.SetStage(29)
    endif
    SyncCathedralExteriorDestruction(false)
    SyncMasterVaultExitAndGates()
    StartTimer(5.0, 80)
EndFunction

Function CleanupAct5CinematicSafety(bool abStopMusic)
    CancelTimer(91)
    CancelTimer(92)
    if iAct5SirenInstance >= 0
        Sound.StopInstance(iAct5SirenInstance)
        iAct5SirenInstance = -1
    endif
    if abStopMusic && iEndingMusicInstance >= 0
        Sound.StopInstance(iEndingMusicInstance)
        iEndingMusicInstance = -1
    endif
    if kActiveCreditCardRef != None
        kActiveCreditCardRef.DisableNoWait(false)
        if kActiveCreditCardRef.GetFormID() < 0
            kActiveCreditCardRef.Delete()
        endif
        kActiveCreditCardRef = None
    endif
    int cIdx = 0
    while cIdx < 6
        ObjectReference cardRef = Game.GetFormFromFile(0x00009950 + cIdx, "Vault13Chronicles.esp") as ObjectReference
        if cardRef != None && !cardRef.IsDisabled()
            cardRef.DisableNoWait(false)
        endif
        cIdx += 1
    endwhile
    if kActiveExileDouble != None
        kActiveExileDouble.DisableNoWait(false)
        kActiveExileDouble = None
    endif
    Actor dblM = Game.GetFormFromFile(0x00009949, "Vault13Chronicles.esp") as Actor
    if dblM != None && !dblM.IsDisabled()
        dblM.DisableNoWait(false)
    endif
    Actor dblF = Game.GetFormFromFile(0x0000994A, "Vault13Chronicles.esp") as Actor
    if dblF != None && !dblF.IsDisabled()
        dblF.DisableNoWait(false)
    endif
    ObjectReference exileLightCln = Game.GetFormFromFile(0x0000994C, "Vault13Chronicles.esp") as ObjectReference
    if exileLightCln != None && !exileLightCln.IsDisabled()
        exileLightCln.DisableNoWait(false)
    endif
    Weather.ReleaseOverride()
    Actor player = Game.GetPlayer()
    if player != None
        player.SetGhost(false)
        player.SetAlpha(1.0, false)
    endif
    Game.ShowFirstPersonGeometry(true)
    if kAct5CineLayer != None
        kAct5CineLayer.EnablePlayerControls()
        kAct5CineLayer.Delete()
        kAct5CineLayer = None
    endif
    bCathedralCinematicActive = false
    iCathedralCinePhase = 0
    bExileEndingCinematicActive = false
    iExileCinePhase = 0
    iAct5CineReadyTicks = 0
EndFunction

Function StartExileEndingCinematic()
    if bExileEndingPlayed || bCathedralCinematicActive
        return
    endif
    bPendingExileEndingOnExit = false
    bExileEndingCinematicActive = false
    bExileEndingPlayed = true
    iExileCinePhase = 0
    iAct5CineReadyTicks = 0
    SetupExileEpilogueActorsAndSeals()
    if Self.GetStage() < 40
        Self.SetStage(40)
    endif
    CancelTimer(82)
    StartTimer(1.0, 92)
EndFunction

Function TriggerCathedralAtomicDetonation()
    if bCathedralDetonated
        return
    endif
    bCathedralDetonated = true
    bCountdownActive = false
    CancelTimer(80)

    Actor player = Game.GetPlayer()
    ObjectReference cathDoor = Game.GetFormFromFile(0x00003509, "Vault13Chronicles.esp") as ObjectReference
    if cathDoor != None
        cathDoor.SetLockLevel(253)
        cathDoor.Lock(true, false)
    endif
    ObjectReference sanctDoor = Game.GetFormFromFile(0x00002D81, "Vault13Chronicles.esp") as ObjectReference
    if sanctDoor != None
        sanctDoor.SetLockLevel(253)
        sanctDoor.Lock(true, false)
    endif

    Actor theMaster = Game.GetFormFromFile(0x00002D11, "Vault13Chronicles.esp") as Actor
    if theMaster != None && !theMaster.IsDead()
        theMaster.KillEssential(None)
    endif

    WorldSpace ws2161 = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    ObjectReference overlookCam = Game.GetFormFromFile(0x00009944, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference groundBlast = Game.GetFormFromFile(0x00009945, "Vault13Chronicles.esp") as ObjectReference
    if player != None && !bCathedralCinematicActive && overlookCam != None && groundBlast != None && ws2161 != None && player.GetWorldSpace() == ws2161
        bCathedralCinematicActive = true
        iCathedralCinePhase = 0
        iAct5CineReadyTicks = 0
        StartTimer(0.45, 91)
        return
    endif

    SyncCathedralExteriorDestruction(true)

    if player != None
        Game.ShakeCamera(player, 1.0, 3.5)
    endif

    Form nukeExpl = Game.GetFormFromFile(0x000C32DA, "Fallout4.esm")
    ObjectReference nukeAnchor = Game.GetFormFromFile(0x00003669, "Vault13Chronicles.esp") as ObjectReference
    if nukeAnchor != None && nukeAnchor.Is3DLoaded()
        if Math.abs(nukeAnchor.GetPositionX() - (-19500.0)) > 5.0 || Math.abs(nukeAnchor.GetPositionY() - (-31520.0)) > 5.0 || Math.abs(nukeAnchor.GetPositionZ() - 260.0) > 5.0
            nukeAnchor.SetPosition(-19500.0, -31520.0, 260.0)
        endif
    endif
    if nukeExpl != None
        if nukeAnchor != None
            nukeAnchor.PlaceAtMe(nukeExpl, 1, false, false)
        endif
        if cathDoor != None
            cathDoor.PlaceAtMe(nukeExpl, 1, false, false)
        endif
        StartTimer(0.65, 84)
    endif

    Game.RewardPlayerXP(800, false)
    Debug.Notification("[La Catedral] ¡DETONACIÓN TERMONUCLEAR! ¡La torre de la Unidad ha sido borrada de la faz de California! (+800 XP)")

    if Self.GetStage() < 30
        Self.SetStage(30)
    else
        CheckTriggerExileEpilogue()
    endif
EndFunction

Function SetupExileEpilogueActorsAndSeals()
    if Self.GetStage() < 30
        return
    endif
    Actor pEx = Game.GetPlayer()
    Cell v13CaveC = Game.GetFormFromFile(0x00002200, "Vault13Chronicles.esp") as Cell
    Cell v13IntC = Game.GetFormFromFile(0x00002100, "Vault13Chronicles.esp") as Cell
    WorldSpace caliExW = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    Cell pCellEx = None
    if pEx != None
        pCellEx = pEx.GetParentCell()
    endif
    bool inExileZone = (pEx != None && ((v13CaveC != None && pCellEx == v13CaveC) || (v13IntC != None && pCellEx == v13IntC) || (caliExW != None && pEx.GetWorldSpace() == caliExW)))

    ObjectReference v13GearDoor = Game.GetFormFromFile(0x00002201, "Vault13Chronicles.esp") as ObjectReference
    if v13GearDoor != None
        if v13GearDoor.IsDisabled()
            v13GearDoor.EnableNoWait()
        endif
        if inExileZone || v13GearDoor.Is3DLoaded()
            v13GearDoor.SetLockLevel(253)
            v13GearDoor.Lock(true, false)
        endif
    endif
    ObjectReference v13InnerDoor = Game.GetFormFromFile(0x00002208, "Vault13Chronicles.esp") as ObjectReference
    if v13InnerDoor != None && Self.GetStage() >= 35
        if v13InnerDoor.IsDisabled()
            v13InnerDoor.EnableNoWait()
        endif
        if inExileZone || v13InnerDoor.Is3DLoaded()
            v13InnerDoor.SetLockLevel(253)
            v13InnerDoor.Lock(true, false)
        endif
    endif
    ObjectReference surfDoorSeal = Game.GetFormFromFile(0x00003501, "Vault13Chronicles.esp") as ObjectReference
    if surfDoorSeal != None && Self.GetStage() >= 38
        if inExileZone || surfDoorSeal.Is3DLoaded()
            surfDoorSeal.SetLockLevel(253)
            surfDoorSeal.Lock(true, false)
        endif
    endif
    ObjectReference caveDest = Game.GetFormFromFile(0x00002205, "Vault13Chronicles.esp") as ObjectReference
    if caveDest != None && (inExileZone || caveDest.Is3DLoaded())
        float dxDest = caveDest.GetPositionX() - 4430.0
        if dxDest < -5.0 || dxDest > 5.0
            caveDest.SetPosition(4430.0, -5268.0, -31.0)
            caveDest.SetAngle(0.0, 0.0, 270.0)
        endif
    endif
    Cell c2200Exit = Game.GetFormFromFile(0x00002200, "Vault13Chronicles.esp") as Cell
    Actor pExileExit = Game.GetPlayer()
    bool inCave2200Exit = (c2200Exit != None && pExileExit != None && pExileExit.GetParentCell() == c2200Exit)
    ObjectReference caveExitDoor = Game.GetFormFromFile(0x00002206, "Vault13Chronicles.esp") as ObjectReference
    if caveExitDoor != None
        if caveExitDoor.IsDisabled()
            caveExitDoor.EnableNoWait()
        endif
        if caveExitDoor.IsLocked()
            caveExitDoor.Lock(false, false)
        endif
        if caveExitDoor.Is3DLoaded() || inCave2200Exit || Math.abs(caveExitDoor.GetPositionX() - 6736.0) > 2.0 || Math.abs(caveExitDoor.GetPositionY() + 4255.0) > 2.0 || Math.abs(caveExitDoor.GetPositionZ() - 388.0) > 2.0 || Math.abs(caveExitDoor.GetAngleZ() - 71.811373) > 2.0
            if Math.abs(caveExitDoor.GetPositionX() - 6736.0) > 2.0 || Math.abs(caveExitDoor.GetPositionY() + 4255.0) > 2.0 || Math.abs(caveExitDoor.GetPositionZ() - 388.0) > 2.0 || Math.abs(caveExitDoor.GetAngleZ() - 71.811373) > 2.0
                caveExitDoor.SetPosition(6736.0, -4255.0, 388.0)
                caveExitDoor.SetAngle(0.0, 0.0, 71.811373)
            endif
        endif
    endif
    int iBulk = 0
    while iBulk < 5
        ObjectReference bulkRef = Game.GetFormFromFile(0x00002238 + iBulk, "Vault13Chronicles.esp") as ObjectReference
        if bulkRef != None
            if bulkRef.IsDisabled()
                bulkRef.EnableNoWait()
            endif
            float bTargetX = 6736.0
            float bTargetY = -4255.0
            float bTargetZ = 388.0
            if iBulk == 1
                bTargetX = 6614.402
                bTargetY = -4294.973
            elseif iBulk == 2
                bTargetX = 6534.456
                bTargetY = -4051.776
            elseif iBulk == 3
                bTargetX = 6694.348
                bTargetY = -4538.170
            elseif iBulk == 4
                bTargetX = 6614.402
                bTargetY = -4294.973
                bTargetZ = 644.0
            endif
            if bulkRef.Is3DLoaded() || inCave2200Exit || Math.abs(bulkRef.GetPositionX() - bTargetX) > 2.0 || Math.abs(bulkRef.GetPositionY() - bTargetY) > 2.0 || Math.abs(bulkRef.GetPositionZ() - bTargetZ) > 2.0 || Math.abs(bulkRef.GetAngleZ() - 161.811373) > 2.0
                if Math.abs(bulkRef.GetPositionX() - bTargetX) > 2.0 || Math.abs(bulkRef.GetPositionY() - bTargetY) > 2.0 || Math.abs(bulkRef.GetPositionZ() - bTargetZ) > 2.0 || Math.abs(bulkRef.GetAngleZ() - 161.811373) > 2.0
                    bulkRef.SetPosition(bTargetX, bTargetY, bTargetZ)
                    bulkRef.SetAngle(0.0, 0.0, 161.811373)
                endif
            endif
        endif
        iBulk += 1
    endwhile
    if Self.GetStage() >= 35
        int rIdx = 0
        while rIdx < 3
            ObjectReference caveRat = Game.GetFormFromFile(0x00002220 + rIdx, "Vault13Chronicles.esp") as ObjectReference
            if caveRat != None && !caveRat.IsDisabled()
                caveRat.DisableNoWait()
            endif
            rIdx += 1
        endwhile
    endif

    Actor exileJac = Game.GetFormFromFile(0x00002235, "Vault13Chronicles.esp") as Actor
    if exileJac != None
        if Self.GetStage() >= 35 && (Self.GetStage() < 40 || (v13CaveC != None && pCellEx == v13CaveC))
            if exileJac.IsDisabled()
                exileJac.EnableNoWait()
            endif
            if exileJac.Is3DLoaded()
                float dxJac = exileJac.GetPositionX() - 4260.0
                if dxJac < -5.0 || dxJac > 5.0
                    exileJac.SetPosition(4260.0, -5268.0, -31.0)
                    exileJac.SetAngle(0.0, 0.0, 90.0)
                endif
                exileJac.EvaluatePackage()
            endif
        elseif Self.GetStage() >= 40
            if !exileJac.IsDisabled()
                exileJac.DisableNoWait()
            endif
        endif
    endif

    ObjectReference caveRelay = Game.GetFormFromFile(0x00002236, "Vault13Chronicles.esp") as ObjectReference
    if caveRelay != None && Self.GetStage() >= 35
        if caveRelay.IsDisabled()
            caveRelay.EnableNoWait()
        endif
    endif
    ObjectReference caveRelayDesk = Game.GetFormFromFile(0x00002237, "Vault13Chronicles.esp") as ObjectReference
    if caveRelayDesk != None && Self.GetStage() >= 35
        if caveRelayDesk.IsDisabled()
            caveRelayDesk.EnableNoWait()
        endif
    endif

    int campIdx = 0
    if Self.GetStage() >= 38
        while campIdx < 8
            ObjectReference campRef = Game.GetFormFromFile(0x00003660 + campIdx, "Vault13Chronicles.esp") as ObjectReference
            if campRef != None && campRef.IsDisabled()
                campRef.EnableNoWait()
            endif
            campIdx += 1
        endwhile
    else
        while campIdx < 8
            ObjectReference campRefDis = Game.GetFormFromFile(0x00003660 + campIdx, "Vault13Chronicles.esp") as ObjectReference
            if campRefDis != None && !campRefDis.IsDisabled()
                campRefDis.DisableNoWait()
            endif
            campIdx += 1
        endwhile
    endif
    Actor preMale = Game.GetFormFromFile(0x00009949, "Vault13Chronicles.esp") as Actor
    if preMale != None && !preMale.IsDisabled()
        preMale.DisableNoWait(false)
    endif
    Actor preFemale = Game.GetFormFromFile(0x0000994A, "Vault13Chronicles.esp") as Actor
    if preFemale != None && !preFemale.IsDisabled()
        preFemale.DisableNoWait(false)
    endif
    ObjectReference preLight = Game.GetFormFromFile(0x0000994C, "Vault13Chronicles.esp") as ObjectReference
    if preLight != None && !preLight.IsDisabled()
        preLight.DisableNoWait(false)
    endif
    int hideCardPre = 0
    while hideCardPre < 6
        ObjectReference preCard = Game.GetFormFromFile(0x00009950 + hideCardPre, "Vault13Chronicles.esp") as ObjectReference
        if preCard != None && !preCard.IsDisabled()
            preCard.DisableNoWait(false)
        endif
        hideCardPre += 1
    endwhile
EndFunction

Function CheckTriggerExileEpilogue()
    if Self.GetStage() < 30
        return
    endif
    Quest act4Quest = Game.GetFormFromFile(0x00007000, "Vault13Chronicles.esp") as Quest
    int act4Stg = 0
    if act4Quest != None
        act4Stg = act4Quest.GetStage()
    endif
    bool act4Done = (act4Quest != None && (act4Stg >= 30 || act4Quest.IsCompleted() || act4Quest.IsStageDone(30) || act4Quest.IsStageDone(40)))

    if act4Done
        if act4Quest != None && act4Stg < 40
            act4Quest.SetStage(40)
        endif
        if Self.GetStage() < 35
            Self.SetStage(35)
        elseif !bStage35Ready || !Self.IsObjectiveDisplayed(35) || Self.IsObjectiveDisplayed(29) || Self.IsObjectiveDisplayed(21)
            ApplyV13Act5Stage(35)
        else
            SetupExileEpilogueActorsAndSeals()
        endif
    else
        ; Free Order: Player destroyed The Cathedral BEFORE destroying Mariposa Vats!
        bool firstStage32 = (Self.GetStage() < 32)
        if firstStage32
            Self.SetStage(32)
        elseif !Self.IsObjectiveDisplayed(32) || Self.IsObjectiveDisplayed(29)
            ApplyV13Act5Stage(32)
        endif
        if act4Quest != None
            V13Act4QuestScript act4S = act4Quest as V13Act4QuestScript
            if act4S != None
                act4S.WakeUpAct4()
            endif
            if firstStage32
                act4Quest.SetActive(true)
            endif
        endif
    endif
EndFunction

Function ShowDynamicCaliforniaEpilogue()
    if bDynamicEndingShown
        return
    endif
    bDynamicEndingShown = true

    Quest qInv = Game.GetFormFromFile(0x000D5000, "Vault13Chronicles.esp") as Quest
    V13MutantInvasionScript invS = qInv as V13MutantInvasionScript

    string sShady = "SHADY SANDS: Próspera — semilla de la futura República de Nueva California."
    string sJunk = "JUNKTOWN: Libre y abierta a las caravanas del desierto."
    string sHub = "EL EJE (THE HUB): Sus rutas mercantiles vertebran toda Nueva California."
    string sBoneyard = "EL BONEYARD (ADYTUM): Liberado de la sombra de la Catedral."
    string sNecro = "NECRÓPOLIS: Los necrófagos conservaron su ciudad y la Gran Bomba de Agua."

    if invS != None
        if invS.HasSettlementFallen(5)
            sShady = "SHADY SANDS: Arrasada por las hordas mutantes antes de la caída de Mariposa."
        endif
        if invS.HasSettlementFallen(4)
            sJunk = "JUNKTOWN: Arrasada durante la invasión del ejército del Maestro."
        endif
        if invS.HasSettlementFallen(2)
            sHub = "EL EJE (THE HUB): Sus caravanas cayeron bajo el asedio supermutante."
        endif
        if invS.HasSettlementFallen(3)
            sBoneyard = "EL BONEYARD: Devastado por las legiones de la Unidad."
        endif
        if invS.HasSettlementFallen(1)
            sNecro = "NECRÓPOLIS: Masacrada en la represalia mutante del Día 110."
        endif
    endif

    string epilogueText = "[CRÓNICA FINAL — 10 DE MAYO DE 2162]\n\nTras salvar al Refugio 13 y destruir tanto las Cubas de Mariposa como al Maestro, el Supervisor Jacoren selló la compuerta a tus espaldas. Así quedó el Sur de California:\n\n• " + sShady + "\n• " + sJunk + "\n• " + sHub + "\n• " + sBoneyard + "\n• " + sNecro + "\n\nJunto a Theresa, Lyle y los moradores que decidieron seguirte en el cañón exterior, marcharéis hacia el norte hasta Oregón para fundar la aldea de ARROYO."
    Debug.MessageBox(epilogueText)
EndFunction

Function SetCathedralState(bool abEnabled)
    ObjectReference masterVault = Game.GetFormFromFile(0x00002D10, "Vault13Chronicles.esp") as ObjectReference
    Actor theMaster = Game.GetFormFromFile(0x00002D11, "Vault13Chronicles.esp") as Actor
    Actor morpheus = Game.GetFormFromFile(0x00002D12, "Vault13Chronicles.esp") as Actor
    Actor g1 = Game.GetFormFromFile(0x00002D20, "Vault13Chronicles.esp") as Actor
    Actor g2 = Game.GetFormFromFile(0x00002D21, "Vault13Chronicles.esp") as Actor
    ObjectReference termMaster = Game.GetFormFromFile(0x00002D30, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference d2D01 = Game.GetFormFromFile(0x00002D01, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference d2D03 = Game.GetFormFromFile(0x00002D03, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference d2D3F = Game.GetFormFromFile(0x00002D3F, "Vault13Chronicles.esp") as ObjectReference
    Form vindicator = Game.GetFormFromFile(0x0000110E, "Vault13Chronicles.esp")

    V13Act1QuestScript act1S = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as V13Act1QuestScript
    if act1S != None
        act1S.SyncVault13ExpeditionDoors()
    endif

    if abEnabled && Self.GetStage() < 30 && !bCathedralDetonated
        SyncCathedralExteriorDestruction(false)
        SyncMasterVaultExitAndGates()
        if d2D03 != None && !d2D03.IsDisabled()
            d2D03.DisableNoWait()
        endif
        if d2D3F != None && d2D3F.IsDisabled()
            d2D3F.EnableNoWait()
        endif
        if d2D01 != None
            d2D01.EnableNoWait()
            if d2D01.Is3DLoaded()
                d2D01.Lock(false, false)
            endif
        endif
        if masterVault != None
            masterVault.EnableNoWait()
        endif
        if termMaster != None
            termMaster.EnableNoWait()
        endif
        if theMaster != None
            if theMaster.IsDisabled()
                theMaster.EnableNoWait()
            endif
            if theMaster.Is3DLoaded() && !theMaster.IsDead() && vindicator != None
                if theMaster.GetItemCount(vindicator) > 1
                    theMaster.RemoveItem(vindicator, theMaster.GetItemCount(vindicator) - 1, true, None)
                endif
                if theMaster.GetItemCount(vindicator) > 0 && !theMaster.IsEquipped(vindicator)
                    theMaster.EquipItem(vindicator, false, true)
                endif
            endif
        endif
        if morpheus != None && morpheus.IsDisabled()
            morpheus.EnableNoWait()
        endif
        if g1 != None && g1.IsDisabled()
            g1.EnableNoWait()
        endif
        if g2 != None && g2.IsDisabled()
            g2.EnableNoWait()
        endif
        int dIdx = 2
        while dIdx < 7
            ObjectReference dExtra = Game.GetFormFromFile(0x00002D20 + dIdx, "Vault13Chronicles.esp") as ObjectReference
            if dExtra != None && dExtra.IsDisabled()
                dExtra.EnableNoWait()
            endif
            dIdx += 1
        endwhile
        int nIdx = 0
        while nIdx < 4
            ObjectReference nRef = Game.GetFormFromFile(0x00002D31 + nIdx, "Vault13Chronicles.esp") as ObjectReference
            if nRef != None && nRef.IsDisabled()
                nRef.EnableNoWait()
            endif
            nIdx += 1
        endwhile
        ObjectReference warheadTerm = Game.GetFormFromFile(0x00002D38, "Vault13Chronicles.esp") as ObjectReference
        if warheadTerm != None && warheadTerm.IsDisabled()
            warheadTerm.EnableNoWait()
        endif
        int[] sanctFids = new int[8]
        sanctFids[0] = 0x00002D81
        sanctFids[1] = 0x00002D82
        sanctFids[2] = 0x00002D83
        sanctFids[3] = 0x00002D84
        sanctFids[4] = 0x00002D85
        sanctFids[5] = 0x00002D86
        sanctFids[6] = 0x00002D87
        sanctFids[7] = 0x00002D88
        int sIdx = 0
        while sIdx < 8
            ObjectReference sRef = Game.GetFormFromFile(sanctFids[sIdx], "Vault13Chronicles.esp") as ObjectReference
            if sRef != None && sRef.IsDisabled()
                sRef.EnableNoWait()
            endif
            sIdx += 1
        endwhile
        MigrateCathedralSanctuaryLiveSave()
        SyncCathedralMutantHostility()
    elseif Self.GetStage() >= 30 || bCathedralDetonated
        if !bCathedralCinematicActive
            SyncCathedralExteriorDestruction(true)
        endif
    endif
EndFunction

Function GrantAct5CompletionRewards()
    if rewardsGiven
        return
    endif
    rewardsGiven = true

    Actor player = Game.GetPlayer()
    if player == None
        return
    endif

    Form masterCore = Game.GetFormFromFile(0x00001115, "Vault13Chronicles.esp")
    ObjectReference masterVault = Game.GetFormFromFile(0x00002D10, "Vault13Chronicles.esp") as ObjectReference
    Actor theMaster = Game.GetFormFromFile(0x00002D11, "Vault13Chronicles.esp") as Actor

    if masterCore != None
        if player.GetItemCount(masterCore) > 0
            player.RemoveItem(masterCore, player.GetItemCount(masterCore), true, None)
        endif
        if masterVault != None && masterVault.GetItemCount(masterCore) > 0
            masterVault.RemoveItem(masterCore, masterVault.GetItemCount(masterCore), true, None)
        endif
    endif

    Form vindicator = Game.GetFormFromFile(0x0000110E, "Vault13Chronicles.esp")
    if vindicator != None
        if masterVault != None && masterVault.GetItemCount(vindicator) > 0
            masterVault.RemoveItem(vindicator, masterVault.GetItemCount(vindicator), true, None)
        endif
        if player.GetItemCount(vindicator) == 0
            if theMaster != None && theMaster.GetItemCount(vindicator) > 0
                theMaster.RemoveItem(vindicator, 1, true, player)
            else
                player.AddItem(vindicator, 1, false)
            endif
        endif
        if theMaster != None && theMaster.GetItemCount(vindicator) > 0
            theMaster.RemoveItem(vindicator, theMaster.GetItemCount(vindicator), true, None)
        endif
        if player.GetItemCount(vindicator) > 1
            player.RemoveItem(vindicator, player.GetItemCount(vindicator) - 1, true, None)
        endif
    endif

    int i = 0
    while i < 6
        Form paPiece = Game.GetFormFromFile(0x00001301 + i, "Vault13Chronicles.esp")
        if paPiece != None
            if player.GetItemCount(paPiece) == 0
                player.AddItem(paPiece, 1, false)
            elseif player.GetItemCount(paPiece) > 1
                player.RemoveItem(paPiece, player.GetItemCount(paPiece) - 1, true, None)
            endif
        endif
        i += 1
    endwhile

    Form memoirs = Game.GetFormFromFile(0x00001145, "Vault13Chronicles.esp")
    if memoirs != None && player.GetItemCount(memoirs) == 0
        player.AddItem(memoirs, 1, false)
    endif

    Form chronicle2162 = Game.GetFormFromFile(0x000015A9, "Vault13Chronicles.esp")
    if chronicle2162 != None && player.GetItemCount(chronicle2162) == 0
        player.AddItem(chronicle2162, 1, false)
    endif

    ObjectReference relicDisplay5 = Game.GetFormFromFile(0x00002033, "Vault13Chronicles.esp") as ObjectReference
    if relicDisplay5 != None && relicDisplay5.IsDisabled()
        relicDisplay5.EnableNoWait()
    endif

    Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
    Form fusionCore = Game.GetFormFromFile(0x00075FE4, "Fallout4.esm")
    Form stimpak = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
    Form radaway = Game.GetFormFromFile(0x00023742, "Fallout4.esm")

    if caps != None
        player.AddItem(caps, 3000, false)
    endif
    if fusionCore != None
        player.AddItem(fusionCore, 6, false)
    endif
    if stimpak != None
        player.AddItem(stimpak, 10, false)
    endif
    if radaway != None
        player.AddItem(radaway, 6, false)
    endif

    Game.RewardPlayerXP(2000, false)
EndFunction

Function InterceptVault13ForExileIfNeeded()
    if Self.GetStage() < 35
        return
    endif
    SetupExileEpilogueActorsAndSeals()
    Actor player = Game.GetPlayer()
    if player == None || Utility.IsInMenuMode() || !player.Is3DLoaded()
        return
    endif
    Cell v13Cell = Game.GetFormFromFile(0x00002100, "Vault13Chronicles.esp") as Cell
    Cell v13Cave = Game.GetFormFromFile(0x00002200, "Vault13Chronicles.esp") as Cell
    WorldSpace ws2161 = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    ObjectReference surfDoor3501 = Game.GetFormFromFile(0x00003501, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference caveEntryDest = Game.GetFormFromFile(0x0000223D, "Vault13Chronicles.esp") as ObjectReference
    if caveEntryDest == None
        caveEntryDest = Game.GetFormFromFile(0x00002205, "Vault13Chronicles.esp") as ObjectReference
    endif
    if v13Cell != None && player.GetParentCell() == v13Cell
        if caveEntryDest != None
            player.MoveTo(caveEntryDest, 0.0, 0.0, 0.0, true)
        endif
        return
    endif
    if v13Cave != None && player.GetParentCell() == v13Cave && player.GetPositionX() < 2850.0
        if caveEntryDest != None
            player.MoveTo(caveEntryDest, 0.0, 0.0, 0.0, true)
        endif
        return
    endif
    if Self.GetStage() < 38 && !bExileSceneTriggered && !bPendingExileEndingOnExit && !bExileEndingCinematicActive && ws2161 != None && player.GetWorldSpace() == ws2161 && surfDoor3501 != None && player.GetDistance(surfDoor3501) <= 1600.0
        if caveEntryDest != None
            player.MoveTo(caveEntryDest, 0.0, 0.0, 0.0, true)
        endif
        return
    endif
    if Self.GetStage() >= 35 && Self.GetStage() < 38 && v13Cave != None && player.GetParentCell() == v13Cave
        if !bExileSceneTriggered
            Actor exileJac = Game.GetFormFromFile(0x00002235, "Vault13Chronicles.esp") as Actor
            if exileJac != None && exileJac.GetDistance(player) <= 420.0
                bExileSceneTriggered = true
                QueueCathedralScene(0x00008106)
            endif
        elseif iPendingSceneID != 0x00008106 && iPendingActSceneID != 0x00008106
            Actor exileJacCheck = Game.GetFormFromFile(0x00002235, "Vault13Chronicles.esp") as Actor
            Scene sc8106 = Game.GetFormFromFile(0x00008106, "Vault13Chronicles.esp") as Scene
            if (sc8106 == None || !sc8106.IsPlaying()) && (exileJacCheck == None || (!exileJacCheck.IsInDialogueWithPlayer() && !exileJacCheck.IsTalking()))
                Self.SetStage(38)
            elseif exileJacCheck != None && !exileJacCheck.IsInDialogueWithPlayer() && !exileJacCheck.IsTalking() && exileJacCheck.GetDistance(player) > 340.0
                if sc8106 != None && sc8106.IsPlaying()
                    sc8106.Stop()
                endif
                Self.SetStage(38)
            endif
        endif
    endif
EndFunction

Function UpdateCathedralDungeonMechanics()
    Actor player = Game.GetPlayer()
    Cell vaultCell = Game.GetFormFromFile(0x00002D00, "Vault13Chronicles.esp") as Cell
    Cell sanctCell = Game.GetFormFromFile(0x00002D80, "Vault13Chronicles.esp") as Cell
    if player == None || vaultCell == None
        return
    endif

    if !IsPlayerInCathedral(player)
        if bCountdownActive && !bCathedralDetonated
            WorldSpace ws2161 = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
            if ws2161 != None && player.GetWorldSpace() == ws2161
                TriggerCathedralAtomicDetonation()
            endif
        elseif (Self.GetStage() >= 30 || bCathedralDetonated) && !bCathedralCinematicActive
            SyncCathedralExteriorDestruction(true)
        endif
        return
    endif

    MigrateCathedralSanctuaryLiveSave()
    if !bCathedralDetonated
        SyncCathedralExteriorDestruction(false)
        SyncMasterVaultExitAndGates()
        if bCountdownActive && Self.GetStage() >= 30
            bStage35Ready = false
            if Self.IsObjectiveDisplayed(35)
                Self.SetObjectiveDisplayed(35, false, false)
            endif
            if Self.IsObjectiveDisplayed(32)
                Self.SetObjectiveDisplayed(32, false, false)
            endif
            Self.SetObjectiveCompleted(29, false)
            if !Self.IsObjectiveDisplayed(29)
                Self.SetObjectiveDisplayed(29, true, false)
                Self.SetActive(true)
            endif
            ForceAllAct5Aliases()
        endif
    endif
    DeployFollowersStrikeTeam()
    SyncCathedralMutantHostility()
    SyncSanctuaryAcolytePanic()
    if !bCryptDoorAutoUnlocked
        Form lauraKey = Game.GetFormFromFile(0x000015A7, "Vault13Chronicles.esp")
        Form morphBadge = Game.GetFormFromFile(0x000015A8, "Vault13Chronicles.esp")
        if (lauraKey != None && player.GetItemCount(lauraKey) > 0) || (morphBadge != None && player.GetItemCount(morphBadge) > 0)
            TryUnlockCathedralCryptDoor(false)
        endif
    endif
    UpdateSanctuaryQuestTargetAlias()
    SyncCathedralOptionalObjectives()

    ; Father Lasher disguise check in Upper Sanctuary (South Nave)
    Actor lasher = Game.GetFormFromFile(0x00002D33, "Vault13Chronicles.esp") as Actor
    if sanctCell != None && player.GetParentCell() == sanctCell && lasher != None && !lasher.IsDead() && !bLasherHostile && !bCountdownActive
        if !IsPlayerDisguisedAsCathedral() && lasher.GetDistance(player) <= 460.0
            BeginLasherFight()
        endif
    endif

    ; Corridor of Revulsion psychic assault & Master throne approach (only in lower Vault sublevel)
    Actor theMaster = Game.GetFormFromFile(0x00002D11, "Vault13Chronicles.esp") as Actor
    if player.GetParentCell() == vaultCell && theMaster != None && !theMaster.IsDead() && !bCountdownActive
        float distMaster = theMaster.GetDistance(player)
        if player.GetPositionZ() <= -820.0 && distMaster <= 1080.0 && distMaster > 430.0
            if IsPlayerWearingPsychicNullifier()
                if !bPsychicShieldNotified
                    bPsychicShieldNotified = true
                    Debug.Notification("[Anulador Psíquico] ¡Las alucinaciones psíquicas del Pasillo de la Revulsión quedan bloqueadas al 100%!")
                endif
            else
                EffectShader psyFX = Game.GetFormFromFile(0x0006F122, "Fallout4.esm") as EffectShader
                if psyFX != None
                    psyFX.Play(player, 1.8)
                endif
                ActorValue hpAV = Game.GetFormFromFile(0x000002D4, "Fallout4.esm") as ActorValue
                if hpAV != None && player.GetValue(hpAV) > 18.0
                    player.DamageValue(hpAV, 14.0)
                endif
                Game.ShakeCamera(player, 0.28, 0.7)
                Debug.Notification("[Pasillo de la Revulsión] ¡Visiones psíquicas abrasan tu mente! (-14 PV — Equipa un Anulador Psíquico)")
            endif
        endif

        ; Auto-trigger The Master's iconic Tri-Voice confrontation when stepping before his Biomechanical Throne!
        if distMaster <= 430.0 && !bMasterConfronted && !bMasterHostile && !Utility.IsInMenuMode()
            bMasterConfronted = true
            QueueCathedralScene(0x00008105)
        endif
    endif
EndFunction

Function ApplyV13Act5Stage(int aiStage)
    if bApplyingAct5Stage
        StartTimer(0.35, 1)
        return
    endif
    bApplyingAct5Stage = true

    V13Act1QuestScript act1S = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as V13Act1QuestScript
    bool inDial = (act1S != None && act1S.IsJacorenInDialogueOrScene())
    if !inDial && aiStage < 30
        SetCathedralState(true)
    elseif act1S != None
        act1S.SyncVault13ExpeditionDoors()
    endif
    if (aiStage >= 30 || bCathedralDetonated) && !bCathedralCinematicActive
        SyncCathedralExteriorDestruction(true)
    endif
    ForceAllAct5Aliases()
    SyncCathedralOptionalObjectives()

    if aiStage == 15
        if !Self.IsObjectiveDisplayed(15)
            Self.SetObjectiveDisplayed(15, true, false)
            Self.SetActive(true)
        endif
    elseif aiStage >= 20 && aiStage < 29
        ObjectReference masterVault = Game.GetFormFromFile(0x00002D10, "Vault13Chronicles.esp") as ObjectReference
        Form vindicator = Game.GetFormFromFile(0x0000110E, "Vault13Chronicles.esp")
        if masterVault != None && vindicator != None && masterVault.GetItemCount(vindicator) > 0
            masterVault.RemoveItem(vindicator, masterVault.GetItemCount(vindicator), true, None)
        endif
        if Self.IsObjectiveDisplayed(15)
            SetObjectiveCompleted(15, true)
            Self.SetObjectiveDisplayed(15, false, false)
        endif
        Actor player = Game.GetPlayer()
        WorldSpace ws2161 = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
        bool inWastelandOrDungeon = (player != None && ((ws2161 != None && player.GetWorldSpace() == ws2161) || IsPlayerInCathedral(player)))
        if inWastelandOrDungeon || IsObjectiveCompleted(20)
            SetObjectiveCompleted(20, true)
            if Self.IsObjectiveDisplayed(20)
                Self.SetObjectiveDisplayed(20, false, false)
            endif
            if !Self.IsObjectiveDisplayed(21)
                Self.SetObjectiveDisplayed(21, true, false)
                Self.SetActive(true)
            endif
        else
            if Self.IsObjectiveDisplayed(20) && lastAppliedAct5Stage < 20
                Self.SetObjectiveDisplayed(20, false, false)
            endif
            if !Self.IsObjectiveDisplayed(20)
                Self.SetObjectiveDisplayed(20, true, false)
                Self.SetActive(true)
            endif
        endif

        ; Stage-specific Cathedral scene consequences
        if aiStage == 22
            GrantSisterLauraAid()
        elseif aiStage == 23
            if !bLasherBadgeGiven && player != None
                bLasherBadgeGiven = true
                Form lashBadge = Game.GetFormFromFile(0x000015A6, "Vault13Chronicles.esp")
                if lashBadge != None && player.GetItemCount(lashBadge) == 0
                    player.AddItem(lashBadge, 1, false)
                endif
                Game.RewardPlayerXP(200, false)
                Debug.Notification("[Padre Lasher] ¡Insignia Roja del Padre Lasher obtenida mediante engaño! (+200 XP)")
            endif
        elseif aiStage == 24
            ; Morpheus escorts the player directly down to The Master's throne room!
            ObjectReference masterApproach = Game.GetFormFromFile(0x00002D04, "Vault13Chronicles.esp") as ObjectReference
            Actor morph = Game.GetFormFromFile(0x00002D12, "Vault13Chronicles.esp") as Actor
            if player != None && masterApproach != None
                player.MoveTo(masterApproach, 0.0, -80.0, 0.0, true)
                if morph != None && !morph.IsDead()
                    morph.MoveTo(masterApproach, 90.0, 40.0, 0.0, false)
                endif
                bMasterConfronted = true
                QueueCathedralScene(0x00008105)
            endif
        elseif aiStage == 25
            if !bMorpheusBadgeGiven && player != None
                bMorpheusBadgeGiven = true
                Form blackBadge = Game.GetFormFromFile(0x000015A8, "Vault13Chronicles.esp")
                if blackBadge != None && player.GetItemCount(blackBadge) == 0
                    player.AddItem(blackBadge, 1, false)
                endif
                Game.RewardPlayerXP(300, false)
                Debug.Notification("[Sumo Sacerdote Morfeo] ¡Insignia del Capullo Negro entregada! (+300 XP)")
            endif
            TryUnlockCathedralCryptDoor(true)
            SyncCathedralOptionalObjectives()
        elseif aiStage == 26
            bApplyingAct5Stage = false
            StartCathedralNuclearCountdown(1)
            return
        elseif aiStage == 27
            BeginLasherFight()
        elseif aiStage == 28
            Actor theMasterCheck = Game.GetFormFromFile(0x00002D11, "Vault13Chronicles.esp") as Actor
            if player != None && theMasterCheck != None && theMasterCheck.GetDistance(player) <= 900.0
                BeginMasterBossFight()
            else
                BeginMorpheusFight()
            endif
        endif
    elseif aiStage == 29
        if Self.IsObjectiveDisplayed(15)
            SetObjectiveCompleted(15, true)
            Self.SetObjectiveDisplayed(15, false, false)
        endif
        SetObjectiveCompleted(20, true)
        if Self.IsObjectiveDisplayed(20)
            Self.SetObjectiveDisplayed(20, false, false)
        endif
        SetObjectiveCompleted(21, true)
        if Self.IsObjectiveDisplayed(21)
            Self.SetObjectiveDisplayed(21, false, false)
        endif
        if !Self.IsObjectiveDisplayed(29)
            Self.SetObjectiveDisplayed(29, true, false)
            Self.SetActive(true)
        endif
    elseif aiStage >= 30 && aiStage < 35
        if Self.IsObjectiveDisplayed(15)
            SetObjectiveCompleted(15, true)
            Self.SetObjectiveDisplayed(15, false, false)
        endif
        SetObjectiveCompleted(20, true)
        if Self.IsObjectiveDisplayed(20)
            Self.SetObjectiveDisplayed(20, false, false)
        endif
        SetObjectiveCompleted(21, true)
        if Self.IsObjectiveDisplayed(21)
            Self.SetObjectiveDisplayed(21, false, false)
        endif
        if Self.IsObjectiveDisplayed(29)
            SetObjectiveCompleted(29, true)
            Self.SetObjectiveDisplayed(29, false, false)
        endif
        if !bStage30Done
            bStage30Done = true
            Actor player30 = Game.GetPlayer()
            Form vindicator30 = Game.GetFormFromFile(0x0000110E, "Vault13Chronicles.esp")
            if player30 != None && vindicator30 != None && player30.GetItemCount(vindicator30) == 0
                player30.AddItem(vindicator30, 1, false)
                bVindicatorPreGranted = true
            endif
        endif
        if aiStage == 32
            if !Self.IsObjectiveDisplayed(32)
                Self.SetObjectiveDisplayed(32, true, false)
            endif
        else
            SyncCathedralOptionalObjectives()
            lastAppliedAct5Stage = aiStage
            bApplyingAct5Stage = false
            CheckTriggerExileEpilogue()
            return
        endif
    elseif aiStage >= 35 && aiStage < 38
        if Self.IsObjectiveDisplayed(15)
            SetObjectiveCompleted(15, true)
            Self.SetObjectiveDisplayed(15, false, false)
        endif
        SetObjectiveCompleted(20, true)
        if Self.IsObjectiveDisplayed(20)
            Self.SetObjectiveDisplayed(20, false, false)
        endif
        SetObjectiveCompleted(21, true)
        if Self.IsObjectiveDisplayed(21)
            Self.SetObjectiveDisplayed(21, false, false)
        endif
        if Self.IsObjectiveDisplayed(29)
            SetObjectiveCompleted(29, true)
            Self.SetObjectiveDisplayed(29, false, false)
        endif
        if Self.IsObjectiveDisplayed(32)
            SetObjectiveCompleted(32, true)
            Self.SetObjectiveDisplayed(32, false, false)
        endif
        ForceAllAct5Aliases()
        SetupExileEpilogueActorsAndSeals()
        if !bStage35Ready
            bStage35Ready = true
            Debug.Notification("[Crónicas del Refugio 13] ¡Mariposa y La Catedral han caído! Regresa al Refugio 13 para el epílogo final.")
        endif
        if !Self.IsObjectiveDisplayed(35)
            Self.SetObjectiveDisplayed(35, true, false)
        endif
        Self.SetActive(true)
        InterceptVault13ForExileIfNeeded()
    elseif aiStage >= 38 && aiStage < 40
        ObjectReference fastExit38 = Game.GetFormFromFile(0x00002206, "Vault13Chronicles.esp") as ObjectReference
        if fastExit38 != None && fastExit38.IsDisabled()
            fastExit38.EnableNoWait()
        endif
        ForceQuestAlias(18, 0x00002206)
        ForceQuestAlias(19, 0x00003660)
        SetObjectiveCompleted(35, true)
        if Self.IsObjectiveDisplayed(35)
            Self.SetObjectiveDisplayed(35, false, false)
        endif
        if !Self.IsObjectiveDisplayed(38)
            Self.SetObjectiveDisplayed(38, true, false)
        endif
        Self.SetActive(true)
        if Self.IsObjectiveDisplayed(15)
            SetObjectiveCompleted(15, true)
            Self.SetObjectiveDisplayed(15, false, false)
        endif
        SetObjectiveCompleted(20, true)
        if Self.IsObjectiveDisplayed(20)
            Self.SetObjectiveDisplayed(20, false, false)
        endif
        SetObjectiveCompleted(21, true)
        if Self.IsObjectiveDisplayed(21)
            Self.SetObjectiveDisplayed(21, false, false)
        endif
        if Self.IsObjectiveDisplayed(29)
            SetObjectiveCompleted(29, true)
            Self.SetObjectiveDisplayed(29, false, false)
        endif
        if Self.IsObjectiveDisplayed(32)
            SetObjectiveCompleted(32, true)
            Self.SetObjectiveDisplayed(32, false, false)
        endif
        if !bStage40Rewarded
            bStage40Rewarded = true
            GrantAct5CompletionRewards()
            Debug.Notification("[10 de mayo de 2162 — El Exilio] Jacoren ha sellado el Refugio 13 a tu espalda. Sal al exterior para reunirte con Theresa y Lyle rumbo a Arroyo.")
        endif
        ForceAllAct5Aliases()
        SetupExileEpilogueActorsAndSeals()
        if !bExileEndingPlayed && !bExileEndingCinematicActive
            bPendingExileEndingOnExit = true
            Actor pl38 = Game.GetPlayer()
            WorldSpace ws38 = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
            if pl38 != None && ws38 != None && pl38.GetWorldSpace() == ws38
                StartExileEndingCinematic()
            else
                StartTimer(1.0, 1)
            endif
        endif
    elseif aiStage >= 40
        if Self.IsObjectiveDisplayed(15)
            SetObjectiveCompleted(15, true)
        endif
        SetObjectiveCompleted(20, true)
        SetObjectiveCompleted(21, true)
        if Self.IsObjectiveDisplayed(29)
            SetObjectiveCompleted(29, true)
        endif
        if Self.IsObjectiveDisplayed(32)
            SetObjectiveCompleted(32, true)
        endif
        if Self.IsObjectiveDisplayed(35)
            SetObjectiveCompleted(35, true)
        endif
        if Self.IsObjectiveDisplayed(38)
            SetObjectiveCompleted(38, true)
        endif
        if !bStage40Rewarded
            bStage40Rewarded = true
            GrantAct5CompletionRewards()
            Debug.Notification("[10 de mayo de 2162 — El Exilio] ¡Campaña completada! Servoarmadura T-51f Endurecida, Ametralladora Vindicator y Crónica de 2162 desbloqueadas.")
        endif
        SetupExileEpilogueActorsAndSeals()
        if !Self.IsCompleted()
            CompleteAllObjectives()
            CompleteQuest()
        endif
        if !bExileEndingPlayed && !bExileEndingCinematicActive
            Actor plEnd = Game.GetPlayer()
            WorldSpace wsEnd = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
            if plEnd != None && wsEnd != None && plEnd.GetWorldSpace() == wsEnd
                StartExileEndingCinematic()
            else
                bPendingExileEndingOnExit = true
                StartTimer(1.0, 1)
            endif
        elseif !bDynamicEndingShown && !bExileEndingCinematicActive
            StartTimer(1.2, 82)
        endif
    endif
    SyncCathedralOptionalObjectives()
    lastAppliedAct5Stage = aiStage
    bApplyingAct5Stage = false
EndFunction

Function CheckStartAndProgress()
    RegisterPlayerEvents()
    Actor player = Game.GetPlayer()
    if player == None
        return
    endif

    int currentStage = Self.GetStage()
    if Self.IsCompleted() || Self.IsStageDone(40)
        currentStage = 40
    endif
    Quest act3Quest = Game.GetFormFromFile(0x00006002, "Vault13Chronicles.esp") as Quest
    Quest act4Quest = Game.GetFormFromFile(0x00007000, "Vault13Chronicles.esp") as Quest
    bool act3Done = (act3Quest != None && (act3Quest.IsCompleted() || act3Quest.GetStage() >= 40 || act3Quest.IsStageDone(40)))
    bool act4Done = (act4Quest != None && (act4Quest.IsCompleted() || act4Quest.GetStage() >= 40 || act4Quest.IsStageDone(40)))
    bool inCathedralNow = IsPlayerInCathedral(player)

    ; Self-heal saves where Act V prematurely started before Mariposa (Act IV) / Lost Hills (Act III)
    if currentStage >= 15 && currentStage < 29 && !act4Done && !(act3Done && inCathedralNow) && !Self.IsCompleted() && !Self.IsStageDone(40)
        introShown = false
        Self.SetObjectiveDisplayed(15, false, false)
        Self.SetObjectiveDisplayed(20, false, false)
        Self.SetObjectiveDisplayed(21, false, false)
        Self.SetObjectiveDisplayed(22, false, false)
        Self.SetObjectiveDisplayed(23, false, false)
        Self.SetObjectiveDisplayed(24, false, false)
        SetCathedralState(false)
        Self.Reset()
        Self.Stop()
        V13Act1QuestScript act1Heal = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as V13Act1QuestScript
        if act1Heal != None
            act1Heal.SyncVault13ExpeditionDoors()
        endif
        return
    endif

    if currentStage < 15
        if act4Done
            if !Self.IsRunning()
                Self.Start()
            endif
            Self.SetStage(15)
        elseif act3Done && inCathedralNow
            if !Self.IsRunning()
                Self.Start()
            endif
            introShown = true
            Self.SetStage(20)
        endif
        return
    endif

    if !bCathedralDetonated && (inCathedralNow || bCountdownActive) && currentStage >= 30
        UpdateCathedralDungeonMechanics()
        if !bCathedralDetonated
            return
        endif
    endif

    if currentStage >= 40
        SetupExileEpilogueActorsAndSeals()
        InterceptVault13ForExileIfNeeded()
        if bPendingExileEndingOnExit && !bExileEndingPlayed && !bExileEndingCinematicActive
            WorldSpace wsChk = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
            if wsChk != None && player.GetWorldSpace() == wsChk
                StartExileEndingCinematic()
                return
            endif
        endif
        if !rewardsGiven || !Self.IsCompleted()
            ApplyV13Act5Stage(currentStage)
        endif
        return
    endif

    if currentStage >= 38
        if !bStage40Rewarded || !Self.IsObjectiveDisplayed(38) || Self.IsObjectiveDisplayed(35) || Self.IsObjectiveDisplayed(29) || Self.IsObjectiveDisplayed(21) || Self.IsObjectiveDisplayed(32)
            ApplyV13Act5Stage(38)
        endif
        SetupExileEpilogueActorsAndSeals()
        if bPendingExileEndingOnExit && !bExileEndingPlayed && !bExileEndingCinematicActive
            WorldSpace wsChk38 = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
            if wsChk38 != None && player.GetWorldSpace() == wsChk38
                StartExileEndingCinematic()
                return
            endif
        endif
        InterceptVault13ForExileIfNeeded()
        return
    endif

    if currentStage >= 35
        if !bStage35Ready || !Self.IsObjectiveDisplayed(35) || Self.IsObjectiveDisplayed(29) || Self.IsObjectiveDisplayed(21) || Self.IsObjectiveDisplayed(32)
            ApplyV13Act5Stage(35)
        endif
        InterceptVault13ForExileIfNeeded()
        return
    endif

    if currentStage >= 30
        if bCountdownActive && !bCathedralDetonated
            UpdateCathedralDungeonMechanics()
            if !bCathedralDetonated
                return
            endif
        endif
        if currentStage == 32 && !Self.IsObjectiveDisplayed(32)
            ApplyV13Act5Stage(32)
        endif
        CheckTriggerExileEpilogue()
        return
    endif

    UpdateCathedralDungeonMechanics()

    if currentStage == 15
        WorldSpace ws2161 = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
        if (ws2161 != None && player.GetWorldSpace() == ws2161) || inCathedralNow
            Self.SetStage(20)
            return
        endif
        if !IsObjectiveDisplayed(15)
            SetCathedralState(true)
            ForceAllAct5Aliases()
            Self.SetObjectiveDisplayed(15, true, false)
        endif
        if act4Done && !introShown
            introShown = true
        endif
    elseif currentStage >= 20 && currentStage < 29
        if Self.IsObjectiveDisplayed(15) || (!Self.IsObjectiveDisplayed(20) && !Self.IsObjectiveDisplayed(21))
            ApplyV13Act5Stage(currentStage)
        endif
    endif
EndFunction

Function WakeUpAct5()
    Quest act3Gate = Game.GetFormFromFile(0x00006002, "Vault13Chronicles.esp") as Quest
    Quest act4Gate = Game.GetFormFromFile(0x00007000, "Vault13Chronicles.esp") as Quest
    Actor player = Game.GetPlayer()
    bool act3Done = (act3Gate != None && (act3Gate.IsCompleted() || act3Gate.GetStage() >= 40 || act3Gate.IsStageDone(40)))
    bool act4Done = (act4Gate != None && (act4Gate.IsCompleted() || act4Gate.GetStage() >= 40 || act4Gate.IsStageDone(40)))
    bool inCathedralNow = IsPlayerInCathedral(player)
    if !act4Done && !(act3Done && inCathedralNow)
        return
    endif
    if (Self.IsCompleted() || Self.IsStageDone(40)) && (rewardsGiven || bStage40Rewarded)
        bStage40Rewarded = true
        rewardsGiven = true
        if !Self.IsCompleted()
            CompleteAllObjectives()
            CompleteQuest()
        endif
        return
    endif
    if !Self.IsRunning()
        Self.Start()
    endif
    RegisterPlayerEvents()
    if Self.GetStage() < 15 && !Self.IsStageDone(40)
        if act4Done
            Self.SetStage(15)
        else
            introShown = true
            Self.SetStage(20)
        endif
    elseif Self.IsStageDone(40) || bStage40Rewarded
        ApplyV13Act5Stage(40)
    else
        ApplyV13Act5Stage(Self.GetStage())
    endif
    StartTimer(0.5, 1)
EndFunction

Function ProcessVindicatorHit(Actor akTarget, Actor akCaster)
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
        if hitCounter >= 5 || akTarget.IsDead()
            hitCounter = 0
            ActorValue apAV = Game.GetFormFromFile(0x000002D5, "Fallout4.esm") as ActorValue
            ActorValue hpAV = Game.GetFormFromFile(0x000002D4, "Fallout4.esm") as ActorValue
            if apAV != None
                player.RestoreValue(apAV, 40.0)
            endif
            if hpAV != None
                player.RestoreValue(hpAV, 30.0)
            endif
            Debug.Notification("[Ametralladora Vindicator] ¡Onda de choque Rheinmetall! (+40 PA / +30 PV)")
        endif
    endif
EndFunction

Event OnHit(ObjectReference akTarget, ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked, string apMaterial)
    if akAggressor == Game.GetPlayer()
        ObjectReference masterRef = Game.GetFormFromFile(0x00002D11, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference morphRef = Game.GetFormFromFile(0x00002D12, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference lasherRef = Game.GetFormFromFile(0x00002D33, "Vault13Chronicles.esp") as ObjectReference
        if akTarget == masterRef
            BeginMasterBossFight()
        elseif akTarget == morphRef
            BeginMorpheusFight()
        elseif akTarget == lasherRef
            BeginLasherFight()
        else
            BlowCathedralDisguise()
        endif
    else
        Cell sanctCellHit = Game.GetFormFromFile(0x00002D80, "Vault13Chronicles.esp") as Cell
        Cell vaultCellHit = Game.GetFormFromFile(0x00002D00, "Vault13Chronicles.esp") as Cell
        bool inSanctHit = (sanctCellHit != None && ((akTarget != None && akTarget.GetParentCell() == sanctCellHit) || (akAggressor != None && akAggressor.GetParentCell() == sanctCellHit)))
        bool inVaultHit = (vaultCellHit != None && ((akTarget != None && akTarget.GetParentCell() == vaultCellHit) || (akAggressor != None && akAggressor.GetParentCell() == vaultCellHit)))
        if inSanctHit
            SyncSanctuaryAcolytePanic()
        endif
        if inSanctHit || inVaultHit || IsPlayerInCathedral(Game.GetPlayer())
            SyncCathedralMutantHostility()
        endif
    endif
    Actor hitAct = akTarget as Actor
    if hitAct != None && !hitAct.IsDead()
        RegisterForHitEvent(hitAct)
    endif
EndEvent

Event Actor.OnDeath(Actor akSender, Actor akKiller)
    Actor theMaster = Game.GetFormFromFile(0x00002D11, "Vault13Chronicles.esp") as Actor
    if akSender == theMaster && !bCountdownActive && !bCathedralDetonated
        StartCathedralNuclearCountdown(3)
    endif
    Actor morpheus = Game.GetFormFromFile(0x00002D12, "Vault13Chronicles.esp") as Actor
    if akSender == morpheus
        if !bCryptDoorAutoUnlocked
            Debug.Notification("[Sumo Sacerdote Morfeo ha caído] Recoge la Insignia del Capullo Negro de su cuerpo para abrir la Cripta Subterránea.")
        endif
        UpdateSanctuaryQuestTargetAlias()
    endif
EndEvent

Event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
    Actor player = Game.GetPlayer()
    if akActionRef != player || player == None
        return
    endif

    ObjectReference v13GearDoor = Game.GetFormFromFile(0x00002201, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference v13InnerDoor = Game.GetFormFromFile(0x00002208, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference v13SurfDoor = Game.GetFormFromFile(0x00003501, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference v13CaveExit = Game.GetFormFromFile(0x00002206, "Vault13Chronicles.esp") as ObjectReference
    if v13CaveExit != None && akSender == v13CaveExit && Self.GetStage() >= 35
        bExileSceneTriggered = true
        if !bExileEndingPlayed
            bPendingExileEndingOnExit = true
        endif
        if Self.GetStage() < 38
            Self.SetStage(38)
        endif
        return
    endif
    if ((akSender == v13GearDoor || (v13InnerDoor != None && akSender == v13InnerDoor)) && Self.GetStage() >= 35) || (v13SurfDoor != None && akSender == v13SurfDoor && Self.GetStage() >= 38)
        Debug.Notification("[Refugio 13 — 10 de mayo de 2162] La compuerta dentada de acero ha sido sellada desde el interior. Tu leyenda pertenece ahora al Yermo.")
        return
    endif

    ObjectReference d2D01 = Game.GetFormFromFile(0x00002D01, "Vault13Chronicles.esp") as ObjectReference
    if d2D01 != None && akSender == d2D01
        d2D01.SetLockLevel(0)
        d2D01.Lock(false, false)
        StartTimer(0.35, 1)
        return
    endif

    ObjectReference d2D3F = Game.GetFormFromFile(0x00002D3F, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference d2D03 = Game.GetFormFromFile(0x00002D03, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference d2D81 = Game.GetFormFromFile(0x00002D81, "Vault13Chronicles.esp") as ObjectReference
    if (d2D3F != None && akSender == d2D3F) || (d2D03 != None && akSender == d2D03) || (d2D81 != None && akSender == d2D81)
        if !bCathedralDetonated
            ObjectReference cathDoor = Game.GetFormFromFile(0x00003509, "Vault13Chronicles.esp") as ObjectReference
            bool wasBlocked = akSender.IsLocked() || (cathDoor != None && (cathDoor.IsLocked() || cathDoor.IsDisabled()))
            akSender.SetLockLevel(0)
            akSender.Lock(false, false)
            if cathDoor != None
                if cathDoor.IsDisabled()
                    cathDoor.EnableNoWait()
                endif
                cathDoor.SetLockLevel(0)
                cathDoor.Lock(false, false)
            endif
            if wasBlocked
                ObjectReference cathFt = Game.GetFormFromFile(0x0000351A, "Vault13Chronicles.esp") as ObjectReference
                if cathFt != None
                    if d2D81 != None && akSender == d2D81
                        player.MoveTo(cathFt, 0.0, -790.0, 0.0, true)
                    else
                        player.MoveTo(cathFt, 0.0, -1090.0, 0.0, true)
                    endif
                endif
                StartTimer(0.25, 1)
            endif
        endif
        return
    endif

    ObjectReference lauraRef = Game.GetFormFromFile(0x00002D32, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference lasherRef = Game.GetFormFromFile(0x00002D33, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference morphRef = Game.GetFormFromFile(0x00002D12, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference gideonRef = Game.GetFormFromFile(0x00002D34, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference masterRef = Game.GetFormFromFile(0x00002D11, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference exileJacRef = Game.GetFormFromFile(0x00002235, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference exTheresa = Game.GetFormFromFile(0x00003660, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference exLyle = Game.GetFormFromFile(0x00003661, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference fol1Ref = Game.GetFormFromFile(0x00002D35, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference fol2Ref = Game.GetFormFromFile(0x00002D36, "Vault13Chronicles.esp") as ObjectReference

    if akSender == lauraRef
        Actor lauraAct = lauraRef as Actor
        if lauraAct != None && !lauraAct.IsDead()
            QueueCathedralActivateFallback(0x00008102)
        endif
    elseif akSender == lasherRef
        Actor lashAct = lasherRef as Actor
        if lashAct != None && !lashAct.IsDead() && !bLasherHostile && !lashAct.IsInCombat()
            QueueCathedralActivateFallback(0x00008107)
        endif
    elseif akSender == morphRef
        Actor morphAct = morphRef as Actor
        if morphAct != None && !morphAct.IsDead() && !bMorpheusHostile && !morphAct.IsInCombat()
            QueueCathedralActivateFallback(0x00008103)
        endif
    elseif akSender == gideonRef
        Actor gidAct = gideonRef as Actor
        if gidAct != None && !gidAct.IsDead()
            if !bGideonNullifierGiven
                bGideonNullifierGiven = true
                Form psyNull = Game.GetFormFromFile(0x00001333, "Vault13Chronicles.esp")
                if psyNull != None && player.GetItemCount(psyNull) == 0
                    player.AddItem(psyNull, 1, false)
                endif
                Game.RewardPlayerXP(200, false)
                Debug.Notification("[Gideon] ¡Has recibido el Anulador Psíquico! Equípalo antes de cruzar el Pasillo de la Revulsión (+200 XP).")
            endif
            SyncCathedralOptionalObjectives()
            QueueCathedralActivateFallback(0x00008104)
        endif
    elseif akSender == masterRef
        Actor mastAct = masterRef as Actor
        if mastAct != None && !mastAct.IsDead() && !bMasterHostile && !bCountdownActive
            bMasterConfronted = true
            QueueCathedralActivateFallback(0x00008105)
        endif
    elseif akSender == exileJacRef
        Actor jacAct = exileJacRef as Actor
        if jacAct != None && !jacAct.IsDead()
            if Self.GetStage() >= 38
                Debug.Notification("[Supervisor Jacoren]: 'La compuerta del Refugio 13 está sellada para siempre. Sigue el túnel hasta la salida al cañón.'")
            elseif Self.GetStage() >= 35
                bExileSceneTriggered = true
                QueueCathedralActivateFallback(0x00008106)
            endif
        endif
    elseif akSender == exTheresa
        if Self.GetStage() >= 38
            Debug.Notification("[Theresa — Rumbo a Arroyo]: 'No podíamos quedarnos encerrados allí dentro después de lo que te hizo Jacoren. ¡Iremos contigo hacia el norte, hasta Oregón!'")
        endif
    elseif akSender == exLyle
        if Self.GetStage() >= 38
            Debug.Notification("[Lyle — Pionero de Arroyo]: 'Robé las provisiones y los manuales agrícolas del almacén antes del cierre. Cuando estés listo para dejar California, fundaremos Arroyo juntos.'")
        endif
    elseif akSender == fol1Ref || akSender == fol2Ref
        Actor folAct = akSender as Actor
        if folAct != None && !folAct.IsDead()
            Debug.Notification("[Exploradora de los Seguidores]: «Nicole nos envió para cubrir tu infiltración. Avanza hacia el Subnivel IV y detén al Maestro.»")
            folAct.EvaluatePackage()
        endif
    endif
EndEvent

Event OnInit()
    RegisterPlayerEvents()
    StartTimer(2.5, 1)
EndEvent

Event OnQuestInit()
    RegisterPlayerEvents()
    StartTimer(2.5, 1)
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
    bool resumeExile = ((bExileEndingCinematicActive || (Self.GetStage() >= 38 && !bDynamicEndingShown)) && !bCathedralCinematicActive)
    if bCathedralCinematicActive || bExileEndingCinematicActive
        CleanupAct5CinematicSafety(true)
    endif
    if iExileCineFixRev < 4
        iExileCineFixRev = 4
        SetupExileEpilogueActorsAndSeals()
    endif
    if resumeExile
        bExileEndingPlayed = false
        bPendingExileEndingOnExit = true
    endif
    if !bCathedralDetonated && IsPlayerInCathedral(Game.GetPlayer())
        SyncCathedralExteriorDestruction(false)
        SyncMasterVaultExitAndGates()
        MigrateCathedralSanctuaryLiveSave()
    endif
    RegisterPlayerEvents()
    if resumeExile
        StartTimer(1.0, 1)
    else
        StartTimer(2.0, 1)
    endif
EndEvent

Event Actor.OnItemEquipped(Actor akSender, Form akBaseObject, ObjectReference akReference)
    Form vindicator = Game.GetFormFromFile(0x0000110E, "Vault13Chronicles.esp")
    Form psyNull = Game.GetFormFromFile(0x00001333, "Vault13Chronicles.esp")
    Form purpleRobe = Game.GetFormFromFile(0x00001330, "Vault13Chronicles.esp")
    if akBaseObject == vindicator && vindicator != None
        Debug.Notification("[Ametralladora Vindicator - 2161] Supresor rotativo activo: Onda de choque cada 5 impactos (+40 PA / +30 PV)")
    elseif akBaseObject == psyNull && psyNull != None
        Debug.Notification("[Anulador Psíquico] Escudo neural activo: inmune al daño psiónico del Pasillo de la Revulsión.")
    elseif akBaseObject == purpleRobe && purpleRobe != None
        SyncCathedralMutantHostility()
    endif
EndEvent

Event Actor.OnItemUnequipped(Actor akSender, Form akBaseObject, ObjectReference akReference)
    Form purpleRobe = Game.GetFormFromFile(0x00001330, "Vault13Chronicles.esp")
    if akBaseObject == purpleRobe && purpleRobe != None
        SyncCathedralMutantHostility()
    endif
EndEvent

Event ObjectReference.OnItemAdded(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    Form lauraKey = Game.GetFormFromFile(0x000015A7, "Vault13Chronicles.esp")
    Form morphBadge = Game.GetFormFromFile(0x000015A8, "Vault13Chronicles.esp")
    Form psyNull = Game.GetFormFromFile(0x00001333, "Vault13Chronicles.esp")
    if (lauraKey != None && akBaseItem == lauraKey) || (morphBadge != None && akBaseItem == morphBadge)
        TryUnlockCathedralCryptDoor(true)
        UpdateSanctuaryQuestTargetAlias()
        SyncCathedralOptionalObjectives()
    elseif psyNull != None && akBaseItem == psyNull
        SyncCathedralOptionalObjectives()
    endif
EndEvent

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
    SyncCathedralMutantHostility()
    if (bPendingExileEndingOnExit || Self.GetStage() >= 38 || (Self.GetStage() >= 35 && bExileSceneTriggered)) && !bExileEndingPlayed && !bExileEndingCinematicActive
        Actor plLoc = Game.GetPlayer()
        WorldSpace wsLoc = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
        if plLoc != None && wsLoc != None && plLoc.GetWorldSpace() == wsLoc
            if Self.GetStage() < 38
                Self.SetStage(38)
            endif
            if !bExileEndingCinematicActive
                StartExileEndingCinematic()
            endif
            return
        endif
    endif
    if !bCathedralDetonated && (IsPlayerInCathedral(Game.GetPlayer()) || bCountdownActive)
        UpdateCathedralDungeonMechanics()
        if !bCathedralDetonated
            return
        endif
    endif
    if Self.GetStage() >= 35
        InterceptVault13ForExileIfNeeded()
    elseif bCountdownActive && !bCathedralDetonated
        UpdateCathedralDungeonMechanics()
    elseif Self.GetStage() >= 15 && Self.GetStage() < 40
        ApplyV13Act5Stage(Self.GetStage())
    endif
EndEvent

Event Scene.OnEnd(Scene akSender)
    Scene exileSc = Game.GetFormFromFile(0x00008106, "Vault13Chronicles.esp") as Scene
    if akSender != None && akSender == exileSc
        if Self.GetStage() >= 35 && Self.GetStage() < 38
            Self.SetStage(38)
        endif
    endif
EndEvent

Event TopicInfo.OnBegin(TopicInfo akSender, ObjectReference akSpeakerRef, bool abHasBeenSaid)
    TopicInfo exileEndInfo = Game.GetFormFromFile(0x00008385, "Vault13Chronicles.esp") as TopicInfo
    if akSender != None && akSender == exileEndInfo
        if Self.GetStage() >= 35 && Self.GetStage() < 38
            Self.SetStage(38)
        endif
    endif
EndEvent

Event TopicInfo.OnEnd(TopicInfo akSender, ObjectReference akSpeakerRef, bool abHasBeenSaid)
    TopicInfo exileEndInfo = Game.GetFormFromFile(0x00008385, "Vault13Chronicles.esp") as TopicInfo
    if akSender != None && akSender == exileEndInfo
        if Self.GetStage() >= 35 && Self.GetStage() < 38
            Self.SetStage(38)
        endif
    endif
EndEvent

Event Actor.OnCombatStateChanged(Actor akSender, Actor akTarget, int aeCombatState)
    if aeCombatState >= 1 && !bCathedralDetonated
        Actor playerCsc = Game.GetPlayer()
        Cell sanctCellCsc = Game.GetFormFromFile(0x00002D80, "Vault13Chronicles.esp") as Cell
        Cell vaultCellCsc = Game.GetFormFromFile(0x00002D00, "Vault13Chronicles.esp") as Cell
        bool inSanctCsc = (sanctCellCsc != None && ((akSender != None && akSender.GetParentCell() == sanctCellCsc) || (playerCsc != None && playerCsc.GetParentCell() == sanctCellCsc)))
        bool inVaultCsc = (vaultCellCsc != None && ((akSender != None && akSender.GetParentCell() == vaultCellCsc) || (playerCsc != None && playerCsc.GetParentCell() == vaultCellCsc)))
        if inSanctCsc
            SyncSanctuaryAcolytePanic()
        endif
        if inSanctCsc || inVaultCsc || (playerCsc != None && IsPlayerInCathedral(playerCsc))
            SyncCathedralMutantHostility()
        endif
    endif
EndEvent

Event OnStageSet(int auiStageID, int auiItemID)
    ApplyV13Act5Stage(auiStageID)
    StartTimer(0.25, 1)
EndEvent

Event OnTimer(int aiTimerID)
    if aiTimerID == 1
        if bCathedralCinematicActive || bExileEndingCinematicActive
            StartTimer(1.0, 1)
            return
        endif
        CheckStartAndProgress()
        int stg = Self.GetStage()
        if stg < 40 || !rewardsGiven || bCountdownActive || (bPendingExileEndingOnExit && !bExileEndingPlayed)
            Actor pT1 = Game.GetPlayer()
            Cell sanctT1 = Game.GetFormFromFile(0x00002D80, "Vault13Chronicles.esp") as Cell
            bool bSanctPoll = (!bCathedralDetonated && pT1 != None && sanctT1 != None && pT1.GetParentCell() == sanctT1)
            if (bPendingExileEndingOnExit && !bExileEndingPlayed) || (stg >= 35 && stg < 40) || bSanctPoll
                StartTimer(1.0, 1)
            else
                StartTimer(2.5, 1)
            endif
        endif
    elseif aiTimerID == 80
        if !bCountdownActive || bCathedralDetonated
            return
        endif
        Actor player80 = Game.GetPlayer()
        if player80 != None && !IsPlayerInCathedral(player80)
            TriggerCathedralAtomicDetonation()
            return
        endif
        iCountdownSecondsLeft -= 5
        if iCountdownSecondsLeft <= 0
            bCountdownActive = false
            if player80 != None
                Form nukeExpl = Game.GetFormFromFile(0x000C32DA, "Fallout4.esm")
                if nukeExpl != None
                    player80.PlaceAtMe(nukeExpl, 1, false, false)
                endif
                Debug.Notification("[La Catedral] ¡La ojiva atómica ha detonado contigo dentro del Refugio del Futuro!")
                player80.Kill(None)
            endif
            return
        endif
        if (iCountdownSecondsLeft % 30) == 0 || iCountdownSecondsLeft <= 25
            if player80 != None
                Game.ShakeCamera(player80, 0.35, 1.0)
            endif
            Debug.Notification("[Ojiva Nuclear — La Catedral] ¡Detonación atómica en " + iCountdownSecondsLeft + " segundos! ¡Corre hacia la salida!")
        endif
        StartTimer(5.0, 80)
    elseif aiTimerID == 81
        if iPendingSceneID == 0
            return
        endif
        Actor spk81 = GetCathedralSceneSpeaker(iPendingSceneID)
        if spk81 != None && spk81.IsInDialogueWithPlayer()
            iPendingSceneID = 0
            return
        endif
        if (Utility.IsInMenuMode() || (spk81 != None && spk81.IsTalking())) && iSceneRetryTicks < 35
            iSceneRetryTicks += 1
            StartTimer(0.35, 81)
            return
        endif
        int runSceneID = iPendingSceneID
        iPendingSceneID = 0
        Scene targetSc = Game.GetFormFromFile(runSceneID, "Vault13Chronicles.esp") as Scene
        if targetSc != None && !targetSc.IsPlaying() && (spk81 == None || !spk81.IsInDialogueWithPlayer())
            StopCathedralScenes(runSceneID)
            targetSc.Start()
        endif
    elseif aiTimerID == 83
        if iPendingActSceneID == 0
            return
        endif
        int actScId = iPendingActSceneID
        iPendingActSceneID = 0
        Scene actSc = Game.GetFormFromFile(actScId, "Vault13Chronicles.esp") as Scene
        Actor spk83 = GetCathedralSceneSpeaker(actScId)
        if actSc != None && !actSc.IsPlaying() && !Utility.IsInMenuMode() && (spk83 == None || (!spk83.IsInDialogueWithPlayer() && !spk83.IsTalking()))
            ForceAllAct5Aliases()
            StopCathedralScenes(actScId)
            actSc.Start()
        endif
    elseif aiTimerID == 82
        if Utility.IsInMenuMode()
            StartTimer(0.5, 82)
            return
        endif
        ShowDynamicCaliforniaEpilogue()
    elseif aiTimerID == 84
        Form nukeExpl84 = Game.GetFormFromFile(0x000C32DA, "Fallout4.esm")
        ObjectReference nukeAnchor84 = Game.GetFormFromFile(0x00003669, "Vault13Chronicles.esp") as ObjectReference
        if nukeAnchor84 != None && nukeAnchor84.Is3DLoaded()
            if Math.abs(nukeAnchor84.GetPositionX() - (-19500.0)) > 5.0 || Math.abs(nukeAnchor84.GetPositionY() - (-31520.0)) > 5.0 || Math.abs(nukeAnchor84.GetPositionZ() - 260.0) > 5.0
                nukeAnchor84.SetPosition(-19500.0, -31520.0, 260.0)
            endif
        endif
        ObjectReference cathDoor84 = Game.GetFormFromFile(0x00003509, "Vault13Chronicles.esp") as ObjectReference
        if nukeExpl84 != None
            if nukeAnchor84 != None
                nukeAnchor84.PlaceAtMe(nukeExpl84, 1, false, false)
            endif
            if cathDoor84 != None
                cathDoor84.PlaceAtMe(nukeExpl84, 1, false, false)
            endif
        endif
        Actor player84 = Game.GetPlayer()
        if player84 != None
            Game.ShakeCamera(player84, 0.75, 2.2)
        endif
    elseif aiTimerID == 85
        ExecuteJumpToCathedral()
    elseif aiTimerID == 86
        if !bPendingCathedralArrival
            return
        endif
        Actor player86 = Game.GetPlayer()
        WorldSpace ws2161_86 = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
        if player86 != None && ws2161_86 != None && player86.GetWorldSpace() != ws2161_86
            iCathedralJumpRetries += 1
            if !Utility.IsInMenuMode()
                ObjectReference cathFt86 = Game.GetFormFromFile(0x0000351A, "Vault13Chronicles.esp") as ObjectReference
                if cathFt86 != None
                    player86.MoveTo(cathFt86, 0.0, 0.0, 0.0, true)
                endif
            endif
            if iCathedralJumpRetries < 120
                StartTimer(0.35, 86)
            else
                bPendingCathedralArrival = false
            endif
        else
            bPendingCathedralArrival = false
            SetCathedralState(true)
            ApplyV13Act5Stage(20)
            SyncCathedralMutantHostility()
            ForceAllAct5Aliases()
            Self.SetActive(true)
            Debug.Notification("[Salto Directo QA] Asalto a La Catedral (Acto V) — Túnica Púrpura y Holocinta de Vree disponibles en tu inventario.")
        endif
    elseif aiTimerID == 91
        if !bCathedralCinematicActive
            return
        endif
        Actor cinePlayer = Game.GetPlayer()
        if cinePlayer == None
            CleanupAct5CinematicSafety(true)
            return
        endif
        if iCathedralCinePhase == 0
            WorldSpace wsCheck91 = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
            if Utility.IsInMenuMode() || !cinePlayer.Is3DLoaded() || (wsCheck91 != None && cinePlayer.GetWorldSpace() != wsCheck91)
                iAct5CineReadyTicks = 0
                StartTimer(0.45, 91)
                return
            endif
            iAct5CineReadyTicks += 1
            if iAct5CineReadyTicks < 3
                StartTimer(0.45, 91)
                return
            endif
            iAct5CineReadyTicks = 0
            if kAct5CineLayer == None
                kAct5CineLayer = InputEnableLayer.Create()
            endif
            if kAct5CineLayer != None
                kAct5CineLayer.DisablePlayerControls(true, true, true, true, true, false, true, true, true, true, true)
            endif
            cinePlayer.SetGhost(true)
            iCathedralCinePhase = 1
            StartTimer(0.15, 91)
        elseif iCathedralCinePhase == 1
            ObjectReference groundBlast1 = Game.GetFormFromFile(0x00009945, "Vault13Chronicles.esp") as ObjectReference
            Game.ForceFirstPerson()
            Game.ShowFirstPersonGeometry(false)
            cinePlayer.SetAlpha(0.0, false)
            if groundBlast1 != None
                cinePlayer.SetAngle(0.0, 0.0, cinePlayer.GetAngleZ() + cinePlayer.GetHeadingAngle(groundBlast1))
            endif
            Sound sirenSnd = Game.GetFormFromFile(0x001B9C63, "Fallout4.esm") as Sound
            if sirenSnd != None
                iAct5SirenInstance = sirenSnd.Play(cinePlayer)
            endif
            iCathedralCinePhase = 2
            StartTimer(1.6, 91)
        elseif iCathedralCinePhase == 2
            Form libertyNuke = Game.GetFormFromFile(0x001D9C16, "Fallout4.esm")
            Form fatManNuke = Game.GetFormFromFile(0x001A7FF2, "Fallout4.esm")
            Form oldNuke = Game.GetFormFromFile(0x000C32DA, "Fallout4.esm")
            ObjectReference groundBlast = Game.GetFormFromFile(0x00009945, "Vault13Chronicles.esp") as ObjectReference
            ObjectReference spireAnchor = Game.GetFormFromFile(0x00003669, "Vault13Chronicles.esp") as ObjectReference
            if spireAnchor != None && spireAnchor.Is3DLoaded()
                if Math.abs(spireAnchor.GetPositionX() - (-19500.0)) > 5.0 || Math.abs(spireAnchor.GetPositionY() - (-31520.0)) > 5.0 || Math.abs(spireAnchor.GetPositionZ() - 260.0) > 5.0
                    spireAnchor.SetPosition(-19500.0, -31520.0, 260.0)
                endif
            endif
            if libertyNuke != None && groundBlast != None
                groundBlast.PlaceAtMe(libertyNuke, 1, false, false)
            endif
            if fatManNuke != None && spireAnchor != None
                spireAnchor.PlaceAtMe(fatManNuke, 1, false, false)
            endif
            if oldNuke != None && groundBlast != None
                groundBlast.PlaceAtMe(oldNuke, 1, false, false)
            endif
            SyncCathedralExteriorDestruction(true)
            ImageSpaceModifier hugeImod = Game.GetFormFromFile(0x001844BD, "Fallout4.esm") as ImageSpaceModifier
            if hugeImod != None
                hugeImod.Apply(1.0)
            endif
            Game.ShakeCamera(cinePlayer, 1.0, 3.5)
            iCathedralCinePhase = 3
            StartTimer(2.2, 91)
        elseif iCathedralCinePhase == 3
            Form vertibirdExpl3 = Game.GetFormFromFile(0x00020023, "Fallout4.esm")
            Form fatManNuke3 = Game.GetFormFromFile(0x001A7FF2, "Fallout4.esm")
            ObjectReference groundBlast3 = Game.GetFormFromFile(0x00009945, "Vault13Chronicles.esp") as ObjectReference
            ObjectReference spireAnchor3 = Game.GetFormFromFile(0x00003669, "Vault13Chronicles.esp") as ObjectReference
            if spireAnchor3 != None && spireAnchor3.Is3DLoaded()
                if Math.abs(spireAnchor3.GetPositionX() - (-19500.0)) > 5.0 || Math.abs(spireAnchor3.GetPositionY() - (-31520.0)) > 5.0 || Math.abs(spireAnchor3.GetPositionZ() - 260.0) > 5.0
                    spireAnchor3.SetPosition(-19500.0, -31520.0, 260.0)
                endif
            endif
            if vertibirdExpl3 != None && groundBlast3 != None
                groundBlast3.PlaceAtMe(vertibirdExpl3, 1, false, false)
            endif
            if fatManNuke3 != None && groundBlast3 != None
                groundBlast3.PlaceAtMe(fatManNuke3, 1, false, false)
            endif
            SyncCathedralExteriorDestruction(true)
            ImageSpaceModifier shockImod = Game.GetFormFromFile(0x001851A2, "Fallout4.esm") as ImageSpaceModifier
            if shockImod != None
                shockImod.Apply(0.9)
            endif
            Game.ShakeCamera(cinePlayer, 0.85, 2.5)
            iCathedralCinePhase = 4
            StartTimer(2.5, 91)
        else
            CleanupAct5CinematicSafety(true)
            Game.RewardPlayerXP(800, false)
            Debug.Notification("[La Catedral] ¡DETONACIÓN TERMONUCLEAR! ¡La torre de la Unidad ha sido borrada de la faz de California! (+800 XP)")
            if Self.GetStage() < 30
                Self.SetStage(30)
            else
                CheckTriggerExileEpilogue()
            endif
        endif
    elseif aiTimerID == 92
        Actor exilePlayer = Game.GetPlayer()
        WorldSpace wsCheck92 = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
        if exilePlayer == None
            return
        endif
        if Utility.IsInMenuMode() || !exilePlayer.Is3DLoaded() || (wsCheck92 != None && exilePlayer.GetWorldSpace() != wsCheck92)
            StartTimer(0.5, 92)
            return
        endif
        if iExileCinePhase == 0
            SetupExileEpilogueActorsAndSeals()
            Sound endingMusic = Game.GetFormFromFile(0x00001079, "Vault13Chronicles.esp") as Sound
            if endingMusic != None && iEndingMusicInstance < 0
                iEndingMusicInstance = endingMusic.Play(exilePlayer)
            endif
            Debug.Notification("[Refugio 13 — 10 de mayo de 2162] La compuerta dentada de acero ha sido sellada desde el interior. Tu leyenda pertenece ahora al Yermo.")
            Debug.Notification("[Theresa — Rumbo a Arroyo]: 'No podíamos quedarnos encerrados allí dentro después de lo que te hizo Jacoren. ¡Iremos contigo hacia el norte, hasta Oregón!'")
            iExileCinePhase = 1
            StartTimer(2.5, 92)
        else
            Debug.Notification("[Lyle — Pionero de Arroyo]: 'Robé las provisiones y los manuales agrícolas del almacén antes del cierre. Cuando estés listo para dejar California, fundaremos Arroyo juntos.'")
            iExileCinePhase = 0
            iExileCineFixRev = 4
            if Self.GetStage() < 40
                Self.SetStage(40)
            endif
            StartTimer(1.2, 82)
        endif
    endif
EndEvent

Function QueueJumpToCathedral()
    if bCathedralJumpBusy
        return
    endif
    bCathedralJumpBusy = true
    bPendingCathedralArrival = true
    iCathedralJumpRetries = 0

    Quest q1 = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as Quest
    V13Act1QuestScript act1S = q1 as V13Act1QuestScript
    if act1S != None
        act1S.SilentCompleteAct1ForJump()
    endif
    if q1 != None
        q1.SetStage(40)
    endif

    V13Act2QuestScript act2S = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as V13Act2QuestScript
    if act2S != None
        act2S.SilentCompleteAct2ForJump()
    endif

    V13Act3QuestScript act3S = Game.GetFormFromFile(0x00006002, "Vault13Chronicles.esp") as V13Act3QuestScript
    if act3S != None
        act3S.SilentCompleteAct3ForJump()
    endif

    V13Act4QuestScript act4S = Game.GetFormFromFile(0x00007000, "Vault13Chronicles.esp") as V13Act4QuestScript
    if act4S != None
        act4S.SilentCompleteAct4ForJump()
    endif

    V13SideQuestFollowersSpyScript spyS = Game.GetFormFromFile(0x000D4000, "Vault13Chronicles.esp") as V13SideQuestFollowersSpyScript
    if spyS != None
        spyS.SilentCompleteFollowersSpyForJump()
    endif

    if Self.IsCompleted() || Self.GetStage() > 20 || bCathedralDetonated
        Self.Reset()
    endif
    if !Self.IsRunning()
        Self.Start()
    endif

    InputEnableLayer tempLayer = InputEnableLayer.Create()
    if tempLayer != None
        tempLayer.DisablePlayerControls(false, false, false, false, false, true, false, false, false, false, false)
        Utility.WaitMenuMode(0.1)
        tempLayer.EnablePlayerControls()
        tempLayer.Delete()
    endif
    StartTimer(0.1, 85)
EndFunction

Function ExecuteJumpToCathedral()
    Actor player = Game.GetPlayer()
    if player == None
        bCathedralJumpBusy = false
        return
    endif

    CancelTimer(80)
    introShown = true
    rewardsGiven = false
    bVindicatorPreGranted = false
    bStage30Done = false
    bStage35Ready = false
    bStage40Rewarded = false
    bApplyingAct5Stage = false
    bCathedralDisguiseBlown = false
    bLauraKeyGiven = false
    bLasherBadgeGiven = false
    bMorpheusBadgeGiven = false
    bGideonNullifierGiven = false
    bFollowersStrikeDeployed = false
    bPsychicShieldNotified = false
    bMorpheusHostile = false
    bLasherHostile = false
    bMasterHostile = false
    bMasterConfronted = false
    bCountdownActive = false
    CleanupAct5CinematicSafety(true)
    bCathedralDetonated = false
    bCathedralSanctuaryMigratedV3 = false
    bExileSceneTriggered = false
    bDynamicEndingShown = false
    bExileEndingPlayed = false
    bPendingExileEndingOnExit = false
    bCryptDoorAutoUnlocked = false
    iCountdownSecondsLeft = 240
    lastAppliedAct5Stage = 0
    Self.SetObjectiveDisplayed(22, false, false)
    Self.SetObjectiveDisplayed(23, false, false)
    Self.SetObjectiveDisplayed(24, false, false)

    int[] clearItemFids = new int[5]
    clearItemFids[0] = 0x000015A6
    clearItemFids[1] = 0x000015A7
    clearItemFids[2] = 0x000015A8
    clearItemFids[3] = 0x00001333
    clearItemFids[4] = 0x00001115
    int cIdx = 0
    while cIdx < 5
        Form cf = Game.GetFormFromFile(clearItemFids[cIdx], "Vault13Chronicles.esp")
        if cf != None && player.GetItemCount(cf) > 0
            player.RemoveItem(cf, player.GetItemCount(cf), true, None)
        endif
        cIdx += 1
    endwhile

    ObjectReference cathDoor = Game.GetFormFromFile(0x00003509, "Vault13Chronicles.esp") as ObjectReference
    if cathDoor != None
        cathDoor.SetLockLevel(0)
        cathDoor.Lock(false, false)
    endif
    ObjectReference sanctDoor = Game.GetFormFromFile(0x00002D81, "Vault13Chronicles.esp") as ObjectReference
    if sanctDoor != None
        sanctDoor.SetLockLevel(0)
        sanctDoor.Lock(false, false)
    endif
    ObjectReference cryptDoor = Game.GetFormFromFile(0x00002D83, "Vault13Chronicles.esp") as ObjectReference
    if cryptDoor != None
        cryptDoor.SetLockLevel(100)
        cryptDoor.Lock(true, false)
    endif
    SyncCathedralExteriorDestruction(false)
    ObjectReference v13GearDoor = Game.GetFormFromFile(0x00002201, "Vault13Chronicles.esp") as ObjectReference
    if v13GearDoor != None
        v13GearDoor.SetLockLevel(0)
        v13GearDoor.Lock(false, false)
    endif
    ObjectReference v13InnerDoor = Game.GetFormFromFile(0x00002208, "Vault13Chronicles.esp") as ObjectReference
    if v13InnerDoor != None
        v13InnerDoor.SetLockLevel(0)
        v13InnerDoor.Lock(false, false)
    endif

    int[] revFids = new int[15]
    revFids[0] = 0x00002D11
    revFids[1] = 0x00002D12
    revFids[2] = 0x00002D32
    revFids[3] = 0x00002D33
    revFids[4] = 0x00002D34
    revFids[5] = 0x00002D35
    revFids[6] = 0x00002D36
    revFids[7] = 0x00002D20
    revFids[8] = 0x00002D21
    revFids[9] = 0x00002D22
    revFids[10] = 0x00002D84
    revFids[11] = 0x00002D85
    revFids[12] = 0x00002D86
    revFids[13] = 0x00002D87
    revFids[14] = 0x00002D88
    Faction playerFac = Game.GetFormFromFile(0x0001C21C, "Fallout4.esm") as Faction
    Faction raiderFac = Game.GetFormFromFile(0x0001CBED, "Fallout4.esm") as Faction
    Faction smFac = Game.GetFormFromFile(0x00058305, "Fallout4.esm") as Faction
    Faction cultCivFac = Game.GetFormFromFile(0x00001C59, "Vault13Chronicles.esp") as Faction
    Faction folStrikeFac = Game.GetFormFromFile(0x00001C5A, "Vault13Chronicles.esp") as Faction
    int rIdx = 0
    while rIdx < 15
        int rf = revFids[rIdx]
        Actor revAct = Game.GetFormFromFile(rf, "Vault13Chronicles.esp") as Actor
        if revAct != None
            if rf == 0x00002D35 || rf == 0x00002D36
                if revAct.IsInCombat()
                    revAct.StopCombat()
                endif
                if !bFollowersStrikeDeployed
                    if !revAct.IsDisabled()
                        revAct.DisableNoWait()
                    endif
                else
                    if revAct.IsDead()
                        revAct.Resurrect()
                    endif
                    revAct.EnableNoWait()
                    if playerFac != None && revAct.IsInFaction(playerFac)
                        revAct.RemoveFromFaction(playerFac)
                    endif
                    if folStrikeFac != None && !revAct.IsInFaction(folStrikeFac)
                        revAct.AddToFaction(folStrikeFac)
                    endif
                endif
            else
                if revAct.IsDead()
                    revAct.Resurrect()
                endif
                revAct.EnableNoWait()
                if revAct.IsInCombat()
                    revAct.StopCombat()
                endif
                if rf == 0x00002D11 || rf == 0x00002D12 || rf == 0x00002D33 || rf == 0x00002D20 || rf == 0x00002D21 || rf == 0x00002D22 || rf == 0x00002D25 || rf == 0x00002D26 || rf == 0x00002D84 || rf == 0x00002D85
                    if raiderFac != None && revAct.IsInFaction(raiderFac)
                        revAct.RemoveFromFaction(raiderFac)
                    endif
                    if playerFac != None && revAct.IsInFaction(playerFac)
                        revAct.RemoveFromFaction(playerFac)
                    endif
                    if smFac != None && !revAct.IsInFaction(smFac)
                        revAct.AddToFaction(smFac)
                    endif
                    if rf == 0x00002D11 || rf == 0x00002D12 || rf == 0x00002D33
                        revAct.SetValue(Game.GetAggressionAV(), 0.0)
                    endif
                elseif rf == 0x00002D32 || rf == 0x00002D34 || rf >= 0x00002D86
                    if playerFac != None && revAct.IsInFaction(playerFac)
                        revAct.RemoveFromFaction(playerFac)
                    endif
                    if cultCivFac != None && !revAct.IsInFaction(cultCivFac)
                        revAct.AddToFaction(cultCivFac)
                    endif
                    revAct.SetValue(Game.GetAggressionAV(), 0.0)
                    if rf >= 0x00002D86
                        revAct.SetValue(Game.GetConfidenceAV(), 2.0)
                        ActorValue fleeAVJump = Game.GetFormFromFile(0x00214027, "Fallout4.esm") as ActorValue
                        if fleeAVJump != None
                            revAct.SetValue(fleeAVJump, 0.0)
                        endif
                    endif
                    revAct.EvaluatePackage(true)
                endif
            endif
        endif
        rIdx += 1
    endwhile
    MigrateGideonToPsychicCell()

    Form v13Suit = Game.GetFormFromFile(0x00001307, "Vault13Chronicles.esp")
    if v13Suit != None && player.GetItemCount(v13Suit) == 0
        player.AddItem(v13Suit, 1, true)
    endif
    Form colt6520 = Game.GetFormFromFile(0x00001102, "Vault13Chronicles.esp")
    if colt6520 != None && player.GetItemCount(colt6520) == 0
        player.AddItem(colt6520, 1, true)
    endif
    Form ammo10mm = Game.GetFormFromFile(0x0001F276, "Fallout4.esm")
    if ammo10mm != None && player.GetItemCount(ammo10mm) < 120
        player.AddItem(ammo10mm, 120 - player.GetItemCount(ammo10mm), true)
    endif
    Form wattz2000 = Game.GetFormFromFile(0x00001108, "Vault13Chronicles.esp")
    if wattz2000 != None && player.GetItemCount(wattz2000) == 0
        player.AddItem(wattz2000, 1, true)
    endif
    Form fusionCell = Game.GetFormFromFile(0x000C1897, "Fallout4.esm")
    if fusionCell != None && player.GetItemCount(fusionCell) < 160
        player.AddItem(fusionCell, 160 - player.GetItemCount(fusionCell), true)
    endif
    Form turboP94 = Game.GetFormFromFile(0x0000110B, "Vault13Chronicles.esp")
    if turboP94 != None && player.GetItemCount(turboP94) == 0
        player.AddItem(turboP94, 1, true)
    endif
    Form plasmaAmmo = Game.GetFormFromFile(0x0001DBB7, "Fallout4.esm")
    if plasmaAmmo != None && player.GetItemCount(plasmaAmmo) < 160
        player.AddItem(plasmaAmmo, 160 - player.GetItemCount(plasmaAmmo), true)
    endif
    Form vreeHolo = Game.GetFormFromFile(0x00001113, "Vault13Chronicles.esp")
    if vreeHolo != None && player.GetItemCount(vreeHolo) == 0
        player.AddItem(vreeHolo, 1, true)
    endif
    Form purpleRobe = Game.GetFormFromFile(0x00001330, "Vault13Chronicles.esp")
    if purpleRobe != None && player.GetItemCount(purpleRobe) == 0
        player.AddItem(purpleRobe, 1, true)
    endif
    Form stimpak = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
    if stimpak != None && player.GetItemCount(stimpak) < 25
        player.AddItem(stimpak, 25 - player.GetItemCount(stimpak), true)
    endif
    Form radaway = Game.GetFormFromFile(0x00023742, "Fallout4.esm")
    if radaway != None && player.GetItemCount(radaway) < 10
        player.AddItem(radaway, 10 - player.GetItemCount(radaway), true)
    endif
    Form bobbyPin = Game.GetFormFromFile(0x0000000A, "Fallout4.esm")
    if bobbyPin != None && player.GetItemCount(bobbyPin) < 20
        player.AddItem(bobbyPin, 20 - player.GetItemCount(bobbyPin), true)
    endif

    int[] mapFids = new int[5]
    mapFids[0] = 0x0000341A
    mapFids[1] = 0x00003420
    mapFids[2] = 0x00003410
    mapFids[3] = 0x00003411
    mapFids[4] = 0x0000341B
    int mIdx = 0
    while mIdx < 5
        ObjectReference mm = Game.GetFormFromFile(mapFids[mIdx], "Vault13Chronicles.esp") as ObjectReference
        if mm != None
            mm.EnableNoWait()
            mm.AddToMap(true)
        endif
        mIdx += 1
    endwhile

    RegisterPlayerEvents()
    SetCathedralState(true)
    Self.SetStage(20)
    bCathedralSanctuaryMigratedV3 = false
    MigrateCathedralSanctuaryLiveSave()
    SyncCathedralMutantHostility()
    UpdateSanctuaryQuestTargetAlias()
    ObjectReference cathFtMarker = Game.GetFormFromFile(0x0000351A, "Vault13Chronicles.esp") as ObjectReference
    if cathFtMarker != None
        player.MoveTo(cathFtMarker, 0.0, 0.0, 0.0, true)
    endif
    bCathedralJumpBusy = false
    StartTimer(0.35, 86)
EndFunction
