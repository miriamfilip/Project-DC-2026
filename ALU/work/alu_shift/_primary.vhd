library verilog;
use verilog.vl_types.all;
entity alu_shift is
    port(
        A               : in     vl_logic_vector(7 downto 0);
        shiftPos        : in     vl_logic_vector(2 downto 0);
        op              : in     vl_logic_vector(1 downto 0);
        result          : out    vl_logic_vector(7 downto 0)
    );
end alu_shift;
