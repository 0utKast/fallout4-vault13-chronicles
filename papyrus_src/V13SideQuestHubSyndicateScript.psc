Scriptname V13SideQuestHubSyndicateScript extends Quest

bool bWaterCaravanHired = False
bool bJacorenWaterReactionShown = False
bool bMutantHoloRecovered = False
bool bDeckerResolved = False
bool bItemsDeliveredToSheriff = False
bool bFinalRewardGranted = False
bool bRewardGranted = False
bool bStg15Done = False
bool bStg20Done = False
bool bStg26Done = False
bool bStg28Done = False
bool bStg30Done = False
bool bDclawDeathNotified = False
int sceneWaitTicks = 0
int tugDeathWaitTicks = 0

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

Function SyncHubSyndicateProgressFlags()
    Actor player = Game.GetPlayer()
    Form holoBase = Game.GetFormFromFile(0x0000145E, "Vault13Chronicles.esp")
    Form ledgerBase = Game.GetFormFromFile(0x0000145F, "Vault13Chronicles.esp")
    Actor mutantAct = Game.GetFormFromFile(0x000035EB, "Vault13Chronicles.esp") as Actor
    Actor deckerAct = Game.GetFormFromFile(0x00002710, "Vault13Chronicles.esp") as Actor

    if player != None
        if holoBase != None && player.GetItemCount(holoBase) > 0
            bMutantHoloRecovered = True
        endif
        if ledgerBase != None && player.GetItemCount(ledgerBase) > 0
            bDeckerResolved = True
        endif
    endif
    if bItemsDeliveredToSheriff || Self.IsCompleted() || Self.GetStage() >= 40 || Self.IsStageDone(40) || Self.IsStageDone(30)
        bItemsDeliveredToSheriff = True
        bMutantHoloRecovered = True
        bDeckerResolved = True
    endif
    if Self.GetStage() == 25 || Self.IsStageDone(25)
        bMutantHoloRecovered = True
    endif
    if mutantAct != None && mutantAct.IsDead() && Self.GetStage() >= 20
        bMutantHoloRecovered = True
    endif
    if deckerAct != None && deckerAct.IsDead() && Self.GetStage() >= 20
        bDeckerResolved = True
    endif
EndFunction

Function FinalizeHubSyndicateQuestCleanly()
    SetObjectiveCompleted(15, True)
    SetObjectiveCompleted(20, True)
    SetObjectiveCompleted(21, True)
    if Self.IsObjectiveDisplayed(30)
        SetObjectiveCompleted(30, True)
    endif
    Self.CompleteAllObjectives()
    ClearQuestAlias(0)
    ClearQuestAlias(1)
    ClearQuestAlias(9)
    ClearQuestAlias(10)
    if !Self.IsCompleted()
        Self.CompleteQuest()
    endif
EndFunction

Function ForceAllHubSyndicateAliases()
    SyncHubSyndicateProgressFlags()
    if Self.IsCompleted() || Self.GetStage() >= 40 || Self.IsStageDone(40) || Self.IsStageDone(30) || bItemsDeliveredToSheriff
        bItemsDeliveredToSheriff = True
        FinalizeHubSyndicateQuestCleanly()
        return
    endif

    Scene mutantScn = Game.GetFormFromFile(0x0001A101, "Vault13Chronicles.esp") as Scene
    Scene deckerScn = Game.GetFormFromFile(0x0001A103, "Vault13Chronicles.esp") as Scene
    Actor mutantAct = Game.GetFormFromFile(0x000035EB, "Vault13Chronicles.esp") as Actor
    Actor deckerAct = Game.GetFormFromFile(0x00002710, "Vault13Chronicles.esp") as Actor
    ForceQuestAlias(0, 0x000035E7)
    if !bMutantHoloRecovered
        ForceQuestAlias(1, 0x000035EB)
    elseif (mutantScn == None || !mutantScn.IsPlaying()) && (mutantAct == None || !mutantAct.IsTalking())
        ClearQuestAlias(1)
    endif
    ForceQuestAlias(2, 0x00003005)
    ForceQuestAlias(3, 0x00002003)
    ForceQuestAlias(4, 0x00003605)
    ForceQuestAlias(5, 0x00002101)
    ForceQuestAlias(6, 0x00003501)
    ForceQuestAlias(7, 0x00002701)
    ForceQuestAlias(8, 0x00002035)
    ClearQuestAlias(9)
    if !bDeckerResolved
        ForceQuestAlias(10, 0x00002710)
    elseif (deckerScn == None || !deckerScn.IsPlaying()) && (deckerAct == None || !deckerAct.IsTalking())
        ClearQuestAlias(10)
    endif
EndFunction

Function StartHubSyndicateQuest()
    BindHubSyndicateListeners()
    if Self.GetStage() < 15
        Self.SetStage(15)
    endif
EndFunction

Function StopAllHubSyndicateScenesExcept(int aiKeepSceneIdx)
    Scene mutantScn = Game.GetFormFromFile(0x0001A101, "Vault13Chronicles.esp") as Scene
    Scene sheriffScn = Game.GetFormFromFile(0x0001A102, "Vault13Chronicles.esp") as Scene
    Scene deckerScn = Game.GetFormFromFile(0x0001A103, "Vault13Chronicles.esp") as Scene
    if aiKeepSceneIdx != 2 && mutantScn != None && mutantScn.IsPlaying()
        mutantScn.Stop()
    endif
    if aiKeepSceneIdx != 3 && sheriffScn != None && sheriffScn.IsPlaying()
        sheriffScn.Stop()
    endif
    if aiKeepSceneIdx != 4 && deckerScn != None && deckerScn.IsPlaying()
        deckerScn.Stop()
    endif
EndFunction

