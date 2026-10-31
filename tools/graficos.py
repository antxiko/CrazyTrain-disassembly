#!/usr/bin/env python3
"""Los graficos de Crazy Train, desde lo que el propio cartucho sube a la VRAM.

Se ejecuta INIT (0x0160) con tools/z80run.py hasta que acaba de subir las
letras, los sprites y los colores (0x0201: los colores de 0x134E, ya en los
tres tercios), y de esa VRAM se dibuja:

  piezas.png      las 21 piezas (0x00-0x14), cada una sus 4 x 4 letras de 0x15C7
  sprites.png     el tren blanco en sus 8 direcciones (patrones 0x00-0x1C, color
                  15) y el negro en sus 4 (0x20-0x2C, color 1), sobre gris
  tablero1-4.png  los cuatro tableros de 0x11AB, casilla a casilla con sus piezas
  revuelto5-8.png los tableros de las fases 5 a 8: el cuarto, revuelto como lo
                  hace 0x0B5A con el numero de la fase anterior

Cada tablero se coteja PUNTO A PUNTO con la pantalla grabada en openMSX
(work/fases.bin, el primer cuadro de cada fase, sin sprites), de la fila 2 a
la 23: la 0 y la 1 llevan los marcadores encima del marco.

Uso: graficos.py <dir>
"""
import os
import sys

AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, AQUI)
import vdp                  # noqa: E402
from z80run import Z80      # noqa: E402

RAIZ = os.path.dirname(AQUI)
REGS = bytes([0x02, 0xE2, 0x0E, 0x7F, 0x07, 0x76, 0x03, 0xE1])   # 0x1346
# El primer cuadro de cada fase en work/fases.bin (tools/guiones/fases.tcl):
# el primero con la interrupcion ya moviendo trenes (0xE200 a cero)
COTEJO = {1: 736, 2: 1376, 3: 2528, 4: 3584, 5: 4640, 6: 5696, 7: 6688, 8: 7680}


class C(Z80):
    def _escribir(self, d, v):
        if (d & 0xFFFF) >= 0xE000:
            self.mem[d & 0xFFFF] = v & 0xFF


def vram():
    rom = open(os.path.join(RAIZ, "crazytrain.rom"), "rb").read()[:0x2000]
    z = C()
    z.carga(rom, 0)
    z.corre_hasta(0x0160, 0x0201, tope=40_000_000)
    return bytearray(z.vdp.vram), rom


def tablero_de_fase(rom, fase):
    """Las 48 casillas del tablero de la fase (1, 2, ...), como las deja
    0x0CBE: los tres primeros tal cual, y desde el cuarto, revuelto (0x0B5A)
    con el numero (BCD) de la fase anterior."""
    n = min(fase, 4) - 1
    t = bytearray(rom[0x11AB + 48 * n:0x11DB + 48 * n])
    if n < 3:
        return t
    # 0x0313 revuelve ANTES de que 0x0320 suba la fase: cuenta la anterior
    bcd = int(str(fase - 1), 16)
    a = bcd
    while a >= 0x11:
        a -= 0x10
    de = 0x126B + a
    c = 9
    while c != 0x29:
        if rom[de] == 0:
            de = 0x126B
            continue
        t[c] = rom[de]
        de += 1
        c += 1
        if c & 7 == 7:
            c += 2
    t[0x0C] = 0x0F
    t[0x1C] = 0x0E
    a = bcd
    if a < 0x11:
        a -= 1
        b = a if a < 7 else 6
    else:
        b = 8 if a >= 0x20 else (7 if a >= 0x14 else 6)
        while a >= 0x10:
            a -= 0x10
    for k in range(b):
        t[rom[0x127E + a + k]] = 0x14
    return t


def nombres(rom, tablero):
    """La tabla de nombres que pinta 0x0402: cada casilla, 4 x 4 letras desde
    0x3820 (fila 1); la fila 5 del tablero se corta en la 23 de la pantalla."""
    nm = bytearray(768)
    for c, pieza in enumerate(tablero):
        f, col = c >> 3, c & 7
        letras = rom[0x15C7 + 16 * pieza:0x15D7 + 16 * pieza]
        for y in range(4):
            fila = 1 + 4 * f + y
            if fila < 24:
                nm[fila * 32 + col * 4:fila * 32 + col * 4 + 4] = letras[4 * y:4 * y + 4]
    return nm


def pinta(v, nm, desde=0, hasta=24):
    from PIL import Image
    w = bytearray(v)
    w[0x3800:0x3B00] = nm
    t = vdp.tela(w, REGS, con_sprites=False)
    im = Image.new("RGB", (256, 8 * (hasta - desde)))
    for y in range(8 * desde, 8 * hasta):
        for x in range(256):
            im.putpixel((x, y - 8 * desde), vdp.PALETA[t[y][x]])
    return im, t


def sprite(v, n, color, fondo=14, esc=3):
    from PIL import Image
    im = Image.new("RGB", (16, 16), vdp.PALETA[fondo])
    for q in range(4):
        ox, oy = (q // 2) * 8, (q % 2) * 8
        for y in range(8):
            b = v[0x1800 + (n + q) * 8 + y]
            for x in range(8):
                if b & (0x80 >> x):
                    im.putpixel((ox + x, oy + y), vdp.PALETA[color])
    return im.resize((16 * esc, 16 * esc), Image.NEAREST)


def main(argv):
    from PIL import Image
    out = argv[0]
    v, rom = vram()
    grab = list(vdp.cuadros(os.path.join(RAIZ, "work", "fases.bin")))
    # las piezas: 7 por fila
    pz = Image.new("RGB", (7 * 40 + 8, 3 * 40 + 8))
    for p in range(21):
        nm = bytearray(768)
        for y in range(4):
            nm[y * 32:y * 32 + 4] = rom[0x15C7 + 16 * p + 4 * y:0x15C7 + 16 * p + 4 * y + 4]
        im, _ = pinta(v, nm, 0, 4)
        pz.paste(im.crop((0, 0, 32, 32)), (8 + (p % 7) * 40, 8 + (p // 7) * 40))
    pz = pz.resize((pz.width * 2, pz.height * 2), Image.NEAREST)
    pz.save(os.path.join(out, "piezas.png"))
    # los sprites
    sp = Image.new("RGB", (8 * 54 + 6, 2 * 54 + 6), vdp.PALETA[1])
    for k in range(8):
        sp.paste(sprite(v, 4 * k, 15), (6 + 54 * k, 6))
    for k in range(4):
        sp.paste(sprite(v, 0x20 + 4 * k, 1), (6 + 54 * k, 60))
    sp.save(os.path.join(out, "sprites.png"))
    # los tableros, cotejados
    for fase, cuadro in sorted(COTEJO.items()):
        tab = tablero_de_fase(rom, fase)
        im, t = pinta(v, nombres(rom, tab), 1, 24)
        suya = vdp.tela(grab[cuadro]["vram"], grab[cuadro]["regs"], con_sprites=False)
        dif = sum(1 for y in range(16, 192) for x in range(256) if t[y][x] != suya[y][x])
        nombre = ("tablero%d.png" % fase) if fase <= 4 else ("revuelto%d.png" % fase)
        im.save(os.path.join(out, nombre))
        print("%-14s fase %d: %d puntos distintos de openMSX (cuadro %d, filas 2-23)"
              % (nombre, fase, dif, cuadro))
    print("piezas.png sprites.png")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
