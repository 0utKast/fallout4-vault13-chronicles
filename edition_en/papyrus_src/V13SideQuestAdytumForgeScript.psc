Scriptname V13SideQuestAdytumForgeScript extends Quest

bool bStg20Notified = False
bool bStg25Notified = False
bool bStg30Notified = False
bool bRewardGranted = False
bool bHydroRecovered = False
bool bHydroDelivered = False
bool bJournalsRecovered = False
bool bTurboPlasmaCrafted = False
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

Function ForceAllAdytumForgeAliases()
    int stg = Self.GetStage()
    if Self.IsCompleted() || stg >= 40 || Self.IsStageDone(40) || bRewardGranted
        ClearQuestAlias(0)
        ClearQuestAlias(1)
        ClearQuestAlias(9)
        ClearQuestAlias(10)
        ClearQuestAlias(11)
        return
    endif
    ForceQuestAlias(0, 0x00003625)
    ForceQuestAlias(2, 0x00003005)
    ForceQuestAlias(3, 0x00002003)
    ForceQuestAlias(4, 0x00003520)
    ForceQuestAlias(5, 0x00002101)
    ForceQuestAlias(6, 0x00003501)
    ForceQuestAlias(7, 0x00002206)
    ForceQuestAlias(8, 0x00002035)
    ForceQuestAlias(9, 0x000035D5)
    ForceQuestAlias(10, 0x00003630)
    ForceQuestAlias(11, 0x00003631)
    if stg == 20
        ForceQuestAlias(1, 0x00003630)
    elseif stg == 22
        ForceQuestAlias(1, 0x00003625)
    elseif stg == 25
        ForceQuestAlias(1, 0x00003631)
    elseif stg == 30
        ForceQuestAlias(1, 0x00003625)
    endif
EndFunction

Function StopAdytumForgeScenes(int aiKeepSlot = 0)
    Scene milesPhase1Scene = Game.GetFormFromFile(0x000D3100, "Vault13Chronicles.esp") as Scene
    Scene milesPhase2Scene = Game.GetFormFromFile(0x000D3101, "Vault13Chronicles.esp") as Scene
    if aiKeepSlot != 1 && milesPhase1Scene != None && milesPhase1Scene.IsPlaying()
        milesPhase1Scene.Stop()
    endif
    if aiKeepSlot != 2 && milesPhase2Scene != None && milesPhase2Scene.IsPlaying()
        milesPhase2Scene.Stop()
    endif
EndFunction

Function EquipForgeScavengerGear(Actor akActor, int aiOutfitID, int aiBodyID, int aiHatID)
    if akActor == None || !akActor.Is3DLoaded() || akActor.IsDead() || akActor.IsTalking() || akActor.IsInDialogueWithPlayer()
        return
    endif
    Actor player = Game.GetPlayer()
    if player != None && akActor.GetDistance(player) < 2200.0
        return
    endif
    Outfit oForm = Game.GetFormFromFile(aiOutfitID, "Vault13Chronicles.esp") as Outfit
    if oForm != None
        akActor.SetOutfit(oForm, False)
    endif
    Form bItem = Game.GetFormFromFile(aiBodyID, "Fallout4.esm")
    if bItem != None
        if akActor.GetItemCount(bItem) == 0
            akActor.AddItem(bItem, 1, True)
        endif
        if !akActor.IsEquipped(bItem)
            akActor.EquipItem(bItem, False, True)
        endif
    endif
    if aiHatID != 0
        Form hItem = Game.GetFormFromFile(aiHatID, "Vault13Chronicles.esp")
        if hItem != None
            if akActor.GetItemCount(hItem) == 0
                akActor.AddItem(hItem, 1, True)
            endif
            if !akActor.IsEquipped(hItem)
                akActor.EquipItem(hItem, False, True)
            endif
        endif
    endif
EndFunction