Function EquipHubSyndicateActorGear(Actor akAct, int aiOutfitID, int aiBodyArmorID, int aiHatID, int aiOldBodyID)
    if akAct == None || akAct.IsDead() || !akAct.Is3DLoaded() || akAct.IsTalking()
        return
    endif
    Actor plDist = Game.GetPlayer()
    if plDist != None && akAct.GetDistance(plDist) < 2200.0
        return
    endif
    Form bodyArmor = None
    if aiBodyArmorID > 0
        bodyArmor = Game.GetFormFromFile(aiBodyArmorID, "Fallout4.esm")
    endif
    Outfit otft = Game.GetFormFromFile(aiOutfitID, "Vault13Chronicles.esp") as Outfit
    if otft != None && (bodyArmor == None || !akAct.IsEquipped(bodyArmor))
        akAct.SetOutfit(otft, false)
    endif
    if aiOldBodyID > 0
        Form oldBody = Game.GetFormFromFile(aiOldBodyID, "Fallout4.esm")
        if oldBody != None && akAct.GetItemCount(oldBody) > 0
            akAct.RemoveItem(oldBody, akAct.GetItemCount(oldBody), true, None)
        endif
    endif
    if bodyArmor != None && !akAct.IsEquipped(bodyArmor)
        if akAct.GetItemCount(bodyArmor) == 0
            akAct.AddItem(bodyArmor, 1, true)
        endif
        akAct.EquipItem(bodyArmor, false, true)
    endif
    if aiHatID > 0
        Form hatForm = Game.GetFormFromFile(aiHatID, "Fallout4.esm")
        if hatForm != None && !akAct.IsEquipped(hatForm)
            if akAct.GetItemCount(hatForm) == 0
                akAct.AddItem(hatForm, 1, true)
            endif
            akAct.EquipItem(hatForm, false, true)
        endif
    endif
EndFunction

Function RefreshHubSyndicateLayout()
    Actor player = Game.GetPlayer()
    WorldSpace caliSyn = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    Cell hubUgCell = Game.GetFormFromFile(0x00002700, "Vault13Chronicles.esp") as Cell
    if player == None || ((caliSyn == None || player.GetWorldSpace() != caliSyn) && (hubUgCell == None || player.GetParentCell() != hubUgCell))
        return
    endif
    Actor sheriffAct = Game.GetFormFromFile(0x000035E7, "Vault13Chronicles.esp") as Actor
    if sheriffAct != None && !sheriffAct.IsDead()
        if sheriffAct.IsDisabled()
            sheriffAct.EnableNoWait()
        endif
        if sheriffAct.Is3DLoaded() && !sheriffAct.IsInCombat()
            sheriffAct.AllowPCDialogue(True)
            sheriffAct.BlockActivation(False, False)
            if !sheriffAct.IsTalking() && (Math.Abs(sheriffAct.GetPositionX() + 5400.0) > 45.0 || Math.Abs(sheriffAct.GetPositionY() + 11800.0) > 45.0)
                sheriffAct.SetPosition(-5400.0, -11800.0, 80.0)
                sheriffAct.SetAngle(0.0, 0.0, 45.0)
                sheriffAct.EvaluatePackage()
            endif
            EquipHubSyndicateActorGear(sheriffAct, 0x00001034, 0x00237680, 0x0023767F, 0x0016892C)
        endif
    endif

    Actor legacyDecker = Game.GetFormFromFile(0x000035E8, "Vault13Chronicles.esp") as Actor
    if legacyDecker != None && !legacyDecker.IsDisabled()
        legacyDecker.DisableNoWait()
    endif
    Actor legacyKane = Game.GetFormFromFile(0x000035E9, "Vault13Chronicles.esp") as Actor
    if legacyKane != None && !legacyKane.IsDisabled()
        legacyKane.DisableNoWait()
    endif

    Actor deckerAct = Game.GetFormFromFile(0x00002710, "Vault13Chronicles.esp") as Actor
    Form ledgerBase = Game.GetFormFromFile(0x0000145F, "Vault13Chronicles.esp")
    Form dossierBase = Game.GetFormFromFile(0x00001C87, "Vault13Chronicles.esp")
    if deckerAct != None
        if deckerAct.IsDisabled() && Self.GetStage() < 40
            deckerAct.EnableNoWait()
        endif
        if !deckerAct.IsDead() && deckerAct.Is3DLoaded() && !deckerAct.IsInCombat()
            deckerAct.AllowPCDialogue(True)
            deckerAct.BlockActivation(False, False)
            if !deckerAct.IsTalking() && (Math.Abs(deckerAct.GetPositionX() - 10.0) > 45.0 || Math.Abs(deckerAct.GetPositionY() + 30.0) > 45.0)
                deckerAct.SetPosition(10.0, -30.0, 1.3)
                deckerAct.SetAngle(0.0, 0.0, 0.0)
                deckerAct.EvaluatePackage()
            endif
            EquipHubSyndicateActorGear(deckerAct, 0x00001035, 0x001BDDF8, 0, 0x001536F4)
            if !bDeckerResolved && ledgerBase != None && player != None && player.GetItemCount(ledgerBase) == 0 && deckerAct.GetItemCount(ledgerBase) == 0
                deckerAct.AddItem(ledgerBase, 1, True)
            endif
            if dossierBase != None && deckerAct.GetItemCount(dossierBase) == 0
                deckerAct.AddItem(dossierBase, 1, True)
            endif
        endif
    endif

    Actor kaneAct = Game.GetFormFromFile(0x00002711, "Vault13Chronicles.esp") as Actor
    if kaneAct != None && !kaneAct.IsDead()
        if kaneAct.IsDisabled() && Self.GetStage() < 40
            kaneAct.EnableNoWait()
        endif
        if kaneAct.Is3DLoaded() && !kaneAct.IsInCombat()
            kaneAct.BlockActivation(False, False)
            if !kaneAct.IsTalking() && (Math.Abs(kaneAct.GetPositionX() - 150.0) > 45.0 || Math.Abs(kaneAct.GetPositionY() + 50.0) > 45.0)
                kaneAct.SetPosition(150.0, -50.0, 1.3)
                kaneAct.SetAngle(0.0, 0.0, 14.0)
                kaneAct.EvaluatePackage()
            endif
            EquipHubSyndicateActorGear(kaneAct, 0x00001036, 0x001FE1A6, 0, 0x000B2D8E)
        endif
    endif

    Actor dclawAct = Game.GetFormFromFile(0x000035EA, "Vault13Chronicles.esp") as Actor
    if dclawAct != None && !dclawAct.IsDead()
        if dclawAct.IsDisabled() && Self.GetStage() < 40
            dclawAct.EnableNoWait()
        endif
        if dclawAct.Is3DLoaded()
            dclawAct.EnableAI(True)
            ActorValue aggAV = Game.GetFormFromFile(0x000002BC, "Fallout4.esm") as ActorValue
            ActorValue confAV = Game.GetFormFromFile(0x000002BD, "Fallout4.esm") as ActorValue
            if aggAV != None
                dclawAct.SetValue(aggAV, 2.0)
            endif
            if confAV != None
                dclawAct.SetValue(confAV, 4.0)
            endif
            V13WastelandCreatureAIScript dcAI = (dclawAct as ObjectReference) as V13WastelandCreatureAIScript
            if dcAI != None
                dcAI.InitCreatureAI()
            endif
            if player != None && !player.IsDead() && dclawAct.GetDistance(player) <= 1850.0 && !dclawAct.IsInCombat()
                dclawAct.StartCombat(player)
            endif
        endif
    endif

    Actor mutantAct = Game.GetFormFromFile(0x000035EB, "Vault13Chronicles.esp") as Actor
    Form holoBase = Game.GetFormFromFile(0x0000145E, "Vault13Chronicles.esp")
    Form docBase = Game.GetFormFromFile(0x00001C86, "Vault13Chronicles.esp")
    if mutantAct != None
        if mutantAct.IsDisabled() && Self.GetStage() < 40
            mutantAct.EnableNoWait()
        endif
        if !mutantAct.IsDead() && mutantAct.Is3DLoaded() && !mutantAct.IsInCombat()
            mutantAct.AllowPCDialogue(True)
            mutantAct.BlockActivation(False, False)
            if Math.Abs(mutantAct.GetPositionX() + 15450.0) > 450.0 || Math.Abs(mutantAct.GetPositionY() + 18850.0) > 450.0
                mutantAct.SetPosition(-15450.0, -18850.0, 102.0)
                mutantAct.SetAngle(0.0, 0.0, 30.0)
            endif
            if !bMutantHoloRecovered && holoBase != None && player != None && player.GetItemCount(holoBase) == 0 && mutantAct.GetItemCount(holoBase) == 0
                mutantAct.AddItem(holoBase, 1, True)
            endif
            if docBase != None && mutantAct.GetItemCount(docBase) == 0
                mutantAct.AddItem(docBase, 1, True)
            endif
        endif
    endif
