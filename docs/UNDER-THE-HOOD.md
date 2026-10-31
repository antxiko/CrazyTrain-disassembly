# Under the hood

## Rebuilding the ROM

`make verify` assembles `src/crazytrain.asm` with pasmo and out comes the 8 KB
ROM **byte for byte**; repeated four times, it gives the 32 KB dump. `make
sanity` checks what reassembling does not cover: that no byte declared as data
is read as code, and that all 8,192 are explained. `make test` runs the tests.
The ROM is not in the repository: put it in the root as `crazytrain.rom` (the
GoodMSX dump, `[!]`, sha1 `bbe8df03...`).

| | bytes |
|---|---|
| traced code | 4,423 |
| named data | 3,769 |
| unexplained | 0 |

The listing carries 1,103 comments over 2,612 instructions (42.2%), 280
routines and labels, none below 10% commented, and no called routine without a
name.

## Page 0, without the BIOS

The header gives INIT at `0x0160`, and the BIOS calls it with CALSLT, which
puts the cartridge in page 0. From there on everything belongs to the
cartridge: RAM and VRAM cleared, the interrupt in mode 1 (which jumps to
`0x0038`), the stack at `0xE800`, and its RSTs:

| | What it does |
|---|---|
| RST 10h | HL + A |
| RST 18h | the address DE to the VDP |
| RST 20h | B bytes from HL to VRAM, at address DE |
| RST 28h | B times the byte C into VRAM, from DE |
| RST 30h | the player in turn (0 or 1) in A, with Z if it is player 1 |

The screen is SCREEN 2 with its three thirds the same: the characters and
their colours are uploaded once and copied from VRAM to VRAM to the other two
(`copia_en_vram`, 0x0F3E). The board is characters in the name table; the
trains, four 16 x 16 sprites.

## Each train's record and its script

The four trains (the white one and three black ones) have a 32-byte record at
`0xE300`, `0xE320`, `0xE340` and `0xE360`, copied from the template at
0x12B7:

| | |
|---|---|
| +1 | the tile on its square |
| +2 | its square (row x 8 + column) |
| +3 | its direction on the board (0 up, 1 right, 2 down, 3 left) |
| +4 | its number (0 the white one) |
| +5 | its sprite's direction (0-7) |
| +6 | what is left of the stretch |
| +7, +8 | its script |
| +9 | code: reads the next script byte and jumps to 0x0850 |

Each script byte is "times x 16 + sprite direction": while there are times
left, the sprite moves one dot (`un_pixel`, 0x08B7, with the eight snippets at
0x0AE0, `dec d`, `inc e`...); 0xFF ends the square and 0x10 is a dead end.
When the square ends, `casilla_siguiente` (0x0E61) moves on to the next one
and `entra_en_casilla` (0x0DD6) looks up in the exit table (0x12CE), from the
tile and the side it enters by, the direction it leaves in and its script.

Each player has their four spare records (`0xE400` and `0xE480`) and their
board (`0xE100` and `0xE130`): when the turn changes they are saved and
restored.

## The interrupt

It runs almost the whole game: it moves the four trains (each with its own
frame count), the explosions, the push and its slide, the music and the
clocks. The game loop (0x047E) keeps the crashes, the score, the button, the
black-train countdown and the end of the stage. With `0xE200` at one, the
interrupt only moves the music and the clocks: that is how the banners and the
waits work.

## The RAM

| | |
|---|---|
| `0xE000`, `0xE001` | two players; the one in turn |
| `0xE002`, `0xE003` | each one's lives |
| `0xE005` | the white train has crashed |
| `0xE006`, `0xE007` | each player's hole |
| `0xE030`-`0xE03D` | the sliding tile |
| `0xE040`-`0xE044` | the station squares the white train goes through |
| `0xE045`, `0xE046` | the stations left |
| `0xE060`-`0xE062` | the button and the speed |
| `0xE067`-`0xE06C` | the black trains running, and the ones exploding |
| `0xE080`-`0xE09F` | each player's four sprites |
| `0xE100`, `0xE130` | each player's board |
| `0xE160`, `0xE170` | their stations: visited or not |
| `0xE1A0`-`0xE1AA` | the track ahead (whether it is going round in circles) |
| `0xE1B0`, `0xE1B1` | which board each one has |
| `0xE1E0` | the wait, in spans of 32 frames |
| `0xE210`-`0xE215` | each one's score and the high score (BCD) |
| `0xE230`, `0xE231` | each one's stage (BCD) |
| `0xE240`-`0xE24E` | the black train being announced: wait, countdown and station |
| `0xE260`-`0xE262` | the demo and its controller |
| `0xE300`-`0xE37F` | the four train records |
| `0xE3A0`-`0xE3B7` | the three music channels |

## The tools

| | |
|---|---|
| `tools/z80trace.py`, `tools/mkasm.py` | the tracing and the listing |
| `tools/presupuesto.py`, `tools/densidad.py` | the bytes explained and the comments |
| `tools/omsx_graba.tcl`, `tools/lanza_graba.ps1` | record the cartridge in openMSX, frame by frame |
| `tools/guiones/*.tcl` | what is pressed (and poked) in each recording |
| `tools/sonda_ret.tcl`, `tools/lanza_sonda.ps1` | how many times the program reaches an address |
| `tools/vdp.py`, `tools/gifs.py` | the TMS9918 in Python and the GIFs |
| `tools/pantallas.py`, `tools/graficos.py` | the title, the menu, the tiles, the sprites and the boards, running the cartridge with `tools/z80run.py`, and their checks |
| `tools/musica.py` | the tunes, running their engine, and their check |

## The checks

| | Result |
|---|---|
| the title and the menu | 0 different dots out of 49,152 |
| the eight boards (stages 1 to 8) | 0 different dots, rows 2 to 23 |
| the four tunes | whole, frame by frame: 0 different |
| the extra life (4,900 and 4,910 before a station) | one more train both times |
| the stage after 99 | 02 |
| the `ret` at 0x084F | 0 times in 20,000 frames |

## Code shared with other Konami cartridges

This disassembly has been compared, instruction by instruction, with
every other Konami one in the series. A block counts when the same
instructions, at least six of them from a label to its `ret` or its
unconditional jump, are in both cartridges; the addresses are left
aside, because they change from one cartridge to the next. Of the
other 63, **7** have at least one block in common with this one;
these are the ones that share the most:

| Cartridge | Blocks | Instructions | For example (here = there) |
|---|---:|---:|---|
| [Frogger](https://antxiko.github.io/Frogger-disassembly/) | 4 | 47 | `elige_opcion` (0x024D) = `MIRA_QUE_TECLA` |
| [Time Pilot](https://antxiko.github.io/TimePilot-disassembly/) | 3 | 29 | `texto_letra` (0x0797) = `ESCRIBE_ROTULO_BUCLE` |
| [Hyper Olympic 1](https://antxiko.github.io/HyperOlympic1-disassembly/) | 2 | 14 | `pinta_menu` (0x1142) = `PINTA_EL_MARCO_DEL_MENU` |

The whole matrix, the 64 cartridges against each other, is on
[The routines](https://antxiko.github.io/MSX-disassembly-database/THE-ROUTINES.html) in the series database, along
with the method and the program that measures it.
