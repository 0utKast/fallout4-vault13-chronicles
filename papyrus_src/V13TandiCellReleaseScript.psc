Scriptname V13TandiCellReleaseScript extends ObjectReference

bool bActivating = False

Event OnActivate(ObjectReference akActionRef)
    If bActivating
        Return
    EndIf
    bActivating = True
    Actor player = Game.GetPlayer()
    If akActionRef != player
        bActivating = False
        Return
    EndIf

    Quest rescueQ = Game.GetFormFromFile(0x00018000, "Vault13Chronicles.esp") as Quest
    If rescueQ == None
        bActivating = False
        Return
    EndIf

    int st = rescueQ.GetStage()
    If st >= 30
        Debug.Notification("El cerrojo de retencion ya esta abierto y Tandi ha regresado a Arenas Sombrías.")
        bActivating = False
        Return
    EndIf

    If !rescueQ.IsRunning() || st < 15
        Debug.Notification("Cerrojo de retencion de los Khans. No hay ningun prisionero encadenado aqui.")
        bActivating = False
        Return
    EndIf

    Form keyForm = Game.GetFormFromFile(0x0001459, "Vault13Chronicles.esp")
    Form bobbyPin = Game.GetFormFromFile(0x0000000A, "Fallout4.esm")
    Actor petrox = Game.GetFormFromFile(0x000035D8, "Vault13Chronicles.esp") as Actor

    If keyForm != None && player.GetItemCount(keyForm) > 0
        Debug.Notification("Abres los grilletes con la llave de Petrox y liberas a Tandi.")
    ElseIf petrox != None && petrox.IsDead()
        Debug.Notification("Rompes el cerrojo de la celda tras abatir a los secuestradores y liberas a Tandi.")
    ElseIf bobbyPin != None && player.GetItemCount(bobbyPin) > 0
        Debug.Notification("[Ganzua / Sigilo] Fuerzas el cerrojo con una horquilla y liberas a Tandi en silencio.")
    Else
        Debug.Notification("[Fuerza / Sigilo] Desencajas el pestillo oxidado de la celda y liberas a Tandi.")
    EndIf

    If st < 26
        rescueQ.SetStage(29)
    Else
        rescueQ.SetStage(30)
    EndIf
    bActivating = False
EndEvent
