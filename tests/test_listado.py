"""Lo que se afirma del cartucho, comprobado contra sus bytes.

Corre con el cartucho delante y sin el: cuando no esta, la imagen se rehace
desde las filas defb/defw del listado, que si viaja con el repositorio. Sin el
cartucho solo se comprueba lo que cae en datos.
"""

import os
import re
import subprocess
import sys
import unittest

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(RAIZ, "tools"))

ROM = os.path.join(RAIZ, "crazytrain.rom")
ASM = os.path.join(RAIZ, "src", "crazytrain.asm")
NOTAS = os.path.join(RAIZ, "src", "crazytrain.notes")
ORG = 0x0000
TAM = 8192

FILA = re.compile(r"^\s+def(b|w)\s+([0-9a-fA-F,h ]+)\s*;\s*([0-9a-f]{4})")


def imagen_desde_el_listado():
    img = bytearray(TAM)
    with open(ASM, encoding="utf-8") as f:
        for ln in f:
            m = FILA.match(ln)
            if not m:
                continue
            ancho, cuerpo, dirr = m.group(1), m.group(2), int(m.group(3), 16)
            p = dirr - ORG
            for tok in cuerpo.split(","):
                tok = tok.strip().rstrip("h")
                if not tok:
                    continue
                v = int(tok, 16)
                if ancho == "b":
                    img[p] = v
                    p += 1
                else:
                    img[p] = v & 0xFF
                    img[p + 1] = v >> 8
                    p += 2
    return bytes(img)


def lee():
    if os.path.exists(ROM):
        with open(ROM, "rb") as f:
            return f.read()[:TAM]
    return imagen_desde_el_listado()


class Cabecera(unittest.TestCase):
    def test_ab_e_init_en_la_pagina_0(self):
        rom = lee()
        self.assertEqual(rom[:2], b"AB")
        self.assertEqual(rom[2] | (rom[3] << 8), 0x0160)

    def test_solo_usa_init(self):
        self.assertEqual(lee()[4:16], b"\x00" * 12)

    def test_el_volcado_son_cuatro_copias_de_8_kb(self):
        """Con el cartucho delante, sus cuatro cuartos; sin el, el listado
        tiene que dar los 8 KB enteros."""
        if os.path.exists(ROM):
            with open(ROM, "rb") as f:
                d = f.read()
            self.assertEqual(len(d), 32768)
            for k in range(1, 4):
                self.assertEqual(d[k * TAM:(k + 1) * TAM], d[:TAM])
        self.assertEqual(len(lee()), TAM)


class Tableros(unittest.TestCase):
    def test_estaciones_por_tablero(self):
        self.assertEqual(list(lee()[0x11A7:0x11AB]), [6, 8, 8, 10])

    def test_cada_lista_da_dos_casillas_por_estacion(self):
        rom = lee()
        ptr = [rom[0x115F + 2 * k] | (rom[0x1160 + 2 * k] << 8) for k in range(4)]
        self.assertEqual(ptr, [0x1167, 0x1173, 0x1183, 0x1193])
        fin = ptr[1:] + [0x11A7]
        for k in range(4):
            self.assertEqual(fin[k] - ptr[k], 2 * rom[0x11A7 + k])

    def test_las_casillas_de_las_estaciones_son_de_estacion(self):
        """Cada casilla de la lista lleva en su tablero una pieza 0-7."""
        rom = lee()
        for k in range(4):
            p = rom[0x115F + 2 * k] | (rom[0x1160 + 2 * k] << 8)
            tab = rom[0x11AB + 48 * k:0x11DB + 48 * k]
            for c in rom[p:p + 2 * rom[0x11A7 + k]]:
                self.assertLess(tab[c], 8, (k, c))

    def test_el_hueco_en_la_casilla_12(self):
        rom = lee()
        for k in range(4):
            self.assertEqual(rom[0x11AB + 48 * k + 12], 0x0F)

    def test_el_tren_blanco_sale_de_un_cruce(self):
        """La plantilla pone el tren en la casilla 28; en los cuatro tableros
        hay alli un cruce (0x0E)."""
        rom = lee()
        self.assertEqual(rom[0x12B9], 28)
        for k in range(4):
            self.assertEqual(rom[0x11AB + 48 * k + 28], 0x0E)


class LaFicha(unittest.TestCase):
    def test_el_codigo_de_la_plantilla_salta_a_0x0850(self):
        """ld b,(ix+0) / inc hl / inc hl / inc (hl) / ld a,l / sub 5 / ld l,a /
        ld a,b / jp 0x0850."""
        self.assertEqual(lee()[0x12C0:0x12CE],
                         bytes.fromhex("dd460023233 47dd6056f78c35008".replace(" ", "")))

    def test_los_guiones_acaban_en_ff(self):
        rom = lee()
        for k in range(16):
            g = rom[0x12FA + 4 * k:0x12FE + 4 * k]
            self.assertIn(0xFF, g, k)


class Pantalla(unittest.TestCase):
    def test_screen2_y_sprites_de_16(self):
        """Los registros de 0x1346: M3 a uno (SCREEN 2), sprites de 16x16."""
        r = lee()[0x1346:0x134E]
        self.assertEqual(r[0] & 2, 2)
        self.assertEqual(r[1] & 0x18, 0)
        self.assertEqual(r[1] & 2, 2)

    def test_los_sprites_acaban_en_el_ultimo_byte(self):
        """0x01DB carga 128 + 256 bytes de sprites desde 0x1E7F: 12 patrones,
        hasta 0x1FFE."""
        self.assertEqual(0x1E7F + 128 + 256, 0x1FFF)


class ElListado(unittest.TestCase):
    def test_densidad_y_flojas(self):
        salida = subprocess.run(
            [sys.executable, os.path.join(RAIZ, "tools", "densidad.py"), ASM],
            capture_output=True, text=True, check=True).stdout
        m = re.search(r"(\d+) instrucciones, (\d+) comentarios", salida)
        self.assertGreaterEqual(int(m.group(2)) * 100, 40 * int(m.group(1)))
        self.assertIn("---- 0 rutinas por debajo del 10 %", salida)

    def test_ningun_call_sin_nombre(self):
        salida = subprocess.run(
            [sys.executable, os.path.join(RAIZ, "tools", "sin_bautizar.py"), ASM],
            capture_output=True, text=True, check=True).stdout
        self.assertTrue(salida.startswith("0 rutinas sin bautizar"), salida[:200])

    def test_cada_comentario_en_su_instruccion(self):
        salida = subprocess.run(
            [sys.executable, os.path.join(RAIZ, "tools", "valida_c.py"), ASM, NOTAS],
            capture_output=True, text=True, check=True).stdout
        self.assertIn("0 fuera de sitio, 0 repetidos", salida)


if __name__ == "__main__":
    unittest.main()
