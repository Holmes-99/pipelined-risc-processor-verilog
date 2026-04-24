// Bismillah
module Splitter(
    input [31:0] Inst,
    output [4:0]  OPCode, Rp, Rd, Rs, Rt,        
    output [11:0] Immediate,  
    output [21:0] Offset     
);

    assign OPCode = Inst[31:27]; 
    assign Rp = Inst[26:22]; 

    // R-Type: [Op5][Rp5][Rd5][Rs5][Rt5][Unused7]
    // I-Type: [Op5][Rp5][Rd5][Rs5][Immediate12]
	// J-Type: [Op5][Rp5][Offset22]
	
    assign Rd = Inst[21:17]; 
    assign Rs = Inst[16:12];	
    assign Rt = Inst[11:7];  
    assign Immediate = Inst[11:0];  
    assign Offset = Inst[21:0];  

endmodule	  


`timescale 1ns/1ps

module Splitter_tb;

    reg [31:0] Inst;
 
    wire [4:0]  OPCode, Rp, Rd, Rs, Rt;
    wire [11:0] Immediate;
    wire [21:0] Offset;

    Splitter uut (
        .Inst(Inst),
        .OPCode(OPCode),
        .Rp(Rp),
        .Rd(Rd),
        .Rs(Rs),
        .Rt(Rt),
        .Immediate(Immediate),
        .Offset(Offset)
    );

    initial begin
        $display("Starting Splitter Verification");

        // test case 1: R-type inst
      
        Inst = 32'b00000000010001000011001000000000;
        #10;
        $display("TC1 (R-type): Op=%d, Rp=%d, Rd=%d, Rs=%d, Rt=%d", OPCode, Rp, Rd, Rs, Rt);
        if (OPCode == 0 && Rp == 1 && Rd == 2 && Rs == 3 && Rt == 4)
            $display("Yayy (; R-type fields split correctly.");
        else
            $display("Fail :( R-type field mismatch.");

        // test case 2: I-type inst
        
        Inst = {5'd5, 5'd5, 5'd6, 5'd7, 12'hABC};
        #10;
        $display("TC2 (I-type): Op=%d, Rp=%d, Rd=%d, Rs=%d, Imm=%h", OPCode, Rp, Rd, Rs, Immediate);
        if (OPCode == 5 && Rp == 5 && Rd == 6 && Rs == 7 && Immediate == 12'hABC)
            $display("Yayy (; I-type fields split correctly.");
        else
            $display("Fail :( I-type field mismatch.");

        // test case 3: J-type inst
     
        Inst = {5'd12, 5'd0, 22'h3FFFFF};
        #10;
        $display("TC3 (J-type): Op=%d, Rp=%d, Offset=%h", OPCode, Rp, Offset);
        if (OPCode == 12 && Rp == 0 && Offset == 22'h3FFFFF)
            $display("Yayy (; J-type fields split correctly.");
        else
            $display("Fail :( J-type field mismatch.");

  
        $display("Splitter Verification Complete.");
        $finish;
    end

endmodule