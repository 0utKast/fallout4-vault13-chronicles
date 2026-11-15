Scriptname V13SideQuestHubScript extends Quest

bool bItemDelivered = False
bool bRewardGranted = False
bool bDeedRecovered = False
bool bDeedSeeded = False
bool bStg20Notified = False
bool bStg22Notified = False
bool bStg25Notified = False
bool bStg30Notified = False
bool bMenuJumpBusy = False
bool bKragCampHostile = False
bool bKragCampTruce = False
bool bKragMenuBusy = False
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

Function ForceAllHubAliases()
    if Self.IsCompleted() || Self.GetStage() >= 40 || Self.IsStageDone(40) || bRewardGranted
        return
    endif
    ForceQuestAlias(0, 0x000035C6)
    ForceQuestAlias(1, 0x000035C9)
    ForceQuestAlias(2, 0x00003005)
    ForceQuestAlias(3, 0x00002003)
    ForceQuestAlias(4, 0x0000351D)
    ForceQuestAlias(5, 0x00002101)
    ForceQuestAlias(6, 0x00003501)
    ForceQuestAlias(7, 0x00002206)
    ForceQuestAlias(8, 0x00002035)
    ForceQuestAlias(9, 0x000035C8)
    ForceQuestAlias(10, 0x000035C7)
EndFunction

Function EquipHubActorGear(Actor akAct, int aiOutfitID, int aiBodyArmorID, int aiChestArmorID, int aiHatID)
    if akAct == None || akAct.IsDead() || !akAct.Is3DLoaded() || akAct.IsTalking() || akAct.IsInDialogueWithPlayer()
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
    Form oldHelmet = Game.GetFormFromFile(0x0011E2C8, "Fallout4.esm")
    if oldHelmet != None && akAct.GetItemCount(oldHelmet) > 0
        akAct.RemoveItem(oldHelmet, akAct.GetItemCount(oldHelmet), true, None)
    endif
    if aiChestArmorID == 0
        Form oldChest = Game.GetFormFromFile(0x00156C0D, "Fallout4.esm")
        if oldChest != None && akAct.GetItemCount(oldChest) > 0
            akAct.RemoveItem(oldChest, akAct.GetItemCount(oldChest), true, None)
        endif
    endif
    if aiHatID == 0
        Form oldCap = Game.GetFormFromFile(0x00001314, "Vault13Chronicles.esp")
        if oldCap != None && akAct.GetItemCount(oldCap) > 0
            akAct.RemoveItem(oldCap, akAct.GetItemCount(oldCap), true, None)
        endif
    endif
    if bodyArmor != None && !akAct.IsEquipped(bodyArmor)
        if akAct.GetItemCount(bodyArmor) == 0
            akAct.AddItem(bodyArmor, 1, true)
        endif
        akAct.EquipItem(bodyArmor, false, true)
    endif
    if aiChestArmorID > 0
        Form chestArmor = Game.GetFormFromFile(aiChestArmorID, "Fallout4.esm")
        if chestArmor != None && !akAct.IsEquipped(chestArmor)
            if akAct.GetItemCount(chestArmor) == 0
                akAct.AddItem(chestArmor, 1, true)
            endif
            akAct.EquipItem(chestArmor, false, true)
        endif
    endif
    if aiHatID > 0
        Form hatForm = Game.GetFormFromFile(aiHatID, "Vault13Chronicles.esp")
        if hatForm != None && !akAct.IsEquipped(hatForm)
            if akAct.GetItemCount(hatForm) == 0
                akAct.AddItem(hatForm, 1, true)
            endif
            akAct.EquipItem(hatForm, false, true)
        endif
    endif
EndFunction

Function RefreshHubSettlementLayout()
    Actor pHub = Game.GetPlayer()
    WorldSpace caliHub = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if pHub == None || caliHub == None || pHub.GetWorldSpace() != caliHub
        return
    endif
    Actor irwinAct = Game.GetFormFromFile(0x000035C6, "Vault13Chronicles.esp") as Actor
    if irwinAct != None && !irwinAct.IsDead()
        if irwinAct.IsDisabled()
            irwinAct.EnableNoWait()
        endif
        if irwinAct.Is3DLoaded()
            irwinAct.AllowPCDialogue(True)
            irwinAct.BlockActivation(False, False)
            if !irwinAct.IsInCombat() && !irwinAct.IsTalking() && (Math.Abs(irwinAct.GetPositionX() + 3500.0) > 45.0 || Math.Abs(irwinAct.GetPositionY() + 11400.0) > 45.0)
                irwinAct.SetPosition(-3500.0, -11400.0, 80.0)
                irwinAct.SetAngle(0.0, 0.0, 180.0)
                irwinAct.EvaluatePackage()
            endif
            EquipHubActorGear(irwinAct, 0x00001026, 0x000A740B, 0, 0x00001313)
        endif
    endif
    Actor haroldAct = Game.GetFormFromFile(0x000035C7, "Vault13Chronicles.esp") as Actor
    if haroldAct != None && !haroldAct.IsDead()
        if haroldAct.IsDisabled()
            haroldAct.EnableNoWait()
        endif
        if haroldAct.Is3DLoaded()
            haroldAct.AllowPCDialogue(True)
            haroldAct.BlockActivation(False, False)
            if !haroldAct.IsInCombat() && !haroldAct.IsTalking()
                if Math.Abs(haroldAct.GetPositionX() + 1650.0) > 45.0 || Math.Abs(haroldAct.GetPositionY() + 14500.0) > 45.0
                    haroldAct.SetPosition(-1650.0, -14500.0, 80.0)
                    haroldAct.SetAngle(0.0, 0.0, 270.0)
                    haroldAct.EvaluatePackage()
                elseif Math.Abs(haroldAct.GetAngleZ() - 270.0) > 35.0
                    haroldAct.SetAngle(0.0, 0.0, 270.0)
                endif
            endif
            EquipHubActorGear(haroldAct, 0x0000103E, 0x000DF455, 0, 0)
        endif
    endif
    Actor butchAct = Game.GetFormFromFile(0x000035C8, "Vault13Chronicles.esp") as Actor
    if butchAct != None && !butchAct.IsDead()
        if butchAct.IsDisabled()
            butchAct.EnableNoWait()
        endif
        if butchAct.Is3DLoaded()
            butchAct.AllowPCDialogue(True)
            butchAct.BlockActivation(False, False)
            if !butchAct.IsInCombat() && !butchAct.IsTalking() && (Math.Abs(butchAct.GetPositionX() + 1650.0) > 45.0 || Math.Abs(butchAct.GetPositionY() + 13000.0) > 45.0)
                butchAct.SetPosition(-1650.0, -13000.0, 80.0)
                butchAct.SetAngle(0.0, 0.0, 180.0)
                butchAct.EvaluatePackage()
            endif
            EquipHubActorGear(butchAct, 0x00001027, 0x001536F4, 0, 0)
        endif
    endif

    Form noteBase = Game.GetFormFromFile(0x0000114B, "Vault13Chronicles.esp")
    if noteBase != None
        ObjectReference noteRef = Game.FindClosestReferenceOfType(noteBase, -1790.0, -13004.0, 80.0, 3500.0)
        if noteRef != None && noteRef.Is3DLoaded() && noteRef.GetContainer() == None
            noteRef.SetPosition(-1790.0, -13004.0, 136.5)
        endif
    endif
    Actor kragAct = Game.GetFormFromFile(0x000035C9, "Vault13Chronicles.esp") as Actor
    if kragAct != None && kragAct.Is3DLoaded() && !kragAct.IsDead()
        float kz = kragAct.GetPositionZ()
        if (kz < 68.0 || kz > 190.0) && Self.GetStage() < 25
            kragAct.SetPosition(-18500.0, 6500.0, 86.0)
            ForceQuestAlias(1, 0x000035C9)
        elseif !kragAct.IsInCombat() && (Math.Abs(kragAct.GetPositionX() + 18500.0) > 450.0 || Math.Abs(kragAct.GetPositionY() - 6500.0) > 450.0)
            kragAct.SetPosition(-18500.0, 6500.0, 86.0)
            ForceQuestAlias(1, 0x000035C9)
        endif
    endif
