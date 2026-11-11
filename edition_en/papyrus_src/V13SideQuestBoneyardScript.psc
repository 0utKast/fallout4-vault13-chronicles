Scriptname V13SideQuestBoneyardScript extends Quest

bool bItemDelivered = False
bool bRewardGranted = False
bool bClawRecovered = False
bool bClawSeeded = False
bool bStg20Notified = False
bool bStg22Notified = False
bool bStg25Notified = False
bool bStg30Notified = False
bool bMenuJumpBusy = False
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

Function ForceAllBoneyardAliases()
    ForceQuestAlias(0, 0x000035D4)
    ForceQuestAlias(1, 0x000035D7)
    ForceQuestAlias(2, 0x00003005)
    ForceQuestAlias(3, 0x00002003)
    ForceQuestAlias(4, 0x00003520)
    ForceQuestAlias(5, 0x00002101)
    ForceQuestAlias(6, 0x00003501)
    ForceQuestAlias(7, 0x00002206)
    ForceQuestAlias(8, 0x00002035)
    ForceQuestAlias(9, 0x000035D5)
    ForceQuestAlias(10, 0x000035D6)
EndFunction

Function EquipBoneyardActorGear(Actor akAct, int aiOutfitID, int aiBodyArmorID, int aiChestArmorID, int aiHatID, int aiRemoveArmorID)
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
    if aiRemoveArmorID > 0
        Form oldGear = Game.GetFormFromFile(aiRemoveArmorID, "Fallout4.esm")
        if oldGear != None && akAct.GetItemCount(oldGear) > 0
            akAct.RemoveItem(oldGear, akAct.GetItemCount(oldGear), true, None)
        endif
    endif
    if aiChestArmorID == 0
        Form oldChest = Game.GetFormFromFile(0x00156C0D, "Fallout4.esm")
        if oldChest != None && akAct.GetItemCount(oldChest) > 0
            akAct.RemoveItem(oldChest, akAct.GetItemCount(oldChest), true, None)
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

