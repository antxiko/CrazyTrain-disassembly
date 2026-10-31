# sonda_ret.tcl - cuantas veces llega el programa a una direccion (SONDA_DIR)
# en SONDA_CUADROS cuadros de partida: "3" en el menu, un empujon cada 90
# cuadros (arriba, derecha, abajo, izquierda) y las vidas siempre a 3. Escribe
# el resultado en SONDA_SALIDA.
set throttle off
set ::n 0
set ::golpes 0
proc cuadro {} {
    incr ::n
    if {$::n == 400} { keymatrixdown 0 0x08 }
    if {$::n == 410} { keymatrixup 0 0x08 }
    if {$::n > 800} {
        set k [expr {($::n / 90) % 4}]
        if {$::n % 90 == 0} { keymatrixdown 8 [lindex {0x20 0x80 0x40 0x10} $k] }
        if {$::n % 90 == 10} { keymatrixup 8 0xF0 }
        if {[debug read memory 0xE200] == 0} { debug write memory 0xE002 3 }
    }
    if {$::n >= $::env(SONDA_CUADROS)} {
        set f [open $::env(SONDA_SALIDA) w]
        puts $f "cuadros $::n golpes $::golpes"
        close $f
        exit
    }
}
debug set_bp 0x0038 {[pc_in_slot 1]} { cuadro }
debug set_bp $::env(SONDA_DIR) {[pc_in_slot 1]} { incr ::golpes }
