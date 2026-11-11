Scriptname V13SideQuestJunktownScript extends Quest

bool bItemDelivered = False
bool bRewardGranted = False
bool bProofRecovered = False
bool bProofSeeded = False
bool bStg20Notified = False
bool bStg22Notified = False
bool bStg25Notified = False
bool bStg30Notified = False
bool bMenuJumpBusy = False
bool bSteppingCompanion = False
int sceneWaitTicks = 0
int DogmeatState = 0
int IanState = 0
int TychoState = 0
int iActiveDogFormID = 0x000035B3
bool bDogmeatMenuBusy = False
bool bDogmeatFirstRecruitXP = False
bool bIanFirstRecruitXP = False
bool bTychoFirstRecruitXP = False
int iDogmeatScavengeIdx = 0
int iIanSupplyIdx = 0
int iTychoSupplyIdx = 0
bool bDogmeatApproachCoolingDown = False
bool bDogmeatSneakCoolingDown = False
Actor rDogCombatTarget = None
ObjectReference rDogMoveTarget = None
int iDogMoveTicks = 0
int iDogBiteCooldown = 0
bool bCompanionsSuspendedInCommonwealth = False
int iSavedDogmeatState = 0
int iSavedIanState = 0
int iSavedTychoState = 0

Function ForceQuestAlias(int aiAliasID, int aiFormID)
    ObjectReference targetRef = Game.GetFormFromFile(aiFormID, "Vault13Chronicles.esp") as ObjectReference
    ReferenceAlias al = Self.GetAlias(aiAliasID) as ReferenceAlias
    if al != None && targetRef != None
        if al.GetReference() != targetRef
            al.ForceRefTo(targetRef)
        endif
    endif
EndFunction

Function ForceAllJunktownAliases()
    ForceQuestAlias(0, 0x000035C0)
    ForceQuestAlias(1, 0x000035C4)
    ForceQuestAlias(2, 0x00003005)
    ForceQuestAlias(3, 0x00002003)
    ForceQuestAlias(4, 0x0000351C)
    ForceQuestAlias(5, 0x00002101)
    ForceQuestAlias(6, 0x00003501)
    ForceQuestAlias(7, 0x00002206)
    ForceQuestAlias(8, 0x00002035)
    ForceQuestAlias(9, 0x000035C1)
    ForceQuestAlias(10, 0x000035C2)
EndFunction

Function EquipCustomGear(Actor akNpc, int aiOutfitID, int aiBodyArmorEsmID, int aiExtraArmorEsmID, int aiHatID)
    if akNpc == None || akNpc.IsDead() || !akNpc.Is3DLoaded() || akNpc.IsTalking()
        return
    endif
    Form combatHelm = Game.GetFormFromFile(0x0011E2C8, "Fallout4.esm")
    Form metalHelm = Game.GetFormFromFile(0x000787D3, "Fallout4.esm")
    if combatHelm != None && akNpc.GetItemCount(combatHelm) > 0
        akNpc.RemoveItem(combatHelm, akNpc.GetItemCount(combatHelm), true, None)
    endif
    if metalHelm != None && akNpc.GetItemCount(metalHelm) > 0
        akNpc.RemoveItem(metalHelm, akNpc.GetItemCount(metalHelm), true, None)
    endif
    Form bodyArmor = None
    if aiBodyArmorEsmID > 0
        bodyArmor = Game.GetFormFromFile(aiBodyArmorEsmID, "Fallout4.esm")
    endif
    if aiOutfitID > 0 && (bodyArmor == None || !akNpc.IsEquipped(bodyArmor))
        Outfit customOtft = Game.GetFormFromFile(aiOutfitID, "Vault13Chronicles.esp") as Outfit
        if customOtft != None
            akNpc.SetOutfit(customOtft, false)
        endif
    endif
    if bodyArmor != None && !akNpc.IsEquipped(bodyArmor)
        if akNpc.GetItemCount(bodyArmor) == 0
            akNpc.AddItem(bodyArmor, 1, true)
        endif
        akNpc.EquipItem(bodyArmor, false, true)
    endif
    if aiExtraArmorEsmID > 0
        Form extraArmor = Game.GetFormFromFile(aiExtraArmorEsmID, "Fallout4.esm")
        if extraArmor != None && !akNpc.IsEquipped(extraArmor)
            if akNpc.GetItemCount(extraArmor) == 0
                akNpc.AddItem(extraArmor, 1, true)
            endif
            akNpc.EquipItem(extraArmor, false, true)
        endif
    endif
    if aiHatID > 0
        Form customHat = Game.GetFormFromFile(aiHatID, "Vault13Chronicles.esp")
        if customHat != None && !akNpc.IsEquipped(customHat)
            if akNpc.GetItemCount(customHat) == 0
                akNpc.AddItem(customHat, 1, true)
            endif
            akNpc.EquipItem(customHat, false, true)
        endif
    endif
EndFunction

Actor Function GetActiveDogmeatActor()
    iActiveDogFormID = 0x000035B3
    Actor shadyDog = Game.GetFormFromFile(0x000035B3, "Vault13Chronicles.esp") as Actor
    if shadyDog != None
        return shadyDog
    endif
    return Game.GetFormFromFile(0x000035C3, "Vault13Chronicles.esp") as Actor
EndFunction

bool Function IsDogmeatRecruited()
    return DogmeatState >= 1 || iSavedDogmeatState >= 1
EndFunction

bool Function IsIanRecruited()
    return IanState >= 1 || iSavedIanState >= 1
EndFunction

bool Function IsTychoRecruited()
    return TychoState >= 1 || iSavedTychoState >= 1
EndFunction

Actor Function GetIanActor()
    return Game.GetFormFromFile(0x000035A4, "Vault13Chronicles.esp") as Actor
EndFunction

Actor Function GetTychoActor()
    return Game.GetFormFromFile(0x000035C2, "Vault13Chronicles.esp") as Actor
EndFunction

bool Function IsPlayerInVault13Space()
    Actor player = Game.GetPlayer()
    if player == None
        return False
    endif
    WorldSpace v13Wrld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if v13Wrld != None && player.GetWorldSpace() == v13Wrld
        return True
    endif
    if !player.IsInInterior()
        return False
    endif
    Cell pCell = player.GetParentCell()
    if pCell == None
        return False
    endif
    if pCell == (Game.GetFormFromFile(0x00002100, "Vault13Chronicles.esp") as Cell)
        return True
    elseif pCell == (Game.GetFormFromFile(0x00002200, "Vault13Chronicles.esp") as Cell)
        return True
    elseif pCell == (Game.GetFormFromFile(0x00002500, "Vault13Chronicles.esp") as Cell)
        return True
    elseif pCell == (Game.GetFormFromFile(0x00002900, "Vault13Chronicles.esp") as Cell)
        return True
    elseif pCell == (Game.GetFormFromFile(0x00002A00, "Vault13Chronicles.esp") as Cell)
        return True
    elseif pCell == (Game.GetFormFromFile(0x00002B00, "Vault13Chronicles.esp") as Cell)
        return True
    elseif pCell == (Game.GetFormFromFile(0x00002C00, "Vault13Chronicles.esp") as Cell)
        return True
    elseif pCell == (Game.GetFormFromFile(0x00002D00, "Vault13Chronicles.esp") as Cell)
        return True
    elseif pCell == (Game.GetFormFromFile(0x00002E00, "Vault13Chronicles.esp") as Cell)
        return True
    elseif pCell == (Game.GetFormFromFile(0x00002F00, "Vault13Chronicles.esp") as Cell)
        return True
    endif
    return False
EndFunction

Function PlayDogmeatVocal(Actor akDog, int aiType)
    if akDog == None || akDog.IsDead()
        return
    endif
    int sounFormID = 0x0000106D
    if aiType == 2
        sounFormID = 0x0000106F
    elseif aiType == 3
        sounFormID = 0x00001071
    elseif aiType == 4
        sounFormID = 0x00001073
    elseif aiType == 5
        sounFormID = 0x00001075
    endif
    Sound dogSnd = Game.GetFormFromFile(sounFormID, "Vault13Chronicles.esp") as Sound
    if dogSnd != None
        if akDog.Is3DLoaded()
            dogSnd.Play(akDog as ObjectReference)
        else
            Actor player = Game.GetPlayer()
            if player != None
                dogSnd.Play(player as ObjectReference)
            endif
        endif
    endif
EndFunction

Function DismissDogmeatToShadySands(bool abShowNotification)
    DogmeatState = 0
    if abShowNotification
        iSavedDogmeatState = 0
    endif
    rDogCombatTarget = None
    rDogMoveTarget = None
    iDogMoveTicks = 0
    ActorValue aggressionAV = Game.GetFormFromFile(0x000002BC, "Fallout4.esm") as ActorValue
    ActorValue confidenceAV = Game.GetFormFromFile(0x000002BD, "Fallout4.esm") as ActorValue
    ActorValue followerStateAV = Game.GetFormFromFile(0x00000344, "Fallout4.esm") as ActorValue
    Faction curCompFaction = Game.GetFormFromFile(0x00023C01, "Fallout4.esm") as Faction
    Faction dogmeatFact = Game.GetFormFromFile(0x0006E269, "Fallout4.esm") as Faction
    WorldSpace v13Wrld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    ObjectReference shadyFT = Game.GetFormFromFile(0x00003512, "Vault13Chronicles.esp") as ObjectReference

    Actor dogJunktown = Game.GetFormFromFile(0x000035C3, "Vault13Chronicles.esp") as Actor
    if dogJunktown != None
        dogJunktown.StopCombat()
        dogJunktown.SetCommandState(False)
        dogJunktown.SetCanDoCommand(False)
        if dogJunktown.IsPlayerTeammate()
            dogJunktown.SetPlayerTeammate(False, False, False)
        endif
        if curCompFaction != None && dogJunktown.IsInFaction(curCompFaction)
            dogJunktown.RemoveFromFaction(curCompFaction)
        endif
        if dogmeatFact != None && dogJunktown.IsInFaction(dogmeatFact)
            dogJunktown.RemoveFromFaction(dogmeatFact)
        endif
        if confidenceAV != None
            dogJunktown.SetValue(confidenceAV, 4.0)
        endif
        if !dogJunktown.IsDisabled()
            dogJunktown.DisableNoWait()
        endif
    endif

    Actor dogShady = Game.GetFormFromFile(0x000035B3, "Vault13Chronicles.esp") as Actor
    if dogShady != None
        if dogShady.IsDisabled()
            dogShady.EnableNoWait()
        endif
        if abShowNotification
            PlayDogmeatVocal(dogShady, 5)
        endif
        dogShady.StopCombat()
        dogShady.SetCommandState(False)
        dogShady.SetCanDoCommand(False)
        if dogShady.IsPlayerTeammate()
            dogShady.SetPlayerTeammate(False, False, False)
        endif
        if curCompFaction != None && dogShady.IsInFaction(curCompFaction)
            dogShady.RemoveFromFaction(curCompFaction)
        endif
        if dogmeatFact != None && dogShady.IsInFaction(dogmeatFact)
            dogShady.RemoveFromFaction(dogmeatFact)
        endif
        if aggressionAV != None
            dogShady.SetValue(aggressionAV, 0.0)
        endif
        if confidenceAV != None
            dogShady.SetValue(confidenceAV, 4.0)
        endif
        if followerStateAV != None
            dogShady.SetValue(followerStateAV, 2.0)
        endif
        if shadyFT != None && (v13Wrld == None || dogShady.GetWorldSpace() != v13Wrld || dogShady.IsInInterior() || abShowNotification)
            dogShady.MoveTo(shadyFT, 0.0, 200.0, 0.0, false)
        endif
        if v13Wrld != None && dogShady.GetWorldSpace() == v13Wrld && dogShady.Is3DLoaded()
            dogShady.SetPosition(2600.0, 9600.0, 160.0)
        endif
        dogShady.EvaluatePackage(True)
    endif

    Quest vanillaDogQ = Game.GetFormFromFile(0x0006DFAF, "Fallout4.esm") as Quest
    GlobalVariable knowsNameGlob = Game.GetFormFromFile(0x0004AF3D, "Fallout4.esm") as GlobalVariable
    if vanillaDogQ != None && knowsNameGlob != None && vanillaDogQ.GetStage() < 2
        knowsNameGlob.SetValue(0.0)
    endif

    if abShowNotification
        Debug.Notification("Albóndiga (2161) ha dejado de ser tu compañero y ha regresado a Shady Sands.")
    endif
EndFunction

Function DismissIanToShadySands(bool abShowNotification)
    IanState = 0
    if abShowNotification
        iSavedIanState = 0
    endif
    ActorValue aggressionAV = Game.GetFormFromFile(0x000002BC, "Fallout4.esm") as ActorValue
    ActorValue confidenceAV = Game.GetFormFromFile(0x000002BD, "Fallout4.esm") as ActorValue
    ActorValue followerStateAV = Game.GetFormFromFile(0x00000344, "Fallout4.esm") as ActorValue
    Faction curCompFaction = Game.GetFormFromFile(0x00023C01, "Fallout4.esm") as Faction
    WorldSpace v13Wrld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    ObjectReference shadyFT = Game.GetFormFromFile(0x00003512, "Vault13Chronicles.esp") as ObjectReference
    Actor ianAct = GetIanActor()
    if ianAct != None
        if ianAct.IsDisabled()
            ianAct.EnableNoWait()
        endif
        ianAct.StopCombat()
        ianAct.SetCommandState(False)
        ianAct.SetCanDoCommand(False)
        if ianAct.IsPlayerTeammate()
            ianAct.SetPlayerTeammate(False, False, False)
        endif
        if curCompFaction != None && ianAct.IsInFaction(curCompFaction)
            ianAct.RemoveFromFaction(curCompFaction)
        endif
        if aggressionAV != None
            ianAct.SetValue(aggressionAV, 0.0)
        endif
        if confidenceAV != None
            ianAct.SetValue(confidenceAV, 4.0)
        endif
        if followerStateAV != None
            ianAct.SetValue(followerStateAV, 2.0)
        endif
        if shadyFT != None && (v13Wrld == None || ianAct.GetWorldSpace() != v13Wrld || ianAct.IsInInterior() || abShowNotification)
            ianAct.MoveTo(shadyFT, -220.0, 120.0, 0.0, false)
        endif
        if v13Wrld != None && ianAct.GetWorldSpace() == v13Wrld && ianAct.Is3DLoaded()
            ianAct.SetPosition(1810.0, 9460.0, 160.0)
            ianAct.SetAngle(0.0, 0.0, 180.0)
        endif
        ianAct.EvaluatePackage(True)
    endif
    if abShowNotification
        Debug.Notification("Ian ha dejado de ser tu compañero y ha regresado a su puesto de guardia en Shady Sands.")
    endif
