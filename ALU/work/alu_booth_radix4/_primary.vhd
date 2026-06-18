library verilog;
use verilog.vl_types.all;
entity alu_booth_radix4 is
    port(
        clk             : in     vl_logic;
        enable          : in     vl_logic;
        rst_n           : in     vl_logic;
        inbus           : in     vl_logic_vector(7 downto 0);
        done            : out    vl_logic;
        outbus          : out    vl_logic_vector(7 downto 0);
        product         : out    vl_logic_vector(15 downto 0)
    );
end alu_booth_radix4;
