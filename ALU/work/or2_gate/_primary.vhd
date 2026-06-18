library verilog;
use verilog.vl_types.all;
entity or2_gate is
    port(
        a               : in     vl_logic;
        b               : in     vl_logic;
        y               : out    vl_logic
    );
end or2_gate;
