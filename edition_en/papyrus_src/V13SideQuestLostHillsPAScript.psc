Scriptname V13SideQuestLostHillsPAScript extends Quest

bool bMotivatorObtained = False
bool bLorenzoRescued = False
bool bRewardGranted = False
bool bCaptorKeySeeded = False
bool bPAInitialized = False
bool bStg20Notified = False
bool bStg22Notified = False
bool bStg25Notified = False
bool bStg30Notified = False
bool bOldTownCampHostile = False
bool bOldTownCampTruce = False
bool bCaptorMenuBusy = False
bool bShackApproachCooldown = False
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

Function ForceAllLostHillsPAAliases()
    if Self.IsCompleted() || Self.GetStage() >= 40 || Self.IsStageDone(40) || bRewardGranted
        return
    endif
    ForceQuestAlias(0, 0x00002B33) ; Knight Kyle (L2 Workshop)
    if Self.GetStage() == 25
        ForceQuestAlias(1, 0x00002B33) ; Deliver Motivator to Kyle / PA Frame
    elseif Self.GetStage() == 30
        ForceQuestAlias(1, 0x00002B33) ; Report Lorenzo's rescue to Kyle
    else
        ForceQuestAlias(1, 0x00003610) ; Captive Initiate Lorenzo in Old Town (Hub)
    endif
    ForceQuestAlias(2, 0x00003005)
    ForceQuestAlias(3, 0x00002003)
    ForceQuestAlias(4, 0x00003507) ; Lost Hills Surface Bunker Door
    ForceQuestAlias(5, 0x00002143)
    ForceQuestAlias(6, 0x00003501)
    Actor paPlayer = Game.GetPlayer()
    Cell paLostHillsCell = Game.GetFormFromFile(0x00002B00, "Vault13Chronicles.esp") as Cell
    if paPlayer != None && paLostHillsCell != None && paPlayer.GetParentCell() == paLostHillsCell && paPlayer.GetPositionX() > 1200.0
        ForceQuestAlias(7, 0x00002B47)
    else
        ForceQuestAlias(7, 0x00002B48)
    endif
    ForceQuestAlias(9, 0x00002B31) ; Quartermaster Michael (L1)
    ForceQuestAlias(10, 0x00002B32) ; Head Paladin Rhombus (L2)
    ForceQuestAlias(11, 0x00003610) ; Initiate Lorenzo (Old Town)
    ForceQuestAlias(12, 0x00002B42) ; T-51b Power Armor Frame (L2)
    ForceQuestAlias(13, 0x00003611) ; Old Town Captor Leader
EndFunction

Function SyncPowerArmorFrameLock()
    ObjectReference paRef = Game.GetFormFromFile(0x00002B42, "Vault13Chronicles.esp") as ObjectReference
    Actor player = Game.GetPlayer()
    if paRef == None
        return
    endif
    if paRef.IsDisabled()
        paRef.EnableNoWait()
    endif
    if Self.IsCompleted() || Self.GetStage() >= 40 || Self.IsStageDone(40) || bRewardGranted
        paRef.BlockActivation(False, False)
        if player != None
            paRef.SetActorOwner(player.GetActorBase())
        endif
    else
        paRef.BlockActivation(True, True)
    endif
    bPAInitialized = True
EndFunction

Function RefreshLorenzoShackDoorGuard()
    ObjectReference shackDoor = Game.GetFormFromFile(0x00003615, "Vault13Chronicles.esp") as ObjectReference
    if shackDoor == None
        return
    endif
    Actor captor1 = Game.GetFormFromFile(0x00003611, "Vault13Chronicles.esp") as Actor
    Actor captor2 = Game.GetFormFromFile(0x00003612, "Vault13Chronicles.esp") as Actor
    bool captorsAlive = (captor1 != None && !captor1.IsDead()) || (captor2 != None && !captor2.IsDead())
    if !bOldTownCampTruce && !bLorenzoRescued && Self.GetStage() < 30 && captorsAlive
        shackDoor.BlockActivation(True, True)
    else
        shackDoor.BlockActivation(False, False)
    endif
EndFunction

