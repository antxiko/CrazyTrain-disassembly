#!/usr/bin/env python3
"""EL CONTENIDO de la web de este cartucho: lo unico que es de este juego.

jekyll.py y make_web.py son la maquinaria y no llevan dentro el nombre de
ningun juego: lo leen de aqui.

Todas las cifras de aqui estan medidas sobre este cartucho, con las
herramientas de tools/: CODIGO y DATOS los imprime tools/presupuesto.py
(make sanity), INSTRUCCIONES, COMENTARIOS y RUTINAS los da tools/densidad.py
(make densidad: "de N" rutinas, "N instrucciones, M comentarios").
"""

NOMBRE = "Crazy Train"
ANIO = 1983
REPOSITORIO = "https://github.com/antxiko/CrazyTrain-disassembly"
SHA1 = "bbe8df034869a06cb263255ac04374de469c00ba"

CODIGO = 4423
DATOS = 3769
RUTINAS = 280
INSTRUCCIONES = 2612
COMENTARIOS = 1103


def densidad(idioma):
    """El porcentaje comentado, con la coma o el punto de cada idioma."""
    d = "%.1f" % (100.0 * COMENTARIOS / INSTRUCCIONES)
    return d.replace(".", ",") if idioma == "es" else d


PIE_LEGAL = {
    "es": "<em>Crazy Train</em> lo hizo Konami y lo public&oacute; Sony para MSX en "
          "1983, en un cartucho de 8 KB. Todos los derechos sobre el juego siguen "
          "siendo de sus titulares. Este trabajo es de preservaci&oacute;n, estudio "
          "y documentaci&oacute;n, y la imagen del cartucho no se distribuye.",
    "en": "<em>Crazy Train</em> was made by Konami and published by Sony for the MSX in "
          "1983, on an 8 KB cartridge. All rights in the game remain with their "
          "holders. This is preservation, study and documentation work, and the "
          "cartridge image is not distributed.",
}

PORTADA = {
    "es": dict(
        titulo="Crazy Train - desensamblado comentado",
        claim="Un puzle de piezas deslizantes con un tren encima: los empujones, las "
              "estaciones, los trenes negros y sus avisos, los choques y la fase "
              "superada jugados en GIF; los ocho primeros tableros desde los bytes "
              "del cartucho, cotejados punto a punto con openMSX; las m&uacute;sicas "
              "de su propio motor, y cuatro fallos medidos.",
        ficha=["Konami para Sony - <b>(c) Konami 1983</b>",
               "Cartucho de <b>8 KB</b> en la p&aacute;gina 0 (el volcado: cuatro "
               "copias, 32 KB)", "<b>MSX</b>", "Volcado <b>bbe8df03...</b>"],
        aviso="<b>Aqu&iacute; no hay capturas del juego.</b> Las piezas, los trenes, "
              "los tableros, el t&iacute;tulo y el men&uacute; salen de los bytes del "
              "cartucho (cotejados con openMSX), y los GIF son el cartucho "
              "<b>funcionando en openMSX</b>: en cada cuadro se apuntan la VRAM y los "
              "registros del VDP, y <b>c&oacute;digo nuestro los pinta</b>.",
    ),
    "en": dict(
        titulo="Crazy Train - commented disassembly",
        claim="A sliding-tile puzzle with a train on top: the pushes, the stations, the "
              "black trains and their warnings, the crashes and the cleared stage "
              "played in GIF; the first eight boards from the cartridge's bytes, "
              "checked dot by dot against openMSX; the tunes from its own engine, and "
              "four measured bugs.",
        ficha=["Konami for Sony - <b>(c) Konami 1983</b>",
               "<b>8 KB</b> cartridge in page 0 (the dump: four copies, 32 KB)",
               "<b>MSX</b>", "Dump <b>bbe8df03...</b>"],
        aviso="<b>There are no screenshots of the game here.</b> The tiles, the trains, "
              "the boards, the title and the menu come from the cartridge's bytes "
              "(checked against openMSX), and the GIFs are the cartridge <b>running in "
              "openMSX</b>: on every frame the VRAM and the VDP registers are logged, "
              "and <b>our own code paints them</b>.",
    ),
}

PAGINAS = [
    [("THE-GAME.html", "LA-PARTIDA.html", "The game", "La partida",
      "the rules as the code has them, the tiles, the push, the speed, the crashes, "
      "the stations and the black trains, played in GIF",
      "las reglas como las tiene el c&oacute;digo, las piezas, el empuj&oacute;n, la "
      "velocidad, los choques, las estaciones y los trenes negros, jugados en GIF"),
     ("THE-BOARDS.html", "LOS-TABLEROS.html", "The boards", "Los tableros",
      "the four boards, the shuffled ones from stage 4 and the stage cleared",
      "los cuatro tableros, los revueltos desde la fase 4 y la fase superada"),
     ("THE-SEQUENCES.html", "LAS-SECUENCIAS.html", "The sequences", "Las secuencias",
      "the title, the menu, the demo and GAME OVER",
      "el t&iacute;tulo, el men&uacute;, la demostraci&oacute;n y el GAME OVER"),
     ("THE-TEXTS.html", "LOS-TEXTOS.html", "The texts", "Los textos",
      "every text in the cartridge, with its translation",
      "todos los textos del cartucho, con su traducci&oacute;n"),
     ("THE-MUSIC.html", "LA-MUSICA.html", "The music", "La m&uacute;sica",
      "the three tunes and the chime, from its own sound engine and checked against "
      "openMSX",
      "las tres m&uacute;sicas y la campanilla, de su propio motor de sonido y "
      "cotejadas con openMSX")],
    [("CURIOSITIES.html", "CURIOSIDADES.html", "Curiosities", "Curiosidades",
      "four measured bugs, one that is not, the code in RAM, the overlapping "
      "tables, the leftovers, the open questions",
      "cuatro fallos medidos, uno que no lo es, el c&oacute;digo en la RAM, las "
      "tablas que se pisan, los restos, las preguntas abiertas")],
    [("UNDER-THE-HOOD.html", "POR-DENTRO.html", "Under the hood", "Por dentro",
      "rebuilding the ROM, page 0 without the BIOS, the train records and their "
      "scripts, the interrupt, the RAM, the tools and the shared code",
      "rehacer la ROM, la p&aacute;gina 0 sin la BIOS, las fichas de los trenes y sus "
      "guiones, la interrupci&oacute;n, la RAM, las herramientas y el c&oacute;digo "
      "compartido")],
]

# Repositorio nuevo: no hay paginas viejas que redirigir.
VIEJAS = {}

LOGOTIPO = "logotipo.png"
