Scriptname V13SideQuestShadySandsScript extends Quest

bool bGlandDelivered = False
bool bRewardGranted = False
bool bGlandRecovered = False
bool bGlandSeeded = False
bool bPendingTandiKidnapTrigger = False
bool bStg20Notified = False
bool bStg22Notified = False
bool bStg25Notified = False
bool bStg30Notified = False
bool bMenuJumpBusy = False
int aradeshSceneWaitTicks = 0

Function ForceQuestAlias(int aiAliasID, int aiFormID)
    ObjectReference targetRef = Game.GetFormFromFile(aiFormID, "Vault13Chronicles.esp") as ObjectReference
    ReferenceAlias al = Self.GetAlias(aiAliasID) as ReferenceAlias
    if al != None && targetRef != None
        if al.GetReference() != targetRef
            al.ForceRefTo(targetRef)
        endif
    endif
EndFunction

Function ForceAllShadySandsAliases()
    ForceQuestAlias(0, 0x000035A0)
    ForceQuestAlias(1, 0x000035A6)
    ForceQuestAlias(2, 0x00003005)
    ForceQuestAlias(3, 0x00002003)
    ForceQuestAlias(4, 0x00003502)
    ForceQuestAlias(5, 0x00002101)
    ForceQuestAlias(6, 0x00003501)
    ForceQuestAlias(7, 0x00002206)
    ForceQuestAlias(8, 0x00002035)
    ForceQuestAlias(9, 0x000035A3)
    ForceQuestAlias(10, 0x000035A2)
EndFunction

Function EquipFullOutfitOnActor(Actor akActor, Outfit akOutfit, Form akBodyArmor, Form akExtraArmor)
    if akActor == None || akActor.IsDead() || !akActor.Is3DLoaded() || akActor.IsTalking()
        return
    endif
    if akOutfit != None && (akBodyArmor == None || !akActor.IsEquipped(akBodyArmor))
        akActor.SetOutfit(akOutfit, false)
    endif
    if akBodyArmor != None && !akActor.IsEquipped(akBodyArmor)
        if akActor.GetItemCount(akBodyArmor) == 0
            akActor.AddItem(akBodyArmor, 1, true)
        endif
        akActor.EquipItem(akBodyArmor, false, true)
    endif
    if akExtraArmor != None && !akActor.IsEquipped(akExtraArmor)
        if akActor.GetItemCount(akExtraArmor) == 0
            akActor.AddItem(akExtraArmor, 1, true)
        endif
        akActor.EquipItem(akExtraArmor, false, true)
    endif
EndFunction

Function RemoveLegacyArmorFromActor(Actor akActor, Form akOldItem)
    if akActor != None && !akActor.IsDead() && akActor.Is3DLoaded() && akOldItem != None && akActor.GetItemCount(akOldItem) > 0
        akActor.RemoveItem(akOldItem, akActor.GetItemCount(akOldItem), true, None)
    endif
EndFunction

