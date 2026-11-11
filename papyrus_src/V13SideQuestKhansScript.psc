Scriptname V13SideQuestKhansScript extends Quest

bool bItemDelivered = False
bool bRewardGranted = False
bool bKeyRecovered = False
bool bKeySeeded = False
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

Function ForceAllKhansAliases()
    ForceQuestAlias(0, 0x000035CB)
    ForceQuestAlias(1, 0x000035CE)
    ForceQuestAlias(2, 0x00003005)
    ForceQuestAlias(3, 0x00002003)
    ForceQuestAlias(4, 0x0000351E)
    ForceQuestAlias(5, 0x00002101)
    ForceQuestAlias(6, 0x00003501)
    ForceQuestAlias(7, 0x00002206)
    ForceQuestAlias(8, 0x00002035)
    ForceQuestAlias(9, 0x000035CC)
    ForceQuestAlias(10, 0x000035A2)
EndFunction

Function EquipKhansActorGear(Actor akAct, int aiOutfitID, int aiBodyArmorID, int aiHatID)
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
    Form oldHelmet = Game.GetFormFromFile(0x0011E2C8, "Fallout4.esm")
    if oldHelmet != None && akAct.GetItemCount(oldHelmet) > 0
        akAct.RemoveItem(oldHelmet, akAct.GetItemCount(oldHelmet), true, None)
    endif
    if bodyArmor != None && !akAct.IsEquipped(bodyArmor)
        if akAct.GetItemCount(bodyArmor) == 0
            akAct.AddItem(bodyArmor, 1, true)
        endif
        akAct.EquipItem(bodyArmor, false, true)
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

Function RefreshKhansSettlementLayout()
    Actor dianaAct = Game.GetFormFromFile(0x000035CB, "Vault13Chronicles.esp") as Actor
    if dianaAct != None
        if dianaAct.IsDisabled()
            dianaAct.EnableNoWait()
        endif
        if dianaAct.IsDead()
            dianaAct.Resurrect()
        endif
        if dianaAct.Is3DLoaded()
            float dx = Math.Abs(dianaAct.GetPositionX() - 8060.0)
            float dy = Math.Abs(dianaAct.GetPositionY() - 7740.0)
            float dz = dianaAct.GetPositionZ()
            if dianaAct.IsInCombat() && (dx > 750.0 || dy > 750.0 || dz < 185.0)
                dianaAct.StopCombat()
                dianaAct.SetPosition(8060.0, 7740.0, 200.0)
                dianaAct.EvaluatePackage()
            elseif !dianaAct.IsInCombat() && (dx > 240.0 || dy > 240.0 || dz < 185.0)
                dianaAct.SetPosition(8060.0, 7740.0, 200.0)
                dianaAct.EvaluatePackage()
            endif
            EquipKhansActorGear(dianaAct, 0x00001028, 0x000DDB80, 0x00001315)
        endif
    endif
    Actor gwenAct = Game.GetFormFromFile(0x000035CC, "Vault13Chronicles.esp") as Actor
    if gwenAct != None
        if gwenAct.IsDisabled()
            gwenAct.EnableNoWait()
        endif
        if gwenAct.IsDead()
            gwenAct.Resurrect()
        endif
        if gwenAct.Is3DLoaded()
            float gx = Math.Abs(gwenAct.GetPositionX() - 8280.0)
            float gy = Math.Abs(gwenAct.GetPositionY() - 7740.0)
            float gz = gwenAct.GetPositionZ()
            if gwenAct.IsInCombat() && (gx > 750.0 || gy > 750.0 || gz < 185.0)
                gwenAct.StopCombat()
                gwenAct.SetPosition(8280.0, 7740.0, 200.0)
                gwenAct.EvaluatePackage()
            elseif !gwenAct.IsInCombat() && (gx > 240.0 || gy > 240.0 || gz < 185.0)
                gwenAct.SetPosition(8280.0, 7740.0, 200.0)
                gwenAct.EvaluatePackage()
            endif
            EquipKhansActorGear(gwenAct, 0x00001024, 0x00146174, 0)
        endif
    endif

    Form noteBase = Game.GetFormFromFile(0x0000114C, "Vault13Chronicles.esp")
    if noteBase != None
        ObjectReference noteRef = Game.FindClosestReferenceOfType(noteBase, 8340.0, 7880.0, 200.0, 400.0)
        if noteRef != None && noteRef.GetContainer() == None
            noteRef.SetPosition(8370.0, 7876.0, 256.5)
        endif
    endif
    Actor tolanAct = Game.GetFormFromFile(0x000035CE, "Vault13Chronicles.esp") as Actor
    if tolanAct != None && !tolanAct.IsDead()
        float tz = tolanAct.GetPositionZ()
        if (tz < 188.0 || tz > 310.0) && Self.GetStage() < 25
            tolanAct.SetPosition(14200.0, 10800.0, 206.0)
            ForceQuestAlias(1, 0x000035CE)
        elseif !tolanAct.IsInCombat() && (Math.Abs(tolanAct.GetPositionX() - 14200.0) > 450.0 || Math.Abs(tolanAct.GetPositionY() - 10800.0) > 450.0)
            tolanAct.SetPosition(14200.0, 10800.0, 206.0)
            ForceQuestAlias(1, 0x000035CE)
        endif
    endif
