#!/usr/bin/env python3
"""Los GIF de la web: tramos de las grabaciones de openMSX (tools/guiones/*.tcl,
grabados con tools/lanza_graba.ps1), pintados con tools/vdp.py.

Uso: gifs.py docs/imagenes
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import vdp          # noqa: E402

# (fichero, grabacion, desde, hasta): los cuadros los dice tools/eventos (ver
# la pagina EN-EL-EMULADOR): el cambio de modo, de estado de Sparkie, etc.
TRAMOS = [
    ("sony_y_menu.gif", "atraccion", 0, 600),
    ("demostracion.gif", "atraccion", 601, 1000),
    ("oleada_empieza.gif", "partida", 691, 830),
    ("partida.gif", "partida", 818, 1240),
    ("astronauta.gif", "astronauta", 818, 1650),
    ("oleada_acabada.gif", "oleada", 860, 1080),
    ("especial.gif", "especial", 818, 1240),
    ("tiempo_y_game_over.gif", "tiempo", 818, 1160),
]


def main(salida):
    raiz = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    for fichero, grab, desde, hasta in TRAMOS:
        n, s = vdp.gif(os.path.join(raiz, "work", grab + ".bin"),
                       os.path.join(salida, fichero), desde, hasta, cada=2, tope_ms=4000)
        print("%-24s %4d imagenes, %5.1f s, %7d bytes" % (
            fichero, n, s, os.path.getsize(os.path.join(salida, fichero))))


if __name__ == "__main__":
    main(sys.argv[1])
