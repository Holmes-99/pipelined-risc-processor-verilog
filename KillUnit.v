// Bismillah
module KillUnit(
    input [4:0] Opcode,
    input ExecuteEn,    
    output reg killSignal
);
    always @(*) begin
        if (ExecuteEn) begin
            case (Opcode)
                5'd11, 5'd12, 5'd13: killSignal = 1'b1; // J, CALL, JR
                default: killSignal = 1'b0;
            endcase
        end 
        else begin
            killSignal = 1'b0;
        end
    end
endmodule


`timescale 1ns/1ps
module KillUnit_tb;

    reg [4:0] Opcode;
    reg ExecuteEn;
    wire killSignal;

    KillUnit uut (
        .Opcode(Opcode),
        .ExecuteEn(ExecuteEn),
        .killSignal(killSignal)
    );

    initial begin
        $display("Starting Kill Unit Verification");
		
		
        // test case 1: Jump with predicate = 1 -> Should kill
        
        Opcode = 5'd11; ExecuteEn = 1'b1;
        #10;
        $display("TC1 (J True): Op=%d, En=%b, Kill=%b", Opcode, ExecuteEn, killSignal);
        if (killSignal == 1'b1)
            $display("Yayy (; Kill is handled for executing Jump.");
        else
            $display("Fail :( Jump failed to handle kill signal.");


        // test case 2: Jump with Predicate = 0	-> Should NOT kill
        
        Opcode = 5'd11; ExecuteEn = 1'b0;
        #10;
        $display("TC2 (J False): Op=%d, En=%b, Kill=%b", Opcode, ExecuteEn, killSignal);
        if (killSignal == 1'b0)
            $display("Yayy (; Kill correctly ignored because predicate was false.");
        else
            $display("Fail :( Kill handled despite false predicate.");


        // test case 3: normal op opcode 8 (ANDI) -> Should NOT kill
        
        Opcode = 5'd8; ExecuteEn = 1'b1;
        #10;
        $display("TC3 (ANDI): Op=%d, En=%b, Kill=%b", Opcode, ExecuteEn, killSignal);
        if (killSignal == 1'b0)
            $display("Yayy (; Normal instruction did not trigger kill.");
        else
            $display("Fail :( Kill signal active for a non-jump instruction.");

        $display("Kill Unit Verification Complete.");
        $finish;
    end

endmodule