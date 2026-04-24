// Bismillah
module FetchStage(
    input clk, rst, stall, kill, 
    
    // from ID stage
    input [1:0] PCSrc_D, // 00: PC+1, 01: J/Call, 10: JR
    input ExecuteEn_D,          
    input [31:0] sign_ext_off_D,
    input [31:0] rs_data_D,     
    input [31:0] current_pc,   
    
    output [31:0] Instruction_F,
    output [31:0] next_pc_to_RF,
    output [31:0] PC_plus_1_F  
);

    wire [31:0] raw_instruction;
    wire [31:0] calculated_next_pc;

    InstructionMemory inst_mem(
        .address(current_pc),
        .inst(raw_instruction)
    );

    PC_Control pc_ctrl(
        .current_pc(current_pc),
        .sign_ext_off(sign_ext_off_D),
        .rs_data(rs_data_D),
        .PCSrc(PCSrc_D),
        .ExecuteEn(ExecuteEn_D),
        .next_pc(calculated_next_pc)
    );

    // if stalling next pc to RF remains curr pc so R30 doesn't change 	
    assign next_pc_to_RF = (stall) ? current_pc : calculated_next_pc;

    // If a j type inst happens kill or rst we send a NOP 
    assign Instruction_F = (kill || rst) ? 32'h0 : raw_instruction;
    
    // for CALL insts we save return address in R[31]
    assign PC_plus_1_F = current_pc + 32'd1;

endmodule

