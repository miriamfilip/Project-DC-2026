library verilog;
use verilog.vl_types.all;
entity count_leading_zeros is
    port(
        B               : in     vl_logic_vector(7 downto 0);
        K               : out    vl_logic_vector(3 downto 0);
        k_is_zero       : out    vl_logic
    );
end count_leading_zeros;
