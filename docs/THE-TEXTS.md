# The texts

Every text in the cartridge, in English: there are no more. They come in
blocks of "screen row and column, characters, 0xFF" (`pinta_textos`, 0x0792).
The font does not follow alphabetical order (P is character 0xD0, A is 0xD2,
the digit 0 is 0xE2), and the menu letters are loaded four times, each copy in
its own colour (0x8B, 0xA2, 0xB9 and 0xD0).

| Where | Text | Note |
|---|---|---|
| title (0x13F2, rows 2 and 3) | SONY | (the name, made of drawing characters) |
| title (0x140B, rows 7 to 13) | HIT BIT | (the logo of Sony's MSX range, seven rows of characters) |
| title (0x1494) and menu (0x14B3) | CRAZY TRAIN | |
| title (0x14A2) and menu (0x14C1) | (C) Konami 1983 | (the Konami logo is five characters) |
| menu (0x14D1) | HIGH-SCORE | |
| menu (0x14DF) | "1" KEY 1 PLAYER W/ JOYSTICK | |
| menu (0x1500) | "2" KEY 2 PLAYERS W/ JOYSTICK | |
| menu (0x1521) | "3" KEY 1 PLAYER W/ KEYBOARD | |
| menu (0x1542) | "4" KEY 2 PLAYERS W/ KEYBOARD | |
| at the start and when the turn changes (0x15A0, 0x15B2) | PLAYER 1 / PLAYER 2 | |
| scores (0x1563) | 1P-00000 2P-00000 HIGH-00000 | (the last digit is always a painted zero) |
| scores (0x15BE) | STAGE | |
| at the end (0x1583) | GAME OVER | |

The four menu options are **four whole texts**, not a template: the top two
with the letters at 0x8B and the bottom two with those at 0xA2, which are the
same letters in another colour. The 1P- or 2P- label of the player in turn
**blinks** every 24 frames (`parpadea_rotulo`, 0x07B7), and is taken from the
score line text itself (0x1565 and 0x156E).