Function RefreshShadySandsSettlementLayout()
    Form combatHelm = Game.GetFormFromFile(0x0011E2C8, "Fallout4.esm")
    Form metalHelm = Game.GetFormFromFile(0x000787D3, "Fallout4.esm")
    Form pastorClothes = Game.GetFormFromFile(0x001467A4, "Fallout4.esm")
    Form v81LabCoat = Game.GetFormFromFile(0x00068CF3, "Fallout4.esm")

    Actor aradeshAct = Game.GetFormFromFile(0x000035A0, "Vault13Chronicles.esp") as Actor
    if aradeshAct != None && !aradeshAct.IsDead() && aradeshAct.Is3DLoaded()
        if !aradeshAct.IsInCombat() && !aradeshAct.IsTalking()
            if Math.Abs(aradeshAct.GetPositionX() - 2250.0) > 45.0 || Math.Abs(aradeshAct.GetPositionY() - 9690.0) > 45.0
                aradeshAct.SetPosition(2250.0, 9690.0, 160.0)
                aradeshAct.SetAngle(0.0, 0.0, 180.0)
                aradeshAct.EvaluatePackage()
            elseif Math.Abs(aradeshAct.GetAngleZ() - 180.0) > 35.0 && Math.Abs(aradeshAct.GetAngleZ() - 180.0) < 325.0
                aradeshAct.SetAngle(0.0, 0.0, 180.0)
            endif
        endif
        RemoveLegacyArmorFromActor(aradeshAct, pastorClothes)
        Outfit aradeshOut = Game.GetFormFromFile(0x0000102C, "Vault13Chronicles.esp") as Outfit
        Form aradeshClothes = Game.GetFormFromFile(0x000732AE, "Fallout4.esm")
        EquipFullOutfitOnActor(aradeshAct, aradeshOut, aradeshClothes, None)
    endif

    Quest tandiRescueQ = Game.GetFormFromFile(0x00018000, "Vault13Chronicles.esp") as Quest
    if Self.GetStage() >= 40 && !bPendingTandiKidnapTrigger && tandiRescueQ != None && tandiRescueQ.GetStage() < 15
        bPendingTandiKidnapTrigger = True
        StartTimer(15.0, 96)
    endif

    Actor player = Game.GetPlayer()
    Actor tandiAct = Game.GetFormFromFile(0x000035A1, "Vault13Chronicles.esp") as Actor
    if tandiAct != None && !tandiAct.IsDead() && tandiAct.Is3DLoaded()
        int trStage = 0
        if tandiRescueQ != None
            trStage = tandiRescueQ.GetStage()
        endif
        bool bTandiKidnapped = (trStage >= 15 && trStage < 30)
        if bTandiKidnapped
            if !tandiAct.IsInCombat() && (Math.Abs(tandiAct.GetPositionX() - 10400.0) > 400.0 || Math.Abs(tandiAct.GetPositionY() - 13580.0) > 400.0)
                tandiAct.SetPosition(10400.0, 13580.0, 206.0)
            endif
        elseif trStage != 30 || player == None || player.GetDistance(tandiAct) > 1800.0 || (aradeshAct != None && player.GetDistance(aradeshAct) < 2400.0)
            if !tandiAct.IsInCombat() && !tandiAct.IsTalking()
                if Math.Abs(tandiAct.GetPositionX() - 2550.0) > 45.0 || Math.Abs(tandiAct.GetPositionY() - 9690.0) > 45.0
                    tandiAct.SetPosition(2550.0, 9690.0, 160.0)
                    tandiAct.SetAngle(0.0, 0.0, 180.0)
                    tandiAct.EvaluatePackage()
                elseif Math.Abs(tandiAct.GetAngleZ() - 180.0) > 35.0 && Math.Abs(tandiAct.GetAngleZ() - 180.0) < 325.0
                    tandiAct.SetAngle(0.0, 0.0, 180.0)
                endif
            endif
        endif
        RemoveLegacyArmorFromActor(tandiAct, metalHelm)
        Outfit tandiOut = Game.GetFormFromFile(0x00001024, "Vault13Chronicles.esp") as Outfit
        Form tandiClothes = Game.GetFormFromFile(0x000E5084, "Fallout4.esm")
        EquipFullOutfitOnActor(tandiAct, tandiOut, tandiClothes, None)
    endif

    Actor sethAct = Game.GetFormFromFile(0x000035A2, "Vault13Chronicles.esp") as Actor
    if sethAct != None && !sethAct.IsDead() && sethAct.Is3DLoaded()
        if !sethAct.IsInCombat() && (Math.Abs(sethAct.GetPositionX() - 1810.0) > 600.0 || Math.Abs(sethAct.GetPositionY() - 9720.0) > 600.0)
            sethAct.SetPosition(1810.0, 9720.0, 160.0)
        endif
        Outfit sethOut = Game.GetFormFromFile(0x00001023, "Vault13Chronicles.esp") as Outfit
        Form sethUnder = Game.GetFormFromFile(0x0019CBB3, "Fallout4.esm")
        Form sethVest = Game.GetFormFromFile(0x00156C0D, "Fallout4.esm")
        Form rangerHelm = Game.GetFormFromFile(0x00001315, "Vault13Chronicles.esp")
        EquipFullOutfitOnActor(sethAct, sethOut, sethUnder, sethVest)
        EquipFullOutfitOnActor(sethAct, None, rangerHelm, None)
    endif

    Actor razloAct = Game.GetFormFromFile(0x000035A3, "Vault13Chronicles.esp") as Actor
    if razloAct != None && !razloAct.IsDead() && razloAct.Is3DLoaded()
        if !razloAct.IsInCombat() && (Math.Abs(razloAct.GetPositionX() - 2990.0) > 600.0 || Math.Abs(razloAct.GetPositionY() - 9600.0) > 600.0)
            razloAct.SetPosition(2990.0, 9600.0, 160.0)
        endif
        RemoveLegacyArmorFromActor(razloAct, v81LabCoat)
        Outfit razloOut = Game.GetFormFromFile(0x0000102B, "Vault13Chronicles.esp") as Outfit
        Form razloClothes = Game.GetFormFromFile(0x00178B68, "Fallout4.esm")
        EquipFullOutfitOnActor(razloAct, razloOut, razloClothes, None)
    endif

    Quest junktownQ = Game.GetFormFromFile(0x00010000, "Vault13Chronicles.esp") as Quest
    V13SideQuestJunktownScript junktownS = junktownQ as V13SideQuestJunktownScript

    Actor ianAct = Game.GetFormFromFile(0x000035A4, "Vault13Chronicles.esp") as Actor
    if ianAct != None && !ianAct.IsDead() && ianAct.Is3DLoaded()
        bool bIanRecruited = False
        if junktownS != None && junktownS.IsIanRecruited()
            bIanRecruited = True
        endif
        if !bIanRecruited && !ianAct.IsInCombat() && (Math.Abs(ianAct.GetPositionX() - 1810.0) > 600.0 || Math.Abs(ianAct.GetPositionY() - 9460.0) > 600.0)
            ianAct.SetPosition(1810.0, 9460.0, 160.0)
        endif
        RemoveLegacyArmorFromActor(ianAct, combatHelm)
        RemoveLegacyArmorFromActor(ianAct, metalHelm)
        Outfit ianOut = Game.GetFormFromFile(0x00001025, "Vault13Chronicles.esp") as Outfit
        Form ianJacket = Game.GetFormFromFile(0x0014BF50, "Fallout4.esm")
        EquipFullOutfitOnActor(ianAct, ianOut, ianJacket, None)
    endif

    Actor jarvisAct = Game.GetFormFromFile(0x000035A5, "Vault13Chronicles.esp") as Actor
    if jarvisAct != None && !jarvisAct.IsDead() && jarvisAct.Is3DLoaded()
        if !jarvisAct.IsInCombat() && (Math.Abs(jarvisAct.GetPositionX() - 3320.0) > 600.0 || Math.Abs(jarvisAct.GetPositionY() - 9480.0) > 600.0)
            jarvisAct.SetPosition(3320.0, 9480.0, 160.0)
        endif
        Form jarvisClothes = Game.GetFormFromFile(0x000B2D8D, "Fallout4.esm")
        EquipFullOutfitOnActor(jarvisAct, None, jarvisClothes, None)
    endif

    Actor shadyDog = Game.GetFormFromFile(0x000035B3, "Vault13Chronicles.esp") as Actor
    if shadyDog != None && !shadyDog.IsDead()
        if shadyDog.IsDisabled()
            shadyDog.EnableNoWait()
        endif
        if junktownS != None
            if !junktownS.IsDogmeatRecruited() && shadyDog.Is3DLoaded() && !shadyDog.IsInCombat()
                if Math.Abs(shadyDog.GetPositionX() - 2600.0) > 220.0 || Math.Abs(shadyDog.GetPositionY() - 9600.0) > 220.0
                    shadyDog.SetPosition(2600.0, 9600.0, 160.0)
                endif
            endif
            junktownS.RefreshDogmeatAppearance(shadyDog)
        endif
    endif
