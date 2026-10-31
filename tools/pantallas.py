#!/usr/bin/env python3
"""El titulo y el menu, EJECUTANDO el cartucho con tools/z80run.py:

  - el titulo: INIT (0x0160) hasta la espera de nueve tramos (0x0211), con
    SONY, el logotipo de HIT BIT, CRAZY TRAIN y (c) Konami 1983 ya pintados;
  - el menu: desde 0x021C hasta que empieza a mirar las teclas (0x0231).
logotipo.png, la cabecera de la web: CRAZY TRAIN y (c) Konami 1983 del titulo.
Los registros, los de 0x1346. Cada una se coteja con la VRAM de openMSX del
cuadro que se diga: la imagen entera, punto a punto.

Uso: pantallas.py <dir> [grabacion.bin cuadro_titulo cuadro_menu]
"""
import os
import sys

AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, AQUI)
import vdp                  # noqa: E402
from z80run import Z80      # noqa: E402

RAIZ = os.path.dirname(AQUI)


class C(Z80):
    def _escribir(self, d, v):
        if (d & 0xFFFF) >= 0xE000:
            self.mem[d & 0xFFFF] = v & 0xFF


def main(argv):
    rom = open(os.path.join(RAIZ, "crazytrain.rom"), "rb").read()[:0x2000]
    regs = rom[0x1346:0x134E]
    z = C()
    z.carga(rom, 0)
    z.corre_hasta(0x0160, 0x0211, tope=40_000_000)
    titulo = bytes(z.vdp.vram)
    z.corre_hasta(0x021C, 0x0231, tope=40_000_000)
    menu = bytes(z.vdp.vram)
    for nom, v in (("titulo", titulo), ("menu", menu)):
        vdp.imagen(v, regs, 2).save(os.path.join(argv[0], "%s.png" % nom))
    # el logotipo de la cabecera de la web: el nombre del juego y (c) Konami
    # 1983 (filas 17 a 20 del titulo); SONY y HIT BIT son de la gama, no del juego
    vdp.imagen(titulo, regs, 2).crop((128, 272, 384, 336)).save(
        os.path.join(argv[0], "logotipo.png"))
    if len(argv) > 1:
        cs = list(vdp.cuadros(argv[1]))
        for nom, v, n in (("titulo", titulo, argv[2]), ("menu", menu, argv[3])):
            suya = cs[int(n)]
            a, b = vdp.tela(v, regs), vdp.tela(suya["vram"], suya["regs"])
            dif = sum(1 for y in range(192) for x in range(256) if a[y][x] != b[y][x])
            print("%s contra el cuadro %s: %d puntos distintos de 49152, registros %s"
                  % (nom, n, dif, "iguales" if bytes(regs) == suya["regs"] else "DISTINTOS"))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
