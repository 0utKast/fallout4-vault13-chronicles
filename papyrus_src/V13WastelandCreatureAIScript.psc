Scriptname V13WastelandCreatureAIScript extends Actor

float HomeX = 0.0
float HomeY = 0.0
float HomeZ = 0.0
float LastCombatX = 0.0
float LastCombatY = 0.0
int StuckCombatTicks = 0
bool bInitialized = false
bool bFormsCached = false
bool bCachedLegacyChecked = false
bool bCachedIsLegacy = false
ActorBase ab1206 = None
ActorBase ab1207 = None
ActorBase ab1208 = None
ActorBase ab120A = None
ActorBase ab120B = None
ActorBase ab120C = None
Cell cMariposa = None
Cell cCathedral = None
Cell cCathedralSanctuary = None
ObjectReference refExtSentry = None
ObjectReference refKenji = None
ObjectReference refSkull = None
Form fSensorBase = None
EffectShader fxRedHalo = None
EffectShader fxTargetScan = None
EffectShader fxStealthDeath = None
V13Act4QuestScript cachedAct4 = None
V13Act5QuestScript cachedAct5 = None

Function EnsureCachedForms()
    if bFormsCached
        return
    endif
    bFormsCached = true
    ab1206 = Game.GetFormFromFile(0x00001206, "Vault13Chronicles.esp") as ActorBase
    ab1207 = Game.GetFormFromFile(0x00001207, "Vault13Chronicles.esp") as ActorBase
    ab1208 = Game.GetFormFromFile(0x00001208, "Vault13Chronicles.esp") as ActorBase
    ab120A = Game.GetFormFromFile(0x0000120A, "Vault13Chronicles.esp") as ActorBase
    ab120B = Game.GetFormFromFile(0x0000120B, "Vault13Chronicles.esp") as ActorBase
    ab120C = Game.GetFormFromFile(0x0000120C, "Vault13Chronicles.esp") as ActorBase
    cMariposa = Game.GetFormFromFile(0x00002C00, "Vault13Chronicles.esp") as Cell
    cCathedral = Game.GetFormFromFile(0x00002D00, "Vault13Chronicles.esp") as Cell
    cCathedralSanctuary = Game.GetFormFromFile(0x00002D80, "Vault13Chronicles.esp") as Cell
    refExtSentry = Game.GetFormFromFile(0x0000358D, "Vault13Chronicles.esp") as ObjectReference
    refKenji = Game.GetFormFromFile(0x000035C4, "Vault13Chronicles.esp") as ObjectReference
    refSkull = Game.GetFormFromFile(0x000035C5, "Vault13Chronicles.esp") as ObjectReference
    fSensorBase = Game.GetFormFromFile(0x00001456, "Vault13Chronicles.esp")
    fxRedHalo = Game.GetFormFromFile(0x0022517C, "Fallout4.esm") as EffectShader
    fxTargetScan = Game.GetFormFromFile(0x00247A3F, "Fallout4.esm") as EffectShader
    fxStealthDeath = Game.GetFormFromFile(0x00102B7E, "Fallout4.esm") as EffectShader
    cachedAct4 = Game.GetFormFromFile(0x00007000, "Vault13Chronicles.esp") as V13Act4QuestScript
    cachedAct5 = Game.GetFormFromFile(0x00008000, "Vault13Chronicles.esp") as V13Act5QuestScript
EndFunction

bool Function IsInShadySandsSafeZone(float ax, float ay)
    if ax >= 3300.0 && ax <= 9600.0 && ay >= 21100.0 && ay <= 25900.0
        return true
    endif
    if ax >= 6000.0 && ax <= 9000.0 && ay >= 4100.0 && ay <= 7200.0
        return true
    endif
    if ax >= -5200.0 && ax <= -2400.0 && ay >= 1100.0 && ay <= 3300.0
        return true
    endif
    if ax >= -6600.0 && ax <= -900.0 && ay >= -16800.0 && ay <= -10400.0
        return true
    endif
    if ax >= 20400.0 && ax <= 22600.0 && ay >= 17400.0 && ay <= 19600.0
        return true
    endif
    if ax >= -26200.0 && ax <= -22800.0 && ay >= -8600.0 && ay <= -6400.0
        return true
    endif
    if ax >= -6400.0 && ax <= -2600.0 && ay >= -33000.0 && ay <= -30000.0
        return true
    endif
    return false
EndFunction

