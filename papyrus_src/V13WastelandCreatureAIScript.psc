Scriptname V13WastelandCreatureAIScript extends Actor

float HomeX = 0.0
float HomeY = 0.0
float HomeZ = 0.0
float LastCombatX = 0.0
float LastCombatY = 0.0
int StuckCombatTicks = 0
bool bInitialized = false

bool Function IsInShadySandsSafeZone(float ax, float ay)
    if ax >= 1200.0 && ax <= 3600.0 && ay >= 8550.0 && ay <= 10650.0
        return true
    endif
    if ax >= 2800.0 && ax <= 4400.0 && ay >= 3100.0 && ay <= 4500.0
        return true
    endif
    if ax >= -1800.0 && ax <= 0.0 && ay >= -4500.0 && ay <= -3100.0
        return true
    endif
    if ax >= 7550.0 && ax <= 8850.0 && ay >= 7150.0 && ay <= 8450.0
        return true
    endif
    if ax >= -10500.0 && ax <= -9100.0 && ay >= -3400.0 && ay <= -2100.0
        return true
    endif
    if ax >= -200.0 && ax <= 1400.0 && ay >= -13500.0 && ay <= -12100.0
        return true
    endif
    return false
EndFunction

Function EscapeBunkerOrBuildingWall()
    if Self.GetWorldSpace() == None || Self.IsDead() || Self.IsDisabled()
        return
    endif
    float cx = Self.GetPositionX()
    float cy = Self.GetPositionY()
    ; Eject immediately if inside any of the 10 hollow concrete surface bunker boxes ([bdx - 430 .. bdx + 550, bdy - 60 .. bdy + 760])
    if cx >= 10970.0 && cx <= 11950.0 && cy >= -2440.0 && cy <= -1620.0
        HomeX = 10950.0
        HomeY = -2750.0
        HomeZ = 6.0
        Self.SetPosition(HomeX, HomeY, HomeZ)
    elseif cx >= 13170.0 && cx <= 14150.0 && cy >= -2040.0 && cy <= -1220.0
        HomeX = 13600.0
        HomeY = -2340.0
        HomeZ = 6.0
        Self.SetPosition(HomeX, HomeY, HomeZ)
    elseif cx >= 9970.0 && cx <= 10950.0 && cy >= -4240.0 && cy <= -3420.0
        HomeX = 10400.0
        HomeY = -4540.0
        HomeZ = 6.0
        Self.SetPosition(HomeX, HomeY, HomeZ)
    elseif cx >= 11570.0 && cx <= 12550.0 && cy >= 760.0 && cy <= 1580.0
        HomeX = 12000.0
        HomeY = 460.0
        HomeZ = 6.0
        Self.SetPosition(HomeX, HomeY, HomeZ)
    elseif cx >= 12170.0 && cx <= 13150.0 && cy >= 6820.0 && cy <= 7640.0
        HomeX = 12600.0
        HomeY = 6520.0
        HomeZ = 246.0
        Self.SetPosition(HomeX, HomeY, HomeZ)
    elseif cx >= -3630.0 && cx <= -2650.0 && cy >= 13300.0 && cy <= 14120.0
        HomeX = -3200.0
        HomeY = 13000.0
        HomeZ = 326.0
        Self.SetPosition(HomeX, HomeY, HomeZ)
    elseif cx >= -6630.0 && cx <= -5650.0 && cy >= 13540.0 && cy <= 14360.0
        HomeX = -6200.0
        HomeY = 13240.0
        HomeZ = 326.0
        Self.SetPosition(HomeX, HomeY, HomeZ)
    elseif cx >= -10230.0 && cx <= -9250.0 && cy >= -2640.0 && cy <= -1820.0
        HomeX = -9800.0
        HomeY = -2940.0
        HomeZ = 126.0
        Self.SetPosition(HomeX, HomeY, HomeZ)
    elseif cx >= -10230.0 && cx <= -9250.0 && cy >= 13360.0 && cy <= 14180.0
        HomeX = -9800.0
        HomeY = 13060.0
        HomeZ = 286.0
        Self.SetPosition(HomeX, HomeY, HomeZ)
    elseif cx >= -5230.0 && cx <= -4250.0 && cy >= -13240.0 && cy <= -12420.0
        HomeX = -4800.0
        HomeY = -13540.0
        HomeZ = 46.0
        Self.SetPosition(HomeX, HomeY, HomeZ)
    ; Also eject from closed Necropolis building shells (Commercial Block, Hotel Block, Brick Garage, Church)
    elseif cx >= 9350.0 && cx <= 10550.0 && cy >= 50.0 && cy <= 1050.0
        HomeX = 10850.0
        HomeY = -150.0
        HomeZ = 6.0
        Self.SetPosition(HomeX, HomeY, HomeZ)
    elseif cx >= 12650.0 && cx <= 13850.0 && cy >= -150.0 && cy <= 1050.0
        HomeX = 12150.0
        HomeY = -600.0
        HomeZ = 6.0
        Self.SetPosition(HomeX, HomeY, HomeZ)
    elseif cx >= 11100.0 && cx <= 12000.0 && cy >= -4400.0 && cy <= -3500.0
        HomeX = 10550.0
        HomeY = -3100.0
        HomeZ = 6.0
        Self.SetPosition(HomeX, HomeY, HomeZ)
    ; Also eject from closed camp cabins (Vault 15 Cabin, Kenji Cabin, Tolan Cabin, Irwin Farm Cabin)
    elseif cx >= 11030.0 && cx <= 11925.0 && cy >= 6910.0 && cy <= 7635.0
        HomeX = 11200.0
        HomeY = 6800.0
        HomeZ = 246.0
        Self.SetPosition(HomeX, HomeY, HomeZ)
    elseif cx >= -2220.0 && cx <= -1495.0 && cy >= 5165.0 && cy <= 6060.0
        HomeX = -2600.0
        HomeY = 5480.0
        HomeZ = 86.0
        Self.SetPosition(HomeX, HomeY, HomeZ)
    elseif cx >= 13860.0 && cx <= 14585.0 && cy >= 11165.0 && cy <= 12060.0
        HomeX = 14200.0
        HomeY = 10800.0
        HomeZ = 206.0
        Self.SetPosition(HomeX, HomeY, HomeZ)
    elseif cx >= -9540.0 && cx <= -8815.0 && cy >= 2565.0 && cy <= 3460.0
        HomeX = -9200.0
        HomeY = 2200.0
        HomeZ = 86.0
        Self.SetPosition(HomeX, HomeY, HomeZ)
    endif
