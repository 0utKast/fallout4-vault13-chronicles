Scriptname V13Act2QuestScript extends Quest

int hitCounter = 0
bool introShown = false
bool rewardsGiven = false
bool necroCellRefreshed = false
bool intercomResolved = false
bool harryEvacuated = false
bool necroPumpRepaired = false
bool undergroundRewardGiven = false
bool setContractRewarded = false
bool waterChipInstalledInPlant = false
bool waterPlantWalkActive = false
int waterPlantWalkStep = 0
bool waterPlantStateApplied = false
bool lastWaterPlantRepaired = false
bool sewerPasswordFound = false
bool v13CrisisResolved = false
bool v13CrisisBanterShown = false
bool v13CrisisRewardGiven = false
int savedNecroStageBeforeCrisis = 0
bool garretIntroDone = false
bool garretIntroSceneStarted = false
bool garretArmoryUnlockedNotified = false
bool ezequielGreeted = false
bool harryCombatStarted = false
bool harryDialogueMenuOpen = false
bool harryGreetedInRoom = false
bool harryEvacPending = false
bool harryEvacWalkStarted = false
int harryEvacTicks = 0
bool harryCombatPending = false
int harryCombatWaitTicks = 0
bool harrySceneStarted = false
int harrySceneOutcome = 0
bool part1EndShown = false
bool part1EndCardShownV2 = false
bool jacorenFinaleTriggered = false
bool waterPlantMarkerOnConsole = false
bool cheerLylePlayed = false
bool cheerCindyPlayed = false
bool cheerTheresaPlayed = false
bool cheerTechPlayed = false
bool cheerJacorenArrivedPlayed = false
int cheerCooldownTicks = 0
ObjectReference spawnedHarryIntercom = None
ObjectReference spawnedHarryWallIntercom = None
bool harryPatrolRefreshedV4 = false
bool waterChipExtracted = false
bool pumpPartsRecovered = false
bool pumpStateInitialized = false
bool lastPumpStateRepaired = false
int pendingCheckpointJump = 0
bool isExecutingCheckpointJump = false
int lastCheckpointJumpID = 0
int checkpointJumpRetries = 0
bool waterPlantInstallQueued = false
bool waterPlantConsoleOpenedWithChip = false
int celebrationStep = 0
bool watershedPrisonerGreeted = false
bool watershedPrisonerFreed = false
bool necroWaterDilemmaRewarded = false
bool bApplyingAct2Stage = false
int lastAppliedAct2Stage = 0
bool bAct2RewardLock = false
bool bSewerChamberUnlocked = false
bool pumpPartsNotified = false
bool chipExtractedNotified = false
bool bResolvingHarry = false
bool bShowingPart1End = false
bool bPumpPromptQueued = false
bool bPumpMissingPartsHold = false
bool bWaterPlantPromptBusy = false

Function SanitizeLegacyQuestStage(int aiTargetStage)
    if !Self.IsRunning()
        Self.Start()
    endif
    RegisterPlayerEvents()
    if aiTargetStage > 0 && Self.GetStage() < aiTargetStage
        Self.SetStage(aiTargetStage)
    endif
EndFunction

Function HealNecropolisStateFromCellAndInventory()
    if isExecutingCheckpointJump || lastCheckpointJumpID > 0 || pendingCheckpointJump > 0
        return
    endif
    Actor player = Game.GetPlayer()
    if player == None
        return
    endif
    Quest act1Quest = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as Quest
    if act1Quest != None && act1Quest.GetStage() > 0 && act1Quest.GetStage() < 40
        introShown = false
        v13CrisisResolved = false
        v13CrisisRewardGiven = false
        garretIntroDone = false
        garretArmoryUnlockedNotified = false
        sewerPasswordFound = false
        bSewerChamberUnlocked = false
        ezequielGreeted = false
        pumpPartsRecovered = false
        pumpPartsNotified = false
        necroPumpRepaired = false
        pumpStateInitialized = false
        intercomResolved = false
        harryEvacuated = false
        harryEvacWalkStarted = false
        harryEvacPending = false
        harryCombatStarted = false
        harryCombatPending = false
        harrySceneOutcome = 0
        waterChipExtracted = false
        chipExtractedNotified = false
        waterPlantWalkActive = false
        waterChipInstalledInPlant = false
        rewardsGiven = false
        part1EndShown = false
        lastAppliedAct2Stage = 0
        return
    endif
    Form waterChip = Game.GetFormFromFile(0x00001112, "Vault13Chronicles.esp")
    if waterChip != None && player.GetItemCount(waterChip) > 0 && !waterChipInstalledInPlant
        waterChipExtracted = true
        intercomResolved = true
    endif
    Form pumpParts = Game.GetFormFromFile(0x0000111D, "Vault13Chronicles.esp")
    if pumpParts != None && player.GetItemCount(pumpParts) > 0
        pumpPartsRecovered = true
    endif
    Cell pCell = player.GetParentCell()
    if pCell == None
        return
    endif
    Cell necroCell = Game.GetFormFromFile(0x00002A00, "Vault13Chronicles.esp") as Cell
    Cell hallCell = Game.GetFormFromFile(0x00002E00, "Vault13Chronicles.esp") as Cell
    Cell sewerCell = Game.GetFormFromFile(0x00002F00, "Vault13Chronicles.esp") as Cell
    Cell watershedCell = Game.GetFormFromFile(0x00002900, "Vault13Chronicles.esp") as Cell
    bool inAnyNecroCell = (pCell == necroCell || pCell == hallCell || pCell == sewerCell || pCell == watershedCell)
    if inAnyNecroCell
        waterChipInstalledInPlant = false
        rewardsGiven = false
        part1EndShown = false
        waterPlantWalkActive = false
    endif
EndFunction

Function EnsureSingleActiveObjective(int aiActiveObjID)
    int[] objIDs = new int[14]
    objIDs[0] = 15
    objIDs[1] = 18
    objIDs[2] = 20
    objIDs[3] = 21
    objIDs[4] = 22
    objIDs[5] = 23
    objIDs[6] = 24
    objIDs[7] = 25
    objIDs[8] = 26
    objIDs[9] = 27
    objIDs[10] = 28
    objIDs[11] = 30
    objIDs[12] = 35
    objIDs[13] = 38
    int idx = 0
    while idx < 14
        int oid = objIDs[idx]
        if oid != aiActiveObjID
            if oid < aiActiveObjID && !(oid == 27 && aiActiveObjID == 28)
                if Self.IsObjectiveDisplayed(oid) && !Self.IsObjectiveCompleted(oid)
                    Self.SetObjectiveCompleted(oid, true)
                endif
                if Self.IsObjectiveDisplayed(oid)
                    Self.SetObjectiveDisplayed(oid, false, false)
                endif
            else
                if Self.IsObjectiveDisplayed(oid)
                    Self.SetObjectiveDisplayed(oid, false, false)
                endif
            endif
        endif
        idx += 1
    endwhile
    if aiActiveObjID > 0
        if Self.IsObjectiveCompleted(aiActiveObjID)
            Self.SetObjectiveCompleted(aiActiveObjID, false)
        endif
        if !Self.IsObjectiveDisplayed(aiActiveObjID)
            Self.SetObjectiveDisplayed(aiActiveObjID, true, false)
        endif
        Self.SetActive(true)
    endif
EndFunction

int Function GetEffectiveAct2Stage()
    if rewardsGiven && waterChipInstalledInPlant
        return 40
    endif
    if waterChipInstalledInPlant
        return 38
    endif
    if waterPlantWalkActive
        return 35
    endif
    Actor player = Game.GetPlayer()
    Form waterChip = Game.GetFormFromFile(0x00001112, "Vault13Chronicles.esp")
    if waterChipExtracted || (player != None && waterChip != None && player.GetItemCount(waterChip) > 0)
        if Self.IsObjectiveDisplayed(35) && !Self.IsObjectiveCompleted(35)
            return 35
        endif
        return 30
    endif
    Cell watershedCell = Game.GetFormFromFile(0x00002900, "Vault13Chronicles.esp") as Cell
    if necroPumpRepaired || (player != None && watershedCell != None && player.GetParentCell() == watershedCell)
        if IsHarryResolved() || harrySceneOutcome == 1
            return 27
        endif
        if harryCombatStarted || harryCombatPending || harrySceneOutcome == 2
            return 28
        endif
        return 26
    endif
    Form pumpParts = Game.GetFormFromFile(0x0000111D, "Vault13Chronicles.esp")
    if pumpPartsRecovered || (player != None && pumpParts != None && player.GetItemCount(pumpParts) > 0)
        return 25
    endif
    Cell sewerCell = Game.GetFormFromFile(0x00002F00, "Vault13Chronicles.esp") as Cell
    if garretArmoryUnlockedNotified || sewerPasswordFound || ezequielGreeted || (player != None && sewerCell != None && player.GetParentCell() == sewerCell)
        return 24
    endif
    int stg = Self.GetStage()
    if stg >= 15 && stg <= 24
        return stg
    endif
    if garretIntroDone || Self.GetStageDone(22)
        return 22
    endif
    if Self.GetStageDone(21)
        return 21
    endif
    if Self.GetStageDone(20) || v13CrisisResolved
        return 20
    endif
    if Self.GetStageDone(18)
        return 18
    endif
    if Self.GetStageDone(15) || introShown
        return 15
    endif
    return 0
EndFunction

Function GiveV13CrisisResolutionReward()
    if v13CrisisRewardGiven
        return
    endif
    v13CrisisRewardGiven = true
    v13CrisisResolved = true
    Actor player = Game.GetPlayer()
    Form pureWater = Game.GetFormFromFile(0x000366C0, "Fallout4.esm")
    Form stimpak = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
    Form crisisBook = Game.GetFormFromFile(0x00001149, "Vault13Chronicles.esp")
    if player != None
        if pureWater != None
            player.AddItem(pureWater, 3, false)
        endif
        if stimpak != None
            player.AddItem(stimpak, 2, false)
        endif
        if crisisBook != None && player.GetItemCount(crisisBook) == 0
            player.AddItem(crisisBook, 1, true)
        endif
    endif
    Game.RewardPlayerXP(200, false)
    Debug.Notification("[Refugio 13] ¡Rebelión de Theresa calmada y crisis de agua de Cindy resuelta! Esclusa a Necrópolis desbloqueada (+200 PE).")
EndFunction