EndFunction

Function DismissTychoToJunktown(bool abShowNotification)
    TychoState = 0
    if abShowNotification
        iSavedTychoState = 0
    endif
    ActorValue aggressionAV = Game.GetFormFromFile(0x000002BC, "Fallout4.esm") as ActorValue
    ActorValue confidenceAV = Game.GetFormFromFile(0x000002BD, "Fallout4.esm") as ActorValue
    ActorValue followerStateAV = Game.GetFormFromFile(0x00000344, "Fallout4.esm") as ActorValue
    Faction curCompFaction = Game.GetFormFromFile(0x00023C01, "Fallout4.esm") as Faction
    WorldSpace v13Wrld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    ObjectReference junkFT = Game.GetFormFromFile(0x00003513, "Vault13Chronicles.esp") as ObjectReference
    Actor tychoAct = GetTychoActor()
    if tychoAct != None
        if tychoAct.IsDisabled()
            tychoAct.EnableNoWait()
        endif
        tychoAct.StopCombat()
        tychoAct.SetCommandState(False)
        tychoAct.SetCanDoCommand(False)
        if tychoAct.IsPlayerTeammate()
            tychoAct.SetPlayerTeammate(False, False, False)
        endif
        if curCompFaction != None && tychoAct.IsInFaction(curCompFaction)
            tychoAct.RemoveFromFaction(curCompFaction)
        endif
        if aggressionAV != None
            tychoAct.SetValue(aggressionAV, 0.0)
        endif
        if confidenceAV != None
            tychoAct.SetValue(confidenceAV, 4.0)
        endif
        if followerStateAV != None
            tychoAct.SetValue(followerStateAV, 2.0)
        endif
        if junkFT != None && (v13Wrld == None || tychoAct.GetWorldSpace() != v13Wrld || tychoAct.IsInInterior() || abShowNotification)
            tychoAct.MoveTo(junkFT, 120.0, 220.0, 0.0, false)
        endif
        if v13Wrld != None && tychoAct.GetWorldSpace() == v13Wrld && tychoAct.Is3DLoaded()
            tychoAct.SetPosition(3600.0, 4280.0, 80.0)
            tychoAct.SetAngle(0.0, 0.0, 180.0)
        endif
        tychoAct.EvaluatePackage(True)
    endif
    if abShowNotification
        Debug.Notification("El Ranger Tycho ha dejado de ser tu compañero y ha regresado a Junktown.")
    endif
EndFunction

Function SuspendCompanionsForCommonwealth()
    bool bHadActive = False
    if DogmeatState > 0
        iSavedDogmeatState = DogmeatState
        bHadActive = True
    endif
    if IanState > 0
        iSavedIanState = IanState
        bHadActive = True
    endif
    if TychoState > 0
        iSavedTychoState = TychoState
        bHadActive = True
    endif
    WorldSpace v13Wrld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    Actor dogShady = Game.GetFormFromFile(0x000035B3, "Vault13Chronicles.esp") as Actor
    Actor ianAct = GetIanActor()
    Actor tychoAct = GetTychoActor()
    if DogmeatState != 0 || (dogShady != None && (dogShady.IsPlayerTeammate() || (v13Wrld != None && dogShady.GetWorldSpace() != v13Wrld)))
        DismissDogmeatToShadySands(False)
    endif
    if IanState != 0 || (ianAct != None && (ianAct.IsPlayerTeammate() || (v13Wrld != None && ianAct.GetWorldSpace() != v13Wrld)))
        DismissIanToShadySands(False)
    endif
    if TychoState != 0 || (tychoAct != None && (tychoAct.IsPlayerTeammate() || (v13Wrld != None && tychoAct.GetWorldSpace() != v13Wrld)))
        DismissTychoToJunktown(False)
    endif
    if !bCompanionsSuspendedInCommonwealth && (bHadActive || iSavedDogmeatState > 0 || iSavedIanState > 0 || iSavedTychoState > 0)
        bCompanionsSuspendedInCommonwealth = True
        Debug.Notification("[Grupo de California] Tus compañeros de 2161 aguardan en Nueva California hasta tu regreso.")
    endif
EndFunction

Function RestoreCompanionsOnReturnTo2161()
    if !IsPlayerInVault13Space()
        return
    endif
    bool bRestoredAny = False
    if iSavedDogmeatState > 0
        int targetDogState = iSavedDogmeatState
        iSavedDogmeatState = 0
        DogmeatState = targetDogState
        Actor activeDog = GetActiveDogmeatActor()
        if activeDog != None
            if targetDogState == 1
                SetDogmeatFollowMode(activeDog)
            else
                ConfigureDogmeatCombatAI(activeDog, 4.0)
                activeDog.FollowerWait()
                activeDog.EvaluatePackage(True)
                RefreshDogmeatAppearance(activeDog)
            endif
            bRestoredAny = True
        endif
    endif
    if iSavedIanState > 0
        int targetIanState = iSavedIanState
        iSavedIanState = 0
        IanState = targetIanState
        Actor ianAct = GetIanActor()
        if ianAct != None
            if targetIanState == 1
                SetIanFollowMode(ianAct)
            else
                ConfigureDogmeatCombatAI(ianAct, 4.0)
                ianAct.FollowerWait()
                ianAct.EvaluatePackage(True)
                RefreshIanCompanionGear(ianAct)
            endif
            bRestoredAny = True
        endif
    endif
    if iSavedTychoState > 0
        int targetTychoState = iSavedTychoState
        iSavedTychoState = 0
        TychoState = targetTychoState
        Actor tychoAct = GetTychoActor()
        if tychoAct != None
            if targetTychoState == 1
                SetTychoFollowMode(tychoAct)
            else
                ConfigureDogmeatCombatAI(tychoAct, 4.0)
                tychoAct.FollowerWait()
                tychoAct.EvaluatePackage(True)
                RefreshTychoCompanionGear(tychoAct)
            endif
            bRestoredAny = True
        endif
    endif
    if bCompanionsSuspendedInCommonwealth
        bCompanionsSuspendedInCommonwealth = False
    endif
    if bRestoredAny
        SyncDogmeatWithPlayer()
        Debug.Notification("[Grupo de California] Tus compañeros de 2161 se han reincorporado a tu grupo.")
    endif
EndFunction

Function RefreshIanCompanionGear(Actor akIan)
    if akIan == None || akIan.IsDead()
        return
    endif
    if akIan.IsDisabled()
        akIan.EnableNoWait()
    endif
    RegisterForRemoteEvent(akIan as ObjectReference, "OnActivate")
    RegisterForRemoteEvent(akIan, "OnCommandModeGiveCommand")
    RegisterForRemoteEvent(akIan, "OnCompanionDismiss")
    if !akIan.Is3DLoaded()
        return
    endif
    akIan.BlockActivation(False, False)
    if !akIan.IsDoingFavor()
        akIan.AllowPCDialogue(False)
    endif
    EquipCustomGear(akIan, 0x00001025, 0x0014BF50, 0, 0)
    Form coltPistol = Game.GetFormFromFile(0x00001102, "Vault13Chronicles.esp")
    if coltPistol != None
        if akIan.GetItemCount(coltPistol) == 0
            akIan.AddItem(coltPistol, 1, True)
            akIan.EquipItem(coltPistol, False, True)
        endif
    endif
    Form ammo10 = Game.GetFormFromFile(0x0001F276, "Fallout4.esm")
    if ammo10 != None && akIan.GetItemCount(ammo10) < 60
        akIan.AddItem(ammo10, 140, True)
    endif
EndFunction

Function RefreshTychoCompanionGear(Actor akTycho)
    if akTycho == None || akTycho.IsDead()
        return
    endif
    if akTycho.IsDisabled()
        akTycho.EnableNoWait()
    endif
    RegisterForRemoteEvent(akTycho as ObjectReference, "OnActivate")
    RegisterForRemoteEvent(akTycho, "OnCommandModeGiveCommand")
    RegisterForRemoteEvent(akTycho, "OnCompanionDismiss")
    if !akTycho.Is3DLoaded()
        return
    endif
    akTycho.BlockActivation(False, False)
    if !akTycho.IsDoingFavor()
        akTycho.AllowPCDialogue(False)
    endif
    EquipCustomGear(akTycho, 0x00001022, 0x001153DB, 0, 0x00001315)
    Form cShotgun = Game.GetFormFromFile(0x0014831C, "Fallout4.esm")
    if cShotgun != None && akTycho.GetItemCount(cShotgun) == 0
        akTycho.AddItem(cShotgun, 1, True)
        akTycho.EquipItem(cShotgun, False, True)
    endif
    Form shells = Game.GetFormFromFile(0x0001F673, "Fallout4.esm")
    if shells != None && akTycho.GetItemCount(shells) < 50
        akTycho.AddItem(shells, 120, True)
    endif
    Form ammo308 = Game.GetFormFromFile(0x0001F66B, "Fallout4.esm")
    if ammo308 != None && akTycho.GetItemCount(ammo308) < 30
        akTycho.AddItem(ammo308, 60, True)
    endif
EndFunction

Function SetIanFollowMode(Actor akIan)
    if akIan == None
        return
    endif
    if !IsPlayerInVault13Space()
        DismissIanToShadySands(False)
        return
    endif
    if akIan.IsDisabled()
        akIan.EnableNoWait()
    endif
    IanState = 1
    ConfigureDogmeatCombatAI(akIan, 2.0)
    akIan.SetCommandState(False)
    akIan.AllowPCDialogue(False)
    akIan.IgnoreFriendlyHits(True)
    akIan.SetPlayerTeammate(True, True, True)
    akIan.SetCanDoCommand(True)
    akIan.AllowCompanion(True, True)
    akIan.FollowerFollow()
    akIan.FollowerSetDistanceNear()
    akIan.EvaluatePackage(True)
    RefreshIanCompanionGear(akIan)
    Actor player = Game.GetPlayer()
    if player != None
        RegisterForRemoteEvent(player, "OnCombatStateChanged")
        RegisterForHitEvent(player)
    endif
    RegisterForPlayerTeleport()
    StartTimer(3.0, 96)
    StartTimer(0.75, 98)
EndFunction

Function SetTychoFollowMode(Actor akTycho)
    if akTycho == None
        return
    endif
    if !IsPlayerInVault13Space()
        DismissTychoToJunktown(False)
        return
    endif
    if akTycho.IsDisabled()
        akTycho.EnableNoWait()
    endif
    TychoState = 1
    ConfigureDogmeatCombatAI(akTycho, 2.0)
    akTycho.SetCommandState(False)
    akTycho.AllowPCDialogue(False)
    akTycho.IgnoreFriendlyHits(True)
    akTycho.SetPlayerTeammate(True, True, True)
    akTycho.SetCanDoCommand(True)
    akTycho.AllowCompanion(True, True)
    akTycho.FollowerFollow()
    akTycho.FollowerSetDistanceNear()
    akTycho.EvaluatePackage(True)
    RefreshTychoCompanionGear(akTycho)
    Actor player = Game.GetPlayer()
    if player != None
        RegisterForRemoteEvent(player, "OnCombatStateChanged")
        RegisterForHitEvent(player)
    endif
    RegisterForPlayerTeleport()
    StartTimer(3.0, 96)
    StartTimer(0.75, 98)
EndFunction

Function EnsurePlayerHasDogmeatItems()
    if !IsPlayerInVault13Space()
        return
    endif
    Actor player = Game.GetPlayer()
    if player == None
        return
    endif
    Form leatherJacket = Game.GetFormFromFile(0x0014BF50, "Fallout4.esm")
    if leatherJacket != None && player.GetItemCount(leatherJacket) == 0
        player.AddItem(leatherJacket, 1, True)
    endif
    Form iguanaStick = Game.GetFormFromFile(0x000330FE, "Fallout4.esm")
    if iguanaStick != None && player.GetItemCount(iguanaStick) == 0
        player.AddItem(iguanaStick, 2, True)
    endif
EndFunction

