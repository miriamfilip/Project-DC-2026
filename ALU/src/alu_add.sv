module alu_add (
    input  logic signed [7:0] A,
    input  logic signed [7:0] B,

    output logic signed [7:0] result,
    output logic              overflow
);

always_comb begin
    result = A + B;

    overflow = (A[7] == B[7]) &&
               (result[7] != A[7]);
end

endmodule