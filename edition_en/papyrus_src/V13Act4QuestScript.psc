Scriptname V13Act4QuestScript extends Quest

int hitCounter = 0
bool introShown = false
bool rewardsGiven = false
bool bStage30Done = false
bool bStage40Rewarded = false
bool bApplyingAct4Stage = false
bool bMariposaDisguiseBlown = false
bool bSecurityGridOffline = false
bool bCaptiveFreed = false
bool bLouConfronted = false
bool bPaladinsDeployed = false
bool bCountdownActive = false
bool bMariposaCollapsed = false
int iCountdownSecondsLeft = 0
int sceneWaitTicks = 0
int lastAppliedAct4Stage = 0
bool bLouScaledV2 = false
bool bMariposaCinematicActive = false
int iMariposaCinePhase = 0
InputEnableLayer kMariposaCineLayer
int iMariposaSirenInstance = -1
int iMariposaReadyTicks = 0

Function ForceQuestAlias(int aiAliasID, int aiFormID)
    ObjectReference targetRef = Game.GetFormFromFile(aiFormID, "Vault13Chronicles.esp") as ObjectReference
    ReferenceAlias al = Self.GetAlias(aiAliasID) as ReferenceAlias
    if al != None && targetRef != None
        if al.GetReference() != targetRef
            al.ForceRefTo(targetRef)
        endif
    endif
EndFunction

bool Function IsPlayerDisguisedAsCathedral()
    if bMariposaDisguiseBlown
        return false
    endif
    Actor player = Game.GetPlayer()
    Form purpleRobe = Game.GetFormFromFile(0x00001330, "Vault13Chronicles.esp")
    if player != None && purpleRobe != None && player.IsEquipped(purpleRobe)
        return true
    endif
    return false
EndFunction

Function SyncMariposaMutantHostilityAndGear()
    Faction smFac = Game.GetFormFromFile(0x00058305, "Fallout4.esm") as Faction
    Faction playerFac = Game.GetFormFromFile(0x0001C21C, "Fallout4.esm") as Faction
    Faction raiderFac = Game.GetFormFromFile(0x0001CBED, "Fallout4.esm") as Faction
    Cell mariposaCell = Game.GetFormFromFile(0x00002C00, "Vault13Chronicles.esp") as Cell
    Cell wshCell = Game.GetFormFromFile(0x00002900, "Vault13Chronicles.esp") as Cell
    Actor player = Game.GetPlayer()
    if smFac != None && playerFac != None && player != None
        if mariposaCell != None && player.GetParentCell() == mariposaCell && IsPlayerDisguisedAsCathedral()
            smFac.SetEnemy(playerFac, true, true)
        elseif wshCell == None || player.GetParentCell() != wshCell
            smFac.SetEnemy(playerFac, false, false)
        endif
    endif
    Actor techAct = Game.GetFormFromFile(0x00002C35, "Vault13Chronicles.esp") as Actor
    if techAct != None && !techAct.IsDead()
        if raiderFac != None && techAct.IsInFaction(raiderFac)
            techAct.RemoveFromFaction(raiderFac)
        endif
        if playerFac != None && techAct.IsInFaction(playerFac)
            techAct.RemoveFromFaction(playerFac)
        endif
        if smFac != None && !techAct.IsInFaction(smFac)
            techAct.AddToFaction(smFac)
        endif
        if techAct.IsInCombat() && techAct.GetCombatTarget() != player
            techAct.StopCombat()
            techAct.StopCombatAlarm()
            techAct.EvaluatePackage()
        endif
    endif
    Weapon wMinigun = Game.GetFormFromFile(0x0001F669, "Fallout4.esm") as Weapon
    Ammo a5mm = Game.GetFormFromFile(0x0001F66C, "Fallout4.esm") as Ammo
    Actor louAct = Game.GetFormFromFile(0x00002C11, "Vault13Chronicles.esp") as Actor
    if louAct != None
        if louAct.IsDisabled()
            louAct.EnableNoWait()
        endif
        if raiderFac != None && louAct.IsInFaction(raiderFac)
            louAct.RemoveFromFaction(raiderFac)
        endif
        if smFac != None && !louAct.IsInFaction(smFac)
            louAct.AddToFaction(smFac)
        endif
        if !bLouScaledV2 && louAct.Is3DLoaded()
            louAct.SetScale(1.18)
            bLouScaledV2 = true
        endif
        if !louAct.IsDead() && louAct.Is3DLoaded()
            if wMinigun != None && louAct.GetItemCount(wMinigun) < 1
                louAct.AddItem(wMinigun, 1, true)
            endif
            if a5mm != None && louAct.GetItemCount(a5mm) < 100
                louAct.AddItem(a5mm, 300, true)
            endif
            if wMinigun != None && !louAct.IsEquipped(wMinigun)
                louAct.EquipItem(wMinigun, false, true)
            endif
        endif
        if !louAct.IsDead() && !louAct.IsInCombat() && (louAct.GetPositionZ() < -100.0 || louAct.GetPositionZ() > 500.0)
            louAct.SetPosition(-2480.0, -1780.0, 128.0)
        endif
        if IsPlayerDisguisedAsCathedral() && louAct.IsInCombat()
            louAct.StopCombat()
        elseif !louAct.IsDead()
            louAct.SetValue(Game.GetAggressionAV(), 1.0)
        endif
    endif
    EffectShader fxSD = Game.GetFormFromFile(0x00102B7E, "Fallout4.esm") as EffectShader
    int[] nkFids = new int[7]
    nkFids[0] = 0x00002C12
    nkFids[1] = 0x00002C20
    nkFids[2] = 0x00002C21
    nkFids[3] = 0x00002C22
    nkFids[4] = 0x0000372A
    nkFids[5] = 0x0000372B
    nkFids[6] = 0x0000358D
    int idx = 0
    while idx < 7
        Actor nk = Game.GetFormFromFile(nkFids[idx], "Vault13Chronicles.esp") as Actor
        if nk != None
            if idx < 4 && nk.IsDisabled()
                nk.EnableNoWait()
            endif
            if raiderFac != None && nk.IsInFaction(raiderFac)
                nk.RemoveFromFaction(raiderFac)
            endif
            if smFac != None && !nk.IsInFaction(smFac)
                nk.AddToFaction(smFac)
            endif
            if !nk.IsDead()
                nk.SetValue(Game.GetAggressionAV(), 1.0)
                if techAct != None && nk.IsInCombat() && nk.GetCombatTarget() == techAct
                    nk.StopCombat()
                    nk.StopCombatAlarm()
                endif
            endif
            if fxSD != None
                fxSD.Stop(nk)
            endif
            if !nk.IsDead() && wMinigun != None
                if nk.GetItemCount(wMinigun) == 0
                    nk.AddItem(wMinigun, 1, true)
                endif
                if a5mm != None && nk.GetItemCount(a5mm) < 100
                    nk.AddItem(a5mm, 250, true)
                endif
                if !nk.IsEquipped(wMinigun)
                    nk.EquipItem(wMinigun, false, true)
                endif
            endif
        endif
        idx += 1
    endwhile