Function RefreshDogmeatAppearance(Actor akDog)
    if akDog == None || akDog.IsDead()
        return
    endif
    if akDog.IsDisabled()
        akDog.EnableNoWait()
    endif
    akDog.EnableAI(True)
    RegisterForRemoteEvent(akDog as ObjectReference, "OnActivate")
    RegisterForRemoteEvent(akDog, "OnCommandModeGiveCommand")
    RegisterForRemoteEvent(akDog, "OnCompanionDismiss")
    if !akDog.Is3DLoaded()
        return
    endif
    akDog.BlockActivation(False, False)
    akDog.AllowPCDialogue(True)
    Form dogCollar = Game.GetFormFromFile(0x00034602, "Fallout4.esm")
    if dogCollar != None && akDog.GetItemCount(dogCollar) > 0
        akDog.RemoveItem(dogCollar, akDog.GetItemCount(dogCollar), True, None)
    endif
    Form redBandana = Game.GetFormFromFile(0x0009C05B, "Fallout4.esm")
    if redBandana != None && akDog.GetItemCount(redBandana) > 0
        akDog.RemoveItem(redBandana, akDog.GetItemCount(redBandana), True, None)
    endif
    Form skinDogmeat = Game.GetFormFromFile(0x0001D725, "Fallout4.esm")
    if skinDogmeat != None && akDog.GetItemCount(skinDogmeat) > 0
        akDog.RemoveItem(skinDogmeat, akDog.GetItemCount(skinDogmeat), True, None)
    endif
    Form v13DogSkin = Game.GetFormFromFile(0x00001319, "Vault13Chronicles.esp")
    if v13DogSkin != None && !akDog.IsEquipped(v13DogSkin)
        if akDog.GetItemCount(v13DogSkin) == 0
            akDog.AddItem(v13DogSkin, 1, true)
        endif
        akDog.EquipItem(v13DogSkin, false, true)
    endif
    Form medArmor = Game.GetFormFromFile(0x001C32C8, "Fallout4.esm")
    Form reinfCollar = Game.GetFormFromFile(0x001C67B2, "Fallout4.esm")
    if medArmor != None && akDog.IsEquipped(medArmor) && reinfCollar != None && akDog.IsEquipped(reinfCollar)
        return
    endif
    Outfit dogOtft = Game.GetFormFromFile(0x0000102D, "Vault13Chronicles.esp") as Outfit
    if dogOtft != None
        akDog.SetOutfit(dogOtft, false)
    endif
    if medArmor != None
        if akDog.GetItemCount(medArmor) == 0
            akDog.AddItem(medArmor, 1, true)
        endif
        if !akDog.IsEquipped(medArmor)
            akDog.EquipItem(medArmor, false, true)
        endif
    endif
    if reinfCollar != None
        if akDog.GetItemCount(reinfCollar) == 0
            akDog.AddItem(reinfCollar, 1, true)
        endif
        if !akDog.IsEquipped(reinfCollar)
            akDog.EquipItem(reinfCollar, false, true)
        endif
    endif
EndFunction

Function ConfigureDogmeatCombatAI(Actor akDog, float afConfidence)
    if akDog == None || akDog.IsDead()
        return
    endif
    akDog.EnableAI(True)
    ActorValue aggressionAV = Game.GetFormFromFile(0x000002BC, "Fallout4.esm") as ActorValue
    ActorValue confidenceAV = Game.GetFormFromFile(0x000002BD, "Fallout4.esm") as ActorValue
    ActorValue assistanceAV = Game.GetFormFromFile(0x000002BF, "Fallout4.esm") as ActorValue
    ActorValue followerStateAV = Game.GetFormFromFile(0x00000344, "Fallout4.esm") as ActorValue
    if aggressionAV != None
        if afConfidence >= 3.0
            akDog.SetValue(aggressionAV, 0.0)
        else
            akDog.SetValue(aggressionAV, 1.0)
        endif
    endif
    if confidenceAV != None
        akDog.SetValue(confidenceAV, afConfidence)
    endif
    if assistanceAV != None
        akDog.SetValue(assistanceAV, 2.0)
    endif
    if followerStateAV != None
        if afConfidence < 2.5
            akDog.SetValue(followerStateAV, 1.0)
        else
            akDog.SetValue(followerStateAV, 2.0)
        endif
    endif
    Faction playerFaction = Game.GetFormFromFile(0x0001C21C, "Fallout4.esm") as Faction
    if playerFaction != None && !akDog.IsInFaction(playerFaction)
        akDog.AddToFaction(playerFaction)
    endif
    Faction curCompFaction = Game.GetFormFromFile(0x00023C01, "Fallout4.esm") as Faction
    if curCompFaction != None
        if afConfidence < 2.5 && !akDog.IsInFaction(curCompFaction)
            akDog.AddToFaction(curCompFaction)
        elseif afConfidence >= 2.5 && akDog.IsInFaction(curCompFaction)
            akDog.RemoveFromFaction(curCompFaction)
        endif
    endif
EndFunction

Function SetDogmeatFollowMode(Actor akDog)
    if akDog == None
        return
    endif
    if !IsPlayerInVault13Space()
        DismissDogmeatToShadySands(False)
        return
    endif
    Actor dogJunktown = Game.GetFormFromFile(0x000035C3, "Vault13Chronicles.esp") as Actor
    Actor dogShady = Game.GetFormFromFile(0x000035B3, "Vault13Chronicles.esp") as Actor
    if akDog == dogShady
        iActiveDogFormID = 0x000035B3
        if dogJunktown != None && !dogJunktown.IsDisabled()
            dogJunktown.DisableNoWait()
        endif
    else
        iActiveDogFormID = 0x000035C3
        if dogShady != None && !dogShady.IsDisabled()
            dogShady.DisableNoWait()
        endif
    endif
    if akDog.IsDisabled()
        akDog.EnableNoWait()
    endif
    akDog.EnableAI(True)
    DogmeatState = 1
    rDogMoveTarget = None
    iDogMoveTicks = 0
    ConfigureDogmeatCombatAI(akDog, 2.0)
    akDog.AllowPCDialogue(True)
    akDog.IgnoreFriendlyHits(True)
    akDog.SetPlayerTeammate(True, True, True)
    akDog.SetCanDoCommand(True)
    akDog.FollowerFollow()
    akDog.FollowerSetDistanceNear()
    akDog.EvaluatePackage(True)
    RefreshDogmeatAppearance(akDog)
    Actor player = Game.GetPlayer()
    if player != None
        RegisterForRemoteEvent(player, "OnCombatStateChanged")
        RegisterForHitEvent(player)
        if akDog.GetDistance(player) > 160.0
            StepDogmeatInExterior(akDog, player as ObjectReference, 145.0, 310.0)
        endif
    endif
    RegisterForPlayerTeleport()
    StartTimer(2.0, 96)
    StartTimer(0.25, 98)
EndFunction

Function SyncDogmeatWithPlayer()
    if !IsPlayerInVault13Space()
        SuspendCompanionsForCommonwealth()
        return
    endif
    if bCompanionsSuspendedInCommonwealth || iSavedDogmeatState > 0 || iSavedIanState > 0 || iSavedTychoState > 0
        RestoreCompanionsOnReturnTo2161()
    endif
    if DogmeatState < 1 && IanState < 1 && TychoState < 1
        return
    endif
    Actor player = Game.GetPlayer()
    if player == None
        return
    endif
    float angZ = player.GetAngleZ()
    Actor dogAct = GetActiveDogmeatActor()
    if DogmeatState >= 1 && dogAct != None && !dogAct.IsDead()
        if dogAct.IsDisabled()
            dogAct.EnableNoWait()
        endif
        if DogmeatState == 1
            ConfigureDogmeatCombatAI(dogAct, 2.0)
            if !dogAct.IsPlayerTeammate()
                dogAct.SetPlayerTeammate(True, True, True)
                dogAct.SetCanDoCommand(True)
            endif
            bool bNeedTeleport = False
            if dogAct.GetWorldSpace() != player.GetWorldSpace()
                bNeedTeleport = True
            elseif dogAct.IsInInterior() != player.IsInInterior()
                bNeedTeleport = True
            elseif dogAct.GetDistance(player) > 2200.0 && rDogCombatTarget == None
                bNeedTeleport = True
            endif
            if bNeedTeleport
                dogAct.StopCombat()
                float offX = -125.0 * Math.Sin(angZ) + 55.0 * Math.Cos(angZ)
                float offY = -125.0 * Math.Cos(angZ) - 55.0 * Math.Sin(angZ)
                dogAct.MoveTo(player, offX, offY, 0.0, false)
                dogAct.SetAngle(0.0, 0.0, angZ)
                dogAct.EvaluatePackage(False)
            endif
        endif
        RefreshDogmeatAppearance(dogAct)
    endif

    Actor ianAct = GetIanActor()
    if IanState >= 1 && ianAct != None && !ianAct.IsDead()
        if ianAct.IsDisabled()
            ianAct.EnableNoWait()
        endif
        if IanState == 1
            ConfigureDogmeatCombatAI(ianAct, 2.0)
            if !ianAct.IsPlayerTeammate()
                ianAct.SetPlayerTeammate(True, True, True)
                ianAct.SetCanDoCommand(True)
            endif
            bool bIanTp = False
            if ianAct.GetWorldSpace() != player.GetWorldSpace()
                bIanTp = True
            elseif ianAct.IsInInterior() != player.IsInInterior()
                bIanTp = True
            elseif ianAct.GetDistance(player) > 2200.0 && !ianAct.IsInCombat()
                bIanTp = True
            endif
            if bIanTp
                ianAct.StopCombat()
                float offXI = -145.0 * Math.Sin(angZ) - 75.0 * Math.Cos(angZ)
                float offYI = -145.0 * Math.Cos(angZ) + 75.0 * Math.Sin(angZ)
                ianAct.MoveTo(player, offXI, offYI, 0.0, false)
                ianAct.SetAngle(0.0, 0.0, angZ)
                ianAct.EvaluatePackage(False)
            endif
        endif
        RefreshIanCompanionGear(ianAct)
    endif

    Actor tychoAct = GetTychoActor()
    if TychoState >= 1 && tychoAct != None && !tychoAct.IsDead()
        if tychoAct.IsDisabled()
            tychoAct.EnableNoWait()
        endif
        if TychoState == 1
            ConfigureDogmeatCombatAI(tychoAct, 2.0)
            if !tychoAct.IsPlayerTeammate()
                tychoAct.SetPlayerTeammate(True, True, True)
                tychoAct.SetCanDoCommand(True)
            endif
            bool bTychoTp = False
            if tychoAct.GetWorldSpace() != player.GetWorldSpace()
                bTychoTp = True
            elseif tychoAct.IsInInterior() != player.IsInInterior()
                bTychoTp = True
            elseif tychoAct.GetDistance(player) > 2200.0 && !tychoAct.IsInCombat()
                bTychoTp = True
            endif
            if bTychoTp
                tychoAct.StopCombat()
                float offXT = -195.0 * Math.Sin(angZ)
                float offYT = -195.0 * Math.Cos(angZ)
                tychoAct.MoveTo(player, offXT, offYT, 0.0, false)
                tychoAct.SetAngle(0.0, 0.0, angZ)
                tychoAct.EvaluatePackage(False)
            endif
        endif
        RefreshTychoCompanionGear(tychoAct)
    endif

    StartTimer(4.0, 96)
EndFunction

Actor Function PickBestHostileFromArray(ObjectReference[] akRefs, Actor akPlayer, Actor akDog, float afBestDist, Actor akBestEnemy)
    if akRefs == None
        return akBestEnemy
    endif
    int idx = 0
    int count = akRefs.Length
    while idx < count
        Actor cand = akRefs[idx] as Actor
        if cand != None && cand != akPlayer && cand != akDog && !cand.IsDead() && !cand.IsDisabled() && cand.Is3DLoaded()
            if cand.IsHostileToActor(akPlayer) || cand.GetCombatTarget() == akPlayer || cand.GetCombatTarget() == akDog || cand.GetFactionReaction(akPlayer) == 1
                float d = akPlayer.GetDistance(cand)
                if d < afBestDist
                    afBestDist = d
                    akBestEnemy = cand
                endif
            endif
        endif
        idx += 1
    endwhile
    return akBestEnemy
EndFunction

Actor Function FindDogmeatCombatTarget(Actor akPlayer, Actor akDog)
    if akPlayer == None || akDog == None
        return None
    endif
    if rDogCombatTarget != None
        if !rDogCombatTarget.IsDead() && !rDogCombatTarget.IsDisabled() && rDogCombatTarget.Is3DLoaded() && rDogCombatTarget != akPlayer && rDogCombatTarget != akDog
            if rDogCombatTarget.GetWorldSpace() == akPlayer.GetWorldSpace() && rDogCombatTarget.GetDistance(akPlayer) <= 1800.0
                return rDogCombatTarget
            endif
        endif
        rDogCombatTarget = None
    endif

    Actor dogTarget = akDog.GetCombatTarget()
    if dogTarget != None && dogTarget != akPlayer && dogTarget != akDog && !dogTarget.IsDead() && !dogTarget.IsDisabled()
        if dogTarget.GetDistance(akPlayer) <= 1800.0
            return dogTarget
        endif
    endif

    Actor bestEnemy = None
    float bestDist = 1550.0

    Actor[] playerTargets = akPlayer.GetAllCombatTargets()
    if playerTargets != None
        int ti = 0
        int tlen = playerTargets.Length
        while ti < tlen
            Actor pt = playerTargets[ti]
            if pt != None && pt != akPlayer && pt != akDog && !pt.IsDead() && !pt.IsDisabled() && pt.Is3DLoaded()
                float dp = akPlayer.GetDistance(pt)
                if dp < bestDist
                    bestDist = dp
                    bestEnemy = pt
                endif
            endif
            ti += 1
        endwhile
    endif
    if bestEnemy != None
        return bestEnemy
    endif

    if !akPlayer.IsInCombat() && !akDog.IsInCombat()
        return None
    endif

    Keyword kwCreature = Game.GetFormFromFile(0x00013795, "Fallout4.esm") as Keyword
    if kwCreature != None
        ObjectReference[] creatures = akPlayer.FindAllReferencesWithKeyword(kwCreature, 1450.0)
        bestEnemy = PickBestHostileFromArray(creatures, akPlayer, akDog, bestDist, bestEnemy)
        if bestEnemy != None
            bestDist = akPlayer.GetDistance(bestEnemy)
        endif
    endif

    Keyword kwNPC = Game.GetFormFromFile(0x00013794, "Fallout4.esm") as Keyword
    if kwNPC != None
        ObjectReference[] npcs = akPlayer.FindAllReferencesWithKeyword(kwNPC, 1450.0)
        bestEnemy = PickBestHostileFromArray(npcs, akPlayer, akDog, bestDist, bestEnemy)
        if bestEnemy != None
            bestDist = akPlayer.GetDistance(bestEnemy)
        endif
    endif

    Keyword kwRobot = Game.GetFormFromFile(0x0002CB73, "Fallout4.esm") as Keyword
    if kwRobot != None
        ObjectReference[] robots = akPlayer.FindAllReferencesWithKeyword(kwRobot, 1450.0)
        bestEnemy = PickBestHostileFromArray(robots, akPlayer, akDog, bestDist, bestEnemy)
    endif

    return bestEnemy
