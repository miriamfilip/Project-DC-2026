`timescale 1ns/1ps

module alu_shift_tb;
    logic signed [7:0] A;
    logic        [2:0] shiftPos;
    logic        [1:0] op;
    logic signed [7:0] result;

    alu_shift dut (
        .A(A),
        .shiftPos(shiftPos),
        .op(op),
        .result(result)
    );

    initial begin
        $display("Starting shifter testbench");

        A = 8'sd1; shiftPos = 3'd1; op = 2'b00;
        #10;
        $display("%0d << %0d = %0d", A, shiftPos, result);

        A = -8'sd1; shiftPos = 3'd1; op = 2'b00;
        #10;
        $display("%0d << %0d = %0d", A, shiftPos, result);

        A = -8'sd1; shiftPos = 3'd1; op = 2'b01;
        #10;
        $display("%0d >> %0d = %0d (logical)", A, shiftPos, result);

        A = -8'sd1; shiftPos = 3'd1; op = 2'b10;
        #10;
        $display("%0d >>> %0d = %0d (arithmetic)", A, shiftPos, result);

        A = -8'sd128; shiftPos = 3'd1; op = 2'b10;
        #10;
        $display("%0d >>> %0d = %0d (arithmetic)", A, shiftPos, result);

        $display("Testbench complete");
        $finish;
    end
endmodule