EndFunction

Function EquipMariposaPaladinsArmor()
    Outfit palOtft = Game.GetFormFromFile(0x00001040, "Vault13Chronicles.esp") as Outfit
    Form bosUnder = Game.GetFormFromFile(0x000DEDEB, "Fallout4.esm")
    Form combatTorso = Game.GetFormFromFile(0x0011D3C3, "Fallout4.esm")
    Form combatLArm = Game.GetFormFromFile(0x0011D3C7, "Fallout4.esm")
    Form combatRArm = Game.GetFormFromFile(0x0011D3C6, "Fallout4.esm")
    Form combatLLeg = Game.GetFormFromFile(0x0011D3C5, "Fallout4.esm")
    Form combatRLeg = Game.GetFormFromFile(0x0011D3C4, "Fallout4.esm")
    Form combatHelm = Game.GetFormFromFile(0x0011E2C8, "Fallout4.esm")
    Form[] armorPieces = new Form[7]
    armorPieces[0] = bosUnder
    armorPieces[1] = combatTorso
    armorPieces[2] = combatLArm
    armorPieces[3] = combatRArm
    armorPieces[4] = combatLLeg
    armorPieces[5] = combatRLeg
    armorPieces[6] = combatHelm
    int pIdx = 0
    while pIdx < 2
        Actor pal = Game.GetFormFromFile(0x00002C36 + pIdx, "Vault13Chronicles.esp") as Actor
        if pal != None && !pal.IsDead() && !pal.IsDisabled() && pal.Is3DLoaded()
            if palOtft != None
                pal.SetOutfit(palOtft)
            endif
            if combatTorso != None && !pal.IsEquipped(combatTorso)
                int aIdx = 0
                while aIdx < 7
                    Form piece = armorPieces[aIdx]
                    if piece != None
                        if pal.GetItemCount(piece) == 0
                            pal.AddItem(piece, 1, true)
                        endif
                        if !pal.IsEquipped(piece)
                            pal.EquipItem(piece, false, true)
                        endif
                    endif
                    aIdx += 1
                endwhile
            endif
        endif
        pIdx += 1
    endwhile
EndFunction

Function EnsurePaladinsPositioned()
    Actor pal1 = Game.GetFormFromFile(0x00002C36, "Vault13Chronicles.esp") as Actor
    Actor pal2 = Game.GetFormFromFile(0x00002C37, "Vault13Chronicles.esp") as Actor
    if pal1 != None && !pal1.IsDead() && pal1.Is3DLoaded() && pal1.GetPositionY() < -220.0
        pal1.SetPosition(640.0, -120.0, 128.0)
        pal1.SetAngle(0.0, 0.0, 270.0)
    endif
    if pal2 != None && !pal2.IsDead() && pal2.Is3DLoaded() && pal2.GetPositionY() < -220.0
        pal2.SetPosition(560.0, 20.0, 128.0)
        pal2.SetAngle(0.0, 0.0, 270.0)
    endif
    EquipMariposaPaladinsArmor()
EndFunction

Function BlowCathedralDisguise()
    if !bMariposaDisguiseBlown
        bMariposaDisguiseBlown = true
        Debug.Notification("[Mariposa Military Base] Intrusion alarm! The Lieutenant and his Nightkin have uncovered your identity!")
        SyncMariposaMutantHostilityAndGear()
        Actor lou = Game.GetFormFromFile(0x00002C11, "Vault13Chronicles.esp") as Actor
        Actor player = Game.GetPlayer()
        if lou != None && !lou.IsDead() && player != None
            lou.SetValue(Game.GetAggressionAV(), 2.0)
            lou.StartCombat(player)
        endif
        int idx = 0
        while idx < 4
            int nFid = 0x00002C20 + idx
            if idx == 3
                nFid = 0x00002C12
            endif
            Actor nk = Game.GetFormFromFile(nFid, "Vault13Chronicles.esp") as Actor
            if nk != None && !nk.IsDead() && player != None
                nk.SetValue(Game.GetAggressionAV(), 2.0)
                nk.StartCombat(player)
            endif
            idx += 1
        endwhile
    endif
EndFunction

