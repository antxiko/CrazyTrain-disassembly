# Por dentro

## Rehacer la ROM

`make verify` ensambla `src/crazytrain.asm` con pasmo y sale la ROM de 8 KB
**byte a byte**; repetida cuatro veces, da el volcado de 32 KB. `make sanity`
comprueba lo que el reensamblado no cubre: que ningún byte declarado como
datos se lea como código, y que los 8.192 estén explicados. `make test` pasa
los tests. La ROM no está en el repositorio: hace falta ponerla en la raíz
como `crazytrain.rom` (el volcado de GoodMSX, `[!]`, sha1 `bbe8df03...`).

| | bytes |
|---|---|
| código trazado | 4.423 |
| datos con nombre | 3.769 |
| sin explicar | 0 |

El listado lleva 1.103 comentarios en 2.612 instrucciones (42,2 %), 280
rutinas y etiquetas, ninguna por debajo del 10 % comentada, y ninguna rutina
llamada sin nombre.

## La página 0, sin la BIOS

La cabecera da INIT en `0x0160`, y la BIOS lo llama con CALSLT, que pone el
cartucho en la página 0. Desde ahí todo es del cartucho: la RAM y la VRAM a
cero, la interrupción en modo 1 (que salta a `0x0038`), la pila en `0xE800`, y
sus RST:

| | Qué hace |
|---|---|
| RST 10h | HL + A |
| RST 18h | la dirección DE al VDP |
| RST 20h | B bytes de HL a la VRAM, en la dirección DE |
| RST 28h | B veces el byte C en la VRAM, desde DE |
| RST 30h | el jugador en curso (0 o 1) en A, con Z si es el 1 |

La pantalla es SCREEN 2 con los tres tercios iguales: las letras y sus colores
se suben una vez y se copian de VRAM a VRAM a los otros dos (`copia_en_vram`,
0x0F3E). El tablero son letras en la tabla de nombres; los trenes, cuatro
sprites de 16 x 16.

## La ficha de cada tren y su guion

Los cuatro trenes (el blanco y tres negros) tienen una ficha de 32 bytes en
`0xE300`, `0xE320`, `0xE340` y `0xE360`, copiada de la plantilla de 0x12B7:

| | |
|---|---|
| +1 | la pieza de su casilla |
| +2 | su casilla (fila x 8 + columna) |
| +3 | su dirección en el tablero (0 arriba, 1 derecha, 2 abajo, 3 izquierda) |
| +4 | su número (0 el blanco) |
| +5 | la dirección de su sprite (0-7) |
| +6 | lo que le queda al tramo |
| +7, +8 | su guion |
| +9 | código: lee el byte siguiente del guion y salta a 0x0850 |

Cada byte del guion es "veces x 16 + dirección del sprite": mientras quedan
veces, el sprite avanza un punto (`un_pixel`, 0x08B7, con los ocho trocitos de
0x0AE0, `dec d`, `inc e`...); 0xFF acaba la casilla y 0x10 es un callejón.
Al acabar la casilla, `casilla_siguiente` (0x0E61) pasa a la de al lado y
`entra_en_casilla` (0x0DD6) busca en la tabla de salidas (0x12CE), con la pieza
y el lado por el que entra, la dirección en la que sale y su guion.

Cada jugador tiene sus cuatro fichas de reserva (`0xE400` y `0xE480`) y su
tablero (`0xE100` y `0xE130`): al cambiar el turno se guardan y se sacan.

## La interrupción

Hace casi todo el juego: mueve los cuatro trenes (cada uno con su cuenta de
cuadros), las explosiones, el empujón y su deslizamiento, la música y los
relojes. El bucle de la partida (0x047E) se queda con los choques, los puntos,
el botón, la cuenta del tren negro y el final de la fase. Con `0xE200` a uno,
la interrupción solo mueve la música y los relojes: así están los carteles y
las esperas.

## La RAM

