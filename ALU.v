// Bismillah
module ALU(
    input  [31:0] IN1, IN2,   
    input  [2:0]  ALU_OP,      
    output reg [31:0] Result 
);

    always @(*) begin
        case (ALU_OP)
            3'b000: Result = IN1 + IN2; // ADD,ADDI,LW,SW
            3'b001: Result = IN1 - IN2; // SUB
            3'b010: Result = IN1 | IN2; // OR,ORI
            3'b011: Result = ~(IN1 | IN2); // NOR,NORI
            3'b100: Result = IN1 & IN2; // AND,ANDI
            default: Result = 32'h0;      
        endcase
    end

endmodule  			


`timescale 1ns/1ps
module ALU_tb;

    reg [31:0] IN1, IN2;
    reg [2:0]  ALU_OP;

    wire [31:0] Result;

    ALU uut (
        .IN1(IN1),
        .IN2(IN2),
        .ALU_OP(ALU_OP),
        .Result(Result)
    );
	
    initial begin
        $display("ALU Verification");
        
        // test case 1: addition
			
        IN1 = 32'd100; IN2 = 32'd50; ALU_OP = 3'b000;
        #10;
        if (Result == 32'd150) $display("Yayy (; ADD is correct (100+50=150)");
        else $display("Fail :( ADD result: %d", Result);

        // test case 2: Subtraction (neg res)
        IN1 = 32'd10; IN2 = 32'd20; ALU_OP = 3'b001;
        #10;
        if (Result == 32'hFFFFFFF6) $display("Yayy (; SUB is correct (10-20=-10)");
        else $display("Fail :( SUB result: %h", Result);

        // test case 3: OR
        IN1 = 32'hAAAA_0000; IN2 = 32'h0000_5555; ALU_OP = 3'b010;
        #10;
        if (Result == 32'hAAAA_5555) $display("Yayy (; OR is correct");
        else $display("Fail :( OR result: %h", Result);

        // test case 4: NOR
        IN1 = 32'h0; IN2 = 32'h0; ALU_OP = 3'b011;
        #10;
        if (Result == 32'hFFFF_FFFF) $display("Yayy (; NOR is correct");
        else $display("Fail :( NOR. Result: %h", Result);

        // test case 5: AND
        IN1 = 32'hFFFF_FFFF; IN2 = 32'hF0F0_F0F0; ALU_OP = 3'b100;
        #10;
        if (Result == 32'hF0F0_F0F0) $display("Yayy (; AND is correct");
        else $display("Fail :( AND result: %h", Result);

        // tect case 6: Large Addition
        IN1 = 32'hFFFF_FFFF; IN2 = 32'h1; ALU_OP = 3'b000;
        #10;
        if (Result == 32'h0) $display("Yayy (; ADD Overflow (FFFFFFFF + 1 = 0)");
        else $display("Fail :( Overflow result: %h", Result);

        $display("ALU Verification Complete.");
        $finish;
    end

endmodule