Function DeactivateMariposaSecurityGrid()
    bSecurityGridOffline = true
    ObjectReference ff1 = Game.GetFormFromFile(0x00002C40, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference ff2 = Game.GetFormFromFile(0x00002C42, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference ff3 = Game.GetFormFromFile(0x00002C44, "Vault13Chronicles.esp") as ObjectReference
    if ff1 != None
        ff1.DisableNoWait()
    endif
    if ff2 != None
        ff2.DisableNoWait()
    endif
    if ff3 != None
        ff3.DisableNoWait()
    endif
    Actor tur1 = Game.GetFormFromFile(0x00002C25, "Vault13Chronicles.esp") as Actor
    Actor tur2 = Game.GetFormFromFile(0x00002C26, "Vault13Chronicles.esp") as Actor
    if tur1 != None && !tur1.IsDead()
        tur1.DisableNoWait()
    endif
    if tur2 != None && !tur2.IsDead()
        tur2.DisableNoWait()
    endif
EndFunction

Function HandleForcefieldEmitterActivate(ObjectReference akEmitter)
    if akEmitter == None
        return
    endif
    ObjectReference em1 = Game.GetFormFromFile(0x00002C41, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference em2 = Game.GetFormFromFile(0x00002C43, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference em3 = Game.GetFormFromFile(0x00002C45, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference targetFF = None
    if akEmitter == em1
        targetFF = Game.GetFormFromFile(0x00002C40, "Vault13Chronicles.esp") as ObjectReference
    elseif akEmitter == em2
        targetFF = Game.GetFormFromFile(0x00002C42, "Vault13Chronicles.esp") as ObjectReference
    elseif akEmitter == em3
        targetFF = Game.GetFormFromFile(0x00002C44, "Vault13Chronicles.esp") as ObjectReference
    endif
    if targetFF == None
        return
    endif
    if targetFF.IsDisabled()
        targetFF.EnableNoWait()
        Debug.Notification("[Mariposa Emitter] Force field reactivated.")
        return
    endif
    Message ffMenu = Game.GetFormFromFile(0x00001C96, "Vault13Chronicles.esp") as Message
    if ffMenu == None
        targetFF.DisableNoWait()
        return
    endif
    Actor player = Game.GetPlayer()
    int choice = ffMenu.Show()
    if choice == 0
        ; [Reparar / Sobrecarga de Bobina]
        Form fusionCell = Game.GetFormFromFile(0x000C1897, "Fallout4.esm")
        ActorValue intAV = Game.GetFormFromFile(0x000002C6, "Fallout4.esm") as ActorValue
        bool canRepair = (intAV != None && player.GetValue(intAV) >= 5.0) || (fusionCell != None && player.GetItemCount(fusionCell) > 0)
        if canRepair
            if fusionCell != None && player.GetItemCount(fusionCell) > 0
                player.RemoveItem(fusionCell, 1, true, None)
            endif
            targetFF.DisableNoWait()
            Game.RewardPlayerXP(75, false)
            Debug.Notification("[Repair] Emitter coil bypassed! Force field disabled (+75 XP).")
        else
            Debug.Notification("[Emitter] You need at least 1 Fusion Cell or Intelligence 5+ to bypass the force field emitter.")
        endif
    elseif choice == 1
        ; [Ciencia / Desfase Armónico]
        ActorValue intAV2 = Game.GetFormFromFile(0x000002C6, "Fallout4.esm") as ActorValue
        Form greyHolo = Game.GetFormFromFile(0x00001565, "Vault13Chronicles.esp")
        if bSecurityGridOffline || (greyHolo != None && player.GetItemCount(greyHolo) > 0) || (intAV2 != None && player.GetValue(intAV2) >= 6.0)
            targetFF.DisableNoWait()
            Game.RewardPlayerXP(75, false)
            Debug.Notification("[Science] Harmonic frequency inverted! Force field neutralized (+75 XP).")
        else
            Debug.Notification("[Science] Encrypted access code required (Intelligence 6+ or the Research Level Security Terminal).")
        endif
    elseif choice == 2
        ; [Explosivos]
        Form fragGrenade = Game.GetFormFromFile(0x000EEBED, "Fallout4.esm")
        if fragGrenade != None && player.GetItemCount(fragGrenade) > 0
            player.RemoveItem(fragGrenade, 1, true, None)
            targetFF.DisableNoWait()
            Game.ShakeCamera(player, 0.45, 1.0)
            BlowCathedralDisguise()
            Game.RewardPlayerXP(100, false)
            Debug.Notification("[Explosives] Force field emitter demolished with explosive charge! (+100 XP)")
        else
            Debug.Notification("[Explosives] You need a Fragmentation Grenade to blow up the armored emitter.")
        endif
    elseif choice == 3
        ; [Radio de Patrulla de la Unidad]
        Form unityRadio = Game.GetFormFromFile(0x00001564, "Vault13Chronicles.esp")
        if unityRadio != None && player.GetItemCount(unityRadio) > 0
            targetFF.DisableNoWait()
            Game.RewardPlayerXP(100, false)
            Debug.Notification("[Unity Radio] Patrol sub-channel accepted: force field opened silently (+100 XP).")
        else
            Debug.Notification("[Radio] You do not carry a Unity Mutant Patrol Radio Transceiver.")
        endif
    endif
EndFunction

Function ArmMariposaSelfDestructCountdown()
    if bCountdownActive || bMariposaCollapsed
        return
    endif
    bCountdownActive = true
    iCountdownSecondsLeft = 180
    BlowCathedralDisguise()
    Game.ShakeCamera(Game.GetPlayer(), 0.55, 1.8)
    StartTimer(5.0, 77)
EndFunction

Function CleanupMariposaCinematicSafety()
    CancelTimer(90)
    if iMariposaSirenInstance >= 0
        Sound.StopInstance(iMariposaSirenInstance)
        iMariposaSirenInstance = -1
    endif
    Actor player = Game.GetPlayer()
    if player != None
        player.SetGhost(false)
        player.SetAlpha(1.0, false)
    endif
    Game.ShowFirstPersonGeometry(true)
    if kMariposaCineLayer != None
        kMariposaCineLayer.EnablePlayerControls()
        kMariposaCineLayer.Delete()
        kMariposaCineLayer = None
    endif
    bMariposaCinematicActive = false
    iMariposaCinePhase = 0
    iMariposaReadyTicks = 0
EndFunction

Function TriggerMariposaDestructionFinale()
    if bMariposaCollapsed
        return
    endif
    bMariposaCollapsed = true
    bCountdownActive = false
    CancelTimer(77)
    ObjectReference surfDoor = Game.GetFormFromFile(0x00003508, "Vault13Chronicles.esp") as ObjectReference
    if surfDoor != None
        surfDoor.Lock(true, false)
        surfDoor.SetLockLevel(255)
    endif
    Actor player = Game.GetPlayer()
    WorldSpace ws2161 = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    ObjectReference overlookCam = Game.GetFormFromFile(0x00009940, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference blastAnchor = Game.GetFormFromFile(0x00009941, "Vault13Chronicles.esp") as ObjectReference
    if player != None && !bMariposaCinematicActive && overlookCam != None && blastAnchor != None && ws2161 != None && player.GetWorldSpace() == ws2161
        bMariposaCinematicActive = true
        iMariposaCinePhase = 0
        iMariposaReadyTicks = 0
        StartTimer(0.45, 90)
        return
    endif
    ObjectReference fireA = Game.GetFormFromFile(0x00009942, "Vault13Chronicles.esp") as ObjectReference
    if fireA != None
        fireA.Enable(false)
    endif
    ObjectReference fireB = Game.GetFormFromFile(0x00009943, "Vault13Chronicles.esp") as ObjectReference
    if fireB != None
        fireB.Enable(false)
    endif
    if player != None
        Game.ShakeCamera(player, 0.9, 3.0)
    endif
    Game.RewardPlayerXP(500, false)
    Debug.Notification("[Mariposa Military Base] BOOM! The FEV Vats have collapsed beneath tons of rubble! (+500 XP)")
EndFunction

Function CheckDeployBrotherhoodPaladins()
    Quest q3 = Game.GetFormFromFile(0x00006002, "Vault13Chronicles.esp") as Quest
    V13Act3QuestScript act3S = q3 as V13Act3QuestScript
    if act3S != None && act3S.AreMariposaPaladinsAuthorized()
        Actor pal1 = Game.GetFormFromFile(0x00002C36, "Vault13Chronicles.esp") as Actor
        Actor pal2 = Game.GetFormFromFile(0x00002C37, "Vault13Chronicles.esp") as Actor
        if pal1 != None && pal1.IsDisabled()
            pal1.EnableNoWait()
            pal1.EvaluatePackage()
        endif
        if pal2 != None && pal2.IsDisabled()
            pal2.EnableNoWait()
            pal2.EvaluatePackage()
        endif
        EnsurePaladinsPositioned()
        if !bPaladinsDeployed
            bPaladinsDeployed = true
            Cell mariposaCell = Game.GetFormFromFile(0x00002C00, "Vault13Chronicles.esp") as Cell
            Actor player = Game.GetPlayer()
            if player != None && mariposaCell != None && player.GetParentCell() == mariposaCell
                Debug.Notification("[Brotherhood of Steel] Paladin Assault Squad deployed at Mariposa on Elder Maxson's orders!")
            endif
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
    ObjectReference captiveRef = Game.GetFormFromFile(0x00002C34, "Vault13Chronicles.esp") as ObjectReference
    if captiveRef != None
        RegisterForRemoteEvent(captiveRef, "OnActivate")
    endif
    ObjectReference louRef = Game.GetFormFromFile(0x00002C11, "Vault13Chronicles.esp") as ObjectReference
    if louRef != None
        RegisterForRemoteEvent(louRef, "OnActivate")
    endif
    ObjectReference pal1Ref = Game.GetFormFromFile(0x00002C36, "Vault13Chronicles.esp") as ObjectReference
    if pal1Ref != None
        RegisterForRemoteEvent(pal1Ref, "OnActivate")
    endif
    ObjectReference pal2Ref = Game.GetFormFromFile(0x00002C37, "Vault13Chronicles.esp") as ObjectReference
    if pal2Ref != None
        RegisterForRemoteEvent(pal2Ref, "OnActivate")
    endif
    Actor techAct = Game.GetFormFromFile(0x00002C35, "Vault13Chronicles.esp") as Actor
    if techAct != None
        RegisterForHitEvent(techAct)
    endif
EndFunction

Event OnHit(ObjectReference akTarget, ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked, string apMaterial)
    if akAggressor == Game.GetPlayer()
        BlowCathedralDisguise()
    endif
    Actor hitAct = akTarget as Actor
    if hitAct != None && !hitAct.IsDead()
        RegisterForHitEvent(hitAct)
    endif
EndEvent

Event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
    if akActionRef != Game.GetPlayer()
        return
    endif
    ObjectReference captiveRef = Game.GetFormFromFile(0x00002C34, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference louRef = Game.GetFormFromFile(0x00002C11, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference pal1Ref = Game.GetFormFromFile(0x00002C36, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference pal2Ref = Game.GetFormFromFile(0x00002C37, "Vault13Chronicles.esp") as ObjectReference
    if akSender == captiveRef
        Actor capAct = captiveRef as Actor
        if capAct != None && !capAct.IsDead()
            ObjectReference detFF = Game.GetFormFromFile(0x00002C44, "Vault13Chronicles.esp") as ObjectReference
            if detFF != None && !detFF.IsDisabled()
                detFF.DisableNoWait()
            endif
            if !bCaptiveFreed
                bCaptiveFreed = true
                Game.RewardPlayerXP(250, false)
                Debug.Notification("[Mariposa] Caravan prisoner rescued from the dipping chambers! (+250 XP)")
            endif
            ForceAllAct4Aliases()
            sceneWaitTicks = 0
            StartTimer(1.2, 78)
        endif
    elseif akSender == louRef
        Actor louAct = louRef as Actor
        if louAct != None && !louAct.IsDead() && !louAct.IsInCombat()
            bLouConfronted = true
            ForceAllAct4Aliases()
            sceneWaitTicks = 0
            StartTimer(1.2, 79)
        endif
    elseif akSender == pal1Ref || akSender == pal2Ref
        Actor palAct = akSender as Actor
        if palAct != None && !palAct.IsDead()
            Debug.Notification("[Assault Paladin]: 'Breach secured by order of Maxson! Push toward the FEV Vats - we have your flank.'")
            palAct.EvaluatePackage()
        endif
    endif
EndEvent

Function BeginLieutenantBossFight()
    bLouConfronted = true
    BlowCathedralDisguise()
EndFunction

bool Function CanSabotageMariposaVats()
    Actor lou = Game.GetFormFromFile(0x00002C11, "Vault13Chronicles.esp") as Actor
    if lou == None || lou.IsDead()
        return true
    endif
    if IsPlayerDisguisedAsCathedral() && !bMariposaDisguiseBlown
        return true
    endif
    return false
EndFunction

Function EnforceLieutenantBeforeSabotage()
    BeginLieutenantBossFight()
    Actor lou = Game.GetFormFromFile(0x00002C11, "Vault13Chronicles.esp") as Actor
    Actor player = Game.GetPlayer()
    if lou != None && !lou.IsDead()
        if lou.IsDisabled()
            lou.EnableNoWait()
        endif
        if player != None
            if lou.GetDistance(player) > 1500.0
                lou.SetPosition(-1950.0, -1620.0, 128.0)
            endif
            lou.SetValue(Game.GetAggressionAV(), 2.0)
            lou.StartCombat(player)
        endif
    endif
    ForceAllAct4Aliases()
    Debug.Notification("[Mariposa] The Lieutenant ('Lou') guards the Vat controls! Defeat him first or infiltrate wearing a Cathedral Robe.")
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

    if abEnabled && Self.GetStage() < 30 && !bMariposaCollapsed
        ObjectReference swDoor1 = Game.GetFormFromFile(0x00070225, "Vault13Chronicles.esp") as ObjectReference
        if swDoor1 != None && !swDoor1.IsDisabled()
            swDoor1.DisableNoWait()
        endif
        ObjectReference swDoor2 = Game.GetFormFromFile(0x00070226, "Vault13Chronicles.esp") as ObjectReference
        if swDoor2 != None && !swDoor2.IsDisabled()
            swDoor2.DisableNoWait()
        endif
        Actor playerRef = Game.GetPlayer()
        Cell mariposaCellRef = Game.GetFormFromFile(0x00002C00, "Vault13Chronicles.esp") as Cell
        if playerRef != None && mariposaCellRef != None && playerRef.GetParentCell() == mariposaCellRef && playerRef.GetPositionY() < -360.0 && playerRef.GetPositionX() > 700.0
            playerRef.SetPosition(848.0, -256.0, 128.0)
        endif
        if d2C01 != None
            d2C01.EnableNoWait()
            d2C01.Lock(false, false)
        endif
        if d2C03 != None
            d2C03.EnableNoWait()
            d2C03.Lock(false, false)
        endif
        if ltChest != None
            ltChest.EnableNoWait()
        endif
        if termMariposa != None
            termMariposa.EnableNoWait()
        endif
        if lieutenant != None
            if lieutenant.IsDisabled()
                lieutenant.EnableNoWait()
            endif
            if !lieutenant.IsDead()
                if winchesterP94 != None
                    if lieutenant.GetItemCount(winchesterP94) > 1
                        lieutenant.RemoveItem(winchesterP94, lieutenant.GetItemCount(winchesterP94) - 1, true, None)
                    elseif lieutenant.GetItemCount(winchesterP94) == 0
                        lieutenant.AddItem(winchesterP94, 1, true)
                    endif
                endif
                Weapon wGatLaser = Game.GetFormFromFile(0x000E27BC, "Fallout4.esm") as Weapon
                Ammo aFCore = Game.GetFormFromFile(0x00075FE4, "Fallout4.esm") as Ammo
                if wGatLaser != None
                    if lieutenant.GetItemCount(wGatLaser) == 0
                        lieutenant.AddItem(wGatLaser, 1, true)
                    endif
                    if aFCore != None && lieutenant.GetItemCount(aFCore) < 2
                        lieutenant.AddItem(aFCore, 4, true)
                    endif
                    if !lieutenant.IsEquipped(wGatLaser)
                        lieutenant.EquipItem(wGatLaser, false, true)
                    endif
                endif
            endif
        endif
        if g1 != None && g1.IsDisabled()
            g1.EnableNoWait()
        endif
        if g2 != None && g2.IsDisabled()
            g2.EnableNoWait()
        endif
        if g3 != None && g3.IsDisabled()
            g3.EnableNoWait()
        endif
        int cIdx = 2
        while cIdx < 7
            ObjectReference cExtra = Game.GetFormFromFile(0x00002C20 + cIdx, "Vault13Chronicles.esp") as ObjectReference
            if cExtra != None && cExtra.IsDisabled() && !bSecurityGridOffline
                cExtra.EnableNoWait()
            endif
            cIdx += 1
        endwhile
        SyncMariposaMutantHostilityAndGear()
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
    if CanSabotageMariposaVats()
        ForceQuestAlias(1, 0x00002C10)
    else
        ForceQuestAlias(1, 0x00002C11)
    endif
    ForceQuestAlias(2, 0x00003005)
    ForceQuestAlias(3, 0x00002003)
    ForceQuestAlias(4, 0x00003508)
    V13Act1QuestScript act1DoorS = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as V13Act1QuestScript
    if act1DoorS != None
        ForceQuestAlias(5, act1DoorS.GetEnabledVault13ExitDoorFid(0x00002144))
    else
        ForceQuestAlias(5, 0x00002144)
    endif
    ForceQuestAlias(6, 0x00003501)
    ForceQuestAlias(7, 0x00002C03)
    ForceQuestAlias(9, 0x00002C34)
    ForceQuestAlias(10, 0x00002C11)
EndFunction

Function ApplyV13Act4Stage(int auiStage)
    if bApplyingAct4Stage
        return
    endif
    bApplyingAct4Stage = true

    V13Act1QuestScript act1S = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as V13Act1QuestScript
    bool inDial = (act1S != None && act1S.IsJacorenInDialogueOrScene())

    if auiStage < 15
        ForceAllAct4Aliases()
        bApplyingAct4Stage = false
        return
    endif

    if !inDial
        SetMariposaState(true)
        CheckDeployBrotherhoodPaladins()
    elseif act1S != None
        act1S.SyncVault13ExpeditionDoors()
    endif
    ForceAllAct4Aliases()

    if auiStage >= 15 && !introShown
        introShown = true
    endif

    if auiStage == 15
        if !Self.IsObjectiveDisplayed(15)
            Self.SetObjectiveDisplayed(15, true, false)
            Self.SetActive(true)
        endif
    elseif auiStage >= 20 && auiStage < 30
        if Self.IsObjectiveDisplayed(15)
            Self.SetObjectiveCompleted(15, true)
            Self.SetObjectiveDisplayed(15, false, false)
        endif
        Actor player = Game.GetPlayer()
        WorldSpace ws2161 = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
        Cell mariposaCell = Game.GetFormFromFile(0x00002C00, "Vault13Chronicles.esp") as Cell
        bool inWastelandOrDungeon = (player != None && ((ws2161 != None && player.GetWorldSpace() == ws2161) || (mariposaCell != None && player.GetParentCell() == mariposaCell)))
        if mariposaCell != None && player != None && player.GetParentCell() == mariposaCell
            CheckDeployBrotherhoodPaladins()
        endif
        if inWastelandOrDungeon || Self.IsObjectiveCompleted(20)
            if !Self.IsObjectiveCompleted(20)
                Self.SetObjectiveCompleted(20, true)
            endif
            if Self.IsObjectiveDisplayed(20)
                Self.SetObjectiveDisplayed(20, false, false)
            endif
            if !Self.IsObjectiveDisplayed(21)
                Self.SetObjectiveDisplayed(21, true, false)
                Self.SetActive(true)
            endif
        else
            if Self.IsObjectiveDisplayed(20) && lastAppliedAct4Stage < 20
                Self.SetObjectiveDisplayed(20, false, false)
            endif
            if !Self.IsObjectiveDisplayed(20)
                Self.SetObjectiveDisplayed(20, true, false)
                Self.SetActive(true)
            endif
        endif
    elseif auiStage >= 30 && auiStage < 40
        if !bStage30Done
            bStage30Done = true
            if Self.IsObjectiveDisplayed(15)
                Self.SetObjectiveCompleted(15, true)
                Self.SetObjectiveDisplayed(15, false, false)
            endif
            if !Self.IsObjectiveCompleted(20)
                Self.SetObjectiveCompleted(20, true)
            endif
            if Self.IsObjectiveDisplayed(20)
                Self.SetObjectiveDisplayed(20, false, false)
            endif
            if !Self.IsObjectiveCompleted(21)
                Self.SetObjectiveCompleted(21, true)
            endif
            if Self.IsObjectiveDisplayed(21)
                Self.SetObjectiveDisplayed(21, false, false)
            endif
            Quest act5Check = Game.GetFormFromFile(0x00008000, "Vault13Chronicles.esp") as Quest
            if act5Check != None && act5Check.GetStage() >= 30
                lastAppliedAct4Stage = auiStage
                bApplyingAct4Stage = false
                Self.SetStage(40)
                return
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
        if Self.IsObjectiveDisplayed(15)
            Self.SetObjectiveCompleted(15, true)
            Self.SetObjectiveDisplayed(15, false, false)
        endif
        if !Self.IsObjectiveCompleted(20)
            Self.SetObjectiveCompleted(20, true)
        endif
        if Self.IsObjectiveDisplayed(20)
            Self.SetObjectiveDisplayed(20, false, false)
        endif
        if !Self.IsObjectiveCompleted(21)
            Self.SetObjectiveCompleted(21, true)
        endif
        if Self.IsObjectiveDisplayed(21)
            Self.SetObjectiveDisplayed(21, false, false)
        endif
        if !Self.IsObjectiveCompleted(30)
            Self.SetObjectiveCompleted(30, true)
        endif
        if !Self.IsCompleted()
            Self.CompleteAllObjectives()
            Self.CompleteQuest()
        endif
        Quest act5Quest = Game.GetFormFromFile(0x00008000, "Vault13Chronicles.esp") as Quest
        if act5Quest != None
            V13Act5QuestScript act5S = act5Quest as V13Act5QuestScript
            if act5Quest.GetStage() >= 30
                if act5S != None
                    act5S.CheckTriggerExileEpilogue()
                endif
            else
                if !act5Quest.IsRunning()
                    act5Quest.Start()
                endif
                if act5Quest.GetStage() < 20
                    act5Quest.SetStage(20)
                endif
                if act5S != None
                    act5S.WakeUpAct5()
                endif
            endif
        endif
    endif
    lastAppliedAct4Stage = auiStage
    bApplyingAct4Stage = false
EndFunction

Function WakeUpAct4()
    Quest act3Gate = Game.GetFormFromFile(0x00006002, "Vault13Chronicles.esp") as Quest
    if act3Gate == None || (!act3Gate.IsCompleted() && act3Gate.GetStage() < 40 && !act3Gate.IsStageDone(40))
        return
    endif
    if (Self.IsCompleted() || Self.IsStageDone(40)) && (rewardsGiven || bStage40Rewarded)
        bStage40Rewarded = true
        rewardsGiven = true
        if !Self.IsCompleted()
            Self.CompleteAllObjectives()
            Self.CompleteQuest()
        endif
        return
    endif
    if Self.IsCompleted() && rewardsGiven
        return
    endif
    if !Self.IsRunning()
        Self.Start()
    endif
    RegisterPlayerEvents()
    if Self.GetStage() < 15 && !Self.IsStageDone(40)
        Self.SetStage(15)
    elseif Self.IsStageDone(40) || bStage40Rewarded
        ApplyV13Act4Stage(40)
    else
        ApplyV13Act4Stage(Self.GetStage())
    endif
    StartTimer(0.5, 1)
EndFunction

Function CheckProgressionAndLevelGate()
    RegisterPlayerEvents()
    Quest act3Quest = Game.GetFormFromFile(0x00006002, "Vault13Chronicles.esp") as Quest
    int curStg = Self.GetStage()
    if Self.IsCompleted() || Self.IsStageDone(40) || bStage40Rewarded
        curStg = 40
    endif
    if act3Quest == None || (!act3Quest.IsCompleted() && act3Quest.GetStage() < 40 && !act3Quest.IsStageDone(40))
        if curStg >= 15 && curStg < 30 && !Self.IsCompleted() && !Self.IsStageDone(40)
            introShown = false
            Self.SetObjectiveDisplayed(15, false, false)
            Self.SetObjectiveDisplayed(20, false, false)
            Self.SetObjectiveDisplayed(21, false, false)
            Self.Reset()
            Self.Stop()
        endif
        return
    endif
    if curStg < 15
        if !Self.IsRunning()
            Self.Start()
        endif
        Self.SetStage(15)
        return
    endif
    Actor player = Game.GetPlayer()
    Cell mariposaCell = Game.GetFormFromFile(0x00002C00, "Vault13Chronicles.esp") as Cell
    if player != None && mariposaCell != None && player.GetParentCell() == mariposaCell
        CheckDeployBrotherhoodPaladins()
        EnsurePaladinsPositioned()
        SyncMariposaMutantHostilityAndGear()
        Actor lou = Game.GetFormFromFile(0x00002C11, "Vault13Chronicles.esp") as Actor
        if lou != None && !lou.IsDead()
            if IsPlayerDisguisedAsCathedral() && !bLouConfronted
                lou.SetValue(Game.GetAggressionAV(), 0.0)
                if lou.IsInCombat()
                    lou.StopCombat()
                endif
                if lou.GetDistance(player) <= 440.0 && !Utility.IsInMenuMode()
                    bLouConfronted = true
                    ForceAllAct4Aliases()
                    sceneWaitTicks = 0
                    StartTimer(0.25, 79)
                endif
            endif
        endif
    endif
    if curStg >= 15 && (curStg < 40 || !rewardsGiven || !Self.IsCompleted())
        ApplyV13Act4Stage(curStg)
    endif
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
    StartTimer(2.5, 1)
EndEvent

Event OnQuestInit()
    RegisterPlayerEvents()
    StartTimer(2.5, 1)
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
    if bMariposaCinematicActive
        CleanupMariposaCinematicSafety()
        Game.FadeOutGame(false, true, 0.0, 0.5, false)
    endif
    RegisterPlayerEvents()
    StartTimer(2.5, 1)
    if bCountdownActive && !bMariposaCollapsed
        StartTimer(5.0, 77)
    endif
EndEvent

Event Actor.OnItemEquipped(Actor akSender, Form akBaseObject, ObjectReference akReference)
    Form winchesterP94 = Game.GetFormFromFile(0x0000110B, "Vault13Chronicles.esp")
    Form purpleRobe = Game.GetFormFromFile(0x00001330, "Vault13Chronicles.esp")
    if akBaseObject == winchesterP94 && winchesterP94 != None
        Debug.Notification("[Winchester P94] Turbo plasma caster active: Toroidal implosion every 3 hits (+35 AP / +25 HP)")
    elseif akBaseObject == purpleRobe && purpleRobe != None
        SyncMariposaMutantHostilityAndGear()
        if !bMariposaDisguiseBlown
            Debug.Notification("[Unity Disguise] Purple Robes equipped: Mariposa and Cathedral sentries will hold fire unless provoked.")
        endif
    endif
EndEvent

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
    Actor player = Game.GetPlayer()
    WorldSpace ws2161 = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if bCountdownActive && !bMariposaCollapsed && player != None && ws2161 != None && player.GetWorldSpace() == ws2161
        TriggerMariposaDestructionFinale()
    endif
    SyncMariposaMutantHostilityAndGear()
    if Self.GetStage() >= 15 && Self.GetStage() < 40
        ApplyV13Act4Stage(Self.GetStage())
    endif
EndEvent

Event OnStageSet(int auiStageID, int auiItemID)
    if auiStageID == 22
        BeginLieutenantBossFight()
    endif
    ApplyV13Act4Stage(auiStageID)
    if Self.IsRunning()
        StartTimer(0.2, 1)
    endif
EndEvent

Event OnTimer(int aiTimerID)
    if aiTimerID == 1
        CheckProgressionAndLevelGate()
        if Self.GetStage() >= 40
            V13Act5QuestScript act5S = Game.GetFormFromFile(0x00008000, "Vault13Chronicles.esp") as V13Act5QuestScript
            if act5S != None
                act5S.WakeUpAct5()
            endif
        endif
        if !Self.IsRunning()
            CancelTimer(1)
            return
        endif
        Quest act3Quest = Game.GetFormFromFile(0x00006002, "Vault13Chronicles.esp") as Quest
        if (Self.GetStage() >= 15 && (Self.GetStage() < 40 || !rewardsGiven || !Self.IsCompleted())) || (act3Quest != None && act3Quest.GetStage() >= 40 && Self.GetStage() < 40)
            StartTimer(2.5, 1)
        endif
    elseif aiTimerID == 77
        if !bCountdownActive || bMariposaCollapsed
            return
        endif
        Actor player = Game.GetPlayer()
        WorldSpace ws2161 = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
        Cell mariposaCell = Game.GetFormFromFile(0x00002C00, "Vault13Chronicles.esp") as Cell
        if player != None && ws2161 != None && player.GetWorldSpace() == ws2161
            TriggerMariposaDestructionFinale()
            return
        endif
        iCountdownSecondsLeft -= 5
        if iCountdownSecondsLeft == 120 || iCountdownSecondsLeft == 60 || iCountdownSecondsLeft == 30 || iCountdownSecondsLeft == 15 || iCountdownSecondsLeft == 5
            if player != None
                Game.ShakeCamera(player, 0.35, 1.0)
            endif
            Debug.Notification("[MARIPOSA SELF-DESTRUCT] Vats detonation in " + iCountdownSecondsLeft + " seconds! Get outside!")
        endif
        if iCountdownSecondsLeft <= 0
            if player != None && mariposaCell != None && player.GetParentCell() == mariposaCell
                ActorValue hpAV = Game.GetFormFromFile(0x000002D4, "Fallout4.esm") as ActorValue
                if hpAV != None
                    float curHP = player.GetValue(hpAV)
                    if curHP > 25.0
                        player.DamageValue(hpAV, curHP * 0.75)
                    endif
                endif
                ObjectReference extExit = Game.GetFormFromFile(0x00003419, "Vault13Chronicles.esp") as ObjectReference
                if extExit != None
                    player.MoveTo(extExit, 0.0, -220.0, 10.0, true)
                endif
            endif
            TriggerMariposaDestructionFinale()
            return
        endif
        StartTimer(5.0, 77)
    elseif aiTimerID == 78
        Scene capScene = Game.GetFormFromFile(0x00007102, "Vault13Chronicles.esp") as Scene
        Actor capAct = Game.GetFormFromFile(0x00002C34, "Vault13Chronicles.esp") as Actor
        if capScene != None && capAct != None && !capAct.IsDead()
            if !capScene.IsPlaying() && !Utility.IsInMenuMode() && !capAct.IsInDialogueWithPlayer() && !capAct.IsTalking()
                ForceAllAct4Aliases()
                capScene.Start()
            endif
        endif
    elseif aiTimerID == 79
        Scene louScene = Game.GetFormFromFile(0x00007103, "Vault13Chronicles.esp") as Scene
        Actor louAct = Game.GetFormFromFile(0x00002C11, "Vault13Chronicles.esp") as Actor
        if louScene != None && louAct != None && !louAct.IsDead() && !louAct.IsInCombat()
            if !louScene.IsPlaying() && !Utility.IsInMenuMode() && !louAct.IsInDialogueWithPlayer() && !louAct.IsTalking()
                ForceAllAct4Aliases()
                louScene.Start()
            endif
        endif
    elseif aiTimerID == 90
        if !bMariposaCinematicActive
            return
        endif
        Actor cinePlayer = Game.GetPlayer()
        if cinePlayer == None
            CleanupMariposaCinematicSafety()
            return
        endif
        if iMariposaCinePhase == 0
            WorldSpace wsCheck90 = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
            if Utility.IsInMenuMode() || !cinePlayer.Is3DLoaded() || (wsCheck90 != None && cinePlayer.GetWorldSpace() != wsCheck90)
                iMariposaReadyTicks = 0
                StartTimer(0.45, 90)
                return
            endif
            iMariposaReadyTicks += 1
            if iMariposaReadyTicks < 3
                StartTimer(0.45, 90)
                return
            endif
            iMariposaReadyTicks = 0
            if kMariposaCineLayer == None
                kMariposaCineLayer = InputEnableLayer.Create()
            endif
            if kMariposaCineLayer != None
                kMariposaCineLayer.DisablePlayerControls(true, true, true, true, true, false, true, true, true, true, true)
            endif
            cinePlayer.SetGhost(true)
            iMariposaCinePhase = 1
            StartTimer(0.15, 90)
        elseif iMariposaCinePhase == 1
            Game.ForceFirstPerson()
            Game.ShowFirstPersonGeometry(false)
            cinePlayer.SetAlpha(0.0, false)
            ObjectReference blastAnchor1 = Game.GetFormFromFile(0x00009941, "Vault13Chronicles.esp") as ObjectReference
            if blastAnchor1 != None
                cinePlayer.SetAngle(0.0, 0.0, cinePlayer.GetAngleZ() + cinePlayer.GetHeadingAngle(blastAnchor1))
            endif
            Sound sirenSnd = Game.GetFormFromFile(0x001B9C63, "Fallout4.esm") as Sound
            if sirenSnd != None
                iMariposaSirenInstance = sirenSnd.Play(cinePlayer)
            endif
            iMariposaCinePhase = 2
            StartTimer(1.5, 90)
        elseif iMariposaCinePhase == 2
            Form nukeExpl = Game.GetFormFromFile(0x001844BC, "Fallout4.esm")
            ObjectReference blastAnchor = Game.GetFormFromFile(0x00009941, "Vault13Chronicles.esp") as ObjectReference
            if nukeExpl != None && blastAnchor != None
                blastAnchor.PlaceAtMe(nukeExpl, 1, false, false)
            endif
            ImageSpaceModifier hugeImod = Game.GetFormFromFile(0x001844BD, "Fallout4.esm") as ImageSpaceModifier
            if hugeImod != None
                hugeImod.Apply(1.0)
            endif
            ObjectReference fire1 = Game.GetFormFromFile(0x00009942, "Vault13Chronicles.esp") as ObjectReference
            if fire1 != None
                fire1.Enable(false)
            endif
            ObjectReference fire2 = Game.GetFormFromFile(0x00009943, "Vault13Chronicles.esp") as ObjectReference
            if fire2 != None
                fire2.Enable(false)
            endif
            Game.ShakeCamera(cinePlayer, 1.0, 3.0)
            iMariposaCinePhase = 3
            StartTimer(2.0, 90)
        elseif iMariposaCinePhase == 3
            ImageSpaceModifier shockImod = Game.GetFormFromFile(0x001851A2, "Fallout4.esm") as ImageSpaceModifier
            if shockImod != None
                shockImod.Apply(0.85)
            endif
            Game.ShakeCamera(cinePlayer, 0.8, 2.5)
            iMariposaCinePhase = 4
            StartTimer(2.6, 90)
        else
            CleanupMariposaCinematicSafety()
            Game.RewardPlayerXP(500, false)
            Debug.Notification("[Mariposa Military Base] BOOM! The FEV Vats have collapsed beneath tons of rubble! (+500 XP)")
        endif
    endif
EndEvent

Function SilentCompleteAct4ForJump()
    CleanupMariposaCinematicSafety()
    introShown = true
    bStage30Done = true
    bStage40Rewarded = true
    rewardsGiven = true
    bMariposaCollapsed = true
    bCountdownActive = false
    CancelTimer(77)
    ObjectReference fire1J = Game.GetFormFromFile(0x00009942, "Vault13Chronicles.esp") as ObjectReference
    if fire1J != None
        fire1J.Enable(false)
    endif
    ObjectReference fire2J = Game.GetFormFromFile(0x00009943, "Vault13Chronicles.esp") as ObjectReference
    if fire2J != None
        fire2J.Enable(false)
    endif
    ObjectReference surfDoor = Game.GetFormFromFile(0x00003508, "Vault13Chronicles.esp") as ObjectReference
    if surfDoor != None
        surfDoor.Lock(true, false)
        surfDoor.SetLockLevel(255)
    endif
    if !Self.IsRunning() && !Self.IsCompleted()
        Self.Start()
    endif
    Self.SetObjectiveDisplayed(15, false, false)
    Self.SetObjectiveDisplayed(20, false, false)
    Self.SetObjectiveDisplayed(21, false, false)
    Self.SetObjectiveDisplayed(30, false, false)
    bApplyingAct4Stage = true
    Self.SetStage(40)
    bApplyingAct4Stage = false
    Self.CompleteAllObjectives()
    Self.CompleteQuest()
EndFunction
