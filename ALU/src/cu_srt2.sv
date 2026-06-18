module cu_srt2(
	   input logic	        clk,
	   input logic          start,
	   input logic	        rst_n,
	   input logic          count,

       input logic          p_zero,
       input logic          p_positive,
       input logic          p_negative,

       input logic          k_is_zero,

       output logic         stop,
       output logic [14:0]  c
);

typedef enum logic [3:0] {
                             IDLE,
                             C0_LOAD_B,
                             C1_LOAD_A,
                             SCAN,
                             SHIFT,
                             CHECK,
                             CORRECT,
                             DENORMALIZE,
                             OUTPUT_Q,
                             OUTPUT_R,
                             STOP
} state_t;
state_t state, next;

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        state <= IDLE;
    else 
        state <= next;
end

always_comb begin
    next = state;
    stop = 1'b0;
    c    = 15'b0;

    case(state)
        IDLE: begin
            if(start)
                next = C0_LOAD_B;
        end
        C0_LOAD_B: begin
            c[0] = 1'b1;
            next = C1_LOAD_A;
        end
        C1_LOAD_A: begin 
            c[1] = 1'b1;
            next = SCAN;
        end
        SCAN: begin
            if(p_zero)
                c[6] = 1'b1;
            else if(p_positive) begin
                c[4] = 1'b1;
                c[7] = 1'b1;
            end
            else begin
                c[3] = 1'b1;
                c[8] = 1'b1;
            end
            next = SHIFT;
        end
        SHIFT: begin
            c[2] = 1'b1;
            next = CHECK;
        end
        CHECK: begin
            c[5] = 1'b1;
            if(count)
                next = CORRECT;
            else
                next = SCAN;
        end
        CORRECT: begin
            if(p_negative) begin
                c[9] = 1'b1;
                c[10] = 1'b1;
            end

            next = DENORMALIZE;
        end
        DENORMALIZE: begin 
            if(!k_is_zero)
                c[11] = 1'b1;
            next = OUTPUT_Q;
        end
        OUTPUT_Q: begin
            c[12] = 1'b1;
            next = OUTPUT_R;
        end
        OUTPUT_R: begin
            c[13] = 1'b1;
            next = STOP;
        end
        STOP: begin
            stop = 1'b1;
            c[14] = 1'b1;
            next = IDLE;
        end

    endcase

end


endmodule