EndFunction

Function SilenceKhansActorsExcept(Actor akSpeaker)
    Topic stopTopic = Game.GetFormFromFile(0x00004003, "Vault13Chronicles.esp") as Topic
    if stopTopic == None
        return
    endif
    Actor dianaAct = Game.GetFormFromFile(0x000035CB, "Vault13Chronicles.esp") as Actor
    Actor gwenAct = Game.GetFormFromFile(0x000035CC, "Vault13Chronicles.esp") as Actor
    if dianaAct != None && dianaAct != akSpeaker && dianaAct.IsTalking()
        dianaAct.Say(stopTopic, None, false, None)
    endif
    if gwenAct != None && gwenAct != akSpeaker && gwenAct.IsTalking()
        gwenAct.Say(stopTopic, None, false, None)
    endif
EndFunction

Function SetupKhansListeners()
    if !Self.IsRunning() && !Self.IsCompleted()
        Self.Start()
    endif
    if Self.GetStage() < 10
        Self.SetStage(10)
    endif
    ForceAllKhansAliases()
    RefreshKhansSettlementLayout()

    Actor player = Game.GetPlayer()
    Form keyBase = Game.GetFormFromFile(0x00001453, "Vault13Chronicles.esp")
    Self.RemoveAllInventoryEventFilters()
    if keyBase != None
        Self.AddInventoryEventFilter(keyBase)
    endif
    if player != None
        RegisterForRemoteEvent(player, "OnPlayerLoadGame")
        RegisterForRemoteEvent(player, "OnLocationChange")
        if keyBase != None
            RegisterForRemoteEvent(player as ObjectReference, "OnItemAdded")
        endif
    endif

    ObjectReference dianaRef = Game.GetFormFromFile(0x000035CB, "Vault13Chronicles.esp") as ObjectReference
    if dianaRef != None
        RegisterForRemoteEvent(dianaRef, "OnActivate")
        if (dianaRef as Actor) != None
            RegisterForRemoteEvent(dianaRef as Actor, "OnCombatStateChanged")
        endif
    endif
    ObjectReference gwenRef = Game.GetFormFromFile(0x000035CC, "Vault13Chronicles.esp") as ObjectReference
    if gwenRef != None
        RegisterForRemoteEvent(gwenRef, "OnActivate")
        if (gwenRef as Actor) != None
            RegisterForRemoteEvent(gwenRef as Actor, "OnCombatStateChanged")
        endif
    endif
    Actor tolanRef = Game.GetFormFromFile(0x000035CE, "Vault13Chronicles.esp") as Actor
    if tolanRef != None
        RegisterForRemoteEvent(tolanRef, "OnDeath")
        RegisterForRemoteEvent(tolanRef as ObjectReference, "OnActivate")
        RegisterForRemoteEvent(tolanRef as ObjectReference, "OnItemRemoved")
        V13WastelandCreatureAIScript tolAI = tolanRef as V13WastelandCreatureAIScript
        if tolAI != None
            tolAI.InitCreatureAI()
        endif
        float tx = tolanRef.GetPositionX()
        float ty = tolanRef.GetPositionY()
        float tz = tolanRef.GetPositionZ()
        if !tolanRef.IsDead()
            if (tz < 188.0 || tz > 310.0) && Self.GetStage() < 25
                tolanRef.SetPosition(14200.0, 10800.0, 206.0)
                ForceQuestAlias(1, 0x000035CE)
            elseif !tolanRef.IsInCombat()
                if Math.Abs(tx - 14200.0) > 450.0 || Math.Abs(ty - 10800.0) > 450.0
                    tolanRef.SetPosition(14200.0, 10800.0, 206.0)
                    ForceQuestAlias(1, 0x000035CE)
                endif
            endif
        endif
        if bKeyRecovered || bItemDelivered || Self.GetStage() >= 25 || (player != None && keyBase != None && player.GetItemCount(keyBase) > 0)
            bKeyRecovered = True
            bKeySeeded = True
            if keyBase != None && tolanRef.GetItemCount(keyBase) > 0
                tolanRef.RemoveItem(keyBase, tolanRef.GetItemCount(keyBase), True)
            endif
        elseif tolanRef.Is3DLoaded() && !bKeySeeded && keyBase != None
            if tolanRef.GetItemCount(keyBase) == 0
                tolanRef.AddItem(keyBase, 1, True)
            endif
            bKeySeeded = True
        endif
        if Self.GetStage() == 20 && tolanRef.IsDead()
            if bKeyRecovered || (player != None && keyBase != None && player.GetItemCount(keyBase) > 0)
                Self.SetStage(25)
            else
                Self.SetStage(22)
            endif
        endif
    endif
    Actor khanRef = Game.GetFormFromFile(0x000035CF, "Vault13Chronicles.esp") as Actor
    if khanRef != None && !khanRef.IsDead()
        V13WastelandCreatureAIScript khAI = khanRef as V13WastelandCreatureAIScript
        if khAI != None
            khAI.InitCreatureAI()
        endif
        float kz = khanRef.GetPositionZ()
        if kz < 188.0 || kz > 310.0 || (!khanRef.IsInCombat() && (Math.Abs(khanRef.GetPositionX() - 14040.0) > 450.0 || Math.Abs(khanRef.GetPositionY() - 10700.0) > 450.0))
            khanRef.SetPosition(14040.0, 10700.0, 206.0)
        endif
    endif
    StartTimer(3.5, 97)
