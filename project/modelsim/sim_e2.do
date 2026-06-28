# sim_e2.do -- compila e simula hello_e2.asm (Etapa 02)
# Uso: vsim -c -do sim_e2.do    (executar de dentro de project/modelsim/)
# NOTA: vsim sem -do interno para que o script continue apos "run -all"
#       e restaure os arquivos hex antes de sair.

set SRC "../src"
set ASM "../assembler"

# ---- trocar hex files para Etapa 02 ----
file copy -force ${ASM}/program.hex    ${ASM}/program_base_bkp.hex
file copy -force ${ASM}/data.hex       ${ASM}/data_base_bkp.hex
file copy -force ${ASM}/program_e2.hex ${ASM}/program.hex
file copy -force ${ASM}/data_e2.hex    ${ASM}/data.hex

# ---- trocar golden para Etapa 02 ----
if {[file exists golden.txt]}    { file rename -force golden.txt    golden_base_bkp.txt }
if {[file exists golden_e2.txt]} { file copy   -force golden_e2.txt golden.txt }

# ---- compilacao ----
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

vlog -sv -work work ${SRC}/pl_pipe_pkg.sv
vlog -sv -work work ${SRC}/pl_alu.sv
vlog -sv -work work ${SRC}/pl_alu_ctrl.sv
vlog -sv -work work ${SRC}/pl_control.sv
vlog -sv -work work ${SRC}/pl_regfile.sv
vlog -sv -work work ${SRC}/pl_sign_ext.sv
vlog -sv -work work ${SRC}/pl_hazard.sv
vlog -sv -work work ${SRC}/pl_forward.sv
vlog -sv -work work ${SRC}/pl_imem.sv
vlog -sv -work work ${SRC}/pl_dmem.sv
vlog -sv -work work ${SRC}/pl_uart.sv
vlog -sv -work work ${SRC}/pl_mmio.sv
vlog -sv -work work ${SRC}/pl_datapath.sv
vlog -sv -work work ${SRC}/pl_cpu.sv
vlog    -work work  ${SRC}/pll_10mhz.v
vlog -sv -work work ${SRC}/pl_top.sv
vlog -sv -work work ${SRC}/pl_top_no_pll.sv
vlog -sv -work work ${SRC}/pl_cpu_tb.sv

# ---- simulacao: vsim SEM -do para que "run -all" retorne ao script ----
vsim -lib work pl_cpu_tb
run -all

# ---- restaurar arquivos originais (so executado apos run -all) ----
if {[file exists golden_base_bkp.txt]} {
    file copy   -force golden.txt           golden_e2.txt
    file rename -force golden_base_bkp.txt  golden.txt
}
file copy  -force ${ASM}/program_base_bkp.hex ${ASM}/program.hex
file copy  -force ${ASM}/data_base_bkp.hex    ${ASM}/data.hex
file delete -force ${ASM}/program_base_bkp.hex ${ASM}/data_base_bkp.hex

quit -f
