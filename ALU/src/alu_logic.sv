module alu_logic (
    input logic     [7:0] A,
    input logic     [7:0] B,
    input logic     [1:0] op,
    output logic    [7:0] result
);

always_comb begin
    case(op)
        2'b00: result = A & B;  //AND
        2'b01: result = A | B;  //OR
        2'b10: result = A ^ B;  //XOR
    endcase
end

endmodule