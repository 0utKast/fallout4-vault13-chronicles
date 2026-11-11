Scriptname V13SideQuestJunktownSyndicateScript extends Quest

bool bGizmoResolved = False
bool bUrnRecovered = False
bool bUrnReturnedToNeal = False
bool bDocMorbidExposed = False
bool bFinalRewardGranted = False
bool bRewardGranted = False
bool bStg15Done = False
bool bStg20Done = False
bool bStg24Done = False
bool bStg28Done = False
bool bStg30Done = False
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

Function SyncSyndicateProgressFlags()
    Actor player = Game.GetPlayer()
    Form tapeBase = Game.GetFormFromFile(0x0000145A, "Vault13Chronicles.esp")
    Form urnBase = Game.GetFormFromFile(0x0000145B, "Vault13Chronicles.esp")
    Actor gizmoAct = Game.GetFormFromFile(0x000035DE, "Vault13Chronicles.esp") as Actor
    Actor vinnieAct = Game.GetFormFromFile(0x000035EC, "Vault13Chronicles.esp") as Actor
    Quest killianQ = Game.GetFormFromFile(0x00010000, "Vault13Chronicles.esp") as Quest

    if player != None
        if tapeBase != None && player.GetItemCount(tapeBase) > 0
            bGizmoResolved = True
        endif
        if urnBase != None && player.GetItemCount(urnBase) > 0
            bUrnRecovered = True
        endif
    endif
    if bUrnReturnedToNeal
        bUrnRecovered = True
    endif
    if gizmoAct != None && gizmoAct.IsDead()
        bGizmoResolved = True
    endif
    if vinnieAct != None && vinnieAct.IsDead()
        bUrnRecovered = True
    endif
    if killianQ != None && (killianQ.IsCompleted() || killianQ.GetStage() >= 40) && bUrnRecovered
        bGizmoResolved = True
    endif
EndFunction

Function FinalizeSyndicateQuestCleanly()
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

Function ForceAllSyndicateAliases()
    SyncSyndicateProgressFlags()
    if Self.IsCompleted() || Self.GetStage() >= 40 || (bFinalRewardGranted && bUrnReturnedToNeal)
        if Self.GetStage() < 40
            Self.SetStage(40)
        endif
        FinalizeSyndicateQuestCleanly()
        return
    endif

    Scene gizmoScn = Game.GetFormFromFile(0x00019100, "Vault13Chronicles.esp") as Scene
    Scene vinnieScn = Game.GetFormFromFile(0x00019102, "Vault13Chronicles.esp") as Scene
    ForceQuestAlias(0, 0x000035DC)
    if !bGizmoResolved
        ForceQuestAlias(1, 0x000035DE)
    elseif gizmoScn == None || !gizmoScn.IsPlaying()
        ClearQuestAlias(1)
    endif
    ForceQuestAlias(2, 0x00003005)
    ForceQuestAlias(3, 0x00002003)
    ForceQuestAlias(4, 0x0000351C)
    ForceQuestAlias(5, 0x00002101)
    ForceQuestAlias(6, 0x00003501)
    ForceQuestAlias(7, 0x00002206)
    ForceQuestAlias(8, 0x00002035)
    if !bUrnRecovered
        ForceQuestAlias(9, 0x000035EC)
    elseif vinnieScn == None || !vinnieScn.IsPlaying()
        ClearQuestAlias(9)
    endif
    ForceQuestAlias(10, 0x000035DD)
EndFunction

Function StartJunktownSyndicateQuest()
    BindSyndicateListeners()
    if Self.GetStage() < 15
        Self.SetStage(15)
    endif
EndFunction

Function CheckLarsSyndicateReward()
    SyncSyndicateProgressFlags()
    if bGizmoResolved
        if Self.IsObjectiveDisplayed(21)
            SetObjectiveCompleted(21, True)
        endif
        ClearQuestAlias(1)
        if bUrnRecovered && !bFinalRewardGranted
            if !bUrnReturnedToNeal
                DeliverUrnToNeal()
            endif
            GrantSyndicateFinalReward()
        endif
    endif
EndFunction

Function StopAllSyndicateScenesExcept(int aiKeepSceneIdx)
    Scene gizmoScn = Game.GetFormFromFile(0x00019100, "Vault13Chronicles.esp") as Scene
    Scene nealScn = Game.GetFormFromFile(0x00019101, "Vault13Chronicles.esp") as Scene
    Scene vinnieScn = Game.GetFormFromFile(0x00019102, "Vault13Chronicles.esp") as Scene
    Scene morbidScn = Game.GetFormFromFile(0x00019103, "Vault13Chronicles.esp") as Scene
    if aiKeepSceneIdx != 1 && gizmoScn != None && gizmoScn.IsPlaying()
        gizmoScn.Stop()
    endif
    if aiKeepSceneIdx != 2 && nealScn != None && nealScn.IsPlaying()
        nealScn.Stop()
    endif
    if aiKeepSceneIdx != 3 && vinnieScn != None && vinnieScn.IsPlaying()
        vinnieScn.Stop()
    endif
    if aiKeepSceneIdx != 4 && morbidScn != None && morbidScn.IsPlaying()
        morbidScn.Stop()
    endif