Function NotifyPlayerApproachedOldTownShack()
    if Self.IsCompleted() || Self.GetStage() >= 30 || bLorenzoRescued || bOldTownCampTruce || bOldTownCampHostile || bShackApproachCooldown
        return
    endif
    Actor captor1 = Game.GetFormFromFile(0x00003611, "Vault13Chronicles.esp") as Actor
    Actor captor2 = Game.GetFormFromFile(0x00003612, "Vault13Chronicles.esp") as Actor
    if (captor1 == None || captor1.IsDead()) && (captor2 == None || captor2.IsDead())
        RefreshLorenzoShackDoorGuard()
        return
    endif
    bShackApproachCooldown = True
    StartTimer(12.0, 96)
    if !Self.IsRunning()
        Self.Start()
    endif
    if Self.GetStage() < 20
        Self.SetStage(20)
    endif
    RefreshLorenzoShackDoorGuard()
    ForceQuestAlias(13, 0x00003611)
    if captor1 != None && !captor1.IsDead()
        captor1.AllowPCDialogue(True)
    endif
    Debug.Notification("Old Town Mercenary: 'Hold it right there! Initiate Lorenzo isn't leaving this shack until his debt is settled.'")
    StartTimer(0.6, 92)
EndFunction

Function SetupLostHillsPAListeners(bool abRefreshLayout = True)
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
    ForceAllLostHillsPAAliases()
    Actor pLH = Game.GetPlayer()
    WorldSpace caliLH = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    Cell lhCell = Game.GetFormFromFile(0x00002B00, "Vault13Chronicles.esp") as Cell
    bool inLHOrCali = (pLH != None && ((caliLH != None && pLH.GetWorldSpace() == caliLH) || (lhCell != None && pLH.GetParentCell() == lhCell)))
    if abRefreshLayout && inLHOrCali
        SyncPowerArmorFrameLock()
    endif

    Actor player = Game.GetPlayer()
    Form motivatorBase = Game.GetFormFromFile(0x00001511, "Vault13Chronicles.esp")
    Form shackKeyFilter = Game.GetFormFromFile(0x00001513, "Vault13Chronicles.esp")
    Self.RemoveAllInventoryEventFilters()
    if motivatorBase != None
        Self.AddInventoryEventFilter(motivatorBase)
    endif
    if shackKeyFilter != None
        Self.AddInventoryEventFilter(shackKeyFilter)
    endif
    if player != None
        RegisterForRemoteEvent(player, "OnPlayerLoadGame")
        RegisterForRemoteEvent(player, "OnLocationChange")
        if motivatorBase != None || shackKeyFilter != None
            RegisterForRemoteEvent(player as ObjectReference, "OnItemAdded")
        endif
    endif

    ObjectReference kyleRef = Game.GetFormFromFile(0x00002B33, "Vault13Chronicles.esp") as ObjectReference
    if kyleRef != None
        RegisterForRemoteEvent(kyleRef, "OnActivate")
    endif
    ObjectReference michaelRef = Game.GetFormFromFile(0x00002B31, "Vault13Chronicles.esp") as ObjectReference
    if michaelRef != None
        RegisterForRemoteEvent(michaelRef, "OnActivate")
    endif
    ObjectReference rhombusRef = Game.GetFormFromFile(0x00002B32, "Vault13Chronicles.esp") as ObjectReference
    if rhombusRef != None
        RegisterForRemoteEvent(rhombusRef, "OnActivate")
    endif
    ObjectReference paRef = Game.GetFormFromFile(0x00002B42, "Vault13Chronicles.esp") as ObjectReference
    if paRef != None
        RegisterForRemoteEvent(paRef, "OnActivate")
    endif

    Actor lorenzoAct = Game.GetFormFromFile(0x00003610, "Vault13Chronicles.esp") as Actor
    if lorenzoAct != None
        if lorenzoAct.IsDisabled() && !bLorenzoRescued && Self.GetStage() < 40
            lorenzoAct.EnableNoWait()
        endif
        RegisterForRemoteEvent(lorenzoAct as ObjectReference, "OnActivate")
    endif

    Actor captor1 = Game.GetFormFromFile(0x00003611, "Vault13Chronicles.esp") as Actor
    Actor captor2 = Game.GetFormFromFile(0x00003612, "Vault13Chronicles.esp") as Actor
    Form shackKey = Game.GetFormFromFile(0x00001513, "Vault13Chronicles.esp")
    if captor1 != None
        RegisterForRemoteEvent(captor1, "OnDeath")
        RegisterForRemoteEvent(captor1 as ObjectReference, "OnActivate")
        if !captor1.IsDead()
            RegisterForHitEvent(captor1)
        endif
        if !bCaptorKeySeeded && shackKey != None && captor1.GetItemCount(shackKey) == 0
            captor1.AddItem(shackKey, 1, True)
            bCaptorKeySeeded = True
        endif
    endif
    if captor2 != None
        RegisterForRemoteEvent(captor2, "OnDeath")
        RegisterForRemoteEvent(captor2 as ObjectReference, "OnActivate")
        if !captor2.IsDead()
            RegisterForHitEvent(captor2)
        endif
    endif
    if abRefreshLayout && inLHOrCali
        SanitizeOldTownCampPeace()
    endif

    ObjectReference shackDoor = Game.GetFormFromFile(0x00003615, "Vault13Chronicles.esp") as ObjectReference
    if shackDoor != None
        if shackDoor.IsDisabled()
            shackDoor.EnableNoWait()
        endif
        RegisterForRemoteEvent(shackDoor, "OnActivate")
    endif
    if abRefreshLayout && inLHOrCali
        RefreshLorenzoShackDoorGuard()
    endif