EndFunction

Function SanitizeLegacyHomePosition()
    EscapeBunkerOrBuildingWall()
    if Self.GetWorldSpace() == None || Self.IsInCombat()
        return
    endif
    ; Migrate any legacy savegame-baked HomeX/HomeY that was inside a settlement plaza
    if HomeX >= 400.0 && HomeX <= 4400.0 && HomeY >= 8200.0 && HomeY <= 11150.0
        HomeX = 6400.0
        HomeY = 13800.0
        HomeZ = 166.0
        Self.StopCombat()
        Self.SetPosition(HomeX, HomeY, HomeZ)
    elseif HomeX >= 2800.0 && HomeX <= 4400.0 && HomeY >= 3100.0 && HomeY <= 4500.0
        HomeX = 5600.0
        HomeY = 3800.0
        HomeZ = 86.0
        Self.StopCombat()
        Self.SetPosition(HomeX, HomeY, HomeZ)
    elseif HomeX >= 7550.0 && HomeX <= 8850.0 && HomeY >= 7150.0 && HomeY <= 8450.0
        HomeX = 9600.0
        HomeY = 7800.0
        HomeZ = 206.0
        Self.StopCombat()
        Self.SetPosition(HomeX, HomeY, HomeZ)
    endif
EndFunction

Function InitCreatureAI()
    if Self.IsDead() || Self.IsDisabled()
        return
    endif
    if !Self.Is3DLoaded()
        StartTimer(2.0, 1)
        return
    endif
    Self.EnableAI(true)
    RegisterForHitEvent(Self)
    if Self.GetWorldSpace() == None
        Self.SetValue(Game.GetAggressionAV(), 2.0)
        Self.SetValue(Game.GetConfidenceAV(), 4.0)
        Self.EvaluatePackage()
        StartTimer(Utility.RandomFloat(1.5, 2.5), 1)
        return
    endif
    ObjectReference selfRef = Self as ObjectReference
    if selfRef == (Game.GetFormFromFile(0x000035C4, "Vault13Chronicles.esp") as ObjectReference)
        if Math.Abs(Self.GetPositionX() + 2760.0) > 450.0 || Math.Abs(Self.GetPositionY() - 5480.0) > 450.0
            if !Self.IsInCombat()
                Self.SetPosition(-2760.0, 5480.0, 86.0)
            endif
        endif
    elseif selfRef == (Game.GetFormFromFile(0x000035C5, "Vault13Chronicles.esp") as ObjectReference)
        if Math.Abs(Self.GetPositionX() + 2600.0) > 450.0 || Math.Abs(Self.GetPositionY() - 5480.0) > 450.0
            if !Self.IsInCombat()
                Self.SetPosition(-2600.0, 5480.0, 86.0)
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
    if Self.IsDead() || Self.IsDisabled()
        return
    endif
    RegisterForHitEvent(Self)
    Self.EnableAI(true)
    HomeX = Self.GetPositionX()
    HomeY = Self.GetPositionY()
    HomeZ = Self.GetPositionZ()
    Self.SetValue(Game.GetAggressionAV(), 2.0)
    Self.SetValue(Game.GetConfidenceAV(), 4.0)
    Actor kPlayer = Game.GetPlayer()
    if !Self.IsDead() && kPlayer != None && !kPlayer.IsDead() && !Self.IsInCombat()
        Self.StartCombat(kPlayer)
    endif
    if Self.Is3DLoaded()
        StartTimer(1.0, 1)
    endif