EndFunction

Function GrantDogmeatScavengeFind(Actor akDog)
    Actor player = Game.GetPlayer()
    if player == None
        return
    endif
    iDogmeatScavengeIdx += 1
    if iDogmeatScavengeIdx > 4
        iDogmeatScavengeIdx = 1
    endif
    if iDogmeatScavengeIdx == 1
        Form stim = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
        if stim != None
            player.AddItem(stim, 2, False)
        endif
        Debug.Notification("Albóndiga ha rastreado la zona y te ha traído 2 Estimulantes.")
    elseif iDogmeatScavengeIdx == 2
        Form ammo10 = Game.GetFormFromFile(0x0001F276, "Fallout4.esm")
        if ammo10 != None
            player.AddItem(ammo10, 24, False)
        endif
        Debug.Notification("Albóndiga ha desenterrado 24 proyectiles de 10 mm.")
    elseif iDogmeatScavengeIdx == 3
        Form ammo308 = Game.GetFormFromFile(0x0001F66B, "Fallout4.esm")
        if ammo308 != None
            player.AddItem(ammo308, 16, False)
        endif
        Debug.Notification("Albóndiga ha encontrado 16 cartuchos del calibre .308.")
    else
        Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
        if caps != None
            player.AddItem(caps, 65, False)
        endif
        Debug.Notification("Albóndiga ha encontrado una bolsa con 65 chapas.")
    endif
EndFunction

Function GrantIanSupplyFind()
    Actor player = Game.GetPlayer()
    if player == None
        return
    endif
    iIanSupplyIdx += 1
    if iIanSupplyIdx > 3
        iIanSupplyIdx = 1
    endif
    if iIanSupplyIdx == 1
        Form ammo10 = Game.GetFormFromFile(0x0001F276, "Fallout4.esm")
        if ammo10 != None
            player.AddItem(ammo10, 36, False)
        endif
        Debug.Notification("Ian ha compartido contigo 36 proyectiles del calibre 10 mm de su reserva de escolta.")
    elseif iIanSupplyIdx == 2
        Form stim = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
        if stim != None
            player.AddItem(stim, 2, False)
        endif
        Debug.Notification("Ian te ha entregado 2 Estimulantes del botiquín de las caravanas.")
    else
        Form ammo38 = Game.GetFormFromFile(0x0004CE87, "Fallout4.esm")
        if ammo38 != None
            player.AddItem(ammo38, 28, False)
        endif
        Debug.Notification("Ian te ha pasado 28 cartuchos del calibre .38 recuperados en el desierto.")
    endif
EndFunction

Function GrantTychoSupplyFind()
    Actor player = Game.GetPlayer()
    if player == None
        return
    endif
    iTychoSupplyIdx += 1
    if iTychoSupplyIdx > 3
        iTychoSupplyIdx = 1
    endif
    if iTychoSupplyIdx == 1
        Form shells = Game.GetFormFromFile(0x0001F673, "Fallout4.esm")
        if shells != None
            player.AddItem(shells, 20, False)
        endif
        Debug.Notification("El Ranger Tycho te ha entregado 20 cartuchos de escopeta de los Rangers del Desierto.")
    elseif iTychoSupplyIdx == 2
        Form ammo308 = Game.GetFormFromFile(0x0001F66B, "Fallout4.esm")
        if ammo308 != None
            player.AddItem(ammo308, 18, False)
        endif
        Debug.Notification("El Ranger Tycho ha compartido contigo 18 proyectiles del calibre .308.")
    else
        Form radaway = Game.GetFormFromFile(0x00023742, "Fallout4.esm")
        Form water = Game.GetFormFromFile(0x000366C0, "Fallout4.esm")
        if radaway != None
            player.AddItem(radaway, 2, False)
        endif
        if water != None
            player.AddItem(water, 2, False)
        endif
        Debug.Notification("El Ranger Tycho te ha dado 2 RadAway y 2 de Agua Purificada de su cantimplora.")
    endif
EndFunction

Function StepDogmeatInExterior(Actor akDog, ObjectReference akTarget, float afStopDist, float afSpeed)
    if bSteppingCompanion || akDog == None || akTarget == None || akDog.IsDead() || akDog.IsInInterior()
        return
    endif
    WorldSpace v13Wrld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if v13Wrld == None || akDog.GetWorldSpace() != v13Wrld
        return
    endif
    if akDog.GetDistance(akTarget) > afStopDist && !akDog.IsDead()
        bSteppingCompanion = True
        akDog.PathToReference(akTarget, 1.0)
        bSteppingCompanion = False
    endif
EndFunction

Function UpdateHumanCompanionTick(Actor akComp, Actor akPlayer, int aiWho)
    if akComp == None || akPlayer == None || akComp.IsDead()
        return
    endif
    int cState = 0
    if aiWho == 1
        cState = IanState
    else
        cState = TychoState
    endif
    if cState == 0
        if akComp.Is3DLoaded()
            akComp.AllowPCDialogue(True)
            akComp.BlockActivation(False, False)
        endif
        return
    endif
    if akComp.IsDisabled()
        akComp.EnableNoWait()
    endif
    ActorValue followerStateAV = Game.GetFormFromFile(0x00000344, "Fallout4.esm") as ActorValue
    if followerStateAV != None
        float fsVal = akComp.GetValue(followerStateAV)
        if fsVal == 2.0 && cState == 1
            cState = 2
            if aiWho == 1
                IanState = 2
            else
                TychoState = 2
            endif
            ConfigureDogmeatCombatAI(akComp, 4.0)
            akComp.EvaluatePackage(True)
        elseif fsVal == 1.0 && cState == 2
            cState = 1
            if aiWho == 1
                IanState = 1
            else
                TychoState = 1
            endif
            ConfigureDogmeatCombatAI(akComp, 2.0)
            akComp.EvaluatePackage(True)
        endif
    endif
    if !akComp.Is3DLoaded()
        if cState == 1
            SyncDogmeatWithPlayer()
        endif
        return
    endif
    if !akComp.IsDoingFavor()
        akComp.AllowPCDialogue(False)
    endif
    if cState == 2
        return
    endif
    if rDogCombatTarget != None && !rDogCombatTarget.IsDead() && !akComp.IsDead()
        if akComp.GetCombatTarget() != rDogCombatTarget
            akComp.StartCombat(rDogCombatTarget)
        endif
        return
    endif
    float dPlayer = akComp.GetDistance(akPlayer)
    if akComp.GetWorldSpace() != akPlayer.GetWorldSpace() || akComp.IsInInterior() != akPlayer.IsInInterior() || (dPlayer > 2200.0 && !akComp.IsInCombat())
        float angZ = akPlayer.GetAngleZ()
        float offX = 0.0
        float offY = 0.0
        if aiWho == 1
            offX = -145.0 * Math.Sin(angZ) - 75.0 * Math.Cos(angZ)
            offY = -145.0 * Math.Cos(angZ) + 75.0 * Math.Sin(angZ)
        else
            offX = -195.0 * Math.Sin(angZ)
            offY = -195.0 * Math.Cos(angZ)
        endif
        akComp.StopCombat()
        akComp.MoveTo(akPlayer, offX, offY, 0.0, false)
        akComp.SetAngle(0.0, 0.0, angZ)
        akComp.EvaluatePackage(False)
    elseif !akComp.IsInCombat() && dPlayer > 270.0
        StepDogmeatInExterior(akComp, akPlayer as ObjectReference, 200.0, 280.0)
    endif
EndFunction

Function CheckDogmeatProximity()
    Actor player = Game.GetPlayer()
    if player == None
        StartTimer(1.0, 98)
        return
    endif
    WorldSpace v13Wrld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    Actor dogJunktown = Game.GetFormFromFile(0x000035C3, "Vault13Chronicles.esp") as Actor
    Actor dogShady = Game.GetFormFromFile(0x000035B3, "Vault13Chronicles.esp") as Actor
    Actor ianAct = GetIanActor()
    Actor tychoAct = GetTychoActor()

    if dogJunktown != None && !dogJunktown.IsDisabled()
        dogJunktown.DisableNoWait()
    endif

    if !IsPlayerInVault13Space()
        SuspendCompanionsForCommonwealth()
        return
    endif

    if bCompanionsSuspendedInCommonwealth || iSavedDogmeatState > 0 || iSavedIanState > 0 || iSavedTychoState > 0
        RestoreCompanionsOnReturnTo2161()
    endif

    UpdateHumanCompanionTick(ianAct, player, 1)
    UpdateHumanCompanionTick(tychoAct, player, 2)

    Form redBandana = Game.GetFormFromFile(0x0009C05B, "Fallout4.esm")
    Form medArmor = Game.GetFormFromFile(0x001C32C8, "Fallout4.esm")
    Form reinfCollar = Game.GetFormFromFile(0x001C67B2, "Fallout4.esm")

    if DogmeatState == 0
        if dogShady != None && !dogShady.IsDead()
            if dogShady.IsDisabled()
                dogShady.EnableNoWait()
            endif
            if dogShady.Is3DLoaded()
                if !dogShady.IsInCombat() && (Math.Abs(dogShady.GetPositionX() - 2600.0) > 220.0 || Math.Abs(dogShady.GetPositionY() - 9600.0) > 220.0)
                    dogShady.SetPosition(2600.0, 9600.0, 160.0)
                endif
                if (redBandana != None && dogShady.IsEquipped(redBandana)) || (medArmor != None && !dogShady.IsEquipped(medArmor)) || (reinfCollar != None && !dogShady.IsEquipped(reinfCollar))
                    RefreshDogmeatAppearance(dogShady)
                endif
                dogShady.AllowPCDialogue(True)
                dogShady.BlockActivation(False, False)
            endif
        endif
        StartTimer(1.2, 98)
        return
    endif

    Actor activeDog = GetActiveDogmeatActor()

    if activeDog == None || activeDog.IsDead()
        StartTimer(1.0, 98)
        return
    endif
    if activeDog.IsDisabled()
        activeDog.EnableNoWait()
    endif
    activeDog.EnableAI(True)

    ActorValue followerStateAV = Game.GetFormFromFile(0x00000344, "Fallout4.esm") as ActorValue
    if followerStateAV != None
        float fsVal = activeDog.GetValue(followerStateAV)
        if fsVal == 2.0 && DogmeatState == 1
            DogmeatState = 2
            ConfigureDogmeatCombatAI(activeDog, 4.0)
            activeDog.EvaluatePackage(True)
        elseif fsVal == 1.0 && DogmeatState == 2
            DogmeatState = 1
            ConfigureDogmeatCombatAI(activeDog, 2.0)
            activeDog.EvaluatePackage(True)
        endif
    endif

    if !activeDog.Is3DLoaded()
        if DogmeatState == 1
            SyncDogmeatWithPlayer()
        endif
        StartTimer(1.2, 98)
        return
    endif

    if (redBandana != None && activeDog.IsEquipped(redBandana)) || (medArmor != None && !activeDog.IsEquipped(medArmor)) || (reinfCollar != None && !activeDog.IsEquipped(reinfCollar))
        RefreshDogmeatAppearance(activeDog)
    endif

    if DogmeatState == 2
        StartTimer(1.2, 98)
        return
    endif

    Actor enemy = FindDogmeatCombatTarget(player, activeDog)
    if enemy != None
        if rDogCombatTarget != enemy
            PlayDogmeatVocal(activeDog, 3)
        endif
        rDogCombatTarget = enemy
        iDogMoveTicks = 0
        rDogMoveTarget = None
        if !activeDog.IsDead() && !enemy.IsDead() && activeDog.GetCombatTarget() != enemy
            activeDog.StartCombat(enemy)
        endif
        float dEnemy = activeDog.GetDistance(enemy)
        if dEnemy > 140.0
            StepDogmeatInExterior(activeDog, enemy as ObjectReference, 125.0, 320.0)
        else
            iDogBiteCooldown += 1
            if iDogBiteCooldown >= 2
                iDogBiteCooldown = 0
                PlayDogmeatVocal(activeDog, 4)
                ActorValue healthAV = Game.GetFormFromFile(0x000002D4, "Fallout4.esm") as ActorValue
                if healthAV != None && !enemy.IsDead()
                    enemy.DamageValue(healthAV, 28.0)
                    if enemy.GetValue(healthAV) <= 1.0 && !enemy.IsDead()
                        enemy.Kill(activeDog)
                    endif
                endif
            endif
        endif
        StartTimer(0.65, 98)
        return
    endif

    if iDogMoveTicks > 0 && rDogMoveTarget != None
        iDogMoveTicks -= 1
        if activeDog.GetDistance(rDogMoveTarget) <= 140.0
            iDogMoveTicks = 0
            rDogMoveTarget = None
        else
            StepDogmeatInExterior(activeDog, rDogMoveTarget, 120.0, 290.0)
        endif
        StartTimer(0.65, 98)
        return
    endif

    float dPlayer = activeDog.GetDistance(player)
    if activeDog.GetWorldSpace() != player.GetWorldSpace() || activeDog.IsInInterior() != player.IsInInterior() || dPlayer > 1150.0
        float angZ = player.GetAngleZ()
        float offX = -125.0 * Math.Sin(angZ) + 55.0 * Math.Cos(angZ)
        float offY = -125.0 * Math.Cos(angZ) - 55.0 * Math.Sin(angZ)
        activeDog.MoveTo(player, offX, offY, 0.0, false)
        activeDog.SetAngle(0.0, 0.0, angZ)
        activeDog.EvaluatePackage(False)
    elseif dPlayer > 175.0
        float followSpd = 260.0
        if dPlayer > 480.0
            followSpd = 320.0
        endif
        if Utility.RandomInt(1, 20) == 1
            PlayDogmeatVocal(activeDog, 2)
        endif
        StepDogmeatInExterior(activeDog, player as ObjectReference, 145.0, followSpd)
    endif

    StartTimer(1.25, 98)
