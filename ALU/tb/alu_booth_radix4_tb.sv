//--------------------------------------------------------------------------
// Design Name: Testbench for alu_booth_radix4
// File Name: alu_booth_radix4_tb.sv
// Description: Drives M and Q into the radix-4 Booth multiplier through
//              inbus, steps through the LOAD_M -> LOAD_Q -> 4x(SCAN/SHIFT/
//              CHECK) -> OUTPUT_A -> OUTPUT_Q -> STOP sequence, captures
//              the 16-bit signed product from outbus (A high byte, then
//              Q low byte, sampled via the control bits c[7]/c[8]), and
//              compares it against the expected signed product.
// -------------------------------------------------------------------------
`timescale 1ns/1ps

module alu_booth_radix4_tb;

   logic              clk;
   logic              rst_n;
   logic              enable;
   logic signed [7:0] inbus;
   logic              done;
   logic [7:0]        outbus;

   integer pass_count = 0;
   integer fail_count = 0;

   // DUT
   alu_booth_radix4 dut (
       .clk(clk),
       .enable(enable),
       .rst_n(rst_n),
       .inbus(inbus),
       .done(done),
       .outbus(outbus)
   );

   // 10 ns clock period
   initial clk = 0;
   always #5 clk = ~clk;

   // -----------------------------------------------------------------
   // Task: run_and_check
   //   Drives one full multiplication M * Q through the DUT, sampling
   //   outbus during the cycles where the control vector asserts
   //   c[7] (drive A) / c[8] (drive Q), then compares the assembled
   //   16-bit signed product against the expected value.
   // -----------------------------------------------------------------
   task automatic run_and_check(input logic signed [7:0] M_val,
                                 input logic signed [7:0] Q_val);
      logic signed [7:0]  A_byte;
      logic signed [7:0]  Q_byte;
      logic signed [15:0] product;
      logic signed [15:0] expected;
      integer guard;

      begin
         expected = M_val * Q_val;

         // Start from a known state with enable low
         enable = 0;
         @(posedge clk);

         // Present M on inbus and pulse enable for one edge (IDLE -> C0_LOAD_M)
         inbus  = M_val;
         enable = 1;
         @(posedge clk);
         enable = 0;

         // M_reg latches on this edge (c[0] was active during C0_LOAD_M);
         // present Q in time for the C1_LOAD_Q capture edge
         @(posedge clk);
         inbus = Q_val;

         // Q_reg latches here; FSM moves into SCAN next
         @(posedge clk);

         // Step cycle by cycle until done, sampling outbus right after
         // edges where c[7] / c[8] are active.
         A_byte = '0;
         Q_byte = '0;
         guard  = 0;
         while (done !== 1'b1 && guard < 50) begin
            @(posedge clk);
            guard = guard + 1;
            #1; // allow combinational c[] / outbus to settle post-edge
            if (dut.c[7] === 1'b1) A_byte = outbus;
            if (dut.c[8] === 1'b1) Q_byte = outbus;
         end

         product = {A_byte, Q_byte};

         if (product == expected) begin
            $display("PASS: %0d * %0d = %0d (got %0d)", M_val, Q_val, expected, product);
            pass_count = pass_count + 1;
         end else begin
            $display("FAIL: %0d * %0d -> expected %0d, got %0d (A=%0d Q=%0d)",
                      M_val, Q_val, expected, product, A_byte, Q_byte);
            fail_count = fail_count + 1;
         end

         // Let the FSM settle back to IDLE before the next test
         @(posedge clk);
      end
   endtask

   initial begin
      $display("Starting alu_booth_radix4 testbench");
      rst_n  = 0;
      enable = 0;
      inbus  = 0;
      repeat (2) @(posedge clk);
      rst_n = 1;
      @(posedge clk);

     
    //   run_and_check(-8'sd128,  8'sd1);     // -128
    //   run_and_check(-8'sd3,   8'sd105);   // 16129
    //   run_and_check(8'sd127, 8'sd127);   // 16129
      run_and_check(8'b00110101, -8'sd128);   // 16384
    //   run_and_check(8'sd0,     8'sd99);    // 0
    //   run_and_check(8'sd10,   -8'sd1);     // -10

      $display("--------------------------------------------------");
      $display("Tests passed: %0d, Tests failed: %0d", pass_count, fail_count);
      $display("Testbench complete");
      $finish;
   end

endmodule // alu_booth_radix4_tb