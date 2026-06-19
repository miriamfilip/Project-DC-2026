library verilog;
use verilog.vl_types.all;
entity cu_srt2 is
    port(
        clk             : in     vl_logic;
        start           : in     vl_logic;
        rst_n           : in     vl_logic;
        count           : in     vl_logic;
        p_zero          : in     vl_logic;
        p_positive      : in     vl_logic;
        p_negative      : in     vl_logic;
        k_is_zero       : in     vl_logic;
        stop            : out    vl_logic;
        c               : out    vl_logic_vector(14 downto 0)
    );
end cu_srt2;