EndFunction

Function SilenceHubActorsExcept(Actor akSpeaker, int aiKeepScene = 0)
    Scene irwinScene = Game.GetFormFromFile(0x00011100, "Vault13Chronicles.esp") as Scene
    Scene butchScene = Game.GetFormFromFile(0x00011101, "Vault13Chronicles.esp") as Scene
    Scene haroldScene = Game.GetFormFromFile(0x00011102, "Vault13Chronicles.esp") as Scene
    if aiKeepScene != 1 && irwinScene != None && irwinScene.IsPlaying()
        irwinScene.Stop()
    endif
    if aiKeepScene != 2 && butchScene != None && butchScene.IsPlaying()
        butchScene.Stop()
    endif
    if aiKeepScene != 3 && haroldScene != None && haroldScene.IsPlaying()
        haroldScene.Stop()
    endif
    Topic stopTopic = Game.GetFormFromFile(0x00004003, "Vault13Chronicles.esp") as Topic
    if stopTopic == None
        return
    endif
    Actor irwinAct = Game.GetFormFromFile(0x000035C6, "Vault13Chronicles.esp") as Actor
    Actor haroldAct = Game.GetFormFromFile(0x000035C7, "Vault13Chronicles.esp") as Actor
    Actor butchAct = Game.GetFormFromFile(0x000035C8, "Vault13Chronicles.esp") as Actor
    if irwinAct != None && irwinAct != akSpeaker && irwinAct.IsTalking()
        irwinAct.Say(stopTopic, None, false, None)
    endif
    if haroldAct != None && haroldAct != akSpeaker && haroldAct.IsTalking()
        haroldAct.Say(stopTopic, None, false, None)
    endif
    if butchAct != None && butchAct != akSpeaker && butchAct.IsTalking()
        butchAct.Say(stopTopic, None, false, None)
    endif
EndFunction

Function EnsureHubStage20Active()
    ObjectReference mapMarker = Game.GetFormFromFile(0x0000341D, "Vault13Chronicles.esp") as ObjectReference
    if mapMarker != None
        mapMarker.EnableNoWait()
        mapMarker.AddToMap(True)
    endif
    Actor player = Game.GetPlayer()
    Form deedBase = Game.GetFormFromFile(0x00001452, "Vault13Chronicles.esp")
    if deedBase != None && player != None && player.GetItemCount(deedBase) > 0
        if Self.GetStage() < 25
            Self.SetStage(25)
        endif
        return
    endif
    Actor kragRef = Game.GetFormFromFile(0x000035C9, "Vault13Chronicles.esp") as Actor
    if kragRef != None && kragRef.IsDead()
        if Self.GetStage() < 22
            Self.SetStage(22)
        endif
        return
    endif
    if Self.GetStage() < 20
        Self.SetStage(20)
    endif
    if IsObjectiveDisplayed(12)
        SetObjectiveCompleted(12, True)
        SetObjectiveDisplayed(12, False, False)
    endif
    ForceQuestAlias(1, 0x000035C9)
    if !IsObjectiveDisplayed(20)
        SetObjectiveDisplayed(20, True, False)
        Self.SetActive(True)
    endif
    if !bStg20Notified
        bStg20Notified = True
        Debug.Notification("Side Quest: Irwin's Farm - Eliminate Raider Chieftain Krag north of The Hub.")
    endif
EndFunction

