Scriptname V13SideQuestAdytumWarScript extends Quest

bool bStg20Notified = False
bool bStg25Notified = False
bool bStg30Notified = False
bool bStg35Notified = False
bool bRewardGranted = False
bool bHoloRecovered = False
bool bBladesArmed = False
bool bRegulatorsTurnedHostile = False
bool bRegulatorsPeacefulSurrender = False
bool bWarMenuBusy = False
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

Function ForceAllAdytumWarAliases()
    int stg = Self.GetStage()
    if Self.IsCompleted() || stg >= 40 || Self.IsStageDone(40) || bRewardGranted
        ClearQuestAlias(0)
        ClearQuestAlias(1)
        ClearQuestAlias(9)
        ClearQuestAlias(10)
        ClearQuestAlias(11)
        return
    endif
    ForceQuestAlias(0, 0x00003621)
    ForceQuestAlias(2, 0x00003005)
    ForceQuestAlias(3, 0x00002003)
    ForceQuestAlias(4, 0x00003520)
    ForceQuestAlias(5, 0x00002101)
    ForceQuestAlias(6, 0x00003501)
    ForceQuestAlias(7, 0x00002206)
    ForceQuestAlias(8, 0x00002035)
    ForceQuestAlias(9, 0x00003624)
    ForceQuestAlias(10, 0x00003622)
    ForceQuestAlias(11, 0x000035D4)
    if stg == 20
        ForceQuestAlias(1, 0x00003624)
    elseif stg == 25
        ForceQuestAlias(1, 0x00003621)
    elseif stg == 30
        Actor calebAct = Game.GetFormFromFile(0x00003622, "Vault13Chronicles.esp") as Actor
        if calebAct != None && !calebAct.IsDead()
            ForceQuestAlias(1, 0x00003622)
        else
            ForceQuestAlias(1, 0x00003623)
        endif
    elseif stg == 35
        ForceQuestAlias(1, 0x00003621)
    endif
EndFunction

bool Function IsAdytumLiberated()
    return Self.IsCompleted() || Self.GetStage() >= 40
EndFunction

bool Function AreBladesArmed()
    return bBladesArmed
EndFunction

Function StopAdytumWarScenes(int aiKeepSlot = 0)
    Scene zimmScene = Game.GetFormFromFile(0x000D2100, "Vault13Chronicles.esp") as Scene
    Scene razorScene = Game.GetFormFromFile(0x000D2101, "Vault13Chronicles.esp") as Scene
    Scene calebScene = Game.GetFormFromFile(0x000D7500, "Vault13Chronicles.esp") as Scene
    Scene gabrielScene = Game.GetFormFromFile(0x000D7700, "Vault13Chronicles.esp") as Scene
    if aiKeepSlot != 1 && zimmScene != None && zimmScene.IsPlaying()
        zimmScene.Stop()
    endif
    if aiKeepSlot != 2 && razorScene != None && razorScene.IsPlaying()
        razorScene.Stop()
    endif
    if aiKeepSlot != 3 && calebScene != None && calebScene.IsPlaying()
        calebScene.Stop()
    endif
    if aiKeepSlot != 4 && gabrielScene != None && gabrielScene.IsPlaying()
        gabrielScene.Stop()
    endif
EndFunction