EndFunction

Function EquipSyndicateActorGear(Actor akAct, int aiOutfitID, int aiBodyArmorID, int aiHatID, int aiOldBodyID)
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

Function RefreshJunktownSyndicateLayout()
    Actor nealAct = Game.GetFormFromFile(0x000035DC, "Vault13Chronicles.esp") as Actor
    if nealAct != None && !nealAct.IsDead()
        if nealAct.IsDisabled()
            nealAct.EnableNoWait()
        endif
        if nealAct.Is3DLoaded() && !nealAct.IsInCombat()
            nealAct.AllowPCDialogue(True)
            nealAct.BlockActivation(False, False)
            if Math.Abs(nealAct.GetPositionX() - 3340.0) > 450.0 || Math.Abs(nealAct.GetPositionY() - 4320.0) > 450.0
                nealAct.SetPosition(3340.0, 4320.0, 80.0)
                nealAct.SetAngle(0.0, 0.0, 180.0)
            endif
            EquipSyndicateActorGear(nealAct, 0x00001031, 0x00237685, 0, 0x000A740B)
        endif
    endif

    Actor morbidAct = Game.GetFormFromFile(0x000035DD, "Vault13Chronicles.esp") as Actor
    if morbidAct != None && !morbidAct.IsDead()
        if morbidAct.IsDisabled()
            morbidAct.EnableNoWait()
        endif
        if morbidAct.Is3DLoaded() && !morbidAct.IsInCombat()
            morbidAct.AllowPCDialogue(True)
            morbidAct.BlockActivation(False, False)
            if Math.Abs(morbidAct.GetPositionX() - 3600.0) > 450.0 || Math.Abs(morbidAct.GetPositionY() - 3320.0) > 450.0
                morbidAct.SetPosition(3600.0, 3320.0, 80.0)
                morbidAct.SetAngle(0.0, 0.0, 0.0)
            endif
            EquipSyndicateActorGear(morbidAct, 0x00001032, 0x001E8CAB, 0, 0x00178B68)
        endif
    endif

    ObjectReference coolerRef = Game.GetFormFromFile(0x000035E5, "Vault13Chronicles.esp") as ObjectReference
    if coolerRef != None && coolerRef.IsDisabled()
        coolerRef.EnableNoWait()
    endif

    Actor gizmoAct = Game.GetFormFromFile(0x000035DE, "Vault13Chronicles.esp") as Actor
    Form tapeBase = Game.GetFormFromFile(0x0000145A, "Vault13Chronicles.esp")
    Form dossierBase = Game.GetFormFromFile(0x00001C83, "Vault13Chronicles.esp")
    Actor player = Game.GetPlayer()
    if gizmoAct != None
        if gizmoAct.IsDisabled() && Self.GetStage() < 40
            gizmoAct.EnableNoWait()
        endif
        if !gizmoAct.IsDead() && gizmoAct.Is3DLoaded() && !gizmoAct.IsInCombat()
            gizmoAct.AllowPCDialogue(True)
            gizmoAct.BlockActivation(False, False)
            if Math.Abs(gizmoAct.GetPositionX() + 1760.0) > 450.0 || Math.Abs(gizmoAct.GetPositionY() - 1460.0) > 450.0
                gizmoAct.SetPosition(-1760.0, 1460.0, 86.0)
                gizmoAct.SetAngle(0.0, 0.0, 180.0)
            endif
            EquipSyndicateActorGear(gizmoAct, 0x0000102E, 0x001BDE07, 0x001BA8DA, 0x001536F4)
            if !bGizmoResolved && tapeBase != None && player != None && player.GetItemCount(tapeBase) == 0 && gizmoAct.GetItemCount(tapeBase) == 0
                gizmoAct.AddItem(tapeBase, 1, True)
            endif
            if dossierBase != None && gizmoAct.GetItemCount(dossierBase) == 0
                gizmoAct.AddItem(dossierBase, 1, True)
            endif
        endif
    endif

    Actor izoAct = Game.GetFormFromFile(0x000035DF, "Vault13Chronicles.esp") as Actor
    if izoAct != None && !izoAct.IsDead()
        if izoAct.IsDisabled() && Self.GetStage() < 40
            izoAct.EnableNoWait()
        endif
        if izoAct.Is3DLoaded() && !izoAct.IsInCombat()
            izoAct.BlockActivation(False, False)
            if Math.Abs(izoAct.GetPositionX() + 1900.0) > 450.0 || Math.Abs(izoAct.GetPositionY() - 1460.0) > 450.0
                izoAct.SetPosition(-1900.0, 1460.0, 86.0)
                izoAct.SetAngle(0.0, 0.0, 180.0)
            endif
            EquipSyndicateActorGear(izoAct, 0x0000102F, 0x00237679, 0x001C4BE8, 0x000B2D8E)
        endif
    endif

    Actor vinnieAct = Game.GetFormFromFile(0x000035EC, "Vault13Chronicles.esp") as Actor
    Form urnBase = Game.GetFormFromFile(0x0000145B, "Vault13Chronicles.esp")
    if vinnieAct != None
        if vinnieAct.IsDisabled() && Self.GetStage() < 40
            vinnieAct.EnableNoWait()
        endif
        if !vinnieAct.IsDead() && vinnieAct.Is3DLoaded() && !vinnieAct.IsInCombat()
            vinnieAct.AllowPCDialogue(True)
            vinnieAct.BlockActivation(False, False)
            if Math.Abs(vinnieAct.GetPositionX() + 1180.0) > 450.0 || Math.Abs(vinnieAct.GetPositionY() - 1240.0) > 450.0
                vinnieAct.SetPosition(-1180.0, 1240.0, 86.0)
                vinnieAct.SetAngle(0.0, 0.0, 270.0)
            endif
            EquipSyndicateActorGear(vinnieAct, 0x00001030, 0x00237682, 0x0017E91D, 0x000B2D8E)
            if !bUrnRecovered && urnBase != None && player != None && player.GetItemCount(urnBase) == 0 && vinnieAct.GetItemCount(urnBase) == 0
                vinnieAct.AddItem(urnBase, 1, True)
            endif
        endif
    endif
