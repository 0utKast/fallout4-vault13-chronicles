Scriptname V13SideQuestTandiRescueScript extends Quest

bool Property PaidRansom = False Auto
int sceneWaitTicks = 0
bool bStg15Done = False
bool bStg20Done = False
bool bStg26Done = False
bool bStg27Done = False
bool bStg28Done = False
bool bStg29Done = False
bool bStg30Done = False
bool bStg40Done = False
bool bPetroxResolved = False

Function ForceQuestAlias(int aiAliasID, int aiFormID)
    ObjectReference targetRef = Game.GetFormFromFile(aiFormID, "Vault13Chronicles.esp") as ObjectReference
    ReferenceAlias al = Self.GetAlias(aiAliasID) as ReferenceAlias
    If al != None && targetRef != None
        If al.GetReference() != targetRef
            al.ForceRefTo(targetRef)
        EndIf
    EndIf
EndFunction

Function ForceAllTandiRescueAliases()
    ForceQuestAlias(0, 0x000035A0)
    ForceQuestAlias(1, 0x000035D8)
    ForceQuestAlias(2, 0x00003005)
    ForceQuestAlias(3, 0x00002003)
    ForceQuestAlias(4, 0x00003512)
    ForceQuestAlias(5, 0x00002101)
    ForceQuestAlias(6, 0x00003501)
    ForceQuestAlias(7, 0x00002206)
    ForceQuestAlias(8, 0x00002035)
    ForceQuestAlias(9, 0x000035A1)
    ForceQuestAlias(10, 0x000035A2)
EndFunction

Function SetupTandiRescueListeners()
    ForceAllTandiRescueAliases()
    Actor player = Game.GetPlayer()
    Form keyForm = Game.GetFormFromFile(0x0001459, "Vault13Chronicles.esp")
    Self.RemoveAllInventoryEventFilters()
    If keyForm != None
        Self.AddInventoryEventFilter(keyForm)
    EndIf
    If player != None
        RegisterForRemoteEvent(player, "OnPlayerLoadGame")
        RegisterForRemoteEvent(player, "OnLocationChange")
        If keyForm != None
            RegisterForRemoteEvent(player, "OnItemAdded")
        EndIf
    EndIf
    ObjectReference aradeshRef = Game.GetFormFromFile(0x000035A0, "Vault13Chronicles.esp") as ObjectReference
    If aradeshRef != None
        RegisterForRemoteEvent(aradeshRef, "OnActivate")
    EndIf
    ObjectReference sethRef = Game.GetFormFromFile(0x000035A2, "Vault13Chronicles.esp") as ObjectReference
    If sethRef != None
        RegisterForRemoteEvent(sethRef, "OnActivate")
    EndIf
    ObjectReference tandiRef = Game.GetFormFromFile(0x000035A1, "Vault13Chronicles.esp") as ObjectReference
    If tandiRef != None
        RegisterForRemoteEvent(tandiRef, "OnActivate")
    EndIf
    Actor petroxAct = Game.GetFormFromFile(0x000035D8, "Vault13Chronicles.esp") as Actor
    If petroxAct != None
        RegisterForRemoteEvent(petroxAct as ObjectReference, "OnActivate")
        RegisterForRemoteEvent(petroxAct, "OnDeath")
        RegisterForRemoteEvent(petroxAct, "OnCombatStateChanged")
        RegisterForHitEvent(petroxAct)
    EndIf
    Actor guard1Act = Game.GetFormFromFile(0x000035D9, "Vault13Chronicles.esp") as Actor
    If guard1Act != None
        RegisterForRemoteEvent(guard1Act, "OnCombatStateChanged")
        RegisterForHitEvent(guard1Act)
    EndIf
    Actor guard2Act = Game.GetFormFromFile(0x000035DA, "Vault13Chronicles.esp") as Actor
    If guard2Act != None
        RegisterForRemoteEvent(guard2Act, "OnCombatStateChanged")
        RegisterForHitEvent(guard2Act)
    EndIf
    If GetStage() < 15
        Quest shadyQ = Game.GetFormFromFile(0x00009500, "Vault13Chronicles.esp") as Quest
        Actor aradeshCheck = aradeshRef as Actor
        Actor tandiCheck = tandiRef as Actor
        if shadyQ != None && shadyQ.GetStage() >= 40 && player != None && (aradeshCheck == None || !aradeshCheck.IsTalking())
            if player.IsInInterior() || ((aradeshCheck == None || player.GetDistance(aradeshCheck) >= 3200.0) && (tandiCheck == None || player.GetDistance(tandiCheck) >= 2800.0))
                SetStage(15)
            endif
        endif
    EndIf