EndFunction

Function SilenceShadySandsActorsExcept(Actor akSpeaker, int aiKeepScene = 0)
    Scene aradeshScene = Game.GetFormFromFile(0x00009600, "Vault13Chronicles.esp") as Scene
    Scene razloScene = Game.GetFormFromFile(0x00009601, "Vault13Chronicles.esp") as Scene
    if aiKeepScene != 1 && aradeshScene != None && aradeshScene.IsPlaying()
        aradeshScene.Stop()
    endif
    if aiKeepScene != 2 && razloScene != None && razloScene.IsPlaying()
        razloScene.Stop()
    endif
    Topic stopTopic = Game.GetFormFromFile(0x00004003, "Vault13Chronicles.esp") as Topic
    if stopTopic == None
        return
    endif
    int[] npcRefs = new int[6]
    npcRefs[0] = 0x000035A0
    npcRefs[1] = 0x000035A1
    npcRefs[2] = 0x000035A2
    npcRefs[3] = 0x000035A3
    npcRefs[4] = 0x000035A4
    npcRefs[5] = 0x000035A5
    int idx = 0
    while idx < 6
        Actor npcAct = Game.GetFormFromFile(npcRefs[idx], "Vault13Chronicles.esp") as Actor
        if npcAct != None && npcAct != akSpeaker && npcAct.IsTalking()
            npcAct.Say(stopTopic, None, false, None)
        endif
        idx += 1
    endwhile
EndFunction