bool Function IsUnityDisguiseActiveForSelf()
    EnsureCachedForms()
    ActorBase myBase = Self.GetActorBase()
    if myBase == None
        return false
    endif
    bool isMariposaGuard = (myBase == ab1207) || (myBase == ab1208) || (myBase == ab120C)
    bool isCathedralGuard = (myBase == ab1206) || (myBase == ab120A) || (myBase == ab120B) || (myBase == ab120C)
    if !isMariposaGuard && !isCathedralGuard
        return false
    endif
    Cell parentCell = Self.GetParentCell()
    ObjectReference selfRef = Self as ObjectReference
    if (parentCell != None && parentCell == cMariposa) || selfRef == refExtSentry
        if cachedAct4 != None && cachedAct4.IsPlayerDisguisedAsCathedral()
            return true
        endif
    elseif parentCell != None && (parentCell == cCathedral || parentCell == cCathedralSanctuary)
        if cachedAct5 != None && cachedAct5.IsPlayerDisguisedAsCathedral()
            return true
        endif
    endif
    return false
EndFunction

Function RefreshMutantLoadoutAndFaction()
    EnsureCachedForms()
    EffectShader fxSD = Game.GetFormFromFile(0x00102B7E, "Fallout4.esm") as EffectShader
    if fxSD != None
        fxSD.Stop(Self)
    endif
    ActorBase myBase = Self.GetActorBase()
    if !Self.IsDead() && myBase != None && myBase == ab1208
        Weapon wMinigun = Game.GetFormFromFile(0x0001F669, "Fallout4.esm") as Weapon
        Ammo a5mm = Game.GetFormFromFile(0x0001F66C, "Fallout4.esm") as Ammo
        if wMinigun != None
            if Self.GetItemCount(wMinigun) == 0
                Self.AddItem(wMinigun, 1, true)
            endif
            if a5mm != None && Self.GetItemCount(a5mm) < 100
                Self.AddItem(a5mm, 250, true)
            endif
            if !Self.IsEquipped(wMinigun)
                Self.EquipItem(wMinigun, false, true)
            endif
        endif
    endif
    Faction smFac = Game.GetFormFromFile(0x00058305, "Fallout4.esm") as Faction
    Faction playerFac = Game.GetFormFromFile(0x0001C21C, "Fallout4.esm") as Faction
    Faction cultCivFac = Game.GetFormFromFile(0x00001C59, "Vault13Chronicles.esp") as Faction
    Actor kPlayer = Game.GetPlayer()
    if smFac != None && cultCivFac != None
        smFac.SetAlly(cultCivFac, true, true)
    endif
    if smFac != None && playerFac != None && kPlayer != None && Self.IsInFaction(smFac)
        if IsUnityDisguiseActiveForSelf()
            smFac.SetEnemy(playerFac, true, true)
        else
            Cell cWatershed = Game.GetFormFromFile(0x00002900, "Vault13Chronicles.esp") as Cell
            Cell pCell = kPlayer.GetParentCell()
            bool playerDisguisedInMariposa = (cMariposa != None && pCell == cMariposa && cachedAct4 != None && cachedAct4.IsPlayerDisguisedAsCathedral())
            bool playerDisguisedInCathedral = (cCathedral != None && (pCell == cCathedral || pCell == cCathedralSanctuary) && cachedAct5 != None && cachedAct5.IsPlayerDisguisedAsCathedral())
            if (cWatershed == None || pCell != cWatershed) && !playerDisguisedInMariposa && !playerDisguisedInCathedral
                smFac.SetEnemy(playerFac, false, false)
            endif
        endif
    endif
EndFunction

