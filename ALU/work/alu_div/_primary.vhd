library verilog;
use verilog.vl_types.all;
entity alu_div is
    port(
        A               : in     vl_logic_vector(7 downto 0);
        B               : in     vl_logic_vector(7 downto 0);
        quotient        : out    vl_logic_vector(7 downto 0);
        remainder       : out    vl_logic_vector(7 downto 0);
        divide_by_zero  : out    vl_logic
    );
end alu_div;
