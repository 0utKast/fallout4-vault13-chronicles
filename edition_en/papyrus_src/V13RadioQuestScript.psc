Scriptname V13RadioQuestScript extends Quest

bool bCommonwealthRadiosSuppressed = false
bool bAnnouncedStation = false
bool bEventsRegistered = false

bool bSavedDCR = false
bool bSavedClassical = false
bool bSavedFreedom = false
bool bSavedAF95 = false
bool bSavedBoS00 = false
bool bSavedShroud = false
bool bSavedTrinity = false
bool bSavedEyebot = false

Function EnsureEventsRegistered()
    Actor kPlayer = Game.GetPlayer()
    if kPlayer != None && !bEventsRegistered
        bEventsRegistered = true
        RegisterForRemoteEvent(kPlayer, "OnLocationChange")
        RegisterForRemoteEvent(kPlayer, "OnPlayerLoadGame")
    endif
EndFunction

Event OnInit()
    EnsureEventsRegistered()
    SyncRadioEnvironment()
    if IsPlayerIn2161(Game.GetPlayer())
        StartTimer(2.0, 1)
    endif
EndEvent

Event OnQuestInit()
    EnsureEventsRegistered()
    SyncRadioEnvironment()
    if IsPlayerIn2161(Game.GetPlayer())
        StartTimer(2.0, 1)
    endif
EndEvent

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
    SyncRadioEnvironment()
    if IsPlayerIn2161(Game.GetPlayer())
        StartTimer(1.5, 1)
    else
        CancelTimer(1)
    endif
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
    Scene kHubScene = Game.GetFormFromFile(0x00008511, "Vault13Chronicles.esp") as Scene
    if kHubScene != None && kHubScene.IsPlaying()
        kHubScene.Stop()
        Utility.Wait(0.25)
    endif
    SyncRadioEnvironment()
    if IsPlayerIn2161(Game.GetPlayer())
        StartTimer(1.5, 1)
    else
        CancelTimer(1)
    endif
EndEvent

bool Function IsPlayerIn2161(Actor akPlayer)
    if akPlayer == None
        return false
    endif
    WorldSpace kWS = akPlayer.GetWorldSpace()
    WorldSpace kSoCalWS = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if kWS != None && kSoCalWS != None && kWS == kSoCalWS
        return true
    endif
    Cell kCell = akPlayer.GetParentCell()
    if kCell == None
        return false
    endif
    if kCell == (Game.GetFormFromFile(0x00002000, "Vault13Chronicles.esp") as Cell)
        return true
    elseif kCell == (Game.GetFormFromFile(0x00002100, "Vault13Chronicles.esp") as Cell)
        return true
    elseif kCell == (Game.GetFormFromFile(0x00002200, "Vault13Chronicles.esp") as Cell)
        return true
    elseif kCell == (Game.GetFormFromFile(0x00002500, "Vault13Chronicles.esp") as Cell)
        return true
    elseif kCell == (Game.GetFormFromFile(0x00002900, "Vault13Chronicles.esp") as Cell)
        return true
    elseif kCell == (Game.GetFormFromFile(0x00002A00, "Vault13Chronicles.esp") as Cell)
        return true
    elseif kCell == (Game.GetFormFromFile(0x00002B00, "Vault13Chronicles.esp") as Cell)
        return true
    elseif kCell == (Game.GetFormFromFile(0x00002C00, "Vault13Chronicles.esp") as Cell)
        return true
    elseif kCell == (Game.GetFormFromFile(0x00002D00, "Vault13Chronicles.esp") as Cell)
        return true
    elseif kCell == (Game.GetFormFromFile(0x00002E00, "Vault13Chronicles.esp") as Cell)
        return true
    elseif kCell == (Game.GetFormFromFile(0x00002F00, "Vault13Chronicles.esp") as Cell)
        return true
    endif
    return false
EndFunction

