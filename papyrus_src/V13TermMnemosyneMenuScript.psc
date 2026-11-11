Scriptname V13TermMnemosyneMenuScript extends ObjectReference

Function RegisterTerminalMenuEvent()
    Terminal termBase = Self.GetBaseObject() as Terminal
    if termBase != None
        RegisterForRemoteEvent(termBase, "OnMenuItemRun")
    endif
EndFunction

Event OnInit()
    RegisterTerminalMenuEvent()
EndEvent

Event OnLoad()
    RegisterTerminalMenuEvent()
EndEvent

Event OnActivate(ObjectReference akActionRef)
    RegisterTerminalMenuEvent()
    if akActionRef == Game.GetPlayer()
        Terminal barracksBase = Game.GetFormFromFile(0x0000113C, "Vault13Chronicles.esp") as Terminal
        Terminal sewerForemanBase = Game.GetFormFromFile(0x00001186, "Vault13Chronicles.esp") as Terminal
        if Self.GetBaseObject() == barracksBase
            Utility.Wait(0.35)
            if !Self.IsLocked()
                Quest q1 = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as Quest
                V13Act1QuestScript act1S = q1 as V13Act1QuestScript
                if act1S != None
                    act1S.UnlockAndOpenVault15BarracksDoors()
                endif
            endif
        elseif Self.GetBaseObject() == sewerForemanBase
            Quest q2 = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as Quest
            V13Act2QuestScript act2S = q2 as V13Act2QuestScript
            if act2S != None
                act2S.NotifySewerForemanTerminalRead()
            endif
        elseif Self.GetBaseObject() == (Game.GetFormFromFile(0x0000119E, "Vault13Chronicles.esp") as Terminal)
            Quest qT = Game.GetFormFromFile(0x00015000, "Vault13Chronicles.esp") as Quest
            V13SideQuestTardisScript sT = qT as V13SideQuestTardisScript
            if sT != None
                sT.NotifyTardisTerminalRead()
            endif
        elseif Self.GetBaseObject() == (Game.GetFormFromFile(0x000011A9, "Vault13Chronicles.esp") as Terminal)
            Quest qNuka = Game.GetFormFromFile(0x00016000, "Vault13Chronicles.esp") as Quest
            V13SideQuestTardisScript sNuka = qNuka as V13SideQuestTardisScript
            if sNuka != None
                sNuka.NotifyTardisTerminalRead()
            endif
        elseif Self.GetBaseObject() == (Game.GetFormFromFile(0x000011AA, "Vault13Chronicles.esp") as Terminal)
            Quest qAlien = Game.GetFormFromFile(0x00017000, "Vault13Chronicles.esp") as Quest
            V13SideQuestTardisScript sAlien = qAlien as V13SideQuestTardisScript
            if sAlien != None
                sAlien.NotifyTardisTerminalRead()
            endif
        endif
    endif
EndEvent

