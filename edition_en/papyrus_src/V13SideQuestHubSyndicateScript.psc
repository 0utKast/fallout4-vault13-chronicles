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
    Actor deckerAct = Game.GetFormFromFile(0x000035E8, "Vault13Chronicles.esp") as Actor

    if player != None
        if holoBase != None && player.GetItemCount(holoBase) > 0
            bMutantHoloRecovered = True
        endif
        if ledgerBase != None && player.GetItemCount(ledgerBase) > 0
            bDeckerResolved = True
        endif
    endif
    if bItemsDeliveredToSheriff
        bMutantHoloRecovered = True
        bDeckerResolved = True
    endif
    if Self.GetStage() == 25
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
    if Self.IsCompleted() || Self.GetStage() >= 40
        FinalizeHubSyndicateQuestCleanly()
        return
    endif

    Scene mutantScn = Game.GetFormFromFile(0x0001A101, "Vault13Chronicles.esp") as Scene
    Scene deckerScn = Game.GetFormFromFile(0x0001A103, "Vault13Chronicles.esp") as Scene
    ForceQuestAlias(0, 0x000035E7)
    if !bMutantHoloRecovered
        ForceQuestAlias(1, 0x000035EB)
    elseif mutantScn == None || !mutantScn.IsPlaying()
        ClearQuestAlias(1)
    endif
    ForceQuestAlias(2, 0x00003005)
    ForceQuestAlias(3, 0x00002003)
    ForceQuestAlias(4, 0x0000351D)
    ForceQuestAlias(5, 0x00002101)
    ForceQuestAlias(6, 0x00003501)
    ForceQuestAlias(7, 0x00002206)
    ForceQuestAlias(8, 0x00002035)
    ForceQuestAlias(9, 0x000035E6)
    if !bDeckerResolved
        ForceQuestAlias(10, 0x000035E8)
    elseif deckerScn == None || !deckerScn.IsPlaying()
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
    Scene marthaScn = Game.GetFormFromFile(0x0001A100, "Vault13Chronicles.esp") as Scene
    Scene mutantScn = Game.GetFormFromFile(0x0001A101, "Vault13Chronicles.esp") as Scene
    Scene sheriffScn = Game.GetFormFromFile(0x0001A102, "Vault13Chronicles.esp") as Scene
    Scene deckerScn = Game.GetFormFromFile(0x0001A103, "Vault13Chronicles.esp") as Scene
    if aiKeepSceneIdx != 1 && marthaScn != None && marthaScn.IsPlaying()
        marthaScn.Stop()
    endif
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
    Actor marthaAct = Game.GetFormFromFile(0x000035E6, "Vault13Chronicles.esp") as Actor
    if marthaAct != None && !marthaAct.IsDead()
        if marthaAct.IsDisabled()
            marthaAct.EnableNoWait()
        endif
        if marthaAct.Is3DLoaded() && !marthaAct.IsInCombat()
            marthaAct.AllowPCDialogue(True)
            marthaAct.BlockActivation(False, False)
            if !marthaAct.IsTalking() && (Math.Abs(marthaAct.GetPositionX() + 760.0) > 45.0 || Math.Abs(marthaAct.GetPositionY() + 4250.0) > 45.0)
                marthaAct.SetPosition(-760.0, -4250.0, 80.0)
                marthaAct.SetAngle(0.0, 0.0, 0.0)
                marthaAct.EvaluatePackage()
            endif
            EquipHubSyndicateActorGear(marthaAct, 0x00001033, 0x001B5F1B, 0, 0x000E5084)
        endif
    endif

    Actor sheriffAct = Game.GetFormFromFile(0x000035E7, "Vault13Chronicles.esp") as Actor
    if sheriffAct != None && !sheriffAct.IsDead()
        if sheriffAct.IsDisabled()
            sheriffAct.EnableNoWait()
        endif
        if sheriffAct.Is3DLoaded() && !sheriffAct.IsInCombat()
            sheriffAct.AllowPCDialogue(True)
            sheriffAct.BlockActivation(False, False)
            if !sheriffAct.IsTalking() && (Math.Abs(sheriffAct.GetPositionX() + 1040.0) > 45.0 || Math.Abs(sheriffAct.GetPositionY() + 4020.0) > 45.0)
                sheriffAct.SetPosition(-1040.0, -4020.0, 80.0)
                sheriffAct.SetAngle(0.0, 0.0, 45.0)
                sheriffAct.EvaluatePackage()
            endif
            EquipHubSyndicateActorGear(sheriffAct, 0x00001034, 0x00237680, 0x0023767F, 0x0016892C)
        endif
    endif

    Actor deckerAct = Game.GetFormFromFile(0x000035E8, "Vault13Chronicles.esp") as Actor
    Form ledgerBase = Game.GetFormFromFile(0x0000145F, "Vault13Chronicles.esp")
    Form dossierBase = Game.GetFormFromFile(0x00001C87, "Vault13Chronicles.esp")
    Actor player = Game.GetPlayer()
    if deckerAct != None
        if deckerAct.IsDisabled() && Self.GetStage() < 40
            deckerAct.EnableNoWait()
        endif
        if !deckerAct.IsDead() && deckerAct.Is3DLoaded() && !deckerAct.IsInCombat()
            deckerAct.AllowPCDialogue(True)
            deckerAct.BlockActivation(False, False)
            if !deckerAct.IsTalking() && (Math.Abs(deckerAct.GetPositionX() + 1390.0) > 45.0 || Math.Abs(deckerAct.GetPositionY() + 4200.0) > 45.0)
                deckerAct.SetPosition(-1390.0, -4200.0, 80.0)
                deckerAct.SetAngle(0.0, 0.0, 90.0)
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

    Actor kaneAct = Game.GetFormFromFile(0x000035E9, "Vault13Chronicles.esp") as Actor
    if kaneAct != None && !kaneAct.IsDead()
        if kaneAct.IsDisabled() && Self.GetStage() < 40
            kaneAct.EnableNoWait()
        endif
        if kaneAct.Is3DLoaded() && !kaneAct.IsInCombat()
            kaneAct.BlockActivation(False, False)
            if !kaneAct.IsTalking() && (Math.Abs(kaneAct.GetPositionX() + 1340.0) > 45.0 || Math.Abs(kaneAct.GetPositionY() + 4100.0) > 45.0)
                kaneAct.SetPosition(-1340.0, -4100.0, 80.0)
                kaneAct.SetAngle(0.0, 0.0, 90.0)
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
        if dclawAct.Is3DLoaded()
            if !dclawAct.IsInCombat() && (Math.Abs(dclawAct.GetPositionX() + 4720.0) > 650.0 || Math.Abs(dclawAct.GetPositionY() + 6080.0) > 650.0)
                dclawAct.SetPosition(-4720.0, -6080.0, 102.0)
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
            if Math.Abs(mutantAct.GetPositionX() + 5020.0) > 450.0 || Math.Abs(mutantAct.GetPositionY() + 6320.0) > 450.0
                mutantAct.SetPosition(-5020.0, -6320.0, 102.0)
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

