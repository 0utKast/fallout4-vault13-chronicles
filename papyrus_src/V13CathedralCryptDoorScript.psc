Scriptname V13CathedralCryptDoorScript extends ObjectReference

Event OnActivate(ObjectReference akActionRef)
    Actor player = Game.GetPlayer()
    if akActionRef != player
        return
    endif
    if !Self.IsLocked()
        return
    endif

    Form fKeyLaura = Game.GetFormFromFile(0x000015A7, "Vault13Chronicles.esp")
    Form fBadgeMorpheus = Game.GetFormFromFile(0x000015A8, "Vault13Chronicles.esp")
    bool hasKey = (fKeyLaura != None && player.GetItemCount(fKeyLaura) > 0) || (fBadgeMorpheus != None && player.GetItemCount(fBadgeMorpheus) > 0)

    if hasKey
        Self.Lock(false, false)
        Debug.Notification("[La Catedral] ¡Cripta Subterránea desbloqueada rumbo al Refugio del Futuro!")
        Self.Activate(player, true)
    else
        Debug.Notification("[La Catedral] Puerta sellada al sótano secreto: obtén la llave de la espía Hermana Laura en la nave («Rosa Roja»), la Insignia Negra de Morfeo en la galería superior o usa Cerradura Maestro.")
    endif
EndEvent
