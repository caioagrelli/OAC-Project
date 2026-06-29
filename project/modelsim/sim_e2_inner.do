# sim_e2_inner.do -- apenas compila e simula (chamado pelo run_e2.ps1)
# O swap de program.hex / data.hex / golden.txt e feito pelo PowerShell wrapper.

set SRC "../src"

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

vsim -c -lib work pl_cpu_tb -do "run -all; quit -f"
