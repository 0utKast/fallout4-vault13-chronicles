Scriptname V13TermMariposaScript extends ObjectReference

bool bArmed = False

Event OnActivate(ObjectReference akActionRef)
    if bArmed
        return
    endif
    Actor player = Game.GetPlayer()
    if akActionRef == player
        bArmed = True
        Quest q4 = Game.GetFormFromFile(0x00007000, "Vault13Chronicles.esp") as Quest
        Form mariposaCodes = Game.GetFormFromFile(0x00001114, "Vault13Chronicles.esp")
        Form report4 = Game.GetFormFromFile(0x00001144, "Vault13Chronicles.esp")
        Form psychicNullifier = Game.GetFormFromFile(0x00001333, "Vault13Chronicles.esp")
        if q4 != None && q4.GetStage() >= 20 && q4.GetStage() < 30
            V13Act4QuestScript act4S = q4 as V13Act4QuestScript
            if act4S != None && !act4S.CanSabotageMariposaVats()
                bArmed = False
                act4S.EnforceLieutenantBeforeSabotage()
                return
            endif
            if mariposaCodes != None && player.GetItemCount(mariposaCodes) == 0
                player.AddItem(mariposaCodes, 1, false)
            endif
            if report4 != None && player.GetItemCount(report4) == 0
                player.AddItem(report4, 1, false)
            endif
            if psychicNullifier != None && player.GetItemCount(psychicNullifier) == 0
                player.AddItem(psychicNullifier, 1, false)
            endif
            q4.SetStage(30)
            if act4S != None
                act4S.ArmMariposaSelfDestructCountdown()
            endif
            Debug.Notification("[Control de Cubas de Mariposa] ¡Autodestrucción armada (180 s)! ¡Evacúa la base inmediatamente!")
        else
            bArmed = False
        endif
    endif
EndEvent
