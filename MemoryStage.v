// Bismillah
module MemoryStage(
    input clk,

    input RegWrite_MEM, MemRead_MEM, MemWrite_MEM,
    input [1:0] WB_Sel_MEM,
    
    input [31:0] ALU_Result_MEM,WriteData_MEM, PC_plus_1_MEM,  
    input [4:0] Rd_Addr_MEM,

    output RegWrite_OUT,
    output [1:0] WB_Sel_OUT,
    output [31:0] ALU_Result_OUT, MemData_OUT, PC_plus_1_OUT, 
    output [4:0] Rd_Addr_OUT
);

    wire [31:0] ram_out;

    DataMemory data_ram (
        .clk(clk),
        .MEM_W(MemWrite_MEM),
        .MEM_R(MemRead_MEM),
        .address(ALU_Result_MEM),
        .data_in(WriteData_MEM),
        .data_out(ram_out)
    );

    assign RegWrite_OUT = RegWrite_MEM;
    assign WB_Sel_OUT = WB_Sel_MEM;
    assign ALU_Result_OUT = ALU_Result_MEM;
    assign MemData_OUT = ram_out;
    assign PC_plus_1_OUT = PC_plus_1_MEM;
    assign Rd_Addr_OUT = Rd_Addr_MEM;

endmodule