| | |
|---|---|
| `0xE000`, `0xE001` | dos jugadores; el que juega |
| `0xE002`, `0xE003` | las vidas de cada uno |
| `0xE005` | el tren blanco ha chocado |
| `0xE006`, `0xE007` | el hueco de cada jugador |
| `0xE030`-`0xE03D` | la pieza que se desliza |
| `0xE040`-`0xE044` | las casillas de estación que pisa el tren blanco |
| `0xE045`, `0xE046` | las estaciones que faltan |
| `0xE060`-`0xE062` | el botón y la velocidad |
| `0xE067`-`0xE06C` | los trenes negros en marcha, y los que estallan |
| `0xE080`-`0xE09F` | los cuatro sprites de cada jugador |
| `0xE100`, `0xE130` | el tablero de cada jugador |
| `0xE160`, `0xE170` | sus estaciones: visitada o no |
| `0xE1A0`-`0xE1AA` | el camino por adelantado (si va dando vueltas) |
| `0xE1B0`, `0xE1B1` | qué tablero tiene cada uno |
| `0xE1E0` | la espera, en tramos de 32 cuadros |
| `0xE210`-`0xE215` | los puntos de cada uno y el récord (BCD) |
| `0xE230`, `0xE231` | la fase de cada uno (BCD) |
| `0xE240`-`0xE24E` | el tren negro que se anuncia: espera, cuenta y estación |
| `0xE260`-`0xE262` | la demostración y su mando |
| `0xE300`-`0xE37F` | las cuatro fichas de los trenes |
| `0xE3A0`-`0xE3B7` | los tres canales de música |

## Las herramientas

| | |
|---|---|
| `tools/z80trace.py`, `tools/mkasm.py` | el trazado y el listado |
| `tools/presupuesto.py`, `tools/densidad.py` | los bytes explicados y los comentarios |
| `tools/omsx_graba.tcl`, `tools/lanza_graba.ps1` | graban el cartucho en openMSX, cuadro a cuadro |
| `tools/guiones/*.tcl` | lo que se pulsa (y los pokes) en cada grabación |
| `tools/sonda_ret.tcl`, `tools/lanza_sonda.ps1` | cuántas veces llega el programa a una dirección |
| `tools/vdp.py`, `tools/gifs.py` | el TMS9918 en Python y los GIF |
| `tools/pantallas.py`, `tools/graficos.py` | el título, el menú, las piezas, los sprites y los tableros, ejecutando el cartucho con `tools/z80run.py`, y su cotejo |
| `tools/musica.py` | las músicas, ejecutando su motor, y su cotejo |

## Los cotejos

| | Resultado |
|---|---|
| el título y el menú | 0 puntos distintos de 49.152 |
| los ocho tableros (fases 1 a 8) | 0 puntos distintos, de la fila 2 a la 23 |
| las cuatro músicas | enteras, cuadro a cuadro: 0 distintos |
| la vida extra (4.900 y 4.910 antes de una estación) | un tren más las dos veces |
| la fase después de la 99 | la 02 |
| el `ret` de 0x084F | 0 veces en 20.000 cuadros |

## Código compartido con otros cartuchos de Konami

Este desensamblado se ha comparado, instrucción por instrucción, con
todos los demás de Konami de la serie. Cuenta un bloque cuando las
mismas instrucciones, al menos seis desde una etiqueta hasta su `ret`
o su salto sin condición, están en los dos cartuchos; las direcciones
no se miran, porque cambian de un cartucho a otro. De los otros 63,
**7** tienen al menos un bloque en común con este; estos son los
que más comparten:

| Cartucho | Bloques | Instrucciones | Por ejemplo (aquí = allí) |
|---|---:|---:|---|
| [Frogger](https://antxiko.github.io/Frogger-disassembly/es/) | 4 | 47 | `elige_opcion` (0x024D) = `MIRA_QUE_TECLA` |
| [Time Pilot](https://antxiko.github.io/TimePilot-disassembly/es/) | 3 | 29 | `texto_letra` (0x0797) = `ESCRIBE_ROTULO_BUCLE` |
| [Hyper Olympic 1](https://antxiko.github.io/HyperOlympic1-disassembly/es/) | 2 | 14 | `pinta_menu` (0x1142) = `PINTA_EL_MARCO_DEL_MENU` |

La matriz entera, los 64 cartuchos entre sí, está en
[Las rutinas](https://antxiko.github.io/MSX-disassembly-database/es/LAS-RUTINAS.html) de la base de datos de la
serie, con el método y el programa que la mide.
