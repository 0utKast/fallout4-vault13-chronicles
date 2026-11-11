Scriptname V13Act1QuestScript extends Quest

int hitCounter = 0
bool introShown = false
bool rewardsGiven = false
bool suitGiven = false
bool bunkerVisited = false
bool portalActivated = false
bool portalMenuClicked = false
bool mapMarkerShown = false
bool mapMarkerFastTravelEnabled = false
bool v13CorridorPopulated = false
bool v15BannerShown = false
bool v15CellRefreshed = false
bool exteriorInitialized = false
bool v15StateInitialized = false
int lastSpokenResidentIdx = -1
int longMonologueResidentIdx = -1
int playerStoppedTicks = 0
bool isPlayingLongMonologue = false
bool isPlayingShortHelo = false
int pendingActivateResidentIdx = -1
int silencedResidentIdx = -1
bool residentTimerActive = false
bool v15BarracksTermLockApplied = false
bool v15BarracksDoorsOpened = false
bool hydroCoreAnalyzedInTerm = false
bool hydroCoreWalkActive = false
int hydroCoreWalkStep = 0
bool worldMap2161Synced = false
bool worldMapSyncInProgress = false
bool visitedV13 = false
bool visitedShadyPass = false
bool visitedV15 = false
bool visitedNecroSub = false
bool visitedHallDead = false
bool visitedNecroSewers = false
bool visitedV12Watershed = false
bool visitedLostHills = false
bool visitedMariposa = false
bool visitedCathedral = false
bool bApplyingAct1Stage = false
int lastAppliedAct1Stage = 0
bool lastAppliedPortalClicked = false
bool lastAppliedLeftV13 = false
bool introCheckBusy = false
bool bAnalyzingHydroCore = false
bool bMenuReturnBusy = false
bool v15ArmoryUnlocked = false
bool v15CmdUnlocked = false

Function SilenceResidentActor(Actor akRes)
    if akRes == None
        return
    endif
    Topic stopTopic = Game.GetFormFromFile(0x00004003, "Vault13Chronicles.esp") as Topic
    if stopTopic != None
        akRes.Say(stopTopic, None, false, None)
    endif
EndFunction

Function PlayResidentFullMonologue(Actor akRes, int aiResIdx)
    Actor player = Game.GetPlayer()
    if akRes == None || player == None || IsJacorenInDialogueOrScene()
        return
    endif
    Quest q2 = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as Quest
    Quest q3 = Game.GetFormFromFile(0x00006000, "Vault13Chronicles.esp") as Quest
    int q2Stg = 0
    if q2 != None
        q2Stg = q2.GetStage()
    endif
    int q3Stg = 0
    if q3 != None
        q3Stg = q3.GetStage()
    endif

    if aiResIdx == 3 && q2Stg >= 15 && q2Stg < 20
        return
    endif

    int oIdx = 0
    while oIdx < 8
        if oIdx != aiResIdx
            if !(oIdx == 3 && q2Stg >= 15 && q2Stg < 20)
                Actor oAct = Game.GetFormFromFile(0x00002150 + oIdx, "Vault13Chronicles.esp") as Actor
                if oAct != None && oAct.IsTalking()
                    SilenceResidentActor(oAct)
                endif
            endif
        endif
        oIdx += 1
    endwhile

    Topic fullTopic = None
    if (aiResIdx == 0 || aiResIdx == 2 || aiResIdx == 3) && q2Stg >= 15 && q3Stg < 20
        fullTopic = Game.GetFormFromFile(0x00005001, "Vault13Chronicles.esp") as Topic
    else
        fullTopic = Game.GetFormFromFile(0x00004001, "Vault13Chronicles.esp") as Topic
    endif

    if fullTopic != None
        lastSpokenResidentIdx = aiResIdx
        longMonologueResidentIdx = aiResIdx
        isPlayingLongMonologue = true
        isPlayingShortHelo = false
        playerStoppedTicks = 10
        akRes.SetLookAt(player, false)
        akRes.Say(fullTopic, None, false, player)
    endif
EndFunction

Function UpdateVault13ResidentMonologues()
    Actor player = Game.GetPlayer()
    Cell v13Cell = Game.GetFormFromFile(0x00002100, "Vault13Chronicles.esp") as Cell
    if player == None || v13Cell == None || player.GetParentCell() != v13Cell
        lastSpokenResidentIdx = -1
        longMonologueResidentIdx = -1
        playerStoppedTicks = 0
        isPlayingLongMonologue = false
        isPlayingShortHelo = false
        silencedResidentIdx = -1
        return
    endif

    Quest q2 = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as Quest
    Quest q3 = Game.GetFormFromFile(0x00006000, "Vault13Chronicles.esp") as Quest
    int q2Stg = 0
    if q2 != None
        q2Stg = q2.GetStage()
    endif
    int q3Stg = 0
    if q3 != None
        q3Stg = q3.GetStage()
    endif

    if IsJacorenInDialogueOrScene()
        Scene theresaSceneCheck = Game.GetFormFromFile(0x00005104, "Vault13Chronicles.esp") as Scene
        Actor theresaCheck = Game.GetFormFromFile(0x00002153, "Vault13Chronicles.esp") as Actor
        bool theresaActive = (theresaSceneCheck != None && theresaSceneCheck.IsPlaying()) || (theresaCheck != None && theresaCheck.IsInDialogueWithPlayer())
        int sIdx = 0
        while sIdx < 8
            if !(theresaActive && sIdx == 3)
                Actor sAct = Game.GetFormFromFile(0x00002150 + sIdx, "Vault13Chronicles.esp") as Actor
                if sAct != None && sAct.IsTalking() && !sAct.IsInDialogueWithPlayer()
                    SilenceResidentActor(sAct)
                endif
            endif
            sIdx += 1
        endwhile
        isPlayingLongMonologue = false
        isPlayingShortHelo = false
        longMonologueResidentIdx = -1
        return
    endif

    if q2Stg >= 30 && q3Stg < 15
        isPlayingLongMonologue = false
        isPlayingShortHelo = false
        longMonologueResidentIdx = -1
        return
    endif

    bool skipCrisisTrio = (q2Stg >= 15 && q2Stg < 20)

    int talkingIdx = -1
    Actor talkingActor = None
    float talkingDist = 99999.0
    float talkingDz = 99999.0

    float pz = player.GetPositionZ()
    int rIdx = 0
    while rIdx < 8
        if !(skipCrisisTrio && rIdx == 3)
            Actor rActor = Game.GetFormFromFile(0x00002150 + rIdx, "Vault13Chronicles.esp") as Actor
            if rActor != None && !rActor.IsDisabled() && !rActor.IsDead()
                float d = player.GetDistance(rActor)
                float dz = pz - rActor.GetPositionZ()
                if dz < 0.0
                    dz = -dz
                endif
                if rActor.IsTalking() && rIdx != silencedResidentIdx
                    if talkingActor == None
                        talkingIdx = rIdx
                        talkingActor = rActor
                        talkingDist = d
                        talkingDz = dz
                    else
                        SilenceResidentActor(rActor)
                    endif
                endif
            endif
        endif
        rIdx += 1
    endwhile
    silencedResidentIdx = -1

    if talkingActor == None
        isPlayingLongMonologue = false
        isPlayingShortHelo = false
        longMonologueResidentIdx = -1
        return
    endif

    if talkingDist > 300.0 || talkingDz > 145.0
        silencedResidentIdx = talkingIdx
        isPlayingLongMonologue = false
        isPlayingShortHelo = false
        longMonologueResidentIdx = -1
        SilenceResidentActor(talkingActor)
    endif
EndFunction

bool Function IsJacorenInDialogueOrScene()
    Actor jacoren = Game.GetFormFromFile(0x00002110, "Vault13Chronicles.esp") as Actor
    if jacoren != None && (jacoren.IsInDialogueWithPlayer() || jacoren.IsTalking())
        return true
    endif
    Actor theresa = Game.GetFormFromFile(0x00002153, "Vault13Chronicles.esp") as Actor
    if theresa != None && theresa.IsInDialogueWithPlayer()
        return true
    endif
    int[] sceneIDs = new int[11]
    sceneIDs[0] = 0x00004100
    sceneIDs[1] = 0x00004101
    sceneIDs[2] = 0x00005100
    sceneIDs[3] = 0x00005101
    sceneIDs[4] = 0x00006100
    sceneIDs[5] = 0x00006101
    sceneIDs[6] = 0x00007100
    sceneIDs[7] = 0x00007101
    sceneIDs[8] = 0x00008100
    sceneIDs[9] = 0x00008101
    sceneIDs[10] = 0x00005104
    int sIdx = 0
    while sIdx < 11
        Scene sc = Game.GetFormFromFile(sceneIDs[sIdx], "Vault13Chronicles.esp") as Scene
        if sc != None && sc.IsPlaying()
            return true
        endif
        sIdx += 1
    endwhile
    return false
EndFunction

Function ForceQuestAlias(int aiAliasID, int aiFormID)
    ObjectReference targetRef = Game.GetFormFromFile(aiFormID, "Vault13Chronicles.esp") as ObjectReference
    ReferenceAlias al = Self.GetAlias(aiAliasID) as ReferenceAlias
    if al != None && targetRef != None
        if al.GetReference() != targetRef
            al.ForceRefTo(targetRef)
        endif
    endif
EndFunction

Function RegisterPlayerEvents()
    Actor player = Game.GetPlayer()
    if player != None
        RegisterForRemoteEvent(player, "OnPlayerLoadGame")
        RegisterForRemoteEvent(player, "OnItemEquipped")
        RegisterForRemoteEvent(player, "OnLocationChange")
    endif
    Terminal mnemoTermBase = Game.GetFormFromFile(0x00001130, "Vault13Chronicles.esp") as Terminal
    if mnemoTermBase != None
        RegisterForRemoteEvent(mnemoTermBase, "OnMenuItemRun")
    endif
    Terminal overseerTermBase = Game.GetFormFromFile(0x00001131, "Vault13Chronicles.esp") as Terminal
    if overseerTermBase != None
        RegisterForRemoteEvent(overseerTermBase, "OnMenuItemRun")
    endif
    Terminal v15BarracksTermBase = Game.GetFormFromFile(0x0000113C, "Vault13Chronicles.esp") as Terminal
    if v15BarracksTermBase != None
        RegisterForRemoteEvent(v15BarracksTermBase, "OnMenuItemRun")
    endif
    Terminal v15EngTermBase = Game.GetFormFromFile(0x0000113D, "Vault13Chronicles.esp") as Terminal
    if v15EngTermBase != None
        RegisterForRemoteEvent(v15EngTermBase, "OnMenuItemRun")
    endif
    int rIdx = 0
    while rIdx < 8
        ObjectReference rRef = Game.GetFormFromFile(0x00002150 + rIdx, "Vault13Chronicles.esp") as ObjectReference
        if rRef != None
            RegisterForRemoteEvent(rRef, "OnActivate")
        endif
        rIdx += 1
    endwhile
EndFunction

Function UnlockVault15Armory()
    if v15ArmoryUnlocked || v15BarracksDoorsOpened
        return
    endif
    v15ArmoryUnlocked = true
    UnlockAndOpenVault15BarracksDoors()
EndFunction

Function UnlockVault15CommandCenter()
    if v15CmdUnlocked || v15BarracksDoorsOpened
        return
    endif
    v15CmdUnlocked = true
    UnlockAndOpenVault15BarracksDoors()
EndFunction

Function UnlockAndOpenVault15BarracksDoors()
    if v15BarracksDoorsOpened
        return
    endif
    v15BarracksDoorsOpened = true
    v15ArmoryUnlocked = true
    v15CmdUnlocked = true
    ObjectReference barracksTerm = Game.GetFormFromFile(0x00002536, "Vault13Chronicles.esp") as ObjectReference
    if barracksTerm != None && barracksTerm.IsLocked()
        barracksTerm.Lock(false, false)
    endif
    ObjectReference d80 = Game.GetFormFromFile(0x00002580, "Vault13Chronicles.esp") as ObjectReference
    if d80 != None
        if d80.IsDisabled()
            d80.Enable(false)
        endif
        d80.Lock(false, false)
        d80.SetOpen(true)
    endif
    ObjectReference d81 = Game.GetFormFromFile(0x00002581, "Vault13Chronicles.esp") as ObjectReference
    if d81 != None
        if d81.IsDisabled()
            d81.Enable(false)
        endif
        d81.Lock(false, false)
        d81.SetOpen(true)
    endif
    ObjectReference d82 = Game.GetFormFromFile(0x00002582, "Vault13Chronicles.esp") as ObjectReference
    if d82 != None
        if d82.IsDisabled()
            d82.Enable(false)
        endif
        d82.Lock(false, false)
        d82.SetOpen(true)
    endif
    Debug.Notification("[Security Terminal] Password accepted! Khan sector reinforced blast doors unlocked and opened.")
EndFunction

Function ForceAllAct1Aliases()
    ForceQuestAlias(0, 0x00002110)
    ForceQuestAlias(1, 0x00002510)
    ForceQuestAlias(2, 0x00003005)
    ForceQuestAlias(3, 0x00002003)
    ForceQuestAlias(4, 0x00003502)
    ForceQuestAlias(5, 0x00002101)
    ForceQuestAlias(6, 0x00003501)
    ForceQuestAlias(7, 0x00002503)
    if portalMenuClicked || Self.GetStage() >= 16
        ForceQuestAlias(8, 0x00002003)
    else
        ForceQuestAlias(8, 0x00002035)
    endif
    if Self.GetStage() >= 30 || hydroCoreAnalyzedInTerm
        ForceQuestAlias(9, 0x00002110)
    else
        ForceQuestAlias(9, 0x00002130)
    endif
EndFunction