Function SyncRadioEnvironment()
    EnsureEventsRegistered()
    Actor kPlayer = Game.GetPlayer()
    if kPlayer == None
        return
    endif

    ObjectReference kHubTx = Game.GetFormFromFile(0x0000321F, "Vault13Chronicles.esp") as ObjectReference
    Scene kHubScene = Game.GetFormFromFile(0x00008511, "Vault13Chronicles.esp") as Scene
    ReferenceAlias kTxAlias = Self.GetAlias(0) as ReferenceAlias

    bool bIn2161 = IsPlayerIn2161(kPlayer)
    if bIn2161
        if kHubTx != None && kHubTx.IsDisabled()
            kHubTx.Enable(false)
        endif
        if !Self.IsRunning()
            Self.Start()
        endif
        if Self.GetStage() < 10
            Self.SetStage(10)
        endif
        if kTxAlias != None && kHubTx != None && kTxAlias.GetReference() != kHubTx
            kTxAlias.ForceRefTo(kHubTx)
        endif
        if kHubScene != None && !kHubScene.IsPlaying()
            kHubScene.Start()
        endif

        ObjectReference kDCR = Game.GetFormFromFile(0x0001FA5B, "Fallout4.esm") as ObjectReference
        Quest kDCRQuest = Game.GetFormFromFile(0x0001FA58, "Fallout4.esm") as Quest
        if kDCR != None && !kDCR.IsDisabled()
            bSavedDCR = true
            kDCR.DisableNoWait()
        endif
        if kDCRQuest != None && kDCRQuest.IsRunning()
            bSavedDCR = true
            kDCRQuest.Stop()
        endif

        ObjectReference kClassical = Game.GetFormFromFile(0x00031C19, "Fallout4.esm") as ObjectReference
        Quest kClassicalQuest = Game.GetFormFromFile(0x00031C1A, "Fallout4.esm") as Quest
        if kClassical != None && !kClassical.IsDisabled()
            bSavedClassical = true
            kClassical.DisableNoWait()
        endif
        if kClassicalQuest != None && kClassicalQuest.IsRunning()
            bSavedClassical = true
            kClassicalQuest.Stop()
        endif

        ObjectReference kFreedom = Game.GetFormFromFile(0x0009FF44, "Fallout4.esm") as ObjectReference
        if kFreedom != None && !kFreedom.IsDisabled()
            bSavedFreedom = true
            kFreedom.DisableNoWait()
        endif

        ObjectReference kAF95 = Game.GetFormFromFile(0x0004AF75, "Fallout4.esm") as ObjectReference
        if kAF95 != None && !kAF95.IsDisabled()
            bSavedAF95 = true
            kAF95.DisableNoWait()
        endif

        ObjectReference kBoS00 = Game.GetFormFromFile(0x0006F105, "Fallout4.esm") as ObjectReference
        if kBoS00 != None && !kBoS00.IsDisabled()
            bSavedBoS00 = true
            kBoS00.DisableNoWait()
        endif

        ObjectReference kShroud = Game.GetFormFromFile(0x0002F519, "Fallout4.esm") as ObjectReference
        if kShroud != None && !kShroud.IsDisabled()
            bSavedShroud = true
            kShroud.DisableNoWait()
        endif

        ObjectReference kTrinity = Game.GetFormFromFile(0x0001DAF9, "Fallout4.esm") as ObjectReference
        if kTrinity != None && !kTrinity.IsDisabled()
            bSavedTrinity = true
            kTrinity.DisableNoWait()
        endif

        ObjectReference kEyebot = Game.GetFormFromFile(0x000E0B61, "Fallout4.esm") as ObjectReference
        if kEyebot != None && !kEyebot.IsDisabled()
            bSavedEyebot = true
            kEyebot.DisableNoWait()
        endif

        bCommonwealthRadiosSuppressed = true

        float fCurFreq = Game.GetPlayerRadioFrequency()
        if !bAnnouncedStation
            bAnnouncedStation = true
            Game.SetPlayerRadioFrequency(84.5)
            Debug.Notification("[PIP-BOY 2000] Active station: The Hub Radio - New California (2161)")
        elseif (fCurFreq > 97.5 && fCurFreq < 98.5) || (fCurFreq > 91.4 && fCurFreq < 92.4)
            Game.SetPlayerRadioFrequency(84.5)
        endif
    else
        if bCommonwealthRadiosSuppressed
            bCommonwealthRadiosSuppressed = false
            bAnnouncedStation = false

            if bSavedDCR
                ObjectReference kDCR = Game.GetFormFromFile(0x0001FA5B, "Fallout4.esm") as ObjectReference
                Quest kDCRQuest = Game.GetFormFromFile(0x0001FA58, "Fallout4.esm") as Quest
                Scene kDCRScene = Game.GetFormFromFile(0x000304F0, "Fallout4.esm") as Scene
                if kDCR != None
                    kDCR.EnableNoWait()
                endif
                if kDCRQuest != None
                    if !kDCRQuest.IsRunning()
                        kDCRQuest.Start()
                    endif
                    ReferenceAlias kDCRAlias = kDCRQuest.GetAlias(0) as ReferenceAlias
                    if kDCRAlias != None && kDCR != None
                        kDCRAlias.ForceRefTo(kDCR)
                    endif
                endif
                if kDCRScene != None && !kDCRScene.IsPlaying()
                    kDCRScene.Start()
                endif
                bSavedDCR = false
            endif

            if bSavedClassical
                ObjectReference kClassical = Game.GetFormFromFile(0x00031C19, "Fallout4.esm") as ObjectReference
                Quest kClassicalQuest = Game.GetFormFromFile(0x00031C1A, "Fallout4.esm") as Quest
                Scene kClassicalScene = Game.GetFormFromFile(0x00031C1B, "Fallout4.esm") as Scene
                if kClassical != None
                    kClassical.EnableNoWait()
                endif
                if kClassicalQuest != None
                    if !kClassicalQuest.IsRunning()
                        kClassicalQuest.Start()
                    endif
                    ReferenceAlias kClassicalAlias = kClassicalQuest.GetAlias(0) as ReferenceAlias
                    if kClassicalAlias != None && kClassical != None
                        kClassicalAlias.ForceRefTo(kClassical)
                    endif
                endif
                if kClassicalScene != None && !kClassicalScene.IsPlaying()
                    kClassicalScene.Start()
                endif
                bSavedClassical = false
            endif

            if bSavedFreedom
                ObjectReference kFreedom = Game.GetFormFromFile(0x0009FF44, "Fallout4.esm") as ObjectReference
                if kFreedom != None
                    kFreedom.EnableNoWait()
                endif
                bSavedFreedom = false
            endif

            if bSavedAF95
                ObjectReference kAF95 = Game.GetFormFromFile(0x0004AF75, "Fallout4.esm") as ObjectReference
                if kAF95 != None
                    kAF95.EnableNoWait()
                endif
                bSavedAF95 = false
            endif

            if bSavedBoS00
                ObjectReference kBoS00 = Game.GetFormFromFile(0x0006F105, "Fallout4.esm") as ObjectReference
                if kBoS00 != None
                    kBoS00.EnableNoWait()
                endif
                bSavedBoS00 = false
            endif

            if bSavedShroud
                ObjectReference kShroud = Game.GetFormFromFile(0x0002F519, "Fallout4.esm") as ObjectReference
                if kShroud != None
                    kShroud.EnableNoWait()
                endif
                bSavedShroud = false
            endif

            if bSavedTrinity
                ObjectReference kTrinity = Game.GetFormFromFile(0x0001DAF9, "Fallout4.esm") as ObjectReference
                if kTrinity != None
                    kTrinity.EnableNoWait()
                endif
                bSavedTrinity = false
            endif

            if bSavedEyebot
                ObjectReference kEyebot = Game.GetFormFromFile(0x000E0B61, "Fallout4.esm") as ObjectReference
                if kEyebot != None
                    kEyebot.EnableNoWait()
                endif
                bSavedEyebot = false
            endif
        endif

        if kHubScene != None && kHubScene.IsPlaying()
            kHubScene.Stop()
        endif
        if kTxAlias != None && kTxAlias.GetReference() != None
            kTxAlias.Clear()
        endif
        if kHubTx != None && !kHubTx.IsDisabled()
            kHubTx.DisableNoWait()
        endif
    endif

    Quest kShadyQ = Game.GetFormFromFile(0x00009500, "Vault13Chronicles.esp") as Quest
    if kShadyQ != None && !kShadyQ.IsCompleted()
        if !kShadyQ.IsRunning()
            kShadyQ.Start()
            if kShadyQ.GetStage() < 10
                kShadyQ.SetStage(10)
            endif
            V13SideQuestShadySandsScript kShadyS = kShadyQ as V13SideQuestShadySandsScript
            if kShadyS != None
                kShadyS.SetupShadySandsListeners()
            endif
        elseif kShadyQ.GetStage() < 10
            kShadyQ.SetStage(10)
        endif
    endif

    Quest kJunktownQ = Game.GetFormFromFile(0x00010000, "Vault13Chronicles.esp") as Quest
    if kJunktownQ != None
        V13SideQuestJunktownScript kJunktownS = kJunktownQ as V13SideQuestJunktownScript
        if kJunktownS != None
            if !kJunktownS.IsPlayerInVault13Space()
                kJunktownS.SuspendCompanionsForCommonwealth()
            else
                kJunktownS.RestoreCompanionsOnReturnTo2161()
            endif
        endif
    endif
EndFunction

Event OnTimer(int aiTimerID)
    if aiTimerID == 1
        SyncRadioEnvironment()
        if IsPlayerIn2161(Game.GetPlayer())
            StartTimer(3.0, 1)
        endif
    endif
EndEvent
