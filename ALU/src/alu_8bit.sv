`timescale 1ns/1ps

module alu(

    input logic clk,
    input logic rst_n,
    input logic start,

    input logic signed [7:0] A,
    input logic signed [7:0] B,

    input logic [3:0] opcode,

    output logic signed [15:0] result,

    output logic Z,
    output logic N,
    output logic V,

    output logic done

);

    typedef enum logic [2:0]{
        IDLE,
        LOAD_M,
        WAIT_ONE,
        LOAD_Q,
        WAIT_MULT,
        FINISH
    } mult_state_t;

    mult_state_t state,next;

    logic        mult_enable;
    logic [7:0]  mult_bus;

    //--------------------------------------------------------
    // Opcodes
    //--------------------------------------------------------

    localparam ADD = 4'd0;
    localparam SUB = 4'd1;
    localparam MUL = 4'd2;
    localparam DIV = 4'd3;
    localparam AND = 4'd4;
    localparam OR  = 4'd5;
    localparam XOR = 4'd6;
    localparam SLL = 4'd7;
    localparam SRL = 4'd8;


    logic signed [7:0] addsub_result;
    logic overflow_addsub;

    alu_addsub #(.WIDTH(8)) ADDER(

        .A(A),
        .B(B),

        .sub(opcode==SUB),

        .result(addsub_result),

        .overflow(overflow_addsub)

    );

    logic [7:0] logic_result;

    alu_logic LOGIC(
        .A(A),
        .B(B),
        .op(opcode[1:0]),
        .result(logic_result)
    );

    logic [7:0] shift_result;

    alu_shift #(.WIDTH(8)) SHIFT(

        .A(A),

        .shiftPos(B[2:0]),

        .op(opcode==SLL ? 2'b00 : 2'b01),

        .result(shift_result)

    );

    logic signed [7:0]  mul_out;
    logic signed [15:0] mul_product;
    logic               mul_done;

    alu_booth_radix4 MULT(
        .clk(clk),
        .rst_n(rst_n),
        .enable(mult_enable),
        .inbus(mult_bus),
        .done(mul_done),
        .outbus(mul_out),
        .product(mul_product)
    );

   logic signed [7:0] div_q;
    logic signed [7:0] div_r;
    logic               div_zero;

    alu_div divider(

        .A(A),
        .B(B),

        .quotient(div_q),
        .remainder(div_r),
        .divide_by_zero(div_zero)

    );

    always_ff @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            state <= IDLE;
        else
            state <= next;
    end

    always_comb begin

        next        = state;
        mult_enable = 1'b0;
        mult_bus    = 8'd0;

        case(state)

            IDLE:
                if(start && opcode==MUL)
                    next = LOAD_M;

            LOAD_M: begin
                mult_enable = 1'b1;
                mult_bus    = A;
                next        = WAIT_ONE;
            end

            WAIT_ONE: begin
                mult_enable = 1'b0;
                mult_bus    = A;
                next        = LOAD_Q;
            end

            LOAD_Q: begin
                mult_enable = 1'b0;
                mult_bus    = B;
                next        = WAIT_MULT;
            end

            WAIT_MULT: begin
                mult_bus = B;
                if(mul_done)
                    next = FINISH;
            end

            FINISH:
                next = IDLE;

        endcase

    end

    always_comb begin

        result = 0;
        done   = 1;

        case(opcode)

            ADD,
            SUB:
            begin
                result = addsub_result;
            end

            AND,
            OR,
            XOR:
            begin
                result = logic_result;
            end

            SLL,
            SRL:
            begin
                result = shift_result;
            end

            MUL:
            begin
                result = mul_product;
                done   = mul_done;
            end

            DIV: begin
                result = div_q;
                done   = 1'b1;
            end

            default:
                result = 0;

        endcase

    end
    assign Z = (result == 0);
    assign N = result[7];
    assign V = (opcode==ADD || opcode==SUB) ? overflow_addsub : 1'b0;

endmodule