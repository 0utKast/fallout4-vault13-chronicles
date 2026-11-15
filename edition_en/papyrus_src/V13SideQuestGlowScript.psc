Scriptname V13SideQuestGlowScript extends Quest

bool bItemDelivered = False
bool bRewardGranted = False
bool bHoloRecovered = False
bool bHoloSeeded = False
bool bAllenCorpsePrepared = False
bool bAllenArmorEquipped = False
bool bDeconLockerStocked = False
bool bWestTekPowerRestored = False
bool bFEVLogsDownloaded = False
bool bZAXChessWon = False
bool bZAXVaultUnlocked = False
bool bRadWarningShown = False
bool bStg20Notified = False
bool bStg22Notified = False
bool bStg25Notified = False
bool bStg30Notified = False
bool bMenuJumpBusy = False
int sceneWaitTicks = 0
int zaxWaitTicks = 0
bool bLostHillsGuardsResetV2 = False
bool bLostHillsGuardsHavokRebuiltV3 = False
bool bStuckRadPurgedV1 = False
bool bWestTekSentryRelocatedV2 = False
bool bZAXSpeakerMovedV2 = False
int zaxPendingAction = 0

Function ForceQuestAlias(int aiAliasID, int aiFormID)
    ObjectReference targetRef = Game.GetFormFromFile(aiFormID, "Vault13Chronicles.esp") as ObjectReference
    ReferenceAlias al = Self.GetAlias(aiAliasID) as ReferenceAlias
    if al != None && targetRef != None
        if al.GetReference() != targetRef
            al.ForceRefTo(targetRef)
        endif
    endif
EndFunction

Function ForceAllGlowAliases()
    if Self.IsCompleted() || Self.GetStage() >= 40 || Self.IsStageDone(40) || bRewardGranted
        return
    endif
    Actor player = Game.GetPlayer()
    Cell westTekCell = Game.GetFormFromFile(0x00002800, "Vault13Chronicles.esp") as Cell
    bool inWestTek = (player != None && westTekCell != None && player.GetParentCell() == westTekCell)

    ForceQuestAlias(0, 0x000035D0)
    if inWestTek
        ForceQuestAlias(1, 0x00002810) ; Fallen Sgt. Dennis Allen inside West Tek
    else
        ObjectReference craterHatch = Game.GetFormFromFile(0x00003601, "Vault13Chronicles.esp") as ObjectReference
        if craterHatch != None
            ForceQuestAlias(1, 0x00003601)
        else
            ForceQuestAlias(1, 0x000035D2)
        endif
    endif
    ForceQuestAlias(2, 0x00003005)
    ForceQuestAlias(3, 0x00002003)
    ForceQuestAlias(4, 0x00003601)
    ForceQuestAlias(5, 0x00002101)
    ForceQuestAlias(6, 0x00003501)
    ForceQuestAlias(7, 0x00002801)
    ForceQuestAlias(8, 0x00002035)
    ForceQuestAlias(9, 0x000035D1)
    ForceQuestAlias(10, 0x000035D0)
    ForceQuestAlias(11, 0x00002815) ; Supercomputer ZAX 1.2
    ForceQuestAlias(12, 0x00002810) ; Fallen Sgt. Dennis Allen
EndFunction