Function BindHubSyndicateListeners()
    Actor player = Game.GetPlayer()
    Form contractBase = Game.GetFormFromFile(0x0000145D, "Vault13Chronicles.esp")
    Form holoBase = Game.GetFormFromFile(0x0000145E, "Vault13Chronicles.esp")
    Form ledgerBase = Game.GetFormFromFile(0x0000145F, "Vault13Chronicles.esp")
    Self.RemoveAllInventoryEventFilters()
    if contractBase != None
        Self.AddInventoryEventFilter(contractBase)
    endif
    if holoBase != None
        Self.AddInventoryEventFilter(holoBase)
    endif
    if ledgerBase != None
        Self.AddInventoryEventFilter(ledgerBase)
    endif
    if player != None
        RegisterForRemoteEvent(player, "OnPlayerLoadGame")
        RegisterForRemoteEvent(player, "OnLocationChange")
        if contractBase != None || holoBase != None || ledgerBase != None
            RegisterForRemoteEvent(player as ObjectReference, "OnItemAdded")
        endif
    endif

    ForceAllHubSyndicateAliases()
    RefreshHubSyndicateLayout()

    ObjectReference marthaRef = Game.GetFormFromFile(0x000035E6, "Vault13Chronicles.esp") as ObjectReference
    if marthaRef != None
        RegisterForRemoteEvent(marthaRef, "OnActivate")
    endif
    ObjectReference sheriffRef = Game.GetFormFromFile(0x000035E7, "Vault13Chronicles.esp") as ObjectReference
    if sheriffRef != None
        RegisterForRemoteEvent(sheriffRef, "OnActivate")
    endif
    Actor deckerAct = Game.GetFormFromFile(0x000035E8, "Vault13Chronicles.esp") as Actor
    if deckerAct != None
        RegisterForRemoteEvent(deckerAct as ObjectReference, "OnActivate")
        if ledgerBase != None
            RegisterForRemoteEvent(deckerAct as ObjectReference, "OnItemRemoved")
        endif
        RegisterForRemoteEvent(deckerAct, "OnDeath")
    endif
    Actor kaneAct = Game.GetFormFromFile(0x000035E9, "Vault13Chronicles.esp") as Actor
    if kaneAct != None
        RegisterForRemoteEvent(kaneAct as ObjectReference, "OnActivate")
        RegisterForRemoteEvent(kaneAct, "OnDeath")
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
    if Self.IsCompleted() || Self.GetStage() >= 40
        FinalizeHubSyndicateQuestCleanly()
        return
    endif

    Scene mutantScn = Game.GetFormFromFile(0x0001A101, "Vault13Chronicles.esp") as Scene
    Scene deckerScn = Game.GetFormFromFile(0x0001A103, "Vault13Chronicles.esp") as Scene

    if bMutantHoloRecovered
        SetObjectiveCompleted(20, True)
        if mutantScn == None || !mutantScn.IsPlaying()
            ClearQuestAlias(1)
        endif
    elseif Self.GetStage() >= 20
        ForceQuestAlias(1, 0x000035EB)
        if !Self.IsObjectiveDisplayed(20)
            Self.SetObjectiveDisplayed(20, True, False)
        endif
    endif

    if bDeckerResolved
        SetObjectiveCompleted(21, True)
        if deckerScn == None || !deckerScn.IsPlaying()
            ClearQuestAlias(10)
        endif
    elseif Self.GetStage() >= 20
        ForceQuestAlias(10, 0x000035E8)
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
    if Self.GetStage() < 20
        Self.SetStage(20)
    endif
    if Self.GetStage() < 25 && !bDeckerResolved
        Self.SetStage(25)
    endif
    Game.RewardPlayerXP(200)
    Debug.Notification("Mutant Transmissions Holodisk obtained! Proof that northern Super Mutant patrols are ambushing the caravans (+200 XP).")
    CheckHubSyndicateCompletionState()
    tugDeathWaitTicks = 0
    StartTimer(2.0, 806)
