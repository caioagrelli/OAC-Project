# run_e2.ps1 -- executa simulacao da Etapa 02 e restaura os arquivos base
# Uso: cd project\modelsim; .\run_e2.ps1

$vsim  = "C:\intelFPGA\20.1\modelsim_ase\win32aloem\vsim.exe"
$asm   = "..\assembler"
$mod   = "."

# ---- swap para Etapa 02 ----
Copy-Item "$asm\program.hex"    "$asm\program_base_bkp.hex" -Force
Copy-Item "$asm\data.hex"       "$asm\data_base_bkp.hex"    -Force
Copy-Item "$asm\program_e2.hex" "$asm\program.hex"          -Force
Copy-Item "$asm\data_e2.hex"    "$asm\data.hex"             -Force

if (Test-Path "$mod\golden.txt")    { Rename-Item "$mod\golden.txt"    "$mod\golden_base_bkp.txt" -Force }
if (Test-Path "$mod\golden_e2.txt") { Copy-Item   "$mod\golden_e2.txt" "$mod\golden.txt"          -Force }

# ---- simulacao ----
& $vsim -c -do "sim_e2_inner.do"

# ---- restaurar arquivos originais ----
if (Test-Path "$mod\golden_base_bkp.txt") {
    Copy-Item "$mod\golden.txt"          "$mod\golden_e2.txt"  -Force
    Rename-Item "$mod\golden_base_bkp.txt" "$mod\golden.txt"   -Force
}
Copy-Item "$asm\program_base_bkp.hex" "$asm\program.hex" -Force
Copy-Item "$asm\data_base_bkp.hex"    "$asm\data.hex"    -Force
Remove-Item "$asm\program_base_bkp.hex","$asm\data_base_bkp.hex" -Force

Write-Host "`n>>> program.hex restaurado: $(Get-Content "$asm\program.hex" -TotalCount 1)"
Write-Host ">>> data.hex restaurado:    $(Get-Content "$asm\data.hex" -TotalCount 1)"
