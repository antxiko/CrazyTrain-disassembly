# Despues de la 99: la partida de fases.tcl, y en el cuadro 800 la fase
# (0xE230) a 0x98. La fase siguiente es la 99, y la otra...: 2700 cuadros.
proc guion {n} {
    if {$n == 400} { keymatrixdown 0 0x08 }
    if {$n == 410} { keymatrixup 0 0x08 }
    if {$n == 800} { debug write memory 0xE230 0x98 }
    if {$n > 700 && [debug read memory 0xE200] == 0} {
        if {[debug read memory 0xE045] > 1} { debug write memory 0xE045 1 }
        debug write memory 0xE002 3
    }
    return [expr {$n >= 2700}]
}
