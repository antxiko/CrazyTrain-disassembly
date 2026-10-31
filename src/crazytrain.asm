; ==========================================================================
; CRAZY TRAIN - Konami para Sony - MSX1 (1983) - ROM de 8 KB vista en las cuatro paginas
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x00000


; ----------------------------------------------------------------------
; Direcciones que solo aparecen como VALOR -en un `ld`, no en
; un salto-: son punteros que el codigo se pasa o numeros que
; casualmente coinciden con una direccion. No hay nada que
; trazar en ellas; el equ existe para que el listado ensamble.
; ----------------------------------------------------------------------
l0303h:	equ 0x00303
l0606h:	equ 0x00606
l07ffh:	equ 0x007ff
l0fffh:	equ 0x00fff

; ----------------------------------------------------------------------
; DATOS cabecera_del_cartucho: "AB" y la direccion de INIT (0x0160), en la
;   pagina 0; STATEMENT, DEVICE y TEXT a cero
;   0x0000..0x0010  (16 bytes)
DATA_cabecera_del_cartucho:
	defb 041h,042h	; 0000
	defw 00160h,00000h,00000h,00000h,00000h,00000h,00000h	; 0002

; ======================================================================
; CODIGO 0x0010..0x0015  (5 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; RST 10h: HL = HL + A
; ----------------------------------------------------------------------
rst_suma_hl:		; RST 10h: HL + A
	add a,l			;0010   ; el byte bajo
	ld l,a			;0011
	ret nc			;0012   ; sin acarreo, ya esta
	inc h			;0013   ; con acarreo, el alto
	ret			;0014

; ----------------------------------------------------------------------
; DATOS relleno_0015: 0xFF x 3, hasta el RST siguiente
;   0x0015..0x0018  (3 bytes)
DATA_relleno_0015:
	defb 0ffh,0ffh,0ffh	; 0015

; ======================================================================
; CODIGO 0x0018..0x001f  (7 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; RST 18h: la direccion DE al VDP (con el bit 6 de D, para escribir; con el 7, un registro)
; ----------------------------------------------------------------------
rst_vdp_direccion:		; RST 18h: DE al puerto 0x99
	ld a,e			;0018   ; el byte bajo
	out (099h),a		;0019
	ld a,d			;001b   ; y el alto
	out (099h),a		;001c
	ret			;001e

; ----------------------------------------------------------------------
; DATOS relleno_001F: 0xFF
;   0x001f..0x0020  (1 bytes)
DATA_relleno_001F:
	defb 0ffh	; 001f

; ======================================================================
; CODIGO 0x0020..0x0035  (21 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; RST 20h: B bytes de HL a la VRAM, en la direccion DE
; ----------------------------------------------------------------------
rst_copia_vram:		; RST 20h: B bytes de HL a la VRAM en DE
	rst 18h			;0020   ; la direccion
copia_vram:		; B bytes de HL a la VRAM, en la direccion ya puesta
	ld a,(hl)			;0021   ; un byte
	out (098h),a		;0022
	inc hl			;0024   ; el siguiente
	djnz copia_vram		;0025
	ret			;0027

; ----------------------------------------------------------------------
; RST 28h: B bytes con el valor C en la VRAM, desde DE
; ----------------------------------------------------------------------
rst_rellena_vram:		; RST 28h: B veces C en la VRAM desde DE
	rst 18h			;0028   ; la direccion
rellena_vram:		; B veces C, en la direccion ya puesta
	ld a,c			;0029
rellena_vram_a:		; B veces A, en la direccion ya puesta
	out (098h),a		;002a   ; un byte
	nop			;002c   ; el VDP necesita su tiempo
	djnz rellena_vram_a		;002d
	ret			;002f

; ----------------------------------------------------------------------
; RST 30h: el jugador en curso, en A y en la bandera Z (Z: el 1)
; ----------------------------------------------------------------------
rst_jugador:		; RST 30h: A = el jugador en curso (0 o 1), Z si es el 1
	ld a,(0e001h)		;0030   ; 0 o 1
	or a			;0033
	ret			;0034

; ----------------------------------------------------------------------
; DATOS relleno_0035: 0xFF x 3
;   0x0035..0x0038  (3 bytes)
DATA_relleno_0035:
	defb 0ffh,0ffh,0ffh	; 0035

; ======================================================================
; CODIGO 0x0038..0x084f  (2071 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; LA INTERRUPCION DEL VDP, una vez por cuadro: las explosiones, el paso de los cuatro trenes, la pieza que se desliza, la musica y los relojes. Con 0xE200 a 1 solo la musica y los relojes.
; ----------------------------------------------------------------------
interrupcion:		; El cuadro: trenes, mando, musica y relojes
	push hl			;0038   ; se guarda lo que se toca
	push de			;0039
	push bc			;003a
	push af			;003b
	in a,(099h)		;003c   ; lee el estado del VDP, que baja la peticion
	di			;003e
	ld a,(0e200h)		;003f   ; solo musica (los carteles y las esperas)?
	or a			;0042
	jp nz,L_00D8		;0043
	ld de,0e06ah		;0046   ; los tres trenes negros: estalla alguno?
	ld a,(de)			;0049
	or a			;004a
	jr z,L_0053		;004b
	ld hl,0e206h		;004d   ; su cuenta de la explosion
	call explosion		;0050
L_0053:
	ld de,0e06bh		;0053   ; el segundo
	ld a,(de)			;0056   ; estalla?
	or a			;0057
	jr z,L_0060		;0058
	ld hl,0e20ah		;005a   ; su cuenta
	call explosion		;005d
L_0060:
	ld de,0e06ch		;0060   ; el tercero
	ld a,(de)			;0063   ; estalla?
	or a			;0064
	jr z,L_006D		;0065
	ld hl,0e20eh		;0067   ; su cuenta
	call explosion		;006a
L_006D:
	ld de,0e005h		;006d   ; y el blanco: ha chocado?
	ld a,(de)			;0070   ; estalla?
	or a			;0071
	jr z,L_007C		;0072
	ld hl,0e202h		;0074   ; su explosion, y nada mas este cuadro
	call explosion		;0077
	jr L_00D8		;007a   ; y el cuadro se acaba aqui
L_007C:
	ld hl,0e063h		;007c   ; la cuenta del tren blanco: un pixel cada tantos cuadros como diga la velocidad
	dec (hl)			;007f
	jr nz,mueve_negros		;0080   ; aun no le toca moverse
	dec hl			;0082
	ld a,(hl)			;0083   ; la velocidad...
	inc hl			;0084
	ld (hl),a			;0085   ; ...recarga la cuenta
	ld a,(0e305h)		;0086   ; en diagonal (direccion del sprite 4-7)...
	cp 004h		;0089
	jr c,mueve_tren_blanco		;008b
	ld a,(hl)			;008d   ; ...va mas despacio: un cuadro mas por pixel...
	inc (hl)			;008e
	cp 003h		;008f   ; ...y con la velocidad 3 o mas, otro
	jr c,mueve_tren_blanco		;0091
	inc (hl)			;0093
mueve_tren_blanco:		; Un paso del tren blanco: su guion (0x0843)
	ld hl,0e306h		;0094   ; la cuenta del guion del tren blanco
	call paso_de_tren		;0097
mueve_negros:		; Los tres trenes negros: los que estan en marcha, un pixel cada tres cuadros (cuatro en diagonal)
	ld hl,0e067h		;009a   ; en marcha
	ld de,0e325h		;009d   ; la direccion de su sprite (+5 de su ficha)
	ld b,003h		;00a0   ; tres trenes
L_00A2:
	push hl			;00a2
	push de			;00a3
	push bc			;00a4
	ld a,(hl)			;00a5
	or a			;00a6
	jr z,L_00BC		;00a7   ; este no esta
	dec hl			;00a9   ; su cuenta de paso (0xE064-0xE066)
	dec hl			;00aa
	dec hl			;00ab
	dec (hl)			;00ac   ; aun no le toca
	jr nz,L_00BC		;00ad
	ld (hl),003h		;00af   ; se recarga: tres cuadros...
	ld a,(de)			;00b1   ; ...en diagonal...
	cp 004h		;00b2
	jr c,L_00B7		;00b4
	inc (hl)			;00b6   ; ...cuatro
L_00B7:
	inc de			;00b7   ; la cuenta de su guion (+6)
	ex de,hl			;00b8
	call paso_de_tren		;00b9   ; un paso del guion
L_00BC:
	pop bc			;00bc
	pop hl			;00bd
	ld a,020h		;00be   ; la ficha siguiente: 32 bytes
	rst 10h			;00c0
	ex de,hl			;00c1
	pop hl			;00c2
	inc hl			;00c3   ; el tren siguiente
	djnz L_00A2		;00c4
	ld a,(0e005h)		;00c6   ; el tren blanco ha chocado?
	or a			;00c9
	call z,mando_empuja		;00ca   ; no: el mando empuja las piezas
	ld a,001h		;00cd   ; el bucle principal sabe que ha pasado un cuadro
	ld (0e251h),a		;00cf
	ld (0e250h),a		;00d2
	call parpadea_rotulo		;00d5   ; el rotulo del jugador parpadea
L_00D8:
	ld a,(0e260h)		;00d8   ; en la demostracion no suena nada
	or a			;00db
	jr nz,relojes		;00dc
	ld hl,0e3a1h		;00de   ; los tres canales de musica
	call canal_musica		;00e1
	ld l,0a9h		;00e4   ; el 2
	call canal_musica		;00e6
	ld l,0b1h		;00e9   ; el 3
	call canal_musica		;00eb
relojes:		; La cuenta de cuadros y la espera de 0xE1E0, que baja cada 32 cuadros
	ld hl,0e1e1h		;00ee   ; la cuenta de cuadros
	inc (hl)			;00f1
	ld a,(hl)			;00f2
	and 01fh		;00f3   ; cada 32 cuadros...
	jr nz,L_00FC		;00f5
	dec hl			;00f7
	cp (hl)			;00f8   ; ...la espera, si no ha llegado a cero...
	jr z,L_00FC		;00f9
	dec (hl)			;00fb   ; ...baja uno
L_00FC:
	pop af			;00fc   ; se devuelve lo que se toco
	pop bc			;00fd
	pop de			;00fe
	pop hl			;00ff
	ei			;0100   ; y se vuelve con las interrupciones abiertas
	reti		;0101

; ----------------------------------------------------------------------
; UN CANAL DE MUSICA (HL = su ficha + 1: 0xE3A1, 0xE3A9, 0xE3B1). La ficha: +0/+1 el puntero a las notas (a cero, callado), +2 lo que le queda a la nota, +3 su registro de tono en el PSG, +4 el tempo corto. Cada nota son tres bytes: tono bajo, tono alto (con la duracion en el nibble alto) y volumen; un 0x01 suelto pasa al tempo corto y 0xFF acaba.
; ----------------------------------------------------------------------
canal_musica:		; Un cuadro de un canal: la nota sigue o se pasa a la siguiente
	ld a,(hl)			;0103   ; el byte alto del puntero
	or a			;0104
	ret z			;0105   ; a cero: el canal calla
	dec hl			;0106   ; el puntero a la nota
	ld e,(hl)			;0107
	inc hl			;0108
	ld d,(hl)			;0109
	inc hl			;010a   ; lo que le queda a la nota
	ld a,(hl)			;010b
	or a			;010c
	jr nz,cuenta_nota		;010d   ; aun suena: un cuadro menos
	ld a,(de)			;010f   ; la nota siguiente
	cp 0ffh		;0110   ; 0xFF: se acabo
	jr z,calla_canal		;0112
	inc hl			;0114
	cp 001h		;0115   ; un 0x01...
	jr nz,toca_nota		;0117
	inc hl			;0119   ; ...pasa al tempo corto (+4)...
	inc de			;011a   ; ...y se salta
	ld (hl),a			;011b
	dec hl			;011c
toca_nota:		; Los tres bytes de la nota al PSG: tono bajo, tono alto y volumen
	ld a,(hl)			;011d   ; el registro de tono del canal (0, 2 o 4)
	ld c,0a1h		;011e
	ex de,hl			;0120   ; de la nota...
	out (0a0h),a		;0121   ; ...el tono bajo
	outi		;0123
	inc a			;0125   ; el registro siguiente...
	out (0a0h),a		;0126
	outi		;0128   ; ...el tono alto
	rrca			;012a   ; 1, 3 o 5 -> 0x80, 0x81, 0x82...
	add a,088h		;012b   ; ...+ 0x88: 8, 9 o 10, su volumen
	out (0a0h),a		;012d
	outi		;012f   ; el volumen
	ex de,hl			;0131
	push de			;0132   ; el puntero, ya en la nota siguiente
	dec de			;0133
	dec de			;0134
	ld a,(de)			;0135   ; el tono alto de la que suena
	and 0f0h		;0136   ; lleva la duracion arriba
	inc hl			;0138   ; el tempo
	ld c,(hl)			;0139
	dec c			;013a   ; tempo corto?...
	jr nz,L_013F		;013b
	rrca			;013d   ; ...la duracion entre 16...
	rrca			;013e
L_013F:
	rrca			;013f   ; ...y si no, entre 4
	rrca			;0140   ; ...(dos vueltas mas o menos)
	dec hl			;0141   ; lo que dura
	dec hl			;0142
	ld (hl),a			;0143   ; a +2
	pop de			;0144
	push hl			;0145   ; el puntero, guardado
	dec hl			;0146
	ld (hl),d			;0147   ; el alto
	dec hl			;0148
	ld (hl),e			;0149   ; y el bajo
	pop hl			;014a
cuenta_nota:		; Un cuadro menos de la nota
	dec (hl)			;014b
	ret			;014c
calla_canal:		; El canal se acabo: el puntero a cero y su volumen a cero
	inc a			;014d   ; A = 0
	dec hl			;014e
	ld (hl),a			;014f   ; sin puntero
	inc hl			;0150
	inc hl			;0151
	inc hl			;0152
	ld (hl),a			;0153   ; el tempo, normal
	dec hl			;0154   ; el registro de tono...
	ld a,(hl)			;0155   ; ...0, 1 o 2...
	srl a		;0156
	add a,008h		;0158   ; ...+ 8: su volumen...
	out (0a0h),a		;015a
	xor a			;015c   ; ...a cero
	out (0a1h),a		;015d
	ret			;015f

; ----------------------------------------------------------------------
; INIT: la maquina entera para el juego. La RAM a cero, la VRAM a cero, los registros del VDP, las letras y los sprites, los colores, el PSG, y el titulo con el logotipo de HIT BIT.
; ----------------------------------------------------------------------
init:		; El arranque: RAM, VRAM, VDP, letras, colores y titulo
	ld a,0f0h		;0160   ; el PPI: fila 0 del teclado, el clic callado
	out (0aah),a		;0162
	ld a,00fh		;0164   ; el registro 15 del PSG...
	out (0a0h),a		;0166
	ld a,08fh		;0168   ; ...el puerto de mando 1
	out (0a1h),a		;016a
	ld sp,0e800h		;016c   ; la pila, al final de la RAM
	ld de,081a2h		;016f   ; registro 1 del VDP = 0xA2: la pantalla apagada
	rst 18h			;0172
	ld hl,0e000h		;0173   ; la RAM 0xE000-0xE7FF...
	ld de,0e001h		;0176
	ld bc,l07ffh		;0179
	ld (hl),l			;017c   ; ...a cero (L vale 0)
	ldir		;017d
	ld a,001h		;017f   ; la interrupcion, solo musica
	ld (0e200h),a		;0181
	im 1		;0184
	ld de,04000h		;0186   ; la VRAM desde 0x0000...
	rst 18h			;0189
L_018A:
	ld b,e			;018a   ; ...256 ceros...
	ld c,e			;018b
	call rellena_vram		;018c
	dec d			;018f   ; ...64 veces: los 16 KB
	jr nz,L_018A		;0190
	ld hl,01346h		;0192   ; los ocho registros del VDP (0x1346)
	ld b,008h		;0195   ; ocho
	ld d,080h		;0197   ; el registro 0
L_0199:
	ld e,(hl)			;0199   ; su valor
	rst 18h			;019a
	inc hl			;019b
	inc d			;019c   ; el siguiente
	djnz L_0199		;019d
	ld de,06048h		;019f   ; los patrones desde la letra 9 (0x2048)
	rst 18h			;01a2
	ld hl,01967h		;01a3   ; tres dibujos, cada uno en cinco letras seguidas
	ld b,003h		;01a6
L_01A8:
	push bc			;01a8
	ld c,005h		;01a9   ; cinco
L_01AB:
	push hl			;01ab
	ld b,008h		;01ac   ; 8 bytes...
	call copia_vram		;01ae   ; ...el mismo dibujo otra vez
	pop hl			;01b1
	dec c			;01b2
	jr nz,L_01AB		;01b3
	pop bc			;01b5
	ld a,008h		;01b6   ; el dibujo siguiente
	rst 10h			;01b8
	djnz L_01A8		;01b9
	call copia_vram		;01bb   ; y de seguido, 3 x 256 + 152 bytes: las letras 0x18-0x8A
	call copia_vram		;01be
	call copia_vram		;01c1
	ld b,098h		;01c4
	call copia_vram		;01c6
	ld c,004h		;01c9   ; las 23 letras de 0x1D17, cuatro veces
L_01CB:
	ld hl,01d17h		;01cb
	ld b,0b8h		;01ce   ; 184 bytes
	call copia_vram		;01d0
	dec c			;01d3
	jr nz,L_01CB		;01d4
	ld b,0b0h		;01d6   ; y 176 mas: la fuente
	call copia_vram		;01d8
	ld de,05800h		;01db   ; los patrones de los sprites (0x1800)...
	rst 18h			;01de
	ld hl,01e7fh		;01df   ; ...los 8 sprites de 16 x 16
	ld b,080h		;01e2
	call copia_vram		;01e4
	call copia_vram		;01e7
	ld hl,0134eh		;01ea   ; los colores del titulo (0x134E)
	call pinta_colores		;01ed
	ld b,00fh		;01f0   ; el PSG: cinco parejas (0x0F1F)
	call psg_inicial		;01f2
	call colores_tres_tercios		;01f5   ; los colores, a los tres tercios
	ld de,02000h		;01f8   ; y los patrones de 0x2000...
	ld hl,06800h		;01fb   ; ...a los otros dos tercios (0x2800 y 0x3000)
	call copia_en_vram		;01fe
	ld a,002h		;0201   ; el registro de tono de los canales 2 y 3...
	ld (0e3abh),a		;0203
	add a,a			;0206   ; ...2 y 4
	ld (0e3b3h),a		;0207
	ld hl,013f2h		;020a   ; el titulo: SONY, HIT BIT, CRAZY TRAIN, (c) Konami 1983
	call pinta_textos		;020d
	ei			;0210
	ld a,009h		;0211   ; nueve tramos de 32 cuadros (casi cinco segundos)
	call espera		;0213
	call mira_disparo		;0216   ; disparo o barra?
	jp c,al_menu		;0219   ; si: a la partida con lo de la vez anterior

; ----------------------------------------------------------------------
; EL MENU: la pantalla del record y las cuatro opciones. Las teclas 1-4 empiezan la partida; sin tocar nada, a los 20 tramos de 32 cuadros (unos once segundos) empieza la demostracion.
; ----------------------------------------------------------------------
menu:		; El menu: record, opciones y espera
	call pinta_menu		;021c   ; la pantalla del menu (0x14B3)
	ld hl,0e214h		;021f   ; el record...
	ld de,07934h		;0222   ; ...en la fila 9
	call pinta_cifras		;0225   ; cuatro cifras...
	ld a,0e2h		;0228   ; ...y el cero de detras
	out (098h),a		;022a
	ld a,014h		;022c   ; la espera: 20 tramos
	ld (0e1e0h),a		;022e
menu_espera:		; Mira las teclas 1-4 hasta que se acaba la espera
	ld hl,0e260h		;0231   ; se marca la demostracion
	ld (hl),001h		;0234
	ld a,(0e1e0h)		;0236   ; se acabo la espera?
	or a			;0239
	jr z,empieza_partida		;023a   ; si: a la demostracion
	xor a			;023c   ; los canales de musica, callados
	call calla_canales		;023d
	ld (hl),a			;0240   ; no hay demostracion...
	inc hl			;0241
	ld (hl),a			;0242   ; ...ni su mando
	di			;0243
	inc a			;0244   ; el mando, de momento
	ld (0e0fch),a		;0245
	xor a			;0248
	call lee_fila		;0249   ; la fila 0 del teclado: las teclas 0-7
	ei			;024c
elige_opcion:		; Las teclas 1-4 (a cero lo pulsado): 1 y 2 con el mando, 3 y 4 con el teclado
	rrca			;024d   ; el bit 1...
	ld hl,014dfh		;024e   ; "1": un jugador con el mando
	rrca			;0251
	jr nc,un_jugador		;0252   ; pulsado
	ld hl,01500h		;0254   ; "2": dos jugadores con el mando
	rrca			;0257   ; el bit 2
	jr nc,dos_jugadores		;0258
	ex af,af'			;025a   ; ni 1 ni 2:...
	xor a			;025b   ; ...entonces el teclado
	ld (0e0fch),a		;025c
	ex af,af'			;025f
	ld hl,01521h		;0260   ; "3": un jugador con el teclado
	rrca			;0263   ; el bit 3
	jr nc,un_jugador		;0264
	ld hl,01542h		;0266   ; "4": dos jugadores con el teclado
	rrca			;0269   ; el bit 4
	jr nc,dos_jugadores		;026a
	jr menu_espera		;026c   ; nada: otra vuelta
un_jugador:		; Un jugador
	xor a			;026e
	jr opcion_elegida		;026f
dos_jugadores:		; Dos jugadores
	ld a,001h		;0271
opcion_elegida:		; Se guarda cuantos juegan y se deja en pantalla solo la opcion elegida
	ld (0e000h),a		;0273   ; cuantos
	di			;0276
	push hl			;0277   ; el texto de la opcion
	ld de,079a0h		;0278   ; las cuatro opciones (0x39A0)...
	ld c,000h		;027b   ; ...se borran: 96 ceros
	ld b,060h		;027d
	rst 28h			;027f
	call rellena_vram_a		;0280
	ei			;0283
	pop hl			;0284
	call pinta_textos		;0285   ; y se pinta la elegida
	ld hl,015a0h		;0288   ; y el rotulo de debajo
	call pinta_textos		;028b

; ----------------------------------------------------------------------
; LA PARTIDA (o la demostracion, con 0xE260 a 1): las fichas de los dos jugadores, la musica de salida y todo a cero.
; ----------------------------------------------------------------------
empieza_partida:		; Las fichas de los jugadores, la musica de salida y los marcadores a cero
	ld hl,0e000h		;028e
	ld a,(hl)			;0291   ; dos jugadores?
	inc hl			;0292   ; 0xE001
	or a			;0293
	jr z,prepara_jugador1		;0294
	ld (hl),001h		;0296   ; el jugador 2...
	push hl			;0298
	call prepara_trenes		;0299   ; ...sus trenes...
	call prepara_tablero_jugador		;029c   ; ...y su tablero
	pop hl			;029f
prepara_jugador1:		; Y lo mismo del jugador 1, que es el que empieza
	ld (hl),000h		;02a0   ; el jugador 1
	call prepara_trenes		;02a2   ; sus trenes
	call prepara_tablero_jugador		;02a5   ; y su tablero
	ld a,(0e260h)		;02a8   ; en la demostracion, sin musica
	or a			;02ab
	jr nz,a_cero		;02ac
	ld b,00fh		;02ae   ; el PSG, cinco parejas
	call psg_inicial		;02b0
	ld a,001h		;02b3   ; la interrupcion, solo musica
	ld (0e200h),a		;02b5
	di			;02b8
	ld hl,01717h		;02b9   ; la musica de salida: los tres canales (0x1717, 0x174B, 0x17AC)
	ld (0e3a0h),hl		;02bc
	ld hl,0174bh		;02bf
	ld (0e3a8h),hl		;02c2
	ld hl,017ach		;02c5
	ld (0e3b0h),hl		;02c8
	ei			;02cb
L_02CC:
	ld a,(0e3a9h)		;02cc   ; hasta que se acaba el canal 2
	or a			;02cf
	jr nz,L_02CC		;02d0
a_cero:		; Los tableros de los dos jugadores a 0, las fases y los puntos a cero, tres vidas y la cabecera
	xor a			;02d2   ; cero
	ld h,a			;02d3
	ld l,a			;02d4
	ld (0e1b0h),hl		;02d5   ; el tablero de cada jugador
	ld (0e230h),hl		;02d8   ; la fase
	ld (0e210h),hl		;02db   ; los puntos del 1
	ld (0e212h),hl		;02de   ; los del 2
	ld (0e216h),hl		;02e1   ; las vidas extra ya dadas
	ld (0e008h),hl		;02e4   ; los toques de los trenes negros
	inc a			;02e7   ; la primera fase de la partida
	ld (0e1b2h),a		;02e8
	call borra_juego		;02eb   ; la zona de juego, en blanco
	ld hl,l0303h		;02ee   ; tres vidas a cada uno
	ld (0e002h),hl		;02f1
	ld hl,l0606h		;02f4   ; y seis estaciones
	ld (0e045h),hl		;02f7
	ld hl,01563h		;02fa   ; la cabecera: 1P-00000 2P-00000 HIGH-00000
	call pinta_textos		;02fd
	ld a,(0e260h)		;0300   ; en la demostracion...
L_0303:
	or a			;0303
	jr nz,L_030C		;0304
	ld a,(0e000h)		;0306   ; ...o con un jugador...
	or a			;0309
	jr nz,fase_nueva		;030a
L_030C:
	ld de,0780ah		;030c   ; ...se borra el marcador del 2P
	ld bc,00900h		;030f
	rst 28h			;0312

; ----------------------------------------------------------------------
; UNA FASE NUEVA del jugador en curso: su tablero y sus trenes desde la reserva, la fase uno mas, el hueco en su sitio de salida y las estaciones por visitar.
; ----------------------------------------------------------------------
fase_nueva:		; Empieza una fase: tablero, trenes, fase, hueco y estaciones
	call prepara_tablero_jugador		;0313   ; el tablero (desde la fase 4, revuelto con el numero de la anterior)
	call saca_trenes		;0316   ; las fichas de los trenes, de la reserva del jugador
	ld hl,0e008h		;0319   ; sin toques
	rst 30h			;031c
	rst 10h			;031d
	xor a			;031e
	ld (hl),a			;031f
	ld hl,0e230h		;0320   ; la fase...
	rst 30h			;0323
	rst 10h			;0324
	ld a,(hl)			;0325
	add a,001h		;0326   ; ...uno mas, en BCD
	daa			;0328
	ld (hl),a			;0329
	jr nz,L_032E		;032a   ; tras la 99...
	ld (hl),002h		;032c   ; ...la 02
L_032E:
	ld hl,0e006h		;032e   ; el hueco empieza en la fila 1, columna 4
	rst 30h			;0331
	rst 10h			;0332
	ld (hl),00ch		;0333   ; 0x0C
	ld hl,0e1b0h		;0335   ; que tablero toca (0-3)
	rst 30h			;0338
	rst 10h			;0339
	ld b,(hl)			;033a
	ld hl,0e045h		;033b   ; las estaciones que hay que visitar...
	rst 30h			;033e
	rst 10h			;033f
	ex de,hl			;0340   ; a DE
	ld hl,011a7h		;0341   ; ...segun el tablero (0x11A7: 6, 8, 8 y 10)
	ld a,b			;0344
	rst 10h			;0345
	ld a,(hl)			;0346
	ld (de),a			;0347   ; a 0xE045 o 0xE046
	push af			;0348
	ld hl,0e160h		;0349   ; la lista de estaciones del jugador
	rst 30h			;034c
	jr z,L_0351		;034d
	ld l,070h		;034f
L_0351:
	push hl			;0351
	inc a			;0352   ; las 16, con un valor que no es cero...
	ld b,010h		;0353
L_0355:
	ld (hl),a			;0355   ; una
	inc hl			;0356
	djnz L_0355		;0357
	pop hl			;0359
	pop af			;035a
	ld b,a			;035b   ; ...y las N de este tablero, a cero: por visitar
	xor a			;035c
L_035D:
	ld (hl),a			;035d   ; las primeras N...
	inc hl			;035e
	djnz L_035D		;035f
	ld hl,0e067h		;0361   ; ni trenes negros en marcha ni explosiones
	ld b,006h		;0364
L_0366:
	ld (hl),a			;0366   ; seis bytes a cero
	inc hl			;0367
	djnz L_0366		;0368
	jr prepara_tablero		;036a
sigue_tras_perder:		; Tras perder una vida: el tren blanco vuelve a donde estaba (0xE1C0)
	ld hl,0e1c0h		;036c   ; donde estaba el tren...
	rst 30h			;036f
	add a,a			;0370   ; ...de este jugador
	rst 10h			;0371
	ld e,(hl)			;0372   ; Y...
	inc hl			;0373
	ld d,(hl)			;0374   ; ...y X
	ld hl,0e080h		;0375   ; a su sprite
	rst 30h			;0378
	jr z,L_037D		;0379
	ld l,090h		;037b   ; el sprite del jugador 2
L_037D:
	ld (hl),e			;037d
	inc hl			;037e
	ld (hl),d			;037f
prepara_tablero:		; La fase en marcha: los relojes, la pieza sin deslizar, la velocidad y el hueco
	call espera_negro		;0380   ; la espera del primer tren negro
	ld h,a			;0383   ; cero
	ld l,a			;0384
	ld (0e040h),hl		;0385   ; sin cruce
	ld (0e180h),hl		;0388   ; ningun tren encima de la pieza que se desliza
	ld (0e182h),hl		;038b
	ld (0e03ah),hl		;038e   ; ninguna pieza deslizandose
	dec a			;0391   ; ninguna direccion
	ld (0e03bh),a		;0392
	ld hl,0e006h		;0395   ; el hueco del jugador
	rst 30h			;0398
	rst 10h			;0399
	ld a,(hl)			;039a
	ld (0e036h),a		;039b
	ld l,062h		;039e   ; la velocidad del tren: un paso cada 4 cuadros
	ld (hl),004h		;03a0
	ld b,004h		;03a2   ; y las cuentas de paso de los cuatro, a 1
L_03A4:
	inc hl			;03a4
	ld (hl),001h		;03a5
	djnz L_03A4		;03a7
	ld hl,00a0ah		;03a9   ; la demostracion
	ld (0e1a1h),hl		;03ac
	ld a,0ffh		;03af   ; ningun tren negro esperando
	ld (0e24bh),a		;03b1
	ld hl,0e045h		;03b4   ; quedan estaciones?
	rst 30h			;03b7
	rst 10h			;03b8
	xor a			;03b9
	cp (hl)			;03ba
	jr nz,pinta_tablero		;03bb   ; si: a jugar

; ----------------------------------------------------------------------
; FASE SUPERADA: la musica de la fase, 200 puntos, los sprites fuera y el tablero siguiente (hasta el cuarto, que se repite).
; ----------------------------------------------------------------------
fase_superada:		; Todas las estaciones visitadas: musica, puntos y tablero siguiente
	ld b,00fh		;03bd   ; el PSG, cinco parejas
	call psg_inicial		;03bf
	ld hl,0e200h		;03c2   ; la interrupcion, solo musica
	ld (hl),001h		;03c5
	di			;03c7
	ld hl,017d1h		;03c8   ; la musica de la fase superada (0x17D1, 0x1802, 0x1833)
	ld (0e3a0h),hl		;03cb
	ld hl,01802h		;03ce
	ld (0e3a8h),hl		;03d1
	ld hl,01833h		;03d4
	ld (0e3b0h),hl		;03d7
	ei			;03da
L_03DB:
	ld a,(0e3a1h)		;03db   ; hasta que acaba el canal 1
	or a			;03de   ; el canal 1 calla?
	jr nz,L_03DB		;03df
	ld b,020h		;03e1   ; 200 puntos
	call suma_puntos		;03e3
	ld a,0d1h		;03e6   ; el tren blanco, fuera (Y = 0xD1)
	ld (0e080h),a		;03e8
	ld (0e090h),a		;03eb   ; y el del jugador 2
	call fuera_negros		;03ee   ; y los negros
	ld hl,0e1b0h		;03f1   ; el tablero siguiente...
	rst 30h			;03f4
	rst 10h			;03f5
	ld a,003h		;03f6
	cp (hl)			;03f8   ; ...hasta el cuarto
	jr z,L_03FC		;03f9
	inc (hl)			;03fb
L_03FC:
	call prepara_trenes		;03fc   ; las fichas de reserva, de nuevo
	jp fase_nueva		;03ff   ; y otra fase

; ----------------------------------------------------------------------
; EL TABLERO EN PANTALLA: los colores del juego y las 48 casillas, de 4 x 4 letras cada una, desde 0x3820.
; ----------------------------------------------------------------------
pinta_tablero:		; El tablero entero y el marcador; la musica del tren y a jugar
	call borra_juego		;0402   ; la zona de juego, en blanco
	ld hl,0134eh		;0405   ; los colores del juego (0x134E)
	call pinta_colores		;0408
	call colores_tres_tercios		;040b   ; a los tres tercios
	ld hl,07820h		;040e   ; la primera casilla, en la fila 1
	push hl			;0411
	ld hl,0e100h		;0412   ; el tablero del jugador
	rst 30h			;0415
	jr z,L_041A		;0416
	ld l,030h		;0418
L_041A:
	ex de,hl			;041a   ; las casillas, en DE
	exx			;041b
	ld b,030h		;041c   ; 48 casillas
	exx			;041e
pinta_casilla:		; Una casilla: su pieza (0x0A7D) en el sitio de la pila
	ld a,(de)			;041f   ; la pieza
	inc de			;0420
	ld (0e011h),de		;0421   ; la siguiente, guardada
	call pinta_pieza		;0425   ; cuatro por cuatro letras
	exx			;0428   ; la ultima?
	dec b			;0429
	exx			;042a
	jr z,marcadores		;042b
	ld hl,00004h		;042d   ; cuatro letras a la derecha...
	ld a,e			;0430   ; ...salvo en la ultima columna (0x1C)...
	and 01fh		;0431
	cp 01ch		;0433
	jr nz,L_0439		;0435
	ld l,064h		;0437   ; ...que baja tres filas y vuelve al principio
L_0439:
	add hl,de			;0439
	push hl			;043a   ; el sitio de la siguiente, para 0x0A7D
	ld de,(0e011h)		;043b
	jr pinta_casilla		;043f
marcadores:		; La fase y las vidas (fuera de la demostracion)
	ld a,(0e260h)		;0441
	or a			;0444
	jr nz,en_marcha		;0445
	call pinta_fase		;0447   ; STAGE
	call pinta_vidas		;044a   ; las vidas
en_marcha:		; El tren blanco arranca: su guion, el PSG, el sonido del tren, el mando del jugador y una espera
	ld hl,0e306h		;044d   ; el primer paso del guion del tren blanco
	call paso_de_tren		;0450
	ld b,012h		;0453   ; el PSG: seis parejas, con el ruido
	call psg_inicial		;0455
	ld hl,01849h		;0458   ; el canal 1: el traqueteo (0x1849)
	ld (0e3a0h),hl		;045b
	di			;045e
	rst 30h			;045f   ; el jugador...
	ld a,00fh		;0460   ; ...el registro 15...
	out (0a0h),a		;0462
	ld a,08fh		;0464   ; ...mando 1 para el jugador 1...
	jr z,L_046A		;0466
	ld a,0cfh		;0468   ; ...mando 2 para el 2
L_046A:
	out (0a1h),a		;046a
	ei			;046c
	ei			;046d
	ld a,002h		;046e   ; dos tramos de 32 cuadros
	call espera		;0470
	ld (0e200h),a		;0473   ; a cero: la interrupcion mueve los trenes
	ld (0e270h),a		;0476   ; el tablero aun no ha cambiado de color
	ld a,03ch		;0479   ; la espera: 60 tramos de 32 cuadros (32 segundos)
	ld (0e1e0h),a		;047b

; ----------------------------------------------------------------------
; EL BUCLE DE LA PARTIDA: el color del tablero, el traqueteo, los choques, los puntos, el boton que acelera, la cuenta del tren negro que va a salir y el final de la fase.
; ----------------------------------------------------------------------
bucle_partida:		; Una vuelta del bucle de la partida
	ld a,(0e1e0h)		;047e   ; se acabo la espera de 32 segundos?
	or a			;0481
	jr nz,traqueteo		;0482
	ld hl,0e270h		;0484   ; y aun no ha cambiado?
	cp (hl)			;0487
	jr nz,traqueteo		;0488
	ld a,001h		;048a   ; ya cambia: una vez
	ld (hl),a			;048c
	ld hl,01390h		;048d   ; los colores de 0x1390: el tablero pierde los colores de las piezas
	call pinta_colores		;0490
	call colores_tres_tercios		;0493   ; a los tres tercios
traqueteo:		; El canal 3 vuelve a sonar cuando se acaba: mas deprisa con la velocidad 2
	ld a,(0e3b1h)		;0496   ; el canal 3 calla?
	or a			;0499
	jr nz,choque_blanco		;049a
	ld a,(0e062h)		;049c   ; la velocidad
	cp 002h		;049f   ; a tope (2)...
	ld hl,018a6h		;04a1   ; ...el traqueteo rapido (0x18A6)
	jr z,L_04A9		;04a4
	ld hl,01899h		;04a6   ; si no, el normal (0x1899)
L_04A9:
	ld (0e3b0h),hl		;04a9
choque_blanco:		; El tren blanco (sprite 0) contra los tres negros
	ld de,0e084h		;04ac   ; los negros
	ld hl,0e080h		;04af   ; el blanco
	rst 30h			;04b2
	jr z,L_04B9		;04b3
	ld e,094h		;04b5
	ld l,090h		;04b7
L_04B9:
	push de			;04b9   ; tres
	ld b,003h		;04ba
	call se_tocan		;04bc   ; se tocan?
	jr nc,choque_negros		;04bf
	ld a,e			;04c1   ; cual: (la X de su sprite - 5) / 4
	sub 005h		;04c2
	rrca			;04c4
	rrca			;04c5
	and 003h		;04c6
	ld b,a			;04c8
	ld hl,0e067h		;04c9   ; esta en marcha?
	rst 10h			;04cc
	ld a,(hl)			;04cd
	or a			;04ce
	jr z,choque_negros		;04cf   ; no: nada
	push bc			;04d1
	ld l,008h		;04d2   ; el tren blanco saldra otra vez desde su casilla
	rst 30h			;04d4
	rst 10h			;04d5
	ld (hl),001h		;04d6
	ld hl,(0e301h)		;04d8   ; la pieza y la casilla del tren blanco
	call visita_estacion		;04db   ; si esta en una estacion, cuenta
	jr nc,L_04F2		;04de   ; no lo estaba
	ld hl,0e041h		;04e0   ; las casillas de estacion ya pisadas...
	ld a,(hl)			;04e3
	ld (hl),000h		;04e4   ; ...a cero
	dec hl			;04e6
	ld (hl),001h		;04e7   ; ha chocado en una estacion
	cp 002h		;04e9   ; llevaba las dos: esa estacion ya se habia contado...
	jr nz,L_04F2		;04eb
	ld l,045h		;04ed
	rst 30h			;04ef
	rst 10h			;04f0
	inc (hl)			;04f1   ; ...y se devuelve la que resta 0x090C
L_04F2:
	pop bc			;04f2   ; el tren negro
	call estalla_negro		;04f3   ; el negro estalla
	ld hl,0e306h		;04f6   ; y el blanco choca
	ld de,0e180h		;04f9   ; sin nada encima de la pieza que se desliza
	call choque		;04fc
	pop de			;04ff
	jr puntos		;0500   ; al resto de la vuelta
choque_negros:		; Los trenes negros entre si: el 1 contra el 2, y el 3 contra los dos
	pop de			;0502
	push de			;0503
	ld hl,(0e067h)		;0504   ; el 1 y el 2...
	ld a,l			;0507   ; ...hay alguno?
	add a,h			;0508
	or a			;0509
	jr z,choque_tercero		;050a
	ld a,e			;050c   ; el sprite 2
	add a,004h		;050d
	ld l,a			;050f
	ld h,d			;0510
	ld b,001h		;0511   ; contra el 1
	call se_tocan		;0513
	jr nc,choque_tercero		;0516
	ld hl,018b3h		;0518   ; se tocan: el ruido del choque en los canales 2 y 3
	ld (0e3a8h),hl		;051b
	ld (0e3b0h),hl		;051e
	ld hl,(0e321h)		;0521   ; si el 1 estaba en una estacion, cuenta...
	call visita_estacion		;0524
	jr c,L_052F		;0527
	ld hl,(0e341h)		;0529   ; ...y si no, la del 2
	call visita_estacion		;052c
L_052F:
	ld b,001h		;052f   ; y los dos estallan
	call estalla_negro		;0531
	call estalla_negro		;0534
choque_tercero:		; El tercer tren negro contra los otros dos
	pop de			;0537
	ld a,(0e069h)		;0538   ; en marcha...
	or a			;053b
	jr z,puntos		;053c
	ld a,(0e06ch)		;053e   ; ...y sin estallar?
	or a			;0541
	jr nz,puntos		;0542
	ld h,d			;0544   ; el sprite 3
	ld a,e			;0545
	add a,008h		;0546
	ld l,a			;0548
	ld b,002h		;0549   ; contra el 1 y el 2
	call se_tocan		;054b
	jr nc,puntos		;054e
	push bc			;0550
	ld hl,018b3h		;0551   ; el ruido del choque
	ld (0e3a8h),hl		;0554
	ld (0e3b0h),hl		;0557
	ld hl,(0e361h)		;055a   ; si estaba en una estacion, cuenta
	call visita_estacion		;055d
	pop bc			;0560
	res 1,b		;0561   ; 2 -> el 1, 1 -> el 2: con cual ha chocado
	call estalla_negro		;0563   ; ese estalla...
	ld b,002h		;0566   ; ...y el tercero tambien
	call estalla_negro		;0568
puntos:		; Los puntos del jugador y el record
	call pinta_puntos		;056b   ; los del jugador
	ld de,(0e210h)		;056e   ; el 1 contra el record
	call mira_record		;0572
	ld de,(0e212h)		;0575   ; el 2 contra el record
	call mira_record		;0579
	ld a,(0e005h)		;057c   ; el tren blanco ha chocado?...
	or a			;057f
	scf			;0580   ; ...con acarreo...
	jp nz,fin_de_fase		;0581   ; ...al final de la vuelta
	ld hl,0e045h		;0584   ; quedan estaciones?
	rst 30h			;0587
	rst 10h			;0588
	ld a,(hl)			;0589
	or a			;058a
	jp z,fin_de_fase		;058b   ; no: fase superada (sin acarreo)
	ld a,(0e260h)		;058e   ; en la demostracion no hay boton
	or a			;0591
	jr nz,cuenta_tren_negro		;0592
boton_acelera:		; El boton (o la barra), una vez por cuadro: apretado 32 cuadros, el tren acelera; suelto 32 cuadros, frena
	ld hl,0e251h		;0594   ; ha pasado un cuadro?
	ld a,(hl)			;0597
	or a			;0598
	jr z,cuenta_tren_negro		;0599
	ld (hl),000h		;059b   ; se gasta
	call lee_mando		;059d   ; el mando
	ld c,a			;05a0
	ld b,030h		;05a1   ; los dos botones
	ld a,(0e0fch)		;05a3   ; con el mando, ya esta
	or a			;05a6
	jr nz,mira_boton		;05a7
	di			;05a9
	ld a,007h		;05aa   ; el teclado: la fila 7 (SELECT, bit 6)...
	call lee_fila		;05ac
	and 040h		;05af
	ld h,a			;05b1
	ld a,008h		;05b2   ; ...y la fila 8 (la barra, bit 0)
	call lee_fila		;05b4
	ei			;05b7
	and 001h		;05b8
	or h			;05ba
	ld c,a			;05bb
	ld b,041h		;05bc   ; los dos bits
mira_boton:		; A 1 lo suelto: apretado o no
	ld a,c			;05be
	ld hl,0e060h		;05bf   ; las cuentas
	and b			;05c2
	cp b			;05c3
	jr z,boton_suelto		;05c4   ; suelto
	ld (hl),000h		;05c6   ; apretado: la cuenta de suelto a cero...
	inc hl			;05c8
	inc (hl)			;05c9   ; ...y la de apretado, uno mas
	ld a,(hl)			;05ca
	cp 020h		;05cb   ; 32 cuadros?
	jr nz,cuenta_tren_negro		;05cd
	ld (hl),000h		;05cf   ; otra vez desde cero
	inc hl			;05d1
	ld a,(hl)			;05d2   ; la velocidad (cuadros por paso)...
	cp 003h		;05d3   ; ...si es 3 o mas...
	jr c,cuenta_tren_negro		;05d5
	dec (hl)			;05d7   ; ...uno menos: mas deprisa
	jr cuenta_tren_negro		;05d8
boton_suelto:		; Suelto: la cuenta de suelto, y a los 32 cuadros el tren frena
	inc (hl)			;05da   ; uno mas
	ld a,(hl)			;05db
	inc hl			;05dc
	ld (hl),000h		;05dd   ; la de apretado, a cero
	cp 020h		;05df   ; 32 cuadros?
	jr nz,cuenta_tren_negro		;05e1
	dec hl			;05e3
	ld (hl),000h		;05e4   ; otra vez desde cero
	inc hl			;05e6
	inc hl			;05e7
	ld a,(hl)			;05e8   ; la velocidad...
	cp 004h		;05e9   ; ...si es menos de 4...
	jr nc,cuenta_tren_negro		;05eb
	inc (hl)			;05ed   ; ...uno mas: mas despacio
cuenta_tren_negro:		; La cuenta junto a la estacion de la que va a salir un tren negro: baja uno cada 48 cuadros, y a cero sale
	xor a			;05ee   ; ha pasado un cuadro?
	ld hl,0e250h		;05ef
	cp (hl)			;05f2
	jr z,mira_vueltas		;05f3
	ld (hl),a			;05f5   ; se gasta
	ld l,041h		;05f6   ; hay un tren negro anunciado (0xE241)?
	cp (hl)			;05f8
	jr z,mira_vueltas		;05f9
	inc hl			;05fb
	dec (hl)			;05fc   ; el divisor de 48 cuadros
	jr nz,mira_vueltas		;05fd
	ld (hl),030h		;05ff   ; se recarga
	inc hl			;0601
	ld a,(hl)			;0602   ; la cuenta (BCD)...
	sub 001h		;0603   ; ...uno menos
	daa			;0605
L_0606:
	ld (hl),a			;0606
	push af			;0607
	ld b,001h		;0608   ; a dos cifras
	call bcd_a_letras		;060a
	ld bc,0e224h		;060d   ; las cifras
	ld a,0e2h		;0610   ; la ultima es siempre un "0"
	ld hl,0e249h		;0612   ; las tres direcciones de la VRAM, de la ultima a la primera
L_0615:
	ld d,(hl)			;0615   ; la direccion...
	dec hl			;0616
	ld e,(hl)			;0617
	dec hl			;0618
	push bc			;0619
	ld c,a			;061a   ; una letra
	ld b,001h		;061b
	di			;061d
	rst 28h			;061e
	ei			;061f
	pop bc			;0620
	ld a,l			;0621   ; la siguiente
	dec bc			;0622
	cp 043h		;0623   ; hasta 0xE244
	ld a,(bc)			;0625   ; la cifra siguiente
	jr nz,L_0615		;0626
	pop af			;0628   ; a cero...
	call z,cuenta_a_cero		;0629   ; ...sale el tren negro
mira_vueltas:		; El tren blanco ha entrado en otra casilla: se sigue su camino por adelantado; si vuelve al mismo sitio, va dando vueltas y no se le dan los 10 puntos por casilla
	xor a			;062c   ; hay que mirarlo?
	ld hl,0e1a0h		;062d
	cp (hl)			;0630
	jr z,estacion_cerrada		;0631
	ld (hl),a			;0633   ; una vez
	ld hl,(0e302h)		;0634   ; la casilla y la direccion del tren blanco...
	ld (0e1a8h),hl		;0637   ; ...el punto de partida...
	ld (0e1a5h),hl		;063a   ; ...y el que avanza
	ld de,0e1a9h		;063d
sigue_camino:		; Una casilla mas del camino
	call casilla_de_al_lado		;0640   ; a la casilla de al lado
	call entra_en_casilla		;0643   ; la pieza: por donde sale
	cp 00ch		;0646   ; sin via (o el hueco)...
	ld a,000h		;0648   ; ...el camino se acaba: no da vueltas
	jr nc,marca_vueltas		;064a
	ld b,(hl)			;064c   ; la casilla y la direccion a las que se llega
	dec hl			;064d
	ld c,(hl)			;064e
	inc hl			;064f
	ex de,hl			;0650   ; contra las de partida
	ld hl,0e1a5h		;0651
	ld a,c			;0654
	cp (hl)			;0655
	jr nz,sigue_camino		;0656
	inc hl			;0658
	ld a,b			;0659
	cp (hl)			;065a
	jr nz,sigue_camino		;065b   ; iguales: vuelve al mismo sitio
	ld a,001h		;065d
marca_vueltas:		; 0xE1AA: el tren da vueltas (1) o no (0)
	ld hl,0e1aah		;065f
	ld (hl),a			;0662
estacion_cerrada:		; Se ha cerrado una estacion: el tren negro que estuviera en ella estalla
	ld hl,0e05ah		;0663   ; el tablero ha cambiado?
	xor a			;0666
	cp (hl)			;0667
	jr z,fin_vuelta		;0668
	ld (hl),a			;066a   ; una vez
	ld l,067h		;066b   ; el tren negro 1...
	cp (hl)			;066d
	jr z,L_0677		;066e
	ld b,a			;0670   ; ...su casilla
	ld a,(0e322h)		;0671
	call negro_en_cerrada		;0674   ; en la estacion cerrada?
L_0677:
	ld hl,0e068h		;0677   ; el 2
	xor a			;067a
	cp (hl)			;067b
	jr z,L_0686		;067c
	ld b,001h		;067e   ; el 2
	ld a,(0e342h)		;0680   ; su casilla
	call negro_en_cerrada		;0683   ; en la estacion cerrada?
L_0686:
	ld hl,0e069h		;0686   ; el 3
	xor a			;0689
	cp (hl)			;068a
	jr z,fin_vuelta		;068b
	ld b,002h		;068d   ; el 3
	ld a,(0e362h)		;068f   ; su casilla
	call negro_en_cerrada		;0692   ; en la estacion cerrada?
fin_vuelta:		; En la partida, otra vuelta; en la demostracion, el disparo la corta
	ld a,(0e260h)		;0695   ; la demostracion?
	or a			;0698
	jp z,bucle_partida		;0699   ; no: otra vuelta
	call mira_disparo		;069c   ; disparo o barra?
	jp nc,bucle_partida		;069f   ; no: sigue la demostracion
	push af			;06a2
	xor a			;06a3   ; los canales, callados...
	call calla_canales		;06a4
	ld (0e260h),a		;06a7   ; ...y fuera la demostracion
	ld a,001h		;06aa   ; la interrupcion, solo musica
	ld (0e200h),a		;06ac
	ld a,0d1h		;06af   ; el tren blanco, fuera
	ld (0e080h),a		;06b1
	call fuera_negros		;06b4   ; y los negros
	call sube_sprites		;06b7
	pop af			;06ba
al_menu:		; El menu otra vez, y la opcion que se trae en A
	push af			;06bb
	call pinta_menu		;06bc   ; la pantalla del menu
	pop af			;06bf
	jp elige_opcion		;06c0   ; la opcion

; ----------------------------------------------------------------------
; EL FINAL DE LA FASE: con acarreo el tren blanco ha chocado, sin el se han visitado todas las estaciones.
; ----------------------------------------------------------------------
fin_de_fase:		; Choque o fase superada
	push af			;06c3
	ld a,001h		;06c4   ; el rotulo del jugador, encendido
	ld hl,0e0feh		;06c6
	call pon_rotulo		;06c9
	pop af			;06cc
	jp nc,fase_superada		;06cd   ; sin acarreo: fase superada
	ld hl,018b3h		;06d0   ; el ruido del choque en los canales 2 y 3
	ld (0e3a8h),hl		;06d3
	ld (0e3b0h),hl		;06d6
espera_explosion:		; Hasta que acaba la explosion del tren blanco
	ld a,(0e005h)		;06d9
	or a			;06dc
	jr nz,espera_explosion		;06dd
	inc a			;06df   ; la interrupcion, solo musica
	ld (0e200h),a		;06e0
	call fuera_negros		;06e3   ; los trenes negros, fuera
	ld a,(0e260h)		;06e6   ; la demostracion acaba aqui...
	or a			;06e9
	jp nz,menu		;06ea   ; ...en el menu
	ld hl,0e002h		;06ed   ; una vida menos
	rst 30h			;06f0
	rst 10h			;06f1
	dec (hl)			;06f2
	jr z,game_over		;06f3   ; sin vidas: se acabo
	ld l,040h		;06f5   ; habia chocado justo al cerrar una estacion?...
	ld a,(hl)			;06f7
	dec a			;06f8
	jr nz,cambia_jugador		;06f9   ; ...no
	ld (hl),a			;06fb   ; se borra
	ld l,045h		;06fc   ; si quedan estaciones...
	rst 30h			;06fe
	rst 10h			;06ff
	xor a			;0700
	cp (hl)			;0701
	jr z,cambia_jugador		;0702
	call estacion_al_azar		;0704   ; ...el tren sale de una de ellas, al azar
	ld (0e302h),bc		;0707
cambia_jugador:		; Con dos jugadores, el turno pasa al otro si le quedan vidas
	xor a			;070b   ; dos jugadores?
	ld hl,0e000h		;070c
	cp (hl)			;070f
	jr z,sigue_el_mismo		;0710
	call otro_jugador		;0712   ; el otro, si tiene vidas
	ld a,b			;0715   ; el de antes
	jr c,turno_del_otro		;0716   ; al otro
	ld (0e001h),a		;0718   ; sin vidas: sigue el mismo
sigue_el_mismo:		; A la fase del jugador en curso, donde la dejo
	jp sigue_tras_perder		;071b
turno_del_otro:		; Se guardan los trenes del que deja de jugar
	call guarda_trenes		;071e
entra_el_otro:		; Los trenes del que entra, la pantalla en blanco y PLAYER 1 / PLAYER 2
	call saca_trenes		;0721   ; sus trenes
	ld b,000h		;0724   ; una espera
	call espera_b		;0726
	call borra_juego		;0729   ; la zona de juego, en blanco
	ld hl,015a0h		;072c   ; PLAYER 1...
	rst 30h			;072f
	jr z,L_0735		;0730
	ld hl,015b2h		;0732   ; ...o PLAYER 2
L_0735:
	call pinta_textos		;0735
	ld a,004h		;0738   ; cuatro tramos de 32 cuadros
	call espera		;073a
	rst 30h			;073d   ; el jugador 1...
	or a			;073e
	jr z,sigue_el_mismo		;073f   ; ...sigue donde estaba
	ld hl,0e1b2h		;0741   ; el 2, la primera vez...
	xor a			;0744
	cp (hl)			;0745
	ld (hl),a			;0746
	jp nz,fase_nueva		;0747   ; ...empieza su primera fase
	jr sigue_el_mismo		;074a

; ----------------------------------------------------------------------
; SE ACABO para este jugador: GAME OVER y su musica; con dos jugadores, el otro sigue si le quedan vidas.
; ----------------------------------------------------------------------
game_over:		; GAME OVER: el rotulo, la musica, y el otro jugador o el menu
	ld hl,01583h		;074c   ; GAME OVER
	call pinta_textos		;074f
	ld b,00fh		;0752   ; el PSG, cinco parejas
	call psg_inicial		;0754
	di			;0757
	ld hl,018c6h		;0758   ; la musica del final (0x18C6, 0x18FD, 0x1925)
	ld (0e3a0h),hl		;075b
	ld hl,018fdh		;075e   ; el canal 2
	ld (0e3a8h),hl		;0761
	ld hl,01925h		;0764   ; el canal 3
	ld (0e3b0h),hl		;0767
	ei			;076a
espera_game_over:		; Hasta que acaba el canal 1
	ld a,(0e3a1h)		;076b   ; el canal 1 calla?
	or a			;076e
	jr nz,espera_game_over		;076f
	xor a			;0771   ; dos jugadores?
	ld hl,0e000h		;0772
	cp (hl)			;0775   ; un jugador: se acabo
	jr z,fin_de_partida		;0776
	call otro_jugador		;0778   ; el otro tiene vidas: le toca
	jp c,entra_el_otro		;077b   ; le quedan vidas: le toca
fin_de_partida:		; Ocho tramos de 32 cuadros: el disparo vuelve a empezar; si no, el menu
	ld a,008h		;077e
	ld (0e1e0h),a		;0780
espera_fin:		; Mira el disparo hasta que se acaba la espera
	ld a,(0e1e0h)		;0783   ; se acabo la espera?
	or a			;0786
	jp z,menu		;0787   ; si: el menu
	call mira_disparo		;078a   ; disparo o barra?
	jp c,al_menu		;078d   ; si: otra partida
	jr espera_fin		;0790

; ----------------------------------------------------------------------
; TEXTOS: bloques de "direccion de la VRAM (alto, bajo), letras, 0xFF"; dentro, 0xFE N L repite N veces la letra L; un 0xFF tras el 0xFF del bloque acaba la lista.
; ----------------------------------------------------------------------
pinta_textos:		; Una lista de bloques de texto a la VRAM
	ld d,(hl)			;0792   ; la direccion
	inc hl			;0793
	ld e,(hl)			;0794
	di			;0795
	rst 18h			;0796   ; al VDP
texto_letra:		; Letra a letra
	inc hl			;0797
	ld a,(hl)			;0798   ; 0xFE: una tira
	cp 0feh		;0799
	jr nz,texto_fin		;079b
	inc hl			;079d
	ld b,(hl)			;079e   ; cuantas
	inc hl			;079f
	ld a,(hl)			;07a0   ; de que letra
	call rellena_vram_a		;07a1
	inc hl			;07a4   ; lo que sigue
	ld a,(hl)			;07a5
texto_fin:		; 0xFF: se acaba el bloque
	cp 0ffh		;07a6
	jr z,texto_bloque		;07a8
	out (098h),a		;07aa   ; una letra
	jr texto_letra		;07ac
texto_bloque:		; Otro bloque, o el final de la lista (otro 0xFF)
	ei			;07ae   ; las interrupciones, otra vez
	inc hl			;07af   ; el byte de detras
	ld a,(hl)			;07b0
	cp 0ffh		;07b1   ; 0xFF otra vez: se acabo
	jr nz,pinta_textos		;07b3
	inc hl			;07b5   ; HL detras de la lista
	ret			;07b6
parpadea_rotulo:		; El rotulo 1P- o 2P- del jugador que juega se enciende y se apaga cada 24 cuadros
	ld a,(0e260h)		;07b7   ; en la demostracion, no
	or a			;07ba
	ret nz			;07bb
	ld hl,0e0feh		;07bc   ; la cuenta
	dec (hl)			;07bf
	ret nz			;07c0
	ld (hl),018h		;07c1   ; se recarga
	inc hl			;07c3   ; encendido o apagado
	ld a,(hl)			;07c4
pon_rotulo:		; Con A a 0 se apaga (tres ceros de 0xE0E0) y con A a 1 se enciende (0x1565, 1P- o 2P-)
	ld de,01565h		;07c5   ; el rotulo
	or a			;07c8   ; estaba apagado?
	jr nz,rotulo_a_vram		;07c9
	inc (hl)			;07cb   ; lo estara...
	inc (hl)			;07cc
	ld de,0e0e0h		;07cd   ; ...pintando ceros
rotulo_a_vram:		; Las tres letras en la fila 0: columna 2 (1P) u 11 (2P)
	dec (hl)			;07d0   ; la vez siguiente, lo contrario
	ex de,hl			;07d1
	ld de,07802h		;07d2   ; el del jugador 1
	rst 30h			;07d5
	jr z,L_07DD		;07d6
	ld a,009h		;07d8   ; el del 2: nueve letras mas alla...
	rst 10h			;07da
	ld e,00bh		;07db   ; ...en la columna 11
L_07DD:
	ld b,003h		;07dd   ; tres letras
	di			;07df
	rst 20h			;07e0
	ei			;07e1
	ret			;07e2
explosion:		; Un cuadro de la explosion de un tren (HL = su cuenta, DE = su bandera): el dibujo cambia cada 4 cuadros, y a los 20 cambios el tren desaparece
	dec (hl)			;07e3   ; un cuadro menos
	ret p			;07e4   ; aun no toca cambiar
	ld (hl),003h		;07e5   ; cada 4 cuadros
	push hl			;07e7
	ld h,0e0h		;07e8   ; el sprite de su tren...
	rst 30h			;07ea
	ld a,080h		;07eb   ; ...en la tabla del jugador
	jr z,L_07F1		;07ed
	ld a,090h		;07ef
L_07F1:
	rst 10h			;07f1   ; su patron
	ld a,(hl)			;07f2   ; el siguiente...
	add a,004h		;07f3
	and 00fh		;07f5   ; ...de los cuatro de la explosion
	ld (hl),a			;07f7
	ld a,l			;07f8   ; es el tren blanco?
	res 4,a		;07f9
	cp 082h		;07fb
	jr z,explosion_vram		;07fd
L_07FF:
	ld a,020h		;07ff   ; los negros estallan con los patrones de 0x20
	or (hl)			;0801
	ld (hl),a			;0802
explosion_vram:		; Los sprites a la VRAM y cuantos cambios lleva
	push de			;0803   ; a la VRAM
	call sube_sprites		;0804
	pop de			;0807
	ld b,h			;0808   ; el sprite, a mano
	ld c,l			;0809
	pop hl			;080a
	dec hl			;080b   ; los cambios
	inc (hl)			;080c   ; uno mas
	ld a,(hl)			;080d
	sub 014h		;080e   ; 20?
	ret nz			;0810   ; aun no
	ld (hl),a			;0811   ; se acabo: a cero...
	inc hl			;0812
	ld (hl),a			;0813
	ld (de),a			;0814   ; ...y la bandera del tren, tambien
	ld h,b			;0815   ; el sprite
	ld l,c			;0816
	dec hl			;0817   ; su Y
	dec hl			;0818
	ld b,(hl)			;0819
	ld (hl),0d1h		;081a   ; fuera de la pantalla
	ld a,l			;081c   ; el tren blanco?...
	and 00fh		;081d
	jr nz,explosion_negro		;081f
	inc hl			;0821   ; ...se guarda donde estaba, para la vida siguiente (0xE1C0)
	ld c,(hl)			;0822
	ld hl,0e1c0h		;0823
	rst 30h			;0826
	add a,a			;0827
	rst 10h			;0828
	ld (hl),b			;0829
	inc hl			;082a
	ld (hl),c			;082b
explosion_sube:		; Los sprites a la VRAM
	jp sube_sprites		;082c
explosion_negro:		; Un tren negro: deja de estar en marcha y su casilla a cero
	dec de			;082f   ; su bandera de "en marcha" (0xE067-0xE069)...
	dec de			;0830   ; de la explosion (0xE06A) a "en marcha" (0xE067)
	dec de			;0831
	xor a			;0832
	ld (de),a			;0833   ; ...a cero
	ld a,l			;0834   ; su ficha: 0xE322, 0xE342 o 0xE362
	and 00ch		;0835   ; la ficha, por la direccion del sprite...
	rlca			;0837
	rlca			;0838
	rlca			;0839
	or 002h		;083a   ; ...+2: la casilla
	ld l,a			;083c
	ld h,0e3h		;083d
	xor a			;083f
	ld (hl),a			;0840   ; sin casilla
	jr explosion_sube		;0841   ; y a la VRAM

; ----------------------------------------------------------------------
; UN PASO DEL GUION DE UN TREN (HL = la cuenta de su ficha, +6). El guion son bytes "veces x 16 + direccion" (0x0850): mientras la cuenta no llega a cero el sprite avanza un pixel en su direccion; a cero, el codigo de la ficha lee el byte siguiente. Las direcciones del sprite: 0 arriba, 1 abajo, 2 derecha, 3 izquierda, 4-7 las diagonales.
; ----------------------------------------------------------------------
paso_de_tren:		; La cuenta baja: un pixel mas, o el byte siguiente del guion
	dec (hl)			;0843   ; un paso menos
	jr nz,$+115		;0844   ; quedan: un pixel en la misma direccion (0x08B7)
	inc hl			;0846   ; el puntero al guion...
	ld e,(hl)			;0847
L_0848:
	inc hl			;0848
	ld d,(hl)			;0849
	push de			;084a   ; ...a IX
	pop ix		;084b
	inc hl			;084d   ; al codigo de la ficha (+9): lee el byte (IX + n), suma uno a n y salta a 0x0850
salta_hl:		; jp (hl): al codigo de la ficha o al trocito de 0x0AE0
	jp (hl)			;084e

; ----------------------------------------------------------------------
; DATOS ret_suelto_084F: 0xC9 (ret) suelto detras del jp (hl): nadie salta
;   aqui (tools/sonda_ret.tcl: 0 veces en 20.000 cuadros de partida)
;   0x084f..0x0850  (1 bytes)
DATA_ret_suelto_084F:
	defb 0c9h	; 084f

; ======================================================================
; CODIGO 0x0850..0x115f  (2319 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; EL BYTE DEL GUION (A), que trae el codigo de la ficha: 0xFF acaba la casilla (0x0E61), 0x10 es un callejon sin salida (el tren choca) y lo demas, "veces x 16 + direccion".
; ----------------------------------------------------------------------
byte_de_guion:		; Lo que dice el byte del guion
	cp 0ffh		;0850   ; 0xFF: fin de la casilla
	jr nz,callejon		;0852
	push hl			;0854   ; la ficha...
	dec hl			;0855   ; ...su numero (+4)...
	dec hl			;0856
	ld a,(hl)			;0857
	ld b,a			;0858
	ld hl,0e180h		;0859   ; ...esta encima de la pieza que se desliza?
	rst 10h			;085c
	ld a,(hl)			;085d
	ex de,hl			;085e
	pop hl			;085f
	or a			;0860   ; no: a la casilla siguiente
	jp z,casilla_siguiente		;0861
	ld a,b			;0864   ; si: choca. El blanco?...
	or a			;0865
	jr nz,choca		;0866
	push hl			;0868   ; ...saldra otra vez desde su casilla
	ld hl,0e008h		;0869
	rst 30h			;086c
	rst 10h			;086d
	ld (hl),001h		;086e
	pop hl			;0870
choca:		; El tren choca (0x0EFB)
	jp choque		;0871
callejon:		; 0x10: el tren no tiene por donde seguir
	cp 010h		;0874
	jr nz,tramo		;0876
	ld a,l			;0878   ; el blanco (la cuenta en 0xE306)...
	sub 006h		;0879
	ld de,0e180h		;087b
	jr z,choca		;087e   ; ...choca
	jp casilla_siguiente		;0880   ; los negros siguen a la casilla de al lado
tramo:		; Un tramo nuevo: la cuenta y la direccion del sprite, y su patron
	ex af,af'			;0883
	xor a			;0884   ; ya no esta recien salido de una estacion
	ld (0e040h),a		;0885
	ex af,af'			;0888
	cp 004h		;0889   ; menos de 4: 32 pixeles en esa direccion (una casilla recta)
	ld (hl),020h		;088b
	jr c,L_0893		;088d
	ld (hl),a			;088f   ; si no, las veces en el nibble alto...
	xor a			;0890
	rrd		;0891   ; ...y la direccion en el bajo
L_0893:
	push hl			;0893
	dec hl			;0894   ; la direccion (+5)
	ld (hl),a			;0895
	ld c,a			;0896
	dec hl			;0897   ; el numero del tren (+4)
	ld b,(hl)			;0898
	ld hl,0e082h		;0899   ; su sprite: 0xE082 + 4 x el numero
	rst 30h			;089c
	jr z,L_08A1		;089d
	ld l,092h		;089f
L_08A1:
	ld a,b			;08a1
	or a			;08a2
	jr z,patron_blanco		;08a3   ; el blanco
busca_sprite:		; Cuatro bytes por sprite
	ld a,004h		;08a5   ; cuatro...
	rst 10h			;08a7
	djnz busca_sprite		;08a8   ; ...por el numero del tren
	ld a,c			;08aa   ; un negro: de dos en dos direcciones...
	and 006h		;08ab
	add a,a			;08ad
	add a,020h		;08ae   ; ...los patrones de 0x20
	jr pon_patron		;08b0   ; al sprite
patron_blanco:		; El blanco: un patron por direccion
	ld a,c			;08b2
	add a,a			;08b3
	add a,a			;08b4
pon_patron:		; El patron, y el primer pixel del tramo
	ld (hl),a			;08b5
	pop hl			;08b6
un_pixel:		; El sprite del tren, un pixel en su direccion (el trocito de 0x0AE0 + 3 x la direccion)
	dec hl			;08b7   ; la direccion (+5)...
	ld a,(hl)			;08b8
	ld b,a			;08b9
	add a,a			;08ba   ; ...por 3
	add a,b			;08bb
	ld c,a			;08bc
	dec hl			;08bd   ; el numero del tren (+4)...
	ld a,(hl)			;08be
	add a,a			;08bf   ; ...por 4
	add a,a			;08c0
	ld b,a			;08c1
	ld hl,0e080h		;08c2   ; los sprites del jugador
	rst 30h			;08c5
	jr z,lee_sprite		;08c6
	ld l,090h		;08c8
lee_sprite:		; Y a D, X a E
	ld a,b			;08ca   ; su sprite
	rst 10h			;08cb
	ld d,(hl)			;08cc
	inc hl			;08cd
	ld e,(hl)			;08ce
	push hl			;08cf
	ld a,c			;08d0   ; el trocito de la direccion
	ld hl,paso_arriba		;08d1
	rst 10h			;08d4
	call salta_hl		;08d5   ; mueve D y E
	pop hl			;08d8
	ld (hl),e			;08d9   ; la X...
	dec hl			;08da
	ld (hl),d			;08db   ; ...y la Y
sube_sprites:		; Los cuatro sprites del jugador a la tabla de atributos (0x3B00)
	push hl			;08dc
	ld hl,0e080h		;08dd   ; los del jugador 1...
	rst 30h			;08e0
	jr z,L_08E5		;08e1
	ld l,090h		;08e3   ; ...o los del 2
L_08E5:
	ld de,07b00h		;08e5   ; 16 bytes a 0x3B00
	ld b,010h		;08e8   ; 16 bytes
	di			;08ea
	rst 20h			;08eb
	ei			;08ec
	pop hl			;08ed   ; HL, como estaba
	ret			;08ee
se_tocan:		; Sprites que se tocan: |dY| + |dX| < 15 entre HL y los B de DE (de cuatro en cuatro); acarreo si alguno
	ld a,(de)			;08ef   ; dY
	sub (hl)			;08f0
	jr nc,L_08F5		;08f1
	neg		;08f3   ; en positivo
L_08F5:
	ld c,a			;08f5
	inc hl			;08f6   ; dX
	inc de			;08f7   ; el sprite siguiente de DE
	ld a,(de)			;08f8
	sub (hl)			;08f9
	jr nc,L_08FE		;08fa   ; en positivo
	neg		;08fc   ; en positivo
L_08FE:
	add a,c			;08fe   ; la suma
	jr c,otro_sprite		;08ff
	cp 00fh		;0901   ; menos de 15: se tocan
	ret c			;0903
otro_sprite:		; El sprite siguiente
	inc de			;0904   ; DE al sprite siguiente
	inc de			;0905
	inc de			;0906
	dec hl			;0907   ; HL a la Y otra vez
	djnz se_tocan		;0908   ; y el siguiente
	or a			;090a   ; no se toca ninguno
	ret			;090b
visita_estacion:		; Si el tren (L = su pieza, H = su casilla) esta en una estacion (pieza < 8), se da por visitada y se cierra; acarreo si lo estaba
	ld a,l			;090c   ; su pieza
	cp 008h		;090d   ; no es estacion
	ret nc			;090f
	ld a,h			;0910   ; cual de las estaciones del tablero
	call numero_estacion		;0911
	ld (hl),001h		;0914   ; visitada
	ld a,b			;0916
	push bc			;0917
	call estacion_n		;0918   ; sus dos casillas y su lado
	ld hl,0e051h		;091b   ; se guardan las casillas (0xE051, 0xE052)...
	ld (hl),a			;091e
	inc hl			;091f
	ld (hl),d			;0920
	call pieza_de		;0921   ; ...y la pieza (0xE050)
	ex de,hl			;0924
	call cierra_estacion		;0925   ; se cierra
	ld hl,0e045h		;0928   ; una estacion menos
	rst 30h			;092b
	rst 10h			;092c
	dec (hl)			;092d
	pop bc			;092e
	ld a,(0e24bh)		;092f   ; de la que iba a salir el tren negro?...
	cp b			;0932
	call z,espera_negro		;0933   ; ...entonces ya no sale
	scf			;0936   ; lo estaba
	ret			;0937
fuera_negros:		; Los tres trenes negros, fuera: sin marcha, sin casilla, y sus sprites abajo
	ld b,002h		;0938   ; el 3, el 2 y el 1
L_093A:
	push bc			;093a   ; el tren B
	call quita_negro		;093b   ; sin marcha
	inc hl			;093e   ; la casilla...
	xor a			;093f   ; sin casilla
	ld (hl),a			;0940   ; ...a cero
	pop bc			;0941
	dec b			;0942   ; el anterior
	jp p,L_093A		;0943
	ld hl,0e084h		;0946   ; sus sprites...
	rst 30h			;0949   ; o los del jugador 2
	jr z,L_094E		;094a
	ld l,094h		;094c
L_094E:
	ld b,003h		;094e   ; ...los tres
sprite_fuera:		; Y = 0xD1: fuera
	ld (hl),0d1h		;0950   ; Y fuera
	ld a,004h		;0952
	rst 10h			;0954   ; el siguiente
	djnz sprite_fuera		;0955
	call sube_sprites		;0957   ; a la VRAM
	ret			;095a
sale_negro:		; Un tren negro sale de la estacion anunciada (0xE24D), si hay sitio para el; acarreo si no
	ld hl,0e24dh		;095b   ; sus dos casillas y su lado
	call lado_estacion		;095e
	ld a,b			;0961   ; el lado menos uno: la direccion en la que arranca, por la via del marco
	dec a			;0962
	and 003h		;0963
	ld b,a			;0965
	ld hl,0e067h		;0966   ; los tres trenes negros
	ld a,(0e06ah)		;0969   ; el 1: en marcha o estallando?
	add a,(hl)			;096c
	jr z,pon_negro		;096d
	inc hl			;096f
	ld a,(0e06bh)		;0970   ; el 2
	add a,(hl)			;0973
	ld a,001h		;0974
	jr z,pon_negro		;0976
	inc hl			;0978
	ld a,(0e06ch)		;0979   ; el 3
	add a,(hl)			;097c
	scf			;097d   ; los tres ocupados: no sale
	ret nz			;097e
	ld a,002h		;097f
pon_negro:		; El tren negro A (0-2) en marcha: su casilla, su direccion y su primer paso
	inc (hl)			;0981   ; en marcha
	ld hl,0e322h		;0982   ; su ficha: 0xE322 + 32 x A
	rrca			;0985
	rrca			;0986
	rrca			;0987
	rst 10h			;0988
	ld (hl),c			;0989   ; la casilla
	inc hl			;098a
	ld (hl),b			;098b   ; y la direccion
	ld d,h			;098c
	ld e,l			;098d
	inc hl			;098e
	inc hl			;098f
	inc hl			;0990
	push hl			;0991
	ld (hl),001h		;0992   ; la cuenta, a 1
	ld a,005h		;0994
	rst 10h			;0996
	ld (hl),003h		;0997   ; el guion, en el 0xFF del final: entra en la casilla
	call sprite_en_casilla		;0999   ; su sprite en el borde de la casilla
	pop hl			;099c
	call paso_de_tren		;099d   ; y el primer paso
	or a			;09a0
	ret			;09a1
negro_en_cerrada:		; El tren negro B, si su casilla (A) es una de las dos de la estacion que se cierra, estalla
	ld hl,(0e058h)		;09a2   ; las dos casillas
	cp l			;09a5
	jr z,estalla_negro		;09a6
	cp h			;09a8
	ret nz			;09a9
estalla_negro:		; El tren negro B estalla
	ld a,b			;09aa   ; su explosion
	ld hl,0e06ah		;09ab
	rst 10h			;09ae
	ld (hl),001h		;09af
quita_negro:		; El tren negro B, sin marcha y sin pieza
	ld a,b			;09b1   ; sin marcha
	ld hl,0e067h		;09b2
	rst 10h			;09b5
	ld (hl),000h		;09b6
	inc b			;09b8   ; su ficha
	ld hl,0e302h		;09b9
busca_ficha:		; 32 bytes por ficha
	ld a,020h		;09bc   ; 32 bytes...
	rst 10h			;09be
	djnz busca_ficha		;09bf   ; ...por cada ficha
	dec hl			;09c1   ; sin pieza
	ld (hl),0ffh		;09c2   ; 0xFF: ninguna pieza
	ret			;09c4
estacion_al_azar:		; Una estacion del tablero sin visitar, al azar: C y D sus casillas, B su lado, E su numero
	ld hl,0e1b0h		;09c5   ; el tablero del jugador
	rst 30h			;09c8
	rst 10h			;09c9
	ld a,(hl)			;09ca
	ld b,a			;09cb   ; la lista de sus estaciones (0x115F)
	add a,a			;09cc
	ld hl,0115fh		;09cd
	rst 10h			;09d0
	ld e,(hl)			;09d1
	inc hl			;09d2
	ld d,(hl)			;09d3
	ld hl,011a7h		;09d4   ; cuantas tiene (0x11A7)
	ld a,b			;09d7
	rst 10h			;09d8
	ld c,(hl)			;09d9
	xor a			;09da   ; la primera...
	call lista_jugador		;09db
	push hl			;09de   ; ...en la lista del jugador
	ld a,r		;09df   ; al azar...
	and 007h		;09e1
	add a,l			;09e3   ; ...entre las ocho primeras
	ld l,a			;09e4
busca_sin_visitar:		; La siguiente, dando la vuelta a las 12
	inc hl			;09e5   ; la siguiente de la lista
	ld a,l			;09e6
	and 00fh		;09e7
	sub 00ch		;09e9   ; pasa de la 12?...
	jr c,sin_visitar		;09eb   ; menos de 12: vale
	ld b,a			;09ed   ; ...vuelve al principio
	ld a,l			;09ee   ; la decena de la direccion...
	and 0f0h		;09ef
	add a,b			;09f1
	ld l,a			;09f2   ; ...y vuelta al principio
sin_visitar:		; A cero: sin visitar
	xor a			;09f3   ; sin visitar?
	cp (hl)			;09f4
	jr nz,busca_sin_visitar		;09f5   ; visitada: otra
	pop bc			;09f7   ; su numero
	or a			;09f8
	sbc hl,bc		;09f9   ; su sitio en la lista...
	ld a,l			;09fb   ; ...es su numero
estacion_n:		; La estacion A de la lista DE: sus dos casillas (C, D) y su lado (B)
	ex de,hl			;09fc
	add a,a			;09fd   ; dos casillas por estacion
	rst 10h			;09fe
lado_estacion:		; El lado de la estacion: 0 abajo (fila 5), 1 izquierda, 2 arriba (fila 0), 3 derecha
	ld a,(hl)			;09ff   ; la primera casilla
	ld c,(hl)			;0a00
	inc hl			;0a01   ; la segunda
	ld d,(hl)			;0a02
	ld b,000h		;0a03
	cp 02ah		;0a05   ; la fila 5: abajo
	ret nc			;0a07
	ld b,002h		;0a08
	cp 007h		;0a0a   ; la fila 0: arriba
	ret c			;0a0c
	dec b			;0a0d
	bit 3,a		;0a0e   ; la primera casilla en fila par: izquierda; impar: derecha
	ret z			;0a10
	ld b,003h		;0a11
	ret			;0a13
cierra_estacion:		; La estacion de HL (pieza, casilla, casilla) se cierra: sus dos casillas pasan a la pieza 8-11 (las cruces) y se pintan
	ld a,(hl)			;0a14   ; la pieza de estacion (0-7) / 2...
	and 006h		;0a15
	rrca			;0a17
	or 008h		;0a18   ; ...+ 8: 8 arriba, 9 derecha, 10 abajo, 11 izquierda
	ld c,a			;0a1a
	inc hl			;0a1b
	ld a,(hl)			;0a1c   ; la primera casilla
	push af			;0a1d
	inc hl			;0a1e
	ld b,(hl)			;0a1f   ; la segunda
	ld (0e058h),bc		;0a20   ; las dos, para los trenes negros (0x0663)
	push bc			;0a24
	call casilla_a_vram		;0a25   ; la primera en la VRAM
	push hl			;0a28
	ld a,c			;0a29   ; la pieza nueva
	call pinta_pieza		;0a2a
	pop bc			;0a2d
	push bc			;0a2e
	ld a,b			;0a2f   ; la segunda
	call casilla_a_vram		;0a30
	push hl			;0a33
	ld a,c			;0a34   ; la pieza nueva
	call pinta_pieza		;0a35
	pop bc			;0a38
	pop af			;0a39
	ld (0e058h),a		;0a3a   ; 0xE058: la primera casilla
	call casilla_en_tablero		;0a3d   ; en el tablero
	ex de,hl			;0a40
	ld a,b			;0a41
	call casilla_en_tablero		;0a42
	ld a,c			;0a45   ; las dos
	ld (de),a			;0a46
	ld (hl),a			;0a47
	ld a,001h		;0a48   ; el tablero ha cambiado
	ld (0e05ah),a		;0a4a
	call pinta_fase		;0a4d   ; STAGE...
	call pinta_vidas		;0a50   ; ...y las vidas, otra vez
	ret			;0a53
numero_estacion:		; El numero de la estacion que tiene la casilla A, y HL a su sitio en la lista del jugador (0xE160)
	ld b,a			;0a54   ; la casilla
	ld hl,0e1b0h		;0a55   ; el tablero del jugador
	rst 30h			;0a58
	rst 10h			;0a59
	ld a,(hl)			;0a5a
	ld hl,0115fh		;0a5b   ; su lista de casillas
	add a,a			;0a5e   ; la lista de ese tablero
	rst 10h			;0a5f
	ld e,(hl)			;0a60
	inc hl			;0a61
	ld d,(hl)			;0a62
	ex de,hl			;0a63   ; al principio
	push hl			;0a64
	ld a,b			;0a65   ; la casilla que se busca
busca_casilla:		; Hasta dar con la casilla
	cp (hl)			;0a66   ; es esta?
	inc hl			;0a67
	jr nz,busca_casilla		;0a68   ; no: la siguiente
	dec hl			;0a6a   ; el sitio en la lista...
	pop de			;0a6b   ; el principio de la lista
	or a			;0a6c
	sbc hl,de		;0a6d   ; el sitio en la lista
	ld a,l			;0a6f   ; ...entre 2: el numero de la estacion
	rra			;0a70
lista_jugador:		; HL = 0xE160 (o 0xE170) + A: la estacion A del jugador
	ld b,a			;0a71
	ld hl,0e160h		;0a72   ; la del jugador 1
	rst 30h			;0a75
	jr z,L_0A7A		;0a76
	ld l,070h		;0a78   ; o la del 2
L_0A7A:
	ld a,b			;0a7a
	rst 10h			;0a7b
	ret			;0a7c
pinta_pieza:		; La pieza A (16 letras de 0x15C7) en la direccion de la VRAM que se deja en la pila
	pop bc			;0a7d   ; la vuelta, a un lado
	ld hl,015c7h		;0a7e   ; las piezas
	rlca			;0a81   ; x 16
	rlca			;0a82
	rlca			;0a83
	rla			;0a84
	jr nc,L_0A88		;0a85
	inc h			;0a87
L_0A88:
	rst 10h			;0a88
	pop de			;0a89   ; la direccion de la VRAM
	push bc			;0a8a
	push de			;0a8b   ; la vuelta, otra vez en su sitio
	call pinta_4x4		;0a8c   ; cuatro filas de cuatro
	pop de			;0a8f
	ret			;0a90
pieza_de:		; La pieza de la casilla (DE) a (DE - 1)
	ex de,hl			;0a91
	dec de			;0a92   ; la casilla
	ld a,(de)			;0a93
	call casilla_en_tablero		;0a94   ; su sitio en el tablero
	ld a,(hl)			;0a97   ; la pieza
	dec de			;0a98
	ld (de),a			;0a99
	ret			;0a9a
casilla_a_vram:		; La casilla A (fila x 8 + columna) a su direccion en la tabla de nombres, con el bit de escritura: 0x7820 + fila x 128 + columna x 4
	ld b,a			;0a9b
	and 0f0h		;0a9c   ; dos filas por cada 16...
	rrca			;0a9e
	rrca			;0a9f
	rrca			;0aa0
	rrca			;0aa1
	ld d,a			;0aa2   ; ...256 letras
	ld a,b			;0aa3   ; la columna...
	and 00fh		;0aa4
	add a,a			;0aa6   ; ...x 4, desde la letra 32
	add a,a			;0aa7
	add a,020h		;0aa8
	bit 3,b		;0aaa   ; y la fila impar...
	jr z,L_0AB0		;0aac
	add a,060h		;0aae   ; ...4 filas mas abajo
L_0AB0:
	ld e,a			;0ab0
	ld hl,07800h		;0ab1   ; la tabla de nombres
	add hl,de			;0ab4
	ret			;0ab5
casilla_en_tablero:		; HL = el sitio de la casilla A en el tablero del jugador (A no se toca)
	ex af,af'			;0ab6
	ld hl,0e100h		;0ab7   ; el del 1
	rst 30h			;0aba
	jr z,L_0ABF		;0abb
	ld l,030h		;0abd   ; o el del 2
L_0ABF:
	ex af,af'			;0abf
	rst 10h			;0ac0
	ret			;0ac1
suma_puntos:		; B (BCD, decenas) a los puntos del jugador, salvo en la demostracion
	ld a,(0e260h)		;0ac2   ; en la demostracion no se puntua
	or a			;0ac5
	ret nz			;0ac6
	ld hl,0e210h		;0ac7   ; los del 1
	rst 30h			;0aca
	jr z,L_0ACF		;0acb
	ld l,012h		;0acd   ; o los del 2
L_0ACF:
	ld a,(hl)			;0acf
	add a,b			;0ad0   ; las decenas y centenas
	daa			;0ad1   ; en BCD
	ld (hl),a			;0ad2
	ret nc			;0ad3   ; sin acarreo, ya esta
	inc hl			;0ad4   ; con acarreo, los millares
	ld a,(hl)			;0ad5
	add a,001h		;0ad6   ; uno mas
	daa			;0ad8
	ld (hl),a			;0ad9
	ret nc			;0ada   ; sin acarreo, ya esta
	xor a			;0adb   ; pasa de 99990: vuelve a cero
	ld (hl),a			;0adc
	dec hl			;0add
	ld (hl),a			;0ade
	ret			;0adf

; ----------------------------------------------------------------------
; LOS PASOS: ocho trocitos de 3 bytes, uno por direccion del sprite, que 0x08D5 llama con jp (hl). D es la Y y E la X.
; ----------------------------------------------------------------------
paso_arriba:		; Direccion 0: Y - 1
	dec d			;0ae0
	nop			;0ae1
	ret			;0ae2
paso_abajo:		; Direccion 1: Y + 1
	inc d			;0ae3
	nop			;0ae4
	ret			;0ae5
paso_derecha:		; Direccion 2: X + 1
	nop			;0ae6
	inc e			;0ae7
	ret			;0ae8
paso_izquierda:		; Direccion 3: X - 1
	nop			;0ae9
	dec e			;0aea
	ret			;0aeb
paso_arriba_derecha:		; Direccion 4
	dec d			;0aec
	inc e			;0aed
	ret			;0aee
paso_abajo_izquierda:		; Direccion 5
	inc d			;0aef
	dec e			;0af0
	ret			;0af1
paso_abajo_derecha:		; Direccion 6
	inc d			;0af2
	inc e			;0af3
	ret			;0af4
paso_arriba_izquierda:		; Direccion 7
	dec d			;0af5
	dec e			;0af6
	ret			;0af7
sprite_en_casilla:		; El sprite del tren de la ficha DE (+2 su casilla, +3 su direccion) en el borde de su casilla por el que va a salir
	ex de,hl			;0af8   ; la direccion (0 arriba, 1 derecha, 2 abajo, 3 izquierda)...
	ld e,(hl)			;0af9
	dec hl			;0afa   ; ...y la casilla
	ld d,(hl)			;0afb
	inc hl			;0afc
	push de			;0afd
	ld a,d			;0afe   ; la fila...
	rrca			;0aff
	rrca			;0b00
	rrca			;0b01
	and 007h		;0b02
	add a,a			;0b04   ; ...x 2
	ld b,a			;0b05
	ld a,e			;0b06   ; hacia arriba?...
	or a			;0b07
	jr nz,L_0B0B		;0b08
	dec b			;0b0a   ; ...medio paso menos
L_0B0B:
	cp 002h		;0b0b   ; hacia abajo?...
	jr nz,L_0B10		;0b0d
	inc b			;0b0f   ; ...medio paso mas
L_0B10:
	ld a,010h		;0b10   ; la Y: 16 + 16 x (2 x fila + el ajuste)
L_0B12:
	add a,010h		;0b12
	djnz L_0B12		;0b14
	ld c,a			;0b16   ; la Y
	pop de			;0b17
	ld a,d			;0b18   ; la columna...
	and 007h		;0b19
	add a,a			;0b1b   ; ...x 2
	ld b,a			;0b1c
	ld a,e			;0b1d   ; hacia la derecha?...
	dec a			;0b1e
	jr nz,L_0B22		;0b1f
	inc b			;0b21   ; ...medio paso mas
L_0B22:
	cp 002h		;0b22   ; hacia la izquierda?...
	jr nz,L_0B27		;0b24
	dec b			;0b26   ; ...medio paso menos
L_0B27:
	ld a,008h		;0b27   ; la X: 8 + 16 x (2 x columna + el ajuste)
L_0B29:
	add a,010h		;0b29   ; 16 x...
	djnz L_0B29		;0b2b   ; ...el doble de la columna
	ld b,a			;0b2d   ; la X
	ex de,hl			;0b2e
	ld a,e			;0b2f   ; el numero de la ficha (bits 5-6 de su direccion)...
	and 0e0h		;0b30   ; la ficha: 0xE300, 0xE320, ...
	rrca			;0b32   ; ...x 4: su sprite
	rrca			;0b33
	rrca			;0b34
	add a,080h		;0b35   ; ...0x80, 0x84, 0x88, 0x8C: su sprite
	ld l,a			;0b37
	rst 30h			;0b38   ; el jugador 2...
	jr z,L_0B3E		;0b39
	ld a,010h		;0b3b   ; ...16 mas alla
	rst 10h			;0b3d
L_0B3E:
	ld h,0e0h		;0b3e   ; en la tabla del jugador
	ld (hl),c			;0b40   ; Y
	inc hl			;0b41
	ld (hl),b			;0b42   ; y X
	ret			;0b43
pinta_4x4:		; 16 letras de HL en cuatro filas de cuatro desde DE; para al llegar al final de la tabla de nombres
	ld c,004h		;0b44   ; cuatro filas
fila_4x4:		; Una fila de cuatro letras
	ld b,004h		;0b46   ; cuatro letras
	di			;0b48
	rst 20h			;0b49   ; a la VRAM
	ei			;0b4a
	ex de,hl			;0b4b   ; la fila de abajo
	ld a,020h		;0b4c   ; DE + 32
	rst 10h			;0b4e
	ex de,hl			;0b4f
	ld a,d			;0b50   ; se sale de la tabla de nombres (0x3B00)?
	and 003h		;0b51
	cp 003h		;0b53   ; 0x3B00?
	ret z			;0b55   ; fuera de la tabla: se acaba
	dec c			;0b56   ; cuatro filas
	ret z			;0b57
	jr fila_4x4		;0b58   ; la fila siguiente

; ----------------------------------------------------------------------
; EL TABLERO REVUELTO, desde el cuarto tablero: el interior (6 x 4 casillas) sale de la tira de 0x126B, empezando en un sitio que depende de N; el hueco en la casilla 12 y un cruce en la 28; y segun N, de 2 a 8 casillas pasan a ser vias rectas (la pieza 0x14) en los sitios de 0x127E. N es el numero de la fase ANTERIOR: 0x0313 llama aqui antes de que 0x0320 suba 0xE230 (en la fase 4, N = 3).
; ----------------------------------------------------------------------
tablero_revuelto:		; El interior del cuarto tablero, revuelto segun la fase
	ld hl,0e230h		;0b5a   ; N, la fase anterior
	rst 30h			;0b5d
	rst 10h			;0b5e
	ld a,(hl)			;0b5f
fase_a_16:		; N (BCD), de 1 a 16
	cp 011h		;0b60
	jr c,empieza_tira		;0b62
	sub 010h		;0b64
	jr fase_a_16		;0b66
empieza_tira:		; Desde ese sitio de la tira
	ld hl,0126bh		;0b68
	rst 10h			;0b6b
	ex de,hl			;0b6c
	ld c,009h		;0b6d   ; la casilla 9: fila 1, columna 1
casilla_de_tira:		; Una casilla del interior
	ld a,(de)			;0b6f   ; la pieza
	or a			;0b70   ; el cero del final: la tira vuelve a empezar
	jr z,tira_otra_vez		;0b71
	ld b,a			;0b73
	ld a,c			;0b74
	call casilla_en_tablero		;0b75   ; su sitio en el tablero
	ld (hl),b			;0b78   ; la pieza
	inc de			;0b79
	inc c			;0b7a   ; la casilla siguiente
	ld a,c			;0b7b
	and 007h		;0b7c
	cp 007h		;0b7e   ; la columna 7?...
	jr nz,casilla_de_tira		;0b80
	inc c			;0b82   ; ...a la columna 1 de la fila siguiente
	inc c			;0b83
	ld a,c			;0b84
	cp 029h		;0b85   ; hasta la fila 5
	jr nz,casilla_de_tira		;0b87
	ld hl,0e10ch		;0b89   ; la casilla 12...
	rst 30h			;0b8c
	jr z,L_0B91		;0b8d
	ld l,03ch		;0b8f
L_0B91:
	ld (hl),00fh		;0b91   ; ...es el hueco
	ld a,010h		;0b93   ; y la 28...
	rst 10h			;0b95
	ld (hl),00eh		;0b96   ; ...un cruce
	ld hl,0e230h		;0b98   ; N
	rst 30h			;0b9b
	rst 10h			;0b9c
	ld a,(hl)			;0b9d
	cp 011h		;0b9e   ; N de 11 en adelante:...
	jr c,fase_baja		;0ba0
	ld b,008h		;0ba2   ; ...8 rectas desde 20...
	cp 020h		;0ba4
	jr nc,fase_a_16b		;0ba6
	ld b,007h		;0ba8   ; ...7 desde 14...
	cp 014h		;0baa
	jr nc,fase_a_16b		;0bac
	ld b,006h		;0bae   ; ...6 hasta 13
fase_a_16b:		; Menos 16, hasta quedar por debajo
	cp 010h		;0bb0
	jr c,pon_rectas		;0bb2
	sub 010h		;0bb4
	jr fase_a_16b		;0bb6
fase_baja:		; N hasta 10: N - 1 rectas, 6 como mucho
	dec a			;0bb8   ; N - 1
	ld b,006h		;0bb9
	cp 007h		;0bbb
	jr nc,pon_rectas		;0bbd
	ld b,a			;0bbf
pon_rectas:		; Las B rectas, desde ese sitio de la lista de 0x127E
	ld hl,0127eh		;0bc0
	rst 10h			;0bc3
pon_recta:		; Una recta
	ld a,(hl)			;0bc4   ; la casilla
	push hl			;0bc5
	call casilla_en_tablero		;0bc6
	ld (hl),014h		;0bc9   ; la pieza 0x14
	pop hl			;0bcb
	inc hl			;0bcc   ; el siguiente sitio
	djnz pon_recta		;0bcd   ; las B
	ret			;0bcf
tira_otra_vez:		; La tira vuelve a empezar
	ld de,0126bh		;0bd0
	jr casilla_de_tira		;0bd3
borra_pantalla:		; La tabla de nombres entera, a cero
	ld l,000h		;0bd5   ; 768 letras
	ld de,07800h		;0bd7
	jr borra_nombres		;0bda
borra_juego:		; La tabla de nombres desde la fila 2, a cero (la cabecera se queda)
	ld l,0e0h		;0bdc   ; desde la fila 2: 704 letras
	ld de,07840h		;0bde
borra_nombres:		; 256 ceros, y dos veces L ceros mas
	ld c,000h		;0be1   ; 256 ceros
	ld b,c			;0be3
	di			;0be4
	rst 28h			;0be5
	ld h,002h		;0be6
borra_tramo:		; L ceros
	ld b,l			;0be8   ; L ceros
	call rellena_vram_a		;0be9
	dec h			;0bec   ; dos veces
	jr nz,borra_tramo		;0bed
	ei			;0bef   ; las interrupciones, otra vez
	ret			;0bf0
otro_jugador:		; El turno al otro jugador; acarreo si le quedan vidas (B = el de antes)
	ld hl,0e001h		;0bf1   ; el jugador en curso
	ld a,(hl)			;0bf4
	ld b,(hl)			;0bf5
	inc a			;0bf6   ; el otro
	and 001h		;0bf7
	ld (hl),a			;0bf9
	inc hl			;0bfa
	rst 10h			;0bfb   ; sus vidas
	ld a,(hl)			;0bfc
	or a			;0bfd
	ret z			;0bfe   ; sin vidas
	scf			;0bff   ; le quedan
	ret			;0c00
pinta_puntos:		; Los puntos del jugador en curso: fila 0, columna 5 (1P) o 14 (2P)
	ld hl,0e210h		;0c01   ; los del 1
	ld de,07805h		;0c04   ; en la fila 0, columna 5
	rst 30h			;0c07
	jr z,pinta_cifras		;0c08
	ld l,012h		;0c0a   ; los del 2
	ld e,00eh		;0c0c   ; columna 14
	jr pinta_cifras		;0c0e
pinta_record:		; El record: fila 0, columna 25
	ld hl,0e214h		;0c10
	ld de,07819h		;0c13
pinta_cifras:		; Cuatro cifras BCD de HL en DE; con los puntos de un jugador, mira tambien la vida extra
	push de			;0c16
	ld b,(hl)			;0c17   ; las decenas y centenas
	push bc			;0c18
	inc hl			;0c19
	ld c,(hl)			;0c1a   ; los millares
	ld a,l			;0c1b   ; es el record?
	cp 015h		;0c1c
	jr z,cifras_a_vram		;0c1e
	ld hl,0e216h		;0c20   ; las vidas extra que lleva el jugador
	rst 30h			;0c23
	rst 10h			;0c24
	ex de,hl			;0c25
	ld a,(de)			;0c26
	cp 004h		;0c27   ; cuatro ya: no hay mas
	jr nc,cifras_a_vram		;0c29
	ld hl,00005h		;0c2b   ; la primera a los 5000...
	or a			;0c2e
	ld b,a			;0c2f   ; ...si aun no lleva ninguna (B, desde aqui, las vidas dadas)
	jr z,mira_vida_extra		;0c30
	xor a			;0c32
umbral_vida:		; La siguiente cada 30000: 30000, 60000, 90000
	add a,030h		;0c33
	daa			;0c35
	djnz umbral_vida		;0c36
	ld l,a			;0c38
mira_vida_extra:		; Solo cuentan los millares (C): B ya no son las decenas: 0x0C2F ha puesto en B las vidas dadas (y el djnz lo deja a cero). Como los millares suben de uno en uno, la vida extra no se salta nunca
	or a			;0c39
	sbc hl,bc		;0c3a   ; H y L (0, el umbral) contra B y C (0, los millares)
	ex de,hl			;0c3c
	jr nz,cifras_a_vram		;0c3d   ; otros millares
	inc (hl)			;0c3f   ; una vida extra dada
	ld hl,0e002h		;0c40   ; una vida mas
	rst 30h			;0c43
	rst 10h			;0c44
	inc (hl)			;0c45
	call pinta_vidas		;0c46   ; las vidas en pantalla
cifras_a_vram:		; Las cuatro cifras a la VRAM
	pop af			;0c49   ; A = decenas y centenas, C = millares
	ld b,002h		;0c4a   ; dos bytes
	call bcd_a_letras		;0c4c
	inc de			;0c4f   ; las cuatro letras
	ex de,hl			;0c50
	pop de			;0c51   ; la direccion
	ld b,004h		;0c52   ; cuatro
	di			;0c54
	rst 20h			;0c55
	ei			;0c56
	ret			;0c57
bcd_a_letras:		; B bytes BCD (A y luego C) a letras (0xE2 = "0"), de 0xE223 hacia atras
	ld de,0e223h		;0c58
byte_a_letras:		; Un byte: dos cifras
	ld hl,0e218h		;0c5b   ; el byte, a 0xE218
	ld (hl),a			;0c5e
	xor a			;0c5f   ; la cifra baja
	rrd		;0c60   ; la cifra baja a A
	add a,0e2h		;0c62   ; como letra
	ld (de),a			;0c64   ; a su sitio
	dec de			;0c65
	ld a,(hl)			;0c66   ; la alta
	add a,0e2h		;0c67   ; como letra
	ld (de),a			;0c69   ; a su sitio
	dec de			;0c6a
	ld a,c			;0c6b   ; el byte siguiente
	djnz byte_a_letras		;0c6c   ; el byte siguiente (C)
	ret			;0c6e
mira_record:		; Los puntos DE contra el record: si lo pasan, son el record nuevo
	ld hl,(0e214h)		;0c6f   ; el record
	sbc hl,de		;0c72
	jr nc,pinta_record		;0c74   ; no lo pasan
	ld (0e214h),de		;0c76   ; record nuevo
	jr pinta_record		;0c7a
pinta_vidas:		; Las vidas que quedan, menos la que se juega: un tren pequeno (letra 0x64) cada una, en la fila 1
	ld a,(0e260h)		;0c7c   ; en la demostracion, no
	or a			;0c7f
	ret nz			;0c80
	ld de,07822h		;0c81   ; fila 1, columna 2
	push de			;0c84   ; se guarda
	ld b,011h		;0c85   ; 17 letras a cero
	ld c,a			;0c87   ; cero
	di			;0c88
	rst 28h			;0c89   ; a la VRAM
	ei			;0c8a
	ld hl,0e002h		;0c8b   ; las vidas del jugador
	rst 30h			;0c8e
	rst 10h			;0c8f
	ld b,(hl)			;0c90
	pop de			;0c91   ; la direccion
	dec b			;0c92   ; menos la que se juega
	ret z			;0c93   ; era la ultima: ninguna
	ld c,064h		;0c94   ; la letra 0x64
	di			;0c96
	rst 28h			;0c97   ; una por vida
	ei			;0c98
	ret			;0c99
pinta_fase:		; STAGE y su numero (dos cifras, fila 1, columna 26)
	ld hl,015beh		;0c9a   ; STAGE
	call pinta_textos		;0c9d
	ld hl,0e230h		;0ca0   ; la fase
	rst 30h			;0ca3
	rst 10h			;0ca4
	ld a,(hl)			;0ca5
	ld l,032h		;0ca6
	ld (hl),a			;0ca8   ; la cifra baja
	xor a			;0ca9
	rrd		;0caa
	inc hl			;0cac
	add a,0e2h		;0cad   ; como letra
	ld (hl),a			;0caf
	dec hl			;0cb0
	ld a,(hl)			;0cb1   ; la alta
	add a,0e2h		;0cb2
	ld (hl),a			;0cb4
	ld de,0783ah		;0cb5   ; fila 1, columna 26
	ld b,002h		;0cb8   ; dos cifras
	di			;0cba
	rst 20h			;0cbb
	ei			;0cbc
	ret			;0cbd
prepara_tablero_jugador:		; Los sprites (0x12EA) y el tablero que toca (0x11AB + 48 x n) del jugador en curso
	ld de,012eah		;0cbe   ; los cuatro sprites de salida
	ld hl,0e080h		;0cc1
	rst 30h			;0cc4
	jr z,L_0CC9		;0cc5
	ld l,090h		;0cc7
L_0CC9:
	ex de,hl			;0cc9   ; 16 bytes
	ld bc,00010h		;0cca   ; 16 bytes
	ldir		;0ccd
	ld hl,0e1b0h		;0ccf   ; el tablero que toca
	rst 30h			;0cd2
	rst 10h			;0cd3
	ld a,(hl)			;0cd4
	push af			;0cd5
	ld hl,0117bh		;0cd6   ; los tableros, 48 bytes cada uno
	ld b,a			;0cd9
	inc b			;0cda   ; uno mas: el primero se salta la tabla de 0x117B
	ld c,030h		;0cdb   ; 48 bytes por tablero
busca_tablero:		; 48 bytes por tablero
	ld a,c			;0cdd   ; 48...
	rst 10h			;0cde
	djnz busca_tablero		;0cdf   ; ...por cada uno
	ld de,0e100h		;0ce1   ; al tablero del jugador
	rst 30h			;0ce4
	jr z,L_0CE9		;0ce5
	ld e,030h		;0ce7   ; o 0xE130
L_0CE9:
	ldir		;0ce9   ; los 48 bytes (BC sigue siendo 48)
	pop af			;0ceb   ; el cuarto?...
	cp 003h		;0cec
	ret c			;0cee
	jp tablero_revuelto		;0cef   ; ...revuelto
prepara_trenes:		; Las cuatro fichas de reserva del jugador (0xE400 o 0xE480): la plantilla de 0x12B7 y su numero
	ld hl,0e400h		;0cf2   ; la reserva del 1...
	rst 30h			;0cf5
	jr z,L_0CFA		;0cf6
	ld l,080h		;0cf8   ; ...o la del 2
L_0CFA:
	ex de,hl			;0cfa
	push de			;0cfb
	ld a,004h		;0cfc   ; cuatro
copia_plantilla:		; Una ficha: los 32 bytes de la plantilla
	ld hl,012b7h		;0cfe   ; la plantilla
	ld bc,00020h		;0d01   ; 32 bytes
	ldir		;0d04
	dec a			;0d06   ; la siguiente
	jr nz,copia_plantilla		;0d07
	pop hl			;0d09   ; la segunda ficha (+1)
	ld a,021h		;0d0a
	rst 10h			;0d0c
	ld b,001h		;0d0d   ; los trenes negros 1-3
numera_ficha:		; Sin pieza, sin casilla y su numero (+4)
	xor a			;0d0f   ; sin pieza (+1)...
	ld (hl),a			;0d10
	inc hl			;0d11
	ld (hl),a			;0d12   ; ...sin casilla (+2)...
	inc hl			;0d13
	inc hl			;0d14
	ld (hl),b			;0d15   ; ...y su numero (+4)
	ld a,01dh		;0d16   ; la ficha siguiente
	rst 10h			;0d18   ; la ficha siguiente (+1)
	inc b			;0d19   ; el numero siguiente
	ld a,004h		;0d1a
	cp b			;0d1c   ; hasta la 3
	jr nz,numera_ficha		;0d1d
	ret			;0d1f
guarda_trenes:		; Las fichas en juego (0xE300) a la reserva del jugador A
	ld de,0e400h		;0d20
	or a			;0d23
	jr z,L_0D28		;0d24
	ld e,080h		;0d26
L_0D28:
	ld hl,0e300h		;0d28   ; 128 bytes
copia_fichas:		; 128 bytes
	ld bc,00080h		;0d2b
	ldir		;0d2e
	ret			;0d30
saca_trenes:		; La reserva del jugador en curso a las fichas en juego (0xE300)
	ld hl,0e400h		;0d31
	rst 30h			;0d34
	jr z,L_0D39		;0d35
	ld l,080h		;0d37
L_0D39:
	ld de,0e300h		;0d39
	jr copia_fichas		;0d3c
anuncia_negro:		; Va a salir un tren negro: su sonido, la cuenta (21) y una estacion sin visitar al azar; las tres letras de la cuenta, junto a ella
	ld hl,01954h		;0d3e   ; el sonido del aviso
	ld (0e3a0h),hl		;0d41
	ld hl,0e240h		;0d44   ; anunciado...
	inc hl			;0d47
	inc (hl)			;0d48
	inc hl			;0d49   ; ...el divisor, para la primera bajada...
	inc (hl)			;0d4a
	inc hl			;0d4b   ; ...y la cuenta: 21
	ld (hl),021h		;0d4c
	call estacion_al_azar		;0d4e   ; la estacion
	push de			;0d51
	push bc			;0d52
	ld hl,0e24dh		;0d53   ; sus casillas
	ld (hl),c			;0d56
	inc hl			;0d57
	ld (hl),d			;0d58
	call pieza_de		;0d59   ; y su pieza
	ld a,c			;0d5c   ; la primera casilla en la VRAM
	call casilla_a_vram		;0d5d
	pop af			;0d60   ; el lado
	cp 001h		;0d61   ; la de la derecha...
	jr nz,L_0D66		;0d63
	dec h			;0d65   ; ...ocho filas mas arriba
L_0D66:
	add a,a			;0d66   ; el sitio de la primera cifra y el paso (0x1297)...
	ex de,hl			;0d67
	ld hl,01297h		;0d68
	rst 10h			;0d6b
	ex de,hl			;0d6c
	ld a,(de)			;0d6d   ; ...segun el lado
	rst 10h			;0d6e
	ld (0e244h),hl		;0d6f   ; la primera cifra
	inc de			;0d72
	ld a,(de)			;0d73   ; el paso: 1 (en fila) o 32 (en columna)
	ld b,a			;0d74
	rst 10h			;0d75
	ld (0e246h),hl		;0d76   ; la segunda
	ld a,b			;0d79
	rst 10h			;0d7a
	ld (0e248h),hl		;0d7b   ; la tercera
	ex de,hl			;0d7e
	di			;0d7f
	res 6,d		;0d80   ; para leer
	rst 18h			;0d82
	in a,(098h)		;0d83   ; lo que habia en la primera
	ei			;0d85
	ld hl,0e24ah		;0d86   ; se guarda, para borrar luego
	ld (hl),a			;0d89
	inc hl			;0d8a
	pop de			;0d8b   ; y el numero de la estacion
	ld (hl),e			;0d8c
	ret			;0d8d
cuenta_a_cero:		; La cuenta llega a cero: sale el tren negro; si no cabe, la estacion se cierra
	call sale_negro		;0d8e   ; sale
	jr nc,borra_cuenta		;0d91   ; ha salido: se borra la cuenta
	ld hl,0e24ch		;0d93   ; no cabe: la estacion se cierra...
	call cierra_estacion		;0d96
	ld a,(0e24bh)		;0d99   ; ...y queda visitada...
	call lista_jugador		;0d9c
	inc (hl)			;0d9f
	ld hl,0e045h		;0da0   ; ...una menos
	rst 30h			;0da3
	rst 10h			;0da4
	dec (hl)			;0da5
	jr espera_negro		;0da6
borra_cuenta:		; Las tres letras de la cuenta, otra vez como estaban
	ld hl,0e24ah		;0da8   ; lo que habia
	ld c,(hl)			;0dab
	ld b,003h		;0dac   ; tres
L_0DAE:
	dec hl			;0dae   ; la direccion de la cifra...
	ld d,(hl)			;0daf
	dec hl			;0db0
	ld e,(hl)			;0db1   ; ...en DE
	di			;0db2
	set 6,d		;0db3   ; para escribir
	rst 18h			;0db5
	ld a,c			;0db6   ; lo que habia
	out (098h),a		;0db7   ; a la VRAM
	ei			;0db9
	djnz L_0DAE		;0dba   ; la siguiente
espera_negro:		; La espera hasta el siguiente aviso: 3 a 6 casillas del tren blanco, al azar, y sin aviso
	ld hl,0e240h		;0dbc   ; la espera
	ld a,r		;0dbf
	and 003h		;0dc1
	add a,003h		;0dc3   ; de 3 a 6
	ld (hl),a			;0dc5
	inc hl			;0dc6
	xor a			;0dc7   ; sin aviso
	ld (hl),a			;0dc8
	ret			;0dc9
casilla_de_al_lado:		; La casilla de la ficha DE (+2) pasa a la de al lado en su direccion (+3): -8, +1, +8 o -1 (0x1293); B = la de antes
	ld hl,01293h		;0dca   ; el paso de cada direccion
	ld a,(de)			;0dcd   ; la direccion
	rst 10h			;0dce
	ld a,(hl)			;0dcf   ; el paso
	ex de,hl			;0dd0
	dec hl			;0dd1
	ld b,(hl)			;0dd2   ; la casilla de antes
	add a,(hl)			;0dd3   ; la nueva
	ld (hl),a			;0dd4
	ret			;0dd5
entra_en_casilla:		; El tren entra en la casilla nueva: por donde entra, la pieza que hay, y por donde sale y con que guion (A); en las estaciones, el tren blanco las va pisando
	inc hl			;0dd6
	ld a,(hl)			;0dd7   ; la direccion...
	add a,002h		;0dd8   ; ...dada la vuelta: el lado por el que entra
	and 003h		;0dda
	ld (hl),a			;0ddc
mira_pieza:		; La pieza de la casilla y lo que hace con el tren
	call pieza_de		;0ddd   ; la pieza (+1)
	inc de			;0de0
	cp 008h		;0de1   ; una estacion (0-7)?
	jr nc,pieza_a_grupo		;0de3
	ld b,e			;0de5   ; la ficha: es el tren blanco (0xE302)?
	dec b			;0de6
	dec b			;0de7
	jr nz,estacion_es_curva		;0de8   ; los negros solo pasan
	ld hl,0e041h		;0dea   ; una casilla de estacion pisada mas
	inc (hl)			;0ded
	ld b,(hl)			;0dee
	inc hl			;0def   ; la pieza
	ld (hl),a			;0df0
	ex af,af'			;0df1   ; a un lado
	ld a,b			;0df2   ; y la casilla...
	rst 10h			;0df3
	ld a,(de)			;0df4
	ld (hl),a			;0df5   ; ...a 0xE043 o 0xE044
	exx			;0df6
	call numero_estacion		;0df7   ; de que estacion es
	ld a,(0e24bh)		;0dfa   ; la del tren negro anunciado?...
	cp b			;0dfd
	jr nz,segunda_casilla		;0dfe
	call espera_negro		;0e00   ; ...ya no sale...
	ld a,(0e243h)		;0e03   ; ...y la cuenta que le quedaba, en puntos
	ld b,a			;0e06
	call suma_puntos		;0e07
segunda_casilla:		; Las dos casillas pisadas: la estacion queda visitada, 90 puntos
	exx			;0e0a
	ld a,b			;0e0b   ; dos?
	cp 002h		;0e0c
	jr nz,pieza_otra_vez		;0e0e
	exx			;0e10
	ld a,(0e043h)		;0e11   ; la segunda casilla...
	call numero_estacion		;0e14   ; ...su estacion...
	inc (hl)			;0e17   ; ...visitada
	ld a,(0e24bh)		;0e18   ; la del tren negro anunciado?...
	cp b			;0e1b
	jr nz,L_0E21		;0e1c
	call borra_cuenta		;0e1e   ; ...se borra su cuenta
L_0E21:
	ld b,009h		;0e21   ; 90 puntos
	call suma_puntos		;0e23
	exx			;0e26
	ld hl,0e045h		;0e27   ; una estacion menos
	rst 30h			;0e2a
	rst 10h			;0e2b
	dec (hl)			;0e2c
	jr z,pieza_otra_vez		;0e2d   ; era la ultima: sin campanilla
	push hl			;0e2f
	ld hl,01849h		;0e30   ; la campanilla del canal 1 (0x1849)
	ld (0e3a0h),hl		;0e33
	pop hl			;0e36
pieza_otra_vez:		; La pieza, otra vez en A
	ex af,af'			;0e37
estacion_es_curva:		; Las piezas de estacion, como las del interior (0x12E2: 0x0C o 0x0D)
	ld hl,012e2h		;0e38
	rst 10h			;0e3b
	ld a,(hl)			;0e3c
pieza_a_grupo:		; El grupo de la pieza en la tabla de 0x12CE: 0 sin via (el hueco, 8-11), 4 la 0x0C, 8 la 0x0D, 12 el cruce (0x0E), 16 la recta (0x14)
	cp 00fh		;0e3d   ; el hueco?
	jr z,sin_via		;0e3f
	cp 00ch		;0e41   ; las cruces de las estaciones cerradas (8-11)?
	jr c,sin_via		;0e43
	cp 014h		;0e45   ; la recta (0x14)...
	jr nz,L_0E4B		;0e47
	ld a,00fh		;0e49   ; ...cuenta como la 0x0F: el grupo 16
L_0E4B:
	and 003h		;0e4b   ; (la pieza & 3 + 1) x 4
	inc a			;0e4d
	rlca			;0e4e
	rlca			;0e4f
	jr salida		;0e50
sin_via:		; Sin via: el grupo 0
	xor a			;0e52
salida:		; La tabla de la pieza por el lado de entrada: nibble alto, la direccion nueva; bajo, el guion (0-15) que se devuelve en A
	ld hl,012ceh		;0e53   ; la tabla
	rst 10h			;0e56
	inc de			;0e57   ; el lado de entrada
	ld a,(de)			;0e58
	rst 10h			;0e59
	ld a,(hl)			;0e5a   ; el byte
	ex de,hl			;0e5b
	ld (hl),a			;0e5c   ; a la direccion
	xor a			;0e5d
	rrd		;0e5e   ; la direccion nueva arriba, el guion en A
	ret			;0e60

; ----------------------------------------------------------------------
; LA CASILLA SIGUIENTE (del 0xFF del guion; DE = la ficha + 6). Para el tren blanco, ademas: el mando de la demostracion, 10 puntos si no va dando vueltas, la espera del tren negro y el cierre de la estacion recien pisada.
; ----------------------------------------------------------------------
casilla_siguiente:		; El tren pasa a la casilla de al lado y toma su guion
	ex de,hl			;0e61   ; la ficha...
	dec de			;0e62   ; ...+3
	dec de			;0e63
	dec de			;0e64
	ld a,e			;0e65   ; el tren blanco (0xE303)?
	sub 003h		;0e66
	jr nz,a_la_casilla		;0e68
	ld hl,0e261h		;0e6a   ; la demostracion: el siguiente movimiento de su mando...
	ld a,(hl)			;0e6d
	inc (hl)			;0e6e
	ld hl,013e2h		;0e6f   ; ...de la tira de 0x13E2
	rst 10h			;0e72
	ld a,(hl)			;0e73
	ld (0e262h),a		;0e74
	ld a,001h		;0e77   ; que se mire si va dando vueltas
	ld (0e1a0h),a		;0e79
	ld a,(0e1aah)		;0e7c   ; dando vueltas...
	or a			;0e7f
	jr nz,L_0E87		;0e80   ; ...no puntua
	ld b,001h		;0e82   ; 10 puntos por casilla
	call suma_puntos		;0e84
L_0E87:
	ld hl,0e041h		;0e87   ; casillas de estacion pisadas
	ld b,(hl)			;0e8a
	dec b			;0e8b   ; una: a medias, nada
	jr z,L_0E9B		;0e8c
	exx			;0e8e
	ld hl,0e240h		;0e8f   ; la espera del tren negro...
	ld a,(hl)			;0e92
	or a			;0e93   ; ...si no hay aviso ya...
	jr z,L_0E9A		;0e94
	dec (hl)			;0e96   ; ...una casilla menos, y a cero, el aviso
	call z,anuncia_negro		;0e97
L_0E9A:
	exx			;0e9a
L_0E9B:
	dec b			;0e9b   ; dos?
	jr nz,a_la_casilla		;0e9c
	ld (hl),b			;0e9e   ; a cero
	dec hl			;0e9f   ; recien salido de una estacion (0xE040)
	ld (hl),001h		;0ea0
	exx			;0ea2
	ld hl,0e042h		;0ea3   ; la estacion se cierra
	call cierra_estacion		;0ea6
	exx			;0ea9
a_la_casilla:		; Todos los trenes: a la casilla de al lado
	ld hl,0e008h		;0eaa   ; el tren blanco tiene que salir otra vez desde su casilla?
	rst 30h			;0ead
	rst 10h			;0eae
	ld a,(hl)			;0eaf
	or a			;0eb0
	jr z,avanza		;0eb1
	dec (hl)			;0eb3   ; una vez
	call sprite_en_casilla		;0eb4   ; su sprite en el borde de la casilla
	ex de,hl			;0eb7
	call mira_pieza		;0eb8   ; y la pieza de la misma casilla
	jr pon_guion		;0ebb
avanza:		; A la casilla de al lado
	call casilla_de_al_lado		;0ebd   ; la casilla nueva
	ld a,(0e03ah)		;0ec0   ; se esta deslizando una pieza?...
	or a			;0ec3
	jr z,entra		;0ec4
	ld a,(0e035h)		;0ec6   ; ...y es la casilla nueva?
	cp (hl)			;0ec9
	jr nz,entra		;0eca
	ld (hl),b			;0ecc   ; si: el tren se queda donde estaba...
	set 2,l		;0ecd   ; ...(la cuenta, +6)...
	ld a,(0e040h)		;0ecf   ; ...y choca; el blanco, si no acaba de salir de una estacion...
	or a			;0ed2
	jr nz,choca_deslizando		;0ed3
	push hl			;0ed5
	ld hl,0e008h		;0ed6   ; ...sale otra vez desde su casilla
	rst 30h			;0ed9
	rst 10h			;0eda
	ld (hl),001h		;0edb
	pop hl			;0edd
choca_deslizando:		; Choca contra la pieza que se mueve
	jp choque_sigue		;0ede
entra:		; Entra en la casilla nueva
	call entra_en_casilla		;0ee1
pon_guion:		; El guion que toca (0x12FA + 4 x A), desde su primer byte, y a leerlo
	ex de,hl			;0ee4
	add a,a			;0ee5   ; 4 bytes por guion
	add a,a			;0ee6
	ld hl,012fah		;0ee7   ; los guiones
	rst 10h			;0eea
	ex de,hl			;0eeb   ; DE = el guion
	inc hl			;0eec
	ld a,007h		;0eed   ; la n del codigo de la ficha (+11)...
	rst 10h			;0eef
	ld (hl),000h		;0ef0   ; ...a cero
	dec hl			;0ef2   ; de +11 a +8
	dec hl			;0ef3
	dec hl			;0ef4
	ld (hl),d			;0ef5   ; el puntero al guion (+7, +8)
	dec hl			;0ef6
	ld (hl),e			;0ef7   ; el bajo (+7)
	jp L_0848		;0ef8   ; y a leer el primer byte
choque:		; El tren de la ficha HL (+6) choca: 3 cuadros de cuenta y el guion en su 0xFF; el blanco, ademas, la explosion
	xor a			;0efb   ; ya no esta encima de la pieza que se mueve
	ld (de),a			;0efc
choque_sigue:		; La cuenta y el guion
	ld (hl),001h		;0efd   ; un paso
	ld a,005h		;0eff   ; la n (+11)...
	rst 10h			;0f01
	ld (hl),003h		;0f02   ; ...en el 0xFF del guion
	ld a,l			;0f04   ; el tren blanco (0xE30B)?
	sub 00bh		;0f05
	ret nz			;0f07
	ld hl,0e005h		;0f08   ; ha chocado
	inc (hl)			;0f0b
	inc hl			;0f0c   ; el hueco del jugador...
	rst 30h			;0f0d
	rst 10h			;0f0e
	ld a,(0e036h)		;0f0f   ; ...se guarda
	ld (hl),a			;0f12
	ld l,040h		;0f13   ; acababa de salir de una estacion?...
	ld a,(hl)			;0f15
	or a			;0f16
	ret z			;0f17
	ld l,008h		;0f18   ; ...saldra otra vez desde su casilla
	rst 30h			;0f1a
	rst 10h			;0f1b
	ld (hl),001h		;0f1c
	ret			;0f1e
psg_inicial:		; Parejas registro-valor de 0x133A al PSG. Cada vuelta gasta 3 de B (las dos outi y el djnz): B = 0x0F son 5 parejas y 0x12 son 6
	ld hl,0133ah		;0f1f
	di			;0f22
pareja_psg:		; Una pareja
	ld c,0a0h		;0f23   ; el registro
	outi		;0f25   ; a 0xA0
	ld c,0a1h		;0f27   ; el valor
	outi		;0f29   ; a 0xA1
	djnz pareja_psg		;0f2b   ; la siguiente
	ei			;0f2d
	ld a,(0e260h)		;0f2e   ; en la demostracion...
	or a			;0f31
	ret z			;0f32
	di			;0f33   ; ...el mezclador, todo cerrado: sin sonido
	ld a,007h		;0f34   ; el registro 7...
	out (0a0h),a		;0f36
	ld a,0ffh		;0f38   ; ...0xFF
	out (0a1h),a		;0f3a
	ei			;0f3c
	ret			;0f3d
copia_en_vram:		; 0x0FFF bytes de la VRAM, de DE a HL (con el bit de escritura): copia hacia delante, asi que se repite cada 2 KB
	ld bc,l0fffh		;0f3e
byte_vram:		; Un byte
	di			;0f41   ; DE para leer
	rst 18h			;0f42   ; leer de DE
	inc de			;0f43   ; el byte siguiente
	in a,(098h)		;0f44   ; el byte
	ei			;0f46   ; un respiro para la interrupcion
	ex de,hl			;0f47   ; HL a DE
	push af			;0f48
	di			;0f49
	rst 18h			;0f4a   ; escribir en HL
	inc de			;0f4b   ; el byte siguiente
	pop af			;0f4c
	out (098h),a		;0f4d   ; se escribe
	ei			;0f4f
	ex de,hl			;0f50   ; y otra vez como estaban
	dec bc			;0f51   ; hasta que BC llega a cero
	ld a,b			;0f52   ; BC a cero?
	or c			;0f53
	jr nz,byte_vram		;0f54
	ret			;0f56
espera_b:		; Una espera: B x 256 vueltas
	ld c,000h		;0f57
espera_vuelta:
	dec c			;0f59
	jr nz,espera_vuelta		;0f5a
	djnz espera_b		;0f5c
	ret			;0f5e

; ----------------------------------------------------------------------
; EL MANDO, cada cuadro (desde la interrupcion): una direccion nueva empuja hacia el hueco la pieza del lado contrario. Hay que soltar entre empujon y empujon; las piezas del marco (menos de 0x0C) no se mueven.
; ----------------------------------------------------------------------
mando_empuja:		; El mando: un empujon, o el deslizamiento en curso
	ld hl,0e03ah		;0f5f   ; se esta deslizando una?
	ld a,(hl)			;0f62
	or a			;0f63
	jp nz,desliza		;0f64   ; si: el paso siguiente
	call lee_mando		;0f67   ; el mando
	ld c,a			;0f6a
	ld a,(0e0fch)		;0f6b   ; con el teclado...
	or a			;0f6e
	call z,cursores		;0f6f   ; ...los cursores
	ld a,(0e260h)		;0f72   ; en la demostracion...
	or a			;0f75
	jr z,mando_a_direccion		;0f76
	ld hl,0e262h		;0f78   ; ...su mando...
	ld c,(hl)			;0f7b
	ld a,0ffh		;0f7c   ; ...una vez
	ld (hl),a			;0f7e
mando_a_direccion:		; Los cuatro bits de direccion (a 1 lo pulsado) a la direccion del empujon (0x13D2): 0 nada, 1 arriba, 2 derecha, 3 abajo, 4 izquierda
	ld a,c			;0f7f   ; a 1 lo pulsado
	cpl			;0f80
	and 00fh		;0f81
	ld hl,013d2h		;0f83   ; la direccion
	rst 10h			;0f86
	ld a,(hl)			;0f87
	ld hl,0e03bh		;0f88   ; la de antes
	ld b,(hl)			;0f8b
	ld (hl),a			;0f8c   ; la nueva
	ld c,a			;0f8d
	xor a			;0f8e   ; habia una: hay que soltar antes
	cp b			;0f8f
	ret nz			;0f90
	cp c			;0f91   ; ninguna: nada
	ret z			;0f92
	dec hl			;0f93   ; cuatro pasos de 8 pixeles
	dec hl			;0f94
	ld (hl),004h		;0f95
	ld a,(0e036h)		;0f97   ; el hueco...
	call casilla_a_vram		;0f9a   ; ...en la VRAM
	ld (0e037h),hl		;0f9d
	ex de,hl			;0fa0
	ld a,(0e03bh)		;0fa1   ; el empujon
	add a,a			;0fa4
	ld c,a			;0fa5
	ld hl,0129dh		;0fa6   ; desde el hueco, donde esta la pieza que entra (0x129D)
	rst 10h			;0fa9
	ld a,c			;0faa
	ld c,(hl)			;0fab
	inc hl			;0fac
	ld b,(hl)			;0fad
	ex de,hl			;0fae   ; en la VRAM
	add hl,bc			;0faf
	ld (0e030h),hl		;0fb0
	ld hl,012a5h		;0fb3   ; cuanto se mueve en cada paso (0x12A5): una letra o una fila
	ld c,a			;0fb6
	rst 10h			;0fb7
	ld e,(hl)			;0fb8
	inc hl			;0fb9
	ld d,(hl)			;0fba
	ld (0e032h),de		;0fbb   ; 0xE032
	ld a,c			;0fbf   ; lo que se mueve el sprite de un tren encima (0x12AD)...
	ld hl,012adh		;0fc0
	rst 10h			;0fc3
	ld a,(hl)			;0fc4
	ld b,a			;0fc5   ; ...y su casilla al acabar
	neg		;0fc6
	ld (0e03dh),a		;0fc8
	inc hl			;0fcb
	ld a,(hl)			;0fcc   ; 8 pixeles por paso
	ld (0e03ch),a		;0fcd
	ld hl,0e036h		;0fd0   ; el hueco...
	ld a,(hl)			;0fd3
	add a,b			;0fd4   ; ...mas el desplazamiento: la casilla que entra
	dec hl			;0fd5
	ld (hl),a			;0fd6
	inc hl			;0fd7
	call pieza_de		;0fd8   ; su pieza (0xE034)
	cp 00ch		;0fdb   ; una del marco (menos de 0x0C): no se mueve
	ret c			;0fdd
	ld hl,0e03ah		;0fde   ; se mueve
	inc (hl)			;0fe1
	ld a,(0e3a1h)		;0fe2   ; el canal 1 calla?...
	or a			;0fe5
	jr nz,desliza		;0fe6
	ld bc,0194dh		;0fe8   ; ...el sonido del empujon (0x194D)
	ld (0e3a0h),bc		;0feb
desliza:		; Un paso: el hueco y el sitio de la pieza, en negro (0x16B7); la pieza, 8 pixeles mas alla; y los trenes que van encima, con ella
	ld hl,016b7h		;0fef   ; el hueco, en negro
	ld de,(0e037h)		;0ff2
	push hl			;0ff6
	call pinta_4x4		;0ff7
	pop hl			;0ffa
	ld de,(0e030h)		;0ffb   ; el sitio de la pieza...
L_0FFF:
	call pinta_4x4		;0fff   ; el sitio de la pieza, en negro tambien
	ld a,(0e039h)		;1002   ; los pasos que quedan...
	ld b,a			;1005
	ld a,005h		;1006   ; ...cuantos lleva
	sub b			;1008
	ld b,a			;1009
	ld hl,(0e030h)		;100a   ; desde su sitio...
	ld de,(0e032h)		;100d   ; ...un paso por cada uno
suma_paso:
	add hl,de			;1011
	djnz suma_paso		;1012
	ld a,(0e034h)		;1014   ; la pieza
	push hl			;1017
	call pinta_pieza		;1018   ; a la VRAM
	ld b,004h		;101b   ; las cuatro fichas
	ld hl,0e302h		;101d
tren_encima:		; Si el tren de la ficha esta en la pieza, se mueve con ella
	push bc			;1020
	call mueve_con_pieza		;1021
	ld a,020h		;1024   ; la ficha siguiente
	rst 10h			;1026
	pop bc			;1027
	djnz tren_encima		;1028
	ld hl,0e039h		;102a   ; un paso menos
	dec (hl)			;102d
	ret nz			;102e   ; aun no acaba
	xor a			;102f
	inc hl			;1030
	ld (hl),a			;1031   ; se acabo el deslizamiento
	ld hl,0e100h		;1032   ; el tablero del jugador...
	rst 30h			;1035
	jr z,L_103A		;1036
	ld l,030h		;1038
L_103A:
	push hl			;103a
	ld de,0e036h		;103b   ; ...el hueco...
	ld a,(de)			;103e
	rst 10h			;103f
	dec de			;1040
	dec de			;1041
	ld a,(de)			;1042   ; ...recibe la pieza
	ld (hl),a			;1043
	pop hl			;1044
	inc de			;1045
	ld a,(de)			;1046   ; la casilla de la que salio...
	ld (0e036h),a		;1047   ; ...es el hueco nuevo
	rst 10h			;104a
	ld (hl),00fh		;104b   ; la pieza 0x0F
	ret			;104d
mueve_con_pieza:		; El tren de la ficha HL (+2) va encima de la pieza que se desliza: su sprite, 8 pixeles; al acabar, su casilla es la nueva
	ld a,(0e035h)		;104e   ; la casilla de la pieza
	cp (hl)			;1051   ; no esta encima
	ret nz			;1052
	push hl			;1053
	ld h,0e0h		;1054
	ld a,l			;1056   ; la ficha (bits 5-6) x 4...
	rrca			;1057
	rrca			;1058
	rrca			;1059
	and 00ch		;105a
	or 080h		;105c   ; ...su sprite
	ld l,a			;105e
	rst 30h			;105f
	jr z,L_1065		;1060
	ld a,010h		;1062   ; el del jugador 2
	rst 10h			;1064
L_1065:
	ld a,(0e03bh)		;1065   ; arriba o abajo: la Y; a los lados, la X
	rra			;1068
	jr c,L_106C		;1069
	inc hl			;106b
L_106C:
	ld a,(0e03ch)		;106c   ; 8 pixeles
	add a,(hl)			;106f   ; 8 pixeles mas (o menos)
	ld (hl),a			;1070
	call sube_sprites		;1071   ; a la VRAM
	pop hl			;1074   ; la ficha
	ld a,l			;1075   ; el numero de la ficha...
	rlca			;1076   ; la ficha / 32: su numero
	rlca			;1077
	rlca			;1078
	and 003h		;1079
	ex de,hl			;107b
	ld hl,0e180h		;107c   ; ...encima de la pieza (0xE180)
	rst 10h			;107f
	inc (hl)			;1080   ; encima
	ex de,hl			;1081
	ld a,(0e039h)		;1082   ; el ultimo paso?
	dec a			;1085   ; el ultimo paso?
	ret nz			;1086
	xor a			;1087   ; ya no esta encima...
	ld (de),a			;1088   ; ya no esta encima
	ld a,(0e03dh)		;1089   ; ...y su casilla es la nueva
	add a,(hl)			;108c   ; la casilla, la de al lado
	ld (hl),a			;108d
	ret			;108e
cursores:		; La fila 8 del teclado (cursores) al formato del mando: bit 0 arriba, 1 abajo, 2 izquierda, 3 derecha
	ld a,008h		;108f   ; la fila 8
	call lee_fila		;1091
	rrca			;1094   ; arriba (bit 5)...
	rrca			;1095
	ld b,a			;1096
	rrca			;1097   ; abajo (bit 6)...
	rrca			;1098
	ld c,a			;1099
	rrca			;109a   ; la derecha (bit 7)...
	and 003h		;109b
	ld h,a			;109d
	ld a,c			;109e   ; la izquierda (bit 4)...
	and 008h		;109f
	or h			;10a1
	ld h,a			;10a2
	ld a,b			;10a3   ; la izquierda (bit 4)...
	and 004h		;10a4
	or h			;10a6
	ld c,a			;10a7   ; al formato del mando
	ret			;10a8
mira_disparo:		; El disparo (mando 1 o 2) o la barra o SELECT: acarreo si alguno, y en A la opcion del menu que repite lo de la vez anterior (1-2 con mando, 3-4 con teclado)
	xor a			;10a9   ; el teclado, de momento
	ld (0e0fch),a		;10aa
	ld a,007h		;10ad   ; la fila 7: SELECT
	di			;10af
	call lee_fila		;10b0
	ei			;10b3
	bit 6,a		;10b4
	jr z,con_teclado		;10b6   ; pulsado
	ld a,008h		;10b8   ; la fila 8: la barra
	di			;10ba
	call lee_fila		;10bb
	ei			;10be
	bit 0,a		;10bf
	jr z,con_teclado		;10c1   ; pulsada
	ld a,001h		;10c3   ; el mando
	ld (0e0fch),a		;10c5
	ld a,00fh		;10c8   ; el puerto del mando 2
	di			;10ca
	out (0a0h),a		;10cb
	ld a,0cfh		;10cd
	out (0a1h),a		;10cf
	call lee_mando		;10d1   ; el mando
	ei			;10d4
	and 030h		;10d5   ; los dos botones
	cp 030h		;10d7
	jr nz,con_mando		;10d9
	ld a,00fh		;10db   ; el puerto del mando 1
	di			;10dd
	out (0a0h),a		;10de
	ld a,08fh		;10e0
	out (0a1h),a		;10e2
	call lee_mando		;10e4
	ei			;10e7
	and 030h		;10e8
	cp 030h		;10ea
	ret z			;10ec   ; ninguno: sin acarreo
con_mando:		; Con el mando: la opcion 1 o 2 (los jugadores de antes)
	xor a			;10ed
	ld a,(0e000h)		;10ee
	inc a			;10f1
	jr opcion_tecla		;10f2
con_teclado:		; Con el teclado: la opcion 3 o 4
	xor a			;10f4
	ld a,(0e000h)		;10f5
	inc a			;10f8
	rlca			;10f9
	rlca			;10fa
opcion_tecla:		; La opcion como la leeria la fila 0: un bit a cero
	rlca			;10fb
	cpl			;10fc
	scf			;10fd   ; acarreo: algo pulsado
	ret			;10fe
espera:		; A tramos de 32 cuadros hasta que la interrupcion la baja a cero
	ld hl,0e1e0h		;10ff
	ld (hl),a			;1102
espera_vuelta32:
	ld a,(hl)			;1103
	or a			;1104
	jr nz,espera_vuelta32		;1105
	ret			;1107
lee_mando:		; El registro 14 del PSG: el mando del puerto elegido (a cero lo pulsado)
	ld a,00eh		;1108
	out (0a0h),a		;110a
	in a,(0a2h)		;110c
	ret			;110e
pinta_colores:		; Los colores de las letras: 24 letras de un color cada una (un byte) y 21 tiras de N bytes de un color (dos bytes), desde 0x0000
	ld de,04000h		;110f   ; la tabla de colores
	ld c,02dh		;1112   ; 45 tiras
tira_color:		; Una tira
	di			;1114
	rst 18h			;1115
	ld a,015h		;1116   ; las 24 primeras...
	cp c			;1118
	ld b,008h		;1119   ; ...son de 8 bytes
	jr c,L_111F		;111b
	ld b,(hl)			;111d   ; las demas, de N
	inc hl			;111e
L_111F:
	ld a,(hl)			;111f   ; el color
	inc hl			;1120
	push bc			;1121
	call rellena_vram_a		;1122   ; a la VRAM
	pop bc			;1125
	ei			;1126
	ld a,b			;1127   ; DE + N
	ex de,hl			;1128
	rst 10h			;1129
	ex de,hl			;112a
	dec c			;112b   ; la siguiente
	jr nz,tira_color		;112c
	ret			;112e
colores_tres_tercios:		; La tabla de colores (0x0000) se copia sobre si misma hasta 0x17FF: los tres tercios iguales
	ld de,00000h		;112f
	ld hl,04800h		;1132
	call copia_en_vram		;1135
	ret			;1138
lee_fila:		; Una fila del teclado (A) por el PPI
	or 0f0h		;1139
	out (0aah),a		;113b   ; la fila...
	out (0aah),a		;113d   ; ...otra vez, para dar tiempo
	in a,(0a9h)		;113f   ; las teclas
	ret			;1141
pinta_menu:		; La pantalla en blanco y los cinco bloques del menu (0x14B3)
	call borra_pantalla		;1142
	ld hl,014b3h		;1145
	ld b,005h		;1148
bloque_menu:
	push bc			;114a
	call pinta_textos		;114b
	pop bc			;114e
	djnz bloque_menu		;114f
	ret			;1151
calla_canales:		; Los canales de musica, sin nota
	ld (0e3a1h),a		;1152
	ld (0e3a4h),a		;1155
	ld (0e3a9h),a		;1158
	ld (0e3b1h),a		;115b
	ret			;115e

; ----------------------------------------------------------------------
; DATOS listas_de_estaciones: las casillas de las estaciones de cada tablero
;   (0x1167, 0x1173, 0x1183, 0x1193); las lee 0x09C5 y 0x0A54
;   0x115f..0x1167  (8 bytes)
DATA_listas_de_estaciones:
	defw 01167h,01173h,01183h,01193h	; 115f  -> DATA_estaciones_tablero1 DATA_estaciones_tablero2 DATA_estaciones_tablero3 DATA_estaciones_tablero4

; ----------------------------------------------------------------------
; DATOS estaciones_tablero1: 6 estaciones, dos casillas cada una (fila x 8 +
;   columna): la de arriba, dos a la derecha, la de abajo y dos a la izquierda
;   0x1167..0x1173  (12 bytes)
DATA_estaciones_tablero1:
	defb 003h,004h	; 1167
	defb 00eh,016h	; 1169
	defb 01eh,026h	; 116b
	defb 02dh,02ch	; 116d
	defb 022h,01ah	; 116f
	defb 012h,00ah	; 1171

; ----------------------------------------------------------------------
; DATOS estaciones_tablero2: 8 estaciones
;   0x1173..0x1183  (16 bytes)
DATA_estaciones_tablero2:
	defb 002h,003h	; 1173
	defb 004h,005h	; 1175
	defb 00eh,016h	; 1177
	defb 01eh,026h	; 1179
	defb 02dh,02ch	; 117b
	defb 02bh,02ah	; 117d
	defb 021h,019h	; 117f
	defb 011h,009h	; 1181

; ----------------------------------------------------------------------
; DATOS estaciones_tablero3: 8 estaciones
;   0x1183..0x1193  (16 bytes)
DATA_estaciones_tablero3:
	defb 002h,003h	; 1183
	defb 004h,005h	; 1185
	defb 00eh,016h	; 1187
	defb 01eh,026h	; 1189
	defb 02dh,02ch	; 118b
	defb 02bh,02ah	; 118d
	defb 020h,018h	; 118f
	defb 010h,008h	; 1191

; ----------------------------------------------------------------------
; DATOS estaciones_tablero4: 10 estaciones
;   0x1193..0x11a7  (20 bytes)
DATA_estaciones_tablero4:
	defb 001h,002h	; 1193
	defb 003h,004h	; 1195
	defb 005h,006h	; 1197
	defb 00fh,017h	; 1199
	defb 01fh,027h	; 119b
	defb 02eh,02dh	; 119d
	defb 02ch,02bh	; 119f
	defb 02ah,029h	; 11a1
	defb 020h,018h	; 11a3
	defb 010h,008h	; 11a5

; ----------------------------------------------------------------------
; DATOS cuantas_estaciones: 6, 8, 8 y 10: las que hay que visitar en cada
;   tablero (0x0341)
;   0x11a7..0x11ab  (4 bytes)
DATA_cuantas_estaciones:
	defb 006h,008h,008h,00ah	; 11a7

; ----------------------------------------------------------------------
; DATOS tablero1: 8 x 6 casillas: el interior de 3 x 4 piezas, el hueco en la
;   casilla 12 y el marco con sus estaciones; fuera, la 0x0F
;   0x11ab..0x11db  (48 bytes)
DATA_tablero1:
	defb 00fh,00fh,010h,000h,001h,008h,011h,00fh	; 11ab  ........
	defb 00fh,00fh,006h,00ch,00fh,00dh,002h,00fh	; 11b3  ........
	defb 00fh,00fh,007h,00eh,00dh,00ch,003h,00fh	; 11bb  ........
	defb 00fh,00fh,006h,00dh,00eh,00eh,002h,00fh	; 11c3  ........
	defb 00fh,00fh,007h,00ch,00eh,00dh,003h,00fh	; 11cb  ........
	defb 00fh,00fh,013h,00ah,004h,005h,012h,00fh	; 11d3  ........

; ----------------------------------------------------------------------
; DATOS tablero2: el interior de 4 x 4
;   0x11db..0x120b  (48 bytes)
DATA_tablero2:
	defb 00fh,010h,000h,001h,000h,001h,011h,00fh	; 11db  ........
	defb 00fh,006h,00eh,00ch,00fh,00dh,002h,00fh	; 11e3  ........
	defb 00fh,007h,00ch,00dh,00eh,00dh,003h,00fh	; 11eb  ........
	defb 00fh,006h,00dh,00eh,00eh,00ch,002h,00fh	; 11f3  ........
	defb 00fh,007h,00eh,00ch,00ch,00dh,003h,00fh	; 11fb  ........
	defb 00fh,013h,004h,005h,004h,005h,012h,00fh	; 1203  ........

; ----------------------------------------------------------------------
; DATOS tablero3: el interior de 5 x 4, con una recta (0x14) en la casilla 19
;   0x120b..0x123b  (48 bytes)
DATA_tablero3:
	defb 010h,008h,000h,001h,000h,001h,011h,00fh	; 120b  ........
	defb 006h,00ch,00eh,00dh,00fh,00ch,002h,00fh	; 1213  ........
	defb 007h,00dh,014h,00ch,00eh,00dh,003h,00fh	; 121b  ........
	defb 006h,00eh,00ch,00dh,00eh,00ch,002h,00fh	; 1223  ........
	defb 007h,00dh,00eh,00ch,00eh,00dh,003h,00fh	; 122b  ........
	defb 013h,00ah,004h,005h,004h,005h,012h,00fh	; 1233  ........

; ----------------------------------------------------------------------
; DATOS tablero4: el interior de 6 x 4 y el marco entero; el interior no se ve
;   nunca: desde la fase 4 lo revuelve siempre 0x0B5A
;   0x123b..0x126b  (48 bytes)
DATA_tablero4:
	defb 010h,000h,001h,000h,001h,000h,001h,011h	; 123b  ........
	defb 006h,00ch,00ch,00dh,00fh,00ch,00dh,002h	; 1243  ........
	defb 007h,00eh,00dh,00ch,00eh,00dh,00eh,003h	; 124b  ........
	defb 006h,00ch,00eh,00eh,00eh,00ch,00eh,002h	; 1253  ........
	defb 007h,00dh,00ch,00dh,00ch,00eh,00ch,003h	; 125b  ........
	defb 013h,004h,005h,004h,005h,004h,005h,012h	; 1263  ........

; ----------------------------------------------------------------------
; DATOS tira_revuelta: 18 piezas (0x0C, 0x0D, 0x0E) y un cero: el interior del
;   cuarto tablero sale de aqui, desde un sitio que depende de la fase
;   (0x0B5A)
;   0x126b..0x127e  (19 bytes)
DATA_tira_revuelta:
	defb 00ch,00dh,00eh,00ch,00ch,00dh,00dh,00eh,00dh,00ch,00eh,00ch,00dh,00eh,00dh,00dh	; 126b  ................
	defb 00ch,00ch,000h	; 127b

; ----------------------------------------------------------------------
; DATOS sitios_de_rectas: las casillas que pasan a ser rectas en los tableros
;   revueltos, de 6 a 8 desde un sitio que depende de la fase (0x0BC0)
;   0x127e..0x1293  (21 bytes)
DATA_sitios_de_rectas:
	defb 00dh,01ah,00ah,00bh,022h,01eh,026h,011h,019h,015h,00eh,009h,021h,023h,024h,025h	; 127e  ....".&.....!#$%
	defb 012h,016h,013h,01bh,01dh	; 128e

; ----------------------------------------------------------------------
; DATOS paso_por_direccion: lo que cambia la casilla en cada direccion: -8
;   arriba, +1 derecha, +8 abajo, -1 izquierda (0x0DCA)
;   0x1293..0x1297  (4 bytes)
DATA_paso_por_direccion:
	defb 0f8h,001h,008h,0ffh	; 1293

; ----------------------------------------------------------------------
; DATOS cifras_por_lado: la cuenta del tren negro: donde va su primera cifra
;   respecto a la estacion y el paso entre cifras (1 en fila, 32 en columna),
;   por lado (0x0D66)
;   0x1297..0x129f  (8 bytes)
DATA_cifras_por_lado:
	defb 03eh,001h	; 1297
	defb 0c1h,020h	; 1299
	defb 022h,001h	; 129b
	defb 042h,020h	; 129d

; ----------------------------------------------------------------------
; DATOS empujon_desde: para cada empujon (1 arriba, 2 derecha, 3 abajo, 4
;   izquierda), donde esta la pieza que entra respecto al hueco en la tabla de
;   nombres: +128, -4, -128, +4 (0x0FA6; la entrada 0 no se usa y cae en la
;   tabla anterior)
;   0x129f..0x12a7  (8 bytes)
DATA_empujon_desde:
	defw 00080h,0fffch,0ff80h,00004h	; 129f

; ----------------------------------------------------------------------
; DATOS empujon_paso: cuanto se mueve la pieza en cada uno de sus cuatro
;   pasos: una fila arriba, una letra a la derecha, una fila abajo, una letra
;   a la izquierda (0x0FB3)
;   0x12a7..0x12af  (8 bytes)
DATA_empujon_paso:
	defw 0ffe0h,00001h,00020h,0ffffh	; 12a7  -> 0xffe0 0x0001 rst_copia_vram 0xffff

; ----------------------------------------------------------------------
; DATOS empujon_trenes: por empujon: lo que cambia la casilla de un tren que
;   va encima de la pieza y lo que se mueve su sprite en cada paso (8 pixeles)
;   (0x0FBF)
;   0x12af..0x12b7  (8 bytes)
DATA_empujon_trenes:
	defb 008h,0f8h	; 12af
	defb 0ffh,008h	; 12b1
	defb 0f8h,008h	; 12b3
	defb 001h,0f8h	; 12b5

; ----------------------------------------------------------------------
; DATOS plantilla_de_ficha: los 32 bytes de la ficha de un tren (0x0CFE); sus
;   9 ultimos son los 9 primeros de la tabla de salidas. +1 la pieza, +2 la
;   casilla, +3 la direccion, +4 el numero, +5 la direccion del sprite, +6 la
;   cuenta, +7/+8 el guion (0x12FA) y desde +9 el codigo que lee el guion: ld
;   b,(ix+n) / inc hl / inc hl / inc (hl) / ld a,l / sub 5 / ld l,a / ld a,b /
;   jp 0x0850. El tren blanco sale de la casilla 28, sobre un cruce, hacia
;   arriba
;   0x12b7..0x12ce  (23 bytes)
DATA_plantilla_de_ficha:
	defb 000h	; 12b7
	defb 00eh	; 12b8
	defb 01ch	; 12b9
	defb 000h	; 12ba
	defb 000h	; 12bb
	defb 000h	; 12bc
	defb 001h	; 12bd
	defb 0fah,012h	; 12be
	defb 0ddh,046h,000h	; 12c0
	defb 023h	; 12c3
	defb 023h	; 12c4
	defb 034h	; 12c5
	defb 07dh	; 12c6
	defb 0d6h,005h	; 12c7
	defb 06fh	; 12c9
	defb 078h	; 12ca
	defb 0c3h,050h,008h	; 12cb

; ----------------------------------------------------------------------
; DATOS salidas: por pieza (sin via, 0x0C, 0x0D, el cruce y la recta) y por el
;   lado por el que entra el tren, un byte: la direccion en la que sale
;   (nibble alto) y su guion (bajo); los guiones 12-15 son los callejones
;   (0x0E53)
;   0x12ce..0x12e2  (20 bytes)
DATA_salidas:
	defb 00ch,01dh,02eh,03fh	; 12ce
	defb 034h,02ah,01bh,005h	; 12d2
	defb 016h,007h,039h,028h	; 12d6
	defb 021h,033h,000h,012h	; 12da
	defb 00ch,033h,02eh,012h	; 12de

; ----------------------------------------------------------------------
; DATOS estaciones_como_piezas: las piezas de estacion 0-7, para la via, son
;   la 0x0C o la 0x0D (0x0E38)
;   0x12e2..0x12ea  (8 bytes)
DATA_estaciones_como_piezas:
	defb 00ch,00dh,00dh,00ch,00dh,00ch,00ch,00dh	; 12e2  ........

; ----------------------------------------------------------------------
; DATOS sprites_de_salida: los cuatro sprites al empezar: el tren blanco en Y
;   0x7F, X 0x88, patron 0, blanco; los otros tres, fuera (Y 0xD1), patron
;   0x20 y negros (0x0CBE)
;   0x12ea..0x12fa  (16 bytes)
DATA_sprites_de_salida:
	defb 07fh,088h,000h,00fh	; 12ea
	defb 0d1h,0ffh,020h,001h	; 12ee
	defb 0d1h,0ffh,020h,001h	; 12f2
	defb 0d1h,0ffh,020h,001h	; 12f6

; ----------------------------------------------------------------------
; DATOS guiones: los 16 guiones de 4 bytes ("veces x 16 + direccion del
;   sprite", 0xFF el final): 0-3 las rectas (32 pixeles), 4-11 las curvas (5 +
;   11 diagonales + 5), 12-15 los callejones (0x10)
;   0x12fa..0x133a  (64 bytes)
DATA_guiones:
	defb 000h,0ffh,0ffh,0ffh	; 12fa
	defb 001h,0ffh,0ffh,0ffh	; 12fe
	defb 002h,0ffh,0ffh,0ffh	; 1302
	defb 003h,0ffh,0ffh,0ffh	; 1306
	defb 051h,0b5h,053h,0ffh	; 130a
	defb 052h,0b4h,050h,0ffh	; 130e
	defb 061h,0a6h,062h,0ffh	; 1312
	defb 063h,0a7h,060h,0ffh	; 1316
	defb 062h,0a6h,061h,0ffh	; 131a
	defb 060h,0a7h,063h,0ffh	; 131e
	defb 073h,095h,071h,0ffh	; 1322
	defb 070h,094h,072h,0ffh	; 1326
	defb 010h,000h,0ffh,0ffh	; 132a
	defb 010h,001h,0ffh,0ffh	; 132e
	defb 010h,002h,0ffh,0ffh	; 1332
	defb 010h,003h,0ffh,0ffh	; 1336

; ----------------------------------------------------------------------
; DATOS parejas_psg: registro y valor: el mezclador, el ruido, los tres
;   volumenes a cero y el mezclador con el ruido; 0x0F1F manda 5 o 6
;   0x133a..0x1346  (12 bytes)
DATA_parejas_psg:
	defb 007h,0b8h	; 133a
	defb 006h,01eh	; 133c
	defb 008h,000h	; 133e
	defb 009h,000h	; 1340
	defb 00ah,000h	; 1342
	defb 007h,088h	; 1344

; ----------------------------------------------------------------------
; DATOS registros_vdp: los ocho registros: SCREEN 2, sprites de 16 x 16,
;   nombres en 0x3800, colores en 0x0000, patrones en 0x2000, atributos en
;   0x3B00, patrones de sprites en 0x1800 y el fondo negro (0x0192)
;   0x1346..0x134e  (8 bytes)
DATA_registros_vdp:
	defb 002h,0e2h,00eh,07fh,007h,076h,003h,0e1h	; 1346  .....v..

; ----------------------------------------------------------------------
; DATOS colores_con_piezas: los colores de las letras (0x110F): 24 letras de
;   un color cada una y 21 tiras de "cuantos bytes, color"
;   0x134e..0x1390  (66 bytes)
DATA_colores_con_piezas:
	defb 040h,042h,048h,04fh,045h,04dh,04ah,04ch,043h,045h,04dh,04ah,04ch,043h,045h,04dh,04ah,04ch,043h,045h,04dh,04ah,04ch,043h	; 134e  @BHOEMJLCEMJLCEMJLCEMJLC
	defb 040h,0ach	; 1366
	defb 050h,045h	; 1368
	defb 050h,04ah	; 136a
	defb 060h,04dh	; 136c
	defb 0a0h,04ch	; 136e
	defb 080h,04ch	; 1370
	defb 008h,0f0h	; 1372
	defb 008h,01bh	; 1374
	defb 090h,050h	; 1376
	defb 040h,020h	; 1378
	defb 008h,024h	; 137a
	defb 028h,02fh	; 137c
	defb 010h,04fh	; 137e
	defb 008h,070h	; 1380
	defb 010h,0f0h	; 1382
	defb 0b8h,070h	; 1384
	defb 0b8h,0a0h	; 1386
	defb 0b8h,0d0h	; 1388
	defb 0b8h,0f0h	; 138a
	defb 090h,0f0h	; 138c
	defb 020h,0adh	; 138e

; ----------------------------------------------------------------------
; DATOS colores_sin_piezas: los mismos, salvo el fondo de las piezas: lo que
;   se pone a los 32 segundos de fase (0x048D)
;   0x1390..0x13d2  (66 bytes)
DATA_colores_sin_piezas:
	defb 040h,040h,048h,04fh,040h,040h,040h,040h,040h,040h,040h,040h,040h,040h,040h,040h,040h,040h,040h,040h,040h,040h,040h,040h	; 1390  @@HO@@@@@@@@@@@@@@@@@@@@
	defb 040h,0a0h	; 13a8
	defb 050h,040h	; 13aa
	defb 050h,040h	; 13ac
	defb 060h,040h	; 13ae
	defb 0a0h,040h	; 13b0
	defb 080h,040h	; 13b2
	defb 008h,0f0h	; 13b4
	defb 008h,01bh	; 13b6
	defb 090h,050h	; 13b8
	defb 040h,020h	; 13ba
	defb 008h,024h	; 13bc
	defb 028h,02fh	; 13be
	defb 010h,04fh	; 13c0
	defb 008h,070h	; 13c2
	defb 010h,0f0h	; 13c4
	defb 0b8h,070h	; 13c6
	defb 0b8h,0a0h	; 13c8
	defb 0b8h,0d0h	; 13ca
	defb 0b8h,0f0h	; 13cc
	defb 090h,0f0h	; 13ce
	defb 020h,0a0h	; 13d0

; ----------------------------------------------------------------------
; DATOS mando_a_empujon: los cuatro bits de direccion del mando (a 1 lo
;   pulsado) al empujon: 0 nada, 1 arriba, 2 derecha, 3 abajo, 4 izquierda
;   (0x0F83)
;   0x13d2..0x13e2  (16 bytes)
DATA_mando_a_empujon:
	defb 000h,001h,003h,000h,004h,001h,004h,000h,002h,001h,002h,000h,000h,000h,000h,000h	; 13d2  ................

; ----------------------------------------------------------------------
; DATOS mando_de_la_demostracion: un movimiento del mando por cada casilla que
;   entra el tren blanco (a 0 lo pulsado: 0xFE arriba, 0xFD abajo, 0xFB
;   izquierda, 0xF7 derecha) (0x0E6F)
;   0x13e2..0x13f2  (16 bytes)
DATA_mando_de_la_demostracion:
	defb 0feh,0fdh,0f7h,0fbh,0fbh,0feh,0f7h,0f7h,0feh,0fbh,0feh,0fdh,0f7h,0fbh,0fbh,0fdh	; 13e2  ................

; ----------------------------------------------------------------------
; DATOS texto_titulo: SONY, el logotipo de HIT BIT, CRAZY TRAIN y (c) Konami
;   1983 (los bloques de 0x0792)
;   0x13f2..0x14b3  (193 bytes)
DATA_texto_titulo:
	defb 078h,04bh,066h,067h,068h,069h,06ah,06bh,06ch,06dh,06eh,06fh,0ffh,078h,06bh,070h	; 13f2  xKfghijklmno.xkp
	defb 071h,072h,073h,074h,075h,076h,000h,077h,0ffh,078h,0e6h,001h,078h,001h,000h,002h	; 1402  qrstuv.w.x..x...
	defb 000h,001h,001h,001h,000h,000h,000h,001h,001h,07bh,000h,002h,000h,001h,001h,001h	; 1412  .........{......
	defb 0ffh,079h,006h,001h,07fh,001h,000h,001h,000h,000h,07eh,0feh,004h,000h,07ah,079h	; 1422  .y........~...zy
	defb 07ch,000h,001h,000h,000h,07eh,0ffh,079h,026h,001h,001h,001h,000h,001h,000h,000h	; 1432  |....~.y&.......
	defb 001h,0feh,004h,000h,001h,001h,07dh,000h,001h,000h,000h,001h,0ffh,079h,044h,089h	; 1442  ......}......yD.
	defb 003h,001h,085h,001h,003h,001h,003h,003h,001h,0feh,004h,003h,084h,083h,082h,003h	; 1452  ................
	defb 001h,003h,003h,001h,003h,08ah,0ffh,079h,063h,089h,003h,003h,001h,080h,001h,086h	; 1462  .......yc.......
	defb 001h,086h,003h,001h,086h,003h,003h,087h,001h,001h,081h,087h,001h,003h,087h,001h	; 1472  ................
	defb 003h,003h,08ah,0ffh,079h,082h,089h,0feh,01ah,003h,08ah,0ffh,079h,0a2h,0feh,01ch	; 1482  ....y.......y...
	defb 088h,0ffh,07ah,02ah,0ddh,0d5h,0d2h,0ech,0d3h,000h,0dbh,0d5h,0d2h,0dch,0edh,0ffh	; 1492  ..z*............
	defb 07ah,089h,0f3h,000h,0f4h,0f5h,0f6h,0f7h,0f8h,000h,000h,0e3h,0ebh,0eah,0e5h,0ffh	; 14a2  z...............
	defb 0ffh	; 14b2

; ----------------------------------------------------------------------
; DATOS texto_menu: CRAZY TRAIN, (c) Konami 1983 y HIGH-SCORE
;   0x14b3..0x14df  (44 bytes)
DATA_texto_menu:
	defb 078h,08bh,0ddh,0d5h,0d2h,0ech,0d3h,000h,0dbh,0d5h,0d2h,0dch,0edh,0ffh,078h,0cah	; 14b3  x.............x.
	defb 0f3h,000h,0f4h,0f5h,0f6h,0f7h,0f8h,000h,000h,0e3h,0ebh,0eah,0e5h,0ffh,079h,029h	; 14c3  ..............y)
	defb 0eeh,0dch,0efh,0eeh,0f2h,0d6h,0ddh,0dah,0d5h,0d4h,0ffh,0ffh	; 14d3  ............

; ----------------------------------------------------------------------
; DATOS texto_opcion1: "1" KEY 1 PLAYER  W/ JOYSTICK
;   0x14df..0x1500  (33 bytes)
DATA_texto_opcion1:
	defb 079h,0a2h,09ch,09eh,09ch,000h,099h,08fh,08eh,000h,09eh,000h,08bh,08ch,08dh,08eh	; 14df  y...............
	defb 08fh,090h,000h,000h,092h,093h,000h,094h,095h,08eh,091h,096h,097h,098h,099h,0ffh	; 14ef  ................
	defb 0ffh	; 14ff

; ----------------------------------------------------------------------
; DATOS texto_opcion2: "2" KEY 2 PLAYERS W/ JOYSTICK
;   0x1500..0x1521  (33 bytes)
DATA_texto_opcion2:
	defb 079h,0e2h,09ch,09fh,09ch,000h,099h,08fh,08eh,000h,09fh,000h,08bh,08ch,08dh,08eh	; 1500  y...............
	defb 08fh,090h,091h,000h,092h,093h,000h,094h,095h,08eh,091h,096h,097h,098h,099h,0ffh	; 1510  ................
	defb 0ffh	; 1520

; ----------------------------------------------------------------------
; DATOS texto_opcion3: "3" KEY 1 PLAYER  W/ KEYBOARD
;   0x1521..0x1542  (33 bytes)
DATA_texto_opcion3:
	defb 07ah,042h,0b3h,0b7h,0b3h,000h,0b0h,0a6h,0a5h,000h,0b5h,000h,0a2h,0a3h,0a4h,0a5h	; 1521  zB..............
	defb 0a6h,0a7h,000h,000h,0a9h,0aah,000h,0b0h,0a6h,0a5h,0b1h,0ach,0a4h,0a7h,0b2h,0ffh	; 1531  ................
	defb 0ffh	; 1541

; ----------------------------------------------------------------------
; DATOS texto_opcion4: "4" KEY 2 PLAYERS W/ KEYBOARD
;   0x1542..0x1563  (33 bytes)
DATA_texto_opcion4:
	defb 07ah,082h,0b3h,0b8h,0b3h,000h,0b0h,0a6h,0a5h,000h,0b6h,000h,0a2h,0a3h,0a4h,0a5h	; 1542  z...............
	defb 0a6h,0a7h,0a8h,000h,0a9h,0aah,000h,0b0h,0a6h,0a5h,0b1h,0ach,0a4h,0a7h,0b2h,0ffh	; 1552  ................
	defb 0ffh	; 1562

; ----------------------------------------------------------------------
; DATOS texto_cabecera: 1P-00000 2P-00000 HIGH-00000; 0x07C5 toma de aqui los
;   rotulos 1P- (0x1565) y 2P- (0x156E)
;   0x1563..0x1583  (32 bytes)
DATA_texto_cabecera:
	defb 078h,002h,0e3h,0d0h,0f2h,0e2h,0e2h,0e2h,0e2h,0e2h,000h,0e4h,0d0h,0f2h,0e2h,0e2h	; 1563  x...............
	defb 0e2h,0e2h,0e2h,000h,0eeh,0dch,0efh,0eeh,0f2h,0e2h,0e2h,0e2h,0e2h,0e2h,0ffh,0ffh	; 1573  ................

; ----------------------------------------------------------------------
; DATOS texto_game_over: GAME OVER entre dos filas en blanco
;   0x1583..0x15a0  (29 bytes)
DATA_texto_game_over:
	defb 079h,04ah,0feh,00dh,000h,0ffh,079h,06ah,000h,000h,0efh,0d2h,0f0h,0d4h,000h,0dah	; 1583  yJ....yj........
	defb 0f1h,0d4h,0d5h,000h,000h,0ffh,079h,08ah,0feh,00dh,000h,0ffh,0ffh	; 1593  ......y......

; ----------------------------------------------------------------------
; DATOS texto_player1: PLAYER 1
;   0x15a0..0x15b2  (18 bytes)
DATA_texto_player1:
	defb 079h,029h,000h,000h,000h,0d0h,0d1h,0d2h,0d3h,0d4h,0d5h,000h,0e3h,0feh,006h,000h	; 15a0  y)..............
	defb 0ffh,0ffh	; 15b0

; ----------------------------------------------------------------------
; DATOS texto_player2: PLAYER 2
;   0x15b2..0x15be  (12 bytes)
DATA_texto_player2:
	defb 079h,02ch,0d0h,0d1h,0d2h,0d3h,0d4h,0d5h,000h,0e4h,0ffh,0ffh	; 15b2  y,..........

; ----------------------------------------------------------------------
; DATOS texto_stage: STAGE
;   0x15be..0x15c7  (9 bytes)
DATA_texto_stage:
	defb 078h,034h,0d6h,0dbh,0d2h,0efh,0d4h,0ffh,0ffh	; 15be  x4.......

; ----------------------------------------------------------------------
; DATOS piezas: las 21 piezas (0x00-0x14), cada una 4 x 4 letras (0x0A7D)
;   0x15c7..0x1717  (336 bytes)
DATA_piezas:
	defb 000h,000h,000h,000h	; 15c7
	defb 060h,061h,061h,061h	; 15cb
	defb 016h,007h,040h,041h	; 15cf
	defb 011h,042h,043h,065h	; 15d3
	defb 000h,000h,000h,000h	; 15d7
	defb 061h,061h,061h,061h	; 15db
	defb 044h,045h,007h,007h	; 15df
	defb 065h,046h,047h,00ch	; 15e3
	defb 016h,007h,062h,000h	; 15e7
	defb 048h,007h,062h,000h	; 15eb
	defb 049h,04ah,062h,000h	; 15ef
	defb 065h,04bh,062h,000h	; 15f3
	defb 065h,04ch,062h,000h	; 15f7
	defb 04dh,04eh,062h,000h	; 15fb
	defb 04fh,007h,062h,000h	; 15ff
	defb 011h,00ch,063h,000h	; 1603
	defb 060h,050h,051h,065h	; 1607
	defb 016h,007h,052h,053h	; 160b
	defb 011h,00ch,00ch,00ch	; 160f
	defb 000h,000h,000h,000h	; 1613
	defb 065h,054h,055h,061h	; 1617
	defb 056h,057h,007h,007h	; 161b
	defb 00ch,00ch,00ch,00ch	; 161f
	defb 000h,000h,000h,000h	; 1623
	defb 000h,016h,007h,062h	; 1627
	defb 000h,016h,007h,058h	; 162b
	defb 000h,016h,059h,05ah	; 162f
	defb 000h,016h,05bh,065h	; 1633
	defb 000h,016h,05ch,065h	; 1637
	defb 000h,016h,05dh,05eh	; 163b
	defb 000h,016h,007h,05fh	; 163f
	defb 000h,011h,00ch,063h	; 1643
	defb 000h,000h,000h,000h	; 1647
	defb 060h,061h,061h,061h	; 164b
	defb 016h,007h,007h,007h	; 164f
	defb 011h,018h,019h,00ch	; 1653
	defb 016h,007h,062h,000h	; 1657
	defb 01ah,007h,062h,000h	; 165b
	defb 01bh,007h,062h,000h	; 165f
	defb 011h,00ch,063h,000h	; 1663
	defb 060h,01ch,01dh,061h	; 1667
	defb 016h,007h,007h,007h	; 166b
	defb 011h,00ch,00ch,00ch	; 166f
	defb 000h,000h,000h,000h	; 1673
	defb 000h,016h,007h,062h	; 1677
	defb 000h,016h,007h,01eh	; 167b
	defb 000h,016h,007h,01fh	; 167f
	defb 000h,011h,00ch,063h	; 1683
	defb 015h,02ah,02bh,006h	; 1687
	defb 02ch,02dh,006h,02eh	; 168b
	defb 02fh,006h,030h,031h	; 168f
	defb 010h,032h,033h,00bh	; 1693
	defb 013h,020h,021h,004h	; 1697
	defb 022h,004h,023h,024h	; 169b
	defb 025h,026h,004h,027h	; 169f
	defb 00eh,028h,029h,009h	; 16a3
	defb 014h,034h,035h,005h	; 16a7
	defb 036h,037h,038h,039h	; 16ab
	defb 03ah,03bh,03ch,03dh	; 16af
	defb 00fh,03eh,03fh,00ah	; 16b3
	defb 000h,000h,000h,000h	; 16b7
	defb 000h,000h,000h,000h	; 16bb
	defb 000h,000h,000h,000h	; 16bf
	defb 000h,000h,000h,000h	; 16c3
	defb 000h,000h,000h,000h	; 16c7
	defb 000h,008h,008h,008h	; 16cb
	defb 000h,008h,008h,008h	; 16cf
	defb 000h,00dh,00dh,00dh	; 16d3
	defb 000h,000h,000h,000h	; 16d7
	defb 017h,008h,008h,000h	; 16db
	defb 017h,008h,008h,000h	; 16df
	defb 012h,00dh,00dh,000h	; 16e3
	defb 017h,008h,008h,000h	; 16e7
	defb 017h,008h,008h,000h	; 16eb
	defb 017h,008h,008h,000h	; 16ef
	defb 000h,000h,000h,000h	; 16f3
	defb 000h,008h,008h,008h	; 16f7
	defb 000h,008h,008h,008h	; 16fb
	defb 000h,008h,008h,008h	; 16ff
	defb 000h,000h,000h,000h	; 1703
	defb 014h,0f9h,0fah,005h	; 1707
	defb 036h,039h,039h,039h	; 170b
	defb 03ah,03dh,03dh,03dh	; 170f
	defb 00fh,0fbh,0fch,00ah	; 1713

; ----------------------------------------------------------------------
; DATOS musica_salida_1: la musica de salida, canal 1: 17 notas (tres bytes:
;   tono, tono alto con la duracion, volumen; 0xFF el final)
;   0x1717..0x174b  (52 bytes)
DATA_musica_salida_1:
	defb 09fh,040h,00ch	; 1717
	defb 000h,020h,000h	; 171a
	defb 0d4h,020h,00ch	; 171d
	defb 09fh,020h,00ch	; 1720
	defb 000h,010h,00ch	; 1723
	defb 0d4h,010h,00ch	; 1726
	defb 09fh,020h,00ch	; 1729
	defb 000h,010h,000h	; 172c
	defb 08eh,010h,00ch	; 172f
	defb 07eh,080h,00ch	; 1732
	defb 09fh,080h,00ch	; 1735
	defb 0efh,040h,00ch	; 1738
	defb 000h,020h,000h	; 173b
	defb 0efh,020h,00ch	; 173e
	defb 09fh,040h,00ch	; 1741
	defb 08eh,040h,00ch	; 1744
	defb 07eh,0f0h,00ch	; 1747
	defb 0ffh	; 174a

; ----------------------------------------------------------------------
; DATOS musica_salida_2: canal 2: 32 notas
;   0x174b..0x17ac  (97 bytes)
DATA_musica_salida_2:
	defb 000h,020h,000h	; 174b
	defb 0fdh,020h,00ch	; 174e
	defb 000h,020h,00ch	; 1751
	defb 0fdh,020h,00ch	; 1754
	defb 000h,020h,00ch	; 1757
	defb 0fdh,020h,00ch	; 175a
	defb 000h,020h,00ch	; 175d
	defb 0fdh,020h,00ch	; 1760
	defb 000h,020h,000h	; 1763
	defb 0fdh,020h,00ch	; 1766
	defb 000h,020h,00ch	; 1769
	defb 0fdh,020h,00ch	; 176c
	defb 000h,020h,00ch	; 176f
	defb 0fdh,020h,00ch	; 1772
	defb 000h,020h,00ch	; 1775
	defb 0fdh,020h,00ch	; 1778
	defb 000h,020h,000h	; 177b
	defb 0efh,020h,00ch	; 177e
	defb 000h,020h,00ch	; 1781
	defb 0efh,020h,00ch	; 1784
	defb 000h,020h,00ch	; 1787
	defb 0efh,020h,00ch	; 178a
	defb 000h,020h,00ch	; 178d
	defb 0efh,020h,00ch	; 1790
	defb 000h,020h,00ch	; 1793
	defb 0fdh,020h,00ch	; 1796
	defb 000h,020h,00ch	; 1799
	defb 0fdh,020h,00ch	; 179c
	defb 000h,020h,00ch	; 179f
	defb 0fdh,020h,00ch	; 17a2
	defb 000h,020h,00ch	; 17a5
	defb 0fdh,020h,00ch	; 17a8
	defb 0ffh	; 17ab

; ----------------------------------------------------------------------
; DATOS musica_salida_3: canal 3: 12 notas
;   0x17ac..0x17d1  (37 bytes)
DATA_musica_salida_3:
	defb 07dh,042h,00ch	; 17ac
	defb 052h,043h,00ch	; 17af
	defb 07dh,042h,00ch	; 17b2
	defb 052h,043h,00ch	; 17b5
	defb 07dh,042h,00ch	; 17b8
	defb 052h,043h,00ch	; 17bb
	defb 07dh,042h,00ch	; 17be
	defb 0f9h,041h,00ch	; 17c1
	defb 0ddh,041h,00ch	; 17c4
	defb 07dh,042h,00ch	; 17c7
	defb 0ddh,041h,00ch	; 17ca
	defb 0ddh,041h,00ch	; 17cd
	defb 0ffh	; 17d0

; ----------------------------------------------------------------------
; DATOS musica_fase_1: la de la fase superada, canal 1: 16 notas
;   0x17d1..0x1802  (49 bytes)
DATA_musica_fase_1:
	defb 059h,020h,00ch	; 17d1
	defb 059h,020h,00ch	; 17d4
	defb 059h,010h,00ch	; 17d7
	defb 054h,020h,00ch	; 17da
	defb 054h,010h,00ch	; 17dd
	defb 054h,010h,00ch	; 17e0
	defb 059h,040h,00ch	; 17e3
	defb 064h,040h,00ch	; 17e6
	defb 071h,020h,00ch	; 17e9
	defb 071h,010h,00ch	; 17ec
	defb 071h,010h,00ch	; 17ef
	defb 071h,010h,00ch	; 17f2
	defb 059h,010h,00ch	; 17f5
	defb 071h,010h,00ch	; 17f8
	defb 059h,010h,00ch	; 17fb
	defb 071h,040h,00ch	; 17fe
	defb 0ffh	; 1801

; ----------------------------------------------------------------------
; DATOS musica_fase_2: canal 2: 16 notas
;   0x1802..0x1833  (49 bytes)
DATA_musica_fase_2:
	defb 04bh,020h,00ch	; 1802
	defb 04bh,010h,00ch	; 1805
	defb 04bh,010h,00ch	; 1808
	defb 043h,020h,00ch	; 180b
	defb 043h,010h,00ch	; 180e
	defb 043h,010h,00ch	; 1811
	defb 04bh,040h,00ch	; 1814
	defb 054h,040h,00ch	; 1817
	defb 059h,020h,00ch	; 181a
	defb 059h,010h,00ch	; 181d
	defb 059h,010h,00ch	; 1820
	defb 059h,010h,00ch	; 1823
	defb 04bh,010h,00ch	; 1826
	defb 059h,010h,00ch	; 1829
	defb 04bh,010h,00ch	; 182c
	defb 059h,040h,00ch	; 182f
	defb 0ffh	; 1832

; ----------------------------------------------------------------------
; DATOS musica_fase_3: canal 3: 7 notas
;   0x1833..0x1849  (22 bytes)
DATA_musica_fase_3:
	defb 065h,041h,00ch	; 1833
	defb 051h,041h,00ch	; 1836
	defb 065h,041h,00ch	; 1839
	defb 0c2h,041h,00ch	; 183c
	defb 065h,041h,00ch	; 183f
	defb 065h,041h,00ch	; 1842
	defb 065h,041h,00ch	; 1845
	defb 0ffh	; 1848

; ----------------------------------------------------------------------
; DATOS campanilla: canal 1: 26 notas, al arrancar la fase y al visitar cada
;   estacion
;   0x1849..0x1899  (80 bytes)
DATA_campanilla:
	defb 001h,092h,010h	; 1849
	defb 000h,08eh,010h	; 184c
	defb 000h,090h,010h	; 184f
	defb 00dh,08ch,010h	; 1852
	defb 00dh,08eh,010h	; 1855
	defb 00dh,08ah,010h	; 1858
	defb 00dh,08ch,010h	; 185b
	defb 00dh,08ah,010h	; 185e
	defb 00dh,08ch,010h	; 1861
	defb 00dh,08ah,010h	; 1864
	defb 00dh,08ch,010h	; 1867
	defb 00dh,08ah,010h	; 186a
	defb 00ch,000h,0b0h	; 186d
	defb 000h,08ch,010h	; 1870
	defb 00eh,08ah,010h	; 1873
	defb 00eh,08ch,010h	; 1876
	defb 00eh,08ah,010h	; 1879
	defb 00eh,08ch,010h	; 187c
	defb 00eh,08ah,010h	; 187f
	defb 00eh,08ch,010h	; 1882
	defb 00eh,08ah,010h	; 1885
	defb 00eh,08ch,010h	; 1888
	defb 00eh,08ah,010h	; 188b
	defb 00eh,08ch,010h	; 188e
	defb 00eh,08ah,030h	; 1891
	defb 00eh,08ch,030h	; 1894
	defb 00dh,0ffh	; 1897

; ----------------------------------------------------------------------
; DATOS traqueteo: canal 3: 4 notas, una y otra vez
;   0x1899..0x18a6  (13 bytes)
DATA_traqueteo:
	defb 000h,020h,00ch	; 1899
	defb 000h,020h,000h	; 189c
	defb 000h,020h,00ch	; 189f
	defb 000h,020h,000h	; 18a2
	defb 0ffh	; 18a5

; ----------------------------------------------------------------------
; DATOS traqueteo_rapido: canal 3: 4 notas, con el tren a tope
;   0x18a6..0x18b3  (13 bytes)
DATA_traqueteo_rapido:
	defb 000h,010h,00ch	; 18a6
	defb 000h,010h,000h	; 18a9
	defb 000h,010h,00ch	; 18ac
	defb 000h,010h,000h	; 18af
	defb 0ffh	; 18b2

; ----------------------------------------------------------------------
; DATOS choque: canales 2 y 3: 6 notas
;   0x18b3..0x18c6  (19 bytes)
DATA_choque:
	defb 059h,010h,00ch	; 18b3
	defb 054h,010h,00ch	; 18b6
	defb 05dh,010h,00ch	; 18b9
	defb 05bh,010h,00ch	; 18bc
	defb 047h,010h,00ch	; 18bf
	defb 043h,010h,00ch	; 18c2
	defb 0ffh	; 18c5

; ----------------------------------------------------------------------
; DATOS musica_final_1: GAME OVER, canal 1: 18 notas
;   0x18c6..0x18fd  (55 bytes)
DATA_musica_final_1:
	defb 059h,020h,00ch	; 18c6
	defb 02ch,021h,00ch	; 18c9
	defb 02ch,021h,00ch	; 18cc
	defb 071h,010h,00ch	; 18cf
	defb 096h,010h,00ch	; 18d2
	defb 071h,020h,00ch	; 18d5
	defb 02ch,021h,00ch	; 18d8
	defb 02ch,021h,00ch	; 18db
	defb 096h,010h,00ch	; 18de
	defb 0b3h,010h,00ch	; 18e1
	defb 096h,020h,00ch	; 18e4
	defb 02ch,021h,00ch	; 18e7
	defb 02ch,021h,00ch	; 18ea
	defb 0c9h,010h,00ch	; 18ed
	defb 0b3h,010h,00ch	; 18f0
	defb 0e1h,020h,00ch	; 18f3
	defb 02ch,021h,00ch	; 18f6
	defb 02ch,021h,00ch	; 18f9
	defb 0ffh	; 18fc

; ----------------------------------------------------------------------
; DATOS musica_final_2: canal 2: 13 notas
;   0x18fd..0x1925  (40 bytes)
DATA_musica_final_2:
	defb 000h,020h,000h	; 18fd
	defb 065h,021h,00ch	; 1900
	defb 065h,021h,00ch	; 1903
	defb 000h,040h,000h	; 1906
	defb 065h,021h,00ch	; 1909
	defb 065h,021h,00ch	; 190c
	defb 000h,020h,000h	; 190f
	defb 000h,020h,000h	; 1912
	defb 051h,021h,00ch	; 1915
	defb 051h,021h,00ch	; 1918
	defb 000h,040h,000h	; 191b
	defb 065h,021h,00ch	; 191e
	defb 065h,021h,00ch	; 1921
	defb 0ffh	; 1924

; ----------------------------------------------------------------------
; DATOS musica_final_3: canal 3: 13 notas
;   0x1925..0x194d  (40 bytes)
DATA_musica_final_3:
	defb 000h,020h,000h	; 1925
	defb 0c2h,021h,00ch	; 1928
	defb 0c2h,021h,00ch	; 192b
	defb 000h,040h,000h	; 192e
	defb 0c2h,021h,00ch	; 1931
	defb 0c2h,021h,00ch	; 1934
	defb 000h,020h,000h	; 1937
	defb 000h,020h,000h	; 193a
	defb 0ddh,021h,00ch	; 193d
	defb 0ddh,021h,00ch	; 1940
	defb 000h,040h,000h	; 1943
	defb 0c2h,021h,00ch	; 1946
	defb 0c2h,021h,00ch	; 1949
	defb 0ffh	; 194c

; ----------------------------------------------------------------------
; DATOS empujon: canal 1: 2 notas, al empujar una pieza
;   0x194d..0x1954  (7 bytes)
DATA_empujon:
	defb 051h,011h,00dh	; 194d
	defb 0efh,010h,00dh	; 1950
	defb 0ffh	; 1953

; ----------------------------------------------------------------------
; DATOS aviso: canal 1: 6 notas, al anunciar un tren negro
;   0x1954..0x1967  (19 bytes)
DATA_aviso:
	defb 03ch,010h,00dh	; 1954
	defb 059h,010h,00dh	; 1957
	defb 000h,040h,000h	; 195a
	defb 03ch,010h,00dh	; 195d
	defb 059h,010h,00dh	; 1960
	defb 000h,040h,000h	; 1963
	defb 0ffh	; 1966

; ----------------------------------------------------------------------
; DATOS letras_9_a_23: tres dibujos de 8 bytes, cada uno en cinco letras
;   seguidas (0x019F)
;   0x1967..0x197f  (24 bytes)
DATA_letras_9_a_23:
	defb 000h,000h,000h,000h,000h,000h,000h,0ffh	; 1967  ........
	defb 080h,080h,080h,080h,080h,080h,080h,0ffh	; 196f  ........
	defb 080h,080h,080h,080h,080h,080h,080h,080h	; 1977  ........

; ----------------------------------------------------------------------
; DATOS letras_18_a_8A: las vias, el marco, las estaciones, el logotipo y el
;   tren pequeno de las vidas: 115 letras de 8 bytes
;   0x197f..0x1d17  (920 bytes)
DATA_letras_18_a_8A:
	defb 00fh,00bh,00dh,00eh,00eh,00dh,00bh,0ffh	; 197f  ........
	defb 0f0h,0d0h,0b0h,070h,070h,0b0h,0d0h,0ffh	; 1987  ...pp...
	defb 080h,080h,080h,080h,0ffh,0bdh,0dbh,0e7h	; 198f  ........
	defb 0e7h,0dbh,0bdh,0ffh,080h,080h,080h,080h	; 1997  ........
	defb 00fh,00bh,00dh,00eh,00eh,00dh,00bh,00fh	; 199f  ........
	defb 0f0h,0d0h,0b0h,070h,070h,0b0h,0d0h,0f0h	; 19a7  ...pp...
	defb 000h,000h,000h,000h,0ffh,0bdh,0dbh,0e7h	; 19af  ........
	defb 0e7h,0dbh,0bdh,0ffh,000h,000h,000h,000h	; 19b7  ........
	defb 006h,006h,006h,007h,003h,003h,001h,001h	; 19bf  ........
	defb 060h,060h,070h,0f0h,0f8h,098h,09ch,0ceh	; 19c7  ``p.....
	defb 080h,080h,080h,080h,080h,0f0h,0fch,01fh	; 19cf  ........
	defb 0ffh,0e3h,071h,039h,01dh,00fh,007h,003h	; 19d7  ..q9....
	defb 000h,080h,0c0h,0f0h,07ch,01fh,09fh,0f8h	; 19df  ....|...
	defb 08fh,0f9h,0f8h,0beh,08fh,083h,081h,080h	; 19e7  ........
	defb 0c0h,0e0h,0f0h,0b8h,09ch,08eh,0c7h,0ffh	; 19ef  ........
	defb 0f8h,03fh,00fh,000h,000h,000h,000h,000h	; 19f7  .?......
	defb 073h,039h,019h,01fh,00fh,00eh,006h,0feh	; 19ff  s9......
	defb 080h,080h,0c0h,0c0h,0e0h,060h,060h,07fh	; 1a07  .....``.
	defb 006h,006h,00eh,00fh,01fh,019h,039h,073h	; 1a0f  ......9s
	defb 060h,060h,060h,0e0h,0c0h,0c0h,080h,080h	; 1a17  ```.....
	defb 080h,081h,083h,08fh,0beh,0f8h,0e1h,007h	; 1a1f  ........
	defb 0ffh,0c7h,08eh,09ch,0b8h,0f0h,0e0h,0c0h	; 1a27  ........
	defb 000h,000h,000h,000h,000h,00fh,03fh,0f8h	; 1a2f  ......?.
	defb 01fh,0fch,0f0h,080h,080h,080h,080h,080h	; 1a37  ........
	defb 003h,007h,00fh,01dh,039h,071h,0e3h,0ffh	; 1a3f  ....9q..
	defb 0e0h,0e7h,07fh,07ch,0f0h,0c0h,080h,000h	; 1a47  ...|....
	defb 001h,001h,003h,003h,007h,006h,006h,0feh	; 1a4f  ........
	defb 0ceh,09ch,098h,0f8h,0f0h,070h,060h,07fh	; 1a57  .....p`.
	defb 007h,007h,006h,006h,006h,006h,007h,007h	; 1a5f  ........
	defb 0e0h,0e0h,060h,060h,060h,060h,0e0h,0e0h	; 1a67  ..````..
	defb 080h,080h,080h,080h,080h,0ffh,0ffh,0c3h	; 1a6f  ........
	defb 006h,006h,006h,006h,007h,0ffh,0ffh,00eh	; 1a77  ........
	defb 060h,060h,060h,060h,0e0h,0ffh,0ffh,070h	; 1a7f  ````...p
	defb 000h,000h,000h,000h,000h,0ffh,0ffh,0c3h	; 1a87  ........
	defb 0c3h,0ffh,0ffh,080h,080h,080h,080h,080h	; 1a8f  ........
	defb 00eh,0ffh,0ffh,007h,006h,006h,006h,006h	; 1a97  ........
	defb 070h,0ffh,0ffh,0e0h,060h,060h,060h,060h	; 1a9f  p...````
	defb 0c3h,0ffh,0ffh,000h,000h,000h,000h,000h	; 1aa7  ........
	defb 007h,007h,006h,006h,006h,006h,007h,0ffh	; 1aaf  ........
	defb 0e0h,0e0h,060h,060h,060h,060h,0e0h,0ffh	; 1ab7  ..````..
	defb 000h,000h,003h,00fh,01eh,038h,071h,0ffh	; 1abf  .....8q.
	defb 000h,0ffh,0ffh,0c0h,0c0h,0ffh,0ffh,0c0h	; 1ac7  ........
	defb 001h,001h,003h,003h,007h,006h,006h,0feh	; 1acf  ........
	defb 0c7h,08eh,09ch,0f8h,0f0h,070h,060h,07fh	; 1ad7  .....p`.
	defb 000h,0ffh,0ffh,003h,003h,0ffh,0ffh,003h	; 1adf  ........
	defb 000h,000h,0c0h,0f0h,078h,01ch,08eh,0ffh	; 1ae7  ....x...
	defb 0e3h,071h,039h,01fh,00fh,00eh,006h,0feh	; 1aef  .q9.....
	defb 080h,080h,0c0h,0c0h,0e0h,060h,060h,07fh	; 1af7  .....``.
	defb 080h,080h,080h,080h,080h,0f0h,0fch,01fh	; 1aff  ........
	defb 01fh,0f9h,0f8h,0bch,08eh,087h,083h,081h	; 1b07  ........
	defb 080h,0c0h,0e0h,0f0h,0b8h,09ch,09eh,0cch	; 1b0f  ........
	defb 0feh,0feh,066h,066h,066h,066h,066h,066h	; 1b17  ..ffffff
	defb 066h,066h,066h,066h,066h,066h,0feh,0feh	; 1b1f  ffffff..
	defb 081h,083h,087h,09eh,0bch,0f8h,0f9h,01fh	; 1b27  ........
	defb 0cch,09ch,098h,0b8h,0f0h,0e0h,0c0h,080h	; 1b2f  ........
	defb 01fh,0fch,0f0h,080h,080h,080h,080h,080h	; 1b37  ........
	defb 0feh,006h,006h,007h,003h,003h,001h,001h	; 1b3f  ........
	defb 07fh,060h,070h,0f0h,0f8h,09ch,08eh,0c7h	; 1b47  .`p.....
	defb 0ffh,071h,038h,01eh,00fh,003h,000h,000h	; 1b4f  .q8.....
	defb 0c0h,0ffh,0ffh,0c0h,0c0h,0ffh,0ffh,000h	; 1b57  ........
	defb 0feh,006h,00eh,00fh,01fh,039h,071h,0e3h	; 1b5f  .....9q.
	defb 07fh,060h,060h,0e0h,0c0h,0c0h,080h,080h	; 1b67  .``.....
	defb 003h,0ffh,0ffh,003h,003h,0ffh,0ffh,000h	; 1b6f  ........
	defb 0ffh,08eh,01ch,078h,0f0h,0c0h,000h,000h	; 1b77  ...x....
	defb 001h,001h,001h,001h,001h,00fh,03fh,0f8h	; 1b7f  ......?.
	defb 001h,003h,007h,00fh,01dh,019h,039h,033h	; 1b87  ......93
	defb 0f8h,09fh,01fh,03dh,071h,0e1h,0c1h,081h	; 1b8f  ...=q...
	defb 07fh,07fh,066h,066h,066h,066h,066h,066h	; 1b97  ..ffffff
	defb 066h,066h,066h,066h,066h,066h,07fh,07fh	; 1b9f  ffffff..
	defb 033h,039h,019h,01dh,00fh,007h,003h,001h	; 1ba7  39......
	defb 081h,0c1h,0e1h,071h,03dh,01fh,09fh,0f8h	; 1baf  ...q=...
	defb 0f8h,03fh,00fh,001h,001h,001h,001h,001h	; 1bb7  .?......
	defb 0ffh,080h,080h,080h,080h,080h,080h,080h	; 1bbf  ........
	defb 0ffh,000h,000h,000h,000h,000h,000h,000h	; 1bc7  ........
	defb 001h,001h,001h,001h,001h,001h,001h,001h	; 1bcf  ........
	defb 001h,001h,001h,001h,001h,001h,001h,0ffh	; 1bd7  ........
	defb 038h,010h,07fh,02bh,06bh,07fh,013h,06dh	; 1bdf  8..+k..m
	defb 07ch,0feh,0ceh,082h,0aah,0aah,082h,038h	; 1be7  |......8
	defb 000h,000h,000h,000h,003h,00fh,00eh,00fh	; 1bef  ........
	defb 000h,000h,000h,0fch,0ffh,003h,000h,000h	; 1bf7  ........
	defb 000h,000h,000h,000h,060h,0e1h,0e3h,067h	; 1bff  ....`..g
	defb 000h,000h,000h,03fh,0ffh,0e0h,0c0h,080h	; 1c07  ...?....
	defb 000h,000h,000h,080h,0e0h,0f0h,078h,03ch	; 1c0f  ......x<
	defb 000h,000h,000h,000h,0feh,0ffh,03fh,03bh	; 1c17  ......?;
	defb 000h,000h,000h,000h,01fh,01fh,087h,0c7h	; 1c1f  ........
	defb 000h,000h,000h,000h,0cfh,0cfh,003h,001h	; 1c27  ........
	defb 000h,000h,000h,000h,0e3h,0e3h,0c1h,0e3h	; 1c2f  ........
	defb 000h,000h,000h,000h,0f0h,0f0h,0c0h,080h	; 1c37  ........
	defb 00fh,007h,000h,00ch,00eh,00fh,00dh,000h	; 1c3f  ........
	defb 0feh,0ffh,0ffh,000h,000h,081h,0ffh,0ffh	; 1c47  ........
	defb 007h,0c7h,0e7h,0e7h,0e3h,0e1h,0c0h,000h	; 1c4f  ........
	defb 080h,080h,080h,080h,0c0h,0e0h,0ffh,03fh	; 1c57  .......?
	defb 03ch,03ch,03ch,03ch,078h,0f0h,0e0h,080h	; 1c5f  <<<<x...
	defb 039h,038h,038h,038h,038h,0ffh,0ffh,000h	; 1c67  98888...
	defb 0e7h,0f7h,07fh,03fh,01fh,00fh,007h,000h	; 1c6f  ...?....
	defb 0f7h,07eh,03ch,03ch,03ch,0ffh,0ffh,000h	; 1c77  .~<<<...
	defb 0e7h,0e7h,0e7h,0e7h,0e7h,0e7h,0e7h,0e7h	; 1c7f  ........
	defb 0c3h,0c3h,0c3h,003h,003h,0c3h,0c3h,0c3h	; 1c87  ........
	defb 0ffh,0ffh,0ffh,000h,000h,0ffh,0ffh,0ffh	; 1c8f  ........
	defb 000h,0c0h,0f0h,0f8h,0fch,0feh,0feh,0feh	; 1c97  ........
	defb 0feh,0feh,0feh,0feh,0feh,0fch,0fch,0f8h	; 1c9f  ........
	defb 0f8h,0f0h,0e0h,0c0h,0c0h,0e0h,0f0h,0f8h	; 1ca7  ........
	defb 0f8h,0f8h,0f8h,0f8h,0ffh,0ffh,0ffh,0ffh	; 1caf  ........
	defb 0e7h,0e7h,0e7h,000h,000h,000h,000h,0ffh	; 1cb7  ........
	defb 0e7h,0e7h,0e7h,0e7h,0e7h,0e7h,0e7h,0e7h	; 1cbf  ........
	defb 0feh,0feh,0fch,0fch,0f8h,0f0h,0e0h,0c0h	; 1cc7  ........
	defb 0f8h,0fch,0fch,0feh,0feh,0feh,0feh,0feh	; 1ccf  ........
	defb 0c3h,0c3h,0c3h,003h,003h,0c3h,0c3h,0c3h	; 1cd7  ........
	defb 0ffh,0ffh,0ffh,000h,000h,0ffh,0ffh,0ffh	; 1cdf  ........
	defb 0ffh,000h,000h,000h,000h,0e7h,0e7h,0e7h	; 1ce7  ........
	defb 0feh,0feh,0fch,0f8h,0f0h,0e0h,0c0h,080h	; 1cef  ........
	defb 0ffh,07fh,03fh,01fh,00fh,007h,003h,001h	; 1cf7  ..?.....
	defb 0ffh,0ffh,0ffh,000h,000h,000h,000h,000h	; 1cff  ........
	defb 001h,003h,007h,00fh,01fh,03fh,07fh,0ffh	; 1d07  .....?..
	defb 080h,0c0h,0e0h,0f0h,0f8h,0fch,0feh,0ffh	; 1d0f  ........

; ----------------------------------------------------------------------
; DATOS fuente_menu: 23 letras que se cargan cuatro veces (0x8B, 0xA2, 0xB9 y
;   0xD0), cada copia con su color: las del menu, PLAYER, STAGE y las cifras
;   0-4
;   0x1d17..0x1dcf  (184 bytes)
DATA_fuente_menu:
	defb 03ch,022h,022h,03ch,020h,020h,020h,000h	; 1d17  <""<   .
	defb 020h,020h,020h,020h,020h,020h,03eh,000h	; 1d1f        >.
	defb 018h,024h,042h,07eh,042h,042h,042h,000h	; 1d27  .$B~BBB.
	defb 022h,022h,022h,01ch,008h,008h,008h,000h	; 1d2f  """.....
	defb 03eh,020h,020h,03ch,020h,020h,03eh,000h	; 1d37  >  <  >.
	defb 03ch,022h,022h,03ch,028h,024h,022h,000h	; 1d3f  <""<($".
	defb 03ch,042h,040h,03ch,002h,042h,03ch,000h	; 1d47  <B@<.B<.
	defb 042h,042h,042h,05ah,05ah,066h,042h,000h	; 1d4f  BBBZZfB.
	defb 000h,002h,004h,008h,010h,020h,040h,000h	; 1d57  ..... @.
	defb 004h,004h,004h,004h,044h,044h,038h,000h	; 1d5f  ....DD8.
	defb 018h,024h,042h,042h,042h,024h,018h,000h	; 1d67  .$BBB$..
	defb 03eh,008h,008h,008h,008h,008h,008h,000h	; 1d6f  >.......
	defb 01ch,008h,008h,008h,008h,008h,01ch,000h	; 1d77  ........
	defb 01ch,022h,040h,040h,040h,022h,01ch,000h	; 1d7f  ."@@@"..
	defb 022h,024h,028h,030h,028h,024h,022h,000h	; 1d87  "$(0($".
	defb 07ch,022h,022h,03ch,022h,022h,07ch,000h	; 1d8f  |""<""|.
	defb 038h,024h,022h,022h,022h,024h,038h,000h	; 1d97  8$"""$8.
	defb 066h,066h,044h,000h,000h,000h,000h,000h	; 1d9f  ffD.....
	defb 03ch,042h,046h,05ah,062h,042h,03ch,000h	; 1da7  <BFZbB<.
	defb 008h,018h,038h,008h,008h,008h,008h,000h	; 1daf  ..8.....
	defb 03ch,042h,002h,00ch,030h,040h,07eh,000h	; 1db7  <B..0@~.
	defb 03ch,042h,002h,01ch,002h,042h,03ch,000h	; 1dbf  <B...B<.
	defb 004h,00ch,014h,024h,07eh,004h,004h,000h	; 1dc7  ...$~...

; ----------------------------------------------------------------------
; DATOS fuente_resto: 22 letras mas, detras de la cuarta copia (desde 0xE7):
;   las cifras 5-9 y el resto
;   0x1dcf..0x1e7f  (176 bytes)
DATA_fuente_resto:
	defb 07ch,040h,078h,004h,002h,044h,038h,000h	; 1dcf  |@x..D8.
	defb 01ch,020h,040h,07ch,042h,042h,03ch,000h	; 1dd7  . @|BB<.
	defb 07eh,002h,004h,008h,010h,010h,010h,000h	; 1ddf  ~.......
	defb 03ch,042h,042h,03ch,042h,042h,03ch,000h	; 1de7  <BB<BB<.
	defb 03ch,042h,042h,03eh,002h,004h,038h,000h	; 1def  <BB>..8.
	defb 07eh,002h,004h,008h,010h,020h,07eh,000h	; 1df7  ~.... ~.
	defb 022h,022h,032h,02ah,026h,022h,022h,000h	; 1dff  ""2*&"".
	defb 022h,022h,022h,03eh,022h,022h,022h,000h	; 1e07  """>""".
	defb 01ch,022h,040h,04eh,042h,022h,01ch,000h	; 1e0f  ."@NB"..
	defb 042h,066h,05ah,05ah,042h,042h,042h,000h	; 1e17  BfZZBBB.
	defb 042h,042h,042h,024h,024h,018h,018h,000h	; 1e1f  BBB$$...
	defb 000h,000h,000h,07eh,000h,000h,000h,000h	; 1e27  ...~....
	defb 03ch,042h,099h,0a1h,0a1h,099h,042h,03ch	; 1e2f  <B....B<
	defb 003h,067h,06eh,07ch,079h,079h,07fh,06fh	; 1e37  .gn|yy.o
	defb 080h,000h,000h,03dh,0adh,0adh,0adh,03dh	; 1e3f  ...=...=
	defb 000h,000h,000h,0ceh,063h,06fh,06bh,06fh	; 1e47  ....coko
	defb 000h,000h,000h,07ch,056h,056h,056h,056h	; 1e4f  ...|VVVV
	defb 000h,000h,0c0h,000h,0c0h,0c0h,0c0h,0c0h	; 1e57  ........
	defb 00fh,00bh,00dh,00eh,00eh,00dh,00bh,00fh	; 1e5f  ........
	defb 0f0h,0d0h,0b0h,070h,070h,0b0h,0d0h,0f0h	; 1e67  ...pp...
	defb 00fh,00bh,00dh,00eh,00eh,00dh,00bh,0ffh	; 1e6f  ........
	defb 0f0h,0d0h,0b0h,070h,070h,0b0h,0d0h,0ffh	; 1e77  ...pp...

; ----------------------------------------------------------------------
; DATOS sprites: 12 patrones de 16 x 16: el tren blanco en sus 8 direcciones
;   (0x00-0x1C) y el negro en 4 (0x20-0x2C)
;   0x1e7f..0x1fff  (384 bytes)
DATA_sprites:
	defb 018h,005h,037h,05bh,06bh,037h,027h,027h,017h,017h,037h,05bh,06bh,037h,00fh,00fh,0c0h,0f0h,0f0h,0feh,0feh,0f0h,0f0h,0f0h,068h,008h,0f8h,068h,008h,0f8h,0f8h,088h	; 1e7f  ..7[k7''..7[k7..........h..h....
	defb 011h,01fh,01fh,010h,016h,01fh,010h,016h,00fh,00fh,00fh,07fh,07fh,00fh,00fh,003h,0f0h,0f0h,0ech,0b6h,0dah,0ech,0e8h,0e8h,0e4h,0e4h,0ech,0d6h,0dah,0ech,0a0h,018h	; 1e9f  ................................
	defb 000h,000h,000h,0ffh,064h,06dh,06dh,0e4h,0ffh,0ffh,0e7h,0d8h,02fh,034h,018h,000h,000h,018h,018h,018h,0feh,0feh,0ffh,0ffh,0feh,0fch,0e6h,019h,02dh,0f4h,018h,000h	; 1ebf  ....dmm...../4..............-...
	defb 000h,018h,018h,018h,07fh,07fh,0ffh,0ffh,07fh,03fh,067h,098h,0b4h,02fh,018h,000h,000h,000h,000h,0ffh,026h,0b6h,0b6h,027h,0ffh,0ffh,0e7h,01bh,0f4h,02ch,018h,000h	; 1edf  .........?g../......&..'.....,..
	defb 00ch,00eh,007h,003h,017h,03fh,067h,0f3h,08bh,0c9h,067h,037h,01eh,00dh,00dh,000h,000h,080h,0c0h,0e0h,0fah,0f5h,0f8h,0f6h,0ebh,0edh,0ceh,010h,0e0h,060h,0a0h,0c0h	; 1eff  .....?g...g7.................`..
	defb 001h,003h,007h,00dh,0c4h,0eeh,07fh,03fh,07fh,03fh,01fh,00fh,00ah,005h,009h,004h,0c0h,060h,030h,018h,0ceh,03eh,0b8h,0f6h,0ebh,0edh,0ceh,010h,0e0h,060h,0a0h,0c0h	; 1f1f  .......?.?.......`0..>.......`..
	defb 003h,006h,00ch,018h,073h,0ech,01dh,06fh,0d7h,0b7h,073h,008h,007h,006h,005h,003h,080h,0c0h,0e0h,0b0h,023h,077h,0feh,0fch,0feh,0fch,0f8h,0f0h,050h,0a0h,090h,020h	; 1f3f  ....s..o..s.........#w......P.. 
	defb 000h,001h,003h,007h,05fh,0afh,01fh,06fh,0d7h,0b7h,073h,008h,007h,006h,005h,003h,030h,070h,0e0h,0c0h,0e8h,0fch,0e6h,0cfh,0d1h,093h,0e6h,0ech,078h,0b0h,0b0h,000h	; 1f5f  ...._..o..s.....0p..........x...
	defb 000h,007h,02eh,02fh,05eh,05eh,02eh,02eh,00fh,02eh,02eh,05eh,05eh,02fh,02eh,007h,000h,0e0h,070h,0f6h,0f6h,0f8h,076h,076h,0f0h,0f6h,0f6h,078h,076h,0f6h,070h,0e0h	; 1f7f  .../^^.....^^/....p...vv...xv.p.
	defb 000h,018h,066h,018h,07fh,0ffh,0ffh,0a1h,0a7h,0ffh,0ffh,07fh,008h,036h,036h,000h,000h,030h,0cch,030h,0fch,0feh,0feh,00ah,03ah,0feh,0feh,0fch,020h,0d8h,0d8h,000h	; 1f9f  ..f..........66..0.0....:... ...
	defb 003h,005h,006h,001h,003h,067h,0afh,0dfh,039h,071h,0efh,0f7h,05fh,02ch,019h,001h,030h,078h,0f4h,0cah,08eh,07ch,0b8h,0fbh,0e3h,0cch,08ch,000h,060h,060h,080h,080h	; 1fbf  .....g..9q.._,..0x...|......``..
	defb 00ch,01eh,02fh,05bh,075h,03ch,08ch,0dfh,0c7h,033h,031h,000h,006h,006h,001h,001h,0c0h,0a0h,060h,080h,0c0h,0e6h,0f5h,0fbh,0dch,0aeh,0e7h,0e7h,0fah,034h,098h,080h	; 1fdf  ../[u<...31.......`..........4..

; ----------------------------------------------------------------------
; DATOS relleno_1FFF: 0xFF, el ultimo byte de los 8 KB
;   0x1fff..0x2000  (1 bytes)
DATA_relleno_1FFF:
	defb 0ffh	; 1fff
