library verilog;
use verilog.vl_types.all;
entity and3_gate is
    port(
        a               : in     vl_logic;
        b               : in     vl_logic;
        c               : in     vl_logic;
        y               : out    vl_logic
    );
end and3_gate;