EndFunction

Event OnInit()
    SetupLostHillsPAListeners(False)
    Actor player = Game.GetPlayer()
    WorldSpace caliLH = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    Cell lhCell = Game.GetFormFromFile(0x00002B00, "Vault13Chronicles.esp") as Cell
    if player != None && ((caliLH != None && player.GetWorldSpace() == caliLH) || (lhCell != None && player.GetParentCell() == lhCell))
        StartTimer(2.5, 99)
    endif
EndEvent

Event OnQuestInit()
    SetupLostHillsPAListeners(False)
    Actor player = Game.GetPlayer()
    WorldSpace caliLH = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    Cell lhCell = Game.GetFormFromFile(0x00002B00, "Vault13Chronicles.esp") as Cell
    if player != None && ((caliLH != None && player.GetWorldSpace() == caliLH) || (lhCell != None && player.GetParentCell() == lhCell))
        StartTimer(2.5, 99)
    endif
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
    SetupLostHillsPAListeners(False)
    Actor player = Game.GetPlayer()
    WorldSpace caliLH = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    Cell lhCell = Game.GetFormFromFile(0x00002B00, "Vault13Chronicles.esp") as Cell
    if player != None && ((caliLH != None && player.GetWorldSpace() == caliLH) || (lhCell != None && player.GetParentCell() == lhCell))
        StartTimer(2.5, 99)
    endif
EndEvent

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
    SetupLostHillsPAListeners()
EndEvent

Function GrantSystolicMotivator()
    Actor player = Game.GetPlayer()
    Form motivatorBase = Game.GetFormFromFile(0x00001511, "Vault13Chronicles.esp")
    if player != None && motivatorBase != None
        if player.GetItemCount(motivatorBase) == 0 && !bRewardGranted && Self.GetStage() < 40
            player.AddItem(motivatorBase, 1, False)
        endif
    endif
    bMotivatorObtained = True
    if Self.GetStage() < 25
        Self.SetStage(25)
    endif
    ForceAllLostHillsPAAliases()
EndFunction

Function RequestSystolicMotivatorFromTerminal()
    if Self.GetStage() >= 40 || bRewardGranted
        Debug.Notification("[Lost Hills Quartermaster] The workshop T-51b Power Armor is already calibrated and assigned to you.")
        return
    endif
    if bMotivatorObtained
        Debug.Notification("[Lost Hills Quartermaster] The T-51b Systolic Motivator has already been issued. Install it with Knight Kyle on Level 2.")
        return
    endif
    Actor player = Game.GetPlayer()
    Quest qGlow = Game.GetFormFromFile(0x00013000, "Vault13Chronicles.esp") as Quest
    ActorValue chrAV = Game.GetFormFromFile(0x000002C4, "Fallout4.esm") as ActorValue
    ActorValue intAV = Game.GetFormFromFile(0x000002C6, "Fallout4.esm") as ActorValue
    Perk sciPerk = Game.GetFormFromFile(0x000264D9, "Fallout4.esm") as Perk
    bool authorized = (qGlow != None && qGlow.GetStage() >= 30)
    if !authorized && player != None
        if (chrAV != None && player.GetValue(chrAV) >= 6.0) || (intAV != None && player.GetValue(intAV) >= 7.0) || (sciPerk != None && player.HasPerk(sciPerk))
            authorized = True
        endif
    endif
    if authorized
        GrantSystolicMotivator()
        Debug.Notification("[Lost Hills Quartermaster] Requisition approved: T-51b Systolic Motivator withdrawn from stores. Deliver it to Knight Kyle on Level 2.")
    else
        if Self.GetStage() < 20
            Self.SetStage(20)
        endif
        Debug.Notification("[Lost Hills Quartermaster] Restricted to Initiates (Trial of The Glow) or technical specialists (INT 7 / Science / CHA 6). Alternative: rescue Initiate Lorenzo in Old Town (The Hub).")
    endif
EndFunction

