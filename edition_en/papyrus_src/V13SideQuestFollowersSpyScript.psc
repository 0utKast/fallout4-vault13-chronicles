Scriptname V13SideQuestFollowersSpyScript extends Quest

bool bStg20Notified = False
bool bStg25Notified = False
bool bStg30Notified = False
bool bRewardGranted = False
bool bTaliusGiftGranted = False
bool bCipherRecovered = False
bool bHeatherHostile = False
bool bSpyMenuBusy = False
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

bool Function AreFollowersSupportingCathedral()
    return Self.IsCompleted() || Self.GetStage() >= 40 || Self.IsStageDone(40) || bRewardGranted
EndFunction

Function ForceAllFollowersSpyAliases()
    ForceQuestAlias(12, 0x00003620)
    int stg = Self.GetStage()
    if Self.IsCompleted() || stg >= 40 || Self.IsStageDone(40) || bRewardGranted
        ClearQuestAlias(0)
        ClearQuestAlias(1)
        ClearQuestAlias(9)
        ClearQuestAlias(10)
        ClearQuestAlias(11)
        return
    endif
    ForceQuestAlias(0, 0x000035D6)
    ForceQuestAlias(2, 0x00003005)
    ForceQuestAlias(3, 0x00002003)
    ForceQuestAlias(4, 0x00003520)
    ForceQuestAlias(5, 0x00002101)
    ForceQuestAlias(6, 0x00003501)
    ForceQuestAlias(7, 0x00002206)
    ForceQuestAlias(8, 0x00002035)
    ForceQuestAlias(9, 0x00003626)
    ForceQuestAlias(10, 0x00003627)
    ForceQuestAlias(11, 0x00003632)
    if stg == 20
        ForceQuestAlias(1, 0x00003632)
    elseif stg == 25
        ForceQuestAlias(1, 0x00003627)
    elseif stg == 30
        ForceQuestAlias(1, 0x000035D6)
    endif
EndFunction

Function StopFollowersSpyScenes(int aiKeepSlot = 0)
    Scene nicoleScene = Game.GetFormFromFile(0x000D4100, "Vault13Chronicles.esp") as Scene
    Scene taliusScene = Game.GetFormFromFile(0x000D4101, "Vault13Chronicles.esp") as Scene
    Scene katjaScene = Game.GetFormFromFile(0x000D4102, "Vault13Chronicles.esp") as Scene
    Scene heatherScene = Game.GetFormFromFile(0x000D7600, "Vault13Chronicles.esp") as Scene
    if aiKeepSlot != 1 && nicoleScene != None && nicoleScene.IsPlaying()
        nicoleScene.Stop()
    endif
    if aiKeepSlot != 2 && taliusScene != None && taliusScene.IsPlaying()
        taliusScene.Stop()
    endif
    if aiKeepSlot != 3 && katjaScene != None && katjaScene.IsPlaying()
        katjaScene.Stop()
    endif
    if aiKeepSlot != 4 && heatherScene != None && heatherScene.IsPlaying()
        heatherScene.Stop()
    endif
EndFunction

Function StartKatjaLoreDialogue()
    bool wasDone = Self.IsCompleted() || Self.GetStage() >= 40 || Self.IsStageDone(40) || bRewardGranted
    bool wasGift = bTaliusGiftGranted
    if !Self.IsRunning()
        Self.Start()
    endif
    if wasDone
        bRewardGranted = True
        bTaliusGiftGranted = wasGift
        Self.CompleteAllObjectives()
        if !Self.IsCompleted()
            Self.CompleteQuest()
        endif
    endif
    ForceQuestAlias(12, 0x00003620)
    Actor katjaAct = Game.GetFormFromFile(0x00003620, "Vault13Chronicles.esp") as Actor
    StopFollowersSpyScenes(3)
    if katjaAct != None
        katjaAct.AllowPCDialogue(True)
    endif
    sceneWaitTicks = 0
    StartTimer(1.2, 93)
EndFunction

