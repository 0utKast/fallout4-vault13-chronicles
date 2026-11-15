Scriptname V13MutantInvasionScript extends Quest

float fCampaignStartDay = -1.0
bool bVatsDestroyed = False
bool bNecropolisFallen = False
bool bHubFallen = False
bool bBoneyardFallen = False
bool bJunktownFallen = False
bool bShadySandsFallen = False

bool bRobeGiftedByMalachi = False
bool bRangerRewardGiven = False
bool bTrentSuppliesGiven = False
bool bFishermanGiftGiven = False
bool bViperCodexFound = False
bool bUnityRadioFound = False
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

Function ForceAllInvasionAliases()
    ForceQuestAlias(0, 0x00003644)
    ForceQuestAlias(1, 0x00003649)
    ForceQuestAlias(2, 0x00003005)
    ForceQuestAlias(3, 0x00002003)
    ForceQuestAlias(4, 0x00003419)
    ForceQuestAlias(5, 0x00002144)
    ForceQuestAlias(6, 0x00003501)
    ForceQuestAlias(7, 0x00002C03)
    ForceQuestAlias(9, 0x00003646)
    ForceQuestAlias(10, 0x0000364B)
EndFunction

bool Function HasSettlementFallen(int aiSettlementID)
    ; 1=Necropolis, 2=Hub, 3=Boneyard, 4=Junktown, 5=ShadySands
    if aiSettlementID == 1
        return bNecropolisFallen
    elseif aiSettlementID == 2
        return bHubFallen
    elseif aiSettlementID == 3
        return bBoneyardFallen
    elseif aiSettlementID == 4
        return bJunktownFallen
    elseif aiSettlementID == 5
        return bShadySandsFallen
    endif
    return False
EndFunction

Function FailSideQuestByInvasion(Quest akQuest, string asQuestTitle, string asSettlementName)
    if akQuest == None || akQuest.IsCompleted()
        return
    endif
    bool hadDisplayedObj = False
    int objIdx = 5
    while objIdx <= 45
        if akQuest.IsObjectiveDisplayed(objIdx) && !akQuest.IsObjectiveCompleted(objIdx)
            akQuest.SetObjectiveFailed(objIdx, True)
            hadDisplayedObj = True
        endif
        objIdx += 1
    endwhile
    int alIdx = 0
    while alIdx < 14
        ReferenceAlias rAl = akQuest.GetAlias(alIdx) as ReferenceAlias
        if rAl != None && rAl.GetReference() != None
            rAl.Clear()
        endif
        alIdx += 1
    endwhile
    if !akQuest.IsRunning()
        akQuest.Start()
    endif
    akQuest.SetActive(False)
    akQuest.CompleteQuest()
    akQuest.Stop()
    if hadDisplayedObj
        Debug.Notification("[Invasión Mutante] " + asSettlementName + " ha caído: la misión '" + asQuestTitle + "' ha fracasado.")
    else
        Debug.Notification("[Invasión Mutante] " + asSettlementName + " ha sido ocupado: '" + asQuestTitle + "' ya no está disponible.")
    endif
EndFunction

