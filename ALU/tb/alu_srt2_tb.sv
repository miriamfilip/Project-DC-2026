//--------------------------------------------------------------------------
// Design Name : Testbench for alu_srt2
// File Name   : alu_srt2_tb.sv
// Description : Tests the radix-2 SRT divider.
//               Dividend is loaded first, divisor second.
//               Quotient and remainder are captured from outbus.
//--------------------------------------------------------------------------

`timescale 1ns/1ps

module alu_srt2_tb;

    logic              clk;
    logic              rst_n;
    logic              enable;
    logic signed [7:0] inbus;

    logic              done;
    logic [7:0]        outbus;

    integer pass_count = 0;
    integer fail_count = 0;

    logic signed [7:0] quotient;
    logic signed [7:0] remainder;

    //-----------------------------------------------
    // DUT
    //-----------------------------------------------

    alu_srt2 dut(
        .clk(clk),
        .enable(enable),
        .rst_n(rst_n),
        .inbus(inbus),
        .done(done),
        .outbus(outbus)
    );

    //-----------------------------------------------
    // Clock
    //-----------------------------------------------

    initial clk = 0;
    always #5 clk = ~clk;

    //-----------------------------------------------
    // Test Task
    //-----------------------------------------------

    task automatic run_and_check(

        input logic signed [7:0] dividend,
        input logic signed [7:0] divisor

    );

        logic signed [7:0] expected_q;
        logic signed [7:0] expected_r;

        integer guard;

        begin

            expected_q = dividend / divisor;
            expected_r = dividend % divisor;

            //---------------------------------------
            // Start
            //---------------------------------------

            enable = 0;

            @(posedge clk);

            //---------------------------------------
            // Load Divisor (C0)
            //---------------------------------------

            inbus = divisor;

            enable = 1;

            @(posedge clk);

            enable = 0;

            //---------------------------------------
            // Load Dividend (C1)
            //---------------------------------------

            @(posedge clk);

            inbus = dividend;

            @(posedge clk);

            //---------------------------------------
            // Wait for completion
            //---------------------------------------

            quotient  = 0;
            remainder = 0;

            guard = 0;

            while(done !== 1'b1 && guard < 100) begin

                @(posedge clk);

                guard++;

                #1;

                if(dut.c[8])
                    quotient = outbus;

                if(dut.c[9])
                    remainder = outbus;

            end

            //---------------------------------------
            // Compare
            //---------------------------------------

            if((quotient == expected_q) &&
               (remainder == expected_r))
            begin

                $display("PASS: %0d / %0d = %0d R=%0d",
                         dividend,
                         divisor,
                         quotient,
                         remainder);

                pass_count++;

            end

            else begin

                $display("FAIL: %0d / %0d",
                         dividend,
                         divisor);

                $display(" Expected Q=%0d R=%0d",
                         expected_q,
                         expected_r);

                $display(" Got      Q=%0d R=%0d",
                         quotient,
                         remainder);

                fail_count++;

            end

            @(posedge clk);

        end

    endtask

    //-----------------------------------------------
    // Test Sequence
    //-----------------------------------------------

    initial begin

        $display("------------------------------------------");
        $display("Starting alu_srt2 testbench");
        $display("------------------------------------------");

        rst_n  = 0;
        enable = 0;
        inbus  = 0;

        repeat(2)
            @(posedge clk);

        rst_n = 1;

        @(posedge clk);

        //---------------------------------------
        // Positive
        //---------------------------------------

        run_and_check(35,5);
        run_and_check(100,3);
        run_and_check(127,2);
        run_and_check(64,8);

        //---------------------------------------
        // Signed
        //---------------------------------------

        run_and_check(-35,5);
        run_and_check(35,-5);
        run_and_check(-35,-5);

        //---------------------------------------
        // Edge cases
        //---------------------------------------

        run_and_check(0,5);
        run_and_check(127,1);
        run_and_check(-128,2);

        //---------------------------------------

        $display("------------------------------------------");
        $display("Tests Passed : %0d",pass_count);
        $display("Tests Failed : %0d",fail_count);
        $display("------------------------------------------");

        $finish;

    end

endmodule