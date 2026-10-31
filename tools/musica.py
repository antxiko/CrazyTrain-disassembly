#!/usr/bin/env python3
"""Las musicas de Crazy Train, EJECUTANDO su propio motor de sonido.

tools/z80run.py ejecuta el codigo del cartucho (8 KB en 0x0000, sin BIOS: el
PSG se escribe con `out (0xA0)` / `out (0xA1)` y cada escritura se apunta).
Cada pieza: `psg_inicial` (0x0F1F) con B = 0x0F, como antes de cada musica
(cinco parejas: el mezclador sin ruido y los volumenes a cero), el registro de
tono de cada canal como lo deja `init` (0xE3A3 = 0, 0xE3AB = 2, 0xE3B3 = 4),
los punteros de los canales como los pone el juego (0xE3A0, 0xE3A8, 0xE3B0)
y, en cada cuadro, lo mismo que la interrupcion (0x00DE): `canal_musica`
(0x0103) con HL = 0xE3A1, 0xE3A9 y 0xE3B1. Cada pieza acaba cuando los tres
canales se callan.

`cotejo` pone al lado los registros del PSG que grabo openMSX (las
grabaciones de tools/guiones, que apuntan los 16 registros en cada entrada a
la interrupcion) y los de la ejecucion, cuadro a cuadro.

Uso:  musica.py registros <clave> | todas docs/audio | cotejo
"""
import os
import sys

AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, AQUI)
import motor_musica as mm            # noqa: E402
from z80run import Z80                # noqa: E402

RAIZ = os.path.dirname(AQUI)
ROM = os.path.join(RAIZ, "crazytrain.rom")
HZ = 60
CANALES = (0xE3A1, 0xE3A9, 0xE3B1)

# (clave, fichero, titulo es, titulo en, {canal: puntero}, quien la pide,
#  (grabacion, primer cuadro en que suena) para el cotejo)
PIEZAS = [
    ("salida", "musica_salida.mp3", "Al empezar la partida", "Starting the game",
     {0xE3A0: 0x1717, 0xE3A8: 0x174B, 0xE3B0: 0x17AC}, "`empieza_partida` (0x02B9)",
     ("sola", 400)),
    ("fase", "musica_fase.mp3", "La fase superada", "Stage cleared",
     {0xE3A0: 0x17D1, 0xE3A8: 0x1802, 0xE3B0: 0x1833}, "`fase_superada` (0x03C8)",
     ("fases", 1205)),
    ("campanilla", "musica_campanilla.mp3", "La campanilla de las estaciones",
     "The station chime",
     {0xE3A0: 0x1849}, "`en_marcha` (0x0458) al arrancar cada fase, y `segunda_casilla` "
     "(0x0E30) en cada estacion visitada", ("sola", 600)),
    ("final", "musica_final.mp3", "GAME OVER", "GAME OVER",
     {0xE3A0: 0x18C6, 0xE3A8: 0x18FD, 0xE3B0: 0x1925}, "`game_over` (0x0758)",
     ("empuja", 2134)),
]


class Cartucho(Z80):
    def __init__(self, rom):
        super().__init__()
        self.escrituras = []
        self.maq = mm.MaquinaMusica(self.escrituras)
        self.vdp = self.maq.vdp
        self.carga(rom[:0x2000], 0)

    def _escribir(self, d, v):
        if (d & 0xFFFF) < 0xE000:
            return
        self.mem[d & 0xFFFF] = v & 0xFF


