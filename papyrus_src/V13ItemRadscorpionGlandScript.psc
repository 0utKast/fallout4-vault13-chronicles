Scriptname V13ItemRadscorpionGlandScript extends ObjectReference

Event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)
    if akNewContainer == Game.GetPlayer()
        Form myBase = Self.GetBaseObject()
        if myBase == Game.GetFormFromFile(0x00001116, "Vault13Chronicles.esp")
            Quest qSide = Game.GetFormFromFile(0x00009500, "Vault13Chronicles.esp") as Quest
            V13SideQuestShadySandsScript sideS = qSide as V13SideQuestShadySandsScript
            if sideS != None
                sideS.NotifyRadscorpionGlandRecovered()
            endif
        elseif myBase == Game.GetFormFromFile(0x00001451, "Vault13Chronicles.esp")
            Quest qJ = Game.GetFormFromFile(0x00010000, "Vault13Chronicles.esp") as Quest
            V13SideQuestJunktownScript sJ = qJ as V13SideQuestJunktownScript
            if sJ != None
                sJ.NotifyJunktownProofRecovered()
            endif
        elseif myBase == Game.GetFormFromFile(0x00001452, "Vault13Chronicles.esp")
            Quest qH = Game.GetFormFromFile(0x00011000, "Vault13Chronicles.esp") as Quest
            V13SideQuestHubScript sH = qH as V13SideQuestHubScript
            if sH != None
                sH.NotifyHubDeedRecovered()
            endif
        elseif myBase == Game.GetFormFromFile(0x00001453, "Vault13Chronicles.esp")
            Quest qK = Game.GetFormFromFile(0x00012000, "Vault13Chronicles.esp") as Quest
            V13SideQuestKhansScript sK = qK as V13SideQuestKhansScript
            if sK != None
                sK.NotifyKhanKeyRecovered()
            endif
        elseif myBase == Game.GetFormFromFile(0x00001454, "Vault13Chronicles.esp")
            Quest qG = Game.GetFormFromFile(0x00013000, "Vault13Chronicles.esp") as Quest
            V13SideQuestGlowScript sG = qG as V13SideQuestGlowScript
            if sG != None
                sG.NotifyGlowHolodiskRecovered()
            endif
        elseif myBase == Game.GetFormFromFile(0x00001455, "Vault13Chronicles.esp")
            Quest qB = Game.GetFormFromFile(0x00014000, "Vault13Chronicles.esp") as Quest
            V13SideQuestBoneyardScript sB = qB as V13SideQuestBoneyardScript
            if sB != None
                sB.NotifyBoneyardClawRecovered()
            endif
        elseif myBase == Game.GetFormFromFile(0x00001456, "Vault13Chronicles.esp")
            Quest qT = Game.GetFormFromFile(0x00015000, "Vault13Chronicles.esp") as Quest
            V13SideQuestTardisScript sT = qT as V13SideQuestTardisScript
            if sT != None
                sT.NotifyMotionSensorRecovered()
            endif
        elseif myBase == Game.GetFormFromFile(0x00001457, "Vault13Chronicles.esp")
            Quest qNuka = Game.GetFormFromFile(0x00016000, "Vault13Chronicles.esp") as Quest
            V13SideQuestTardisScript sNuka = qNuka as V13SideQuestTardisScript
            if sNuka != None
                sNuka.NotifyMotionSensorRecovered()
            endif
        elseif myBase == Game.GetFormFromFile(0x00001458, "Vault13Chronicles.esp") || myBase == Game.GetFormFromFile(0x0000110F, "Vault13Chronicles.esp")
            Quest qAlien = Game.GetFormFromFile(0x00017000, "Vault13Chronicles.esp") as Quest
            V13SideQuestTardisScript sAlien = qAlien as V13SideQuestTardisScript
            if sAlien != None
                sAlien.NotifyMotionSensorRecovered()
            endif
        elseif myBase == Game.GetFormFromFile(0x0000145A, "Vault13Chronicles.esp")
            Quest qSyn = Game.GetFormFromFile(0x00019000, "Vault13Chronicles.esp") as Quest
            V13SideQuestJunktownSyndicateScript sSyn = qSyn as V13SideQuestJunktownSyndicateScript
            if sSyn != None
                sSyn.NotifyGizmoTapeRecovered()
            endif
        elseif myBase == Game.GetFormFromFile(0x0000145B, "Vault13Chronicles.esp")
            Quest qSynU = Game.GetFormFromFile(0x00019000, "Vault13Chronicles.esp") as Quest
            V13SideQuestJunktownSyndicateScript sSynU = qSynU as V13SideQuestJunktownSyndicateScript
            if sSynU != None
                sSynU.NotifyNealUrnRecovered()
            endif
        elseif myBase == Game.GetFormFromFile(0x0000145C, "Vault13Chronicles.esp")
            Quest qSynM = Game.GetFormFromFile(0x00019000, "Vault13Chronicles.esp") as Quest
            V13SideQuestJunktownSyndicateScript sSynM = qSynM as V13SideQuestJunktownSyndicateScript
            if sSynM != None
                sSynM.NotifyDocMorbidLedgerRecovered()
            endif
        elseif myBase == Game.GetFormFromFile(0x0000145E, "Vault13Chronicles.esp")
            Quest qHubSyn = Game.GetFormFromFile(0x0001A000, "Vault13Chronicles.esp") as Quest
            V13SideQuestHubSyndicateScript sHubSyn = qHubSyn as V13SideQuestHubSyndicateScript
            if sHubSyn != None
                sHubSyn.NotifyMutantHolodiskRecovered()
            endif
        elseif myBase == Game.GetFormFromFile(0x0000145F, "Vault13Chronicles.esp")
            Quest qHubSynD = Game.GetFormFromFile(0x0001A000, "Vault13Chronicles.esp") as Quest
            V13SideQuestHubSyndicateScript sHubSynD = qHubSynD as V13SideQuestHubSyndicateScript
            if sHubSynD != None
                sHubSynD.NotifyDeckerLedgerRecovered()
            endif
        elseif myBase == Game.GetFormFromFile(0x00001460, "Vault13Chronicles.esp")
            Quest qGF = Game.GetFormFromFile(0x0001B000, "Vault13Chronicles.esp") as Quest
            V13SideQuestTardisScript sGF = qGF as V13SideQuestTardisScript
            if sGF != None
                sGF.NotifyMotionSensorRecovered()
            endif
        elseif myBase == Game.GetFormFromFile(0x00001461, "Vault13Chronicles.esp") || myBase == Game.GetFormFromFile(0x00001117, "Vault13Chronicles.esp")
            Quest qBM = Game.GetFormFromFile(0x0001C000, "Vault13Chronicles.esp") as Quest
            V13SideQuestTardisScript sBM = qBM as V13SideQuestTardisScript
            if sBM != None
                sBM.NotifyMotionSensorRecovered()
            endif
        elseif myBase == Game.GetFormFromFile(0x00001462, "Vault13Chronicles.esp")
            Quest qPC = Game.GetFormFromFile(0x0001D000, "Vault13Chronicles.esp") as Quest
            V13SideQuestTardisScript sPC = qPC as V13SideQuestTardisScript
            if sPC != None
                sPC.NotifyMotionSensorRecovered()
            endif
        endif
    endif
EndEvent
