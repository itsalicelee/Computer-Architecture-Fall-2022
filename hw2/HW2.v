module ALU(
    clk,
    rst_n,
    valid,
    ready,
    mode,
    in_A,
    in_B,
    out
);

    // Definition of ports
    input         clk, rst_n;
    input         valid;
    input  [1:0]  mode; // mode: 0: mulu, 1: divu, 2: shift, 3: avg
    output        ready;
    input  [31:0] in_A, in_B;
    output [63:0] out;

    // Definition of states
    parameter IDLE = 3'd0;
    parameter MUL  = 3'd1;
    parameter DIV  = 3'd2;
    parameter SHIFT = 3'd3;
    parameter AVG = 3'd4;
    parameter OUT  = 3'd5;

    // Todo: Wire and reg if needed
    reg  [ 2:0] state, state_nxt;
    reg  [ 4:0] counter, counter_nxt;
    reg  [63:0] shreg, shreg_nxt;
    reg  [31:0] alu_in, alu_in_nxt;
    reg  [32:0] alu_out;  // it's not a real register, it's wire!
    // Todo: Instatiate any primitives if needed
    reg         dividend_flag;  // it's not a real register, it's wire!
    reg         rdy, rdy_nxt;
    // Todo 5: Wire assignments
    assign out = shreg;
    assign ready = rdy;
    
    always @(*) begin
        case(state)
            IDLE: begin
               rdy_nxt = 0;
            end
            MUL : begin
                if(counter == 5'd31) rdy_nxt = 1;
                else rdy_nxt = 0;
            end
            DIV : begin
                if(counter == 5'd31) rdy_nxt = 1;
                else rdy_nxt = 0;
            end
            SHIFT : rdy_nxt = 1;
            AVG : rdy_nxt = 1;
            OUT : rdy_nxt = 0;
            default : rdy_nxt = 0;
        endcase
    end
    
    // Combinational always block // use "=" instead of "<=" in  always @(*) begin
    // Todo 1: Next-state logic of state machine
    always @(*) begin
        case(state)
            IDLE: begin
                if(!valid) state_nxt = IDLE; 
                else begin
                    case(mode)
                        2'd0: state_nxt = MUL;
                        2'd1: state_nxt = DIV;
                        2'd2: state_nxt = SHIFT;
                        2'd3: state_nxt = AVG;
                        default: state_nxt = IDLE;
                    endcase
                end
            end
            MUL : begin
                if(counter == 5'd31) state_nxt = OUT;
                else state_nxt = MUL;
            end
            DIV : begin
                if(counter == 5'd31) state_nxt = OUT;
                else state_nxt = DIV;
            end
            SHIFT : state_nxt = OUT;
            AVG : state_nxt = OUT;
            OUT : state_nxt = IDLE;
            default : state_nxt = IDLE;
        endcase
    end
    // Todo 2: Counter
    // Counter counts from 0 to 31 when the state is MUL or DIV
    // Otherwise, keep it zero
    always @(*) begin
        if(state == MUL || state == DIV) begin
            counter_nxt = counter + 1;
        end
        else counter_nxt = 0;
    end

    
    // ALU input
    always @(*) begin
        case(state)
            IDLE: begin
                if (valid) alu_in_nxt = in_B;
                else       alu_in_nxt = 0;
            end
            OUT : alu_in_nxt = 0;
            default: alu_in_nxt = alu_in;
        endcase
    end

    // Todo 3: ALU output & dividend flag
    always @(*) begin
        alu_out = 0;
        dividend_flag = 0;
        case(state)
            MUL: begin
                if(shreg[0] == 1) begin
                    alu_out = shreg[63:32] + alu_in;
                    // $signed(in_A) + $signed(in_B)
                end
                else begin
                    alu_out = shreg[63:32];
                end
            end
            DIV: begin
                // if remainder goes < 0, add divisor back
                dividend_flag = (shreg[63:32] >= alu_in);
                if(dividend_flag) begin
                    alu_out = shreg[63:32] - alu_in;
                end 
                else begin
                    alu_out = shreg[63:32];
                end
            end
            SHIFT: begin
                alu_out = shreg[31:0] >> alu_in[2:0];
            end
            AVG: begin
                alu_out = (shreg[31:0] + alu_in) >> 1;
            end  
        endcase
    end
    
    // Todo 4: Shift register
    always @(*) begin
        case(state)
            IDLE: begin
                if(!valid) shreg_nxt = 0; 
                else begin
                    if(mode == 2'd1)begin
                        shreg_nxt = {{31{1'b0}}, in_A, {1'b0}}; 
                    end
                    else begin
                        shreg_nxt = {{32{1'b0}}, in_A};
                    end
                end
            end
            MUL: begin
                shreg_nxt = {alu_out, shreg[31:1]};
            end
            DIV: begin
                if(counter == 31)begin
                    if(dividend_flag)begin
                        shreg_nxt = {alu_out[31:0], shreg[30:0], {1'b1}};
                    end
                    else begin
                        shreg_nxt = {alu_out[31:0], shreg[30:0], {1'b0}};
                    end
                end
                else begin
                    if(dividend_flag)begin
                        shreg_nxt = {alu_out[30:0], shreg[31:0], {1'b1}};
                    end
                    else begin
                        shreg_nxt = {alu_out[30:0], shreg[31:0], {1'b0}};
                    end
                end
            end
            SHIFT: begin
                shreg_nxt = {32'b0, alu_out[31:0]};
            end
            AVG: begin
                shreg_nxt = {32'b0, alu_out[31:0]};
            end  
            OUT: begin
                shreg_nxt = shreg;
            end
            default: begin
                shreg_nxt = shreg;
            end
        endcase
    end

    // Todo: Sequential always block
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            counter <= 0;
            shreg <= 0;
            alu_in <= 0;
            rdy <= 0;
        end
        else begin
            state <= state_nxt;
            counter <= counter_nxt;
            shreg <= shreg_nxt;
            alu_in <= alu_in_nxt;
            rdy <= rdy_nxt;
        end
    end

endmodule
