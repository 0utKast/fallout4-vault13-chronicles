Scriptname V13TermMasterScript extends ObjectReference

bool bMasterMenuBusy = False

Event OnActivate(ObjectReference akActionRef)
    if bMasterMenuBusy
        return
    endif
    Actor player = Game.GetPlayer()
    if akActionRef != player || player == None
        return
    endif
    bMasterMenuBusy = True

    Quest q5 = Game.GetFormFromFile(0x00008000, "Vault13Chronicles.esp") as Quest
    V13Act5QuestScript act5S = q5 as V13Act5QuestScript
    Terminal warheadBase = Game.GetFormFromFile(0x000015AA, "Vault13Chronicles.esp") as Terminal
    Terminal caveRelayBase = Game.GetFormFromFile(0x000015AB, "Vault13Chronicles.esp") as Terminal

    Utility.Wait(0.55)

    if caveRelayBase != None && Self.GetBaseObject() == caveRelayBase
        Message relayMenu = Game.GetFormFromFile(0x000015AD, "Vault13Chronicles.esp") as Message
        if relayMenu != None
            int rChoice = relayMenu.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
            if rChoice == 0
                V13Act1QuestScript act1S = Game.GetFormFromFile(0x00004000, "Vault13Chronicles.esp") as V13Act1QuestScript
                if act1S != None
                    act1S.ReturnPlayerToCommonwealthFromTerminal()
                else
                    ObjectReference mnemoDest = Game.GetFormFromFile(0x00002002, "Vault13Chronicles.esp") as ObjectReference
                    if mnemoDest != None
                        player.MoveTo(mnemoDest, 0.0, 0.0, 0.0, true)
                    endif
                endif
            endif
        endif
        bMasterMenuBusy = False
        return
    endif

    if warheadBase != None && Self.GetBaseObject() == warheadBase
        Message warheadMenu = Game.GetFormFromFile(0x000015AC, "Vault13Chronicles.esp") as Message
        if warheadMenu != None
            int wChoice = warheadMenu.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
            if wChoice == 0
                Form mariposaCodes = Game.GetFormFromFile(0x00001114, "Vault13Chronicles.esp")
                Form lauraKey = Game.GetFormFromFile(0x000015A7, "Vault13Chronicles.esp")
                Form morpheusBadge = Game.GetFormFromFile(0x000015A8, "Vault13Chronicles.esp")
                bool hasAuth = ((mariposaCodes != None && player.GetItemCount(mariposaCodes) > 0) || (lauraKey != None && player.GetItemCount(lauraKey) > 0) || (morpheusBadge != None && player.GetItemCount(morpheusBadge) > 0))
                if hasAuth
                    if act5S != None
                        act5S.StartCathedralNuclearCountdown(2)
                    endif
                else
                    Debug.Notification("[Ojiva de Preguerra] Se requieren los Códigos de Mariposa, la Insignia de Morfeo o la Llave de la Hermana Laura.")
                endif
            elseif wChoice == 1
                Perk sciPerk = Game.GetFormFromFile(0x000264D9, "Fallout4.esm") as Perk
                ActorValue intAV = Game.GetFormFromFile(0x000002C5, "Fallout4.esm") as ActorValue
                bool canHack = ((sciPerk != None && player.HasPerk(sciPerk)) || (intAV != None && player.GetValue(intAV) >= 7.0))
                if canHack
                    if act5S != None
                        act5S.StartCathedralNuclearCountdown(2)
                    endif
                else
                    Debug.Notification("[Ojiva de Preguerra] Necesitas el extra Ciencia o Inteligencia 7+ para puentear el detonador nuclear.")
                endif
            endif
        endif
        bMasterMenuBusy = False
        return
    endif

    Message masterMenu = Game.GetFormFromFile(0x00001159, "Vault13Chronicles.esp") as Message
    if masterMenu != None
        int choice = masterMenu.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        if choice == 0
            Form vreeHolo = Game.GetFormFromFile(0x00001113, "Vault13Chronicles.esp")
            if vreeHolo != None && player.GetItemCount(vreeHolo) > 0
                if act5S != None
                    act5S.StartCathedralNuclearCountdown(1)
                endif
            else
                Debug.Notification("[Consola Neuronal] Necesitas la Holocinta de Autopsia de la Escriba Vree (Lost Hills) para demostrar la esterilidad mutante.")
            endif
        elseif choice == 1
            Actor theMaster = Game.GetFormFromFile(0x00002D11, "Vault13Chronicles.esp") as Actor
            Form mariposaCodes = Game.GetFormFromFile(0x00001114, "Vault13Chronicles.esp")
            Form morpheusBadge = Game.GetFormFromFile(0x000015A8, "Vault13Chronicles.esp")
            if (theMaster == None || theMaster.IsDead()) || (mariposaCodes != None && player.GetItemCount(mariposaCodes) > 0) || (morpheusBadge != None && player.GetItemCount(morpheusBadge) > 0)
                if act5S != None
                    act5S.StartCathedralNuclearCountdown(2)
                endif
            else
                Debug.Notification("[Consola Neuronal] El enlace neural del Maestro bloquea el armado manual; derrótalo, usa los Códigos de Mariposa o sabotea la ojiva del Subnivel IV.")
            endif
        endif
    endif
    bMasterMenuBusy = False
EndEvent
