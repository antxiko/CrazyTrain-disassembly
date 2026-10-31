# Crazy Train - desensamblado comentado

*(Also [in English](README.md).)*

El desensamblado comentado de **Crazy Train** (Konami para Sony, 1983) para MSX: una ROM de 8 KB escrita para la página 0, que no usa la BIOS.

- **100 %** del binario explicado: 4.423 bytes de código y 3.769 de datos con nombre, ni un byte sin asignar.
- **42,2 %** del listado comentado, 280 rutinas y etiquetas, ninguna por debajo del 10 % de comentarios.
- El listado se reensambla en la ROM original **byte a byte** (y cuatro veces seguida da el volcado de 32 KB).
- Las piezas, los trenes, los ocho primeros tableros, el título y el menú salen de los bytes del cartucho, cotejados punto a punto con openMSX; los empujones, las estaciones, los trenes negros, los choques, la fase superada y el GAME OVER, jugados en GIF; las tres músicas y la campanilla, de su propio motor de sonido; cuatro fallos, medidos.

La web: <https://antxiko.github.io/CrazyTrain-disassembly/es/>
(en inglés: <https://antxiko.github.io/CrazyTrain-disassembly/>).

## Reproducirlo

La imagen del cartucho no se distribuye. Pon la tuya en la raíz como `crazytrain.rom` (sha256 `8cf0f8a2...`) y ejecuta `make`. El detalle, en [POR DENTRO](docs/es/POR-DENTRO.md).

## Legal

El juego es de Konami, de Sony y de sus titulares. La licencia de `LICENSE` cubre solo las herramientas, los comentarios, el análisis y la documentación de aquí. Mira [AVISO-LEGAL.md](AVISO-LEGAL.md).