EndFunction

Function HandleDogmeatActivation(Actor akDog)
    if akDog == None || bDogmeatMenuBusy
        return
    endif
    if !IsPlayerInVault13Space()
        DismissDogmeatToShadySands(True)
        return
    endif
    bDogmeatMenuBusy = True
    RefreshDogmeatAppearance(akDog)
    PlayDogmeatVocal(akDog, 1)
    if DogmeatState == 0
        Message recruitMsg = Game.GetFormFromFile(0x000011C0, "Vault13Chronicles.esp") as Message
        int rChoice = 0
        if recruitMsg != None
            rChoice = recruitMsg.Show()
        endif
        if rChoice == 0 || rChoice == 1 || rChoice == 2
            EnsurePlayerHasDogmeatItems()
            SetDogmeatFollowMode(akDog)
            SyncDogmeatWithPlayer()
            PlayDogmeatVocal(akDog, 1)
            if !bDogmeatFirstRecruitXP
                bDogmeatFirstRecruitXP = True
                Game.RewardPlayerXP(150)
            endif
            Debug.Notification("¡Albóndiga (2161) se ha unido a ti! Pulsa [E]/[A] sobre él cuando quieras para darle órdenes o despedirlo.")
        endif
    else
        Message cmdMsg = Game.GetFormFromFile(0x000011C1, "Vault13Chronicles.esp") as Message
        int cChoice = 0
        if cmdMsg != None
            cChoice = cmdMsg.Show()
        endif
        if cChoice == 0
            SetDogmeatFollowMode(akDog)
            PlayDogmeatVocal(akDog, 1)
            Debug.Notification("Albóndiga (2161): Siguiéndote de cerca.")
        elseif cChoice == 1
            PlayDogmeatVocal(akDog, 2)
            akDog.AllowPCDialogue(True)
            akDog.SetPlayerTeammate(True, True, True)
            akDog.SetCanDoCommand(True)
            if !akDog.IsDoingFavor()
                akDog.SetCommandState(True)
            endif
        elseif cChoice == 2
            PlayDogmeatVocal(akDog, 2)
            GrantDogmeatScavengeFind(akDog)
        elseif cChoice == 3
            PlayDogmeatVocal(akDog, 2)
            akDog.OpenInventory(True)
        elseif cChoice == 4
            DogmeatState = 2
            rDogMoveTarget = None
            rDogCombatTarget = None
            iDogMoveTicks = 0
            ConfigureDogmeatCombatAI(akDog, 4.0)
            akDog.FollowerWait()
            akDog.EvaluatePackage(True)
            PlayDogmeatVocal(akDog, 5)
            Debug.Notification("Albóndiga (2161): Esperando en esta posición.")
        elseif cChoice == 5
            DismissDogmeatToShadySands(True)
        elseif cChoice == 6
            akDog.ResetHealthAndLimbs()
            PlayDogmeatVocal(akDog, 1)
        endif
    endif
    bDogmeatMenuBusy = False
EndFunction

Function HandleIanActivation(Actor akIan)
    if akIan == None || bDogmeatMenuBusy
        return
    endif
    if !IsPlayerInVault13Space()
        DismissIanToShadySands(True)
        return
    endif
    bDogmeatMenuBusy = True
    RefreshIanCompanionGear(akIan)
    Actor player = Game.GetPlayer()
    if IanState == 0
        Message recruitMsg = Game.GetFormFromFile(0x000011C2, "Vault13Chronicles.esp") as Message
        int rChoice = 3
        if recruitMsg != None
            rChoice = recruitMsg.Show()
        endif
        if rChoice == 0
            Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
            if player != None && caps != None && player.GetItemCount(caps) >= 100
                player.RemoveItem(caps, 100, False)
            endif
            SetIanFollowMode(akIan)
            SyncDogmeatWithPlayer()
            if !bIanFirstRecruitXP
                bIanFirstRecruitXP = True
                Game.RewardPlayerXP(175)
            endif
            Debug.Notification("¡Ian se ha unido a tu grupo! Puedes viajar con Ian, Tycho y Albóndiga simultáneamente.")
        elseif rChoice == 1
            SetIanFollowMode(akIan)
            SyncDogmeatWithPlayer()
            if !bIanFirstRecruitXP
                bIanFirstRecruitXP = True
                Game.RewardPlayerXP(175)
            endif
            Debug.Notification("¡Has convencido a Ian para unirse sin coste! Su pistola 10 mm cubrirá tu flanco.")
        elseif rChoice == 2
            Topic shadyHello = Game.GetFormFromFile(0x00009501, "Vault13Chronicles.esp") as Topic
            if shadyHello != None && !akIan.IsTalking()
                akIan.Say(shadyHello, None, false, None)
            endif
            Debug.Notification("Ian: «Fui escolta de las caravanas del Eje hasta que los Khans me hirieron. Junktown queda al sur y el Eje más allá.»")
        endif
    else
        Message cmdMsg = Game.GetFormFromFile(0x000011C3, "Vault13Chronicles.esp") as Message
        int cChoice = 6
        if cmdMsg != None
            cChoice = cmdMsg.Show()
        endif
        if cChoice == 0
            SetIanFollowMode(akIan)
            Debug.Notification("Ian (Shady Sands): Cubriendo tu flanco de cerca.")
        elseif cChoice == 1
            akIan.AllowPCDialogue(True)
            akIan.SetPlayerTeammate(True, True, True)
            akIan.SetCanDoCommand(True)
            if !akIan.IsDoingFavor()
                akIan.SetCommandState(True)
            endif
        elseif cChoice == 2
            GrantIanSupplyFind()
        elseif cChoice == 3
            akIan.OpenInventory(True)
        elseif cChoice == 4
            IanState = 2
            ConfigureDogmeatCombatAI(akIan, 4.0)
            akIan.FollowerWait()
            akIan.EvaluatePackage(True)
            Debug.Notification("Ian (Shady Sands): Manteniendo posición aquí.")
        elseif cChoice == 5
            DismissIanToShadySands(True)
        elseif cChoice == 6
            akIan.ResetHealthAndLimbs()
        endif
    endif
    bDogmeatMenuBusy = False
EndFunction

Function HandleTychoActivation(Actor akTycho)
    if akTycho == None || bDogmeatMenuBusy
        return
    endif
    if !IsPlayerInVault13Space()
        DismissTychoToJunktown(True)
        return
    endif
    bDogmeatMenuBusy = True
    RefreshTychoCompanionGear(akTycho)
    if TychoState == 0
        Message recruitMsg = Game.GetFormFromFile(0x000011C4, "Vault13Chronicles.esp") as Message
        int rChoice = 3
        if recruitMsg != None
            rChoice = recruitMsg.Show()
        endif
        if rChoice == 0 || rChoice == 1
            SetTychoFollowMode(akTycho)
            SyncDogmeatWithPlayer()
            if !bTychoFirstRecruitXP
                bTychoFirstRecruitXP = True
                Game.RewardPlayerXP(200)
            endif
            Debug.Notification("¡El Ranger Tycho se ha unido a tu grupo! Puedes viajar con Tycho, Ian y Albóndiga simultáneamente.")
        elseif rChoice == 2
            int curStage = Self.GetStage()
            SilenceJunktownActorsExcept(akTycho, 3)
            Topic junkHello = Game.GetFormFromFile(0x00010001, "Vault13Chronicles.esp") as Topic
            if junkHello != None && !akTycho.IsTalking()
                akTycho.Say(junkHello, None, false, None)
            endif
            if curStage < 25
                EnsureJunktownStage20Active()
            endif
            CancelTimer(91)
            CancelTimer(92)
            sceneWaitTicks = 0
            StartTimer(0.6, 93)
            if curStage < 25
                StartTimer(2.0, 94)
            endif
        endif
    else
        Message cmdMsg = Game.GetFormFromFile(0x000011C5, "Vault13Chronicles.esp") as Message
        int cChoice = 6
        if cmdMsg != None
            cChoice = cmdMsg.Show()
        endif
        if cChoice == 0
            SetTychoFollowMode(akTycho)
            Debug.Notification("Ranger Tycho: En formación de escolta.")
        elseif cChoice == 1
            akTycho.AllowPCDialogue(True)
            akTycho.SetPlayerTeammate(True, True, True)
            akTycho.SetCanDoCommand(True)
            if !akTycho.IsDoingFavor()
                akTycho.SetCommandState(True)
            endif
        elseif cChoice == 2
            GrantTychoSupplyFind()
        elseif cChoice == 3
            akTycho.OpenInventory(True)
        elseif cChoice == 4
            TychoState = 2
            ConfigureDogmeatCombatAI(akTycho, 4.0)
            akTycho.FollowerWait()
            akTycho.EvaluatePackage(True)
            Debug.Notification("Ranger Tycho: Vigilando esta posición.")
        elseif cChoice == 5
            DismissTychoToJunktown(True)
        elseif cChoice == 6
            akTycho.ResetHealthAndLimbs()
        endif
    endif
    bDogmeatMenuBusy = False
EndFunction

Event Actor.OnCommandModeGiveCommand(Actor akSender, int aeCommandType, ObjectReference akTarget)
    Actor activeDog = GetActiveDogmeatActor()
    Actor ianAct = GetIanActor()
    Actor tychoAct = GetTychoActor()
    if akSender != activeDog && akSender != ianAct && akSender != tychoAct
        return
    endif
    if aeCommandType == 1 || aeCommandType == 2
        if akSender == activeDog
            DogmeatState = 1
            rDogMoveTarget = None
            iDogMoveTicks = 0
            PlayDogmeatVocal(activeDog, 1)
            Debug.Notification("Albóndiga (2161): Siguiéndote de cerca.")
        elseif akSender == ianAct
            IanState = 1
            Debug.Notification("Ian: Siguiéndote de cerca.")
        elseif akSender == tychoAct
            TychoState = 1
            Debug.Notification("Ranger Tycho: Siguiéndote de cerca.")
        endif
        ConfigureDogmeatCombatAI(akSender, 2.0)
        akSender.FollowerFollow()
        akSender.FollowerSetDistanceNear()
        akSender.EvaluatePackage(True)
    elseif aeCommandType == 7
        if akSender == activeDog
            DogmeatState = 2
            rDogMoveTarget = None
            rDogCombatTarget = None
            iDogMoveTicks = 0
            PlayDogmeatVocal(activeDog, 5)
            Debug.Notification("Albóndiga (2161): Esperando en esta posición.")
        elseif akSender == ianAct
            IanState = 2
            Debug.Notification("Ian: Esperando en esta posición.")
        elseif akSender == tychoAct
            TychoState = 2
            Debug.Notification("Ranger Tycho: Esperando en esta posición.")
        endif
        ConfigureDogmeatCombatAI(akSender, 4.0)
        akSender.FollowerWait()
        akSender.EvaluatePackage(True)
    elseif aeCommandType == 4
        Actor targetEnemy = akTarget as Actor
        if targetEnemy != None && !targetEnemy.IsDead() && akSender != None && !akSender.IsDead()
            if akSender == activeDog
                DogmeatState = 1
                rDogCombatTarget = targetEnemy
                rDogMoveTarget = None
                iDogMoveTicks = 0
                PlayDogmeatVocal(activeDog, 3)
            elseif akSender == ianAct
                IanState = 1
            elseif akSender == tychoAct
                TychoState = 1
            endif
            ConfigureDogmeatCombatAI(akSender, 2.0)
            if !akSender.IsDead() && !targetEnemy.IsDead()
                akSender.StartCombat(targetEnemy)
            endif
        endif
    elseif aeCommandType == 3 || aeCommandType == 5 || aeCommandType == 6
        if akTarget != None && akSender != None && !akSender.IsDead()
            akSender.PathToReference(akTarget, 1.0)
            if akSender == activeDog
                rDogMoveTarget = akTarget
                iDogMoveTicks = 8
                PlayDogmeatVocal(activeDog, 2)
                if aeCommandType == 5 || aeCommandType == 6
                    GrantDogmeatScavengeFind(akSender)
                endif
            elseif akSender == ianAct && (aeCommandType == 5 || aeCommandType == 6)
                GrantIanSupplyFind()
            elseif akSender == tychoAct && (aeCommandType == 5 || aeCommandType == 6)
                GrantTychoSupplyFind()
            endif
        endif
    elseif aeCommandType == 9
        akSender.ResetHealthAndLimbs()
        if akSender == activeDog
            PlayDogmeatVocal(activeDog, 1)
        endif
    endif
EndEvent

Event Actor.OnCompanionDismiss(Actor akSender)
    Actor activeDog = GetActiveDogmeatActor()
    Actor ianAct = GetIanActor()
    Actor tychoAct = GetTychoActor()
    if akSender == activeDog
        DismissDogmeatToShadySands(True)
    elseif akSender == ianAct
        DismissIanToShadySands(True)
    elseif akSender == tychoAct
        DismissTychoToJunktown(True)
    endif
EndEvent

Event Actor.OnCombatStateChanged(Actor akSender, Actor akTarget, int aeCombatState)
    if akSender == Game.GetPlayer() && (DogmeatState == 1 || IanState == 1 || TychoState == 1)
        if aeCombatState >= 1 && akTarget != None && !akTarget.IsDead()
            rDogCombatTarget = akTarget
        elseif aeCombatState == 0
            rDogCombatTarget = None
        endif
    endif
EndEvent

Event OnHit(ObjectReference akTarget, ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked, string asMaterialName)
    Actor player = Game.GetPlayer()
    if akTarget == player && (DogmeatState == 1 || IanState == 1 || TychoState == 1)
        Actor attacker = akAggressor as Actor
        Actor activeDog = GetActiveDogmeatActor()
        Actor ianAct = GetIanActor()
        Actor tychoAct = GetTychoActor()
        if attacker != None && attacker != player && attacker != activeDog && attacker != ianAct && attacker != tychoAct && !attacker.IsDead()
            rDogCombatTarget = attacker
        endif
    endif
    if player != None
        RegisterForHitEvent(player)
    endif