Function RefreshFollowersPlazaLayout()
    Actor pSpy = Game.GetPlayer()
    WorldSpace caliSpy = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if pSpy == None || caliSpy == None || pSpy.GetWorldSpace() != caliSpy
        return
    endif
    Faction playerFact = Game.GetFormFromFile(0x0001C21C, "Fallout4.esm") as Faction
    Actor taliusAct = Game.GetFormFromFile(0x00003626, "Vault13Chronicles.esp") as Actor
    if taliusAct != None && !taliusAct.IsDead() && taliusAct.Is3DLoaded()
        if !taliusAct.IsInCombat() && !taliusAct.IsTalking()
            if Math.Abs(taliusAct.GetPositionX() + 3200.0) > 55.0 || Math.Abs(taliusAct.GetPositionY() + 34900.0) > 55.0
                taliusAct.SetPosition(-3200.0, -34900.0, 40.0)
                taliusAct.SetAngle(0.0, 0.0, 45.0)
            endif
        endif
    endif
    Actor heatherAct = Game.GetFormFromFile(0x00003627, "Vault13Chronicles.esp") as Actor
    if heatherAct != None && !heatherAct.IsDead() && !heatherAct.IsDisabled()
        if !bHeatherHostile && heatherAct.Is3DLoaded()
            if playerFact != None && !heatherAct.IsInFaction(playerFact)
                heatherAct.AddToFaction(playerFact)
            endif
            if !heatherAct.IsInCombat() && !heatherAct.IsTalking()
                if Math.Abs(heatherAct.GetPositionX() + 1800.0) > 55.0 || Math.Abs(heatherAct.GetPositionY() + 33300.0) > 55.0
                    heatherAct.SetPosition(-1800.0, -33300.0, 40.0)
                    heatherAct.SetAngle(0.0, 0.0, 180.0)
                endif
            endif
        endif
    endif
    ObjectReference spyFootlocker = Game.GetFormFromFile(0x00003632, "Vault13Chronicles.esp") as ObjectReference
    if spyFootlocker != None
        if spyFootlocker.IsDisabled()
            spyFootlocker.EnableNoWait()
        endif
        if spyFootlocker.Is3DLoaded() && (Math.Abs(spyFootlocker.GetPositionX() + 1680.0) > 55.0 || Math.Abs(spyFootlocker.GetPositionY() + 33220.0) > 55.0)
            spyFootlocker.SetPosition(-1680.0, -33220.0, 40.0)
            spyFootlocker.SetAngle(0.0, 0.0, 0.0)
        endif
    endif
EndFunction

Function NotifyHeatherCipherRecovered()
    if bCipherRecovered || Self.IsCompleted() || Self.GetStage() >= 40 || Self.IsStageDone(40) || bRewardGranted
        return
    endif
    bCipherRecovered = True
    if !Self.IsRunning() && !Self.IsCompleted()
        Self.Start()
    endif
    if Self.GetStage() < 25
        Self.SetStage(25)
    endif
EndFunction

Function TurnHeatherHostile()
    bHeatherHostile = True
    Scene heatherStop = Game.GetFormFromFile(0x000D7600, "Vault13Chronicles.esp") as Scene
    if heatherStop != None && heatherStop.IsPlaying()
        heatherStop.Stop()
    endif
    Actor player = Game.GetPlayer()
    Actor heatherAct = Game.GetFormFromFile(0x00003627, "Vault13Chronicles.esp") as Actor
    Faction playerFact = Game.GetFormFromFile(0x0001C21C, "Fallout4.esm") as Faction
    ActorValue aggressionAV = Game.GetFormFromFile(0x000002BC, "Fallout4.esm") as ActorValue
    ActorValue confidenceAV = Game.GetFormFromFile(0x000002BD, "Fallout4.esm") as ActorValue
    if heatherAct != None && !heatherAct.IsDead()
        if playerFact != None && heatherAct.IsInFaction(playerFact)
            heatherAct.RemoveFromFaction(playerFact)
        endif
        if aggressionAV != None
            heatherAct.SetValue(aggressionAV, 2.0)
        endif
        if confidenceAV != None
            heatherAct.SetValue(confidenceAV, 4.0)
        endif
        if player != None && heatherAct.Is3DLoaded()
            heatherAct.StartCombat(player)
        endif
    endif
