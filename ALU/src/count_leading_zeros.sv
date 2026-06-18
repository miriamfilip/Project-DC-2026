module count_leading_zeros (
    input  logic [7:0] B,
    output logic [3:0] K,
    output logic       k_is_zero
);

always_comb begin

    casez(B)

        8'b1???????: K = 4'd0;
        8'b01??????: K = 4'd1;
        8'b001?????: K = 4'd2;
        8'b0001????: K = 4'd3;
        8'b00001???: K = 4'd4;
        8'b000001??: K = 4'd5;
        8'b0000001?: K = 4'd6;
        8'b00000001: K = 4'd7;
        default:     K = 4'd8;   // B == 0

    endcase

    k_is_zero = (K == 0);

end

endmodule