EndEvent

Function RefreshJunktownSettlementLayout()
    Actor killianAct = Game.GetFormFromFile(0x000035C0, "Vault13Chronicles.esp") as Actor
    if killianAct != None && !killianAct.IsDead()
        if killianAct.IsDisabled()
            killianAct.EnableNoWait()
        endif
        if killianAct.Is3DLoaded()
            killianAct.AllowPCDialogue(True)
            killianAct.BlockActivation(False, False)
            if !killianAct.IsInCombat() && !killianAct.IsTalking()
                if Math.Abs(killianAct.GetPositionX() - 3850.0) > 45.0 || Math.Abs(killianAct.GetPositionY() - 3820.0) > 45.0
                    killianAct.SetPosition(3850.0, 3820.0, 80.0)
                    killianAct.SetAngle(0.0, 0.0, 225.0)
                    killianAct.EvaluatePackage()
                elseif Math.Abs(killianAct.GetAngleZ() - 225.0) > 35.0 && Math.Abs(killianAct.GetAngleZ() - 225.0) < 325.0
                    killianAct.SetAngle(0.0, 0.0, 225.0)
                endif
            endif
            EquipCustomGear(killianAct, 0x00001020, 0x000D415A, 0, 0x00001313)
        endif
    endif

    Actor larsAct = Game.GetFormFromFile(0x000035C1, "Vault13Chronicles.esp") as Actor
    if larsAct != None && !larsAct.IsDead()
        if larsAct.IsDisabled()
            larsAct.EnableNoWait()
        endif
        if larsAct.Is3DLoaded()
            larsAct.AllowPCDialogue(True)
            larsAct.BlockActivation(False, False)
            if !larsAct.IsInCombat() && !larsAct.IsTalking()
                if Math.Abs(larsAct.GetPositionX() - 3310.0) > 45.0 || Math.Abs(larsAct.GetPositionY() - 3820.0) > 45.0
                    larsAct.SetPosition(3310.0, 3820.0, 80.0)
                    larsAct.SetAngle(0.0, 0.0, 90.0)
                    larsAct.EvaluatePackage()
                elseif Math.Abs(larsAct.GetAngleZ() - 90.0) > 35.0 && Math.Abs(larsAct.GetAngleZ() - 90.0) < 325.0
                    larsAct.SetAngle(0.0, 0.0, 90.0)
                endif
            endif
            EquipCustomGear(larsAct, 0x00001021, 0x0016892C, 0x00156C0D, 0x00001314)
        endif
    endif

    Actor tychoAct = Game.GetFormFromFile(0x000035C2, "Vault13Chronicles.esp") as Actor
    if tychoAct != None && !tychoAct.IsDead()
        if tychoAct.Is3DLoaded()
            tychoAct.AllowPCDialogue(True)
            tychoAct.BlockActivation(False, False)
        endif
        if IsPlayerInVault13Space()
            RefreshTychoCompanionGear(tychoAct)
            if TychoState == 0 && iSavedTychoState == 0 && tychoAct.Is3DLoaded() && !tychoAct.IsInCombat()
                if Math.Abs(tychoAct.GetPositionX() - 3600.0) > 600.0 || Math.Abs(tychoAct.GetPositionY() - 4280.0) > 600.0
                    tychoAct.SetPosition(3600.0, 4280.0, 80.0)
                    tychoAct.SetAngle(0.0, 0.0, 180.0)
                endif
            endif
        else
            SuspendCompanionsForCommonwealth()
        endif
    endif

    Actor dogAct = Game.GetFormFromFile(0x000035C3, "Vault13Chronicles.esp") as Actor
    if dogAct != None && !dogAct.IsDisabled()
        dogAct.DisableNoWait()
    endif

    Actor dogShady = Game.GetFormFromFile(0x000035B3, "Vault13Chronicles.esp") as Actor
    if dogShady != None && !dogShady.IsDead()
        if dogShady.IsDisabled()
            dogShady.EnableNoWait()
        endif
        if IsPlayerInVault13Space()
            RefreshDogmeatAppearance(dogShady)
            if DogmeatState == 0 && iSavedDogmeatState == 0 && dogShady.Is3DLoaded() && !dogShady.IsInCombat()
                if Math.Abs(dogShady.GetPositionX() - 2600.0) > 220.0 || Math.Abs(dogShady.GetPositionY() - 9600.0) > 220.0
                    dogShady.SetPosition(2600.0, 9600.0, 160.0)
                endif
            endif
        else
            SuspendCompanionsForCommonwealth()
        endif
    endif

    Form noteBase = Game.GetFormFromFile(0x0000114A, "Vault13Chronicles.esp")
    if noteBase != None
        ObjectReference noteRef = Game.FindClosestReferenceOfType(noteBase, 3920.0, 4000.0, 80.0, 400.0)
        if noteRef != None && noteRef.GetContainer() == None
            noteRef.SetPosition(3950.0, 3996.0, 136.5)
        endif
    endif
EndFunction

Function SilenceJunktownActorsExcept(Actor akSpeaker, int aiKeepSceneSlot)
    Topic stopTopic = Game.GetFormFromFile(0x00004003, "Vault13Chronicles.esp") as Topic
    Actor killianAct = Game.GetFormFromFile(0x000035C0, "Vault13Chronicles.esp") as Actor
    Actor larsAct = Game.GetFormFromFile(0x000035C1, "Vault13Chronicles.esp") as Actor
    Actor tychoAct = Game.GetFormFromFile(0x000035C2, "Vault13Chronicles.esp") as Actor

    Scene sKillian = Game.GetFormFromFile(0x00010100, "Vault13Chronicles.esp") as Scene
    Scene sLars = Game.GetFormFromFile(0x00010101, "Vault13Chronicles.esp") as Scene
    Scene sTycho = Game.GetFormFromFile(0x00010102, "Vault13Chronicles.esp") as Scene

    if aiKeepSceneSlot != 1 && sKillian != None && sKillian.IsPlaying()
        sKillian.Stop()
    endif
    if aiKeepSceneSlot != 2 && sLars != None && sLars.IsPlaying()
        sLars.Stop()
    endif
    if aiKeepSceneSlot != 3 && sTycho != None && sTycho.IsPlaying()
        sTycho.Stop()
    endif

    if stopTopic != None
        if killianAct != None && killianAct != akSpeaker && killianAct.IsTalking()
            killianAct.Say(stopTopic, None, false, None)
        endif
        if larsAct != None && larsAct != akSpeaker && larsAct.IsTalking()
            larsAct.Say(stopTopic, None, false, None)
        endif
        if tychoAct != None && tychoAct != akSpeaker && tychoAct.IsTalking()
            tychoAct.Say(stopTopic, None, false, None)
        endif
    endif
EndFunction

Function EnsureJunktownStage20Active()
    ObjectReference mapMarker = Game.GetFormFromFile(0x0000341C, "Vault13Chronicles.esp") as ObjectReference
    if mapMarker != None
        mapMarker.EnableNoWait()
        mapMarker.AddToMap(True)
    endif
    Actor player = Game.GetPlayer()
    Form proofBase = Game.GetFormFromFile(0x00001451, "Vault13Chronicles.esp")
    if proofBase != None && player != None && player.GetItemCount(proofBase) > 0
        if Self.GetStage() < 25
            Self.SetStage(25)
        endif
        return
    endif
    Actor kenjiRef = Game.GetFormFromFile(0x000035C4, "Vault13Chronicles.esp") as Actor
    if kenjiRef != None && kenjiRef.IsDead()
        if Self.GetStage() < 22
            Self.SetStage(22)
        endif
        return
    endif
    if Self.GetStage() < 20
        Self.SetStage(20)
    endif
    ForceQuestAlias(1, 0x000035C4)
    if !IsObjectiveDisplayed(20)
        SetObjectiveDisplayed(20, True, False)
    endif
    Self.SetActive(True)
    if !bStg20Notified
        bStg20Notified = True
        Debug.Notification("Misión Secundaria: Justicia en Junktown — Elimina al sicario Kenji en el local de Gizmo al oeste.")
    endif
EndFunction

Function BindJunktownListeners()
    ForceAllJunktownAliases()
    if !IsPlayerInVault13Space()
        SuspendCompanionsForCommonwealth()
        RefreshJunktownSettlementLayout()
    else
        RestoreCompanionsOnReturnTo2161()
        RefreshJunktownSettlementLayout()
        if DogmeatState >= 1
            Actor activeDog = GetActiveDogmeatActor()
            if activeDog != None
                if DogmeatState == 1
                    SetDogmeatFollowMode(activeDog)
                else
                    ConfigureDogmeatCombatAI(activeDog, 4.0)
                    RefreshDogmeatAppearance(activeDog)
                endif
            endif
        endif
        if IanState >= 1
            Actor ianAct = GetIanActor()
            if ianAct != None
                if IanState == 1
                    SetIanFollowMode(ianAct)
                else
                    ConfigureDogmeatCombatAI(ianAct, 4.0)
                    RefreshIanCompanionGear(ianAct)
                endif
            endif
        endif
        if TychoState >= 1
            Actor tychoAct = GetTychoActor()
            if tychoAct != None
                if TychoState == 1
                    SetTychoFollowMode(tychoAct)
                else
                    ConfigureDogmeatCombatAI(tychoAct, 4.0)
                    RefreshTychoCompanionGear(tychoAct)
                endif
            endif
        endif
        if DogmeatState >= 1 || IanState >= 1 || TychoState >= 1
            SyncDogmeatWithPlayer()
        endif
        StartTimer(0.8, 98)
    endif

    Actor player = Game.GetPlayer()
    Form proofBase = Game.GetFormFromFile(0x00001451, "Vault13Chronicles.esp")
    Self.RemoveAllInventoryEventFilters()
    if proofBase != None
        Self.AddInventoryEventFilter(proofBase)
    endif
    if player != None
        RegisterForRemoteEvent(player, "OnPlayerLoadGame")
        RegisterForRemoteEvent(player, "OnLocationChange")
        RegisterForRemoteEvent(player, "OnCombatStateChanged")
        RegisterForHitEvent(player)
        RegisterForPlayerTeleport()
        if proofBase != None
            RegisterForRemoteEvent(player as ObjectReference, "OnItemAdded")
        endif
    endif

    ObjectReference killianRef = Game.GetFormFromFile(0x000035C0, "Vault13Chronicles.esp") as ObjectReference
    if killianRef != None
        RegisterForRemoteEvent(killianRef, "OnActivate")
        EnsureKillianVendorReady(killianRef as Actor)
    endif
    ObjectReference larsRef = Game.GetFormFromFile(0x000035C1, "Vault13Chronicles.esp") as ObjectReference
    if larsRef != None
        RegisterForRemoteEvent(larsRef, "OnActivate")
    endif
    ObjectReference tychoRef = Game.GetFormFromFile(0x000035C2, "Vault13Chronicles.esp") as ObjectReference
    if tychoRef != None
        RegisterForRemoteEvent(tychoRef, "OnActivate")
        RegisterForRemoteEvent(tychoRef as Actor, "OnCommandModeGiveCommand")
        RegisterForRemoteEvent(tychoRef as Actor, "OnCompanionDismiss")
    endif
    ObjectReference ianRef = Game.GetFormFromFile(0x000035A4, "Vault13Chronicles.esp") as ObjectReference
    if ianRef != None
        RegisterForRemoteEvent(ianRef, "OnActivate")
        RegisterForRemoteEvent(ianRef as Actor, "OnCommandModeGiveCommand")
        RegisterForRemoteEvent(ianRef as Actor, "OnCompanionDismiss")
    endif
    ObjectReference dogRef = Game.GetFormFromFile(0x000035C3, "Vault13Chronicles.esp") as ObjectReference
    if dogRef != None
        RegisterForRemoteEvent(dogRef, "OnActivate")
        RegisterForRemoteEvent(dogRef as Actor, "OnCommandModeGiveCommand")
        RegisterForRemoteEvent(dogRef as Actor, "OnCompanionDismiss")
    endif
    ObjectReference dogShadyRef = Game.GetFormFromFile(0x000035B3, "Vault13Chronicles.esp") as ObjectReference
    if dogShadyRef != None
        RegisterForRemoteEvent(dogShadyRef, "OnActivate")
        RegisterForRemoteEvent(dogShadyRef as Actor, "OnCommandModeGiveCommand")
        RegisterForRemoteEvent(dogShadyRef as Actor, "OnCompanionDismiss")
    endif
    Faction playerFact = Game.GetFormFromFile(0x0001C21C, "Fallout4.esm") as Faction
    Actor gizmoRef = Game.GetFormFromFile(0x000035DE, "Vault13Chronicles.esp") as Actor
    if gizmoRef != None && playerFact != None && gizmoRef.IsInFaction(playerFact) && !gizmoRef.IsInCombat()
        gizmoRef.RemoveFromFaction(playerFact)
    endif
    Actor izoRef = Game.GetFormFromFile(0x000035DF, "Vault13Chronicles.esp") as Actor
    if izoRef != None && playerFact != None && izoRef.IsInFaction(playerFact) && !izoRef.IsInCombat()
        izoRef.RemoveFromFaction(playerFact)
    endif
    Actor vinnieRef = Game.GetFormFromFile(0x000035EC, "Vault13Chronicles.esp") as Actor
    if vinnieRef != None && playerFact != None && vinnieRef.IsInFaction(playerFact) && !vinnieRef.IsInCombat()
        vinnieRef.RemoveFromFaction(playerFact)
    endif
    Actor kenjiRef = Game.GetFormFromFile(0x000035C4, "Vault13Chronicles.esp") as Actor
    if kenjiRef != None
        RegisterForRemoteEvent(kenjiRef, "OnDeath")
        RegisterForRemoteEvent(kenjiRef as ObjectReference, "OnActivate")
        if proofBase != None
            AddInventoryEventFilter(proofBase)
        endif
        RegisterForRemoteEvent(kenjiRef as ObjectReference, "OnItemRemoved")
        V13WastelandCreatureAIScript kenjiAI = (kenjiRef as ObjectReference) as V13WastelandCreatureAIScript
        if kenjiAI != None
            kenjiAI.InitCreatureAI()
        endif
        if kenjiRef.IsDead() && Self.GetStage() < 25 && !bProofRecovered && (player == None || player.GetDistance(kenjiRef) > 2200.0)
            kenjiRef.Resurrect()
            Utility.Wait(0.1)
            kenjiRef.StopCombat()
            kenjiRef.SetValue(Game.GetAggressionAV(), 0.0)
            kenjiRef.SetPosition(-2760.0, 5480.0, 86.0)
            ForceQuestAlias(1, 0x000035C4)
        endif
        float kx = kenjiRef.GetPositionX()
        float ky = kenjiRef.GetPositionY()
        float kz = kenjiRef.GetPositionZ()
        if !kenjiRef.IsDead()
            if (kz < 68.0 || kz > 190.0) && Self.GetStage() < 25
                kenjiRef.SetPosition(-2760.0, 5480.0, 86.0)
                ForceQuestAlias(1, 0x000035C4)
            elseif !kenjiRef.IsInCombat()
                if Math.Abs(kx + 2760.0) > 450.0 || Math.Abs(ky - 5480.0) > 450.0
                    kenjiRef.StopCombat()
                    kenjiRef.SetPosition(-2760.0, 5480.0, 86.0)
                    ForceQuestAlias(1, 0x000035C4)
                endif
            endif
        endif
        if bProofRecovered || bItemDelivered || Self.GetStage() >= 25 || (player != None && proofBase != None && player.GetItemCount(proofBase) > 0)
            bProofRecovered = True
            bProofSeeded = True
            if proofBase != None && kenjiRef.GetItemCount(proofBase) > 0
                kenjiRef.RemoveItem(proofBase, kenjiRef.GetItemCount(proofBase), True)
            endif
        elseif kenjiRef.Is3DLoaded() && !bProofSeeded && proofBase != None
            if kenjiRef.GetItemCount(proofBase) == 0
                kenjiRef.AddItem(proofBase, 1, True)
            endif
            bProofSeeded = True
        endif
        if Self.GetStage() == 20 && kenjiRef.IsDead()
            if bProofRecovered || (player != None && proofBase != None && player.GetItemCount(proofBase) > 0)
                Self.SetStage(25)
            else
                Self.SetStage(22)
            endif
        endif
    endif
    if Self.GetStage() == 20 && !IsObjectiveDisplayed(20)
        EnsureJunktownStage20Active()
    endif
    Actor skullRef = Game.GetFormFromFile(0x000035C5, "Vault13Chronicles.esp") as Actor
    if skullRef != None
        V13WastelandCreatureAIScript skullAI = (skullRef as ObjectReference) as V13WastelandCreatureAIScript
        if skullAI != None
            skullAI.InitCreatureAI()
        endif
        if skullRef.IsDead() && Self.GetStage() < 25 && (player == None || player.GetDistance(skullRef) > 2200.0)
            skullRef.Resurrect()
            Utility.Wait(0.1)
            skullRef.StopCombat()
            skullRef.SetValue(Game.GetAggressionAV(), 0.0)
            skullRef.SetPosition(-2600.0, 5480.0, 86.0)
        endif
        float sz = skullRef.GetPositionZ()
        if !skullRef.IsDead() && (sz < 68.0 || sz > 190.0 || (!skullRef.IsInCombat() && (Math.Abs(skullRef.GetPositionX() + 2600.0) > 450.0 || Math.Abs(skullRef.GetPositionY() - 5480.0) > 450.0)))
            skullRef.StopCombat()
            skullRef.SetPosition(-2600.0, 5480.0, 86.0)
        endif
    endif
    Quest syndQ = Game.GetFormFromFile(0x00019000, "Vault13Chronicles.esp") as Quest
    if syndQ != None
        V13SideQuestJunktownSyndicateScript syndS = syndQ as V13SideQuestJunktownSyndicateScript
        if syndS != None
            syndS.BindSyndicateListeners()
        endif
    endif
