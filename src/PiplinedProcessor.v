// Bismillah
module PipelinedProcessor(
    input clk,
    input rst
);

    reg [31:0] clockCycles;

    // IF stage
    wire [31:0] Instruction_F, next_pc_Fetch, PC_plus_1_F;
    
    // ID stage
    wire [31:0] Instruction_D, PC_plus_1_D;
    wire stall, kill, ExecuteEn_D;
    wire [1:0] PCSrc_D;
    wire [31:0] sign_ext_off_D, Final_Rs_Data_D, current_pc_D;
    
    // ID/EX buffer
    wire RegWrite_IDEX, MemRead_IDEX, MemWrite_IDEX, ALUSrc_IDEX;
    wire [1:0] WB_Sel_IDEX;
    wire [2:0] ALU_OP_IDEX;
    wire [31:0] RsData_IDEX, RtData_IDEX, ExtImm_IDEX, PC_plus_1_IDEX_pass;
    wire [4:0] Rd_Addr_IDEX, Rs_Addr_IDEX, Rt_Addr_IDEX;

    // EX stage
    wire RegWrite_EX, MemRead_EX, MemWrite_EX, ALUSrc_EX;
    wire [1:0] WB_Sel_EX;
    wire [2:0] ALU_OP_EX;
    wire [31:0] RsData_EX, RtData_EX, ExtImm_EX, PC_plus_1_EX;
    wire [4:0] Rd_Addr_EX, Rs_Addr_EX, Rt_Addr_EX;
    wire RegWrite_EX_out, MemRead_EX_out, MemWrite_EX_out;
    wire [1:0] WB_Sel_EX_out;
    wire [31:0] ALU_Result_EX_out, WriteData_EX_out, PC_plus_1_EX_out;
    wire [4:0] Rd_Addr_EX_out;

    // EX/MEM buffer 
    wire RegWrite_MEM, MemRead_MEM, MemWrite_MEM;
    wire [1:0] WB_Sel_MEM;
    wire [31:0] ALU_Result_MEM, WriteData_MEM, PC_plus_1_MEM;
    wire [4:0] Rd_Addr_MEM; 
    
    // MEM stage
    wire RegWrite_MEM_out;
    wire [1:0] WB_Sel_MEM_out;
    wire [31:0] ALU_Result_MEM_out, MemData_MEM_out, PC_plus_1_MEM_out;
    wire [4:0] Rd_Addr_MEM_out;

    // MEM/WB buffer 
    wire RegWrite_WB;
    wire [1:0] WB_Sel_WB;
    wire [31:0] ALU_Result_WB, MemData_WB, PC_plus_1_WB;
    wire [4:0] Rd_Addr_WB;
    wire [31:0] Final_Data_WB;

    // cycles counter
    always @(posedge clk or posedge rst) begin
        if (rst) begin 
            clockCycles <= 0; 
        end else begin 
            clockCycles <= clockCycles + 1;
        end
    end

    // IF stage
    FetchStage IF_Stage (
        .clk(clk), .rst(rst), .stall(stall), .kill(kill),
        .PCSrc_D(PCSrc_D), .ExecuteEn_D(ExecuteEn_D),
        .sign_ext_off_D(sign_ext_off_D), .rs_data_D(Final_Rs_Data_D),
        .current_pc(current_pc_D),
        .Instruction_F(Instruction_F), .next_pc_to_RF(next_pc_Fetch), .PC_plus_1_F(PC_plus_1_F)
    );	
	
    // IF/ID buffer
    IF_ID IF_ID_Buf (
        .clk(clk), .rst(rst), .stall(stall), .kill(kill),
        .Instruction_F(Instruction_F), .PC_F(PC_plus_1_F),
        .Instruction_D(Instruction_D), .PC_D(PC_plus_1_D)
    );

    // ID stage
    DecodeStage ID_Stage (
        .clk(clk), .rst(rst),
        .Instruction_D(Instruction_D), .PC_plus_1_D(PC_plus_1_D),
        .Data_WB(Final_Data_WB), .Rd_WB(Rd_Addr_WB), .RegWrite_WB(RegWrite_WB), 
        .ALU_Result_EX(ALU_Result_EX_out), .Rd_EX(Rd_Addr_EX), .RegWrite_EX(RegWrite_EX), .MemRead_EX(MemRead_EX),
        .ALU_Result_MEM(ALU_Result_MEM), 
        .MemData_MEM(MemData_MEM_out), 
        .PC_plus_1_MEM(PC_plus_1_MEM),        
        .WB_Sel_MEM(WB_Sel_MEM), 
        .Rd_MEM(Rd_Addr_MEM), .RegWrite_MEM(RegWrite_MEM),
        .next_pc_Fetch(next_pc_Fetch),
        .stallSignal(stall), .killSignal(kill), .ExecuteEn_D(ExecuteEn_D),
        .PCSrc_D(PCSrc_D), .sign_ext_off_D(sign_ext_off_D), .Final_Rs_Data_D(Final_Rs_Data_D), .current_pc_D(current_pc_D),
        .RegWrite_IDEX(RegWrite_IDEX), .MemRead_IDEX(MemRead_IDEX), .MemWrite_IDEX(MemWrite_IDEX),
        .ALUSrc_IDEX(ALUSrc_IDEX), 
        .WB_Sel_IDEX(WB_Sel_IDEX), .ALU_OP_IDEX(ALU_OP_IDEX),
        .RsData_IDEX(RsData_IDEX), .RtData_IDEX(RtData_IDEX), .ExtImm_IDEX(ExtImm_IDEX), .PC_plus_1_IDEX(PC_plus_1_IDEX_pass),
        .Rd_Addr_IDEX(Rd_Addr_IDEX), .Rs_Addr_IDEX(Rs_Addr_IDEX), .Rt_Addr_IDEX(Rt_Addr_IDEX)
    );

    // ID/EX buffer
    ID_EX ID_EX_Buf (
        .clk(clk), .rst(rst), .stall(stall),
        .ActualRegWrite_D(RegWrite_IDEX), .ActualMemWrite_D(MemWrite_IDEX), .ActualMemRead_D(MemRead_IDEX),
        .ALUSrc_D(ALUSrc_IDEX), 
        .WB_Sel_D(WB_Sel_IDEX), .ALU_OP_D(ALU_OP_IDEX),
        .RsData_D(RsData_IDEX), .RtData_D(RtData_IDEX), .ExtImm_D(ExtImm_IDEX), .PC_plus_1_D(PC_plus_1_IDEX_pass),
        .Rd_Addr_D(Rd_Addr_IDEX), .Rs_Addr_D(Rs_Addr_IDEX), .Rt_Addr_D(Rt_Addr_IDEX),
        .RegWrite_EX(RegWrite_EX), .MemWrite_EX(MemWrite_EX), .MemRead_EX(MemRead_EX),
        .ALUSrc_EX(ALUSrc_EX), 
        .WB_Sel_EX(WB_Sel_EX), .ALU_OP_EX(ALU_OP_EX),
        .RsData_EX(RsData_EX), .RtData_EX(RtData_EX), .ExtImm_EX(ExtImm_EX), .PC_plus_1_EX(PC_plus_1_EX),
        .Rd_Addr_EX(Rd_Addr_EX), .Rs_Addr_EX(Rs_Addr_EX), .Rt_Addr_EX(Rt_Addr_EX)
    );

    // EX stage
    ExecuteStage EX_Stage (
        .RegWrite_EX(RegWrite_EX), .MemRead_EX(MemRead_EX), .MemWrite_EX(MemWrite_EX),
        .ALUSrc_EX(ALUSrc_EX), .WB_Sel_EX(WB_Sel_EX), .ALU_OP_EX(ALU_OP_EX),
        .RsData_EX(RsData_EX), .RtData_EX(RtData_EX), .ExtImm_EX(ExtImm_EX), .PC_plus_1_EX(PC_plus_1_EX), .Rd_Addr_EX(Rd_Addr_EX),
        .RegWrite_OUT(RegWrite_EX_out), .MemRead_OUT(MemRead_EX_out), .MemWrite_OUT(MemWrite_EX_out),
        .WB_Sel_OUT(WB_Sel_EX_out), .ALU_Result_OUT(ALU_Result_EX_out), .WriteData_OUT(WriteData_EX_out),
        .PC_plus_1_OUT(PC_plus_1_EX_out), .Rd_Addr_OUT(Rd_Addr_EX_out)
    );
    // EX/MEM buffer
    EX_MEM EX_MEM_Buf (
        .clk(clk), .rst(rst),
        .RegWrite_EX(RegWrite_EX_out), .MemRead_EX(MemRead_EX_out), .MemWrite_EX(MemWrite_EX_out), 
        .WB_Sel_EX(WB_Sel_EX_out), .ALU_Result_EX(ALU_Result_EX_out), .WriteData_EX(WriteData_EX_out),
        .PC_plus_1_EX(PC_plus_1_EX_out), .Rd_Addr_EX(Rd_Addr_EX_out),
        .RegWrite_MEM(RegWrite_MEM), .MemRead_MEM(MemRead_MEM), .MemWrite_MEM(MemWrite_MEM), 
        .WB_Sel_MEM(WB_Sel_MEM), .ALU_Result_MEM(ALU_Result_MEM), .WriteData_MEM(WriteData_MEM),
        .PC_plus_1_MEM(PC_plus_1_MEM), .Rd_Addr_MEM(Rd_Addr_MEM)
    );

    // MEM stage
    MemoryStage MEM_Stage (
        .clk(clk),
        .RegWrite_MEM(RegWrite_MEM), .MemRead_MEM(MemRead_MEM), .MemWrite_MEM(MemWrite_MEM), .WB_Sel_MEM(WB_Sel_MEM),
        .ALU_Result_MEM(ALU_Result_MEM), .WriteData_MEM(WriteData_MEM), .PC_plus_1_MEM(PC_plus_1_MEM), .Rd_Addr_MEM(Rd_Addr_MEM),
        .RegWrite_OUT(RegWrite_MEM_out), .WB_Sel_OUT(WB_Sel_MEM_out), .ALU_Result_OUT(ALU_Result_MEM_out),
        .MemData_OUT(MemData_MEM_out), .PC_plus_1_OUT(PC_plus_1_MEM_out), .Rd_Addr_OUT(Rd_Addr_MEM_out)
    );
    // MEM/WB buffer
    MEM_WB MEM_WB_Buf (
        .clk(clk), .rst(rst), .RegWrite_MEM(RegWrite_MEM_out), .WB_Sel_MEM(WB_Sel_MEM_out),
        .ALU_Result_MEM(ALU_Result_MEM_out), .MemData_MEM(MemData_MEM_out), .PC_plus_1_MEM(PC_plus_1_MEM_out), .Rd_Addr_MEM(Rd_Addr_MEM_out),
        .RegWrite_WB(RegWrite_WB), .WB_Sel_WB(WB_Sel_WB), .ALU_Result_WB(ALU_Result_WB),
        .MemData_WB(MemData_WB), .PC_plus_1_WB(PC_plus_1_WB), .Rd_Addr_WB(Rd_Addr_WB)
    );

    // WB stage
    assign Final_Data_WB = (WB_Sel_WB == 2'b00) ? ALU_Result_WB :
                           (WB_Sel_WB == 2'b01) ? MemData_WB :
                           (WB_Sel_WB == 2'b10) ? PC_plus_1_WB : ALU_Result_WB;

endmodule

`timescale 1ns/1ps
module PipelinedProcessor_tb();
    reg clk, rst;
    integer i;
    reg stop_log;
  
    PipelinedProcessor uut (.clk(clk), .rst(rst));
    always #5 clk = ~clk;

    initial begin  
        $display("======================================================================");
        $display("Pipelined Processor: Full State Snapshot Trace");
        $display("======================================================================");
        
        clk = 0; rst = 1; stop_log = 0;
        #15 rst = 0; 
        wait(uut.ID_Stage.Instruction_D == 32'h0000DEAD);
        stop_log = 1;
        repeat(4) @(negedge clk);  

        $display("----------------------------------------------------------------------");
        $display("Simulation Finished Successfully.");
        $display("----------------------------------------------------------------------");
        $finish;
    end

    always @(negedge clk) begin
        if (!rst) begin
            $display("\n[CYCLE: %0d] | PC: %0d", uut.clockCycles, uut.current_pc_D-1);
            
            if (stop_log)
                $display("Instruction: program is done");
            else
                $display("Instruction: %h", uut.Instruction_D);

          
            $display("Data Memory:");
            for (i = 15; i <=20; i = i + 1) begin
                $display("  Mem[%0d]: %h", i, uut.MEM_Stage.data_ram.RAM[i]);
            end
		   
            $display("Registers:");
            for (i = 0; i < 32; i = i + 1) begin
                $display("  R%02d: %h", i, uut.ID_Stage.RF.Registers[i]);
            end
            
            $display("======================================================================");
        end
    end
endmodule