EndFunction

Function BindHubSyndicateListeners(bool abRefreshLayout = True)
    Actor player = Game.GetPlayer()
    Form holoBase = Game.GetFormFromFile(0x0000145E, "Vault13Chronicles.esp")
    Form ledgerBase = Game.GetFormFromFile(0x0000145F, "Vault13Chronicles.esp")
    Self.RemoveAllInventoryEventFilters()
    if holoBase != None
        Self.AddInventoryEventFilter(holoBase)
    endif
    if ledgerBase != None
        Self.AddInventoryEventFilter(ledgerBase)
    endif
    if player != None
        RegisterForRemoteEvent(player, "OnPlayerLoadGame")
        RegisterForRemoteEvent(player, "OnLocationChange")
        if holoBase != None || ledgerBase != None
            RegisterForRemoteEvent(player as ObjectReference, "OnItemAdded")
        endif
    endif

    ForceAllHubSyndicateAliases()
    if abRefreshLayout
        RefreshHubSyndicateLayout()
    endif

    Quest wmQ = Game.GetFormFromFile(0x0001E000, "Vault13Chronicles.esp") as Quest
    if wmQ != None
        V13SideQuestWaterMerchantsScript wmS = wmQ as V13SideQuestWaterMerchantsScript
        if wmS != None
            wmS.BindWaterMerchantsListeners(abRefreshLayout)
        endif
    endif
    ObjectReference sheriffRef = Game.GetFormFromFile(0x000035E7, "Vault13Chronicles.esp") as ObjectReference
    if sheriffRef != None
        RegisterForRemoteEvent(sheriffRef, "OnActivate")
    endif
    Actor deckerAct = Game.GetFormFromFile(0x00002710, "Vault13Chronicles.esp") as Actor
    if deckerAct != None
        RegisterForRemoteEvent(deckerAct as ObjectReference, "OnActivate")
        if ledgerBase != None
            RegisterForRemoteEvent(deckerAct as ObjectReference, "OnItemRemoved")
        endif
        RegisterForRemoteEvent(deckerAct, "OnDeath")
        if !deckerAct.IsDead()
            RegisterForHitEvent(deckerAct)
        endif
    endif
    Actor kaneAct = Game.GetFormFromFile(0x00002711, "Vault13Chronicles.esp") as Actor
    if kaneAct != None
        RegisterForRemoteEvent(kaneAct as ObjectReference, "OnActivate")
        RegisterForRemoteEvent(kaneAct, "OnDeath")
        if !kaneAct.IsDead()
            RegisterForHitEvent(kaneAct)
        endif
    endif
    Actor dclawAct = Game.GetFormFromFile(0x000035EA, "Vault13Chronicles.esp") as Actor
    if dclawAct != None
        RegisterForRemoteEvent(dclawAct, "OnDeath")
        V13WastelandCreatureAIScript dcAI = (dclawAct as ObjectReference) as V13WastelandCreatureAIScript
        if dcAI != None
            dcAI.InitCreatureAI()
        endif
    endif
    Actor mutantAct = Game.GetFormFromFile(0x000035EB, "Vault13Chronicles.esp") as Actor
    if mutantAct != None
        RegisterForRemoteEvent(mutantAct as ObjectReference, "OnActivate")
        if holoBase != None
            RegisterForRemoteEvent(mutantAct as ObjectReference, "OnItemRemoved")
        endif
        RegisterForRemoteEvent(mutantAct, "OnDeath")
    endif
