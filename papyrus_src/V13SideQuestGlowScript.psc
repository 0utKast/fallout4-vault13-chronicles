Scriptname V13SideQuestGlowScript extends Quest

bool bItemDelivered = False
bool bRewardGranted = False
bool bHoloRecovered = False
bool bHoloSeeded = False
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

Function ForceAllGlowAliases()
    ForceQuestAlias(0, 0x000035D0)
    ForceQuestAlias(1, 0x000035D2)
    ForceQuestAlias(2, 0x00003005)
    ForceQuestAlias(3, 0x00002003)
    ForceQuestAlias(4, 0x0000351F)
    ForceQuestAlias(5, 0x00002101)
    ForceQuestAlias(6, 0x00003501)
    ForceQuestAlias(7, 0x00002206)
    ForceQuestAlias(8, 0x00002035)
    ForceQuestAlias(9, 0x000035D1)
    ForceQuestAlias(10, 0x000035D0)
EndFunction

Function RefreshGlowSettlementLayout()
    Form noteBase = Game.GetFormFromFile(0x0000114D, "Vault13Chronicles.esp")
    if noteBase != None
        ObjectReference noteRef = Game.FindClosestReferenceOfType(noteBase, -10040.0, -2700.0, 120.0, 400.0)
        if noteRef != None && noteRef.GetContainer() == None
            noteRef.SetPosition(-10010.0, -2664.0, 176.5)
        endif
    endif

    Actor cabbotAct = Game.GetFormFromFile(0x000035D0, "Vault13Chronicles.esp") as Actor
    if cabbotAct != None && !cabbotAct.IsDead() && cabbotAct.Is3DLoaded()
        if !cabbotAct.IsInCombat() && (cabbotAct.GetPositionZ() > 132.0 || Math.Abs(cabbotAct.GetPositionX() + 9940.0) > 50.0 || Math.Abs(cabbotAct.GetPositionY() + 2760.0) > 450.0)
            cabbotAct.SetPosition(-9940.0, -2760.0, 120.0)
            cabbotAct.EvaluatePackage()
        endif
    endif
    Actor talusAct = Game.GetFormFromFile(0x000035D1, "Vault13Chronicles.esp") as Actor
    if talusAct != None && !talusAct.IsDead() && talusAct.Is3DLoaded()
        if !talusAct.IsInCombat() && (talusAct.GetPositionZ() > 132.0 || Math.Abs(talusAct.GetPositionX() + 9580.0) > 450.0 || Math.Abs(talusAct.GetPositionY() + 2760.0) > 450.0)
            talusAct.SetPosition(-9580.0, -2760.0, 120.0)
            talusAct.EvaluatePackage()
        endif
    endif
    Actor sentryAct = Game.GetFormFromFile(0x000035D2, "Vault13Chronicles.esp") as Actor
    if sentryAct != None && !sentryAct.IsDead()
        float sz = sentryAct.GetPositionZ()
        if (sz < 108.0 || sz > 230.0) && Self.GetStage() < 25
            sentryAct.SetPosition(-8400.0, -8600.0, 126.0)
            ForceQuestAlias(1, 0x000035D2)
        elseif !sentryAct.IsInCombat() && (Math.Abs(sentryAct.GetPositionX() + 8400.0) > 450.0 || Math.Abs(sentryAct.GetPositionY() + 8600.0) > 450.0)
            sentryAct.SetPosition(-8400.0, -8600.0, 126.0)
            ForceQuestAlias(1, 0x000035D2)
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

Function SetupGlowListeners()
    if !Self.IsRunning() && !Self.IsCompleted()
        Self.Start()
    endif
    if Self.GetStage() < 10
        Self.SetStage(10)
    endif
    ForceAllGlowAliases()
    RefreshGlowSettlementLayout()

    Actor player = Game.GetPlayer()
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
        if holoBase != None
            AddInventoryEventFilter(holoBase)
        endif
        RegisterForRemoteEvent(sentryRef as ObjectReference, "OnItemRemoved")
        V13WastelandCreatureAIScript sentryAI = (sentryRef as ObjectReference) as V13WastelandCreatureAIScript
        if sentryAI != None
            sentryAI.InitCreatureAI()
        endif
        float sx = sentryRef.GetPositionX()
        float sy = sentryRef.GetPositionY()
        float sz = sentryRef.GetPositionZ()
        if !sentryRef.IsDead()
            if (sz < 108.0 || sz > 230.0) && Self.GetStage() < 25
                sentryRef.SetPosition(-8400.0, -8600.0, 126.0)
                ForceQuestAlias(1, 0x000035D2)
            elseif !sentryRef.IsInCombat()
                if Math.Abs(sx + 8400.0) > 450.0 || Math.Abs(sy + 8600.0) > 450.0
                    sentryRef.SetPosition(-8400.0, -8600.0, 126.0)
                    ForceQuestAlias(1, 0x000035D2)
                endif
            endif
        endif
        if bHoloRecovered || bItemDelivered || Self.GetStage() >= 25 || (player != None && holoBase != None && player.GetItemCount(holoBase) > 0)
            bHoloRecovered = True
            bHoloSeeded = True
            if holoBase != None && sentryRef.GetItemCount(holoBase) > 0
                sentryRef.RemoveItem(holoBase, sentryRef.GetItemCount(holoBase), True)
            endif
        elseif sentryRef.Is3DLoaded() && !bHoloSeeded && holoBase != None
            if sentryRef.GetItemCount(holoBase) == 0
                sentryRef.AddItem(holoBase, 1, True)
            endif
            bHoloSeeded = True
        endif
        if Self.GetStage() == 20 && sentryRef.IsDead()
            if bHoloRecovered || (player != None && holoBase != None && player.GetItemCount(holoBase) > 0)
                Self.SetStage(25)
            else
                Self.SetStage(22)
            endif
        endif
    endif
