quit -sim

if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

# Leaf-level primitives (no internal module dependencies)
vlog src/dff.sv
vlog src/jkff.sv
vlog src/gates.sv
vlog src/alu_addsub.sv
vlog src/tristate_buffer_bus.sv
vlog src/mux2.sv
vlog src/alu_shift.sv

# Modules that depend on the leaf-level primitives above
vlog src/register.sv
vlog src/counter_n_bits.sv

# Control unit (radix-4 logic, file currently named cu_booth.sv)
vlog src/cu_booth.sv

# Top-level datapath (depends on everything above)
vlog src/alu_booth_radix4.sv

# Testbench
vlog tb/alu_booth_radix4_tb.sv

vsim alu_booth_radix4_tb
add wave -r /*
run -all