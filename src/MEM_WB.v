// Bismillah
module MEM_WB(
    input clk, rst, RegWrite_MEM, 
    input [1:0] WB_Sel_MEM,
    input [31:0] ALU_Result_MEM, MemData_MEM, PC_plus_1_MEM, 
    input [4:0]  Rd_Addr_MEM,

    output reg RegWrite_WB, 
    output reg [1:0] WB_Sel_WB,
    output reg [31:0] ALU_Result_WB, 
    output reg [31:0] MemData_WB, 
    output reg [31:0] PC_plus_1_WB, 
    output reg [4:0]  Rd_Addr_WB
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            RegWrite_WB <= 0;
            WB_Sel_WB <= 2'b0;
            ALU_Result_WB <= 32'h0;
            MemData_WB <= 32'h0;
            PC_plus_1_WB <= 32'h0;
            Rd_Addr_WB <= 5'h0;
        end 
        else begin
            RegWrite_WB <= RegWrite_MEM;
            WB_Sel_WB <= WB_Sel_MEM;
            ALU_Result_WB <= ALU_Result_MEM;
            MemData_WB <= MemData_MEM;
            PC_plus_1_WB <= PC_plus_1_MEM;
            Rd_Addr_WB <= Rd_Addr_MEM;
        end
    end
endmodule

