`timescale 1ns/1ps

module alu_addsub_tb;

    logic signed [7:0] A;
    logic signed [7:0] B;
    logic        sub;

    logic signed [7:0] result;
    logic overflow;

    alu_addsub dut (
        .A(A),
        .B(B),
        .sub(sub),
        .result(result),
        .overflow(overflow)
    );

    initial begin

        $display("Starting adder testbench");

        // 10 + 5 = 15
        A = 8'sd10;
        B = 8'sd5;
        sub = 0;
        #10;
        $display("%0d + %0d = %0d, OV=%b",
                 A, B, result, overflow);

        // 20 + (-10) = 10
        A = 8'sd20;
        B = -8'sd10;
        #10;
        $display("%0d + %0d = %0d, OV=%b",
                 A, B, result, overflow);

        // 127 + 1 -> overflow
        A = 8'sd127;
        B = 8'sd1;
        #10;
        $display("%0d + %0d = %0d, OV=%b",
                 A, B, result, overflow);

        // -128 + (-1) -> overflow
        A = -8'sd128;
        B = -8'sd1;
        #10;
        $display("%0d + %0d = %0d, OV=%b",
                 A, B, result, overflow);

        // -128 + (-1) -> overflow
        A = 8'sd103;
        B = 8'sd45;
        sub = -1;
        #10;
        $display("%0d - %0d = %0d, OV=%b",
                 A, B, result, overflow);

        // 5 - 10 = -5
        A = 8'sd5;
        B = 8'sd10;
        #10;
        $display("%0d - %0d = %0d, OV=%b",
                A, B, result, overflow);

        // 0 - 0 = 0
        A = 8'sd0;
        B = 8'sd0;
        #10;
        $display("%0d - %0d = %0d, OV=%b",
                A, B, result, overflow);

        // 127 - (-1) = -128 (overflow)
        A = 8'sd127;
        B = -8'sd1;
        #10;
        $display("%0d - %0d = %0d, OV=%b",
                A, B, result, overflow);

        // -128 - 1 = 127 (overflow)
        A = -8'sd128;
        B = 8'sd1;
        #10;
        $display("%0d - %0d = %0d, OV=%b",
                A, B, result, overflow);


        $display("Testbench complete");
        $finish;

    end

endmodule