Function PrepareWestTekFacilityState()
    ObjectReference allenObj = Game.GetFormFromFile(0x00002810, "Vault13Chronicles.esp") as ObjectReference
    if allenObj != None
        RegisterForRemoteEvent(allenObj, "OnActivate")
        RegisterForRemoteEvent(allenObj, "OnItemRemoved")
    endif
    ObjectReference zaxPreRef = Game.GetFormFromFile(0x00002815, "Vault13Chronicles.esp") as ObjectReference
    if zaxPreRef != None
        RegisterForRemoteEvent(zaxPreRef, "OnActivate")
    endif
    Actor pPre = Game.GetPlayer()
    Cell westTekCellPre = Game.GetFormFromFile(0x00002800, "Vault13Chronicles.esp") as Cell
    WorldSpace caliWorldPre = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    bool inWestTekPre = (pPre != None && westTekCellPre != None && pPre.GetParentCell() == westTekCellPre)
    bool inCaliPre = (pPre != None && caliWorldPre != None && pPre.GetWorldSpace() == caliWorldPre)
    if !inWestTekPre && !inCaliPre
        return
    endif
    ObjectReference craterHatch = Game.GetFormFromFile(0x00003601, "Vault13Chronicles.esp") as ObjectReference
    if craterHatch != None
        if craterHatch.IsDisabled()
            craterHatch.EnableNoWait()
        endif
        if craterHatch.IsLocked()
            craterHatch.Lock(False, False)
        endif
    endif
    ObjectReference exitDoor = Game.GetFormFromFile(0x00002801, "Vault13Chronicles.esp") as ObjectReference
    if exitDoor != None
        if exitDoor.IsDisabled()
            exitDoor.EnableNoWait()
        endif
        if exitDoor.IsLocked()
            exitDoor.Lock(False, False)
        endif
    endif

    ; Stock Decontamination Locker (0x00002834) once with Hazmat Suit, Rad-X, RadAway, and Mentats
    ObjectReference deconLocker = Game.GetFormFromFile(0x00002834, "Vault13Chronicles.esp") as ObjectReference
    if deconLocker != None && !bDeconLockerStocked
        if deconLocker.IsDisabled()
            deconLocker.EnableNoWait()
        endif
        Form hazmat = Game.GetFormFromFile(0x000CEAC4, "Fallout4.esm")
        Form radx = Game.GetFormFromFile(0x00024057, "Fallout4.esm")
        Form radaway = Game.GetFormFromFile(0x00023742, "Fallout4.esm")
        Form mentats = Game.GetFormFromFile(0x0003377B, "Fallout4.esm")
        if hazmat != None && deconLocker.GetItemCount(hazmat) == 0
            deconLocker.AddItem(hazmat, 1, True)
        endif
        if radx != None && deconLocker.GetItemCount(radx) == 0
            deconLocker.AddItem(radx, 4, True)
        endif
        if radaway != None && deconLocker.GetItemCount(radaway) == 0
            deconLocker.AddItem(radaway, 4, True)
        endif
        if mentats != None && deconLocker.GetItemCount(mentats) == 0
            deconLocker.AddItem(mentats, 2, True)
        endif
        bDeconLockerStocked = True
    endif

    ; Fallen Brotherhood Sergeant Dennis Allen (0x00002810)
    Actor allenCorpse = Game.GetFormFromFile(0x00002810, "Vault13Chronicles.esp") as Actor
    Form holoBase = Game.GetFormFromFile(0x00001454, "Vault13Chronicles.esp")
    Form keycardBase = Game.GetFormFromFile(0x00001512, "Vault13Chronicles.esp")
    Actor player = Game.GetPlayer()
    if allenCorpse != None
        if allenCorpse.IsDisabled()
            allenCorpse.EnableNoWait()
        endif
        if !bAllenArmorEquipped && allenCorpse.Is3DLoaded()
            Outfit bosOutfit = Game.GetFormFromFile(0x000E04A0, "Fallout4.esm") as Outfit
            Form bosUniform = Game.GetFormFromFile(0x000DEDEB, "Fallout4.esm")
            if bosOutfit != None
                allenCorpse.SetOutfit(bosOutfit, False)
            endif
            if bosUniform != None
                if allenCorpse.GetItemCount(bosUniform) == 0
                    allenCorpse.AddItem(bosUniform, 1, True)
                endif
                if !allenCorpse.IsEquipped(bosUniform)
                    allenCorpse.EquipItem(bosUniform, False, True)
                endif
                if allenCorpse.IsEquipped(bosUniform)
                    bAllenArmorEquipped = True
                endif
            endif
        endif
        if allenCorpse.Is3DLoaded() && !allenCorpse.IsDead()
            allenCorpse.KillSilent()
        endif
        RegisterForRemoteEvent(allenCorpse as ObjectReference, "OnActivate")
        RegisterForRemoteEvent(allenCorpse as ObjectReference, "OnItemRemoved")
        if !bAllenCorpsePrepared
            if keycardBase != None && allenCorpse.GetItemCount(keycardBase) == 0
                allenCorpse.AddItem(keycardBase, 1, True)
            endif
            if !bHoloRecovered && !bItemDelivered && Self.GetStage() < 25 && holoBase != None
                if (player == None || player.GetItemCount(holoBase) == 0) && allenCorpse.GetItemCount(holoBase) == 0
                    allenCorpse.AddItem(holoBase, 1, True)
                endif
            endif
            bAllenCorpsePrepared = True
        endif
    endif

    ; Sync Auxiliary Generator state (0x00002820..2824)
    ObjectReference genBroken = Game.GetFormFromFile(0x00002820, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference genSparks = Game.GetFormFromFile(0x00002822, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference genRunning = Game.GetFormFromFile(0x00002823, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference genLight = Game.GetFormFromFile(0x00002824, "Vault13Chronicles.esp") as ObjectReference
    if bWestTekPowerRestored
        if genBroken != None && !genBroken.IsDisabled()
            genBroken.DisableNoWait()
        endif
        if genSparks != None && !genSparks.IsDisabled()
            genSparks.DisableNoWait()
        endif
        if genRunning != None && genRunning.IsDisabled()
            genRunning.EnableNoWait()
        endif
        if genLight != None && genLight.IsDisabled()
            genLight.EnableNoWait()
        endif
    else
        if genBroken != None && genBroken.IsDisabled()
            genBroken.EnableNoWait()
        endif
        if genSparks != None && genSparks.IsDisabled()
            genSparks.EnableNoWait()
        endif
        if genRunning != None && !genRunning.IsDisabled()
            genRunning.DisableNoWait()
        endif
        if genLight != None && !genLight.IsDisabled()
            genLight.DisableNoWait()
        endif
    endif

    ; Sync ZAX 1.2 Mainframe Speaker (0x00002815) & High-Security Vault (0x00002835)
    ObjectReference zaxSpeaker = Game.GetFormFromFile(0x00002815, "Vault13Chronicles.esp") as ObjectReference
    Actor zaxActor = zaxSpeaker as Actor
    Faction playerFact = Game.GetFormFromFile(0x0001C21C, "Fallout4.esm") as Faction
    if zaxSpeaker != None
        if zaxSpeaker.IsDisabled()
            zaxSpeaker.EnableNoWait()
        endif
        if !bZAXSpeakerMovedV2 && (!inWestTekPre || zaxSpeaker.GetPositionX() < 3400.0)
            zaxSpeaker.SetPosition(3736.0, 5692.0, 288.5)
            zaxSpeaker.SetAngle(0.0, 0.0, 270.0)
            bZAXSpeakerMovedV2 = True
        endif
        if zaxActor != None
            if playerFact != None && zaxActor.IsInFaction(playerFact)
                zaxActor.RemoveFromFaction(playerFact)
            endif
            zaxActor.SetValue(Game.GetAggressionAV(), 0.0)
            zaxActor.SetValue(Game.GetConfidenceAV(), 0.0)
            if zaxActor.IsInCombat()
                zaxActor.StopCombat()
                zaxActor.StopCombatAlarm()
            endif
        endif
        RegisterForRemoteEvent(zaxSpeaker, "OnActivate")
    endif
    int rIdx = 0
    while rIdx < 4
        int robotFID = 0x00002811 + rIdx
        if rIdx == 3
            robotFID = 0x000035D2
        endif
        Actor botAct = Game.GetFormFromFile(robotFID, "Vault13Chronicles.esp") as Actor
        if botAct != None && !botAct.IsDead()
            botAct.SetValue(Game.GetAggressionAV(), 1.0)
            if zaxActor != None && botAct.IsInCombat() && botAct.GetCombatTarget() == zaxActor
                botAct.StopCombat()
                botAct.StopCombatAlarm()
                botAct.EvaluatePackage()
            endif
        endif
        rIdx += 1
    endwhile

    ObjectReference zaxSafe = Game.GetFormFromFile(0x00002835, "Vault13Chronicles.esp") as ObjectReference
    if zaxSafe != None
        if zaxSafe.IsDisabled()
            zaxSafe.EnableNoWait()
        endif
        if bZAXVaultUnlocked
            if zaxSafe.IsLocked()
                zaxSafe.Lock(False, False)
            endif
        else
            if !zaxSafe.IsLocked()
                zaxSafe.SetLockLevel(253)
                zaxSafe.Lock(True, False)
            endif
        endif
        RegisterForRemoteEvent(zaxSafe, "OnActivate")
    endif
EndFunction

bool Function RescueLostHillsGuard(Actor akGuard, ObjectReference akAnchor, float afTargetX, float afTargetY, float afOffX, float afOffY, float afAngZ, bool abForce3DReset, bool abRebuildHavok = False)
    if akGuard == None || akGuard.IsDead()
        return False
    endif
    if akGuard.IsInCombat() || akGuard.IsInDialogueWithPlayer() || akGuard.IsTalking()
        return False
    endif
    WorldSpace ws2161 = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    float gx = akGuard.GetPositionX()
    float gy = akGuard.GetPositionY()
    float gz = akGuard.GetPositionZ()
    bool outOfBounds = (gz < 96.0 || gz > 138.0 || Math.Abs(gx - afTargetX) > 40.0 || Math.Abs(gy - afTargetY) > 40.0)
    if !akGuard.Is3DLoaded()
        if outOfBounds || !bLostHillsGuardsResetV2
            if akAnchor != None
                akGuard.MoveTo(akAnchor, afOffX, afOffY, 2.0, False)
            else
                akGuard.SetPosition(afTargetX, afTargetY, 122.0)
            endif
            akGuard.SetAngle(0.0, 0.0, afAngZ)
        endif
        return False
    endif
    if abRebuildHavok
        akGuard.DisableNoWait(False)
        Utility.Wait(0.15)
        akGuard.EnableNoWait(False)
        if akAnchor != None
            akGuard.MoveTo(akAnchor, afOffX, afOffY, 2.0, False)
        else
            akGuard.SetPosition(afTargetX, afTargetY, 122.0)
        endif
        akGuard.SetAngle(0.0, 0.0, afAngZ)
        akGuard.EvaluatePackage()
        return True
    endif
    if outOfBounds || abForce3DReset
        if akAnchor != None
            akGuard.MoveTo(akAnchor, afOffX, afOffY, 2.0, False)
        else
            akGuard.SetPosition(afTargetX, afTargetY, 122.0)
        endif
        akGuard.SetAngle(0.0, 0.0, afAngZ)
        akGuard.EvaluatePackage()
    endif
    return True
EndFunction

Function RefreshGlowSettlementLayout()
    Actor pGlow = Game.GetPlayer()
    WorldSpace caliGlow = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if pGlow == None || caliGlow == None || pGlow.GetWorldSpace() != caliGlow
        return
    endif
    Form noteBase = Game.GetFormFromFile(0x0000114D, "Vault13Chronicles.esp")
    if noteBase != None
        ObjectReference noteRef = Game.FindClosestReferenceOfType(noteBase, -24860.0, -7740.0, 120.0, 400.0)
        if noteRef != None && noteRef.GetContainer() == None
            noteRef.SetPosition(-24890.0, -7744.0, 176.5)
        endif
    endif

    ObjectReference ftLh = Game.GetFormFromFile(0x00003518, "Vault13Chronicles.esp") as ObjectReference
    if ftLh != None
        if Math.Abs(ftLh.GetPositionX() - (-24500.0)) > 4.0 || Math.Abs(ftLh.GetPositionY() - (-7680.0)) > 4.0 || Math.Abs(ftLh.GetPositionZ() - 120.0) > 4.0
            ftLh.SetPosition(-24500.0, -7680.0, 120.0)
            ftLh.SetAngle(0.0, 0.0, 0.0)
        endif
    endif
    Actor cabbotAct = Game.GetFormFromFile(0x000035D0, "Vault13Chronicles.esp") as Actor
    Actor talusAct = Game.GetFormFromFile(0x000035D1, "Vault13Chronicles.esp") as Actor
    bool forceResetNow = !bLostHillsGuardsResetV2
    bool rebuildHavokNow = !bLostHillsGuardsHavokRebuiltV3
    bool cabbotChecked = RescueLostHillsGuard(cabbotAct, ftLh, -24660.0, -7840.0, -160.0, -160.0, 150.0, forceResetNow, rebuildHavokNow)
    bool talusChecked = RescueLostHillsGuard(talusAct, ftLh, -24340.0, -7840.0, 160.0, -160.0, 210.0, forceResetNow, rebuildHavokNow)
    if cabbotChecked && talusChecked
        bLostHillsGuardsResetV2 = True
        bLostHillsGuardsHavokRebuiltV3 = True
    endif
    Actor sentryAct = Game.GetFormFromFile(0x000035D2, "Vault13Chronicles.esp") as Actor
    if sentryAct != None && !sentryAct.IsDead()
        float sx = sentryAct.GetPositionX()
        float sy = sentryAct.GetPositionY()
        float sz = sentryAct.GetPositionZ()
        bool inBunkerWall = (sx >= 31070.0 && sx <= 32050.0 && sy >= -33580.0 && sy <= -32760.0)
        bool atOldWall = (Math.Abs(sx - 31180.0) < 220.0 && Math.Abs(sy + 33680.0) < 220.0)
        if sz < -120.0 || sz > 450.0
            sentryAct.SetPosition(31500.0, -33920.0, 124.0)
            sentryAct.SetAngle(0.0, 0.0, 180.0)
            bWestTekSentryRelocatedV2 = True
        elseif !bWestTekSentryRelocatedV2 && (inBunkerWall || atOldWall) && (!sentryAct.IsInCombat() || sentryAct.GetDistance(pGlow) > 950.0)
            sentryAct.SetPosition(31500.0, -33920.0, 124.0)
            sentryAct.SetAngle(0.0, 0.0, 180.0)
            bWestTekSentryRelocatedV2 = True
        elseif !sentryAct.IsInCombat() && (inBunkerWall || sz < 80.0 || sz > 260.0 || Math.Abs(sx - 31500.0) > 650.0 || Math.Abs(sy + 33920.0) > 650.0)
            sentryAct.SetPosition(31500.0, -33920.0, 124.0)
            sentryAct.SetAngle(0.0, 0.0, 180.0)
        endif
    endif
EndFunction

Function SilenceGlowActorsExcept(Actor akSpeaker)
    Topic stopTopic = Game.GetFormFromFile(0x00004003, "Vault13Chronicles.esp") as Topic
    if stopTopic == None
        return
    endif
    Actor cabbotAct = Game.GetFormFromFile(0x000035D0, "Vault13Chronicles.esp") as Actor
    Actor talusAct = Game.GetFormFromFile(0x000035D1, "Vault13Chronicles.esp") as Actor
    if cabbotAct != None && cabbotAct != akSpeaker && cabbotAct.IsTalking()
        cabbotAct.Say(stopTopic, None, false, None)
    endif
    if talusAct != None && talusAct != akSpeaker && talusAct.IsTalking()
        talusAct.Say(stopTopic, None, false, None)
    endif
EndFunction

Function ClearStuckWestTekRadiation(Actor akPlayer)
    if akPlayer == None || !akPlayer.Is3DLoaded() || Utility.IsInMenuMode()
        return
    endif
    Spell radLight = Game.GetFormFromFile(0x0009252C, "Fallout4.esm") as Spell
    Spell radStrong = Game.GetFormFromFile(0x0009253D, "Fallout4.esm") as Spell
    MagicEffect radMgef = Game.GetFormFromFile(0x0009252A, "Fallout4.esm") as MagicEffect
    bool hadStuckEffect = (radMgef != None && akPlayer.HasMagicEffect(radMgef))
    if hadStuckEffect
        akPlayer.InterruptCast()
        if radLight != None
            akPlayer.DispelSpell(radLight)
            akPlayer.RemoveSpell(radLight)
        endif
        if radStrong != None
            akPlayer.DispelSpell(radStrong)
            akPlayer.RemoveSpell(radStrong)
        endif
    endif
    if !bStuckRadPurgedV1 || hadStuckEffect
        bStuckRadPurgedV1 = True
        ActorValue radsAV = Game.GetFormFromFile(0x000002E1, "Fallout4.esm") as ActorValue
        if radsAV != None && akPlayer.GetValue(radsAV) > 0.0
            Cell westTekCell = Game.GetFormFromFile(0x00002800, "Vault13Chronicles.esp") as Cell
            if hadStuckEffect || westTekCell == None || akPlayer.GetParentCell() != westTekCell
                akPlayer.RestoreValue(radsAV, akPlayer.GetValue(radsAV))
            endif
        endif
    endif
EndFunction

Function CheckWestTekRadiationLoop()
    Actor player = Game.GetPlayer()
    Cell westTekCell = Game.GetFormFromFile(0x00002800, "Vault13Chronicles.esp") as Cell
    if player == None || westTekCell == None || player.GetParentCell() != westTekCell
        bRadWarningShown = False
        CancelTimer(98)
        ClearStuckWestTekRadiation(player)
        return
    endif
    ClearStuckWestTekRadiation(player)
    if !bRadWarningShown
        bRadWarningShown = True
        Debug.Notification("[The Glow - West Tek] Gamma radiation alert! Equip a Hazmat Suit (entrance locker), take Rad-X, or repair the Auxiliary Generator.")
    endif
    Form hazmat = Game.GetFormFromFile(0x000CEAC4, "Fallout4.esm")
    bool fullyShielded = player.IsInPowerArmor() || (hazmat != None && player.IsEquipped(hazmat))
    if !fullyShielded && !player.IsDead() && !Utility.IsInMenuMode()
        ActorValue radsAV = Game.GetFormFromFile(0x000002E1, "Fallout4.esm") as ActorValue
        ActorValue radResAV = Game.GetFormFromFile(0x000002EA, "Fallout4.esm") as ActorValue
        if radsAV != None
            float baseRads = 15.0
            if bWestTekPowerRestored
                baseRads = 4.0
            endif
            float radRes = 0.0
            if radResAV != None
                radRes = player.GetValue(radResAV)
            endif
            float resMult = 1.0
            if radRes > 0.0
                resMult = 100.0 / (100.0 + radRes)
            endif
            if resMult < 0.05
                resMult = 0.05
            endif
            player.DamageValue(radsAV, baseRads * resMult)
        endif
    endif
    if bWestTekPowerRestored
        StartTimer(9.0, 98)
    else
        StartTimer(5.0, 98)
    endif
EndFunction

Function RepairWestTekGenerator()
    if bWestTekPowerRestored
        Debug.Notification("[West Tek - Auxiliary Power] The auxiliary reactor and anti-radiation scrubbers are operating at 100%.")
        return
    endif
    bWestTekPowerRestored = True
    PrepareWestTekFacilityState()
    Game.RewardPlayerXP(150, False)
    Debug.Notification("[West Tek] Auxiliary Generator repaired! Radiation scrubbers online and ZAX 1.2 supercomputer booted (+150 XP).")
EndFunction

Function DownloadMaxsonAndFEVLogs()
    Actor player = Game.GetPlayer()
    Form maxsonBook = Game.GetFormFromFile(0x00001520, "Vault13Chronicles.esp")
    Form fevBook = Game.GetFormFromFile(0x00001521, "Vault13Chronicles.esp")
    if player != None
        if maxsonBook != None && player.GetItemCount(maxsonBook) == 0
            player.AddItem(maxsonBook, 1, False)
        endif
        if fevBook != None && player.GetItemCount(fevBook) == 0
            player.AddItem(fevBook, 1, False)
        endif
    endif
    if !bFEVLogsDownloaded
        bFEVLogsDownloaded = True
        Game.RewardPlayerXP(100, False)
        Debug.Notification("[West Tek Archive] Original Project FEV logs and Capt. Roger Maxson's 2077 Diary downloaded (+100 XP).")
    else
        Debug.Notification("[West Tek Archive] Copies of the Project FEV and Roger Maxson files verified on your Pip-Boy.")
    endif
EndFunction

Function UnlockZAXHighSecurityVault(bool abViaChess)
    if bZAXVaultUnlocked
        Debug.Notification("[ZAX 1.2] The West Tek high-security vault is already unlocked.")
        return
    endif
    bZAXVaultUnlocked = True
    ObjectReference zaxSafe = Game.GetFormFromFile(0x00002835, "Vault13Chronicles.esp") as ObjectReference
    if zaxSafe != None
        if zaxSafe.IsDisabled()
            zaxSafe.EnableNoWait()
        endif
        if zaxSafe.IsLocked()
            zaxSafe.Lock(False, False)
        endif
        Form plasmaGun = Game.GetFormFromFile(0x00100AE9, "Fallout4.esm")
        Form plasmaAmmo = Game.GetFormFromFile(0x0001DBB7, "Fallout4.esm")
        Form fusionCell = Game.GetFormFromFile(0x000C1897, "Fallout4.esm")
        Form fCore = Game.GetFormFromFile(0x00075FE4, "Fallout4.esm")
        Form radaway = Game.GetFormFromFile(0x00023742, "Fallout4.esm")
        if plasmaGun != None && zaxSafe.GetItemCount(plasmaGun) == 0
            zaxSafe.AddItem(plasmaGun, 1, True)
        endif
        if plasmaAmmo != None && zaxSafe.GetItemCount(plasmaAmmo) == 0
            zaxSafe.AddItem(plasmaAmmo, 60, True)
        endif
        if fusionCell != None && zaxSafe.GetItemCount(fusionCell) == 0
            zaxSafe.AddItem(fusionCell, 60, True)
        endif
        if fCore != None && zaxSafe.GetItemCount(fCore) == 0
            zaxSafe.AddItem(fCore, 2, True)
        endif
        if radaway != None && zaxSafe.GetItemCount(radaway) == 0
            zaxSafe.AddItem(radaway, 4, True)
        endif
    endif
    Game.RewardPlayerXP(300, False)
    if abViaChess
        Debug.Notification("[ZAX 1.2] 'Impressive checkmate, human.' West Tek high-security vault unlocked! (+300 XP)")
    else
        Debug.Notification("[ZAX 1.2] West Tek emergency override accepted. High-security vault unlocked! (+300 XP)")
    endif
EndFunction

Function QueryZAXPhilosophy()
    zaxPendingAction = 1
    StartTimer(0.25, 93)
EndFunction

Function PlayChessWithZAX()
    zaxPendingAction = 2
    StartTimer(0.25, 93)
EndFunction

Function OverrideZAXSecurityVault()
    zaxPendingAction = 3
    StartTimer(0.25, 93)
EndFunction

Function ProcessZAXPendingAction(int aiAction)
    if !bWestTekPowerRestored
        Debug.MessageBox("ZAX 1.2 - MAIN POWER OFFLINE (Battery at 4%)\n\nZAX 1.2 remains in emergency hibernation. Repair the Auxiliary Generator in the northern lab (Auxiliary Generator Console) to converse with the AI, play chess, or unlock this Reinforced Footlocker.\n\nQuest reminder: the Brotherhood Holodisk you seek for Talus is on Sergeant Dennis Allen's body in the upper corridor.")
        return
    endif
    Actor player = Game.GetPlayer()
    ActorValue intAV = Game.GetFormFromFile(0x000002C6, "Fallout4.esm") as ActorValue
    Perk sciPerk = Game.GetFormFromFile(0x000264D9, "Fallout4.esm") as Perk
    Form keycardBase = Game.GetFormFromFile(0x00001512, "Vault13Chronicles.esp")
    bool hasInt = (player != None && intAV != None && player.GetValue(intAV) >= 7.0)
    bool hasSci = (player != None && sciPerk != None && player.HasPerk(sciPerk))
    bool hasKey = (player != None && keycardBase != None && player.GetItemCount(keycardBase) > 0)

    if aiAction == 1
        DownloadMaxsonAndFEVLogs()
        ForceAllGlowAliases()
        Scene zaxScene = Game.GetFormFromFile(0x00013101, "Vault13Chronicles.esp") as Scene
        if zaxScene != None && !zaxScene.IsPlaying()
            zaxScene.Start()
        endif
        Debug.Notification("[ZAX 1.2] 'Neural link active. Hear my report on Project FEV and the West Tek facility.'")
    elseif aiAction == 2
        if bZAXChessWon
            if !bZAXVaultUnlocked
                UnlockZAXHighSecurityVault(True)
            endif
            Debug.MessageBox("ZAX 1.2 - TACTICAL CHESS\n\n'You have already defeated me fairly at the board, human. The adjacent Reinforced Footlocker remains unlocked with its full experimental arsenal.'")
        elseif hasInt || hasSci
            bZAXChessWon = True
            UnlockZAXHighSecurityVault(True)
            Debug.MessageBox("ZAX 1.2 - CHECKMATE AGAINST THE SUPERCOMPUTER!\n\n'Brilliant moves, human. My heuristics concede defeat.' (+300 XP)\n\nZAX 1.2 has unlocked the adjacent Reinforced Footlocker (experimental Plasma Rifle, fusion cells, fusion cores, and RadAway).")
        else
            Debug.MessageBox("ZAX 1.2 - CHESS MATCH\n\nZAX 1.2: 'Checkmate in 34 moves.'\n\nTo defeat ZAX at chess you need Intelligence 7+ or the Science! perk (you can take Mentats from the Decontamination Locker), or open the footlocker directly via option [3] using the West Tek Security Passcard from Sergeant Dennis Allen's body.")
        endif
    elseif aiAction == 3
        if bZAXVaultUnlocked
            Debug.MessageBox("ZAX 1.2 - REINFORCED FOOTLOCKER\n\nThe high-security Reinforced Footlocker is already unlocked. Collect its experimental gear right beside the console.")
        elseif hasKey || hasSci || hasInt
            UnlockZAXHighSecurityVault(False)
            Debug.MessageBox("ZAX 1.2 - SECURITY OVERRIDE COMPLETE\n\nWest Tek credentials verified (+300 XP). The adjacent Reinforced Footlocker is now open with experimental plasma weaponry!")
        else
            Debug.MessageBox("ZAX 1.2 - OVERRIDE DENIED\n\nInsufficient authorization. Recover the West Tek Security Passcard from Sergeant Dennis Allen's body (upper corridor, next to the Brotherhood Holodisk) or raise Intelligence to 7+ / Science! perk.")
        endif
    endif
EndFunction

Function SetupGlowListeners(bool abRefreshLayout = True)
    if Self.IsCompleted() || Self.GetStage() >= 40 || Self.IsStageDone(40) || bRewardGranted
        bRewardGranted = True
        bItemDelivered = True
        bHoloRecovered = True
        bHoloSeeded = True
        Self.CompleteAllObjectives()
        if !Self.IsCompleted()
            Self.CompleteQuest()
        endif
    else
        if !Self.IsRunning()
            Self.Start()
        endif
        if Self.GetStage() < 10
            Self.SetStage(10)
        endif
    endif
    ForceAllGlowAliases()

    Actor player = Game.GetPlayer()
    Cell westTekCell = Game.GetFormFromFile(0x00002800, "Vault13Chronicles.esp") as Cell
    WorldSpace caliWorld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    bool inWestTek = (player != None && westTekCell != None && player.GetParentCell() == westTekCell)
    bool inCali = (player != None && caliWorld != None && player.GetWorldSpace() == caliWorld)
    if abRefreshLayout && (inWestTek || inCali)
        PrepareWestTekFacilityState()
        RefreshGlowSettlementLayout()
    else
        ObjectReference allenObj = Game.GetFormFromFile(0x00002810, "Vault13Chronicles.esp") as ObjectReference
        if allenObj != None
            RegisterForRemoteEvent(allenObj, "OnActivate")
            RegisterForRemoteEvent(allenObj, "OnItemRemoved")
        endif
        ObjectReference zaxPreRef = Game.GetFormFromFile(0x00002815, "Vault13Chronicles.esp") as ObjectReference
        if zaxPreRef != None
            RegisterForRemoteEvent(zaxPreRef, "OnActivate")
        endif
        ObjectReference zaxSafePreRef = Game.GetFormFromFile(0x00002835, "Vault13Chronicles.esp") as ObjectReference
        if zaxSafePreRef != None
            RegisterForRemoteEvent(zaxSafePreRef, "OnActivate")
        endif
    endif

    Form holoBase = Game.GetFormFromFile(0x00001454, "Vault13Chronicles.esp")
    Self.RemoveAllInventoryEventFilters()
    if holoBase != None
        Self.AddInventoryEventFilter(holoBase)
    endif
    if player != None
        RegisterForRemoteEvent(player, "OnPlayerLoadGame")
        RegisterForRemoteEvent(player, "OnLocationChange")
        if holoBase != None
            RegisterForRemoteEvent(player as ObjectReference, "OnItemAdded")
        endif
    endif

    ObjectReference cabbotRef = Game.GetFormFromFile(0x000035D0, "Vault13Chronicles.esp") as ObjectReference
    if cabbotRef != None
        RegisterForRemoteEvent(cabbotRef, "OnActivate")
    endif
    ObjectReference talusRef = Game.GetFormFromFile(0x000035D1, "Vault13Chronicles.esp") as ObjectReference
    if talusRef != None
        RegisterForRemoteEvent(talusRef, "OnActivate")
    endif
    Actor sentryRef = Game.GetFormFromFile(0x000035D2, "Vault13Chronicles.esp") as Actor
    if sentryRef != None
        RegisterForRemoteEvent(sentryRef, "OnDeath")
        RegisterForRemoteEvent(sentryRef as ObjectReference, "OnActivate")
        RegisterForRemoteEvent(sentryRef as ObjectReference, "OnItemRemoved")
        if abRefreshLayout && (inWestTek || inCali)
            V13WastelandCreatureAIScript sentryAI = (sentryRef as ObjectReference) as V13WastelandCreatureAIScript
            if sentryAI != None
                sentryAI.InitCreatureAI()
            endif
            if sentryRef.Is3DLoaded() && !sentryRef.IsDead()
                float sx = sentryRef.GetPositionX()
                float sy = sentryRef.GetPositionY()
                float sz = sentryRef.GetPositionZ()
                if (sz < 108.0 || sz > 230.0) && Self.GetStage() < 25 && !Self.IsStageDone(40) && !bRewardGranted
                    sentryRef.SetPosition(31180.0, -33680.0, 126.0)
                elseif !sentryRef.IsInCombat()
                    if Math.Abs(sx - 31180.0) > 450.0 || Math.Abs(sy + 33680.0) > 450.0
                        sentryRef.SetPosition(31180.0, -33680.0, 126.0)
                    endif
                endif
            endif
        endif
        if bHoloRecovered || bItemDelivered || bRewardGranted || Self.IsStageDone(40) || Self.GetStage() >= 25 || (player != None && holoBase != None && player.GetItemCount(holoBase) > 0)
            bHoloRecovered = True
            bHoloSeeded = True
            if holoBase != None && sentryRef.GetItemCount(holoBase) > 0
                sentryRef.RemoveItem(holoBase, sentryRef.GetItemCount(holoBase), True)
            endif
        endif
    endif

    if inWestTek
        StartTimer(1.5, 98)
    endif
EndFunction

Event OnInit()
    SetupGlowListeners(False)
    Actor player = Game.GetPlayer()
    Cell westTekCell = Game.GetFormFromFile(0x00002800, "Vault13Chronicles.esp") as Cell
    WorldSpace caliWorld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if player != None && ((westTekCell != None && player.GetParentCell() == westTekCell) || (caliWorld != None && player.GetWorldSpace() == caliWorld))
        StartTimer(2.5, 96)
    endif
EndEvent

Event OnQuestInit()
    SetupGlowListeners(False)
    Actor player = Game.GetPlayer()
    Cell westTekCell = Game.GetFormFromFile(0x00002800, "Vault13Chronicles.esp") as Cell
    WorldSpace caliWorld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if player != None && ((westTekCell != None && player.GetParentCell() == westTekCell) || (caliWorld != None && player.GetWorldSpace() == caliWorld))
        StartTimer(2.5, 96)
    endif
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
    SetupGlowListeners(False)
    Actor player = Game.GetPlayer()
    Cell westTekCell = Game.GetFormFromFile(0x00002800, "Vault13Chronicles.esp") as Cell
    WorldSpace caliWorld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if player != None && ((westTekCell != None && player.GetParentCell() == westTekCell) || (caliWorld != None && player.GetWorldSpace() == caliWorld))
        StartTimer(2.5, 96)
    endif
    StartTimer(3.5, 99)
EndEvent

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
    SetupGlowListeners()
    CheckWestTekRadiationLoop()
    StartTimer(1.0, 97)
    Actor player = Game.GetPlayer()
    Cell westTekCell = Game.GetFormFromFile(0x00002800, "Vault13Chronicles.esp") as Cell
    if player != None && westTekCell != None && player.GetParentCell() == westTekCell
        StartTimer(1.5, 96)
    endif
EndEvent

Function NotifyGlowHolodiskRecovered()
    if bHoloRecovered
        return
    endif
    bHoloRecovered = True
    bHoloSeeded = True
    Actor sentryRef = Game.GetFormFromFile(0x000035D2, "Vault13Chronicles.esp") as Actor
    Actor allenCorpse = Game.GetFormFromFile(0x00002810, "Vault13Chronicles.esp") as Actor
    Form holoBase = Game.GetFormFromFile(0x00001454, "Vault13Chronicles.esp")
    if sentryRef != None && holoBase != None && sentryRef.GetItemCount(holoBase) > 0
        sentryRef.RemoveItem(holoBase, sentryRef.GetItemCount(holoBase), True)
    endif
    if allenCorpse != None && holoBase != None && allenCorpse.GetItemCount(holoBase) > 0
        allenCorpse.RemoveItem(holoBase, allenCorpse.GetItemCount(holoBase), True)
    endif
    if Self.GetStage() < 25
        Self.SetStage(25)
    endif
    SetupGlowListeners()
EndFunction

Function UnlockLostHillsBunkerForInitiate()
    Quest q3 = Game.GetFormFromFile(0x00006002, "Vault13Chronicles.esp") as Quest
    V13Act3QuestScript act3S = q3 as V13Act3QuestScript
    if act3S != None
        act3S.NotifyLostHillsAdmitted()
    endif
    V13Act1QuestScript act1S = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as V13Act1QuestScript
    if act1S != None
        act1S.SyncVault13ExpeditionDoors()
    endif
EndFunction

Function DeliverHolodiskToTalus()
    if bItemDelivered
        return
    endif
    bItemDelivered = True
    Actor player = Game.GetPlayer()
    Form holoBase = Game.GetFormFromFile(0x00001454, "Vault13Chronicles.esp")
    if holoBase != None && player.GetItemCount(holoBase) > 0
        player.RemoveItem(holoBase, 1, True)
    endif
    Form noteBase = Game.GetFormFromFile(0x0000114D, "Vault13Chronicles.esp")
    if noteBase != None && player.GetItemCount(noteBase) == 0
        player.AddItem(noteBase, 1, True)
    endif
    Form radaway = Game.GetFormFromFile(0x00023742, "Fallout4.esm")
    if radaway != None
        player.AddItem(radaway, 3, False)
    endif
    UnlockLostHillsBunkerForInitiate()
    if Self.GetStage() < 30
        Self.SetStage(30)
    endif
EndFunction

Event ObjectReference.OnItemAdded(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    Form holoBase = Game.GetFormFromFile(0x00001454, "Vault13Chronicles.esp")
    if akBaseItem == holoBase
        NotifyGlowHolodiskRecovered()
    endif
EndEvent

Event ObjectReference.OnItemRemoved(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
    Form holoBase = Game.GetFormFromFile(0x00001454, "Vault13Chronicles.esp")
    if akBaseItem == holoBase && akDestContainer == (Game.GetPlayer() as ObjectReference)
        NotifyGlowHolodiskRecovered()
    endif
EndEvent

Event Actor.OnDeath(Actor akSender, Actor akKiller)
    Actor sentryRef = Game.GetFormFromFile(0x000035D2, "Vault13Chronicles.esp") as Actor
    if akSender == sentryRef
        ForceAllGlowAliases()
        if Self.GetStage() == 20 && !bHoloRecovered
            Debug.Notification("[The Glow] Sentry ZAX-WT01 destroyed! Descend the crater hatch into West Tek to find Sgt. Dennis Allen.")
        endif
    endif
EndEvent

Event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
    if akActionRef != Game.GetPlayer()
        return
    endif
    ObjectReference cabbotRef = Game.GetFormFromFile(0x000035D0, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference talusRef = Game.GetFormFromFile(0x000035D1, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference sentryObjRef = Game.GetFormFromFile(0x000035D2, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference allenObjRef = Game.GetFormFromFile(0x00002810, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference zaxObjRef = Game.GetFormFromFile(0x00002815, "Vault13Chronicles.esp") as ObjectReference
    Form holoBase = Game.GetFormFromFile(0x00001454, "Vault13Chronicles.esp")
    Form keycardBase = Game.GetFormFromFile(0x00001512, "Vault13Chronicles.esp")
    Actor player = Game.GetPlayer()

    if akSender == allenObjRef
        Actor allenAct = allenObjRef as Actor
        if holoBase != None && player != None && player.GetItemCount(holoBase) == 0 && !bItemDelivered
            if allenAct != None && allenAct.GetItemCount(holoBase) > 0
                allenAct.RemoveItem(holoBase, allenAct.GetItemCount(holoBase), True)
            endif
            player.AddItem(holoBase, 1, False)
        endif
        if keycardBase != None && player != None && player.GetItemCount(keycardBase) == 0
            if allenAct != None && allenAct.GetItemCount(keycardBase) > 0
                allenAct.RemoveItem(keycardBase, allenAct.GetItemCount(keycardBase), True)
            endif
            player.AddItem(keycardBase, 1, False)
        endif
        NotifyGlowHolodiskRecovered()
        return
    endif

    if akSender == zaxObjRef
        if !bWestTekPowerRestored
            Debug.Notification("[ZAX 1.2 Supercomputer] 'Battery at 4%. Repair the Auxiliary Generator in the north wing to talk or play chess (Sgt. Allen's Holodisk is in the upper corridor).'")
            return
        endif
        ForceAllGlowAliases()
        zaxWaitTicks = 0
        StartTimer(1.2, 92)
        return
    endif

    ObjectReference zaxSafeAct = Game.GetFormFromFile(0x00002835, "Vault13Chronicles.esp") as ObjectReference
    if zaxSafeAct != None && akSender == zaxSafeAct && zaxSafeAct.IsLocked()
        if !bWestTekPowerRestored
            Debug.Notification("[West Tek Footlocker] Locked by security. First restore the northern lab's Auxiliary Generator and operate the ZAX 1.2 Console.")
        else
            Debug.Notification("[West Tek Footlocker] Use the adjacent ZAX 1.2 Master Console (win at chess or override the lock with Sgt. Allen's Passcard / Science!).")
        endif
        return
    endif

    if akSender == sentryObjRef
        Debug.Notification("[Sentinel ZAX-WT01] 'West Tek Quarantine Protocol. Restricted access to the underground core (crater hatch); retrieve Sergeant Dennis Allen's Holotape.'")
        if Self.GetStage() < 20 && !Self.IsCompleted() && !Self.IsStageDone(40) && !bRewardGranted
            Self.SetStage(20)
        endif
        ForceAllGlowAliases()
        if !Self.IsCompleted() && !Self.IsStageDone(40) && !bRewardGranted
            Self.SetActive(True)
        endif
        return
    endif

    int curStage = Self.GetStage()
    if Self.IsCompleted() || Self.IsStageDone(40) || bRewardGranted
        bRewardGranted = True
        curStage = 40
    endif
    bool playerHasHolo = (holoBase != None && player != None && player.GetItemCount(holoBase) > 0)
    if (akSender == talusRef || akSender == cabbotRef) && (curStage == 22 || curStage == 25 || (playerHasHolo && curStage < 40))
        NotifyGlowHolodiskRecovered()
        DeliverHolodiskToTalus()
        if akSender == cabbotRef || Self.GetStage() >= 30
            UnlockLostHillsBunkerForInitiate()
            if Self.GetStage() < 40
                Self.SetStage(40)
            endif
        endif
        ForceAllGlowAliases()
        SilenceGlowActorsExcept(akSender as Actor)
        RefreshGlowSettlementLayout()
        return
    endif

    ForceAllGlowAliases()
    RefreshGlowSettlementLayout()
    SilenceGlowActorsExcept(akSender as Actor)
    if akSender == cabbotRef && (curStage == 30 || (bItemDelivered && curStage < 40))
        UnlockLostHillsBunkerForInitiate()
        if Self.GetStage() < 40
            Self.SetStage(40)
        endif
    elseif akSender == cabbotRef && curStage < 25
        sceneWaitTicks = 0
        StartTimer(1.2, 91)
        StartTimer(2.0, 94)
    elseif akSender == talusRef && curStage < 20
        StartTimer(2.0, 94)
    endif
EndEvent

Function QueueJumpToGlow()
    if bMenuJumpBusy
        return
    endif
    bMenuJumpBusy = True
    SetupGlowListeners()
    StartTimer(0.6, 95)
EndFunction

Event OnTimer(int aiTimerID)
    if aiTimerID == 91
        Scene introScene = Game.GetFormFromFile(0x00013100, "Vault13Chronicles.esp") as Scene
        Actor cabbotActor = Game.GetFormFromFile(0x000035D0, "Vault13Chronicles.esp") as Actor
        if Self.IsRunning() && introScene != None && Self.GetStage() < 25
            if !introScene.IsPlaying() && !Utility.IsInMenuMode() && (cabbotActor == None || (!cabbotActor.IsInDialogueWithPlayer() && !cabbotActor.IsTalking()))
                ForceAllGlowAliases()
                SilenceGlowActorsExcept(cabbotActor)
                if Self.IsRunning()
                    introScene.Start()
                endif
            endif
        endif
    elseif aiTimerID == 92
        Scene zaxScene = Game.GetFormFromFile(0x00013101, "Vault13Chronicles.esp") as Scene
        Actor zaxActor = Game.GetFormFromFile(0x00002815, "Vault13Chronicles.esp") as Actor
        if Self.IsRunning() && zaxScene != None
            if !zaxScene.IsPlaying() && !Utility.IsInMenuMode() && (zaxActor == None || (!zaxActor.IsInDialogueWithPlayer() && !zaxActor.IsTalking()))
                ForceAllGlowAliases()
                zaxScene.Start()
            endif
        endif
    elseif aiTimerID == 93
        if zaxPendingAction <= 0
            return
        endif
        if Utility.IsInMenuMode()
            StartTimer(0.25, 93)
            return
        endif
        int zAct = zaxPendingAction
        zaxPendingAction = 0
        ProcessZAXPendingAction(zAct)
    elseif aiTimerID == 94
        if Self.GetStage() < 20
            Self.SetStage(20)
        endif
    elseif aiTimerID == 95
        bMenuJumpBusy = False
        Actor player = Game.GetPlayer()
        Form v13Suit = Game.GetFormFromFile(0x00001307, "Vault13Chronicles.esp")
        if v13Suit != None && player.GetItemCount(v13Suit) == 0
            player.AddItem(v13Suit, 1, True)
        endif
        Form colt6520 = Game.GetFormFromFile(0x00001102, "Vault13Chronicles.esp")
        if colt6520 != None && player.GetItemCount(colt6520) == 0
            player.AddItem(colt6520, 1, False)
        endif
        Form ammo10 = Game.GetFormFromFile(0x0001F276, "Fallout4.esm")
        if ammo10 != None && player.GetItemCount(ammo10) < 80
            player.AddItem(ammo10, 80, True)
        endif
        Form stimpak = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
        if stimpak != None && player.GetItemCount(stimpak) < 6
            player.AddItem(stimpak, 6, True)
        endif
        ObjectReference lhMarker = Game.GetFormFromFile(0x00003418, "Vault13Chronicles.esp") as ObjectReference
        if lhMarker != None
            lhMarker.EnableNoWait()
            lhMarker.AddToMap(True)
        endif
        ObjectReference mapMarker = Game.GetFormFromFile(0x0000341F, "Vault13Chronicles.esp") as ObjectReference
        if mapMarker != None
            mapMarker.EnableNoWait()
            mapMarker.AddToMap(True)
        endif
        ObjectReference ftMarker = Game.GetFormFromFile(0x0000351F, "Vault13Chronicles.esp") as ObjectReference
        if ftMarker != None
            player.MoveTo(ftMarker)
            RefreshGlowSettlementLayout()
            StartTimer(1.0, 97)
            Debug.Notification("Traveled to the Lost Hills Surface Outpost (2161). Speak with Cabbot or Paladin Talus regarding the Trial of The Glow.")
        endif
    elseif aiTimerID == 96
        SetupGlowListeners(True)
    elseif aiTimerID == 97
        RefreshGlowSettlementLayout()
    elseif aiTimerID == 98
        CheckWestTekRadiationLoop()
    elseif aiTimerID == 99
        ClearStuckWestTekRadiation(Game.GetPlayer())
    endif
EndEvent

Event OnStageSet(int auiStageID, int auiItemID)
    bool doStg20 = False
    bool doStg22 = False
    bool doStg25 = False
    bool doStg30 = False
    bool doReward40 = False
    if auiStageID == 20
        if !bStg20Notified
            bStg20Notified = True
            doStg20 = True
        endif
    elseif auiStageID == 22
        if !bStg22Notified
            bStg22Notified = True
            doStg22 = True
        endif
    elseif auiStageID == 25
        if !bStg25Notified
            bStg25Notified = True
            doStg25 = True
        endif
    elseif auiStageID == 30
        if !bStg30Notified
            bStg30Notified = True
            doStg30 = True
        endif
    elseif auiStageID == 40
        if !bRewardGranted
            bRewardGranted = True
            doReward40 = True
        endif
    endif

    SetupGlowListeners()
    Actor player = Game.GetPlayer()
    Form holoBase = Game.GetFormFromFile(0x00001454, "Vault13Chronicles.esp")

    if auiStageID == 11
        if Self.GetStage() < 20 && !Self.IsCompleted()
            ForceAllGlowAliases()
            if !IsObjectiveDisplayed(11)
                SetObjectiveDisplayed(11, True, False)
            endif
            Self.SetActive(True)
        endif
    elseif auiStageID == 20
        if IsObjectiveDisplayed(11)
            SetObjectiveCompleted(11, True)
            SetObjectiveDisplayed(11, False, False)
        endif
        ObjectReference mapMarker = Game.GetFormFromFile(0x0000341F, "Vault13Chronicles.esp") as ObjectReference
        if mapMarker != None
            mapMarker.EnableNoWait()
            if !mapMarker.IsMapMarkerVisible()
                mapMarker.AddToMap(False)
            endif
        endif
        if holoBase != None && player.GetItemCount(holoBase) > 0
            Self.SetStage(25)
            return
        endif
        ForceAllGlowAliases()
        if !IsObjectiveDisplayed(20)
            SetObjectiveDisplayed(20, True, False)
        endif
        Self.SetActive(True)
        if doStg20
            Debug.Notification("Side Quest: The Glow (West Tek) - Descend into the West Tek bunker and recover Sgt. Dennis Allen's Holodisk.")
        endif
    elseif auiStageID == 22
        if IsObjectiveDisplayed(11)
            SetObjectiveCompleted(11, True)
            SetObjectiveDisplayed(11, False, False)
        endif
        if holoBase != None && player.GetItemCount(holoBase) > 0
            Self.SetStage(25)
            return
        endif
        ForceAllGlowAliases()
        SetObjectiveCompleted(20, True)
        if !IsObjectiveDisplayed(22)
            SetObjectiveDisplayed(22, True, False)
        endif
        Self.SetActive(True)
        if doStg22
            Debug.Notification("Descend into the West Tek underground facility and recover Sgt. Dennis Allen's Holodisk.")
        endif
    elseif auiStageID == 25
        SetObjectiveCompleted(20, True)
        if IsObjectiveDisplayed(22)
            SetObjectiveCompleted(22, True)
        endif
        if !IsObjectiveDisplayed(25)
            SetObjectiveDisplayed(25, True, False)
        endif
        Self.SetActive(True)
        if doStg25
            Debug.Notification("Sgt. Allen's Holodisk recovered at West Tek. Deliver it to Paladin Talus at the Lost Hills entrance.")
        endif
    elseif auiStageID == 30
        if !bItemDelivered
            DeliverHolodiskToTalus()
        endif
        UnlockLostHillsBunkerForInitiate()
        SetObjectiveCompleted(20, True)
        if IsObjectiveDisplayed(22)
            SetObjectiveCompleted(22, True)
        endif
        SetObjectiveCompleted(25, True)
        if !IsObjectiveDisplayed(30)
            SetObjectiveDisplayed(30, True, False)
        endif
        Self.SetActive(True)
        if doStg30
            Debug.Notification("Paladin Talus authenticated the holodisk! The Lost Hills bunker is open. Speak with Cabbot for your reward.")
        endif
    elseif auiStageID == 40
        UnlockLostHillsBunkerForInitiate()
        SetObjectiveCompleted(20, True)
        if IsObjectiveDisplayed(22)
            SetObjectiveCompleted(22, True)
        endif
        SetObjectiveCompleted(25, True)
        SetObjectiveCompleted(30, True)
        if doReward40
            Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
            Form wattz2000 = Game.GetFormFromFile(0x00001108, "Vault13Chronicles.esp")
            Form cells = Game.GetFormFromFile(0x000C1897, "Fallout4.esm")
            Form radx = Game.GetFormFromFile(0x00024057, "Fallout4.esm")
            if caps != None
                player.AddItem(caps, 700, False)
            endif
            if wattz2000 != None && player.GetItemCount(wattz2000) == 0
                player.AddItem(wattz2000, 1, False)
            endif
            if cells != None
                player.AddItem(cells, 45, False)
            endif
            if radx != None
                player.AddItem(radx, 4, False)
            endif
            Game.RewardPlayerXP(450)
            Debug.Notification("Quest Completed: Trial of The Glow! Full access to Lost Hills bunker, Wattz 2000 Laser Rifle, +700 Caps, and +450 XP.")
        endif
        Self.CompleteAllObjectives()
        Self.CompleteQuest()
    endif
EndEvent
