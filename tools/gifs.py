#!/usr/bin/env python3
"""Los GIF de la web: tramos de las grabaciones de openMSX (tools/guiones/*.tcl,
grabados con tools/lanza_graba.ps1), pintados con tools/vdp.py.

Uso: gifs.py docs/imagenes
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import vdp          # noqa: E402

# (fichero, grabacion, desde, hasta): los cuadros salen de la RAM grabada
# (0xE200 la interrupcion, 0xE005 el choque, 0xE045 las estaciones, 0xE241 el
# aviso, 0xE067 los trenes negros, 0xE230 la fase, 0xE002 las vidas)
TRAMOS = [
    ("titulo_y_menu.gif", "atraccion", 0, 1000),
    ("partida.gif", "sola", 736, 1260),
    ("empujones.gif", "empuja", 800, 1420),
    ("choque_y_vuelta.gif", "sola", 1560, 1840),
    ("aviso.gif", "atraccion", 1700, 1960),
    ("tren_negro.gif", "atraccion", 2600, 3060),
    ("fase_superada.gif", "fases", 1150, 1420),
    ("fase_99.gif", "fase99", 2290, 2560),
    ("game_over.gif", "empuja", 2000, 2830),
]

# (fichero, grabacion, cuadro, recorte): imagenes sueltas de una grabacion.
# record.png: el GAME OVER de empuja.tcl, 1P-00280 y HIGH-00290 (las dos filas
# de arriba): los 10 puntos de la casilla del choque los conto el record y no
# la partida.
SUELTAS = [
    ("record.png", "empuja", 2300, (0, 0, 256, 16)),
]


def main(salida):
    raiz = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    for fichero, grab, desde, hasta in TRAMOS:
        n, s = vdp.gif(os.path.join(raiz, "work", grab + ".bin"),
                       os.path.join(salida, fichero), desde, hasta, cada=2, tope_ms=4000)
        print("%-24s %4d imagenes, %5.1f s, %7d bytes" % (
            fichero, n, s, os.path.getsize(os.path.join(salida, fichero))))
    for fichero, grab, cuadro, recorte in SUELTAS:
        c = list(vdp.cuadros(os.path.join(raiz, "work", grab + ".bin")))[cuadro]
        vdp.imagen(c["vram"], c["regs"], 2).crop(tuple(2 * v for v in recorte)).save(
            os.path.join(salida, fichero))
        print("%-24s cuadro %d" % (fichero, cuadro))


if __name__ == "__main__":
    main(sys.argv[1])
