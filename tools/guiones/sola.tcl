# Una partida con el teclado ("3" en el menu, en el cuadro 400) sin tocar nada
# mas: 3000 cuadros.
proc guion {n} {
    if {$n == 400} { keymatrixdown 0 0x08 }
    if {$n == 410} { keymatrixup 0 0x08 }
    return [expr {$n >= 3000}]
}