EndFunction

Function BindSyndicateListeners()
    Actor player = Game.GetPlayer()
    Form tapeBase = Game.GetFormFromFile(0x0000145A, "Vault13Chronicles.esp")
    Form urnBase = Game.GetFormFromFile(0x0000145B, "Vault13Chronicles.esp")
    Form ledgerBase = Game.GetFormFromFile(0x0000145C, "Vault13Chronicles.esp")
    Self.RemoveAllInventoryEventFilters()
    if tapeBase != None
        Self.AddInventoryEventFilter(tapeBase)
    endif
    if urnBase != None
        Self.AddInventoryEventFilter(urnBase)
    endif
    if ledgerBase != None
        Self.AddInventoryEventFilter(ledgerBase)
    endif
    if player != None
        RegisterForRemoteEvent(player, "OnPlayerLoadGame")
        RegisterForRemoteEvent(player, "OnLocationChange")
        if tapeBase != None || urnBase != None || ledgerBase != None
            RegisterForRemoteEvent(player as ObjectReference, "OnItemAdded")
        endif
    endif

    ForceAllSyndicateAliases()
    RefreshJunktownSyndicateLayout()

    ObjectReference nealRef = Game.GetFormFromFile(0x000035DC, "Vault13Chronicles.esp") as ObjectReference
    if nealRef != None
        RegisterForRemoteEvent(nealRef, "OnActivate")
    endif
    ObjectReference morbidRef = Game.GetFormFromFile(0x000035DD, "Vault13Chronicles.esp") as ObjectReference
    if morbidRef != None
        RegisterForRemoteEvent(morbidRef, "OnActivate")
    endif
    ObjectReference coolerRef = Game.GetFormFromFile(0x000035E5, "Vault13Chronicles.esp") as ObjectReference
    if coolerRef != None
        RegisterForRemoteEvent(coolerRef, "OnActivate")
    endif
    Actor gizmoAct = Game.GetFormFromFile(0x000035DE, "Vault13Chronicles.esp") as Actor
    if gizmoAct != None
        RegisterForRemoteEvent(gizmoAct as ObjectReference, "OnActivate")
        if tapeBase != None
            RegisterForRemoteEvent(gizmoAct as ObjectReference, "OnItemRemoved")
        endif
        RegisterForRemoteEvent(gizmoAct, "OnDeath")
    endif
    Actor izoAct = Game.GetFormFromFile(0x000035DF, "Vault13Chronicles.esp") as Actor
    if izoAct != None
        RegisterForRemoteEvent(izoAct as ObjectReference, "OnActivate")
        RegisterForRemoteEvent(izoAct, "OnDeath")
    endif
    Actor vinnieAct = Game.GetFormFromFile(0x000035EC, "Vault13Chronicles.esp") as Actor
    if vinnieAct != None
        RegisterForRemoteEvent(vinnieAct as ObjectReference, "OnActivate")
        if urnBase != None
            RegisterForRemoteEvent(vinnieAct as ObjectReference, "OnItemRemoved")
        endif
        RegisterForRemoteEvent(vinnieAct, "OnDeath")
    endif
EndFunction

