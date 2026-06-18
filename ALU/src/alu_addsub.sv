module alu_addsub #(parameter WIDTH = 8)(
    input  logic signed [WIDTH-1:0] A,
    input  logic signed [WIDTH-1:0] B,
    input  logic                    sub,
    output logic signed [WIDTH-1:0] result,
    output logic                    overflow
);

always_comb begin
    if (sub == 0) begin
        result = A + B;
        overflow = (A[WIDTH-1] == B[WIDTH-1]) &&
        (result[WIDTH-1] != A[WIDTH-1]);
    end
    else begin
        result = A + (~B) + 1;
        overflow = (A[WIDTH-1] != B[WIDTH-1]) &&
           (result[WIDTH-1] != A[WIDTH-1]);
    end            
end

endmodule