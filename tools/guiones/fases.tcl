# Una partida sin tocar ("3" en el menu, cuadro 400) en la que, con la fase en
# marcha, las estaciones que faltan (0xE045) se dejan en 1 y las vidas (0xE002)
# en 3: cada estacion que visita el tren acaba la fase, y se ven los tableros
# uno tras otro. 9000 cuadros.
proc guion {n} {
    if {$n == 400} { keymatrixdown 0 0x08 }
    if {$n == 410} { keymatrixup 0 0x08 }
    if {$n > 700 && [debug read memory 0xE200] == 0} {
        if {[debug read memory 0xE045] > 1} { debug write memory 0xE045 1 }
        debug write memory 0xE002 3
    }
    return [expr {$n >= 9000}]
}