Function RefreshBoneyardSettlementLayout()
    Actor gabrielAct = Game.GetFormFromFile(0x000035D4, "Vault13Chronicles.esp") as Actor
    if gabrielAct != None && !gabrielAct.IsDead() && gabrielAct.Is3DLoaded()
        if !gabrielAct.IsInCombat() && !gabrielAct.IsTalking()
            if Math.Abs(gabrielAct.GetPositionX() - 380.0) > 45.0 || Math.Abs(gabrielAct.GetPositionY() + 12620.0) > 45.0
                gabrielAct.SetPosition(380.0, -12620.0, 40.0)
                gabrielAct.SetAngle(0.0, 0.0, 90.0)
                gabrielAct.EvaluatePackage()
            elseif Math.Abs(gabrielAct.GetAngleZ() - 90.0) > 35.0 && Math.Abs(gabrielAct.GetAngleZ() - 90.0) < 325.0
                gabrielAct.SetAngle(0.0, 0.0, 90.0)
            endif
        endif
        EquipBoneyardActorGear(gabrielAct, 0x00001029, 0x0012A332, 0, 0x00001314, 0x0011E2C8)
    endif
    Actor smittyAct = Game.GetFormFromFile(0x000035D5, "Vault13Chronicles.esp") as Actor
    if smittyAct != None && !smittyAct.IsDead() && smittyAct.Is3DLoaded()
        if !smittyAct.IsInCombat() && !smittyAct.IsTalking()
            if smittyAct.GetPositionZ() > 52.0 || Math.Abs(smittyAct.GetPositionX() - 760.0) > 45.0 || Math.Abs(smittyAct.GetPositionY() + 12640.0) > 45.0
                smittyAct.SetPosition(760.0, -12640.0, 40.0)
                smittyAct.SetAngle(0.0, 0.0, 270.0)
                smittyAct.EvaluatePackage()
            elseif Math.Abs(smittyAct.GetAngleZ() - 270.0) > 35.0 && Math.Abs(smittyAct.GetAngleZ() - 270.0) < 325.0
                smittyAct.SetAngle(0.0, 0.0, 270.0)
            endif
        endif
        EquipBoneyardActorGear(smittyAct, 0x0000102A, 0x00039A66, 0, 0x00001315, 0)
    endif
    Actor nicoleAct = Game.GetFormFromFile(0x000035D6, "Vault13Chronicles.esp") as Actor
    if nicoleAct != None && !nicoleAct.IsDead() && nicoleAct.Is3DLoaded()
        if !nicoleAct.IsInCombat() && !nicoleAct.IsTalking()
            if Math.Abs(nicoleAct.GetPositionX() - 1020.0) > 45.0 || Math.Abs(nicoleAct.GetPositionY() + 12780.0) > 45.0
                nicoleAct.SetPosition(1020.0, -12780.0, 40.0)
                nicoleAct.SetAngle(0.0, 0.0, 270.0)
                nicoleAct.EvaluatePackage()
            elseif Math.Abs(nicoleAct.GetAngleZ() - 270.0) > 35.0 && Math.Abs(nicoleAct.GetAngleZ() - 270.0) < 325.0
                nicoleAct.SetAngle(0.0, 0.0, 270.0)
            endif
        endif
        EquipBoneyardActorGear(nicoleAct, 0x0000102B, 0x00178B68, 0, 0, 0x00068CF3)
    endif

    Form noteBase = Game.GetFormFromFile(0x0000114E, "Vault13Chronicles.esp")
    if noteBase != None
        ObjectReference noteRef = Game.FindClosestReferenceOfType(noteBase, 420.0, -12540.0, 40.0, 400.0)
        if noteRef != None && noteRef.GetContainer() == None
            noteRef.SetPosition(450.0, -12544.0, 96.5)
        endif
    endif

    Actor motherAct = Game.GetFormFromFile(0x000035D7, "Vault13Chronicles.esp") as Actor
    if motherAct != None
        if motherAct.IsDisabled()
            motherAct.EnableNoWait()
        endif
        if !motherAct.IsDead()
            float mx = motherAct.GetPositionX()
            float my = motherAct.GetPositionY()
            float mz = motherAct.GetPositionZ()
            bool bUndergroundOrSky = (mz < 30.0 || mz > 150.0)
            bool bFarFromArena = (Math.Abs(mx - 6800.0) > 450.0 || Math.Abs(my + 10400.0) > 450.0)
            if (bUndergroundOrSky && Self.GetStage() < 25) || (!motherAct.IsInCombat() && bFarFromArena)
                motherAct.SetPosition(6800.0, -10400.0, 48.0)
                ForceQuestAlias(1, 0x000035D7)
            endif
        endif
    endif
EndFunction

Function SilenceBoneyardActorsExcept(Actor akSpeaker, int aiKeepScene = 0)
    Scene gabrielScene = Game.GetFormFromFile(0x00014100, "Vault13Chronicles.esp") as Scene
    Scene smittyScene = Game.GetFormFromFile(0x00014101, "Vault13Chronicles.esp") as Scene
    if aiKeepScene != 1 && gabrielScene != None && gabrielScene.IsPlaying()
        gabrielScene.Stop()
    endif
    if aiKeepScene != 2 && smittyScene != None && smittyScene.IsPlaying()
        smittyScene.Stop()
    endif
    Topic stopTopic = Game.GetFormFromFile(0x00004003, "Vault13Chronicles.esp") as Topic
    if stopTopic == None
        return
    endif
    Actor gabrielAct = Game.GetFormFromFile(0x000035D4, "Vault13Chronicles.esp") as Actor
    Actor smittyAct = Game.GetFormFromFile(0x000035D5, "Vault13Chronicles.esp") as Actor
    Actor nicoleAct = Game.GetFormFromFile(0x000035D6, "Vault13Chronicles.esp") as Actor
    if gabrielAct != None && gabrielAct != akSpeaker && gabrielAct.IsTalking()
        gabrielAct.Say(stopTopic, None, false, None)
    endif
    if smittyAct != None && smittyAct != akSpeaker && smittyAct.IsTalking()
        smittyAct.Say(stopTopic, None, false, None)
    endif
    if nicoleAct != None && nicoleAct != akSpeaker && nicoleAct.IsTalking()
        nicoleAct.Say(stopTopic, None, false, None)
    endif
