`timescale 1ns/1ps

module alu_tb;

    logic clk;
    logic rst_n;
    logic start;

    logic signed [7:0] A;
    logic signed [7:0] B;
    logic [3:0] opcode;

    logic signed [7:0] result;

    logic Z;
    logic N;
    logic V;
    logic done;

    integer pass_count = 0;
    integer fail_count = 0;

    //----------------------------------------------------------
    // DUT
    //----------------------------------------------------------

    alu dut(

        .clk(clk),
        .rst_n(rst_n),
        .start(start),

        .A(A),
        .B(B),

        .opcode(opcode),

        .result(result),

        .Z(Z),
        .N(N),
        .V(V),

        .done(done)

    );

    //----------------------------------------------------------
    // Clock
    //----------------------------------------------------------

    initial clk = 0;
    always #5 clk = ~clk;

    //----------------------------------------------------------
    // Task
    //----------------------------------------------------------

    task automatic run_test(

        input logic signed [7:0] a_in,
        input logic signed [7:0] b_in,
        input logic [3:0] op,
        input logic signed [7:0] expected

    );

    begin

        @(posedge clk);

        A      = a_in;
        B      = b_in;
        opcode = op;
        start  = 1;

        @(posedge clk);

        start = 0;

        if(op == 4'd2) begin

            while(done == 0)
                @(posedge clk);

        end

        else begin

            @(posedge clk);

        end

        #1;

        if(result == expected) begin

            $display("PASS : opcode=%0d  A=%0d  B=%0d  Result=%0d",
                      op,a_in,b_in,result);

            pass_count++;

        end

        else begin

            $display("FAIL : opcode=%0d  A=%0d  B=%0d",
                      op,a_in,b_in);

            $display("Expected = %0d",expected);
            $display("Got      = %0d",result);

            fail_count++;

        end

    end

    endtask

    //----------------------------------------------------------
    // Tests
    //----------------------------------------------------------

    initial begin

        rst_n = 0;
        start = 0;
        A = 0;
        B = 0;
        opcode = 0;

        repeat(2)
            @(posedge clk);

        rst_n = 1;

        //--------------------------------------------------
        // Arithmetic
        //--------------------------------------------------

        run_test(10,5,4'd0,15);

        run_test(10,5,4'd1,5);

        //--------------------------------------------------
        // Logic
        //--------------------------------------------------

        run_test(8'b10101010,
                 8'b11110000,
                 4'd4,
                 8'b10100000);

        run_test(8'b10101010,
                 8'b11110000,
                 4'd5,
                 8'b11111010);

        run_test(8'b10101010,
                 8'b11110000,
                 4'd6,
                 8'b01011010);

        //--------------------------------------------------
        // Shift
        //--------------------------------------------------

        run_test(8'd4,2,4'd7,16);

        run_test(8'd32,2,4'd8,8);

        //--------------------------------------------------
        // Division
        //--------------------------------------------------

        run_test(35,5,4'd3,7);

        run_test(100,4,4'd3,25);

        //--------------------------------------------------
        // Multiplication
        //--------------------------------------------------

        run_test(7,8,4'd2,56);

        run_test(-5,8,4'd2,-40);

        //--------------------------------------------------

        $display("--------------------------------");
        $display("Passed : %0d",pass_count);
        $display("Failed : %0d",fail_count);
        $display("--------------------------------");

        $finish;

    end

endmodule