EndFunction

Function BindFollowersSpyListeners(bool abRefreshLayout = True)
    bool isDone = Self.IsCompleted() || Self.GetStage() >= 40 || Self.IsStageDone(40) || bRewardGranted
    if isDone
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
    Form cipherBase = Game.GetFormFromFile(0x00001563, "Vault13Chronicles.esp")
    if !Self.IsCompleted() && player != None && cipherBase != None && player.GetItemCount(cipherBase) > 0
        int curStg = Self.GetStage()
        if curStg >= 11 && curStg < 25
            bCipherRecovered = True
            Self.SetStage(25)
        endif
    endif
    ForceAllFollowersSpyAliases()
    if abRefreshLayout
        RefreshFollowersPlazaLayout()
    endif

    Self.RemoveAllInventoryEventFilters()
    if cipherBase != None
        Self.AddInventoryEventFilter(cipherBase)
    endif
    if player != None
        RegisterForRemoteEvent(player, "OnPlayerLoadGame")
        RegisterForRemoteEvent(player, "OnLocationChange")
        if cipherBase != None
            RegisterForRemoteEvent(player as ObjectReference, "OnItemAdded")
        endif
    endif

    ObjectReference nicoleRef = Game.GetFormFromFile(0x000035D6, "Vault13Chronicles.esp") as ObjectReference
    if nicoleRef != None
        RegisterForRemoteEvent(nicoleRef, "OnActivate")
    endif
    ObjectReference taliusRef = Game.GetFormFromFile(0x00003626, "Vault13Chronicles.esp") as ObjectReference
    if taliusRef != None
        RegisterForRemoteEvent(taliusRef, "OnActivate")
    endif
    Actor heatherAct = Game.GetFormFromFile(0x00003627, "Vault13Chronicles.esp") as Actor
    if heatherAct != None
        RegisterForRemoteEvent(heatherAct as ObjectReference, "OnActivate")
        RegisterForRemoteEvent(heatherAct, "OnDeath")
        RegisterForHitEvent(heatherAct)
    endif
EndFunction

Event OnInit()
    BindFollowersSpyListeners(False)
    Actor player = Game.GetPlayer()
    WorldSpace caliWorld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if player != None && caliWorld != None && player.GetWorldSpace() == caliWorld
        StartTimer(2.5, 98)
    endif
EndEvent

Event OnQuestInit()
    BindFollowersSpyListeners(False)
    Actor player = Game.GetPlayer()
    WorldSpace caliWorld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if player != None && caliWorld != None && player.GetWorldSpace() == caliWorld
        StartTimer(2.5, 98)
    endif
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
    BindFollowersSpyListeners(False)
    Actor player = Game.GetPlayer()
    WorldSpace caliWorld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if player != None && caliWorld != None && player.GetWorldSpace() == caliWorld
        StartTimer(2.5, 98)
    endif
EndEvent

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
    BindFollowersSpyListeners()
EndEvent