Function RefreshAdytumWarLayout()
    Actor pWar = Game.GetPlayer()
    WorldSpace caliWar = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if pWar == None || caliWar == None || pWar.GetWorldSpace() != caliWar
        return
    endif
    Faction playerFact = Game.GetFormFromFile(0x0001C21C, "Fallout4.esm") as Faction
    Actor zimmAct = Game.GetFormFromFile(0x00003621, "Vault13Chronicles.esp") as Actor
    if zimmAct != None && !zimmAct.IsDead() && zimmAct.Is3DLoaded()
        if !zimmAct.IsInCombat() && !zimmAct.IsTalking()
            if Math.Abs(zimmAct.GetPositionX() + 6800.0) > 55.0 || Math.Abs(zimmAct.GetPositionY() + 33180.0) > 55.0
                zimmAct.SetPosition(-6800.0, -33180.0, 40.0)
                zimmAct.SetAngle(0.0, 0.0, 180.0)
            endif
        endif
    endif
    Actor razorAct = Game.GetFormFromFile(0x00003624, "Vault13Chronicles.esp") as Actor
    if razorAct != None && !razorAct.IsDead() && razorAct.Is3DLoaded()
        if !razorAct.IsInCombat() && !razorAct.IsTalking()
            if Math.Abs(razorAct.GetPositionX() - 2200.0) > 55.0 || Math.Abs(razorAct.GetPositionY() + 31600.0) > 55.0
                razorAct.SetPosition(2200.0, -31600.0, 40.0)
                razorAct.SetAngle(0.0, 0.0, 270.0)
            endif
        endif
    endif
    Actor calebAct = Game.GetFormFromFile(0x00003622, "Vault13Chronicles.esp") as Actor
    if calebAct != None && !calebAct.IsDead()
        if !bRegulatorsTurnedHostile && Self.GetStage() < 30
            if calebAct.Is3DLoaded() && playerFact != None && !calebAct.IsInFaction(playerFact)
                calebAct.AddToFaction(playerFact)
            endif
            if calebAct.Is3DLoaded() && !calebAct.IsInCombat() && !calebAct.IsTalking()
                if Math.Abs(calebAct.GetPositionX() + 8400.0) > 55.0 || Math.Abs(calebAct.GetPositionY() + 34650.0) > 55.0
                    calebAct.SetPosition(-8400.0, -34650.0, 40.0)
                    calebAct.SetAngle(0.0, 0.0, 45.0)
                endif
            endif
        endif
    endif
    Actor regGuardAct = Game.GetFormFromFile(0x00003623, "Vault13Chronicles.esp") as Actor
    if regGuardAct != None && !regGuardAct.IsDead()
        if !bRegulatorsTurnedHostile && Self.GetStage() < 30
            if regGuardAct.Is3DLoaded() && playerFact != None && !regGuardAct.IsInFaction(playerFact)
                regGuardAct.AddToFaction(playerFact)
            endif
            if regGuardAct.Is3DLoaded() && !regGuardAct.IsInCombat()
                if Math.Abs(regGuardAct.GetPositionX() + 8220.0) > 55.0 || Math.Abs(regGuardAct.GetPositionY() + 34520.0) > 55.0
                    regGuardAct.SetPosition(-8220.0, -34520.0, 40.0)
                    regGuardAct.SetAngle(0.0, 0.0, 45.0)
                endif
            endif
        endif
    endif
EndFunction

Function TurnRegulatorsHostile()
    bRegulatorsTurnedHostile = True
    Scene calebStop = Game.GetFormFromFile(0x000D7500, "Vault13Chronicles.esp") as Scene
    if calebStop != None && calebStop.IsPlaying()
        calebStop.Stop()
    endif
    Actor player = Game.GetPlayer()
    Faction playerFact = Game.GetFormFromFile(0x0001C21C, "Fallout4.esm") as Faction
    ActorValue aggressionAV = Game.GetFormFromFile(0x000002BC, "Fallout4.esm") as ActorValue
    ActorValue confidenceAV = Game.GetFormFromFile(0x000002BD, "Fallout4.esm") as ActorValue
    Actor calebAct = Game.GetFormFromFile(0x00003622, "Vault13Chronicles.esp") as Actor
    Actor regGuardAct = Game.GetFormFromFile(0x00003623, "Vault13Chronicles.esp") as Actor
    if calebAct != None && !calebAct.IsDead()
        if playerFact != None && calebAct.IsInFaction(playerFact)
            calebAct.RemoveFromFaction(playerFact)
        endif
        if aggressionAV != None
            calebAct.SetValue(aggressionAV, 2.0)
        endif
        if confidenceAV != None
            calebAct.SetValue(confidenceAV, 4.0)
        endif
        if player != None && calebAct.Is3DLoaded()
            calebAct.StartCombat(player)
        endif
    endif
    if regGuardAct != None && !regGuardAct.IsDead()
        if playerFact != None && regGuardAct.IsInFaction(playerFact)
            regGuardAct.RemoveFromFaction(playerFact)
        endif
        if aggressionAV != None
            regGuardAct.SetValue(aggressionAV, 2.0)
        endif
        if confidenceAV != None
            regGuardAct.SetValue(confidenceAV, 4.0)
        endif
        if player != None && regGuardAct.Is3DLoaded()
            regGuardAct.StartCombat(player)
        endif
    endif
    if Self.GetStage() < 30
        Self.SetStage(30)
    else
        CheckRegulatorsDefeated()
    endif