Function BindHubListeners(bool abRefreshLayout = True)
    if Self.IsCompleted() || Self.GetStage() >= 40 || Self.IsStageDone(40) || bRewardGranted
        bRewardGranted = True
        bItemDelivered = True
        bDeedRecovered = True
        bDeedSeeded = True
        Self.CompleteAllObjectives()
        if !Self.IsCompleted()
            Self.CompleteQuest()
        endif
    endif
    ForceAllHubAliases()
    if abRefreshLayout
        RefreshHubSettlementLayout()
    endif

    Actor player = Game.GetPlayer()
    Form deedBase = Game.GetFormFromFile(0x00001452, "Vault13Chronicles.esp")
    Self.RemoveAllInventoryEventFilters()
    if deedBase != None
        Self.AddInventoryEventFilter(deedBase)
    endif
    if player != None
        RegisterForRemoteEvent(player, "OnPlayerLoadGame")
        RegisterForRemoteEvent(player, "OnLocationChange")
        if deedBase != None
            RegisterForRemoteEvent(player as ObjectReference, "OnItemAdded")
        endif
    endif

    ObjectReference irwinRef = Game.GetFormFromFile(0x000035C6, "Vault13Chronicles.esp") as ObjectReference
    if irwinRef != None
        RegisterForRemoteEvent(irwinRef, "OnActivate")
    endif
    ObjectReference haroldRef = Game.GetFormFromFile(0x000035C7, "Vault13Chronicles.esp") as ObjectReference
    if haroldRef != None
        RegisterForRemoteEvent(haroldRef, "OnActivate")
    endif
    WorldSpace caliWorld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    bool inCali = (player != None && caliWorld != None && player.GetWorldSpace() == caliWorld)
    ObjectReference butchRef = Game.GetFormFromFile(0x000035C8, "Vault13Chronicles.esp") as ObjectReference
    if butchRef != None
        RegisterForRemoteEvent(butchRef, "OnActivate")
        if abRefreshLayout && inCali
            EnsureButchVendorReady(butchRef as Actor)
        endif
    endif
    Actor kragRef = Game.GetFormFromFile(0x000035C9, "Vault13Chronicles.esp") as Actor
    if kragRef != None
        RegisterForRemoteEvent(kragRef, "OnDeath")
        RegisterForRemoteEvent(kragRef as ObjectReference, "OnActivate")
        if !kragRef.IsDead()
            RegisterForHitEvent(kragRef)
        endif
        if deedBase != None
            AddInventoryEventFilter(deedBase)
        endif
        RegisterForRemoteEvent(kragRef as ObjectReference, "OnItemRemoved")
        if abRefreshLayout && inCali && kragRef.Is3DLoaded() && !kragRef.IsDead()
            float kx = kragRef.GetPositionX()
            float ky = kragRef.GetPositionY()
            float kz = kragRef.GetPositionZ()
            if (kz < 68.0 || kz > 190.0) && Self.GetStage() < 25
                kragRef.SetPosition(-18500.0, 6500.0, 86.0)
                ForceQuestAlias(1, 0x000035C9)
            elseif !kragRef.IsInCombat()
                if Math.Abs(kx + 18500.0) > 450.0 || Math.Abs(ky - 6500.0) > 450.0
                    kragRef.SetPosition(-18500.0, 6500.0, 86.0)
                    ForceQuestAlias(1, 0x000035C9)
                endif
            endif
        endif
        if bDeedRecovered || bItemDelivered || Self.GetStage() >= 25 || (player != None && deedBase != None && player.GetItemCount(deedBase) > 0)
            bDeedRecovered = True
            bDeedSeeded = True
            if deedBase != None && kragRef.GetItemCount(deedBase) > 0
                kragRef.RemoveItem(deedBase, kragRef.GetItemCount(deedBase), True)
            endif
        elseif kragRef.Is3DLoaded() && !bDeedSeeded && deedBase != None
            if kragRef.GetItemCount(deedBase) == 0
                kragRef.AddItem(deedBase, 1, True)
            endif
            bDeedSeeded = True
        endif
        if (Self.GetStage() == 20 || Self.GetStage() == 21) && kragRef.IsDead()
            if bDeedRecovered || (player != None && deedBase != None && player.GetItemCount(deedBase) > 0)
                Self.SetStage(25)
            else
                Self.SetStage(22)
            endif
        endif
    endif
    if (Self.GetStage() == 20 || Self.GetStage() == 21) && !IsObjectiveDisplayed(20)
        EnsureHubStage20Active()
    endif
    Actor raiderRef = Game.GetFormFromFile(0x000035CA, "Vault13Chronicles.esp") as Actor
    if raiderRef != None
        RegisterForRemoteEvent(raiderRef as ObjectReference, "OnActivate")
        if !raiderRef.IsDead()
            RegisterForHitEvent(raiderRef)
            if abRefreshLayout && inCali && raiderRef.Is3DLoaded()
                float rz_val = raiderRef.GetPositionZ()
                if rz_val < 68.0 || rz_val > 190.0 || (!raiderRef.IsInCombat() && (Math.Abs(raiderRef.GetPositionX() + 18340.0) > 450.0 || Math.Abs(raiderRef.GetPositionY() - 6420.0) > 450.0))
                    raiderRef.SetPosition(-18340.0, 6420.0, 86.0)
                endif
            endif
        endif
    endif
    if abRefreshLayout && inCali
        SanitizeKragCampPeace()
        if Self.GetStage() < 25
            StartTimer(3.0, 97)
        endif
    endif
    Quest hubSynQ = Game.GetFormFromFile(0x0001A000, "Vault13Chronicles.esp") as Quest
    if hubSynQ != None
        V13SideQuestHubSyndicateScript hubSynS = hubSynQ as V13SideQuestHubSyndicateScript
        if hubSynS != None
            hubSynS.BindHubSyndicateListeners(abRefreshLayout)
        endif
    endif
    Quest wmQ = Game.GetFormFromFile(0x0001E000, "Vault13Chronicles.esp") as Quest
    if wmQ != None
        V13SideQuestWaterMerchantsScript wmS = wmQ as V13SideQuestWaterMerchantsScript
        if wmS != None
            wmS.BindWaterMerchantsListeners(abRefreshLayout)
        endif
    endif
EndFunction

