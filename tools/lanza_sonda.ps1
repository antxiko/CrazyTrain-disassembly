# lanza_sonda.ps1 -dir 0x084F -cuadros 20000 -salida work/sonda.txt: UN openMSX
# con tools/sonda_ret.tcl, fuera del sandbox, minimizado
param([string]$dir, [string]$cuadros, [string]$salida, [string]$rom = "crazytrain.rom")
$raiz = Split-Path -Parent $PSScriptRoot
Set-Location $raiz
$env:SONDA_DIR = $dir
$env:SONDA_CUADROS = $cuadros
$env:SONDA_SALIDA = $salida
$args_ = @("-machine", "C-BIOS_MSX1_JP", "-cart", $rom, "-script", "tools/sonda_ret.tcl")
Start-Process -FilePath "C:\Program Files\openMSX\openmsx.exe" -ArgumentList $args_ -Wait -WindowStyle Minimized