Function SyncVault13CrisisAndCelebrationActors()
    Actor player = Game.GetPlayer()
    Cell v13Cell = Game.GetFormFromFile(0x00002100, "Vault13Chronicles.esp") as Cell
    Actor lyle = Game.GetFormFromFile(0x00002150, "Vault13Chronicles.esp") as Actor
    Actor cindy = Game.GetFormFromFile(0x00002152, "Vault13Chronicles.esp") as Actor
    Actor theresa = Game.GetFormFromFile(0x00002153, "Vault13Chronicles.esp") as Actor
    ObjectReference waterCrate = Game.GetFormFromFile(0x00002185, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference crisisLight = Game.GetFormFromFile(0x00002186, "Vault13Chronicles.esp") as ObjectReference
    Scene theresaScene = Game.GetFormFromFile(0x00005104, "Vault13Chronicles.esp") as Scene
    Quest q3 = Game.GetFormFromFile(0x00006000, "Vault13Chronicles.esp") as Quest
    bool act3Active = (q3 != None && q3.GetStage() >= 20)
    int curStage = GetEffectiveAct2Stage()

    if curStage < 15
        return
    endif

    if waterCrate != None && waterCrate.IsDisabled()
        waterCrate.EnableNoWait()
    endif
    if crisisLight != None && crisisLight.IsDisabled()
        crisisLight.EnableNoWait()
    endif

    if lyle != None
        if lyle.IsDead()
            lyle.Resurrect()
        endif
        if lyle.IsDisabled()
            lyle.Enable(false)
        endif
    endif
    if cindy != None
        if cindy.IsDead()
            cindy.Resurrect()
        endif
        if cindy.IsDisabled()
            cindy.Enable(false)
        endif
    endif
    if theresa != None
        if theresa.IsDead()
            theresa.Resurrect()
        endif
        if theresa.IsDisabled()
            theresa.Enable(false)
        endif
    endif

    if (theresaScene != None && theresaScene.IsPlaying()) || (theresa != None && (theresa.IsInDialogueWithPlayer() || theresa.IsTalking())) || (lyle != None && (lyle.IsInDialogueWithPlayer() || lyle.IsTalking())) || (cindy != None && (cindy.IsInDialogueWithPlayer() || cindy.IsTalking()))
        return
    endif

    if curStage >= 30 && !act3Active
        Actor calvin = Game.GetFormFromFile(0x00002151, "Vault13Chronicles.esp") as Actor
        Actor medOfficer = Game.GetFormFromFile(0x00002154, "Vault13Chronicles.esp") as Actor
        Actor atriumMale = Game.GetFormFromFile(0x00002156, "Vault13Chronicles.esp") as Actor
        Actor atriumFem = Game.GetFormFromFile(0x00002157, "Vault13Chronicles.esp") as Actor
        if atriumFem != None
            if atriumFem.IsDead()
                atriumFem.Resurrect()
            endif
            if atriumFem.IsDisabled()
                atriumFem.Enable(false)
            endif
        endif
        if atriumMale != None
            if atriumMale.IsDead()
                atriumMale.Resurrect()
            endif
            if atriumMale.IsDisabled()
                atriumMale.Enable(false)
            endif
        endif
        if medOfficer != None
            if medOfficer.IsDead()
                medOfficer.Resurrect()
            endif
            if medOfficer.IsDisabled()
                medOfficer.Enable(false)
            endif
        endif
        if calvin != None
            if calvin.IsDead()
                calvin.Resurrect()
            endif
            if calvin.IsDisabled()
                calvin.Enable(false)
            endif
            float cvdx3 = calvin.GetPositionX() - (-1445.0)
            float cvdy3 = calvin.GetPositionY() - (-4645.0)
            if (cvdx3 * cvdx3 + cvdy3 * cvdy3) > 250000.0 || calvin.GetPositionZ() > -420.0
                calvin.SetPosition(-1445.0, -4645.0, -528.0)
                calvin.SetAngle(0.0, 0.0, 218.0)
            endif
        endif
        if curStage >= 38 || waterChipInstalledInPlant
            ; Celebration gathering around the Water Plant turbines once the Water Chip is installed:
            if lyle != None
                float ldx4 = lyle.GetPositionX() - (-1390.0)
                float ldy4 = lyle.GetPositionY() - (-4540.0)
                if (ldx4 * ldx4 + ldy4 * ldy4) > 250000.0 || lyle.GetPositionZ() > -420.0
                    lyle.SetPosition(-1390.0, -4540.0, -528.0)
                    lyle.SetAngle(0.0, 0.0, 215.0)
                endif
            endif
            if cindy != None
                float cdx4 = cindy.GetPositionX() - (-1510.0)
                float cdy4 = cindy.GetPositionY() - (-4490.0)
                if (cdx4 * cdx4 + cdy4 * cdy4) > 250000.0 || cindy.GetPositionZ() > -420.0
                    cindy.SetPosition(-1510.0, -4490.0, -528.0)
                    cindy.SetAngle(0.0, 0.0, 190.0)
                endif
            endif
            if theresa != None
                float tdx4 = theresa.GetPositionX() - (-1640.0)
                float tdy4 = theresa.GetPositionY() - (-4490.0)
                if (tdx4 * tdx4 + tdy4 * tdy4) > 250000.0 || theresa.GetPositionZ() > -420.0
                    theresa.SetPosition(-1640.0, -4490.0, -528.0)
                    theresa.SetAngle(0.0, 0.0, 165.0)
                endif
            endif
            if atriumFem != None
                float afdx4 = atriumFem.GetPositionX() - (-1760.0)
                float afdy4 = atriumFem.GetPositionY() - (-4530.0)
                if (afdx4 * afdx4 + afdy4 * afdy4) > 250000.0 || atriumFem.GetPositionZ() > -420.0
                    atriumFem.SetPosition(-1760.0, -4530.0, -528.0)
                    atriumFem.SetAngle(0.0, 0.0, 145.0)
                endif
            endif
            if atriumMale != None
                float amdx4 = atriumMale.GetPositionX() - (-1820.0)
                float amdy4 = atriumMale.GetPositionY() - (-4620.0)
                if (amdx4 * amdx4 + amdy4 * amdy4) > 250000.0 || atriumMale.GetPositionZ() > -420.0
                    atriumMale.SetPosition(-1820.0, -4620.0, -528.0)
                    atriumMale.SetAngle(0.0, 0.0, 125.0)
                endif
            endif
        else
            ; Pre-installation positions (Stage 30..35): keep Lyle, Cindy, and Theresa in the storage atrium area
            ; so they do not block the Overseer's stairs or prematurely celebrate before the Water Chip is installed:
            if theresa != None
                float tdx3 = theresa.GetPositionX() - (-1745.0)
                float tdy3 = theresa.GetPositionY() - (-3865.0)
                if (tdx3 * tdx3 + tdy3 * tdy3) > 250000.0 || theresa.GetPositionZ() < -350.0
                    theresa.SetPosition(-1745.0, -3865.0, -272.0)
                    theresa.SetAngle(0.0, 0.0, 180.0)
                endif
            endif
            if cindy != None
                float cdx3 = cindy.GetPositionX() - (-1635.0)
                float cdy3 = cindy.GetPositionY() - (-3865.0)
                if (cdx3 * cdx3 + cdy3 * cdy3) > 250000.0 || cindy.GetPositionZ() < -350.0
                    cindy.SetPosition(-1635.0, -3865.0, -272.0)
                    cindy.SetAngle(0.0, 0.0, 180.0)
                endif
            endif
            if lyle != None
                float ldx3 = lyle.GetPositionX() - (-1585.0)
                float ldy3 = lyle.GetPositionY() - (-3915.0)
                if (ldx3 * ldx3 + ldy3 * ldy3) > 250000.0 || lyle.GetPositionZ() < -350.0
                    lyle.SetPosition(-1585.0, -3915.0, -272.0)
                    lyle.SetAngle(0.0, 0.0, 210.0)
                endif
            endif
            if atriumFem != None
                float afdx3 = atriumFem.GetPositionX() - (-1920.0)
                float afdy3 = atriumFem.GetPositionY() - (-4520.0)
                if (afdx3 * afdx3 + afdy3 * afdy3) > 250000.0 || atriumFem.GetPositionZ() > -420.0
                    atriumFem.SetPosition(-1920.0, -4520.0, -528.0)
                    atriumFem.SetAngle(0.0, 0.0, 0.0)
                endif
            endif
            if atriumMale != None
                float amdx3 = atriumMale.GetPositionX() - (-2153.8)
                float amdy3 = atriumMale.GetPositionY() - (-4696.1)
                if (amdx3 * amdx3 + amdy3 * amdy3) > 250000.0 || atriumMale.GetPositionZ() > -420.0
                    atriumMale.SetPosition(-2153.8, -4696.1, -527.3)
                    atriumMale.SetAngle(0.0, 0.0, 0.0)
                endif
            endif
        endif
    else
        if theresa != None
            float tdx2 = theresa.GetPositionX() - (-1745.0)
            float tdy2 = theresa.GetPositionY() - (-3865.0)
            if (tdx2 * tdx2 + tdy2 * tdy2) > 250000.0 || theresa.GetPositionZ() < -350.0
                theresa.SetPosition(-1745.0, -3865.0, -272.0)
                theresa.SetAngle(0.0, 0.0, 180.0)
            endif
        endif
        if cindy != None
            float cdx2 = cindy.GetPositionX() - (-1635.0)
            float cdy2 = cindy.GetPositionY() - (-3865.0)
            if (cdx2 * cdx2 + cdy2 * cdy2) > 250000.0 || cindy.GetPositionZ() < -350.0
                cindy.SetPosition(-1635.0, -3865.0, -272.0)
                cindy.SetAngle(0.0, 0.0, 180.0)
            endif
        endif
        if lyle != None
            float ldx2 = lyle.GetPositionX() - (-1585.0)
            float ldy2 = lyle.GetPositionY() - (-3915.0)
            if (ldx2 * ldx2 + ldy2 * ldy2) > 250000.0 || lyle.GetPositionZ() < -350.0
                lyle.SetPosition(-1585.0, -3915.0, -272.0)
                lyle.SetAngle(0.0, 0.0, 210.0)
            endif
        endif
        if curStage >= 15 && curStage < 20 && player != None && v13Cell != None && player.GetParentCell() == v13Cell && theresa != None
            if !v13CrisisBanterShown && player.GetDistance(theresa) < 620.0
                v13CrisisBanterShown = true
                Debug.Notification("[Theresa]: '¡Abrid la puerta del Refugio 13! ¡El Refugio 15 está en ruinas y no vamos a esperar aquí a morir de sed!'")
                Debug.Notification("[Oficial Lyle]: '¡Atrás, Theresa! ¡Y tú, Cindy, suelta esos frascos de agua robados del depósito! ¡Morador, ayúdame a calmarlas!'")
            endif
        endif
    endif
EndFunction

bool Function IsWaterChipInstalledInPlant()
    return waterChipInstalledInPlant
EndFunction

bool Function IsWaterChipExtracted()
    return waterChipExtracted
EndFunction

Function RewardWatershedPrisonerLiberation()
    if watershedPrisonerFreed
        return
    endif
    watershedPrisonerFreed = true
    Actor player = Game.GetPlayer()
    Actor ghoulPrisoner = Game.GetFormFromFile(0x00002918, "Vault13Chronicles.esp") as Actor
    ObjectReference prisonerLight = Game.GetFormFromFile(0x00002919, "Vault13Chronicles.esp") as ObjectReference
    if ghoulPrisoner != None && !ghoulPrisoner.IsDisabled()
        ghoulPrisoner.Disable(false)
    endif
    if prisonerLight != None && !prisonerLight.IsDisabled()
        prisonerLight.Disable(false)
    endif
    Form prisonerNote = Game.GetFormFromFile(0x00001C88, "Vault13Chronicles.esp")
    Form radAway = Game.GetFormFromFile(0x00023742, "Fallout4.esm")
    Form stimpak = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
    if player != None
        if prisonerNote != None && player.GetItemCount(prisonerNote) == 0
            player.AddItem(prisonerNote, 1, false)
        endif
        if radAway != None
            player.AddItem(radAway, 2, false)
        endif
        if stimpak != None
            player.AddItem(stimpak, 2, false)
        endif
    endif
    Game.RewardPlayerXP(150, false)
EndFunction

Function RewardNecropolisWaterDilemma()
    if necroWaterDilemmaRewarded || !necroPumpRepaired
        return
    endif
    necroWaterDilemmaRewarded = true
    Actor player = Game.GetPlayer()
    Form pactDoc = Game.GetFormFromFile(0x00001C89, "Vault13Chronicles.esp")
    Form pureWater = Game.GetFormFromFile(0x000366C0, "Fallout4.esm")
    Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
    if player != None
        if pactDoc != None && player.GetItemCount(pactDoc) == 0
            player.AddItem(pactDoc, 1, false)
        endif
        if pureWater != None
            player.AddItem(pureWater, 3, false)
        endif
        if caps != None
            player.AddItem(caps, 200, false)
        endif
    endif
    Game.RewardPlayerXP(200, false)
    Debug.Notification("[Pacto Hidrológico de Necrópolis] ¡Dilema del Agua resuelto! Al reparar la Gran Bomba antes de extraer el Chip, has salvado tanto al Refugio 13 como a Necrópolis (+200 chapas / +200 PE).")
EndFunction

Function OnWaterChipExtracted()
    if waterChipInstalledInPlant
        return
    endif
    if chipExtractedNotified && waterChipExtracted && Self.IsObjectiveDisplayed(30) && !Self.IsObjectiveCompleted(30)
        return
    endif
    bool firstExtract = !chipExtractedNotified
    chipExtractedNotified = true
    waterChipExtracted = true
    intercomResolved = true
    harryEvacPending = false
    harryCombatPending = false
    if firstExtract
        Debug.Notification("[Refugio 12] ¡Chip de Purificación de Agua extraído! Sube por la Escalerilla de Salida al Yermo (aquí mismo) y regresa al Refugio 13.")
    endif
    if necroPumpRepaired
        RewardNecropolisWaterDilemma()
    endif
    SyncVault12InnerChamberState()
    ForceAllAct2Aliases()
    EnsureSingleActiveObjective(30)
    RefreshDisplayedAct2Objective()
    Actor player = Game.GetPlayer()
    ObjectReference waterComp = Game.GetFormFromFile(0x00002A10, "Vault13Chronicles.esp") as ObjectReference
    Form waterChip = Game.GetFormFromFile(0x00001112, "Vault13Chronicles.esp")
    Form report2 = Game.GetFormFromFile(0x00001142, "Vault13Chronicles.esp")
    Form pistol223 = Game.GetFormFromFile(0x00001105, "Vault13Chronicles.esp")
    if player != None
        if waterChip != None
            if player.GetItemCount(waterChip) == 0
                if waterComp != None && waterComp.GetItemCount(waterChip) > 0
                    waterComp.RemoveItem(waterChip, 1, false, player)
                else
                    player.AddItem(waterChip, 1, false)
                endif
            endif
            if waterComp != None && waterComp.GetItemCount(waterChip) > 0
                waterComp.RemoveItem(waterChip, waterComp.GetItemCount(waterChip), true, None)
            endif
            if player.GetItemCount(waterChip) > 1
                player.RemoveItem(waterChip, player.GetItemCount(waterChip) - 1, true, None)
            endif
        endif
        if report2 != None && player.GetItemCount(report2) == 0
            if waterComp != None && waterComp.GetItemCount(report2) > 0
                waterComp.RemoveItem(report2, 1, false, player)
            else
                player.AddItem(report2, 1, false)
            endif
        endif
        if pistol223 != None && player.GetItemCount(pistol223) == 0
            if waterComp != None && waterComp.GetItemCount(pistol223) > 0
                waterComp.RemoveItem(pistol223, 1, false, player)
            else
                player.AddItem(pistol223, 1, false)
            endif
        endif
    endif
    if !Self.IsRunning()
        Self.Start()
    endif
    if Self.GetStage() < 30
        Self.SetStage(30)
    elseif firstExtract
        ApplyV13Act2Stage(30)
    endif
EndFunction

bool Function IsNecropolisPumpRepaired()
    return necroPumpRepaired
EndFunction

Function SetNecropolisPumpState(bool abRepaired)
    if pumpStateInitialized && lastPumpStateRepaired == abRepaired
        return
    endif
    pumpStateInitialized = true
    lastPumpStateRepaired = abRepaired
    ObjectReference pumpConsole = Game.GetFormFromFile(0x00002A54, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference pumpTable = Game.GetFormFromFile(0x00002A5D, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference pumpBroken = Game.GetFormFromFile(0x00002A55, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference pumpSparks = Game.GetFormFromFile(0x00002A56, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference pumpAlarm = Game.GetFormFromFile(0x00002A5C, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference pumpRunning = Game.GetFormFromFile(0x00002A57, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference pumpGreenLight = Game.GetFormFromFile(0x00002A58, "Vault13Chronicles.esp") as ObjectReference

    if pumpConsole != None && pumpConsole.IsDisabled()
        pumpConsole.Enable(false)
    endif
    if pumpTable != None && pumpTable.IsDisabled()
        pumpTable.Enable(false)
    endif

    if abRepaired
        if pumpBroken != None && !pumpBroken.IsDisabled()
            pumpBroken.Disable(false)
        endif
        if pumpSparks != None && !pumpSparks.IsDisabled()
            pumpSparks.Disable(false)
        endif
        if pumpAlarm != None && !pumpAlarm.IsDisabled()
            pumpAlarm.Disable(false)
        endif
        if pumpRunning != None && pumpRunning.IsDisabled()
            pumpRunning.Enable(false)
        endif
        if pumpGreenLight != None && pumpGreenLight.IsDisabled()
            pumpGreenLight.Enable(false)
        endif
    else
        if pumpRunning != None && !pumpRunning.IsDisabled()
            pumpRunning.Disable(false)
        endif
        if pumpGreenLight != None && !pumpGreenLight.IsDisabled()
            pumpGreenLight.Disable(false)
        endif
        if pumpBroken != None && pumpBroken.IsDisabled()
            pumpBroken.Enable(false)
        endif
        if pumpSparks != None && pumpSparks.IsDisabled()
            pumpSparks.Enable(false)
        endif
        if pumpAlarm != None && pumpAlarm.IsDisabled()
            pumpAlarm.Enable(false)
        endif
    endif
EndFunction

Function OnPumpPartsRecovered()
    if necroPumpRepaired || waterChipExtracted || waterChipInstalledInPlant
        return
    endif
    if pumpPartsNotified && pumpPartsRecovered && Self.IsObjectiveDisplayed(25) && !Self.IsObjectiveCompleted(25)
        return
    endif
    bool firstParts = !pumpPartsNotified
    pumpPartsNotified = true
    pumpPartsRecovered = true
    garretArmoryUnlockedNotified = true
    sewerPasswordFound = true
    if firstParts
        Debug.Notification("[Necrópolis] Has recuperado las Piezas Hidráulicas (Junk Parts). Dirígete a la Plaza de Bombeo de la Cuenca e instálalas en la Gran Bomba de Agua.")
    endif
    ForceAllAct2Aliases()
    EnsureSingleActiveObjective(25)
    RefreshDisplayedAct2Objective()
    Actor player = Game.GetPlayer()
    Form pumpParts = Game.GetFormFromFile(0x0000111D, "Vault13Chronicles.esp")
    ObjectReference sewPartsBox = Game.GetFormFromFile(0x00002F22, "Vault13Chronicles.esp") as ObjectReference
    if player != None && pumpParts != None
        if player.GetItemCount(pumpParts) == 0
            if sewPartsBox != None && sewPartsBox.GetItemCount(pumpParts) > 0
                sewPartsBox.RemoveItem(pumpParts, 1, false, player)
            else
                player.AddItem(pumpParts, 1, false)
            endif
        endif
        if sewPartsBox != None && sewPartsBox.GetItemCount(pumpParts) > 0
            sewPartsBox.RemoveItem(pumpParts, sewPartsBox.GetItemCount(pumpParts), true, None)
        endif
    endif
    if !Self.IsRunning()
        Self.Start()
    endif
    if Self.GetStage() < 25
        Self.SetStage(25)
    elseif firstParts
        ApplyV13Act2Stage(25)
    endif
EndFunction

Function NotifySewerForemanTerminalRead()
    if sewerPasswordFound
        return
    endif
    sewerPasswordFound = true
    Game.RewardPlayerXP(75, false)
    Debug.Notification("[Alcantarillas de Necrópolis] Clave del Capataz Ezequiel obtenida: 2161-AGUA-12. Avanza hacia el Taller Hidráulico al oeste.")
    ForceAllAct2Aliases()
EndFunction

Function UnlockSewerHydraulicChamber()
    if bSewerChamberUnlocked
        return
    endif
    bSewerChamberUnlocked = true
    sewerPasswordFound = true
    ObjectReference d2F05 = Game.GetFormFromFile(0x00002F05, "Vault13Chronicles.esp") as ObjectReference
    if d2F05 != None
        d2F05.Enable(false)
        if d2F05.IsLocked()
            d2F05.Lock(false, false)
        endif
        d2F05.SetOpen(true)
    endif
    Game.RewardPlayerXP(150, false)
    ForceAllAct2Aliases()
    Debug.Notification("[Alcantarillas de Necrópolis] ¡Contraseña aceptada (2161-AGUA-12)! Taller Hidráulico desbloqueado.")
EndFunction

Function OnWaterPumpActivated()
    if necroPumpRepaired || bPumpPromptQueued || bPumpMissingPartsHold
        return
    endif
    bPumpPromptQueued = true
    Actor player = Game.GetPlayer()
    Form pumpPartsCheck = Game.GetFormFromFile(0x0000111D, "Vault13Chronicles.esp")
    int stgNow = GetEffectiveAct2Stage()
    bool hasParts = (stgNow >= 25 || pumpPartsRecovered || (player != None && pumpPartsCheck != None && player.GetItemCount(pumpPartsCheck) > 0))
    if !hasParts
        bPumpPromptQueued = false
        bPumpMissingPartsHold = true
        StartTimer(0.4, 17)
        Debug.Notification("[Cuenca de Necrópolis] Necesitas las Piezas Hidráulicas de Repuesto ('Junk Parts') perdidas en el tramo medio de las alcantarillas.")
        return
    endif
    StartTimer(0.3, 17)
EndFunction

Function RepairNecropolisWaterPump()
    if necroPumpRepaired
        return
    endif
    necroPumpRepaired = true
    pumpPartsRecovered = true
    pumpPartsNotified = true
    bPumpPromptQueued = false
    bPumpMissingPartsHold = false
    CancelTimer(17)

    ObjectReference d2A34 = Game.GetFormFromFile(0x00002A34, "Vault13Chronicles.esp") as ObjectReference
    if d2A34 != None
        if d2A34.IsDisabled()
            d2A34.Enable(false)
        endif
        d2A34.Lock(false, false)
        d2A34.BlockActivation(false, false)
    endif

    ForceAllAct2Aliases()
    EnsureSingleActiveObjective(26)
    RefreshDisplayedAct2Objective()
    Debug.Notification("[Cuenca de Necrópolis] ¡GRAN BOMBA DE AGUA REPARADA! Esclusa de la Estación del Refugio 12 desbloqueada.")

    Actor player = Game.GetPlayer()
    Form pumpParts = Game.GetFormFromFile(0x0000111D, "Vault13Chronicles.esp")
    Actor ugLeader = Game.GetFormFromFile(0x00002A18, "Vault13Chronicles.esp") as Actor
    ObjectReference pumpRunning = Game.GetFormFromFile(0x00002A57, "Vault13Chronicles.esp") as ObjectReference

    if player != None && pumpParts != None && player.GetItemCount(pumpParts) > 0
        player.RemoveItem(pumpParts, player.GetItemCount(pumpParts), true, None)
    endif

    SetNecropolisPumpState(true)

    if !undergroundRewardGiven
        undergroundRewardGiven = true
        Form radAway = Game.GetFormFromFile(0x00023742, "Fallout4.esm")
        Form stimpak = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
        if player != None
            if radAway != None
                player.AddItem(radAway, 3, false)
            endif
            if stimpak != None
                player.AddItem(stimpak, 3, false)
            endif
        endif
        Game.RewardPlayerXP(250, false)
    endif

    if Self.GetStage() < 26
        Self.SetStage(26)
    else
        ApplyV13Act2Stage(26)
    endif

    if ugLeader != None
        if ugLeader.IsDisabled()
            ugLeader.Enable(false)
        endif
        if ugLeader.IsDead()
            ugLeader.Resurrect()
        endif
        ugLeader.StopCombat()
        ugLeader.SetPosition(80.0, 7820.0, 0.0)
        ugLeader.SetAngle(0.0, 0.0, 145.0)
        if player != None
            ugLeader.SetLookAt(player, false)
        endif
        ugLeader.EvaluatePackage()
    endif

    EffectShader constFX = Game.GetFormFromFile(0x002494E4, "Fallout4.esm") as EffectShader
    Form pulseExpl = Game.GetFormFromFile(0x000C32DA, "Fallout4.esm")
    Sound sfxPumpRepair = Game.GetFormFromFile(0x00001064, "Vault13Chronicles.esp") as Sound
    if sfxPumpRepair != None && player != None
        sfxPumpRepair.Play(player)
    endif
    if pumpRunning != None && pulseExpl != None
        pumpRunning.PlaceAtMe(pulseExpl, 1, false, false)
    endif
    if player != None && constFX != None
        constFX.Play(player, 1.8)
    endif

    if ugLeader != None
        if player != None
            ugLeader.SetLookAt(player, false)
        endif
        Topic ugThanksTopic = Game.GetFormFromFile(0x00005049, "Vault13Chronicles.esp") as Topic
        if ugThanksTopic != None && !ugLeader.IsTalking()
            ugLeader.Say(ugThanksTopic, None, false)
        endif
    endif
EndFunction

Function SetWaterPlantState(bool abRepaired)
    waterPlantStateApplied = true
    lastWaterPlantRepaired = abRepaired
    ObjectReference wpConsole = Game.GetFormFromFile(0x00002138, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference wpGenBroken = Game.GetFormFromFile(0x00002160, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference wpSparks1 = Game.GetFormFromFile(0x00002161, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference wpSparks2 = Game.GetFormFromFile(0x00002162, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference wpRed1 = Game.GetFormFromFile(0x00002163, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference wpRed2 = Game.GetFormFromFile(0x00002164, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference wpKlaxon = Game.GetFormFromFile(0x00002165, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference wpRedGlow = Game.GetFormFromFile(0x00002166, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference wpGenRunning = Game.GetFormFromFile(0x00002167, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference wpGreen1 = Game.GetFormFromFile(0x00002168, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference wpGreen2 = Game.GetFormFromFile(0x00002169, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference wpCleanLight = Game.GetFormFromFile(0x0000216A, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference wpChipDisplay = Game.GetFormFromFile(0x0000216B, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference wpTable = Game.GetFormFromFile(0x0000216C, "Vault13Chronicles.esp") as ObjectReference

    if wpConsole != None && wpConsole.IsDisabled()
        wpConsole.EnableNoWait()
    endif
    if wpTable != None && wpTable.IsDisabled()
        wpTable.EnableNoWait()
    endif

    Actor atriumFem = Game.GetFormFromFile(0x00002157, "Vault13Chronicles.esp") as Actor
    if atriumFem != None && !atriumFem.IsTalking() && !atriumFem.IsInDialogueWithPlayer()
        float afDx = atriumFem.GetPositionX() - (-1960.0)
        float afDy = atriumFem.GetPositionY() - (-4480.0)
        if (afDx * afDx + afDy * afDy) > 1600.0
            atriumFem.SetPosition(-1960.0, -4480.0, -528.0)
            atriumFem.SetAngle(0.0, 0.0, 325.0)
        endif
    endif

    int mIdx = 0
    while mIdx < 6
        ObjectReference wpMarker = Game.GetFormFromFile(0x00002170 + mIdx, "Vault13Chronicles.esp") as ObjectReference
        if wpMarker != None && wpMarker.IsDisabled()
            wpMarker.EnableNoWait()
        endif
        mIdx += 1
    endwhile

    if abRepaired
        if wpGenBroken != None && !wpGenBroken.IsDisabled()
            wpGenBroken.DisableNoWait()
        endif
        if wpSparks1 != None && !wpSparks1.IsDisabled()
            wpSparks1.DisableNoWait()
        endif
        if wpSparks2 != None && !wpSparks2.IsDisabled()
            wpSparks2.DisableNoWait()
        endif
        if wpRed1 != None && !wpRed1.IsDisabled()
            wpRed1.DisableNoWait()
        endif
        if wpRed2 != None && !wpRed2.IsDisabled()
            wpRed2.DisableNoWait()
        endif
        if wpKlaxon != None && !wpKlaxon.IsDisabled()
            wpKlaxon.DisableNoWait()
        endif
        if wpRedGlow != None && !wpRedGlow.IsDisabled()
            wpRedGlow.DisableNoWait()
        endif
        if wpGenRunning != None && wpGenRunning.IsDisabled()
            wpGenRunning.EnableNoWait()
        endif
        if wpGreen1 != None && wpGreen1.IsDisabled()
            wpGreen1.EnableNoWait()
        endif
        if wpGreen2 != None && wpGreen2.IsDisabled()
            wpGreen2.EnableNoWait()
        endif
        if wpCleanLight != None && wpCleanLight.IsDisabled()
            wpCleanLight.EnableNoWait()
        endif
        if wpChipDisplay != None && wpChipDisplay.IsDisabled()
            wpChipDisplay.EnableNoWait()
        endif
    else
        if wpGenRunning != None && !wpGenRunning.IsDisabled()
            wpGenRunning.DisableNoWait()
        endif
        if wpGreen1 != None && !wpGreen1.IsDisabled()
            wpGreen1.DisableNoWait()
        endif
        if wpGreen2 != None && !wpGreen2.IsDisabled()
            wpGreen2.DisableNoWait()
        endif
        if wpCleanLight != None && !wpCleanLight.IsDisabled()
            wpCleanLight.DisableNoWait()
        endif
        if wpChipDisplay != None && !wpChipDisplay.IsDisabled()
            wpChipDisplay.DisableNoWait()
        endif
        if wpGenBroken != None && wpGenBroken.IsDisabled()
            wpGenBroken.EnableNoWait()
        endif
        if wpSparks1 != None && wpSparks1.IsDisabled()
            wpSparks1.EnableNoWait()
        endif
        if wpSparks2 != None && wpSparks2.IsDisabled()
            wpSparks2.EnableNoWait()
        endif
        if wpRed1 != None && wpRed1.IsDisabled()
            wpRed1.EnableNoWait()
        endif
        if wpRed2 != None && wpRed2.IsDisabled()
            wpRed2.EnableNoWait()
        endif
        if wpKlaxon != None && wpKlaxon.IsDisabled()
            wpKlaxon.EnableNoWait()
        endif
        if wpRedGlow != None && wpRedGlow.IsDisabled()
            wpRedGlow.EnableNoWait()
        endif
    endif
EndFunction

Function SilenceAllVault13ResidentsExcept(Actor akKeepSpeaker)
    V13Act1QuestScript act1S = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as V13Act1QuestScript
    if act1S == None
        return
    endif
    int sIdx = 0
    while sIdx < 8
        Actor sAct = Game.GetFormFromFile(0x00002150 + sIdx, "Vault13Chronicles.esp") as Actor
        if sAct != None && sAct != akKeepSpeaker && sAct.IsTalking() && !sAct.IsInDialogueWithPlayer()
            act1S.SilenceResidentActor(sAct)
        endif
        sIdx += 1
    endwhile
EndFunction

Function StartWaterPlantWalkSequence()
    if waterChipInstalledInPlant
        return
    endif
    SetWaterPlantState(false)
    SyncVault13CrisisAndCelebrationActors()
    Actor player = Game.GetPlayer()
    Form waterChip = Game.GetFormFromFile(0x00001112, "Vault13Chronicles.esp")
    if player != None && waterChip != None && player.GetItemCount(waterChip) == 0
        player.AddItem(waterChip, 1, true)
    endif
    Actor jacoren = Game.GetFormFromFile(0x00002110, "Vault13Chronicles.esp") as Actor
    Actor calvin = Game.GetFormFromFile(0x00002151, "Vault13Chronicles.esp") as Actor
    if calvin != None
        calvin.Enable(false)
        calvin.SetPosition(-1445.0, -4645.0, -528.0)
        calvin.SetAngle(0.0, 0.0, 218.0)
    endif
    waterPlantMarkerOnConsole = true
    ForceQuestAlias(0, 0x00002110)
    if ForceQuestAlias(9, 0x00002138)
        RefreshDisplayedAct2Objective()
    endif
    ; Keep Jacoren in his office during Stage 35 (no stair teleport); he moves to the Water Plant once the chip is installed (Stage 38):
    if jacoren != None
        if jacoren.GetPositionX() < -3250.0 || jacoren.GetPositionX() > -2920.0 || jacoren.GetPositionZ() < -100.0
            jacoren.SetPosition(-3090.0, -4540.0, -16.0)
            jacoren.SetAngle(0.0, 0.0, 180.0)
        endif
        if !jacoren.IsTalking() && !jacoren.IsInDialogueWithPlayer()
            jacoren.ClearLookAt()
            jacoren.EvaluatePackage()
        endif
    endif
    waterPlantWalkActive = true
    waterPlantWalkStep = 1
EndFunction

Function AdvanceWaterPlantWalkStep()
    if !waterPlantWalkActive || waterChipInstalledInPlant
        return
    endif
    ForceQuestAlias(0, 0x00002110)
    ForceQuestAlias(9, 0x00002138)
EndFunction

Function UpdateWaterPlantSequence()
    Actor player = Game.GetPlayer()
    Cell v13Cell = Game.GetFormFromFile(0x00002100, "Vault13Chronicles.esp") as Cell
    Actor jacoren = Game.GetFormFromFile(0x00002110, "Vault13Chronicles.esp") as Actor
    Actor calvin = Game.GetFormFromFile(0x00002151, "Vault13Chronicles.esp") as Actor
    ObjectReference wpConsole = Game.GetFormFromFile(0x00002138, "Vault13Chronicles.esp") as ObjectReference
    Scene act2RetScene = Game.GetFormFromFile(0x00005101, "Vault13Chronicles.esp") as Scene

    int curStage = GetEffectiveAct2Stage()
    if curStage >= 40
        Quest q3 = Game.GetFormFromFile(0x00006000, "Vault13Chronicles.esp") as Quest
        if q3 != None && q3.GetStage() >= 20
            waterChipInstalledInPlant = true
        endif
    endif

    if curStage >= 30
        if !waterPlantStateApplied || lastWaterPlantRepaired != waterChipInstalledInPlant
            SetWaterPlantState(waterChipInstalledInPlant)
        endif
    endif

    if player == None || v13Cell == None || player.GetParentCell() != v13Cell
        return
    endif

    if !v13CrisisResolved && curStage >= 20 && curStage < 30
        savedNecroStageBeforeCrisis = curStage
        Self.SetStage(18)
        ApplyV13Act2Stage(18)
        return
    endif

    SyncVault13CrisisAndCelebrationActors()

    if curStage < 38 && !waterChipInstalledInPlant
        if jacoren != None && (jacoren.GetPositionX() < -3250.0 || jacoren.GetPositionX() > -2920.0 || jacoren.GetPositionZ() < -100.0)
            jacoren.SetPosition(-3090.0, -4540.0, -16.0)
            jacoren.SetAngle(0.0, 0.0, 180.0)
        endif
        if curStage == 35 && !waterPlantWalkActive
            StartWaterPlantWalkSequence()
        endif
    elseif curStage == 38 || (waterChipInstalledInPlant && (!part1EndShown || !part1EndCardShownV2))
        if jacoren != None && (jacoren.GetPositionZ() > -400.0 || (wpConsole != None && jacoren.GetDistance(wpConsole) > 350.0))
            jacoren.SetPosition(-1685.0, -4645.0, -528.0)
            jacoren.SetAngle(0.0, 0.0, 140.0)
            jacoren.EvaluatePackage()
        endif
    elseif curStage >= 40 && waterChipInstalledInPlant
        if (act2RetScene == None || !act2RetScene.IsPlaying()) && part1EndShown && part1EndCardShownV2 && player.GetPositionZ() > -300.0
            if jacoren != None && (jacoren.GetPositionZ() < -200.0 || jacoren.GetPositionX() > -2920.0) && !jacoren.IsTalking() && !jacoren.IsInDialogueWithPlayer()
                jacoren.SetPosition(-3090.0, -4540.0, -16.0)
                jacoren.SetAngle(0.0, 0.0, 180.0)
            endif
            if calvin != None && calvin.GetPositionZ() < -350.0
                calvin.SetPosition(-2450.0, -4020.0, -272.0)
                calvin.SetAngle(0.0, 0.0, 302.5)
            endif
        endif
    endif
EndFunction

Function OnWaterPlantTerminalInstallSelected()
    if waterChipInstalledInPlant || waterPlantInstallQueued
        return
    endif
    waterPlantInstallQueued = true
    waterChipExtracted = true
    chipExtractedNotified = true
    StartTimer(0.15, 14)
EndFunction

Function OnWaterPlantConsoleActivated()
    if waterChipInstalledInPlant || waterPlantConsoleOpenedWithChip || waterPlantInstallQueued || bWaterPlantPromptBusy
        return
    endif
    bWaterPlantPromptBusy = true
    Actor player = Game.GetPlayer()
    Form waterChip = Game.GetFormFromFile(0x00001112, "Vault13Chronicles.esp")
    int effStg = GetEffectiveAct2Stage()
    if effStg >= 30 || waterChipExtracted || (player != None && waterChip != None && player.GetItemCount(waterChip) > 0)
        waterPlantConsoleOpenedWithChip = true
        StartTimer(0.25, 14)
    else
        bWaterPlantPromptBusy = false
    endif
EndFunction

Function TriggerWaterPlantCelebrationStep()
    if !waterChipInstalledInPlant
        return
    endif
    Actor player = Game.GetPlayer()
    Actor jacoren = Game.GetFormFromFile(0x00002110, "Vault13Chronicles.esp") as Actor
    Actor lyle = Game.GetFormFromFile(0x00002150, "Vault13Chronicles.esp") as Actor
    Actor calvin = Game.GetFormFromFile(0x00002151, "Vault13Chronicles.esp") as Actor
    Actor cindy = Game.GetFormFromFile(0x00002152, "Vault13Chronicles.esp") as Actor
    Actor theresa = Game.GetFormFromFile(0x00002153, "Vault13Chronicles.esp") as Actor
    Actor atriumMale = Game.GetFormFromFile(0x00002156, "Vault13Chronicles.esp") as Actor
    Actor atriumFem = Game.GetFormFromFile(0x00002157, "Vault13Chronicles.esp") as Actor
    Scene act2RetScene = Game.GetFormFromFile(0x00005101, "Vault13Chronicles.esp") as Scene
    Idle idleCheer = Game.GetFormFromFile(0x0010BA3A, "Fallout4.esm") as Idle
    Idle idleClap = Game.GetFormFromFile(0x00141F3C, "Fallout4.esm") as Idle
    Idle idleStop = Game.GetFormFromFile(0x00029380, "Fallout4.esm") as Idle
    Sound sfxCheer = Game.GetFormFromFile(0x00001061, "Vault13Chronicles.esp") as Sound

    bool jacorenInDial = (act2RetScene != None && act2RetScene.IsPlaying()) || (jacoren != None && jacoren.IsInDialogueWithPlayer())
    if jacorenInDial
        if idleStop != None
            if theresa != None
                theresa.PlayIdle(idleStop)
            endif
            if cindy != None
                cindy.PlayIdle(idleStop)
            endif
            if lyle != None
                lyle.PlayIdle(idleStop)
            endif
            if atriumFem != None
                atriumFem.PlayIdle(idleStop)
            endif
            if atriumMale != None
                atriumMale.PlayIdle(idleStop)
            endif
            if calvin != None
                calvin.PlayIdle(idleStop)
            endif
        endif
        return
    endif

    if celebrationStep == 1
        if sfxCheer != None && player != None
            sfxCheer.Play(player)
        endif
        Debug.Notification("[Moradores del Refugio 13]: '¡Hurra! ¡Agua pura en los conductos! ¡Viva el Morador del Refugio!'")
        if theresa != None
            if player != None
                theresa.SetLookAt(player, false)
            endif
            if idleCheer != None
                theresa.PlayIdle(idleCheer)
            endif
        endif
        if cindy != None
            if player != None
                cindy.SetLookAt(player, false)
            endif
            if idleClap != None
                cindy.PlayIdle(idleClap)
            endif
        endif
        if lyle != None
            if player != None
                lyle.SetLookAt(player, false)
            endif
            if idleCheer != None
                lyle.PlayIdle(idleCheer)
            endif
        endif
        if atriumFem != None
            if player != None
                atriumFem.SetLookAt(player, false)
            endif
            if idleClap != None
                atriumFem.PlayIdle(idleClap)
            endif
        endif
        if atriumMale != None
            if player != None
                atriumMale.SetLookAt(player, false)
            endif
            if idleCheer != None
                atriumMale.PlayIdle(idleCheer)
            endif
        endif
        if theresa != None
            SilenceAllVault13ResidentsExcept(theresa)
            Topic theresaTopic = Game.GetFormFromFile(0x00005042, "Vault13Chronicles.esp") as Topic
            if theresaTopic != None
                theresa.Say(theresaTopic, None, false)
            endif
        endif
        celebrationStep = 2
        StartTimer(4.5, 13)
    elseif celebrationStep == 2
        if sfxCheer != None && player != None
            sfxCheer.Play(player)
        endif
        if cindy != None
            if idleCheer != None
                cindy.PlayIdle(idleCheer)
            endif
            SilenceAllVault13ResidentsExcept(cindy)
            Topic cindyTopic = Game.GetFormFromFile(0x00005041, "Vault13Chronicles.esp") as Topic
            if cindyTopic != None
                cindy.Say(cindyTopic, None, false)
            endif
        endif
        if lyle != None && idleClap != None
            lyle.PlayIdle(idleClap)
        endif
        if theresa != None && idleClap != None
            theresa.PlayIdle(idleClap)
        endif
        celebrationStep = 3
        StartTimer(4.5, 13)
    elseif celebrationStep == 3
        if idleStop != None
            if theresa != None
                theresa.PlayIdle(idleStop)
            endif
            if cindy != None
                cindy.PlayIdle(idleStop)
            endif
            if lyle != None
                lyle.PlayIdle(idleStop)
            endif
            if atriumFem != None
                atriumFem.PlayIdle(idleStop)
            endif
            if atriumMale != None
                atriumMale.PlayIdle(idleStop)
            endif
            if calvin != None
                calvin.PlayIdle(idleStop)
            endif
        endif
        if jacoren != None && !jacoren.IsTalking() && !jacoren.IsInDialogueWithPlayer()
            SilenceAllVault13ResidentsExcept(None)
            if player != None
                jacoren.SetLookAt(player, false)
            endif
            Topic jacTopic = Game.GetFormFromFile(0x00005045, "Vault13Chronicles.esp") as Topic
            if jacTopic != None
                jacoren.Say(jacTopic, None, false)
            endif
        endif
        celebrationStep = 4
    endif
EndFunction

Function InstallWaterChipInMainframe()
    if waterChipInstalledInPlant
        return
    endif
    waterChipExtracted = true
    chipExtractedNotified = true
    waterChipInstalledInPlant = true
    waterPlantInstallQueued = false
    waterPlantConsoleOpenedWithChip = false
    bWaterPlantPromptBusy = false
    CancelTimer(14)
    waterPlantWalkActive = false
    waterPlantWalkStep = 5
    waterPlantMarkerOnConsole = true

    SilenceAllVault13ResidentsExcept(None)

    Actor player = Game.GetPlayer()
    Form waterChip = Game.GetFormFromFile(0x00001112, "Vault13Chronicles.esp")
    Actor jacoren = Game.GetFormFromFile(0x00002110, "Vault13Chronicles.esp") as Actor
    Actor calvin = Game.GetFormFromFile(0x00002151, "Vault13Chronicles.esp") as Actor
    ObjectReference wpGenRunning = Game.GetFormFromFile(0x00002167, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference wpConsole = Game.GetFormFromFile(0x00002138, "Vault13Chronicles.esp") as ObjectReference

    if player != None && waterChip != None && player.GetItemCount(waterChip) > 0
        player.RemoveItem(waterChip, player.GetItemCount(waterChip), true, None)
    endif

    SetWaterPlantState(true)
    SyncVault13CrisisAndCelebrationActors()

    if jacoren != None
        jacoren.SetPosition(-1685.0, -4645.0, -528.0)
        jacoren.SetAngle(0.0, 0.0, 140.0)
        jacoren.EvaluatePackage()
    endif
    if calvin != None
        calvin.SetPosition(-1445.0, -4645.0, -528.0)
        calvin.SetAngle(0.0, 0.0, 218.0)
        calvin.EvaluatePackage()
    endif

    if GetEffectiveAct2Stage() < 38
        Self.SetStage(38)
        ApplyV13Act2Stage(38)
    else
        EnsureSingleActiveObjective(38)
        ForceAllAct2Aliases()
        RefreshDisplayedAct2Objective()
    endif

    SilenceAllVault13ResidentsExcept(calvin)

    EffectShader shockFX = Game.GetFormFromFile(0x0006F122, "Fallout4.esm") as EffectShader
    EffectShader constFX = Game.GetFormFromFile(0x002494E4, "Fallout4.esm") as EffectShader
    Form pulseExpl = Game.GetFormFromFile(0x000C32DA, "Fallout4.esm")
    Sound sfxTurbine = Game.GetFormFromFile(0x00001060, "Vault13Chronicles.esp") as Sound
    Sound sfxCheerInit = Game.GetFormFromFile(0x00001061, "Vault13Chronicles.esp") as Sound
    Idle idleCheer = Game.GetFormFromFile(0x0010BA3A, "Fallout4.esm") as Idle

    if sfxTurbine != None && player != None
        sfxTurbine.Play(player)
    endif
    if sfxCheerInit != None && wpConsole != None
        sfxCheerInit.Play(wpConsole)
    endif
    if wpGenRunning != None && pulseExpl != None
        wpGenRunning.PlaceAtMe(pulseExpl, 1, false, false)
    endif
    if player != None
        if constFX != None
            constFX.Play(player, 2.5)
        endif
        Game.ShakeCamera(player, 0.35, 1.5)
        Game.ShakeController(0.45, 0.45, 1.4)
    endif
    if jacoren != None && shockFX != None
        shockFX.Play(jacoren, 1.2)
    endif
    if jacoren != None && player != None
        jacoren.SetLookAt(player, false)
    endif

    Debug.Notification("[Procesador Central del Refugio 13] ¡CHIP DE AGUA ACOPLADO! ¡Las turbinas purificadoras vuelven a girar al 100% y el agua limpia fluye de nuevo!")
    if calvin != None
        if player != None
            calvin.SetLookAt(player, false)
        endif
        if idleCheer != None
            calvin.PlayIdle(idleCheer)
        endif
        Topic calvinTopic = Game.GetFormFromFile(0x00005044, "Vault13Chronicles.esp") as Topic
        if calvinTopic != None
            calvin.Say(calvinTopic, None, false)
        endif
    endif
    celebrationStep = 1
    StartTimer(5.0, 13)
EndFunction

bool Function IsHarryResolved()
    if intercomResolved || waterChipExtracted || harryEvacuated || harryEvacWalkStarted || harryEvacPending || harrySceneOutcome == 1
        return true
    endif
    Actor harry = Game.GetFormFromFile(0x00002A11, "Vault13Chronicles.esp") as Actor
    if harry != None && harry.IsDead()
        return true
    endif
    return false
EndFunction

Function SyncVault12InnerChamberState()
    Actor player = Game.GetPlayer()
    Cell watershedCell = Game.GetFormFromFile(0x00002900, "Vault13Chronicles.esp") as Cell
    ObjectReference m2903 = Game.GetFormFromFile(0x00002903, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference d290A = Game.GetFormFromFile(0x0000290A, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference d290B = Game.GetFormFromFile(0x0000290B, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference w290E = Game.GetFormFromFile(0x0000290E, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference waterComp = Game.GetFormFromFile(0x00002A10, "Vault13Chronicles.esp") as ObjectReference
    Form waterChip = Game.GetFormFromFile(0x00001112, "Vault13Chronicles.esp")
    Form report2 = Game.GetFormFromFile(0x00001142, "Vault13Chronicles.esp")
    Form pistol223 = Game.GetFormFromFile(0x00001105, "Vault13Chronicles.esp")
    bool resolved = IsHarryResolved()
    if w290E != None && !w290E.IsDisabled()
        w290E.SetPosition(-161.9, 1024.0, -3000.0)
        w290E.Disable(false)
    endif
    if m2903 != None
        if m2903.IsDisabled()
            m2903.Enable(false)
        endif
    endif
    if d290A != None
        if d290A.IsDisabled()
            d290A.Enable(false)
        endif
        if resolved
            d290A.Lock(false, false)
            d290A.BlockActivation(false, false)
            d290A.SetOpen(true)
        else
            d290A.SetOpen(false)
            d290A.BlockActivation(true, true)
        endif
    endif
    if d290B != None
        if d290B.IsDisabled()
            d290B.Enable(false)
        endif
        if watershedCell != None && d290B.GetParentCell() != watershedCell
            if m2903 != None && m2903.GetParentCell() == watershedCell
                d290B.MoveTo(m2903, -152.0, -150.0, 254.0, true)
            elseif d290A != None && d290A.GetParentCell() == watershedCell
                d290B.MoveTo(d290A, 290.0, -58.0, 254.0, true)
            endif
        endif
        if watershedCell == None || d290B.GetParentCell() == watershedCell
            float d290BDx = d290B.GetPositionX() - 128.0
            float d290BDy = d290B.GetPositionY() - 710.0
            float d290BDz = d290B.GetPositionZ() - 254.0
            if (d290BDx * d290BDx + d290BDy * d290BDy + d290BDz * d290BDz) > 25.0
                d290B.SetPosition(128.0, 710.0, 254.0)
                d290B.SetAngle(0.0, 0.0, 0.0)
            endif
        endif
        d290B.Lock(false, false)
        bool hasChipForExit = waterChipExtracted || waterChipInstalledInPlant || GetEffectiveAct2Stage() >= 30 || (player != None && waterChip != None && player.GetItemCount(waterChip) > 0)
        if resolved && hasChipForExit
            d290B.BlockActivation(false, false)
        else
            d290B.BlockActivation(true, true)
        endif
    endif
    if waterComp != None
        if waterComp.IsDisabled()
            waterComp.Enable(false)
        endif
        if watershedCell != None && waterComp.GetParentCell() != watershedCell
            if m2903 != None && m2903.GetParentCell() == watershedCell
                waterComp.MoveTo(m2903, 0.0, 0.0, 0.0, true)
            elseif d290A != None && d290A.GetParentCell() == watershedCell
                waterComp.MoveTo(d290A, 442.0, 92.0, 0.0, true)
            elseif player != None && player.GetParentCell() == watershedCell
                waterComp.MoveTo(player, 0.0, 0.0, 0.0, true)
            endif
        endif
        if watershedCell == None || waterComp.GetParentCell() == watershedCell
            float wcDx = waterComp.GetPositionX() - 280.0
            float wcDy = waterComp.GetPositionY() - 860.0
            float wcDz = waterComp.GetPositionZ() - 0.0
            if (wcDx * wcDx + wcDy * wcDy + wcDz * wcDz) > 25.0
                waterComp.SetPosition(280.0, 860.0, 0.0)
                waterComp.SetAngle(0.0, 0.0, 270.0)
            endif
        endif
        if !waterChipExtracted && !waterChipInstalledInPlant
            if waterChip != None && (player == None || player.GetItemCount(waterChip) == 0)
                if waterComp.GetItemCount(waterChip) == 0
                    waterComp.AddItem(waterChip, 1, true)
                elseif waterComp.GetItemCount(waterChip) > 1
                    waterComp.RemoveItem(waterChip, waterComp.GetItemCount(waterChip) - 1, true, None)
                endif
            endif
            if report2 != None && (player == None || player.GetItemCount(report2) == 0) && waterComp.GetItemCount(report2) == 0
                waterComp.AddItem(report2, 1, true)
            endif
            if pistol223 != None && (player == None || player.GetItemCount(pistol223) == 0) && waterComp.GetItemCount(pistol223) == 0
                waterComp.AddItem(pistol223, 1, true)
            endif
        endif
        if resolved
            waterComp.Lock(false, false)
            waterComp.BlockActivation(false, false)
        else
            waterComp.BlockActivation(true, true)
        endif
    endif
EndFunction

Function ShowHarryIntercomDialog()
    if IsHarryResolved() || harryCombatStarted || harryCombatPending
        return
    endif
    Actor harry = Game.GetFormFromFile(0x00002A11, "Vault13Chronicles.esp") as Actor
    if harry == None || harry.IsDead()
        ResolveHarryIntercom()
        return
    endif
    if GetEffectiveAct2Stage() < 26
        Self.SetStage(26)
    endif
    ForceQuestAlias(10, 0x00002A11)
    Actor player = Game.GetPlayer()
    if player != None && !harry.IsInDialogueWithPlayer() && !harry.IsTalking()
        harry.Activate(player, false)
    endif
EndFunction

Function SyncHarryPatrolFactions(bool abHostileToPlayer)
    Actor harry = Game.GetFormFromFile(0x00002A11, "Vault13Chronicles.esp") as Actor
    Actor g1 = Game.GetFormFromFile(0x00002A12, "Vault13Chronicles.esp") as Actor
    Actor g2 = Game.GetFormFromFile(0x00002A20, "Vault13Chronicles.esp") as Actor
    Faction playerFac = Game.GetFormFromFile(0x0001C21C, "Fallout4.esm") as Faction
    Faction smFac = Game.GetFormFromFile(0x00058305, "Fallout4.esm") as Faction
    Faction raiderFac = Game.GetFormFromFile(0x0001CBED, "Fallout4.esm") as Faction
    ActorValue aggroAV = Game.GetFormFromFile(0x000002BC, "Fallout4.esm") as ActorValue
    ActorValue confAV = Game.GetFormFromFile(0x000002BD, "Fallout4.esm") as ActorValue
    ActorValue assistAV = Game.GetFormFromFile(0x000002BF, "Fallout4.esm") as ActorValue

    if smFac != None
        smFac.SetAlly(smFac, false, false)
        if playerFac != None
            if abHostileToPlayer
                smFac.SetEnemy(playerFac, false, false)
            else
                smFac.SetAlly(playerFac, true, true)
            endif
        endif
    endif

    float targetAggro = 0.0
    if abHostileToPlayer
        targetAggro = 1.0 ; 1.0 = Aggressive (attacks Enemies only, NEVER 2.0 Very Aggressive which attacks Neutrals/Allies!)
    endif

    if harry != None && !harry.IsDead()
        if playerFac != None
            harry.RemoveFromFaction(playerFac)
        endif
        if raiderFac != None
            harry.RemoveFromFaction(raiderFac)
        endif
        if smFac != None
            harry.AddToFaction(smFac)
        endif
        if aggroAV != None
            harry.SetValue(aggroAV, targetAggro)
        endif
        if confAV != None && !harryEvacWalkStarted
            harry.SetValue(confAV, 4.0)
        endif
        if assistAV != None
            harry.SetValue(assistAV, 2.0)
        endif
    endif
    if g1 != None && !g1.IsDead()
        if playerFac != None
            g1.RemoveFromFaction(playerFac)
        endif
        if raiderFac != None
            g1.RemoveFromFaction(raiderFac)
        endif
        if smFac != None
            g1.AddToFaction(smFac)
        endif
        if aggroAV != None
            g1.SetValue(aggroAV, targetAggro)
        endif
        if confAV != None && !harryEvacWalkStarted
            g1.SetValue(confAV, 4.0)
        endif
        if assistAV != None
            g1.SetValue(assistAV, 2.0)
        endif
    endif
    if g2 != None && !g2.IsDead()
        if playerFac != None
            g2.RemoveFromFaction(playerFac)
        endif
        if raiderFac != None
            g2.RemoveFromFaction(raiderFac)
        endif
        if smFac != None
            g2.AddToFaction(smFac)
        endif
        if aggroAV != None
            g2.SetValue(aggroAV, targetAggro)
        endif
        if confAV != None && !harryEvacWalkStarted
            g2.SetValue(confAV, 4.0)
        endif
        if assistAV != None
            g2.SetValue(assistAV, 2.0)
        endif
    endif
EndFunction

Function RefreshHarryPatrolWeaponsAndAI()
    if harryPatrolRefreshedV4
        return
    endif
    harryPatrolRefreshedV4 = true
    Actor player = Game.GetPlayer()
    Actor harry = Game.GetFormFromFile(0x00002A11, "Vault13Chronicles.esp") as Actor
    Actor g1 = Game.GetFormFromFile(0x00002A12, "Vault13Chronicles.esp") as Actor
    Actor g2 = Game.GetFormFromFile(0x00002A20, "Vault13Chronicles.esp") as Actor
    ObjectReference waterComp = Game.GetFormFromFile(0x00002A10, "Vault13Chronicles.esp") as ObjectReference
    Form waterChip = Game.GetFormFromFile(0x00001112, "Vault13Chronicles.esp")
    Form report2 = Game.GetFormFromFile(0x00001142, "Vault13Chronicles.esp")
    Form pistol223 = Game.GetFormFromFile(0x00001105, "Vault13Chronicles.esp")
    Form assaultRifle = Game.GetFormFromFile(0x0000463F, "Fallout4.esm")
    Form ammo556 = Game.GetFormFromFile(0x0001F278, "Fallout4.esm")
    Form sledge = Game.GetFormFromFile(0x0005DF2E, "Fallout4.esm")
    ActorValue hpAV = Game.GetFormFromFile(0x000002D4, "Fallout4.esm") as ActorValue
    Scene harryScene = Game.GetFormFromFile(0x00005109, "Vault13Chronicles.esp") as Scene
    Scene harrySceneOld = Game.GetFormFromFile(0x00005108, "Vault13Chronicles.esp") as Scene
    Scene harrySceneWsh = Game.GetFormFromFile(0x0000510A, "Vault13Chronicles.esp") as Scene

    if harry == None || (!harry.IsInDialogueWithPlayer() && !harry.IsTalking())
        if harryScene != None && harryScene.IsPlaying()
            harryScene.Stop()
        endif
        if harrySceneOld != None && harrySceneOld.IsPlaying()
            harrySceneOld.Stop()
        endif
        if harrySceneWsh != None && harrySceneWsh.IsPlaying()
            harrySceneWsh.Stop()
        endif
    endif

    if harry != None && !harry.IsDead() && !harryEvacuated && !intercomResolved && !harryEvacWalkStarted && !harryEvacPending && !harryCombatStarted && !harryCombatPending && !waterChipExtracted && !harry.IsInCombat() && !harry.IsInDialogueWithPlayer() && !harry.IsTalking()
        if player == None || waterChip == None || player.GetItemCount(waterChip) == 0
            if !Self.IsRunning()
                Self.Start()
            endif
            if waterComp != None
                if waterChip != None
                    if waterComp.GetItemCount(waterChip) == 0
                        waterComp.AddItem(waterChip, 1, true)
                    elseif waterComp.GetItemCount(waterChip) > 1
                        waterComp.RemoveItem(waterChip, waterComp.GetItemCount(waterChip) - 1, true, None)
                    endif
                endif
                if report2 != None && (player == None || player.GetItemCount(report2) == 0) && waterComp.GetItemCount(report2) == 0
                    waterComp.AddItem(report2, 1, true)
                endif
                if pistol223 != None && (player == None || player.GetItemCount(pistol223) == 0) && waterComp.GetItemCount(pistol223) == 0
                    waterComp.AddItem(pistol223, 1, true)
                endif
            endif
            EnsureSingleActiveObjective(26)
        endif
    endif

    if !waterChipExtracted && !waterChipInstalledInPlant && !IsHarryResolved()
        ForceQuestAlias(1, 0x00002907)
        ForceQuestAlias(16, 0x00002907)
    endif
    if !harryCombatStarted && !harryCombatPending && !IsHarryResolved()
        ForceQuestAlias(10, 0x00002A11)
    endif

    if !harryEvacuated
        SyncHarryPatrolFactions(harryCombatStarted || harryCombatPending)
    endif

    Cell watershedCell = Game.GetFormFromFile(0x00002900, "Vault13Chronicles.esp") as Cell
    ObjectReference m2904 = Game.GetFormFromFile(0x00002904, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference m2905 = Game.GetFormFromFile(0x00002905, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference m2906 = Game.GetFormFromFile(0x00002906, "Vault13Chronicles.esp") as ObjectReference

    if harry != None && !harry.IsDead() && !harryEvacuated
        if pistol223 != None && harry.GetItemCount(pistol223) > 0
            if waterComp != None && waterComp.GetItemCount(pistol223) == 0
                harry.RemoveItem(pistol223, harry.GetItemCount(pistol223), true, waterComp)
            else
                harry.RemoveItem(pistol223, harry.GetItemCount(pistol223), true, None)
            endif
        endif
        if assaultRifle != None && harry.GetItemCount(assaultRifle) == 0
            harry.AddItem(assaultRifle, 1, true)
        endif
        if ammo556 != None && harry.GetItemCount(ammo556) < 80
            harry.AddItem(ammo556, 120, true)
        endif
        if sledge != None && harry.GetItemCount(sledge) == 0
            harry.AddItem(sledge, 1, true)
        endif
        if !harryCombatStarted && !harry.IsInDialogueWithPlayer() && !harry.IsTalking()
            if harry.IsDisabled()
                harry.Enable(false)
            endif
            if watershedCell != None && harry.GetParentCell() != watershedCell && m2904 != None
                harry.MoveTo(m2904, 0.0, 0.0, 0.0, true)
            endif
            harry.StopCombat()
            harry.ResetHealthAndLimbs()
            if hpAV != None
                harry.RestoreValue(hpAV, 9999.0)
            endif
            harry.SetPosition(-265.0, 830.0, 4.0)
            harry.SetAngle(0.0, 0.0, 270.0)
        endif
        if assaultRifle != None
            harry.EquipItem(assaultRifle, false, true)
        endif
        harry.EvaluatePackage()
        RegisterForHitEvent(harry, None, None, None, -1, -1, -1, -1, true)
        RegisterForRemoteEvent(harry, "OnDeath")
    endif

    if g1 != None && !g1.IsDead() && !harryEvacuated
        if assaultRifle != None && g1.GetItemCount(assaultRifle) == 0
            g1.AddItem(assaultRifle, 1, true)
        endif
        if ammo556 != None && g1.GetItemCount(ammo556) < 60
            g1.AddItem(ammo556, 100, true)
        endif
        if sledge != None && g1.GetItemCount(sledge) == 0
            g1.AddItem(sledge, 1, true)
        endif
        if !harryCombatStarted
            if g1.IsDisabled()
                g1.Enable(false)
            endif
            if watershedCell != None && g1.GetParentCell() != watershedCell && m2905 != None
                g1.MoveTo(m2905, 0.0, 0.0, 0.0, true)
            endif
            g1.StopCombat()
            g1.ResetHealthAndLimbs()
            if hpAV != None
                g1.RestoreValue(hpAV, 9999.0)
            endif
            g1.SetPosition(-225.0, 950.0, 4.0)
            g1.SetAngle(0.0, 0.0, 270.0)
        endif
        if assaultRifle != None
            g1.EquipItem(assaultRifle, false, true)
        endif
        g1.EvaluatePackage()
        RegisterForHitEvent(g1, None, None, None, -1, -1, -1, -1, true)
        RegisterForRemoteEvent(g1, "OnDeath")
    endif

    if g2 != None && !g2.IsDead() && !harryEvacuated
        if assaultRifle != None && g2.GetItemCount(assaultRifle) == 0
            g2.AddItem(assaultRifle, 1, true)
        endif
        if ammo556 != None && g2.GetItemCount(ammo556) < 60
            g2.AddItem(ammo556, 100, true)
        endif
        if sledge != None && g2.GetItemCount(sledge) == 0
            g2.AddItem(sledge, 1, true)
        endif
        if !harryCombatStarted
            if g2.IsDisabled()
                g2.Enable(false)
            endif
            if watershedCell != None && g2.GetParentCell() != watershedCell && m2906 != None
                g2.MoveTo(m2906, 0.0, 0.0, 0.0, true)
            endif
            g2.StopCombat()
            g2.ResetHealthAndLimbs()
            if hpAV != None
                g2.RestoreValue(hpAV, 9999.0)
            endif
            g2.SetPosition(-225.0, 700.0, 4.0)
            g2.SetAngle(0.0, 0.0, 270.0)
        endif
        if assaultRifle != None
            g2.EquipItem(assaultRifle, false, true)
        endif
        g2.EvaluatePackage()
        RegisterForHitEvent(g2, None, None, None, -1, -1, -1, -1, true)
        RegisterForRemoteEvent(g2, "OnDeath")
    endif
EndFunction

Function StartHarryCombat()
    if harryCombatStarted || harryEvacuated
        return
    endif
    harryCombatStarted = true
    harryEvacWalkStarted = false
    intercomResolved = false
    harryEvacPending = false
    harrySceneStarted = false
    harryDialogueMenuOpen = false
    harryCombatPending = false
    harryCombatWaitTicks = 0
    harrySceneOutcome = 2
    if Self.GetStage() < 28
        Self.SetStage(28)
    endif
    Actor player = Game.GetPlayer()
    Actor harry = Game.GetFormFromFile(0x00002A11, "Vault13Chronicles.esp") as Actor
    Actor g1 = Game.GetFormFromFile(0x00002A12, "Vault13Chronicles.esp") as Actor
    Actor g2 = Game.GetFormFromFile(0x00002A20, "Vault13Chronicles.esp") as Actor
    Scene harrySceneOld = Game.GetFormFromFile(0x00005108, "Vault13Chronicles.esp") as Scene
    Scene harryScene = Game.GetFormFromFile(0x00005109, "Vault13Chronicles.esp") as Scene
    Scene harrySceneWsh = Game.GetFormFromFile(0x0000510A, "Vault13Chronicles.esp") as Scene
    Form assaultRifle = Game.GetFormFromFile(0x0000463F, "Fallout4.esm")
    Form ammo556 = Game.GetFormFromFile(0x0001F278, "Fallout4.esm")

    if harryScene != None && harryScene.IsPlaying()
        harryScene.Stop()
    endif
    if harrySceneOld != None && harrySceneOld.IsPlaying()
        harrySceneOld.Stop()
    endif
    if harrySceneWsh != None && harrySceneWsh.IsPlaying()
        harrySceneWsh.Stop()
    endif
    ReferenceAlias al10 = Self.GetAlias(10) as ReferenceAlias
    if al10 != None
        al10.Clear()
    endif

    ; Synchronize factions and aggression on ALL three actors BEFORE starting combat so they are 100% allies and NEVER attack each other:
    SyncHarryPatrolFactions(true)

    EnsureSingleActiveObjective(28)

    if harry != None && !harry.IsDead()
        if assaultRifle != None
            if harry.GetItemCount(assaultRifle) == 0
                harry.AddItem(assaultRifle, 1, true)
            endif
            if ammo556 != None && harry.GetItemCount(ammo556) < 60
                harry.AddItem(ammo556, 120, true)
            endif
            if harry.GetEquippedWeapon() == None
                harry.EquipItem(assaultRifle, false, true)
            endif
        endif
        harry.SetAlert(true)
        harry.EvaluatePackage()
    endif
    if g1 != None && !g1.IsDead()
        if assaultRifle != None
            if g1.GetItemCount(assaultRifle) == 0
                g1.AddItem(assaultRifle, 1, true)
            endif
            if ammo556 != None && g1.GetItemCount(ammo556) < 60
                g1.AddItem(ammo556, 100, true)
            endif
            if g1.GetEquippedWeapon() == None
                g1.EquipItem(assaultRifle, false, true)
            endif
        endif
        g1.SetAlert(true)
        g1.EvaluatePackage()
    endif
    if g2 != None && !g2.IsDead()
        if assaultRifle != None
            if g2.GetItemCount(assaultRifle) == 0
                g2.AddItem(assaultRifle, 1, true)
            endif
            if ammo556 != None && g2.GetItemCount(ammo556) < 60
                g2.AddItem(ammo556, 100, true)
            endif
            if g2.GetEquippedWeapon() == None
                g2.EquipItem(assaultRifle, false, true)
            endif
        endif
        g2.SetAlert(true)
        g2.EvaluatePackage()
    endif
    if player != None && !player.IsDead()
        if harry != None && !harry.IsDead()
            harry.StartCombat(player)
        endif
        if g1 != None && !g1.IsDead()
            g1.StartCombat(player)
        endif
        if g2 != None && !g2.IsDead()
            g2.StartCombat(player)
        endif
    endif
    StartTimer(0.25, 11)
    SyncVault12InnerChamberState()
    ForceAllAct2Aliases()
    RefreshDisplayedAct2Objective()
    Debug.Notification("[Refugio 12 — Supermutante Harry] '¡Nadie toca el agua de Lou! ¡Aplastad al humano, muchachos!'")
EndFunction

Function OpenHarryDialogueMenu()
    ShowHarryIntercomDialog()
EndFunction

Function ResolveHarryIntercom()
    if bResolvingHarry || (intercomResolved && setContractRewarded && watershedPrisonerFreed)
        return
    endif
    bResolvingHarry = true
    bool firstResolve = !intercomResolved
    bool grantSetReward = !setContractRewarded
    setContractRewarded = true
    intercomResolved = true
    harryCombatPending = false
    if !Self.IsRunning()
        Self.Start()
    endif
    SyncVault12InnerChamberState()
    Actor harry = Game.GetFormFromFile(0x00002A11, "Vault13Chronicles.esp") as Actor
    ObjectReference waterComp = Game.GetFormFromFile(0x00002A10, "Vault13Chronicles.esp") as ObjectReference
    Form waterChip = Game.GetFormFromFile(0x00001112, "Vault13Chronicles.esp")
    Form report2 = Game.GetFormFromFile(0x00001142, "Vault13Chronicles.esp")
    Form pistol223 = Game.GetFormFromFile(0x00001105, "Vault13Chronicles.esp")
    Actor player = Game.GetPlayer()
    bool alreadyHasChip = waterChipExtracted || waterChipInstalledInPlant || (player != None && waterChip != None && player.GetItemCount(waterChip) > 0)
    ForceAllAct2Aliases()
    if !alreadyHasChip
        EnsureSingleActiveObjective(27)
    endif
    RefreshDisplayedAct2Objective()
    if waterComp != None && player != None && !alreadyHasChip
        if waterChip != None && player.GetItemCount(waterChip) == 0
            if waterComp.GetItemCount(waterChip) == 0
                waterComp.AddItem(waterChip, 1, true)
            elseif waterComp.GetItemCount(waterChip) > 1
                waterComp.RemoveItem(waterChip, waterComp.GetItemCount(waterChip) - 1, true, None)
            endif
        endif
        if report2 != None && player.GetItemCount(report2) == 0 && waterComp.GetItemCount(report2) == 0
            waterComp.AddItem(report2, 1, true)
        endif
        if pistol223 != None && player.GetItemCount(pistol223) == 0 && waterComp.GetItemCount(pistol223) == 0
            if harry != None && !harry.IsDead() && harry.GetItemCount(pistol223) > 0
                harry.RemoveItem(pistol223, 1, true, waterComp)
            else
                waterComp.AddItem(pistol223, 1, true)
            endif
        endif
    endif
    ObjectReference armoryChest = Game.GetFormFromFile(0x00002E20, "Vault13Chronicles.esp") as ObjectReference
    if armoryChest != None
        if armoryChest.IsDisabled()
            armoryChest.Enable(false)
        endif
        armoryChest.Lock(false, false)
    endif
    if grantSetReward
        Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
        if player != None && caps != None
            player.AddItem(caps, 300, false)
        endif
        Game.RewardPlayerXP(300, false)
        Debug.Notification("[Refugio 12] ¡Patrulla de Harry, Barry y Sally neutralizada y Cámara del Procesador desbloqueada! (+300 chapas / +300 PE)")
    elseif firstResolve && !alreadyHasChip
        Debug.Notification("[Refugio 12] ¡Cámara del Procesador Central desbloqueada! Extrae el Chip de Agua de la Computadora del Refugio 12.")
    endif
    RewardWatershedPrisonerLiberation()
    bResolvingHarry = false
EndFunction

Function BeginHarryEvacuationWalk()
    if harryEvacuated
        return
    endif
    harryDialogueMenuOpen = false
    harrySceneStarted = false
    harrySceneOutcome = 1
    harryEvacPending = false
    harryEvacWalkStarted = true
    Scene harryScene = Game.GetFormFromFile(0x00005109, "Vault13Chronicles.esp") as Scene
    Scene harrySceneOld = Game.GetFormFromFile(0x00005108, "Vault13Chronicles.esp") as Scene
    Scene harrySceneWsh = Game.GetFormFromFile(0x0000510A, "Vault13Chronicles.esp") as Scene
    if harryScene != None && harryScene.IsPlaying()
        harryScene.Stop()
    endif
    if harrySceneOld != None && harrySceneOld.IsPlaying()
        harrySceneOld.Stop()
    endif
    if harrySceneWsh != None && harrySceneWsh.IsPlaying()
        harrySceneWsh.Stop()
    endif
    ResolveHarryIntercom()
    Actor harry = Game.GetFormFromFile(0x00002A11, "Vault13Chronicles.esp") as Actor
    Actor g1 = Game.GetFormFromFile(0x00002A12, "Vault13Chronicles.esp") as Actor
    Actor g2 = Game.GetFormFromFile(0x00002A20, "Vault13Chronicles.esp") as Actor
    ActorValue aggroAV = Game.GetFormFromFile(0x000002BC, "Fallout4.esm") as ActorValue
    ActorValue confAV = Game.GetFormFromFile(0x000002BD, "Fallout4.esm") as ActorValue
    Actor player = Game.GetPlayer()
    if harry != None && !harry.IsDead()
        if aggroAV != None
            harry.SetValue(aggroAV, 0.0)
        endif
        if confAV != None
            harry.SetValue(confAV, 1.0)
        endif
        harry.StopCombat()
        harry.EvaluatePackage()
    endif
    if g1 != None && !g1.IsDead()
        if aggroAV != None
            g1.SetValue(aggroAV, 0.0)
        endif
        if confAV != None
            g1.SetValue(confAV, 1.0)
        endif
        g1.StopCombat()
        g1.EvaluatePackage()
    endif
    if g2 != None && !g2.IsDead()
        if aggroAV != None
            g2.SetValue(aggroAV, 0.0)
        endif
        if confAV != None
            g2.SetValue(confAV, 1.0)
        endif
        g2.StopCombat()
        g2.EvaluatePackage()
    endif
    if player != None
        player.StopCombatAlarm()
    endif
EndFunction

Function EvacuateHarryPatrol()
    harryEvacPending = false
    harryEvacWalkStarted = true
    harryEvacuated = true
    ResolveHarryIntercom()
    Actor harry = Game.GetFormFromFile(0x00002A11, "Vault13Chronicles.esp") as Actor
    Actor g1 = Game.GetFormFromFile(0x00002A12, "Vault13Chronicles.esp") as Actor
    Actor g2 = Game.GetFormFromFile(0x00002A20, "Vault13Chronicles.esp") as Actor
    ObjectReference waterComp = Game.GetFormFromFile(0x00002A10, "Vault13Chronicles.esp") as ObjectReference
    Form pistol223 = Game.GetFormFromFile(0x00001105, "Vault13Chronicles.esp")
    Actor player = Game.GetPlayer()
    if harry != None
        if pistol223 != None && waterComp != None && player != None
            if player.GetItemCount(pistol223) == 0 && waterComp.GetItemCount(pistol223) == 0
                if harry.GetItemCount(pistol223) > 0
                    harry.RemoveItem(pistol223, 1, true, waterComp)
                else
                    waterComp.AddItem(pistol223, 1, true)
                endif
            endif
        endif
        harry.StopCombat()
        harry.Disable(true)
    endif
    if g1 != None
        g1.StopCombat()
        g1.Disable(true)
    endif
    if g2 != None
        g2.StopCombat()
        g2.Disable(true)
    endif
    if player != None
        player.StopCombatAlarm()
    endif
EndFunction

bool Function ForceQuestAlias(int aiAliasID, int aiFormID)
    ObjectReference targetRef = Game.GetFormFromFile(aiFormID, "Vault13Chronicles.esp") as ObjectReference
    ReferenceAlias al = Self.GetAlias(aiAliasID) as ReferenceAlias
    if al != None && targetRef != None
        if al.GetReference() != targetRef
            al.ForceRefTo(targetRef)
            return al.GetReference() == targetRef
        endif
    endif
    return false
EndFunction

Function RefreshDisplayedAct2Objective()
    int[] objIDs = new int[14]
    objIDs[0] = 15
    objIDs[1] = 18
    objIDs[2] = 20
    objIDs[3] = 21
    objIDs[4] = 22
    objIDs[5] = 23
    objIDs[6] = 24
    objIDs[7] = 25
    objIDs[8] = 26
    objIDs[9] = 27
    objIDs[10] = 28
    objIDs[11] = 30
    objIDs[12] = 35
    objIDs[13] = 38
    int idx = 0
    while idx < 14
        int oid = objIDs[idx]
        if Self.IsObjectiveDisplayed(oid) && !Self.IsObjectiveCompleted(oid)
            Self.SetObjectiveDisplayed(oid, false, false)
            Self.SetObjectiveDisplayed(oid, true, false)
            Self.SetActive(true)
        endif
        idx += 1
    endwhile
EndFunction

Function RegisterPlayerEvents()
    Self.RemoveAllInventoryEventFilters()
    Form waterChipFilter = Game.GetFormFromFile(0x00001112, "Vault13Chronicles.esp")
    Form pumpPartsFilter = Game.GetFormFromFile(0x0000111D, "Vault13Chronicles.esp")
    Form prisonerNoteFilter = Game.GetFormFromFile(0x00001C88, "Vault13Chronicles.esp")
    if waterChipFilter != None
        Self.AddInventoryEventFilter(waterChipFilter)
    endif
    if pumpPartsFilter != None
        Self.AddInventoryEventFilter(pumpPartsFilter)
    endif
    if prisonerNoteFilter != None
        Self.AddInventoryEventFilter(prisonerNoteFilter)
    endif
    Actor player = Game.GetPlayer()
    if player != None
        RegisterForRemoteEvent(player, "OnPlayerLoadGame")
        RegisterForRemoteEvent(player, "OnItemEquipped")
        RegisterForRemoteEvent(player, "OnItemAdded")
        RegisterForRemoteEvent(player, "OnLocationChange")
        RegisterForPlayerTeleport()
    endif
    ObjectReference v13ExitDoor42Obj = Game.GetFormFromFile(0x00002142, "Vault13Chronicles.esp") as ObjectReference
    if v13ExitDoor42Obj != None
        RegisterForRemoteEvent(v13ExitDoor42Obj, "OnActivate")
    endif
    ObjectReference v13ExitDoor01Obj = Game.GetFormFromFile(0x00002101, "Vault13Chronicles.esp") as ObjectReference
    if v13ExitDoor01Obj != None
        RegisterForRemoteEvent(v13ExitDoor01Obj, "OnActivate")
    endif
    ObjectReference garretObj = Game.GetFormFromFile(0x00002E12, "Vault13Chronicles.esp") as ObjectReference
    if garretObj != None
        RegisterForRemoteEvent(garretObj, "OnActivate")
        EnsureGarretVendorReady(garretObj as Actor)
    endif
    ObjectReference jacorenObj = Game.GetFormFromFile(0x00002110, "Vault13Chronicles.esp") as ObjectReference
    if jacorenObj != None
        RegisterForRemoteEvent(jacorenObj, "OnActivate")
    endif
    ObjectReference wpConsoleObj = Game.GetFormFromFile(0x00002138, "Vault13Chronicles.esp") as ObjectReference
    if wpConsoleObj != None
        RegisterForRemoteEvent(wpConsoleObj, "OnActivate")
    endif
    ObjectReference pumpConsoleObj = Game.GetFormFromFile(0x00002A54, "Vault13Chronicles.esp") as ObjectReference
    if pumpConsoleObj != None
        RegisterForRemoteEvent(pumpConsoleObj, "OnActivate")
    endif
    Terminal wpTermBase = Game.GetFormFromFile(0x00001182, "Vault13Chronicles.esp") as Terminal
    if wpTermBase != None
        RegisterForRemoteEvent(wpTermBase, "OnMenuItemRun")
    endif
    Terminal pumpTermBase = Game.GetFormFromFile(0x00001183, "Vault13Chronicles.esp") as Terminal
    if pumpTermBase != None
        RegisterForRemoteEvent(pumpTermBase, "OnMenuItemRun")
    endif
    ObjectReference waterCompObj = Game.GetFormFromFile(0x00002A10, "Vault13Chronicles.esp") as ObjectReference
    if waterCompObj != None
        RegisterForRemoteEvent(waterCompObj, "OnActivate")
        RegisterForRemoteEvent(waterCompObj, "OnItemRemoved")
    endif
    ObjectReference sewPartsBoxObj = Game.GetFormFromFile(0x00002F22, "Vault13Chronicles.esp") as ObjectReference
    if sewPartsBoxObj != None
        RegisterForRemoteEvent(sewPartsBoxObj, "OnActivate")
        RegisterForRemoteEvent(sewPartsBoxObj, "OnItemRemoved")
    endif
    ObjectReference ezequielObj = Game.GetFormFromFile(0x00002F18, "Vault13Chronicles.esp") as ObjectReference
    if ezequielObj != None
        RegisterForRemoteEvent(ezequielObj, "OnActivate")
    endif
    Actor harryObj = Game.GetFormFromFile(0x00002A11, "Vault13Chronicles.esp") as Actor
    if harryObj != None
        RegisterForRemoteEvent(harryObj, "OnActivate")
        RegisterForRemoteEvent(harryObj, "OnDeath")
        RegisterForHitEvent(harryObj, None, None, None, -1, -1, -1, -1, true)
    endif
    Actor g1Obj = Game.GetFormFromFile(0x00002A12, "Vault13Chronicles.esp") as Actor
    if g1Obj != None
        RegisterForRemoteEvent(g1Obj, "OnDeath")
        RegisterForHitEvent(g1Obj, None, None, None, -1, -1, -1, -1, true)
    endif
    Actor g2Obj = Game.GetFormFromFile(0x00002A20, "Vault13Chronicles.esp") as Actor
    if g2Obj != None
        RegisterForRemoteEvent(g2Obj, "OnDeath")
        RegisterForHitEvent(g2Obj, None, None, None, -1, -1, -1, -1, true)
    endif
    ObjectReference ghoulPrisonerObj = Game.GetFormFromFile(0x00002918, "Vault13Chronicles.esp") as ObjectReference
    if ghoulPrisonerObj != None
        RegisterForRemoteEvent(ghoulPrisonerObj, "OnActivate")
    endif
    ObjectReference ugLeaderObj = Game.GetFormFromFile(0x00002A18, "Vault13Chronicles.esp") as ObjectReference
    if ugLeaderObj != None
        RegisterForRemoteEvent(ugLeaderObj, "OnActivate")
    endif
    ObjectReference setObj = Game.GetFormFromFile(0x00002E11, "Vault13Chronicles.esp") as ObjectReference
    if setObj != None
        RegisterForRemoteEvent(setObj, "OnActivate")
    endif
    ObjectReference d2A34Obj = Game.GetFormFromFile(0x00002A34, "Vault13Chronicles.esp") as ObjectReference
    if d2A34Obj != None
        RegisterForRemoteEvent(d2A34Obj, "OnActivate")
    endif
    ObjectReference d2A35Obj = Game.GetFormFromFile(0x00002A35, "Vault13Chronicles.esp") as ObjectReference
    if d2A35Obj != None
        RegisterForRemoteEvent(d2A35Obj, "OnActivate")
    endif
    ObjectReference d2901Obj = Game.GetFormFromFile(0x00002901, "Vault13Chronicles.esp") as ObjectReference
    if d2901Obj != None
        RegisterForRemoteEvent(d2901Obj, "OnActivate")
    endif
    ObjectReference d290BObj = Game.GetFormFromFile(0x0000290B, "Vault13Chronicles.esp") as ObjectReference
    if d290BObj != None
        RegisterForRemoteEvent(d290BObj, "OnActivate")
    endif
    ObjectReference d2F03Obj = Game.GetFormFromFile(0x00002F03, "Vault13Chronicles.esp") as ObjectReference
    if d2F03Obj != None
        RegisterForRemoteEvent(d2F03Obj, "OnActivate")
    endif
    ObjectReference d2F04Obj = Game.GetFormFromFile(0x00002F04, "Vault13Chronicles.esp") as ObjectReference
    if d2F04Obj != None
        RegisterForRemoteEvent(d2F04Obj, "OnActivate")
    endif
    ObjectReference d290AObj = Game.GetFormFromFile(0x0000290A, "Vault13Chronicles.esp") as ObjectReference
    if d290AObj != None
        RegisterForRemoteEvent(d290AObj, "OnActivate")
    endif
    ObjectReference ic290CObj = Game.GetFormFromFile(0x0000290C, "Vault13Chronicles.esp") as ObjectReference
    if ic290CObj != None
        RegisterForRemoteEvent(ic290CObj, "OnActivate")
    endif
    ObjectReference ic290FObj = Game.GetFormFromFile(0x0000290F, "Vault13Chronicles.esp") as ObjectReference
    if ic290FObj != None
        RegisterForRemoteEvent(ic290FObj, "OnActivate")
    endif
    ObjectReference ic2910Obj = Game.GetFormFromFile(0x00002910, "Vault13Chronicles.esp") as ObjectReference
    if ic2910Obj != None
        RegisterForRemoteEvent(ic2910Obj, "OnActivate")
    endif
    if spawnedHarryIntercom != None
        RegisterForRemoteEvent(spawnedHarryIntercom, "OnActivate")
    endif
    if spawnedHarryWallIntercom != None
        RegisterForRemoteEvent(spawnedHarryWallIntercom, "OnActivate")
    endif
    Scene harrySceneReg = Game.GetFormFromFile(0x00005108, "Vault13Chronicles.esp") as Scene
    if harrySceneReg != None
        RegisterForRemoteEvent(harrySceneReg, "OnBegin")
        RegisterForRemoteEvent(harrySceneReg, "OnPhaseBegin")
        RegisterForRemoteEvent(harrySceneReg, "OnEnd")
    endif
    Scene harryWheelSceneReg = Game.GetFormFromFile(0x00005109, "Vault13Chronicles.esp") as Scene
    if harryWheelSceneReg != None
        RegisterForRemoteEvent(harryWheelSceneReg, "OnBegin")
        RegisterForRemoteEvent(harryWheelSceneReg, "OnPhaseBegin")
        RegisterForRemoteEvent(harryWheelSceneReg, "OnEnd")
    endif
    Scene harryWshSceneReg = Game.GetFormFromFile(0x0000510A, "Vault13Chronicles.esp") as Scene
    if harryWshSceneReg != None
        RegisterForRemoteEvent(harryWshSceneReg, "OnBegin")
        RegisterForRemoteEvent(harryWshSceneReg, "OnPhaseBegin")
        RegisterForRemoteEvent(harryWshSceneReg, "OnEnd")
    endif
    Scene act2RetSceneReg = Game.GetFormFromFile(0x00005101, "Vault13Chronicles.esp") as Scene
    if act2RetSceneReg != None
        RegisterForRemoteEvent(act2RetSceneReg, "OnBegin")
        RegisterForRemoteEvent(act2RetSceneReg, "OnPhaseBegin")
        RegisterForRemoteEvent(act2RetSceneReg, "OnEnd")
    endif
    Scene theresaSceneReg = Game.GetFormFromFile(0x00005104, "Vault13Chronicles.esp") as Scene
    if theresaSceneReg != None
        RegisterForRemoteEvent(theresaSceneReg, "OnBegin")
        RegisterForRemoteEvent(theresaSceneReg, "OnPhaseBegin")
        RegisterForRemoteEvent(theresaSceneReg, "OnEnd")
    endif
EndFunction

Function SetNecropolisState(bool abEnabled)
    if !abEnabled
        return
    endif
    ObjectReference armoryChest = Game.GetFormFromFile(0x00002E20, "Vault13Chronicles.esp") as ObjectReference
    if armoryChest != None
        if armoryChest.IsDisabled()
            armoryChest.Enable(false)
        endif
        if GetEffectiveAct2Stage() >= 23 || intercomResolved
            armoryChest.SetLockLevel(0)
            armoryChest.Lock(false, false)
        endif
    endif
    ObjectReference sewPartsBox = Game.GetFormFromFile(0x00002F22, "Vault13Chronicles.esp") as ObjectReference
    if sewPartsBox != None
        if sewPartsBox.IsDisabled()
            sewPartsBox.Enable(false)
        endif
        Form pumpPartsForm = Game.GetFormFromFile(0x0000111D, "Vault13Chronicles.esp")
        Actor playerCheck = Game.GetPlayer()
        if !necroPumpRepaired && !pumpPartsRecovered && pumpPartsForm != None && playerCheck != None
            if playerCheck.GetItemCount(pumpPartsForm) == 0 && sewPartsBox.GetItemCount(pumpPartsForm) == 0
                sewPartsBox.AddItem(pumpPartsForm, 1, true)
            endif
        endif
    endif
    ObjectReference d2A34 = Game.GetFormFromFile(0x00002A34, "Vault13Chronicles.esp") as ObjectReference
    if d2A34 != None
        if d2A34.IsDisabled()
            d2A34.Enable(false)
        endif
        d2A34.Lock(false, false)
        if !necroPumpRepaired && GetEffectiveAct2Stage() < 26
            d2A34.BlockActivation(true, true)
        else
            d2A34.BlockActivation(false, false)
        endif
    endif
    ObjectReference d2A35 = Game.GetFormFromFile(0x00002A35, "Vault13Chronicles.esp") as ObjectReference
    if d2A35 != None
        if d2A35.IsDisabled()
            d2A35.Enable(false)
        endif
        float d2A35Dx = d2A35.GetPositionX() - (-640.0)
        float d2A35Dy = d2A35.GetPositionY() - 8962.0
        float d2A35Dz = d2A35.GetPositionZ() - 254.0
        if (d2A35Dx * d2A35Dx + d2A35Dy * d2A35Dy + d2A35Dz * d2A35Dz) > 25.0
            d2A35.SetPosition(-640.0, 8962.0, 254.0)
            d2A35.SetAngle(0.0, 0.0, 180.0)
        endif
        d2A35.Lock(false, false)
        d2A35.BlockActivation(false, false)
    endif
    ObjectReference d2A03 = Game.GetFormFromFile(0x00002A03, "Vault13Chronicles.esp") as ObjectReference
    if d2A03 != None
        if d2A03.IsDisabled()
            d2A03.Enable(false)
        endif
        float d2A03Dx = d2A03.GetPositionX() - 5305.0
        float d2A03Dy = d2A03.GetPositionY() - (-3840.0)
        float d2A03Dz = d2A03.GetPositionZ() - (-1138.0)
        if (d2A03Dx * d2A03Dx + d2A03Dy * d2A03Dy + d2A03Dz * d2A03Dz) > 25.0
            d2A03.SetPosition(5305.0, -3840.0, -1138.0)
            d2A03.SetAngle(0.0, 0.0, 270.0)
        endif
        d2A03.Lock(false, false)
        d2A03.BlockActivation(false, false)
    endif
    ObjectReference s2A82 = Game.GetFormFromFile(0x00002A82, "Vault13Chronicles.esp") as ObjectReference
    if s2A82 != None
        if s2A82.IsDisabled()
            s2A82.Enable(false)
        endif
        float s2A82Dz = s2A82.GetPositionZ() - (-1138.0)
        if s2A82Dz > 5.0 || s2A82Dz < -5.0
            s2A82.SetPosition(5449.0, -3840.0, -1138.0)
            s2A82.SetAngle(0.0, 0.0, 90.0)
        endif
    endif
    int sealFid = 0x000029AB
    while sealFid <= 0x000029B3
        ObjectReference sealRef = Game.GetFormFromFile(sealFid, "Vault13Chronicles.esp") as ObjectReference
        if sealRef != None && sealRef.IsDisabled()
            sealRef.Enable(false)
        endif
        sealFid += 1
    endwhile
    SetNecropolisPumpState(necroPumpRepaired)
    SyncVault12InnerChamberState()
    Actor ghoulPrisonerState = Game.GetFormFromFile(0x00002918, "Vault13Chronicles.esp") as Actor
    ObjectReference prisonerLightState = Game.GetFormFromFile(0x00002919, "Vault13Chronicles.esp") as ObjectReference
    if ghoulPrisonerState != None
        if !ghoulPrisonerState.IsDisabled()
            ghoulPrisonerState.StopCombat()
            ghoulPrisonerState.Disable(false)
        endif
        if ghoulPrisonerState.GetPositionZ() > -1000.0
            ghoulPrisonerState.SetPosition(-380.0, 980.0, -3000.0)
        endif
    endif
    if prisonerLightState != None && !prisonerLightState.IsDisabled()
        prisonerLightState.Disable(false)
    endif
    if harryEvacuated
        Actor harry = Game.GetFormFromFile(0x00002A11, "Vault13Chronicles.esp") as Actor
        Actor g1 = Game.GetFormFromFile(0x00002A12, "Vault13Chronicles.esp") as Actor
        Actor g2 = Game.GetFormFromFile(0x00002A20, "Vault13Chronicles.esp") as Actor
        if harry != None && !harry.IsDisabled()
            harry.Disable(false)
        endif
        if g1 != None && !g1.IsDisabled()
            g1.Disable(false)
        endif
        if g2 != None && !g2.IsDisabled()
            g2.Disable(false)
        endif
    endif
EndFunction

bool Function ShouldHoldNecropolisCreatures(Actor akPlayer)
    if GetEffectiveAct2Stage() < 21
        return true
    endif
    Scene ugScene = Game.GetFormFromFile(0x00005102, "Vault13Chronicles.esp") as Scene
    if ugScene != None && ugScene.IsPlaying()
        return true
    endif
    Actor ugLeader = Game.GetFormFromFile(0x00002A18, "Vault13Chronicles.esp") as Actor
    if ugLeader != None && (ugLeader.IsTalking() || ugLeader.IsInDialogueWithPlayer())
        return true
    endif
    if akPlayer != None && akPlayer.GetPositionX() > 4100.0 && akPlayer.GetPositionY() < -3200.0
        return true
    endif
    return false
EndFunction

Function UpdateNecropolisRouteAndCombat()
    Actor player = Game.GetPlayer()
    if player == None
        return
    endif
    Cell necroCell = Game.GetFormFromFile(0x00002A00, "Vault13Chronicles.esp") as Cell
    Cell hallCell = Game.GetFormFromFile(0x00002E00, "Vault13Chronicles.esp") as Cell
    Cell sewerCell = Game.GetFormFromFile(0x00002F00, "Vault13Chronicles.esp") as Cell
    Cell watershedCell = Game.GetFormFromFile(0x00002900, "Vault13Chronicles.esp") as Cell
    if watershedCell != None && player.GetParentCell() == watershedCell
        ObjectReference waterCompWsh = Game.GetFormFromFile(0x00002A10, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference d290ACheck = Game.GetFormFromFile(0x0000290A, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference d290BCheck = Game.GetFormFromFile(0x0000290B, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference m2902Check = Game.GetFormFromFile(0x00002902, "Vault13Chronicles.esp") as ObjectReference
        Actor harryWsh = Game.GetFormFromFile(0x00002A11, "Vault13Chronicles.esp") as Actor
        Actor g1Wsh = Game.GetFormFromFile(0x00002A12, "Vault13Chronicles.esp") as Actor
        Actor g2Wsh = Game.GetFormFromFile(0x00002A20, "Vault13Chronicles.esp") as Actor
        Scene harryScene = Game.GetFormFromFile(0x00005109, "Vault13Chronicles.esp") as Scene
        Scene harrySceneOld = Game.GetFormFromFile(0x00005108, "Vault13Chronicles.esp") as Scene
        Scene harrySceneWsh = Game.GetFormFromFile(0x0000510A, "Vault13Chronicles.esp") as Scene
        bool isHarryScenePlaying = (harryScene != None && harryScene.IsPlaying()) || (harrySceneOld != None && harrySceneOld.IsPlaying()) || (harrySceneWsh != None && harrySceneWsh.IsPlaying())
        if necroCellRefreshed || (waterCompWsh != None && waterCompWsh.GetParentCell() != watershedCell) || (!harryEvacuated && harryWsh != None && harryWsh.GetParentCell() != watershedCell) || (d290ACheck != None && d290ACheck.IsDisabled()) || (d290BCheck != None && d290BCheck.IsDisabled())
            necroCellRefreshed = false
            SetNecropolisState(true)
        endif
        RefreshHarryPatrolWeaponsAndAI()
        SyncVault12InnerChamberState()
        ForceAllAct2Aliases()

        if !intercomResolved && IsHarryResolved()
            ResolveHarryIntercom()
        endif

        Form waterChipWsh = Game.GetFormFromFile(0x00001112, "Vault13Chronicles.esp")
        Form report2Wsh = Game.GetFormFromFile(0x00001142, "Vault13Chronicles.esp")
        Form pistol223Wsh = Game.GetFormFromFile(0x00001105, "Vault13Chronicles.esp")
        if !waterChipExtracted && !waterChipInstalledInPlant
            bool chipTaken = (waterChipWsh != None && player.GetItemCount(waterChipWsh) > 0)
            if chipTaken
                OnWaterChipExtracted()
                return
            elseif waterCompWsh != None && waterChipWsh != None && waterCompWsh.GetItemCount(waterChipWsh) == 0
                waterCompWsh.AddItem(waterChipWsh, 1, true)
            endif
        endif

        if harryEvacPending && !harryEvacWalkStarted
            if !isHarryScenePlaying && (harryWsh == None || (!harryWsh.IsTalking() && !harryWsh.IsInDialogueWithPlayer()))
                BeginHarryEvacuationWalk()
            endif
            return
        endif

        if harryEvacWalkStarted && !harryEvacuated
            harryEvacTicks += 1
            if harryWsh == None || harryWsh.IsDead() || harryWsh.GetPositionZ() > 140.0 || (m2902Check != None && harryWsh.GetDistance(m2902Check) < 220.0) || harryEvacTicks >= 8
                EvacuateHarryPatrol()
            else
                harryWsh.EvaluatePackage()
                if g1Wsh != None && !g1Wsh.IsDead()
                    g1Wsh.EvaluatePackage()
                endif
                if g2Wsh != None && !g2Wsh.IsDead()
                    g2Wsh.EvaluatePackage()
                endif
            endif
            return
        endif

        if harryCombatPending && !harryCombatStarted
            SyncHarryPatrolFactions(true)
            harryCombatWaitTicks += 1
            if harryWsh == None || harryWsh.IsDead() || (harryCombatWaitTicks >= 2 && !harryWsh.IsTalking()) || harryCombatWaitTicks >= 6
                StartHarryCombat()
                return
            endif
        endif

        if harryCombatStarted && !intercomResolved && !harryEvacuated && !player.IsDead()
            SyncHarryPatrolFactions(true)
            if harryWsh != None && !harryWsh.IsDead()
                if harryWsh.GetCombatTarget() != None && harryWsh.GetCombatTarget() != player
                    harryWsh.StopCombat()
                endif
                if !harryWsh.IsInCombat() || harryWsh.GetCombatTarget() != player
                    harryWsh.SetAlert(true)
                    harryWsh.EvaluatePackage()
                    harryWsh.StartCombat(player)
                endif
            endif
            if g1Wsh != None && !g1Wsh.IsDead()
                if g1Wsh.GetCombatTarget() != None && g1Wsh.GetCombatTarget() != player
                    g1Wsh.StopCombat()
                endif
                if !g1Wsh.IsInCombat() || g1Wsh.GetCombatTarget() != player
                    g1Wsh.SetAlert(true)
                    g1Wsh.EvaluatePackage()
                    g1Wsh.StartCombat(player)
                endif
            endif
            if g2Wsh != None && !g2Wsh.IsDead()
                if g2Wsh.GetCombatTarget() != None && g2Wsh.GetCombatTarget() != player
                    g2Wsh.StopCombat()
                endif
                if !g2Wsh.IsInCombat() || g2Wsh.GetCombatTarget() != player
                    g2Wsh.SetAlert(true)
                    g2Wsh.EvaluatePackage()
                    g2Wsh.StartCombat(player)
                endif
            endif
        endif

        if !harryCombatStarted && !intercomResolved && !harryEvacuated && !harryEvacWalkStarted && !harryEvacPending
            ActorValue hpAV = Game.GetFormFromFile(0x000002D4, "Fallout4.esm") as ActorValue
            bool patrolDamaged = false
            if hpAV != None
                if (harryWsh != None && !harryWsh.IsDead() && harryWsh.GetValuePercentage(hpAV) < 0.98) || (g1Wsh != None && !g1Wsh.IsDead() && g1Wsh.GetValuePercentage(hpAV) < 0.98) || (g2Wsh != None && !g2Wsh.IsDead() && g2Wsh.GetValuePercentage(hpAV) < 0.98)
                    patrolDamaged = true
                endif
            endif
            if (g1Wsh != None && g1Wsh.IsDead()) || (g2Wsh != None && g2Wsh.IsDead())
                patrolDamaged = true
            endif
            bool fightingPlayer = (harryWsh != None && (harryWsh.IsInCombat() || harryWsh.GetCombatTarget() == player)) || (g1Wsh != None && (g1Wsh.IsInCombat() || g1Wsh.GetCombatTarget() == player)) || (g2Wsh != None && (g2Wsh.IsInCombat() || g2Wsh.GetCombatTarget() == player))
            if patrolDamaged || fightingPlayer
                if GetEffectiveAct2Stage() < 28
                    Self.SetStage(28)
                endif
                StartHarryCombat()
                return
            endif
        endif
        if harryWsh != None && !harryWsh.IsDead() && !harryEvacuated && !harryCombatStarted && !intercomResolved
            if !harryGreetedInRoom && player.GetDistance(harryWsh) < 650.0
                harryGreetedInRoom = true
                harryWsh.SetLookAt(player, false)
                Debug.Notification("[Supermutante Harry]: '¡Eh, tú! ¡Tú no eres un necrófago, eres un humano normal! ¡Habla con Harry ahora mismo antes de que Harry, Barry y Sally te aplasten!'")
            endif
        endif
        Actor ghoulPrisoner = Game.GetFormFromFile(0x00002918, "Vault13Chronicles.esp") as Actor
        ObjectReference prisonerLight = Game.GetFormFromFile(0x00002919, "Vault13Chronicles.esp") as ObjectReference
        if prisonerLight != None && !prisonerLight.IsDisabled()
            prisonerLight.Disable(false)
        endif
        if ghoulPrisoner != None
            if !ghoulPrisoner.IsDisabled()
                ghoulPrisoner.StopCombat()
                ghoulPrisoner.Disable(false)
            endif
            if ghoulPrisoner.GetPositionZ() > -1000.0
                ghoulPrisoner.SetPosition(-380.0, 980.0, -3000.0)
            endif
        endif
        Actor ugLeaderWshCheck = Game.GetFormFromFile(0x00002A18, "Vault13Chronicles.esp") as Actor
        ObjectReference m2A02Return = Game.GetFormFromFile(0x00002A02, "Vault13Chronicles.esp") as ObjectReference
        if ugLeaderWshCheck != None && ugLeaderWshCheck.GetParentCell() == watershedCell && m2A02Return != None
            ugLeaderWshCheck.MoveTo(m2A02Return, 0.0, 0.0, 0.0, true)
        endif
        return
    endif
    if hallCell != None && player.GetParentCell() == hallCell
        ObjectReference armoryChestCheck = Game.GetFormFromFile(0x00002E20, "Vault13Chronicles.esp") as ObjectReference
        if necroCellRefreshed || (armoryChestCheck != None && armoryChestCheck.GetPositionX() > 1750.0)
            necroCellRefreshed = false
            SetNecropolisState(true)
            ForceAllAct2Aliases()
        endif
        Scene garretScene1 = Game.GetFormFromFile(0x00005105, "Vault13Chronicles.esp") as Scene
        Scene garretScene2 = Game.GetFormFromFile(0x00005106, "Vault13Chronicles.esp") as Scene
        Actor garretActor = Game.GetFormFromFile(0x00002E12, "Vault13Chronicles.esp") as Actor
        int hStage = GetEffectiveAct2Stage()
        if hStage >= 23 && armoryChestCheck != None
            armoryChestCheck.SetLockLevel(0)
            armoryChestCheck.Lock(false, false)
        endif
        if !garretIntroDone && (hStage == 21 || hStage == 22)
            if (garretScene1 != None && garretScene1.IsPlaying()) || (garretActor != None && garretActor.IsInDialogueWithPlayer())
                garretIntroSceneStarted = true
            endif
            if garretIntroSceneStarted && (garretScene1 == None || !garretScene1.IsPlaying()) && (garretActor == None || (!garretActor.IsTalking() && !garretActor.IsInDialogueWithPlayer()))
                garretIntroDone = true
                if hStage < 22
                    Self.SetStage(22)
                endif
                ApplyV13Act2Stage(22)
            endif
        endif
        if hStage == 23
            if (garretScene2 != None && garretScene2.IsPlaying()) || (garretActor != None && (garretActor.IsInDialogueWithPlayer() || garretActor.IsTalking()))
                Self.SetStage(24)
                ApplyV13Act2Stage(24)
            endif
        endif
        if hStage >= 24
            ForceAllAct2Aliases()
        endif
        return
    endif
    if sewerCell != None && player.GetParentCell() == sewerCell
        ObjectReference sewTermForemanCheck = Game.GetFormFromFile(0x00002F30, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference sewTermSecCheck = Game.GetFormFromFile(0x00002F31, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference sewWoundedSitCheck = Game.GetFormFromFile(0x00002F19, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference sewBedrollCheck = Game.GetFormFromFile(0x000A078B, "Vault13Chronicles.esp") as ObjectReference
        Actor sewDeadMechCheck = Game.GetFormFromFile(0x00002F18, "Vault13Chronicles.esp") as Actor
        Scene ezequielScene = Game.GetFormFromFile(0x00005107, "Vault13Chronicles.esp") as Scene
        if necroCellRefreshed || (sewTermForemanCheck != None && sewTermForemanCheck.GetPositionY() < -7550.0) || (sewTermSecCheck != None && (sewTermSecCheck.GetPositionY() < -4850.0 || sewTermSecCheck.GetPositionX() < 4910.0)) || (sewDeadMechCheck != None && (sewDeadMechCheck.IsDead() || sewDeadMechCheck.IsBleedingOut())) || (sewBedrollCheck != None && !sewBedrollCheck.IsDisabled())
            necroCellRefreshed = false
            SetNecropolisState(true)
            ForceAllAct2Aliases()
        else
            ForceAllAct2Aliases()
        endif
        if sewDeadMechCheck != None
            if !sewerPasswordFound && !ezequielGreeted && player.GetDistance(sewDeadMechCheck) > 420.0 && sewDeadMechCheck.Is3DLoaded() && sewWoundedSitCheck != None && sewDeadMechCheck.GetSitState() == 0 && !sewDeadMechCheck.IsTalking() && !sewDeadMechCheck.IsInDialogueWithPlayer()
                sewDeadMechCheck.EvaluatePackage()
                sewDeadMechCheck.SnapIntoInteraction(sewWoundedSitCheck)
            endif
            if !ezequielGreeted && player.GetDistance(sewDeadMechCheck) < 280.0
                ezequielGreeted = true
                Debug.Notification("[Capataz Ezequiel]: '¡Argh, mi costado...! ¡Un morador del Refugio! Habla conmigo, tengo la clave del Taller Hidráulico.'")
            endif
            if !sewerPasswordFound && ((ezequielScene != None && ezequielScene.IsPlaying()) || sewDeadMechCheck.IsInDialogueWithPlayer() || sewDeadMechCheck.IsTalking())
                NotifySewerForemanTerminalRead()
            endif
        endif
        Form pumpPartsSew = Game.GetFormFromFile(0x0000111D, "Vault13Chronicles.esp")
        ObjectReference sewPartsBoxCheck = Game.GetFormFromFile(0x00002F22, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference d2F05Sew = Game.GetFormFromFile(0x00002F05, "Vault13Chronicles.esp") as ObjectReference
        if !necroPumpRepaired && pumpPartsSew != None
            if player.GetItemCount(pumpPartsSew) > 0 || (sewPartsBoxCheck != None && d2F05Sew != None && !d2F05Sew.IsLocked() && sewPartsBoxCheck.GetItemCount(pumpPartsSew) == 0)
                if !Self.IsObjectiveDisplayed(25) || Self.IsObjectiveCompleted(25)
                    OnPumpPartsRecovered()
                endif
            endif
        endif
        if !player.IsSneaking() && !player.IsDead()
            float spz = player.GetPositionZ()
            int swIdx = 0
            while swIdx < 7
                Actor swEnemy = Game.GetFormFromFile(0x00002F10 + swIdx, "Vault13Chronicles.esp") as Actor
                if swEnemy != None && !swEnemy.IsDead() && !swEnemy.IsDisabled() && !swEnemy.IsInCombat() && swEnemy.Is3DLoaded()
                    float swDist = player.GetDistance(swEnemy)
                    if swDist < 900.0
                        float swdz = spz - swEnemy.GetPositionZ()
                        if swdz < 0.0
                            swdz = -swdz
                        endif
                        if swdz < 180.0 && (swDist < 420.0 || player.HasDetectionLOS(swEnemy) || swEnemy.HasDetectionLOS(player))
                            swEnemy.EvaluatePackage()
                            swEnemy.StartCombat(player)
                        endif
                    endif
                endif
                swIdx += 1
            endwhile
        endif
        return
    endif
    if necroCell == None || player.GetParentCell() != necroCell
        necroCellRefreshed = false
        return
    endif

    if GetEffectiveAct2Stage() >= 26 || necroPumpRepaired
        Actor ugLeaderPump = Game.GetFormFromFile(0x00002A18, "Vault13Chronicles.esp") as Actor
        if ugLeaderPump != None
            if ugLeaderPump.IsDisabled()
                ugLeaderPump.Enable(false)
            endif
            if !ugLeaderPump.IsDead() && ugLeaderPump.GetPositionY() < 6000.0
                ugLeaderPump.SetPosition(80.0, 7820.0, 0.0)
                ugLeaderPump.SetAngle(0.0, 0.0, 145.0)
                ugLeaderPump.EvaluatePackage()
                Topic ugThanksTopic = Game.GetFormFromFile(0x00005049, "Vault13Chronicles.esp") as Topic
                if ugThanksTopic != None && !ugLeaderPump.IsTalking()
                    ugLeaderPump.Say(ugThanksTopic, None, false)
                endif
            endif
        endif
        ForceAllAct2Aliases()
    endif

    if !intercomResolved && IsHarryResolved()
        ResolveHarryIntercom()
    endif

    ObjectReference d2A01 = Game.GetFormFromFile(0x00002A01, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference d2A03 = Game.GetFormFromFile(0x00002A03, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference d2A05 = Game.GetFormFromFile(0x00002A05, "Vault13Chronicles.esp") as ObjectReference
    Actor ugLeader = Game.GetFormFromFile(0x00002A18, "Vault13Chronicles.esp") as Actor
    if ugLeader != None
        if ugLeader.IsDead()
            ugLeader.Resurrect()
        endif
        if ugLeader.IsInCombat()
            ugLeader.StopCombat()
            ugLeader.StopCombatAlarm()
        endif
    endif

    ObjectReference m2A02 = Game.GetFormFromFile(0x00002A02, "Vault13Chronicles.esp") as ObjectReference
    if m2A02 != None
        m2A02.Enable(false)
        m2A02.SetPosition(5078.7, -3816.0, -1145.0)
        m2A02.SetAngle(0.0, 0.0, 270.0)
    endif

    if player.GetPositionX() > 2500.0 && player.GetPositionY() > 7500.0
        SetNecropolisState(true)
        ObjectReference m2A45 = Game.GetFormFromFile(0x00002A45, "Vault13Chronicles.esp") as ObjectReference
        if m2A45 != None
            player.MoveTo(m2A45, 0.0, 0.0, 0.0, true)
        else
            player.SetPosition(-320.0, 8760.0, 0.0)
            player.SetAngle(0.0, 0.0, 180.0)
        endif
        return
    endif

    if player.GetPositionX() > 2500.0 && player.GetPositionY() > 1000.0 && player.GetPositionZ() < -150.0
        SetNecropolisState(true)
        if m2A02 != None
            player.MoveTo(m2A02, 0.0, 0.0, 0.0, true)
        endif
        return
    endif

    if !necroCellRefreshed
        necroCellRefreshed = true
        SetNecropolisState(true)
        ForceAllAct2Aliases()
        RefreshDisplayedAct2Objective()
        ActorValue avSpeedMult = Game.GetFormFromFile(0x000002DA, "Fallout4.esm") as ActorValue
        int ncIdx = 0
        while ncIdx < 14
            int ncFid = 0x00002A60 + ncIdx
            Actor ncCreature = Game.GetFormFromFile(ncFid, "Vault13Chronicles.esp") as Actor
            if ncCreature != None && !ncCreature.IsDead()
                if avSpeedMult != None && ncCreature.GetValue(avSpeedMult) < 95.0
                    ncCreature.SetValue(avSpeedMult, 100.0)
                endif
                if ncFid == 0x00002A60 && ncCreature.GetPositionX() > 3050.0
                    ncCreature.SetPosition(2960.0, -3840.0, -900.0)
                elseif ncFid == 0x00002A61 && ncCreature.GetPositionX() > 2850.0
                    ncCreature.SetPosition(2720.0, -3880.0, -910.0)
                elseif ncFid == 0x00002A62 && ncCreature.GetPositionX() > 2600.0
                    ncCreature.SetPosition(2480.0, -3820.0, -935.0)
                elseif ncFid == 0x00002A63 && ncCreature.GetPositionX() > 2350.0
                    ncCreature.SetPosition(2220.0, -3800.0, -955.0)
                elseif ncFid == 0x00002A64 && (ncCreature.GetPositionX() < 1800.0 || ncCreature.GetPositionX() > 2100.0)
                    ncCreature.SetPosition(1920.0, -3772.0, -970.1)
                elseif ncFid == 0x00002A65 && (ncCreature.GetPositionZ() > -930.0 || ncCreature.GetPositionX() > 550.0)
                    ncCreature.SetPosition(380.0, -3780.0, -960.0)
                elseif ncFid == 0x00002A66 && ncCreature.GetPositionY() > -3350.0
                    ncCreature.SetPosition(-802.1, -3472.0, -498.5)
                elseif ncFid == 0x00002A6B && ncCreature.GetPositionX() < 150.0
                    ncCreature.SetPosition(232.0, 2760.0, -514.3)
                elseif ncFid == 0x00002A6D && ncCreature.GetPositionY() > 6800.0
                    ncCreature.SetPosition(120.0, 6500.0, 0.0)
                endif
                ncCreature.EvaluatePackage()
            endif
            ncIdx += 1
        endwhile
    endif

    bool holdCreaturesNow = ShouldHoldNecropolisCreatures(player)
    if holdCreaturesNow
        int holdIdx = 0
        while holdIdx < 14
            int holdFid = 0x00002A60 + holdIdx
            Actor holdNC = Game.GetFormFromFile(holdFid, "Vault13Chronicles.esp") as Actor
            if holdNC != None
                if !holdNC.IsDead()
                    if holdFid == 0x00002A60 && holdNC.GetPositionX() > 3050.0
                        holdNC.SetPosition(2960.0, -3840.0, -900.0)
                    elseif holdFid == 0x00002A61 && holdNC.GetPositionX() > 2850.0
                        holdNC.SetPosition(2720.0, -3880.0, -910.0)
                    elseif holdFid == 0x00002A62 && holdNC.GetPositionX() > 2600.0
                        holdNC.SetPosition(2480.0, -3820.0, -935.0)
                    elseif holdFid == 0x00002A63 && holdNC.GetPositionX() > 2350.0
                        holdNC.SetPosition(2220.0, -3800.0, -955.0)
                    endif
                    if holdNC.IsInCombat()
                        holdNC.StopCombat()
                    endif
                endif
                if !holdNC.IsDisabled()
                    holdNC.Disable(false)
                endif
            endif
            holdIdx += 1
        endwhile
        if player.IsInCombat()
            player.StopCombatAlarm()
        endif
        return
    endif

    int enIdx = 0
    while enIdx < 14
        int enFid = 0x00002A60 + enIdx
        Actor enNC = Game.GetFormFromFile(enFid, "Vault13Chronicles.esp") as Actor
        if enNC != None
            if enNC.IsDisabled()
                enNC.Enable(false)
                if !enNC.IsDead()
                    enNC.EvaluatePackage()
                endif
            endif
            if !enNC.IsDead() && enNC.GetPositionX() > 3800.0 && enNC.GetPositionY() < -3200.0
                enNC.StopCombat()
                enNC.SetPosition(2960.0, -3840.0, -900.0)
            endif
        endif
        enIdx += 1
    endwhile

    if (d2A01 != None && player.GetDistance(d2A01) < 380.0) || (d2A03 != None && player.GetDistance(d2A03) < 380.0) || (d2A05 != None && player.GetDistance(d2A05) < 380.0) || (ugLeader != None && player.GetDistance(ugLeader) < 520.0)
        int stopIdx = 0
        while stopIdx < 14
            Actor stopNC = Game.GetFormFromFile(0x00002A60 + stopIdx, "Vault13Chronicles.esp") as Actor
            if stopNC != None && !stopNC.IsDead() && stopNC.IsInCombat()
                stopNC.StopCombat()
            endif
            stopIdx += 1
        endwhile
        return
    endif

    if !player.IsSneaking() && !player.IsDead()
        float pz = player.GetPositionZ()
        int cIdx = 0
        while cIdx < 14
            Actor cEnemy = Game.GetFormFromFile(0x00002A60 + cIdx, "Vault13Chronicles.esp") as Actor
            if cEnemy != None && !cEnemy.IsDead() && !cEnemy.IsDisabled() && !cEnemy.IsInCombat() && cEnemy.Is3DLoaded()
                float cDist = player.GetDistance(cEnemy)
                if cDist < 950.0
                    float cdz = pz - cEnemy.GetPositionZ()
                    if cdz < 0.0
                        cdz = -cdz
                    endif
                    if cdz < 175.0 && (cDist < 420.0 || player.HasDetectionLOS(cEnemy) || cEnemy.HasDetectionLOS(player))
                        cEnemy.EvaluatePackage()
                        cEnemy.StartCombat(player)
                    endif
                endif
            endif
            cIdx += 1
        endwhile
    endif
EndFunction

Function GiveAct2CompletionRewards()
    if rewardsGiven
        return
    endif
    rewardsGiven = true
    Actor player = Game.GetPlayer()
    Form waterChip = Game.GetFormFromFile(0x00001112, "Vault13Chronicles.esp")
    Form pistol223 = Game.GetFormFromFile(0x00001105, "Vault13Chronicles.esp")
    Actor harry = Game.GetFormFromFile(0x00002A11, "Vault13Chronicles.esp") as Actor
    ObjectReference waterComp = Game.GetFormFromFile(0x00002A10, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference relicDisplay2 = Game.GetFormFromFile(0x00002032, "Vault13Chronicles.esp") as ObjectReference
    Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
    Form stimpak = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
    Form ammo44 = Game.GetFormFromFile(0x0009221C, "Fallout4.esm")

    if player != None
        if waterChip != None
            if player.GetItemCount(waterChip) > 0
                player.RemoveItem(waterChip, player.GetItemCount(waterChip), true, None)
            endif
            if waterComp != None && waterComp.GetItemCount(waterChip) > 0
                waterComp.RemoveItem(waterChip, waterComp.GetItemCount(waterChip), true, None)
            endif
        endif
        if pistol223 != None
            if player.GetItemCount(pistol223) == 0
                if harry != None && harry.GetItemCount(pistol223) > 0
                    harry.RemoveItem(pistol223, 1, true, player)
                else
                    player.AddItem(pistol223, 1, false)
                endif
            endif
            if harry != None && harry.GetItemCount(pistol223) > 0
                harry.RemoveItem(pistol223, harry.GetItemCount(pistol223), true, None)
            endif
            if player.GetItemCount(pistol223) > 1
                player.RemoveItem(pistol223, player.GetItemCount(pistol223) - 1, true, None)
            endif
        endif
        if caps != None
            player.AddItem(caps, 750, false)
        endif
        if stimpak != None
            player.AddItem(stimpak, 5, false)
        endif
        if ammo44 != None
            player.AddItem(ammo44, 60, false)
        endif
    endif

    if relicDisplay2 != None
        relicDisplay2.Enable(false)
    endif

    Game.RewardPlayerXP(600, false)
    Debug.Notification("[Crónicas del Refugio 13] ¡Chip de Agua del Refugio 12 instalado! ¡Pistola '.223' desbloqueada!")
EndFunction

Function ForceAllAct2Aliases()
    int curStage = GetEffectiveAct2Stage()
    bool markerChanged = false
    Actor player = Game.GetPlayer()
    Cell pCell = None
    if player != None
        pCell = player.GetParentCell()
    endif
    Cell hallCell = Game.GetFormFromFile(0x00002E00, "Vault13Chronicles.esp") as Cell
    Cell sewerCell = Game.GetFormFromFile(0x00002F00, "Vault13Chronicles.esp") as Cell
    Cell watershedCell = Game.GetFormFromFile(0x00002900, "Vault13Chronicles.esp") as Cell
    bool harryDone = IsHarryResolved()
    Form waterChipAlias = Game.GetFormFromFile(0x00001112, "Vault13Chronicles.esp")
    bool hasChipNow = waterChipExtracted || curStage >= 30 || waterChipInstalledInPlant || (player != None && waterChipAlias != None && player.GetItemCount(waterChipAlias) > 0)

    ForceQuestAlias(0, 0x00002110)

    ObjectReference m2907 = Game.GetFormFromFile(0x00002907, "Vault13Chronicles.esp") as ObjectReference
    if m2907 != None
        m2907.Enable(false)
        if harryDone
            if m2907.GetPositionX() < 0.0
                m2907.SetPosition(280.0, 860.0, 50.0)
                if pCell == watershedCell
                    markerChanged = true
                endif
            endif
        else
            if m2907.GetPositionX() > 0.0 || m2907.GetPositionX() < -300.0
                m2907.SetPosition(-265.0, 830.0, 75.0)
                if pCell == watershedCell
                    markerChanged = true
                endif
            endif
        endif
    endif

    int wshTargetFid = 0x00002907
    int wshExitFid = 0x00002901
    if hasChipNow
        wshTargetFid = 0x0000290B
        wshExitFid = 0x0000290B
    elseif harryDone
        wshTargetFid = 0x00002A10
    endif
    ForceQuestAlias(16, wshTargetFid)
    ForceQuestAlias(17, wshExitFid)

    ObjectReference d2F05Check = Game.GetFormFromFile(0x00002F05, "Vault13Chronicles.esp") as ObjectReference
    int sewTargetFid = 0x00002F22
    if d2F05Check != None && d2F05Check.IsLocked()
        if !sewerPasswordFound
            sewTargetFid = 0x00002F18
        else
            sewTargetFid = 0x00002F31
        endif
    endif
    int sewExitFid = 0x00002F01
    if pCell == sewerCell && player.GetPositionX() < 6800.0
        sewExitFid = 0x00002F03
    endif
    ForceQuestAlias(13, sewTargetFid)
    ForceQuestAlias(14, sewExitFid)

    ForceQuestAlias(11, 0x00002E11)
    int hodTargetFid = 0x00002E01
    if curStage < 24 && !necroPumpRepaired && !hasChipNow
        if curStage == 22 && garretIntroDone
            hodTargetFid = 0x00002E11
        else
            hodTargetFid = 0x00002E12
        endif
    endif
    if curStage < 24
        ForceQuestAlias(12, 0x00002E12)
    else
        ForceQuestAlias(12, 0x00002E01)
    endif

    ; Dynamically drive Alias 1 and Alias 7 (which exist in 100% of savegames and new games) based on the player's current cell:
    if pCell == watershedCell
        if ForceQuestAlias(1, wshTargetFid)
            markerChanged = true
        endif
        if ForceQuestAlias(7, wshExitFid)
            markerChanged = true
        endif
    elseif pCell == sewerCell
        int sewActiveFid = sewTargetFid
        if curStage >= 25 || necroPumpRepaired || hasChipNow
            sewActiveFid = sewExitFid
        endif
        if ForceQuestAlias(1, sewActiveFid)
            markerChanged = true
        endif
        if ForceQuestAlias(7, sewExitFid)
            markerChanged = true
        endif
    elseif pCell == hallCell
        if ForceQuestAlias(1, hodTargetFid)
            markerChanged = true
        endif
        if ForceQuestAlias(7, 0x00002E01)
            markerChanged = true
        endif
    else
        int necroTargetFid = 0x00002A34
        int necroExitFid = 0x00002A03
        if hasChipNow
            if player != None && player.GetPositionY() > 2000.0
                necroTargetFid = 0x00002A35
                necroExitFid = 0x00002A35
            else
                necroTargetFid = 0x00002A03
                necroExitFid = 0x00002A03
            endif
        elseif curStage < 21 && !necroPumpRepaired
            necroTargetFid = 0x00002A18
        elseif (curStage == 21 || curStage == 22) && !necroPumpRepaired
            necroTargetFid = 0x00002A05
        elseif (curStage == 23 || curStage == 24) && !necroPumpRepaired
            necroTargetFid = 0x00002A09
        elseif curStage == 25 && !necroPumpRepaired
            necroTargetFid = 0x00002A54
        endif
        if ForceQuestAlias(1, necroTargetFid)
            markerChanged = true
        endif
        if ForceQuestAlias(7, necroExitFid)
            markerChanged = true
        endif
    endif

    ForceQuestAlias(2, 0x00003005)
    ForceQuestAlias(3, 0x00002003)
    if curStage < 21 || (curStage == 25 && !necroPumpRepaired)
        if ForceQuestAlias(4, 0x00003503)
            markerChanged = true
        endif
    elseif curStage >= 21 && curStage <= 23
        if ForceQuestAlias(4, 0x00003504)
            markerChanged = true
        endif
    elseif curStage == 24
        if ForceQuestAlias(4, 0x00003505)
            markerChanged = true
        endif
    else
        if ForceQuestAlias(4, 0x00003506)
            markerChanged = true
        endif
    endif
    ForceQuestAlias(5, 0x00002142)
    ForceQuestAlias(6, 0x00003501)
    if ForceQuestAlias(9, 0x00002138)
        markerChanged = true
    endif
    if pCell == sewerCell
        ForceQuestAlias(10, 0x00002F18)
    elseif (pCell == watershedCell || curStage >= 26 || necroPumpRepaired) && !harryEvacuated && !harryCombatStarted && !harryCombatPending && !IsHarryResolved()
        ForceQuestAlias(10, 0x00002A11)
    elseif pCell == watershedCell
        ReferenceAlias al10Wsh = Self.GetAlias(10) as ReferenceAlias
        if al10Wsh != None && al10Wsh.GetReference() != None
            al10Wsh.Clear()
        endif
    else
        ForceQuestAlias(10, 0x00002A18)
    endif
    Scene theresaScnAlias = Game.GetFormFromFile(0x00005104, "Vault13Chronicles.esp") as Scene
    if !v13CrisisResolved || (theresaScnAlias != None && theresaScnAlias.IsPlaying())
        ForceQuestAlias(15, 0x00002153)
    else
        ReferenceAlias al15Th = Self.GetAlias(15) as ReferenceAlias
        if al15Th != None && al15Th.GetReference() != None
            al15Th.Clear()
            markerChanged = true
        endif
    endif
    if markerChanged
        RefreshDisplayedAct2Objective()
    endif
EndFunction

Function CompleteNecropolisSubObjectives()
    if !Self.IsObjectiveCompleted(15)
        Self.SetObjectiveCompleted(15, true)
    endif
    if Self.IsObjectiveDisplayed(18) && !Self.IsObjectiveCompleted(18)
        Self.SetObjectiveCompleted(18, true)
    endif
    if !Self.IsObjectiveCompleted(20)
        Self.SetObjectiveCompleted(20, true)
    endif
    if Self.IsObjectiveDisplayed(21) && !Self.IsObjectiveCompleted(21)
        Self.SetObjectiveCompleted(21, true)
    endif
    if Self.IsObjectiveDisplayed(22) && !Self.IsObjectiveCompleted(22)
        Self.SetObjectiveCompleted(22, true)
    endif
    if Self.IsObjectiveDisplayed(23) && !Self.IsObjectiveCompleted(23)
        Self.SetObjectiveCompleted(23, true)
    endif
    if Self.IsObjectiveDisplayed(24) && !Self.IsObjectiveCompleted(24)
        Self.SetObjectiveCompleted(24, true)
    endif
    if Self.IsObjectiveDisplayed(25) && !Self.IsObjectiveCompleted(25)
        Self.SetObjectiveCompleted(25, true)
    endif
    if Self.IsObjectiveDisplayed(26)
        if !Self.IsObjectiveCompleted(26)
            Self.SetObjectiveCompleted(26, true)
        endif
        Self.SetObjectiveDisplayed(26, false, false)
    endif
    if Self.IsObjectiveDisplayed(27)
        if !Self.IsObjectiveCompleted(27)
            Self.SetObjectiveCompleted(27, true)
        endif
        Self.SetObjectiveDisplayed(27, false, false)
    endif
    if Self.IsObjectiveDisplayed(28)
        if !Self.IsObjectiveCompleted(28)
            Self.SetObjectiveCompleted(28, true)
        endif
        Self.SetObjectiveDisplayed(28, false, false)
    endif
EndFunction

Function ApplyV13Act2Stage(int auiStage)
    if auiStage < 15 || bApplyingAct2Stage
        return
    endif
    bApplyingAct2Stage = true

    if auiStage == 23
        garretIntroDone = true
        if Self.GetStage() < 24
            Self.SetStage(24)
        endif
        auiStage = 24
    endif

    if (auiStage == 21 || auiStage == 22 || auiStage == 24 || auiStage == 25) && necroPumpRepaired
        if Self.GetStage() < 26
            Self.SetStage(26)
        endif
        auiStage = 26
    endif

    V13Act1QuestScript act1S = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as V13Act1QuestScript
    Scene ugScene = Game.GetFormFromFile(0x00005102, "Vault13Chronicles.esp") as Scene
    Scene setScene = Game.GetFormFromFile(0x00005103, "Vault13Chronicles.esp") as Scene
    Scene theresaScene = Game.GetFormFromFile(0x00005104, "Vault13Chronicles.esp") as Scene
    Scene garretScene1 = Game.GetFormFromFile(0x00005105, "Vault13Chronicles.esp") as Scene
    Scene garretScene2 = Game.GetFormFromFile(0x00005106, "Vault13Chronicles.esp") as Scene
    Scene ezequielScene = Game.GetFormFromFile(0x00005107, "Vault13Chronicles.esp") as Scene
    Scene harryScene = Game.GetFormFromFile(0x00005109, "Vault13Chronicles.esp") as Scene
    Scene harrySceneOld = Game.GetFormFromFile(0x00005108, "Vault13Chronicles.esp") as Scene
    Scene harrySceneWsh = Game.GetFormFromFile(0x0000510A, "Vault13Chronicles.esp") as Scene
    bool isHarryScenePlaying = (harryScene != None && harryScene.IsPlaying()) || (harrySceneOld != None && harrySceneOld.IsPlaying()) || (harrySceneWsh != None && harrySceneWsh.IsPlaying())
    Actor garretActor = Game.GetFormFromFile(0x00002E12, "Vault13Chronicles.esp") as Actor
    bool garretInDial = (garretScene1 != None && garretScene1.IsPlaying()) || (garretScene2 != None && garretScene2.IsPlaying()) || (garretActor != None && (garretActor.IsTalking() || garretActor.IsInDialogueWithPlayer()))
    bool inDial = (act1S != None && act1S.IsJacorenInDialogueOrScene()) || (ugScene != None && ugScene.IsPlaying()) || (setScene != None && setScene.IsPlaying()) || (theresaScene != None && theresaScene.IsPlaying()) || (ezequielScene != None && ezequielScene.IsPlaying()) || isHarryScenePlaying || garretInDial

    if auiStage >= 30
        waterChipExtracted = true
        chipExtractedNotified = true
        intercomResolved = true
    endif

    SyncVault13CrisisAndCelebrationActors()

    if auiStage >= 23
        ObjectReference armoryChestNow = Game.GetFormFromFile(0x00002E20, "Vault13Chronicles.esp") as ObjectReference
        if armoryChestNow != None
            armoryChestNow.SetLockLevel(0)
            armoryChestNow.Lock(false, false)
        endif
    endif

    if auiStage >= 20
        SetNecropolisState(true)
        ObjectReference necroMapMarker = Game.GetFormFromFile(0x00003414, "Vault13Chronicles.esp") as ObjectReference
        if necroMapMarker != None
            necroMapMarker.EnableNoWait()
            necroMapMarker.AddToMap(false)
        endif
        ObjectReference v12MapMarker = Game.GetFormFromFile(0x00003417, "Vault13Chronicles.esp") as ObjectReference
        if v12MapMarker != None
            v12MapMarker.EnableNoWait()
            v12MapMarker.AddToMap(false)
        endif
        if act1S != None
            act1S.SyncVault13ExpeditionDoors()
            act1S.UpdateSouthernCaliforniaMapMarkers()
        endif
    elseif act1S != None && auiStage != lastAppliedAct2Stage
        act1S.SyncVault13ExpeditionDoors()
    endif

    if auiStage >= 15 && !introShown
        introShown = true
    endif

    if auiStage == 20
        v13CrisisResolved = true
        GiveV13CrisisResolutionReward()
        if !Self.IsObjectiveCompleted(15)
            Self.SetObjectiveCompleted(15, true)
        endif
        if !Self.IsObjectiveCompleted(18)
            Self.SetObjectiveCompleted(18, true)
        endif
        if Self.IsObjectiveDisplayed(18)
            Self.SetObjectiveDisplayed(18, false, false)
        endif
        SyncVault13CrisisAndCelebrationActors()
        if act1S != None
            act1S.SyncVault13ExpeditionDoors()
        endif
        if savedNecroStageBeforeCrisis > 20
            int restoreStg = savedNecroStageBeforeCrisis
            savedNecroStageBeforeCrisis = 0
            if Self.GetStage() < restoreStg
                Self.SetStage(restoreStg)
            endif
            auiStage = restoreStg
            if (auiStage == 21 || auiStage == 22 || auiStage == 23 || auiStage == 24 || auiStage == 25) && necroPumpRepaired
                auiStage = 26
            elseif auiStage == 23
                auiStage = 24
            endif
        else
            EnsureSingleActiveObjective(20)
            if !Self.IsObjectiveDisplayed(20)
                Self.SetObjectiveDisplayed(20, true, false)
            endif
            Self.SetActive(true)
        endif
    endif

    if auiStage == 15
        EnsureSingleActiveObjective(15)
        ForceAllAct2Aliases()
    elseif auiStage == 18
        if !Self.IsObjectiveCompleted(15)
            Self.SetObjectiveCompleted(15, true)
        endif
        if Self.IsObjectiveDisplayed(20)
            Self.SetObjectiveDisplayed(20, false, false)
        endif
        if !Self.IsObjectiveDisplayed(18)
            Self.SetObjectiveDisplayed(18, true, false)
            Self.SetActive(true)
        endif
        ForceAllAct2Aliases()
        SyncVault13CrisisAndCelebrationActors()
        if act1S != None
            act1S.SyncVault13ExpeditionDoors()
        endif
    elseif auiStage == 20
        EnsureSingleActiveObjective(20)
        ForceAllAct2Aliases()
        if !Self.IsObjectiveDisplayed(20)
            Self.SetObjectiveDisplayed(20, true, false)
        endif
        RefreshDisplayedAct2Objective()
        Self.SetActive(true)
    elseif auiStage == 21
        if !Self.IsObjectiveCompleted(15)
            Self.SetObjectiveCompleted(15, true)
        endif
        if !Self.IsObjectiveCompleted(20)
            Self.SetObjectiveCompleted(20, true)
        endif
        if !Self.IsObjectiveDisplayed(21)
            Self.SetObjectiveDisplayed(21, true, false)
            Self.SetActive(true)
        endif
        ForceAllAct2Aliases()
    elseif auiStage == 22
        if !Self.IsObjectiveCompleted(15)
            Self.SetObjectiveCompleted(15, true)
        endif
        if !Self.IsObjectiveCompleted(20)
            Self.SetObjectiveCompleted(20, true)
        endif
        if Self.IsObjectiveDisplayed(21) || garretInDial || garretIntroSceneStarted
            garretIntroDone = true
        endif
        if !garretIntroDone && !Self.IsObjectiveCompleted(21)
            if Self.IsObjectiveDisplayed(22)
                Self.SetObjectiveDisplayed(22, false, false)
            endif
            if !Self.IsObjectiveDisplayed(21)
                Self.SetObjectiveDisplayed(21, true, false)
                Self.SetActive(true)
            endif
        else
            garretIntroDone = true
            if !Self.IsObjectiveCompleted(21)
                Self.SetObjectiveCompleted(21, true)
            endif
            if !Self.IsObjectiveDisplayed(22)
                Self.SetObjectiveDisplayed(22, true, false)
                Self.SetActive(true)
            endif
        endif
        ForceAllAct2Aliases()
    elseif auiStage == 24
        garretIntroDone = true
        Actor player24 = Game.GetPlayer()
        Form pumpParts24 = Game.GetFormFromFile(0x0000111D, "Vault13Chronicles.esp")
        if pumpPartsRecovered || (player24 != None && pumpParts24 != None && player24.GetItemCount(pumpParts24) > 0)
            bApplyingAct2Stage = false
            OnPumpPartsRecovered()
            return
        endif
        if !garretArmoryUnlockedNotified
            garretArmoryUnlockedNotified = true
            Debug.Notification("[La Sala de los Muertos] ¡Garret ha desbloqueado el Baúl de Armería de Set! Recoge los suministros y sal hacia las alcantarillas.")
        endif
        EnsureSingleActiveObjective(24)
        ForceAllAct2Aliases()
        ObjectReference armoryChest24 = Game.GetFormFromFile(0x00002E20, "Vault13Chronicles.esp") as ObjectReference
        if armoryChest24 != None
            if armoryChest24.IsDisabled()
                armoryChest24.Enable(false)
            endif
            if armoryChest24.IsLocked()
                armoryChest24.Lock(false, false)
            endif
        endif
    elseif auiStage == 25
        garretIntroDone = true
        pumpPartsRecovered = true
        pumpPartsNotified = true
        EnsureSingleActiveObjective(25)
        ForceAllAct2Aliases()
        ObjectReference armoryChest25 = Game.GetFormFromFile(0x00002E20, "Vault13Chronicles.esp") as ObjectReference
        if armoryChest25 != None
            if armoryChest25.IsDisabled()
                armoryChest25.Enable(false)
            endif
            armoryChest25.Lock(false, false)
        endif
    elseif auiStage >= 26 && auiStage < 30
        garretIntroDone = true
        ObjectReference armoryChest26 = Game.GetFormFromFile(0x00002E20, "Vault13Chronicles.esp") as ObjectReference
        if armoryChest26 != None
            armoryChest26.Enable(false)
            armoryChest26.Lock(false, false)
        endif
        Actor harry26 = Game.GetFormFromFile(0x00002A11, "Vault13Chronicles.esp") as Actor
        if auiStage == 26
            if IsHarryResolved()
                EnsureSingleActiveObjective(27)
            else
                EnsureSingleActiveObjective(26)
            endif
        elseif auiStage == 27
            harrySceneOutcome = 1
            harryCombatPending = false
            EnsureSingleActiveObjective(27)
            ResolveHarryIntercom()
            if isHarryScenePlaying || (harry26 != None && (harry26.IsTalking() || harry26.IsInDialogueWithPlayer()))
                harryEvacPending = true
                harryCombatWaitTicks = 0
                StartTimer(0.2, 7)
            else
                BeginHarryEvacuationWalk()
            endif
        elseif auiStage == 28
            if IsHarryResolved()
                EnsureSingleActiveObjective(27)
                ResolveHarryIntercom()
            else
                harrySceneOutcome = 2
                intercomResolved = false
                harryEvacPending = false
                SyncHarryPatrolFactions(true)
                EnsureSingleActiveObjective(28)
                if isHarryScenePlaying || (harry26 != None && (harry26.IsTalking() || harry26.IsInDialogueWithPlayer()))
                    harryCombatPending = true
                    harryCombatWaitTicks = 0
                    StartTimer(0.2, 7)
                else
                    StartHarryCombat()
                endif
            endif
        endif
        SyncVault12InnerChamberState()
        ForceAllAct2Aliases()
    elseif auiStage == 30
        waterChipExtracted = true
        chipExtractedNotified = true
        intercomResolved = true
        SyncVault12InnerChamberState()
        CompleteNecropolisSubObjectives()
        ForceAllAct2Aliases()
        EnsureSingleActiveObjective(30)
        RefreshDisplayedAct2Objective()
        if !waterPlantStateApplied
            SetWaterPlantState(false)
        endif
        if Self.GetStage() < 30
            SanitizeLegacyQuestStage(30)
        endif
    elseif auiStage == 35
        waterChipExtracted = true
        chipExtractedNotified = true
        SanitizeLegacyQuestStage(35)
        CompleteNecropolisSubObjectives()
        EnsureSingleActiveObjective(35)
        StartWaterPlantWalkSequence()
        ForceAllAct2Aliases()
        RefreshDisplayedAct2Objective()
    elseif auiStage == 38
        waterChipExtracted = true
        chipExtractedNotified = true
        waterChipInstalledInPlant = true
        SanitizeLegacyQuestStage(38)
        SetWaterPlantState(true)
        CompleteNecropolisSubObjectives()
        EnsureSingleActiveObjective(38)
        ForceAllAct2Aliases()
        RefreshDisplayedAct2Objective()
    elseif auiStage == 40 || auiStage == 45
        if inDial && auiStage < 45
            bApplyingAct2Stage = false
            StartTimer(0.5, 9)
            StartTimer(0.5, 1)
            return
        endif
        waterChipInstalledInPlant = true
        SetWaterPlantState(true)
        GiveAct2CompletionRewards()
        CompleteNecropolisSubObjectives()
        if !Self.IsObjectiveCompleted(30)
            Self.SetObjectiveCompleted(30, true)
        endif
        if !Self.IsObjectiveCompleted(35)
            Self.SetObjectiveCompleted(35, true)
        endif
        if !Self.IsObjectiveCompleted(38)
            Self.SetObjectiveCompleted(38, true)
        endif
        if !Self.IsCompleted()
            Self.CompleteAllObjectives()
            Self.CompleteQuest()
        endif
        if (!part1EndShown || !part1EndCardShownV2) && !bShowingPart1End
            bShowingPart1End = true
            if !Utility.IsInMenuMode()
                part1EndShown = true
                part1EndCardShownV2 = true
                Message part1EndMsg = Game.GetFormFromFile(0x00001450, "Vault13Chronicles.esp") as Message
                if part1EndMsg == None
                    part1EndMsg = Game.GetFormFromFile(0x00001152, "Vault13Chronicles.esp") as Message
                endif
                if part1EndMsg != None
                    Actor playerEnd = Game.GetPlayer()
                    Sound sfxEndCheer = Game.GetFormFromFile(0x00001061, "Vault13Chronicles.esp") as Sound
                    if sfxEndCheer != None && playerEnd != None
                        sfxEndCheer.Play(playerEnd)
                    endif
                    int endChoice = part1EndMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
                    if endChoice == 1
                        ObjectReference mnemoDest = Game.GetFormFromFile(0x00002002, "Vault13Chronicles.esp") as ObjectReference
                        if playerEnd != None && mnemoDest != None
                            playerEnd.MoveTo(mnemoDest, 0.0, 0.0, 0.0, true)
                            Debug.Notification("[Archivo Mnemosyne - 2287] Has regresado a la Commonwealth con el equipo y las reliquias de 2161.")
                        endif
                    else
                        Debug.Notification("[Refugio 13] La Puerta Dimensional/Temporal en el Despacho del Supervisor queda abierta para regresar a la Commonwealth cuando quieras.")
                    endif
                else
                    part1EndShown = false
                    part1EndCardShownV2 = false
                endif
            endif
            bShowingPart1End = false
        endif
        StartTimer(0.2, 1)
    endif
    lastAppliedAct2Stage = auiStage
    ForceAllAct2Aliases()
    RefreshDisplayedAct2Objective()
    StartTimer(0.15, 12)
    bApplyingAct2Stage = false
EndFunction

Function WakeUpAct2()
    if !Self.IsRunning()
        Self.Start()
    endif
    RegisterPlayerEvents()
    CheckProgressionAndLevelGate()
    StartTimer(0.2, 1)
EndFunction

Function CheckProgressionAndLevelGate()
    if isExecutingCheckpointJump || pendingCheckpointJump != 0
        return
    endif
    Actor player = Game.GetPlayer()
    if player == None
        return
    endif

    Cell v13CellSync = Game.GetFormFromFile(0x00002100, "Vault13Chronicles.esp") as Cell
    Cell playerCellSync = player.GetParentCell()
    if playerCellSync != None && playerCellSync == v13CellSync
        V13Act1QuestScript act1DoorSync = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as V13Act1QuestScript
        if act1DoorSync != None
            act1DoorSync.SyncVault13ExpeditionDoors()
        endif
    endif

    int curStage = GetEffectiveAct2Stage()

    if curStage < 15
        Quest act1Quest = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as Quest
        if act1Quest != None && act1Quest.GetStage() >= 40
            Scene act1RetScene = Game.GetFormFromFile(0x00004101, "Vault13Chronicles.esp") as Scene
            if act1RetScene != None && act1RetScene.IsPlaying()
                act1RetScene.Stop()
            endif
            if !Self.IsRunning()
                Self.Start()
            endif
            Self.SetStage(15)
            ApplyV13Act2Stage(15)
            return
        endif
        return
    endif

    if curStage >= 15 && !introShown
        introShown = true
    endif

    Form waterChip = Game.GetFormFromFile(0x00001112, "Vault13Chronicles.esp")
    if !waterChipInstalledInPlant && waterChip != None && player.GetItemCount(waterChip) > 0
        if !waterChipExtracted || Self.IsObjectiveDisplayed(26) || Self.IsObjectiveDisplayed(27) || Self.IsObjectiveDisplayed(28) || (curStage == 30 && (!Self.IsObjectiveDisplayed(30) || Self.IsObjectiveCompleted(30)))
            OnWaterChipExtracted()
            return
        endif
    endif

    if curStage >= 20 && curStage < 30
        Form pumpParts = Game.GetFormFromFile(0x0000111D, "Vault13Chronicles.esp")
        if (curStage == 23 || curStage == 24) && !necroPumpRepaired && (pumpPartsRecovered || (pumpParts != None && player.GetItemCount(pumpParts) > 0))
            OnPumpPartsRecovered()
            return
        endif
    endif

    V13Act1QuestScript act1S = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as V13Act1QuestScript
    Scene ugScene = Game.GetFormFromFile(0x00005102, "Vault13Chronicles.esp") as Scene
    Scene setScene = Game.GetFormFromFile(0x00005103, "Vault13Chronicles.esp") as Scene
    Scene theresaScene = Game.GetFormFromFile(0x00005104, "Vault13Chronicles.esp") as Scene
    Scene garretScene1 = Game.GetFormFromFile(0x00005105, "Vault13Chronicles.esp") as Scene
    Scene garretScene2 = Game.GetFormFromFile(0x00005106, "Vault13Chronicles.esp") as Scene
    if curStage == 35 && !waterChipInstalledInPlant
        UpdateWaterPlantSequence()
    endif
    if (act1S != None && act1S.IsJacorenInDialogueOrScene()) || (ugScene != None && ugScene.IsPlaying()) || (setScene != None && setScene.IsPlaying()) || (theresaScene != None && theresaScene.IsPlaying()) || (garretScene1 != None && garretScene1.IsPlaying()) || (garretScene2 != None && garretScene2.IsPlaying())
        return
    endif

    UpdateNecropolisRouteAndCombat()
    UpdateWaterPlantSequence()
    WorldSpace ws2161 = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if act1S != None && ws2161 != None && player.GetWorldSpace() == ws2161
        act1S.UpdateSouthernCaliforniaMapMarkers()
        act1S.SyncWorldMap2161()
    endif

    curStage = GetEffectiveAct2Stage()
    if (curStage == 15 && (!Self.IsObjectiveDisplayed(15) || Self.IsObjectiveCompleted(15))) || (curStage == 18 && (!Self.IsObjectiveDisplayed(18) || Self.IsObjectiveCompleted(18))) || (curStage == 20 && (!Self.IsObjectiveDisplayed(20) || Self.IsObjectiveCompleted(20))) || (curStage == 21 && (!Self.IsObjectiveDisplayed(21) || Self.IsObjectiveCompleted(21))) || (curStage == 22 && ((!garretIntroDone && (!Self.IsObjectiveDisplayed(21) || Self.IsObjectiveCompleted(21))) || (garretIntroDone && (!Self.IsObjectiveDisplayed(22) || Self.IsObjectiveCompleted(22))))) || (curStage == 23 && (!Self.IsObjectiveDisplayed(23) || Self.IsObjectiveCompleted(23))) || (curStage == 24 && (!Self.IsObjectiveDisplayed(24) || Self.IsObjectiveCompleted(24))) || (curStage == 25 && (!Self.IsObjectiveDisplayed(25) || Self.IsObjectiveCompleted(25))) || (curStage == 26 && (!Self.IsObjectiveDisplayed(26) || Self.IsObjectiveCompleted(26)) && !IsHarryResolved()) || (curStage == 27 && (!Self.IsObjectiveDisplayed(27) || Self.IsObjectiveCompleted(27))) || (curStage == 28 && (!Self.IsObjectiveDisplayed(28) || Self.IsObjectiveCompleted(28)) && !IsHarryResolved()) || (curStage == 30 && (!Self.IsObjectiveDisplayed(30) || Self.IsObjectiveCompleted(30))) || (curStage == 35 && (!Self.IsObjectiveDisplayed(35) || Self.IsObjectiveCompleted(35))) || (curStage == 38 && (!Self.IsObjectiveDisplayed(38) || Self.IsObjectiveCompleted(38))) || (curStage >= 40 && (!rewardsGiven || !Self.IsCompleted() || !part1EndShown || !part1EndCardShownV2))
        ApplyV13Act2Stage(curStage)
    endif
EndFunction

Function EnsureGarretVendorReady(Actor akGarret)
    if akGarret == None
        return
    endif
    Faction vFact = Game.GetFormFromFile(0x00001C55, "Vault13Chronicles.esp") as Faction
    if vFact != None && !akGarret.IsInFaction(vFact)
        akGarret.AddToFaction(vFact)
    endif
    ObjectReference vChest = Game.GetFormFromFile(0x00002E25, "Vault13Chronicles.esp") as ObjectReference
    Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
    if vChest != None
        if vChest.IsDisabled()
            vChest.EnableNoWait()
        endif
        if caps != None && vChest.GetItemCount(caps) < 400
            vChest.AddItem(caps, 1400, True)
            Form radaway = Game.GetFormFromFile(0x00023742, "Fallout4.esm")
            Form radx = Game.GetFormFromFile(0x00024057, "Fallout4.esm")
            Form stim = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
            Form water = Game.GetFormFromFile(0x000366C0, "Fallout4.esm")
            Form a10 = Game.GetFormFromFile(0x0001F276, "Fallout4.esm")
            Form aShell = Game.GetFormFromFile(0x0001F673, "Fallout4.esm")
            Form a308 = Game.GetFormFromFile(0x0001F66B, "Fallout4.esm")
            Form aFusion = Game.GetFormFromFile(0x000C1897, "Fallout4.esm")
            Form wShot = Game.GetFormFromFile(0x0014831C, "Fallout4.esm")
            if radaway != None && vChest.GetItemCount(radaway) < 6
                vChest.AddItem(radaway, 16, True)
            endif
            if radx != None && vChest.GetItemCount(radx) < 6
                vChest.AddItem(radx, 16, True)
            endif
            if stim != None && vChest.GetItemCount(stim) < 6
                vChest.AddItem(stim, 15, True)
            endif
            if water != None && vChest.GetItemCount(water) < 6
                vChest.AddItem(water, 15, True)
            endif
            if a10 != None && vChest.GetItemCount(a10) < 40
                vChest.AddItem(a10, 100, True)
            endif
            if aShell != None && vChest.GetItemCount(aShell) < 30
                vChest.AddItem(aShell, 72, True)
            endif
            if a308 != None && vChest.GetItemCount(a308) < 30
                vChest.AddItem(a308, 72, True)
            endif
            if aFusion != None && vChest.GetItemCount(aFusion) < 30
                vChest.AddItem(aFusion, 80, True)
            endif
            if wShot != None && vChest.GetItemCount(wShot) == 0
                vChest.AddItem(wShot, 1, True)
            endif
        endif
    endif
EndFunction

Function OpenGarretBarter(Actor akGarret)
    if akGarret == None || akGarret.IsDead()
        return
    endif
    EnsureGarretVendorReady(akGarret)
    Utility.Wait(0.15)
    akGarret.ShowBarterMenu()
EndFunction

Function ProcessPistol223Hit(Actor akTarget, Actor akCaster)
    if akTarget == None || akCaster == None
        return
    endif

    EffectShader shockFX = Game.GetFormFromFile(0x0006F122, "Fallout4.esm") as EffectShader
    if shockFX != None
        shockFX.Play(akTarget, 2.0)
    endif

    Actor player = Game.GetPlayer()
    if akCaster == player
        hitCounter += 1
        if hitCounter >= 3 || akTarget.IsDead()
            hitCounter = 0
            ActorValue apAV = Game.GetFormFromFile(0x000002D5, "Fallout4.esm") as ActorValue
            ActorValue hpAV = Game.GetFormFromFile(0x000002D4, "Fallout4.esm") as ActorValue
            if apAV != None
                player.RestoreValue(apAV, 30.0)
            endif
            if hpAV != None
                player.RestoreValue(hpAV, 15.0)
            endif
            EffectShader constFX = Game.GetFormFromFile(0x002494E4, "Fallout4.esm") as EffectShader
            if constFX != None
                constFX.Play(player, 1.2)
            endif
            Debug.Notification("[Pistola .223] ¡Impacto perforante! (+30 PA / +15 PV)")
        endif
    endif
EndFunction

Event OnInit()
    RegisterPlayerEvents()
    CheckProgressionAndLevelGate()
    StartTimer(2.5, 1)
EndEvent

Event OnQuestInit()
    RegisterPlayerEvents()
    CheckProgressionAndLevelGate()
    StartTimer(2.5, 1)
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
    bApplyingAct2Stage = false
    bResolvingHarry = false
    bShowingPart1End = false
    bPumpPromptQueued = false
    bPumpMissingPartsHold = false
    bWaterPlantPromptBusy = false
    HealNecropolisStateFromCellAndInventory()
    Actor pLoad = Game.GetPlayer()
    Form chipLoad = Game.GetFormFromFile(0x00001112, "Vault13Chronicles.esp")
    bool hasChipInInv = (pLoad != None && chipLoad != None && pLoad.GetItemCount(chipLoad) > 0)
    if !IsHarryResolved() && !hasChipInInv
        waterChipExtracted = false
        chipExtractedNotified = false
    endif
    if !waterChipExtracted && (waterChipInstalledInPlant || rewardsGiven || part1EndShown || part1EndCardShownV2 || Self.GetStage() >= 30 || Self.IsCompleted())
        waterChipInstalledInPlant = false
        rewardsGiven = false
        part1EndShown = false
        part1EndCardShownV2 = false
        jacorenFinaleTriggered = false
        waterPlantWalkActive = false
    endif
    necroCellRefreshed = false
    harryPatrolRefreshedV4 = false
    harrySceneStarted = false
    harryDialogueMenuOpen = false
    RegisterPlayerEvents()
    int effLoadStg = GetEffectiveAct2Stage()
    if effLoadStg >= 15 && effLoadStg < 40
        ApplyV13Act2Stage(effLoadStg)
    endif
    ForceAllAct2Aliases()
    CheckProgressionAndLevelGate()
    StartTimer(2.5, 1)
EndEvent

Event Actor.OnItemEquipped(Actor akSender, Form akBaseObject, ObjectReference akReference)
    Form pistol223 = Game.GetFormFromFile(0x00001105, "Vault13Chronicles.esp")
    if akBaseObject == pistol223 && pistol223 != None
        Debug.Notification("[Pistola .223 - 2161] Revólver de rifle recortado activo: Derribo cada 3 impactos (+30 PA / +15 PV)")
    endif
EndEvent

Event ObjectReference.OnItemAdded(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    if akBaseItem == None
        return
    endif
    Form waterChip = Game.GetFormFromFile(0x00001112, "Vault13Chronicles.esp")
    Form pumpParts = Game.GetFormFromFile(0x0000111D, "Vault13Chronicles.esp")
    if waterChip != None && akBaseItem == waterChip && !waterChipInstalledInPlant
        OnWaterChipExtracted()
    elseif pumpParts != None && akBaseItem == pumpParts && !necroPumpRepaired
        OnPumpPartsRecovered()
    endif
EndEvent

Event ObjectReference.OnItemRemoved(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
    Actor player = Game.GetPlayer()
    if akDestContainer != player
        return
    endif
    ObjectReference waterCompObj = Game.GetFormFromFile(0x00002A10, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference sewPartsBoxObj = Game.GetFormFromFile(0x00002F22, "Vault13Chronicles.esp") as ObjectReference
    Form waterChip = Game.GetFormFromFile(0x00001112, "Vault13Chronicles.esp")
    Form pumpParts = Game.GetFormFromFile(0x0000111D, "Vault13Chronicles.esp")
    if (waterCompObj != None && akSender == waterCompObj) || (waterChip != None && akBaseItem == waterChip)
        if !waterChipInstalledInPlant
            OnWaterChipExtracted()
        endif
    elseif (sewPartsBoxObj != None && akSender == sewPartsBoxObj) || (pumpParts != None && akBaseItem == pumpParts)
        if !necroPumpRepaired
            OnPumpPartsRecovered()
        endif
    endif
EndEvent

Event Actor.OnDeath(Actor akSender, Actor akKiller)
    if !intercomResolved && IsHarryResolved()
        ResolveHarryIntercom()
    endif
EndEvent

Event OnHit(ObjectReference akTarget, ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked, string apMaterial)
    Actor player = Game.GetPlayer()
    if !harryCombatStarted && !intercomResolved && !harryEvacuated && !harryEvacWalkStarted && !harryEvacPending
        if akAggressor == player || (akAggressor as Actor) != None
            if GetEffectiveAct2Stage() < 28
                Self.SetStage(28)
            endif
            StartHarryCombat()
        endif
    endif
    if akTarget != None
        RegisterForHitEvent(akTarget, None, None, None, -1, -1, -1, -1, true)
    endif
EndEvent

Event Terminal.OnMenuItemRun(Terminal akSender, int auiMenuItemID, ObjectReference akTerminalRef)
    if akSender == None
        return
    endif
    Terminal wpTermBase = Game.GetFormFromFile(0x00001182, "Vault13Chronicles.esp") as Terminal
    Terminal pumpTermBase = Game.GetFormFromFile(0x00001183, "Vault13Chronicles.esp") as Terminal
    if wpTermBase != None && akSender == wpTermBase && auiMenuItemID == 2
        OnWaterPlantTerminalInstallSelected()
    elseif pumpTermBase != None && akSender == pumpTermBase && auiMenuItemID == 2
        RepairNecropolisWaterPump()
    endif
EndEvent

Event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
    Actor player = Game.GetPlayer()
    if akSender == None || akActionRef != player
        return
    endif
    ObjectReference ezequielObj = Game.GetFormFromFile(0x00002F18, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference garretObj = Game.GetFormFromFile(0x00002E12, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference harryObj = Game.GetFormFromFile(0x00002A11, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference jacorenObj = Game.GetFormFromFile(0x00002110, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference wpConsoleObj = Game.GetFormFromFile(0x00002138, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference pumpConsoleObj = Game.GetFormFromFile(0x00002A54, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference waterCompObj = Game.GetFormFromFile(0x00002A10, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference sewPartsBoxObj = Game.GetFormFromFile(0x00002F22, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference d2A34Obj = Game.GetFormFromFile(0x00002A34, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference d2A35Obj = Game.GetFormFromFile(0x00002A35, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference d2901Obj = Game.GetFormFromFile(0x00002901, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference d290AObj = Game.GetFormFromFile(0x0000290A, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference d290BObj = Game.GetFormFromFile(0x0000290B, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference d2F03Obj = Game.GetFormFromFile(0x00002F03, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference d2F04Obj = Game.GetFormFromFile(0x00002F04, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference ghoulPrisonerObj = Game.GetFormFromFile(0x00002918, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference ugLeaderObj = Game.GetFormFromFile(0x00002A18, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference setObj = Game.GetFormFromFile(0x00002E11, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference v13ExitDoor42Obj = Game.GetFormFromFile(0x00002142, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference v13ExitDoor01Obj = Game.GetFormFromFile(0x00002101, "Vault13Chronicles.esp") as ObjectReference
    int stgNow = GetEffectiveAct2Stage()
    if (v13ExitDoor42Obj != None && akSender == v13ExitDoor42Obj) || (v13ExitDoor01Obj != None && akSender == v13ExitDoor01Obj)
        if stgNow >= 20 && stgNow < 40
            SetNecropolisState(true)
            StartTimer(0.15, 12)
        endif
        return
    endif
    if wpConsoleObj != None && akSender == wpConsoleObj
        OnWaterPlantConsoleActivated()
    elseif pumpConsoleObj != None && akSender == pumpConsoleObj
        OnWaterPumpActivated()
    elseif waterCompObj != None && akSender == waterCompObj
        if !waterChipInstalledInPlant && (IsHarryResolved() || !waterCompObj.IsLocked())
            OnWaterChipExtracted()
        endif
    elseif sewPartsBoxObj != None && akSender == sewPartsBoxObj
        if !necroPumpRepaired
            OnPumpPartsRecovered()
        endif
    elseif jacorenObj != None && akSender == jacorenObj
        if (stgNow == 30 || waterChipExtracted) && !waterPlantWalkActive && !waterChipInstalledInPlant
            StartTimer(0.25, 9)
        elseif (stgNow >= 38 || waterChipInstalledInPlant) && (!rewardsGiven || !part1EndShown || !part1EndCardShownV2)
            celebrationStep = 4
            if !jacorenFinaleTriggered
                jacorenFinaleTriggered = true
                Scene retSceneAct = Game.GetFormFromFile(0x00005101, "Vault13Chronicles.esp") as Scene
                if retSceneAct != None && !retSceneAct.IsPlaying()
                    retSceneAct.Start()
                endif
            endif
            StartTimer(1.0, 9)
        endif
    elseif ezequielObj != None && akSender == ezequielObj
        NotifySewerForemanTerminalRead()
    elseif garretObj != None && akSender == garretObj
        if !garretIntroDone && (stgNow == 21 || stgNow == 22)
            garretIntroSceneStarted = true
            garretIntroDone = true
            EnsureSingleActiveObjective(22)
            ForceAllAct2Aliases()
            if stgNow < 22
                Self.SetStage(22)
            endif
        elseif stgNow == 23
            garretIntroDone = true
            if !garretArmoryUnlockedNotified
                garretArmoryUnlockedNotified = true
                Debug.Notification("[La Sala de los Muertos] ¡Garret ha desbloqueado el Baúl de Armería de Set! Recoge los suministros y sal hacia las alcantarillas.")
            endif
            EnsureSingleActiveObjective(24)
            ForceAllAct2Aliases()
            ObjectReference armoryChestAct = Game.GetFormFromFile(0x00002E20, "Vault13Chronicles.esp") as ObjectReference
            if armoryChestAct != None
                armoryChestAct.SetLockLevel(0)
                armoryChestAct.Lock(false, false)
            endif
            Self.SetStage(24)
        else
            Message barterMsg = Game.GetFormFromFile(0x00001C75, "Vault13Chronicles.esp") as Message
            if barterMsg != None
                int choice = barterMsg.Show()
                if choice == 0
                    OpenGarretBarter(garretObj as Actor)
                    return
                elseif choice == 2
                    return
                endif
            endif
            Topic gHello = Game.GetFormFromFile(0x00005001, "Vault13Chronicles.esp") as Topic
            if gHello != None && (garretObj as Actor) != None && !(garretObj as Actor).IsTalking()
                (garretObj as Actor).Say(gHello, None, false, None)
            endif
        endif
        StartTimer(0.2, 1)
    elseif harryObj != None && akSender == harryObj
        if stgNow < 26
            Self.SetStage(26)
        endif
        ForceQuestAlias(10, 0x00002A11)
    elseif d2A34Obj != None && akSender == d2A34Obj
        if !necroPumpRepaired && stgNow < 26
            Debug.Notification("[Cuenca de Necrópolis] Repara primero la Gran Bomba de Agua aquí fuera (junto a la consola de control) antes de entrar en la Estación de Purificación.")
            return
        endif
        StartTimer(0.15, 5)
    elseif d290AObj != None && akSender == d290AObj
        if !IsHarryResolved()
            Debug.Notification("[Estación del Refugio 12] Los supermutantes Harry, Barry y Sally bloquean el paso. Habla con Harry o derrota a su patrulla para abrir la cámara del procesador.")
        endif
    elseif d290BObj != None && akSender == d290BObj
        Form waterChipExit = Game.GetFormFromFile(0x00001112, "Vault13Chronicles.esp")
        bool hasChipExit = waterChipExtracted || waterChipInstalledInPlant || stgNow >= 30 || (waterChipExit != None && player.GetItemCount(waterChipExit) > 0)
        if !IsHarryResolved() || !hasChipExit
            Debug.Notification("[Estación del Refugio 12] Extrae primero el Chip de Purificación de Agua de la Computadora del Refugio 12 antes de subir a la superficie.")
            return
        endif
        StartTimer(0.35, 6)
    elseif d2A35Obj != None && akSender == d2A35Obj
        StartTimer(0.35, 6)
    elseif d2901Obj != None && akSender == d2901Obj
        StartTimer(0.25, 1)
    elseif (d2F03Obj != None && akSender == d2F03Obj) || (d2F04Obj != None && akSender == d2F04Obj)
        StartTimer(0.3, 10)
    elseif ghoulPrisonerObj != None && akSender == ghoulPrisonerObj
        if IsHarryResolved()
            RewardWatershedPrisonerLiberation()
        endif
    elseif (ugLeaderObj != None && akSender == ugLeaderObj) || (setObj != None && akSender == setObj)
        if (waterChipExtracted || stgNow >= 30) && necroPumpRepaired
            RewardNecropolisWaterDilemma()
        endif
    endif
EndEvent

Event Scene.OnBegin(Scene akSender)
    Scene harryScene = Game.GetFormFromFile(0x00005109, "Vault13Chronicles.esp") as Scene
    Scene harrySceneOld = Game.GetFormFromFile(0x00005108, "Vault13Chronicles.esp") as Scene
    Scene harrySceneWsh = Game.GetFormFromFile(0x0000510A, "Vault13Chronicles.esp") as Scene
    if (harryScene != None && akSender == harryScene) || (harrySceneOld != None && akSender == harrySceneOld) || (harrySceneWsh != None && akSender == harrySceneWsh)
        harrySceneStarted = true
    endif
EndEvent

Event Scene.OnPhaseBegin(Scene akSender, int auiPhaseIndex)
    Scene harryScene = Game.GetFormFromFile(0x00005109, "Vault13Chronicles.esp") as Scene
    Scene harrySceneOld = Game.GetFormFromFile(0x00005108, "Vault13Chronicles.esp") as Scene
    Scene harrySceneWsh = Game.GetFormFromFile(0x0000510A, "Vault13Chronicles.esp") as Scene
    if (harryScene != None && akSender == harryScene) || (harrySceneOld != None && akSender == harrySceneOld) || (harrySceneWsh != None && akSender == harrySceneWsh)
        if auiPhaseIndex == 2
            harrySceneOutcome = 1
            harryEvacPending = true
            harryCombatWaitTicks = 0
            if GetEffectiveAct2Stage() < 27
                Self.SetStage(27)
            endif
            StartTimer(0.2, 7)
        elseif auiPhaseIndex == 3
            harrySceneOutcome = 2
            harryCombatPending = true
            harryCombatWaitTicks = 0
            SyncHarryPatrolFactions(true)
            if GetEffectiveAct2Stage() < 28
                Self.SetStage(28)
            endif
            StartTimer(0.2, 7)
        endif
    endif
EndEvent

Event Scene.OnEnd(Scene akSender)
    Scene harryScene = Game.GetFormFromFile(0x00005109, "Vault13Chronicles.esp") as Scene
    Scene harrySceneOld = Game.GetFormFromFile(0x00005108, "Vault13Chronicles.esp") as Scene
    Scene harrySceneWsh = Game.GetFormFromFile(0x0000510A, "Vault13Chronicles.esp") as Scene
    Scene act2RetScene = Game.GetFormFromFile(0x00005101, "Vault13Chronicles.esp") as Scene
    Scene theresaScene = Game.GetFormFromFile(0x00005104, "Vault13Chronicles.esp") as Scene
    if (harryScene != None && akSender == harryScene) || (harrySceneOld != None && akSender == harrySceneOld) || (harrySceneWsh != None && akSender == harrySceneWsh)
        harrySceneStarted = false
        harryDialogueMenuOpen = false
        if harrySceneOutcome == 1 || harryEvacPending
            BeginHarryEvacuationWalk()
        elseif harrySceneOutcome == 2 || harryCombatPending || GetEffectiveAct2Stage() == 28
            StartHarryCombat()
        endif
    elseif theresaScene != None && akSender == theresaScene
        if v13CrisisResolved || GetEffectiveAct2Stage() >= 20
            ReferenceAlias al15End = Self.GetAlias(15) as ReferenceAlias
            if al15End != None && al15End.GetReference() != None
                al15End.Clear()
            endif
            EnsureSingleActiveObjective(20)
            ForceAllAct2Aliases()
            RefreshDisplayedAct2Objective()
        endif
    elseif act2RetScene != None && akSender == act2RetScene
        if waterChipInstalledInPlant
            jacorenFinaleTriggered = true
            if Self.GetStage() < 40
                Self.SetStage(40)
            endif
            StartTimer(0.35, 9)
        endif
    endif
EndEvent

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
    int stgLoc = GetEffectiveAct2Stage()
    if stgLoc >= 15 && stgLoc < 40
        ForceAllAct2Aliases()
        RefreshDisplayedAct2Objective()
        StartTimer(0.15, 12)
    endif
EndEvent

Event OnPlayerTeleport()
    int stgTel = GetEffectiveAct2Stage()
    if stgTel >= 15 && stgTel < 40
        if stgTel >= 20
            SetNecropolisState(true)
            V13Act1QuestScript act1Tel = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as V13Act1QuestScript
            if act1Tel != None
                act1Tel.UpdateSouthernCaliforniaMapMarkers()
            endif
        endif
        ForceAllAct2Aliases()
        RefreshDisplayedAct2Objective()
        StartTimer(0.15, 12)
    endif
EndEvent

Event OnStageSet(int auiStageID, int auiItemID)
    if auiStageID > 45 || isExecutingCheckpointJump
        return
    endif
    ApplyV13Act2Stage(auiStageID)
    StartTimer(0.2, 1)
EndEvent

Event OnTimer(int aiTimerID)
    if aiTimerID == 1
        CheckProgressionAndLevelGate()
        Quest act1Quest = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as Quest
        Actor jacoren = Game.GetFormFromFile(0x00002110, "Vault13Chronicles.esp") as Actor
        Actor player = Game.GetPlayer()
        Cell hallCell = Game.GetFormFromFile(0x00002E00, "Vault13Chronicles.esp") as Cell
        Cell sewerCell = Game.GetFormFromFile(0x00002F00, "Vault13Chronicles.esp") as Cell
        Cell watershedCell = Game.GetFormFromFile(0x00002900, "Vault13Chronicles.esp") as Cell
        int effStg = GetEffectiveAct2Stage()
        if (effStg >= 15 && (effStg < 40 || !rewardsGiven || !Self.IsCompleted() || !part1EndShown || !part1EndCardShownV2)) || (act1Quest != None && act1Quest.GetStage() >= 40 && effStg < 40) || (jacoren != None && jacoren.GetPositionZ() < -200.0)
            if player != None && ((hallCell != None && player.GetParentCell() == hallCell) || (sewerCell != None && player.GetParentCell() == sewerCell) || (watershedCell != None && player.GetParentCell() == watershedCell))
                StartTimer(0.8, 1)
            else
                StartTimer(2.0, 1)
            endif
        endif
    elseif aiTimerID == 2
        AdvanceWaterPlantWalkStep()
    elseif aiTimerID == 3
        NotifySewerForemanTerminalRead()
    elseif aiTimerID == 4
        Actor harry = Game.GetFormFromFile(0x00002A11, "Vault13Chronicles.esp") as Actor
        Scene harryScene = Game.GetFormFromFile(0x00005109, "Vault13Chronicles.esp") as Scene
        Scene harrySceneOld = Game.GetFormFromFile(0x00005108, "Vault13Chronicles.esp") as Scene
        Scene harrySceneWsh = Game.GetFormFromFile(0x0000510A, "Vault13Chronicles.esp") as Scene
        if harry != None && !harry.IsDead() && !harryEvacuated && !harryEvacWalkStarted && !harryEvacPending && !harryCombatStarted && !harryCombatPending && !intercomResolved
            if (harryScene == None || !harryScene.IsPlaying()) && (harrySceneOld == None || !harrySceneOld.IsPlaying()) && (harrySceneWsh == None || !harrySceneWsh.IsPlaying()) && !harry.IsInDialogueWithPlayer() && !harry.IsTalking()
                OpenHarryDialogueMenu()
            endif
        endif
    elseif aiTimerID == 5
        Actor player5 = Game.GetPlayer()
        Cell watershedCell5 = Game.GetFormFromFile(0x00002900, "Vault13Chronicles.esp") as Cell
        ObjectReference m2902 = Game.GetFormFromFile(0x00002902, "Vault13Chronicles.esp") as ObjectReference
        if player5 != None && watershedCell5 != None && player5.GetParentCell() != watershedCell5 && m2902 != None
            player5.MoveTo(m2902, 0.0, 0.0, 0.0, true)
        endif
        ForceAllAct2Aliases()
    elseif aiTimerID == 6
        Actor player6 = Game.GetPlayer()
        WorldSpace ws2161 = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
        ObjectReference m3517 = Game.GetFormFromFile(0x00003517, "Vault13Chronicles.esp") as ObjectReference
        if player6 != None
            if ws2161 != None && player6.GetWorldSpace() != ws2161 && m3517 != None
                player6.MoveTo(m3517, 0.0, 0.0, 0.0, true)
            endif
            Debug.Notification("[La Cuenca — Superficie] Has salido al Yermo del Sur de California con el Chip de Agua. Regresa al Refugio 13.")
        endif
        ForceAllAct2Aliases()
        RefreshDisplayedAct2Objective()
    elseif aiTimerID == 7
        Actor harry7 = Game.GetFormFromFile(0x00002A11, "Vault13Chronicles.esp") as Actor
        Scene harryScene7 = Game.GetFormFromFile(0x00005109, "Vault13Chronicles.esp") as Scene
        Scene harrySceneOld7 = Game.GetFormFromFile(0x00005108, "Vault13Chronicles.esp") as Scene
        Scene harrySceneWsh7 = Game.GetFormFromFile(0x0000510A, "Vault13Chronicles.esp") as Scene
        bool scenePlaying7 = (harryScene7 != None && harryScene7.IsPlaying()) || (harrySceneOld7 != None && harrySceneOld7.IsPlaying()) || (harrySceneWsh7 != None && harrySceneWsh7.IsPlaying())
        if harryCombatPending && !harryCombatStarted && !harryEvacuated
            SyncHarryPatrolFactions(true)
            harryCombatWaitTicks += 1
            if harry7 == None || harry7.IsDead() || (harryCombatWaitTicks >= 2 && !harry7.IsTalking()) || harryCombatWaitTicks >= 6
                StartHarryCombat()
            else
                StartTimer(0.2, 7)
            endif
        elseif harryEvacPending && !harryEvacWalkStarted && !harryEvacuated
            harryCombatWaitTicks += 1
            if harry7 == None || harry7.IsDead() || (!scenePlaying7 && !harry7.IsTalking() && !harry7.IsInDialogueWithPlayer()) || harryCombatWaitTicks >= 10
                BeginHarryEvacuationWalk()
            else
                StartTimer(0.2, 7)
            endif
        endif
    elseif aiTimerID == 8
        if IsHarryResolved() && !waterChipInstalledInPlant && !waterChipExtracted
            OnWaterChipExtracted()
        endif
    elseif aiTimerID == 9
        Actor jac9 = Game.GetFormFromFile(0x00002110, "Vault13Chronicles.esp") as Actor
        Scene retScene9 = Game.GetFormFromFile(0x00005101, "Vault13Chronicles.esp") as Scene
        if waterChipExtracted && !waterPlantWalkActive && !waterChipInstalledInPlant
            SanitizeLegacyQuestStage(35)
            Self.SetStage(35)
            ApplyV13Act2Stage(35)
        elseif waterChipInstalledInPlant && (!rewardsGiven || !part1EndShown || !part1EndCardShownV2)
            if (retScene9 != None && retScene9.IsPlaying()) || (jac9 != None && (jac9.IsTalking() || jac9.IsInDialogueWithPlayer())) || Utility.IsInMenuMode()
                StartTimer(0.8, 9)
            else
                if Self.GetStage() < 40
                    Self.SetStage(40)
                endif
                ApplyV13Act2Stage(40)
            endif
        endif
    elseif aiTimerID == 10
        Actor player10 = Game.GetPlayer()
        WorldSpace ws10 = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
        ObjectReference m2A0A = Game.GetFormFromFile(0x00002A0A, "Vault13Chronicles.esp") as ObjectReference
        if player10 != None && ws10 != None && player10.GetWorldSpace() == ws10 && m2A0A != None
            if player10.GetPositionX() > 5400.0 && player10.GetPositionX() < 7000.0 && player10.GetPositionY() < -3400.0
                player10.MoveTo(m2A0A, 0.0, 0.0, 0.0, true)
            endif
        endif
        ForceAllAct2Aliases()
        RefreshDisplayedAct2Objective()
    elseif aiTimerID == 11
        if harryCombatStarted && !intercomResolved && !harryEvacuated
            Actor player11 = Game.GetPlayer()
            Actor harry11 = Game.GetFormFromFile(0x00002A11, "Vault13Chronicles.esp") as Actor
            Actor g111 = Game.GetFormFromFile(0x00002A12, "Vault13Chronicles.esp") as Actor
            Actor g211 = Game.GetFormFromFile(0x00002A20, "Vault13Chronicles.esp") as Actor
            ReferenceAlias al1011 = Self.GetAlias(10) as ReferenceAlias
            if al1011 != None && al1011.GetReference() != None
                al1011.Clear()
            endif
            SyncHarryPatrolFactions(true)
            if player11 != None && !player11.IsDead()
                if harry11 != None && !harry11.IsDead()
                    harry11.SetAlert(true)
                    harry11.EvaluatePackage()
                    harry11.StartCombat(player11)
                endif
                if g111 != None && !g111.IsDead()
                    g111.SetAlert(true)
                    g111.EvaluatePackage()
                    g111.StartCombat(player11)
                endif
                if g211 != None && !g211.IsDead()
                    g211.SetAlert(true)
                    g211.EvaluatePackage()
                    g211.StartCombat(player11)
                endif
            endif
        endif
    elseif aiTimerID == 12
        ForceAllAct2Aliases()
        RefreshDisplayedAct2Objective()
    elseif aiTimerID == 13
        TriggerWaterPlantCelebrationStep()
    elseif aiTimerID == 14
        if waterChipInstalledInPlant
            waterPlantInstallQueued = false
            waterPlantConsoleOpenedWithChip = false
            bWaterPlantPromptBusy = false
            return
        endif
        if Utility.IsInMenuMode()
            StartTimer(0.15, 14)
            return
        endif
        bWaterPlantPromptBusy = false
        if waterPlantInstallQueued
            waterPlantInstallQueued = false
            waterPlantConsoleOpenedWithChip = false
            InstallWaterChipInMainframe()
        elseif waterPlantConsoleOpenedWithChip
            waterPlantConsoleOpenedWithChip = false
            Message installMenu = Game.GetFormFromFile(0x0000115C, "Vault13Chronicles.esp") as Message
            if installMenu != None
                int choice = installMenu.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
                if choice == 0
                    InstallWaterChipInMainframe()
                endif
            else
                InstallWaterChipInMainframe()
            endif
        endif
    elseif aiTimerID == 17
        if bPumpMissingPartsHold
            bPumpMissingPartsHold = false
            return
        endif
        if necroPumpRepaired
            bPumpPromptQueued = false
            return
        endif
        if Utility.IsInMenuMode()
            StartTimer(0.15, 17)
            return
        endif
        bPumpPromptQueued = false
        if necroPumpRepaired
            return
        endif
        Message pumpMenu = Game.GetFormFromFile(0x0000115D, "Vault13Chronicles.esp") as Message
        if pumpMenu != None
            int pChoice = pumpMenu.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
            if pChoice == 0
                RepairNecropolisWaterPump()
            endif
        else
            RepairNecropolisWaterPump()
        endif
    elseif aiTimerID == 15
        if Utility.IsInMenuMode()
            StartTimer(0.15, 15)
            return
        endif
        int jumpID = pendingCheckpointJump
        pendingCheckpointJump = 0
        if jumpID >= 5 && jumpID <= 11
            ExecuteMnemosyneCheckpointJump(jumpID)
        endif
    elseif aiTimerID == 16
        Actor player16 = Game.GetPlayer()
        Cell mnemoCell16 = Game.GetFormFromFile(0x00002000, "Vault13Chronicles.esp") as Cell
        if lastCheckpointJumpID >= 5 && lastCheckpointJumpID <= 11 && player16 != None && mnemoCell16 != None && player16.GetParentCell() == mnemoCell16
            checkpointJumpRetries += 1
            if !Utility.IsInMenuMode()
                MovePlayerToCheckpointTarget(lastCheckpointJumpID)
            endif
            if checkpointJumpRetries < 180
                StartTimer(0.35, 16)
            else
                lastCheckpointJumpID = 0
            endif
        else
            if lastCheckpointJumpID == 7 && player16 != None && player16.GetPositionX() > 2000.0
                player16.SetPosition(1280.0, 128.0, 260.0)
            elseif lastCheckpointJumpID == 8 && player16 != None && player16.GetPositionY() > -6000.0
                player16.SetPosition(8680.0, -7390.0, 628.0)
            endif
            lastCheckpointJumpID = 0
            SetNecropolisState(true)
            SyncVault12InnerChamberState()
            harryPatrolRefreshedV4 = false
            RefreshHarryPatrolWeaponsAndAI()
            ForceAllAct2Aliases()
            RefreshDisplayedAct2Objective()
        endif
    endif
EndEvent

Function MovePlayerToCheckpointTarget(int aiMenuID)
    Actor player = Game.GetPlayer()
    if player == None
        return
    endif
    if aiMenuID == 5 || aiMenuID == 11
        ObjectReference m2102 = Game.GetFormFromFile(0x00002102, "Vault13Chronicles.esp") as ObjectReference
        if m2102 != None
            player.MoveTo(m2102, 0.0, 0.0, 0.0, true)
        endif
    elseif aiMenuID == 6
        ObjectReference m2A02 = Game.GetFormFromFile(0x00002A02, "Vault13Chronicles.esp") as ObjectReference
        if m2A02 != None
            player.MoveTo(m2A02, 0.0, 0.0, 0.0, true)
        endif
    elseif aiMenuID == 7
        Actor setActor = Game.GetFormFromFile(0x00002E11, "Vault13Chronicles.esp") as Actor
        ObjectReference m2E02 = Game.GetFormFromFile(0x00002E02, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference armoryChest = Game.GetFormFromFile(0x00002E20, "Vault13Chronicles.esp") as ObjectReference
        if armoryChest != None
            armoryChest.Enable(false)
            armoryChest.SetLockLevel(0)
            armoryChest.Lock(false, false)
        endif
        if setActor != None && !setActor.IsDisabled()
            player.MoveTo(setActor, 220.0, 0.0, 4.0, true)
        elseif m2E02 != None
            player.MoveTo(m2E02, 0.0, 0.0, 0.0, true)
        endif
    elseif aiMenuID == 8
        Actor ezequielActor = Game.GetFormFromFile(0x00002F18, "Vault13Chronicles.esp") as Actor
        ObjectReference m2F02 = Game.GetFormFromFile(0x00002F02, "Vault13Chronicles.esp") as ObjectReference
        if ezequielActor != None && !ezequielActor.IsDisabled()
            player.MoveTo(ezequielActor, -180.0, 50.0, 4.0, true)
        elseif m2F02 != None
            player.MoveTo(m2F02, 0.0, 0.0, 0.0, true)
        endif
    elseif aiMenuID == 9
        ObjectReference m2A45 = Game.GetFormFromFile(0x00002A45, "Vault13Chronicles.esp") as ObjectReference
        if m2A45 != None
            player.MoveTo(m2A45, 0.0, -220.0, 4.0, true)
        endif
    elseif aiMenuID == 10
        ObjectReference m2902 = Game.GetFormFromFile(0x00002902, "Vault13Chronicles.esp") as ObjectReference
        if m2902 != None
            player.MoveTo(m2902, 0.0, 0.0, 0.0, true)
        endif
    endif
EndFunction

Function QueueMnemosyneCheckpointJump(int aiMenuID)
    if isExecutingCheckpointJump || pendingCheckpointJump == aiMenuID
        return
    endif
    pendingCheckpointJump = aiMenuID
    lastCheckpointJumpID = aiMenuID
    checkpointJumpRetries = 0
    if !Self.IsRunning()
        Self.Start()
    endif
    RegisterPlayerEvents()
    InputEnableLayer tempLayer = InputEnableLayer.Create()
    if tempLayer != None
        tempLayer.DisablePlayerControls(false, false, false, false, false, true, false, false, false, false, false)
        Utility.WaitMenuMode(0.1)
        tempLayer.EnablePlayerControls()
        tempLayer.Delete()
    endif
    StartTimer(0.1, 15)
EndFunction

Function ExecuteMnemosyneCheckpointJump(int aiMenuID)
    Actor player = Game.GetPlayer()
    if player == None
        return
    endif
    isExecutingCheckpointJump = true
    lastCheckpointJumpID = aiMenuID
    checkpointJumpRetries = 0

    ; 1. Set all Act II state flags immediately (before any latent call)
    introShown = true
    v13CrisisResolved = (aiMenuID >= 6)
    v13CrisisRewardGiven = (aiMenuID >= 6)
    garretIntroDone = (aiMenuID >= 7)
    garretArmoryUnlockedNotified = (aiMenuID >= 7)
    sewerPasswordFound = (aiMenuID >= 9)
    bSewerChamberUnlocked = (aiMenuID >= 9)
    ezequielGreeted = (aiMenuID >= 9)
    pumpPartsRecovered = (aiMenuID >= 9)
    pumpPartsNotified = (aiMenuID >= 9)
    necroPumpRepaired = (aiMenuID >= 10)
    pumpStateInitialized = false
    intercomResolved = false
    harryEvacuated = false
    harryEvacWalkStarted = false
    harryEvacPending = false
    harryCombatStarted = false
    harryCombatPending = false
    harrySceneOutcome = 0
    waterChipExtracted = (aiMenuID >= 11)
    chipExtractedNotified = (aiMenuID >= 11)
    waterPlantWalkActive = false
    waterChipInstalledInPlant = (aiMenuID >= 11)
    rewardsGiven = false
    part1EndShown = (aiMenuID >= 11)
    part1EndCardShownV2 = (aiMenuID >= 11)
    jacorenFinaleTriggered = (aiMenuID >= 11)
    lastAppliedAct2Stage = 0
    bPumpPromptQueued = false
    bPumpMissingPartsHold = false
    bWaterPlantPromptBusy = false

    ; 2. TELEPORT PLAYER IMMEDIATELY (and start Timer 16 to guarantee arrival once terminal closes)
    MovePlayerToCheckpointTarget(aiMenuID)
    StartTimer(0.35, 16)

    ; 3. Complete Act I silently and grant Vault 13 Jumpsuit (0x00001307) & Colt 6520 (0x00001102)
    Quest q1 = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as Quest
    V13Act1QuestScript act1S = q1 as V13Act1QuestScript
    if act1S != None
        act1S.SilentCompleteAct1ForJump()
    endif
    if q1 != None
        q1.SetStage(40)
    endif
    Form v13Suit = Game.GetFormFromFile(0x00001307, "Vault13Chronicles.esp")
    Form colt6520 = Game.GetFormFromFile(0x00001102, "Vault13Chronicles.esp")
    Form ammo10mm = Game.GetFormFromFile(0x0001F276, "Fallout4.esm")
    Form stimpak = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
    Form radaway = Game.GetFormFromFile(0x00023742, "Fallout4.esm")
    Form bobbyPin = Game.GetFormFromFile(0x0000000A, "Fallout4.esm")
    if v13Suit != None && player.GetItemCount(v13Suit) == 0
        player.AddItem(v13Suit, 1, true)
    endif
    if colt6520 != None && player.GetItemCount(colt6520) == 0
        player.AddItem(colt6520, 1, true)
    endif
    if ammo10mm != None && player.GetItemCount(ammo10mm) < 120
        player.AddItem(ammo10mm, 120 - player.GetItemCount(ammo10mm), true)
    endif
    if stimpak != None && player.GetItemCount(stimpak) < 10
        player.AddItem(stimpak, 10 - player.GetItemCount(stimpak), true)
    endif
    if radaway != None && player.GetItemCount(radaway) < 5
        player.AddItem(radaway, 5 - player.GetItemCount(radaway), true)
    endif
    if bobbyPin != None && player.GetItemCount(bobbyPin) < 15
        player.AddItem(bobbyPin, 15 - player.GetItemCount(bobbyPin), true)
    endif

    ; 4. Configure quest items & containers for the chosen checkpoint
    Form waterChip = Game.GetFormFromFile(0x00001112, "Vault13Chronicles.esp")
    ObjectReference waterComp = Game.GetFormFromFile(0x00002A10, "Vault13Chronicles.esp") as ObjectReference
    Form pumpParts = Game.GetFormFromFile(0x0000111D, "Vault13Chronicles.esp")
    ObjectReference sewPartsBox = Game.GetFormFromFile(0x00002F22, "Vault13Chronicles.esp") as ObjectReference

    if aiMenuID <= 10
        if waterChip != None && player.GetItemCount(waterChip) > 0
            player.RemoveItem(waterChip, player.GetItemCount(waterChip), true, None)
        endif
        if waterComp != None && waterChip != None
            if waterComp.GetItemCount(waterChip) == 0
                waterComp.AddItem(waterChip, 1, true)
            elseif waterComp.GetItemCount(waterChip) > 1
                waterComp.RemoveItem(waterChip, waterComp.GetItemCount(waterChip) - 1, true, None)
            endif
        endif
    endif
    if aiMenuID <= 8
        if pumpParts != None && player.GetItemCount(pumpParts) > 0
            player.RemoveItem(pumpParts, player.GetItemCount(pumpParts), true, None)
        endif
        if sewPartsBox != None && pumpParts != None && sewPartsBox.GetItemCount(pumpParts) == 0
            sewPartsBox.AddItem(pumpParts, 1, true)
        endif
    elseif aiMenuID == 9
        if sewPartsBox != None && pumpParts != None && sewPartsBox.GetItemCount(pumpParts) > 0
            sewPartsBox.RemoveItem(pumpParts, sewPartsBox.GetItemCount(pumpParts), true, None)
        endif
        if pumpParts != None && player.GetItemCount(pumpParts) == 0
            player.AddItem(pumpParts, 1, true)
        endif
    elseif aiMenuID >= 10
        if sewPartsBox != None && pumpParts != None && sewPartsBox.GetItemCount(pumpParts) > 0
            sewPartsBox.RemoveItem(pumpParts, sewPartsBox.GetItemCount(pumpParts), true, None)
        endif
        if pumpParts != None && player.GetItemCount(pumpParts) > 0
            player.RemoveItem(pumpParts, player.GetItemCount(pumpParts), true, None)
        endif
    endif

    Actor harry = Game.GetFormFromFile(0x00002A11, "Vault13Chronicles.esp") as Actor
    Actor g1 = Game.GetFormFromFile(0x00002A12, "Vault13Chronicles.esp") as Actor
    Actor g2 = Game.GetFormFromFile(0x00002A20, "Vault13Chronicles.esp") as Actor
    if aiMenuID <= 10
        if harry != None
            if harry.IsDead()
                harry.Resurrect()
            endif
            harry.Enable(false)
        endif
        if g1 != None
            if g1.IsDead()
                g1.Resurrect()
            endif
            g1.Enable(false)
        endif
        if g2 != None
            if g2.IsDead()
                g2.Resurrect()
            endif
            g2.Enable(false)
        endif
        SyncHarryPatrolFactions(false)
    endif

    if aiMenuID == 5
        Self.SetStage(18)
        EnsureSingleActiveObjective(18)
        Debug.Notification("[Salto Directo QA] Acto II — Refugio 13 (Etapa 18: Crisis de Agua)")
    elseif aiMenuID == 6
        Self.SetStage(20)
        EnsureSingleActiveObjective(20)
        Debug.Notification("[Salto Directo QA] Acto II — Entrada a Necrópolis (Etapa 20)")
    elseif aiMenuID == 7
        Self.SetStage(24)
        EnsureSingleActiveObjective(24)
        Debug.Notification("[Salto Directo QA] Acto II — Junto a Set y Garret (Etapa 24: Rumbo a las Alcantarillas)")
    elseif aiMenuID == 8
        Self.SetStage(24)
        EnsureSingleActiveObjective(24)
        Debug.Notification("[Salto Directo QA] Acto II — Junto a Ezequiel en las Alcantarillas (Etapa 24)")
    elseif aiMenuID == 9
        Self.SetStage(25)
        EnsureSingleActiveObjective(25)
        Debug.Notification("[Salto Directo QA] Acto II — Gran Bomba de Agua con Piezas listas (Etapa 25)")
    elseif aiMenuID == 10
        SetNecropolisPumpState(true)
        Self.SetStage(26)
        EnsureSingleActiveObjective(26)
        Debug.Notification("[Salto Directo QA] Acto II — Estación del Refugio 12 frente a Harry (Etapa 26)")
    elseif aiMenuID == 11
        SetWaterPlantState(true)
        GiveAct2CompletionRewards()
        Self.SetStage(40)
        Self.CompleteAllObjectives()
        Self.CompleteQuest()
        Quest q3 = Game.GetFormFromFile(0x00006000, "Vault13Chronicles.esp") as Quest
        if q3 != None
            if !q3.IsRunning()
                q3.Start()
            endif
            q3.SetStage(20)
        endif
        Debug.Notification("[Salto Directo QA] Acto III — Lost Hills y Hermandad del Acero")
    endif

    isExecutingCheckpointJump = false
    SetNecropolisState(true)
    SyncVault12InnerChamberState()
    if aiMenuID <= 10
        harryPatrolRefreshedV4 = false
        RefreshHarryPatrolWeaponsAndAI()
    endif
    ForceAllAct2Aliases()
    RefreshDisplayedAct2Objective()
    StartTimer(0.2, 1)
EndFunction
