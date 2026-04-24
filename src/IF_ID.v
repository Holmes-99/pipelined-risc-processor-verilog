// Bismillah
module IF_ID (
    input clk, rst, stall, kill,
    input [31:0] Instruction_F, PC_F,
    output reg [31:0] Instruction_D, PC_D
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            Instruction_D <= 32'h0;
            PC_D <= 32'h0;
        end 
        else if (kill) begin
            Instruction_D <= 32'h0;
            PC_D <= PC_F; 
        end
        else if (!stall) begin
            Instruction_D <= Instruction_F;
            PC_D <= PC_F;
        end
    end
endmodule	  

