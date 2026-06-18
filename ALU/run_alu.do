quit -sim

if {[file exists work]} {
    vdel -lib work -all
}

vlib work
vmap work work

#-------------------------------------------------
# Basic Components
#-------------------------------------------------

vlog src/dff.sv
vlog src/jkff.sv
vlog src/gates.sv

vlog src/alu_addsub.sv
vlog src/alu_logic.sv
vlog src/alu_shift.sv

vlog src/mux2.sv
vlog src/tristate_buffer_bus.sv

#-------------------------------------------------
# Registers / Counters
#-------------------------------------------------

vlog src/register.sv
vlog src/counter_n_bits.sv

#-------------------------------------------------
# Booth Multiplier
#-------------------------------------------------

vlog src/cu_booth.sv
vlog src/alu_booth_radix4.sv

#-------------------------------------------------
# Divider
#-------------------------------------------------

vlog src/alu_div.sv

#-------------------------------------------------
# Top-Level ALU
#-------------------------------------------------

vlog src/alu_8bit.sv

#-------------------------------------------------
# Testbench
#-------------------------------------------------

vlog tb/alu_tb.sv

vsim alu_tb

add wave -r /*

run -all