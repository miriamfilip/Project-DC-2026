library verilog;
use verilog.vl_types.all;
entity \register\ is
    generic(
        WIDTH           : integer := 8
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        load_en         : in     vl_logic;
        shift_en        : in     vl_logic;
        sr              : in     vl_logic;
        sl              : in     vl_logic;
        shift_dir       : in     vl_logic;
        d               : in     vl_logic_vector;
        q               : out    vl_logic_vector
    );
end \register\;