EndFunction

Function NotifyDeckerLedgerRecovered()
    if bDeckerResolved
        CheckHubSyndicateCompletionState()
        return
    endif
    bDeckerResolved = True
    Actor player = Game.GetPlayer()
    Actor deckerAct = Game.GetFormFromFile(0x000035E8, "Vault13Chronicles.esp") as Actor
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
    Game.RewardPlayerXP(200)
    Debug.Notification("Decker's Underground Ledger obtained! Deliver it to Sheriff Justin Greene in The Hub (+200 XP).")
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
    Debug.Notification("Water Merchants Caravan dispatched to Vault 13! (+100 days of water reserves, +10 Purified Water, and +250 XP)")
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
    Actor deckerAct = Game.GetFormFromFile(0x000035E8, "Vault13Chronicles.esp") as Actor
    if deckerAct != None && !deckerAct.IsDead()
        deckerAct.DisableNoWait()
    endif
    Actor kaneAct = Game.GetFormFromFile(0x000035E9, "Vault13Chronicles.esp") as Actor
    if kaneAct != None && !kaneAct.IsDead()
        kaneAct.DisableNoWait()
    endif
EndFunction

Event OnInit()
    BindHubSyndicateListeners()
EndEvent

Event OnQuestInit()
    BindHubSyndicateListeners()
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
    BindHubSyndicateListeners()
    if Self.GetStage() >= 20 && !Self.IsCompleted()
        CheckHubSyndicateCompletionState()
        if bMutantHoloRecovered
            tugDeathWaitTicks = 0
            StartTimer(1.0, 806)
        endif
    endif
