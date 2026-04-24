// Bismillah
module EX_MEM(
    input clk, rst,
    input RegWrite_EX, MemRead_EX, MemWrite_EX,
    input [1:0] WB_Sel_EX,
    input [31:0] ALU_Result_EX, WriteData_EX, PC_plus_1_EX, 
    input [4:0] Rd_Addr_EX, 

    output reg RegWrite_MEM, MemRead_MEM, MemWrite_MEM,
    output reg [1:0] WB_Sel_MEM,
    output reg [31:0] ALU_Result_MEM, 
    output reg [31:0] WriteData_MEM,
    output reg [31:0] PC_plus_1_MEM,
    output reg [4:0] Rd_Addr_MEM
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            RegWrite_MEM <= 0;
			MemRead_MEM <= 0;
			MemWrite_MEM <= 0;
            WB_Sel_MEM <= 2'b0;
            ALU_Result_MEM <= 32'h0;
			WriteData_MEM <= 32'h0;
            PC_plus_1_MEM <= 32'h0;
			Rd_Addr_MEM <= 5'h0;
        end 
        else begin
            RegWrite_MEM <= RegWrite_EX;
            MemRead_MEM <= MemRead_EX;
            MemWrite_MEM <= MemWrite_EX;
            WB_Sel_MEM <= WB_Sel_EX;
            ALU_Result_MEM <= ALU_Result_EX;
            WriteData_MEM <= WriteData_EX;
            PC_plus_1_MEM <= PC_plus_1_EX;
            Rd_Addr_MEM <= Rd_Addr_EX;
        end
    end
endmodule