Function EscapeBunkerOrBuildingWall()
    if Self.GetWorldSpace() == None || Self.IsDead() || Self.IsDisabled()
        return
    endif
    float cx = Self.GetPositionX()
    float cy = Self.GetPositionY()
    ; Eject immediately if inside any of the 10 hollow concrete surface bunker boxes ([bdx - 430 .. bdx + 550, bdy - 60 .. bdy + 760])
    if cx >= 27570.0 && cx <= 28550.0 && cy >= -8040.0 && cy <= -7220.0
        HomeX = 28000.0
        HomeY = -8340.0
        HomeZ = 6.0
        Self.SetPosition(HomeX, HomeY, HomeZ)
    elseif cx >= 33070.0 && cx <= 34050.0 && cy >= -7040.0 && cy <= -6220.0
        HomeX = 33500.0
        HomeY = -7340.0
        HomeZ = 6.0
        Self.SetPosition(HomeX, HomeY, HomeZ)
    elseif cx >= 25070.0 && cx <= 26050.0 && cy >= -11540.0 && cy <= -10720.0
        HomeX = 25500.0
        HomeY = -11840.0
        HomeZ = 6.0
        Self.SetPosition(HomeX, HomeY, HomeZ)
    elseif cx >= 28570.0 && cx <= 29550.0 && cy >= -2040.0 && cy <= -1220.0
        HomeX = 29000.0
        HomeY = -2340.0
        HomeZ = 6.0
        Self.SetPosition(HomeX, HomeY, HomeZ)
    elseif cx >= 33070.0 && cx <= 34050.0 && cy >= 13520.0 && cy <= 14340.0
        HomeX = 33500.0
        HomeY = 13280.0
        HomeZ = 246.0
        Self.SetPosition(HomeX, HomeY, HomeZ)
    elseif cx >= -7430.0 && cx <= -6450.0 && cy >= 33080.0 && cy <= 33900.0
        HomeX = -7000.0
        HomeY = 32840.0
        HomeZ = 326.0
        Self.SetPosition(HomeX, HomeY, HomeZ)
    elseif cx >= -18430.0 && cx <= -17450.0 && cy >= 33440.0 && cy <= 34260.0
        HomeX = -18000.0
        HomeY = 33200.0
        HomeZ = 326.0
        Self.SetPosition(HomeX, HomeY, HomeZ)
    elseif cx >= -24930.0 && cx <= -23950.0 && cy >= -7540.0 && cy <= -6720.0
        HomeX = -24500.0
        HomeY = -7780.0
        HomeZ = 126.0
        Self.SetPosition(HomeX, HomeY, HomeZ)
    elseif cx >= -31430.0 && cx <= -30450.0 && cy >= 30960.0 && cy <= 31780.0
        HomeX = -31000.0
        HomeY = 30720.0
        HomeZ = 286.0
        Self.SetPosition(HomeX, HomeY, HomeZ)
    elseif cx >= -19930.0 && cx <= -18950.0 && cy >= -31540.0 && cy <= -30720.0
        HomeX = -19500.0
        HomeY = -31860.0
        HomeZ = 46.0
        Self.SetPosition(HomeX, HomeY, HomeZ)
    elseif cx >= 31070.0 && cx <= 32050.0 && cy >= -33580.0 && cy <= -32760.0
        HomeX = 31500.0
        HomeY = -33920.0
        HomeZ = 124.0
        Self.SetPosition(HomeX, HomeY, HomeZ)
    endif
EndFunction

Function SanitizeLegacyHomePosition()
    EscapeBunkerOrBuildingWall()
    if Self.GetWorldSpace() == None || Self.IsInCombat()
        return
    endif
    ; Migrate any legacy savegame-baked HomeX/HomeY that was inside a settlement plaza
    if HomeX >= 3300.0 && HomeX <= 9600.0 && HomeY >= 21100.0 && HomeY <= 25900.0
        HomeX = 16000.0
        HomeY = 34500.0
        HomeZ = 166.0
        Self.StopCombat()
        Self.SetPosition(HomeX, HomeY, HomeZ)
    elseif HomeX >= 6000.0 && HomeX <= 9000.0 && HomeY >= 4100.0 && HomeY <= 7200.0
        HomeX = 14200.0
        HomeY = 14800.0
        HomeZ = 158.0
        Self.StopCombat()
        Self.SetPosition(HomeX, HomeY, HomeZ)
    elseif HomeX >= 20400.0 && HomeX <= 22600.0 && HomeY >= 17400.0 && HomeY <= 19600.0
        HomeX = 27200.0
        HomeY = 16200.0
        HomeZ = 174.0
        Self.StopCombat()
        Self.SetPosition(HomeX, HomeY, HomeZ)
    endif
EndFunction

bool Function IsLegacyHumanCampActor()
    if bCachedLegacyChecked
        return bCachedIsLegacy
    endif
    bCachedLegacyChecked = true
    ObjectReference selfRef = Self as ObjectReference
    if selfRef == None
        bCachedIsLegacy = false
        return false
    endif
    int[] campFids = new int[8]
    campFids[0] = 0x000035C4
    campFids[1] = 0x000035C5
    campFids[2] = 0x000035C9
    campFids[3] = 0x000035CA
    campFids[4] = 0x000035CE
    campFids[5] = 0x000035CF
    campFids[6] = 0x00003611
    campFids[7] = 0x00003612
    int i = 0
    while i < 8
        if selfRef == Game.GetFormFromFile(campFids[i], "Vault13Chronicles.esp")
            bCachedIsLegacy = true
            return true
        endif
        i += 1
    endwhile
    bCachedIsLegacy = false
    return false