Function CheckAdvanceToStage30()
    SyncSyndicateProgressFlags()
    Scene gizmoScn = Game.GetFormFromFile(0x00019100, "Vault13Chronicles.esp") as Scene
    Scene vinnieScn = Game.GetFormFromFile(0x00019102, "Vault13Chronicles.esp") as Scene
    if bUrnRecovered
        SetObjectiveCompleted(20, True)
        if vinnieScn == None || !vinnieScn.IsPlaying()
            ClearQuestAlias(9)
        endif
    elseif Self.GetStage() >= 20 && Self.GetStage() < 40 && !Self.IsObjectiveDisplayed(20)
        ForceQuestAlias(9, 0x000035EC)
        Self.SetObjectiveDisplayed(20, True, False)
    endif

    if bGizmoResolved
        SetObjectiveCompleted(21, True)
        if gizmoScn == None || !gizmoScn.IsPlaying()
            ClearQuestAlias(1)
        endif
    elseif Self.GetStage() >= 20 && Self.GetStage() < 40 && !Self.IsObjectiveDisplayed(21)
        ForceQuestAlias(1, 0x000035DE)
        Self.SetObjectiveDisplayed(21, True, False)
    endif

    if bGizmoResolved && bUrnRecovered
        if bUrnReturnedToNeal && bFinalRewardGranted
            if Self.GetStage() < 40
                Self.SetStage(40)
            endif
            FinalizeSyndicateQuestCleanly()
        elseif Self.GetStage() < 30
            Self.SetStage(30)
        endif
    endif
EndFunction

Function NotifyGizmoTapeRecovered()
    if bGizmoResolved
        CheckAdvanceToStage30()
        return
    endif
    bGizmoResolved = True
    Actor player = Game.GetPlayer()
    Actor gizmoAct = Game.GetFormFromFile(0x000035DE, "Vault13Chronicles.esp") as Actor
    Form tapeBase = Game.GetFormFromFile(0x0000145A, "Vault13Chronicles.esp")
    Form dossierBase = Game.GetFormFromFile(0x00001C83, "Vault13Chronicles.esp")
    if gizmoAct != None && tapeBase != None && gizmoAct.GetItemCount(tapeBase) > 0
        gizmoAct.RemoveItem(tapeBase, gizmoAct.GetItemCount(tapeBase), True)
    endif
    if gizmoAct != None && dossierBase != None && gizmoAct.GetItemCount(dossierBase) > 0
        gizmoAct.RemoveItem(dossierBase, gizmoAct.GetItemCount(dossierBase), True)
    endif
    if player != None
        if tapeBase != None && player.GetItemCount(tapeBase) == 0
            player.AddItem(tapeBase, 1, False)
        endif
        if dossierBase != None && player.GetItemCount(dossierBase) == 0
            player.AddItem(dossierBase, 1, True)
        endif
    endif
    Game.RewardPlayerXP(250)
    Debug.Notification("¡Has obtenido la Confesión Grabada de Gizmo! Entrégasela al Capitán Lars o a Neal en Junktown.")
    CheckAdvanceToStage30()
EndFunction

Function NotifyNealUrnRecovered()
    if bUrnRecovered
        CheckAdvanceToStage30()
        return
    endif
    bUrnRecovered = True
    Actor player = Game.GetPlayer()
    Actor vinnieAct = Game.GetFormFromFile(0x000035EC, "Vault13Chronicles.esp") as Actor
    Form urnBase = Game.GetFormFromFile(0x0000145B, "Vault13Chronicles.esp")
    if vinnieAct != None && urnBase != None && vinnieAct.GetItemCount(urnBase) > 0
        vinnieAct.RemoveItem(urnBase, vinnieAct.GetItemCount(urnBase), True)
    endif
    if player != None && urnBase != None && player.GetItemCount(urnBase) == 0
        player.AddItem(urnBase, 1, False)
    endif
    Game.RewardPlayerXP(200)
    Debug.Notification("¡Has recuperado la Urna Funeraria de la esposa de Neal! Devuélvesela al barman Neal en La Espumadera.")
    CheckAdvanceToStage30()
EndFunction

Function NotifyDocMorbidLedgerRecovered()
    if bDocMorbidExposed
        return
    endif
    bDocMorbidExposed = True
    Actor player = Game.GetPlayer()
    ObjectReference coolerRef = Game.GetFormFromFile(0x000035E5, "Vault13Chronicles.esp") as ObjectReference
    Form ledgerBase = Game.GetFormFromFile(0x0000145C, "Vault13Chronicles.esp")
    Form docBook = Game.GetFormFromFile(0x00001C84, "Vault13Chronicles.esp")
    if coolerRef != None && ledgerBase != None && coolerRef.GetItemCount(ledgerBase) > 0
        coolerRef.RemoveItem(ledgerBase, coolerRef.GetItemCount(ledgerBase), True)
    endif
    if coolerRef != None && docBook != None && coolerRef.GetItemCount(docBook) > 0
        coolerRef.RemoveItem(docBook, coolerRef.GetItemCount(docBook), True)
    endif
    Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
    Form stim = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
    Form radaway = Game.GetFormFromFile(0x00023742, "Fallout4.esm")
    if player != None
        if ledgerBase != None && player.GetItemCount(ledgerBase) == 0
            player.AddItem(ledgerBase, 1, False)
        endif
        if docBook != None && player.GetItemCount(docBook) == 0
            player.AddItem(docBook, 1, True)
        endif
        if caps != None
            player.AddItem(caps, 250, False)
        endif
        if stim != None
            player.AddItem(stim, 4, False)
        endif
        if radaway != None
            player.AddItem(radaway, 4, False)
        endif
        player.ResetHealthAndLimbs()
    endif
    Game.RewardPlayerXP(200)
    Debug.Notification("¡Has descubierto el secreto de Doc Morbid y sus envíos de «carne especial» a Iguana Bob en El Eje! (+250 chapas y suministros médicos)")