EndFunction

Function SetupBoneyardListeners()
    if !Self.IsRunning() && !Self.IsCompleted()
        Self.Start()
    endif
    if Self.GetStage() < 10
        Self.SetStage(10)
    endif
    ForceAllBoneyardAliases()
    RefreshBoneyardSettlementLayout()

    Actor player = Game.GetPlayer()
    Form clawBase = Game.GetFormFromFile(0x00001455, "Vault13Chronicles.esp")
    Self.RemoveAllInventoryEventFilters()
    if clawBase != None
        Self.AddInventoryEventFilter(clawBase)
    endif
    if player != None
        RegisterForRemoteEvent(player, "OnPlayerLoadGame")
        RegisterForRemoteEvent(player, "OnLocationChange")
        if clawBase != None
            RegisterForRemoteEvent(player as ObjectReference, "OnItemAdded")
        endif
    endif

    ObjectReference gabrielRef = Game.GetFormFromFile(0x000035D4, "Vault13Chronicles.esp") as ObjectReference
    if gabrielRef != None
        RegisterForRemoteEvent(gabrielRef, "OnActivate")
        EnsureBoneyardVendorReady(gabrielRef as Actor, 0x00001C54, 0x000035E4, True)
    endif
    ObjectReference smittyRef = Game.GetFormFromFile(0x000035D5, "Vault13Chronicles.esp") as ObjectReference
    if smittyRef != None
        RegisterForRemoteEvent(smittyRef, "OnActivate")
        EnsureBoneyardVendorReady(smittyRef as Actor, 0x00001C53, 0x000035E3, False)
    endif
    ObjectReference nicoleRef = Game.GetFormFromFile(0x000035D6, "Vault13Chronicles.esp") as ObjectReference
    if nicoleRef != None
        RegisterForRemoteEvent(nicoleRef, "OnActivate")
    endif
    Actor motherRef = Game.GetFormFromFile(0x000035D7, "Vault13Chronicles.esp") as Actor
    if motherRef != None
        RegisterForRemoteEvent(motherRef, "OnDeath")
        RegisterForRemoteEvent(motherRef as ObjectReference, "OnActivate")
        if clawBase != None
            AddInventoryEventFilter(clawBase)
        endif
        RegisterForRemoteEvent(motherRef as ObjectReference, "OnItemRemoved")
        V13WastelandCreatureAIScript motherAI = (motherRef as ObjectReference) as V13WastelandCreatureAIScript
        if motherAI != None
            motherAI.InitCreatureAI()
        endif
        float mx = motherRef.GetPositionX()
        float my = motherRef.GetPositionY()
        float mz = motherRef.GetPositionZ()
        if !motherRef.IsDead()
            if (mz < 30.0 || mz > 150.0) && Self.GetStage() < 25
                motherRef.SetPosition(6800.0, -10400.0, 48.0)
                ForceQuestAlias(1, 0x000035D7)
            elseif !motherRef.IsInCombat()
                if Math.Abs(mx - 6800.0) > 450.0 || Math.Abs(my + 10400.0) > 450.0
                    motherRef.SetPosition(6800.0, -10400.0, 48.0)
                    ForceQuestAlias(1, 0x000035D7)
                endif
            endif
        endif
        if bClawRecovered || bItemDelivered || Self.GetStage() >= 25 || (player != None && clawBase != None && player.GetItemCount(clawBase) > 0)
            bClawRecovered = True
            bClawSeeded = True
            if clawBase != None && motherRef.GetItemCount(clawBase) > 0
                motherRef.RemoveItem(clawBase, motherRef.GetItemCount(clawBase), True)
            endif
        elseif motherRef.Is3DLoaded() && !bClawSeeded && clawBase != None
            if motherRef.GetItemCount(clawBase) == 0
                motherRef.AddItem(clawBase, 1, True)
            endif
            bClawSeeded = True
        endif
        if Self.GetStage() == 20 && motherRef.IsDead()
            if bClawRecovered || (player != None && clawBase != None && player.GetItemCount(clawBase) > 0)
                Self.SetStage(25)
            else
                Self.SetStage(22)
            endif
        endif
    endif
    if Self.GetStage() < 25 && player != None && player.GetWorldSpace() == (Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace)
        StartTimer(3.0, 97)
    endif