EndFunction

Event OnInit()
    SetupGlowListeners()
EndEvent

Event OnQuestInit()
    SetupGlowListeners()
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
    SetupGlowListeners()
EndEvent

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
    SetupGlowListeners()
    StartTimer(1.0, 97)
EndEvent

Function NotifyGlowHolodiskRecovered()
    if bHoloRecovered
        return
    endif
    bHoloRecovered = True
    bHoloSeeded = True
    Actor sentryRef = Game.GetFormFromFile(0x000035D2, "Vault13Chronicles.esp") as Actor
    Form holoBase = Game.GetFormFromFile(0x00001454, "Vault13Chronicles.esp")
    if sentryRef != None && holoBase != None && sentryRef.GetItemCount(holoBase) > 0
        sentryRef.RemoveItem(holoBase, sentryRef.GetItemCount(holoBase), True)
    endif
    if Self.GetStage() < 25
        Self.SetStage(25)
    endif
    SetupGlowListeners()
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
    if akBaseItem == holoBase
        NotifyGlowHolodiskRecovered()
    endif
EndEvent

Event Actor.OnDeath(Actor akSender, Actor akKiller)
    Actor sentryRef = Game.GetFormFromFile(0x000035D2, "Vault13Chronicles.esp") as Actor
    if akSender == sentryRef
        Form holoBase = Game.GetFormFromFile(0x00001454, "Vault13Chronicles.esp")
        Actor player = Game.GetPlayer()
        if !bHoloSeeded && !bHoloRecovered && holoBase != None && player != None && player.GetItemCount(holoBase) == 0 && sentryRef.GetItemCount(holoBase) == 0
            sentryRef.AddItem(holoBase, 1, True)
            bHoloSeeded = True
        endif
        ForceQuestAlias(1, 0x000035D2)
        if bHoloRecovered || (holoBase != None && player != None && player.GetItemCount(holoBase) > 0)
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
    ObjectReference cabbotRef = Game.GetFormFromFile(0x000035D0, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference talusRef = Game.GetFormFromFile(0x000035D1, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference sentryObjRef = Game.GetFormFromFile(0x000035D2, "Vault13Chronicles.esp") as ObjectReference
    Actor sentryAct = sentryObjRef as Actor
    Form holoBase = Game.GetFormFromFile(0x00001454, "Vault13Chronicles.esp")
    Actor player = Game.GetPlayer()

    if akSender == sentryObjRef
        if sentryAct != None && sentryAct.IsDead()
            if holoBase != None && player != None && player.GetItemCount(holoBase) == 0 && !bItemDelivered
                if sentryAct.GetItemCount(holoBase) > 0
                    sentryAct.RemoveItem(holoBase, sentryAct.GetItemCount(holoBase), True)
                endif
                player.AddItem(holoBase, 1, False)
            endif
            NotifyGlowHolodiskRecovered()
        endif
        return
    endif

    ForceAllGlowAliases()
    RefreshGlowSettlementLayout()
    SilenceGlowActorsExcept(akSender as Actor)
    int curStage = Self.GetStage()
    if akSender == talusRef && (curStage == 22 || curStage == 25 || (holoBase != None && player.GetItemCount(holoBase) > 0 && curStage < 30))
        NotifyGlowHolodiskRecovered()
        DeliverHolodiskToTalus()
    elseif akSender == cabbotRef && (curStage == 25 || curStage == 30 || (bItemDelivered && curStage < 40) || (holoBase != None && player.GetItemCount(holoBase) > 0 && curStage < 40))
        if !bItemDelivered
            DeliverHolodiskToTalus()
        endif
        if Self.GetStage() < 40
            Self.SetStage(40)
        endif
    elseif akSender == cabbotRef && curStage < 25
        sceneWaitTicks = 0
        StartTimer(0.6, 91)
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
            if introScene.IsPlaying()
                return
            elseif cabbotActor != None && cabbotActor.IsTalking() && sceneWaitTicks < 28
                sceneWaitTicks += 1
                StartTimer(0.35, 91)
            else
                ForceAllGlowAliases()
                SilenceGlowActorsExcept(cabbotActor)
                if Self.IsRunning()
                    introScene.Start()
                endif
            endif
        endif
    elseif aiTimerID == 93
        Actor sentryRef = Game.GetFormFromFile(0x000035D2, "Vault13Chronicles.esp") as Actor
        Actor player = Game.GetPlayer()
        Form holoBase = Game.GetFormFromFile(0x00001454, "Vault13Chronicles.esp")
        if bHoloRecovered || bItemDelivered || Self.GetStage() >= 25
            return
        endif
        if player != None && holoBase != None && player.GetItemCount(holoBase) > 0
            NotifyGlowHolodiskRecovered()
            return
        endif
        if sentryRef != None && sentryRef.IsDead()
            if holoBase != None && sentryRef.GetItemCount(holoBase) == 0 && bHoloSeeded
                if player != None && player.GetItemCount(holoBase) == 0
                    player.AddItem(holoBase, 1, False)
                endif
                NotifyGlowHolodiskRecovered()
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
            Debug.Notification("Trasladado al Puesto Exterior de Lost Hills (2161). Habla con Cabbot o el Paladín Talus para la prueba de El Resplandor.")
        endif
    elseif aiTimerID == 97
        RefreshGlowSettlementLayout()
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

    if auiStageID == 20
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
        Actor sentryRef = Game.GetFormFromFile(0x000035D2, "Vault13Chronicles.esp") as Actor
        if sentryRef != None && sentryRef.IsDead()
            Self.SetStage(22)
            return
        endif
        ForceQuestAlias(1, 0x000035D2)
        if !IsObjectiveDisplayed(20)
            SetObjectiveDisplayed(20, True, False)
        endif
        Self.SetActive(True)
        if doStg20
            Debug.Notification("Misión Secundaria: El Resplandor (West Tek) — Destruye al Centinela ZAX-WT01 en el cráter al sur de Lost Hills.")
        endif
    elseif auiStageID == 22
        if holoBase != None && player.GetItemCount(holoBase) > 0
            Self.SetStage(25)
            return
        endif
        ForceQuestAlias(1, 0x000035D2)
        SetObjectiveCompleted(20, True)
        if !IsObjectiveDisplayed(22)
            SetObjectiveDisplayed(22, True, False)
        endif
        Self.SetActive(True)
        if doStg22
            Debug.Notification("¡Centinela ZAX-WT01 abatido! Extrae el Holodisco del Sargento Dennis Allen de sus restos.")
        endif
    elseif auiStageID == 25
        SetObjectiveCompleted(20, True)
        SetObjectiveCompleted(22, True)
        if !IsObjectiveDisplayed(25)
            SetObjectiveDisplayed(25, True, False)
        endif
        Self.SetActive(True)
        if doStg25
            Debug.Notification("Holodisco del Sargento Allen recuperado. Entrégaselo al Paladín Talus en Lost Hills.")
        endif
    elseif auiStageID == 30
        if !bItemDelivered
            DeliverHolodiskToTalus()
        endif
        SetObjectiveCompleted(20, True)
        SetObjectiveCompleted(22, True)
        SetObjectiveCompleted(25, True)
        if !IsObjectiveDisplayed(30)
            SetObjectiveDisplayed(30, True, False)
        endif
        Self.SetActive(True)
        if doStg30
            Debug.Notification("¡El Paladín Talus ha autenticado el holodisco! Habla con Cabbot en la entrada de Lost Hills.")
        endif
    elseif auiStageID == 40
        SetObjectiveCompleted(20, True)
        SetObjectiveCompleted(22, True)
        SetObjectiveCompleted(25, True)
        SetObjectiveCompleted(30, True)
        if doReward40
            Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
            Form wattz2000 = Game.GetFormFromFile(0x00001108, "Vault13Chronicles.esp")
            Form cells = Game.GetFormFromFile(0x000C1897, "Fallout4.esm")
            Form radx = Game.GetFormFromFile(0x00024057, "Fallout4.esm")
            if caps != None
                player.AddItem(caps, 500, False)
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
            Game.RewardPlayerXP(350)
            Debug.Notification("¡Misión Secundaria completada: La Prueba de El Resplandor! (+Rifle Láser Wattz 2000, Células, +500 Chapas y +350 XP)")
        endif
        Self.CompleteQuest()
    endif
EndEvent
