library verilog;
use verilog.vl_types.all;
entity jkff is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        j               : in     vl_logic;
        k               : in     vl_logic;
        q               : out    vl_logic;
        qn              : out    vl_logic
    );
end jkff;