EndFunction

Function CheckHubSyndicateCompletionState()
    Actor player = Game.GetPlayer()
    if player == None
        return
    endif
    SyncHubSyndicateProgressFlags()
    if Self.IsCompleted() || Self.GetStage() >= 40 || Self.IsStageDone(40) || Self.IsStageDone(30) || bItemsDeliveredToSheriff
        bItemsDeliveredToSheriff = True
        FinalizeHubSyndicateQuestCleanly()
        return
    endif

    Scene mutantScn = Game.GetFormFromFile(0x0001A101, "Vault13Chronicles.esp") as Scene
    Scene deckerScn = Game.GetFormFromFile(0x0001A103, "Vault13Chronicles.esp") as Scene
    Actor mutantAct = Game.GetFormFromFile(0x000035EB, "Vault13Chronicles.esp") as Actor
    Actor deckerAct = Game.GetFormFromFile(0x00002710, "Vault13Chronicles.esp") as Actor

    if bMutantHoloRecovered
        SetObjectiveCompleted(20, True)
        ClearQuestAlias(1)
    elseif Self.GetStage() >= 20
        ForceQuestAlias(1, 0x000035EB)
        if !Self.IsObjectiveDisplayed(20)
            Self.SetObjectiveDisplayed(20, True, False)
        endif
    endif

    if bDeckerResolved
        SetObjectiveCompleted(21, True)
        ClearQuestAlias(10)
    elseif Self.GetStage() >= 20
        ForceQuestAlias(10, 0x00002710)
        if !Self.IsObjectiveDisplayed(21)
            Self.SetObjectiveDisplayed(21, True, False)
        endif
    endif

    if bMutantHoloRecovered && bDeckerResolved && Self.GetStage() < 30
        Self.SetStage(30)
    endif
EndFunction

Function NotifyMutantHolodiskRecovered()
    if bMutantHoloRecovered
        CheckHubSyndicateCompletionState()
        return
    endif
    bMutantHoloRecovered = True
    Actor player = Game.GetPlayer()
    Actor mutantAct = Game.GetFormFromFile(0x000035EB, "Vault13Chronicles.esp") as Actor
    Form holoBase = Game.GetFormFromFile(0x0000145E, "Vault13Chronicles.esp")
    Form docBase = Game.GetFormFromFile(0x00001C86, "Vault13Chronicles.esp")
    if mutantAct != None && holoBase != None && mutantAct.GetItemCount(holoBase) > 0
        mutantAct.RemoveItem(holoBase, mutantAct.GetItemCount(holoBase), True)
    endif
    if mutantAct != None && docBase != None && mutantAct.GetItemCount(docBase) > 0
        mutantAct.RemoveItem(docBase, mutantAct.GetItemCount(docBase), True)
    endif
    if player != None
        if holoBase != None && player.GetItemCount(holoBase) == 0
            player.AddItem(holoBase, 1, False)
        endif
        if docBase != None && player.GetItemCount(docBase) == 0
            player.AddItem(docBase, 1, False)
        endif
    endif
    int prevStage = Self.GetStage()
    if prevStage < 20
        Self.SetStage(20)
        prevStage = 20
    endif
    if !Self.IsStageDone(25)
        Self.SetStage(25)
    endif
    if bDeckerResolved && prevStage >= 26 && Self.GetStage() < 30
        Self.SetStage(30)
    endif
    Game.RewardPlayerXP(200)
    Debug.Notification("¡Holodisco de Transmisiones Mutantes obtenido! Prueba de que patrullas supermutantes del norte asaltan las caravanas (+200 XP).")
    CheckHubSyndicateCompletionState()
    tugDeathWaitTicks = 0
    StartTimer(1.0, 806)
EndFunction

Function NotifyDeckerLedgerRecovered()
    if bDeckerResolved
        CheckHubSyndicateCompletionState()
        return
    endif
    bDeckerResolved = True
    Actor player = Game.GetPlayer()
    Actor deckerAct = Game.GetFormFromFile(0x00002710, "Vault13Chronicles.esp") as Actor
    Form ledgerBase = Game.GetFormFromFile(0x0000145F, "Vault13Chronicles.esp")
    Form dossierBase = Game.GetFormFromFile(0x00001C87, "Vault13Chronicles.esp")
    if deckerAct != None && ledgerBase != None && deckerAct.GetItemCount(ledgerBase) > 0
        deckerAct.RemoveItem(ledgerBase, deckerAct.GetItemCount(ledgerBase), True)
    endif
    if deckerAct != None && dossierBase != None && deckerAct.GetItemCount(dossierBase) > 0
        deckerAct.RemoveItem(dossierBase, deckerAct.GetItemCount(dossierBase), True)
    endif
    if player != None
        if ledgerBase != None && player.GetItemCount(ledgerBase) == 0
            player.AddItem(ledgerBase, 1, False)
        endif
        if dossierBase != None && player.GetItemCount(dossierBase) == 0
            player.AddItem(dossierBase, 1, False)
        endif
    endif
    int prevStageD = Self.GetStage()
    if prevStageD < 20
        Self.SetStage(20)
    endif
    if !Self.IsStageDone(26) && !Self.IsStageDone(27) && !Self.IsStageDone(28)
        Self.SetStage(26)
    endif
    Game.RewardPlayerXP(200)
    Debug.Notification("¡Libro Mayor del Submundo de Decker obtenido! Llévaselo al Sheriff Justin Greene en El Eje (+200 XP).")
    CheckHubSyndicateCompletionState()