Function SetupShadySandsListeners()
    if !Self.IsRunning() && !Self.IsCompleted()
        Self.Start()
    endif
    if Self.GetStage() < 10
        Self.SetStage(10)
    endif
    ForceAllShadySandsAliases()
    RefreshShadySandsSettlementLayout()

    Actor player = Game.GetPlayer()
    Form glandBase = Game.GetFormFromFile(0x00001116, "Vault13Chronicles.esp")
    Self.RemoveAllInventoryEventFilters()
    if glandBase != None
        Self.AddInventoryEventFilter(glandBase)
    endif
    if player != None
        RegisterForRemoteEvent(player, "OnPlayerLoadGame")
        RegisterForRemoteEvent(player, "OnLocationChange")
        if glandBase != None
            RegisterForRemoteEvent(player as ObjectReference, "OnItemAdded")
        endif
    endif

    ObjectReference aradeshRef = Game.GetFormFromFile(0x000035A0, "Vault13Chronicles.esp") as ObjectReference
    if aradeshRef != None
        RegisterForRemoteEvent(aradeshRef, "OnActivate")
    endif
    ObjectReference tandiRef = Game.GetFormFromFile(0x000035A1, "Vault13Chronicles.esp") as ObjectReference
    if tandiRef != None
        RegisterForRemoteEvent(tandiRef, "OnActivate")
    endif
    ObjectReference sethRef = Game.GetFormFromFile(0x000035A2, "Vault13Chronicles.esp") as ObjectReference
    if sethRef != None
        RegisterForRemoteEvent(sethRef, "OnActivate")
    endif
    ObjectReference razloRef = Game.GetFormFromFile(0x000035A3, "Vault13Chronicles.esp") as ObjectReference
    if razloRef != None
        RegisterForRemoteEvent(razloRef, "OnActivate")
    endif
    ObjectReference ianRef = Game.GetFormFromFile(0x000035A4, "Vault13Chronicles.esp") as ObjectReference
    if ianRef != None
        RegisterForRemoteEvent(ianRef, "OnActivate")
    endif
    ObjectReference jarvisRef = Game.GetFormFromFile(0x000035A5, "Vault13Chronicles.esp") as ObjectReference
    if jarvisRef != None
        RegisterForRemoteEvent(jarvisRef, "OnActivate")
    endif
    Actor emperorRef = Game.GetFormFromFile(0x000035A6, "Vault13Chronicles.esp") as Actor
    if emperorRef != None
        RegisterForRemoteEvent(emperorRef, "OnDeath")
        RegisterForRemoteEvent(emperorRef as ObjectReference, "OnActivate")
        RegisterForRemoteEvent(emperorRef as ObjectReference, "OnItemRemoved")
        if !emperorRef.IsDead()
            emperorRef.EnableAI(true)
            emperorRef.SetValue(Game.GetAggressionAV(), 2.0)
            emperorRef.SetValue(Game.GetConfidenceAV(), 4.0)
            V13WastelandCreatureAIScript empAI = emperorRef as V13WastelandCreatureAIScript
            if empAI != None
                empAI.InitCreatureAI()
            endif
            float ex = emperorRef.GetPositionX()
            float ey = emperorRef.GetPositionY()
            float ez = emperorRef.GetPositionZ()
            if (ez < 148.0 || ez > 270.0) && Self.GetStage() < 25
                emperorRef.SetPosition(6400.0, 13800.0, 166.0)
                ForceQuestAlias(1, 0x000035A6)
            elseif !emperorRef.IsInCombat()
                if Math.Abs(ex - 6400.0) > 450.0 || Math.Abs(ey - 13800.0) > 450.0
                    emperorRef.SetPosition(6400.0, 13800.0, 166.0)
                    ForceQuestAlias(1, 0x000035A6)
                endif
            endif
        endif
        if bGlandRecovered || bGlandDelivered || Self.GetStage() >= 25 || (player != None && glandBase != None && player.GetItemCount(glandBase) > 0)
            bGlandRecovered = True
            bGlandSeeded = True
            if glandBase != None && emperorRef.GetItemCount(glandBase) > 0
                emperorRef.RemoveItem(glandBase, emperorRef.GetItemCount(glandBase), True)
            endif
        elseif emperorRef.Is3DLoaded() && !bGlandSeeded && glandBase != None
            if emperorRef.GetItemCount(glandBase) == 0
                emperorRef.AddItem(glandBase, 1, True)
            endif
            bGlandSeeded = True
        endif
        if Self.GetStage() == 20 && emperorRef.IsDead()
            if bGlandRecovered || (player != None && glandBase != None && player.GetItemCount(glandBase) > 0)
                Self.SetStage(25)
            else
                Self.SetStage(22)
            endif
        endif
    endif
    Actor scorp1Ref = Game.GetFormFromFile(0x000035A7, "Vault13Chronicles.esp") as Actor
    if scorp1Ref != None && !scorp1Ref.IsDead()
        scorp1Ref.EnableAI(true)
        scorp1Ref.SetValue(Game.GetAggressionAV(), 2.0)
        scorp1Ref.SetValue(Game.GetConfidenceAV(), 4.0)
        V13WastelandCreatureAIScript sc1AI = scorp1Ref as V13WastelandCreatureAIScript
        if sc1AI != None
            sc1AI.InitCreatureAI()
        endif
        if !scorp1Ref.IsInCombat() && (Math.Abs(scorp1Ref.GetPositionX() - 6220.0) > 800.0 || Math.Abs(scorp1Ref.GetPositionY() - 13660.0) > 800.0)
            scorp1Ref.SetPosition(6220.0, 13660.0, 166.0)
        endif
    endif
    Actor scorp2Ref = Game.GetFormFromFile(0x000035A8, "Vault13Chronicles.esp") as Actor
    if scorp2Ref != None && !scorp2Ref.IsDead()
        scorp2Ref.EnableAI(true)
        scorp2Ref.SetValue(Game.GetAggressionAV(), 2.0)
        scorp2Ref.SetValue(Game.GetConfidenceAV(), 4.0)
        V13WastelandCreatureAIScript sc2AI = scorp2Ref as V13WastelandCreatureAIScript
        if sc2AI != None
            sc2AI.InitCreatureAI()
        endif
        if !scorp2Ref.IsInCombat() && (Math.Abs(scorp2Ref.GetPositionX() - 6480.0) > 350.0 || Math.Abs(scorp2Ref.GetPositionY() - 13560.0) > 350.0)
            scorp2Ref.SetPosition(6480.0, 13560.0, 166.0)
        endif
    endif
    ObjectReference nestRef = Game.GetFormFromFile(0x000035A9, "Vault13Chronicles.esp") as ObjectReference
    if nestRef != None && !nestRef.IsDisabled()
        nestRef.DisableNoWait()
    endif
    Quest junktownQ = Game.GetFormFromFile(0x00010000, "Vault13Chronicles.esp") as Quest
    if junktownQ != None && !junktownQ.IsRunning()
        junktownQ.Start()
    endif
    Actor razloAct = Game.GetFormFromFile(0x000035A3, "Vault13Chronicles.esp") as Actor
    if razloAct != None
        EnsureRazloVendorReady(razloAct)
    endif