EndFunction

Function CheckRegulatorsDefeated()
    if Self.IsCompleted() || Self.GetStage() >= 35
        return
    endif
    Actor calebAct = Game.GetFormFromFile(0x00003622, "Vault13Chronicles.esp") as Actor
    Actor regGuardAct = Game.GetFormFromFile(0x00003623, "Vault13Chronicles.esp") as Actor
    bool calebDown = (calebAct == None || calebAct.IsDead())
    bool guardDown = (regGuardAct == None || regGuardAct.IsDead())
    if bRegulatorsPeacefulSurrender || (calebDown && guardDown)
        Self.SetStage(35)
    elseif Self.GetStage() == 30
        ForceAllAdytumWarAliases()
    endif
EndFunction

Function GrantBladesWeapons()
    if bBladesArmed
        return
    endif
    bBladesArmed = True
    Actor razorAct = Game.GetFormFromFile(0x00003624, "Vault13Chronicles.esp") as Actor
    Form wLaser = Game.GetFormFromFile(0x0009983B, "Fallout4.esm")
    Form aCell = Game.GetFormFromFile(0x000C1897, "Fallout4.esm")
    if razorAct != None && !razorAct.IsDead()
        if wLaser != None && razorAct.GetItemCount(wLaser) == 0
            razorAct.AddItem(wLaser, 1, True)
            razorAct.EquipItem(wLaser, False, True)
        endif
        if aCell != None && razorAct.GetItemCount(aCell) < 40
            razorAct.AddItem(aCell, 60, True)
        endif
    endif
    if IsObjectiveDisplayed(26)
        SetObjectiveCompleted(26, True)
    endif
    Game.RewardPlayerXP(200)
    Debug.Notification("Gabriel and the Gun Runners have armed Razor and the Blades to liberate Adytum! (+200 XP)")
EndFunction

Function HandleGabrielBladesSupply()
    if bWarMenuBusy
        return
    endif
    if Self.IsCompleted() || Self.GetStage() >= 40 || Self.IsStageDone(40) || bRewardGranted
        Debug.Notification("Gabriel: 'Adytum is free at last, and our caravans with the Blades move toll-free.'")
        return
    endif
    if bBladesArmed
        Debug.Notification("Gabriel: 'My crates of laser rifles are already in the hands of Razor and the Blades.'")
        return
    endif
    Quest motherQ = Game.GetFormFromFile(0x00014000, "Vault13Chronicles.esp") as Quest
    if motherQ != None && (motherQ.IsCompleted() || motherQ.GetStage() >= 30)
        GrantBladesWeapons()
        return
    endif
    if !Self.IsRunning()
        Self.Start()
    endif
    Scene gabrielBySc = Game.GetFormFromFile(0x00014100, "Vault13Chronicles.esp") as Scene
    if gabrielBySc != None && gabrielBySc.IsPlaying()
        gabrielBySc.Stop()
    endif
    StopAdytumWarScenes(4)
    ForceQuestAlias(11, 0x000035D4)
    Actor gabrielAct = Game.GetFormFromFile(0x000035D4, "Vault13Chronicles.esp") as Actor
    if gabrielAct != None
        gabrielAct.AllowPCDialogue(True)
    endif
    sceneWaitTicks = 0
    StartTimer(0.25, 93)
