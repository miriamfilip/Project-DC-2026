library verilog;
use verilog.vl_types.all;
entity xorn_gate is
    generic(
        WIDTH           : integer := 8
    );
    port(
        a               : in     vl_logic_vector;
        b               : in     vl_logic;
        y               : out    vl_logic_vector
    );
end xorn_gate;
