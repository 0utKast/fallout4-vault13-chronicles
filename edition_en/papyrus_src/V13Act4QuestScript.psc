Scriptname V13Act4QuestScript extends Quest

int hitCounter = 0
bool introShown = false
bool rewardsGiven = false
bool bStage30Done = false
bool bStage40Rewarded = false
bool bApplyingAct4Stage = false

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

Function SetMariposaState(bool abEnabled)
    ObjectReference ltChest = Game.GetFormFromFile(0x00002C10, "Vault13Chronicles.esp") as ObjectReference
    Actor lieutenant = Game.GetFormFromFile(0x00002C11, "Vault13Chronicles.esp") as Actor
    Actor g1 = Game.GetFormFromFile(0x00002C12, "Vault13Chronicles.esp") as Actor
    Actor g2 = Game.GetFormFromFile(0x00002C20, "Vault13Chronicles.esp") as Actor
    Actor g3 = Game.GetFormFromFile(0x00002C21, "Vault13Chronicles.esp") as Actor
    ObjectReference termMariposa = Game.GetFormFromFile(0x00002C30, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference d2C01 = Game.GetFormFromFile(0x00002C01, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference d2C03 = Game.GetFormFromFile(0x00002C03, "Vault13Chronicles.esp") as ObjectReference
    Form winchesterP94 = Game.GetFormFromFile(0x0000110B, "Vault13Chronicles.esp")

    V13Act1QuestScript act1S = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as V13Act1QuestScript
    if act1S != None
        act1S.SyncVault13ExpeditionDoors()
    endif

    if abEnabled
        if d2C01 != None
            d2C01.Enable(false)
            d2C01.Lock(false, false)
        endif
        if d2C03 != None
            d2C03.Enable(false)
            d2C03.Lock(false, false)
        endif
        if ltChest != None
            ltChest.Enable(false)
        endif
        if termMariposa != None
            termMariposa.Enable(false)
        endif
        if lieutenant != None
            if lieutenant.IsDead()
                lieutenant.Resurrect()
            endif
            lieutenant.Enable(false)
            if !lieutenant.IsDead() && winchesterP94 != None
                if lieutenant.GetItemCount(winchesterP94) > 1
                    lieutenant.RemoveItem(winchesterP94, lieutenant.GetItemCount(winchesterP94) - 1, true, None)
                endif
                if lieutenant.GetItemCount(winchesterP94) > 0 && !lieutenant.IsEquipped(winchesterP94)
                    lieutenant.EquipItem(winchesterP94, false, true)
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
        int cIdx = 2
        while cIdx < 7
            ObjectReference cExtra = Game.GetFormFromFile(0x00002C20 + cIdx, "Vault13Chronicles.esp") as ObjectReference
            if cExtra != None
                Actor cAct = cExtra as Actor
                if cAct != None && cAct.IsDead()
                    cAct.Resurrect()
                endif
                cExtra.Enable(false)
            endif
            cIdx += 1
        endwhile
    endif
EndFunction

Function GiveAct4CompletionRewards()
    if rewardsGiven
        return
    endif
    rewardsGiven = true
    Actor player = Game.GetPlayer()
    Form mariposaCodes = Game.GetFormFromFile(0x00001114, "Vault13Chronicles.esp")
    Form winchesterP94 = Game.GetFormFromFile(0x0000110B, "Vault13Chronicles.esp")
    Actor lieutenant = Game.GetFormFromFile(0x00002C11, "Vault13Chronicles.esp") as Actor
    ObjectReference ltChest = Game.GetFormFromFile(0x00002C10, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference relicDisplay4 = Game.GetFormFromFile(0x00002034, "Vault13Chronicles.esp") as ObjectReference
    Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
    Form stimpak = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
    Form plasmaAmmo = Game.GetFormFromFile(0x0001DBB7, "Fallout4.esm")

    if player != None
        if mariposaCodes != None
            if player.GetItemCount(mariposaCodes) > 0
                player.RemoveItem(mariposaCodes, player.GetItemCount(mariposaCodes), true, None)
            endif
            if ltChest != None && ltChest.GetItemCount(mariposaCodes) > 0
                ltChest.RemoveItem(mariposaCodes, ltChest.GetItemCount(mariposaCodes), true, None)
            endif
        endif
        if winchesterP94 != None
            if player.GetItemCount(winchesterP94) == 0
                if lieutenant != None && lieutenant.GetItemCount(winchesterP94) > 0
                    lieutenant.RemoveItem(winchesterP94, 1, true, player)
                else
                    player.AddItem(winchesterP94, 1, false)
                endif
            endif
            if lieutenant != None && lieutenant.GetItemCount(winchesterP94) > 0
                lieutenant.RemoveItem(winchesterP94, lieutenant.GetItemCount(winchesterP94), true, None)
            endif
            if player.GetItemCount(winchesterP94) > 1
                player.RemoveItem(winchesterP94, player.GetItemCount(winchesterP94) - 1, true, None)
            endif
        endif
        if caps != None
            player.AddItem(caps, 1500, false)
        endif
        if stimpak != None
            player.AddItem(stimpak, 8, false)
        endif
        if plasmaAmmo != None
            player.AddItem(plasmaAmmo, 80, false)
        endif
    endif

    if relicDisplay4 != None
        relicDisplay4.Enable(false)
    endif

    Game.RewardPlayerXP(1200, false)
    Debug.Notification("[Vault 13 Chronicles] Mariposa FEV Vats destroyed! Winchester P94 Turbo Plasma Rifle unlocked!")
EndFunction

Function ForceAllAct4Aliases()
    ForceQuestAlias(0, 0x00002110)
    ForceQuestAlias(1, 0x00002C10)
    ForceQuestAlias(2, 0x00003005)
    ForceQuestAlias(3, 0x00002003)
    ForceQuestAlias(4, 0x00003508)
    ForceQuestAlias(5, 0x00002144)
    ForceQuestAlias(6, 0x00003501)
    ForceQuestAlias(7, 0x00002C03)
EndFunction

Function ApplyV13Act4Stage(int auiStage)
    if bApplyingAct4Stage
        return
    endif
    bApplyingAct4Stage = true

    V13Act1QuestScript act1S = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as V13Act1QuestScript
    bool inDial = (act1S != None && act1S.IsJacorenInDialogueOrScene())
    ForceAllAct4Aliases()

    if auiStage < 15
        bApplyingAct4Stage = false
        return
    endif

    if !inDial
        SetMariposaState(true)
    elseif act1S != None
        act1S.SyncVault13ExpeditionDoors()
    endif

    if auiStage >= 15 && !introShown
        if !Utility.IsInMenuMode()
            introShown = true
            Message radioMsg = Game.GetFormFromFile(0x00001153, "Vault13Chronicles.esp") as Message
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
        Cell mariposaCell = Game.GetFormFromFile(0x00002C00, "Vault13Chronicles.esp") as Cell
        bool inWastelandOrDungeon = (player != None && ((ws2161 != None && player.GetWorldSpace() == ws2161) || (mariposaCell != None && player.GetParentCell() == mariposaCell)))
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
            bApplyingAct4Stage = false
            StartTimer(0.2, 1)
            return
        endif
        if !bStage40Rewarded
            bStage40Rewarded = true
            GiveAct4CompletionRewards()
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
        V13Act5QuestScript act5S = Game.GetFormFromFile(0x00008000, "Vault13Chronicles.esp") as V13Act5QuestScript
        if act5S != None
            act5S.WakeUpAct5()
        endif
        if auiStage >= 45
            Quest act5Quest = Game.GetFormFromFile(0x00008000, "Vault13Chronicles.esp") as Quest
            if act5Quest != None
                if !act5Quest.IsRunning()
                    act5Quest.Start()
                endif
                if act5Quest.GetStage() < 20
                    act5Quest.SetStage(20)
                endif
            endif
        endif
    endif
    bApplyingAct4Stage = false
EndFunction

Function WakeUpAct4()
    ; Congelado en la Primera Parte del mod
    if Self.IsRunning()
        Self.Stop()
    endif
    return
EndFunction

Function CheckProgressionAndLevelGate()
    ; Congelado en la Primera Parte del mod
    if Self.IsRunning()
        Self.Stop()
    endif
    return
EndFunction

Function ProcessWinchesterP94Hit(Actor akTarget, Actor akCaster)
    if akTarget == None || akCaster == None
        return
    endif

    EffectShader shockFX = Game.GetFormFromFile(0x0006F122, "Fallout4.esm") as EffectShader
    if shockFX != None
        shockFX.Play(akTarget, 2.0)
    endif

    Actor player = Game.GetPlayer()
    if akCaster == player
        hitCounter += 1
        if hitCounter >= 3 || akTarget.IsDead()
            hitCounter = 0
            ActorValue apAV = Game.GetFormFromFile(0x000002D5, "Fallout4.esm") as ActorValue
            ActorValue hpAV = Game.GetFormFromFile(0x000002D4, "Fallout4.esm") as ActorValue
            if apAV != None
                player.RestoreValue(apAV, 35.0)
            endif
            if hpAV != None
                player.RestoreValue(hpAV, 25.0)
            endif
            Debug.Notification("[Winchester P94] Turbo plasma implosion! (+35 AP / +25 HP)")
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
    V13Act5QuestScript act5S = Game.GetFormFromFile(0x00008000, "Vault13Chronicles.esp") as V13Act5QuestScript
    if act5S != None
        act5S.WakeUpAct5()
    endif
EndEvent

Event Actor.OnItemEquipped(Actor akSender, Form akBaseObject, ObjectReference akReference)
    Form winchesterP94 = Game.GetFormFromFile(0x0000110B, "Vault13Chronicles.esp")
    if akBaseObject == winchesterP94 && winchesterP94 != None
        Debug.Notification("[Winchester P94] Turbo plasma caster active: Toroidal implosion every 3 hits (+35 AP / +25 HP)")
    endif
EndEvent

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
    if Self.GetStage() >= 15 && Self.GetStage() < 40
        ApplyV13Act4Stage(Self.GetStage())
    endif
EndEvent

Event OnStageSet(int auiStageID, int auiItemID)
    ApplyV13Act4Stage(auiStageID)
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
        Quest act3Quest = Game.GetFormFromFile(0x00006000, "Vault13Chronicles.esp") as Quest
        if (Self.GetStage() >= 15 && (Self.GetStage() < 40 || !rewardsGiven || !Self.IsCompleted())) || (act3Quest != None && act3Quest.GetStage() >= 40 && Self.GetStage() < 40)
            StartTimer(2.5, 1)
        endif
    endif
EndEvent