EndFunction

Function NotifyCalebHoloRecovered()
    if bHoloRecovered || Self.IsCompleted() || Self.GetStage() >= 40 || Self.IsStageDone(40) || bRewardGranted
        return
    endif
    bHoloRecovered = True
    if !Self.IsRunning() && !Self.IsCompleted()
        Self.Start()
    endif
    if Self.GetStage() < 25
        Self.SetStage(25)
    endif
EndFunction

Function BindAdytumWarListeners(bool abRefreshLayout = True)
    if Self.IsCompleted() || Self.GetStage() >= 40 || Self.IsStageDone(40) || bRewardGranted
        bRewardGranted = True
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
    Form holoBase = Game.GetFormFromFile(0x00001560, "Vault13Chronicles.esp")
    if !Self.IsCompleted() && player != None && holoBase != None && player.GetItemCount(holoBase) > 0
        int curStg = Self.GetStage()
        if curStg >= 11 && curStg < 25
            bHoloRecovered = True
            Self.SetStage(25)
        endif
    endif
    ForceAllAdytumWarAliases()
    if abRefreshLayout
        RefreshAdytumWarLayout()
    endif

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

    ObjectReference zimmRef = Game.GetFormFromFile(0x00003621, "Vault13Chronicles.esp") as ObjectReference
    if zimmRef != None
        RegisterForRemoteEvent(zimmRef, "OnActivate")
    endif
    ObjectReference razorRef = Game.GetFormFromFile(0x00003624, "Vault13Chronicles.esp") as ObjectReference
    if razorRef != None
        RegisterForRemoteEvent(razorRef, "OnActivate")
    endif
    Actor calebAct = Game.GetFormFromFile(0x00003622, "Vault13Chronicles.esp") as Actor
    if calebAct != None
        RegisterForRemoteEvent(calebAct as ObjectReference, "OnActivate")
        RegisterForRemoteEvent(calebAct, "OnDeath")
        RegisterForHitEvent(calebAct)
    endif
    Actor regGuardAct = Game.GetFormFromFile(0x00003623, "Vault13Chronicles.esp") as Actor
    if regGuardAct != None
        RegisterForRemoteEvent(regGuardAct as ObjectReference, "OnActivate")
        RegisterForRemoteEvent(regGuardAct, "OnDeath")
        RegisterForHitEvent(regGuardAct)
    endif
    if Self.GetStage() == 30
        CheckRegulatorsDefeated()
    endif
EndFunction

Event OnInit()
    BindAdytumWarListeners(False)
    Actor player = Game.GetPlayer()
    WorldSpace caliWorld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if player != None && caliWorld != None && player.GetWorldSpace() == caliWorld
        StartTimer(2.5, 98)
    endif
EndEvent

Event OnQuestInit()
    BindAdytumWarListeners(False)
    Actor player = Game.GetPlayer()
    WorldSpace caliWorld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if player != None && caliWorld != None && player.GetWorldSpace() == caliWorld
        StartTimer(2.5, 98)
    endif
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
    BindAdytumWarListeners(False)
    Actor player = Game.GetPlayer()
    WorldSpace caliWorld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if player != None && caliWorld != None && player.GetWorldSpace() == caliWorld
        StartTimer(2.5, 98)
    endif
EndEvent

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
    BindAdytumWarListeners()
EndEvent

