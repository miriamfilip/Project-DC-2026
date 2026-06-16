module alu_booth_radix4(
    input logic           clk,
    input logic           rst_n,
    input logic           start,

    input logic     [7:0] Q;
    input logic     Qext;
    input logic     [7:0] M;
    output logic signed [15:0] product,
    output logic              done
);

    logic [8:0] A_in, A_out;
    logic [8:0] M_in = M, M_out;
    logic [7:0] Q_in = Q, Q_out;
    logic       q_min1_in, q_min1_out;

    logic A_load = 1, A_shift;
    logic M_load;
    logic Q_load, Q_shift;

    register #(.WIDTH(9)) A_reg (
        .clk(clk),
        .rst_n(rst_n),
        .load_en(A_load),
        .shift_en(A_shift),
        .sr(A_out[8]),
        .sl(1'b0),
        .shift_dir(1'b1),
        .d(A_in),
        .q(A_out)
    );


    register #(.WIDTH(9)) M_reg (
        .clk(clk),
        .rst_n(rst_n),
        .load_en(M_load),
        .shift_en(1'b0),
        .sr(M_out[8]),
        .sl(1'b0),
        .shift_dir(1'b1),
        .d(M_in),
        .q(M_out)
    );

    register #(.WIDTH(8)) Q_reg (
        .clk(clk),
        .rst_n(rst_n),
        .load_en(Q_load),
        .shift_en(1'b0),
        .sr(Q_out[7]),
        .sl(1'b0),
        .shift_dir(1'b1),
        .d(Q_in),
        .q(Q_out)
    );

    logic signed [17:0] booth_reg;
    logic signed [17:0] booth_shifted;

    assign booth_reg = {A_temp, Q_out, q_min1_out};

    alu_shift #(.WIDTH(18)) booth_shifter (
        .A(booth_reg),
        .shift_pos(3'd2),
        .op(2'b10),
        .result(booth_shifted)
    );

    assign A_in    = booth_shifted[17:9];
    assign Q_in    = booth_shifted[8:1];
    assign qext_in = booth_shifted[0];

always_comb begin
    case(Q[1:0],Qext):
        3'b000:
        3'b001: begin
            booth_operand = 9'sd0;
            booth_sub = 0;
        end
        3'b010:
        3'b011:
        3'b100:
        3'b101:
        3'b110:
        3'b111:
    endcase
end

endmodule