EndFunction

Function DeliverUrnToNeal()
    if bUrnReturnedToNeal
        return
    endif
    bUrnReturnedToNeal = True
    bUrnRecovered = True
    if Self.IsObjectiveDisplayed(20)
        SetObjectiveCompleted(20, True)
    endif
    ClearQuestAlias(9)
    Actor player = Game.GetPlayer()
    Form urnBase = Game.GetFormFromFile(0x0000145B, "Vault13Chronicles.esp")
    Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
    Form nukaQ = Game.GetFormFromFile(0x0004835F, "Fallout4.esm")
    Form stim = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
    if player != None
        if urnBase != None && player.GetItemCount(urnBase) > 0
            player.RemoveItem(urnBase, 1, True)
        endif
        if caps != None
            player.AddItem(caps, 350, False)
        endif
        if nukaQ != None
            player.AddItem(nukaQ, 2, False)
        endif
        if stim != None
            player.AddItem(stim, 3, False)
        endif
    endif
    Game.RewardPlayerXP(250)
    Debug.Notification("Neal: «¡Me has devuelto la urna de mi esposa y has frenado a Vinnie! Toma 350 chapas y la mejor reserva de La Espumadera.»")
    SyncSyndicateProgressFlags()
    if bGizmoResolved
        GrantSyndicateFinalReward()
    endif
EndFunction

Function GrantSyndicateFinalReward()
    if bFinalRewardGranted
        if Self.GetStage() < 40
            Self.SetStage(40)
        endif
        FinalizeSyndicateQuestCleanly()
        return
    endif
    bFinalRewardGranted = True
    bRewardGranted = True
    Actor player = Game.GetPlayer()
    Form tapeBase = Game.GetFormFromFile(0x0000145A, "Vault13Chronicles.esp")
    Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
    Form stim = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
    Form shells = Game.GetFormFromFile(0x0001F673, "Fallout4.esm")
    Form ammo10 = Game.GetFormFromFile(0x0001F276, "Fallout4.esm")
    if player != None
        if tapeBase != None && player.GetItemCount(tapeBase) > 0
            player.RemoveItem(tapeBase, 1, True)
        endif
        if caps != None
            player.AddItem(caps, 600, False)
        endif
        if stim != None
            player.AddItem(stim, 5, False)
        endif
        if shells != None
            player.AddItem(shells, 36, False)
        endif
        if ammo10 != None
            player.AddItem(ammo10, 60, False)
        endif
    endif
    Actor gizmoAct = Game.GetFormFromFile(0x000035DE, "Vault13Chronicles.esp") as Actor
    Actor izoAct = Game.GetFormFromFile(0x000035DF, "Vault13Chronicles.esp") as Actor
    Actor vinnieAct = Game.GetFormFromFile(0x000035EC, "Vault13Chronicles.esp") as Actor
    if gizmoAct != None && !gizmoAct.IsDead()
        gizmoAct.DisableNoWait()
    endif
    if izoAct != None && !izoAct.IsDead()
        izoAct.DisableNoWait()
    endif
    if vinnieAct != None && !vinnieAct.IsDead()
        vinnieAct.DisableNoWait()
    endif
    Game.RewardPlayerXP(450)
    Debug.Notification("¡El sindicato de Gizmo y la banda de Los Cráneos han caído! La guardia de Lars y Neal te entregan 600 chapas y munición.")
    if Self.GetStage() < 40
        Self.SetStage(40)
    endif
    FinalizeSyndicateQuestCleanly()
EndFunction

