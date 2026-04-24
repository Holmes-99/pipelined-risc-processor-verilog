// Bismillah
module ExecuteStage(
    input RegWrite_EX, MemRead_EX, MemWrite_EX,
    input ALUSrc_EX,         
    input [1:0] WB_Sel_EX,
    input [2:0] ALU_OP_EX,
    
    input [31:0] RsData_EX, 
    input [31:0] RtData_EX, 
    input [31:0] ExtImm_EX,
    input [31:0] PC_plus_1_EX,
    input [4:0]  Rd_Addr_EX,

    output RegWrite_OUT, MemRead_OUT, MemWrite_OUT,
    output [1:0] WB_Sel_OUT,
    output [31:0] ALU_Result_OUT,
    output [31:0] WriteData_OUT,  
    output [31:0] PC_plus_1_OUT,
    output [4:0]  Rd_Addr_OUT
);

    wire [31:0] ALU_In2;
    wire [31:0] Result;

    assign ALU_In2 = (ALUSrc_EX) ? ExtImm_EX : RtData_EX;

    ALU execution_unit (
        .IN1(RsData_EX),
        .IN2(ALU_In2),
        .ALU_OP(ALU_OP_EX),
        .Result(Result)
    );
	
    assign RegWrite_OUT = RegWrite_EX;
    assign MemRead_OUT = MemRead_EX;
    assign MemWrite_OUT = MemWrite_EX;
    assign WB_Sel_OUT = WB_Sel_EX;
    assign ALU_Result_OUT = Result;
    assign WriteData_OUT = RtData_EX; 
    assign PC_plus_1_OUT = PC_plus_1_EX;
    assign Rd_Addr_OUT = Rd_Addr_EX;

endmodule