Function CompletePowerArmorUnlock(bool abViaLorenzo)
    if bRewardGranted
        return
    endif
    bRewardGranted = True
    Actor player = Game.GetPlayer()
    Form motivatorBase = Game.GetFormFromFile(0x00001511, "Vault13Chronicles.esp")
    if player != None && motivatorBase != None && player.GetItemCount(motivatorBase) > 0
        player.RemoveItem(motivatorBase, player.GetItemCount(motivatorBase), True)
    endif
    SyncPowerArmorFrameLock()
    if player != None
        Form fCore = Game.GetFormFromFile(0x00075FE4, "Fallout4.esm")
        Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
        if fCore != None
            player.AddItem(fCore, 4, False)
        endif
        if caps != None
            player.AddItem(caps, 500, False)
        endif
    endif
    Game.RewardPlayerXP(600, False)
    if abViaLorenzo
        Debug.Notification("Quest Completed: Lost Hills Honor of Steel! For rescuing Initiate Lorenzo, Rhombus and Kyle grant you a full T-51b Power Armor (+4 Fusion Cores, +500 Caps, +600 XP).")
    else
        Debug.Notification("Quest Completed: Lost Hills Honor of Steel! Systolic Motivator installed: the Level 2 workshop T-51b Power Armor is yours (+4 Fusion Cores, +500 Caps, +600 XP).")
    endif
    if Self.GetStage() < 40
        Self.SetStage(40)
    endif
EndFunction