EndFunction

Function SetupCampActors(bool abEnable)
    ObjectReference petroxRef = Game.GetFormFromFile(0x000035D8, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference guard1Ref = Game.GetFormFromFile(0x000035D9, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference guard2Ref = Game.GetFormFromFile(0x000035DA, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference lockRef = Game.GetFormFromFile(0x000035DB, "Vault13Chronicles.esp") as ObjectReference

    If abEnable
        If lockRef != None
            lockRef.EnableNoWait()
            lockRef.SetPosition(10480.0, 13580.0, 200.0)
        EndIf
        If petroxRef != None
            petroxRef.EnableNoWait()
            petroxRef.SetPosition(10400.0, 13360.0, 206.0)
            petroxRef.SetAngle(0.0, 0.0, 180.0)
            Actor petroxAct = petroxRef as Actor
            If petroxAct != None && !petroxAct.IsDead()
                ActorValue aggrAV = Game.GetAggressionAV()
                If aggrAV != None
                    petroxAct.SetValue(aggrAV, 0.0)
                EndIf
                petroxAct.StopCombat()
                petroxAct.EvaluatePackage()
            EndIf
        EndIf
        If guard1Ref != None
            guard1Ref.EnableNoWait()
            guard1Ref.SetPosition(10240.0, 13320.0, 206.0)
            guard1Ref.SetAngle(0.0, 0.0, 180.0)
            Actor g1Act = guard1Ref as Actor
            If g1Act != None && !g1Act.IsDead()
                ActorValue aggrAV1 = Game.GetAggressionAV()
                If aggrAV1 != None
                    g1Act.SetValue(aggrAV1, 0.0)
                EndIf
                g1Act.StopCombat()
                g1Act.EvaluatePackage()
            EndIf
        EndIf
        If guard2Ref != None
            guard2Ref.EnableNoWait()
            guard2Ref.SetPosition(10560.0, 13320.0, 206.0)
            guard2Ref.SetAngle(0.0, 0.0, 180.0)
            Actor g2Act = guard2Ref as Actor
            If g2Act != None && !g2Act.IsDead()
                ActorValue aggrAV2 = Game.GetAggressionAV()
                If aggrAV2 != None
                    g2Act.SetValue(aggrAV2, 0.0)
                EndIf
                g2Act.StopCombat()
                g2Act.EvaluatePackage()
            EndIf
        EndIf
    Else
        If petroxRef != None
            Actor petroxCheck = petroxRef as Actor
            If petroxCheck != None && !petroxCheck.IsDead() && !petroxCheck.IsInCombat()
                petroxRef.DisableNoWait()
            EndIf
        EndIf
        If guard1Ref != None
            Actor g1Check = guard1Ref as Actor
            If g1Check != None && !g1Check.IsDead() && !g1Check.IsInCombat()
                guard1Ref.DisableNoWait()
            EndIf
        EndIf
        If guard2Ref != None
            Actor g2Check = guard2Ref as Actor
            If g2Check != None && !g2Check.IsDead() && !g2Check.IsInCombat()
                guard2Ref.DisableNoWait()
            EndIf
        EndIf
    EndIf
EndFunction

Function MoveTandiToCamp()
    Actor tandiAct = Game.GetFormFromFile(0x000035A1, "Vault13Chronicles.esp") as Actor
    If tandiAct != None
        tandiAct.EnableNoWait()
        If tandiAct.IsDead()
            tandiAct.Resurrect()
        EndIf
        tandiAct.SetPosition(10400.0, 13580.0, 206.0)
        tandiAct.StopCombat()
        tandiAct.EvaluatePackage()
    EndIf
EndFunction

Function ReturnTandiToShadySands()
    Actor tandiAct = Game.GetFormFromFile(0x000035A1, "Vault13Chronicles.esp") as Actor
    If tandiAct != None
        tandiAct.EnableNoWait()
        If tandiAct.IsDead()
            tandiAct.Resurrect()
        EndIf
        tandiAct.SetPosition(2550.0, 9690.0, 160.0)
        tandiAct.SetAngle(0.0, 0.0, 180.0)
        tandiAct.StopCombat()
        tandiAct.EvaluatePackage()
    EndIf
EndFunction

Function TriggerHostileKhanCamp()
    Actor player = Game.GetPlayer()
    ActorValue aggrAV = Game.GetAggressionAV()
    ActorValue confAV = Game.GetConfidenceAV()

    int[] campIDs = new int[3]
    campIDs[0] = 0x000035D8
    campIDs[1] = 0x000035D9
    campIDs[2] = 0x000035DA

    int idx = 0
    While idx < 3
        Actor kAct = Game.GetFormFromFile(campIDs[idx], "Vault13Chronicles.esp") as Actor
        If kAct != None && !kAct.IsDead()
            ActorBase kBase = kAct.GetActorBase()
            If kBase != None
                kBase.SetEssential(False)
                kBase.SetProtected(False)
                kBase.SetInvulnerable(False)
            EndIf
            bool needsEval = False
            If aggrAV != None && kAct.GetValue(aggrAV) < 2.0
                kAct.SetValue(aggrAV, 2.0)
                needsEval = True
            EndIf
            If confAV != None && kAct.GetValue(confAV) < 4.0
                kAct.SetValue(confAV, 4.0)
                needsEval = True
            EndIf
            If needsEval
                kAct.EvaluatePackage()
            EndIf
            If player != None && !player.IsDead() && !kAct.IsDead() && !kAct.IsInCombat()
                kAct.StartCombat(player)
            EndIf
        EndIf
        idx += 1
    EndWhile
EndFunction

Event OnInit()
    SetupTandiRescueListeners()
EndEvent

Event OnQuestInit()
    SetupTandiRescueListeners()
    If GetStage() >= 15 && GetStage() < 40
        StartTimer(3.0, 101)
    EndIf
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
    SetupTandiRescueListeners()
    If GetStage() >= 15 && GetStage() < 40
        StartTimer(3.0, 101)
    EndIf
EndEvent

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
    SetupTandiRescueListeners()
    If GetStage() >= 15 && GetStage() < 40
        StartTimer(3.0, 101)
    EndIf
    If GetStage() == 30
        Actor player = Game.GetPlayer()
        Actor tandi = Game.GetFormFromFile(0x000035A1, "Vault13Chronicles.esp") as Actor
        Actor aradesh = Game.GetFormFromFile(0x000035A0, "Vault13Chronicles.esp") as Actor
        If tandi != None && (player == None || player.GetDistance(tandi) > 1800.0 || (aradesh != None && player.GetDistance(aradesh) < 2400.0))
            ReturnTandiToShadySands()
        EndIf
    EndIf
EndEvent

Event ObjectReference.OnItemAdded(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    Form keyForm = Game.GetFormFromFile(0x0001459, "Vault13Chronicles.esp")
    If akBaseItem == keyForm && GetStage() >= 15 && GetStage() < 30 && !bPetroxResolved
        bPetroxResolved = True
        SetStage(30)
    EndIf
EndEvent

Event Actor.OnDeath(Actor akSender, Actor akKiller)
    Actor petroxAct = Game.GetFormFromFile(0x000035D8, "Vault13Chronicles.esp") as Actor
    If akSender == petroxAct && GetStage() >= 15 && GetStage() < 30 && !bPetroxResolved
        bPetroxResolved = True
        SetStage(30)
    EndIf
EndEvent

Event OnHit(ObjectReference akTarget, ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked, string asMaterial)
    If akTarget != None
        RegisterForHitEvent(akTarget)
    EndIf
    If GetStage() >= 15 && GetStage() < 30 && akAggressor != None
        Actor player = Game.GetPlayer()
        Actor aggActor = akAggressor as Actor
        If (player != None && akAggressor == (player as ObjectReference)) || (aggActor != None && aggActor.IsPlayerTeammate())
            TriggerHostileKhanCamp()
        EndIf
    EndIf
EndEvent

Event Actor.OnCombatStateChanged(Actor akSender, Actor akTarget, int aeCombatState)
    If aeCombatState > 0 && GetStage() >= 15 && GetStage() < 30
        Actor player = Game.GetPlayer()
        If akTarget == player || (akTarget != None && akTarget.IsPlayerTeammate()) || (akSender != None && akSender.IsInCombat())
            TriggerHostileKhanCamp()
        EndIf
    EndIf
EndEvent

Event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
    If akActionRef != Game.GetPlayer()
        Return
    EndIf
    ForceAllTandiRescueAliases()
    int st = GetStage()
    If st < 15 || st >= 40
        Return
    EndIf

    ObjectReference aradeshRef = Game.GetFormFromFile(0x000035A0, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference sethRef = Game.GetFormFromFile(0x000035A2, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference tandiRef = Game.GetFormFromFile(0x000035A1, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference petroxRef = Game.GetFormFromFile(0x000035D8, "Vault13Chronicles.esp") as ObjectReference

    If akSender == aradeshRef
        If st == 15
            Actor aradeshAct = aradeshRef as Actor
            Topic helloTop = Game.GetFormFromFile(0x00018001, "Vault13Chronicles.esp") as Topic
            If aradeshAct != None && helloTop != None && !aradeshAct.IsTalking()
                aradeshAct.Say(helloTop, None, False, None)
            EndIf
            sceneWaitTicks = 0
            StartTimer(2.5, 91)
            StartTimer(22.0, 94)
        ElseIf st == 30
            Utility.Wait(0.5)
            If GetStage() < 40
                SetStage(40)
            EndIf
        EndIf
    ElseIf akSender == sethRef && st == 15
        StartTimer(8.0, 94)
    ElseIf akSender == petroxRef && st >= 15 && st < 26
        Actor petroxAct = petroxRef as Actor
        If petroxAct != None && !petroxAct.IsDead() && !petroxAct.IsInCombat()
            If st == 15
                SetStage(20)
            EndIf
            sceneWaitTicks = 0
            StartTimer(1.2, 92)
        EndIf
    ElseIf akSender == tandiRef && st >= 15 && st <= 30
        Actor petroxCheck = petroxRef as Actor
        If st < 30 && petroxCheck != None && petroxCheck.IsDead()
            SetStage(30)
        EndIf
        If GetStage() == 30
            Actor tandiAct = tandiRef as Actor
            Topic helloTopTandi = Game.GetFormFromFile(0x00018001, "Vault13Chronicles.esp") as Topic
            If tandiAct != None && helloTopTandi != None && !tandiAct.IsTalking()
                tandiAct.Say(helloTopTandi, None, False, None)
            EndIf
        EndIf
    EndIf
EndEvent

Event OnTimer(int aiTimerID)
    If aiTimerID == 91
        Scene aradeshScene = Game.GetFormFromFile(0x00018100, "Vault13Chronicles.esp") as Scene
        Actor aradeshActor = Game.GetFormFromFile(0x000035A0, "Vault13Chronicles.esp") as Actor
        If aradeshScene != None && GetStage() == 15
            If aradeshScene.IsPlaying()
                Return
            ElseIf aradeshActor != None && aradeshActor.IsTalking() && sceneWaitTicks < 45
                sceneWaitTicks += 1
                StartTimer(0.35, 91)
            Else
                ForceAllTandiRescueAliases()
                aradeshScene.Start()
            EndIf
        EndIf
    ElseIf aiTimerID == 92
        Scene petroxScene = Game.GetFormFromFile(0x00018101, "Vault13Chronicles.esp") as Scene
        Actor petroxActor = Game.GetFormFromFile(0x000035D8, "Vault13Chronicles.esp") as Actor
        If petroxScene != None && GetStage() >= 15 && GetStage() < 26
            If petroxActor != None && (petroxActor.IsDead() || petroxActor.IsInCombat())
                Return
            ElseIf petroxScene.IsPlaying()
                Return
            ElseIf petroxActor != None && petroxActor.IsTalking() && sceneWaitTicks < 28
                sceneWaitTicks += 1
                StartTimer(0.35, 92)
            Else
                ForceAllTandiRescueAliases()
                petroxScene.Start()
            EndIf
        EndIf
    ElseIf aiTimerID == 94
        Scene aradeshSceneCheck = Game.GetFormFromFile(0x00018100, "Vault13Chronicles.esp") as Scene
        If aradeshSceneCheck != None && aradeshSceneCheck.IsPlaying()
            StartTimer(6.0, 94)
            Return
        EndIf
        If GetStage() == 15
            SetStage(20)
        EndIf
    ElseIf aiTimerID == 101
        int st = GetStage()
        If st < 15 || st >= 40
            Return
        EndIf

        Actor player = Game.GetPlayer()
        WorldSpace caliWorld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
        If player == None || caliWorld == None || player.GetWorldSpace() != caliWorld
            Return
        EndIf
        Actor petrox = Game.GetFormFromFile(0x000035D8, "Vault13Chronicles.esp") as Actor
        Actor tandi = Game.GetFormFromFile(0x000035A1, "Vault13Chronicles.esp") as Actor
        Form keyForm = Game.GetFormFromFile(0x0001459, "Vault13Chronicles.esp")

        If st >= 15 && st < 30
            If tandi != None && player.GetDistance(tandi) < 5500.0
                float dx = tandi.GetPositionX() - 10400.0
                float dy = tandi.GetPositionY() - 13580.0
                If (dx * dx + dy * dy) > 160000.0
                    tandi.SetPosition(10400.0, 13580.0, 206.0)
                EndIf
            EndIf

            If st == 15 && petrox != None && player.GetDistance(petrox) < 1600.0
                SetStage(20)
            EndIf

            If !bPetroxResolved && ((petrox != None && petrox.IsDead()) || (keyForm != None && player.GetItemCount(keyForm) > 0))
                bPetroxResolved = True
                SetStage(30)
                StartTimer(3.0, 101)
                Return
            EndIf
        ElseIf st == 30
            Actor aradesh = Game.GetFormFromFile(0x000035A0, "Vault13Chronicles.esp") as Actor
            If tandi != None && (player == None || player.GetDistance(tandi) > 1800.0 || (aradesh != None && player.GetDistance(aradesh) < 2400.0))
                If Math.Abs(tandi.GetPositionX() - 2550.0) > 400.0 || Math.Abs(tandi.GetPositionY() - 9690.0) > 400.0
                    ReturnTandiToShadySands()
                EndIf
            EndIf
        EndIf

        StartTimer(3.0, 101)
    EndIf
EndEvent

Event OnStageSet(int auiStageID, int auiItemID)
    If auiStageID == 15
        If bStg15Done
            Return
        EndIf
        bStg15Done = True
    ElseIf auiStageID == 20
        If bStg20Done
            Return
        EndIf
        bStg20Done = True
    ElseIf auiStageID == 26
        If bStg26Done
            Return
        EndIf
        bStg26Done = True
        bPetroxResolved = True
    ElseIf auiStageID == 27
        If bStg27Done
            Return
        EndIf
        bStg27Done = True
        bPetroxResolved = True
    ElseIf auiStageID == 28
        If bStg28Done
            Return
        EndIf
        bStg28Done = True
    ElseIf auiStageID == 29
        If bStg29Done
            Return
        EndIf
        bStg29Done = True
        bPetroxResolved = True
    ElseIf auiStageID == 30
        If bStg30Done
            Return
        EndIf
        bStg30Done = True
        bPetroxResolved = True
    ElseIf auiStageID == 40
        If bStg40Done
            Return
        EndIf
        bStg40Done = True
    EndIf

    SetupTandiRescueListeners()
    Actor player = Game.GetPlayer()

    If auiStageID == 15
        SetupCampActors(True)
        MoveTandiToCamp()
        If !Self.IsObjectiveDisplayed(15)
            Self.SetObjectiveDisplayed(15, True, False)
        EndIf

        Actor garl = Game.GetFormFromFile(0x00002559, "Vault13Chronicles.esp") as Actor
        If garl != None && garl.IsDead()
            Debug.Notification("¡Un comando superviviente de los Khans liderado por Petrox ha secuestrado a Tandi en venganza por la caida de Garl! Habla con Aradesh.")
        Else
            Debug.Notification("¡Incursores Khans han secuestrado a Tandi en Arenas Sombrías! Habla con Aradesh de inmediato.")
        EndIf
        Actor aradeshStageAct = Game.GetFormFromFile(0x000035A0, "Vault13Chronicles.esp") as Actor
        Topic helloTopStage = Game.GetFormFromFile(0x00018001, "Vault13Chronicles.esp") as Topic
        If aradeshStageAct != None && player != None && player.GetDistance(aradeshStageAct) < 1200.0 && helloTopStage != None
            If !aradeshStageAct.IsTalking()
                aradeshStageAct.Say(helloTopStage, None, False, None)
            EndIf
            sceneWaitTicks = 0
            StartTimer(3.2, 91)
            StartTimer(24.0, 94)
        EndIf
        StartTimer(3.0, 101)

    ElseIf auiStageID == 20
        SetupCampActors(True)
        MoveTandiToCamp()
        SetObjectiveCompleted(15, True)
        If !Self.IsObjectiveDisplayed(20)
            Self.SetObjectiveDisplayed(20, True, False)
        EndIf

        Form noteForm = Game.GetFormFromFile(0x0001C82, "Vault13Chronicles.esp")
        If noteForm != None && player.GetItemCount(noteForm) == 0
            player.AddItem(noteForm, 1, False)
        EndIf
        Debug.Notification("Dirigete al Campamento del Cañon de los Khans al noreste de Arenas Sombrías para rescatar a Tandi.")
        StartTimer(3.0, 101)

    ElseIf auiStageID == 26
        Actor garlCheck = Game.GetFormFromFile(0x00002559, "Vault13Chronicles.esp") as Actor
        Form keyForm1 = Game.GetFormFromFile(0x0001459, "Vault13Chronicles.esp")
        If keyForm1 != None && player.GetItemCount(keyForm1) == 0
            player.AddItem(keyForm1, 1, True)
        EndIf
        If garlCheck != None && garlCheck.IsDead()
            Debug.Notification("[Intimidacion Éxito] Al saber que abatiste a Garl Mano Muerta, Petrox cede y libera a Tandi sin luchar.")
        Else
            Debug.Notification("[Persuasion / Intimidacion Éxito] Convences a Petrox de que retener a Tandi destruira a su banda. Tandi queda libre.")
        EndIf
        Game.RewardPlayerXP(150)
        SetStage(30)

    ElseIf auiStageID == 27
        Form capsForm = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
        Form keyForm2 = Game.GetFormFromFile(0x0001459, "Vault13Chronicles.esp")
        If capsForm != None
            int currentCaps = player.GetItemCount(capsForm)
            If currentCaps >= 500
                player.RemoveItem(capsForm, 500, False)
                PaidRansom = True
                Debug.Notification("[Rescate Pagado: 500 chapas] Petrox acepta el pago y entrega la llave de la celda de Tandi.")
            ElseIf currentCaps > 0
                player.RemoveItem(capsForm, currentCaps, False)
                PaidRansom = True
                Debug.Notification("[Rescate Negociado: " + currentCaps + " chapas] Petrox acepta tus chapas y libera a Tandi.")
            Else
                PaidRansom = False
                Debug.Notification("[Negociacion Tensada] Sin chapas suficientes, intimidas a Petrox para que abra el cerrojo de Tandi.")
            EndIf
        EndIf
        If keyForm2 != None && player.GetItemCount(keyForm2) == 0
            player.AddItem(keyForm2, 1, True)
        EndIf
        Game.RewardPlayerXP(125)
        SetStage(30)

    ElseIf auiStageID == 28
        TriggerHostileKhanCamp()
        Debug.Notification("¡Combate en el Cañon de los Khans! Abate a Petrox o abre el cerrojo de retencion para liberar a Tandi.")
        StartTimer(2.0, 101)

    ElseIf auiStageID == 29
        Game.RewardPlayerXP(150)
        SetStage(30)

    ElseIf auiStageID == 30
        SetObjectiveCompleted(15, True)
        SetObjectiveCompleted(20, True)
        If !Self.IsObjectiveDisplayed(30)
            Self.SetObjectiveDisplayed(30, True, False)
        EndIf
        ObjectReference lockRef30 = Game.GetFormFromFile(0x000035DB, "Vault13Chronicles.esp") as ObjectReference
        If lockRef30 != None
            lockRef30.DisableNoWait()
        EndIf
        Actor tandiStage30 = Game.GetFormFromFile(0x000035A1, "Vault13Chronicles.esp") as Actor
        Actor aradeshStage30 = Game.GetFormFromFile(0x000035A0, "Vault13Chronicles.esp") as Actor
        If tandiStage30 != None
            tandiStage30.StopCombat()
            Topic helloTop30 = Game.GetFormFromFile(0x00018001, "Vault13Chronicles.esp") as Topic
            If player != None && player.GetDistance(tandiStage30) < 1800.0 && helloTop30 != None && !tandiStage30.IsTalking()
                tandiStage30.Say(helloTop30, None, False, None)
            EndIf
            If player == None || player.GetDistance(tandiStage30) > 1800.0 || (aradeshStage30 != None && player.GetDistance(aradeshStage30) < 2400.0)
                ReturnTandiToShadySands()
            EndIf
        EndIf
        Debug.Notification("¡Tandi esta a salvo y regresara a Arenas Sombrías! Habla con Aradesh para recibir tu recompensa.")
        StartTimer(3.0, 101)

    ElseIf auiStageID == 40
        SetObjectiveCompleted(15, True)
        SetObjectiveCompleted(20, True)
        SetObjectiveCompleted(30, True)
        ReturnTandiToShadySands()
        SetupCampActors(False)

        Form capsReward = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
        Form stimReward = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
        Form radAwayReward = Game.GetFormFromFile(0x00023742, "Fallout4.esm")
        Form ammo10mm = Game.GetFormFromFile(0x0001F276, "Fallout4.esm")
        Form spearWeapon = Game.GetFormFromFile(0x000913CA, "Fallout4.esm")

        int totalCaps = 600
        If PaidRansom
            totalCaps = 1100
        EndIf
        If capsReward != None
            player.AddItem(capsReward, totalCaps, False)
        EndIf
        If stimReward != None
            player.AddItem(stimReward, 4, False)
        EndIf
        If radAwayReward != None
            player.AddItem(radAwayReward, 2, False)
        EndIf
        If ammo10mm != None
            player.AddItem(ammo10mm, 36, False)
        EndIf
        If spearWeapon != None
            player.AddItem(spearWeapon, 1, False)
        EndIf

        Game.RewardPlayerXP(500)
        If PaidRansom
            Debug.Notification("Mision completada: El Rescate de Tandi (+1100 chapas incluyendo reembolso del rescate, suministros y +500 XP).")
        Else
            Debug.Notification("Mision completada: El Rescate de Tandi (+600 chapas, suministros de Arenas Sombrías y +500 XP).")
        EndIf
        CompleteAllObjectives()
        CompleteQuest()
    EndIf
EndEvent
