# Crazy Train - commented disassembly

*(También [en castellano](README.es.md).)*

The commented disassembly of **Crazy Train** (Konami for Sony, 1983) for the MSX: an 8 KB ROM written for page 0, which does not use the BIOS.

- **100%** of the binary explained: 4,423 bytes of code and 3,769 of named data, not one byte unassigned.
- **42.2%** of the listing commented, 280 routines and labels, none under 10% comments.
- The listing reassembles into the original ROM **byte for byte** (and four times in a row gives the 32 KB dump).
- The tiles, the trains, the first eight boards, the title and the menu come from the cartridge's bytes, checked dot by dot against openMSX; the pushes, the stations, the black trains, the crashes, the cleared stage and GAME OVER, played in GIF; the three tunes and the chime, from its own sound engine; four bugs, measured.

The website: <https://antxiko.github.io/CrazyTrain-disassembly/>
(in Spanish: <https://antxiko.github.io/CrazyTrain-disassembly/es/>).

## Reproducing it

The cartridge image is not distributed. Put yours in the root as `crazytrain.rom` (sha256 `8cf0f8a2...`) and run `make`. The details, in [UNDER THE HOOD](docs/UNDER-THE-HOOD.md).

## Legal

The game belongs to Konami, Sony and their rights holders. The licence in `LICENSE` covers only the tools, comments, analysis and documentation here. See [LEGAL-NOTICE.md](LEGAL-NOTICE.md).
