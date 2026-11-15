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
        Debug.Notification("[The Cathedral] Underground Crypt unlocked toward the Demonstration Vault!")
        Self.Activate(player, true)
    else
        Debug.Notification("[The Cathedral] Secret basement door sealed: obtain spy Sister Laura's key in the nave ('Red Rose'), Morpheus's Black Badge in the upper gallery, or pick the Master Lock.")
    endif
EndEvent