Event OnStageSet(int auiStageID, int auiItemID)
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
    elseif auiStageID == 24
        if bStg24Done
            return
        endif
        bStg24Done = True
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
            FinalizeSyndicateQuestCleanly()
            return
        endif
        bRewardGranted = True
    endif

    BindSyndicateListeners()

    if auiStageID == 15
        ForceQuestAlias(0, 0x000035DC)
        if !Self.IsObjectiveDisplayed(15)
            Self.SetObjectiveDisplayed(15, True, False)
        endif
    elseif auiStageID == 20
        ForceAllSyndicateAliases()
        SetObjectiveCompleted(15, True)
        if !bUrnRecovered && !Self.IsObjectiveDisplayed(20)
            Self.SetObjectiveDisplayed(20, True, False)
        endif
        if !bGizmoResolved && !Self.IsObjectiveDisplayed(21)
            Self.SetObjectiveDisplayed(21, True, False)
        endif
        Self.SetActive(True)
        CheckAdvanceToStage30()
    elseif auiStageID == 22 || auiStageID == 23
        NotifyNealUrnRecovered()
    elseif auiStageID == 24
        StopAllSyndicateScenesExcept(0)
        Actor player = Game.GetPlayer()
        Actor vinnieAct = Game.GetFormFromFile(0x000035EC, "Vault13Chronicles.esp") as Actor
        Actor skullAct = Game.GetFormFromFile(0x000035C5, "Vault13Chronicles.esp") as Actor
        Faction raiderFact = Game.GetFormFromFile(0x0001CBED, "Fallout4.esm") as Faction
        ActorValue aggAV = Game.GetFormFromFile(0x000002BC, "Fallout4.esm") as ActorValue
        if vinnieAct != None && !vinnieAct.IsDead() && player != None && !player.IsDead()
            if raiderFact != None
                vinnieAct.AddToFaction(raiderFact)
            endif
            if aggAV != None
                vinnieAct.SetValue(aggAV, 2.0)
            endif
            vinnieAct.StartCombat(player)
        endif
        if skullAct != None && !skullAct.IsDead() && player != None && !player.IsDead()
            skullAct.StartCombat(player)
        endif
    elseif auiStageID == 25
        NotifyDocMorbidLedgerRecovered()
    elseif auiStageID == 26 || auiStageID == 27
        NotifyGizmoTapeRecovered()
    elseif auiStageID == 28
        StopAllSyndicateScenesExcept(0)
        Actor player = Game.GetPlayer()
        Actor gizmoAct = Game.GetFormFromFile(0x000035DE, "Vault13Chronicles.esp") as Actor
        Actor izoAct = Game.GetFormFromFile(0x000035DF, "Vault13Chronicles.esp") as Actor
        Faction raiderFact = Game.GetFormFromFile(0x0001CBED, "Fallout4.esm") as Faction
        ActorValue aggAV = Game.GetFormFromFile(0x000002BC, "Fallout4.esm") as ActorValue
        if gizmoAct != None && !gizmoAct.IsDead() && player != None && !player.IsDead()
            if raiderFact != None
                gizmoAct.AddToFaction(raiderFact)
            endif
            if aggAV != None
                gizmoAct.SetValue(aggAV, 2.0)
            endif
            gizmoAct.StartCombat(player)
        endif
        if izoAct != None && !izoAct.IsDead() && player != None && !player.IsDead()
            if aggAV != None
                izoAct.SetValue(aggAV, 2.0)
            endif
            izoAct.StartCombat(player)
        endif
    elseif auiStageID == 30
        SetObjectiveCompleted(15, True)
        SetObjectiveCompleted(20, True)
        SetObjectiveCompleted(21, True)
        Scene gizmoScn30 = Game.GetFormFromFile(0x00019100, "Vault13Chronicles.esp") as Scene
        Scene vinnieScn30 = Game.GetFormFromFile(0x00019102, "Vault13Chronicles.esp") as Scene
        if gizmoScn30 == None || !gizmoScn30.IsPlaying()
            ClearQuestAlias(1)
        endif
        if vinnieScn30 == None || !vinnieScn30.IsPlaying()
            ClearQuestAlias(9)
        endif
        ForceQuestAlias(0, 0x000035DC)
        if !Self.IsObjectiveDisplayed(30)
            Self.SetObjectiveDisplayed(30, True, False)
        endif
        Self.SetActive(True)
    elseif auiStageID == 40
        GrantSyndicateFinalReward()
        FinalizeSyndicateQuestCleanly()
    endif
EndEvent

Event OnInit()
    BindSyndicateListeners()
EndEvent

Event OnQuestInit()
    BindSyndicateListeners()
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
    BindSyndicateListeners()
    if Self.GetStage() >= 20 && !Self.IsCompleted()
        CheckAdvanceToStage30()
    endif
EndEvent

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
    BindSyndicateListeners()
    if Self.GetStage() >= 20 && !Self.IsCompleted()
        CheckAdvanceToStage30()
    endif
EndEvent