Function RefreshMilesLayout()
    Actor player = Game.GetPlayer()
    WorldSpace caliWorld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if player == None || caliWorld == None || player.GetWorldSpace() != caliWorld
        return
    endif
    Actor milesAct = Game.GetFormFromFile(0x00003625, "Vault13Chronicles.esp") as Actor
    if milesAct != None && !milesAct.IsDead() && milesAct.Is3DLoaded()
        if !milesAct.IsInCombat() && !milesAct.IsTalking()
            if Math.Abs(milesAct.GetPositionX() + 7800.0) > 55.0 || Math.Abs(milesAct.GetPositionY() + 30850.0) > 55.0
                milesAct.SetPosition(-7800.0, -30850.0, 40.0)
                milesAct.SetAngle(0.0, 0.0, 180.0)
            endif
        endif
    endif
    Actor sammaelAct = Game.GetFormFromFile(0x00003628, "Vault13Chronicles.esp") as Actor
    if sammaelAct != None && !sammaelAct.IsDead()
        if sammaelAct.Is3DLoaded() && !sammaelAct.IsInCombat() && !sammaelAct.IsTalking()
            if Math.Abs(sammaelAct.GetPositionX() - 2200.0) > 55.0 || Math.Abs(sammaelAct.GetPositionY() + 34400.0) > 55.0
                sammaelAct.SetPosition(2200.0, -34400.0, 40.0)
                sammaelAct.SetAngle(0.0, 0.0, 270.0)
            endif
        endif
        EquipForgeScavengerGear(sammaelAct, 0x00001041, 0x00039A66, 0x00001314)
    endif
    ObjectReference hydroCrate = Game.GetFormFromFile(0x00003630, "Vault13Chronicles.esp") as ObjectReference
    if hydroCrate != None
        if hydroCrate.IsDisabled()
            hydroCrate.EnableNoWait()
        endif
        if hydroCrate.Is3DLoaded() && (Math.Abs(hydroCrate.GetPositionX() - 2320.0) > 55.0 || Math.Abs(hydroCrate.GetPositionY() + 34320.0) > 55.0)
            hydroCrate.SetPosition(2320.0, -34320.0, 40.0)
            hydroCrate.SetAngle(0.0, 0.0, 0.0)
        endif
        Form hydroParts = Game.GetFormFromFile(0x00001561, "Vault13Chronicles.esp")
        if hydroParts != None && !bHydroRecovered && !bHydroDelivered && Self.GetStage() < 22 && player.GetItemCount(hydroParts) == 0
            if hydroCrate.GetItemCount(hydroParts) == 0
                hydroCrate.AddItem(hydroParts, 1, True)
            endif
        endif
    endif
EndFunction

Function NotifyHydroponicPartsRecovered()
    if bHydroRecovered || Self.IsCompleted() || Self.GetStage() >= 40 || Self.IsStageDone(40) || bRewardGranted
        return
    endif
    bHydroRecovered = True
    if !Self.IsRunning() && !Self.IsCompleted()
        Self.Start()
    endif
    if Self.GetStage() < 22
        Self.SetStage(22)
    endif
EndFunction

Function NotifyChemistryJournalsRecovered()
    if bJournalsRecovered || Self.IsCompleted() || Self.GetStage() >= 40 || Self.IsStageDone(40) || bRewardGranted
        return
    endif
    bJournalsRecovered = True
    if !Self.IsRunning() && !Self.IsCompleted()
        Self.Start()
    endif
    if Self.GetStage() >= 25 && Self.GetStage() < 30
        Self.SetStage(30)
    endif
EndFunction

