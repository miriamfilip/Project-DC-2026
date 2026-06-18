module alu_booth_radix4(
    input  logic              clk,
    input  logic              enable,
    input  logic              rst_n,
    input  logic signed [7:0] inbus,
    output logic              done,
    output logic [7:0]        outbus,
    output logic signed [15:0] product
);

    logic [8:0] c;
    logic       stop;
    logic input_is_zero;

    tri [7:0]   output_buffer;

    //Register outputs
    logic signed [8:0] A_reg;
    logic signed [7:0] M_reg;
    logic signed [8:0] Q_reg;

    logic signed [7:0] M_input;

    logic [1:0] counter_o;
    logic       count_and_o;

    
    logic signed [8:0] M_sext;
    logic signed [8:0] M_x2;
    logic signed [8:0] mag_select_o;
    logic signed [8:0] adder_o;

    logic signed [8:0] A_next;
    logic signed [8:0] Q_next;
    logic              A_load_en;
    logic              Q_load_en;
    
    logic signed [17:0] AQ_combined;
    logic signed [17:0] AQ_shifted;

    cu_booth Control_Unit (
        .clk(clk),
        .start(enable),
        .rst_n(rst_n),
        .count(count_and_o),
        .q1(Q_reg[2]),
        .q0(Q_reg[1]),
        .qm1(Q_reg[0]),
        .input_is_zero(input_is_zero),
        .stop(stop),
        .c(c)        
    );

    assign done = stop;

    counter_nbits #(.WIDTH(2)) counter (
        .clk(clk),
        .rst_n(rst_n),
        .en(c[6]),
        .count(counter_o)
    );

    and2_gate and_counter(
        .a(counter_o[0]),
        .b(counter_o[1]),
        .y(count_and_o)
    );

    //REGISTER M

    tristate_buffer_bus #(.WIDTH(8)) M_in(
        .data_in(inbus),
        .enable(c[0]),
        .data_out(M_input)
    );

    register #(.WIDTH(8)) reg_M (
        .clk(clk),
        .rst_n(rst_n),
        .load_en(c[0]),
        .shift_en(1'b0),
        .sr(1'b0),
        .sl(1'b0),
        .shift_dir(1'b0),
        .d(M_input),
        .q(M_reg)
    );

    assign M_sext = {M_reg[7], M_reg};

    alu_shift #(.WIDTH(9)) shift_2M(
        .A(M_sext),
        .shiftPos(3'd1),
        .op(2'b00),        
        .result(M_x2)
    );

    mux2 #(.WIDTH(9)) mux_magnitude (
        .d0(M_sext),
        .d1(M_x2),
        .s(c[4]),
        .y(mag_select_o)
    );

    logic overflow_unused;

   alu_addsub #(.WIDTH(9)) adder_instance (
        .A(A_reg),
        .B(mag_select_o),
        .sub(c[3]),
        .result(adder_o),
        .overflow(overflow_unused)
   );
   
    //REGISTER A


    assign AQ_combined = {A_reg, Q_reg};
    assign AQ_shifted  = AQ_combined >>> 2;

    always_comb begin
        A_load_en = c[0] | c[2] | c[5];
        if(c[0])
            A_next = 9'sd0;
        else if (c[5])
            A_next = AQ_shifted[17:9];
        else
            A_next = adder_o;
    end

    register #(.WIDTH(9)) reg_A (
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

    //REGISTER Q

    logic signed [7:0] Q_input;

    tristate_buffer_bus #(.WIDTH(8)) Q_in (
        .data_in(inbus),
        .enable(c[1]),
        .data_out(Q_input)
    );

    always_comb begin
        Q_load_en = c[0] | c[1] | c[5];
        if(c[1])
            Q_next = {Q_input, 1'b0};
        else if(c[5])
            Q_next = AQ_shifted[8:0];
        else
            Q_next = {Q_reg[8:1], 1'b0};
    end

    register #(.WIDTH(9)) q_Q(
        .clk(clk),
        .rst_n(rst_n),
        .load_en(Q_load_en),
        .shift_en(1'b0),
        .sr(1'b0),
        .sl(1'b0),
        .shift_dir(1'b0),
        .d(Q_next),
        .q(Q_reg)
    );

    assign input_is_zero = (Q_reg == 9'b0) || (M_reg == 8'b0);
    
    logic [7:0] A_or_0;
    logic [7:0] Q_or_0;

    mux2 #(.WIDTH(8)) mux_A_or_0 (
        .d0(A_reg[7:0]),
        .d1(8'b00000000),
        .s(input_is_zero),
        .y(A_or_0)
    );

    mux2 #(.WIDTH(8)) mux_Q_or_0 (
        .d0(Q_reg[8:1]),
        .d1(8'b00000000),
        .s(input_is_zero),
        .y(Q_or_0)
    );

    //OUTPUT BUS
    tristate_buffer_bus #(.WIDTH(8)) A_out(
        .data_in(A_or_0[7:0]),
        .enable(c[7]),
        .data_out(output_buffer)
    );

    tristate_buffer_bus #(.WIDTH(8)) Q_out(
        .data_in(Q_or_0[7:0]),
        .enable(c[8]),
        .data_out(output_buffer)
    );

    assign outbus = output_buffer;  
    assign product = {A_reg[7:0], Q_reg[8:1]};

always @(posedge clk) begin
    $display("state=%0d c=%b count=%0d A=%0d Q=%b M=%0d adder=%0d",
        Control_Unit.state,
        c,
        counter_o,
        A_reg,
        Q_reg,
        M_reg,
        adder_o);
end

endmodule