Function CheckMutantInvasionCalendar()
    Actor player = Game.GetPlayer()
    if player == None
        return
    endif
    Quest qAct4 = Game.GetFormFromFile(0x00007000, "Vault13Chronicles.esp") as Quest
    if qAct4 != None && qAct4.GetStage() >= 30
        bVatsDestroyed = True
        return
    endif
    if bVatsDestroyed
        return
    endif

    WorldSpace ws2161 = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    Quest qAct1 = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as Quest
    if fCampaignStartDay < 0.0
        if (ws2161 != None && player.GetWorldSpace() == ws2161) || (qAct1 != None && qAct1.GetStage() >= 18)
            fCampaignStartDay = Utility.GetCurrentGameTime()
        else
            return
        endif
    endif

    float elapsedDays = Utility.GetCurrentGameTime() - fCampaignStartDay
    if elapsedDays < 0.0
        fCampaignStartDay = Utility.GetCurrentGameTime()
        elapsedDays = 0.0
    endif

    float caravanAcceleration = 0.0
    Quest qHubSyn = Game.GetFormFromFile(0x0001A000, "Vault13Chronicles.esp") as Quest
    V13SideQuestHubSyndicateScript sHubSyn = qHubSyn as V13SideQuestHubSyndicateScript
    Quest qWaterMer = Game.GetFormFromFile(0x0001E000, "Vault13Chronicles.esp") as Quest
    V13SideQuestWaterMerchantsScript sWaterMer = qWaterMer as V13SideQuestWaterMerchantsScript
    if (sHubSyn != None && sHubSyn.IsWaterCaravanHired()) || (sWaterMer != None && sWaterMer.IsWaterCaravanHired())
        caravanAcceleration = 20.0
    endif

    ; 1. Día 110 (Canon 1997): Represalia mutante sobre Necrópolis
    Quest qAct2 = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as Quest
    if !bNecropolisFallen && elapsedDays >= 110.0 && qAct2 != None && qAct2.GetStage() >= 30
        bNecropolisFallen = True
        Actor inv1 = Game.GetFormFromFile(0x00003640, "Vault13Chronicles.esp") as Actor
        Actor inv2 = Game.GetFormFromFile(0x00003641, "Vault13Chronicles.esp") as Actor
        if inv1 != None
            inv1.EnableNoWait()
        endif
        if inv2 != None
            inv2.EnableNoWait()
        endif
        Actor setGhoul = Game.GetFormFromFile(0x00002E11, "Vault13Chronicles.esp") as Actor
        Actor garretGhoul = Game.GetFormFromFile(0x00002E12, "Vault13Chronicles.esp") as Actor
        Actor setGuard1 = Game.GetFormFromFile(0x00002E13, "Vault13Chronicles.esp") as Actor
        Actor setGuard2 = Game.GetFormFromFile(0x00002E14, "Vault13Chronicles.esp") as Actor
        if setGhoul != None && !setGhoul.IsDead()
            setGhoul.DisableNoWait()
        endif
        if garretGhoul != None && !garretGhoul.IsDead()
            garretGhoul.DisableNoWait()
        endif
        if setGuard1 != None && !setGuard1.IsDead()
            setGuard1.DisableNoWait()
        endif
        if setGuard2 != None && !setGuard2.IsDead()
            setGuard2.DisableNoWait()
        endif
        Debug.Notification("[Invasión de la Unidad — Día 110] ¡El ejército del Maestro ha arrasado Necrópolis en represalia!")
    endif

    ; 2. Día 140 (120 con Caravana del Agua): Caída de El Eje (The Hub)
    if !bHubFallen && elapsedDays >= (140.0 - caravanAcceleration)
        bHubFallen = True
        Quest qIrwin = Game.GetFormFromFile(0x00011000, "Vault13Chronicles.esp") as Quest
        FailSideQuestByInvasion(qIrwin, "La Granja de Irwin", "El Eje")
        FailSideQuestByInvasion(qHubSyn, "Las Caravanas Desaparecidas", "El Eje")
        FailSideQuestByInvasion(qWaterMer, "Los Mercaderes del Agua", "El Eje")
    endif

    ; 3. Día 170 (150 con Caravana del Agua): Caída de Los Seguidores y Adytum (El Boneyard)
    if !bBoneyardFallen && elapsedDays >= (170.0 - caravanAcceleration)
        bBoneyardFallen = True
        Quest qBlades = Game.GetFormFromFile(0x00014000, "Vault13Chronicles.esp") as Quest
        Quest qAdytumWar = Game.GetFormFromFile(0x000D2000, "Vault13Chronicles.esp") as Quest
        Quest qAdytumForge = Game.GetFormFromFile(0x000D3000, "Vault13Chronicles.esp") as Quest
        Quest qFollowersSpy = Game.GetFormFromFile(0x000D4000, "Vault13Chronicles.esp") as Quest
        FailSideQuestByInvasion(qBlades, " Nido Sanguinario de Adytum", "El Boneyard")
        FailSideQuestByInvasion(qAdytumWar, "Guerra en Adytum", "El Boneyard")
        FailSideQuestByInvasion(qAdytumForge, "La Forja de Adytum", "El Boneyard")
        FailSideQuestByInvasion(qFollowersSpy, "Sombra en la Biblioteca", "El Boneyard")
    endif

    ; 4. Día 200 (180 con Caravana del Agua): Caída de Junktown (Ciudad Chatarra)
    if !bJunktownFallen && elapsedDays >= (200.0 - caravanAcceleration)
        bJunktownFallen = True
        Quest qJunktown = Game.GetFormFromFile(0x00010000, "Vault13Chronicles.esp") as Quest
        Quest qJunkSyn = Game.GetFormFromFile(0x00019000, "Vault13Chronicles.esp") as Quest
        FailSideQuestByInvasion(qJunktown, "Justicia en Junktown", "Junktown")
        FailSideQuestByInvasion(qJunkSyn, "Sombras sobre Ciudad Chatarra", "Junktown")
    endif

    ; 5. Día 230 (210 con Caravana del Agua): Caída de Shady Sands
    if !bShadySandsFallen && elapsedDays >= (230.0 - caravanAcceleration)
        bShadySandsFallen = True
        Quest qShady = Game.GetFormFromFile(0x00009500, "Vault13Chronicles.esp") as Quest
        Quest qTandi = Game.GetFormFromFile(0x00018000, "Vault13Chronicles.esp") as Quest
        FailSideQuestByInvasion(qShady, "Plaga de Mutascorpiones", "Shady Sands")
        FailSideQuestByInvasion(qTandi, "El Rescate de Tandi", "Shady Sands")
    endif
