module alu_div(
    input  logic signed [7:0] A,
    input  logic signed [7:0] B,

    output logic signed [7:0] quotient,
    output logic signed [7:0] remainder,
    output logic              divide_by_zero
);

always_comb begin

    if (B == 0) begin
        quotient       = 8'sd0;
        remainder      = A;
        divide_by_zero = 1'b1;
    end
    else begin
        quotient       = A / B;
        remainder      = A % B;
        divide_by_zero = 1'b0;
    end

end

endmodule