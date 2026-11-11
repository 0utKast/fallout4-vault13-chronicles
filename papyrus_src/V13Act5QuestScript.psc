Scriptname V13Act5QuestScript extends Quest

int hitCounter = 0
bool introShown = false
bool rewardsGiven = false
bool bStage30Done = false
bool bStage40Rewarded = false
bool bApplyingAct5Stage = false

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
EndFunction

Function SetCathedralState(bool abEnabled)
    ObjectReference masterVault = Game.GetFormFromFile(0x00002D10, "Vault13Chronicles.esp") as ObjectReference
    Actor theMaster = Game.GetFormFromFile(0x00002D11, "Vault13Chronicles.esp") as Actor
    Actor morpheus = Game.GetFormFromFile(0x00002D12, "Vault13Chronicles.esp") as Actor
    Actor g1 = Game.GetFormFromFile(0x00002D20, "Vault13Chronicles.esp") as Actor
    Actor g2 = Game.GetFormFromFile(0x00002D21, "Vault13Chronicles.esp") as Actor
    ObjectReference termMaster = Game.GetFormFromFile(0x00002D30, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference d2D01 = Game.GetFormFromFile(0x00002D01, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference d2D03 = Game.GetFormFromFile(0x00002D03, "Vault13Chronicles.esp") as ObjectReference
    Form vindicator = Game.GetFormFromFile(0x0000110E, "Vault13Chronicles.esp")

    V13Act1QuestScript act1S = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as V13Act1QuestScript
    if act1S != None
        act1S.SyncVault13ExpeditionDoors()
    endif

    if abEnabled
        if d2D01 != None
            d2D01.Enable(false)
            d2D01.Lock(false, false)
        endif
        if d2D03 != None
            d2D03.Enable(false)
            d2D03.Lock(false, false)
        endif
        if masterVault != None
            masterVault.Enable(false)
        endif
        if termMaster != None
            termMaster.Enable(false)
        endif
        if theMaster != None
            if theMaster.IsDead()
                theMaster.Resurrect()
            endif
            theMaster.Enable(false)
            if !theMaster.IsDead() && vindicator != None
                if theMaster.GetItemCount(vindicator) > 1
                    theMaster.RemoveItem(vindicator, theMaster.GetItemCount(vindicator) - 1, true, None)
                endif
                if theMaster.GetItemCount(vindicator) > 0 && !theMaster.IsEquipped(vindicator)
                    theMaster.EquipItem(vindicator, false, true)
                endif
            endif
        endif
        if morpheus != None
            if morpheus.IsDead()
                morpheus.Resurrect()
            endif
            morpheus.Enable(false)
        endif
        if g1 != None
            if g1.IsDead()
                g1.Resurrect()
            endif
            g1.Enable(false)
        endif
        if g2 != None
            if g2.IsDead()
                g2.Resurrect()
            endif
            g2.Enable(false)
        endif
        int dIdx = 2
        while dIdx < 7
            ObjectReference dExtra = Game.GetFormFromFile(0x00002D20 + dIdx, "Vault13Chronicles.esp") as ObjectReference
            if dExtra != None
                Actor dAct = dExtra as Actor
                if dAct != None && dAct.IsDead()
                    dAct.Resurrect()
                endif
                dExtra.Enable(false)
            endif
            dIdx += 1
        endwhile
    endif
EndFunction

Function GrantAct5CompletionRewards()
    if rewardsGiven
        return
    endif
    rewardsGiven = true

    Actor player = Game.GetPlayer()
    if player == None
        return
    endif

    Form masterCore = Game.GetFormFromFile(0x00001115, "Vault13Chronicles.esp")
    ObjectReference masterVault = Game.GetFormFromFile(0x00002D10, "Vault13Chronicles.esp") as ObjectReference
    Actor theMaster = Game.GetFormFromFile(0x00002D11, "Vault13Chronicles.esp") as Actor

    if masterCore != None
        if player.GetItemCount(masterCore) > 0
            player.RemoveItem(masterCore, player.GetItemCount(masterCore), true, None)
        endif
        if masterVault != None && masterVault.GetItemCount(masterCore) > 0
            masterVault.RemoveItem(masterCore, masterVault.GetItemCount(masterCore), true, None)
        endif
    endif

    Form vindicator = Game.GetFormFromFile(0x0000110E, "Vault13Chronicles.esp")
    if vindicator != None
        if masterVault != None && masterVault.GetItemCount(vindicator) > 0
            masterVault.RemoveItem(vindicator, masterVault.GetItemCount(vindicator), true, None)
        endif
        if player.GetItemCount(vindicator) == 0
            if theMaster != None && theMaster.GetItemCount(vindicator) > 0
                theMaster.RemoveItem(vindicator, 1, true, player)
            else
                player.AddItem(vindicator, 1, false)
            endif
        endif
        if theMaster != None && theMaster.GetItemCount(vindicator) > 0
            theMaster.RemoveItem(vindicator, theMaster.GetItemCount(vindicator), true, None)
        endif
        if player.GetItemCount(vindicator) > 1
            player.RemoveItem(vindicator, player.GetItemCount(vindicator) - 1, true, None)
        endif
    endif

    int i = 0
    while i < 6
        Form paPiece = Game.GetFormFromFile(0x00001301 + i, "Vault13Chronicles.esp")
        if paPiece != None
            if player.GetItemCount(paPiece) == 0
                player.AddItem(paPiece, 1, false)
            elseif player.GetItemCount(paPiece) > 1
                player.RemoveItem(paPiece, player.GetItemCount(paPiece) - 1, true, None)
            endif
        endif
        i += 1
    endwhile

    Form memoirs = Game.GetFormFromFile(0x00001145, "Vault13Chronicles.esp")
    if memoirs != None && player.GetItemCount(memoirs) == 0
        player.AddItem(memoirs, 1, false)
    endif

    Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
    Form fusionCore = Game.GetFormFromFile(0x00075FE4, "Fallout4.esm")
    Form stimpak = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
    Form radaway = Game.GetFormFromFile(0x00023742, "Fallout4.esm")

    if caps != None
        player.AddItem(caps, 3000, false)
    endif
    if fusionCore != None
        player.AddItem(fusionCore, 6, false)
    endif
    if stimpak != None
        player.AddItem(stimpak, 10, false)
    endif
    if radaway != None
        player.AddItem(radaway, 6, false)
    endif

    Game.RewardPlayerXP(2000, false)
EndFunction

Function ForceAllAct5Aliases()
    ForceQuestAlias(0, 0x00002110)
    ForceQuestAlias(1, 0x00002D10)
    ForceQuestAlias(2, 0x00003005)
    ForceQuestAlias(3, 0x00002003)
    ForceQuestAlias(4, 0x00003509)
    ForceQuestAlias(5, 0x00002145)
    ForceQuestAlias(6, 0x00003501)
    ForceQuestAlias(7, 0x00002D03)
EndFunction

Function ApplyV13Act5Stage(int aiStage)
    if bApplyingAct5Stage
        return
    endif
    bApplyingAct5Stage = true

    V13Act1QuestScript act1S = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as V13Act1QuestScript
    bool inDial = (act1S != None && act1S.IsJacorenInDialogueOrScene())
    ForceAllAct5Aliases()
    if !inDial
        SetCathedralState(true)
    elseif act1S != None
        act1S.SyncVault13ExpeditionDoors()
    endif

    if aiStage == 15
        if !Self.IsObjectiveDisplayed(15)
            Self.SetObjectiveDisplayed(15, true, false)
        endif
        Self.SetActive(true)
    elseif aiStage >= 20 && aiStage < 30
        ObjectReference masterVault = Game.GetFormFromFile(0x00002D10, "Vault13Chronicles.esp") as ObjectReference
        Form vindicator = Game.GetFormFromFile(0x0000110E, "Vault13Chronicles.esp")
        if masterVault != None && vindicator != None && masterVault.GetItemCount(vindicator) > 0
            masterVault.RemoveItem(vindicator, masterVault.GetItemCount(vindicator), true, None)
        endif
        SetObjectiveCompleted(15, true)
        Actor player = Game.GetPlayer()
        WorldSpace ws2161 = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
        Cell cathedralCell = Game.GetFormFromFile(0x00002D00, "Vault13Chronicles.esp") as Cell
        bool inWastelandOrDungeon = (player != None && ((ws2161 != None && player.GetWorldSpace() == ws2161) || (cathedralCell != None && player.GetParentCell() == cathedralCell)))
        if inWastelandOrDungeon || IsObjectiveCompleted(20)
            SetObjectiveCompleted(20, true)
            if !Self.IsObjectiveDisplayed(21)
                Self.SetObjectiveDisplayed(21, true, false)
            endif
        else
            if !Self.IsObjectiveDisplayed(20)
                Self.SetObjectiveDisplayed(20, true, false)
            endif
        endif
        Self.SetActive(true)
    elseif aiStage >= 30 && aiStage < 40
        if !bStage30Done
            bStage30Done = true
            SetObjectiveCompleted(15, true)
            SetObjectiveCompleted(20, true)
            SetObjectiveCompleted(21, true)
            if !Self.IsObjectiveDisplayed(30)
                Self.SetObjectiveDisplayed(30, true, false)
            endif
            Self.SetActive(true)
        endif
    elseif aiStage >= 40
        if inDial && aiStage < 45
            bApplyingAct5Stage = false
            StartTimer(0.2, 1)
            return
        endif
        SetObjectiveCompleted(15, true)
        SetObjectiveCompleted(20, true)
        SetObjectiveCompleted(21, true)
        SetObjectiveCompleted(30, true)
        if !bStage40Rewarded
            bStage40Rewarded = true
            GrantAct5CompletionRewards()
            Debug.Notification("[Crónicas del Refugio 13] ¡Campaña completada! ¡Servoarmadura T-51f endurecida y Ametralladora Vindicator desbloqueadas!")
        endif
        if !Self.IsCompleted()
            CompleteAllObjectives()
            CompleteQuest()
        endif
    endif
    bApplyingAct5Stage = false
EndFunction

Function CheckStartAndProgress()
    RegisterPlayerEvents()
    Actor player = Game.GetPlayer()
    if player == None
        return
    endif

    int currentStage = Self.GetStage()
    if currentStage < 15
        ; Congelado en la Primera Parte del mod
        if Self.IsRunning()
            Self.Stop()
        endif
        return
    endif

    V13Act1QuestScript act1S = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as V13Act1QuestScript

    if currentStage >= 40
        if (!rewardsGiven || !Self.IsCompleted()) && (act1S == None || !act1S.IsJacorenInDialogueOrScene())
            ApplyV13Act5Stage(currentStage)
        endif
        return
    endif

    if act1S != None && act1S.IsJacorenInDialogueOrScene()
        return
    endif

    if currentStage == 30
        if !IsObjectiveDisplayed(30)
            ForceAllAct5Aliases()
            SetCathedralState(true)
            SetObjectiveCompleted(15, true)
            SetObjectiveCompleted(20, true)
            Self.SetObjectiveDisplayed(30, true, false)
        endif
        return
    endif

    if currentStage == 20
        Form masterCore = Game.GetFormFromFile(0x00001115, "Vault13Chronicles.esp")
        if masterCore != None && player.GetItemCount(masterCore) > 0
            Self.SetStage(30)
            return
        endif
        if !IsObjectiveDisplayed(20)
            ForceAllAct5Aliases()
            SetCathedralState(true)
            SetObjectiveCompleted(15, true)
            Self.SetObjectiveDisplayed(20, true, false)
        endif
        return
    endif

    if currentStage == 15
        if !IsObjectiveDisplayed(15)
            ForceAllAct5Aliases()
            SetCathedralState(true)
            Self.SetObjectiveDisplayed(15, true, false)
        endif
        if !introShown
            if !Utility.IsInMenuMode()
                introShown = true
                Message radioMsg = Game.GetFormFromFile(0x00001154, "Vault13Chronicles.esp") as Message
                if radioMsg != None
                    radioMsg.Show()
                endif
            endif
        endif
        return
    endif
EndFunction

Function WakeUpAct5()
    ; Congelado en la Primera Parte del mod
    if Self.IsRunning()
        Self.Stop()
    endif
    return
EndFunction

Function ProcessVindicatorHit(Actor akTarget, Actor akCaster)
    if akTarget == None || akCaster == None
        return
    endif

    EffectShader fireFX = Game.GetFormFromFile(0x0006F122, "Fallout4.esm") as EffectShader
    if fireFX != None
        fireFX.Play(akTarget, 2.0)
    endif

    Actor player = Game.GetPlayer()
    if akCaster == player
        hitCounter += 1
        if hitCounter >= 5 || akTarget.IsDead()
            hitCounter = 0
            ActorValue apAV = Game.GetFormFromFile(0x000002D5, "Fallout4.esm") as ActorValue
            ActorValue hpAV = Game.GetFormFromFile(0x000002D4, "Fallout4.esm") as ActorValue
            if apAV != None
                player.RestoreValue(apAV, 40.0)
            endif
            if hpAV != None
                player.RestoreValue(hpAV, 30.0)
            endif
            Debug.Notification("[Ametralladora Vindicator] ¡Onda de choque Rheinmetall! (+40 PA / +30 PV)")
        endif
    endif
EndFunction

Event OnInit()
    RegisterPlayerEvents()
    CheckStartAndProgress()
    if Self.IsRunning()
        StartTimer(2.5, 1)
    endif
EndEvent

Event OnQuestInit()
    RegisterPlayerEvents()
    CheckStartAndProgress()
    if Self.IsRunning()
        StartTimer(2.5, 1)
    endif
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
    RegisterPlayerEvents()
    CheckStartAndProgress()
    if Self.IsRunning()
        StartTimer(2.0, 1)
    endif
EndEvent

Event Actor.OnItemEquipped(Actor akSender, Form akBaseObject, ObjectReference akReference)
    Form vindicator = Game.GetFormFromFile(0x0000110E, "Vault13Chronicles.esp")
    if akBaseObject == vindicator && vindicator != None
        Debug.Notification("[Ametralladora Vindicator - 2161] Supresor rotativo activo: Onda de choque cada 5 impactos (+40 PA / +30 PV)")
    endif
EndEvent

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
    if Self.GetStage() >= 15 && Self.GetStage() < 40
        ApplyV13Act5Stage(Self.GetStage())
    endif
EndEvent

Event OnStageSet(int auiStageID, int auiItemID)
    ApplyV13Act5Stage(auiStageID)
    if Self.IsRunning()
        StartTimer(0.2, 1)
    endif
EndEvent

Event OnTimer(int aiTimerID)
    if aiTimerID == 1
        CheckStartAndProgress()
        if !Self.IsRunning()
            CancelTimer(1)
            return
        endif
        Quest act4Quest = Game.GetFormFromFile(0x00007000, "Vault13Chronicles.esp") as Quest
        if (Self.GetStage() >= 15 && (Self.GetStage() < 40 || !rewardsGiven || !Self.IsCompleted())) || (act4Quest != None && act4Quest.GetStage() >= 40 && Self.GetStage() < 40)
            StartTimer(2.5, 1)
        endif
    endif
EndEvent
