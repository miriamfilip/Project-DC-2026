if {![file exists work]} {
    vlib work
}
vmap work work

vlog src/alu_logic.sv
vlog tb/alu_logic_tb.sv

vsim alu_logic_tb

add wave -r /*
run -all