module alu_srt2(
    input  logic              clk,
    input  logic              enable,
    input  logic              rst_n,
    input  logic signed [7:0] inbus,

    output logic              done,
    output logic [7:0]        outbus
);

    logic [14:0] c;
    logic stop;

    assign done = stop;

    tri [7:0] output_buffer;

    logic signed [8:0] P_reg;
    logic signed [7:0] A_reg;
    logic signed [7:0] B_reg;

    logic [7:0] Qm_reg;

    logic [7:0] A_input;
    logic [7:0] B_input;

    logic signed [8:0] P_next;
    logic signed [7:0] A_next;
    logic signed [7:0] B_next;

    logic [7:0] Qm_next;

    logic P_load_en;
    logic A_load_en;
    logic B_load_en;
    logic Qm_load_en;

    logic [2:0] counter_o;
    logic counter_and_o1;
    logic count_and_o;

    logic signed [8:0] remainder_final;

    counter_nbits #(.WIDTH(3)) counter(
        .clk(clk),
        .rst_n(rst_n),
        .en(c[5]),
        .count(counter_o)
    );

    and2_gate and_counter1(
        .a(counter_o[0]),
        .b(counter_o[1]),
        .y(counter_and_o1)
    );

    and2_gate and_counter2(
        .a(counter_and_o1),
        .b(counter_o[2]),
        .y(count_and_o)
    );

    logic [3:0] K;
    logic       k_is_zero;

    count_leading_zeros lzc(
        .B(B_reg),
        .K(K),
        .k_is_zero(k_is_zero)
    );

    logic p_zero;
    logic p_positive;
    logic p_negative;

    assign p_zero     = (P_reg == 9'sd0);
    assign p_positive = (~P_reg[8]) && (P_reg != 0);
    assign p_negative = P_reg[8];

    cu_srt2 Control_Unit(
        .clk(clk),
        .start(enable),
        .rst_n(rst_n),

        .count(count_and_o),

        .p_zero(p_zero),
        .p_positive(p_positive),
        .p_negative(p_negative),

        .k_is_zero(k_is_zero),

        .stop(stop),
        .c(c)
    );

    tristate_buffer_bus #(.WIDTH(8)) B_in(
        .data_in(inbus),
        .enable(c[0]),
        .data_out(B_input)
    );

    always_comb begin

        B_load_en = c[0] | c[1];

        if(c[0])
            B_next = B_input;

        else if(c[1])
            B_next = B_reg <<< K;

        else
            B_next = B_reg;

    end

    register #(.WIDTH(8)) reg_B(

        .clk(clk),
        .rst_n(rst_n),

        .load_en(B_load_en),

        .shift_en(1'b0),
        .sr(1'b0),
        .sl(1'b0),
        .shift_dir(1'b0),

        .d(B_next),
        .q(B_reg)
    );

    tristate_buffer_bus #(.WIDTH(8)) A_in(
        .data_in(inbus),
        .enable(c[1]),
        .data_out(A_input)
    );

    always_comb begin
        A_load_en = c[1] | c[2];
        if(c[1])
            A_next = A_input <<< K;
        else
            A_next = A_reg;

    end

    register #(.WIDTH(8)) reg_A(

        .clk(clk),
        .rst_n(rst_n),

        .load_en(A_load_en),

        .shift_en(1'b0),
        .sr(1'b0),
        .sl(1'b0),
        .shift_dir(1'b0),

        .d(A_next),
        .q(A_reg)
    );

    logic signed [16:0] PA_combined;
    logic signed [16:0] PA_shifted;

    logic [3:0] shift_amount;

    assign PA_combined = {P_reg, A_reg};

    always_comb begin
        if(c[1])
            shift_amount = K;
        else
            shift_amount = 4'd1;
    end

    assign PA_shifted = PA_combined <<< shift_amount;

    logic signed [8:0] B_sext;

    assign B_sext = {B_reg[7], B_reg};

    logic signed [8:0] adder_o;
    logic overflow_unused;

    alu_addsub #(.WIDTH(9)) adder_instance(
        .A(P_reg),
        .B(B_sext),
        .sub(c[4]),        
        .result(adder_o),
        .overflow(overflow_unused)

    );

    always_comb begin
        P_load_en = c[0] | c[1] | c[2] | c[3] | c[4] | c[9];
        if(c[0])
            P_next = 9'sd0;
        else if(c[1])
            P_next = PA_shifted[16:8];
        else if(c[2])
            P_next = PA_shifted[16:8];
        else if(c[3])
            P_next = adder_o;
        else if(c[4])
            P_next = adder_o;
        else if(c[9])
            P_next = adder_o;
        else
            P_next = P_reg;
    end

    register #(.WIDTH(9)) reg_P(

        .clk(clk),
        .rst_n(rst_n),

        .load_en(P_load_en),

        .shift_en(1'b0),
        .sr(1'b0),
        .sl(1'b0),
        .shift_dir(1'b0),

        .d(P_next),
        .q(P_reg)

    );

    always_comb begin
        Qm_load_en = c[4];      
        Qm_next = Qm_reg;
        if(c[4])
            Qm_next = {Qm_reg[6:0], p_negative};
    end

    register #(.WIDTH(8)) reg_Qm(
        .clk(clk),
        .rst_n(rst_n),
        .load_en(Qm_load_en),
        .shift_en(1'b0),
        .sr(1'b0),
        .sl(1'b0),
        .shift_dir(1'b0),
        .d(Qm_next),
        .q(Qm_reg)
    );

    logic [7:0] quotient_final;
    logic quotient_overflow;

    alu_addsub #(.WIDTH(8)) quotient_sub(

        .A(A_reg),
        .B(Qm_reg),

        .sub(1'b1),

        .result(quotient_final),
        .overflow(quotient_overflow)

    );

    logic signed [8:0] remainder_corrected;

    assign remainder_corrected = p_negative ? (P_reg + B_sext) : P_reg;

    logic [7:0] quotient_corrected;

    assign quotient_corrected = p_negative ? (quotient_final - 8'd1) : quotient_final;

    tristate_buffer_bus #(.WIDTH(8)) quotient_out(
        .data_in(quotient_corrected),
        .enable(c[8]),         
        .data_out(output_buffer)
    );


    assign remainder_final = k_is_zero ? remainder_corrected : (remainder_corrected >>> K);

    tristate_buffer_bus #(.WIDTH(8)) remainder_out(
        .data_in(remainder_final[7:0]),
        .enable(c[9]),          
        .data_out(output_buffer)

    );

    assign outbus = output_buffer;

endmodule