EndFunction

Function EnsureBoneyardVendorReady(Actor akVendor, int aiFactID, int aiChestID, bool abIsGabriel)
    if akVendor == None
        return
    endif
    Faction vFact = Game.GetFormFromFile(aiFactID, "Vault13Chronicles.esp") as Faction
    if vFact != None && !akVendor.IsInFaction(vFact)
        akVendor.AddToFaction(vFact)
    endif
    ObjectReference vChest = Game.GetFormFromFile(aiChestID, "Vault13Chronicles.esp") as ObjectReference
    Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
    if vChest != None
        if vChest.IsDisabled()
            vChest.EnableNoWait()
        endif
        if caps != None && vChest.GetItemCount(caps) < 500
            if abIsGabriel
                vChest.AddItem(caps, 2500, True)
            else
                vChest.AddItem(caps, 2000, True)
            endif
            Form aPlasma = Game.GetFormFromFile(0x0001DBB7, "Fallout4.esm")
            Form aFusion = Game.GetFormFromFile(0x000C1897, "Fallout4.esm")
            Form a308 = Game.GetFormFromFile(0x0001F66B, "Fallout4.esm")
            Form a556 = Game.GetFormFromFile(0x0001F278, "Fallout4.esm")
            Form a5mm = Game.GetFormFromFile(0x0001F66C, "Fallout4.esm")
            Form aShell = Game.GetFormFromFile(0x0001F673, "Fallout4.esm")
            Form wPlasma = Game.GetFormFromFile(0x00100AE9, "Fallout4.esm")
            Form wLaser = Game.GetFormFromFile(0x0009983B, "Fallout4.esm")
            Form wMinigun = Game.GetFormFromFile(0x0001F669, "Fallout4.esm")
            Form wARifle = Game.GetFormFromFile(0x0000463F, "Fallout4.esm")
            Form wShot = Game.GetFormFromFile(0x0014831C, "Fallout4.esm")
            Form cArmor = Game.GetFormFromFile(0x0011D3C3, "Fallout4.esm")
            Form stim = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
            if aPlasma != None && vChest.GetItemCount(aPlasma) < 40
                vChest.AddItem(aPlasma, 110, True)
            endif
            if aFusion != None && vChest.GetItemCount(aFusion) < 40
                vChest.AddItem(aFusion, 130, True)
            endif
            if a308 != None && vChest.GetItemCount(a308) < 40
                vChest.AddItem(a308, 110, True)
            endif
            if a556 != None && vChest.GetItemCount(a556) < 40
                vChest.AddItem(a556, 130, True)
            endif
            if a5mm != None && vChest.GetItemCount(a5mm) < 100
                vChest.AddItem(a5mm, 280, True)
            endif
            if aShell != None && vChest.GetItemCount(aShell) < 30
                vChest.AddItem(aShell, 80, True)
            endif
            if wPlasma != None && vChest.GetItemCount(wPlasma) == 0
                vChest.AddItem(wPlasma, 1, True)
            endif
            if wLaser != None && vChest.GetItemCount(wLaser) == 0
                vChest.AddItem(wLaser, 1, True)
            endif
            if abIsGabriel && wMinigun != None && vChest.GetItemCount(wMinigun) == 0
                vChest.AddItem(wMinigun, 1, True)
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
            if stim != None && vChest.GetItemCount(stim) < 6
                vChest.AddItem(stim, 12, True)
            endif
        endif
    endif
