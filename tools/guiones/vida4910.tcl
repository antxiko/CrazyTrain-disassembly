# La vida extra: la misma partida que sola.tcl, y en el cuadro 1150 los puntos
# a 4.910 (0xE211 = 0x04, 0xE210 = 0x91): en el 1205 el tren entra en la
# segunda casilla de una estacion, 10 + 90 puntos en el mismo cuadro.
proc guion {n} {
    if {$n == 400} { keymatrixdown 0 0x08 }
    if {$n == 410} { keymatrixup 0 0x08 }
    if {$n == 1150} { debug write memory 0xE210 0x91; debug write memory 0xE211 0x04 }
    return [expr {$n >= 1400}]
}
