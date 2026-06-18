quit -sim

if {[file exists work]} {
    vdel -lib work -all
}

vlib work
vmap work work

# -------------------------------------------------------
# Leaf-level primitives
# -------------------------------------------------------

vlog src/dff.sv
vlog src/jkff.sv
vlog src/gates.sv
vlog src/alu_addsub.sv
vlog src/tristate_buffer_bus.sv
vlog src/mux2.sv
vlog src/alu_shift.sv
vlog src/count_leading_zeros.sv

# -------------------------------------------------------
# Higher-level modules
# -------------------------------------------------------

vlog src/register.sv
vlog src/counter_n_bits.sv

# -------------------------------------------------------
# SRT2 Control Unit
# -------------------------------------------------------

vlog src/cu_srt2.sv

# -------------------------------------------------------
# Top-level Divider
# -------------------------------------------------------

vlog src/alu_srt2.sv

# -------------------------------------------------------
# Testbench
# -------------------------------------------------------

vlog tb/alu_srt2_tb.sv

# -------------------------------------------------------
# Simulate
# -------------------------------------------------------

vsim alu_srt2_tb

add wave -r /*

run -all