EndFunction

Function OpenBoneyardBarter(Actor akVendor, int aiFactID, int aiChestID, bool abIsGabriel)
    if akVendor == None || akVendor.IsDead()
        return
    endif
    EnsureBoneyardVendorReady(akVendor, aiFactID, aiChestID, abIsGabriel)
    Utility.Wait(0.15)
    akVendor.ShowBarterMenu()
EndFunction

Event OnInit()
    SetupBoneyardListeners()
EndEvent

Event OnQuestInit()
    SetupBoneyardListeners()
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
    SetupBoneyardListeners()
EndEvent

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
    SetupBoneyardListeners()
    StartTimer(1.0, 97)
EndEvent

Function NotifyBoneyardClawRecovered()
    if bClawRecovered
        return
    endif
    bClawRecovered = True
    bClawSeeded = True
    Actor motherRef = Game.GetFormFromFile(0x000035D7, "Vault13Chronicles.esp") as Actor
    Form clawBase = Game.GetFormFromFile(0x00001455, "Vault13Chronicles.esp")
    if motherRef != None && clawBase != None && motherRef.GetItemCount(clawBase) > 0
        motherRef.RemoveItem(clawBase, motherRef.GetItemCount(clawBase), True)
    endif
    if Self.GetStage() < 25
        Self.SetStage(25)
    endif
    SetupBoneyardListeners()
EndFunction

Function DeliverClawToSmitty()
    if bItemDelivered
        return
    endif
    bItemDelivered = True
    Actor player = Game.GetPlayer()
    Form clawBase = Game.GetFormFromFile(0x00001455, "Vault13Chronicles.esp")
    if clawBase != None && player.GetItemCount(clawBase) > 0
        player.RemoveItem(clawBase, 1, True)
    endif
    Form noteBase = Game.GetFormFromFile(0x0000114E, "Vault13Chronicles.esp")
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
    Form clawBase = Game.GetFormFromFile(0x00001455, "Vault13Chronicles.esp")
    if akBaseItem == clawBase
        NotifyBoneyardClawRecovered()
    endif
EndEvent