Event ObjectReference.OnItemAdded(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    Form tapeBase = Game.GetFormFromFile(0x0000145A, "Vault13Chronicles.esp")
    Form urnBase = Game.GetFormFromFile(0x0000145B, "Vault13Chronicles.esp")
    Form ledgerBase = Game.GetFormFromFile(0x0000145C, "Vault13Chronicles.esp")
    if akBaseItem == tapeBase && !bGizmoResolved
        NotifyGizmoTapeRecovered()
    elseif akBaseItem == urnBase && !bUrnRecovered
        NotifyNealUrnRecovered()
    elseif akBaseItem == ledgerBase && !bDocMorbidExposed
        NotifyDocMorbidLedgerRecovered()
    endif
EndEvent

Event ObjectReference.OnItemRemoved(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
    Form tapeBase = Game.GetFormFromFile(0x0000145A, "Vault13Chronicles.esp")
    Form urnBase = Game.GetFormFromFile(0x0000145B, "Vault13Chronicles.esp")
    if akBaseItem == tapeBase && !bGizmoResolved
        NotifyGizmoTapeRecovered()
    elseif akBaseItem == urnBase && !bUrnRecovered
        NotifyNealUrnRecovered()
    endif
EndEvent

Event Actor.OnDeath(Actor akSender, Actor akKiller)
    Actor gizmoAct = Game.GetFormFromFile(0x000035DE, "Vault13Chronicles.esp") as Actor
    Actor vinnieAct = Game.GetFormFromFile(0x000035EC, "Vault13Chronicles.esp") as Actor
    if akSender == gizmoAct
        NotifyGizmoTapeRecovered()
    elseif akSender == vinnieAct
        NotifyNealUrnRecovered()
    endif
EndEvent

Event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
    if akActionRef != Game.GetPlayer()
        return
    endif
    ForceAllSyndicateAliases()
    Actor player = Game.GetPlayer()
    ObjectReference nealRef = Game.GetFormFromFile(0x000035DC, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference morbidRef = Game.GetFormFromFile(0x000035DD, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference coolerRef = Game.GetFormFromFile(0x000035E5, "Vault13Chronicles.esp") as ObjectReference
    Actor gizmoAct = Game.GetFormFromFile(0x000035DE, "Vault13Chronicles.esp") as Actor
    Actor izoAct = Game.GetFormFromFile(0x000035DF, "Vault13Chronicles.esp") as Actor
    Actor vinnieAct = Game.GetFormFromFile(0x000035EC, "Vault13Chronicles.esp") as Actor
    ObjectReference larsRef = Game.GetFormFromFile(0x000035C1, "Vault13Chronicles.esp") as ObjectReference
    Form tapeBase = Game.GetFormFromFile(0x0000145A, "Vault13Chronicles.esp")
    Form urnBase = Game.GetFormFromFile(0x0000145B, "Vault13Chronicles.esp")
    Topic synGreeting = Game.GetFormFromFile(0x00019001, "Vault13Chronicles.esp") as Topic

    if Self.GetStage() < 20
        Self.SetStage(20)
    endif

    if coolerRef != None && akSender == coolerRef
        if !bDocMorbidExposed
            NotifyDocMorbidLedgerRecovered()
        endif
        return
    endif

    if izoAct != None && akSender == (izoAct as ObjectReference)
        if !izoAct.IsDead() && !izoAct.IsInCombat()
            Debug.Notification("Izo (Guardaespaldas): «Si tienes negocios en el Casino, habla con el jefe Gizmo. Y mantén las manos lejos del arma.»")
            if gizmoAct != None && !gizmoAct.IsDead() && !bGizmoResolved
                StopAllSyndicateScenesExcept(1)
                if synGreeting != None && !gizmoAct.IsTalking()
                    gizmoAct.Say(synGreeting, None, false, None)
                endif
                sceneWaitTicks = 0
                StartTimer(0.6, 91)
            endif
        endif
        return
    endif

    if gizmoAct != None && akSender == (gizmoAct as ObjectReference)
        if gizmoAct.IsDead()
            if !bGizmoResolved
                NotifyGizmoTapeRecovered()
            endif
            return
        endif
        if !bGizmoResolved
            StopAllSyndicateScenesExcept(1)
            if synGreeting != None && !gizmoAct.IsTalking()
                gizmoAct.Say(synGreeting, None, false, None)
            endif
            sceneWaitTicks = 0
            StartTimer(0.6, 91)
        endif
        return
    endif

    if vinnieAct != None && akSender == (vinnieAct as ObjectReference)
        if vinnieAct.IsDead()
            if !bUrnRecovered
                NotifyNealUrnRecovered()
            endif
            return
        endif
        if !bUrnRecovered
            StopAllSyndicateScenesExcept(3)
            if synGreeting != None && !vinnieAct.IsTalking()
                vinnieAct.Say(synGreeting, None, false, None)
            endif
            sceneWaitTicks = 0
            StartTimer(0.6, 93)
        endif
        return
    endif

    if nealRef != None && akSender == nealRef
        Actor nealAct = nealRef as Actor
        SyncSyndicateProgressFlags()
        if bUrnRecovered && !bUrnReturnedToNeal
            DeliverUrnToNeal()
        endif
        SyncSyndicateProgressFlags()
        if bUrnReturnedToNeal && bGizmoResolved
            if Self.GetStage() < 30
                Self.SetStage(30)
            endif
            if synGreeting != None && nealAct != None && !nealAct.IsTalking()
                nealAct.Say(synGreeting, None, false, None)
            endif
            GrantSyndicateFinalReward()
            return
        elseif bUrnReturnedToNeal && !bGizmoResolved
            if Self.IsObjectiveDisplayed(30)
                Self.SetObjectiveDisplayed(30, False, False)
            endif
            ForceQuestAlias(1, 0x000035DE)
            if !Self.IsObjectiveDisplayed(21)
                Self.SetObjectiveDisplayed(21, True, False)
            endif
            Self.SetActive(True)
            Debug.Notification("Neal: «¡Gracias por devolverme la urna! Ahora obtén la Confesión de Gizmo en el Casino del Oeste para acabar con su sindicato.»")
            return
        endif
        StopAllSyndicateScenesExcept(2)
        if synGreeting != None && nealAct != None && !nealAct.IsTalking()
            nealAct.Say(synGreeting, None, false, None)
        endif
        if Self.GetStage() < 30 && !bUrnReturnedToNeal
            sceneWaitTicks = 0
            StartTimer(0.6, 92)
        endif
        return
    endif

    if morbidRef != None && akSender == morbidRef
        Actor morbidAct = morbidRef as Actor
        if player != None
            player.ResetHealthAndLimbs()
        endif
        StopAllSyndicateScenesExcept(4)
        if synGreeting != None && morbidAct != None && !morbidAct.IsTalking()
            morbidAct.Say(synGreeting, None, false, None)
        endif
        if !bDocMorbidExposed
            sceneWaitTicks = 0
            StartTimer(0.6, 94)
        else
            Debug.Notification("Doc Morbid ha curado tus heridas en silencio.")
        endif
        return
    endif

    if larsRef != None && akSender == larsRef
        CheckLarsSyndicateReward()
    endif
EndEvent

Event OnTimer(int aiTimerID)
    if aiTimerID == 91
        Scene gizmoScn = Game.GetFormFromFile(0x00019100, "Vault13Chronicles.esp") as Scene
        Actor gizmoAct = Game.GetFormFromFile(0x000035DE, "Vault13Chronicles.esp") as Actor
        if gizmoScn != None && !bGizmoResolved && gizmoAct != None && !gizmoAct.IsDead()
            if gizmoScn.IsPlaying()
                return
            elseif gizmoAct.IsTalking() && sceneWaitTicks < 28
                sceneWaitTicks += 1
                StartTimer(0.4, 91)
            else
                ForceAllSyndicateAliases()
                StopAllSyndicateScenesExcept(1)
                gizmoScn.Start()
            endif
        endif
    elseif aiTimerID == 92
        Scene nealScn = Game.GetFormFromFile(0x00019101, "Vault13Chronicles.esp") as Scene
        Actor nealAct = Game.GetFormFromFile(0x000035DC, "Vault13Chronicles.esp") as Actor
        if nealScn != None && Self.GetStage() < 30 && nealAct != None
            if nealScn.IsPlaying()
                return
            elseif nealAct.IsTalking() && sceneWaitTicks < 28
                sceneWaitTicks += 1
                StartTimer(0.4, 92)
            else
                ForceAllSyndicateAliases()
                StopAllSyndicateScenesExcept(2)
                nealScn.Start()
            endif
        endif
    elseif aiTimerID == 93
        Scene vinnieScn = Game.GetFormFromFile(0x00019102, "Vault13Chronicles.esp") as Scene
        Actor vinnieAct = Game.GetFormFromFile(0x000035EC, "Vault13Chronicles.esp") as Actor
        if vinnieScn != None && !bUrnRecovered && vinnieAct != None && !vinnieAct.IsDead()
            if vinnieScn.IsPlaying()
                return
            elseif vinnieAct.IsTalking() && sceneWaitTicks < 28
                sceneWaitTicks += 1
                StartTimer(0.4, 93)
            else
                ForceAllSyndicateAliases()
                StopAllSyndicateScenesExcept(3)
                vinnieScn.Start()
            endif
        endif
    elseif aiTimerID == 94
        Scene morbidScn = Game.GetFormFromFile(0x00019103, "Vault13Chronicles.esp") as Scene
        Actor morbidAct = Game.GetFormFromFile(0x000035DD, "Vault13Chronicles.esp") as Actor
        if morbidScn != None && !bDocMorbidExposed && morbidAct != None
            if morbidScn.IsPlaying()
                return
            elseif morbidAct.IsTalking() && sceneWaitTicks < 28
                sceneWaitTicks += 1
                StartTimer(0.4, 94)
            else
                ForceAllSyndicateAliases()
                StopAllSyndicateScenesExcept(4)
                morbidScn.Start()
            endif
        endif
    endif
EndEvent