EndFunction

Function GrantMalachiPurpleRobe()
    if bRobeGiftedByMalachi
        return
    endif
    bRobeGiftedByMalachi = True
    Actor player = Game.GetPlayer()
    Form purpleRobe = Game.GetFormFromFile(0x00001330, "Vault13Chronicles.esp")
    if player != None && purpleRobe != None && player.GetItemCount(purpleRobe) == 0
        player.AddItem(purpleRobe, 1, false)
    endif
    Game.RewardPlayerXP(150, false)
    Debug.Notification("[Misioneros de la Catedral] Túnica Púrpura recibida (+150 XP). Úsala para infiltrarte en Mariposa o la Catedral.")
EndFunction

Function GrantDesertRangerConvoyReward()
    if bRangerRewardGiven
        return
    endif
    bRangerRewardGiven = True
    Actor player = Game.GetPlayer()
    Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
    Form ammo556 = Game.GetFormFromFile(0x0001F278, "Fallout4.esm")
    Form stimpak = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
    if player != None
        if caps != None
            player.AddItem(caps, 400, false)
        endif
        if ammo556 != None
            player.AddItem(ammo556, 60, false)
        endif
        if stimpak != None
            player.AddItem(stimpak, 3, false)
        endif
    endif
    Game.RewardPlayerXP(250, false)
    Debug.Notification("[Rangers del Desierto] ¡Convoy liberado! (+400 Chapas, munición de 5,56 mm y +250 XP)")
EndFunction

