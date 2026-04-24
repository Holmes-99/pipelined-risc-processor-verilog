// Bismillah
module Extender(
    input [11:0] Imm12,     
    input [21:0] Offset22, 
    input [1:0] ExtSel,     // control signal: 00 = 0Ext12, 01 = SignExt12, 10 = SignExt22
    output reg [31:0] ExtOut
);

    always @(*) begin
        case (ExtSel)
            // 0Ext 12bits 
            2'b00: ExtOut = {20'b0,Imm12};
            
            // SignExt 12bits
            2'b01: ExtOut = {{20{Imm12[11]}},Imm12};
            
            // SigExt 22bits 
            2'b10: ExtOut = {{10{Offset22[21]}},Offset22};
            
            default: ExtOut = 32'h0;
        endcase
    end
endmodule	

`timescale 1ns/1ps

module Extender_tb;
    reg [11:0] Imm12;
    reg [21:0] Offset22;
    reg [1:0] ExtSel;
    wire [31:0] ExtOut;

    Extender uut (
        .Imm12(Imm12),
        .Offset22(Offset22),
        .ExtSel(ExtSel),
        .ExtOut(ExtOut)
    );

    initial begin
        $display("Starting Extender Verification");

        // test case 1: 0Ext 12bits (logical insts)
        
        Imm12 = 12'h800; ExtSel = 2'b00;
        #10;
        $display("TC1 (0Ext 12): In=%h, Sel=%b, Out=%h", Imm12, ExtSel, ExtOut);
        if (ExtOut == 32'h00000800)
            $display("Yayy (; 0Ext worked correctly.");
        else
            $display("Fail :( 0Ext mismatch.");

        // test case 2: SignExt 12bits
        
        Imm12 = 12'hFFF; ExtSel = 2'b01;
        #10;
        $display("TC2 (SignExt 12): In=%h, Sel=%b, Out=%h", Imm12, ExtSel, ExtOut);
        if (ExtOut == 32'hFFFFFFFF)
            $display("Yayy (; SignExt worked correctly.");
        else
            $display("Fail :( SignExt mismatch.");

        // test case 3: SignExt 22bits (negative offset)
       
        Offset22 = 22'h3FFFFF; ExtSel = 2'b10;
        #10;
        $display("TC3 (SignExt 22): In=%h, Sel=%b, Out=%h", Offset22, ExtSel, ExtOut);
        if (ExtOut == 32'hFFFFFFFF)
            $display("Yayy (; SignExt worked correctly.");
        else
            $display("Fail :( SignExt mismatch.");

        $display("Extender Verification Complete.");
        $finish;
    end

endmodule