Event ObjectReference.OnItemAdded(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    Form cipherBase = Game.GetFormFromFile(0x00001563, "Vault13Chronicles.esp")
    if akBaseItem == cipherBase
        NotifyHeatherCipherRecovered()
    endif
EndEvent

Event OnHit(ObjectReference akTarget, ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked, string asMaterialName)
    Actor player = Game.GetPlayer()
    Actor aggAct = akAggressor as Actor
    bool isPlayerHit = (player != None && akAggressor == (player as ObjectReference)) || (aggAct != None && aggAct.IsPlayerTeammate())
    Actor heatherAct = Game.GetFormFromFile(0x00003627, "Vault13Chronicles.esp") as Actor
    if akTarget == heatherAct && isPlayerHit
        if Self.GetStage() < 20
            Self.SetStage(20)
        endif
        TurnHeatherHostile()
    elseif heatherAct != None && !heatherAct.IsDead()
        RegisterForHitEvent(heatherAct)
    endif
EndEvent

Event Actor.OnDeath(Actor akSender, Actor akKiller)
    Actor heatherAct = Game.GetFormFromFile(0x00003627, "Vault13Chronicles.esp") as Actor
    if akSender == heatherAct
        bHeatherHostile = True
        if Self.GetStage() < 30 && !Self.IsCompleted()
            Self.SetStage(30)
        endif
    endif
EndEvent

Event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
    if akActionRef != Game.GetPlayer() || bSpyMenuBusy
        return
    endif
    Actor player = Game.GetPlayer()
    ObjectReference nicoleRef = Game.GetFormFromFile(0x000035D6, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference taliusRef = Game.GetFormFromFile(0x00003626, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference heatherRef = Game.GetFormFromFile(0x00003627, "Vault13Chronicles.esp") as ObjectReference
    Form cipherBase = Game.GetFormFromFile(0x00001563, "Vault13Chronicles.esp")
    int stg = Self.GetStage()
    if Self.IsCompleted() || Self.IsStageDone(40) || bRewardGranted
        bRewardGranted = True
        stg = 40
    endif

    if akSender == nicoleRef
        if stg >= 40
            return
        elseif stg == 30 && !Self.IsCompleted()
            Self.SetStage(40)
            return
        elseif stg < 30 && !Self.IsCompleted()
            if stg < 20
                Self.SetStage(20)
            endif
            StopFollowersSpyScenes(1)
            sceneWaitTicks = 0
            StartTimer(1.2, 91)
        endif
    elseif akSender == taliusRef
        if !bTaliusGiftGranted && player != None
            bTaliusGiftGranted = True
            Form flamerW = Game.GetFormFromFile(0x000E5881, "Fallout4.esm")
            Form flamerAmmo = Game.GetFormFromFile(0x000CAC78, "Fallout4.esm")
            Form stim = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
            if flamerW != None
                player.AddItem(flamerW, 1, False)
            endif
            if flamerAmmo != None
                player.AddItem(flamerAmmo, 120, False)
            endif
            if stim != None
                player.AddItem(stim, 2, False)
            endif
            Game.RewardPlayerXP(200)
            Debug.Notification("Talius (Vault 13 survivor) entrusted his heavy Flamer and 120 fuel tanks to you! (+200 XP)")
        endif
        if stg < 20 && !Self.IsCompleted()
            Self.SetStage(20)
        endif
        StopFollowersSpyScenes(2)
        sceneWaitTicks = 0
        StartTimer(1.2, 92)
    elseif akSender == heatherRef
        Actor heatherAct = heatherRef as Actor
        if heatherAct == None || heatherAct.IsDead() || heatherAct.IsInCombat()
            return
        endif
        if stg < 20
            if stg < 12
                Self.SetStage(12)
            endif
            ForceQuestAlias(0, 0x000035D6)
            if !IsObjectiveDisplayed(12)
                SetObjectiveDisplayed(12, True, False)
                Self.SetActive(True)
            endif
            Debug.Notification("Heather: 'I'm checking the watch roster right now. If you're trying to help the Followers of the Apocalypse, talk to Nicole first.'")
            return
        endif
        if !Self.IsCompleted() && stg < 30 && !bHeatherHostile && (stg == 25 || bCipherRecovered || (cipherBase != None && player != None && player.GetItemCount(cipherBase) > 0))
            StopFollowersSpyScenes(4)
            ForceQuestAlias(10, 0x00003627)
            heatherAct.AllowPCDialogue(True)
            sceneWaitTicks = 0
            StartTimer(0.4, 95)
            return
        endif
    endif
EndEvent

Event OnTimer(int aiTimerID)
    if aiTimerID == 91
        Scene nicoleScene = Game.GetFormFromFile(0x000D4100, "Vault13Chronicles.esp") as Scene
        Actor nicoleAct = Game.GetFormFromFile(0x000035D6, "Vault13Chronicles.esp") as Actor
        if Self.IsRunning() && nicoleScene != None && Self.GetStage() < 40
            if Utility.IsInMenuMode() || (nicoleAct != None && (nicoleAct.IsInDialogueWithPlayer() || nicoleAct.IsTalking()))
                if sceneWaitTicks < 4
                    sceneWaitTicks += 1
                    StartTimer(0.4, 91)
                endif
            elseif !nicoleScene.IsPlaying()
                sceneWaitTicks = 0
                ForceAllFollowersSpyAliases()
                StopFollowersSpyScenes(1)
                nicoleScene.Start()
            endif
        endif
    elseif aiTimerID == 92
        Scene taliusScene = Game.GetFormFromFile(0x000D4101, "Vault13Chronicles.esp") as Scene
        Actor taliusAct = Game.GetFormFromFile(0x00003626, "Vault13Chronicles.esp") as Actor
        if Self.IsRunning() && taliusScene != None
            if Utility.IsInMenuMode() || (taliusAct != None && (taliusAct.IsInDialogueWithPlayer() || taliusAct.IsTalking()))
                if sceneWaitTicks < 4
                    sceneWaitTicks += 1
                    StartTimer(0.4, 92)
                endif
            elseif !taliusScene.IsPlaying()
                sceneWaitTicks = 0
                ForceAllFollowersSpyAliases()
                StopFollowersSpyScenes(2)
                taliusScene.Start()
            endif
        endif
    elseif aiTimerID == 93
        Scene katjaScene = Game.GetFormFromFile(0x000D4102, "Vault13Chronicles.esp") as Scene
        Actor katjaAct = Game.GetFormFromFile(0x00003620, "Vault13Chronicles.esp") as Actor
        if Self.IsRunning() && katjaScene != None
            if Utility.IsInMenuMode() || (katjaAct != None && (katjaAct.IsInDialogueWithPlayer() || katjaAct.IsTalking()))
                if sceneWaitTicks < 4
                    sceneWaitTicks += 1
                    StartTimer(0.4, 93)
                endif
            elseif !katjaScene.IsPlaying()
                sceneWaitTicks = 0
                ForceQuestAlias(12, 0x00003620)
                StopFollowersSpyScenes(3)
                katjaScene.Start()
            endif
        endif
    elseif aiTimerID == 95
        Scene heatherScene = Game.GetFormFromFile(0x000D7600, "Vault13Chronicles.esp") as Scene
        Actor heatherAct = Game.GetFormFromFile(0x00003627, "Vault13Chronicles.esp") as Actor
        if Self.IsRunning() && heatherScene != None && !Self.IsCompleted() && Self.GetStage() < 30 && !bHeatherHostile
            if Utility.IsInMenuMode() || (heatherAct != None && (heatherAct.IsInDialogueWithPlayer() || heatherAct.IsTalking()))
                if sceneWaitTicks < 4
                    sceneWaitTicks += 1
                    StartTimer(0.4, 95)
                endif
            elseif !heatherScene.IsPlaying() && heatherAct != None && !heatherAct.IsDead() && !heatherAct.IsInCombat()
                sceneWaitTicks = 0
                StopFollowersSpyScenes(4)
                ForceQuestAlias(10, 0x00003627)
                heatherAct.AllowPCDialogue(True)
                heatherScene.Start()
            endif
        endif
    elseif aiTimerID == 94
        Scene heatherStopT = Game.GetFormFromFile(0x000D7600, "Vault13Chronicles.esp") as Scene
        if heatherStopT != None && heatherStopT.IsPlaying()
            heatherStopT.Stop()
        endif
        Debug.Notification("Heather draws her weapon upon being exposed as a Children of the Cathedral spy.")
        TurnHeatherHostile()
    elseif aiTimerID == 98
        RefreshFollowersPlazaLayout()
    endif
EndEvent

Event OnStageSet(int auiStageID, int auiItemID)
    BindFollowersSpyListeners(False)
    Actor player = Game.GetPlayer()
    if auiStageID == 11
        if Self.GetStage() < 12 && !Self.IsCompleted()
            ForceQuestAlias(0, 0x000035D6)
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
        ForceQuestAlias(0, 0x000035D6)
        if !IsObjectiveDisplayed(12)
            SetObjectiveDisplayed(12, True, False)
            Self.SetActive(True)
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
        Form cipherBase = Game.GetFormFromFile(0x00001563, "Vault13Chronicles.esp")
        if cipherBase != None && player != None && player.GetItemCount(cipherBase) > 0
            Self.SetStage(25)
            return
        endif
        ForceQuestAlias(1, 0x00003632)
        if !IsObjectiveDisplayed(20)
            SetObjectiveDisplayed(20, True, False)
            Self.SetActive(True)
        endif
        if !bStg20Notified
            bStg20Notified = True
            Debug.Notification("Side Quest: The Followers' Spy - Speak with Talius and inspect the ledger footlocker beside the post.")
        endif
    elseif auiStageID == 25
        SetObjectiveCompleted(20, True)
        ForceQuestAlias(1, 0x00003627)
        if !IsObjectiveDisplayed(25)
            SetObjectiveDisplayed(25, True, False)
            Self.SetActive(True)
        endif
        if !bStg25Notified
            bStg25Notified = True
            Debug.Notification("The encrypted ledger exposes Heather as Morpheus's spy! Confront her at the Followers outpost.")
        endif
    elseif auiStageID == 26 || auiStageID == 27
        if !bHeatherHostile && !Self.IsCompleted()
            Form cipherRem = Game.GetFormFromFile(0x00001563, "Vault13Chronicles.esp")
            if cipherRem != None && player != None && player.GetItemCount(cipherRem) > 0
                player.RemoveItem(cipherRem, 1, True)
            endif
            Actor heatherTruce = Game.GetFormFromFile(0x00003627, "Vault13Chronicles.esp") as Actor
            if auiStageID == 26
                Form capsFs = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
                if capsFs != None && player != None
                    player.AddItem(capsFs, 300, False)
                endif
                Debug.Notification("You turned Heather into a double agent! She will feed false routes to Morpheus (+300 Caps). Report to Nicole.")
            else
                if heatherTruce != None
                    heatherTruce.DisableNoWait()
                endif
                Debug.Notification("You banished spy Heather from the Boneyard after confiscating her cipher keys. Report to Nicole.")
            endif
            Self.SetStage(30)
        endif
    elseif auiStageID == 28
        if !bHeatherHostile
            StartTimer(0.25, 94)
        endif
    elseif auiStageID == 30
        SetObjectiveCompleted(20, True)
        SetObjectiveCompleted(25, True)
        ForceQuestAlias(1, 0x000035D6)
        if !IsObjectiveDisplayed(30)
            SetObjectiveDisplayed(30, True, False)
            Self.SetActive(True)
        endif
        if !bStg30Notified
            bStg30Notified = True
            Debug.Notification("The Cathedral security leak has been neutralized. Report to Nicole in the Followers courtyard.")
        endif
    elseif auiStageID == 40
        SetObjectiveCompleted(20, True)
        SetObjectiveCompleted(25, True)
        SetObjectiveCompleted(30, True)
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
            Form radaway = Game.GetFormFromFile(0x00023742, "Fallout4.esm")
            if player != None
                if caps != None
                    player.AddItem(caps, 500, False)
                endif
                if stim != None
                    player.AddItem(stim, 3, False)
                endif
                if radaway != None
                    player.AddItem(radaway, 3, False)
                endif
            endif
            Game.RewardPlayerXP(450)
            Debug.Notification("Quest Completed: The Followers' Spy! Nicole gave you Laura's contact inside The Cathedral (+500 Caps and +450 XP).")
        endif
        Self.CompleteQuest()
    endif
EndEvent

Function SilentCompleteFollowersSpyForJump()
    bStg20Notified = True
    bStg25Notified = True
    bStg30Notified = True
    bRewardGranted = True
    bCipherRecovered = True
    if !Self.IsRunning() && !Self.IsCompleted()
        Self.Start()
    endif
    SetObjectiveDisplayed(11, False, False)
    SetObjectiveDisplayed(12, False, False)
    SetObjectiveDisplayed(20, False, False)
    SetObjectiveDisplayed(25, False, False)
    SetObjectiveDisplayed(30, False, False)
    ClearQuestAlias(0)
    ClearQuestAlias(1)
    ClearQuestAlias(9)
    ClearQuestAlias(10)
    ClearQuestAlias(11)
    Self.SetStage(40)
    Self.CompleteAllObjectives()
    Self.CompleteQuest()
EndFunction
