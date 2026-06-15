if {![file exists work]} {
    vlib work
}
vmap work work

vlog src/alu_addsub.sv
vlog tb/alu_addsub_tb.sv

vsim alu_addsub_tb

add wave -r /*
run -all