Event ObjectReference.OnItemRemoved(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
    Form clawBase = Game.GetFormFromFile(0x00001455, "Vault13Chronicles.esp")
    if akBaseItem == clawBase
        NotifyBoneyardClawRecovered()
    endif
EndEvent

Event Actor.OnDeath(Actor akSender, Actor akKiller)
    Actor motherRef = Game.GetFormFromFile(0x000035D7, "Vault13Chronicles.esp") as Actor
    if akSender == motherRef
        Form clawBase = Game.GetFormFromFile(0x00001455, "Vault13Chronicles.esp")
        Actor player = Game.GetPlayer()
        if !bClawSeeded && !bClawRecovered && clawBase != None && player != None && player.GetItemCount(clawBase) == 0 && motherRef.GetItemCount(clawBase) == 0
            motherRef.AddItem(clawBase, 1, True)
            bClawSeeded = True
        endif
        ForceQuestAlias(1, 0x000035D7)
        if bClawRecovered || (clawBase != None && player != None && player.GetItemCount(clawBase) > 0)
            if Self.GetStage() < 25
                Self.SetStage(25)
            endif
        elseif Self.GetStage() < 22
            Self.SetStage(22)
        endif
        StartTimer(0.8, 93)
    endif
EndEvent

Event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
    if akActionRef != Game.GetPlayer()
        return
    endif
    ObjectReference gabrielRef = Game.GetFormFromFile(0x000035D4, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference smittyRef = Game.GetFormFromFile(0x000035D5, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference nicoleRef = Game.GetFormFromFile(0x000035D6, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference motherObjRef = Game.GetFormFromFile(0x000035D7, "Vault13Chronicles.esp") as ObjectReference
    Actor motherAct = motherObjRef as Actor
    Form clawBase = Game.GetFormFromFile(0x00001455, "Vault13Chronicles.esp")
    Actor player = Game.GetPlayer()

    if akSender == motherObjRef
        if motherAct != None && motherAct.IsDead()
            if clawBase != None && player != None && player.GetItemCount(clawBase) == 0 && !bItemDelivered
                if motherAct.GetItemCount(clawBase) > 0
                    motherAct.RemoveItem(clawBase, motherAct.GetItemCount(clawBase), True)
                endif
                player.AddItem(clawBase, 1, False)
            endif
            NotifyBoneyardClawRecovered()
        endif
        return
    endif

    ForceAllBoneyardAliases()
    int curStage = Self.GetStage()
    if akSender == smittyRef && (curStage == 22 || curStage == 25 || (clawBase != None && player.GetItemCount(clawBase) > 0 && curStage < 30))
        SilenceBoneyardActorsExcept(smittyRef as Actor, 0)
        NotifyBoneyardClawRecovered()
        DeliverClawToSmitty()
        Topic helloTop = Game.GetFormFromFile(0x00014001, "Vault13Chronicles.esp") as Topic
        if helloTop != None && (smittyRef as Actor) != None && !(smittyRef as Actor).IsTalking()
            (smittyRef as Actor).Say(helloTop, None, false, None)
        endif
    elseif akSender == gabrielRef && (curStage == 25 || curStage == 30 || (bItemDelivered && curStage < 40) || (clawBase != None && player.GetItemCount(clawBase) > 0 && curStage < 40))
        SilenceBoneyardActorsExcept(gabrielRef as Actor, 0)
        if !bItemDelivered
            DeliverClawToSmitty()
        endif
        if Self.GetStage() < 40
            Self.SetStage(40)
        endif
        Topic helloTop = Game.GetFormFromFile(0x00014001, "Vault13Chronicles.esp") as Topic
        if helloTop != None && (gabrielRef as Actor) != None && !(gabrielRef as Actor).IsTalking()
            (gabrielRef as Actor).Say(helloTop, None, false, None)
        endif
    elseif akSender == smittyRef
        Message barterMsg = Game.GetFormFromFile(0x00001C73, "Vault13Chronicles.esp") as Message
        if barterMsg != None
            int choice = barterMsg.Show()
            if choice == 0
                OpenBoneyardBarter(smittyRef as Actor, 0x00001C53, 0x000035E3, False)
                return
            elseif choice == 2
                return
            endif
        endif
        SilenceBoneyardActorsExcept(smittyRef as Actor, 2)
        Topic helloTop = Game.GetFormFromFile(0x00014001, "Vault13Chronicles.esp") as Topic
        if helloTop != None && (smittyRef as Actor) != None && !(smittyRef as Actor).IsTalking()
            (smittyRef as Actor).Say(helloTop, None, false, None)
        endif
        if curStage < 25
            CancelTimer(91)
            sceneWaitTicks = 0
            StartTimer(0.5, 92)
            StartTimer(2.0, 94)
        endif
    elseif akSender == gabrielRef
        Message barterMsg = Game.GetFormFromFile(0x00001C74, "Vault13Chronicles.esp") as Message
        if barterMsg != None
            int choice = barterMsg.Show()
            if choice == 0
                OpenBoneyardBarter(gabrielRef as Actor, 0x00001C54, 0x000035E4, True)
                return
            elseif choice == 2
                return
            endif
        endif
        SilenceBoneyardActorsExcept(gabrielRef as Actor, 1)
        Topic helloTop = Game.GetFormFromFile(0x00014001, "Vault13Chronicles.esp") as Topic
        if helloTop != None && (gabrielRef as Actor) != None && !(gabrielRef as Actor).IsTalking()
            (gabrielRef as Actor).Say(helloTop, None, false, None)
        endif
        if curStage < 25
            CancelTimer(92)
            sceneWaitTicks = 0
            StartTimer(0.5, 91)
            StartTimer(2.0, 94)
        endif
    elseif akSender == nicoleRef && curStage < 20
        SilenceBoneyardActorsExcept(nicoleRef as Actor, 0)
        StartTimer(2.0, 94)
    endif
EndEvent

Function QueueJumpToBoneyard()
    if bMenuJumpBusy
        return
    endif
    bMenuJumpBusy = True
    SetupBoneyardListeners()
    StartTimer(0.6, 95)
EndFunction

Event OnTimer(int aiTimerID)
    if aiTimerID == 91
        Scene introScene = Game.GetFormFromFile(0x00014100, "Vault13Chronicles.esp") as Scene
        Actor gabrielActor = Game.GetFormFromFile(0x000035D4, "Vault13Chronicles.esp") as Actor
        if Self.IsRunning() && introScene != None && Self.GetStage() < 25
            if introScene.IsPlaying()
                return
            elseif gabrielActor != None && gabrielActor.IsTalking() && sceneWaitTicks < 28
                sceneWaitTicks += 1
                StartTimer(0.35, 91)
            else
                ForceAllBoneyardAliases()
                SilenceBoneyardActorsExcept(gabrielActor, 1)
                if Self.IsRunning()
                    introScene.Start()
                endif
            endif
        endif
    elseif aiTimerID == 92
        Scene smittyScene = Game.GetFormFromFile(0x00014101, "Vault13Chronicles.esp") as Scene
        Actor smittyActor = Game.GetFormFromFile(0x000035D5, "Vault13Chronicles.esp") as Actor
        if Self.IsRunning() && smittyScene != None && Self.GetStage() < 25
            if smittyScene.IsPlaying()
                return
            elseif smittyActor != None && smittyActor.IsTalking() && sceneWaitTicks < 28
                sceneWaitTicks += 1
                StartTimer(0.35, 92)
            else
                ForceAllBoneyardAliases()
                SilenceBoneyardActorsExcept(smittyActor, 2)
                if Self.IsRunning()
                    smittyScene.Start()
                endif
            endif
        endif
    elseif aiTimerID == 93
        Actor motherRef = Game.GetFormFromFile(0x000035D7, "Vault13Chronicles.esp") as Actor
        Actor player = Game.GetPlayer()
        Form clawBase = Game.GetFormFromFile(0x00001455, "Vault13Chronicles.esp")
        if bClawRecovered || bItemDelivered || Self.GetStage() >= 25
            return
        endif
        if player != None && clawBase != None && player.GetItemCount(clawBase) > 0
            NotifyBoneyardClawRecovered()
            return
        endif
        if motherRef != None && motherRef.IsDead()
            if clawBase != None && motherRef.GetItemCount(clawBase) == 0 && bClawSeeded
                if player != None && player.GetItemCount(clawBase) == 0
                    player.AddItem(clawBase, 1, False)
                endif
                NotifyBoneyardClawRecovered()
                return
            endif
            if Self.GetStage() < 25
                StartTimer(0.8, 93)
            endif
        endif
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
        ObjectReference mapMarker = Game.GetFormFromFile(0x00003420, "Vault13Chronicles.esp") as ObjectReference
        if mapMarker != None
            mapMarker.EnableNoWait()
            mapMarker.AddToMap(True)
        endif
        ObjectReference ftMarker = Game.GetFormFromFile(0x00003520, "Vault13Chronicles.esp") as ObjectReference
        if ftMarker != None
            player.MoveTo(ftMarker)
            RefreshBoneyardSettlementLayout()
            StartTimer(1.0, 97)
            Debug.Notification("Traveled to Adytum & Gun Runners (The Boneyard, 2161). Speak with Gabriel, Smitty the gunsmith, or Nicole.")
        endif
    elseif aiTimerID == 97
        RefreshBoneyardSettlementLayout()
        Actor pl97 = Game.GetPlayer()
        if Self.GetStage() < 25 && pl97 != None && pl97.GetWorldSpace() == (Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace)
            StartTimer(3.0, 97)
        endif
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

    SetupBoneyardListeners()
    Actor player = Game.GetPlayer()
    Form clawBase = Game.GetFormFromFile(0x00001455, "Vault13Chronicles.esp")

    if auiStageID == 20
        ObjectReference mapMarker = Game.GetFormFromFile(0x00003420, "Vault13Chronicles.esp") as ObjectReference
        if mapMarker != None
            mapMarker.EnableNoWait()
            mapMarker.AddToMap(True)
        endif
        if clawBase != None && player.GetItemCount(clawBase) > 0
            Self.SetStage(25)
            return
        endif
        Actor motherRef = Game.GetFormFromFile(0x000035D7, "Vault13Chronicles.esp") as Actor
        if motherRef != None && motherRef.IsDead()
            Self.SetStage(22)
            return
        endif
        ForceQuestAlias(1, 0x000035D7)
        if !IsObjectiveDisplayed(20)
            SetObjectiveDisplayed(20, True, False)
        endif
        Self.SetActive(True)
        if doStg20
            Debug.Notification("Side Quest: The Mother Deathclaw's Nest - Eliminate the Mother Deathclaw north of Adytum.")
        endif
    elseif auiStageID == 22
        if clawBase != None && player.GetItemCount(clawBase) > 0
            Self.SetStage(25)
            return
        endif
        ForceQuestAlias(1, 0x000035D7)
        SetObjectiveCompleted(20, True)
        if !IsObjectiveDisplayed(22)
            SetObjectiveDisplayed(22, True, False)
        endif
        Self.SetActive(True)
        if doStg22
            Debug.Notification("Mother Deathclaw slain! Extract the Armored Claw and Deathclaw Egg from her corpse.")
        endif
    elseif auiStageID == 25
        SetObjectiveCompleted(20, True)
        SetObjectiveCompleted(22, True)
        if !IsObjectiveDisplayed(25)
            SetObjectiveDisplayed(25, True, False)
        endif
        Self.SetActive(True)
        if doStg25
            Debug.Notification("Mother Deathclaw trophy obtained. Deliver it to Smitty the gunsmith in Adytum.")
        endif
    elseif auiStageID == 30
        if !bItemDelivered
            DeliverClawToSmitty()
        endif
        SetObjectiveCompleted(20, True)
        SetObjectiveCompleted(22, True)
        SetObjectiveCompleted(25, True)
        if !IsObjectiveDisplayed(30)
            SetObjectiveDisplayed(30, True, False)
        endif
        Self.SetActive(True)
        if doStg30
            Debug.Notification("Smitty calibrated the plasma rifle! Speak with Gabriel (Gun Runners) in Adytum.")
        endif
    elseif auiStageID == 40
        SetObjectiveCompleted(20, True)
        SetObjectiveCompleted(22, True)
        SetObjectiveCompleted(25, True)
        SetObjectiveCompleted(30, True)
        if doReward40
            Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
            Form plasmaP94 = Game.GetFormFromFile(0x0000110B, "Vault13Chronicles.esp")
            Form plasmaAmmo = Game.GetFormFromFile(0x0001DBB7, "Fallout4.esm")
            Form stimpak = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
            if caps != None
                player.AddItem(caps, 600, False)
            endif
            if plasmaP94 != None && player.GetItemCount(plasmaP94) == 0
                player.AddItem(plasmaP94, 1, False)
            endif
            if plasmaAmmo != None
                player.AddItem(plasmaAmmo, 60, False)
            endif
            if stimpak != None
                player.AddItem(stimpak, 4, False)
            endif
            Game.RewardPlayerXP(400)
            Debug.Notification("Side Quest completed: The Mother Deathclaw's Nest! (+P94 Turbo Plasma Rifle, +600 Caps, and +400 XP)")
        endif
        Self.CompleteQuest()
    endif
EndEvent
