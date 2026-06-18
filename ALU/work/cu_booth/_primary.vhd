library verilog;
use verilog.vl_types.all;
entity cu_booth is
    port(
        clk             : in     vl_logic;
        start           : in     vl_logic;
        rst_n           : in     vl_logic;
        count           : in     vl_logic;
        q1              : in     vl_logic;
        q0              : in     vl_logic;
        qm1             : in     vl_logic;
        input_is_zero   : in     vl_logic;
        stop            : out    vl_logic;
        c               : out    vl_logic_vector(8 downto 0)
    );
end cu_booth;
