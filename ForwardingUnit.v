// Bismillah
module Forwarding_Unit(
    input RegWrite_EX, RegWrite_MEM, RegWrite_WB,  
    input [4:0] SrcAddr,         
    input [4:0] Rd_EX, Rd_MEM, Rd_WB, 
    output reg [1:0] Forward // 00: RF, 01: EX, 10: MEM, 11: WB
);
    always @(*) begin
       
        if (RegWrite_EX && (SrcAddr != 5'd0) && (SrcAddr == Rd_EX))
            Forward = 2'b01; // forward from EX stage
        else if (RegWrite_MEM && (SrcAddr != 5'd0) && (SrcAddr == Rd_MEM))
            Forward = 2'b10; // forward from MEM stage
        else if (RegWrite_WB && (SrcAddr != 5'd0) && (SrcAddr == Rd_WB))
            Forward = 2'b11; // forward from WB stage
        else
            Forward = 2'b00; // no hazards use RegFile
    end
endmodule


`timescale 1ns/1ps
module Forwarding_Unit_tb;

    reg RegWrite_EX, RegWrite_MEM, RegWrite_WB;
    reg [4:0] SrcAddr, Rd_EX, Rd_MEM, Rd_WB;
  
    wire [1:0] Forward;
	
    Forwarding_Unit uut (
        .RegWrite_EX(RegWrite_EX), 
        .RegWrite_MEM(RegWrite_MEM), 
        .RegWrite_WB(RegWrite_WB),
        .SrcAddr(SrcAddr),
        .Rd_EX(Rd_EX), 
        .Rd_MEM(Rd_MEM), 
        .Rd_WB(Rd_WB),
        .Forward(Forward)
    );

    initial begin
        $display("Starting Modular Forwarding Unit Verification");
		
        RegWrite_EX = 0; RegWrite_MEM = 0; RegWrite_WB = 0;
        SrcAddr = 0; Rd_EX = 0; Rd_MEM = 0; Rd_WB = 0;
        #10;

        // test case 1: no hazards
        SrcAddr = 5'd1; Rd_EX = 5'd2; Rd_MEM = 5'd3; Rd_WB = 5'd4;
        RegWrite_EX = 1; RegWrite_MEM = 1; RegWrite_WB = 1;
        #10;
        $display("TC1 (No Match): Src=%d, Forward=%b", SrcAddr, Forward);
        if (Forward == 2'b00)
            $display("Yayy (; Correct: No forwarding when registers differ.");
        else
            $display("Fail :( Forwarding triggered without a match.");


        // test case 2: EX stage match
        SrcAddr = 5'd5; Rd_EX = 5'd5;
        #10;
        $display("TC2 (EX Match): Src=%d, Rd_EX=%d, Forward=%b", SrcAddr, Rd_EX, Forward);
        if (Forward == 2'b01)
            $display("Yayy (; Forwarded correctly from EX stage.");
        else
            $display("Fail :( EX forwarding failed.");

        $display("Forwarding Unit Verification Complete.");
        $finish;
    end
endmodule