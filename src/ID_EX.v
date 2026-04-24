// Bismillah
module ID_EX (
    input clk, rst, stall, 
    input ActualRegWrite_D, ActualMemWrite_D, ActualMemRead_D,
    input ALUSrc_D, 
    input [1:0] WB_Sel_D,
    input [2:0] ALU_OP_D,
    input [31:0] RsData_D, RtData_D, ExtImm_D, PC_plus_1_D,
    input [4:0]  Rd_Addr_D, Rs_Addr_D, Rt_Addr_D,

    output reg RegWrite_EX, MemWrite_EX, MemRead_EX,
    output reg ALUSrc_EX,
    output reg [1:0] WB_Sel_EX,
    output reg [2:0] ALU_OP_EX,
    output reg [31:0] RsData_EX, RtData_EX, ExtImm_EX, PC_plus_1_EX,
    output reg [4:0]  Rd_Addr_EX, Rs_Addr_EX, Rt_Addr_EX
);

    always @(posedge clk or posedge rst) begin
        if (rst || stall) begin
            RegWrite_EX <= 0;
			MemWrite_EX <= 0;
			MemRead_EX <= 0;
            ALUSrc_EX <= 0; 
			WB_Sel_EX <= 2'b0; 
			ALU_OP_EX <= 3'b0;
            {RsData_EX, RtData_EX, ExtImm_EX, PC_plus_1_EX} <= 128'b0;
            {Rd_Addr_EX, Rs_Addr_EX, Rt_Addr_EX} <= 15'b0;
        end 
        else begin
            RegWrite_EX <= ActualRegWrite_D;
            MemWrite_EX <= ActualMemWrite_D;
            MemRead_EX <= ActualMemRead_D;
            ALUSrc_EX <= ALUSrc_D;
            WB_Sel_EX <= WB_Sel_D;
            ALU_OP_EX <= ALU_OP_D;
            RsData_EX <= RsData_D;
            RtData_EX <= RtData_D;
            ExtImm_EX <= ExtImm_D;
            PC_plus_1_EX <= PC_plus_1_D;
            Rd_Addr_EX <= Rd_Addr_D;
            Rs_Addr_EX <= Rs_Addr_D;
            Rt_Addr_EX <= Rt_Addr_D;
        end
    end
endmodule	   

