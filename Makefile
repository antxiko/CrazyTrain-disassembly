# Crazy Train (Konami para Sony, MSX1, 1983) - desensamblado
#
# El orden de las cosas: trazar el flujo -> generar el listado -> comprobar que
# vuelve a dar la ROM byte a byte -> las comprobaciones que el reensamblado NO
# cubre.
#
# El volcado son 32 KB, pero son los mismos 8 KB cuatro veces: es una ROM de
# 8 KB que el cartucho no decodifica (ni A13 ni A14) y se ve repetida en las
# cuatro paginas. El programa esta
# escrito para la pagina 0 (org 0x0000): la BIOS llama a INIT con CALSLT, que
# pone el cartucho en la pagina de la direccion llamada, y desde ahi el juego
# se queda con la maquina entera, interrupcion y RST incluidos.
#
# El cartucho no se distribuye: hace falta en la raiz como crazytrain.rom, y
# `make comprueba` verifica su sha256.

JUEGO    = crazytrain
ROM      = $(JUEGO).rom
SHA      = 8cf0f8a22d9161d37d39cc48bc40b952b6f756df465f0d0c9afb69dac8a5d6ee
SHA8     = 4871d116ae385fa0b37fe8029d907fd1332f9a65cdea23a3ccdc5249c30bd0ae
SRC      = src
WORK     = work
ORG      = 0x0000
MITAD    = $(WORK)/$(JUEGO)8.bin
TITULO   = CRAZY TRAIN - Konami para Sony - MSX1 (1983) - ROM de 8 KB vista en las cuatro paginas

all: listado verify sanity test

$(ROM):
	@echo "=================================================================="
	@echo " Falta $(ROM), y este repositorio NO lo distribuye."
	@echo ""
	@echo " Es Crazy Train (Sony, 1983) para MSX, el volcado de 32768 bytes."
	@echo " Ponlo aqui con ese nombre. Para comprobar que es el mismo:"
	@echo "     shasum -a 256 $(ROM)"
	@echo "     $(SHA)"
	@echo "=================================================================="
	@false

comprueba: $(ROM)
	@echo "$(SHA)  $(ROM)" | shasum -a 256 -c -

# Los 8 KB de verdad: el primer cuarto del volcado. Que los cuatro son iguales
# lo comprueba `make verify`.
$(MITAD): $(ROM)
	@mkdir -p $(WORK)
	@head -c 8192 $(ROM) > $(MITAD)

# El trazado sigue el flujo desde los puntos de entrada. Los que no se pueden
# deducir estaticamente -la interrupcion, destinos de saltos indirectos- estan
# declarados en el .entries, cada uno con su justificacion.
$(WORK)/$(JUEGO).trace.json: $(MITAD) $(SRC)/$(JUEGO).entries $(SRC)/$(JUEGO).nocode
	python3 tools/z80trace.py $(MITAD) $(ORG) $(SRC)/$(JUEGO).entries \
	        $(WORK)/$(JUEGO) $(SRC)/$(JUEGO).nocode

trace: $(WORK)/$(JUEGO).trace.json

listado: $(WORK)/$(JUEGO).trace.json $(SRC)/$(JUEGO).notes
	python3 tools/mkasm.py $(MITAD) $(ORG) $(WORK)/$(JUEGO).trace.json \
	        $(SRC)/$(JUEGO).notes work/msx.sym $(SRC)/$(JUEGO).asm "$(TITULO)"

# La prueba que decide si el desensamblado es fiable: el listado da los 8 KB,
# y cuatro veces seguidos dan el volcado entero.
verify: $(SRC)/$(JUEGO).asm $(MITAD)
	@sh tools/verify_build.sh $(SRC)/$(JUEGO).asm $(MITAD) $(ORG)
	@cat $(WORK)/$(JUEGO).bin $(WORK)/$(JUEGO).bin $(WORK)/$(JUEGO).bin $(WORK)/$(JUEGO).bin | cmp -s - $(ROM) \
	   && echo "OK: cuatro veces seguido da el volcado de 32 KB"

# Lo que el reensamblado NO puede cazar: que unos datos se esten leyendo como
# codigo. El binario sale identico igual, porque los bytes no cambian; lo unico
# que cambia es lo que decimos de ellos.
sanity: $(WORK)/$(JUEGO).trace.json
	@echo "=================================================================="
	@echo " ningun byte declarado como datos puede salir como codigo"
	@echo "=================================================================="
	@python3 tools/check_trace.py $(WORK)/$(JUEGO).trace.json $(SRC)/$(JUEGO).nocode
	@python3 tools/check_datos_como_codigo.py $(WORK) $(SRC)
	@echo "=================================================================="
	@echo " ningun punto de entrada puede caer dentro de una zona de datos"
	@echo "=================================================================="
	@python3 tools/check_entradas.py $(SRC)/$(JUEGO).entries $(SRC)/$(JUEGO).notes \
	        $(SRC)/$(JUEGO).nocode
	@echo "=================================================================="
	@echo " ni un byte del cartucho sin asignar"
	@echo "=================================================================="
	@python3 tools/presupuesto.py $(WORK) $(SRC)

densidad:
	@python3 tools/densidad.py $(SRC)/$(JUEGO).asm

test:
	@echo "=================================================================="
	@echo " Tests"
	@echo "=================================================================="
	@python3 -m unittest discover -s tests -v

clean:
	rm -rf $(WORK)/$(JUEGO).trace.json $(WORK)/$(JUEGO).blocks

.PHONY: all comprueba trace listado verify sanity test densidad clean


# ---------------------------------------------------------------------------
# Lo jugado y la web
# ---------------------------------------------------------------------------
# Las grabaciones de openMSX (work/*.bin) se hacen con
#   powershell -File tools/lanza_graba.ps1 -guion tools/guiones/X.tcl -salida work/X.bin
# Necesitan PIL, numpy y lameenc: el python de Programs.
PYIMG ?= /c/Users/Antxiko/AppData/Local/Programs/Python/Python313/python.exe
imagenes: $(ROM)
	$(PYIMG) tools/graficos.py docs/imagenes work/atraccion.bin 400
	$(PYIMG) tools/pantallas.py docs/imagenes work/atraccion.bin 100 400
	$(PYIMG) tools/gifs.py docs/imagenes

musica: $(ROM)
	$(PYIMG) tools/musica.py todas docs/audio

# La web: en el repositorio solo van las paginas en markdown; GitHub Pages las
# convierte con Jekyll (tools/jekyll.py escribe su configuracion y plantillas).
# La portada la monta make_web.py con lo de tools/contenido_web.py.
JEKYLL ?= C:/msys64/mingw64/bin/ruby C:/msys64/mingw64/bin/jekyll
web:
	python3 tools/jekyll.py docs
	python3 tools/make_web.py docs/imagenes docs/index.html en
	python3 tools/make_web.py docs/imagenes docs/es/index.html es
	rm -rf $(WORK)/_site
	$(JEKYLL) build -s docs -d $(WORK)/_site
	python3 tools/check_enlaces.py $(WORK)/_site

.PHONY: imagenes musica web