EndFunction

Function HireWaterCaravanToVault13(int aiCostCaps)
    if bWaterCaravanHired
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
    Debug.Notification("¡Caravana de los Mercaderes del Agua enviada al Refugio 13! (+100 días de reserva de agua, +10 Aguas Purificadas y +250 XP)")
EndFunction

bool Function IsWaterCaravanHired()
    return bWaterCaravanHired
EndFunction

Function DeliverEvidenceToSheriffGreene()
    if bItemsDeliveredToSheriff
        return
    endif
    bItemsDeliveredToSheriff = True
    Actor player = Game.GetPlayer()
    Form holoBase = Game.GetFormFromFile(0x0000145E, "Vault13Chronicles.esp")
    Form ledgerBase = Game.GetFormFromFile(0x0000145F, "Vault13Chronicles.esp")
    if player != None
        if holoBase != None && player.GetItemCount(holoBase) > 0
            player.RemoveItem(holoBase, player.GetItemCount(holoBase), True, None)
        endif
        if ledgerBase != None && player.GetItemCount(ledgerBase) > 0
            player.RemoveItem(ledgerBase, player.GetItemCount(ledgerBase), True, None)
        endif
    endif
    Actor deckerAct = Game.GetFormFromFile(0x00002710, "Vault13Chronicles.esp") as Actor
    if deckerAct != None && !deckerAct.IsDead()
        deckerAct.DisableNoWait()
    endif
    Actor kaneAct = Game.GetFormFromFile(0x00002711, "Vault13Chronicles.esp") as Actor
    if kaneAct != None && !kaneAct.IsDead()
        kaneAct.DisableNoWait()
    endif
EndFunction

Event OnInit()
    BindHubSyndicateListeners(False)
    Actor player = Game.GetPlayer()
    WorldSpace caliSyn = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    Cell hubUgCell = Game.GetFormFromFile(0x00002700, "Vault13Chronicles.esp") as Cell
    if player != None && ((caliSyn != None && player.GetWorldSpace() == caliSyn) || (hubUgCell != None && player.GetParentCell() == hubUgCell))
        StartTimer(2.5, 807)
    endif
EndEvent

Event OnQuestInit()
    BindHubSyndicateListeners(False)
    Actor player = Game.GetPlayer()
    WorldSpace caliSyn = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    Cell hubUgCell = Game.GetFormFromFile(0x00002700, "Vault13Chronicles.esp") as Cell
    if player != None && ((caliSyn != None && player.GetWorldSpace() == caliSyn) || (hubUgCell != None && player.GetParentCell() == hubUgCell))
        StartTimer(2.5, 807)
    endif
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
    BindHubSyndicateListeners(False)
    Actor player = Game.GetPlayer()
    WorldSpace caliSyn = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    Cell hubUgCell = Game.GetFormFromFile(0x00002700, "Vault13Chronicles.esp") as Cell
    bool inZone = (player != None && ((caliSyn != None && player.GetWorldSpace() == caliSyn) || (hubUgCell != None && player.GetParentCell() == hubUgCell)))
    if inZone
        StartTimer(2.5, 807)
    endif
    if Self.GetStage() >= 20 && !Self.IsCompleted()
        if bMutantHoloRecovered
            tugDeathWaitTicks = 0
            StartTimer(1.5, 806)
        elseif inZone
            StartTimer(2.5, 805)
        endif
    endif
EndEvent

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
    RefreshHubSyndicateLayout()
    if Self.GetStage() >= 20 && !Self.IsCompleted()
        CheckHubSyndicateCompletionState()
    endif
EndEvent