Function GrantFishermanCoastalBlessing()
    if bFishermanGiftGiven
        return
    endif
    bFishermanGiftGiven = True
    Actor player = Game.GetPlayer()
    Form pureWater = Game.GetFormFromFile(0x000366C0, "Fallout4.esm")
    Form nukaCola = Game.GetFormFromFile(0x0004835F, "Fallout4.esm")
    if player != None
        if pureWater != None
            player.AddItem(pureWater, 4, false)
        endif
        if nukaCola != None
            player.AddItem(nukaCola, 2, false)
        endif
    endif
    Game.RewardPlayerXP(120, false)
    Debug.Notification("[Costa del Pacífico] El viejo pescador compartió sus provisiones contigo (+4 Aguas Purificadas, +2 Nuka-Cola, +120 XP).")
EndFunction

Function NotifyViperCodexRecovered()
    if bViperCodexFound
        return
    endif
    bViperCodexFound = True
    Game.RewardPlayerXP(200, false)
    Debug.Notification("[Encuentro del Desierto] ¡Códice Ofidio de los Víboras recuperado del altar ritual! (+200 XP)")
EndFunction

Function NotifyUnityRadioRecovered()
    if bUnityRadioFound
        return
    endif
    bUnityRadioFound = True
    Game.RewardPlayerXP(150, false)
    Debug.Notification("[Unidad] ¡Transmisor de Radio de Patrulla Mutante obtenido! Úsalo para abrir campos de fuerza en Mariposa (+150 XP).")
EndFunction

