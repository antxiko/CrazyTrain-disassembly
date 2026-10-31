# The music

Three short tunes and a chime, on the three PSG channels. They are not
recorded by hand: `tools/musica.py` **runs the cartridge's own sound engine**
with `tools/z80run.py` -`psg_inicial` (0x0F1F), the channel pointers as the
game sets them, and on every frame `canal_musica` (0x0103) with the three
channels, like the interrupt- and logs what it writes to the PSG.

**Checked against openMSX**: in the recorded games, the tone and volume
registers of the channels each piece uses match those of the running engine
frame by frame, **the whole piece** each time: 257, 117, 41 and 121 frames,
**0 different**.

Every note is three bytes: the low tone, the high tone with the duration in
the high nibble, and the volume; a lone 0x01 switches the channel to a tempo
four times shorter (only the chime uses it) and 0xFF silences it.

## Starting the game

`empieza_partida` (0x02B9), with the chosen option on screen. The program
waits for channel 2 to end.

<audio controls src="audio/musica_salida.mp3"></audio>

## Stage cleared

`fase_superada` (0x03C8), before the next board.

<audio controls src="audio/musica_fase.mp3"></audio>

## The chime

Plays on channel 1 at the start of every stage and at every station visited,
except the last one (`segunda_casilla`, 0x0E30).

<audio controls src="audio/musica_campanilla.mp3"></audio>

## GAME OVER

`game_over` (0x0758).

<audio controls src="audio/musica_final.mp3"></audio>

## The rest

The sound effects: the clatter of the train on channel 3, with noise, which
repeats for as long as the stage lasts (faster with the train at full speed),
the push, the black-train warning and the crash. The demo is silent: the
interrupt does not move the channels (0x00D8) and `psg_inicial` closes the
whole mixer (0x0F2E).