Function EnsureButchVendorReady(Actor akButch)
    if akButch == None
        return
    endif
    Faction vFact = Game.GetFormFromFile(0x00001C51, "Vault13Chronicles.esp") as Faction
    if vFact != None && !akButch.IsInFaction(vFact)
        akButch.AddToFaction(vFact)
    endif
    ObjectReference vChest = Game.GetFormFromFile(0x000035E1, "Vault13Chronicles.esp") as ObjectReference
    Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
    if vChest != None
        if vChest.IsDisabled()
            vChest.EnableNoWait()
        endif
        if caps != None && vChest.GetItemCount(caps) < 500
            vChest.AddItem(caps, 2200, True)
            Form a10 = Game.GetFormFromFile(0x0001F276, "Fallout4.esm")
            Form a308 = Game.GetFormFromFile(0x0001F66B, "Fallout4.esm")
            Form a556 = Game.GetFormFromFile(0x0001F278, "Fallout4.esm")
            Form aShell = Game.GetFormFromFile(0x0001F673, "Fallout4.esm")
            Form a44 = Game.GetFormFromFile(0x0009221C, "Fallout4.esm")
            Form aFusion = Game.GetFormFromFile(0x000C1897, "Fallout4.esm")
            Form a5mm = Game.GetFormFromFile(0x0001F66C, "Fallout4.esm")
            Form stim = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
            Form radaway = Game.GetFormFromFile(0x00023742, "Fallout4.esm")
            Form radx = Game.GetFormFromFile(0x00024057, "Fallout4.esm")
            Form water = Game.GetFormFromFile(0x000366C0, "Fallout4.esm")
            Form wCRifle = Game.GetFormFromFile(0x000DF42E, "Fallout4.esm")
            Form wARifle = Game.GetFormFromFile(0x0000463F, "Fallout4.esm")
            Form wShot = Game.GetFormFromFile(0x0014831C, "Fallout4.esm")
            Form cArmor = Game.GetFormFromFile(0x0011D3C3, "Fallout4.esm")
            if a10 != None && vChest.GetItemCount(a10) < 40
                vChest.AddItem(a10, 150, True)
            endif
            if a308 != None && vChest.GetItemCount(a308) < 40
                vChest.AddItem(a308, 100, True)
            endif
            if a556 != None && vChest.GetItemCount(a556) < 40
                vChest.AddItem(a556, 120, True)
            endif
            if aShell != None && vChest.GetItemCount(aShell) < 40
                vChest.AddItem(aShell, 90, True)
            endif
            if a44 != None && vChest.GetItemCount(a44) < 30
                vChest.AddItem(a44, 80, True)
            endif
            if aFusion != None && vChest.GetItemCount(aFusion) < 40
                vChest.AddItem(aFusion, 100, True)
            endif
            if a5mm != None && vChest.GetItemCount(a5mm) < 80
                vChest.AddItem(a5mm, 200, True)
            endif
            if stim != None && vChest.GetItemCount(stim) < 6
                vChest.AddItem(stim, 18, True)
            endif
            if radaway != None && vChest.GetItemCount(radaway) < 4
                vChest.AddItem(radaway, 12, True)
            endif
            if radx != None && vChest.GetItemCount(radx) < 4
                vChest.AddItem(radx, 10, True)
            endif
            if water != None && vChest.GetItemCount(water) < 6
                vChest.AddItem(water, 16, True)
            endif
            if wCRifle != None && vChest.GetItemCount(wCRifle) == 0
                vChest.AddItem(wCRifle, 1, True)
            endif
            if wARifle != None && vChest.GetItemCount(wARifle) == 0
                vChest.AddItem(wARifle, 1, True)
            endif
            if wShot != None && vChest.GetItemCount(wShot) == 0
                vChest.AddItem(wShot, 1, True)
            endif
            if cArmor != None && vChest.GetItemCount(cArmor) == 0
                vChest.AddItem(cArmor, 2, True)
            endif
        endif
    endif
EndFunction

Function OpenButchBarter()
    Actor butchAct = Game.GetFormFromFile(0x000035C8, "Vault13Chronicles.esp") as Actor
    if butchAct == None || butchAct.IsDead()
        return
    endif
    EnsureButchVendorReady(butchAct)
    Utility.Wait(0.15)
    butchAct.ShowBarterMenu()
EndFunction

Event OnInit()
    BindHubListeners(False)
    Actor player = Game.GetPlayer()
    WorldSpace caliWorld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if player != None && caliWorld != None && player.GetWorldSpace() == caliWorld
        StartTimer(2.5, 99)
    endif
EndEvent

Event OnQuestInit()
    BindHubListeners(False)
    Actor player = Game.GetPlayer()
    WorldSpace caliWorld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if player != None && caliWorld != None && player.GetWorldSpace() == caliWorld
        StartTimer(2.5, 99)
    endif
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
    BindHubListeners(False)
    Actor player = Game.GetPlayer()
    WorldSpace caliWorld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if player != None && caliWorld != None && player.GetWorldSpace() == caliWorld
        StartTimer(2.5, 99)
    endif
EndEvent

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
    BindHubListeners()
    Actor pLoc = Game.GetPlayer()
    WorldSpace caliLoc = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if pLoc != None && caliLoc != None && pLoc.GetWorldSpace() == caliLoc
        StartTimer(1.0, 97)
    endif
EndEvent

Function NotifyHubDeedRecovered()
    if bDeedRecovered
        return
    endif
    bDeedRecovered = True
    bDeedSeeded = True
    Actor kragRef = Game.GetFormFromFile(0x000035C9, "Vault13Chronicles.esp") as Actor
    Form deedBase = Game.GetFormFromFile(0x00001452, "Vault13Chronicles.esp")
    if kragRef != None && deedBase != None && kragRef.GetItemCount(deedBase) > 0
        kragRef.RemoveItem(deedBase, kragRef.GetItemCount(deedBase), True)
    endif
    if Self.GetStage() < 25
        Self.SetStage(25)
    endif
    BindHubListeners(False)
EndFunction

