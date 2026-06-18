library verilog;
use verilog.vl_types.all;
entity counter_nbits is
    generic(
        WIDTH           : integer := 3
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        en              : in     vl_logic;
        count           : out    vl_logic_vector
    );
end counter_nbits;