Function HandleSmittyForgeUpgrade()
    Actor player = Game.GetPlayer()
    if player == None
        return
    endif
    Form hydroParts = Game.GetFormFromFile(0x00001561, "Vault13Chronicles.esp")
    if !Self.IsCompleted() && !Self.IsStageDone(40) && !Self.IsStageDone(25) && !bHydroDelivered && !bRewardGranted && Self.GetStage() < 25
        if hydroParts != None && player.GetItemCount(hydroParts) > 0
            player.RemoveItem(hydroParts, 1, True)
            bHydroDelivered = True
            Self.SetStage(25)
            Debug.Notification("Smitty welded the Hydroponic Regulators for Miles's farms. The Turbo Forge is now open!")
        else
            if Self.GetStage() < 20
                Self.SetStage(20)
            endif
            Debug.Notification("Smitty: 'Help chemist Miles fix Adytum's hydroponic regulators first, and I'll calibrate your plasma rifle.'")
            return
        endif
    endif
    Form turboP94 = Game.GetFormFromFile(0x0000110B, "Vault13Chronicles.esp")
    Form stdPlasma = Game.GetFormFromFile(0x00100AE9, "Fallout4.esm")
    Form plasmaAmmo = Game.GetFormFromFile(0x0001DBB7, "Fallout4.esm")
    if !bTurboPlasmaCrafted
        bTurboPlasmaCrafted = True
        if stdPlasma != None && player.GetItemCount(stdPlasma) > 0
            player.RemoveItem(stdPlasma, 1, True)
        endif
        if turboP94 != None
            player.AddItem(turboP94, 1, False)
        endif
        if plasmaAmmo != None
            player.AddItem(plasmaAmmo, 60, False)
        endif
        Game.RewardPlayerXP(300)
        Debug.Notification("Smitty forged your Winchester P94 Turbo Plasma Rifle and 60 overcharged plasma cartridges! (+300 XP)")
    else
        Debug.Notification("Smitty: 'That Winchester P94 Turbo accelerator is calibrated to its thermal limit, traveler. Put it to good use against the mutants.'")
    endif
EndFunction

Function BindAdytumForgeListeners(bool abRefreshLayout = True)
    if Self.IsCompleted() || Self.GetStage() >= 40 || Self.IsStageDone(40) || bRewardGranted
        bRewardGranted = True
        bHydroDelivered = True
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
    Actor player = Game.GetPlayer()
    Form hydroParts = Game.GetFormFromFile(0x00001561, "Vault13Chronicles.esp")
    Form chemJournals = Game.GetFormFromFile(0x00001562, "Vault13Chronicles.esp")
    int curStg = Self.GetStage()
    if !Self.IsCompleted() && player != None
        if curStg >= 11 && curStg <= 20 && hydroParts != None && player.GetItemCount(hydroParts) > 0
            bHydroRecovered = True
            Self.SetStage(22)
        elseif curStg >= 25 && curStg < 30 && chemJournals != None && player.GetItemCount(chemJournals) > 0
            bJournalsRecovered = True
            Self.SetStage(30)
        endif
    endif
    ForceAllAdytumForgeAliases()
    if abRefreshLayout
        RefreshMilesLayout()
    endif

    Self.RemoveAllInventoryEventFilters()
    if hydroParts != None
        Self.AddInventoryEventFilter(hydroParts)
    endif
    if chemJournals != None
        Self.AddInventoryEventFilter(chemJournals)
    endif
    if player != None
        RegisterForRemoteEvent(player, "OnPlayerLoadGame")
        RegisterForRemoteEvent(player, "OnLocationChange")
        RegisterForRemoteEvent(player as ObjectReference, "OnItemAdded")
    endif

    ObjectReference milesRef = Game.GetFormFromFile(0x00003625, "Vault13Chronicles.esp") as ObjectReference
    if milesRef != None
        RegisterForRemoteEvent(milesRef, "OnActivate")
    endif
    ObjectReference sammaelRef = Game.GetFormFromFile(0x00003628, "Vault13Chronicles.esp") as ObjectReference
    if sammaelRef != None
        RegisterForRemoteEvent(sammaelRef, "OnActivate")
    endif
    ObjectReference crateRef = Game.GetFormFromFile(0x00003630, "Vault13Chronicles.esp") as ObjectReference
    if crateRef != None
        RegisterForRemoteEvent(crateRef, "OnActivate")
    endif
    ObjectReference journalsChestRef = Game.GetFormFromFile(0x00003631, "Vault13Chronicles.esp") as ObjectReference
    if journalsChestRef != None
        RegisterForRemoteEvent(journalsChestRef, "OnActivate")
    endif
