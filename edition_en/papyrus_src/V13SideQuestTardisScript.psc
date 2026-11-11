Scriptname V13SideQuestTardisScript extends Quest

bool bDematerializing = False
bool bDematerialized = False
bool bRewardGranted = False
bool bNukaCapsStocked = False
bool bStg20Notified = False
bool bStg25Notified = False
bool bMenuJumpBusy = False

int Function GetEncounterType()
    Quest qNuka = Game.GetFormFromFile(0x00016000, "Vault13Chronicles.esp") as Quest
    if Self == qNuka
        return 2
    endif
    Quest qAlien = Game.GetFormFromFile(0x00017000, "Vault13Chronicles.esp") as Quest
    if Self == qAlien
        return 3
    endif
    Quest qGF = Game.GetFormFromFile(0x0001B000, "Vault13Chronicles.esp") as Quest
    if Self == qGF
        return 4
    endif
    Quest qBM = Game.GetFormFromFile(0x0001C000, "Vault13Chronicles.esp") as Quest
    if Self == qBM
        return 5
    endif
    Quest qPC = Game.GetFormFromFile(0x0001D000, "Vault13Chronicles.esp") as Quest
    if Self == qPC
        return 6
    endif
    return 1
EndFunction

Function ForceQuestAlias(int aiAliasID, int aiFormID)
    ObjectReference targetRef = Game.GetFormFromFile(aiFormID, "Vault13Chronicles.esp") as ObjectReference
    ReferenceAlias al = Self.GetAlias(aiAliasID) as ReferenceAlias
    if al != None && targetRef != None
        if al.GetReference() != targetRef
            al.ForceRefTo(targetRef)
        endif
    endif
EndFunction

Function ForceAllTardisAliases()
    int encType = GetEncounterType()
    if encType == 2
        ForceQuestAlias(0, 0x00003530)
        ForceQuestAlias(1, 0x00003531)
        ForceQuestAlias(2, 0x00003005)
        ForceQuestAlias(3, 0x00002003)
        ForceQuestAlias(4, 0x00003529)
        ForceQuestAlias(5, 0x00002101)
        ForceQuestAlias(6, 0x00003501)
        ForceQuestAlias(7, 0x00002206)
        ForceQuestAlias(8, 0x00002035)
        ForceQuestAlias(9, 0x00003532)
    elseif encType == 3
        ForceQuestAlias(0, 0x00003540)
        ForceQuestAlias(1, 0x00003542)
        ForceQuestAlias(2, 0x00003005)
        ForceQuestAlias(3, 0x00002003)
        ForceQuestAlias(4, 0x0000352A)
        ForceQuestAlias(5, 0x00002101)
        ForceQuestAlias(6, 0x00003501)
        ForceQuestAlias(7, 0x00002206)
        ForceQuestAlias(8, 0x00002035)
        ForceQuestAlias(9, 0x00003544)
    elseif encType == 4
        ForceQuestAlias(0, 0x00003561)
        ForceQuestAlias(1, 0x00003560)
        ForceQuestAlias(2, 0x00003005)
        ForceQuestAlias(3, 0x00002003)
        ForceQuestAlias(4, 0x0000352B)
        ForceQuestAlias(5, 0x00002101)
        ForceQuestAlias(6, 0x00003501)
        ForceQuestAlias(7, 0x00002206)
        ForceQuestAlias(8, 0x00002035)
        ForceQuestAlias(9, 0x00003562)
    elseif encType == 5
        ForceQuestAlias(0, 0x00003565)
        ForceQuestAlias(1, 0x00003566)
        ForceQuestAlias(2, 0x00003005)
        ForceQuestAlias(3, 0x00002003)
        ForceQuestAlias(4, 0x0000352C)
        ForceQuestAlias(5, 0x00002101)
        ForceQuestAlias(6, 0x00003501)
        ForceQuestAlias(7, 0x00002206)
        ForceQuestAlias(8, 0x00002035)
        ForceQuestAlias(9, 0x00003567)
    elseif encType == 6
        ForceQuestAlias(0, 0x00003570)
        ForceQuestAlias(1, 0x00003571)
        ForceQuestAlias(2, 0x00003005)
        ForceQuestAlias(3, 0x00002003)
        ForceQuestAlias(4, 0x0000352D)
        ForceQuestAlias(5, 0x00002101)
        ForceQuestAlias(6, 0x00003501)
        ForceQuestAlias(7, 0x00002206)
        ForceQuestAlias(8, 0x00002035)
        ForceQuestAlias(9, 0x00003572)
    else
        ForceQuestAlias(0, 0x000035F0)
        ForceQuestAlias(1, 0x000035F2)
        ForceQuestAlias(2, 0x00003005)
        ForceQuestAlias(3, 0x00002003)
        ForceQuestAlias(4, 0x00003528)
        ForceQuestAlias(5, 0x00002101)
        ForceQuestAlias(6, 0x00003501)
        ForceQuestAlias(7, 0x00002206)
        ForceQuestAlias(8, 0x00002035)
        ForceQuestAlias(9, 0x000035F4)
    endif
EndFunction

int Function ComputeFallout1NukaTruckCaps()
    Actor player = Game.GetPlayer()
    int luckVal = 5
    if player != None
        luckVal = player.GetValue(Game.GetLuckAV()) as int
    endif
    if luckVal < 1
        luckVal = 1
    elseif luckVal > 10
        luckVal = 10
    endif
    int totalCaps = 1000 + (luckVal * 976)
    if luckVal >= 10
        totalCaps = 10765
    endif
    return totalCaps
EndFunction