EndEvent

Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
    if !Self.IsDead() && !Self.IsDisabled() && Self.Is3DLoaded() && Self.GetWorldSpace() != None
        StartTimer(1.0, 1)
    endif
EndEvent

Event OnDeath(Actor akKiller)
    CancelTimer(1)
    EffectShader redHaloFX = Game.GetFormFromFile(0x0022517C, "Fallout4.esm") as EffectShader
    EffectShader targetScanFX = Game.GetFormFromFile(0x00247A3F, "Fallout4.esm") as EffectShader
    if redHaloFX != None
        redHaloFX.Stop(Self)
    endif
    if targetScanFX != None
        targetScanFX.Stop(Self)
    endif
EndEvent

Event OnTimer(int aiTimerID)
    if aiTimerID != 1
        return
    endif
    if Self.IsDead() || Self.IsDisabled()
        return
    endif
    if !Self.Is3DLoaded()
        Actor pWait = Game.GetPlayer()
        if pWait != None && Self.GetWorldSpace() != None && pWait.GetWorldSpace() == Self.GetWorldSpace()
            StartTimer(3.0, 1)
        endif
        return
    endif

    Self.EnableAI(true)

    Actor kPlayer = Game.GetPlayer()
    if kPlayer == None
        StartTimer(2.5, 1)
        return
    endif

    float fDist = Self.GetDistance(kPlayer)
    if fDist <= 4500.0
        Form sensorBase = Game.GetFormFromFile(0x00001456, "Vault13Chronicles.esp")
        if sensorBase != None && kPlayer.GetItemCount(sensorBase) > 0
            EffectShader redHaloFX = Game.GetFormFromFile(0x0022517C, "Fallout4.esm") as EffectShader
            EffectShader targetScanFX = Game.GetFormFromFile(0x00247A3F, "Fallout4.esm") as EffectShader
            if redHaloFX != None
                redHaloFX.Play(Self, 4.5)
            endif
            if targetScanFX != None
                targetScanFX.Play(Self, 4.5)
            endif
        endif
    endif

    ; Interior cells use 100% native NavMesh pathfinding and AI packages
    if Self.GetWorldSpace() == None
        Self.SetValue(Game.GetAggressionAV(), 2.0)
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
        StartTimer(3.0, 1)
        return
    endif

    ObjectReference selfRefTimer = Self as ObjectReference
    ObjectReference kenjiTimer = Game.GetFormFromFile(0x000035C4, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference skullTimer = Game.GetFormFromFile(0x000035C5, "Vault13Chronicles.esp") as ObjectReference
    if selfRefTimer == kenjiTimer || selfRefTimer == skullTimer
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
        elseif Self.IsInCombat() && fDist > 220.0
            float dKMoveX = curX - LastCombatX
            float dKMoveY = curY - LastCombatY
            if (dKMoveX * dKMoveX + dKMoveY * dKMoveY) < 324.0
                StuckCombatTicks += 1
                if StuckCombatTicks >= 2
                    StuckCombatTicks = 0
                    Self.EvaluatePackage()
                    Self.PathToReference(kPlayer, 1.0)
                    Self.StartCombat(kPlayer)
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
        elseif Self.IsInCombat() && fDist > 220.0
            float dMoveX = curX - LastCombatX
            float dMoveY = curY - LastCombatY
            if (dMoveX * dMoveX + dMoveY * dMoveY) < 324.0
                StuckCombatTicks += 1
                if StuckCombatTicks >= 2
                    StuckCombatTicks = 0
                    Self.EvaluatePackage()
                    Self.PathToReference(kPlayer, 1.0)
                    Self.StartCombat(kPlayer)
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
    StartTimer(2.0, 1)
EndEvent