EndFunction

Function EnsureKillianVendorReady(Actor akKillian)
    if akKillian == None
        return
    endif
    Faction vFact = Game.GetFormFromFile(0x00001C50, "Vault13Chronicles.esp") as Faction
    if vFact != None && !akKillian.IsInFaction(vFact)
        akKillian.AddToFaction(vFact)
    endif
    ObjectReference vChest = Game.GetFormFromFile(0x000035E0, "Vault13Chronicles.esp") as ObjectReference
    Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
    if vChest != None
        if vChest.IsDisabled()
            vChest.EnableNoWait()
        endif
        if caps != None && vChest.GetItemCount(caps) < 500
            vChest.AddItem(caps, 1800, True)
            Form a10 = Game.GetFormFromFile(0x0001F276, "Fallout4.esm")
            Form a308 = Game.GetFormFromFile(0x0001F66B, "Fallout4.esm")
            Form aShell = Game.GetFormFromFile(0x0001F673, "Fallout4.esm")
            Form a44 = Game.GetFormFromFile(0x0009221C, "Fallout4.esm")
            Form a556 = Game.GetFormFromFile(0x0001F278, "Fallout4.esm")
            Form stim = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
            Form radaway = Game.GetFormFromFile(0x00023742, "Fallout4.esm")
            Form radx = Game.GetFormFromFile(0x00024057, "Fallout4.esm")
            Form water = Game.GetFormFromFile(0x000366C0, "Fallout4.esm")
            Form bpin = Game.GetFormFromFile(0x0000000A, "Fallout4.esm")
            Form wShot = Game.GetFormFromFile(0x0014831C, "Fallout4.esm")
            Form wRifle = Game.GetFormFromFile(0x0004F46A, "Fallout4.esm")
            Form wCRifle = Game.GetFormFromFile(0x000DF42E, "Fallout4.esm")
            Form cArmor = Game.GetFormFromFile(0x0011D3C3, "Fallout4.esm")
            if a10 != None && vChest.GetItemCount(a10) < 40
                vChest.AddItem(a10, 120, True)
            endif
            if a308 != None && vChest.GetItemCount(a308) < 30
                vChest.AddItem(a308, 80, True)
            endif
            if aShell != None && vChest.GetItemCount(aShell) < 30
                vChest.AddItem(aShell, 72, True)
            endif
            if a44 != None && vChest.GetItemCount(a44) < 24
                vChest.AddItem(a44, 60, True)
            endif
            if a556 != None && vChest.GetItemCount(a556) < 30
                vChest.AddItem(a556, 90, True)
            endif
            if stim != None && vChest.GetItemCount(stim) < 6
                vChest.AddItem(stim, 15, True)
            endif
            if radaway != None && vChest.GetItemCount(radaway) < 4
                vChest.AddItem(radaway, 10, True)
            endif
            if radx != None && vChest.GetItemCount(radx) < 4
                vChest.AddItem(radx, 8, True)
            endif
            if water != None && vChest.GetItemCount(water) < 4
                vChest.AddItem(water, 12, True)
            endif
            if bpin != None && vChest.GetItemCount(bpin) < 10
                vChest.AddItem(bpin, 25, True)
            endif
            if wShot != None && vChest.GetItemCount(wShot) == 0
                vChest.AddItem(wShot, 1, True)
            endif
            if wRifle != None && vChest.GetItemCount(wRifle) == 0
                vChest.AddItem(wRifle, 1, True)
            endif
            if wCRifle != None && vChest.GetItemCount(wCRifle) == 0
                vChest.AddItem(wCRifle, 1, True)
            endif
            if cArmor != None && vChest.GetItemCount(cArmor) == 0
                vChest.AddItem(cArmor, 1, True)
            endif
        endif
    endif
EndFunction

Function OpenKillianBarter()
    Actor killianAct = Game.GetFormFromFile(0x000035C0, "Vault13Chronicles.esp") as Actor
    if killianAct == None || killianAct.IsDead()
        return
    endif
    EnsureKillianVendorReady(killianAct)
    Utility.Wait(0.15)
    killianAct.ShowBarterMenu()
EndFunction

Event OnInit()
    BindJunktownListeners()
EndEvent

Event OnQuestInit()
    BindJunktownListeners()
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
    BindJunktownListeners()
EndEvent

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
    if !IsPlayerInVault13Space()
        SuspendCompanionsForCommonwealth()
    else
        RestoreCompanionsOnReturnTo2161()
    endif
    BindJunktownListeners()
    StartTimer(1.0, 97)
    if DogmeatState == 1 || IanState == 1 || TychoState == 1 || iSavedDogmeatState > 0 || iSavedIanState > 0 || iSavedTychoState > 0
        StartTimer(0.4, 96)
    endif
EndEvent

Event OnPlayerTeleport()
    if !IsPlayerInVault13Space()
        SuspendCompanionsForCommonwealth()
    else
        RestoreCompanionsOnReturnTo2161()
    endif
    if DogmeatState == 1 || IanState == 1 || TychoState == 1 || iSavedDogmeatState > 0 || iSavedIanState > 0 || iSavedTychoState > 0
        StartTimer(0.4, 96)
    endif
EndEvent

Function NotifyJunktownProofRecovered()
    if bProofRecovered
        return
    endif
    bProofRecovered = True
    bProofSeeded = True
    Actor kenjiRef = Game.GetFormFromFile(0x000035C4, "Vault13Chronicles.esp") as Actor
    Form proofBase = Game.GetFormFromFile(0x00001451, "Vault13Chronicles.esp")
    if kenjiRef != None && proofBase != None && kenjiRef.GetItemCount(proofBase) > 0
        kenjiRef.RemoveItem(proofBase, kenjiRef.GetItemCount(proofBase), True)
    endif
    if Self.GetStage() < 25
        Self.SetStage(25)
    endif
    BindJunktownListeners()
EndFunction

Function DeliverProofToLars()
    if bItemDelivered
        return
    endif
    bItemDelivered = True
    Actor player = Game.GetPlayer()
    Form proofBase = Game.GetFormFromFile(0x00001451, "Vault13Chronicles.esp")
    if proofBase != None && player.GetItemCount(proofBase) > 0
        player.RemoveItem(proofBase, 1, True)
    endif
    Form noteBase = Game.GetFormFromFile(0x0000114A, "Vault13Chronicles.esp")
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