EndFunction

Event OnInit()
    SetupKhansListeners()
EndEvent

Event OnQuestInit()
    SetupKhansListeners()
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
    SetupKhansListeners()
EndEvent

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
    SetupKhansListeners()
    StartTimer(1.0, 97)
EndEvent

Function NotifyKhanKeyRecovered()
    if bKeyRecovered
        return
    endif
    bKeyRecovered = True
    bKeySeeded = True
    Actor tolanRef = Game.GetFormFromFile(0x000035CE, "Vault13Chronicles.esp") as Actor
    Form keyBase = Game.GetFormFromFile(0x00001453, "Vault13Chronicles.esp")
    if tolanRef != None && keyBase != None && tolanRef.GetItemCount(keyBase) > 0
        tolanRef.RemoveItem(keyBase, tolanRef.GetItemCount(keyBase), True)
    endif
    if Self.GetStage() < 25
        Self.SetStage(25)
    endif
    SetupKhansListeners()
EndFunction

Function DeliverKeyToGwen()
    if bItemDelivered
        return
    endif
    bItemDelivered = True
    Actor player = Game.GetPlayer()
    Form keyBase = Game.GetFormFromFile(0x00001453, "Vault13Chronicles.esp")
    if keyBase != None && player.GetItemCount(keyBase) > 0
        player.RemoveItem(keyBase, 1, True)
    endif
    Form noteBase = Game.GetFormFromFile(0x0000114C, "Vault13Chronicles.esp")
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

Event Actor.OnCombatStateChanged(Actor akSender, Actor akTarget, int aeCombatState)
    if aeCombatState == 0
        RefreshKhansSettlementLayout()
        StartTimer(1.5, 97)
    endif
EndEvent

