module alu_addsub (
    input  logic signed [7:0] A,
    input  logic signed [7:0] B,
    input  logic signed sub,
    output logic signed [7:0] result,
    output logic        overflow
);

always_comb begin
    if (sub == 0) begin
        result = A + B;
        overflow = (A[7] == B[7]) &&
        (result[7] != A[7]);
    end
    else begin
        result = A + (~B) + 1;
        overflow = (A[7] != B[7]) &&
           (result[7] != A[7]);
    end            
end

endmodule