Function DeliverDeedToButch()
    if bItemDelivered
        return
    endif
    bItemDelivered = True
    Actor player = Game.GetPlayer()
    Form deedBase = Game.GetFormFromFile(0x00001452, "Vault13Chronicles.esp")
    if deedBase != None && player.GetItemCount(deedBase) > 0
        player.RemoveItem(deedBase, 1, True)
    endif
    Form noteBase = Game.GetFormFromFile(0x0000114B, "Vault13Chronicles.esp")
    if noteBase != None && player.GetItemCount(noteBase) == 0
        player.AddItem(noteBase, 1, True)
    endif
    Form stimpak = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
    if stimpak != None
        player.AddItem(stimpak, 3, False)
    endif
    if Self.GetStage() < 30
        Self.SetStage(30)
    endif
EndFunction

Event ObjectReference.OnItemAdded(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    Form deedBase = Game.GetFormFromFile(0x00001452, "Vault13Chronicles.esp")
    if akBaseItem == deedBase
        NotifyHubDeedRecovered()
    endif
EndEvent

Event ObjectReference.OnItemRemoved(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
    Form deedBase = Game.GetFormFromFile(0x00001452, "Vault13Chronicles.esp")
    if akBaseItem == deedBase
        NotifyHubDeedRecovered()
    endif
EndEvent

Function SanitizeKragCampPeace()
    if bKragCampHostile
        return
    endif
    Faction raiderFact = Game.GetFormFromFile(0x0001CBED, "Fallout4.esm") as Faction
    ActorValue aggrAV = Game.GetAggressionAV()
    Actor kragAct = Game.GetFormFromFile(0x000035C9, "Vault13Chronicles.esp") as Actor
    Actor raiderAct = Game.GetFormFromFile(0x000035CA, "Vault13Chronicles.esp") as Actor
    Actor player = Game.GetPlayer()
    if kragAct != None && !kragAct.IsDead()
        if raiderFact != None && kragAct.IsInFaction(raiderFact)
            kragAct.RemoveFromFaction(raiderFact)
        endif
        if aggrAV != None
            kragAct.SetValue(aggrAV, 0.0)
        endif
        if !kragAct.IsInCombat() || kragAct.GetCombatTarget() != player
            kragAct.StopCombat()
        endif
        kragAct.EvaluatePackage()
    endif
    if raiderAct != None && !raiderAct.IsDead()
        if raiderFact != None && raiderAct.IsInFaction(raiderFact)
            raiderAct.RemoveFromFaction(raiderFact)
        endif
        if aggrAV != None
            raiderAct.SetValue(aggrAV, 0.0)
        endif
        if !raiderAct.IsInCombat() || raiderAct.GetCombatTarget() != player
            raiderAct.StopCombat()
        endif
        raiderAct.EvaluatePackage()
    endif
EndFunction

Function TriggerKragCampHostile()
    bKragCampHostile = True
    Scene confStopHb = Game.GetFormFromFile(0x000D7300, "Vault13Chronicles.esp") as Scene
    if confStopHb != None && confStopHb.IsPlaying()
        confStopHb.Stop()
    endif
    if Self.GetStage() < 20
        EnsureHubStage20Active()
    endif
    Actor player = Game.GetPlayer()
    Faction playerFact = Game.GetFormFromFile(0x0001C21C, "Fallout4.esm") as Faction
    ActorValue aggrAV = Game.GetAggressionAV()
    ActorValue confAV = Game.GetConfidenceAV()
    Actor kragAct = Game.GetFormFromFile(0x000035C9, "Vault13Chronicles.esp") as Actor
    Actor raiderAct = Game.GetFormFromFile(0x000035CA, "Vault13Chronicles.esp") as Actor
    if kragAct != None && !kragAct.IsDead()
        if playerFact != None && kragAct.IsInFaction(playerFact)
            kragAct.RemoveFromFaction(playerFact)
        endif
        if aggrAV != None
            kragAct.SetValue(aggrAV, 2.0)
        endif
        if confAV != None
            kragAct.SetValue(confAV, 4.0)
        endif
        if player != None && kragAct.Is3DLoaded()
            kragAct.StartCombat(player)
        endif
    endif
    if raiderAct != None && !raiderAct.IsDead()
        if playerFact != None && raiderAct.IsInFaction(playerFact)
            raiderAct.RemoveFromFaction(playerFact)
        endif
        if aggrAV != None
            raiderAct.SetValue(aggrAV, 2.0)
        endif
        if confAV != None
            raiderAct.SetValue(confAV, 4.0)
        endif
        if player != None && raiderAct.Is3DLoaded()
            raiderAct.StartCombat(player)
        endif
    endif
EndFunction

Event OnHit(ObjectReference akTarget, ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked, string asMaterialName)
    if akTarget != None
        RegisterForHitEvent(akTarget)
    endif
    if bKragCampHostile || akTarget == None || akAggressor == None
        return
    endif
    Actor player = Game.GetPlayer()
    Actor aggAct = akAggressor as Actor
    bool isPlayerHit = (player != None && akAggressor == (player as ObjectReference)) || (aggAct != None && aggAct.IsPlayerTeammate())
    if !isPlayerHit
        return
    endif
    ObjectReference kragHit = Game.GetFormFromFile(0x000035C9, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference raiderHit = Game.GetFormFromFile(0x000035CA, "Vault13Chronicles.esp") as ObjectReference
    if (kragHit != None && akTarget == kragHit) || (raiderHit != None && akTarget == raiderHit)
        TriggerKragCampHostile()
    endif
EndEvent

Event Actor.OnDeath(Actor akSender, Actor akKiller)
    Actor kragRef = Game.GetFormFromFile(0x000035C9, "Vault13Chronicles.esp") as Actor
    if akSender == kragRef
        Form deedBase = Game.GetFormFromFile(0x00001452, "Vault13Chronicles.esp")
        Actor player = Game.GetPlayer()
        if !bDeedSeeded && !bDeedRecovered && deedBase != None && player != None && player.GetItemCount(deedBase) == 0 && kragRef.GetItemCount(deedBase) == 0
            kragRef.AddItem(deedBase, 1, True)
            bDeedSeeded = True
        endif
        ForceQuestAlias(1, 0x000035C9)
        if Self.GetStage() < 20
            Self.SetStage(20)
        endif
        if bDeedRecovered || (deedBase != None && player != None && player.GetItemCount(deedBase) > 0)
            if Self.GetStage() < 25
                Self.SetStage(25)
            endif
        elseif Self.GetStage() < 22
            Self.SetStage(22)
        endif
        StartTimer(0.8, 90)
    endif
EndEvent

Event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
    if akActionRef != Game.GetPlayer()
        return
    endif
    ObjectReference irwinRef = Game.GetFormFromFile(0x000035C6, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference haroldRef = Game.GetFormFromFile(0x000035C7, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference butchRef = Game.GetFormFromFile(0x000035C8, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference kragObjRef = Game.GetFormFromFile(0x000035C9, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference raiderObjRef = Game.GetFormFromFile(0x000035CA, "Vault13Chronicles.esp") as ObjectReference
    Actor kragAct = kragObjRef as Actor
    Form deedBase = Game.GetFormFromFile(0x00001452, "Vault13Chronicles.esp")
    Actor player = Game.GetPlayer()

    if akSender == kragObjRef
        if kragAct != None && kragAct.IsDead()
            if deedBase != None && player != None && player.GetItemCount(deedBase) == 0 && !bItemDelivered
                if kragAct.GetItemCount(deedBase) > 0
                    kragAct.RemoveItem(deedBase, kragAct.GetItemCount(deedBase), True)
                endif
                player.AddItem(deedBase, 1, False)
            endif
            NotifyHubDeedRecovered()
            return
        endif
        if kragAct != None && !kragAct.IsDead() && !kragAct.IsInCombat() && !bKragCampHostile
            int curKragStg = Self.GetStage()
            if curKragStg < 20
                if curKragStg < 12
                    Self.SetStage(12)
                endif
                ForceQuestAlias(0, 0x000035C6)
                if !IsObjectiveDisplayed(12)
                    SetObjectiveDisplayed(12, True, False)
                    Self.SetActive(True)
                endif
                Debug.Notification("Krag: 'This land already has an owner, stranger. If old Irwin in The Hub has a complaint, go talk to him first.'")
                return
            elseif curKragStg < 25 && !bKragCampTruce && !bDeedRecovered && !bKragCampHostile
                ForceQuestAlias(1, 0x000035C9)
                kragAct.AllowPCDialogue(True)
                StartTimer(1.2, 96)
            endif
        endif
        return
    elseif raiderObjRef != None && akSender == raiderObjRef
        Actor raiderAct = raiderObjRef as Actor
        if raiderAct != None && !raiderAct.IsDead() && !raiderAct.IsInCombat() && !bKragCampHostile && !Self.IsCompleted() && !Self.IsStageDone(40) && !bRewardGranted
            if Self.GetStage() < 20
                if Self.GetStage() < 12
                    Self.SetStage(12)
                endif
                ForceQuestAlias(0, 0x000035C6)
                if !IsObjectiveDisplayed(12)
                    SetObjectiveDisplayed(12, True, False)
                    Self.SetActive(True)
                endif
                Debug.Notification("Hired Thug: 'Go talk to old Irwin in The Hub if you want to know who took his farm.'")
            else
                Debug.Notification("Hired Thug: 'Krag calls the shots here. Talk to him in front of the shack.'")
            endif
        endif
        return
    endif

    ForceAllHubAliases()
    int curStage = Self.GetStage()
    if Self.IsCompleted() || Self.IsStageDone(40) || bRewardGranted
        bRewardGranted = True
        curStage = 40
    endif
    if (akSender == butchRef || akSender == haroldRef) && (curStage == 22 || curStage == 25 || (deedBase != None && player.GetItemCount(deedBase) > 0 && curStage < 30))
        SilenceHubActorsExcept(akSender as Actor, 0)
        NotifyHubDeedRecovered()
        DeliverDeedToButch()
    elseif akSender == irwinRef && (curStage == 25 || curStage == 30 || (bItemDelivered && curStage < 40) || (deedBase != None && player.GetItemCount(deedBase) > 0 && curStage < 40))
        SilenceHubActorsExcept(irwinRef as Actor, 0)
        if !bItemDelivered
            DeliverDeedToButch()
        endif
        if Self.GetStage() < 40
            Self.SetStage(40)
        endif
    elseif akSender == butchRef
        if curStage >= 25 || player.IsSneaking()
            Message barterMsg = Game.GetFormFromFile(0x00001C71, "Vault13Chronicles.esp") as Message
            if barterMsg != None
                int choice = barterMsg.Show()
                if choice == 0
                    OpenButchBarter()
                    return
                elseif choice == 2
                    return
                endif
            endif
        endif
        SilenceHubActorsExcept(butchRef as Actor, 2)
        if curStage < 25
            EnsureHubStage20Active()
            CancelTimer(91)
            CancelTimer(93)
            sceneWaitTicks = 0
            StartTimer(1.2, 92)
            StartTimer(2.0, 94)
        endif
    elseif akSender == irwinRef && curStage < 25
        SilenceHubActorsExcept(irwinRef as Actor, 1)
        EnsureHubStage20Active()
        CancelTimer(92)
        CancelTimer(93)
        sceneWaitTicks = 0
        StartTimer(1.2, 91)
        StartTimer(2.0, 94)
    elseif akSender == haroldRef && curStage < 25
        SilenceHubActorsExcept(haroldRef as Actor, 3)
        EnsureHubStage20Active()
        CancelTimer(91)
        CancelTimer(92)
        sceneWaitTicks = 0
        StartTimer(1.2, 93)
        StartTimer(2.0, 94)
    endif
EndEvent

Function QueueJumpToHub()
    if bMenuJumpBusy
        return
    endif
    bMenuJumpBusy = True
    BindHubListeners()
    StartTimer(0.6, 95)
EndFunction

Event OnTimer(int aiTimerID)
    if aiTimerID == 90
        Actor kragRef = Game.GetFormFromFile(0x000035C9, "Vault13Chronicles.esp") as Actor
        Actor player = Game.GetPlayer()
        Form deedBase = Game.GetFormFromFile(0x00001452, "Vault13Chronicles.esp")
        if bDeedRecovered || bItemDelivered || Self.GetStage() >= 25
            return
        endif
        if player != None && deedBase != None && player.GetItemCount(deedBase) > 0
            NotifyHubDeedRecovered()
            return
        endif
        if kragRef != None && kragRef.IsDead()
            if deedBase != None && kragRef.GetItemCount(deedBase) == 0 && bDeedSeeded
                if player != None && player.GetItemCount(deedBase) == 0
                    player.AddItem(deedBase, 1, False)
                endif
                NotifyHubDeedRecovered()
                return
            endif
            if Self.GetStage() < 25
                StartTimer(0.8, 90)
            endif
        endif
    elseif aiTimerID == 91
        Scene introScene = Game.GetFormFromFile(0x00011100, "Vault13Chronicles.esp") as Scene
        Actor irwinActor = Game.GetFormFromFile(0x000035C6, "Vault13Chronicles.esp") as Actor
        if Self.IsRunning() && introScene != None && Self.GetStage() < 25
            if !introScene.IsPlaying() && !Utility.IsInMenuMode() && (irwinActor == None || (!irwinActor.IsInDialogueWithPlayer() && !irwinActor.IsTalking()))
                ForceAllHubAliases()
                SilenceHubActorsExcept(irwinActor, 1)
                if Self.IsRunning()
                    introScene.Start()
                endif
            endif
        endif
    elseif aiTimerID == 92
        Scene butchScene = Game.GetFormFromFile(0x00011101, "Vault13Chronicles.esp") as Scene
        Actor butchActor = Game.GetFormFromFile(0x000035C8, "Vault13Chronicles.esp") as Actor
        if Self.IsRunning() && butchScene != None && Self.GetStage() < 25
            if !butchScene.IsPlaying() && !Utility.IsInMenuMode() && (butchActor == None || (!butchActor.IsInDialogueWithPlayer() && !butchActor.IsTalking()))
                ForceAllHubAliases()
                SilenceHubActorsExcept(butchActor, 2)
                if Self.IsRunning()
                    butchScene.Start()
                endif
            endif
        endif
    elseif aiTimerID == 93
        Scene haroldScene = Game.GetFormFromFile(0x00011102, "Vault13Chronicles.esp") as Scene
        Actor haroldActor = Game.GetFormFromFile(0x000035C7, "Vault13Chronicles.esp") as Actor
        if Self.IsRunning() && haroldScene != None && Self.GetStage() < 25
            if !haroldScene.IsPlaying() && !Utility.IsInMenuMode() && (haroldActor == None || (!haroldActor.IsInDialogueWithPlayer() && !haroldActor.IsTalking()))
                ForceAllHubAliases()
                SilenceHubActorsExcept(haroldActor, 3)
                if Self.IsRunning()
                    haroldScene.Start()
                endif
            endif
        endif
    elseif aiTimerID == 94
        if Self.GetStage() <= 20
            EnsureHubStage20Active()
        endif
    elseif aiTimerID == 96
        Scene confSceneHb = Game.GetFormFromFile(0x000D7300, "Vault13Chronicles.esp") as Scene
        Actor kragAct = Game.GetFormFromFile(0x000035C9, "Vault13Chronicles.esp") as Actor
        if Self.IsRunning() && confSceneHb != None && Self.GetStage() < 25 && !bKragCampTruce && !bDeedRecovered && !bKragCampHostile
            if !confSceneHb.IsPlaying() && !Utility.IsInMenuMode() && kragAct != None && !kragAct.IsDead() && !kragAct.IsInCombat() && !kragAct.IsInDialogueWithPlayer() && !kragAct.IsTalking()
                ForceQuestAlias(1, 0x000035C9)
                kragAct.AllowPCDialogue(True)
                confSceneHb.Start()
            endif
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
        ObjectReference mapMarker = Game.GetFormFromFile(0x0000341D, "Vault13Chronicles.esp") as ObjectReference
        if mapMarker != None
            mapMarker.EnableNoWait()
            mapMarker.AddToMap(True)
        endif
        ObjectReference ftMarker = Game.GetFormFromFile(0x0000351D, "Vault13Chronicles.esp") as ObjectReference
        if ftMarker != None
            player.MoveTo(ftMarker)
            RefreshHubSettlementLayout()
            StartTimer(1.0, 97)
            Debug.Notification("Traveled to The Hub (2161). Speak with Irwin, Old Harold, or Butch Harris.")
        endif
    elseif aiTimerID == 97
        RefreshHubSettlementLayout()
    elseif aiTimerID == 98
        Scene confStopHbT = Game.GetFormFromFile(0x000D7300, "Vault13Chronicles.esp") as Scene
        if confStopHbT != None && confStopHbT.IsPlaying()
            confStopHbT.Stop()
        endif
        TriggerKragCampHostile()
    elseif aiTimerID == 99
        BindHubListeners(True)
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

    Actor player = Game.GetPlayer()
    Form deedBase = Game.GetFormFromFile(0x00001452, "Vault13Chronicles.esp")

    if auiStageID == 11
        if Self.GetStage() < 12 && !Self.IsCompleted()
            ForceQuestAlias(0, 0x000035C6)
            if !IsObjectiveDisplayed(11)
                SetObjectiveDisplayed(11, True, False)
                Self.SetActive(True)
            endif
        endif
    elseif auiStageID == 12
        if IsObjectiveDisplayed(11)
            SetObjectiveCompleted(11, True)
            SetObjectiveDisplayed(11, False, False)
        endif
        ForceQuestAlias(0, 0x000035C6)
        if !IsObjectiveDisplayed(12)
            SetObjectiveDisplayed(12, True, False)
            Self.SetActive(True)
        endif
    elseif auiStageID == 16 || auiStageID == 17 || auiStageID == 18
        if IsObjectiveDisplayed(11)
            SetObjectiveCompleted(11, True)
            SetObjectiveDisplayed(11, False, False)
        endif
        if IsObjectiveDisplayed(12)
            SetObjectiveCompleted(12, True)
            SetObjectiveDisplayed(12, False, False)
        endif
        if !bKragCampTruce
            bKragCampTruce = True
            if auiStageID == 18
                Form capsHb = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
                if capsHb != None && player != None && player.GetItemCount(capsHb) >= 250
                    player.RemoveItem(capsHb, 250, False)
                endif
            endif
            Actor kragTruce = Game.GetFormFromFile(0x000035C9, "Vault13Chronicles.esp") as Actor
            if deedBase != None && kragTruce != None && kragTruce.GetItemCount(deedBase) > 0
                kragTruce.RemoveItem(deedBase, kragTruce.GetItemCount(deedBase), True)
            endif
            if deedBase != None && player != None && player.GetItemCount(deedBase) == 0 && !bItemDelivered
                player.AddItem(deedBase, 1, False)
            endif
            NotifyHubDeedRecovered()
            SanitizeKragCampPeace()
            if auiStageID == 16
                Debug.Notification("[Intimidation] Krag backs down before your imposing presence and hands back Irwin's Farm deed.")
            elseif auiStageID == 17
                Debug.Notification("[Speech] Krag doesn't want to lose Hub trade routes and hands over the farm deed without a fight.")
            else
                Debug.Notification("[Ransom - 250 Caps] Krag takes the caps and tosses you the deed to Irwin's Farm.")
            endif
        endif
    elseif auiStageID == 21
        if !bKragCampHostile
            StartTimer(0.25, 98)
        endif
    elseif auiStageID == 20
        if IsObjectiveDisplayed(11)
            SetObjectiveCompleted(11, True)
            SetObjectiveDisplayed(11, False, False)
        endif
        if IsObjectiveDisplayed(12)
            SetObjectiveCompleted(12, True)
            SetObjectiveDisplayed(12, False, False)
        endif
        ObjectReference mapMarker = Game.GetFormFromFile(0x0000341D, "Vault13Chronicles.esp") as ObjectReference
        if mapMarker != None
            mapMarker.EnableNoWait()
            mapMarker.AddToMap(True)
        endif
        if deedBase != None && player.GetItemCount(deedBase) > 0
            Self.SetStage(25)
            return
        endif
        Actor kragRef = Game.GetFormFromFile(0x000035C9, "Vault13Chronicles.esp") as Actor
        if kragRef != None && kragRef.IsDead()
            Self.SetStage(22)
            return
        endif
        ForceQuestAlias(1, 0x000035C9)
        if !IsObjectiveDisplayed(20)
            SetObjectiveDisplayed(20, True, False)
            Self.SetActive(True)
        endif
        if doStg20
            Debug.Notification("Side Quest: Irwin's Farm - Eliminate Raider Chieftain Krag north of The Hub.")
        endif
        BindHubListeners(False)
        Quest qHubSyn20 = Game.GetFormFromFile(0x0001A000, "Vault13Chronicles.esp") as Quest
        V13SideQuestHubSyndicateScript sHubSyn20 = qHubSyn20 as V13SideQuestHubSyndicateScript
        if sHubSyn20 != None
            sHubSyn20.StartHubSyndicateQuest()
        endif
    elseif auiStageID == 22
        if deedBase != None && player.GetItemCount(deedBase) > 0
            Self.SetStage(25)
            return
        endif
        ForceQuestAlias(1, 0x000035C9)
        SetObjectiveCompleted(20, True)
        if !IsObjectiveDisplayed(22)
            SetObjectiveDisplayed(22, True, False)
            Self.SetActive(True)
        endif
        if doStg22
            Debug.Notification("Chieftain Krag slain! Recover Irwin's Farm Deed from his corpse.")
        endif
        BindHubListeners(False)
    elseif auiStageID == 25
        SetObjectiveCompleted(20, True)
        SetObjectiveCompleted(22, True)
        if !IsObjectiveDisplayed(25)
            SetObjectiveDisplayed(25, True, False)
            Self.SetActive(True)
        endif
        if doStg25
            Debug.Notification("Farm Deed recovered. Register the property liberation with Butch Harris in The Hub.")
        endif
        BindHubListeners(False)
    elseif auiStageID == 30
        if !bItemDelivered
            DeliverDeedToButch()
        endif
        SetObjectiveCompleted(20, True)
        SetObjectiveCompleted(22, True)
        SetObjectiveCompleted(25, True)
        if !IsObjectiveDisplayed(30)
            SetObjectiveDisplayed(30, True, False)
            Self.SetActive(True)
        endif
        if doStg30
            Debug.Notification("Butch Harris registered the deed! Speak with Irwin in The Hub to receive the '.223 Pistol'.")
        endif
        BindHubListeners(False)
    elseif auiStageID == 40
        SetObjectiveCompleted(20, True)
        SetObjectiveCompleted(22, True)
        SetObjectiveCompleted(25, True)
        SetObjectiveCompleted(30, True)
        if doReward40
            Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
            Form pistol223 = Game.GetFormFromFile(0x00001105, "Vault13Chronicles.esp")
            Form ammo44 = Game.GetFormFromFile(0x0009221C, "Fallout4.esm")
            Form stimpak = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
            if caps != None
                player.AddItem(caps, 500, False)
            endif
            if pistol223 != None && player.GetItemCount(pistol223) == 0
                player.AddItem(pistol223, 1, False)
            endif
            if ammo44 != None
                player.AddItem(ammo44, 48, False)
            endif
            if stimpak != None
                player.AddItem(stimpak, 4, False)
            endif
            Game.RewardPlayerXP(350)
            Debug.Notification("Side Quest completed: Irwin's Farm! (+'.223 Pistol', +500 Caps, and +350 XP)")
        endif
        Self.CompleteAllObjectives()
        Self.CompleteQuest()
        BindHubListeners(False)
    endif
EndEvent