Event ObjectReference.OnItemAdded(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    Form keyBase = Game.GetFormFromFile(0x00001453, "Vault13Chronicles.esp")
    if akBaseItem == keyBase
        NotifyKhanKeyRecovered()
    endif
EndEvent

Event ObjectReference.OnItemRemoved(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
    Form keyBase = Game.GetFormFromFile(0x00001453, "Vault13Chronicles.esp")
    if akBaseItem == keyBase || (akSender != None && (akSender as Actor) != None && (akSender as Actor).IsDead())
        Actor player = Game.GetPlayer()
        if keyBase != None && player != None && player.GetItemCount(keyBase) == 0
            player.AddItem(keyBase, 1, False)
        endif
        NotifyKhanKeyRecovered()
    endif
EndEvent

Event Actor.OnDeath(Actor akSender, Actor akKiller)
    Actor tolanRef = Game.GetFormFromFile(0x000035CE, "Vault13Chronicles.esp") as Actor
    if akSender == tolanRef
        Form keyBase = Game.GetFormFromFile(0x00001453, "Vault13Chronicles.esp")
        Actor player = Game.GetPlayer()
        if !bKeySeeded && !bKeyRecovered && keyBase != None && player != None && player.GetItemCount(keyBase) == 0 && tolanRef.GetItemCount(keyBase) == 0
            tolanRef.AddItem(keyBase, 1, True)
            bKeySeeded = True
        endif
        ForceQuestAlias(1, 0x000035CE)
        if bKeyRecovered || (keyBase != None && player != None && player.GetItemCount(keyBase) > 0)
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
    ObjectReference dianaRef = Game.GetFormFromFile(0x000035CB, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference gwenRef = Game.GetFormFromFile(0x000035CC, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference tolanObjRef = Game.GetFormFromFile(0x000035CE, "Vault13Chronicles.esp") as ObjectReference
    Form keyBase = Game.GetFormFromFile(0x00001453, "Vault13Chronicles.esp")
    Actor player = Game.GetPlayer()

    if akSender == tolanObjRef && (tolanObjRef as Actor) != None && (tolanObjRef as Actor).IsDead()
        if keyBase != None && player != None && player.GetItemCount(keyBase) == 0
            player.AddItem(keyBase, 1, False)
        endif
        NotifyKhanKeyRecovered()
        return
    endif

    ForceAllKhansAliases()
    SilenceKhansActorsExcept(akSender as Actor)
    int curStage = Self.GetStage()
    if akSender == gwenRef && (curStage == 25 || (keyBase != None && player.GetItemCount(keyBase) > 0 && curStage < 30))
        DeliverKeyToGwen()
    elseif akSender == dianaRef && (curStage == 30 || (bItemDelivered && curStage < 40))
        if Self.GetStage() < 40
            Self.SetStage(40)
        endif
    elseif akSender == dianaRef && curStage < 25
        sceneWaitTicks = 0
        StartTimer(1.2, 91)
        StartTimer(2.0, 94)
    elseif akSender == gwenRef && curStage < 20
        StartTimer(2.0, 94)
    endif
EndEvent

Function QueueJumpToKhansPass()
    if bMenuJumpBusy
        return
    endif
    bMenuJumpBusy = True
    SetupKhansListeners()
    StartTimer(0.6, 95)
EndFunction

Event OnTimer(int aiTimerID)
    if aiTimerID == 91
        Scene introScene = Game.GetFormFromFile(0x00012100, "Vault13Chronicles.esp") as Scene
        Actor dianaActor = Game.GetFormFromFile(0x000035CB, "Vault13Chronicles.esp") as Actor
        if Self.IsRunning() && introScene != None && Self.GetStage() < 25
            if introScene.IsPlaying()
                return
            elseif dianaActor != None && dianaActor.IsTalking() && sceneWaitTicks < 28
                sceneWaitTicks += 1
                StartTimer(0.35, 91)
            else
                ForceAllKhansAliases()
                SilenceKhansActorsExcept(dianaActor)
                if Self.IsRunning()
                    introScene.Start()
                endif
            endif
        endif
    elseif aiTimerID == 93
        Actor tolCheck = Game.GetFormFromFile(0x000035CE, "Vault13Chronicles.esp") as Actor
        Form keyCheck = Game.GetFormFromFile(0x00001453, "Vault13Chronicles.esp")
        Actor plCheck = Game.GetPlayer()
        if Self.GetStage() < 25 && tolCheck != None && tolCheck.IsDead()
            if (plCheck != None && keyCheck != None && plCheck.GetItemCount(keyCheck) > 0) || (keyCheck != None && tolCheck.GetItemCount(keyCheck) == 0)
                if plCheck != None && keyCheck != None && plCheck.GetItemCount(keyCheck) == 0
                    plCheck.AddItem(keyCheck, 1, False)
                endif
                NotifyKhanKeyRecovered()
            elseif plCheck != None && plCheck.GetDistance(tolCheck) < 2500.0
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
        ObjectReference mapMarker = Game.GetFormFromFile(0x0000341E, "Vault13Chronicles.esp") as ObjectReference
        if mapMarker != None
            mapMarker.EnableNoWait()
            mapMarker.AddToMap(True)
        endif
        ObjectReference ftMarker = Game.GetFormFromFile(0x0000351E, "Vault13Chronicles.esp") as ObjectReference
        if ftMarker != None
            player.MoveTo(ftMarker)
            RefreshKhansSettlementLayout()
            StartTimer(1.0, 97)
            Debug.Notification("Trasladado al Paso Oriental de los Khans (2161). Habla con las exploradoras Diana y Gwen.")
        endif
    elseif aiTimerID == 97
        RefreshKhansSettlementLayout()
        Actor dianaChk = Game.GetFormFromFile(0x000035CB, "Vault13Chronicles.esp") as Actor
        if dianaChk != None && dianaChk.Is3DLoaded()
            StartTimer(3.5, 97)
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

    SetupKhansListeners()
    Actor player = Game.GetPlayer()
    Form keyBase = Game.GetFormFromFile(0x00001453, "Vault13Chronicles.esp")

    if auiStageID == 20
        ObjectReference mapMarker = Game.GetFormFromFile(0x0000341E, "Vault13Chronicles.esp") as ObjectReference
        if mapMarker != None
            mapMarker.EnableNoWait()
            mapMarker.AddToMap(True)
        endif
        if keyBase != None && player.GetItemCount(keyBase) > 0
            Self.SetStage(25)
            return
        endif
        Actor tolanRef = Game.GetFormFromFile(0x000035CE, "Vault13Chronicles.esp") as Actor
        if tolanRef != None && tolanRef.IsDead()
            Self.SetStage(22)
            return
        endif
        ForceQuestAlias(1, 0x000035CE)
        if !IsObjectiveDisplayed(20)
            SetObjectiveDisplayed(20, True, False)
        endif
        Self.SetActive(True)
        if doStg20
            Debug.Notification("Misión Secundaria: Cautivos de los Khans — Elimina al carcelero Tolan en el campamento al norte.")
        endif
    elseif auiStageID == 22
        if keyBase != None && player.GetItemCount(keyBase) > 0
            Self.SetStage(25)
            return
        endif
        ForceQuestAlias(1, 0x000035CE)
        SetObjectiveCompleted(20, True)
        if !IsObjectiveDisplayed(22)
            SetObjectiveDisplayed(22, True, False)
        endif
        Self.SetActive(True)
        if doStg22
            Debug.Notification("¡Carcelero Tolan abatido! Extrae la Llave Maestra y el Sello de Guerra de su cadáver.")
        endif
    elseif auiStageID == 25
        SetObjectiveCompleted(20, True)
        SetObjectiveCompleted(22, True)
        if !IsObjectiveDisplayed(25)
            SetObjectiveDisplayed(25, True, False)
        endif
        Self.SetActive(True)
        if doStg25
            Debug.Notification("Llave Maestra obtenida. Entrégasela a Gwen en el Puesto del Paso Oriental.")
        endif
    elseif auiStageID == 30
        if !bItemDelivered
            DeliverKeyToGwen()
        endif
        SetObjectiveCompleted(20, True)
        SetObjectiveCompleted(22, True)
        SetObjectiveCompleted(25, True)
        if !IsObjectiveDisplayed(30)
            SetObjectiveDisplayed(30, True, False)
        endif
        Self.SetActive(True)
        if doStg30
            Debug.Notification("¡Gwen ha liberado los cerrojos! Informa a Diana en el Puesto del Paso Oriental.")
        endif
    elseif auiStageID == 40
        SetObjectiveCompleted(20, True)
        SetObjectiveCompleted(22, True)
        SetObjectiveCompleted(25, True)
        SetObjectiveCompleted(30, True)
        if doReward40
            Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
            Form rifle = Game.GetFormFromFile(0x0004F46A, "Fallout4.esm")
            Form ammo308 = Game.GetFormFromFile(0x0001F66B, "Fallout4.esm")
            Form stimpak = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
            if caps != None
                player.AddItem(caps, 500, False)
            endif
            if rifle != None
                player.AddItem(rifle, 1, False)
            endif
            if ammo308 != None
                player.AddItem(ammo308, 36, False)
            endif
            if stimpak != None
                player.AddItem(stimpak, 4, False)
            endif
            Game.RewardPlayerXP(350)
            Debug.Notification("¡Misión Secundaria completada: Cautivos de los Khans! (+500 Chapas, Rifle de Caza, Munición .308 y +350 XP)")
        endif
        Self.CompleteQuest()
    endif
EndEvent
