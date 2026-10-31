# La música

Tres músicas cortas y una campanilla, en los tres canales del PSG. No están
grabadas a mano: `tools/musica.py` **ejecuta el motor de sonido del propio
cartucho** con `tools/z80run.py` -`psg_inicial` (0x0F1F), los punteros de los
canales como los pone el juego, y en cada cuadro `canal_musica` (0x0103) con
los tres canales, como la interrupción- y apunta lo que escribe en el PSG.

**Cotejadas con openMSX**: en las partidas grabadas, los registros de tono y
volumen de los canales que usa cada pieza coinciden cuadro a cuadro con los
del motor ejecutado, **la pieza entera** cada una: 257, 117, 41 y 121 cuadros,
**0 distintos**.

Cada nota son tres bytes: el tono bajo, el tono alto con la duración en el
nibble alto, y el volumen; un 0x01 suelto pasa el canal a un tempo cuatro veces
más corto (solo lo usa la campanilla) y 0xFF lo calla.

## Al empezar la partida

`empieza_partida` (0x02B9), con la opción elegida en pantalla. El programa
espera a que acabe el canal 2.

<audio controls src="../audio/musica_salida.mp3"></audio>

## La fase superada

`fase_superada` (0x03C8), antes del tablero siguiente.

<audio controls src="../audio/musica_fase.mp3"></audio>

## La campanilla

Suena en el canal 1 al arrancar cada fase y en cada estación visitada, menos
la última (`segunda_casilla`, 0x0E30).

<audio controls src="../audio/musica_campanilla.mp3"></audio>

## GAME OVER

`game_over` (0x0758).

<audio controls src="../audio/musica_final.mp3"></audio>

## El resto

Los efectos: el traqueteo del tren en el canal 3, con el ruido, que se repite
mientras dura la fase (más rápido con el tren a tope), el empujón, el aviso del
tren negro y el choque. En la demostración no suena nada: la interrupción no
mueve los canales (0x00D8) y `psg_inicial` cierra el mezclador entero
(0x0F2E).
