module alu_shift(
    input  logic signed [7:0] A,
    input  logic        [2:0] shiftPos,
    input  logic        [1:0] op,
    output logic signed [7:0] result
);

    always_comb begin
        case (op)
            2'b00:      result = A << shiftPos;
            2'b01:      result = A >> shiftPos;
            2'b10:      result = A >>> shiftPos;
            default:    result = 8'b0;
        endcase
    end

endmodule