Event ObjectReference.OnItemAdded(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    Form holoBase = Game.GetFormFromFile(0x00001560, "Vault13Chronicles.esp")
    if akBaseItem == holoBase
        NotifyCalebHoloRecovered()
    endif
EndEvent

Event OnHit(ObjectReference akTarget, ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked, string asMaterialName)
    Actor player = Game.GetPlayer()
    Actor aggAct = akAggressor as Actor
    bool isPlayerHit = (player != None && akAggressor == (player as ObjectReference)) || (aggAct != None && aggAct.IsPlayerTeammate())
    Actor calebAct = Game.GetFormFromFile(0x00003622, "Vault13Chronicles.esp") as Actor
    Actor regGuardAct = Game.GetFormFromFile(0x00003623, "Vault13Chronicles.esp") as Actor
    if isPlayerHit && (akTarget == calebAct || akTarget == regGuardAct)
        if Self.GetStage() < 20
            Self.SetStage(20)
        endif
        TurnRegulatorsHostile()
    else
        if calebAct != None && !calebAct.IsDead()
            RegisterForHitEvent(calebAct)
        endif
        if regGuardAct != None && !regGuardAct.IsDead()
            RegisterForHitEvent(regGuardAct)
        endif
    endif
EndEvent

Event Actor.OnDeath(Actor akSender, Actor akKiller)
    Actor calebAct = Game.GetFormFromFile(0x00003622, "Vault13Chronicles.esp") as Actor
    Actor regGuardAct = Game.GetFormFromFile(0x00003623, "Vault13Chronicles.esp") as Actor
    if akSender == calebAct || akSender == regGuardAct
        bRegulatorsTurnedHostile = True
        if Self.GetStage() < 30
            Self.SetStage(30)
        endif
        CheckRegulatorsDefeated()
    endif
EndEvent

Event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
    if akActionRef != Game.GetPlayer() || bWarMenuBusy
        return
    endif
    Actor player = Game.GetPlayer()
    ObjectReference zimmRef = Game.GetFormFromFile(0x00003621, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference calebRef = Game.GetFormFromFile(0x00003622, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference regGuardRef = Game.GetFormFromFile(0x00003623, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference razorRef = Game.GetFormFromFile(0x00003624, "Vault13Chronicles.esp") as ObjectReference
    Form holoBase = Game.GetFormFromFile(0x00001560, "Vault13Chronicles.esp")
    int stg = Self.GetStage()
    if Self.IsCompleted() || Self.IsStageDone(40) || bRewardGranted
        bRewardGranted = True
        stg = 40
    endif

    if akSender == zimmRef
        if stg == 35 && !Self.IsCompleted()
            Self.SetStage(40)
            return
        elseif stg == 25 || (holoBase != None && player != None && player.GetItemCount(holoBase) > 0 && stg < 30)
            StopAdytumWarScenes(0)
            if holoBase != None && player != None && player.GetItemCount(holoBase) > 0
                player.RemoveItem(holoBase, 1, True)
            endif
            Debug.Notification("Mayor Zimmerman: 'My God... Caleb murdered my own son Josh! Guards, wipe out the Regulators!'")
            TurnRegulatorsHostile()
            return
        elseif stg < 25
            if stg < 20
                Self.SetStage(20)
            endif
            StopAdytumWarScenes(1)
            sceneWaitTicks = 0
            StartTimer(0.4, 91)
            return
        endif
    elseif akSender == razorRef
        if stg < 20
            if stg < 12
                Self.SetStage(12)
            endif
            ForceQuestAlias(0, 0x00003621)
            if !IsObjectiveDisplayed(12)
                SetObjectiveDisplayed(12, True, False)
                Self.SetActive(True)
            endif
            Debug.Notification("Razor: 'I don't trust strangers walking out of Caleb's gates. Go speak with Mayor Jon Zimmerman in Adytum first.'")
            return
        endif
        if stg == 35 && !Self.IsCompleted()
            Self.SetStage(40)
            return
        endif
        if holoBase != None && player != None && player.GetItemCount(holoBase) == 0 && !bHoloRecovered
            player.AddItem(holoBase, 1, False)
            NotifyCalebHoloRecovered()
        elseif stg < 25
            Self.SetStage(25)
        endif
        StopAdytumWarScenes(2)
        if Self.GetStage() < 35
            sceneWaitTicks = 0
            StartTimer(0.4, 92)
        endif
    elseif akSender == calebRef
        Actor calebAct = calebRef as Actor
        if calebAct != None && !calebAct.IsDead() && !calebAct.IsInCombat()
            if stg < 20
                if stg < 12
                    Self.SetStage(12)
                endif
                ForceQuestAlias(0, 0x00003621)
                if !IsObjectiveDisplayed(12)
                    SetObjectiveDisplayed(12, True, False)
                    Self.SetActive(True)
                endif
                Debug.Notification("Caleb: 'Move along, stranger. Official town business in Adytum goes through Mayor Jon Zimmerman.'")
                return
            endif
            if !bRegulatorsTurnedHostile && !bRegulatorsPeacefulSurrender && stg < 35 && (stg >= 25 || bHoloRecovered || (holoBase != None && player != None && player.GetItemCount(holoBase) > 0))
                StopAdytumWarScenes(3)
                ForceQuestAlias(10, 0x00003622)
                calebAct.AllowPCDialogue(True)
                sceneWaitTicks = 0
                StartTimer(0.4, 95)
                return
            endif
        endif
    elseif regGuardRef != None && akSender == regGuardRef
        Actor regAct = regGuardRef as Actor
        if regAct != None && !regAct.IsDead() && !regAct.IsInCombat()
            if stg < 20
                if stg < 12
                    Self.SetStage(12)
                endif
                ForceQuestAlias(0, 0x00003621)
                if !IsObjectiveDisplayed(12)
                    SetObjectiveDisplayed(12, True, False)
                    Self.SetActive(True)
                endif
                Debug.Notification("Regulator: 'If you have business in Adytum, take it straight to Mayor Jon Zimmerman.'")
            else
                Debug.Notification("Regulator: 'Caleb and the Regulators run things here. Talk to him by the gate.'")
            endif
        endif
    endif
EndEvent

Event OnTimer(int aiTimerID)
    if aiTimerID == 91
        Scene zimmScene = Game.GetFormFromFile(0x000D2100, "Vault13Chronicles.esp") as Scene
        Actor zimmAct = Game.GetFormFromFile(0x00003621, "Vault13Chronicles.esp") as Actor
        if Self.IsRunning() && zimmScene != None && Self.GetStage() < 25
            if Utility.IsInMenuMode() || (zimmAct != None && (zimmAct.IsInDialogueWithPlayer() || zimmAct.IsTalking()))
                if sceneWaitTicks < 4
                    sceneWaitTicks += 1
                    StartTimer(0.4, 91)
                endif
            elseif !zimmScene.IsPlaying()
                sceneWaitTicks = 0
                ForceAllAdytumWarAliases()
                StopAdytumWarScenes(1)
                zimmScene.Start()
            endif
        endif
    elseif aiTimerID == 92
        Scene razorScene = Game.GetFormFromFile(0x000D2101, "Vault13Chronicles.esp") as Scene
        Actor razorAct = Game.GetFormFromFile(0x00003624, "Vault13Chronicles.esp") as Actor
        if Self.IsRunning() && razorScene != None && Self.GetStage() < 35
            if Utility.IsInMenuMode() || (razorAct != None && (razorAct.IsInDialogueWithPlayer() || razorAct.IsTalking()))
                if sceneWaitTicks < 4
                    sceneWaitTicks += 1
                    StartTimer(0.4, 92)
                endif
            elseif !razorScene.IsPlaying()
                sceneWaitTicks = 0
                ForceAllAdytumWarAliases()
                StopAdytumWarScenes(2)
                razorScene.Start()
            endif
        endif
    elseif aiTimerID == 93
        Scene gabrielSupSc = Game.GetFormFromFile(0x000D7700, "Vault13Chronicles.esp") as Scene
        Actor gabrielActT = Game.GetFormFromFile(0x000035D4, "Vault13Chronicles.esp") as Actor
        if Self.IsRunning() && gabrielSupSc != None && !bBladesArmed && Self.GetStage() < 40
            if Utility.IsInMenuMode() && sceneWaitTicks < 12
                sceneWaitTicks += 1
                StartTimer(0.35, 93)
            elseif !gabrielSupSc.IsPlaying() && !Utility.IsInMenuMode() && (gabrielActT == None || (!gabrielActT.IsInDialogueWithPlayer() && !gabrielActT.IsTalking()))
                sceneWaitTicks = 0
                ForceAllAdytumWarAliases()
                StopAdytumWarScenes(4)
                ForceQuestAlias(11, 0x000035D4)
                if gabrielActT != None
                    gabrielActT.AllowPCDialogue(True)
                endif
                gabrielSupSc.Start()
            endif
        endif
    elseif aiTimerID == 95
        Scene calebScene = Game.GetFormFromFile(0x000D7500, "Vault13Chronicles.esp") as Scene
        Actor calebAct = Game.GetFormFromFile(0x00003622, "Vault13Chronicles.esp") as Actor
        if Self.IsRunning() && calebScene != None && !bRegulatorsTurnedHostile && !bRegulatorsPeacefulSurrender && Self.GetStage() < 35
            if Utility.IsInMenuMode() || (calebAct != None && (calebAct.IsInDialogueWithPlayer() || calebAct.IsTalking()))
                if sceneWaitTicks < 4
                    sceneWaitTicks += 1
                    StartTimer(0.4, 95)
                endif
            elseif !calebScene.IsPlaying() && calebAct != None && !calebAct.IsDead() && !calebAct.IsInCombat()
                sceneWaitTicks = 0
                StopAdytumWarScenes(3)
                ForceQuestAlias(10, 0x00003622)
                calebAct.AllowPCDialogue(True)
                calebScene.Start()
            endif
        endif
    elseif aiTimerID == 94
        Scene calebStopT = Game.GetFormFromFile(0x000D7500, "Vault13Chronicles.esp") as Scene
        if calebStopT != None && calebStopT.IsPlaying()
            calebStopT.Stop()
        endif
        TurnRegulatorsHostile()
    elseif aiTimerID == 98
        RefreshAdytumWarLayout()
    endif
EndEvent

Event OnStageSet(int auiStageID, int auiItemID)
    BindAdytumWarListeners(False)
    Actor player = Game.GetPlayer()
    if auiStageID == 11
        if Self.GetStage() < 12 && !Self.IsCompleted()
            ForceQuestAlias(0, 0x00003621)
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
        ForceQuestAlias(0, 0x00003621)
        if !IsObjectiveDisplayed(12)
            SetObjectiveDisplayed(12, True, False)
            Self.SetActive(True)
        endif
    elseif auiStageID == 16 || auiStageID == 17
        if IsObjectiveDisplayed(11)
            SetObjectiveCompleted(11, True)
            SetObjectiveDisplayed(11, False, False)
        endif
        if IsObjectiveDisplayed(12)
            SetObjectiveCompleted(12, True)
            SetObjectiveDisplayed(12, False, False)
        endif
        if !bBladesArmed
            if auiStageID == 17
                Form capsGab = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
                if capsGab != None && player != None && player.GetItemCount(capsGab) >= 500
                    player.RemoveItem(capsGab, 500, False)
                endif
            endif
            GrantBladesWeapons()
        endif
    elseif auiStageID == 26 || auiStageID == 27
        if !bRegulatorsPeacefulSurrender && !bRegulatorsTurnedHostile
            bRegulatorsPeacefulSurrender = True
            Form holoRem = Game.GetFormFromFile(0x00001560, "Vault13Chronicles.esp")
            if holoRem != None && player != None && player.GetItemCount(holoRem) > 0
                player.RemoveItem(holoRem, 1, True)
            endif
            Self.SetStage(35)
            if auiStageID == 26
                Debug.Notification("[Speech] Exposed before all of Adytum, Caleb lays down his weapon and the Regulators surrender without bloodshed.")
            else
                Debug.Notification("[Intimidation] Cowed by your presence, Caleb drops his shotgun and orders the Regulators out of Adytum.")
            endif
        endif
    elseif auiStageID == 28
        if !bRegulatorsTurnedHostile
            StartTimer(0.25, 94)
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
        ObjectReference mapMarker = Game.GetFormFromFile(0x00003420, "Vault13Chronicles.esp") as ObjectReference
        if mapMarker != None
            mapMarker.EnableNoWait()
            mapMarker.AddToMap(True)
        endif
        ForceQuestAlias(1, 0x00003624)
        if !IsObjectiveDisplayed(20)
            SetObjectiveDisplayed(20, True, False)
            Self.SetActive(True)
        endif
        if !bStg20Notified
            bStg20Notified = True
            Debug.Notification("Side Quest: The Adytum Civil War - Speak with Razor and the Blades in the eastern Boneyard ruin.")
        endif
    elseif auiStageID == 25
        SetObjectiveCompleted(20, True)
        ForceQuestAlias(1, 0x00003621)
        if !IsObjectiveDisplayed(25)
            SetObjectiveDisplayed(25, True, False)
            Self.SetActive(True)
        elseif !bBladesArmed && !IsObjectiveDisplayed(26)
            Self.SetActive(True)
        endif
        if !bBladesArmed && !IsObjectiveDisplayed(26)
            SetObjectiveDisplayed(26, True, False)
        endif
        if !bStg25Notified
            bStg25Notified = True
            Debug.Notification("Razor handed you the Holodisk of truth. Show it to Mayor Zimmerman or request weapons from Gabriel.")
        endif
    elseif auiStageID == 30
        SetObjectiveCompleted(20, True)
        SetObjectiveCompleted(25, True)
        if IsObjectiveDisplayed(26) && !bBladesArmed
            SetObjectiveDisplayed(26, False, False)
        endif
        ForceAllAdytumWarAliases()
        if !IsObjectiveDisplayed(30)
            SetObjectiveDisplayed(30, True, False)
            Self.SetActive(True)
        endif
        if !bStg30Notified
            bStg30Notified = True
            Debug.Notification("Caleb and the Regulators have been unmasked! Defeat them to liberate Adytum.")
        endif
        CheckRegulatorsDefeated()
    elseif auiStageID == 35
        SetObjectiveCompleted(20, True)
        SetObjectiveCompleted(25, True)
        SetObjectiveCompleted(30, True)
        ForceQuestAlias(1, 0x00003621)
        if !IsObjectiveDisplayed(35)
            SetObjectiveDisplayed(35, True, False)
            Self.SetActive(True)
        endif
        if !bStg35Notified
            bStg35Notified = True
            Debug.Notification("The Regulators have fallen! Report Adytum's liberation to Mayor Zimmerman or Razor.")
        endif
    elseif auiStageID == 40
        SetObjectiveCompleted(20, True)
        SetObjectiveCompleted(25, True)
        SetObjectiveCompleted(30, True)
        SetObjectiveCompleted(35, True)
        Self.CompleteAllObjectives()
        ClearQuestAlias(0)
        ClearQuestAlias(1)
        ClearQuestAlias(9)
        ClearQuestAlias(10)
        ClearQuestAlias(11)
        if !bRewardGranted
            bRewardGranted = True
            Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
            Form stim = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
            if player != None
                if caps != None
                    player.AddItem(caps, 750, False)
                endif
                if stim != None
                    player.AddItem(stim, 4, False)
                endif
            endif
            Game.RewardPlayerXP(500)
            Debug.Notification("Quest Completed: The Adytum Civil War! Adytum and the Blades have united in peace (+750 Caps and +500 XP).")
        endif
        Self.CompleteQuest()
    endif
EndEvent
