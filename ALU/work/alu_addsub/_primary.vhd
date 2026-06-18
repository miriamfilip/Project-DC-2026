library verilog;
use verilog.vl_types.all;
entity alu_addsub is
    generic(
        WIDTH           : integer := 8
    );
    port(
        A               : in     vl_logic_vector;
        B               : in     vl_logic_vector;
        sub             : in     vl_logic;
        result          : out    vl_logic_vector;
        overflow        : out    vl_logic
    );
end alu_addsub;
