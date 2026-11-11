# Informe de Situación — *Crónicas del Refugio 13 (2161)* (30/10/2026)

## 1. Resumen de lo Completado y Compilado en `Fallout 4\Data`
1. **Acto I — Cadáver del Explorador Ed (`0x01002589`) y su Nota (`0x0100258A`) en el Refugio 15 (`CELL 0x01002500`)**:
   - Traje del Refugio 13 no jugable (`ARMO 0x01001308` / `OTFT 0x01001019`) para que aparezca siempre vestido y no se desnude al saquearlo.
   - Eliminada la llamada a `Resurrect()` en `V13Act1QuestScript.psc` que causaba el salto sobre la mesa y la duplicación de inventario.
   - Bloqueo de persecución de enemigos a través de puertas de teletransporte hacia el Refugio 13.
2. **Acto II — Intercomunicador y Retirada de Harry en Necrópolis (`CELL 0x01002A00`)**:
   - `EvacuateHarryPatrol()` en `V13Act2QuestScript.psc`: al engañar a Harry por el intercomunicador (`0x01002A15`), Harry (`0x01002A11`) y sus dos centinelas (`0x01002A12`, `0x01002A20`) abandonan la sala (`Disable(true)`) y la Pistola del .223 (`0x01001105`) pasa al arcón de la Computadora Central (`0x01002A10`).
3. **Acto II — Clímax en la Planta Purificadora de Agua del Refugio 13 (`CELL 0x01002100`, `Stages 30 -> 35 -> 38 -> 40`)**:
   - Al regresar con el Chip de Agua (`Stage 30`), hablar con el Supervisor Jacoren inicia `Stage 35`: Jacoren y el técnico Calvin caminan con el jugador hasta la Planta Purificadora en el nivel inferior del atrio (`Z = -528.0`) mientras suenan alarmas rojas y saltan chispas del procesador averiado.
   - Al activar la Consola del Procesador Central (`0x01002138`) e instalar el Chip de Agua (`Stage 38`), se apagan las chispas y luces rojas, se encienden las luces verdes operativas y arranca la Turbina Purificadora animada (`0x01002167`).
   - Hablar con Jacoren frente a la turbina en marcha completa el Acto II (`Stage 40`), entrega las recompensas e inicia la escena hacia el Acto III.

## 2. Próximos Pasos para Retomar Mañana (Acto II — `CELL 0x01002A00`)
1. **Encaje de la puerta de salida (`REFR 0x01002A03`) al final del recorrido de Necrópolis**: Corregir el vacío lateral junto a la puerta para que quede completamente empotrada en roca/muro sin huecos.
2. **Limpieza de objetos flotantes en el recorrido de `CELL 0x01002A00`**: Auditar las referencias del camino entre la entrada y la sala final para eliminar o asentar en el suelo cualquier objeto que haya quedado en el aire.
3. **Eliminación de referencias al Refugio 88 y edificios de entrada**: Retirar carteles/letreros del Refugio 88 y estructuras de la entrada que desentonen con la Cuenca subterránea de Necrópolis / Refugio 12.
4. **Prueba en juego del clímax de la Planta Purificadora de Agua del Refugio 13**.
