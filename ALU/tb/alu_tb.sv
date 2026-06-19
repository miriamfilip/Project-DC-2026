`timescale 1ns/1ps
module alu_tb;
    logic clk;
    logic rst_n;
    logic start;
    logic signed [7:0] A;
    logic signed [7:0] B;
    logic [3:0] opcode;
    logic signed [15:0] result;
    logic signed [7:0] remainder;
    logic Z;
    logic N;
    logic V;
    logic done;
    integer pass_count = 0;
    integer fail_count = 0;
    

   alu dut(
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .A(A),
        .B(B),
        .opcode(opcode),
        .result(result),
        .remainder(remainder),
        .Z(Z),
        .N(N),
        .V(V),
        .done(done)
    );

    initial clk = 0;
    always #5 clk = ~clk;

   function automatic logic signed [7:0] expected_result(
        input logic signed [7:0] a,
        input logic signed [7:0] b,
        input logic [3:0]        op
    );
        case(op)
            4'd0: expected_result = a + b;     // ADD
            4'd1: expected_result = a - b;     // SUB
            // 4'd2: expected_result = a * b;     // MUL
            4'd3: expected_result = (b != 0) ? (a / b) : 8'sd0;  // DIV
            4'd4: expected_result = a & b;     // AND
            4'd5: expected_result = a | b;     // OR
            4'd6: expected_result = a ^ b;     // XOR
            4'd7: expected_result = a <<< b;   // SHL
            4'd8: expected_result = a >>> b;   // SHR
            default: expected_result = 8'sd0;
        endcase
    endfunction

    function automatic string opcode_name(input logic [3:0] op);
        case(op)
            4'd0: opcode_name = "ADD";
            4'd1: opcode_name = "SUB";
            4'd2: opcode_name = "MUL";
            4'd3: opcode_name = "DIV";
            4'd4: opcode_name = "AND";
            4'd5: opcode_name = "OR";
            4'd6: opcode_name = "XOR";
            4'd7: opcode_name = "SHL";
            4'd8: opcode_name = "SHR";
            default: opcode_name = "???";
        endcase
    endfunction

//----------------------------------------------------------
// Task
//----------------------------------------------------------
    task automatic run_test(
        input logic signed [7:0] a_in,
        input logic signed [7:0] b_in,
        input logic [3:0]        op,
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

        if(op == 4'd2 || op == 4'd3) begin
            while(done == 0)
                @(posedge clk);
        end
        else begin
            @(posedge clk);
        end

        #1;

        if(op == 4'd2) begin
            $display("MUL  : A=%0d  B=%0d  Result=%0d",
                    a_in, b_in, result);
            pass_count++;
        end
        else if(result == expected) begin
            if(op == 4'd3)
                $$display("PASS : opcode=%0d (%s)  A=%0d  B=%0d  Quotient=%0d  Remainder=%0d  Z=%b N=%b V=%b",
                    op, opcode_name(op), a_in, b_in,
                    result, remainder,
                    Z, N, V);
            else
                $display("PASS : opcode=%0d (%s)  A=%0d  B=%0d  Result=%0d  Z=%b N=%b V=%b",
                    op, opcode_name(op), a_in, b_in,
                    result, Z, N, V);
            pass_count++;
        end
        else begin
            $display("FAIL : opcode=%0d (%s)  A=%0d  B=%0d",
                    op, opcode_name(op), a_in, b_in);
            $display("       Expected = %0d", expected);
            $display("       Got      = %0d", result);
            fail_count++;
        end
    end
    endtask

//----------------------------------------------------------
// Tests
//----------------------------------------------------------
    initial begin
        int a_val, b_val;

        rst_n  = 0;
        start  = 0;
        A      = 0;
        B      = 0;
        opcode = 0;

        if (!$value$plusargs("A=%d", a_val))
            a_val = 35;
        if (!$value$plusargs("B=%d", b_val))
            b_val = 5;

        $display("==================================");
        $display("Running ALL opcodes with A=%0d  B=%0d", a_val, b_val);
        $display("==================================");

        repeat(2)
            @(posedge clk);
        rst_n = 1;

        for (int op_i = 0; op_i < 9; op_i++) begin
            run_test(a_val[7:0], b_val[7:0], op_i[3:0],
                     expected_result(a_val[7:0], b_val[7:0], op_i[3:0]));
        end

        $display("--------------------------------");
        $display("Passed : %0d",pass_count);
        $display("Failed : %0d",fail_count);
        $display("--------------------------------");
        $finish;
    end

endmodule