module tristate_buffer_bus #(parameter WIDTH = 8)
   (
    input logic [WIDTH-1:0] data_in,
    input logic enable,
    output tri [WIDTH-1:0] data_out
    );
   assign data_out = (enable)?data_in : 'z;
   
endmodule