EndFunction

Function EnsureRazloVendorReady(Actor akRazlo)
    if akRazlo == None
        return
    endif
    Faction vFact = Game.GetFormFromFile(0x00001C52, "Vault13Chronicles.esp") as Faction
    if vFact != None && !akRazlo.IsInFaction(vFact)
        akRazlo.AddToFaction(vFact)
    endif
    ObjectReference vChest = Game.GetFormFromFile(0x000035E2, "Vault13Chronicles.esp") as ObjectReference
    Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
    if vChest != None
        if vChest.IsDisabled()
            vChest.EnableNoWait()
        endif
        if caps != None && vChest.GetItemCount(caps) < 400
            vChest.AddItem(caps, 1200, True)
            Form stim = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
            Form radaway = Game.GetFormFromFile(0x00023742, "Fallout4.esm")
            Form radx = Game.GetFormFromFile(0x00024057, "Fallout4.esm")
            Form water = Game.GetFormFromFile(0x000366C0, "Fallout4.esm")
            Form medx = Game.GetFormFromFile(0x00033779, "Fallout4.esm")
            Form buffout = Game.GetFormFromFile(0x00033778, "Fallout4.esm")
            Form mentats = Game.GetFormFromFile(0x0003377B, "Fallout4.esm")
            Form psycho = Game.GetFormFromFile(0x0003377D, "Fallout4.esm")
            if stim != None && vChest.GetItemCount(stim) < 8
                vChest.AddItem(stim, 24, True)
            endif
            if radaway != None && vChest.GetItemCount(radaway) < 6
                vChest.AddItem(radaway, 18, True)
            endif
            if radx != None && vChest.GetItemCount(radx) < 6
                vChest.AddItem(radx, 16, True)
            endif
            if water != None && vChest.GetItemCount(water) < 6
                vChest.AddItem(water, 20, True)
            endif
            if medx != None && vChest.GetItemCount(medx) < 4
                vChest.AddItem(medx, 10, True)
            endif
            if buffout != None && vChest.GetItemCount(buffout) < 4
                vChest.AddItem(buffout, 10, True)
            endif
            if mentats != None && vChest.GetItemCount(mentats) < 4
                vChest.AddItem(mentats, 10, True)
            endif
            if psycho != None && vChest.GetItemCount(psycho) < 4
                vChest.AddItem(psycho, 8, True)
            endif
        endif
    endif
EndFunction

Function OpenRazloBarter()
    Actor razloAct = Game.GetFormFromFile(0x000035A3, "Vault13Chronicles.esp") as Actor
    if razloAct == None || razloAct.IsDead()
        return
    endif
    EnsureRazloVendorReady(razloAct)
    Utility.Wait(0.15)
    razloAct.ShowBarterMenu()
EndFunction

Event OnInit()
    SetupShadySandsListeners()
EndEvent

Event OnQuestInit()
    SetupShadySandsListeners()
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
    SetupShadySandsListeners()
EndEvent

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
    SetupShadySandsListeners()
    StartTimer(1.0, 97)
EndEvent

Function NotifyRadscorpionGlandRecovered()
    if bGlandRecovered
        return
    endif
    bGlandRecovered = True
    bGlandSeeded = True
    Actor emperorRef = Game.GetFormFromFile(0x000035A6, "Vault13Chronicles.esp") as Actor
    Form glandBase = Game.GetFormFromFile(0x00001116, "Vault13Chronicles.esp")
    if emperorRef != None && glandBase != None && emperorRef.GetItemCount(glandBase) > 0
        emperorRef.RemoveItem(glandBase, emperorRef.GetItemCount(glandBase), True)
    endif
    if Self.GetStage() < 25
        Self.SetStage(25)
    endif
    SetupShadySandsListeners()
EndFunction