Function SetOverseerTelemetryState(int aiMode)
    ObjectReference wpTerm = Game.GetFormFromFile(0x00002180, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference wpMap = Game.GetFormFromFile(0x00002181, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference ltRedScan = Game.GetFormFromFile(0x00002182, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference ltGreenTerm = Game.GetFormFromFile(0x00002183, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference ltGreenMap = Game.GetFormFromFile(0x00002184, "Vault13Chronicles.esp") as ObjectReference

    if wpTerm != None && wpTerm.IsDisabled()
        wpTerm.Enable(false)
    endif
    if wpMap != None && wpMap.IsDisabled()
        wpMap.Enable(false)
    endif

    if aiMode == 1
        if ltRedScan != None && ltRedScan.IsDisabled()
            ltRedScan.Enable(false)
        endif
        if ltGreenTerm != None && !ltGreenTerm.IsDisabled()
            ltGreenTerm.Disable(false)
        endif
        if ltGreenMap != None && !ltGreenMap.IsDisabled()
            ltGreenMap.Disable(false)
        endif
    elseif aiMode == 2
        if ltRedScan != None && !ltRedScan.IsDisabled()
            ltRedScan.Disable(false)
        endif
        if ltGreenTerm != None && ltGreenTerm.IsDisabled()
            ltGreenTerm.Enable(false)
        endif
        if ltGreenMap != None && ltGreenMap.IsDisabled()
            ltGreenMap.Enable(false)
        endif
    else
        if ltRedScan != None && !ltRedScan.IsDisabled()
            ltRedScan.Disable(false)
        endif
        if ltGreenTerm != None && !ltGreenTerm.IsDisabled()
            ltGreenTerm.Disable(false)
        endif
        if ltGreenMap != None && !ltGreenMap.IsDisabled()
            ltGreenMap.Disable(false)
        endif
    endif
EndFunction

Function StartHydroCoreAnalysisSequence()
    if hydroCoreAnalyzedInTerm
        return
    endif
    SetOverseerTelemetryState(1)
    Actor player = Game.GetPlayer()
    Form hydroLog = Game.GetFormFromFile(0x00001110, "Vault13Chronicles.esp")
    if player != None && hydroLog != None && player.GetItemCount(hydroLog) == 0
        player.AddItem(hydroLog, 1, true)
    endif
    Actor jacoren = Game.GetFormFromFile(0x00002110, "Vault13Chronicles.esp") as Actor
    ObjectReference wpTerm = Game.GetFormFromFile(0x00002180, "Vault13Chronicles.esp") as ObjectReference
    if jacoren != None && player != None
        jacoren.SetLookAt(player, false)
    endif
    if !hydroCoreWalkActive
        hydroCoreWalkActive = true
        hydroCoreWalkStep = 1
        if jacoren != None && wpTerm != None && jacoren.GetDistance(wpTerm) > 120.0
            StartTimer(0.15, 2)
        else
            hydroCoreWalkStep = 2
            hydroCoreWalkActive = false
        endif
    endif
EndFunction

Function AdvanceHydroCoreWalkStep()
    Actor jacoren = Game.GetFormFromFile(0x00002110, "Vault13Chronicles.esp") as Actor
    Actor player = Game.GetPlayer()
    ObjectReference wpTerm = Game.GetFormFromFile(0x00002180, "Vault13Chronicles.esp") as ObjectReference
    if jacoren == None
        hydroCoreWalkActive = false
        return
    endif

    if hydroCoreWalkStep == 1 && !hydroCoreAnalyzedInTerm
        hydroCoreWalkStep = 2
        if wpTerm != None && jacoren.GetDistance(wpTerm) > 120.0
            jacoren.PathToReference(wpTerm, 0.8)
        endif
        if player != None
            jacoren.SetLookAt(player, false)
        endif
        hydroCoreWalkActive = false
        Debug.Notification("[Overseer Jacoren]: 'Insert the Vault 15 Hydrological Survey Holotape into my Command Console to decode the Vault-Tec network.'")
    elseif hydroCoreWalkStep == 3
        hydroCoreWalkStep = 4
        if player != None
            jacoren.SetLookAt(player, false)
        endif
        hydroCoreWalkActive = false
        Debug.Notification("[Overseer Jacoren]: 'The holotape confirms Vault 12's Water Chip is still active beneath Bakersfield! Talk to me.'")
    else
        hydroCoreWalkActive = false
    endif
EndFunction

Function UpdateHydroCoreSequence()
    int curStage = Self.GetStage()
    Actor jacoren = Game.GetFormFromFile(0x00002110, "Vault13Chronicles.esp") as Actor
    if curStage >= 35 || (curStage >= 30 && hydroCoreAnalyzedInTerm)
        hydroCoreAnalyzedInTerm = true
        SetOverseerTelemetryState(2)
        ForceQuestAlias(9, 0x00002110)
        if Self.IsObjectiveDisplayed(35)
            Self.SetObjectiveCompleted(35, true)
            Self.SetObjectiveDisplayed(35, false, false)
        endif
        if curStage < 40
            Self.SetStage(40)
            ApplyV13Act1Stage(40)
            return
        endif
        Scene act1RetSc40 = Game.GetFormFromFile(0x00004101, "Vault13Chronicles.esp") as Scene
        if act1RetSc40 != None && act1RetSc40.IsPlaying() && (jacoren == None || !jacoren.IsTalking())
            act1RetSc40.Stop()
        endif
        Quest act2Q40 = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as Quest
        if act2Q40 != None && act2Q40.GetStage() < 15
            if !act2Q40.IsRunning()
                act2Q40.Start()
            endif
            act2Q40.SetStage(15)
            V13Act2QuestScript act2S40 = act2Q40 as V13Act2QuestScript
            if act2S40 != None
                act2S40.WakeUpAct2()
            endif
        endif
        return
    endif
EndFunction

Function AnalyzeHydroCoreInOverseerTerminal()
    if hydroCoreAnalyzedInTerm || bAnalyzingHydroCore
        if hydroCoreAnalyzedInTerm && Self.GetStage() >= 40 && !bAnalyzingHydroCore
            bAnalyzingHydroCore = true
            Quest act2QReady = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as Quest
            if act2QReady != None && act2QReady.GetStage() < 15
                if !act2QReady.IsRunning()
                    act2QReady.Start()
                endif
                act2QReady.SetStage(15)
                V13Act2QuestScript act2SReady = act2QReady as V13Act2QuestScript
                if act2SReady != None
                    act2SReady.WakeUpAct2()
                endif
            endif
            Debug.Notification("[Overseer Console] Vault 15 Holotape already decoded: Vault 12 (Necropolis) coordinates locked.")
            bAnalyzingHydroCore = false
        endif
        return
    endif
    bAnalyzingHydroCore = true
    hydroCoreAnalyzedInTerm = true

    Actor player = Game.GetPlayer()
    Form hydroLog = Game.GetFormFromFile(0x00001110, "Vault13Chronicles.esp")
    int curStage = Self.GetStage()
    if curStage < 30 && (player == None || hydroLog == None || player.GetItemCount(hydroLog) == 0)
        hydroCoreAnalyzedInTerm = false
        bAnalyzingHydroCore = false
        Debug.Notification("[Overseer Console] You must first recover the Vault 15 Hydrological Survey Holotape.")
        return
    endif

    ObjectReference garlChest = Game.GetFormFromFile(0x00002510, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference relicDisplay1 = Game.GetFormFromFile(0x00002031, "Vault13Chronicles.esp") as ObjectReference
    Actor jacoren = Game.GetFormFromFile(0x00002110, "Vault13Chronicles.esp") as Actor
    Scene act1RetSc = Game.GetFormFromFile(0x00004101, "Vault13Chronicles.esp") as Scene
    if act1RetSc != None && act1RetSc.IsPlaying()
        act1RetSc.Stop()
    endif

    if player != None && hydroLog != None
        if player.GetItemCount(hydroLog) > 0
            player.RemoveItem(hydroLog, player.GetItemCount(hydroLog), true, None)
        endif
        if garlChest != None && garlChest.GetItemCount(hydroLog) > 0
            garlChest.RemoveItem(hydroLog, garlChest.GetItemCount(hydroLog), true, None)
        endif
    endif
    if relicDisplay1 != None && relicDisplay1.IsDisabled()
        relicDisplay1.Enable(false)
    endif

    SetOverseerTelemetryState(2)
    GiveAct1CompletionRewards()

    EffectShader constFX = Game.GetFormFromFile(0x002494E4, "Fallout4.esm") as EffectShader
    if player != None && constFX != None
        constFX.Play(player, 1.8)
    endif
    if jacoren != None && player != None
        jacoren.SetLookAt(player, false)
    endif

    Debug.Notification("[Vault 13 Mainframe] Vault 15 Hydrological Survey Holotape read! Triangulating regional Vault-Tec network...")
    Debug.Notification("[Vault-Tec Telemetry] ACTIVE CARRIER SIGNAL DETECTED! Vault 12 located beneath Bakersfield ('Necropolis').")

    hydroCoreWalkActive = false
    hydroCoreWalkStep = 4

    if Self.GetStage() < 40
        Self.SetStage(40)
    endif
    ApplyV13Act1Stage(40)
    Quest act2QNow = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as Quest
    if act2QNow != None
        if !act2QNow.IsRunning()
            act2QNow.Start()
        endif
        if act2QNow.GetStage() < 15
            act2QNow.SetStage(15)
        endif
        V13Act2QuestScript act2SNow = act2QNow as V13Act2QuestScript
        if act2SNow != None
            act2SNow.WakeUpAct2()
        endif
    endif
    bAnalyzingHydroCore = false
EndFunction

Function ActivateTemporalPortal()
    if portalActivated
        return
    endif
    portalMenuClicked = true
    portalActivated = true
    bunkerVisited = true
    ObjectReference mnemoV13Door = Game.GetFormFromFile(0x00002003, "Vault13Chronicles.esp") as ObjectReference
    if mnemoV13Door != None
        mnemoV13Door.Enable(false)
        mnemoV13Door.Lock(false, false)
    endif
    ForceQuestAlias(8, 0x00002003)
    ForceQuestAlias(3, 0x00002003)
    Self.SetObjectiveCompleted(15, true)
    Self.SetObjectiveDisplayed(15, false, false)
    if !Self.IsObjectiveDisplayed(16)
        Self.SetObjectiveDisplayed(16, true, false)
    endif
    Self.SetActive(true)
    Debug.Notification("[Mnemosyne Archive] Dimensional/Temporal Bridge activated! Step through the airlock into Vault 13 (Dec 5, 2161).")
    if Self.GetStage() < 16
        Self.SetStage(16)
    endif
    ApplyV13Act1Stage(16)
EndFunction

Function SyncVault13ExpeditionDoors()
    Quest q1 = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as Quest
    Quest q2 = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as Quest
    Quest q3 = Game.GetFormFromFile(0x00006000, "Vault13Chronicles.esp") as Quest
    Quest q4 = Game.GetFormFromFile(0x00007000, "Vault13Chronicles.esp") as Quest
    Quest q5 = Game.GetFormFromFile(0x00008000, "Vault13Chronicles.esp") as Quest

    int activeAct = 1
    int activeStage = 0
    if q1 != None
        activeStage = q1.GetStage()
    endif
    if q2 != None && q2.GetStage() >= 15
        activeAct = 2
        activeStage = q2.GetStage()
    endif
    if q3 != None && q3.GetStage() >= 15
        activeAct = 3
        activeStage = q3.GetStage()
    endif
    if q4 != None && q4.GetStage() >= 15
        activeAct = 4
        activeStage = q4.GetStage()
    endif
    if q5 != None && q5.GetStage() >= 15
        activeAct = 5
        activeStage = q5.GetStage()
    endif

    int[] expDoors = new int[5]
    expDoors[0] = 0x00002101
    expDoors[1] = 0x00002142
    expDoors[2] = 0x00002143
    expDoors[3] = 0x00002144
    expDoors[4] = 0x00002145

    int dIdx = 0
    while dIdx < 5
        ObjectReference dRef = Game.GetFormFromFile(expDoors[dIdx], "Vault13Chronicles.esp") as ObjectReference
        if dRef != None
            if (dIdx + 1) == activeAct
                if dRef.IsDisabled()
                    dRef.Enable(false)
                endif
                if activeAct == 2 && activeStage < 20
                    if !dRef.IsLocked()
                        dRef.SetLockLevel(253)
                        dRef.Lock(true, false)
                    endif
                else
                    if dRef.IsLocked()
                        dRef.Lock(false, false)
                    endif
                endif
                dRef.SetPosition(-176.0, -4368.0, -272.0)
                dRef.SetAngle(0.0, 0.0, 270.0)
            else
                if !dRef.IsDisabled()
                    dRef.Disable(false)
                endif
            endif
        endif
        dIdx += 1
    endwhile

    ObjectReference extDoorSync = Game.GetFormFromFile(0x00003005, "Vault13Chronicles.esp") as ObjectReference
    if extDoorSync != None
        if extDoorSync.IsDisabled()
            extDoorSync.Enable(false)
        endif
        if extDoorSync.IsLocked()
            extDoorSync.Lock(false, false)
        endif
        extDoorSync.SetPosition(-88742.0, 80494.0, 7280.0)
        extDoorSync.SetAngle(0.0, 0.0, 90.0)
    endif

    if Self.GetStage() >= 20
        portalMenuClicked = true
        portalActivated = true
    elseif Self.GetStage() == 16 && portalMenuClicked
        portalActivated = true
    endif

    ObjectReference mnemoV13Door = Game.GetFormFromFile(0x00002003, "Vault13Chronicles.esp") as ObjectReference
    if mnemoV13Door != None
        if mnemoV13Door.IsDisabled()
            mnemoV13Door.Enable(false)
        endif
        mnemoV13Door.SetPosition(-107.43, -752.59, 0.0)
        mnemoV13Door.SetAngle(0.0, 0.0, 351.4065)
        if portalActivated
            if mnemoV13Door.IsLocked()
                mnemoV13Door.Lock(false, false)
            endif
        else
            if !mnemoV13Door.IsLocked()
                mnemoV13Door.SetLockLevel(255)
                mnemoV13Door.Lock(true, false)
            endif
        endif
    endif
    ObjectReference mnemoDoorFrame = Game.GetFormFromFile(0x00002004, "Vault13Chronicles.esp") as ObjectReference
    if mnemoDoorFrame != None && mnemoDoorFrame.IsDisabled()
        mnemoDoorFrame.Enable(false)
    endif
    ObjectReference mnemoDoorShaft = Game.GetFormFromFile(0x00002005, "Vault13Chronicles.esp") as ObjectReference
    if mnemoDoorShaft != None && mnemoDoorShaft.IsDisabled()
        mnemoDoorShaft.Enable(false)
    endif
    ObjectReference mnemoLounger = Game.GetFormFromFile(0x00002036, "Vault13Chronicles.esp") as ObjectReference
    if mnemoLounger != None && mnemoLounger.IsDisabled()
        mnemoLounger.Enable(false)
    endif

    ObjectReference v13MnemoDoor = Game.GetFormFromFile(0x00002104, "Vault13Chronicles.esp") as ObjectReference
    if v13MnemoDoor != None
        if v13MnemoDoor.IsDisabled()
            v13MnemoDoor.Enable(false)
        endif
        if v13MnemoDoor.IsLocked()
            v13MnemoDoor.Lock(false, false)
        endif
        v13MnemoDoor.SetPosition(-2885.0, -4020.0, -16.0)
        v13MnemoDoor.SetAngle(0.0, 0.0, 180.0)
    endif
    ObjectReference v13MnemoMat = Game.GetFormFromFile(0x00002187, "Vault13Chronicles.esp") as ObjectReference
    if v13MnemoMat != None && v13MnemoMat.IsDisabled()
        v13MnemoMat.Enable(false)
    endif

    ObjectReference oldSyncRoom = Game.GetFormFromFile(0x00003406, "Vault13Chronicles.esp") as ObjectReference
    if oldSyncRoom != None && !oldSyncRoom.IsDisabled()
        oldSyncRoom.SetPosition(0.0, 0.0, -3000.0)
        oldSyncRoom.Disable(false)
    endif

    SyncAllCaliforniaPersistentCoords()

    Quest q3Gate = Game.GetFormFromFile(0x00006000, "Vault13Chronicles.esp") as Quest
    Quest q4Gate = Game.GetFormFromFile(0x00007000, "Vault13Chronicles.esp") as Quest
    Quest q5Gate = Game.GetFormFromFile(0x00008000, "Vault13Chronicles.esp") as Quest
    bool act3Unlocked = (q3Gate != None && q3Gate.GetStage() >= 15)
    bool act4Unlocked = (q4Gate != None && q4Gate.GetStage() >= 15)
    bool act5Unlocked = (q5Gate != None && q5Gate.GetStage() >= 15)

    int sdIdx = 0
    while sdIdx < 10
        ObjectReference sdRef = Game.GetFormFromFile(0x00003500 + sdIdx, "Vault13Chronicles.esp") as ObjectReference
        if sdRef != None
            if sdRef.IsDisabled()
                sdRef.Enable(false)
            endif
            if sdIdx == 7 && !act3Unlocked
                sdRef.SetLockLevel(253)
                sdRef.Lock(true, false)
            elseif sdIdx == 8 && !act4Unlocked
                sdRef.SetLockLevel(253)
                sdRef.Lock(true, false)
            elseif sdIdx == 9 && !act5Unlocked
                sdRef.SetLockLevel(253)
                sdRef.Lock(true, false)
            else
                if sdRef.IsLocked()
                    sdRef.Lock(false, false)
                endif
            endif
        endif
        sdIdx += 1
    endwhile
    ObjectReference oldDupDoor = Game.GetFormFromFile(0x0000350A, "Vault13Chronicles.esp") as ObjectReference
    if oldDupDoor != None && !oldDupDoor.IsDisabled()
        oldDupDoor.SetPosition(-2600.0, 13160.0, -3000.0)
        oldDupDoor.Disable(false)
    endif

    if !act3Unlocked
        ObjectReference kragRef = Game.GetFormFromFile(0x00002B11, "Vault13Chronicles.esp") as ObjectReference
        if kragRef != None && !kragRef.IsDisabled()
            kragRef.Disable(false)
        endif
        ObjectReference kragG1 = Game.GetFormFromFile(0x00002B12, "Vault13Chronicles.esp") as ObjectReference
        if kragG1 != None && !kragG1.IsDisabled()
            kragG1.Disable(false)
        endif
        int act3GIdx = 0
        while act3GIdx < 7
            ObjectReference bGuard = Game.GetFormFromFile(0x00002B20 + act3GIdx, "Vault13Chronicles.esp") as ObjectReference
            if bGuard != None && !bGuard.IsDisabled()
                bGuard.Disable(false)
            endif
            act3GIdx += 1
        endwhile
    endif

    if !act4Unlocked
        ObjectReference ltRef = Game.GetFormFromFile(0x00002C11, "Vault13Chronicles.esp") as ObjectReference
        if ltRef != None && !ltRef.IsDisabled()
            ltRef.Disable(false)
        endif
        ObjectReference ltG1 = Game.GetFormFromFile(0x00002C12, "Vault13Chronicles.esp") as ObjectReference
        if ltG1 != None && !ltG1.IsDisabled()
            ltG1.Disable(false)
        endif
        int act4GIdx = 0
        while act4GIdx < 7
            ObjectReference cGuard = Game.GetFormFromFile(0x00002C20 + act4GIdx, "Vault13Chronicles.esp") as ObjectReference
            if cGuard != None && !cGuard.IsDisabled()
                cGuard.Disable(false)
            endif
            act4GIdx += 1
        endwhile
        ObjectReference extMariposaSentry = Game.GetFormFromFile(0x0000358D, "Vault13Chronicles.esp") as ObjectReference
        if extMariposaSentry != None && !extMariposaSentry.IsDisabled()
            extMariposaSentry.Disable(false)
        endif
    endif

    if !act5Unlocked
        ObjectReference masterRef = Game.GetFormFromFile(0x00002D11, "Vault13Chronicles.esp") as ObjectReference
        if masterRef != None && !masterRef.IsDisabled()
            masterRef.Disable(false)
        endif
        ObjectReference morphRef = Game.GetFormFromFile(0x00002D12, "Vault13Chronicles.esp") as ObjectReference
        if morphRef != None && !morphRef.IsDisabled()
            morphRef.Disable(false)
        endif
        int act5GIdx = 0
        while act5GIdx < 7
            ObjectReference dGuard = Game.GetFormFromFile(0x00002D20 + act5GIdx, "Vault13Chronicles.esp") as ObjectReference
            if dGuard != None && !dGuard.IsDisabled()
                dGuard.Disable(false)
            endif
            act5GIdx += 1
        endwhile
    endif

    int ftIdx = 0
    while ftIdx < 31
        ObjectReference ftRef = Game.GetFormFromFile(0x00003510 + ftIdx, "Vault13Chronicles.esp") as ObjectReference
        if ftRef != None && ftRef.IsDisabled()
            ftRef.Enable(false)
        endif
        ftIdx += 1
    endwhile

    if IsPlayerInAny2161Cell()
        int ecIdx = 0
        while ecIdx < 28
            if ecIdx != 13 || act4Unlocked
                Actor ecAct = Game.GetFormFromFile(0x00003580 + ecIdx, "Vault13Chronicles.esp") as Actor
                if ecAct != None && ecAct.IsDisabled()
                    ecAct.Enable(false)
                endif
            endif
            ecIdx += 1
        endwhile
    endif

    ObjectReference caveExitDoor = Game.GetFormFromFile(0x00002206, "Vault13Chronicles.esp") as ObjectReference
    if caveExitDoor != None
        if caveExitDoor.IsDisabled()
            caveExitDoor.Enable(false)
        endif
        if caveExitDoor.IsLocked()
            caveExitDoor.Lock(false, false)
        endif
    endif
    int cdIdx = 0
    while cdIdx < 5
        ObjectReference oldCaveDoor = Game.GetFormFromFile(0x00002211 + cdIdx, "Vault13Chronicles.esp") as ObjectReference
        if oldCaveDoor != None && !oldCaveDoor.IsDisabled()
            oldCaveDoor.Disable(false)
        endif
        cdIdx += 1
    endwhile
EndFunction

Function PurgeIntrudersFromVault13()
    Actor player = Game.GetPlayer()
    if player == None || !player.IsInCombat() || IsJacorenInDialogueOrScene()
        return
    endif
    Cell v13Cell = Game.GetFormFromFile(0x00002100, "Vault13Chronicles.esp") as Cell
    Cell mnemoCell = Game.GetFormFromFile(0x00002000, "Vault13Chronicles.esp") as Cell
    Cell caveCell = Game.GetFormFromFile(0x00002200, "Vault13Chronicles.esp") as Cell
    if v13Cell == None
        return
    endif

    bool playerInSanctuary = false
    Cell pCell = player.GetParentCell()
    if pCell == v13Cell || (mnemoCell != None && pCell == mnemoCell) || (caveCell != None && pCell == caveCell)
        playerInSanctuary = true
    endif
    if !playerInSanctuary
        return
    endif

    int kIdx = 0
    while kIdx < 12
        Actor kActor = Game.GetFormFromFile(0x0000254E + kIdx, "Vault13Chronicles.esp") as Actor
        if kActor != None
            Cell kCell = kActor.GetParentCell()
            if kCell == v13Cell || (mnemoCell != None && kCell == mnemoCell) || (caveCell != None && kCell == caveCell)
                kActor.StopCombat()
                kActor.Disable(false)
            elseif playerInSanctuary && kActor.IsInCombat()
                kActor.StopCombat()
            endif
        endif
        kIdx += 1
    endwhile

    int vcIdx = 0
    while vcIdx < 20
        Actor vcActor = Game.GetFormFromFile(0x000025D0 + vcIdx, "Vault13Chronicles.esp") as Actor
        if vcActor != None
            Cell vcCell = vcActor.GetParentCell()
            if vcCell == v13Cell || (mnemoCell != None && vcCell == mnemoCell) || (caveCell != None && vcCell == caveCell)
                vcActor.StopCombat()
                vcActor.Disable(false)
            elseif playerInSanctuary && vcActor.IsInCombat()
                vcActor.StopCombat()
            endif
        endif
        vcIdx += 1
    endwhile

    int ncIdx = 0
    while ncIdx < 14
        Actor ncActor = Game.GetFormFromFile(0x00002A60 + ncIdx, "Vault13Chronicles.esp") as Actor
        if ncActor != None
            Cell ncCell = ncActor.GetParentCell()
            if ncCell == v13Cell || (mnemoCell != None && ncCell == mnemoCell) || (caveCell != None && ncCell == caveCell)
                ncActor.StopCombat()
                ncActor.Disable(false)
            elseif playerInSanctuary && ncActor.IsInCombat()
                ncActor.StopCombat()
            endif
        endif
        ncIdx += 1
    endwhile

    int[] bossAndGuards = new int[19]
    bossAndGuards[0] = 0x00002A11
    bossAndGuards[1] = 0x00002A12
    bossAndGuards[2] = 0x00002A20
    bossAndGuards[3] = 0x00002B11
    bossAndGuards[4] = 0x00002B12
    bossAndGuards[5] = 0x00002B20
    bossAndGuards[6] = 0x00002B21
    bossAndGuards[7] = 0x00002B22
    bossAndGuards[8] = 0x00002B23
    bossAndGuards[9] = 0x00002B24
    bossAndGuards[10] = 0x00002C11
    bossAndGuards[11] = 0x00002C12
    bossAndGuards[12] = 0x00002C20
    bossAndGuards[13] = 0x00002C21
    bossAndGuards[14] = 0x00002C22
    bossAndGuards[15] = 0x00002D11
    bossAndGuards[16] = 0x00002D12
    bossAndGuards[17] = 0x00002D20
    bossAndGuards[18] = 0x00002D21
    int bgIdx = 0
    while bgIdx < 19
        Actor bgActor = Game.GetFormFromFile(bossAndGuards[bgIdx], "Vault13Chronicles.esp") as Actor
        if bgActor != None
            Cell bgCell = bgActor.GetParentCell()
            if bgCell == v13Cell || (mnemoCell != None && bgCell == mnemoCell) || (caveCell != None && bgCell == caveCell)
                bgActor.StopCombat()
                bgActor.Disable(false)
            elseif playerInSanctuary && bgActor.IsInCombat()
                bgActor.StopCombat()
            endif
        endif
        bgIdx += 1
    endwhile

    if playerInSanctuary && player != None
        player.StopCombatAlarm()
    endif
EndFunction

Function EnableMnemosyneAndVault13()
    Actor player = Game.GetPlayer()
    Cell mnemoCell = Game.GetFormFromFile(0x00002000, "Vault13Chronicles.esp") as Cell
    Cell v13Cell = Game.GetFormFromFile(0x00002100, "Vault13Chronicles.esp") as Cell
    if player != None
        Cell pCell = player.GetParentCell()
        if (mnemoCell != None && pCell == mnemoCell) || (v13Cell != None && pCell == v13Cell)
            bunkerVisited = true
        endif
    endif
    if Self.GetStage() >= 20
        bunkerVisited = true
        portalMenuClicked = true
        portalActivated = true
    elseif Self.GetStage() == 16 && portalMenuClicked
        bunkerVisited = true
        portalActivated = true
    endif

    ObjectReference extHatch = Game.GetFormFromFile(0x00003001, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference extDoor = Game.GetFormFromFile(0x00003005, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference extPad = Game.GetFormFromFile(0x00003006, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference extFT = Game.GetFormFromFile(0x00003007, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference oldMapMarker = Game.GetFormFromFile(0x00003002, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference oldMapMarker2 = Game.GetFormFromFile(0x00003008, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference newMapMarker = Game.GetFormFromFile(0x00003009, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference extRadar = Game.GetFormFromFile(0x00003003, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference extLight = Game.GetFormFromFile(0x00003004, "Vault13Chronicles.esp") as ObjectReference
    Actor jacoren = Game.GetFormFromFile(0x00002110, "Vault13Chronicles.esp") as Actor
    ObjectReference mnemoTerm = Game.GetFormFromFile(0x00002035, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference v13Term = Game.GetFormFromFile(0x00002130, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference mapTerm1 = Game.GetFormFromFile(0x00002230, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference mapTerm2 = Game.GetFormFromFile(0x00002231, "Vault13Chronicles.esp") as ObjectReference

    int sIdx = 0
    while sIdx < 8
        ObjectReference stRef = Game.GetFormFromFile(0x00003021 + sIdx, "Vault13Chronicles.esp") as ObjectReference
        if stRef != None && !stRef.IsDisabled()
            stRef.Disable(false)
            stRef.SetPosition(-88050.0, 81300.0, 4000.0)
        endif
        sIdx += 1
    endwhile

    int oIdx = 0
    while oIdx < 12
        ObjectReference ouRef = Game.GetFormFromFile(0x00003050 + oIdx, "Vault13Chronicles.esp") as ObjectReference
        if ouRef != None && !ouRef.IsDisabled()
            ouRef.Disable(false)
            ouRef.SetPosition(-88050.0, 81300.0, 4000.0)
        endif
        oIdx += 1
    endwhile

    int oldVIdx = 0
    while oldVIdx <= 30
        ObjectReference oldVRef = Game.GetFormFromFile(0x00003100 + oldVIdx, "Vault13Chronicles.esp") as ObjectReference
        if oldVRef != None && !oldVRef.IsDisabled()
            oldVRef.Disable(false)
            oldVRef.SetPosition(-88050.0, 81300.0, 4000.0)
        endif
        oldVIdx += 1
    endwhile

    if extHatch != None && !extHatch.IsDisabled()
        extHatch.Disable(false)
        extHatch.SetPosition(-88050.0, 81300.0, 4000.0)
    endif
    if extPad != None && !extPad.IsDisabled()
        extPad.Disable(false)
        extPad.SetPosition(-88050.0, 81300.0, 4000.0)
    endif
    if extRadar != None && !extRadar.IsDisabled()
        extRadar.Disable(false)
        extRadar.SetPosition(-88050.0, 81300.0, 4000.0)
    endif
    if extLight != None && !extLight.IsDisabled()
        extLight.Disable(false)
        extLight.SetPosition(-88050.0, 81300.0, 4000.0)
    endif
    if oldMapMarker != None && !oldMapMarker.IsDisabled()
        oldMapMarker.Disable(false)
        oldMapMarker.SetPosition(-88050.0, 81300.0, 4000.0)
    endif
    if oldMapMarker2 != None && !oldMapMarker2.IsDisabled()
        oldMapMarker2.Disable(false)
        oldMapMarker2.SetPosition(-88050.0, 81300.0, 4000.0)
    endif

    int vIdx = 0
    while vIdx <= 28
        ObjectReference vRef = Game.GetFormFromFile(0x00003200 + vIdx, "Vault13Chronicles.esp") as ObjectReference
        if vRef != None && vRef.IsDisabled()
            vRef.Enable(false)
        endif
        vIdx += 1
    endwhile
    ObjectReference badSpot1 = Game.GetFormFromFile(0x0000321D, "Vault13Chronicles.esp") as ObjectReference
    if badSpot1 != None && !badSpot1.IsDisabled()
        badSpot1.Disable(false)
    endif
    ObjectReference badSpot2 = Game.GetFormFromFile(0x0000321E, "Vault13Chronicles.esp") as ObjectReference
    if badSpot2 != None && !badSpot2.IsDisabled()
        badSpot2.Disable(false)
    endif
    int[] badV13Triggers = new int[4]
    badV13Triggers[0] = 0x0002009A
    badV13Triggers[1] = 0x00020932
    badV13Triggers[2] = 0x00020933
    badV13Triggers[3] = 0x00020BE7
    int btIdx = 0
    while btIdx < 4
        ObjectReference btRef = Game.GetFormFromFile(badV13Triggers[btIdx], "Vault13Chronicles.esp") as ObjectReference
        if btRef != None && !btRef.IsDisabled()
            btRef.Disable(false)
        endif
        btIdx += 1
    endwhile

    if extDoor != None
        if extDoor.IsDisabled()
            extDoor.Enable(false)
        endif
        if extDoor.IsLocked()
            extDoor.Lock(false, false)
        endif
        extDoor.SetPosition(-88742.0, 80494.0, 7280.0)
        extDoor.SetAngle(0.0, 0.0, 90.0)
    endif
    if extFT != None
        if extFT.IsDisabled()
            extFT.Enable(false)
        endif
        extFT.SetPosition(-87000.0, 80750.0, 7240.0)
        extFT.SetAngle(0.0, 0.0, 90.0)
    endif
    if newMapMarker != None
        newMapMarker.SetPosition(-87350.0, 80750.0, 7303.0)
        newMapMarker.SetAngle(0.0, 0.0, 0.0)
        if Self.GetStage() >= 15
            if newMapMarker.IsDisabled()
                newMapMarker.Enable(false)
            endif
            if bunkerVisited
                if !mapMarkerFastTravelEnabled
                    mapMarkerFastTravelEnabled = true
                    mapMarkerShown = true
                    if !newMapMarker.CanFastTravelToMarker()
                        newMapMarker.AddToMap(true)
                        newMapMarker.EnableFastTravel(true)
                        Game.RewardPlayerXP(25, false)
                    endif
                endif
            elseif !mapMarkerShown
                mapMarkerShown = true
                if !newMapMarker.IsMapMarkerVisible()
                    newMapMarker.AddToMap(false)
                endif
            endif
        endif
    endif
    if jacoren != None
        if jacoren.IsDead()
            jacoren.Resurrect()
        endif
        if jacoren.IsDisabled()
            jacoren.Enable(false)
        endif
        Quest q2Check = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as Quest
        Quest q3Check = Game.GetFormFromFile(0x00006000, "Vault13Chronicles.esp") as Quest
        Scene act2RetSceneCheck = Game.GetFormFromFile(0x00005101, "Vault13Chronicles.esp") as Scene
        bool inWaterPlantEvent = false
        int q3CheckStg = 0
        if q3Check != None
            q3CheckStg = q3Check.GetStage()
        endif
        if q2Check != None
            int q2Stg = q2Check.GetStage()
            if q2Stg == 35 || q2Stg == 38 || (q2Stg >= 40 && q3CheckStg < 15 && player != None && player.GetPositionZ() < -250.0)
                inWaterPlantEvent = true
            endif
        endif
        if act2RetSceneCheck != None && act2RetSceneCheck.IsPlaying()
            inWaterPlantEvent = true
        endif
        int q1StgCheck = Self.GetStage()
        if q1StgCheck == 35 || q1StgCheck == 38 || hydroCoreWalkActive
            inWaterPlantEvent = true
        endif
        if !inWaterPlantEvent
            float jdx = jacoren.GetPositionX() - (-3090.0)
            float jdy = jacoren.GetPositionY() - (-4540.0)
            if (jdx * jdx + jdy * jdy) > 250000.0
                jacoren.SetPosition(-3090.0, -4540.0, -16.0)
                jacoren.SetAngle(0.0, 0.0, 180.0)
            endif
        endif
    endif
    ObjectReference oldBp = Game.GetFormFromFile(0x00020174, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference newBp = Game.GetFormFromFile(0x00002135, "Vault13Chronicles.esp") as ObjectReference
    if newBp != None
        if oldBp != None && !oldBp.IsDisabled()
            oldBp.Disable(false)
        endif
        if newBp.IsDisabled()
            newBp.Enable(false)
        endif
    endif
    ObjectReference winGlass = Game.GetFormFromFile(0x00002136, "Vault13Chronicles.esp") as ObjectReference
    if winGlass != None && winGlass.IsDisabled()
        winGlass.Enable(false)
    endif
    Quest q2ResCheck = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as Quest
    Quest q3ResCheck = Game.GetFormFromFile(0x00006000, "Vault13Chronicles.esp") as Quest
    int q2ResStg = 0
    if q2ResCheck != None
        q2ResStg = q2ResCheck.GetStage()
    endif
    int q3ResStg = 0
    if q3ResCheck != None
        q3ResStg = q3ResCheck.GetStage()
    endif
    bool act2MovesTrio = (q2ResStg >= 15 && q3ResStg < 20)
    bool act2MovesCalvin = (q2ResStg >= 30 && q3ResStg < 20)

    float[] resX = new float[8]
    float[] resY = new float[8]
    float[] resZ = new float[8]
    float[] resAng = new float[8]
    resX[0] = -3150.0
    resY[0] = -3650.0
    resZ[0] = -144.0
    resAng[0] = 180.0
    resX[1] = -2450.0
    resY[1] = -4020.0
    resZ[1] = -272.0
    resAng[1] = 302.5
    resX[2] = -1680.0
    resY[2] = -3960.0
    resZ[2] = -272.0
    resAng[2] = 176.5
    resX[3] = -1920.0
    resY[3] = -4740.0
    resZ[3] = -272.0
    resAng[3] = 0.0
    resX[4] = -1050.0
    resY[4] = -3960.0
    resZ[4] = -272.0
    resAng[4] = 180.0
    resX[5] = -520.0
    resY[5] = -4312.0
    resZ[5] = -272.0
    resAng[5] = 240.0
    resX[6] = -2153.8
    resY[6] = -4696.1
    resZ[6] = -527.3
    resAng[6] = 0.0
    resX[7] = -1960.0
    resY[7] = -4480.0
    resZ[7] = -528.0
    resAng[7] = 325.0

    int npcIdx = 0
    while npcIdx < 8
        Actor v13Npc = Game.GetFormFromFile(0x00002150 + npcIdx, "Vault13Chronicles.esp") as Actor
        if v13Npc != None
            if v13Npc.IsDead()
                v13Npc.Resurrect()
            endif
            if v13Npc.IsDisabled()
                v13Npc.Enable(false)
            endif
            bool skipPosSync = false
            if act2MovesTrio && (npcIdx == 0 || npcIdx == 2 || npcIdx == 3)
                skipPosSync = true
            elseif act2MovesCalvin && (npcIdx == 1 || npcIdx == 7)
                skipPosSync = true
            endif
            if !skipPosSync
                float rdx = v13Npc.GetPositionX() - resX[npcIdx]
                float rdy = v13Npc.GetPositionY() - resY[npcIdx]
                if (rdx * rdx + rdy * rdy) > 250000.0
                    v13Npc.SetPosition(resX[npcIdx], resY[npcIdx], resZ[npcIdx])
                    v13Npc.SetAngle(0.0, 0.0, resAng[npcIdx])
                endif
            endif
        endif
        npcIdx += 1
    endwhile
    v13CorridorPopulated = true
    exteriorInitialized = true
    if mnemoTerm != None && mnemoTerm.IsDisabled()
        mnemoTerm.Enable(false)
    endif
    if v13Term != None && v13Term.IsDisabled()
        v13Term.Enable(false)
    endif
    if mapTerm1 != None && !mapTerm1.IsDisabled()
        mapTerm1.SetPosition(850.0, -4220.0, -3000.0)
        mapTerm1.Disable(false)
    endif
    ObjectReference oldCaveDesk = Game.GetFormFromFile(0x00030405, "Vault13Chronicles.esp") as ObjectReference
    if oldCaveDesk != None && !oldCaveDesk.IsDisabled()
        oldCaveDesk.SetPosition(850.0, -4220.0, -3000.0)
        oldCaveDesk.Disable(false)
    endif
    ObjectReference dupDoor350A = Game.GetFormFromFile(0x0000350A, "Vault13Chronicles.esp") as ObjectReference
    if dupDoor350A != None && !dupDoor350A.IsDisabled()
        dupDoor350A.SetPosition(-2600.0, 13160.0, -3000.0)
        dupDoor350A.Disable(false)
    endif
    int dupBunkerIdx = 0
    while dupBunkerIdx < 50
        ObjectReference dupBunkerPiece = Game.GetFormFromFile(0x000B0064 + dupBunkerIdx, "Vault13Chronicles.esp") as ObjectReference
        if dupBunkerPiece != None && !dupBunkerPiece.IsDisabled()
            dupBunkerPiece.SetPosition(-2600.0, 13160.0, -3000.0)
            dupBunkerPiece.Disable(false)
        endif
        dupBunkerIdx += 1
    endwhile
    if mapTerm2 != None && mapTerm2.IsDisabled()
        mapTerm2.Enable(false)
    endif
    SyncVault13ExpeditionDoors()
EndFunction

Function SetVault15State(bool abEnabled)
    v15StateInitialized = true
    ObjectReference garlChest = Game.GetFormFromFile(0x00002510, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference term15 = Game.GetFormFromFile(0x00002530, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference d2501 = Game.GetFormFromFile(0x00002501, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference d2503 = Game.GetFormFromFile(0x00002503, "Vault13Chronicles.esp") as ObjectReference
    Form colt6520 = Game.GetFormFromFile(0x00001102, "Vault13Chronicles.esp")

    int[] legacyActors = new int[7]
    legacyActors[0] = 0x00002511
    legacyActors[1] = 0x00002512
    legacyActors[2] = 0x00002520
    legacyActors[3] = 0x00002521
    legacyActors[4] = 0x00002522
    legacyActors[5] = 0x00002523
    legacyActors[6] = 0x00002524
    int lIdx = 0
    while lIdx < 7
        ObjectReference legRef = Game.GetFormFromFile(legacyActors[lIdx], "Vault13Chronicles.esp") as ObjectReference
        if legRef != None && !legRef.IsDisabled()
            legRef.Disable(false)
        endif
        lIdx += 1
    endwhile

    int[] oldV81Refs = new int[5]
    oldV81Refs[0] = 0x0004008B
    oldV81Refs[1] = 0x0004008C
    oldV81Refs[2] = 0x0004008D
    oldV81Refs[3] = 0x00040314
    oldV81Refs[4] = 0x00040315
    int v81Idx = 0
    while v81Idx < 5
        ObjectReference oldRef = Game.GetFormFromFile(oldV81Refs[v81Idx], "Vault13Chronicles.esp") as ObjectReference
        if oldRef != None && !oldRef.IsDisabled()
            oldRef.Disable(false)
        endif
        v81Idx += 1
    endwhile

    int[] restoreShiftedRefs = new int[16]
    restoreShiftedRefs[0] = 0x000409E3
    restoreShiftedRefs[1] = 0x00040F1A
    restoreShiftedRefs[2] = 0x00040F1B
    restoreShiftedRefs[3] = 0x000408BE
    restoreShiftedRefs[4] = 0x000409B6
    restoreShiftedRefs[5] = 0x00040955
    restoreShiftedRefs[6] = 0x00040956
    restoreShiftedRefs[7] = 0x00040E2A
    restoreShiftedRefs[8] = 0x000407FA
    restoreShiftedRefs[9] = 0x000409B1
    restoreShiftedRefs[10] = 0x000409B2
    restoreShiftedRefs[11] = 0x00040080
    restoreShiftedRefs[12] = 0x00040081
    restoreShiftedRefs[13] = 0x00040097
    restoreShiftedRefs[14] = 0x00040953
    restoreShiftedRefs[15] = 0x00040954
    int rsIdx = 0
    while rsIdx < 16
        ObjectReference rsRef = Game.GetFormFromFile(restoreShiftedRefs[rsIdx], "Vault13Chronicles.esp") as ObjectReference
        if rsRef != None && rsRef.IsDisabled()
            rsRef.Enable(false)
        endif
        rsIdx += 1
    endwhile

    int[] extraLootRefs = new int[4]
    extraLootRefs[0] = 0x0004025F
    extraLootRefs[1] = 0x000401A0
    extraLootRefs[2] = 0x0004016C
    extraLootRefs[3] = 0x000400AC
    int elIdx = 0
    while elIdx < 4
        ObjectReference elRef = Game.GetFormFromFile(extraLootRefs[elIdx], "Vault13Chronicles.esp") as ObjectReference
        if elRef != None
            if abEnabled
                if elRef.IsDisabled()
                    elRef.Enable(false)
                endif
            else
                if !elRef.IsDisabled()
                    elRef.Disable(false)
                endif
            endif
        endif
        elIdx += 1
    endwhile

    if abEnabled
        if d2501 != None
            if d2501.IsDisabled()
                d2501.Enable(false)
            endif
            if d2501.IsLocked()
                d2501.Lock(false, false)
            endif
        endif
        if d2503 != None
            if d2503.IsDisabled()
                d2503.Enable(false)
            endif
            if d2503.IsLocked()
                d2503.Lock(false, false)
            endif
            if d2503.GetPositionX() > 8550.0
                d2503.SetPosition(8534.855, -11222.446, -256.0)
                d2503.SetAngle(0.0, 0.0, 269.0)
            endif
        endif
        if garlChest != None && garlChest.IsDisabled()
            garlChest.Enable(false)
        endif
        if term15 != None && term15.IsDisabled()
            term15.Enable(false)
        endif

        int tIdx = 0
        while tIdx < 8
            ObjectReference routeTerm = Game.GetFormFromFile(0x00002531 + tIdx, "Vault13Chronicles.esp") as ObjectReference
            if routeTerm != None && routeTerm.IsDisabled()
                routeTerm.Enable(false)
            endif
            tIdx += 1
        endwhile

        int cIdx = 0
        while cIdx < 9
            ObjectReference routeCont = Game.GetFormFromFile(0x00002570 + cIdx, "Vault13Chronicles.esp") as ObjectReference
            if routeCont != None
                if routeCont.IsDisabled()
                    routeCont.Enable(false)
                endif
                if cIdx == 0
                    if routeCont.GetPositionX() < 5625.0
                        routeCont.SetPosition(5640.0, -5390.0, -511.0)
                        routeCont.SetAngle(0.0, 0.0, 90.0)
                    endif
                    Form razloNoteWrong = Game.GetFormFromFile(0x00001146, "Vault13Chronicles.esp")
                    if razloNoteWrong != None && routeCont.GetItemCount(razloNoteWrong) > 0
                        routeCont.RemoveItem(razloNoteWrong, routeCont.GetItemCount(razloNoteWrong), true, None)
                    endif
                endif
            endif
            cIdx += 1
        endwhile

        ObjectReference d2580 = Game.GetFormFromFile(0x00002580, "Vault13Chronicles.esp") as ObjectReference
        if d2580 != None
            if d2580.IsDisabled()
                d2580.Enable(false)
            endif
            if v15BarracksDoorsOpened
                d2580.Lock(false, false)
                d2580.SetOpen(true)
            else
                d2580.SetOpen(false)
                d2580.SetLockLevel(253)
                d2580.Lock(true, false)
            endif
        endif
        ObjectReference d2581 = Game.GetFormFromFile(0x00002581, "Vault13Chronicles.esp") as ObjectReference
        if d2581 != None
            if d2581.IsDisabled()
                d2581.Enable(false)
            endif
            if v15BarracksDoorsOpened
                d2581.Lock(false, false)
                d2581.SetOpen(true)
            else
                d2581.SetOpen(false)
                d2581.SetLockLevel(253)
                d2581.Lock(true, false)
            endif
        endif
        ObjectReference d2582 = Game.GetFormFromFile(0x00002582, "Vault13Chronicles.esp") as ObjectReference
        if d2582 != None
            if d2582.IsDisabled()
                d2582.Enable(false)
            endif
            if v15BarracksDoorsOpened
                d2582.Lock(false, false)
                d2582.SetOpen(true)
            else
                d2582.SetOpen(false)
                d2582.SetLockLevel(253)
                d2582.Lock(true, false)
            endif
        endif

        int propIdx = 0
        while propIdx < 4
            ObjectReference v15Prop = Game.GetFormFromFile(0x00002585 + propIdx, "Vault13Chronicles.esp") as ObjectReference
            if v15Prop != None
                if propIdx == 0
                    if !v15Prop.IsDisabled()
                        v15Prop.Disable(false)
                    endif
                else
                    if v15Prop.IsDisabled()
                        v15Prop.Enable(false)
                    endif
                endif
            endif
            propIdx += 1
        endwhile

        Actor edCorpseInit = Game.GetFormFromFile(0x00002589, "Vault13Chronicles.esp") as Actor
        if edCorpseInit != None && edCorpseInit.IsDisabled()
            edCorpseInit.Enable(false)
        endif
        ObjectReference edNoteDeskInit = Game.GetFormFromFile(0x0000258A, "Vault13Chronicles.esp") as ObjectReference
        if edNoteDeskInit != None && edNoteDeskInit.IsDisabled()
            edNoteDeskInit.Enable(false)
        endif

        int oldCIdx = 0
        while oldCIdx < 14
            Actor oldCreature = Game.GetFormFromFile(0x00002540 + oldCIdx, "Vault13Chronicles.esp") as Actor
            if oldCreature != None && !oldCreature.IsDisabled()
                oldCreature.StopCombat()
                oldCreature.Disable(false)
            endif
            oldCIdx += 1
        endwhile
        Actor oldScorp51 = Game.GetFormFromFile(0x00002551, "Vault13Chronicles.esp") as Actor
        if oldScorp51 != None && !oldScorp51.IsDisabled()
            oldScorp51.StopCombat()
            oldScorp51.Disable(false)
        endif

        int dcIdx = 0
        while dcIdx < 24
            Actor dirtCreature = Game.GetFormFromFile(0x00002590 + dcIdx, "Vault13Chronicles.esp") as Actor
            if dirtCreature != None && !dirtCreature.IsDisabled()
                dirtCreature.StopCombat()
                dirtCreature.Disable(false)
            endif
            dcIdx += 1
        endwhile

        int kIdx = 0
        while kIdx < 12
            Actor khanEnemy = Game.GetFormFromFile(0x0000254E + kIdx, "Vault13Chronicles.esp") as Actor
            if khanEnemy != None && (0x0000254E + kIdx) != 0x00002551 && khanEnemy.IsDisabled()
                khanEnemy.Enable(false)
            endif
            kIdx += 1
        endwhile

        int vcOldIdx = 0
        while vcOldIdx < 20
            Actor vOldCreature = Game.GetFormFromFile(0x000025B0 + vcOldIdx, "Vault13Chronicles.esp") as Actor
            if vOldCreature != None && !vOldCreature.IsDisabled()
                vOldCreature.StopCombat()
                vOldCreature.Disable(false)
            endif
            vcOldIdx += 1
        endwhile

        int vcIdx = 0
        while vcIdx < 20
            Actor vCreature = Game.GetFormFromFile(0x000025D0 + vcIdx, "Vault13Chronicles.esp") as Actor
            if vCreature != None && vCreature.IsDisabled()
                vCreature.Enable(false)
            endif
            vcIdx += 1
        endwhile

        Actor garl = Game.GetFormFromFile(0x00002559, "Vault13Chronicles.esp") as Actor
        if garl != None && !garl.IsDead() && colt6520 != None
            if garl.GetItemCount(colt6520) > 1
                garl.RemoveItem(colt6520, garl.GetItemCount(colt6520) - 1, true, None)
            endif
            if garl.GetItemCount(colt6520) > 0 && !garl.IsEquipped(colt6520)
                garl.EquipItem(colt6520, false, true)
            endif
        endif
    endif
EndFunction

Function UpdateVault15RouteAndCombat()
    Actor player = Game.GetPlayer()
    if player == None
        return
    endif
    Cell v15Cell = Game.GetFormFromFile(0x00002500, "Vault13Chronicles.esp") as Cell
    if v15Cell == None || player.GetParentCell() != v15Cell
        v15CellRefreshed = false
        return
    endif
    if !v15StateInitialized
        SetVault15State(true)
    endif

    ObjectReference edBagLive = Game.GetFormFromFile(0x00002570, "Vault13Chronicles.esp") as ObjectReference
    if edBagLive != None && edBagLive.GetPositionX() < 5625.0
        if edBagLive.IsDisabled()
            edBagLive.Enable(false)
        endif
        edBagLive.SetPosition(5640.0, -5390.0, -511.0)
        edBagLive.SetAngle(0.0, 0.0, 90.0)
    endif
    ObjectReference edSkelLive = Game.GetFormFromFile(0x00002585, "Vault13Chronicles.esp") as ObjectReference
    if edSkelLive != None && !edSkelLive.IsDisabled()
        edSkelLive.Disable(false)
    endif
    ObjectReference edNoteDeskLive = Game.GetFormFromFile(0x0000258A, "Vault13Chronicles.esp") as ObjectReference
    if edNoteDeskLive != None && edNoteDeskLive.IsDisabled()
        edNoteDeskLive.Enable(false)
    endif
    Actor edCorpseLive = Game.GetFormFromFile(0x00002589, "Vault13Chronicles.esp") as Actor
    Form v13SuitPlayable = Game.GetFormFromFile(0x00001307, "Vault13Chronicles.esp")
    Form v13SuitEdNP = Game.GetFormFromFile(0x00001308, "Vault13Chronicles.esp")
    if edCorpseLive != None
        if edCorpseLive.IsDisabled()
            edCorpseLive.Enable(false)
        endif
        if edCorpseLive.GetPositionX() < 5600.0 && edCorpseLive.Is3DLoaded()
            edCorpseLive.SetPosition(5710.0, -5365.0, -511.0)
            edCorpseLive.SetAngle(0.0, 0.0, 126.0)
        endif
        if !edCorpseLive.IsDead() && edCorpseLive.Is3DLoaded()
            edCorpseLive.SetPosition(5710.0, -5365.0, -511.0)
            edCorpseLive.SetAngle(0.0, 0.0, 126.0)
            if v13SuitPlayable != None && edCorpseLive.GetItemCount(v13SuitPlayable) > 0
                edCorpseLive.RemoveItem(v13SuitPlayable, edCorpseLive.GetItemCount(v13SuitPlayable), true, None)
            endif
            if v13SuitEdNP != None
                if edCorpseLive.GetItemCount(v13SuitEdNP) == 0
                    edCorpseLive.AddItem(v13SuitEdNP, 1, true)
                endif
                edCorpseLive.EquipItem(v13SuitEdNP, true, true)
                Utility.Wait(0.15)
            endif
            edCorpseLive.KillSilent(None)
        endif
    endif
    ObjectReference ianChestLive = Game.GetFormFromFile(0x00002573, "Vault13Chronicles.esp") as ObjectReference
    if ianChestLive != None && (ianChestLive.GetPositionX() > 5890.0 || ianChestLive.GetPositionY() < -8480.0)
        ianChestLive.SetPosition(5880.0, -8430.0, -640.0)
        ianChestLive.SetAngle(0.0, 0.0, 90.0)
    endif
    ObjectReference c71Live = Game.GetFormFromFile(0x00002571, "Vault13Chronicles.esp") as ObjectReference
    if c71Live != None && c71Live.GetPositionX() < 3770.0
        c71Live.SetPosition(3795.0, -4965.0, -768.0)
        c71Live.SetAngle(0.0, 0.0, 180.0)
    endif
    ObjectReference c75Live = Game.GetFormFromFile(0x00002575, "Vault13Chronicles.esp") as ObjectReference
    if c75Live != None && c75Live.GetPositionX() < 7010.0
        c75Live.SetPosition(7045.0, -8485.0, -392.0)
        c75Live.SetAngle(0.0, 0.0, 0.0)
    endif
    ObjectReference c76Live = Game.GetFormFromFile(0x00002576, "Vault13Chronicles.esp") as ObjectReference
    if c76Live != None && c76Live.GetPositionY() < -10110.0
        c76Live.SetPosition(6442.0, -10080.0, -384.0)
        c76Live.SetAngle(0.0, 0.0, 90.0)
    endif
    ObjectReference catwalkCor9E3 = Game.GetFormFromFile(0x000409E3, "Vault13Chronicles.esp") as ObjectReference
    if catwalkCor9E3 != None && catwalkCor9E3.IsDisabled()
        SetVault15State(true)
    endif
    ObjectReference dupTermE2A = Game.GetFormFromFile(0x00040E2A, "Vault13Chronicles.esp") as ObjectReference
    if dupTermE2A != None && dupTermE2A.IsDisabled()
        dupTermE2A.Enable(false)
    endif
    ObjectReference barracksTerm = Game.GetFormFromFile(0x00002536, "Vault13Chronicles.esp") as ObjectReference
    if !v15BarracksTermLockApplied
        v15BarracksTermLockApplied = true
        if barracksTerm != None
            if barracksTerm.IsDisabled()
                barracksTerm.Enable(false)
            endif
            barracksTerm.SetLockLevel(25)
            barracksTerm.Lock(true, false)
        endif
    elseif !v15BarracksDoorsOpened && barracksTerm != None && !barracksTerm.IsLocked()
        UnlockAndOpenVault15BarracksDoors()
    endif
    if !v15BarracksDoorsOpened
        ObjectReference d80Lock = Game.GetFormFromFile(0x00002580, "Vault13Chronicles.esp") as ObjectReference
        if d80Lock != None
            d80Lock.SetOpen(false)
            if !d80Lock.IsLocked()
                d80Lock.SetLockLevel(253)
                d80Lock.Lock(true, false)
            endif
        endif
        ObjectReference d81Lock = Game.GetFormFromFile(0x00002581, "Vault13Chronicles.esp") as ObjectReference
        if d81Lock != None
            d81Lock.SetOpen(false)
            if !d81Lock.IsLocked()
                d81Lock.SetLockLevel(253)
                d81Lock.Lock(true, false)
            endif
        endif
        ObjectReference d82Lock = Game.GetFormFromFile(0x00002582, "Vault13Chronicles.esp") as ObjectReference
        if d82Lock != None
            d82Lock.SetOpen(false)
            if !d82Lock.IsLocked()
                d82Lock.SetLockLevel(253)
                d82Lock.Lock(true, false)
            endif
        endif
    endif

    if !v15CellRefreshed
        v15CellRefreshed = true
        RegisterPlayerEvents()
        Actor edCorpse = Game.GetFormFromFile(0x00002589, "Vault13Chronicles.esp") as Actor
        if edCorpse != None
            if edCorpse.IsDisabled()
                edCorpse.Enable(false)
            endif
            Form edNote = Game.GetFormFromFile(0x00001147, "Vault13Chronicles.esp")
            if edNote != None && edCorpse.GetItemCount(edNote) > 0
                edCorpse.RemoveItem(edNote, edCorpse.GetItemCount(edNote), true, None)
            endif
            if v13SuitPlayable != None && edCorpse.GetItemCount(v13SuitPlayable) > 0
                edCorpse.RemoveItem(v13SuitPlayable, edCorpse.GetItemCount(v13SuitPlayable), true, None)
            endif
            if v13SuitEdNP != None
                if edCorpse.GetItemCount(v13SuitEdNP) == 0
                    edCorpse.AddItem(v13SuitEdNP, 1, true)
                endif
                edCorpse.EquipItem(v13SuitEdNP, true, true)
            endif
        endif
        ObjectReference d83 = Game.GetFormFromFile(0x00002583, "Vault13Chronicles.esp") as ObjectReference
        if d83 != None
            if d83.IsDisabled()
                d83.Enable(false)
            endif
            if d83.IsLocked()
                d83.Lock(false, false)
            endif
            if player.GetPositionY() > -8700.0
                d83.SetOpen(false)
            endif
        endif
        int kSnapIdx = 0
        while kSnapIdx < 12
            int kSnapFid = 0x0000254E + kSnapIdx
            Actor kActor = Game.GetFormFromFile(kSnapFid, "Vault13Chronicles.esp") as Actor
            if kActor != None && !kActor.IsDead()
                if kSnapFid == 0x00002553 && kActor.GetPositionX() > 6460.0 && kActor.GetPositionX() < 6540.0 && kActor.GetPositionY() < -10250.0 && kActor.GetPositionY() > -10320.0
                    kActor.SetPosition(7536.0, -10291.5, -383.6)
                elseif kSnapFid == 0x00002556 && kActor.GetPositionX() > 7540.0 && kActor.GetPositionX() < 7620.0 && kActor.GetPositionY() < -10850.0 && kActor.GetPositionY() > -10930.0
                    kActor.SetPosition(7676.6, -11320.9, -255.9)
                endif
                kActor.EvaluatePackage()
            endif
            kSnapIdx += 1
        endwhile
        ActorValue avSpeedMult = Game.GetFormFromFile(0x000002DA, "Fallout4.esm") as ActorValue
        int rIdx = 0
        while rIdx < 20
            int rFid = 0x000025D0 + rIdx
            Actor rCreature = Game.GetFormFromFile(rFid, "Vault13Chronicles.esp") as Actor
            if rCreature != None && !rCreature.IsDead()
                if rCreature.IsDisabled() && rFid < 0x000025DD
                    rCreature.Enable(false)
                endif
                if avSpeedMult != None && rCreature.GetValue(avSpeedMult) < 95.0
                    rCreature.SetValue(avSpeedMult, 100.0)
                endif
                rCreature.EvaluatePackage()
            endif
            rIdx += 1
        endwhile
    endif

    int cCleanIdx = 0
    while cCleanIdx < 20
        int cCleanFid = 0x000025D0 + cCleanIdx
        Actor cLive = Game.GetFormFromFile(cCleanFid, "Vault13Chronicles.esp") as Actor
        if cLive != None && !cLive.IsDead() && !cLive.IsDisabled()
            if cCleanFid >= 0x000025DD && cCleanFid <= 0x000025E1
                if cLive.GetPositionY() < -9600.0 || (cCleanFid >= 0x000025DF && cLive.GetPositionZ() > -560.0)
                    cLive.StopCombat()
                    cLive.Disable(false)
                endif
            endif
        endif
        cCleanIdx += 1
    endwhile

    float py = player.GetPositionY()

    if py > -8700.0
        ObjectReference d83Hold = Game.GetFormFromFile(0x00002583, "Vault13Chronicles.esp") as ObjectReference
        if d83Hold != None && player.GetDistance(d83Hold) > 220.0
            d83Hold.SetOpen(false)
        endif
    endif

    if py > -10050.0
        if !v15BarracksDoorsOpened
            ObjectReference d80Hold = Game.GetFormFromFile(0x00002580, "Vault13Chronicles.esp") as ObjectReference
            if d80Hold != None && player.GetDistance(d80Hold) > 220.0
                d80Hold.SetOpen(false)
            endif
            ObjectReference d81Hold = Game.GetFormFromFile(0x00002581, "Vault13Chronicles.esp") as ObjectReference
            if d81Hold != None && player.GetDistance(d81Hold) > 220.0
                d81Hold.SetOpen(false)
            endif
        endif
    endif

    if py > -11420.0
        if !v15BarracksDoorsOpened
            ObjectReference d82Hold = Game.GetFormFromFile(0x00002582, "Vault13Chronicles.esp") as ObjectReference
            if d82Hold != None && player.GetDistance(d82Hold) > 220.0
                d82Hold.SetOpen(false)
            endif
        endif
    endif

    if !v15BannerShown && py < -8825.0
        if !Utility.IsInMenuMode()
            v15BannerShown = true
            Debug.Notification("[Vault 15 - December 2161] You have entered the underground levels of Vault 15.")
        endif
    endif

    ObjectReference exitDoor2503 = Game.GetFormFromFile(0x00002503, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference entryDoor2501 = Game.GetFormFromFile(0x00002501, "Vault13Chronicles.esp") as ObjectReference
    if exitDoor2503 != None && exitDoor2503.GetPositionX() > 8550.0
        exitDoor2503.SetPosition(8534.855, -11222.446, -256.0)
        exitDoor2503.SetAngle(0.0, 0.0, 269.0)
    endif
    bool nearExitDoor = false
    if (exitDoor2503 != None && player.GetDistance(exitDoor2503) < 380.0) || (entryDoor2501 != None && player.GetDistance(entryDoor2501) < 380.0)
        nearExitDoor = true
        int stopKIdx = 0
        while stopKIdx < 12
            Actor stopKhan = Game.GetFormFromFile(0x0000254E + stopKIdx, "Vault13Chronicles.esp") as Actor
            if stopKhan != None && !stopKhan.IsDead() && stopKhan.IsInCombat() && player.GetDistance(stopKhan) > 260.0
                stopKhan.StopCombat()
            endif
            stopKIdx += 1
        endwhile
        int stopCIdx = 0
        while stopCIdx < 20
            Actor stopCreat = Game.GetFormFromFile(0x000025D0 + stopCIdx, "Vault13Chronicles.esp") as Actor
            if stopCreat != None && !stopCreat.IsDead() && stopCreat.IsInCombat() && player.GetDistance(stopCreat) > 260.0
                stopCreat.StopCombat()
            endif
            stopCIdx += 1
        endwhile
    endif

    if !player.IsSneaking() && !nearExitDoor && Self.GetStage() < 30
        float pz = player.GetPositionZ()
        int kIdx = 0
        while kIdx < 12
            int kFid = 0x0000254E + kIdx
            bool allowKhanCombat = true
            if kFid == 0x00002551
                allowKhanCombat = false
            elseif kFid >= 0x00002552 && kFid <= 0x00002556 && py > -8825.0
                allowKhanCombat = false
            elseif kFid >= 0x00002557 && !v15BarracksDoorsOpened && py > -11420.0
                allowKhanCombat = false
            endif
            if allowKhanCombat
                Actor enemy = Game.GetFormFromFile(kFid, "Vault13Chronicles.esp") as Actor
                if enemy != None && !enemy.IsDead() && !enemy.IsDisabled() && !enemy.IsInCombat()
                    float dist = player.GetDistance(enemy)
                    if dist < 1100.0
                        float dz = pz - enemy.GetPositionZ()
                        if dz < 0.0
                            dz = -dz
                        endif
                        if dz < 140.0 && (dist < 420.0 || player.HasDetectionLOS(enemy) || enemy.HasDetectionLOS(player))
                            enemy.EvaluatePackage()
                            enemy.StartCombat(player)
                        endif
                    endif
                endif
            endif
            kIdx += 1
        endwhile
        int vcIdx = 0
        while vcIdx < 20
            Actor cEnemy = Game.GetFormFromFile(0x000025D0 + vcIdx, "Vault13Chronicles.esp") as Actor
            if cEnemy != None && !cEnemy.IsDead() && !cEnemy.IsDisabled() && cEnemy.Is3DLoaded()
                float cDist = player.GetDistance(cEnemy)
                if !cEnemy.IsInCombat() && cDist < 950.0
                    float cdz = pz - cEnemy.GetPositionZ()
                    if cdz < 0.0
                        cdz = -cdz
                    endif
                    if cdz < 175.0 && (cDist < 420.0 || player.HasDetectionLOS(cEnemy) || cEnemy.HasDetectionLOS(player))
                        cEnemy.EvaluatePackage()
                        cEnemy.StartCombat(player)
                    endif
                endif
            endif
            vcIdx += 1
        endwhile
    endif
EndFunction

Function DeduplicateV13Items()
    Actor player = Game.GetPlayer()
    if player == None
        return
    endif
    int[] weapIDs = new int[6]
    weapIDs[0] = 0x00001102
    weapIDs[1] = 0x00001105
    weapIDs[2] = 0x00001108
    weapIDs[3] = 0x0000110B
    weapIDs[4] = 0x0000110E
    weapIDs[5] = 0x00001117
    int i = 0
    while i < 6
        Form w = Game.GetFormFromFile(weapIDs[i], "Vault13Chronicles.esp")
        if w != None && player.GetItemCount(w) > 1
            player.RemoveItem(w, player.GetItemCount(w) - 1, true, None)
        endif
        i += 1
    endwhile

    int[] itemIDs = new int[5]
    itemIDs[0] = 0x00001110
    itemIDs[1] = 0x00001112
    itemIDs[2] = 0x00001113
    itemIDs[3] = 0x00001114
    itemIDs[4] = 0x00001115
    int[] qIDs = new int[5]
    qIDs[0] = 0x00004000
    qIDs[1] = 0x00005000
    qIDs[2] = 0x00006000
    qIDs[3] = 0x00007000
    qIDs[4] = 0x00008000
    int[] chestIDs = new int[5]
    chestIDs[0] = 0x00002510
    chestIDs[1] = 0x00002A10
    chestIDs[2] = 0x00002B10
    chestIDs[3] = 0x00002C10
    chestIDs[4] = 0x00002D10
    int j = 0
    while j < 5
        Form c = Game.GetFormFromFile(itemIDs[j], "Vault13Chronicles.esp")
        Quest q = Game.GetFormFromFile(qIDs[j], "Vault13Chronicles.esp") as Quest
        ObjectReference ch = Game.GetFormFromFile(chestIDs[j], "Vault13Chronicles.esp") as ObjectReference
        if c != None
            if q != None && q.GetStage() >= 40
                if player.GetItemCount(c) > 0
                    player.RemoveItem(c, player.GetItemCount(c), true, None)
                endif
                if ch != None && ch.GetItemCount(c) > 0
                    ch.RemoveItem(c, ch.GetItemCount(c), true, None)
                endif
            else
                if player.GetItemCount(c) > 1
                    player.RemoveItem(c, player.GetItemCount(c) - 1, true, None)
                endif
                if player.GetItemCount(c) > 0 && ch != None && ch.GetItemCount(c) > 0
                    ch.RemoveItem(c, ch.GetItemCount(c), true, None)
                endif
            endif
        endif
        j += 1
    endwhile

    Form razloBook = Game.GetFormFromFile(0x00001146, "Vault13Chronicles.esp")
    if razloBook != None && player.GetItemCount(razloBook) > 1
        player.RemoveItem(razloBook, player.GetItemCount(razloBook) - 1, true, None)
    endif
EndFunction

Function GiveVault13StarterGear()
    if suitGiven
        return
    endif
    suitGiven = true
    Actor player = Game.GetPlayer()
    if player == None
        suitGiven = false
        return
    endif
    Form v13Suit = Game.GetFormFromFile(0x00001307, "Vault13Chronicles.esp")
    Form stimpak = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
    if v13Suit != None && player.GetItemCount(v13Suit) == 0
        player.AddItem(v13Suit, 1, false)
    endif
    if stimpak != None
        player.AddItem(stimpak, 2, false)
    endif
    Debug.Notification("[Vault 13 - Dec 5, 2161] Armored Vault 13 Jumpsuit and field rations issued.")
EndFunction

Function GiveAct1CompletionRewards()
    if rewardsGiven
        return
    endif
    rewardsGiven = true
    Actor player = Game.GetPlayer()
    Form hydroLog = Game.GetFormFromFile(0x00001110, "Vault13Chronicles.esp")
    Form colt6520 = Game.GetFormFromFile(0x00001102, "Vault13Chronicles.esp")
    Actor garl = Game.GetFormFromFile(0x00002559, "Vault13Chronicles.esp") as Actor
    ObjectReference garlChest = Game.GetFormFromFile(0x00002510, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference relicDisplay1 = Game.GetFormFromFile(0x00002031, "Vault13Chronicles.esp") as ObjectReference
    Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
    Form stimpak = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
    Form ammo10mm = Game.GetFormFromFile(0x0001F276, "Fallout4.esm")

    if player != None
        if hydroLog != None && (hydroCoreAnalyzedInTerm || Self.GetStage() >= 40)
            if player.GetItemCount(hydroLog) > 0
                player.RemoveItem(hydroLog, player.GetItemCount(hydroLog), true, None)
            endif
            if garlChest != None && garlChest.GetItemCount(hydroLog) > 0
                garlChest.RemoveItem(hydroLog, garlChest.GetItemCount(hydroLog), true, None)
            endif
        endif
        if colt6520 != None
            if player.GetItemCount(colt6520) == 0
                if garl != None && garl.GetItemCount(colt6520) > 0
                    garl.RemoveItem(colt6520, 1, true, player)
                else
                    player.AddItem(colt6520, 1, false)
                endif
            endif
            if garl != None && garl.GetItemCount(colt6520) > 0
                garl.RemoveItem(colt6520, garl.GetItemCount(colt6520), true, None)
            endif
            if player.GetItemCount(colt6520) > 1
                player.RemoveItem(colt6520, player.GetItemCount(colt6520) - 1, true, None)
            endif
        endif
        if caps != None
            player.AddItem(caps, 500, false)
        endif
        if stimpak != None
            player.AddItem(stimpak, 4, false)
        endif
        if ammo10mm != None
            player.AddItem(ammo10mm, 60, false)
        endif
    endif

    if relicDisplay1 != None && relicDisplay1.IsDisabled()
        relicDisplay1.Enable(false)
    endif

    Game.RewardPlayerXP(400, false)
    Debug.Notification("[Vault 13 Chronicles] Vault 15 hydrological core analyzed. Colt 6520 10mm Pistol unlocked!")
EndFunction

Function ApplyV13Act1Stage(int auiStage)
    if auiStage < 15 || bApplyingAct1Stage
        return
    endif
    bApplyingAct1Stage = true

    if auiStage == 35 || auiStage == 38
        hydroCoreAnalyzedInTerm = true
        auiStage = 40
    endif

    if auiStage >= 20
        portalMenuClicked = true
        portalActivated = true
        bunkerVisited = true
    elseif auiStage == 16 && portalMenuClicked
        portalActivated = true
        bunkerVisited = true
    endif

    if auiStage == lastAppliedAct1Stage && introShown && exteriorInitialized
        if (auiStage == 15 || auiStage == 16) && portalMenuClicked == lastAppliedPortalClicked
            if (portalMenuClicked && Self.IsObjectiveDisplayed(16)) || (!portalMenuClicked && Self.IsObjectiveDisplayed(15))
                bApplyingAct1Stage = false
                return
            endif
        elseif auiStage == 30 && Self.IsObjectiveDisplayed(30)
            bApplyingAct1Stage = false
            return
        elseif auiStage >= 40 && auiStage < 45 && rewardsGiven && Self.IsCompleted()
            bApplyingAct1Stage = false
            return
        endif
    endif

    bool inDial = IsJacorenInDialogueOrScene()
    ForceAllAct1Aliases()

    if !exteriorInitialized && !inDial
        EnableMnemosyneAndVault13()
    elseif auiStage != lastAppliedAct1Stage
        SyncVault13ExpeditionDoors()
    endif

    if auiStage >= 15 && !introShown && !introCheckBusy
        introCheckBusy = true
        if !Utility.IsInMenuMode()
            introShown = true
            Message radioMsg = Game.GetFormFromFile(0x00001150, "Vault13Chronicles.esp") as Message
            if radioMsg != None
                radioMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
            endif
        endif
        introCheckBusy = false
    endif

    if (auiStage == 15 || auiStage == 16) && !portalMenuClicked
        if Self.IsObjectiveDisplayed(16)
            Self.SetObjectiveDisplayed(16, false, false)
        endif
        if Self.IsObjectiveCompleted(15)
            Self.SetObjectiveCompleted(15, false)
        endif
        if !Self.IsObjectiveDisplayed(15)
            Self.SetObjectiveDisplayed(15, true, false)
            Self.SetActive(true)
        endif
    elseif (auiStage == 15 || auiStage == 16) && portalMenuClicked
        ForceQuestAlias(8, 0x00002003)
        if !Self.IsObjectiveCompleted(15)
            Self.SetObjectiveCompleted(15, true)
        endif
        if Self.IsObjectiveDisplayed(15)
            Self.SetObjectiveDisplayed(15, false, false)
        endif
        if !Self.IsObjectiveDisplayed(16)
            Self.SetObjectiveDisplayed(16, true, false)
            Self.SetActive(true)
        endif
    elseif auiStage >= 20 && auiStage < 30
        GiveVault13StarterGear()
        if !Self.IsObjectiveCompleted(15)
            Self.SetObjectiveCompleted(15, true)
        endif
        if !Self.IsObjectiveCompleted(16)
            Self.SetObjectiveCompleted(16, true)
        endif
        Actor p20 = Game.GetPlayer()
        WorldSpace v13W = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
        Cell v15C = Game.GetFormFromFile(0x00002500, "Vault13Chronicles.esp") as Cell
        bool leftV13 = (p20 != None && ((v13W != None && p20.GetWorldSpace() == v13W) || (v15C != None && p20.GetParentCell() == v15C)))
        lastAppliedLeftV13 = leftV13
        if leftV13
            if !Self.IsObjectiveCompleted(20)
                Self.SetObjectiveCompleted(20, true)
            endif
            if !Self.IsObjectiveDisplayed(21)
                Self.SetObjectiveDisplayed(21, true, false)
                Self.SetActive(true)
            endif
        else
            if !Self.IsObjectiveDisplayed(20) && !Self.IsObjectiveCompleted(20)
                Self.SetObjectiveDisplayed(20, true, false)
                Self.SetActive(true)
            elseif Self.IsObjectiveCompleted(20) && !Self.IsObjectiveDisplayed(21)
                Self.SetObjectiveDisplayed(21, true, false)
                Self.SetActive(true)
            endif
        endif
    elseif auiStage == 30
        if !Self.IsObjectiveCompleted(15)
            Self.SetObjectiveCompleted(15, true)
        endif
        if !Self.IsObjectiveCompleted(16)
            Self.SetObjectiveCompleted(16, true)
        endif
        if !Self.IsObjectiveCompleted(20)
            Self.SetObjectiveCompleted(20, true)
        endif
        if Self.IsObjectiveDisplayed(21) && !Self.IsObjectiveCompleted(21)
            Self.SetObjectiveCompleted(21, true)
        endif
        if !Self.IsObjectiveDisplayed(30)
            Self.SetObjectiveDisplayed(30, true, false)
            Self.SetActive(true)
        endif
    elseif auiStage >= 40
        if Self.GetStage() < 40
            Self.SetStage(40)
        endif
        Actor jac40 = Game.GetFormFromFile(0x00002110, "Vault13Chronicles.esp") as Actor
        Scene act1RetScStg = Game.GetFormFromFile(0x00004101, "Vault13Chronicles.esp") as Scene
        if act1RetScStg != None && act1RetScStg.IsPlaying() && (jac40 == None || !jac40.IsTalking())
            act1RetScStg.Stop()
        endif
        hydroCoreAnalyzedInTerm = true
        SetOverseerTelemetryState(2)
        ForceQuestAlias(9, 0x00002110)
        Actor p40 = Game.GetPlayer()
        Form hLog40 = Game.GetFormFromFile(0x00001110, "Vault13Chronicles.esp")
        if p40 != None && hLog40 != None && p40.GetItemCount(hLog40) > 0
            p40.RemoveItem(hLog40, p40.GetItemCount(hLog40), true, None)
        endif
        ObjectReference relicDisplay1 = Game.GetFormFromFile(0x00002031, "Vault13Chronicles.esp") as ObjectReference
        if relicDisplay1 != None && relicDisplay1.IsDisabled()
            relicDisplay1.Enable(false)
        endif
        GiveAct1CompletionRewards()
        int[] act1ObjIds = new int[7]
        act1ObjIds[0] = 15
        act1ObjIds[1] = 16
        act1ObjIds[2] = 20
        act1ObjIds[3] = 21
        act1ObjIds[4] = 30
        act1ObjIds[5] = 35
        act1ObjIds[6] = 38
        int oIdx = 0
        while oIdx < 7
            int oid = act1ObjIds[oIdx]
            if !Self.IsObjectiveCompleted(oid)
                Self.SetObjectiveCompleted(oid, true)
            endif
            if Self.IsObjectiveDisplayed(oid)
                Self.SetObjectiveDisplayed(oid, false, false)
            endif
            oIdx += 1
        endwhile
        if !Self.IsCompleted()
            Self.CompleteAllObjectives()
            Self.CompleteQuest()
        endif
        Quest act2Quest40 = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as Quest
        if act2Quest40 != None
            if !act2Quest40.IsRunning()
                act2Quest40.Start()
            endif
            if act2Quest40.GetStage() < 15
                act2Quest40.SetStage(15)
            endif
        endif
        V13Act2QuestScript act2S = act2Quest40 as V13Act2QuestScript
        if act2S != None
            act2S.WakeUpAct2()
        endif
        if auiStage >= 45
            Quest act2Quest = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as Quest
            if act2Quest != None
                if !act2Quest.IsRunning()
                    act2Quest.Start()
                endif
                if act2Quest.GetStage() < 20
                    act2Quest.SetStage(20)
                endif
            endif
        endif
    endif
    lastAppliedAct1Stage = auiStage
    lastAppliedPortalClicked = portalMenuClicked
    bApplyingAct1Stage = false
EndFunction

Function CheckProgressionAndLevelGate()
    Actor player = Game.GetPlayer()
    if player == None
        return
    endif

    int curStage = Self.GetStage()

    if curStage < 15
        if player.GetLevel() >= 1
            if Utility.IsInMenuMode()
                return
            endif
            if !Self.IsRunning()
                Self.Start()
            endif
            Self.SetStage(15)
            ApplyV13Act1Stage(15)
        endif
        return
    endif

    if curStage >= 15 && !introShown && !introCheckBusy
        introCheckBusy = true
        if !Utility.IsInMenuMode()
            introShown = true
            Message radioMsg = Game.GetFormFromFile(0x00001150, "Vault13Chronicles.esp") as Message
            if radioMsg != None
                radioMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
            endif
        endif
        introCheckBusy = false
    endif

    if curStage >= 20 && curStage < 30
        Form hydroLog = Game.GetFormFromFile(0x00001110, "Vault13Chronicles.esp")
        if hydroLog != None && player.GetItemCount(hydroLog) > 0
            Self.SetStage(30)
            ApplyV13Act1Stage(30)
            return
        endif
    endif

    UpdateHydroCoreSequence()

    if IsJacorenInDialogueOrScene()
        return
    endif

    if !bunkerVisited
        Cell mnemoCell = Game.GetFormFromFile(0x00002000, "Vault13Chronicles.esp") as Cell
        Cell v13Cell = Game.GetFormFromFile(0x00002100, "Vault13Chronicles.esp") as Cell
        Cell pCell = player.GetParentCell()
        if (mnemoCell != None && pCell == mnemoCell) || (v13Cell != None && pCell == v13Cell)
            bunkerVisited = true
            EnableMnemosyneAndVault13()
        endif
    endif
    ObjectReference extDoorCheck = Game.GetFormFromFile(0x00003005, "Vault13Chronicles.esp") as ObjectReference
    bool extDoorMisplaced = (extDoorCheck != None && (extDoorCheck.IsDisabled() || extDoorCheck.GetPositionX() < -88760.0 || extDoorCheck.GetPositionX() > -88720.0 || extDoorCheck.GetPositionY() < 80470.0 || extDoorCheck.GetPositionY() > 80520.0))
    if !v13CorridorPopulated || !exteriorInitialized || extDoorMisplaced
        v13CorridorPopulated = true
        EnableMnemosyneAndVault13()
    endif

    PurgeIntrudersFromVault13()
    UpdateVault15RouteAndCombat()
    UpdateHydroCoreSequence()
    UpdateSouthernCaliforniaMapMarkers()
    SyncWorldMap2161()

    Quest qTardisSweep = Game.GetFormFromFile(0x00015000, "Vault13Chronicles.esp") as Quest
    V13SideQuestTardisScript sTardisSweep = qTardisSweep as V13SideQuestTardisScript
    if sTardisSweep != None
        sTardisSweep.TickMotionSensorFromMainLoop()
    endif

    WorldSpace v13W = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    Cell v15C = Game.GetFormFromFile(0x00002500, "Vault13Chronicles.esp") as Cell
    bool inExtOrV15 = ((v13W != None && player.GetWorldSpace() == v13W) || (v15C != None && player.GetParentCell() == v15C))

    if ((curStage == 15 || curStage == 16) && !portalMenuClicked && !Self.IsObjectiveDisplayed(15)) || ((curStage == 15 || curStage == 16) && portalMenuClicked && !Self.IsObjectiveDisplayed(16)) || (curStage == 20 && ((!inExtOrV15 && !Self.IsObjectiveDisplayed(20) && !Self.IsObjectiveCompleted(20)) || (inExtOrV15 && !Self.IsObjectiveDisplayed(21)))) || (curStage == 30 && !Self.IsObjectiveDisplayed(30)) || (curStage == 35 && !Self.IsObjectiveDisplayed(35)) || (curStage == 38 && !Self.IsObjectiveDisplayed(38)) || (curStage >= 40 && (!rewardsGiven || !Self.IsCompleted()))
        ApplyV13Act1Stage(curStage)
    endif
EndFunction

Function ProcessColt6520Hit(Actor akTarget, Actor akCaster)
    if akTarget == None || akCaster == None
        return
    endif

    EffectShader shockFX = Game.GetFormFromFile(0x0006F122, "Fallout4.esm") as EffectShader
    if shockFX != None
        shockFX.Play(akTarget, 1.5)
    endif

    Actor player = Game.GetPlayer()
    if akCaster == player
        hitCounter += 1
        if hitCounter >= 3 || akTarget.IsDead()
            hitCounter = 0
            ActorValue apAV = Game.GetFormFromFile(0x000002D5, "Fallout4.esm") as ActorValue
            if apAV != None
                player.RestoreValue(apAV, 25.0)
            endif
            EffectShader constFX = Game.GetFormFromFile(0x002494E4, "Fallout4.esm") as EffectShader
            if constFX != None
                constFX.Play(player, 1.0)
            endif
            Debug.Notification("[Colt 6520 - 2161] Overcharged 10mm burst! (+25 AP)")
        endif
    endif
EndFunction

Event OnInit()
    RegisterPlayerEvents()
    BindRadioQuestActive()
    SyncAllCaliforniaPersistentCoords()
    StartTimer(2.0, 1)
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
    RegisterPlayerEvents()
    BindRadioQuestActive()
    bMenuReturnBusy = false
    bApplyingAct1Stage = false
    bAnalyzingHydroCore = false
    introCheckBusy = false
    residentTimerActive = false
    lastSpokenResidentIdx = -1
    longMonologueResidentIdx = -1
    playerStoppedTicks = 0
    isPlayingLongMonologue = false
    isPlayingShortHelo = false
    pendingActivateResidentIdx = -1
    silencedResidentIdx = -1
    int stg = Self.GetStage()
    if !IsJacorenInDialogueOrScene()
        DeduplicateV13Items()
        ForceAllAct1Aliases()
        SyncAllCaliforniaPersistentCoords()
        EnableMnemosyneAndVault13()
        Actor p = Game.GetPlayer()
        Cell v15C = Game.GetFormFromFile(0x00002500, "Vault13Chronicles.esp") as Cell
        if stg >= 20 && p != None && v15C != None && p.GetParentCell() == v15C
            SetVault15State(true)
        endif
    endif
    if (stg == 15 || stg == 16) && !portalMenuClicked
        if Self.IsObjectiveDisplayed(16)
            Self.SetObjectiveDisplayed(16, false, false)
        endif
        if Self.IsObjectiveCompleted(15)
            Self.SetObjectiveCompleted(15, false)
        endif
        if !Self.IsObjectiveDisplayed(15)
            Self.SetObjectiveDisplayed(15, true, false)
        endif
        Self.SetActive(true)
    elseif (stg == 15 || stg == 16) && portalMenuClicked
        ForceQuestAlias(8, 0x00002003)
        Self.SetObjectiveCompleted(15, true)
        if Self.IsObjectiveDisplayed(15)
            Self.SetObjectiveDisplayed(15, false, false)
        endif
        if !Self.IsObjectiveDisplayed(16)
            Self.SetObjectiveDisplayed(16, true, false)
        endif
        Self.SetActive(true)
    elseif stg >= 20 && stg < 30
        Actor pLoad = Game.GetPlayer()
        WorldSpace v13WLoad = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
        Cell v15CLoad = Game.GetFormFromFile(0x00002500, "Vault13Chronicles.esp") as Cell
        bool leftV13Load = (pLoad != None && ((v13WLoad != None && pLoad.GetWorldSpace() == v13WLoad) || (v15CLoad != None && pLoad.GetParentCell() == v15CLoad)))
        if leftV13Load
            Self.SetObjectiveCompleted(20, true)
            if !Self.IsObjectiveDisplayed(21)
                Self.SetObjectiveDisplayed(21, true, false)
            endif
        else
            if !Self.IsObjectiveDisplayed(20)
                Self.SetObjectiveDisplayed(20, true, false)
            endif
        endif
        Self.SetActive(true)
    elseif stg == 30
        Self.SetObjectiveCompleted(20, true)
        if Self.IsObjectiveDisplayed(21)
            Self.SetObjectiveCompleted(21, true)
        endif
        if !Self.IsObjectiveDisplayed(30)
            Self.SetObjectiveDisplayed(30, true, false)
        endif
        Self.SetActive(true)
    elseif stg == 35 || stg == 38
        Self.SetObjectiveCompleted(20, true)
        if Self.IsObjectiveDisplayed(21)
            Self.SetObjectiveCompleted(21, true)
        endif
        Self.SetObjectiveCompleted(30, true)
        Self.SetObjectiveCompleted(35, true)
        Self.SetObjectiveDisplayed(35, false, false)
        Self.SetStage(40)
        stg = 40
    endif
    StartTimer(1.5, 1)
    if stg >= 40 || hydroCoreAnalyzedInTerm
        Scene act1RetScLoad = Game.GetFormFromFile(0x00004101, "Vault13Chronicles.esp") as Scene
        if act1RetScLoad != None && act1RetScLoad.IsPlaying()
            act1RetScLoad.Stop()
        endif
        if Self.GetStage() < 40
            Self.SetStage(40)
        endif
        ApplyV13Act1Stage(40)
        Quest act2QLoad = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as Quest
        if act2QLoad != None
            if !act2QLoad.IsRunning()
                act2QLoad.Start()
            endif
            if act2QLoad.GetStage() < 15
                act2QLoad.SetStage(15)
            endif
        endif
        V13Act2QuestScript act2S = act2QLoad as V13Act2QuestScript
        if act2S != None
            act2S.WakeUpAct2()
        endif
    endif
EndEvent

Event Actor.OnItemEquipped(Actor akSender, Form akBaseObject, ObjectReference akReference)
    Form colt6520 = Game.GetFormFromFile(0x00001102, "Vault13Chronicles.esp")
    Form alienBlaster = Game.GetFormFromFile(0x0000110F, "Vault13Chronicles.esp")
    Form redRyderLE = Game.GetFormFromFile(0x00001117, "Vault13Chronicles.esp")
    if colt6520 != None && akBaseObject == colt6520
        EffectShader constFX = Game.GetFormFromFile(0x002494E4, "Fallout4.esm") as EffectShader
        if constFX != None
            constFX.Play(akSender, 0.7)
        endif
        Debug.Notification("[Colt 6520 10mm] Standard-issue Vault 13 sidearm ready: Kinetic discharge every 3 hits (+25 AP)")
    elseif alienBlaster != None && akBaseObject == alienBlaster
        EffectShader constFX2 = Game.GetFormFromFile(0x002494E4, "Fallout4.esm") as EffectShader
        if constFX2 != None
            constFX2.Play(akSender, 0.7)
        endif
        Debug.Notification("[Alien Blaster - Area 51] Fallout 1 extraterrestrial weapon active: Plasma overload every 3 hits (+35 AP / +25 HP)")
    elseif redRyderLE != None && akBaseObject == redRyderLE
        EffectShader constFX3 = Game.GetFormFromFile(0x002494E4, "Fallout4.esm") as EffectShader
        if constFX3 != None
            constFX3.Play(akSender, 0.7)
        endif
        Debug.Notification("[Red Ryder LE BB Gun] Bob's limited-edition carbine ready: Armor-piercing critical strike every 4 shots (+25 AP / +15 HP)")
    endif
EndEvent

Function ReturnPlayerToCommonwealthFromTerminal()
    if bMenuReturnBusy
        return
    endif
    bMenuReturnBusy = true
    SyncVault13ExpeditionDoors()
    StartTimer(0.35, 5)
EndFunction

Function SetSingleMapMarkerState(int aiMarkerFid, bool abVisited, bool abShowOnMap)
    ObjectReference mk = Game.GetFormFromFile(aiMarkerFid, "Vault13Chronicles.esp") as ObjectReference
    if mk == None
        return
    endif
    if mk.IsDisabled()
        mk.Enable(false)
    endif
    if abVisited
        if !mk.CanFastTravelToMarker()
            mk.AddToMap(true)
            mk.EnableFastTravel(true)
        endif
    elseif abShowOnMap
        if !mk.IsMapMarkerVisible()
            mk.AddToMap(false)
        endif
    endif
EndFunction

Function SyncAllCaliforniaPersistentCoords()
    Actor player = Game.GetPlayer()
    WorldSpace v13World = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    bool playerInExt = (player != None && v13World != None && player.GetWorldSpace() == v13World)

    ObjectReference sync3405 = Game.GetFormFromFile(0x00003405, "Vault13Chronicles.esp") as ObjectReference
    if sync3405 != None
        if Math.Abs(sync3405.GetPositionX() - (-3200.0)) > 10.0 || Math.Abs(sync3405.GetPositionY() - 13220.0) > 10.0
            sync3405.SetPosition(-3200.0, 13220.0, 320.0)
            sync3405.SetAngle(0.0, 0.0, 180.0)
        endif
    endif

    ; 1. Synchronize all 31 Fast-Travel Arrival Markers (0x00003510..0x0000352E)
    float[] ftX = new float[31]
    float[] ftY = new float[31]
    float[] ftZ = new float[31]
    ftX[0] = -3200.0
    ftY[0] = 13220.0
    ftZ[0] = 320.0
    ftX[1] = -3200.0
    ftY[1] = 13220.0
    ftZ[1] = 320.0
    ftX[2] = 2400.0
    ftY[2] = 9420.0
    ftZ[2] = 160.0
    ftX[3] = 12600.0
    ftY[3] = 6740.0
    ftZ[3] = 240.0
    ftX[4] = 11400.0
    ftY[4] = -2520.0
    ftZ[4] = 0.0
    ftX[5] = 13600.0
    ftY[5] = -2120.0
    ftZ[5] = 0.0
    ftX[6] = 10400.0
    ftY[6] = -4320.0
    ftZ[6] = 0.0
    ftX[7] = 12000.0
    ftY[7] = 680.0
    ftZ[7] = 0.0
    ftX[8] = -9800.0
    ftY[8] = -2720.0
    ftZ[8] = 120.0
    ftX[9] = -9800.0
    ftY[9] = 13280.0
    ftZ[9] = 280.0
    ftX[10] = -4800.0
    ftY[10] = -13320.0
    ftZ[10] = 40.0
    ftX[11] = -6200.0
    ftY[11] = 13460.0
    ftZ[11] = 320.0
    ftX[12] = 3600.0
    ftY[12] = 3840.0
    ftZ[12] = 80.0
    ftX[13] = -800.0
    ftY[13] = -3760.0
    ftZ[13] = 80.0
    ftX[14] = 8200.0
    ftY[14] = 7620.0
    ftZ[14] = 200.0
    ftX[15] = -8400.0
    ftY[15] = -8820.0
    ftZ[15] = 120.0
    ftX[16] = 600.0
    ftY[16] = -12780.0
    ftZ[16] = 40.0
    ftX[17] = 6400.0
    ftY[17] = 13440.0
    ftZ[17] = 160.0
    ftX[18] = 10400.0
    ftY[18] = 13040.0
    ftZ[18] = 200.0
    ftX[19] = 14200.0
    ftY[19] = 10440.0
    ftZ[19] = 200.0
    ftX[20] = -9200.0
    ftY[20] = 1840.0
    ftZ[20] = 80.0
    ftX[21] = -2760.0
    ftY[21] = 5240.0
    ftZ[21] = 80.0
    ftX[22] = -1600.0
    ftY[22] = 880.0
    ftZ[22] = 80.0
    ftX[23] = -4800.0
    ftY[23] = -6480.0
    ftZ[23] = 102.0
    ftX[24] = -11940.0
    ftY[24] = 7080.0
    ftZ[24] = 160.0
    ftX[25] = 4460.0
    ftY[25] = -5720.0
    ftZ[25] = 48.0
    ftX[26] = -7780.0
    ftY[26] = 7260.0
    ftZ[26] = 160.0
    ftX[27] = 11840.0
    ftY[27] = -12340.0
    ftZ[27] = 160.0
    ftX[28] = 8080.0
    ftY[28] = 2960.0
    ftZ[28] = 80.0
    ftX[29] = 2360.0
    ftY[29] = -580.0
    ftZ[29] = 80.0
    ftX[30] = 6800.0
    ftY[30] = -10720.0
    ftZ[30] = 40.0

    int fIdx = 0
    while fIdx < 31
        ObjectReference ftRef = Game.GetFormFromFile(0x00003510 + fIdx, "Vault13Chronicles.esp") as ObjectReference
        if ftRef != None
            if ftRef.IsDisabled()
                ftRef.Enable(false)
            endif
            if Math.Abs(ftRef.GetPositionX() - ftX[fIdx]) > 10.0 || Math.Abs(ftRef.GetPositionY() - ftY[fIdx]) > 10.0 || Math.Abs(ftRef.GetPositionZ() - ftZ[fIdx]) > 10.0
                ftRef.SetPosition(ftX[fIdx], ftY[fIdx], ftZ[fIdx])
            endif
        endif
        fIdx += 1
    endwhile

    ; 2. Synchronize all 11 Surface Load Doors (0x00003500..0x0000350A) to their 3D concrete bunker doorframes
    float[] sdX = new float[11]
    float[] sdY = new float[11]
    float[] sdZ = new float[11]
    int[] sdFtFid = new int[11]
    sdX[0] = -6200.0
    sdY[0] = 13600.0
    sdZ[0] = 320.0
    sdFtFid[0] = 0x0000351B
    sdX[1] = -3200.0
    sdY[1] = 13360.0
    sdZ[1] = 320.0
    sdFtFid[1] = 0x00003511
    sdX[2] = 12600.0
    sdY[2] = 6880.0
    sdZ[2] = 240.0
    sdFtFid[2] = 0x00003513
    sdX[3] = 11400.0
    sdY[3] = -2380.0
    sdZ[3] = 0.0
    sdFtFid[3] = 0x00003514
    sdX[4] = 13600.0
    sdY[4] = -1980.0
    sdZ[4] = 0.0
    sdFtFid[4] = 0x00003515
    sdX[5] = 10400.0
    sdY[5] = -4180.0
    sdZ[5] = 0.0
    sdFtFid[5] = 0x00003516
    sdX[6] = 12000.0
    sdY[6] = 820.0
    sdZ[6] = 0.0
    sdFtFid[6] = 0x00003517
    sdX[7] = -9800.0
    sdY[7] = -2580.0
    sdZ[7] = 120.0
    sdFtFid[7] = 0x00003518
    sdX[8] = -9800.0
    sdY[8] = 13420.0
    sdZ[8] = 280.0
    sdFtFid[8] = 0x00003519
    sdX[9] = -4800.0
    sdY[9] = -13180.0
    sdZ[9] = 40.0
    sdFtFid[9] = 0x0000351A
    sdX[10] = -2600.0
    sdY[10] = 13160.0
    sdZ[10] = -3000.0
    sdFtFid[10] = 0x00003511

    int movePlayerToFtFid = 0
    int sIdx = 0
    while sIdx < 11
        ObjectReference sdRef = Game.GetFormFromFile(0x00003500 + sIdx, "Vault13Chronicles.esp") as ObjectReference
        if sdRef != None
            if sIdx == 10
                if !sdRef.IsDisabled()
                    sdRef.Disable(false)
                endif
                if Math.Abs(sdRef.GetPositionZ() - sdZ[sIdx]) > 10.0
                    sdRef.SetPosition(sdX[sIdx], sdY[sIdx], sdZ[sIdx])
                endif
                ObjectReference b0064 = Game.GetFormFromFile(0x000B0064, "Vault13Chronicles.esp") as ObjectReference
                if b0064 != None && !b0064.IsDisabled()
                    int dbIdx = 0
                    while dbIdx < 50
                        ObjectReference dbPiece = Game.GetFormFromFile(0x000B0064 + dbIdx, "Vault13Chronicles.esp") as ObjectReference
                        if dbPiece != None && !dbPiece.IsDisabled()
                            dbPiece.Disable(false)
                        endif
                        dbIdx += 1
                    endwhile
                endif
                ObjectReference oldCaveTerm = Game.GetFormFromFile(0x00002230, "Vault13Chronicles.esp") as ObjectReference
                if oldCaveTerm != None && !oldCaveTerm.IsDisabled()
                    oldCaveTerm.SetPosition(850.0, -4220.0, -3000.0)
                    oldCaveTerm.Disable(false)
                endif
                ObjectReference oldCaveDeskRef = Game.GetFormFromFile(0x00030405, "Vault13Chronicles.esp") as ObjectReference
                if oldCaveDeskRef != None && !oldCaveDeskRef.IsDisabled()
                    oldCaveDeskRef.SetPosition(850.0, -4220.0, -3000.0)
                    oldCaveDeskRef.Disable(false)
                endif
            elseif Math.Abs(sdRef.GetPositionX() - sdX[sIdx]) > 10.0 || Math.Abs(sdRef.GetPositionY() - sdY[sIdx]) > 10.0 || Math.Abs(sdRef.GetPositionZ() - sdZ[sIdx]) > 10.0
                if playerInExt && player.GetDistance(sdRef) < 950.0
                    movePlayerToFtFid = sdFtFid[sIdx]
                endif
                sdRef.SetPosition(sdX[sIdx], sdY[sIdx], sdZ[sIdx])
                sdRef.SetAngle(0.0, 0.0, 0.0)
            endif
        endif
        sIdx += 1
    endwhile

    if movePlayerToFtFid != 0 && player != None
        ObjectReference dstFt = Game.GetFormFromFile(movePlayerToFtFid, "Vault13Chronicles.esp") as ObjectReference
        if dstFt != None
            player.MoveTo(dstFt, 0.0, 0.0, 0.0, true)
        endif
    endif

    ; 3. Synchronize all 31 Pip-Boy MapMarkers (0x00003410..0x0000342E) across the full 8x8 worldspace
    float[] mkX = new float[31]
    float[] mkY = new float[31]
    float[] mkZ = new float[31]
    mkX[0] = -3200.0
    mkY[0] = 13600.0
    mkZ[0] = 320.0
    mkX[1] = -2600.0
    mkY[1] = 13200.0
    mkZ[1] = 320.0
    mkX[2] = 2400.0
    mkY[2] = 9600.0
    mkZ[2] = 160.0
    mkX[3] = 12600.0
    mkY[3] = 6800.0
    mkZ[3] = 240.0
    mkX[4] = 11400.0
    mkY[4] = -2400.0
    mkZ[4] = 0.0
    mkX[5] = 13600.0
    mkY[5] = -2000.0
    mkZ[5] = 0.0
    mkX[6] = 10400.0
    mkY[6] = -4200.0
    mkZ[6] = 0.0
    mkX[7] = 12000.0
    mkY[7] = 800.0
    mkZ[7] = 0.0
    mkX[8] = -9800.0
    mkY[8] = -2600.0
    mkZ[8] = 120.0
    mkX[9] = -9800.0
    mkY[9] = 13400.0
    mkZ[9] = 280.0
    mkX[10] = -4800.0
    mkY[10] = -13200.0
    mkZ[10] = 40.0
    mkX[11] = -6200.0
    mkY[11] = 13600.0
    mkZ[11] = 320.0
    mkX[12] = 3600.0
    mkY[12] = 3800.0
    mkZ[12] = 80.0
    mkX[13] = -800.0
    mkY[13] = -3800.0
    mkZ[13] = 80.0
    mkX[14] = 8200.0
    mkY[14] = 7800.0
    mkZ[14] = 200.0
    mkX[15] = -8400.0
    mkY[15] = -8600.0
    mkZ[15] = 120.0
    mkX[16] = 600.0
    mkY[16] = -12800.0
    mkZ[16] = 40.0
    mkX[17] = -11600.0
    mkY[17] = 7400.0
    mkZ[17] = 160.0
    mkX[18] = 4800.0
    mkY[18] = -5400.0
    mkZ[18] = 48.0
    mkX[19] = -7400.0
    mkY[19] = 7600.0
    mkZ[19] = 160.0
    mkX[20] = 12400.0
    mkY[20] = -11800.0
    mkZ[20] = 160.0
    mkX[21] = 8400.0
    mkY[21] = 3200.0
    mkZ[21] = 80.0
    mkX[22] = 2600.0
    mkY[22] = -400.0
    mkZ[22] = 80.0
    mkX[23] = 6400.0
    mkY[23] = 13800.0
    mkZ[23] = 160.0
    mkX[24] = 10400.0
    mkY[24] = 13400.0
    mkZ[24] = 200.0
    mkX[25] = 14200.0
    mkY[25] = 10800.0
    mkZ[25] = 200.0
    mkX[26] = -9200.0
    mkY[26] = 2200.0
    mkZ[26] = 80.0
    mkX[27] = -2800.0
    mkY[27] = 5600.0
    mkZ[27] = 80.0
    mkX[28] = -1600.0
    mkY[28] = 1200.0
    mkZ[28] = 80.0
    mkX[29] = -4800.0
    mkY[29] = -6180.0
    mkZ[29] = 102.0
    mkX[30] = 6800.0
    mkY[30] = -10400.0
    mkZ[30] = 40.0

    int mIdx = 0
    while mIdx < 31
        ObjectReference mkRef = Game.GetFormFromFile(0x00003410 + mIdx, "Vault13Chronicles.esp") as ObjectReference
        if mkRef != None
            if Math.Abs(mkRef.GetPositionX() - mkX[mIdx]) > 10.0 || Math.Abs(mkRef.GetPositionY() - mkY[mIdx]) > 10.0 || Math.Abs(mkRef.GetPositionZ() - mkZ[mIdx]) > 10.0
                mkRef.SetPosition(mkX[mIdx], mkY[mIdx], mkZ[mIdx])
                mkRef.SetAngle(0.0, 0.0, 0.0)
            endif
        endif
        mIdx += 1
    endwhile

    ; 4. Synchronize 28 Roaming Wasteland Creatures (0x00003580..0x0000359B) and 5 Settlement Ambient Actors
    float[] ecX = new float[28]
    float[] ecY = new float[28]
    float[] ecZ = new float[28]
    ecX[0] = -1200.0
    ecY[0] = 12800.0
    ecZ[0] = 270.0
    ecX[1] = -400.0
    ecY[1] = 12200.0
    ecZ[1] = 254.0
    ecX[2] = 560.0
    ecY[2] = 11360.0
    ecZ[2] = 166.0
    ecX[3] = 10400.0
    ecY[3] = 7400.0
    ecZ[3] = 246.0
    ecX[4] = 10800.0
    ecY[4] = 7100.0
    ecZ[4] = 246.0
    ecX[5] = 11200.0
    ecY[5] = 6800.0
    ecZ[5] = 246.0
    ecX[6] = 10850.0
    ecY[6] = -150.0
    ecZ[6] = 6.0
    ecX[7] = 12150.0
    ecY[7] = -600.0
    ecZ[7] = 6.0
    ecX[8] = 10950.0
    ecY[8] = -2750.0
    ecZ[8] = 6.0
    ecX[9] = 12450.0
    ecY[9] = -2350.0
    ecZ[9] = 6.0
    ecX[10] = 10550.0
    ecY[10] = -3100.0
    ecZ[10] = 6.0
    ecX[11] = 9100.0
    ecY[11] = -1800.0
    ecZ[11] = 6.0
    ecX[12] = -8200.0
    ecY[12] = 10800.0
    ecZ[12] = 310.0
    ecX[13] = -9450.0
    ecY[13] = 13160.0
    ecZ[13] = 286.0
    ecX[14] = -9600.0
    ecY[14] = -400.0
    ecZ[14] = 142.0
    ecX[15] = -6200.0
    ecY[15] = -11200.0
    ecZ[15] = 46.0
    ecX[16] = -1600.0
    ecY[16] = 12600.0
    ecZ[16] = 318.0
    ecX[17] = -800.0
    ecY[17] = 11800.0
    ecZ[17] = 254.0
    ecX[18] = -880.0
    ecY[18] = 10960.0
    ecZ[18] = 190.0
    ecX[19] = 600.0
    ecY[19] = 11800.0
    ecZ[19] = 174.0
    ecX[20] = 4800.0
    ecY[20] = 11600.0
    ecZ[20] = 166.0
    ecX[21] = 10600.0
    ecY[21] = 7800.0
    ecZ[21] = 246.0
    ecX[22] = 10680.0
    ecY[22] = 7250.0
    ecZ[22] = 246.0
    ecX[23] = 11600.0
    ecY[23] = 9200.0
    ecZ[23] = 222.0
    ecX[24] = 12400.0
    ecY[24] = 9600.0
    ecZ[24] = 198.0
    ecX[25] = -6200.0
    ecY[25] = 3800.0
    ecZ[25] = 166.0
    ecX[26] = -6600.0
    ecY[26] = 3400.0
    ecZ[26] = 166.0
    ecX[27] = -5800.0
    ecY[27] = -4800.0
    ecZ[27] = 102.0

    int ecI = 0
    while ecI < 28
        Actor ecA = Game.GetFormFromFile(0x00003580 + ecI, "Vault13Chronicles.esp") as Actor
        if ecA != None && !ecA.IsDead()
            float curEcX = ecA.GetPositionX()
            float curEcY = ecA.GetPositionY()
            bool trappedInBunker = (curEcX >= 10970.0 && curEcX <= 11950.0 && curEcY >= -2440.0 && curEcY <= -1620.0) || (curEcX >= 13170.0 && curEcX <= 14150.0 && curEcY >= -2040.0 && curEcY <= -1220.0) || (curEcX >= 9970.0 && curEcX <= 10950.0 && curEcY >= -4240.0 && curEcY <= -3420.0) || (curEcX >= 11570.0 && curEcX <= 12550.0 && curEcY >= 760.0 && curEcY <= 1580.0)
            if trappedInBunker || (!ecA.IsInCombat() && (Math.Abs(curEcX - ecX[ecI]) > 95.0 || Math.Abs(curEcY - ecY[ecI]) > 95.0))
                ecA.SetPosition(ecX[ecI], ecY[ecI], ecZ[ecI])
            endif
        endif
        ecI += 1
    endwhile

    int[] ambFids = new int[5]
    float[] ambX = new float[5]
    float[] ambY = new float[5]
    float[] ambZ = new float[5]
    ambFids[0] = 0x000035B0
    ambX[0] = 2780.0
    ambY[0] = 8980.0
    ambZ[0] = 160.0
    ambFids[1] = 0x000035B1
    ambX[1] = 2960.0
    ambY[1] = 9040.0
    ambZ[1] = 160.0
    ambFids[2] = 0x000035B2
    ambX[2] = 2920.0
    ambY[2] = 8880.0
    ambZ[2] = 160.0
    ambFids[3] = 0x000035C3
    ambX[3] = 3740.0
    ambY[3] = 4260.0
    ambZ[3] = 80.0
    ambFids[4] = 0x000035CD
    ambX[4] = -980.0
    ambY[4] = -4260.0
    ambZ[4] = 80.0
    int aIdx = 0
    while aIdx < 5
        Actor ambAct = Game.GetFormFromFile(ambFids[aIdx], "Vault13Chronicles.esp") as Actor
        if ambAct != None && !ambAct.IsDead() && !ambAct.IsDisabled() && !ambAct.IsInCombat()
            if Math.Abs(ambAct.GetPositionX() - ambX[aIdx]) > 120.0 || Math.Abs(ambAct.GetPositionY() - ambY[aIdx]) > 120.0
                ambAct.SetPosition(ambX[aIdx], ambY[aIdx], ambZ[aIdx])
            endif
        endif
        aIdx += 1
    endwhile
    Quest junktownQ = Game.GetFormFromFile(0x00010000, "Vault13Chronicles.esp") as Quest
    V13SideQuestJunktownScript junktownS = junktownQ as V13SideQuestJunktownScript
    Actor dogShady = Game.GetFormFromFile(0x000035B3, "Vault13Chronicles.esp") as Actor
    if dogShady != None && !dogShady.IsDead() && !dogShady.IsInCombat()
        if junktownS == None || !junktownS.IsDogmeatRecruited()
            if Math.Abs(dogShady.GetPositionX() - 2600.0) > 120.0 || Math.Abs(dogShady.GetPositionY() - 9600.0) > 120.0
                dogShady.SetPosition(2600.0, 9600.0, 160.0)
            endif
        endif
    endif

    int[] npcFids = new int[10]
    float[] npcX = new float[10]
    float[] npcY = new float[10]
    float[] npcZ = new float[10]
    float[] npcAng = new float[10]
    npcFids[0] = 0x000035A0
    npcX[0] = 2250.0
    npcY[0] = 9690.0
    npcZ[0] = 160.0
    npcAng[0] = 180.0
    npcFids[1] = 0x000035C0
    npcX[1] = 3850.0
    npcY[1] = 3820.0
    npcZ[1] = 80.0
    npcAng[1] = 225.0
    npcFids[2] = 0x000035C1
    npcX[2] = 3310.0
    npcY[2] = 3820.0
    npcZ[2] = 80.0
    npcAng[2] = 90.0
    npcFids[3] = 0x000035C7
    npcX[3] = -660.0
    npcY[3] = -3820.0
    npcZ[3] = 80.0
    npcAng[3] = 270.0
    npcFids[4] = 0x000035C8
    npcX[4] = -920.0
    npcY[4] = -3700.0
    npcZ[4] = 80.0
    npcAng[4] = 135.0
    npcFids[5] = 0x000035D6
    npcX[5] = 1020.0
    npcY[5] = -12780.0
    npcZ[5] = 40.0
    npcAng[5] = 270.0
    npcFids[6] = 0x000035E6
    npcX[6] = -760.0
    npcY[6] = -4250.0
    npcZ[6] = 80.0
    npcAng[6] = 0.0
    npcFids[7] = 0x000035E7
    npcX[7] = -1040.0
    npcY[7] = -4020.0
    npcZ[7] = 80.0
    npcAng[7] = 45.0
    npcFids[8] = 0x000035E8
    npcX[8] = -1390.0
    npcY[8] = -4200.0
    npcZ[8] = 80.0
    npcAng[8] = 90.0
    npcFids[9] = 0x000035E9
    npcX[9] = -1340.0
    npcY[9] = -4100.0
    npcZ[9] = 80.0
    npcAng[9] = 90.0
    int nIdx = 0
    while nIdx < 10
        Actor sNpc = Game.GetFormFromFile(npcFids[nIdx], "Vault13Chronicles.esp") as Actor
        if sNpc != None && !sNpc.IsDead() && !sNpc.IsDisabled() && !sNpc.IsInCombat() && !sNpc.IsTalking()
            if Math.Abs(sNpc.GetPositionX() - npcX[nIdx]) > 45.0 || Math.Abs(sNpc.GetPositionY() - npcY[nIdx]) > 45.0
                sNpc.SetPosition(npcX[nIdx], npcY[nIdx], npcZ[nIdx])
                sNpc.SetAngle(0.0, 0.0, npcAng[nIdx])
                sNpc.EvaluatePackage()
            elseif sNpc.Is3DLoaded()
                float angDiff = Math.Abs(sNpc.GetAngleZ() - npcAng[nIdx])
                if angDiff > 35.0 && angDiff < 325.0
                    sNpc.SetAngle(0.0, 0.0, npcAng[nIdx])
                endif
            endif
        endif
        nIdx += 1
    endwhile
EndFunction

Function UpdateSouthernCaliforniaMapMarkers()
    Actor player = Game.GetPlayer()
    if player == None
        return
    endif

    int[] allModCells = new int[11]
    allModCells[0] = 0x00002000
    allModCells[1] = 0x00002100
    allModCells[2] = 0x00002200
    allModCells[3] = 0x00002500
    allModCells[4] = 0x00002900
    allModCells[5] = 0x00002A00
    allModCells[6] = 0x00002B00
    allModCells[7] = 0x00002C00
    allModCells[8] = 0x00002D00
    allModCells[9] = 0x00002E00
    allModCells[10] = 0x00002F00
    int cIdx = 0
    while cIdx < 11
        Cell modC = Game.GetFormFromFile(allModCells[cIdx], "Vault13Chronicles.esp") as Cell
        if modC != None
            modC.EnableFastTravel(true)
        endif
        cIdx += 1
    endwhile

    Cell pCell = player.GetParentCell()
    Cell c2100 = Game.GetFormFromFile(0x00002100, "Vault13Chronicles.esp") as Cell
    Cell c2200 = Game.GetFormFromFile(0x00002200, "Vault13Chronicles.esp") as Cell
    Cell c2500 = Game.GetFormFromFile(0x00002500, "Vault13Chronicles.esp") as Cell
    Cell c2900 = Game.GetFormFromFile(0x00002900, "Vault13Chronicles.esp") as Cell
    Cell c2A00 = Game.GetFormFromFile(0x00002A00, "Vault13Chronicles.esp") as Cell
    Cell c2B00 = Game.GetFormFromFile(0x00002B00, "Vault13Chronicles.esp") as Cell
    Cell c2C00 = Game.GetFormFromFile(0x00002C00, "Vault13Chronicles.esp") as Cell
    Cell c2D00 = Game.GetFormFromFile(0x00002D00, "Vault13Chronicles.esp") as Cell
    Cell c2E00 = Game.GetFormFromFile(0x00002E00, "Vault13Chronicles.esp") as Cell
    Cell c2F00 = Game.GetFormFromFile(0x00002F00, "Vault13Chronicles.esp") as Cell

    Quest q2 = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as Quest
    Quest q3 = Game.GetFormFromFile(0x00006000, "Vault13Chronicles.esp") as Quest
    Quest q4 = Game.GetFormFromFile(0x00007000, "Vault13Chronicles.esp") as Quest
    Quest q5 = Game.GetFormFromFile(0x00008000, "Vault13Chronicles.esp") as Quest

    int q1Stg = Self.GetStage()
    int q2Stg = 0
    if q2 != None
        q2Stg = q2.GetStage()
    endif
    int q3Stg = 0
    if q3 != None
        q3Stg = q3.GetStage()
    endif
    int q4Stg = 0
    if q4 != None
        q4Stg = q4.GetStage()
    endif
    int q5Stg = 0
    if q5 != None
        q5Stg = q5.GetStage()
    endif

    WorldSpace v13World = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    bool inExtWorld = (v13World != None && player.GetWorldSpace() == v13World)

    ObjectReference mk3412 = Game.GetFormFromFile(0x00003412, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference mk3413 = Game.GetFormFromFile(0x00003413, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference mk3414 = Game.GetFormFromFile(0x00003414, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference mk3415 = Game.GetFormFromFile(0x00003415, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference mk3416 = Game.GetFormFromFile(0x00003416, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference mk3417 = Game.GetFormFromFile(0x00003417, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference mk3418 = Game.GetFormFromFile(0x00003418, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference mk3419 = Game.GetFormFromFile(0x00003419, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference mk341A = Game.GetFormFromFile(0x0000341A, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference mk341C = Game.GetFormFromFile(0x0000341C, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference mk341D = Game.GetFormFromFile(0x0000341D, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference mk341E = Game.GetFormFromFile(0x0000341E, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference mk341F = Game.GetFormFromFile(0x0000341F, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference mk3420 = Game.GetFormFromFile(0x00003420, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference mk3421 = Game.GetFormFromFile(0x00003421, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference mk3422 = Game.GetFormFromFile(0x00003422, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference mk3423 = Game.GetFormFromFile(0x00003423, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference mk3424 = Game.GetFormFromFile(0x00003424, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference mk3425 = Game.GetFormFromFile(0x00003425, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference mk3426 = Game.GetFormFromFile(0x00003426, "Vault13Chronicles.esp") as ObjectReference

    if (c2100 != None && pCell == c2100) || (c2200 != None && pCell == c2200) || inExtWorld || q1Stg >= 20
        visitedV13 = true
    endif
    if (c2500 != None && pCell == c2500) || (mk3412 != None && mk3412.CanFastTravelToMarker()) || (inExtWorld && mk3412 != None && player.GetDistance(mk3412) < 850.0) || q1Stg >= 30
        if !visitedShadyPass && mk3412 != None && !mk3412.CanFastTravelToMarker() && ((c2500 != None && pCell == c2500) || inExtWorld)
            Game.RewardPlayerXP(25, false)
        endif
        visitedShadyPass = true
    endif
    if (c2500 != None && pCell == c2500 && player.GetPositionY() < -8400.0) || (mk3413 != None && mk3413.CanFastTravelToMarker()) || (inExtWorld && mk3413 != None && player.GetDistance(mk3413) < 850.0) || q1Stg >= 30
        if !visitedV15 && mk3413 != None && !mk3413.CanFastTravelToMarker() && ((c2500 != None && pCell == c2500) || inExtWorld)
            Game.RewardPlayerXP(25, false)
        endif
        visitedV15 = true
    endif
    if (c2A00 != None && pCell == c2A00) || (mk3414 != None && mk3414.CanFastTravelToMarker()) || (inExtWorld && mk3414 != None && player.GetDistance(mk3414) < 850.0) || q2Stg >= 21
        if !visitedNecroSub && mk3414 != None && !mk3414.CanFastTravelToMarker() && ((c2A00 != None && pCell == c2A00) || inExtWorld)
            Game.RewardPlayerXP(25, false)
        endif
        visitedNecroSub = true
    endif
    if (c2E00 != None && pCell == c2E00) || (mk3415 != None && mk3415.CanFastTravelToMarker()) || (inExtWorld && mk3415 != None && player.GetDistance(mk3415) < 850.0) || q2Stg >= 23
        if !visitedHallDead && mk3415 != None && !mk3415.CanFastTravelToMarker() && ((c2E00 != None && pCell == c2E00) || inExtWorld)
            Game.RewardPlayerXP(25, false)
        endif
        visitedHallDead = true
    endif
    if (c2F00 != None && pCell == c2F00) || (mk3416 != None && mk3416.CanFastTravelToMarker()) || (inExtWorld && mk3416 != None && player.GetDistance(mk3416) < 850.0) || q2Stg >= 25
        if !visitedNecroSewers && mk3416 != None && !mk3416.CanFastTravelToMarker() && ((c2F00 != None && pCell == c2F00) || inExtWorld)
            Game.RewardPlayerXP(25, false)
        endif
        visitedNecroSewers = true
    endif
    if (c2900 != None && pCell == c2900) || (mk3417 != None && mk3417.CanFastTravelToMarker()) || (inExtWorld && mk3417 != None && player.GetDistance(mk3417) < 850.0) || q2Stg >= 27
        if !visitedV12Watershed && mk3417 != None && !mk3417.CanFastTravelToMarker() && ((c2900 != None && pCell == c2900) || inExtWorld)
            Game.RewardPlayerXP(25, false)
        endif
        visitedV12Watershed = true
    endif
    if (c2B00 != None && pCell == c2B00) || (mk3418 != None && mk3418.CanFastTravelToMarker()) || (inExtWorld && mk3418 != None && player.GetDistance(mk3418) < 850.0) || q3Stg >= 30
        if !visitedLostHills && mk3418 != None && !mk3418.CanFastTravelToMarker() && ((c2B00 != None && pCell == c2B00) || inExtWorld)
            Game.RewardPlayerXP(25, false)
        endif
        visitedLostHills = true
    endif
    if (c2C00 != None && pCell == c2C00) || (mk3419 != None && mk3419.CanFastTravelToMarker()) || (inExtWorld && mk3419 != None && player.GetDistance(mk3419) < 850.0) || q4Stg >= 30
        if !visitedMariposa && mk3419 != None && !mk3419.CanFastTravelToMarker() && ((c2C00 != None && pCell == c2C00) || inExtWorld)
            Game.RewardPlayerXP(25, false)
        endif
        visitedMariposa = true
    endif
    if (c2D00 != None && pCell == c2D00) || (mk341A != None && mk341A.CanFastTravelToMarker()) || (inExtWorld && mk341A != None && player.GetDistance(mk341A) < 850.0) || q5Stg >= 30
        if !visitedCathedral && mk341A != None && !mk341A.CanFastTravelToMarker() && ((c2D00 != None && pCell == c2D00) || inExtWorld)
            Game.RewardPlayerXP(25, false)
        endif
        visitedCathedral = true
    endif

    if IsPlayerInAny2161Cell() || worldMap2161Synced
        SetSingleMapMarkerState(0x00003410, visitedV13, true)
        SetSingleMapMarkerState(0x00003411, visitedV13, true)
        SetSingleMapMarkerState(0x00003412, visitedShadyPass, true)
        SetSingleMapMarkerState(0x00003413, visitedV15, true)
        SetSingleMapMarkerState(0x00003414, visitedNecroSub, true)
        SetSingleMapMarkerState(0x00003415, visitedHallDead, true)
        SetSingleMapMarkerState(0x00003416, visitedNecroSewers, true)
        SetSingleMapMarkerState(0x00003417, visitedV12Watershed, true)
        SetSingleMapMarkerState(0x00003418, visitedLostHills, true)
        SetSingleMapMarkerState(0x00003419, visitedMariposa, true)
        SetSingleMapMarkerState(0x0000341A, visitedCathedral, true)
        SetSingleMapMarkerState(0x0000341B, (bunkerVisited || visitedV13), true)
        SetSingleMapMarkerState(0x0000341C, (mk341C != None && mk341C.CanFastTravelToMarker()), true)
        SetSingleMapMarkerState(0x0000341D, (mk341D != None && mk341D.CanFastTravelToMarker()), true)
        SetSingleMapMarkerState(0x0000341E, (mk341E != None && mk341E.CanFastTravelToMarker()), true)
        SetSingleMapMarkerState(0x0000341F, (mk341F != None && mk341F.CanFastTravelToMarker()), true)
        SetSingleMapMarkerState(0x00003420, (mk3420 != None && mk3420.CanFastTravelToMarker()), true)
        SetSingleMapMarkerState(0x00003421, (mk3421 != None && mk3421.CanFastTravelToMarker()), true)
        SetSingleMapMarkerState(0x00003422, (mk3422 != None && mk3422.CanFastTravelToMarker()), true)
        SetSingleMapMarkerState(0x00003423, (mk3423 != None && mk3423.CanFastTravelToMarker()), true)
        SetSingleMapMarkerState(0x00003424, (mk3424 != None && mk3424.CanFastTravelToMarker()), true)
        SetSingleMapMarkerState(0x00003425, (mk3425 != None && mk3425.CanFastTravelToMarker()), true)
        SetSingleMapMarkerState(0x00003426, (mk3426 != None && mk3426.CanFastTravelToMarker()), true)
        int extMkFid = 0x00003427
        while extMkFid <= 0x0000342E
            ObjectReference extMk = Game.GetFormFromFile(extMkFid, "Vault13Chronicles.esp") as ObjectReference
            bool bExtVis = (extMk != None && (extMk.CanFastTravelToMarker() || (inExtWorld && player.GetDistance(extMk) < 950.0)))
            SetSingleMapMarkerState(extMkFid, bExtVis, true)
            extMkFid += 1
        endwhile
    endif
    SetSingleMapMarkerState(0x0000300A, visitedV13, visitedV13)
EndFunction

bool Function IsPlayerInAny2161Cell()
    Actor player = Game.GetPlayer()
    if player == None
        return false
    endif
    WorldSpace v13World = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if v13World != None && player.GetWorldSpace() == v13World
        return true
    endif
    Cell pCell = player.GetParentCell()
    if pCell == None
        return false
    endif
    int[] cells2161 = new int[10]
    cells2161[0] = 0x00002100
    cells2161[1] = 0x00002200
    cells2161[2] = 0x00002500
    cells2161[3] = 0x00002900
    cells2161[4] = 0x00002A00
    cells2161[5] = 0x00002B00
    cells2161[6] = 0x00002C00
    cells2161[7] = 0x00002D00
    cells2161[8] = 0x00002E00
    cells2161[9] = 0x00002F00
    int idx = 0
    while idx < 10
        Cell c = Game.GetFormFromFile(cells2161[idx], "Vault13Chronicles.esp") as Cell
        if c != None && pCell == c
            return true
        endif
        idx += 1
    endwhile
    return false
EndFunction

Function BindRadioQuestActive()
    ObjectReference kHubTx = Game.GetFormFromFile(0x0000321F, "Vault13Chronicles.esp") as ObjectReference
    if kHubTx != None && kHubTx.IsDisabled()
        kHubTx.EnableNoWait()
    endif
    Quest radioQ = Game.GetFormFromFile(0x00008510, "Vault13Chronicles.esp") as Quest
    if radioQ != None
        if !radioQ.IsRunning()
            radioQ.Start()
        endif
        if radioQ.GetStage() < 10
            radioQ.SetStage(10)
        endif
        V13RadioQuestScript rScript = radioQ as V13RadioQuestScript
        if rScript != None
            rScript.SyncRadioEnvironment()
        endif
    endif
    Quest shadyQ = Game.GetFormFromFile(0x00009500, "Vault13Chronicles.esp") as Quest
    if shadyQ != None
        if !shadyQ.IsRunning() && !shadyQ.IsCompleted()
            shadyQ.Start()
        endif
        if shadyQ.GetStage() < 10
            shadyQ.SetStage(10)
        endif
        V13SideQuestShadySandsScript shadyS = shadyQ as V13SideQuestShadySandsScript
        if shadyS != None
            shadyS.SetupShadySandsListeners()
        endif
    endif
    Quest junktownQ = Game.GetFormFromFile(0x00010000, "Vault13Chronicles.esp") as Quest
    if junktownQ != None
        V13SideQuestJunktownScript junktownS = junktownQ as V13SideQuestJunktownScript
        if junktownS != None
            junktownS.SyncDogmeatWithPlayer()
            junktownS.CheckDogmeatProximity()
        endif
    endif
    Quest tardisQ = Game.GetFormFromFile(0x00015000, "Vault13Chronicles.esp") as Quest
    if tardisQ != None
        if !tardisQ.IsRunning() && !tardisQ.IsCompleted()
            tardisQ.Start()
        endif
        if tardisQ.GetStage() < 10
            tardisQ.SetStage(10)
        endif
        V13SideQuestTardisScript tardisS = tardisQ as V13SideQuestTardisScript
        if tardisS != None
            tardisS.SetupTardisListeners()
        endif
    endif
    Quest nukaQ = Game.GetFormFromFile(0x00016000, "Vault13Chronicles.esp") as Quest
    if nukaQ != None
        if !nukaQ.IsRunning() && !nukaQ.IsCompleted()
            nukaQ.Start()
        endif
        if nukaQ.GetStage() < 10
            nukaQ.SetStage(10)
        endif
        V13SideQuestTardisScript nukaS = nukaQ as V13SideQuestTardisScript
        if nukaS != None
            nukaS.SetupTardisListeners()
        endif
    endif
    Quest alienQ = Game.GetFormFromFile(0x00017000, "Vault13Chronicles.esp") as Quest
    if alienQ != None
        if !alienQ.IsRunning() && !alienQ.IsCompleted()
            alienQ.Start()
        endif
        if alienQ.GetStage() < 10
            alienQ.SetStage(10)
        endif
        V13SideQuestTardisScript alienS = alienQ as V13SideQuestTardisScript
        if alienS != None
            alienS.SetupTardisListeners()
        endif
    endif
    Quest gfQ = Game.GetFormFromFile(0x0001B000, "Vault13Chronicles.esp") as Quest
    if gfQ != None
        if !gfQ.IsRunning() && !gfQ.IsCompleted()
            gfQ.Start()
        endif
        if gfQ.GetStage() < 10
            gfQ.SetStage(10)
        endif
        V13SideQuestTardisScript gfS = gfQ as V13SideQuestTardisScript
        if gfS != None
            gfS.SetupTardisListeners()
        endif
    endif
    Quest bmQ = Game.GetFormFromFile(0x0001C000, "Vault13Chronicles.esp") as Quest
    if bmQ != None
        if !bmQ.IsRunning() && !bmQ.IsCompleted()
            bmQ.Start()
        endif
        if bmQ.GetStage() < 10
            bmQ.SetStage(10)
        endif
        V13SideQuestTardisScript bmS = bmQ as V13SideQuestTardisScript
        if bmS != None
            bmS.SetupTardisListeners()
        endif
    endif
    Quest pcQ = Game.GetFormFromFile(0x0001D000, "Vault13Chronicles.esp") as Quest
    if pcQ != None
        if !pcQ.IsRunning() && !pcQ.IsCompleted()
            pcQ.Start()
        endif
        if pcQ.GetStage() < 10
            pcQ.SetStage(10)
        endif
        V13SideQuestTardisScript pcS = pcQ as V13SideQuestTardisScript
        if pcS != None
            pcS.SetupTardisListeners()
        endif
    endif
    Quest tandiQ = Game.GetFormFromFile(0x00018000, "Vault13Chronicles.esp") as Quest
    if tandiQ != None
        if !tandiQ.IsRunning() && !tandiQ.IsCompleted()
            tandiQ.Start()
        endif
        V13SideQuestTandiRescueScript tandiS = tandiQ as V13SideQuestTandiRescueScript
        if tandiS != None
            tandiS.SetupTandiRescueListeners()
        endif
    endif
EndFunction

bool Function IsPointInShadySandsSafeZone(float ax, float ay)
    return (ax >= 400.0 && ax <= 4400.0 && ay >= 8200.0 && ay <= 11150.0)
EndFunction

Function DriveSingleCreatureAI(Actor akActor, bool abIsNorthernLair = false)
    if akActor == None || akActor.IsDead() || akActor.IsDisabled()
        return
    endif
    akActor.EnableAI(True)
    V13WastelandCreatureAIScript cAI = (akActor as ObjectReference) as V13WastelandCreatureAIScript
    if cAI != None
        cAI.InitCreatureAI()
    endif
    if !akActor.Is3DLoaded()
        return
    endif
    if akActor.GetWorldSpace() == None
        return
    endif
    Actor kPlayer = Game.GetPlayer()
    if kPlayer == None
        return
    endif
    float px = kPlayer.GetPositionX()
    float py = kPlayer.GetPositionY()
    bool playerInShadySands = IsPointInShadySandsSafeZone(px, py)
    float fDist = akActor.GetDistance(kPlayer)

    ; While the player is inside the Shady Sands Walled Safe Zone, nearby exterior creatures stand down without teleporting
    if playerInShadySands && fDist < 1600.0
        if akActor.IsInCombat() || akActor.GetValue(Game.GetAggressionAV()) > 0.0
            akActor.SetValue(Game.GetAggressionAV(), 0.0)
            akActor.StopCombat()
            akActor.StopCombatAlarm()
        endif
        return
    endif

    akActor.SetValue(Game.GetAggressionAV(), 2.0)
    akActor.SetValue(Game.GetConfidenceAV(), 4.0)

    if fDist > 1850.0
        if akActor.IsInCombat()
            akActor.StopCombat()
        endif
        return
    endif

    if abIsNorthernLair && py < 10400.0 && fDist > 1100.0
        if akActor.IsInCombat()
            akActor.StopCombat()
        endif
        return
    endif

    if fDist < 1350.0
        if !akActor.IsDead() && !kPlayer.IsDead() && !akActor.IsInCombat()
            akActor.StartCombat(kPlayer)
        endif
    endif
EndFunction

Function UpdateExteriorWastelandCreatures()
    Actor kPlayer = Game.GetPlayer()
    if kPlayer != None && IsPointInShadySandsSafeZone(kPlayer.GetPositionX(), kPlayer.GetPositionY())
        kPlayer.StopCombatAlarm()
    endif
    ObjectReference nestRef = Game.GetFormFromFile(0x000035A9, "Vault13Chronicles.esp") as ObjectReference
    if nestRef != None && (nestRef.GetPositionX() < 5800.0 || nestRef.GetPositionY() < 13200.0)
        nestRef.SetPosition(6400.0, 13800.0, 160.0)
    endif
    int idx = 0
    while idx < 28
        Actor extC = Game.GetFormFromFile(0x00003580 + idx, "Vault13Chronicles.esp") as Actor
        if extC != None
            DriveSingleCreatureAI(extC, false)
        endif
        idx += 1
    endwhile
    int sIdx = 0
    while sIdx < 3
        Actor scorpC = Game.GetFormFromFile(0x000035A6 + sIdx, "Vault13Chronicles.esp") as Actor
        if scorpC != None
            DriveSingleCreatureAI(scorpC, true)
        endif
        sIdx += 1
    endwhile
    Actor hubDclaw = Game.GetFormFromFile(0x000035EA, "Vault13Chronicles.esp") as Actor
    if hubDclaw != None
        DriveSingleCreatureAI(hubDclaw, false)
    endif
    Actor boneyardMother = Game.GetFormFromFile(0x000035D7, "Vault13Chronicles.esp") as Actor
    if boneyardMother != None
        DriveSingleCreatureAI(boneyardMother, false)
    endif
EndFunction

Function SyncWorldMap2161()
    Actor player = Game.GetPlayer()
    if player == None
        return
    endif
    WorldSpace v13World = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if v13World != None && player.GetWorldSpace() == v13World
        if !worldMap2161Synced
            worldMap2161Synced = true
            UpdateSouthernCaliforniaMapMarkers()
            Debug.Notification("[Pip-Boy 2000] Southern California (2161) World Map active. Fast travel enabled between discovered locations.")
        endif
        return
    endif
    if IsPlayerInAny2161Cell()
        if !worldMap2161Synced
            worldMap2161Synced = true
            UpdateSouthernCaliforniaMapMarkers()
        endif
    else
        if worldMap2161Synced
            worldMap2161Synced = false
        endif
    endif
EndFunction

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
    BindRadioQuestActive()
    ForceAllAct1Aliases()
    SyncAllCaliforniaPersistentCoords()
    UpdateSouthernCaliforniaMapMarkers()
    int stg = Self.GetStage()
    if stg >= 20 && stg < 30
        ApplyV13Act1Stage(stg)
    endif
    StartTimer(0.35, 1)
EndEvent

Event Terminal.OnMenuItemRun(Terminal akSender, int auiMenuItemID, ObjectReference akTerminalRef)
    Terminal mnemoTermBase = Game.GetFormFromFile(0x00001130, "Vault13Chronicles.esp") as Terminal
    Terminal overseerTermBase = Game.GetFormFromFile(0x00001131, "Vault13Chronicles.esp") as Terminal
    Terminal v15BarracksTermBase = Game.GetFormFromFile(0x0000113C, "Vault13Chronicles.esp") as Terminal
    Terminal v15EngTermBase = Game.GetFormFromFile(0x0000113D, "Vault13Chronicles.esp") as Terminal
    if akSender == v15BarracksTermBase && auiMenuItemID == 1
        UnlockVault15Armory()
    elseif akSender == v15EngTermBase && auiMenuItemID == 3
        UnlockVault15CommandCenter()
    elseif akSender == overseerTermBase && auiMenuItemID == 3
        AnalyzeHydroCoreInOverseerTerminal()
    elseif akSender == overseerTermBase && auiMenuItemID == 5
        ReturnPlayerToCommonwealthFromTerminal()
    elseif (akSender == mnemoTermBase || akSender == None) && auiMenuItemID == 4
        ActivateTemporalPortal()
    elseif (akSender == mnemoTermBase || akSender == None) && auiMenuItemID >= 5 && auiMenuItemID <= 11
        V13Act2QuestScript act2Jump = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as V13Act2QuestScript
        if act2Jump != None
            act2Jump.QueueMnemosyneCheckpointJump(auiMenuItemID)
        endif
    elseif (akSender == mnemoTermBase || akSender == None) && auiMenuItemID == 12
        Quest qSide = Game.GetFormFromFile(0x00009500, "Vault13Chronicles.esp") as Quest
        V13SideQuestShadySandsScript sideS = qSide as V13SideQuestShadySandsScript
        if sideS != None
            sideS.QueueJumpToShadySands()
        endif
    endif
EndEvent

Function SilentCompleteAct1ForJump()
    introShown = true
    suitGiven = true
    rewardsGiven = true
    hydroCoreAnalyzedInTerm = true
    portalMenuClicked = true
    portalActivated = true
    bunkerVisited = true
    visitedV13 = true
    visitedShadyPass = true
    visitedV15 = true
    if !Self.IsRunning()
        Self.Start()
    endif
    Self.SetObjectiveDisplayed(15, false, false)
    Self.SetObjectiveDisplayed(16, false, false)
    Self.SetObjectiveDisplayed(20, false, false)
    Self.SetObjectiveDisplayed(21, false, false)
    Self.SetObjectiveDisplayed(30, false, false)
    Self.SetObjectiveDisplayed(35, false, false)
    Self.SetObjectiveDisplayed(38, false, false)
    Self.CompleteAllObjectives()
    Self.CompleteQuest()
EndFunction

Function EnsureV13MedicVendorReady(Actor akMedic)
    if akMedic == None
        return
    endif
    Faction vFact = Game.GetFormFromFile(0x00001C56, "Vault13Chronicles.esp") as Faction
    if vFact != None && !akMedic.IsInFaction(vFact)
        akMedic.AddToFaction(vFact)
    endif
    ObjectReference vChest = Game.GetFormFromFile(0x0000219A, "Vault13Chronicles.esp") as ObjectReference
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
            Form mentats = Game.GetFormFromFile(0x0003377B, "Fallout4.esm")
            Form buffout = Game.GetFormFromFile(0x00033778, "Fallout4.esm")
            Form a10 = Game.GetFormFromFile(0x0001F276, "Fallout4.esm")
            Form bpin = Game.GetFormFromFile(0x0000000A, "Fallout4.esm")
            if stim != None && vChest.GetItemCount(stim) < 8
                vChest.AddItem(stim, 20, True)
            endif
            if radaway != None && vChest.GetItemCount(radaway) < 6
                vChest.AddItem(radaway, 16, True)
            endif
            if radx != None && vChest.GetItemCount(radx) < 6
                vChest.AddItem(radx, 16, True)
            endif
            if water != None && vChest.GetItemCount(water) < 6
                vChest.AddItem(water, 18, True)
            endif
            if medx != None && vChest.GetItemCount(medx) < 4
                vChest.AddItem(medx, 8, True)
            endif
            if mentats != None && vChest.GetItemCount(mentats) < 4
                vChest.AddItem(mentats, 8, True)
            endif
            if buffout != None && vChest.GetItemCount(buffout) < 4
                vChest.AddItem(buffout, 8, True)
            endif
            if a10 != None && vChest.GetItemCount(a10) < 30
                vChest.AddItem(a10, 80, True)
            endif
            if bpin != None && vChest.GetItemCount(bpin) < 8
                vChest.AddItem(bpin, 20, True)
            endif
        endif
    endif
EndFunction

Function OpenV13MedicBarter(Actor akMedic)
    if akMedic == None || akMedic.IsDead()
        return
    endif
    EnsureV13MedicVendorReady(akMedic)
    Utility.Wait(0.15)
    akMedic.ShowBarterMenu()
EndFunction

Event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
    Actor player = Game.GetPlayer()
    if akSender == None || akActionRef != player
        return
    endif
    int rIdx = 0
    while rIdx < 8
        Actor rAct = Game.GetFormFromFile(0x00002150 + rIdx, "Vault13Chronicles.esp") as Actor
        if rAct != None && akSender == (rAct as ObjectReference)
            int oIdx = 0
            while oIdx < 8
                if oIdx != rIdx
                    Actor oAct = Game.GetFormFromFile(0x00002150 + oIdx, "Vault13Chronicles.esp") as Actor
                    if oAct != None && oAct.IsTalking()
                        SilenceResidentActor(oAct)
                    endif
                endif
                oIdx += 1
            endwhile
            Quest q2 = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as Quest
            int q2Stg = 0
            if q2 != None
                q2Stg = q2.GetStage()
            endif
            if (rIdx == 3 && q2Stg >= 15 && q2Stg < 20) || q2Stg == 35 || q2Stg == 38 || IsJacorenInDialogueOrScene()
                isPlayingLongMonologue = false
                isPlayingShortHelo = false
                longMonologueResidentIdx = -1
                return
            endif
            if rIdx == 4
                Message medicMsg = Game.GetFormFromFile(0x00001C76, "Vault13Chronicles.esp") as Message
                if medicMsg != None
                    int mChoice = medicMsg.Show()
                    if mChoice == 0
                        OpenV13MedicBarter(rAct)
                        return
                    elseif mChoice == 2
                        return
                    endif
                endif
            endif
            lastSpokenResidentIdx = rIdx
            playerStoppedTicks = 10
            if isPlayingShortHelo && rAct.IsTalking() && longMonologueResidentIdx != rIdx
                PlayResidentFullMonologue(rAct, rIdx)
            elseif rAct.IsTalking()
                longMonologueResidentIdx = rIdx
                isPlayingLongMonologue = true
                isPlayingShortHelo = false
            else
                pendingActivateResidentIdx = rIdx
                StartTimer(0.35, 4)
            endif
            return
        endif
        rIdx += 1
    endwhile
EndEvent

Event OnStageSet(int auiStageID, int auiItemID)
    ApplyV13Act1Stage(auiStageID)
    StartTimer(0.2, 1)
EndEvent

Event OnTimer(int aiTimerID)
    if aiTimerID == 1
        CheckProgressionAndLevelGate()
        Actor player = Game.GetPlayer()
        Cell mnemoCell = Game.GetFormFromFile(0x00002000, "Vault13Chronicles.esp") as Cell
        Cell v13Cell = Game.GetFormFromFile(0x00002100, "Vault13Chronicles.esp") as Cell
        Cell caveCell = Game.GetFormFromFile(0x00002200, "Vault13Chronicles.esp") as Cell
        Cell v15Cell = Game.GetFormFromFile(0x00002500, "Vault13Chronicles.esp") as Cell
        WorldSpace v13World = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
        Cell pCell = None
        if player != None
            pCell = player.GetParentCell()
        endif
        bool inMnemo = (pCell != None && mnemoCell != None && pCell == mnemoCell)
        bool inV13 = (pCell != None && ((v13Cell != None && pCell == v13Cell) || (caveCell != None && pCell == caveCell)))
        bool inV15 = (pCell != None && v15Cell != None && pCell == v15Cell)
        bool inCaliWorld = (player != None && v13World != None && player.GetWorldSpace() == v13World)
        if pCell != None && v13Cell != None && pCell == v13Cell && !residentTimerActive
            residentTimerActive = true
            StartTimer(0.6, 3)
        endif
        if inMnemo || inV13 || inV15 || inCaliWorld
            Quest junktownQ1 = Game.GetFormFromFile(0x00010000, "Vault13Chronicles.esp") as Quest
            V13SideQuestJunktownScript junktownS1 = junktownQ1 as V13SideQuestJunktownScript
            if junktownS1 != None
                junktownS1.CheckDogmeatProximity()
            endif
        endif
        if inMnemo || inV13 || inV15 || inCaliWorld || Self.GetStage() < 15 || !introShown
            StartTimer(2.0, 1)
        endif
    elseif aiTimerID == 2
        AdvanceHydroCoreWalkStep()
    elseif aiTimerID == 3
        Actor player = Game.GetPlayer()
        Cell v13Cell = Game.GetFormFromFile(0x00002100, "Vault13Chronicles.esp") as Cell
        if player != None && v13Cell != None && player.GetParentCell() == v13Cell
            UpdateVault13ResidentMonologues()
            StartTimer(0.6, 3)
        else
            residentTimerActive = false
            lastSpokenResidentIdx = -1
            longMonologueResidentIdx = -1
            playerStoppedTicks = 0
            isPlayingLongMonologue = false
            isPlayingShortHelo = false
            silencedResidentIdx = -1
        endif
    elseif aiTimerID == 4
        if pendingActivateResidentIdx >= 0 && pendingActivateResidentIdx < 8
            int actIdx = pendingActivateResidentIdx
            pendingActivateResidentIdx = -1
            Actor rAct = Game.GetFormFromFile(0x00002150 + actIdx, "Vault13Chronicles.esp") as Actor
            if rAct != None && !IsJacorenInDialogueOrScene()
                if rAct.IsTalking()
                    lastSpokenResidentIdx = actIdx
                    longMonologueResidentIdx = actIdx
                    isPlayingLongMonologue = true
                    isPlayingShortHelo = false
                    playerStoppedTicks = 10
                else
                    PlayResidentFullMonologue(rAct, actIdx)
                endif
            endif
        endif
    elseif aiTimerID == 5
        if Utility.IsInMenuMode()
            StartTimer(0.35, 5)
            return
        endif
        bMenuReturnBusy = false
        Actor player5 = Game.GetPlayer()
        ObjectReference mnemoDest = Game.GetFormFromFile(0x00002002, "Vault13Chronicles.esp") as ObjectReference
        if player5 != None && mnemoDest != None
            worldMap2161Synced = false
            player5.MoveTo(mnemoDest, 0.0, 0.0, 0.0, true)
            Quest junktownQ5 = Game.GetFormFromFile(0x00010000, "Vault13Chronicles.esp") as Quest
            if junktownQ5 != None
                V13SideQuestJunktownScript junktownS5 = junktownQ5 as V13SideQuestJunktownScript
                if junktownS5 != None
                    junktownS5.SyncDogmeatWithPlayer()
                endif
            endif
            Debug.Notification("[Mnemosyne Archive - 2287] You have returned to the Commonwealth. Your 2161 progress is preserved for whenever you return.")
        endif
    endif
EndEvent