EndFunction

Function InitCreatureAI()
    EnsureCachedForms()
    if IsLegacyHumanCampActor()
        CancelTimer(1)
        return
    endif
    if Self.IsDead() || Self.IsDisabled()
        return
    endif
    if !Self.Is3DLoaded()
        StartTimer(2.0, 1)
        return
    endif
    Self.EnableAI(true)
    RegisterForHitEvent(Self)
    RefreshMutantLoadoutAndFaction()
    if IsUnityDisguiseActiveForSelf()
        Self.SetValue(Game.GetAggressionAV(), 0.0)
        Self.StopCombat()
        Self.EvaluatePackage()
        StartTimer(2.0, 1)
        return
    endif
    if Self.GetWorldSpace() == None
        float initIntAgg = 2.0
        Cell initIntCell = Self.GetParentCell()
        if initIntCell != None && ((cMariposa != None && initIntCell == cMariposa) || (cCathedral != None && initIntCell == cCathedral) || (cCathedralSanctuary != None && initIntCell == cCathedralSanctuary))
            initIntAgg = 1.0
        endif
        Self.SetValue(Game.GetAggressionAV(), initIntAgg)
        Self.SetValue(Game.GetConfidenceAV(), 4.0)
        Self.EvaluatePackage()
        StartTimer(Utility.RandomFloat(1.5, 2.5), 1)
        return
    endif
    ObjectReference selfRef = Self as ObjectReference
    if selfRef == refKenji
        if Math.Abs(Self.GetPositionX() + 5460.0) > 450.0 || Math.Abs(Self.GetPositionY() - 12880.0) > 450.0
            if !Self.IsInCombat()
                Self.SetPosition(-5460.0, 12880.0, 86.0)
            endif
        endif
    elseif selfRef == refSkull
        if Math.Abs(Self.GetPositionX() + 5300.0) > 450.0 || Math.Abs(Self.GetPositionY() - 12880.0) > 450.0
            if !Self.IsInCombat()
                Self.SetPosition(-5300.0, 12880.0, 86.0)
            endif
        endif
    endif
    if !bInitialized || !Self.IsInCombat()
        HomeX = Self.GetPositionX()
        HomeY = Self.GetPositionY()
        HomeZ = Self.GetPositionZ()
        bInitialized = true
    endif
    SanitizeLegacyHomePosition()
    if !IsInShadySandsSafeZone(HomeX, HomeY)
        Self.SetValue(Game.GetAggressionAV(), 2.0)
    else
        if !Self.IsInCombat()
            Self.SetValue(Game.GetAggressionAV(), 0.0)
        endif
    endif
    Self.SetValue(Game.GetConfidenceAV(), 4.0)
    Self.EvaluatePackage()
    StartTimer(Utility.RandomFloat(1.0, 1.8), 1)
EndFunction

Event OnInit()
    InitCreatureAI()
EndEvent

Event OnLoad()
    InitCreatureAI()
EndEvent

Event OnCellAttach()
    InitCreatureAI()
EndEvent

Event OnUnload()
    CancelTimer(1)
EndEvent

Event OnCellDetach()
    CancelTimer(1)
EndEvent

Event OnHit(ObjectReference akTarget, ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked, string asMaterial)
    if IsLegacyHumanCampActor()
        CancelTimer(1)
        return
    endif
    if Self.IsDead() || Self.IsDisabled()
        return
    endif
    RegisterForHitEvent(Self)
    Self.EnableAI(true)
    EnsureCachedForms()
    HomeX = Self.GetPositionX()
    HomeY = Self.GetPositionY()
    HomeZ = Self.GetPositionZ()
    Cell hitCell = Self.GetParentCell()
    if hitCell != None && ((cMariposa != None && hitCell == cMariposa) || (cCathedral != None && hitCell == cCathedral) || (cCathedralSanctuary != None && hitCell == cCathedralSanctuary))
        Self.SetValue(Game.GetAggressionAV(), 1.0)
    else
        Self.SetValue(Game.GetAggressionAV(), 2.0)
    endif
    Self.SetValue(Game.GetConfidenceAV(), 4.0)
    Actor kPlayer = Game.GetPlayer()
    if akAggressor == kPlayer
        ObjectReference selfHitRef = Self as ObjectReference
        if (hitCell != None && hitCell == cMariposa) || selfHitRef == refExtSentry
            if cachedAct4 != None
                cachedAct4.BlowCathedralDisguise()
            endif
        elseif hitCell != None && (hitCell == cCathedral || hitCell == cCathedralSanctuary)
            if cachedAct5 != None
                cachedAct5.BlowCathedralDisguise()
            endif
        endif
    endif
    if !Self.IsDead() && kPlayer != None && !kPlayer.IsDead() && !Self.IsInCombat()
        Self.StartCombat(kPlayer)
    endif
    if Self.Is3DLoaded()
        StartTimer(1.0, 1)
    endif