Function DeliverGlandToRazlo()
    if bGlandDelivered
        return
    endif
    bGlandDelivered = True
    Actor player = Game.GetPlayer()
    Form glandBase = Game.GetFormFromFile(0x00001116, "Vault13Chronicles.esp")
    if glandBase != None && player.GetItemCount(glandBase) > 0
        player.RemoveItem(glandBase, 1, True)
    endif
    Form noteBase = Game.GetFormFromFile(0x00001146, "Vault13Chronicles.esp")
    if noteBase != None && player.GetItemCount(noteBase) == 0
        player.AddItem(noteBase, 1, True)
    endif
    Form radaway = Game.GetFormFromFile(0x00023742, "Fallout4.esm")
    if radaway != None
        player.AddItem(radaway, 3, False)
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
    Form glandBase = Game.GetFormFromFile(0x00001116, "Vault13Chronicles.esp")
    if akBaseItem == glandBase
        NotifyRadscorpionGlandRecovered()
    endif
EndEvent

Event ObjectReference.OnItemRemoved(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
    Form glandBase = Game.GetFormFromFile(0x00001116, "Vault13Chronicles.esp")
    if akBaseItem == glandBase || (akSender != None && (akSender as Actor) != None && (akSender as Actor).IsDead())
        Actor player = Game.GetPlayer()
        if glandBase != None && player != None && player.GetItemCount(glandBase) == 0
            player.AddItem(glandBase, 1, False)
        endif
        NotifyRadscorpionGlandRecovered()
    endif
EndEvent

Event Actor.OnDeath(Actor akSender, Actor akKiller)
    Actor emperorRef = Game.GetFormFromFile(0x000035A6, "Vault13Chronicles.esp") as Actor
    if akSender == emperorRef
        Form glandBase = Game.GetFormFromFile(0x00001116, "Vault13Chronicles.esp")
        Actor player = Game.GetPlayer()
        if !bGlandSeeded && !bGlandRecovered && glandBase != None && player != None && player.GetItemCount(glandBase) == 0 && emperorRef.GetItemCount(glandBase) == 0
            emperorRef.AddItem(glandBase, 1, True)
            bGlandSeeded = True
        endif
        ForceQuestAlias(1, 0x000035A6)
        if bGlandRecovered || (glandBase != None && player != None && player.GetItemCount(glandBase) > 0)
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
    ObjectReference aradeshRef = Game.GetFormFromFile(0x000035A0, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference tandiRef = Game.GetFormFromFile(0x000035A1, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference sethRef = Game.GetFormFromFile(0x000035A2, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference razloRef = Game.GetFormFromFile(0x000035A3, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference ianRef = Game.GetFormFromFile(0x000035A4, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference jarvisRef = Game.GetFormFromFile(0x000035A5, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference empObjRef = Game.GetFormFromFile(0x000035A6, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference nestRef = Game.GetFormFromFile(0x000035A9, "Vault13Chronicles.esp") as ObjectReference
    Form glandBase = Game.GetFormFromFile(0x00001116, "Vault13Chronicles.esp")
    Actor player = Game.GetPlayer()

    if akSender == nestRef || (akSender == empObjRef && (empObjRef as Actor) != None && (empObjRef as Actor).IsDead())
        if glandBase != None && player.GetItemCount(glandBase) == 0
            player.AddItem(glandBase, 1, False)
        endif
        NotifyRadscorpionGlandRecovered()
        return
    endif

    ForceAllShadySandsAliases()
    int curStage = Self.GetStage()
    if (akSender == razloRef || akSender == jarvisRef) && (curStage == 25 || (glandBase != None && player.GetItemCount(glandBase) > 0 && curStage < 30))
        SilenceShadySandsActorsExcept(akSender as Actor, 0)
        DeliverGlandToRazlo()
        Topic helloTop = Game.GetFormFromFile(0x00009501, "Vault13Chronicles.esp") as Topic
        if helloTop != None && (akSender as Actor) != None && !(akSender as Actor).IsTalking()
            (akSender as Actor).Say(helloTop, None, false, None)
        endif
    elseif akSender == aradeshRef && (curStage == 30 || (bGlandDelivered && curStage < 40))
        SilenceShadySandsActorsExcept(aradeshRef as Actor, 0)
        if Self.GetStage() < 40
            Self.SetStage(40)
        endif
        Topic helloTop = Game.GetFormFromFile(0x00009501, "Vault13Chronicles.esp") as Topic
        if helloTop != None && (aradeshRef as Actor) != None && !(aradeshRef as Actor).IsTalking()
            (aradeshRef as Actor).Say(helloTop, None, false, None)
        endif
    elseif akSender == razloRef
        Message barterMsg = Game.GetFormFromFile(0x00001C72, "Vault13Chronicles.esp") as Message
        if barterMsg != None
            int choice = barterMsg.Show()
            if choice == 0
                OpenRazloBarter()
                return
            elseif choice == 2
                return
            endif
        endif
        SilenceShadySandsActorsExcept(razloRef as Actor, 2)
        Topic helloTop = Game.GetFormFromFile(0x00009501, "Vault13Chronicles.esp") as Topic
        if helloTop != None && (razloRef as Actor) != None && !(razloRef as Actor).IsTalking()
            (razloRef as Actor).Say(helloTop, None, false, None)
        endif
        if curStage < 25
            CancelTimer(91)
            aradeshSceneWaitTicks = 0
            StartTimer(0.5, 92)
            StartTimer(2.0, 94)
        endif
    elseif akSender == aradeshRef && curStage < 25
        SilenceShadySandsActorsExcept(aradeshRef as Actor, 1)
        CancelTimer(92)
        aradeshSceneWaitTicks = 0
        StartTimer(1.2, 91)
        StartTimer(2.0, 94)
    elseif akSender == ianRef
        Quest junktownQ = Game.GetFormFromFile(0x00010000, "Vault13Chronicles.esp") as Quest
        V13SideQuestJunktownScript junktownS = junktownQ as V13SideQuestJunktownScript
        if junktownS != None
            junktownS.HandleIanActivation(ianRef as Actor)
        endif
    elseif (akSender == sethRef || akSender == jarvisRef) && curStage < 20
        SilenceShadySandsActorsExcept(akSender as Actor, 0)
        StartTimer(2.0, 94)
    endif
EndEvent

Function QueueJumpToShadySands()
    if bMenuJumpBusy
        return
    endif
    bMenuJumpBusy = True
    SetupShadySandsListeners()
    StartTimer(0.6, 95)
EndFunction

Event OnTimer(int aiTimerID)
    if aiTimerID == 91
        Scene introScene = Game.GetFormFromFile(0x00009600, "Vault13Chronicles.esp") as Scene
        Actor aradeshActor = Game.GetFormFromFile(0x000035A0, "Vault13Chronicles.esp") as Actor
        if Self.IsRunning() && introScene != None && Self.GetStage() < 25
            if introScene.IsPlaying()
                return
            elseif aradeshActor != None && aradeshActor.IsTalking() && aradeshSceneWaitTicks < 28
                aradeshSceneWaitTicks += 1
                StartTimer(0.35, 91)
            else
                ForceAllShadySandsAliases()
                SilenceShadySandsActorsExcept(aradeshActor, 1)
                if Self.IsRunning()
                    introScene.Start()
                endif
            endif
        endif
    elseif aiTimerID == 92
        Scene razloScene = Game.GetFormFromFile(0x00009601, "Vault13Chronicles.esp") as Scene
        Actor razloActor = Game.GetFormFromFile(0x000035A3, "Vault13Chronicles.esp") as Actor
        if Self.IsRunning() && razloScene != None && Self.GetStage() < 25
            if razloScene.IsPlaying()
                return
            elseif razloActor != None && razloActor.IsTalking() && aradeshSceneWaitTicks < 28
                aradeshSceneWaitTicks += 1
                StartTimer(0.35, 92)
            else
                ForceAllShadySandsAliases()
                SilenceShadySandsActorsExcept(razloActor, 2)
                if Self.IsRunning()
                    razloScene.Start()
                endif
            endif
        endif
    elseif aiTimerID == 93
        Actor empCheck = Game.GetFormFromFile(0x000035A6, "Vault13Chronicles.esp") as Actor
        Form glandCheck = Game.GetFormFromFile(0x00001116, "Vault13Chronicles.esp")
        Actor plCheck = Game.GetPlayer()
        if Self.GetStage() < 25 && empCheck != None && empCheck.IsDead()
            if (plCheck != None && glandCheck != None && plCheck.GetItemCount(glandCheck) > 0) || (glandCheck != None && empCheck.GetItemCount(glandCheck) == 0)
                if plCheck != None && glandCheck != None && plCheck.GetItemCount(glandCheck) == 0
                    plCheck.AddItem(glandCheck, 1, False)
                endif
                NotifyRadscorpionGlandRecovered()
            elseif plCheck != None && plCheck.GetDistance(empCheck) < 2500.0
                StartTimer(1.0, 93)
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
        ObjectReference shadyMapMarker = Game.GetFormFromFile(0x00003412, "Vault13Chronicles.esp") as ObjectReference
        if shadyMapMarker != None
            shadyMapMarker.EnableNoWait()
            shadyMapMarker.AddToMap(True)
        endif
        ObjectReference shadyFTMarker = Game.GetFormFromFile(0x00003512, "Vault13Chronicles.esp") as ObjectReference
        if shadyFTMarker != None
            player.MoveTo(shadyFTMarker)
            RefreshShadySandsSettlementLayout()
            StartTimer(1.0, 97)
            Debug.Notification("Traveled to Shady Sands (2161). Speak with Aradesh, Seth, or Dr. Razlo, or press [E] on Dogmeat to recruit him.")
        endif
    elseif aiTimerID == 96
        Actor player = Game.GetPlayer()
        Actor aradeshWaitAct = Game.GetFormFromFile(0x000035A0, "Vault13Chronicles.esp") as Actor
        Actor tandiWaitAct = Game.GetFormFromFile(0x000035A1, "Vault13Chronicles.esp") as Actor
        if aradeshWaitAct != None && aradeshWaitAct.IsTalking()
            StartTimer(4.0, 96)
            return
        endif
        if player != None && !player.IsInInterior()
            if (aradeshWaitAct != None && player.GetDistance(aradeshWaitAct) < 3200.0) || (tandiWaitAct != None && player.GetDistance(tandiWaitAct) < 2800.0)
                StartTimer(8.0, 96)
                return
            endif
        endif
        bPendingTandiKidnapTrigger = False
        Quest tandiRescueInitQ = Game.GetFormFromFile(0x00018000, "Vault13Chronicles.esp") as Quest
        if tandiRescueInitQ != None && tandiRescueInitQ.GetStage() < 15
            if !tandiRescueInitQ.IsRunning()
                tandiRescueInitQ.Start()
            endif
            tandiRescueInitQ.SetStage(15)
        endif
    elseif aiTimerID == 97
        RefreshShadySandsSettlementLayout()
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

    SetupShadySandsListeners()
    Actor player = Game.GetPlayer()
    Form glandBase = Game.GetFormFromFile(0x00001116, "Vault13Chronicles.esp")

    if auiStageID == 20
        ObjectReference shadyMapMarker = Game.GetFormFromFile(0x00003412, "Vault13Chronicles.esp") as ObjectReference
        if shadyMapMarker != None
            shadyMapMarker.EnableNoWait()
            shadyMapMarker.AddToMap(True)
        endif
        if glandBase != None && player.GetItemCount(glandBase) > 0
            Self.SetStage(25)
            return
        endif
        Actor emperorRef = Game.GetFormFromFile(0x000035A6, "Vault13Chronicles.esp") as Actor
        if emperorRef != None && emperorRef.IsDead()
            Self.SetStage(22)
            return
        endif
        ForceQuestAlias(1, 0x000035A6)
        if !IsObjectiveDisplayed(20)
            SetObjectiveDisplayed(20, True, False)
        endif
        Self.SetActive(True)
        if doStg20
            Debug.Notification("Side Quest: Shadows Over Shady Sands - Eliminate the Emperor Radscorpion in the northern lair.")
        endif
    elseif auiStageID == 22
        if glandBase != None && player.GetItemCount(glandBase) > 0
            Self.SetStage(25)
            return
        endif
        ForceQuestAlias(1, 0x000035A6)
        SetObjectiveCompleted(20, True)
        if !IsObjectiveDisplayed(22)
            SetObjectiveDisplayed(22, True, False)
        endif
        Self.SetActive(True)
        if doStg22
            Debug.Notification("Emperor Radscorpion slain! Extract the Venom Gland from its corpse.")
        endif
    elseif auiStageID == 25
        SetObjectiveCompleted(20, True)
        SetObjectiveCompleted(22, True)
        if !IsObjectiveDisplayed(25)
            SetObjectiveDisplayed(25, True, False)
        endif
        Self.SetActive(True)
        if doStg25
            Debug.Notification("Venom Gland extracted. Deliver it to Dr. Razlo at the Shady Sands Clinic to cure Jarvis.")
        endif
    elseif auiStageID == 30
        if !bGlandDelivered
            DeliverGlandToRazlo()
        endif
        SetObjectiveCompleted(20, True)
        SetObjectiveCompleted(22, True)
        SetObjectiveCompleted(25, True)
        if !IsObjectiveDisplayed(30)
            SetObjectiveDisplayed(30, True, False)
        endif
        Self.SetActive(True)
        if doStg30
            Debug.Notification("Dr. Razlo synthesized the antivenom and saved Jarvis! Report to Aradesh in Shady Sands.")
        endif
    elseif auiStageID == 40
        SetObjectiveCompleted(20, True)
        SetObjectiveCompleted(22, True)
        SetObjectiveCompleted(25, True)
        SetObjectiveCompleted(30, True)
        if doReward40
            Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
            Form ammo10 = Game.GetFormFromFile(0x0001F276, "Fallout4.esm")
            Form ammo308 = Game.GetFormFromFile(0x0001F66B, "Fallout4.esm")
            Form stimpak = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
            if caps != None
                player.AddItem(caps, 500, False)
            endif
            if ammo10 != None
                player.AddItem(ammo10, 48, False)
            endif
            if ammo308 != None
                player.AddItem(ammo308, 24, False)
            endif
            if stimpak != None
                player.AddItem(stimpak, 4, False)
            endif
            Game.RewardPlayerXP(350)
            Debug.Notification("Side Quest completed: Shadows Over Shady Sands! (+500 Caps, Ammunition, Stimpaks, and +350 XP)")
        endif
        Self.CompleteQuest()
        if !bPendingTandiKidnapTrigger
            bPendingTandiKidnapTrigger = True
            StartTimer(35.0, 96)
        endif
    endif
EndEvent