Event ObjectReference.OnItemAdded(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    Form holoBase = Game.GetFormFromFile(0x0000145E, "Vault13Chronicles.esp")
    Form ledgerBase = Game.GetFormFromFile(0x0000145F, "Vault13Chronicles.esp")
    if holoBase != None && akBaseItem == holoBase
        NotifyMutantHolodiskRecovered()
    elseif ledgerBase != None && akBaseItem == ledgerBase
        NotifyDeckerLedgerRecovered()
    endif
EndEvent

Event ObjectReference.OnItemRemoved(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
    Form holoBase = Game.GetFormFromFile(0x0000145E, "Vault13Chronicles.esp")
    Form ledgerBase = Game.GetFormFromFile(0x0000145F, "Vault13Chronicles.esp")
    if holoBase != None && akBaseItem == holoBase
        NotifyMutantHolodiskRecovered()
    elseif ledgerBase != None && akBaseItem == ledgerBase
        NotifyDeckerLedgerRecovered()
    endif
EndEvent

Event OnHit(ObjectReference akTarget, ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked, string asMaterialName)
    if akTarget != None
        RegisterForHitEvent(akTarget)
    endif
    if akTarget == None || akAggressor == None
        return
    endif
    Actor player = Game.GetPlayer()
    Actor aggAct = akAggressor as Actor
    bool isPlayerHit = (player != None && akAggressor == (player as ObjectReference)) || (aggAct != None && aggAct.IsPlayerTeammate())
    if !isPlayerHit
        return
    endif
    Actor deckerAct = Game.GetFormFromFile(0x00002710, "Vault13Chronicles.esp") as Actor
    Actor kaneAct = Game.GetFormFromFile(0x00002711, "Vault13Chronicles.esp") as Actor
    if (deckerAct != None && akTarget == (deckerAct as ObjectReference)) || (kaneAct != None && akTarget == (kaneAct as ObjectReference))
        if Self.GetStage() < 20
            Self.SetStage(20)
        endif
        Faction playerFact = Game.GetFormFromFile(0x0001C21C, "Fallout4.esm") as Faction
        ActorValue aggrAV = Game.GetAggressionAV()
        ActorValue confAV = Game.GetConfidenceAV()
        if deckerAct != None && !deckerAct.IsDead()
            if playerFact != None && deckerAct.IsInFaction(playerFact)
                deckerAct.RemoveFromFaction(playerFact)
            endif
            if aggrAV != None
                deckerAct.SetValue(aggrAV, 2.0)
            endif
            if confAV != None
                deckerAct.SetValue(confAV, 4.0)
            endif
            if player != None && deckerAct.Is3DLoaded()
                deckerAct.StartCombat(player)
            endif
        endif
        if kaneAct != None && !kaneAct.IsDead()
            if playerFact != None && kaneAct.IsInFaction(playerFact)
                kaneAct.RemoveFromFaction(playerFact)
            endif
            if aggrAV != None
                kaneAct.SetValue(aggrAV, 2.0)
            endif
            if confAV != None
                kaneAct.SetValue(confAV, 4.0)
            endif
            if player != None && kaneAct.Is3DLoaded()
                kaneAct.StartCombat(player)
            endif
        endif
    endif
EndEvent

Event Actor.OnDeath(Actor akSender, Actor akKiller)
    Actor deckerAct = Game.GetFormFromFile(0x00002710, "Vault13Chronicles.esp") as Actor
    Actor kaneAct = Game.GetFormFromFile(0x00002711, "Vault13Chronicles.esp") as Actor
    Actor mutantAct = Game.GetFormFromFile(0x000035EB, "Vault13Chronicles.esp") as Actor
    Actor dclawAct = Game.GetFormFromFile(0x000035EA, "Vault13Chronicles.esp") as Actor
    if deckerAct != None && akSender == deckerAct
        if Self.GetStage() < 20
            Self.SetStage(20)
        endif
        NotifyDeckerLedgerRecovered()
    elseif kaneAct != None && akSender == kaneAct
        if Self.GetStage() < 20
            Self.SetStage(20)
        endif
    elseif mutantAct != None && akSender == mutantAct
        NotifyMutantHolodiskRecovered()
    elseif dclawAct != None && akSender == dclawAct && !bDclawDeathNotified
        bDclawDeathNotified = True
        Debug.Notification("¡Has abatido al Sanguinario de las Caravanas! Habla con el Supermutante Moribundo tendido junto a las rocas.")
    endif
EndEvent

Event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
    if akActionRef != Game.GetPlayer()
        return
    endif
    ForceAllHubSyndicateAliases()
    ObjectReference sheriffRef = Game.GetFormFromFile(0x000035E7, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference deckerRef = Game.GetFormFromFile(0x00002710, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference kaneRef = Game.GetFormFromFile(0x00002711, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference mutantRef = Game.GetFormFromFile(0x000035EB, "Vault13Chronicles.esp") as ObjectReference
    Topic hubSynGreeting = Game.GetFormFromFile(0x0001A001, "Vault13Chronicles.esp") as Topic

    if mutantRef != None && akSender == mutantRef
        if Self.GetStage() < 20
            Self.SetStage(20)
        endif
        Actor mutantAct = mutantRef as Actor
        if mutantAct != None
            if mutantAct.IsDead()
                NotifyMutantHolodiskRecovered()
            elseif !bMutantHoloRecovered
                StopAllHubSyndicateScenesExcept(2)
                Debug.Notification("Tug (Supermutante Moribundo): «Ugggh... esa cosa... el monstruo de garras... despedazó los carros... toma... nuestro holodisco...»")
                Scene mutantScn = Game.GetFormFromFile(0x0001A101, "Vault13Chronicles.esp") as Scene
                if mutantScn != None && !mutantScn.IsPlaying()
                    sceneWaitTicks = 0
                    StartTimer(1.2, 802)
                endif
            else
                CheckHubSyndicateCompletionState()
                if !mutantAct.IsDead()
                    tugDeathWaitTicks = 3
                    StartTimer(0.5, 806)
                endif
                Debug.Notification("Tug ha sucumbido a las heridas del Sanguinario tras entregarte el Holodisco. Investiga a Decker en El Halcón Maltés o informa al Sheriff Greene.")
            endif
        endif
    elseif sheriffRef != None && akSender == sheriffRef
        if Self.GetStage() < 20
            Self.SetStage(20)
        endif
        Actor sheriffAct = sheriffRef as Actor
        if sheriffAct != None && !sheriffAct.IsDead()
            StopAllHubSyndicateScenesExcept(3)
            CheckHubSyndicateCompletionState()
            if Self.GetStage() == 30 || (bMutantHoloRecovered && bDeckerResolved && Self.GetStage() < 40)
                if Self.GetStage() < 30
                    Self.SetStage(30)
                endif
                DeliverEvidenceToSheriffGreene()
                if Self.GetStage() < 40
                    Self.SetStage(40)
                endif
            elseif Self.GetStage() < 30
                Scene sheriffScn = Game.GetFormFromFile(0x0001A102, "Vault13Chronicles.esp") as Scene
                if sheriffScn != None && !sheriffScn.IsPlaying()
                    sceneWaitTicks = 0
                    StartTimer(1.2, 803)
                endif
            endif
        endif
    elseif kaneRef != None && akSender == kaneRef
        Actor kaneAct = kaneRef as Actor
        Actor deckerAct = deckerRef as Actor
        if kaneAct != None && !kaneAct.IsDead() && !kaneAct.IsInCombat()
            if Self.GetStage() < 20
                if Self.GetStage() < 15
                    Self.SetStage(15)
                endif
                ForceQuestAlias(0, 0x000035E7)
                if !Self.IsObjectiveDisplayed(15)
                    Self.SetObjectiveDisplayed(15, True, False)
                    Self.SetActive(True)
                endif
                Debug.Notification("Kane (Lugarteniente de Decker): «Aquí no admitimos curiosos sin permiso. Habla primero con el Sheriff Justin Greene en El Eje.»")
                return
            endif
            Debug.Notification("Kane (Lugarteniente de Decker): «En El Halcón Maltés las órdenes las da el señor Decker. Habla con él si valoras tu pellejo.»")
            if deckerAct != None && !deckerAct.IsDead() && !bDeckerResolved
                StopAllHubSyndicateScenesExcept(4)
                sceneWaitTicks = 0
                StartTimer(1.2, 804)
            endif
        endif
    elseif deckerRef != None && akSender == deckerRef
        Actor deckerAct = deckerRef as Actor
        if deckerAct != None
            if deckerAct.IsDead()
                NotifyDeckerLedgerRecovered()
            elseif Self.GetStage() < 20 && !deckerAct.IsInCombat()
                if Self.GetStage() < 15
                    Self.SetStage(15)
                endif
                ForceQuestAlias(0, 0x000035E7)
                if !Self.IsObjectiveDisplayed(15)
                    Self.SetObjectiveDisplayed(15, True, False)
                    Self.SetActive(True)
                endif
                Debug.Notification("Decker: «No pierdo el tiempo con desconocidos del desierto. Consulta al Sheriff Justin Greene en El Eje si quieres negocios aquí.»")
                return
            elseif !bDeckerResolved && !deckerAct.IsInCombat()
                StopAllHubSyndicateScenesExcept(4)
                Scene deckerScn = Game.GetFormFromFile(0x0001A103, "Vault13Chronicles.esp") as Scene
                if deckerScn != None && !deckerScn.IsPlaying()
                    sceneWaitTicks = 0
                    StartTimer(1.2, 804)
                endif
            endif
        endif
    endif
EndEvent

Event OnTimer(int aiTimerID)
    if aiTimerID == 802
        Actor mutantAct = Game.GetFormFromFile(0x000035EB, "Vault13Chronicles.esp") as Actor
        Scene mutantScn = Game.GetFormFromFile(0x0001A101, "Vault13Chronicles.esp") as Scene
        if mutantScn != None && !mutantScn.IsPlaying()
            if !Utility.IsInMenuMode() && (mutantAct == None || (!mutantAct.IsInDialogueWithPlayer() && !mutantAct.IsTalking()))
                ForceQuestAlias(1, 0x000035EB)
                mutantScn.Start()
            elseif sceneWaitTicks < 12
                sceneWaitTicks += 1
                StartTimer(1.5, 802)
            elseif !bMutantHoloRecovered
                NotifyMutantHolodiskRecovered()
            endif
        endif
    elseif aiTimerID == 803
        Actor sheriffAct = Game.GetFormFromFile(0x000035E7, "Vault13Chronicles.esp") as Actor
        Scene sheriffScn = Game.GetFormFromFile(0x0001A102, "Vault13Chronicles.esp") as Scene
        if sheriffScn != None && !sheriffScn.IsPlaying()
            if !Utility.IsInMenuMode() && (sheriffAct == None || (!sheriffAct.IsInDialogueWithPlayer() && !sheriffAct.IsTalking()))
                ForceQuestAlias(0, 0x000035E7)
                sheriffScn.Start()
            elseif sceneWaitTicks < 10
                sceneWaitTicks += 1
                StartTimer(1.5, 803)
            endif
        endif
    elseif aiTimerID == 804
        Actor deckerAct = Game.GetFormFromFile(0x00002710, "Vault13Chronicles.esp") as Actor
        Scene deckerScn = Game.GetFormFromFile(0x0001A103, "Vault13Chronicles.esp") as Scene
        if deckerScn != None && !deckerScn.IsPlaying()
            if !Utility.IsInMenuMode() && (deckerAct == None || (!deckerAct.IsInDialogueWithPlayer() && !deckerAct.IsTalking()))
                ForceQuestAlias(10, 0x00002710)
                deckerScn.Start()
            elseif sceneWaitTicks < 10
                sceneWaitTicks += 1
                StartTimer(1.5, 804)
            endif
        endif
    elseif aiTimerID == 805
        CheckHubSyndicateCompletionState()
    elseif aiTimerID == 806
        Actor mutantAct806 = Game.GetFormFromFile(0x000035EB, "Vault13Chronicles.esp") as Actor
        Scene mutantScn806 = Game.GetFormFromFile(0x0001A101, "Vault13Chronicles.esp") as Scene
        if mutantAct806 != None && mutantAct806.IsTalking() && tugDeathWaitTicks < 3
            tugDeathWaitTicks += 1
            StartTimer(1.0, 806)
        else
            if mutantScn806 != None && mutantScn806.IsPlaying()
                mutantScn806.Stop()
            endif
            SetObjectiveCompleted(20, True)
            ClearQuestAlias(1)
            if mutantAct806 != None && !mutantAct806.IsDead()
                ActorBase tugBase = mutantAct806.GetBaseObject() as ActorBase
                if tugBase != None
                    tugBase.SetEssential(False)
                endif
                mutantAct806.KillEssential()
            endif
            CheckHubSyndicateCompletionState()
        endif
    elseif aiTimerID == 807
        RefreshHubSyndicateLayout()
        if Self.GetStage() >= 20 && !Self.IsCompleted()
            CheckHubSyndicateCompletionState()
        endif
    elseif aiTimerID == 810
        if Self.GetStage() < 40
            Self.SetStage(40)
        endif
    endif
EndEvent

Event OnStageSet(int auiStageID, int auiItemID)
    bool doStage40Reward = False
    if auiStageID == 15
        if bStg15Done
            return
        endif
        bStg15Done = True
    elseif auiStageID == 20
        if bStg20Done
            return
        endif
        bStg20Done = True
    elseif auiStageID == 26
        if bStg26Done
            return
        endif
        bStg26Done = True
    elseif auiStageID == 28
        if bStg28Done
            return
        endif
        bStg28Done = True
    elseif auiStageID == 30
        if bStg30Done
            return
        endif
        bStg30Done = True
    elseif auiStageID == 40
        if bRewardGranted && bFinalRewardGranted
            FinalizeHubSyndicateQuestCleanly()
            return
        endif
        if !bRewardGranted && !bFinalRewardGranted
            bRewardGranted = True
            bFinalRewardGranted = True
            doStage40Reward = True
        endif
    endif

    BindHubSyndicateListeners()
    Actor player = Game.GetPlayer()

    if auiStageID == 15
        ForceQuestAlias(0, 0x000035E7)
        if !Self.IsObjectiveDisplayed(15)
            Self.SetObjectiveDisplayed(15, True, False)
        endif
        Self.SetActive(True)
    elseif auiStageID == 20
        ForceAllHubSyndicateAliases()
        SetObjectiveCompleted(15, True)
        if !bMutantHoloRecovered && !Self.IsObjectiveDisplayed(20)
            Self.SetObjectiveDisplayed(20, True, False)
        endif
        if !bDeckerResolved && !Self.IsObjectiveDisplayed(21)
            Self.SetObjectiveDisplayed(21, True, False)
        endif
        Self.SetActive(True)
        Debug.Notification("Misión Secundaria: El Submundo y las Caravanas de El Eje — Investiga al Supermutante Moribundo en el Cruce del Oeste y desmantela el sindicato de Decker en El Halcón Maltés.")
        CheckHubSyndicateCompletionState()
    elseif auiStageID == 21
        HireWaterCaravanToVault13(1000)
    elseif auiStageID == 22
        HireWaterCaravanToVault13(2000)
    elseif auiStageID == 25
        NotifyMutantHolodiskRecovered()
    elseif auiStageID == 26
        Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
        if player != None && caps != None
            player.AddItem(caps, 300, False)
        endif
        NotifyDeckerLedgerRecovered()
    elseif auiStageID == 27
        NotifyDeckerLedgerRecovered()
    elseif auiStageID == 28
        Scene deckerScn = Game.GetFormFromFile(0x0001A103, "Vault13Chronicles.esp") as Scene
        if deckerScn != None && deckerScn.IsPlaying()
            deckerScn.Stop()
        endif
        Faction raiderFact = Game.GetFormFromFile(0x0001CBED, "Fallout4.esm") as Faction
        Actor deckerAct = Game.GetFormFromFile(0x00002710, "Vault13Chronicles.esp") as Actor
        Actor kaneAct = Game.GetFormFromFile(0x00002711, "Vault13Chronicles.esp") as Actor
        if deckerAct != None && !deckerAct.IsDead()
            if raiderFact != None
                deckerAct.AddToFaction(raiderFact)
            endif
            deckerAct.SetValue(Game.GetAggressionAV(), 2.0)
            if player != None && !player.IsDead()
                deckerAct.StartCombat(player)
            endif
        endif
        if kaneAct != None && !kaneAct.IsDead()
            if raiderFact != None
                kaneAct.AddToFaction(raiderFact)
            endif
            kaneAct.SetValue(Game.GetAggressionAV(), 2.0)
            if player != None && !player.IsDead()
                kaneAct.StartCombat(player)
            endif
        endif
        Debug.Notification("¡Decker y Kane han abierto fuego en El Halcón Maltés! Abátelos y recupera el Libro Mayor del Submundo.")
    elseif auiStageID == 30
        SetObjectiveCompleted(15, True)
        SetObjectiveCompleted(20, True)
        SetObjectiveCompleted(21, True)
        ClearQuestAlias(1)
        ClearQuestAlias(10)
        ForceQuestAlias(0, 0x000035E7)
        if !Self.IsObjectiveDisplayed(30)
            Self.SetObjectiveDisplayed(30, True, False)
        endif
        Self.SetActive(True)
        Debug.Notification("¡Tienes el Holodisco de Transmisiones Mutantes y el Libro Mayor de Decker! Entrégaselos al Sheriff Justin Greene en El Eje.")
    elseif auiStageID == 40
        if !bItemsDeliveredToSheriff
            DeliverEvidenceToSheriffGreene()
        endif
        if doStage40Reward
            Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
            Form rifle = Game.GetFormFromFile(0x000DF42E, "Fallout4.esm")
            Form a308 = Game.GetFormFromFile(0x0001F66B, "Fallout4.esm")
            Form stim = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
            if player != None
                if caps != None
                    player.AddItem(caps, 750, False)
                endif
                if rifle != None
                    player.AddItem(rifle, 1, False)
                endif
                if a308 != None
                    player.AddItem(a308, 48, False)
                endif
                if stim != None
                    player.AddItem(stim, 5, False)
                endif
            endif
            Game.RewardPlayerXP(500)
            Debug.Notification("¡Misión Secundaria completada: Las Caravanas Desaparecidas y el Submundo de El Eje! (+750 Chapas, Rifle, Munición .308 y +500 XP)")
        endif
        FinalizeHubSyndicateQuestCleanly()
    endif
EndEvent