Event ObjectReference.OnItemAdded(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    Form proofBase = Game.GetFormFromFile(0x00001451, "Vault13Chronicles.esp")
    if akBaseItem == proofBase
        NotifyJunktownProofRecovered()
    endif
EndEvent

Event ObjectReference.OnItemRemoved(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
    Form proofBase = Game.GetFormFromFile(0x00001451, "Vault13Chronicles.esp")
    if akBaseItem == proofBase
        NotifyJunktownProofRecovered()
    endif
EndEvent

Event Actor.OnDeath(Actor akSender, Actor akKiller)
    Actor kenjiRef = Game.GetFormFromFile(0x000035C4, "Vault13Chronicles.esp") as Actor
    if akSender == kenjiRef
        Form proofBase = Game.GetFormFromFile(0x00001451, "Vault13Chronicles.esp")
        Actor player = Game.GetPlayer()
        if akKiller != player && (player == None || player.GetDistance(kenjiRef) > 2200.0) && Self.GetStage() < 25 && !bProofRecovered
            kenjiRef.Resurrect()
            Utility.Wait(0.1)
            kenjiRef.StopCombat()
            kenjiRef.SetValue(Game.GetAggressionAV(), 0.0)
            kenjiRef.SetPosition(-2760.0, 5480.0, 86.0)
            if !bProofSeeded && proofBase != None && kenjiRef.GetItemCount(proofBase) == 0
                kenjiRef.AddItem(proofBase, 1, True)
                bProofSeeded = True
            endif
            return
        endif
        if !bProofSeeded && !bProofRecovered && proofBase != None && player != None && player.GetItemCount(proofBase) == 0 && kenjiRef.GetItemCount(proofBase) == 0
            kenjiRef.AddItem(proofBase, 1, True)
            bProofSeeded = True
        endif
        ForceQuestAlias(1, 0x000035C4)
        if bProofRecovered || (proofBase != None && player != None && player.GetItemCount(proofBase) > 0)
            if Self.GetStage() < 25
                Self.SetStage(25)
            endif
        elseif Self.GetStage() < 22
            Self.SetStage(22)
        endif
        StartTimer(0.8, 90)
    endif
EndEvent

Event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
    if akActionRef != Game.GetPlayer()
        return
    endif
    ObjectReference dogRef = Game.GetFormFromFile(0x000035C3, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference dogShadyRef = Game.GetFormFromFile(0x000035B3, "Vault13Chronicles.esp") as ObjectReference
    if (dogRef != None && akSender == dogRef) || (dogShadyRef != None && akSender == dogShadyRef)
        HandleDogmeatActivation(akSender as Actor)
        return
    endif
    ObjectReference ianRef = Game.GetFormFromFile(0x000035A4, "Vault13Chronicles.esp") as ObjectReference
    if ianRef != None && akSender == ianRef
        HandleIanActivation(akSender as Actor)
        return
    endif
    ObjectReference tychoRef = Game.GetFormFromFile(0x000035C2, "Vault13Chronicles.esp") as ObjectReference
    if tychoRef != None && akSender == tychoRef
        HandleTychoActivation(akSender as Actor)
        return
    endif

    ObjectReference killianRef = Game.GetFormFromFile(0x000035C0, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference larsRef = Game.GetFormFromFile(0x000035C1, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference kenjiObjRef = Game.GetFormFromFile(0x000035C4, "Vault13Chronicles.esp") as ObjectReference
    Actor kenjiAct = kenjiObjRef as Actor
    Form proofBase = Game.GetFormFromFile(0x00001451, "Vault13Chronicles.esp")
    Actor player = Game.GetPlayer()

    if akSender == kenjiObjRef
        if kenjiAct != None && kenjiAct.IsDead()
            if proofBase != None && player != None && player.GetItemCount(proofBase) == 0 && !bItemDelivered
                if kenjiAct.GetItemCount(proofBase) > 0
                    kenjiAct.RemoveItem(proofBase, kenjiAct.GetItemCount(proofBase), True)
                endif
                player.AddItem(proofBase, 1, False)
            endif
            NotifyJunktownProofRecovered()
        endif
        return
    endif

    ForceAllJunktownAliases()
    if akSender == larsRef
        V13SideQuestJunktownSyndicateScript syndLars = Game.GetFormFromFile(0x00019000, "Vault13Chronicles.esp") as V13SideQuestJunktownSyndicateScript
        if syndLars != None
            syndLars.CheckLarsSyndicateReward()
        endif
    endif
    int curStage = Self.GetStage()
    if akSender == larsRef && (curStage == 22 || curStage == 25 || (proofBase != None && player.GetItemCount(proofBase) > 0 && curStage < 30) || (kenjiAct != None && kenjiAct.IsDead() && curStage >= 20 && curStage < 30))
        SilenceJunktownActorsExcept(larsRef as Actor, 0)
        NotifyJunktownProofRecovered()
        DeliverProofToLars()
        Topic helloTopLars = Game.GetFormFromFile(0x00010001, "Vault13Chronicles.esp") as Topic
        if helloTopLars != None && (larsRef as Actor) != None && !(larsRef as Actor).IsTalking()
            (larsRef as Actor).Say(helloTopLars, None, false, None)
        endif
    elseif akSender == larsRef && (curStage == 30 || (bItemDelivered && curStage < 40))
        SilenceJunktownActorsExcept(larsRef as Actor, 0)
        if Self.GetStage() < 40
            Self.SetStage(40)
        endif
        Topic helloTopLars30 = Game.GetFormFromFile(0x00010001, "Vault13Chronicles.esp") as Topic
        if helloTopLars30 != None && (larsRef as Actor) != None && !(larsRef as Actor).IsTalking()
            (larsRef as Actor).Say(helloTopLars30, None, false, None)
        endif
    elseif akSender == killianRef && (curStage == 25 || curStage == 30 || (bItemDelivered && curStage < 40) || (proofBase != None && player.GetItemCount(proofBase) > 0 && curStage < 40))
        SilenceJunktownActorsExcept(killianRef as Actor, 0)
        if !bItemDelivered
            DeliverProofToLars()
        endif
        if Self.GetStage() < 40
            Self.SetStage(40)
        endif
        Topic helloTopKillian30 = Game.GetFormFromFile(0x00010001, "Vault13Chronicles.esp") as Topic
        if helloTopKillian30 != None && (killianRef as Actor) != None && !(killianRef as Actor).IsTalking()
            (killianRef as Actor).Say(helloTopKillian30, None, false, None)
        endif
    elseif akSender == killianRef
        Message barterMsg = Game.GetFormFromFile(0x00001C70, "Vault13Chronicles.esp") as Message
        if barterMsg != None
            int choice = barterMsg.Show()
            if choice == 0
                OpenKillianBarter()
                return
            elseif choice == 2
                return
            endif
        endif
        SilenceJunktownActorsExcept(killianRef as Actor, 1)
        Topic helloTop = Game.GetFormFromFile(0x00010001, "Vault13Chronicles.esp") as Topic
        if helloTop != None && (killianRef as Actor) != None && !(killianRef as Actor).IsTalking()
            (killianRef as Actor).Say(helloTop, None, false, None)
        endif
        if curStage < 25
            EnsureJunktownStage20Active()
            CancelTimer(92)
            CancelTimer(93)
            sceneWaitTicks = 0
            StartTimer(0.5, 91)
            StartTimer(2.0, 94)
        endif
    elseif akSender == larsRef && curStage < 25
        SilenceJunktownActorsExcept(larsRef as Actor, 2)
        Topic helloTop = Game.GetFormFromFile(0x00010001, "Vault13Chronicles.esp") as Topic
        if helloTop != None && (larsRef as Actor) != None && !(larsRef as Actor).IsTalking()
            (larsRef as Actor).Say(helloTop, None, false, None)
        endif
        EnsureJunktownStage20Active()
        CancelTimer(91)
        CancelTimer(93)
        sceneWaitTicks = 0
        StartTimer(0.6, 92)
        StartTimer(2.0, 94)
    elseif akSender == larsRef
        Topic helloTopDone = Game.GetFormFromFile(0x00010001, "Vault13Chronicles.esp") as Topic
        if helloTopDone != None && (larsRef as Actor) != None && !(larsRef as Actor).IsTalking()
            (larsRef as Actor).Say(helloTopDone, None, false, None)
        endif
    endif
EndEvent

Function QueueJumpToJunktown()
    if bMenuJumpBusy
        return
    endif
    bMenuJumpBusy = True
    BindJunktownListeners()
    StartTimer(0.6, 95)
EndFunction

Event OnTimer(int aiTimerID)
    if aiTimerID == 90
        Actor kenjiRef = Game.GetFormFromFile(0x000035C4, "Vault13Chronicles.esp") as Actor
        Actor player = Game.GetPlayer()
        Form proofBase = Game.GetFormFromFile(0x00001451, "Vault13Chronicles.esp")
        if bProofRecovered || bItemDelivered || Self.GetStage() >= 25
            return
        endif
        if player != None && proofBase != None && player.GetItemCount(proofBase) > 0
            NotifyJunktownProofRecovered()
            return
        endif
        if kenjiRef != None && kenjiRef.IsDead()
            if proofBase != None && kenjiRef.GetItemCount(proofBase) == 0 && bProofSeeded
                if player != None && player.GetItemCount(proofBase) == 0
                    player.AddItem(proofBase, 1, False)
                endif
                NotifyJunktownProofRecovered()
                return
            endif
            if Self.GetStage() < 25
                StartTimer(0.8, 90)
            endif
        endif
    elseif aiTimerID == 91
        Scene introScene = Game.GetFormFromFile(0x00010100, "Vault13Chronicles.esp") as Scene
        Actor killianActor = Game.GetFormFromFile(0x000035C0, "Vault13Chronicles.esp") as Actor
        if Self.IsRunning() && introScene != None && Self.GetStage() < 25
            if introScene.IsPlaying()
                return
            elseif killianActor != None && killianActor.IsTalking() && sceneWaitTicks < 28
                sceneWaitTicks += 1
                StartTimer(0.4, 91)
            else
                ForceAllJunktownAliases()
                SilenceJunktownActorsExcept(killianActor, 1)
                if Self.IsRunning()
                    introScene.Start()
                endif
            endif
        endif
    elseif aiTimerID == 92
        Scene larsScene = Game.GetFormFromFile(0x00010101, "Vault13Chronicles.esp") as Scene
        Actor larsActor = Game.GetFormFromFile(0x000035C1, "Vault13Chronicles.esp") as Actor
        if Self.IsRunning() && larsScene != None && Self.GetStage() < 25
            if larsScene.IsPlaying()
                return
            elseif larsActor != None && larsActor.IsTalking() && sceneWaitTicks < 28
                sceneWaitTicks += 1
                StartTimer(0.4, 92)
            else
                ForceAllJunktownAliases()
                SilenceJunktownActorsExcept(larsActor, 2)
                if Self.IsRunning()
                    larsScene.Start()
                endif
            endif
        endif
    elseif aiTimerID == 93
        Scene tychoScene = Game.GetFormFromFile(0x00010102, "Vault13Chronicles.esp") as Scene
        Actor tychoActor = Game.GetFormFromFile(0x000035C2, "Vault13Chronicles.esp") as Actor
        if Self.IsRunning() && tychoScene != None && Self.GetStage() < 30
            if tychoScene.IsPlaying()
                return
            elseif tychoActor != None && tychoActor.IsTalking() && sceneWaitTicks < 28
                sceneWaitTicks += 1
                StartTimer(0.4, 93)
            else
                ForceAllJunktownAliases()
                SilenceJunktownActorsExcept(tychoActor, 3)
                if Self.IsRunning()
                    tychoScene.Start()
                endif
            endif
        endif
    elseif aiTimerID == 94
        if Self.GetStage() <= 20
            EnsureJunktownStage20Active()
        endif
    elseif aiTimerID == 95
        bMenuJumpBusy = False
        Actor player = Game.GetPlayer()
        EnsurePlayerHasDogmeatItems()
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
        ObjectReference mapMarker = Game.GetFormFromFile(0x0000341C, "Vault13Chronicles.esp") as ObjectReference
        if mapMarker != None
            mapMarker.EnableNoWait()
            mapMarker.AddToMap(True)
        endif
        ObjectReference ftMarker = Game.GetFormFromFile(0x0000351C, "Vault13Chronicles.esp") as ObjectReference
        if ftMarker != None
            player.MoveTo(ftMarker)
            RefreshJunktownSettlementLayout()
            if DogmeatState == 1
                SyncDogmeatWithPlayer()
            endif
            StartTimer(1.0, 97)
            StartTimer(0.8, 98)
            Debug.Notification("Trasladado a Junktown (2161). Habla con el alcalde Killian Darkwater, el capitán Lars o el Ranger Tycho.")
        endif
    elseif aiTimerID == 96
        SyncDogmeatWithPlayer()
    elseif aiTimerID == 97
        RefreshJunktownSettlementLayout()
    elseif aiTimerID == 98
        CheckDogmeatProximity()
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

    Actor player = Game.GetPlayer()
    Form proofBase = Game.GetFormFromFile(0x00001451, "Vault13Chronicles.esp")

    if auiStageID == 20
        ObjectReference mapMarker = Game.GetFormFromFile(0x0000341C, "Vault13Chronicles.esp") as ObjectReference
        if mapMarker != None
            mapMarker.EnableNoWait()
            mapMarker.AddToMap(True)
        endif
        if proofBase != None && player.GetItemCount(proofBase) > 0
            Self.SetStage(25)
            return
        endif
        Actor kenjiRef = Game.GetFormFromFile(0x000035C4, "Vault13Chronicles.esp") as Actor
        if kenjiRef != None && kenjiRef.IsDead()
            Self.SetStage(22)
            return
        endif
        ForceQuestAlias(1, 0x000035C4)
        if !IsObjectiveDisplayed(20)
            SetObjectiveDisplayed(20, True, False)
        endif
        Self.SetActive(True)
        if doStg20
            Debug.Notification("Misión Secundaria: Justicia en Junktown — Elimina al sicario Kenji en el local de Gizmo al oeste.")
        endif
        BindJunktownListeners()
        V13SideQuestJunktownSyndicateScript syndQ = Game.GetFormFromFile(0x00019000, "Vault13Chronicles.esp") as V13SideQuestJunktownSyndicateScript
        if syndQ != None && syndQ.GetStage() < 15
            syndQ.StartJunktownSyndicateQuest()
        endif
    elseif auiStageID == 22
        if proofBase != None && player.GetItemCount(proofBase) > 0
            Self.SetStage(25)
            return
        endif
        ForceQuestAlias(1, 0x000035C4)
        SetObjectiveCompleted(20, True)
        if !IsObjectiveDisplayed(22)
            SetObjectiveDisplayed(22, True, False)
        endif
        Self.SetActive(True)
        if doStg22
            Debug.Notification("¡Kenji abatido! Extrae el Contrato y la Cinta de Confesión de Gizmo de su cadáver.")
        endif
        BindJunktownListeners()
    elseif auiStageID == 25
        SetObjectiveCompleted(20, True)
        SetObjectiveCompleted(22, True)
        if !IsObjectiveDisplayed(25)
            SetObjectiveDisplayed(25, True, False)
        endif
        Self.SetActive(True)
        if doStg25
            Debug.Notification("Pruebas contra Gizmo obtenidas. Entrégaselas al Capitán Lars en Junktown.")
        endif
        BindJunktownListeners()
    elseif auiStageID == 30
        if !bItemDelivered
            DeliverProofToLars()
        endif
        SetObjectiveCompleted(20, True)
        SetObjectiveCompleted(22, True)
        SetObjectiveCompleted(25, True)
        if !IsObjectiveDisplayed(30)
            SetObjectiveDisplayed(30, True, False)
        endif
        Self.SetActive(True)
        if doStg30
            Debug.Notification("¡Lars ha incautado las pruebas contra Gizmo! Informa al alcalde Killian Darkwater en Junktown.")
        endif
        BindJunktownListeners()
    elseif auiStageID == 40
        SetObjectiveCompleted(20, True)
        SetObjectiveCompleted(22, True)
        SetObjectiveCompleted(25, True)
        SetObjectiveCompleted(30, True)
        if doReward40
            Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
            Form shotgun = Game.GetFormFromFile(0x0014831C, "Fallout4.esm")
            Form shells = Game.GetFormFromFile(0x0001F673, "Fallout4.esm")
            Form stimpak = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
            if caps != None
                player.AddItem(caps, 500, False)
            endif
            if shotgun != None
                player.AddItem(shotgun, 1, False)
            endif
            if shells != None
                player.AddItem(shells, 36, False)
            endif
            if stimpak != None
                player.AddItem(stimpak, 4, False)
            endif
            Game.RewardPlayerXP(350)
            Debug.Notification("¡Misión Secundaria completada: Justicia en Junktown! (+500 Chapas, Escopeta de Combate, Cartuchos y +350 XP)")
        endif
        Self.CompleteQuest()
        BindJunktownListeners()
        V13SideQuestJunktownSyndicateScript syndQ2 = Game.GetFormFromFile(0x00019000, "Vault13Chronicles.esp") as V13SideQuestJunktownSyndicateScript
        if syndQ2 != None && syndQ2.GetStage() < 15
            syndQ2.StartJunktownSyndicateQuest()
        endif
    endif
EndEvent