Event Terminal.OnMenuItemRun(Terminal akSender, int auiMenuItemID, ObjectReference akTerminalRef)
    Quest q1 = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as Quest
    V13Act1QuestScript act1S = q1 as V13Act1QuestScript
    Quest q2 = Game.GetFormFromFile(0x00005000, "Vault13Chronicles.esp") as Quest
    V13Act2QuestScript act2S = q2 as V13Act2QuestScript
    Terminal mnemoBase = Game.GetFormFromFile(0x00001130, "Vault13Chronicles.esp") as Terminal
    Terminal overseerBase = Game.GetFormFromFile(0x00001131, "Vault13Chronicles.esp") as Terminal
    Terminal barracksBase = Game.GetFormFromFile(0x0000113C, "Vault13Chronicles.esp") as Terminal
    Terminal engBase = Game.GetFormFromFile(0x0000113D, "Vault13Chronicles.esp") as Terminal
    Terminal sewerForemanBase = Game.GetFormFromFile(0x00001186, "Vault13Chronicles.esp") as Terminal
    Terminal sewerSecBase = Game.GetFormFromFile(0x00001187, "Vault13Chronicles.esp") as Terminal

    if akSender == barracksBase && auiMenuItemID == 1
        if act1S != None && (q1 == None || !q1.IsRunning())
            act1S.UnlockVault15Armory()
        endif
    elseif akSender == engBase && auiMenuItemID == 3
        if act1S != None && (q1 == None || !q1.IsRunning())
            act1S.UnlockVault15CommandCenter()
        endif
    elseif akSender == overseerBase && auiMenuItemID == 3
        if act1S != None && (q1 == None || !q1.IsRunning())
            act1S.AnalyzeHydroCoreInOverseerTerminal()
        endif
    elseif akSender == overseerBase && auiMenuItemID == 5
        if act1S != None && (q1 == None || !q1.IsRunning())
            act1S.ReturnPlayerToCommonwealthFromTerminal()
        endif
    elseif akSender == sewerForemanBase && (auiMenuItemID == 1 || auiMenuItemID == 2)
        if act2S != None
            act2S.NotifySewerForemanTerminalRead()
        endif
    elseif akSender == sewerSecBase && auiMenuItemID == 3
        if act2S != None
            act2S.UnlockSewerHydraulicChamber()
        endif
    elseif (akSender == mnemoBase || akSender == None) && auiMenuItemID == 4
        if act1S != None && (q1 == None || !q1.IsRunning())
            act1S.ActivateTemporalPortal()
        elseif q1 != None && !q1.IsRunning() && q1.GetStage() < 16
            q1.SetStage(16)
        endif
    elseif (akSender == mnemoBase || akSender == None) && auiMenuItemID >= 5 && auiMenuItemID <= 11
        if act2S != None && (q1 == None || !q1.IsRunning())
            act2S.QueueMnemosyneCheckpointJump(auiMenuItemID)
        endif
    elseif (akSender == mnemoBase || akSender == None) && auiMenuItemID == 12
        if q1 == None || !q1.IsRunning()
            Quest qSide = Game.GetFormFromFile(0x00009500, "Vault13Chronicles.esp") as Quest
            V13SideQuestShadySandsScript sideS = qSide as V13SideQuestShadySandsScript
            if sideS != None
                sideS.QueueJumpToShadySands()
            endif
        endif
    elseif (akSender == mnemoBase || akSender == None) && auiMenuItemID == 13
        Quest qJ = Game.GetFormFromFile(0x00010000, "Vault13Chronicles.esp") as Quest
        V13SideQuestJunktownScript sJ = qJ as V13SideQuestJunktownScript
        if sJ != None
            sJ.QueueJumpToJunktown()
        endif
    elseif (akSender == mnemoBase || akSender == None) && auiMenuItemID == 14
        Quest qH = Game.GetFormFromFile(0x00011000, "Vault13Chronicles.esp") as Quest
        V13SideQuestHubScript sH = qH as V13SideQuestHubScript
        if sH != None
            sH.QueueJumpToHub()
        endif
    elseif (akSender == mnemoBase || akSender == None) && auiMenuItemID == 15
        Quest qK = Game.GetFormFromFile(0x00012000, "Vault13Chronicles.esp") as Quest
        V13SideQuestKhansScript sK = qK as V13SideQuestKhansScript
        if sK != None
            sK.QueueJumpToKhansPass()
        endif
    elseif (akSender == mnemoBase || akSender == None) && auiMenuItemID == 16
        Quest qG = Game.GetFormFromFile(0x00013000, "Vault13Chronicles.esp") as Quest
        V13SideQuestGlowScript sG = qG as V13SideQuestGlowScript
        if sG != None
            sG.QueueJumpToGlow()
        endif
    elseif (akSender == mnemoBase || akSender == None) && auiMenuItemID == 17
        Quest qB = Game.GetFormFromFile(0x00014000, "Vault13Chronicles.esp") as Quest
        V13SideQuestBoneyardScript sB = qB as V13SideQuestBoneyardScript
        if sB != None
            sB.QueueJumpToBoneyard()
        endif
    elseif (akSender == mnemoBase || akSender == None) && auiMenuItemID == 18
        Quest qT = Game.GetFormFromFile(0x00015000, "Vault13Chronicles.esp") as Quest
        V13SideQuestTardisScript sT = qT as V13SideQuestTardisScript
        if sT != None
            sT.QueueJumpToTardis()
        endif
    elseif (akSender == mnemoBase || akSender == None) && auiMenuItemID == 19
        Quest qNuka = Game.GetFormFromFile(0x00016000, "Vault13Chronicles.esp") as Quest
        V13SideQuestTardisScript sNuka = qNuka as V13SideQuestTardisScript
        if sNuka != None
            sNuka.QueueJumpToTardis()
        endif
    elseif (akSender == mnemoBase || akSender == None) && auiMenuItemID == 20
        Quest qAlien = Game.GetFormFromFile(0x00017000, "Vault13Chronicles.esp") as Quest
        V13SideQuestTardisScript sAlien = qAlien as V13SideQuestTardisScript
        if sAlien != None
            sAlien.QueueJumpToTardis()
        endif
    elseif (akSender == mnemoBase || akSender == None) && auiMenuItemID == 21
        Quest qGF = Game.GetFormFromFile(0x0001B000, "Vault13Chronicles.esp") as Quest
        V13SideQuestTardisScript sGF = qGF as V13SideQuestTardisScript
        if sGF != None
            sGF.QueueJumpToTardis()
        endif
    elseif (akSender == mnemoBase || akSender == None) && auiMenuItemID == 22
        Quest qBM = Game.GetFormFromFile(0x0001C000, "Vault13Chronicles.esp") as Quest
        V13SideQuestTardisScript sBM = qBM as V13SideQuestTardisScript
        if sBM != None
            sBM.QueueJumpToTardis()
        endif
    elseif (akSender == mnemoBase || akSender == None) && auiMenuItemID == 23
        Quest qPC = Game.GetFormFromFile(0x0001D000, "Vault13Chronicles.esp") as Quest
        V13SideQuestTardisScript sPC = qPC as V13SideQuestTardisScript
        if sPC != None
            sPC.QueueJumpToTardis()
        endif
    elseif akSender == Game.GetFormFromFile(0x000011B0, "Vault13Chronicles.esp") as Terminal
        Quest qGFT = Game.GetFormFromFile(0x0001B000, "Vault13Chronicles.esp") as Quest
        V13SideQuestTardisScript sGFT = qGFT as V13SideQuestTardisScript
        if sGFT != None
            sGFT.NotifyTardisTerminalRead()
        endif
    elseif akSender == Game.GetFormFromFile(0x000011B2, "Vault13Chronicles.esp") as Terminal
        Quest qBMT = Game.GetFormFromFile(0x0001C000, "Vault13Chronicles.esp") as Quest
        V13SideQuestTardisScript sBMT = qBMT as V13SideQuestTardisScript
        if sBMT != None
            sBMT.NotifyTardisTerminalRead()
        endif
    elseif akSender == Game.GetFormFromFile(0x000011B3, "Vault13Chronicles.esp") as Terminal
        Quest qPCT = Game.GetFormFromFile(0x0001D000, "Vault13Chronicles.esp") as Quest
        V13SideQuestTardisScript sPCT = qPCT as V13SideQuestTardisScript
        if sPCT != None
            sPCT.NotifyTardisTerminalRead()
        endif
    endif
EndEvent
