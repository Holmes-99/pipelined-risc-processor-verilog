// Bismillah
module DecodeStage(
    input clk, rst,
    input [31:0] Instruction_D, PC_plus_1_D,      
    input [31:0] Data_WB, [4:0] Rd_WB,
	input RegWrite_WB,   
    input [31:0] ALU_Result_EX, [4:0] Rd_EX,
	input RegWrite_EX, MemRead_EX,        
    input [31:0] ALU_Result_MEM, MemData_MEM, PC_plus_1_MEM,    
    input [1:0]  WB_Sel_MEM, [4:0] Rd_MEM, 
	input RegWrite_MEM,      
    input [31:0] next_pc_Fetch,     

    output stallSignal, killSignal, ExecuteEn_D,
    output [1:0] PCSrc_D,
    output [31:0] sign_ext_off_D, Final_Rs_Data_D, current_pc_D,

    output RegWrite_IDEX, MemRead_IDEX, MemWrite_IDEX, ALUSrc_IDEX,
    output [1:0] WB_Sel_IDEX,
    output [2:0] ALU_OP_IDEX,
    output [31:0] RsData_IDEX, RtData_IDEX, ExtImm_IDEX, PC_plus_1_IDEX,
    output [4:0] Rd_Addr_IDEX, Rs_Addr_IDEX, Rt_Addr_IDEX
);

    wire [4:0] Opcode, Rp, Rd, Rs, Rt;
    wire [11:0] Imm12;
    wire [21:0] Offset22;
    wire RegWrite_raw, MemRead_raw, MemWrite_raw, ALUSrc, RegDst, RegReadSrc2;
    wire [1:0] WB_Sel, ExtSel;
    wire [2:0] ALU_OP;
    wire [31:0] Rs_RF, Rt_RF, Rp_RF, Ext_Out;
    wire [1:0] fwd_rs, fwd_rt, fwd_rp;
    wire [4:0] Real_Rt_Addr;

    Splitter split (Instruction_D, Opcode, Rp, Rd, Rs, Rt, Imm12, Offset22);
    ControlUnit CU (Opcode, RegWrite_raw, ALUSrc, RegDst, MemRead_raw, MemWrite_raw, RegReadSrc2, WB_Sel, ALU_OP, PCSrc_D, ExtSel);

    RegFile RF (clk, rst, RegWrite_WB, Rs, Real_Rt_Addr, Rp, Rd_WB, Data_WB, next_pc_Fetch, Rs_RF, Rt_RF, Rp_RF, current_pc_D);
    assign Real_Rt_Addr = (RegReadSrc2) ? Rd : Rt;

    Forwarding_Unit f_rs (RegWrite_EX, RegWrite_MEM, RegWrite_WB, Rs, Rd_EX, Rd_MEM, Rd_WB, fwd_rs);
    Forwarding_Unit f_rt (RegWrite_EX, RegWrite_MEM, RegWrite_WB, Real_Rt_Addr, Rd_EX, Rd_MEM, Rd_WB, fwd_rt);
    Forwarding_Unit f_rp (RegWrite_EX, RegWrite_MEM, RegWrite_WB, Rp, Rd_EX, Rd_MEM, Rd_WB, fwd_rp);

    wire [31:0] Forward_Val_MEM = (WB_Sel_MEM == 2'b01) ? MemData_MEM : (WB_Sel_MEM == 2'b10) ? PC_plus_1_MEM : ALU_Result_MEM;                         
   
    assign Final_Rs_Data_D = (fwd_rs == 2'b01) ? ALU_Result_EX : (fwd_rs == 2'b10) ? Forward_Val_MEM : (fwd_rs == 2'b11) ? Data_WB : Rs_RF;
    wire [31:0] Final_Rt_Data = (fwd_rt == 2'b01) ? ALU_Result_EX : (fwd_rt == 2'b10) ? Forward_Val_MEM : (fwd_rt == 2'b11) ? Data_WB : Rt_RF;
    wire [31:0] Final_Rp_Data = (fwd_rp == 2'b01) ? ALU_Result_EX : (fwd_rp == 2'b10) ? Forward_Val_MEM : (fwd_rp == 2'b11) ? Data_WB : Rp_RF;

    PredicateUnit pred (Rp, Final_Rp_Data, ExecuteEn_D);
    StallUnit stall_u (MemRead_EX, fwd_rs, fwd_rt, fwd_rp, stallSignal);
    KillUnit kill_u (Opcode, ExecuteEn_D, killSignal);
	
    Extender ext (Imm12, Offset22, ExtSel, Ext_Out);
    assign sign_ext_off_D = Ext_Out;

    assign RegWrite_IDEX = (ExecuteEn_D && !stallSignal) ? RegWrite_raw : 1'b0;
    assign MemWrite_IDEX = (ExecuteEn_D && !stallSignal) ? MemWrite_raw : 1'b0;
    assign MemRead_IDEX  = (ExecuteEn_D && !stallSignal) ? MemRead_raw : 1'b0;
    
    assign ALUSrc_IDEX = ALUSrc; 
    assign WB_Sel_IDEX = WB_Sel; 
    assign ALU_OP_IDEX = ALU_OP;
    assign RsData_IDEX = Final_Rs_Data_D; 
    assign RtData_IDEX = Final_Rt_Data;
    assign ExtImm_IDEX = Ext_Out; 
    assign PC_plus_1_IDEX = PC_plus_1_D;
    assign Rd_Addr_IDEX = (RegDst) ? 5'd31 : Rd;
    assign Rs_Addr_IDEX = Rs; 
    assign Rt_Addr_IDEX = Real_Rt_Addr;

endmodule