Function BindInvasionAndEncounterListeners()
    if !Self.IsRunning()
        Self.Start()
    endif
    if Self.GetStage() < 10
        Self.SetStage(10)
    endif
    Actor player = Game.GetPlayer()
    if player != None
        RegisterForRemoteEvent(player, "OnPlayerLoadGame")
        RegisterForRemoteEvent(player, "OnLocationChange")
    endif
    ObjectReference malachiRef = Game.GetFormFromFile(0x00003644, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference ezequielRef = Game.GetFormFromFile(0x00003646, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference trentRef = Game.GetFormFromFile(0x00003649, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference fisherRef = Game.GetFormFromFile(0x0000364B, "Vault13Chronicles.esp") as ObjectReference
    if malachiRef != None
        RegisterForRemoteEvent(malachiRef, "OnActivate")
    endif
    if ezequielRef != None
        RegisterForRemoteEvent(ezequielRef, "OnActivate")
    endif
    if trentRef != None
        RegisterForRemoteEvent(trentRef, "OnActivate")
    endif
    if fisherRef != None
        RegisterForRemoteEvent(fisherRef, "OnActivate")
    endif
    ForceAllInvasionAliases()
EndFunction

Event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
    Actor player = Game.GetPlayer()
    if akActionRef != player || player == None
        return
    endif
    ObjectReference malachiRef = Game.GetFormFromFile(0x00003644, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference ezequielRef = Game.GetFormFromFile(0x00003646, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference trentRef = Game.GetFormFromFile(0x00003649, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference fisherRef = Game.GetFormFromFile(0x0000364B, "Vault13Chronicles.esp") as ObjectReference

    ForceAllInvasionAliases()
    if akSender == malachiRef
        Actor malAct = malachiRef as Actor
        if malAct != None && !malAct.IsDead() && !malAct.IsInCombat()
            sceneWaitTicks = 0
            StartTimer(1.2, 501)
        endif
    elseif akSender == ezequielRef
        Actor ezAct = ezequielRef as Actor
        if ezAct != None && !ezAct.IsDead() && !ezAct.IsInCombat()
            Actor convoyMutant = Game.GetFormFromFile(0x00003648, "Vault13Chronicles.esp") as Actor
            if convoyMutant != None && convoyMutant.IsDead()
                GrantDesertRangerConvoyReward()
            endif
            sceneWaitTicks = 0
            StartTimer(1.2, 502)
        endif
    elseif akSender == trentRef
        Actor trAct = trentRef as Actor
        if trAct != None && !trAct.IsDead()
            Topic grTop3 = Game.GetFormFromFile(0x000D5001, "Vault13Chronicles.esp") as Topic
            if grTop3 != None && !trAct.IsTalking()
                trAct.Say(grTop3, None, false, None)
            endif
            if !bTrentSuppliesGiven
                bTrentSuppliesGiven = True
                Form stimpak = Game.GetFormFromFile(0x00023736, "Fallout4.esm")
                Form fusionCell = Game.GetFormFromFile(0x000C1897, "Fallout4.esm")
                if stimpak != None
                    player.AddItem(stimpak, 3, false)
                endif
                if fusionCell != None
                    player.AddItem(fusionCell, 24, false)
                endif
                Game.RewardPlayerXP(150, false)
                Debug.Notification("[Trent] '¡Eran invisibles! ¡Cuidado en la cresta noroeste!' (+3 Estimulantes, +24 Células de Fusión, +150 XP)")
            endif
        endif
    elseif akSender == fisherRef
        Actor fiAct = fisherRef as Actor
        if fiAct != None && !fiAct.IsDead() && !fiAct.IsInCombat()
            sceneWaitTicks = 0
            StartTimer(1.2, 503)
        endif
    endif
EndEvent

Event OnInit()
    BindInvasionAndEncounterListeners()
    StartTimer(15.0, 500)
EndEvent

Event OnQuestInit()
    BindInvasionAndEncounterListeners()
    StartTimer(15.0, 500)
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
    BindInvasionAndEncounterListeners()
    StartTimer(10.0, 500)
EndEvent

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
    CheckMutantInvasionCalendar()
EndEvent

Event OnStageSet(int auiStageID, int auiItemID)
    if auiStageID == 12
        GrantMalachiPurpleRobe()
    elseif auiStageID == 14
        Actor convoyMutant = Game.GetFormFromFile(0x00003648, "Vault13Chronicles.esp") as Actor
        if convoyMutant != None && convoyMutant.IsDead()
            GrantDesertRangerConvoyReward()
        endif
    elseif auiStageID == 16
        GrantFishermanCoastalBlessing()
    endif
EndEvent

Event OnTimer(int aiTimerID)
    if aiTimerID == 500
        CheckMutantInvasionCalendar()
        if !bVatsDestroyed
            StartTimer(30.0, 500)
        endif
    elseif aiTimerID == 501
        Scene malScn = Game.GetFormFromFile(0x000D5100, "Vault13Chronicles.esp") as Scene
        Actor malAct = Game.GetFormFromFile(0x00003644, "Vault13Chronicles.esp") as Actor
        if malScn != None && malAct != None && !malAct.IsDead()
            if !malScn.IsPlaying() && !Utility.IsInMenuMode() && !malAct.IsInDialogueWithPlayer() && !malAct.IsTalking()
                ForceAllInvasionAliases()
                malScn.Start()
            endif
        endif
    elseif aiTimerID == 502
        Scene ezScn = Game.GetFormFromFile(0x000D5101, "Vault13Chronicles.esp") as Scene
        Actor ezAct = Game.GetFormFromFile(0x00003646, "Vault13Chronicles.esp") as Actor
        if ezScn != None && ezAct != None && !ezAct.IsDead()
            if !ezScn.IsPlaying() && !Utility.IsInMenuMode() && !ezAct.IsInDialogueWithPlayer() && !ezAct.IsTalking()
                ForceAllInvasionAliases()
                ezScn.Start()
            endif
        endif
    elseif aiTimerID == 503
        Scene fiScn = Game.GetFormFromFile(0x000D5102, "Vault13Chronicles.esp") as Scene
        Actor fiAct = Game.GetFormFromFile(0x0000364B, "Vault13Chronicles.esp") as Actor
        if fiScn != None && fiAct != None && !fiAct.IsDead()
            if !fiScn.IsPlaying() && !Utility.IsInMenuMode() && !fiAct.IsInDialogueWithPlayer() && !fiAct.IsTalking()
                ForceAllInvasionAliases()
                fiScn.Start()
            endif
        endif
    endif
EndEvent
