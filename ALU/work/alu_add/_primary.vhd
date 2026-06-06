library verilog;
use verilog.vl_types.all;
entity alu_add is
    port(
        A               : in     vl_logic_vector(7 downto 0);
        B               : in     vl_logic_vector(7 downto 0);
        result          : out    vl_logic_vector(7 downto 0);
        overflow        : out    vl_logic
    );
end alu_add;