Function RefreshTardisEncounterLayout()
    int encType = GetEncounterType()
    if encType == 2
        ObjectReference wreckRef = Game.GetFormFromFile(0x00003530, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference crateRef = Game.GetFormFromFile(0x00003531, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference termRef2 = Game.GetFormFromFile(0x00003532, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference docRef2 = Game.GetFormFromFile(0x00003533, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference deskRef2 = Game.GetFormFromFile(0x00003534, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference legCabRef = Game.GetFormFromFile(0x00003535, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference legTrlRef = Game.GetFormFromFile(0x00003536, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference trlRef2 = Game.GetFormFromFile(0x00003550, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference cabRef2 = Game.GetFormFromFile(0x00003551, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference signRef1 = Game.GetFormFromFile(0x00003552, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference signRef2 = Game.GetFormFromFile(0x00003553, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference machRef2 = Game.GetFormFromFile(0x00003554, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference decalRef = Game.GetFormFromFile(0x00003555, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference machRef3 = Game.GetFormFromFile(0x00003556, "Vault13Chronicles.esp") as ObjectReference
        if legCabRef != None && !legCabRef.IsDisabled()
            legCabRef.DisableNoWait()
        endif
        if legTrlRef != None && !legTrlRef.IsDisabled()
            legTrlRef.DisableNoWait()
        endif
        if signRef1 != None && !signRef1.IsDisabled()
            signRef1.DisableNoWait()
        endif
        if signRef2 != None && !signRef2.IsDisabled()
            signRef2.DisableNoWait()
        endif
        if deskRef2 != None && deskRef2.IsDisabled()
            deskRef2.EnableNoWait()
        endif
        if termRef2 != None && termRef2.IsDisabled()
            termRef2.EnableNoWait()
        endif
        if docRef2 != None && docRef2.Is3DLoaded() && docRef2.GetContainer() == None
            docRef2.SetPosition(4405.0, -5644.0, 104.5)
        endif
        if wreckRef != None && wreckRef.IsDisabled()
            wreckRef.EnableNoWait()
        endif
        if trlRef2 != None && trlRef2.IsDisabled()
            trlRef2.EnableNoWait()
        endif
        if cabRef2 != None && cabRef2.IsDisabled()
            cabRef2.EnableNoWait()
        endif
        if decalRef != None && decalRef.IsDisabled()
            decalRef.EnableNoWait()
        endif
        if machRef2 != None && machRef2.IsDisabled()
            machRef2.EnableNoWait()
        endif
        if machRef3 != None && machRef3.IsDisabled()
            machRef3.EnableNoWait()
        endif
        if crateRef != None
            if crateRef.IsDisabled()
                crateRef.EnableNoWait()
            endif
            if Math.Abs(crateRef.GetPositionX() - 4750.0) > 15.0 || Math.Abs(crateRef.GetPositionY() - (-5520.0)) > 15.0
                crateRef.SetPosition(4750.0, -5520.0, 48.0)
            endif
            if !bNukaCapsStocked && !bRewardGranted && Self.GetStage() < 30
                bNukaCapsStocked = True
                Form capsForm = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
                int targetCaps = ComputeFallout1NukaTruckCaps()
                int curCaps = crateRef.GetItemCount(capsForm)
                if capsForm != None && curCaps < targetCaps
                    crateRef.AddItem(capsForm, targetCaps - curCaps, True)
                endif
            endif
        endif
        return
    elseif encType == 3
        ObjectReference ufoRef = Game.GetFormFromFile(0x00003540, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference ufoLight = Game.GetFormFromFile(0x00003541, "Vault13Chronicles.esp") as ObjectReference
        Actor alien1 = Game.GetFormFromFile(0x00003542, "Vault13Chronicles.esp") as Actor
        Actor alien2 = Game.GetFormFromFile(0x00003543, "Vault13Chronicles.esp") as Actor
        ObjectReference termRef3 = Game.GetFormFromFile(0x00003544, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference docRef3 = Game.GetFormFromFile(0x00003545, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference deskRef3 = Game.GetFormFromFile(0x00003546, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference elvisRef = Game.GetFormFromFile(0x00003547, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference blasterRef = Game.GetFormFromFile(0x00003548, "Vault13Chronicles.esp") as ObjectReference
        if deskRef3 != None && deskRef3.IsDisabled()
            deskRef3.EnableNoWait()
        endif
        if termRef3 != None && termRef3.IsDisabled()
            termRef3.EnableNoWait()
        endif
        if docRef3 != None && docRef3.Is3DLoaded() && docRef3.GetContainer() == None
            docRef3.SetPosition(-7815.0, 7336.0, 216.5)
        endif
        if ufoRef != None && ufoRef.IsDisabled()
            ufoRef.EnableNoWait()
        endif
        if ufoLight != None && ufoLight.IsDisabled()
            ufoLight.EnableNoWait()
        endif
        if alien1 != None
            if alien1.IsDisabled()
                alien1.EnableNoWait()
            endif
            if !alien1.IsDead()
                alien1.KillSilent()
            endif
        endif
        if alien2 != None
            if alien2.IsDisabled()
                alien2.EnableNoWait()
            endif
            if !alien2.IsDead()
                alien2.KillSilent()
            endif
        endif
        Actor player3 = Game.GetPlayer()
        Form elvisBase = Game.GetFormFromFile(0x00001458, "Vault13Chronicles.esp")
        Form blasterBase = Game.GetFormFromFile(0x0000110F, "Vault13Chronicles.esp")
        if player3 != None && elvisBase != None && player3.GetItemCount(elvisBase) > 0
            if elvisRef != None && elvisRef.GetContainer() == None && !elvisRef.IsDisabled()
                elvisRef.DisableNoWait()
            endif
        endif
        if player3 != None && blasterBase != None && player3.GetItemCount(blasterBase) > 0
            if blasterRef != None && blasterRef.GetContainer() == None && !blasterRef.IsDisabled()
                blasterRef.DisableNoWait()
            endif
        endif
        return
    elseif encType == 4
        Actor victimAct = Game.GetFormFromFile(0x00003560, "Vault13Chronicles.esp") as Actor
        ObjectReference fpRef = Game.GetFormFromFile(0x00003561, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference termRef4 = Game.GetFormFromFile(0x00003562, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference docRef4 = Game.GetFormFromFile(0x00003563, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference sbRef = Game.GetFormFromFile(0x00003564, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference ftRef4 = Game.GetFormFromFile(0x0000352B, "Vault13Chronicles.esp") as ObjectReference
        if ftRef4 != None
            ftRef4.SetPosition(11840.0, -12340.0, 160.0)
            ftRef4.SetAngle(0.0, 0.0, 37.2)
        endif
        if fpRef != None
            if fpRef.IsDisabled()
                fpRef.EnableNoWait()
            endif
            if Math.Abs(fpRef.GetPositionX() - 12400.0) > 1.0 || Math.Abs(fpRef.GetPositionY() - (-11800.0)) > 1.0 || Math.Abs(fpRef.GetPositionZ() - 160.0) > 1.0 || Math.Abs(fpRef.GetAngleX()) > 0.5 || Math.Abs(fpRef.GetAngleY()) > 0.5
                fpRef.DisableNoWait()
                Utility.Wait(0.05)
                fpRef.EnableNoWait()
                fpRef.SetPosition(12400.0, -11800.0, 160.0)
                fpRef.SetAngle(0.0, 0.0, 0.0)
            endif
        endif
        ObjectReference rockA4 = Game.GetFormFromFile(0x000B1505, "Vault13Chronicles.esp") as ObjectReference
        if rockA4 != None && !rockA4.IsDisabled()
            rockA4.DisableNoWait()
        endif
        ObjectReference rockB4 = Game.GetFormFromFile(0x000B1507, "Vault13Chronicles.esp") as ObjectReference
        if rockB4 != None && !rockB4.IsDisabled()
            rockB4.DisableNoWait()
        endif
        if termRef4 != None && termRef4.IsDisabled()
            termRef4.EnableNoWait()
        endif
        if docRef4 != None && docRef4.Is3DLoaded() && docRef4.GetContainer() == None
            docRef4.SetPosition(11805.0, -12264.0, 216.5)
        endif
        Actor player4 = Game.GetPlayer()
        Form sbBase = Game.GetFormFromFile(0x00001460, "Vault13Chronicles.esp")
        if victimAct != None
            if victimAct.IsDisabled()
                victimAct.EnableNoWait()
            endif
            if victimAct.Is3DLoaded()
                Armor drifterArmor = Game.GetFormFromFile(0x0014BF50, "Fallout4.esm") as Armor
                Armor underSuit = Game.GetFormFromFile(0x00001308, "Vault13Chronicles.esp") as Armor
                if drifterArmor != None && !victimAct.IsEquipped(drifterArmor)
                    if victimAct.IsDead()
                        victimAct.Resurrect()
                        Utility.Wait(0.15)
                    endif
                    if underSuit != None
                        if victimAct.GetItemCount(underSuit) == 0
                            victimAct.AddItem(underSuit, 1, True)
                        endif
                        victimAct.EquipItem(underSuit, True, True)
                    endif
                    if victimAct.GetItemCount(drifterArmor) == 0
                        victimAct.AddItem(drifterArmor, 1, True)
                    endif
                    victimAct.EquipItem(drifterArmor, False, True)
                    if sbBase != None && victimAct.GetItemCount(sbBase) == 0 && (player4 == None || player4.GetItemCount(sbBase) == 0)
                        victimAct.AddItem(sbBase, 1, True)
                    endif
                endif
                if victimAct.GetPositionZ() < 156.0 || victimAct.GetPositionZ() > 175.0 || Math.Abs(victimAct.GetPositionX() - 12400.0) > 45.0 || Math.Abs(victimAct.GetPositionY() - (-11800.0)) > 45.0
                    victimAct.SetPosition(12400.0, -11800.0, 162.2)
                endif
                if !victimAct.IsDead()
                    victimAct.KillSilent()
                endif
            endif
        endif
        if sbRef != None && sbRef.GetContainer() == None
            if player4 != None && sbBase != None && player4.GetItemCount(sbBase) > 0
                if !sbRef.IsDisabled()
                    sbRef.DisableNoWait()
                endif
            elseif sbRef.Is3DLoaded()
                if sbRef.GetPositionZ() < 156.0 || sbRef.GetPositionZ() > 175.0 || Math.Abs(sbRef.GetPositionX() - 12435.0) > 45.0 || Math.Abs(sbRef.GetPositionY() - (-11815.0)) > 45.0
                    sbRef.SetPosition(12435.0, -11815.0, 163.0)
                endif
            endif
        endif
        return
    elseif encType == 5
        ObjectReference signRef5 = Game.GetFormFromFile(0x00003565, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference caseRef5 = Game.GetFormFromFile(0x00003566, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference termRef5 = Game.GetFormFromFile(0x00003567, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference docRef5 = Game.GetFormFromFile(0x00003568, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference deskRef5 = Game.GetFormFromFile(0x00003569, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference rrRef5 = Game.GetFormFromFile(0x0000356A, "Vault13Chronicles.esp") as ObjectReference
        if signRef5 != None
            if signRef5.IsDisabled()
                signRef5.EnableNoWait()
            endif
            if signRef5.Is3DLoaded() && (Math.Abs(signRef5.GetPositionX() - 8180.0) > 20.0 || Math.Abs(signRef5.GetPositionY() - 3080.0) > 20.0 || signRef5.GetPositionZ() < 120.0)
                signRef5.SetPosition(8180.0, 3080.0, 144.0)
            endif
        endif
        if caseRef5 != None
            if caseRef5.IsDisabled()
                caseRef5.EnableNoWait()
            endif
            if caseRef5.Is3DLoaded() && (Math.Abs(caseRef5.GetPositionX() - 8450.0) > 10.0 || Math.Abs(caseRef5.GetPositionY() - 3220.0) > 10.0)
                caseRef5.SetPosition(8450.0, 3220.0, 80.0)
                caseRef5.SetAngle(0.0, 0.0, 0.0)
            endif
        endif
        ObjectReference shack5 = Game.GetFormFromFile(0x000B0A06, "Vault13Chronicles.esp") as ObjectReference
        if shack5 != None && shack5.Is3DLoaded() && Math.Abs(shack5.GetPositionY() - 3620.0) > 10.0
            shack5.SetPosition(8400.0, 3620.0, 90.0)
            shack5.SetAngle(0.0, 0.0, 180.0)
        endif
        ObjectReference dispDesk5 = Game.GetFormFromFile(0x000B0A07, "Vault13Chronicles.esp") as ObjectReference
        if dispDesk5 != None && dispDesk5.Is3DLoaded() && Math.Abs(dispDesk5.GetPositionX() - 8360.0) > 5.0
            dispDesk5.SetPosition(8360.0, 3220.0, 80.0)
            dispDesk5.SetAngle(0.0, 0.0, 90.0)
        endif
        ObjectReference car1Ref5 = Game.GetFormFromFile(0x000B0A08, "Vault13Chronicles.esp") as ObjectReference
        if car1Ref5 != None && car1Ref5.Is3DLoaded() && (Math.Abs(car1Ref5.GetPositionX() - 8920.0) > 15.0 || Math.Abs(car1Ref5.GetPositionY() - 3560.0) > 15.0)
            car1Ref5.SetPosition(8920.0, 3560.0, 86.0)
            car1Ref5.SetAngle(0.0, 0.0, 0.0)
        endif
        ObjectReference car2Ref5 = Game.GetFormFromFile(0x000B0A09, "Vault13Chronicles.esp") as ObjectReference
        if car2Ref5 != None && car2Ref5.Is3DLoaded() && (Math.Abs(car2Ref5.GetPositionX() - 8920.0) > 15.0 || Math.Abs(car2Ref5.GetPositionY() - 3260.0) > 15.0)
            car2Ref5.SetPosition(8920.0, 3260.0, 82.0)
            car2Ref5.SetAngle(0.0, 0.0, 0.0)
        endif
        ObjectReference car3Ref5 = Game.GetFormFromFile(0x000B0A0A, "Vault13Chronicles.esp") as ObjectReference
        if car3Ref5 != None && car3Ref5.Is3DLoaded() && (Math.Abs(car3Ref5.GetPositionX() - 8920.0) > 15.0 || Math.Abs(car3Ref5.GetPositionY() - 2960.0) > 15.0)
            car3Ref5.SetPosition(8920.0, 2960.0, 86.0)
            car3Ref5.SetAngle(0.0, 0.0, 0.0)
        endif
        ObjectReference pumpRef5 = Game.GetFormFromFile(0x000B0A0B, "Vault13Chronicles.esp") as ObjectReference
        if pumpRef5 != None && pumpRef5.Is3DLoaded() && (Math.Abs(pumpRef5.GetPositionX() - 8160.0) > 15.0 || Math.Abs(pumpRef5.GetPositionY() - 3420.0) > 15.0)
            pumpRef5.SetPosition(8160.0, 3420.0, 80.0)
            pumpRef5.SetAngle(0.0, 0.0, 0.0)
        endif
        if deskRef5 != None
            if deskRef5.IsDisabled()
                deskRef5.EnableNoWait()
            endif
            if deskRef5.Is3DLoaded() && (Math.Abs(deskRef5.GetPositionX() - 8020.0) > 20.0 || Math.Abs(deskRef5.GetPositionY() - 3020.0) > 20.0)
                deskRef5.SetPosition(8020.0, 3020.0, 80.0)
            endif
        endif
        if termRef5 != None
            if termRef5.IsDisabled()
                termRef5.EnableNoWait()
            endif
            if termRef5.Is3DLoaded() && (Math.Abs(termRef5.GetPositionX() - 8010.0) > 20.0 || Math.Abs(termRef5.GetPositionY() - 3020.0) > 20.0)
                termRef5.SetPosition(8010.0, 3020.0, 80.0)
            endif
        endif
        if docRef5 != None && docRef5.Is3DLoaded() && docRef5.GetContainer() == None
            docRef5.SetPosition(8045.0, 3016.0, 136.5)
        endif
        Form oldCurbBase = Game.GetFormFromFile(0x0001EBE6, "Fallout4.esm")
        if oldCurbBase != None
            ObjectReference oldCurbRef = Game.FindClosestReferenceOfType(oldCurbBase, 8260.0, 3160.0, 80.0, 600.0)
            if oldCurbRef != None && !oldCurbRef.IsDisabled()
                oldCurbRef.DisableNoWait()
            endif
        endif
        Form oldGarageBase = Game.GetFormFromFile(0x00004B3B, "Fallout4.esm")
        if oldGarageBase != None
            ObjectReference oldGarageRef = Game.FindClosestReferenceOfType(oldGarageBase, 8520.0, 2600.0, 80.0, 900.0)
            if oldGarageRef != None && !oldGarageRef.IsDisabled()
                oldGarageRef.DisableNoWait()
            endif
        endif
        Form oldRRBase = Game.GetFormFromFile(0x000F397A, "Fallout4.esm")
        if oldRRBase != None
            ObjectReference oldRRRef = Game.FindClosestReferenceOfType(oldRRBase, 7800.0, 2600.0, 80.0, 900.0)
            if oldRRRef != None && !oldRRRef.IsDisabled()
                oldRRRef.DisableNoWait()
            endif
        endif
        Form barrelBase5 = Game.GetFormFromFile(0x00048281, "Fallout4.esm")
        if barrelBase5 != None
            ObjectReference barrelRef5 = Game.FindClosestReferenceOfType(barrelBase5, 7960.0, 3080.0, 80.0, 120.0)
            if barrelRef5 != None && barrelRef5.Is3DLoaded()
                barrelRef5.SetPosition(7900.0, 2920.0, 80.0)
            endif
        endif
        Actor player5 = Game.GetPlayer()
        Form rrBase = Game.GetFormFromFile(0x00001117, "Vault13Chronicles.esp")
        if player5 != None && rrBase != None && player5.GetItemCount(rrBase) > 0
            if rrRef5 != None && rrRef5.GetContainer() == None && !rrRef5.IsDisabled()
                rrRef5.DisableNoWait()
            endif
        endif
        return
    elseif encType == 6
        Actor patrickAct = Game.GetFormFromFile(0x00003570, "Vault13Chronicles.esp") as Actor
        ObjectReference campRef6 = Game.GetFormFromFile(0x00003571, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference termRef6 = Game.GetFormFromFile(0x00003572, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference docRef6 = Game.GetFormFromFile(0x00003573, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference deskRef6 = Game.GetFormFromFile(0x00003574, "Vault13Chronicles.esp") as ObjectReference
        if patrickAct != None
            if patrickAct.IsDisabled()
                patrickAct.EnableNoWait()
            endif
            if patrickAct.IsDead()
                patrickAct.Resurrect()
            endif
            patrickAct.SetValue(Game.GetAggressionAV(), 0.0)
            if !patrickAct.IsInCombat() && patrickAct.Is3DLoaded() && (Math.Abs(patrickAct.GetPositionX() - 2600.0) > 450.0 || Math.Abs(patrickAct.GetPositionY() - (-380.0)) > 450.0)
                patrickAct.SetPosition(2600.0, -380.0, 80.0)
            endif
        endif
        if campRef6 != None && campRef6.IsDisabled()
            campRef6.EnableNoWait()
        endif
        if deskRef6 != None && deskRef6.IsDisabled()
            deskRef6.EnableNoWait()
        endif
        if termRef6 != None && termRef6.IsDisabled()
            termRef6.EnableNoWait()
        endif
        if docRef6 != None && docRef6.Is3DLoaded() && docRef6.GetContainer() == None
            docRef6.SetPosition(2345.0, -524.0, 136.5)
        endif
        return
    endif

    ObjectReference tardisRef = Game.GetFormFromFile(0x000035F0, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference beaconRef = Game.GetFormFromFile(0x000035F1, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference sensorRef = Game.GetFormFromFile(0x000035F2, "Vault13Chronicles.esp") as ObjectReference
    Actor brahminAct = Game.GetFormFromFile(0x000035F3, "Vault13Chronicles.esp") as Actor
    ObjectReference termRef = Game.GetFormFromFile(0x000035F4, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference manualRef = Game.GetFormFromFile(0x000035F5, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference deskRef = Game.GetFormFromFile(0x000035F6, "Vault13Chronicles.esp") as ObjectReference

    if deskRef != None && deskRef.IsDisabled()
        deskRef.EnableNoWait()
    endif
    if termRef != None && termRef.IsDisabled()
        termRef.EnableNoWait()
    endif
    if manualRef != None && manualRef.Is3DLoaded() && manualRef.GetContainer() == None
        manualRef.SetPosition(-11995.0, 7156.0, 216.5)
    endif
    if brahminAct != None && !brahminAct.IsDead() && brahminAct.Is3DLoaded()
        if !brahminAct.IsInCombat() && (Math.Abs(brahminAct.GetPositionX() - (-11360.0)) > 650.0 || Math.Abs(brahminAct.GetPositionY() - 7540.0) > 650.0)
            brahminAct.SetPosition(-11360.0, 7540.0, 160.0)
        endif
    endif

    if bDematerializing
        return
    endif

    int curStage = Self.GetStage()
    if curStage < 25 && !bDematerialized
        if tardisRef != None
            if tardisRef.IsDisabled()
                tardisRef.EnableNoWait(False)
            endif
            tardisRef.SetPosition(-11600.0, 7400.0, 160.0)
            tardisRef.SetAngle(0.0, 0.0, 30.0)
        endif
        if beaconRef != None && !bDematerializing
            if beaconRef.IsDisabled()
                beaconRef.EnableNoWait()
            endif
            beaconRef.SetPosition(-11600.0, 7400.0, 424.0)
        endif
        if sensorRef != None && sensorRef.GetContainer() == None && !sensorRef.IsDisabled()
            sensorRef.DisableNoWait()
        endif
    else
        if tardisRef != None && !tardisRef.IsDisabled()
            tardisRef.DisableNoWait()
        endif
        if beaconRef != None && !beaconRef.IsDisabled()
            beaconRef.DisableNoWait()
        endif
        Actor player = Game.GetPlayer()
        Form sensorBase = Game.GetFormFromFile(0x00001456, "Vault13Chronicles.esp")
        if sensorRef != None && (player == None || sensorBase == None || player.GetItemCount(sensorBase) == 0) && curStage < 30
            if sensorRef.IsDisabled()
                sensorRef.EnableNoWait()
            endif
            sensorRef.SetPosition(-11600.0, 7400.0, 166.0)
        endif
    endif
EndFunction

Function SetupTardisListeners()
    if !Self.IsRunning() && !Self.IsCompleted()
        Self.Start()
    endif
    if Self.GetStage() < 10
        Self.SetStage(10)
    endif
    ForceAllTardisAliases()
    RefreshTardisEncounterLayout()

    int encType = GetEncounterType()
    Actor player = Game.GetPlayer()
    WorldSpace caliWorld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    bool inCaliWorld = (player != None && caliWorld != None && player.GetWorldSpace() == caliWorld)
    Self.RemoveAllInventoryEventFilters()
    if encType == 2
        Form manifestBase = Game.GetFormFromFile(0x00001457, "Vault13Chronicles.esp")
        Form nukaDoc = Game.GetFormFromFile(0x00001C80, "Vault13Chronicles.esp")
        Form capsForm = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
        if manifestBase != None
            AddInventoryEventFilter(manifestBase)
        endif
        if nukaDoc != None
            AddInventoryEventFilter(nukaDoc)
        endif
        if capsForm != None
            AddInventoryEventFilter(capsForm)
        endif
        if player != None
            RegisterForRemoteEvent(player, "OnPlayerLoadGame")
            RegisterForRemoteEvent(player, "OnLocationChange")
            RegisterForRemoteEvent(player as ObjectReference, "OnItemAdded")
        endif
        ObjectReference wreckRef = Game.GetFormFromFile(0x00003530, "Vault13Chronicles.esp") as ObjectReference
        if wreckRef != None
            RegisterForRemoteEvent(wreckRef, "OnActivate")
        endif
        ObjectReference crateRef = Game.GetFormFromFile(0x00003531, "Vault13Chronicles.esp") as ObjectReference
        if crateRef != None
            RegisterForRemoteEvent(crateRef, "OnActivate")
        endif
        ObjectReference termRef2 = Game.GetFormFromFile(0x00003532, "Vault13Chronicles.esp") as ObjectReference
        if termRef2 != None
            RegisterForRemoteEvent(termRef2, "OnActivate")
        endif
        if Self.GetStage() < 30 && inCaliWorld
            StartTimer(2.0, 98)
        endif
        return
    elseif encType == 3
        Form elvisBase = Game.GetFormFromFile(0x00001458, "Vault13Chronicles.esp")
        Form blasterBase = Game.GetFormFromFile(0x0000110F, "Vault13Chronicles.esp")
        if elvisBase != None
            AddInventoryEventFilter(elvisBase)
        endif
        if blasterBase != None
            AddInventoryEventFilter(blasterBase)
        endif
        if player != None
            RegisterForRemoteEvent(player, "OnPlayerLoadGame")
            RegisterForRemoteEvent(player, "OnLocationChange")
            RegisterForRemoteEvent(player as ObjectReference, "OnItemAdded")
        endif
        ObjectReference ufoRef = Game.GetFormFromFile(0x00003540, "Vault13Chronicles.esp") as ObjectReference
        if ufoRef != None
            RegisterForRemoteEvent(ufoRef, "OnActivate")
        endif
        ObjectReference alien1Ref = Game.GetFormFromFile(0x00003542, "Vault13Chronicles.esp") as ObjectReference
        if alien1Ref != None
            RegisterForRemoteEvent(alien1Ref, "OnActivate")
        endif
        ObjectReference alien2Ref = Game.GetFormFromFile(0x00003543, "Vault13Chronicles.esp") as ObjectReference
        if alien2Ref != None
            RegisterForRemoteEvent(alien2Ref, "OnActivate")
        endif
        ObjectReference termRef3 = Game.GetFormFromFile(0x00003544, "Vault13Chronicles.esp") as ObjectReference
        if termRef3 != None
            RegisterForRemoteEvent(termRef3, "OnActivate")
        endif
        if Self.GetStage() < 30 && inCaliWorld
            StartTimer(2.0, 98)
        endif
        return
    elseif encType == 4
        Form sbBase = Game.GetFormFromFile(0x00001460, "Vault13Chronicles.esp")
        if sbBase != None
            AddInventoryEventFilter(sbBase)
        endif
        if player != None
            RegisterForRemoteEvent(player, "OnPlayerLoadGame")
            RegisterForRemoteEvent(player, "OnLocationChange")
            if sbBase != None
                RegisterForRemoteEvent(player as ObjectReference, "OnItemAdded")
            endif
        endif
        ObjectReference victimRef = Game.GetFormFromFile(0x00003560, "Vault13Chronicles.esp") as ObjectReference
        if victimRef != None
            RegisterForRemoteEvent(victimRef, "OnActivate")
        endif
        ObjectReference fpRef = Game.GetFormFromFile(0x00003561, "Vault13Chronicles.esp") as ObjectReference
        if fpRef != None
            RegisterForRemoteEvent(fpRef, "OnActivate")
        endif
        ObjectReference termRef4 = Game.GetFormFromFile(0x00003562, "Vault13Chronicles.esp") as ObjectReference
        if termRef4 != None
            RegisterForRemoteEvent(termRef4, "OnActivate")
        endif
        if Self.GetStage() < 30 && inCaliWorld
            StartTimer(2.0, 98)
        endif
        return
    elseif encType == 5
        Form rrBase = Game.GetFormFromFile(0x00001117, "Vault13Chronicles.esp")
        Form bobKeyBase = Game.GetFormFromFile(0x00001461, "Vault13Chronicles.esp")
        if rrBase != None
            AddInventoryEventFilter(rrBase)
        endif
        if bobKeyBase != None
            AddInventoryEventFilter(bobKeyBase)
        endif
        if player != None
            RegisterForRemoteEvent(player, "OnPlayerLoadGame")
            RegisterForRemoteEvent(player, "OnLocationChange")
            RegisterForRemoteEvent(player as ObjectReference, "OnItemAdded")
        endif
        ObjectReference signRef5 = Game.GetFormFromFile(0x00003565, "Vault13Chronicles.esp") as ObjectReference
        if signRef5 != None
            RegisterForRemoteEvent(signRef5, "OnActivate")
        endif
        ObjectReference caseRef5 = Game.GetFormFromFile(0x00003566, "Vault13Chronicles.esp") as ObjectReference
        if caseRef5 != None
            RegisterForRemoteEvent(caseRef5, "OnActivate")
        endif
        ObjectReference termRef5 = Game.GetFormFromFile(0x00003567, "Vault13Chronicles.esp") as ObjectReference
        if termRef5 != None
            RegisterForRemoteEvent(termRef5, "OnActivate")
        endif
        if Self.GetStage() < 30 && inCaliWorld
            StartTimer(2.0, 98)
        endif
        return
    elseif encType == 6
        Form medBase = Game.GetFormFromFile(0x00001462, "Vault13Chronicles.esp")
        if medBase != None
            AddInventoryEventFilter(medBase)
        endif
        if player != None
            RegisterForRemoteEvent(player, "OnPlayerLoadGame")
            RegisterForRemoteEvent(player, "OnLocationChange")
            if medBase != None
                RegisterForRemoteEvent(player as ObjectReference, "OnItemAdded")
            endif
        endif
        ObjectReference patrickRef = Game.GetFormFromFile(0x00003570, "Vault13Chronicles.esp") as ObjectReference
        if patrickRef != None
            RegisterForRemoteEvent(patrickRef, "OnActivate")
        endif
        ObjectReference campRef6 = Game.GetFormFromFile(0x00003571, "Vault13Chronicles.esp") as ObjectReference
        if campRef6 != None
            RegisterForRemoteEvent(campRef6, "OnActivate")
        endif
        ObjectReference termRef6 = Game.GetFormFromFile(0x00003572, "Vault13Chronicles.esp") as ObjectReference
        if termRef6 != None
            RegisterForRemoteEvent(termRef6, "OnActivate")
        endif
        if Self.GetStage() < 30 && inCaliWorld
            StartTimer(2.0, 98)
        endif
        return
    endif

    Form sensorBase = Game.GetFormFromFile(0x00001456, "Vault13Chronicles.esp")
    if sensorBase != None
        AddInventoryEventFilter(sensorBase)
    endif
    if player != None
        RegisterForRemoteEvent(player, "OnPlayerLoadGame")
        RegisterForRemoteEvent(player, "OnLocationChange")
        if sensorBase != None
            RegisterForRemoteEvent(player as ObjectReference, "OnItemAdded")
        endif
    endif

    ObjectReference tardisRef = Game.GetFormFromFile(0x000035F0, "Vault13Chronicles.esp") as ObjectReference
    if tardisRef != None
        RegisterForRemoteEvent(tardisRef, "OnActivate")
    endif
    ObjectReference termRef = Game.GetFormFromFile(0x000035F4, "Vault13Chronicles.esp") as ObjectReference
    if termRef != None
        RegisterForRemoteEvent(termRef, "OnActivate")
    endif

    if Self.GetStage() < 30 && inCaliWorld
        StartTimer(2.0, 98)
    endif
    if inCaliWorld && sensorBase != None && player.GetItemCount(sensorBase) > 0
        StartTimer(6.0, 99)
    endif
EndFunction

Event OnInit()
    SetupTardisListeners()
EndEvent

Event OnQuestInit()
    SetupTardisListeners()
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
    if GetEncounterType() == 1
        Actor stateHolder = Game.GetFormFromFile(0x000035F3, "Vault13Chronicles.esp") as Actor
        if stateHolder != None
            stateHolder.SetValue(Game.GetLuckAV(), 0.0)
            stateHolder.SetValue(Game.GetCharismaAV(), -1.0)
        endif
    endif
    SetupTardisListeners()
EndEvent

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
    if GetEncounterType() == 1
        Actor stateHolder = Game.GetFormFromFile(0x000035F3, "Vault13Chronicles.esp") as Actor
        if stateHolder != None
            stateHolder.SetValue(Game.GetLuckAV(), 0.0)
            stateHolder.SetValue(Game.GetCharismaAV(), -1.0)
        endif
    endif
    SetupTardisListeners()
    Actor player = Game.GetPlayer()
    WorldSpace caliWorld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    if player != None && caliWorld != None && player.GetWorldSpace() == caliWorld
        if Self.GetStage() < 30
            StartTimer(1.5, 98)
        endif
        if GetEncounterType() == 1
            Form sensorBase = Game.GetFormFromFile(0x00001456, "Vault13Chronicles.esp")
            if sensorBase != None && player.GetItemCount(sensorBase) > 0
                StartTimer(2.0, 99)
            endif
        endif
    else
        CancelTimer(98)
        CancelTimer(99)
    endif
EndEvent

Function NotifyTardisTerminalRead()
    SetupTardisListeners()
    int encType = GetEncounterType()
    int mkFid = 0x00003421
    if encType == 2
        mkFid = 0x00003422
    elseif encType == 3
        mkFid = 0x00003423
    elseif encType == 4
        mkFid = 0x00003424
    elseif encType == 5
        mkFid = 0x00003425
    elseif encType == 6
        mkFid = 0x00003426
    endif
    ObjectReference mapMarker = Game.GetFormFromFile(mkFid, "Vault13Chronicles.esp") as ObjectReference
    if mapMarker != None
        mapMarker.EnableNoWait()
        mapMarker.AddToMap(True)
    endif
    if Self.GetStage() < 20
        Self.SetStage(20)
    endif
EndFunction

Function TriggerTardisDematerialization()
    if bDematerializing || bDematerialized || Self.GetStage() >= 25
        return
    endif
    bDematerializing = True
    bDematerialized = True

    int encType = GetEncounterType()
    if encType == 2
        ObjectReference mapMarker2 = Game.GetFormFromFile(0x00003422, "Vault13Chronicles.esp") as ObjectReference
        if mapMarker2 != None
            mapMarker2.EnableNoWait()
            mapMarker2.AddToMap(True)
        endif
        if Self.GetStage() < 20
            Self.SetStage(20)
        endif
        ObjectReference wreckRef = Game.GetFormFromFile(0x00003530, "Vault13Chronicles.esp") as ObjectReference
        Sound capsSfx = Game.GetFormFromFile(0x00001068, "Vault13Chronicles.esp") as Sound
        if capsSfx != None && wreckRef != None
            capsSfx.Play(wreckRef)
        elseif capsSfx != None
            capsSfx.Play(Game.GetPlayer())
        endif
        Message nukaMsg = Game.GetFormFromFile(0x00001C77, "Vault13Chronicles.esp") as Message
        if nukaMsg != None && Self.GetStage() < 25
            nukaMsg.Show()
        endif
        if Self.GetStage() < 25
            Self.SetStage(25)
        endif
        bDematerializing = False
        return
    elseif encType == 3
        ObjectReference mapMarker3 = Game.GetFormFromFile(0x00003423, "Vault13Chronicles.esp") as ObjectReference
        if mapMarker3 != None
            mapMarker3.EnableNoWait()
            mapMarker3.AddToMap(True)
        endif
        if Self.GetStage() < 20
            Self.SetStage(20)
        endif
        ObjectReference ufoRef = Game.GetFormFromFile(0x00003540, "Vault13Chronicles.esp") as ObjectReference
        Sound ufoSfx = Game.GetFormFromFile(0x0000106A, "Vault13Chronicles.esp") as Sound
        EffectShader phaseFX3 = Game.GetFormFromFile(0x002494E4, "Fallout4.esm") as EffectShader
        if ufoSfx != None && ufoRef != None
            ufoSfx.Play(ufoRef)
        elseif ufoSfx != None
            ufoSfx.Play(Game.GetPlayer())
        endif
        if phaseFX3 != None && ufoRef != None
            phaseFX3.Play(ufoRef, 2.5)
        endif
        Message alienMsg = Game.GetFormFromFile(0x00001C78, "Vault13Chronicles.esp") as Message
        if alienMsg != None
            alienMsg.Show()
        endif
        if Self.GetStage() < 25
            Self.SetStage(25)
        endif
        bDematerializing = False
        return
    elseif encType == 4
        ObjectReference mapMarker4 = Game.GetFormFromFile(0x00003424, "Vault13Chronicles.esp") as ObjectReference
        if mapMarker4 != None
            mapMarker4.EnableNoWait()
            mapMarker4.AddToMap(True)
        endif
        if Self.GetStage() < 20
            Self.SetStage(20)
        endif
        Message fpMsg = Game.GetFormFromFile(0x00001C90, "Vault13Chronicles.esp") as Message
        if fpMsg != None
            fpMsg.Show()
        endif
        if Self.GetStage() < 25
            Self.SetStage(25)
        endif
        bDematerializing = False
        return
    elseif encType == 5
        ObjectReference mapMarker5 = Game.GetFormFromFile(0x00003425, "Vault13Chronicles.esp") as ObjectReference
        if mapMarker5 != None
            mapMarker5.EnableNoWait()
            mapMarker5.AddToMap(True)
        endif
        if Self.GetStage() < 20
            Self.SetStage(20)
        endif
        Message bobMsg = Game.GetFormFromFile(0x00001C91, "Vault13Chronicles.esp") as Message
        if bobMsg != None
            bobMsg.Show()
        endif
        if Self.GetStage() < 25
            Self.SetStage(25)
        endif
        bDematerializing = False
        return
    elseif encType == 6
        ObjectReference mapMarker6 = Game.GetFormFromFile(0x00003426, "Vault13Chronicles.esp") as ObjectReference
        if mapMarker6 != None
            mapMarker6.EnableNoWait()
            mapMarker6.AddToMap(True)
        endif
        if Self.GetStage() < 20
            Self.SetStage(20)
        endif
        Message patMsg = Game.GetFormFromFile(0x00001C92, "Vault13Chronicles.esp") as Message
        if patMsg != None && Self.GetStage() < 30
            patMsg.Show()
        endif
        if Self.GetStage() < 25
            Self.SetStage(25)
        endif
        bDematerializing = False
        return
    endif

    ObjectReference mapMarker = Game.GetFormFromFile(0x00003421, "Vault13Chronicles.esp") as ObjectReference
    if mapMarker != None
        mapMarker.EnableNoWait()
        mapMarker.AddToMap(True)
    endif
    if Self.GetStage() < 20
        Self.SetStage(20)
    endif

    Message inspectMsg = Game.GetFormFromFile(0x0000115F, "Vault13Chronicles.esp") as Message
    if inspectMsg != None
        inspectMsg.Show()
    endif

    ObjectReference tardisRef = Game.GetFormFromFile(0x000035F0, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference beaconRef = Game.GetFormFromFile(0x000035F1, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference sensorRef = Game.GetFormFromFile(0x000035F2, "Vault13Chronicles.esp") as ObjectReference
    Sound tardisSfx = Game.GetFormFromFile(0x00001066, "Vault13Chronicles.esp") as Sound
    EffectShader phaseFX = Game.GetFormFromFile(0x002494E4, "Fallout4.esm") as EffectShader

    if tardisSfx != None && tardisRef != None
        tardisSfx.Play(tardisRef)
    elseif tardisSfx != None
        tardisSfx.Play(Game.GetPlayer())
    endif

    if tardisRef != None
        if phaseFX != None
            phaseFX.Play(tardisRef, 4.2)
        endif
        if beaconRef != None
            beaconRef.EnableNoWait()
        endif
        tardisRef.DisableNoWait(True)
        Utility.Wait(0.75)

        if beaconRef != None
            beaconRef.DisableNoWait()
        endif
        tardisRef.EnableNoWait(True)
        if phaseFX != None
            phaseFX.Play(tardisRef, 3.0)
        endif
        Utility.Wait(0.70)

        if beaconRef != None
            beaconRef.EnableNoWait()
        endif
        tardisRef.DisableNoWait(True)
        Utility.Wait(0.75)

        if beaconRef != None
            beaconRef.DisableNoWait()
        endif
        tardisRef.EnableNoWait(True)
        if phaseFX != None
            phaseFX.Play(tardisRef, 1.8)
        endif
        Utility.Wait(0.70)

        if beaconRef != None
            beaconRef.EnableNoWait()
        endif
        tardisRef.DisableNoWait(True)
        Utility.Wait(0.85)

        if beaconRef != None
            beaconRef.DisableNoWait()
        endif
        tardisRef.DisableNoWait(False)
    endif

    bDematerializing = False

    if sensorRef != None
        sensorRef.EnableNoWait()
        sensorRef.SetPosition(-11600.0, 7400.0, 166.0)
    endif

    if Self.GetStage() < 25
        Self.SetStage(25)
    endif
EndFunction

Function NotifyMotionSensorRecovered()
    bDematerialized = True
    if Self.GetStage() < 30
        Self.SetStage(30)
    endif
    SetupTardisListeners()
EndFunction

Event ObjectReference.OnItemAdded(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    int encType = GetEncounterType()
    if encType == 2
        Form manifestBase = Game.GetFormFromFile(0x00001457, "Vault13Chronicles.esp")
        Form nukaDoc = Game.GetFormFromFile(0x00001C80, "Vault13Chronicles.esp")
        Form capsForm = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
        ObjectReference crateRef = Game.GetFormFromFile(0x00003531, "Vault13Chronicles.esp") as ObjectReference
        if akBaseItem == manifestBase || akBaseItem == nukaDoc || (akBaseItem == capsForm && akSourceContainer == crateRef)
            NotifyMotionSensorRecovered()
        endif
    elseif encType == 3
        Form elvisBase = Game.GetFormFromFile(0x00001458, "Vault13Chronicles.esp")
        Form blasterBase = Game.GetFormFromFile(0x0000110F, "Vault13Chronicles.esp")
        if akBaseItem == elvisBase || akBaseItem == blasterBase
            if akBaseItem == elvisBase
                Debug.Notification("'A velvet painting of The King. Truly a magnificent work of art.'")
            endif
            NotifyMotionSensorRecovered()
        endif
    elseif encType == 4
        Form sbBase = Game.GetFormFromFile(0x00001460, "Vault13Chronicles.esp")
        if akBaseItem == sbBase
            NotifyMotionSensorRecovered()
        endif
    elseif encType == 5
        Form rrBase = Game.GetFormFromFile(0x00001117, "Vault13Chronicles.esp")
        Form bobKeyBase = Game.GetFormFromFile(0x00001461, "Vault13Chronicles.esp")
        if akBaseItem == rrBase || akBaseItem == bobKeyBase
            NotifyMotionSensorRecovered()
        endif
    elseif encType == 6
        Form medBase = Game.GetFormFromFile(0x00001462, "Vault13Chronicles.esp")
        if akBaseItem == medBase
            NotifyMotionSensorRecovered()
        endif
    else
        Form sensorBase = Game.GetFormFromFile(0x00001456, "Vault13Chronicles.esp")
        if akBaseItem == sensorBase
            NotifyMotionSensorRecovered()
        endif
    endif
EndEvent

Event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
    if akActionRef != Game.GetPlayer()
        return
    endif
    int encType = GetEncounterType()
    if encType == 2
        ObjectReference wreckRef = Game.GetFormFromFile(0x00003530, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference crateRef = Game.GetFormFromFile(0x00003531, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference termRef2 = Game.GetFormFromFile(0x00003532, "Vault13Chronicles.esp") as ObjectReference
        if akSender == wreckRef
            TriggerTardisDematerialization()
        elseif akSender == crateRef
            Sound capsSfx = Game.GetFormFromFile(0x00001068, "Vault13Chronicles.esp") as Sound
            if capsSfx != None
                capsSfx.Play(crateRef)
            endif
            if Self.GetStage() < 25
                Self.SetStage(25)
            endif
        elseif akSender == termRef2
            NotifyTardisTerminalRead()
        endif
        return
    elseif encType == 3
        ObjectReference ufoRef = Game.GetFormFromFile(0x00003540, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference alien1Ref = Game.GetFormFromFile(0x00003542, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference alien2Ref = Game.GetFormFromFile(0x00003543, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference termRef3 = Game.GetFormFromFile(0x00003544, "Vault13Chronicles.esp") as ObjectReference
        if akSender == ufoRef
            TriggerTardisDematerialization()
        elseif akSender == alien1Ref || akSender == alien2Ref
            Debug.Notification("'It appears to be some sort of strange creature, even for the wastes. No one alive has ever seen anything like it.'")
            if Self.GetStage() < 25
                Self.SetStage(25)
            endif
        elseif akSender == termRef3
            NotifyTardisTerminalRead()
        endif
        return
    elseif encType == 4
        ObjectReference victimRef = Game.GetFormFromFile(0x00003560, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference fpRef = Game.GetFormFromFile(0x00003561, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference termRef4 = Game.GetFormFromFile(0x00003562, "Vault13Chronicles.esp") as ObjectReference
        if akSender == fpRef
            TriggerTardisDematerialization()
        elseif akSender == victimRef
            Debug.Notification("'You see the crushed body of a traveler at the bottom of the Giant Footprint.'")
            if Self.GetStage() < 25
                Self.SetStage(25)
            endif
        elseif akSender == termRef4
            NotifyTardisTerminalRead()
        endif
        return
    elseif encType == 5
        ObjectReference signRef5 = Game.GetFormFromFile(0x00003565, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference caseRef5 = Game.GetFormFromFile(0x00003566, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference termRef5 = Game.GetFormFromFile(0x00003567, "Vault13Chronicles.esp") as ObjectReference
        if akSender == signRef5
            TriggerTardisDematerialization()
        elseif akSender == caseRef5
            if Self.GetStage() < 25
                Self.SetStage(25)
            endif
        elseif akSender == termRef5
            NotifyTardisTerminalRead()
        endif
        return
    elseif encType == 6
        ObjectReference patrickRef = Game.GetFormFromFile(0x00003570, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference campRef6 = Game.GetFormFromFile(0x00003571, "Vault13Chronicles.esp") as ObjectReference
        ObjectReference termRef6 = Game.GetFormFromFile(0x00003572, "Vault13Chronicles.esp") as ObjectReference
        if akSender == campRef6
            TriggerTardisDematerialization()
        elseif akSender == patrickRef
            if Self.GetStage() < 25
                Self.SetStage(25)
            elseif Self.GetStage() >= 30
                StartTimer(1.5, 94)
            endif
        elseif akSender == termRef6
            NotifyTardisTerminalRead()
        endif
        return
    endif

    ObjectReference tardisRef = Game.GetFormFromFile(0x000035F0, "Vault13Chronicles.esp") as ObjectReference
    ObjectReference termRef = Game.GetFormFromFile(0x000035F4, "Vault13Chronicles.esp") as ObjectReference
    if akSender == tardisRef
        TriggerTardisDematerialization()
    elseif akSender == termRef
        NotifyTardisTerminalRead()
    endif
EndEvent

Function QueueJumpToTardis()
    if bMenuJumpBusy
        return
    endif
    bMenuJumpBusy = True
    SetupTardisListeners()
    StartTimer(0.6, 95)
EndFunction

float Function EvaluateMotionSensorCandidate(Actor akCand, Actor akPlayer, EffectShader akRedHaloFX, EffectShader akTargetScanFX)
    if akCand == None || akCand == akPlayer
        return -1.0
    endif
    if akCand.IsDead() || akCand.IsDisabled()
        if akRedHaloFX != None
            akRedHaloFX.Stop(akCand)
        endif
        if akTargetScanFX != None
            akTargetScanFX.Stop(akCand)
        endif
        return -1.0
    endif
    float dist = akPlayer.GetDistance(akCand)
    if dist <= 0.0 || dist > 4500.0
        return -1.0
    endif
    bool isHostile = ((akCand as V13WastelandCreatureAIScript) != None) || akCand.IsHostileToActor(akPlayer) || (akCand.IsInCombat() && akCand.GetCombatTarget() == akPlayer)
    if !isHostile
        if akRedHaloFX != None
            akRedHaloFX.Stop(akCand)
        endif
        if akTargetScanFX != None
            akTargetScanFX.Stop(akCand)
        endif
        return -1.0
    endif
    if akRedHaloFX != None
        akRedHaloFX.Play(akCand, 6.5)
    endif
    if akTargetScanFX != None
        akTargetScanFX.Play(akCand, 6.5)
    endif
    return dist
EndFunction

Function RunPipBoyMotionSensorSweep()
    if GetEncounterType() != 1
        return
    endif
    Actor player = Game.GetPlayer()
    Form sensorBase = Game.GetFormFromFile(0x00001456, "Vault13Chronicles.esp")
    if player == None || sensorBase == None
        return
    endif
    Actor stateHolder = Game.GetFormFromFile(0x000035F3, "Vault13Chronicles.esp") as Actor
    ActorValue perAV = Game.GetFormFromFile(0x000002C3, "Fallout4.esm") as ActorValue
    bool hasSensor = (player.GetItemCount(sensorBase) > 0)
    if !hasSensor
        if stateHolder != None && stateHolder.GetValue(Game.GetAgilityAV()) == 13.0
            stateHolder.SetValue(Game.GetAgilityAV(), 1.0)
            stateHolder.SetValue(Game.GetCharismaAV(), -1.0)
            stateHolder.SetValue(Game.GetLuckAV(), 0.0)
            if perAV != None
                player.ModValue(perAV, -2.0)
            endif
            Debug.Notification("[Pip-Boy Motion Sensor] Sensor offline (-2 Perception).")
        endif
        return
    endif

    EffectShader redHaloFX = Game.GetFormFromFile(0x0022517C, "Fallout4.esm") as EffectShader
    EffectShader targetScanFX = Game.GetFormFromFile(0x00247A3F, "Fallout4.esm") as EffectShader

    if stateHolder != None && redHaloFX != None
        redHaloFX.Stop(stateHolder)
    endif

    Actor[] seenHostiles = new Actor[48]
    int hostileCount = 0
    float minDist = 99999.0

    WorldSpace v13World = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
    Cell pCell = player.GetParentCell()
    Cell cavernsCell = Game.GetFormFromFile(0x00002F00, "Vault13Chronicles.esp") as Cell
    Cell necroCell = Game.GetFormFromFile(0x00002A00, "Vault13Chronicles.esp") as Cell
    Cell v15Cell = Game.GetFormFromFile(0x00002500, "Vault13Chronicles.esp") as Cell

    if v13World != None && player.GetWorldSpace() == v13World
        int fid = 0x00003580
        while fid <= 0x0000359B
            Actor wAct = Game.GetFormFromFile(fid, "Vault13Chronicles.esp") as Actor
            float d = EvaluateMotionSensorCandidate(wAct, player, redHaloFX, targetScanFX)
            if d > 0.0 && hostileCount < 48
                seenHostiles[hostileCount] = wAct
                hostileCount += 1
                if d < minDist
                    minDist = d
                endif
            endif
            fid += 1
        endwhile
        fid = 0x000035A6
        while fid <= 0x000035A8
            Actor sAct = Game.GetFormFromFile(fid, "Vault13Chronicles.esp") as Actor
            float d = EvaluateMotionSensorCandidate(sAct, player, redHaloFX, targetScanFX)
            if d > 0.0 && hostileCount < 48
                seenHostiles[hostileCount] = sAct
                hostileCount += 1
                if d < minDist
                    minDist = d
                endif
            endif
            fid += 1
        endwhile
        int[] extBossFids = new int[8]
        extBossFids[0] = 0x000035C4
        extBossFids[1] = 0x000035C5
        extBossFids[2] = 0x000035C9
        extBossFids[3] = 0x000035CA
        extBossFids[4] = 0x000035CE
        extBossFids[5] = 0x000035CF
        extBossFids[6] = 0x000035D2
        extBossFids[7] = 0x000035D7
        int bIdx = 0
        while bIdx < 8
            Actor bAct = Game.GetFormFromFile(extBossFids[bIdx], "Vault13Chronicles.esp") as Actor
            float d = EvaluateMotionSensorCandidate(bAct, player, redHaloFX, targetScanFX)
            if d > 0.0 && hostileCount < 48
                seenHostiles[hostileCount] = bAct
                hostileCount += 1
                if d < minDist
                    minDist = d
                endif
            endif
            bIdx += 1
        endwhile
        fid = 0x000035A0
        while fid <= 0x000035A5
            Actor fAct = Game.GetFormFromFile(fid, "Vault13Chronicles.esp") as Actor
            if fAct != None && redHaloFX != None
                redHaloFX.Stop(fAct)
            endif
            fid += 1
        endwhile
        fid = 0x000035C0
        while fid <= 0x000035C3
            Actor fAct2 = Game.GetFormFromFile(fid, "Vault13Chronicles.esp") as Actor
            if fAct2 != None && redHaloFX != None
                redHaloFX.Stop(fAct2)
            endif
            fid += 1
        endwhile
    elseif cavernsCell != None && pCell == cavernsCell
        int fid = 0x00002F10
        while fid <= 0x00002F16
            Actor cAct = Game.GetFormFromFile(fid, "Vault13Chronicles.esp") as Actor
            float d = EvaluateMotionSensorCandidate(cAct, player, redHaloFX, targetScanFX)
            if d > 0.0 && hostileCount < 48
                seenHostiles[hostileCount] = cAct
                hostileCount += 1
                if d < minDist
                    minDist = d
                endif
            endif
            fid += 1
        endwhile
    elseif necroCell != None && pCell == necroCell
        int fid = 0x00002A21
        while fid <= 0x00002A24
            Actor nAct = Game.GetFormFromFile(fid, "Vault13Chronicles.esp") as Actor
            float d = EvaluateMotionSensorCandidate(nAct, player, redHaloFX, targetScanFX)
            if d > 0.0 && hostileCount < 48
                seenHostiles[hostileCount] = nAct
                hostileCount += 1
                if d < minDist
                    minDist = d
                endif
            endif
            fid += 1
        endwhile
        fid = 0x00002A60
        while fid <= 0x00002A6D
            Actor nAct2 = Game.GetFormFromFile(fid, "Vault13Chronicles.esp") as Actor
            float d = EvaluateMotionSensorCandidate(nAct2, player, redHaloFX, targetScanFX)
            if d > 0.0 && hostileCount < 48
                seenHostiles[hostileCount] = nAct2
                hostileCount += 1
                if d < minDist
                    minDist = d
                endif
            endif
            fid += 1
        endwhile
    elseif v15Cell != None && pCell == v15Cell
        int fid = 0x00002540
        while fid <= 0x00002559
            Actor vAct = Game.GetFormFromFile(fid, "Vault13Chronicles.esp") as Actor
            float d = EvaluateMotionSensorCandidate(vAct, player, redHaloFX, targetScanFX)
            if d > 0.0 && hostileCount < 48
                seenHostiles[hostileCount] = vAct
                hostileCount += 1
                if d < minDist
                    minDist = d
                endif
            endif
            fid += 1
        endwhile
        fid = 0x00002590
        while fid <= 0x000025A7
            Actor vAct2 = Game.GetFormFromFile(fid, "Vault13Chronicles.esp") as Actor
            float d = EvaluateMotionSensorCandidate(vAct2, player, redHaloFX, targetScanFX)
            if d > 0.0 && hostileCount < 48
                seenHostiles[hostileCount] = vAct2
                hostileCount += 1
                if d < minDist
                    minDist = d
                endif
            endif
            fid += 1
        endwhile
        fid = 0x000025D0
        while fid <= 0x000025E3
            Actor vAct3 = Game.GetFormFromFile(fid, "Vault13Chronicles.esp") as Actor
            float d = EvaluateMotionSensorCandidate(vAct3, player, redHaloFX, targetScanFX)
            if d > 0.0 && hostileCount < 48
                seenHostiles[hostileCount] = vAct3
                hostileCount += 1
                if d < minDist
                    minDist = d
                endif
            endif
            fid += 1
        endwhile
    endif

    int i = 0
    while i < 16
        Actor cand = Game.FindRandomActorFromRef(player, 4500.0)
        if cand != None && cand != player
            bool alreadySeen = False
            int j = 0
            while j < hostileCount
                if seenHostiles[j] == cand
                    alreadySeen = True
                    j = hostileCount
                else
                    j += 1
                endif
            endwhile
            if !alreadySeen
                float d = EvaluateMotionSensorCandidate(cand, player, redHaloFX, targetScanFX)
                if d > 0.0 && hostileCount < 48
                    seenHostiles[hostileCount] = cand
                    hostileCount += 1
                    if d < minDist
                        minDist = d
                    endif
                endif
            endif
        endif
        i += 1
    endwhile

    int minMeters = (minDist / 70.0) as int
    if minMeters < 1
        minMeters = 1
    endif
    float nowTime = Utility.GetCurrentRealTime()

    if stateHolder != None
        bool firstSweep = (stateHolder.GetValue(Game.GetAgilityAV()) != 13.0)
        if firstSweep
            stateHolder.SetValue(Game.GetAgilityAV(), 13.0)
            stateHolder.SetValue(Game.GetCharismaAV(), hostileCount as float)
            stateHolder.SetValue(Game.GetLuckAV(), nowTime)
            if perAV != None
                player.ModValue(perAV, 2.0)
            endif
            if hostileCount > 0
                Debug.Notification("[Motion Sensor] RADAR ALERT! " + hostileCount + " hostile target(s) detected at " + minMeters + " m (highlighted in red).")
            else
                Debug.Notification("[Motion Sensor] Pip-Boy 2000 ultrasonic radar active (+2 PER). No threats within 65 m.")
            endif
        else
            int lastHostiles = stateHolder.GetValue(Game.GetCharismaAV()) as int
            float lastPing = stateHolder.GetValue(Game.GetLuckAV())
            float elapsed = nowTime - lastPing
            if elapsed < 0.0
                elapsed = 999.0
            endif
            if hostileCount > 0
                if hostileCount != lastHostiles || elapsed >= 8.0
                    stateHolder.SetValue(Game.GetCharismaAV(), hostileCount as float)
                    stateHolder.SetValue(Game.GetLuckAV(), nowTime)
                    Debug.Notification("[Motion Sensor] RADAR ALERT! " + hostileCount + " hostile target(s) detected at " + minMeters + " m (highlighted in red).")
                endif
            elseif lastHostiles > 0
                stateHolder.SetValue(Game.GetCharismaAV(), 0.0)
                stateHolder.SetValue(Game.GetLuckAV(), nowTime)
                Debug.Notification("[Motion Sensor] Perimeter clear: no hostile threats within radar range.")
            endif
        endif
    elseif hostileCount > 0
        Debug.Notification("[Motion Sensor] RADAR ALERT! " + hostileCount + " hostile target(s) detected at " + minMeters + " m (highlighted in red).")
    endif
EndFunction

Function TickMotionSensorFromMainLoop()
    if GetEncounterType() != 1
        return
    endif
    Actor player = Game.GetPlayer()
    Form sensorBase = Game.GetFormFromFile(0x00001456, "Vault13Chronicles.esp")
    if player == None || sensorBase == None
        return
    endif
    if player.GetItemCount(sensorBase) > 0
        if Self.GetStage() < 30
            Self.SetStage(30)
        endif
        RunPipBoyMotionSensorSweep()
    else
        Actor stateHolder = Game.GetFormFromFile(0x000035F3, "Vault13Chronicles.esp") as Actor
        if stateHolder != None && stateHolder.GetValue(Game.GetAgilityAV()) == 13.0
            RunPipBoyMotionSensorSweep()
        endif
    endif
EndFunction

Event OnTimer(int aiTimerID)
    int encType = GetEncounterType()
    if aiTimerID == 95
        bMenuJumpBusy = False
        Actor player = Game.GetPlayer()
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
        int mkFid = 0x00003421
        int ftFid = 0x00003528
        string jumpNotice = "Traveled to Special Encounter: The Unusual Call Box (New California Desert, 2161)."
        if encType == 2
            mkFid = 0x00003422
            ftFid = 0x00003529
            jumpNotice = "Traveled to Special Encounter: Overturned Nuka-Cola Truck (Southeast of The Hub, 2161)."
        elseif encType == 3
            mkFid = 0x00003423
            ftFid = 0x0000352A
            jumpNotice = "Traveled to Special Encounter: Crashed Flying Saucer - Property of Area 51 (Southern California, 2161)."
        elseif encType == 4
            mkFid = 0x00003424
            ftFid = 0x0000352B
            jumpNotice = "Traveled to Special Encounter: Giant Godzilla Footprint (North of Shady Sands, 2161)."
        elseif encType == 5
            mkFid = 0x00003425
            ftFid = 0x0000352C
            jumpNotice = "Traveled to Special Encounter: Bob's Pre-Owned Car Mart (Southeast of Junktown, 2161)."
        elseif encType == 6
            mkFid = 0x00003426
            ftFid = 0x0000352D
            jumpNotice = "Traveled to Special Encounter: Patrick the Celt, Traveling Bard (Central Route North of The Hub, 2161)."
        endif
        ObjectReference mapMarker = Game.GetFormFromFile(mkFid, "Vault13Chronicles.esp") as ObjectReference
        if mapMarker != None
            mapMarker.EnableNoWait()
            mapMarker.AddToMap(True)
        endif
        ObjectReference ftMarker = Game.GetFormFromFile(ftFid, "Vault13Chronicles.esp") as ObjectReference
        if ftMarker != None
            player.MoveTo(ftMarker)
            RefreshTardisEncounterLayout()
            if Self.GetStage() < 20
                Self.SetStage(20)
            endif
            StartTimer(1.0, 98)
            Debug.Notification(jumpNotice)
        endif
    elseif aiTimerID == 98
        Actor player = Game.GetPlayer()
        WorldSpace v13World = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
        if Self.GetStage() >= 30 || player == None || v13World == None || player.GetWorldSpace() != v13World
            return
        endif
        RefreshTardisEncounterLayout()
        if encType == 2
            ObjectReference wreckRef = Game.GetFormFromFile(0x00003530, "Vault13Chronicles.esp") as ObjectReference
            if wreckRef != None
                float dist2 = player.GetDistance(wreckRef)
                if dist2 < 1150.0 && Self.GetStage() < 20
                    ObjectReference mapMarker2 = Game.GetFormFromFile(0x00003422, "Vault13Chronicles.esp") as ObjectReference
                    if mapMarker2 != None
                        mapMarker2.EnableNoWait()
                        mapMarker2.AddToMap(True)
                    endif
                    Self.SetStage(20)
                endif
            endif
        elseif encType == 3
            ObjectReference ufoRef = Game.GetFormFromFile(0x00003540, "Vault13Chronicles.esp") as ObjectReference
            if ufoRef != None
                float dist3 = player.GetDistance(ufoRef)
                if dist3 < 1250.0 && Self.GetStage() < 20
                    ObjectReference mapMarker3 = Game.GetFormFromFile(0x00003423, "Vault13Chronicles.esp") as ObjectReference
                    if mapMarker3 != None
                        mapMarker3.EnableNoWait()
                        mapMarker3.AddToMap(True)
                    endif
                    Self.SetStage(20)
                endif
            endif
        elseif encType == 4
            ObjectReference fpRef = Game.GetFormFromFile(0x00003561, "Vault13Chronicles.esp") as ObjectReference
            if fpRef != None
                float dist4 = player.GetDistance(fpRef)
                if dist4 < 1150.0 && Self.GetStage() < 20
                    ObjectReference mapMarker4 = Game.GetFormFromFile(0x00003424, "Vault13Chronicles.esp") as ObjectReference
                    if mapMarker4 != None
                        mapMarker4.EnableNoWait()
                        mapMarker4.AddToMap(True)
                    endif
                    Self.SetStage(20)
                endif
            endif
        elseif encType == 5
            ObjectReference signRef5 = Game.GetFormFromFile(0x00003565, "Vault13Chronicles.esp") as ObjectReference
            if signRef5 != None
                float dist5 = player.GetDistance(signRef5)
                if dist5 < 1150.0 && Self.GetStage() < 20
                    ObjectReference mapMarker5 = Game.GetFormFromFile(0x00003425, "Vault13Chronicles.esp") as ObjectReference
                    if mapMarker5 != None
                        mapMarker5.EnableNoWait()
                        mapMarker5.AddToMap(True)
                    endif
                    Self.SetStage(20)
                endif
            endif
        elseif encType == 6
            ObjectReference patrickRef = Game.GetFormFromFile(0x00003570, "Vault13Chronicles.esp") as ObjectReference
            if patrickRef != None
                float dist6 = player.GetDistance(patrickRef)
                if dist6 < 1150.0 && Self.GetStage() < 20
                    ObjectReference mapMarker6 = Game.GetFormFromFile(0x00003426, "Vault13Chronicles.esp") as ObjectReference
                    if mapMarker6 != None
                        mapMarker6.EnableNoWait()
                        mapMarker6.AddToMap(True)
                    endif
                    Self.SetStage(20)
                endif
            endif
        else
            ObjectReference tardisRef = Game.GetFormFromFile(0x000035F0, "Vault13Chronicles.esp") as ObjectReference
            if tardisRef != None
                float dist = player.GetDistance(tardisRef)
                if dist < 1150.0 && Self.GetStage() < 20
                    ObjectReference mapMarker = Game.GetFormFromFile(0x00003421, "Vault13Chronicles.esp") as ObjectReference
                    if mapMarker != None
                        mapMarker.EnableNoWait()
                        mapMarker.AddToMap(True)
                    endif
                    Self.SetStage(20)
                endif
                if dist < 210.0 && Self.GetStage() < 25 && !bDematerializing && !bDematerialized
                    TriggerTardisDematerialization()
                endif
            endif
        endif
        if Self.GetStage() < 30 && player.GetWorldSpace() == v13World
            StartTimer(2.0, 98)
        endif
    elseif aiTimerID == 94
        if encType == 6
            Actor patrickAct = Game.GetFormFromFile(0x00003570, "Vault13Chronicles.esp") as Actor
            if patrickAct != None && patrickAct.IsTalking()
                StartTimer(1.0, 94)
                return
            endif
            Sound balladSnd = Game.GetFormFromFile(0x00001077, "Vault13Chronicles.esp") as Sound
            if balladSnd != None
                if patrickAct != None && patrickAct.Is3DLoaded()
                    balladSnd.Play(patrickAct as ObjectReference)
                elseif Game.GetPlayer() != None
                    balladSnd.Play(Game.GetPlayer() as ObjectReference)
                endif
                Debug.Notification("[Patrick the Celt] Ballad of Na Fianna (The Wanderer of Vault Thirteen)")
            endif
        endif
    elseif aiTimerID == 99
        if encType == 1
            Actor player = Game.GetPlayer()
            WorldSpace caliWorld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
            Form sensorBase = Game.GetFormFromFile(0x00001456, "Vault13Chronicles.esp")
            bool inCaliWorld = (player != None && caliWorld != None && player.GetWorldSpace() == caliWorld)
            bool hasSensor = (player != None && sensorBase != None && player.GetItemCount(sensorBase) > 0)
            if inCaliWorld && hasSensor
                RunPipBoyMotionSensorSweep()
                StartTimer(6.0, 99)
            endif
        endif
    endif
EndEvent

Event OnStageSet(int auiStageID, int auiItemID)
    bool doStage20 = False
    bool doStage25 = False
    bool doStage30Reward = False
    if auiStageID == 20
        if !bStg20Notified
            bStg20Notified = True
            doStage20 = True
        endif
    elseif auiStageID == 25
        if !bStg25Notified
            bStg25Notified = True
            doStage25 = True
        endif
    elseif auiStageID == 30
        if !bRewardGranted
            bRewardGranted = True
            bDematerialized = True
            doStage30Reward = True
        endif
    endif

    SetupTardisListeners()
    Actor player = Game.GetPlayer()
    int encType = GetEncounterType()

    if encType == 2
        Form manifestBase = Game.GetFormFromFile(0x00001457, "Vault13Chronicles.esp")
        if auiStageID == 20
            ObjectReference mapMarker2 = Game.GetFormFromFile(0x00003422, "Vault13Chronicles.esp") as ObjectReference
            if mapMarker2 != None
                mapMarker2.EnableNoWait()
                mapMarker2.AddToMap(True)
            endif
            if manifestBase != None && player != None && player.GetItemCount(manifestBase) > 0
                Self.SetStage(30)
                return
            endif
            ForceQuestAlias(0, 0x00003530)
            if !IsObjectiveDisplayed(20)
                SetObjectiveDisplayed(20, True, False)
                Self.SetActive(True)
            endif
            if doStage20
                Debug.Notification("Special Encounter: Overturned Nuka-Cola Truck - Examine the overturned transport in the dunes.")
            endif
        elseif auiStageID == 25
            if manifestBase != None && player != None && player.GetItemCount(manifestBase) > 0
                Self.SetStage(30)
                return
            endif
            ForceQuestAlias(1, 0x00003531)
            SetObjectiveCompleted(20, True)
            if !Self.IsObjectiveDisplayed(25)
                Self.SetObjectiveDisplayed(25, True, False)
            endif
            Self.SetActive(True)
            if doStage25
                Debug.Notification("You found the Nuka-Cola Truck Lockbox! Collect the Shipping Manifest and the stash of Bottle Caps.")
            endif
        elseif auiStageID == 30
            SetObjectiveCompleted(20, True)
            SetObjectiveCompleted(25, True)
            if doStage30Reward
                ObjectReference crateRef = Game.GetFormFromFile(0x00003531, "Vault13Chronicles.esp") as ObjectReference
                Form nukaDoc = Game.GetFormFromFile(0x00001C80, "Vault13Chronicles.esp")
                int targetCaps = ComputeFallout1NukaTruckCaps()
                if manifestBase != None && player != None && player.GetItemCount(manifestBase) == 0
                    if crateRef != None && crateRef.GetItemCount(manifestBase) > 0
                        crateRef.RemoveItem(manifestBase, crateRef.GetItemCount(manifestBase), True)
                    endif
                    player.AddItem(manifestBase, 1, True)
                endif
                if nukaDoc != None && player != None && player.GetItemCount(nukaDoc) == 0
                    if crateRef != None && crateRef.GetItemCount(nukaDoc) > 0
                        crateRef.RemoveItem(nukaDoc, crateRef.GetItemCount(nukaDoc), True)
                    endif
                    player.AddItem(nukaDoc, 1, True)
                endif
                Game.RewardPlayerXP(350)
                Debug.Notification("Special Encounter completed: Overturned Nuka-Cola Truck! (+" + targetCaps + " Caps based on your Luck and +350 XP)")
            endif
            Self.CompleteQuest()
        endif
        return
    elseif encType == 3
        Form elvisBase = Game.GetFormFromFile(0x00001458, "Vault13Chronicles.esp")
        Form blasterBase = Game.GetFormFromFile(0x0000110F, "Vault13Chronicles.esp")
        if auiStageID == 20
            ObjectReference mapMarker3 = Game.GetFormFromFile(0x00003423, "Vault13Chronicles.esp") as ObjectReference
            if mapMarker3 != None
                mapMarker3.EnableNoWait()
                mapMarker3.AddToMap(True)
            endif
            if elvisBase != None && blasterBase != None && player != None && player.GetItemCount(elvisBase) > 0 && player.GetItemCount(blasterBase) > 0
                Self.SetStage(30)
                return
            endif
            ForceQuestAlias(0, 0x00003540)
            if !IsObjectiveDisplayed(20)
                SetObjectiveDisplayed(20, True, False)
                Self.SetActive(True)
            endif
            if doStage20
                Debug.Notification("Special Encounter: Crashed Flying Saucer - Examine the Area 51 craft and the two alien bodies.")
            endif
        elseif auiStageID == 25
            if elvisBase != None && blasterBase != None && player != None && player.GetItemCount(elvisBase) > 0 && player.GetItemCount(blasterBase) > 0
                Self.SetStage(30)
                return
            endif
            ForceQuestAlias(1, 0x00003542)
            SetObjectiveCompleted(20, True)
            if !Self.IsObjectiveDisplayed(25)
                Self.SetObjectiveDisplayed(25, True, False)
            endif
            Self.SetActive(True)
            if doStage25
                Debug.Notification("'PROPERTY OF AREA 51 - RETURN IF FOUND'. Search the two alien bodies to recover the Alien Blaster and the Velvet Elvis Painting.")
            endif
        elseif auiStageID == 30
            SetObjectiveCompleted(20, True)
            SetObjectiveCompleted(25, True)
            if doStage30Reward
                Form alienAmmo = Game.GetFormFromFile(0x001025AA, "Fallout4.esm")
                Form area51Doc = Game.GetFormFromFile(0x00001C81, "Vault13Chronicles.esp")
                if blasterBase != None && player != None && player.GetItemCount(blasterBase) == 0
                    player.AddItem(blasterBase, 1, False)
                endif
                if elvisBase != None && player != None && player.GetItemCount(elvisBase) == 0
                    player.AddItem(elvisBase, 1, False)
                endif
                if alienAmmo != None && player != None && player.GetItemCount(alienAmmo) < 120
                    player.AddItem(alienAmmo, 120, False)
                endif
                if area51Doc != None && player != None && player.GetItemCount(area51Doc) == 0
                    player.AddItem(area51Doc, 1, True)
                endif
                ObjectReference elvisRef = Game.GetFormFromFile(0x00003547, "Vault13Chronicles.esp") as ObjectReference
                ObjectReference blasterRef = Game.GetFormFromFile(0x00003548, "Vault13Chronicles.esp") as ObjectReference
                if elvisRef != None && elvisRef.GetContainer() == None && !elvisRef.IsDisabled()
                    elvisRef.DisableNoWait()
                endif
                if blasterRef != None && blasterRef.GetContainer() == None && !blasterRef.IsDisabled()
                    blasterRef.DisableNoWait()
                endif
                Game.RewardPlayerXP(400)
                Debug.Notification("Special Encounter completed: Crashed Flying Saucer! (+Alien Blaster, +Velvet Painting of 'The King', and +400 XP)")
            endif
            Self.CompleteQuest()
        endif
        return
    elseif encType == 4
        Form sbBase = Game.GetFormFromFile(0x00001460, "Vault13Chronicles.esp")
        if auiStageID == 20
            ObjectReference mapMarker4 = Game.GetFormFromFile(0x00003424, "Vault13Chronicles.esp") as ObjectReference
            if mapMarker4 != None
                mapMarker4.EnableNoWait()
                mapMarker4.AddToMap(True)
            endif
            if sbBase != None && player != None && player.GetItemCount(sbBase) > 0
                Self.SetStage(30)
                return
            endif
            ForceQuestAlias(0, 0x00003561)
            if !IsObjectiveDisplayed(20)
                SetObjectiveDisplayed(20, True, False)
                Self.SetActive(True)
            endif
            if doStage20
                Debug.Notification("Special Encounter: Giant Godzilla Footprint - Examine the giant footprint north of Shady Sands.")
            endif
        elseif auiStageID == 25
            if sbBase != None && player != None && player.GetItemCount(sbBase) > 0
                Self.SetStage(30)
                return
            endif
            ForceQuestAlias(1, 0x00003560)
            SetObjectiveCompleted(20, True)
            if !Self.IsObjectiveDisplayed(25)
                Self.SetObjectiveDisplayed(25, True, False)
            endif
            Self.SetActive(True)
            if doStage25
                Debug.Notification("Search the crushed corpse in the center of the Giant Footprint to recover the RobCo Stealth Boy 3001.")
            endif
        elseif auiStageID == 30
            SetObjectiveCompleted(20, True)
            SetObjectiveCompleted(25, True)
            if doStage30Reward
                Form stealthBoyConsumable = Game.GetFormFromFile(0x0004F4A6, "Fallout4.esm")
                Form fpDoc = Game.GetFormFromFile(0x00001C8A, "Vault13Chronicles.esp")
                if sbBase != None && player != None && player.GetItemCount(sbBase) == 0
                    player.AddItem(sbBase, 1, False)
                endif
                if stealthBoyConsumable != None && player != None
                    player.AddItem(stealthBoyConsumable, 2, False)
                endif
                if fpDoc != None && player != None && player.GetItemCount(fpDoc) == 0
                    player.AddItem(fpDoc, 1, True)
                endif
                ObjectReference sbRef = Game.GetFormFromFile(0x00003564, "Vault13Chronicles.esp") as ObjectReference
                if sbRef != None && sbRef.GetContainer() == None && !sbRef.IsDisabled()
                    sbRef.DisableNoWait()
                endif
                Game.RewardPlayerXP(350)
                Debug.Notification("Special Encounter completed: Giant Godzilla Footprint! (+RobCo Stealth Boy 3001, +2 Stealth Boys, and +350 XP)")
            endif
            Self.CompleteQuest()
        endif
        return
    elseif encType == 5
        Form rrBase = Game.GetFormFromFile(0x00001117, "Vault13Chronicles.esp")
        if auiStageID == 20
            ObjectReference mapMarker5 = Game.GetFormFromFile(0x00003425, "Vault13Chronicles.esp") as ObjectReference
            if mapMarker5 != None
                mapMarker5.EnableNoWait()
                mapMarker5.AddToMap(True)
            endif
            if rrBase != None && player != None && player.GetItemCount(rrBase) > 0
                Self.SetStage(30)
                return
            endif
            ForceQuestAlias(0, 0x00003565)
            if !IsObjectiveDisplayed(20)
                SetObjectiveDisplayed(20, True, False)
                Self.SetActive(True)
            endif
            if doStage20
                Debug.Notification("Special Encounter: Bob's Pre-Owned Car Mart - Examine the sales office and the used car lot.")
            endif
        elseif auiStageID == 25
            if rrBase != None && player != None && player.GetItemCount(rrBase) > 0
                Self.SetStage(30)
                return
            endif
            ForceQuestAlias(1, 0x00003566)
            SetObjectiveCompleted(20, True)
            if !Self.IsObjectiveDisplayed(25)
                Self.SetObjectiveDisplayed(25, True, False)
            endif
            Self.SetActive(True)
            if doStage25
                Debug.Notification("Open Bob's Display Safe and collect the legendary Red Ryder LE BB Gun.")
            endif
        elseif auiStageID == 30
            SetObjectiveCompleted(20, True)
            SetObjectiveCompleted(25, True)
            if doStage30Reward
                Form bobKey = Game.GetFormFromFile(0x00001461, "Vault13Chronicles.esp")
                Form bobDoc = Game.GetFormFromFile(0x00001C8B, "Vault13Chronicles.esp")
                Form ammo308 = Game.GetFormFromFile(0x0001F66B, "Fallout4.esm")
                Form caps5 = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
                if rrBase != None && player != None && player.GetItemCount(rrBase) == 0
                    player.AddItem(rrBase, 1, False)
                endif
                if bobKey != None && player != None && player.GetItemCount(bobKey) == 0
                    player.AddItem(bobKey, 1, True)
                endif
                if bobDoc != None && player != None && player.GetItemCount(bobDoc) == 0
                    player.AddItem(bobDoc, 1, True)
                endif
                if ammo308 != None && player != None
                    player.AddItem(ammo308, 120, False)
                endif
                if caps5 != None && player != None
                    player.AddItem(caps5, 350, False)
                endif
                ObjectReference rrRef5 = Game.GetFormFromFile(0x0000356A, "Vault13Chronicles.esp") as ObjectReference
                if rrRef5 != None && rrRef5.GetContainer() == None && !rrRef5.IsDisabled()
                    rrRef5.DisableNoWait()
                endif
                Game.RewardPlayerXP(400)
                Debug.Notification("Special Encounter completed: Bob's Pre-Owned Car Mart! (+Red Ryder LE BB Gun, +120 Rounds, and +400 XP)")
            endif
            Self.CompleteQuest()
        endif
        return
    elseif encType == 6
        Form medBase = Game.GetFormFromFile(0x00001462, "Vault13Chronicles.esp")
        if auiStageID == 20
            ObjectReference mapMarker6 = Game.GetFormFromFile(0x00003426, "Vault13Chronicles.esp") as ObjectReference
            if mapMarker6 != None
                mapMarker6.EnableNoWait()
                mapMarker6.AddToMap(True)
            endif
            if medBase != None && player != None && player.GetItemCount(medBase) > 0
                Self.SetStage(30)
                return
            endif
            ForceQuestAlias(0, 0x00003570)
            if !IsObjectiveDisplayed(20)
                SetObjectiveDisplayed(20, True, False)
                Self.SetActive(True)
            endif
            if doStage20
                Debug.Notification("Special Encounter: Patrick the Celt - Approach his campfire north of The Hub and speak with the traveling bard.")
            endif
        elseif auiStageID == 25
            if medBase != None && player != None && player.GetItemCount(medBase) > 0
                Self.SetStage(30)
                return
            endif
            ForceQuestAlias(0, 0x00003570)
            SetObjectiveCompleted(20, True)
            if !Self.IsObjectiveDisplayed(25)
                Self.SetObjectiveDisplayed(25, True, False)
            endif
            Self.SetActive(True)
            if doStage25
                Debug.Notification("Speak with Patrick the Celt by his campfire and ask him to sing his traditional Gaelic ballad (+1 Charisma).")
            endif
        elseif auiStageID == 30
            SetObjectiveCompleted(20, True)
            SetObjectiveCompleted(25, True)
            if doStage30Reward
                Form balladDoc = Game.GetFormFromFile(0x00001C8C, "Vault13Chronicles.esp")
                ActorValue chaAV = Game.GetCharismaAV()
                if chaAV != None && player != None
                    player.ModValue(chaAV, 1.0)
                endif
                if medBase != None && player != None && player.GetItemCount(medBase) == 0
                    player.AddItem(medBase, 1, False)
                endif
                if balladDoc != None && player != None && player.GetItemCount(balladDoc) == 0
                    player.AddItem(balladDoc, 1, True)
                endif
                EffectShader chaFX = Game.GetFormFromFile(0x002494E4, "Fallout4.esm") as EffectShader
                if chaFX != None && player != None
                    chaFX.Play(player, 2.0)
                endif
                Game.RewardPlayerXP(350)
                Debug.Notification("Special Encounter completed: Patrick the Celt! (+1 permanent Charisma from hearing 'Na Fianna', +Celtic Medallion, and +350 XP)")
                StartTimer(1.5, 94)
            endif
            Self.CompleteQuest()
        endif
        return
    endif

    Form sensorBase = Game.GetFormFromFile(0x00001456, "Vault13Chronicles.esp")

    if auiStageID == 20
        ObjectReference mapMarker = Game.GetFormFromFile(0x00003421, "Vault13Chronicles.esp") as ObjectReference
        if mapMarker != None
            mapMarker.EnableNoWait()
            mapMarker.AddToMap(True)
        endif
        if sensorBase != None && player != None && player.GetItemCount(sensorBase) > 0
            Self.SetStage(30)
            return
        endif
        ForceQuestAlias(0, 0x000035F0)
        if !IsObjectiveDisplayed(20)
            SetObjectiveDisplayed(20, True, False)
            Self.SetActive(True)
        endif
        if doStage20
            Debug.Notification("Special Encounter: The Unusual Call Box - Approach and examine the blue police box in the middle of the desert.")
        endif
    elseif auiStageID == 25
        if sensorBase != None && player != None && player.GetItemCount(sensorBase) > 0
            Self.SetStage(30)
            return
        endif
        ForceQuestAlias(1, 0x000035F2)
        SetObjectiveCompleted(20, True)
        if !Self.IsObjectiveDisplayed(25)
            Self.SetObjectiveDisplayed(25, True, False)
        endif
        Self.SetActive(True)
        if doStage25
            Debug.Notification("The police box dematerialized across space-time! Pick up the Motion Sensor left behind.")
        endif
    elseif auiStageID == 30
        SetObjectiveCompleted(20, True)
        SetObjectiveCompleted(25, True)
        if doStage30Reward
            Form caps = Game.GetFormFromFile(0x0000000F, "Fallout4.esm")
            Form fusionCell = Game.GetFormFromFile(0x000C1897, "Fallout4.esm")
            Form manualBook = Game.GetFormFromFile(0x0000114F, "Vault13Chronicles.esp")
            if caps != None
                player.AddItem(caps, 500, False)
            endif
            if fusionCell != None
                player.AddItem(fusionCell, 40, False)
            endif
            if manualBook != None && player.GetItemCount(manualBook) == 0
                player.AddItem(manualBook, 1, True)
            endif
            Game.RewardPlayerXP(350)
            RunPipBoyMotionSensorSweep()
            WorldSpace caliWorld = Game.GetFormFromFile(0x00003400, "Vault13Chronicles.esp") as WorldSpace
            if player != None && caliWorld != None && player.GetWorldSpace() == caliWorld
                StartTimer(2.0, 99)
            endif
            Debug.Notification("Special Encounter completed: The Unusual Call Box! (+Pip-Boy 2000 Motion Sensor, +500 Caps, and +350 XP)")
        endif
        Self.CompleteQuest()
    endif
EndEvent
