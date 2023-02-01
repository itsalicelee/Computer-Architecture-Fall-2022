// Your code
module CHIP(clk,
            rst_n,
            // For mem_D
            mem_wen_D,
            mem_addr_D,
            mem_wdata_D,
            mem_rdata_D,
            // For mem_I
            mem_addr_I,
            mem_rdata_I
    );
    //==== I/O Declaration ========================
    input         clk, rst_n ;
    // For mem_D
    output        mem_wen_D  ;
    output [31:0] mem_addr_D ;
    output [31:0] mem_wdata_D;
    input  [31:0] mem_rdata_D;
    // For mem_I
    output [31:0] mem_addr_I ;
    input  [31:0] mem_rdata_I;

    //==== Reg/Wire Declaration ===================
    //---------------------------------------//
    // Do not modify this part!!!            //
    // Exception: You may change wire to reg //
    reg    [31:0] PC          ;              //
    reg    [31:0] PC_nxt      ;              //
    reg           regWrite    ;              //
    reg    [ 4:0] rs1, rs2, rd;              //
    wire   [31:0] rs1_data    ;              //
    wire   [31:0] rs2_data    ;              //
    reg    [31:0] rd_data     ;              //
    //---------------------------------------//
    //====== op code ======
    // R-type
    localparam ADD   = 7'b0110011;
    localparam SUB   = 7'b0110011;
    localparam XOR   = 7'b0110011;
    localparam MUL   = 7'b0110011;
    // I-type
    localparam ADDI  = 7'b0010011;
    localparam SLTI  = 7'b0010011;
    localparam LW    = 7'b0000011;
    // B-type
    localparam BEQ   = 7'b1100011;
    // S-type
    localparam SW    = 7'b0100011;
    // J-type
    localparam JAL   = 7'b1101111;
    localparam JALR  = 7'b1100111;
    // U-type
    localparam AUIPC = 7'b0010111;
    //====== funct3 ======
    localparam ADD_FUNC3  = 3'b000;
    localparam SUB_FUNC3  = 3'b000;
    localparam XOR_FUNC3  = 3'b100;
    localparam ADDI_FUNC3 = 3'b000;
    localparam SLTI_FUNC3 = 3'b010;
    localparam MUL_FUNC3  = 3'b000;

    //====== funct7 ======
    localparam ADD_FUNC7 = 7'b0000000;
    localparam SUB_FUNC7 = 7'b0100000;
    localparam XOR_FUNC7 = 7'b0000000;
    localparam MUL_FUNC7 = 7'b0000001;

    // FSM state
    localparam S_IDLE        = 0;
    localparam S_EXEC        = 1;
    localparam S_EXEC_MULDIV = 2;

    // Todo: other wire/reg
    reg  [6:0 ] op_code_w;
    reg  [31:0] inst_w;
    reg  [1:0 ] state_w, state_r;
    reg  [2:0 ] funct3_w;
    reg  [6:0 ] funct7_w;
    reg  [31:0] imm_w;
    reg  [31:0] mem_addr_D_w, mem_wdata_D_w;
    reg         mem_wen_D_w;
    
    reg         mulDiv_vld_w;
    wire        mulDiv_rdy_w;
    reg  [1:0]  mulDiv_mode_w;
    reg  [31:0] mulDiv_in_A_w, mulDiv_in_B_w;
    wire [63:0] mulDiv_out_w;
    //==== Submodule Connection ===================
    //---------------------------------------//
    // Do not modify this part!!!            //
    reg_file reg0(                           //
        .clk(clk),                           //
        .rst_n(rst_n),                       //
        .wen(regWrite),                      //
        .a1(rs1),                            //
        .a2(rs2),                            //
        .aw(rd),                             //
        .d(rd_data),                         //
        .q1(rs1_data),                       //
        .q2(rs2_data));                      //
    //---------------------------------------//

    // Todo: other submodules
    mulDiv mulDiv0(
        .clk(clk),
        .rst_n(rst_n),
        .valid(mulDiv_vld_w),
        .ready(mulDiv_rdy_w),
        .mode(mulDiv_mode_w),
        .in_A(mulDiv_in_A_w),
        .in_B(mulDiv_in_B_w),
        .out(mulDiv_out_w)
    );

    //==== Assignment =============================
    assign mem_addr_I = PC;
    assign mem_addr_D = mem_addr_D_w;
    assign mem_wdata_D = mem_wdata_D_w;
    assign mem_wen_D = mem_wen_D_w;
    //==== Combinational Part =====================
    // Todo: any combinational/sequential circuit    
    // Decode Instruction
    always @(*) begin
        inst_w = mem_rdata_I;
        PC_nxt = PC + 3'd4;
        op_code_w = inst_w[6:0];
        funct3_w = inst_w[14:12];
        funct7_w = inst_w[31:25];
        rs1 = inst_w[19:15];
        rs2 = inst_w[24:20];
        rd  = inst_w[11:7];
        rd_data = 0;
        imm_w = 0;
        mem_addr_D_w = 0;
        mem_wdata_D_w = 0;
        mem_wen_D_w = 0;
        regWrite = 0;
        mulDiv_vld_w = 0;
        mulDiv_in_A_w = rs1_data;
        mulDiv_in_B_w = rs2_data;
        mulDiv_mode_w = 0;
        case (op_code_w)
            7'b0110011: begin
                regWrite = 1'b1;
                case ({funct7_w, funct3_w})
                    {ADD_FUNC7, ADD_FUNC3}: begin
                        rd_data = $signed(rs1_data) + $signed(rs2_data);
                    end
                    {SUB_FUNC7, SUB_FUNC3}: begin
                        rd_data = $signed(rs1_data) - $signed(rs2_data);
                    end
                    {XOR_FUNC7, XOR_FUNC3}: begin
                        rd_data = rs1_data ^ rs2_data;
                    end
                    {MUL_FUNC7, MUL_FUNC3}: begin
                        if(mulDiv_rdy_w) begin
                           PC_nxt = PC + 3'd4; 
                            regWrite = 1'b1;
                        end
                        else begin
                            PC_nxt = PC;
                            regWrite = 0;
                        end
                        mulDiv_vld_w = 1'b1;
                        mulDiv_mode_w = 1'b0;
                        rd_data = mulDiv_out_w[31:0];
                    end
                endcase
            end
            7'b0010011: begin
                regWrite = 1'b1;
                imm_w[11:0] = inst_w[31:20];
                case (funct3_w)
                    ADDI_FUNC3: begin
                        rd_data = $signed(rs1_data) + $signed(imm_w[11:0]);
                    end
                    SLTI_FUNC3: begin
                        if($signed(rs1_data) < $signed(imm_w[11:0])) rd_data = 32'd1;
                        else                                         rd_data = 32'd0;
                    end
                endcase
            end
            LW: begin
                regWrite = 1'b1;
                imm_w[11:0] = inst_w[31:20];
                mem_addr_D_w = $signed({1'b0, rs1_data}) + $signed(imm_w[11:0]);
                rd_data = mem_rdata_D;
            end
            BEQ: begin
                imm_w[12:0] = {inst_w[31], inst_w[7], inst_w[30:25], inst_w[11:8], 1'b0};
                if(rs1_data == rs2_data) PC_nxt = $signed({1'b0, PC}) + $signed(imm_w[12:0]);
                else                     PC_nxt = PC + 3'd4;
            end
            SW: begin
                mem_wen_D_w = 1'b1;
                imm_w[4:0] = inst_w[11:7];
                imm_w[11:5] = inst_w[31:25];
                mem_addr_D_w = $signed({1'b0, rs1_data}) + $signed(imm_w[11:0]);
                mem_wdata_D_w = rs2_data;
            end
            AUIPC: begin
                regWrite = 1'b1;
                imm_w[31:12] = inst_w[31:12];
                rd_data = PC + imm_w;
            end
            JAL: begin
                imm_w[20:0] = {inst_w[31], inst_w[19:12], inst_w[20], inst_w[30:21], 1'b0};
                PC_nxt = $signed({1'b0, PC}) + $signed(imm_w[20:0]);
                regWrite = 1'b1;
                rd_data = PC + 3'd4;
            end
            JALR: begin
                imm_w[11:0] = inst_w[31:20];
                PC_nxt = $signed({1'b0, rs1_data}) + $signed(imm_w[11:0]);
                regWrite = 1'b1;
                rd_data = PC + 3'd4;
            end
        endcase
    end

    // FSM
    always @(*) begin
        state_w = state_r;
        case (state_r)
            S_IDLE: begin
                state_w = (op_code_w == 7'b0110011 && ({funct7_w, funct3_w} == {MUL_FUNC7, MUL_FUNC3})) ?
                        S_EXEC_MULDIV :
                        S_EXEC;
            end
            S_EXEC: begin
                state_w = (op_code_w == 7'b0110011 && ({funct7_w, funct3_w} == {MUL_FUNC7, MUL_FUNC3})) ?
                        S_EXEC_MULDIV :
                        S_EXEC;
            end
            S_EXEC_MULDIV: begin
                state_w = (mulDiv_rdy_w) ? S_EXEC : S_EXEC_MULDIV;
            end 
        endcase
    end

    //==== Sequential Part ========================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            PC <= 32'h00400000; // Do not modify this value!!!
            state_r <= S_IDLE;
        end
        else begin
            PC <= PC_nxt;
            state_r <= state_w;            
        end
    end
endmodule

module reg_file(clk, rst_n, wen, a1, a2, aw, d, q1, q2);

    parameter BITS = 32;
    parameter word_depth = 32;
    parameter addr_width = 5; // 2^addr_width >= word_depth

    input clk, rst_n, wen; // wen: 0:read | 1:write
    input [BITS-1:0] d;
    input [addr_width-1:0] a1, a2, aw;

    output [BITS-1:0] q1, q2;

    reg [BITS-1:0] mem [0:word_depth-1];
    reg [BITS-1:0] mem_nxt [0:word_depth-1];

    integer i;

    assign q1 = mem[a1];
    assign q2 = mem[a2];

    always @(*) begin
        for (i=0; i<word_depth; i=i+1)
            mem_nxt[i] = (wen && (aw == i)) ? d : mem[i];
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem[0] <= 0; // zero: hard-wired zero
            for (i=1; i<word_depth; i=i+1) begin
                case(i)
                    32'd2: mem[i] <= 32'h7fffeffc; // sp: stack pointer
                    32'd3: mem[i] <= 32'h10008000; // gp: global pointer
                    default: mem[i] <= 32'h0;
                endcase
            end
        end
        else begin
            mem[0] <= 0;
            for (i=1; i<word_depth; i=i+1)
                mem[i] <= mem_nxt[i];
        end
    end
endmodule

module mulDiv(clk, rst_n, valid, ready, mode, in_A, in_B, out);
    // Todo: your HW2
    // Definition of ports
    input         clk, rst_n;
    input         valid;
    input  [1:0]  mode; // mode: 0: mulu, 1: divu, 2: shift, 3: avg
    output        ready;
    input  [31:0] in_A, in_B;
    output [63:0] out;

    // Definition of states
    localparam IDLE = 3'd0;
    localparam MUL  = 3'd1;
    localparam DIV  = 3'd2;
    localparam SHIFT = 3'd3;
    localparam AVG = 3'd4;
    localparam OUT  = 3'd5;

    reg  [ 2:0] state, state_nxt;
    reg  [ 4:0] counter, counter_nxt;
    reg  [63:0] shreg, shreg_nxt;
    reg  [31:0] alu_in, alu_in_nxt;
    reg  [32:0] alu_out;  // it's not a real register, it's wire!
    reg         dividend_flag;  // it's not a real register, it's wire!
    reg         rdy, rdy_nxt;
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
