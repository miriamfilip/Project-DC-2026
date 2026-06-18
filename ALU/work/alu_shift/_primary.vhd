library verilog;
use verilog.vl_types.all;
entity alu_shift is
    generic(
        WIDTH           : integer := 8
    );
    port(
        A               : in     vl_logic_vector;
        shiftPos        : in     vl_logic_vector(2 downto 0);
        op              : in     vl_logic_vector(1 downto 0);
        result          : out    vl_logic_vector
    );
end alu_shift;
