module alu_and (
    input logic     [7:0] A,
    input logic     [7:0] B,
    input logic     [1:0] op,
    output logic    [7:0] O
);

always_comb begin
    case(op)
        2'b00:  O = A & B;  //AND
        2'b01:  O = A | B;  //OR
        2'b10:  O = A ^ B//XOR
    endcase
end

endmodule