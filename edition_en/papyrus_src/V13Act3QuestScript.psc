Scriptname V13Act3QuestScript extends Quest

int hitCounter = 0
bool introShown = false
bool rewardsGiven = false
bool bStage30Done = false
bool bStage40Rewarded = false
bool bApplyingAct3Stage = false

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

Function SetLostHillsState(bool abEnabled)
    ObjectReference vreeChest = Game.GetFormFromFile(0x00002B10, "Vault13Chronicles.esp") as ObjectReference
    Actor kragor = Game.GetFormFromFile(0x00002B11, "Vault13Chronicles.esp") as Actor
    Actor g1 = Game.GetFormFromFile(0x00002B12, "Vault13Chronicles.esp") as Actor
    Actor g2 = Game.GetFormFromFile(0x00002B20, "Vault13Chronicles.esp") as Actor
    Actor g3 = Game.GetFormFromFile(0x00002B21, "Vault13Chronicles.esp") as Actor
    ObjectReference termVree = Game.GetFormFromFile(0x00002B30, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference d2B01 = Game.GetFormFromFile(0x00002B01, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference d2B03 = Game.GetFormFromFile(0x00002B03, "Vault13Chronicles.esp") as ObjectReference
    Form wattz2000 = Game.GetFormFromFile(0x00001108, "Vault13Chronicles.esp")

    V13Act1QuestScript act1S = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as V13Act1QuestScript
    if act1S != None
        act1S.SyncVault13ExpeditionDoors()
    endif

    if abEnabled
        if d2B01 != None
            d2B01.Enable(false)
            d2B01.Lock(false, false)
        endif
        if d2B03 != None
            if d2B03.GetPositionZ() < -450.0
                d2B03.Disable(false)
            endif
            d2B03.SetPosition(2420.0, -2420.0, -351.6)
            d2B03.SetAngle(0.0, 0.0, 252.8)
            d2B03.Enable(false)
            d2B03.Lock(false, false)
        endif
        if vreeChest != None
            vreeChest.Enable(false)
        endif
        if termVree != None
            termVree.Enable(false)
        endif
        if kragor != None
            if kragor.IsDead()
                kragor.Resurrect()
            endif
            kragor.Enable(false)
            if !kragor.IsDead() && wattz2000 != None
                if kragor.GetItemCount(wattz2000) > 1
                    kragor.RemoveItem(wattz2000, kragor.GetItemCount(wattz2000) - 1, true, None)
                endif
                if kragor.GetItemCount(wattz2000) > 0 && !kragor.IsEquipped(wattz2000)
                    kragor.EquipItem(wattz2000, false, true)
                endif
            endif
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
        if g3 != None
            if g3.IsDead()
                g3.Resurrect()
            endif
            g3.Enable(false)
        endif
        int bIdx = 2
        while bIdx < 7
            ObjectReference bExtra = Game.GetFormFromFile(0x00002B20 + bIdx, "Vault13Chronicles.esp") as ObjectReference
            if bExtra != None
                Actor bAct = bExtra as Actor
                if bAct != None && bAct.IsDead()
                    bAct.Resurrect()
                endif
                bExtra.Enable(false)
            endif
            bIdx += 1
        endwhile
    endif
EndFunction

Function GiveAct3CompletionRewards()
    if rewardsGiven
        return
    endif
    rewardsGiven = true
    Actor player = Game.GetPlayer()
    Form vreeHolo = Game.GetFormFromFile(0x00001113, "Vault13Chronicles.esp")
    Form wattz2000 = Game.GetFormFromFile(0x00001108, "Vault13Chronicles.esp")
    Actor kragor = Game.GetFormFromFile(0x00002B11, "Vault13Chronicles.esp") as Actor
    ObjectReference vreeChest = Game.GetFormFromFile(0x00002B10, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference relicDisplay3 = Game.GetFormFromFile(0x00002033, "Vault13Chronicles.esp") as ObjectReference
    Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
    Form stimpak = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
    Form fusionCell = Game.GetFormFromFile(0x000C1897, "Fallout4.esm")

    if player != None
        if vreeHolo != None
            if player.GetItemCount(vreeHolo) > 0
                player.RemoveItem(vreeHolo, player.GetItemCount(vreeHolo), true, None)
            endif
            if vreeChest != None && vreeChest.GetItemCount(vreeHolo) > 0
                vreeChest.RemoveItem(vreeHolo, vreeChest.GetItemCount(vreeHolo), true, None)
            endif
        endif
        if wattz2000 != None
            if player.GetItemCount(wattz2000) == 0
                if kragor != None && kragor.GetItemCount(wattz2000) > 0
                    kragor.RemoveItem(wattz2000, 1, true, player)
                else
                    player.AddItem(wattz2000, 1, false)
                endif
            endif
            if kragor != None && kragor.GetItemCount(wattz2000) > 0
                kragor.RemoveItem(wattz2000, kragor.GetItemCount(wattz2000), true, None)
            endif
            if player.GetItemCount(wattz2000) > 1
                player.RemoveItem(wattz2000, player.GetItemCount(wattz2000) - 1, true, None)
            endif
        endif
        if caps != None
            player.AddItem(caps, 1000, false)
        endif
        if stimpak != None
            player.AddItem(stimpak, 6, false)
        endif
        if fusionCell != None
            player.AddItem(fusionCell, 80, false)
        endif
    endif

    if relicDisplay3 != None
        relicDisplay3.Enable(false)
    endif

    Game.RewardPlayerXP(800, false)
    Debug.Notification("[Vault 13 Chronicles] Scribe Vree's autopsy holotape decoded! Wattz 2000 Laser Rifle unlocked!")
EndFunction

Function ForceAllAct3Aliases()
    ForceQuestAlias(0, 0x00002110)
    ForceQuestAlias(1, 0x00002B10)
    ForceQuestAlias(2, 0x00003005)
    ForceQuestAlias(3, 0x00002003)
    ForceQuestAlias(4, 0x00003507)
    ForceQuestAlias(5, 0x00002143)
    ForceQuestAlias(6, 0x00003501)
    ForceQuestAlias(7, 0x00002B03)
EndFunction

Function ApplyV13Act3Stage(int auiStage)
    if bApplyingAct3Stage
        return
    endif
    bApplyingAct3Stage = true

    V13Act1QuestScript act1S = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as V13Act1QuestScript
    bool inDial = (act1S != None && act1S.IsJacorenInDialogueOrScene())
    ForceAllAct3Aliases()

    if auiStage < 15
        bApplyingAct3Stage = false
        return
    endif

    if !inDial
        SetLostHillsState(true)
    elseif act1S != None
        act1S.SyncVault13ExpeditionDoors()
    endif

    if auiStage >= 15 && !introShown
        if !Utility.IsInMenuMode()
            introShown = true
            Message radioMsg = Game.GetFormFromFile(0x00001152, "Vault13Chronicles.esp") as Message
            if radioMsg != None
                radioMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
            endif
        endif
    endif

    if auiStage == 15
        if !Self.IsObjectiveDisplayed(15)
            Self.SetObjectiveDisplayed(15, true, false)
            Self.SetActive(true)
        endif
    elseif auiStage >= 20 && auiStage < 30
        if !Self.IsObjectiveCompleted(15)
            Self.SetObjectiveCompleted(15, true)
        endif
        Actor player = Game.GetPlayer()
        WorldSpace ws2161 = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
        Cell lostHillsCell = Game.GetFormFromFile(0x00002B00, "Vault13Chronicles.esp") as Cell
        bool inWastelandOrDungeon = (player != None && ((ws2161 != None && player.GetWorldSpace() == ws2161) || (lostHillsCell != None && player.GetParentCell() == lostHillsCell)))
        if inWastelandOrDungeon || Self.IsObjectiveCompleted(20)
            if !Self.IsObjectiveCompleted(20)
                Self.SetObjectiveCompleted(20, true)
            endif
            if !Self.IsObjectiveDisplayed(21)
                Self.SetObjectiveDisplayed(21, true, false)
            endif
        else
            if !Self.IsObjectiveDisplayed(20)
                Self.SetObjectiveDisplayed(20, true, false)
            endif
        endif
        Self.SetActive(true)
    elseif auiStage >= 30 && auiStage < 40
        if !bStage30Done
            bStage30Done = true
            if !Self.IsObjectiveCompleted(15)
                Self.SetObjectiveCompleted(15, true)
            endif
            if !Self.IsObjectiveCompleted(20)
                Self.SetObjectiveCompleted(20, true)
            endif
            if !Self.IsObjectiveCompleted(21)
                Self.SetObjectiveCompleted(21, true)
            endif
            if !Self.IsObjectiveDisplayed(30)
                Self.SetObjectiveDisplayed(30, true, false)
                Self.SetActive(true)
            endif
        endif
    elseif auiStage >= 40
        if inDial && auiStage < 45
            bApplyingAct3Stage = false
            StartTimer(0.2, 1)
            return
        endif
        if !bStage40Rewarded
            bStage40Rewarded = true
            GiveAct3CompletionRewards()
        endif
        if !Self.IsObjectiveCompleted(15)
            Self.SetObjectiveCompleted(15, true)
        endif
        if !Self.IsObjectiveCompleted(20)
            Self.SetObjectiveCompleted(20, true)
        endif
        if !Self.IsObjectiveCompleted(21)
            Self.SetObjectiveCompleted(21, true)
        endif
        if !Self.IsObjectiveCompleted(30)
            Self.SetObjectiveCompleted(30, true)
        endif
        if !Self.IsCompleted()
            Self.CompleteAllObjectives()
            Self.CompleteQuest()
        endif
        V13Act4QuestScript act4S = Game.GetFormFromFile(0x00007000, "Vault13Chronicles.esp") as V13Act4QuestScript
        if act4S != None
            act4S.WakeUpAct4()
        endif
        if auiStage >= 45
            Quest act4Quest = Game.GetFormFromFile(0x00007000, "Vault13Chronicles.esp") as Quest
            if act4Quest != None
                if !act4Quest.IsRunning()
                    act4Quest.Start()
                endif
                if act4Quest.GetStage() < 20
                    act4Quest.SetStage(20)
                endif
            endif
        endif
    endif
    bApplyingAct3Stage = false
EndFunction

Function WakeUpAct3()
    ; Congelado en la Primera Parte del mod
    if Self.IsObjectiveDisplayed(15)
        Self.SetObjectiveDisplayed(15, false, false)
    endif
    if Self.IsObjectiveDisplayed(20)
        Self.SetObjectiveDisplayed(20, false, false)
    endif
    if Self.IsObjectiveDisplayed(30)
        Self.SetObjectiveDisplayed(30, false, false)
    endif
    if Self.IsRunning()
        Self.Stop()
    endif
    return
EndFunction

Function CheckProgressionAndLevelGate()
    ; Congelado en la Primera Parte del mod
    if Self.IsObjectiveDisplayed(15)
        Self.SetObjectiveDisplayed(15, false, false)
    endif
    if Self.IsObjectiveDisplayed(20)
        Self.SetObjectiveDisplayed(20, false, false)
    endif
    if Self.IsObjectiveDisplayed(30)
        Self.SetObjectiveDisplayed(30, false, false)
    endif
    if Self.IsRunning()
        Self.Stop()
    endif
    return
EndFunction

Function ProcessWattz2000Hit(Actor akTarget, Actor akCaster)
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
        if hitCounter >= 4 || akTarget.IsDead()
            hitCounter = 0
            ActorValue apAV = Game.GetFormFromFile(0x000002D5, "Fallout4.esm") as ActorValue
            ActorValue hpAV = Game.GetFormFromFile(0x000002D4, "Fallout4.esm") as ActorValue
            if apAV != None
                player.RestoreValue(apAV, 30.0)
            endif
            if hpAV != None
                player.RestoreValue(hpAV, 20.0)
            endif
            Debug.Notification("[Wattz 2000 Laser Rifle] Lost Hills optical overcharge! (+30 AP / +20 HP)")
        endif
    endif
EndFunction

Event OnInit()
    RegisterPlayerEvents()
    CheckProgressionAndLevelGate()
    if Self.IsRunning()
        StartTimer(2.5, 1)
    endif
EndEvent

Event OnQuestInit()
    RegisterPlayerEvents()
    CheckProgressionAndLevelGate()
    if Self.IsRunning()
        StartTimer(2.5, 1)
    endif
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
    RegisterPlayerEvents()
    CheckProgressionAndLevelGate()
    if Self.IsRunning()
        StartTimer(2.5, 1)
    endif
    V13Act4QuestScript act4S = Game.GetFormFromFile(0x00007000, "Vault13Chronicles.esp") as V13Act4QuestScript
    if act4S != None
        act4S.WakeUpAct4()
    endif
EndEvent

Event Actor.OnItemEquipped(Actor akSender, Form akBaseObject, ObjectReference akReference)
    Form wattz2000 = Game.GetFormFromFile(0x00001108, "Vault13Chronicles.esp")
    if akBaseObject == wattz2000 && wattz2000 != None
        Debug.Notification("[Wattz 2000 Laser Rifle] Lost Hills optical array active: Overcharge every 4 hits (+30 AP / +20 HP)")
    endif
EndEvent

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
    if Self.GetStage() >= 15 && Self.GetStage() < 40
        ApplyV13Act3Stage(Self.GetStage())
    endif
EndEvent

Event OnStageSet(int auiStageID, int auiItemID)
    ApplyV13Act3Stage(auiStageID)
    if Self.IsRunning()
        StartTimer(0.2, 1)
    endif
EndEvent

Event OnTimer(int aiTimerID)
    if aiTimerID == 1
        CheckProgressionAndLevelGate()
        if !Self.IsRunning()
            CancelTimer(1)
            return
        endif
        Quest act2Quest = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as Quest
        if (Self.GetStage() >= 15 && (Self.GetStage() < 40 || !rewardsGiven || !Self.IsCompleted())) || (act2Quest != None && act2Quest.GetStage() >= 40 && Self.GetStage() < 40)
            StartTimer(2.5, 1)
        endif
    endif
EndEvent