EndEvent

Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
    if IsLegacyHumanCampActor()
        CancelTimer(1)
        return
    endif
    if !Self.IsDead() && !Self.IsDisabled() && Self.Is3DLoaded() && Self.GetWorldSpace() != None
        StartTimer(1.0, 1)
    endif
EndEvent

Event OnDeath(Actor akKiller)
    CancelTimer(1)
    EnsureCachedForms()
    if fxRedHalo != None
        fxRedHalo.Stop(Self)
    endif
    if fxTargetScan != None
        fxTargetScan.Stop(Self)
    endif
    if fxStealthDeath != None
        fxStealthDeath.Stop(Self)
    endif
EndEvent

Event OnTimer(int aiTimerID)
    if aiTimerID != 1
        return
    endif
    if IsLegacyHumanCampActor()
        CancelTimer(1)
        return
    endif
    if Self.IsDead() || Self.IsDisabled()
        return
    endif
    if !Self.Is3DLoaded()
        Actor pWait = Game.GetPlayer()
        if pWait != None && Self.GetWorldSpace() != None
            if pWait.GetWorldSpace() == Self.GetWorldSpace()
                StartTimer(6.0, 1)
            else
                StartTimer(8.0, 1)
            endif
        endif
        return
    endif

    EnsureCachedForms()
    Self.EnableAI(true)

    Actor kPlayer = Game.GetPlayer()
    if kPlayer == None
        StartTimer(2.5, 1)
        return
    endif

    RefreshMutantLoadoutAndFaction()

    if Self.GetWorldSpace() != None && kPlayer.GetWorldSpace() != Self.GetWorldSpace()
        StartTimer(12.0, 1)
        return
    endif

    float fDist = Self.GetDistance(kPlayer)
    if fDist <= 4500.0
        if fSensorBase != None && kPlayer.GetItemCount(fSensorBase) > 0
            if fxRedHalo != None
                fxRedHalo.Play(Self, 4.5)
            endif
            if fxTargetScan != None
                fxTargetScan.Play(Self, 4.5)
            endif
        endif
    endif

    if IsUnityDisguiseActiveForSelf()
        if Self.IsInCombat() || Self.GetValue(Game.GetAggressionAV()) > 0.0
            Self.SetValue(Game.GetAggressionAV(), 0.0)
            Self.StopCombat()
            Self.StopCombatAlarm()
            Self.EvaluatePackage()
        endif
        StartTimer(2.0, 1)
        return
    endif

    ; Interior cells use 100% native NavMesh pathfinding and AI packages
    if Self.GetWorldSpace() == None
        float timerIntAgg = 2.0
        Cell timerIntCell = Self.GetParentCell()
        if timerIntCell != None && ((cMariposa != None && timerIntCell == cMariposa) || (cCathedral != None && timerIntCell == cCathedral) || (cCathedralSanctuary != None && timerIntCell == cCathedralSanctuary))
            timerIntAgg = 1.0
        endif
        Self.SetValue(Game.GetAggressionAV(), timerIntAgg)
        Self.SetValue(Game.GetConfidenceAV(), 4.0)
        StartTimer(2.0, 1)
        return
    endif

    EscapeBunkerOrBuildingWall()

    float curX = Self.GetPositionX()
    float curY = Self.GetPositionY()
    float px = kPlayer.GetPositionX()
    float py = kPlayer.GetPositionY()
    bool playerInSafeZone = IsInShadySandsSafeZone(px, py)

    ; Enforce Walled Settlement Sanctuaries: hostile creatures/Raiders calm down if player or creature enters a settlement safe zone
    if IsInShadySandsSafeZone(curX, curY) || (playerInSafeZone && fDist < 1600.0)
        if Self.IsInCombat() || Self.GetValue(Game.GetAggressionAV()) > 0.0
            Self.SetValue(Game.GetAggressionAV(), 0.0)
            Self.StopCombat()
            Self.StopCombatAlarm()
            if playerInSafeZone
                kPlayer.StopCombatAlarm()
            endif
            Self.EvaluatePackage()
        endif
        StartTimer(2.5, 1)
        return
    endif

    if fDist > 4200.0
        if Self.IsInCombat()
            Self.StopCombat()
            Self.EvaluatePackage()
        endif
        Self.SetValue(Game.GetAggressionAV(), 2.0)
        Self.SetValue(Game.GetConfidenceAV(), 4.0)
        StartTimer(6.0, 1)
        return
    endif

    ObjectReference selfRefTimer = Self as ObjectReference
    if selfRefTimer == refKenji || selfRefTimer == refSkull
        if fDist > 950.0 && !Self.IsInCombat()
            StuckCombatTicks = 0
            StartTimer(2.0, 1)
            return
        endif
        Self.SetValue(Game.GetAggressionAV(), 2.0)
        Self.SetValue(Game.GetConfidenceAV(), 4.0)
        if !Self.IsDead() && !kPlayer.IsDead() && !Self.IsInCombat()
            StuckCombatTicks = 0
            LastCombatX = curX
            LastCombatY = curY
            Self.StartCombat(kPlayer)
        elseif Self.IsInCombat() && fDist > 950.0
            float dKMoveX = curX - LastCombatX
            float dKMoveY = curY - LastCombatY
            if (dKMoveX * dKMoveX + dKMoveY * dKMoveY) < 324.0
                StuckCombatTicks += 1
                if StuckCombatTicks >= 5
                    StuckCombatTicks = 0
                    Self.EvaluatePackage()
                    Self.PathToReference(kPlayer, 1.0)
                    if !Self.IsDead()
                        Self.StartCombat(kPlayer)
                    endif
                endif
            else
                StuckCombatTicks = 0
            endif
            LastCombatX = curX
            LastCombatY = curY
        else
            StuckCombatTicks = 0
            LastCombatX = curX
            LastCombatY = curY
        endif
        StartTimer(1.5, 1)
        return
    endif

    float dxHome = curX - HomeX
    float dyHome = curY - HomeY
    float distFromHome = Math.Sqrt((dxHome * dxHome) + (dyHome * dyHome))

    if !Self.IsInCombat() && distFromHome > 2200.0
        HomeX = curX
        HomeY = curY
        HomeZ = Self.GetPositionZ()
        distFromHome = 0.0
    endif

    ; Natural NavMesh Leash: if chased > 3400 units from Home and player moved away, disengage
    if distFromHome > 3400.0 && fDist > 1850.0
        if Self.IsInCombat()
            Self.StopCombat()
            Self.StopCombatAlarm()
            Self.EvaluatePackage()
        endif
        StuckCombatTicks = 0
        HomeX = curX
        HomeY = curY
        HomeZ = Self.GetPositionZ()
        StartTimer(2.5, 1)
        return
    endif

    ; Exterior Detection & Combat Engagement (active NavMesh pursuit + stuck recovery)
    Self.SetValue(Game.GetAggressionAV(), 2.0)
    Self.SetValue(Game.GetConfidenceAV(), 4.0)
    if fDist <= 1850.0 || Self.IsInCombat()
        if !Self.IsDead() && !kPlayer.IsDead() && !Self.IsInCombat()
            StuckCombatTicks = 0
            LastCombatX = curX
            LastCombatY = curY
            Self.StartCombat(kPlayer)
        elseif Self.IsInCombat() && fDist > 950.0
            float dMoveX = curX - LastCombatX
            float dMoveY = curY - LastCombatY
            if (dMoveX * dMoveX + dMoveY * dMoveY) < 324.0
                StuckCombatTicks += 1
                if StuckCombatTicks >= 5
                    StuckCombatTicks = 0
                    Self.EvaluatePackage()
                    Self.PathToReference(kPlayer, 1.0)
                    if !Self.IsDead()
                        Self.StartCombat(kPlayer)
                    endif
                endif
            else
                StuckCombatTicks = 0
            endif
            LastCombatX = curX
            LastCombatY = curY
        else
            StuckCombatTicks = 0
            LastCombatX = curX
            LastCombatY = curY
        endif
        StartTimer(1.3, 1)
        return
    endif

    StuckCombatTicks = 0
    if fDist > 3500.0
        StartTimer(6.0, 1)
    else
        StartTimer(2.0, 1)
    endif
EndEvent
