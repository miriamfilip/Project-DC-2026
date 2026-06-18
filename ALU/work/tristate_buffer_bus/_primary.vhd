library verilog;
use verilog.vl_types.all;
entity tristate_buffer_bus is
    generic(
        WIDTH           : integer := 8
    );
    port(
        data_in         : in     vl_logic_vector;
        enable          : in     vl_logic;
        data_out        : out    vl_logic_vector
    );
end tristate_buffer_bus;