def ejecuta(rom, punteros, maximo=HZ * 60, resto=None):
    """resto: {canal: lo que le quedaba a su nota (+2) y su tempo (+4)} como
    los tenia la RAM al pedir la pieza; sin el, a cero."""
    z = Cartucho(rom)
    z.sp = 0xE800
    z.b = 0x0F
    z.corre(0x0F1F)
    z.mem[0xE3A3], z.mem[0xE3AB], z.mem[0xE3B3] = 0, 2, 4
    for c, p in punteros.items():
        z.mem[c] = p & 0xFF
        z.mem[c + 1] = p >> 8
        z.mem[c + 2], z.mem[c + 4] = (resto or {}).get(c, (0, 0))
    cuadros = [list(z.escrituras)]
    for n in range(maximo):
        z.escrituras.clear()
        for h in CANALES:
            z.hl = h
            z.corre(0x0103)
        cuadros.append(list(z.escrituras))
        if all(z.mem[h] == 0 for h in CANALES):
            break
    return cuadros


def estados(cuadros, inicial=None):
    """Los registros del PSG despues de cada cuadro (desde los de `inicial`)."""
    regs, out = list(inicial or [0] * 16), []
    for escr in cuadros:
        for r, v in escr:
            if r < 16:
                regs[r] = v
        out.append(list(regs))
    return out


def cotejo(rom, pieza):
    """Cuadro a cuadro, los tonos (0-5) y volumenes (8-10) de los canales que
    usa la pieza, contra la grabacion de openMSX. La grabacion apunta la RAM y
    el PSG al ENTRAR en la interrupcion: el primer cuadro en que el puntero del
    canal 1 es el de la pieza es el de la peticion, y su RAM dice lo que le
    quedaba a la nota anterior de cada canal (0x0103 no lo pone a cero); el
    PSG del cuadro n + k es lo que deja nuestro cuadro k."""
    import vdp
    clave, _, _, _, punteros, _, (grab, desde) = pieza
    cs = list(vdp.cuadros(os.path.join(RAIZ, "work", grab + ".bin")))
    p1 = punteros[0xE3A0]
    n0 = next(n for n in range(desde, len(cs))
              if cs[n]["ram"][0x3A0] | (cs[n]["ram"][0x3A1] << 8) == p1)
    ram = cs[n0]["ram"]
    resto = {c: (ram[c + 2 - 0xE000], ram[c + 4 - 0xE000]) for c in punteros}
    nuestros = estados(ejecuta(rom, punteros, resto=resto), cs[n0]["psg"])
    canales = [{0xE3A0: 0, 0xE3A8: 1, 0xE3B0: 2}[c] for c in punteros]
    regs = sorted(sum(([2 * k, 2 * k + 1, 8 + k] for k in canales), []))
    total = len(nuestros) - 1
    malos = [k for k in range(1, total + 1)
             if n0 + k >= len(cs)
             or any(cs[n0 + k]["psg"][r] != nuestros[k][r] for r in regs)]
    return clave, grab, n0, total, malos, resto


def main(argv):
    rom = open(ROM, "rb").read()
    piezas = {p[0]: p for p in PIEZAS}
    if argv[0] == "registros":
        cu = ejecuta(rom, piezas[argv[1]][4])
        for i, e in enumerate(cu):
            print("%5d %s" % (i, " ".join("%X=%02X" % rv for rv in e)))
    elif argv[0] == "todas":
        os.makedirs(argv[1], exist_ok=True)
        for clave, fichero, _, _, punteros, _, _ in PIEZAS:
            cu = ejecuta(rom, punteros)
            cu += [[]] * 30
            mm.a_mp3(mm.sintetiza(cu, HZ), os.path.join(argv[1], fichero), 0, HZ)
            print("%s: %d cuadros (%.1f s) -> %s" % (clave, len(cu) - 30, (len(cu) - 30) / HZ, fichero))
    elif argv[0] == "cotejo":
        for p in PIEZAS:
            clave, grab, n0, total, malos, resto = cotejo(rom, p)
            print("%-10s %s, pedida en el cuadro %d (le quedaba a cada canal: %s): "
                  "%d cuadros, %d distintos %s"
                  % (clave, grab, n0, " ".join(str(r[0]) for r in resto.values()),
                     total, len(malos), malos[:8]))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
