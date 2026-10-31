# Los textos

Todos los textos del cartucho, en inglés: no hay más. Van en bloques de "fila y
columna de la pantalla, letras, 0xFF" (`pinta_textos`, 0x0792). La fuente no
sigue el orden del alfabeto (la P es la letra 0xD0, la A la 0xD2, la cifra 0 la
0xE2), y las letras del menú están cargadas cuatro veces, cada copia en su
color (0x8B, 0xA2, 0xB9 y 0xD0).

| Dónde | Texto | Traducción |
|---|---|---|
| título (0x13F2, filas 2 y 3) | SONY | (el nombre, hecho con letras de dibujo) |
| título (0x140B, filas 7 a 13) | HIT BIT | (el logotipo de la gama de MSX de Sony, siete filas de letras) |
| título (0x1494) y menú (0x14B3) | CRAZY TRAIN | TREN LOCO |
| título (0x14A2) y menú (0x14C1) | (C) Konami 1983 | (el logotipo de Konami son cinco letras) |
| menú (0x14D1) | HIGH-SCORE | RÉCORD |
| menú (0x14DF) | "1" KEY 1 PLAYER W/ JOYSTICK | tecla "1": un jugador con mando |
| menú (0x1500) | "2" KEY 2 PLAYERS W/ JOYSTICK | tecla "2": dos jugadores con mando |
| menú (0x1521) | "3" KEY 1 PLAYER W/ KEYBOARD | tecla "3": un jugador con teclado |
| menú (0x1542) | "4" KEY 2 PLAYERS W/ KEYBOARD | tecla "4": dos jugadores con teclado |
| al empezar y al cambiar el turno (0x15A0, 0x15B2) | PLAYER 1 / PLAYER 2 | JUGADOR 1 / JUGADOR 2 |
| marcador (0x1563) | 1P-00000 2P-00000 HIGH-00000 | J1, J2 y RÉCORD (la última cifra es siempre un cero pintado) |
| marcador (0x15BE) | STAGE | FASE |
| al acabar (0x1583) | GAME OVER | FIN DE LA PARTIDA |

Las cuatro opciones del menú son **cuatro textos enteros**, no una plantilla:
los dos de arriba con las letras de 0x8B y los dos de abajo con las de 0xA2,
que son las mismas en otro color. El rótulo 1P- o 2P- del que juega
**parpadea** cada 24 cuadros (`parpadea_rotulo`, 0x07B7), y lo toma del propio
texto del marcador (0x1565 y 0x156E).