EndFunction

Event OnInit()
    BindAdytumForgeListeners(False)
    Actor player = Game.GetPlayer()
    WorldSpace caliWorld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if player != None && caliWorld != None && player.GetWorldSpace() == caliWorld
        StartTimer(2.5, 98)
    endif
EndEvent

Event OnQuestInit()
    BindAdytumForgeListeners(False)
    Actor player = Game.GetPlayer()
    WorldSpace caliWorld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if player != None && caliWorld != None && player.GetWorldSpace() == caliWorld
        StartTimer(2.5, 98)
    endif
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
    BindAdytumForgeListeners(False)
    Actor player = Game.GetPlayer()
    WorldSpace caliWorld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if player != None && caliWorld != None && player.GetWorldSpace() == caliWorld
        StartTimer(2.5, 98)
    endif
EndEvent

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
    BindAdytumForgeListeners()
EndEvent

Event ObjectReference.OnItemAdded(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    Form hydroParts = Game.GetFormFromFile(0x00001561, "Vault13Chronicles.esp")
    Form chemJournals = Game.GetFormFromFile(0x00001562, "Vault13Chronicles.esp")
    if akBaseItem == hydroParts
        NotifyHydroponicPartsRecovered()
    elseif akBaseItem == chemJournals
        NotifyChemistryJournalsRecovered()
    endif
EndEvent

Event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
    if akActionRef != Game.GetPlayer()
        return
    endif
    Actor player = Game.GetPlayer()
    Form hydroParts = Game.GetFormFromFile(0x00001561, "Vault13Chronicles.esp")
    Form chemJournals = Game.GetFormFromFile(0x00001562, "Vault13Chronicles.esp")
    ObjectReference milesRef = Game.GetFormFromFile(0x00003625, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference crateRef = Game.GetFormFromFile(0x00003630, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference journalsChestRef = Game.GetFormFromFile(0x00003631, "Vault13Chronicles.esp") as ObjectReference
    if akSender == crateRef
        if !Self.IsCompleted() && Self.GetStage() < 22 && hydroParts != None && player != None && player.GetItemCount(hydroParts) == 0 && crateRef.GetItemCount(hydroParts) == 0
            player.AddItem(hydroParts, 1, False)
            NotifyHydroponicPartsRecovered()
        endif
        return
    elseif akSender == journalsChestRef
        if !Self.IsCompleted() && Self.GetStage() >= 25 && Self.GetStage() < 30 && chemJournals != None && player != None && player.GetItemCount(chemJournals) == 0 && journalsChestRef.GetItemCount(chemJournals) == 0
            player.AddItem(chemJournals, 1, False)
            NotifyChemistryJournalsRecovered()
        endif
        return
    elseif akSender != milesRef
        return
    endif

    int stg = Self.GetStage()
    if Self.IsCompleted() || Self.IsStageDone(40) || bRewardGranted
        bRewardGranted = True
        stg = 40
    endif
    if stg >= 40
        return
    endif

    if stg >= 25 && stg < 40 && (stg == 30 || bJournalsRecovered || (chemJournals != None && player != None && player.GetItemCount(chemJournals) > 0))
        if chemJournals != None && player != None && player.GetItemCount(chemJournals) > 0
            player.RemoveItem(chemJournals, 1, True)
        endif
        StopAdytumForgeScenes(0)
        Self.SetStage(40)
        return
    elseif stg < 25 && (stg == 22 || bHydroRecovered || (hydroParts != None && player != None && player.GetItemCount(hydroParts) > 0))
        if hydroParts != None && player != None && player.GetItemCount(hydroParts) > 0
            player.RemoveItem(hydroParts, 1, True)
        endif
        bHydroDelivered = True
        Self.SetStage(25)
        sceneWaitTicks = 0
        StartTimer(0.35, 91)
        return
    endif

    if stg < 20
        Self.SetStage(20)
    endif
    sceneWaitTicks = 0
    StartTimer(0.35, 91)
EndEvent

Event OnTimer(int aiTimerID)
    if aiTimerID == 91
        Actor milesAct = Game.GetFormFromFile(0x00003625, "Vault13Chronicles.esp") as Actor
        int stg = Self.GetStage()
        if !Self.IsRunning() || Self.IsCompleted() || stg >= 40
            return
        endif
        if Utility.IsInMenuMode() || (milesAct != None && (milesAct.IsInDialogueWithPlayer() || milesAct.IsTalking()))
            if sceneWaitTicks < 4
                sceneWaitTicks += 1
                StartTimer(0.4, 91)
            endif
            return
        endif
        int keepSlot = 1
        Scene targetScene = Game.GetFormFromFile(0x000D3100, "Vault13Chronicles.esp") as Scene
        if stg >= 25
            keepSlot = 2
            targetScene = Game.GetFormFromFile(0x000D3101, "Vault13Chronicles.esp") as Scene
        endif
        if targetScene != None && !targetScene.IsPlaying()
            sceneWaitTicks = 0
            ForceAllAdytumForgeAliases()
            StopAdytumForgeScenes(keepSlot)
            targetScene.Start()
        endif
    elseif aiTimerID == 98
        RefreshMilesLayout()
    endif
EndEvent

Event OnStageSet(int auiStageID, int auiItemID)
    BindAdytumForgeListeners(False)
    Actor player = Game.GetPlayer()
    if auiStageID == 11
        if Self.GetStage() < 12 && !Self.IsCompleted()
            ForceQuestAlias(0, 0x00003625)
            if !IsObjectiveDisplayed(11)
                SetObjectiveDisplayed(11, True, False)
                Self.SetActive(True)
            endif
        endif
    elseif auiStageID == 20
        if IsObjectiveDisplayed(11)
            SetObjectiveCompleted(11, True)
            SetObjectiveDisplayed(11, False, False)
        endif
        Form hydroParts = Game.GetFormFromFile(0x00001561, "Vault13Chronicles.esp")
        if hydroParts != None && player != None && player.GetItemCount(hydroParts) > 0
            Self.SetStage(22)
            return
        endif
        ForceQuestAlias(1, 0x00003630)
        if !IsObjectiveDisplayed(20)
            SetObjectiveDisplayed(20, True, False)
            Self.SetActive(True)
        endif
        if !bStg20Notified
            bStg20Notified = True
            Debug.Notification("Side Quest: The Forge of Adytum - Recover the Hydroponic Regulators from Sammael's outpost to the east.")
        endif
    elseif auiStageID == 22
        SetObjectiveCompleted(20, True)
        ForceQuestAlias(1, 0x00003625)
        if !IsObjectiveDisplayed(22)
            SetObjectiveDisplayed(22, True, False)
            Self.SetActive(True)
        endif
        Debug.Notification("Hydroponic Regulators recovered. Deliver them to chemist Miles or Smitty in Adytum.")
    elseif auiStageID == 25
        SetObjectiveCompleted(20, True)
        SetObjectiveCompleted(22, True)
        Form hydroRem = Game.GetFormFromFile(0x00001561, "Vault13Chronicles.esp")
        if hydroRem != None && player != None && player.GetItemCount(hydroRem) > 0
            player.RemoveItem(hydroRem, 1, True)
        endif
        bHydroDelivered = True
        Form chemJournals = Game.GetFormFromFile(0x00001562, "Vault13Chronicles.esp")
        if chemJournals != None && player != None && player.GetItemCount(chemJournals) > 0
            Self.SetStage(30)
            return
        endif
        ObjectReference hubMarker = Game.GetFormFromFile(0x0000341D, "Vault13Chronicles.esp") as ObjectReference
        if hubMarker != None
            hubMarker.EnableNoWait()
            hubMarker.AddToMap(True)
        endif
        ForceQuestAlias(1, 0x00003631)
        if !IsObjectiveDisplayed(25)
            SetObjectiveDisplayed(25, True, False)
            Self.SetActive(True)
        endif
        if !bStg25Notified
            bStg25Notified = True
            Debug.Notification("Adytum farms restored! Smitty can now calibrate your Turbo Plasma Rifle; find the Chemistry Books in The Hub to harden your Power Armor.")
        endif
    elseif auiStageID == 30
        SetObjectiveCompleted(20, True)
        SetObjectiveCompleted(22, True)
        SetObjectiveCompleted(25, True)
        ForceQuestAlias(1, 0x00003625)
        if !IsObjectiveDisplayed(30)
            SetObjectiveDisplayed(30, True, False)
            Self.SetActive(True)
        endif
        if !bStg30Notified
            bStg30Notified = True
            Debug.Notification("Polymer Chemistry Treatises recovered. Deliver them to Miles in Adytum to harden your Power Armor.")
        endif
    elseif auiStageID == 40
        SetObjectiveCompleted(20, True)
        SetObjectiveCompleted(22, True)
        SetObjectiveCompleted(25, True)
        SetObjectiveCompleted(30, True)
        Form chemRem = Game.GetFormFromFile(0x00001562, "Vault13Chronicles.esp")
        if chemRem != None && player != None && player.GetItemCount(chemRem) > 0
            player.RemoveItem(chemRem, 1, True)
        endif
        StopAdytumForgeScenes(0)
        Self.CompleteAllObjectives()
        ClearQuestAlias(0)
        ClearQuestAlias(1)
        ClearQuestAlias(9)
        ClearQuestAlias(10)
        ClearQuestAlias(11)
        if !bRewardGranted
            bRewardGranted = True
            if player != None
                Form paHelm = Game.GetFormFromFile(0x00001301, "Vault13Chronicles.esp")
                Form paTorso = Game.GetFormFromFile(0x00001302, "Vault13Chronicles.esp")
                Form paArmL = Game.GetFormFromFile(0x00001303, "Vault13Chronicles.esp")
                Form paArmR = Game.GetFormFromFile(0x00001304, "Vault13Chronicles.esp")
                Form paLegL = Game.GetFormFromFile(0x00001305, "Vault13Chronicles.esp")
                Form paLegR = Game.GetFormFromFile(0x00001306, "Vault13Chronicles.esp")
                Form fCore = Game.GetFormFromFile(0x00075FE4, "Fallout4.esm")
                if paHelm != None && player.GetItemCount(paHelm) == 0
                    player.AddItem(paHelm, 1, False)
                endif
                if paTorso != None && player.GetItemCount(paTorso) == 0
                    player.AddItem(paTorso, 1, False)
                endif
                if paArmL != None && player.GetItemCount(paArmL) == 0
                    player.AddItem(paArmL, 1, False)
                endif
                if paArmR != None && player.GetItemCount(paArmR) == 0
                    player.AddItem(paArmR, 1, False)
                endif
                if paLegL != None && player.GetItemCount(paLegL) == 0
                    player.AddItem(paLegL, 1, False)
                endif
                if paLegR != None && player.GetItemCount(paLegR) == 0
                    player.AddItem(paLegR, 1, False)
                endif
                if fCore != None
                    player.AddItem(fCore, 2, False)
                endif
            endif
            Game.RewardPlayerXP(550)
            Debug.Notification("Quest Completed: The Forge of Adytum! Miles has tempered your Hardened Power Armor Mk. VI (+2 Fusion Cores and +550 XP).")
        endif
        Self.CompleteQuest()
    endif
EndEvent
