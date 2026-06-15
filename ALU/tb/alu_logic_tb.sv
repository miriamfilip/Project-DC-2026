`timescale 1ns/1ps

module alu_logic_tb;

    logic signed [7:0] A;
    logic signed [7:0] B;
    logic        [1:0] op;

    logic signed [7:0] result;

    alu_logic dut (
        .A(A),
        .B(B),
        .op(op),
        .result(result)
    );

    initial begin

        $display("Starting adder testbench");

        // 10 & 5 = 0
        A = 8'sd10;      // 00001010
        B = 8'sd5;       // 00000101
        op = 2'b00;
        #10;
        $display("%0d & %0d = %0d",
                A, B, result);

        // 15 & 3 = 3
        A = 8'sd15;      // 00001111
        B = 8'sd3;       // 00000011
        #10;
        $display("%0d & %0d = %0d",
                A, B, result);

        // 12 | 3 = 15
        A = 8'sd12;      // 00001100
        B = 8'sd3;       // 00000011
        op = 2'b01;
        #10;
        $display("%0d | %0d = %0d",
                A, B, result);

        // -1 | 0 = -1
        A = -8'sd1;      // 11111111
        B = 8'sd0;       // 00000000
        #10;
        $display("%0d | %0d = %0d",
                A, B, result);

        // -1 ^ 15 = -16
        A = -8'sd1;      // 11111111
        B = 8'sd15;      // 00001111
        op = 2'b10;
        #10;
        $display("%0d ^ %0d = %0d",
                A, B, result);

        // -128 ^ 127 = -1
        A = -8'sd128;    // 10000000
        B = 8'sd127;     // 01111111
        #10;
        $display("%0d ^ %0d = %0d",
                A, B, result);
        $display("Testbench complete");
        $finish;
    end
endmodule