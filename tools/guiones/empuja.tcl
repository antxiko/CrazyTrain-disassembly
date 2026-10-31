# Una partida con el teclado ("3" en el menu, cuadro 400): cada 90 cuadros un
# empujon con los cursores, por turno arriba, derecha, abajo e izquierda (fila
# 8: bits 5, 7, 6 y 4), 10 cuadros apretado. 8000 cuadros, hasta el GAME OVER.
proc guion {n} {
    if {$n == 400} { keymatrixdown 0 0x08 }
    if {$n == 410} { keymatrixup 0 0x08 }
    if {$n > 800} {
        set k [expr {($n / 90) % 4}]
        set b [lindex {0x20 0x80 0x40 0x10} $k]
        if {$n % 90 == 0} { keymatrixdown 8 $b }
        if {$n % 90 == 10} { keymatrixup 8 0xF0 }
    }
    return [expr {$n >= 8000}]
}