Event ObjectReference.OnItemAdded(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    Form motivatorBase = Game.GetFormFromFile(0x00001511, "Vault13Chronicles.esp")
    Form shackKeyBase = Game.GetFormFromFile(0x00001513, "Vault13Chronicles.esp")
    if akBaseItem == motivatorBase && Self.GetStage() < 40
        bMotivatorObtained = True
        if Self.GetStage() < 25
            Self.SetStage(25)
        endif
        ForceAllLostHillsPAAliases()
    elseif akBaseItem == shackKeyBase
        ObjectReference shackDoor = Game.GetFormFromFile(0x00003615, "Vault13Chronicles.esp") as ObjectReference
        if shackDoor != None
            shackDoor.BlockActivation(False, False)
            if shackDoor.IsLocked()
                shackDoor.Lock(False, False)
            endif
        endif
        Debug.Notification("[Old Town Cell Key] The lock on Initiate Lorenzo's shack has been unlocked.")
    endif
EndEvent

Function SanitizeOldTownCampPeace()
    if bOldTownCampHostile
        return
    endif
    Faction raiderFact = Game.GetFormFromFile(0x0001CBED, "Fallout4.esm") as Faction
    ActorValue aggrAV = Game.GetAggressionAV()
    Actor captor1 = Game.GetFormFromFile(0x00003611, "Vault13Chronicles.esp") as Actor
    Actor captor2 = Game.GetFormFromFile(0x00003612, "Vault13Chronicles.esp") as Actor
    Actor player = Game.GetPlayer()
    if captor1 != None && !captor1.IsDead()
        if raiderFact != None && captor1.IsInFaction(raiderFact)
            captor1.RemoveFromFaction(raiderFact)
        endif
        if aggrAV != None
            captor1.SetValue(aggrAV, 0.0)
        endif
        if !captor1.IsInCombat() || captor1.GetCombatTarget() != player
            captor1.StopCombat()
        endif
        captor1.EvaluatePackage()
    endif
    if captor2 != None && !captor2.IsDead()
        if raiderFact != None && captor2.IsInFaction(raiderFact)
            captor2.RemoveFromFaction(raiderFact)
        endif
        if aggrAV != None
            captor2.SetValue(aggrAV, 0.0)
        endif
        if !captor2.IsInCombat() || captor2.GetCombatTarget() != player
            captor2.StopCombat()
        endif
        captor2.EvaluatePackage()
    endif
EndFunction

Function TriggerOldTownCampHostile()
    bOldTownCampHostile = True
    Scene confStopLH = Game.GetFormFromFile(0x000D7400, "Vault13Chronicles.esp") as Scene
    if confStopLH != None && confStopLH.IsPlaying()
        confStopLH.Stop()
    endif
    if Self.GetStage() < 20
        Self.SetStage(20)
    endif
    Actor player = Game.GetPlayer()
    Faction playerFact = Game.GetFormFromFile(0x0001C21C, "Fallout4.esm") as Faction
    ActorValue aggrAV = Game.GetAggressionAV()
    ActorValue confAV = Game.GetConfidenceAV()
    Actor captor1 = Game.GetFormFromFile(0x00003611, "Vault13Chronicles.esp") as Actor
    Actor captor2 = Game.GetFormFromFile(0x00003612, "Vault13Chronicles.esp") as Actor
    if captor1 != None && !captor1.IsDead()
        if playerFact != None && captor1.IsInFaction(playerFact)
            captor1.RemoveFromFaction(playerFact)
        endif
        if aggrAV != None
            captor1.SetValue(aggrAV, 2.0)
        endif
        if confAV != None
            captor1.SetValue(confAV, 4.0)
        endif
        if player != None && captor1.Is3DLoaded()
            captor1.StartCombat(player)
        endif
    endif
    if captor2 != None && !captor2.IsDead()
        if playerFact != None && captor2.IsInFaction(playerFact)
            captor2.RemoveFromFaction(playerFact)
        endif
        if aggrAV != None
            captor2.SetValue(aggrAV, 2.0)
        endif
        if confAV != None
            captor2.SetValue(confAV, 4.0)
        endif
        if player != None && captor2.Is3DLoaded()
            captor2.StartCombat(player)
        endif
    endif
    RefreshLorenzoShackDoorGuard()
EndFunction

Event OnHit(ObjectReference akTarget, ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked, string asMaterialName)
    if akTarget != None
        RegisterForHitEvent(akTarget)
    endif
    if bOldTownCampHostile || akTarget == None || akAggressor == None
        return
    endif
    Actor player = Game.GetPlayer()
    Actor aggAct = akAggressor as Actor
    bool isPlayerHit = (player != None && akAggressor == (player as ObjectReference)) || (aggAct != None && aggAct.IsPlayerTeammate())
    if !isPlayerHit
        return
    endif
    ObjectReference c1Hit = Game.GetFormFromFile(0x00003611, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference c2Hit = Game.GetFormFromFile(0x00003612, "Vault13Chronicles.esp") as ObjectReference
    if (c1Hit != None && akTarget == c1Hit) || (c2Hit != None && akTarget == c2Hit)
        TriggerOldTownCampHostile()
    endif
EndEvent

Event Actor.OnDeath(Actor akSender, Actor akKiller)
    Actor captor1 = Game.GetFormFromFile(0x00003611, "Vault13Chronicles.esp") as Actor
    Actor captor2 = Game.GetFormFromFile(0x00003612, "Vault13Chronicles.esp") as Actor
    if akSender == captor1 || akSender == captor2
        if Self.GetStage() < 20
            Self.SetStage(20)
        endif
        if (captor1 == None || captor1.IsDead()) && (captor2 == None || captor2.IsDead())
            ObjectReference shackDoor = Game.GetFormFromFile(0x00003615, "Vault13Chronicles.esp") as ObjectReference
            if shackDoor != None
                shackDoor.BlockActivation(False, False)
                if shackDoor.IsLocked()
                    shackDoor.Lock(False, False)
                endif
            endif
            Debug.Notification("[Old Town - The Hub] Kidnappers eliminated. Enter the shack and free Brotherhood Initiate Lorenzo.")
        endif
    endif
EndEvent

Event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
    Actor player = Game.GetPlayer()
    if akActionRef != player || player == None
        return
    endif

    ObjectReference kyleRef = Game.GetFormFromFile(0x00002B33, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference michaelRef = Game.GetFormFromFile(0x00002B31, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference rhombusRef = Game.GetFormFromFile(0x00002B32, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference lorenzoRef = Game.GetFormFromFile(0x00003610, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference paRef = Game.GetFormFromFile(0x00002B42, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference captor1Obj = Game.GetFormFromFile(0x00003611, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference captor2Obj = Game.GetFormFromFile(0x00003612, "Vault13Chronicles.esp") as ObjectReference
    Form motivatorBase = Game.GetFormFromFile(0x00001511, "Vault13Chronicles.esp")
    bool hasMotivator = (motivatorBase != None && player.GetItemCount(motivatorBase) > 0)
    int curStage = Self.GetStage()
    if Self.IsCompleted() || Self.IsStageDone(40) || bRewardGranted
        bRewardGranted = True
        curStage = 40
    endif

    ObjectReference shackDoorObj = Game.GetFormFromFile(0x00003615, "Vault13Chronicles.esp") as ObjectReference
    if shackDoorObj != None && akSender == shackDoorObj
        RefreshLorenzoShackDoorGuard()
        Actor c1Door = Game.GetFormFromFile(0x00003611, "Vault13Chronicles.esp") as Actor
        Actor c2Door = Game.GetFormFromFile(0x00003612, "Vault13Chronicles.esp") as Actor
        if !bOldTownCampTruce && !bLorenzoRescued && curStage < 30 && ((c1Door != None && !c1Door.IsDead()) || (c2Door != None && !c2Door.IsDead()))
            if curStage < 20
                Self.SetStage(20)
            endif
            if !bOldTownCampHostile
                Debug.Notification("Old Town Mercenary: 'Hands off that lock while we're on watch! Talk to us or get ready to fight.'")
                ForceQuestAlias(13, 0x00003611)
                if c1Door != None && !c1Door.IsDead()
                    c1Door.AllowPCDialogue(True)
                endif
                StartTimer(0.5, 92)
            endif
            return
        endif
    endif

    if (captor1Obj != None && akSender == captor1Obj) || (captor2Obj != None && akSender == captor2Obj)
        Actor captorAct = akSender as Actor
        if captorAct != None && !captorAct.IsDead() && !captorAct.IsInCombat() && !bOldTownCampHostile
            if curStage < 20
                Self.SetStage(20)
                curStage = 20
            endif
            if curStage < 30 && !bOldTownCampTruce && !bLorenzoRescued && !bOldTownCampHostile
                ForceQuestAlias(13, 0x00003611)
                captorAct.AllowPCDialogue(True)
                StartTimer(0.5, 92)
            endif
        endif
        return
    endif

    if akSender == paRef
        if curStage >= 40 || bRewardGranted
            paRef.BlockActivation(False, False)
            return
        endif
        if hasMotivator || bMotivatorObtained
            CompletePowerArmorUnlock(False)
            return
        endif
        if curStage < 20
            Self.SetStage(20)
        endif
        Debug.Notification("[T-51b Power Armor - Uncalibrated] Missing a Systolic Motivator. Speak with Knight Kyle here: obtain one from Quartermaster Michael (Level 1) or rescue Initiate Lorenzo in The Hub.")
        return
    endif

    if akSender == lorenzoRef
        if curStage < 30
            Actor captor1 = Game.GetFormFromFile(0x00003611, "Vault13Chronicles.esp") as Actor
            Actor captor2 = Game.GetFormFromFile(0x00003612, "Vault13Chronicles.esp") as Actor
            ObjectReference shackDoor = Game.GetFormFromFile(0x00003615, "Vault13Chronicles.esp") as ObjectReference
            if shackDoor != None && shackDoor.IsLocked()
                shackDoor.Lock(False, False)
            endif
            if (captor1 != None && !captor1.IsDead() && captor1.IsInCombat()) || (captor2 != None && !captor2.IsDead() && captor2.IsInCombat())
                Debug.Notification("[Initiate Lorenzo] Take out the kidnappers outside first so I can escape safely!")
                return
            endif
            if curStage < 20
                Self.SetStage(20)
            endif
            bLorenzoRescued = True
            Self.SetStage(30)
            Debug.Notification("Initiate Lorenzo freed in Old Town! Return to Lost Hills bunker and report to Knight Kyle or Head Paladin Rhombus on Level 2.")
        endif
        return
    endif

    if akSender == michaelRef && curStage >= 20 && curStage < 40 && !bMotivatorObtained
        Quest qGlow = Game.GetFormFromFile(0x00013000, "Vault13Chronicles.esp") as Quest
        if qGlow != None && qGlow.GetStage() >= 30
            GrantSystolicMotivator()
            Debug.Notification("[Quartermaster Michael] As a Lost Hills Initiate, Michael issues you the T-51b Systolic Motivator for Knight Kyle's workshop.")
        endif
        return
    endif

    if akSender == rhombusRef
        if curStage == 30 || bLorenzoRescued
            if curStage < 40
                CompletePowerArmorUnlock(True)
            endif
        elseif curStage < 20
            StartTimer(2.0, 94)
        endif
        return
    endif

    if akSender == kyleRef
        if curStage >= 40
            return
        endif
        if curStage == 30 || bLorenzoRescued
            CompletePowerArmorUnlock(True)
        elseif hasMotivator || curStage == 25
            CompletePowerArmorUnlock(False)
        elseif curStage < 25
            sceneWaitTicks = 0
            StartTimer(1.2, 91)
        endif
    endif
EndEvent

Event OnTimer(int aiTimerID)
    if aiTimerID == 91
        Scene introScene = Game.GetFormFromFile(0x000D1100, "Vault13Chronicles.esp") as Scene
        Actor kyleAct = Game.GetFormFromFile(0x00002B33, "Vault13Chronicles.esp") as Actor
        if Self.IsRunning() && introScene != None && Self.GetStage() < 25
            if !introScene.IsPlaying()
                if !Utility.IsInMenuMode() && (kyleAct == None || (!kyleAct.IsInDialogueWithPlayer() && !kyleAct.IsTalking()))
                    ForceAllLostHillsPAAliases()
                    introScene.Start()
                elseif sceneWaitTicks < 4
                    sceneWaitTicks += 1
                    StartTimer(1.5, 91)
                endif
            endif
        endif
    elseif aiTimerID == 92
        Scene confSceneLH = Game.GetFormFromFile(0x000D7400, "Vault13Chronicles.esp") as Scene
        Actor captorAct = Game.GetFormFromFile(0x00003611, "Vault13Chronicles.esp") as Actor
        if Self.IsRunning() && confSceneLH != None && Self.GetStage() < 30 && !bOldTownCampTruce && !bLorenzoRescued && !bOldTownCampHostile
            if !confSceneLH.IsPlaying() && !Utility.IsInMenuMode() && captorAct != None && !captorAct.IsDead() && !captorAct.IsInCombat() && !captorAct.IsInDialogueWithPlayer() && !captorAct.IsTalking()
                ForceQuestAlias(13, 0x00003611)
                captorAct.AllowPCDialogue(True)
                confSceneLH.Start()
            endif
        endif
    elseif aiTimerID == 94
        Scene introScene94 = Game.GetFormFromFile(0x000D1100, "Vault13Chronicles.esp") as Scene
        Actor kyleAct94 = Game.GetFormFromFile(0x00002B33, "Vault13Chronicles.esp") as Actor
        if (introScene94 != None && introScene94.IsPlaying()) || Utility.IsInMenuMode() || (kyleAct94 != None && (kyleAct94.IsInDialogueWithPlayer() || kyleAct94.IsTalking()))
            StartTimer(3.0, 94)
        elseif Self.GetStage() < 20
            Self.SetStage(20)
        endif
    elseif aiTimerID == 96
        bShackApproachCooldown = False
    elseif aiTimerID == 98
        Scene confStopLHT = Game.GetFormFromFile(0x000D7400, "Vault13Chronicles.esp") as Scene
        if confStopLHT != None && confStopLHT.IsPlaying()
            confStopLHT.Stop()
        endif
        TriggerOldTownCampHostile()
    elseif aiTimerID == 99
        SetupLostHillsPAListeners(True)
    endif
EndEvent

Event OnStageSet(int auiStageID, int auiItemID)
    SetupLostHillsPAListeners()
    if auiStageID == 11
        if Self.GetStage() < 12 && !Self.IsCompleted()
            ForceQuestAlias(0, 0x00002B33)
            if !IsObjectiveDisplayed(11)
                SetObjectiveDisplayed(11, True, False)
            endif
            Self.SetActive(True)
        endif
    elseif auiStageID == 12
        if IsObjectiveDisplayed(11)
            SetObjectiveCompleted(11, True)
            SetObjectiveDisplayed(11, False, False)
        endif
        ForceQuestAlias(0, 0x00002B33)
        if !IsObjectiveDisplayed(12)
            SetObjectiveDisplayed(12, True, False)
        endif
        Self.SetActive(True)
    elseif auiStageID == 16 || auiStageID == 17 || auiStageID == 18
        if IsObjectiveDisplayed(11)
            SetObjectiveCompleted(11, True)
            SetObjectiveDisplayed(11, False, False)
        endif
        if IsObjectiveDisplayed(12)
            SetObjectiveCompleted(12, True)
            SetObjectiveDisplayed(12, False, False)
        endif
        if !bOldTownCampTruce
            bOldTownCampTruce = True
            Actor playerLH = Game.GetPlayer()
            if auiStageID == 18
                Form capsLH = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
                if capsLH != None && playerLH != None && playerLH.GetItemCount(capsLH) >= 250
                    playerLH.RemoveItem(capsLH, 250, False)
                endif
            endif
            Form shackKeyLH = Game.GetFormFromFile(0x00001513, "Vault13Chronicles.esp")
            ObjectReference shackDoorLH = Game.GetFormFromFile(0x00003615, "Vault13Chronicles.esp") as ObjectReference
            Actor captor1LH = Game.GetFormFromFile(0x00003611, "Vault13Chronicles.esp") as Actor
            if shackKeyLH != None && captor1LH != None && captor1LH.GetItemCount(shackKeyLH) > 0
                captor1LH.RemoveItem(shackKeyLH, captor1LH.GetItemCount(shackKeyLH), True)
            endif
            if shackKeyLH != None && playerLH != None && playerLH.GetItemCount(shackKeyLH) == 0
                playerLH.AddItem(shackKeyLH, 1, False)
            endif
            if shackDoorLH != None
                shackDoorLH.BlockActivation(False, False)
                shackDoorLH.Lock(False, False)
                shackDoorLH.SetOpen(True)
            endif
            SanitizeOldTownCampPeace()
            RefreshLorenzoShackDoorGuard()
            if !IsObjectiveDisplayed(21) && !bLorenzoRescued
                SetObjectiveDisplayed(21, True, False)
            endif
            if auiStageID == 16
                Debug.Notification("[Brotherhood Authority] The loan sharks back down before the Brotherhood, hand over the key, and unlock Lorenzo's shack.")
            elseif auiStageID == 17
                Debug.Notification("[Speech] Convinced of the risk, the mercenaries hand over the key and open Lorenzo's cell.")
            else
                Debug.Notification("[Debt Settled - 250 Caps] The captors take the caps, hand over the key, and unlock Lorenzo's door.")
            endif
        endif
    elseif auiStageID == 21
        if !bOldTownCampHostile
            StartTimer(0.25, 98)
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
        ObjectReference hubMk = Game.GetFormFromFile(0x0000341D, "Vault13Chronicles.esp") as ObjectReference
        if hubMk != None
            hubMk.EnableNoWait()
            if !hubMk.IsMapMarkerVisible()
                hubMk.AddToMap(False)
            endif
        endif
        if !IsObjectiveDisplayed(20)
            SetObjectiveDisplayed(20, True, False)
        endif
        if !IsObjectiveDisplayed(21)
            SetObjectiveDisplayed(21, True, False)
        endif
        Self.SetActive(True)
        if !bStg20Notified
            bStg20Notified = True
            Debug.Notification("Side Quest: Lost Hills Honor of Steel - Obtain a Systolic Motivator (Level 1) or rescue Initiate Lorenzo in Old Town (The Hub) to earn a T-51b.")
        endif
    elseif auiStageID == 22
        if IsObjectiveDisplayed(11)
            SetObjectiveCompleted(11, True)
            SetObjectiveDisplayed(11, False, False)
        endif
        if IsObjectiveDisplayed(12)
            SetObjectiveCompleted(12, True)
            SetObjectiveDisplayed(12, False, False)
        endif
        if IsObjectiveDisplayed(20)
            SetObjectiveDisplayed(20, False, False)
        endif
        ObjectReference hubMk22 = Game.GetFormFromFile(0x0000341D, "Vault13Chronicles.esp") as ObjectReference
        if hubMk22 != None
            hubMk22.EnableNoWait()
            if !hubMk22.IsMapMarkerVisible()
                hubMk22.AddToMap(False)
            endif
        endif
        if !IsObjectiveDisplayed(21)
            SetObjectiveDisplayed(21, True, False)
            Self.SetActive(True)
        endif
        ForceAllLostHillsPAAliases()
        if !bStg22Notified
            bStg22Notified = True
            Debug.Notification("Side Quest: Honor of Steel - Head to Old Town (The Hub) to rescue Initiate Lorenzo and earn your T-51b Power Armor.")
        endif
    elseif auiStageID == 25
        SetObjectiveCompleted(20, True)
        if IsObjectiveDisplayed(21)
            SetObjectiveDisplayed(21, False, False)
        endif
        if !IsObjectiveDisplayed(25)
            SetObjectiveDisplayed(25, True, False)
        endif
        ForceAllLostHillsPAAliases()
        Self.SetActive(True)
        if !bStg25Notified
            bStg25Notified = True
            Debug.Notification("T-51b Systolic Motivator obtained. Install it with Knight Kyle at the Level 2 Power Armor workshop.")
        endif
    elseif auiStageID == 30
        RefreshLorenzoShackDoorGuard()
        SetObjectiveCompleted(21, True)
        if IsObjectiveDisplayed(20)
            SetObjectiveDisplayed(20, False, False)
        endif
        if !IsObjectiveDisplayed(30)
            SetObjectiveDisplayed(30, True, False)
        endif
        ForceAllLostHillsPAAliases()
        Self.SetActive(True)
        if !bStg30Notified
            bStg30Notified = True
            Debug.Notification("Initiate Lorenzo safe! Report to Knight Kyle or Rhombus on Level 2 of Lost Hills.")
        endif
    elseif auiStageID == 40
        RefreshLorenzoShackDoorGuard()
        if !bRewardGranted
            CompletePowerArmorUnlock(bLorenzoRescued)
        endif
        SyncPowerArmorFrameLock()
        SetObjectiveCompleted(20, True)
        SetObjectiveCompleted(21, True)
        if IsObjectiveDisplayed(25)
            SetObjectiveCompleted(25, True)
        endif
        if IsObjectiveDisplayed(30)
            SetObjectiveCompleted(30, True)
        endif
        CompleteAllObjectives()
        Self.CompleteQuest()
    endif
EndEvent
