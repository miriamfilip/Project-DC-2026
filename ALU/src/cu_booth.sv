`timescale 1ns/1ps
module cu_booth (
	   input logic	clk,
	   input logic	start,
	   input logic	rst_n,
	   input logic	count,
	   
	   input logic  q1,
	   input logic	q0,
	   input logic	qm1,

	   input logic input_is_zero,
	   
	   output logic	stop,
	   output logic [8:0] c
	   );
      typedef enum logic [3:0] {
                             IDLE,
                             C0_LOAD_M,
                             C1_LOAD_Q,
                             SCAN,
                             SHIFT,
                             CHECK,
                             OUTPUT_A,
                             OUTPUT_Q,
                             STOP
                             } state_t;
   state_t state, next;

   always_ff @(posedge clk or negedge rst_n) begin
      if (!rst_n)
		state <= IDLE;
      else
		state <= next;
   end
      
   
   always_comb begin
      next = state;
      stop = 0;
      c = 9'b0;
      case (state)
		IDLE: begin
			if (start)
				next = C0_LOAD_M;
		end
		C0_LOAD_M: begin
			c[0] = 1;
			next = C1_LOAD_Q;
		end
		C1_LOAD_Q: begin
			c[1] = 1;
			next = SCAN;
			if(input_is_zero == 1) begin
				$display("Skipping uneccessary steps");
				next = OUTPUT_A;
			end
		end
		SCAN: begin
			case ({q1,q0,qm1})
				3'b000: begin
				end
				3'b001: begin
					c[2] = 1;
				end
				3'b010: begin
					c[2] = 1;	
				end
				3'b011: begin
					c[2] = 1;	
					c[4] = 1;
				end	
				3'b100: begin
					c[2] = 1;
					c[3] = 1;	
					c[4] = 1;
				end	
				3'b101: begin
					c[2] = 1;
					c[3] = 1;	
				end
				3'b110: begin
					c[2] = 1;
					c[3] = 1;	
				end
				3'b111: begin
				end
			endcase

			next = SHIFT;
		end
		SHIFT: begin
			c[5] = 1;
			next = CHECK;	   
		end
		CHECK: begin
			if (count)
				next = OUTPUT_A;
			else begin
				c[6] = 1;
				next = SCAN;
			end
		end
		OUTPUT_A:begin
			c[7] = 1;
			next = OUTPUT_Q;
		end
		OUTPUT_Q:begin
			c[8] = 1;
			next = STOP;
		end 
		STOP: begin
			stop = 1;  
			next = IDLE;
		end
	
      endcase //case
   end //always_comb
endmodule //cu_booth_radix4
  
