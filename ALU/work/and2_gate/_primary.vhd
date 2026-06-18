library verilog;
use verilog.vl_types.all;
entity and2_gate is
    port(
        a               : in     vl_logic;
        b               : in     vl_logic;
        y               : out    vl_logic
    );
end and2_gate;