EndEvent

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
    RefreshHubSyndicateLayout()
    if Self.GetStage() >= 20 && !Self.IsCompleted()
        CheckHubSyndicateCompletionState()
    endif
    Actor player = Game.GetPlayer()
    if player != None && bWaterCaravanHired && !bJacorenWaterReactionShown
        Cell v13Cell = Game.GetFormFromFile(0x00002100, "Vault13Chronicles.esp") as Cell
        if v13Cell != None && player.GetParentCell() == v13Cell
            bJacorenWaterReactionShown = True
            Form pureWater = Game.GetFormFromFile(0x000366C0, "Fallout4.esm")
            if pureWater != None
                player.AddItem(pureWater, 6, False)
            endif
            Game.RewardPlayerXP(150)
            Debug.Notification("Overseer Jacoren: 'The Water Merchants' barrels have bought Vault 13 another 100 days, but pray nobody followed their tracks.' (+150 XP)")
        endif
    endif
EndEvent

Event ObjectReference.OnItemAdded(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    Form contractBase = Game.GetFormFromFile(0x0000145D, "Vault13Chronicles.esp")
    Form holoBase = Game.GetFormFromFile(0x0000145E, "Vault13Chronicles.esp")
    Form ledgerBase = Game.GetFormFromFile(0x0000145F, "Vault13Chronicles.esp")
    if contractBase != None && akBaseItem == contractBase
        bWaterCaravanHired = True
    elseif holoBase != None && akBaseItem == holoBase
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

Event Actor.OnDeath(Actor akSender, Actor akKiller)
    Actor deckerAct = Game.GetFormFromFile(0x000035E8, "Vault13Chronicles.esp") as Actor
    Actor mutantAct = Game.GetFormFromFile(0x000035EB, "Vault13Chronicles.esp") as Actor
    Actor dclawAct = Game.GetFormFromFile(0x000035EA, "Vault13Chronicles.esp") as Actor
    if deckerAct != None && akSender == deckerAct
        NotifyDeckerLedgerRecovered()
    elseif mutantAct != None && akSender == mutantAct
        NotifyMutantHolodiskRecovered()
    elseif dclawAct != None && akSender == dclawAct && !bDclawDeathNotified
        bDclawDeathNotified = True
        Debug.Notification("You slew the Caravan Deathclaw! Speak with the Dying Super Mutant lying beside the rocks.")
    endif
EndEvent

Event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
    if akActionRef != Game.GetPlayer()
        return
    endif
    ForceAllHubSyndicateAliases()
    ObjectReference marthaRef = Game.GetFormFromFile(0x000035E6, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference sheriffRef = Game.GetFormFromFile(0x000035E7, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference deckerRef = Game.GetFormFromFile(0x000035E8, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference kaneRef = Game.GetFormFromFile(0x000035E9, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference mutantRef = Game.GetFormFromFile(0x000035EB, "Vault13Chronicles.esp") as ObjectReference
    Topic hubSynGreeting = Game.GetFormFromFile(0x0001A001, "Vault13Chronicles.esp") as Topic

    if Self.GetStage() < 20
        Self.SetStage(20)
    endif

    if marthaRef != None && akSender == marthaRef
        Actor marthaAct = marthaRef as Actor
        if marthaAct != None && !marthaAct.IsDead()
            StopAllHubSyndicateScenesExcept(1)
            if hubSynGreeting != None && !marthaAct.IsTalking()
                marthaAct.Say(hubSynGreeting, None, false, None)
            endif
            Scene marthaScn = Game.GetFormFromFile(0x0001A100, "Vault13Chronicles.esp") as Scene
            if !bWaterCaravanHired && marthaScn != None && !marthaScn.IsPlaying()
                sceneWaitTicks = 0
                StartTimer(0.6, 801)
            endif
        endif
    elseif mutantRef != None && akSender == mutantRef
        Actor mutantAct = mutantRef as Actor
        if mutantAct != None
            if mutantAct.IsDead()
                NotifyMutantHolodiskRecovered()
            elseif !bMutantHoloRecovered
                StopAllHubSyndicateScenesExcept(2)
                if hubSynGreeting != None && !mutantAct.IsTalking()
                    mutantAct.Say(hubSynGreeting, None, false, None)
                endif
                Debug.Notification("Tug (Dying Super Mutant): 'Ugggh... that thing... the clawed monster... tore the wagons apart... take... our holodisk...'")
                Scene mutantScn = Game.GetFormFromFile(0x0001A101, "Vault13Chronicles.esp") as Scene
                if mutantScn != None && !mutantScn.IsPlaying()
                    sceneWaitTicks = 0
                    StartTimer(0.6, 802)
                endif
                StartTimer(45.0, 805)
            else
                CheckHubSyndicateCompletionState()
                if !mutantAct.IsDead()
                    tugDeathWaitTicks = 20
                    StartTimer(0.5, 806)
                endif
                Debug.Notification("Tug succumbed to his Deathclaw wounds after handing you the Holodisk. Investigate Decker at The Maltese Falcon or report to Sheriff Greene.")
            endif
        endif
    elseif sheriffRef != None && akSender == sheriffRef
        Actor sheriffAct = sheriffRef as Actor
        if sheriffAct != None && !sheriffAct.IsDead()
            StopAllHubSyndicateScenesExcept(3)
            CheckHubSyndicateCompletionState()
            if Self.GetStage() == 30 || (bMutantHoloRecovered && bDeckerResolved && Self.GetStage() < 40)
                if Self.GetStage() < 30
                    Self.SetStage(30)
                endif
                if hubSynGreeting != None && !sheriffAct.IsTalking()
                    sheriffAct.Say(hubSynGreeting, None, false, None)
                endif
                DeliverEvidenceToSheriffGreene()
                if Self.GetStage() < 40
                    Self.SetStage(40)
                endif
            elseif Self.GetStage() < 30
                if hubSynGreeting != None && !sheriffAct.IsTalking()
                    sheriffAct.Say(hubSynGreeting, None, false, None)
                endif
                Scene sheriffScn = Game.GetFormFromFile(0x0001A102, "Vault13Chronicles.esp") as Scene
                if sheriffScn != None && !sheriffScn.IsPlaying()
                    sceneWaitTicks = 0
                    StartTimer(0.6, 803)
                endif
            endif
        endif
    elseif kaneRef != None && akSender == kaneRef
        Actor kaneAct = kaneRef as Actor
        Actor deckerAct = deckerRef as Actor
        if kaneAct != None && !kaneAct.IsDead() && !kaneAct.IsInCombat()
            Debug.Notification("Kane (Decker's Lieutenant): 'Inside The Maltese Falcon, Mr. Decker gives the orders. Speak with him if you value your hide.'")
            if deckerAct != None && !deckerAct.IsDead() && !bDeckerResolved
                StopAllHubSyndicateScenesExcept(4)
                if hubSynGreeting != None && !deckerAct.IsTalking()
                    deckerAct.Say(hubSynGreeting, None, false, None)
                endif
                sceneWaitTicks = 0
                StartTimer(0.6, 804)
            endif
        endif
    elseif deckerRef != None && akSender == deckerRef
        Actor deckerAct = deckerRef as Actor
        if deckerAct != None
            if deckerAct.IsDead()
                NotifyDeckerLedgerRecovered()
            elseif !bDeckerResolved && !deckerAct.IsInCombat()
                StopAllHubSyndicateScenesExcept(4)
                if hubSynGreeting != None && !deckerAct.IsTalking()
                    deckerAct.Say(hubSynGreeting, None, false, None)
                endif
                Scene deckerScn = Game.GetFormFromFile(0x0001A103, "Vault13Chronicles.esp") as Scene
                if deckerScn != None && !deckerScn.IsPlaying()
                    sceneWaitTicks = 0
                    StartTimer(0.6, 804)
                endif
            endif
        endif
    endif
EndEvent

Event OnTimer(int aiTimerID)
    if aiTimerID == 801
        Actor marthaAct = Game.GetFormFromFile(0x000035E6, "Vault13Chronicles.esp") as Actor
        Scene marthaScn = Game.GetFormFromFile(0x0001A100, "Vault13Chronicles.esp") as Scene
        if marthaScn != None && !marthaScn.IsPlaying()
            if marthaAct != None && marthaAct.IsTalking() && sceneWaitTicks < 14
                sceneWaitTicks += 1
                StartTimer(0.5, 801)
            else
                ForceQuestAlias(9, 0x000035E6)
                marthaScn.Start()
            endif
        endif
    elseif aiTimerID == 802
        Actor mutantAct = Game.GetFormFromFile(0x000035EB, "Vault13Chronicles.esp") as Actor
        Scene mutantScn = Game.GetFormFromFile(0x0001A101, "Vault13Chronicles.esp") as Scene
        if mutantScn != None && !mutantScn.IsPlaying()
            if mutantAct != None && mutantAct.IsTalking() && sceneWaitTicks < 14
                sceneWaitTicks += 1
                StartTimer(0.5, 802)
            else
                ForceQuestAlias(1, 0x000035EB)
                mutantScn.Start()
            endif
        endif
    elseif aiTimerID == 803
        Actor sheriffAct = Game.GetFormFromFile(0x000035E7, "Vault13Chronicles.esp") as Actor
        Scene sheriffScn = Game.GetFormFromFile(0x0001A102, "Vault13Chronicles.esp") as Scene
        if sheriffScn != None && !sheriffScn.IsPlaying()
            if sheriffAct != None && sheriffAct.IsTalking() && sceneWaitTicks < 14
                sceneWaitTicks += 1
                StartTimer(0.5, 803)
            else
                ForceQuestAlias(0, 0x000035E7)
                sheriffScn.Start()
            endif
        endif
    elseif aiTimerID == 804
        Actor deckerAct = Game.GetFormFromFile(0x000035E8, "Vault13Chronicles.esp") as Actor
        Scene deckerScn = Game.GetFormFromFile(0x0001A103, "Vault13Chronicles.esp") as Scene
        if deckerScn != None && !deckerScn.IsPlaying()
            if deckerAct != None && deckerAct.IsTalking() && sceneWaitTicks < 14
                sceneWaitTicks += 1
                StartTimer(0.5, 804)
            else
                ForceQuestAlias(10, 0x000035E8)
                deckerScn.Start()
            endif
        endif
    elseif aiTimerID == 805
        if !bMutantHoloRecovered
            Scene mutantScn805 = Game.GetFormFromFile(0x0001A101, "Vault13Chronicles.esp") as Scene
            if mutantScn805 != None && mutantScn805.IsPlaying()
                StartTimer(15.0, 805)
            else
                NotifyMutantHolodiskRecovered()
            endif
        endif
    elseif aiTimerID == 806
        Actor mutantAct806 = Game.GetFormFromFile(0x000035EB, "Vault13Chronicles.esp") as Actor
        Scene mutantScn806 = Game.GetFormFromFile(0x0001A101, "Vault13Chronicles.esp") as Scene
        if ((mutantScn806 != None && mutantScn806.IsPlaying()) || (mutantAct806 != None && mutantAct806.IsTalking())) && tugDeathWaitTicks < 20
            tugDeathWaitTicks += 1
            StartTimer(1.5, 806)
        else
            if mutantScn806 != None && mutantScn806.IsPlaying()
                mutantScn806.Stop()
            endif
            SetObjectiveCompleted(20, True)
            ClearQuestAlias(1)
            if mutantAct806 != None && !mutantAct806.IsDead()
                mutantAct806.KillEssential()
            endif
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
        Debug.Notification("Side Quest: The Missing Caravans & The Hub Underground - Investigate the Dying Super Mutant at the Western Crossing and dismantle Decker's syndicate at The Maltese Falcon.")
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
        Actor deckerAct = Game.GetFormFromFile(0x000035E8, "Vault13Chronicles.esp") as Actor
        Actor kaneAct = Game.GetFormFromFile(0x000035E9, "Vault13Chronicles.esp") as Actor
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
        Debug.Notification("Decker and Kane opened fire inside The Maltese Falcon! Take them down and recover the Underground Ledger.")
    elseif auiStageID == 30
        SetObjectiveCompleted(15, True)
        SetObjectiveCompleted(20, True)
        SetObjectiveCompleted(21, True)
        Scene mutantScn30 = Game.GetFormFromFile(0x0001A101, "Vault13Chronicles.esp") as Scene
        Scene deckerScn30 = Game.GetFormFromFile(0x0001A103, "Vault13Chronicles.esp") as Scene
        if mutantScn30 == None || !mutantScn30.IsPlaying()
            ClearQuestAlias(1)
        endif
        if deckerScn30 == None || !deckerScn30.IsPlaying()
            ClearQuestAlias(10)
        endif
        ForceQuestAlias(0, 0x000035E7)
        if !Self.IsObjectiveDisplayed(30)
            Self.SetObjectiveDisplayed(30, True, False)
        endif
        Self.SetActive(True)
        Debug.Notification("You have both the Mutant Transmissions Holodisk and Decker's Ledger! Deliver them to Sheriff Justin Greene in The Hub.")
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
            Debug.Notification("Side Quest completed: The Missing Caravans & The Hub Underground! (+750 Caps, Rifle, .308 Ammo, and +500 XP)")
        endif
        FinalizeHubSyndicateQuestCleanly()
    endif
EndEvent
