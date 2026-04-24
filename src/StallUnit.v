module StallUnit(
    input MemRead_EX,               
    input [1:0] forward_rs,        
    input [1:0] forward_rt,      
    input [1:0] forward_rp,        
    output reg stallSignal
);

    initial stallSignal = 1'b0;
    always @(*) begin
      
        if (MemRead_EX && (forward_rs == 2'b01 || forward_rt == 2'b01 || forward_rp == 2'b01)) begin
            stallSignal = 1'b1;
        end
        else begin
            stallSignal = 1'b0;
        end
    end

endmodule	 


`timescale 1ns/1ps
module StallUnit_tb;

    reg MemRead_EX;
    reg [1:0] forward_rs, forward_rt, forward_rp;
    wire stallSignal;

    StallUnit uut (
        .MemRead_EX(MemRead_EX),
        .forward_rs(forward_rs),
        .forward_rt(forward_rt),
        .forward_rp(forward_rp),
        .stallSignal(stallSignal)
    );

    initial begin
        $display("Starting Stall Unit Verification");

        // test case 1: no load inst in EX --> no stall needed		
			
        MemRead_EX = 0; forward_rs = 2'b01; forward_rt = 2'b00; forward_rp = 2'b00;
        #10;
        $display("TC1 (No LW): MemRead_EX=%b, FwdRS=%b, Stall=%b", MemRead_EX, forward_rs, stallSignal);
        if (stallSignal == 1'b0)
            $display("Yayy (; No stall because EX is not a Load instruction.");
        else
            $display("Fail :( Stalled unnecessarily.");


        // test case 2: EX is LW and ID inst needs that res for Rs 
			
        MemRead_EX = 1; forward_rs = 2'b01; forward_rt = 2'b00; forward_rp = 2'b00;
        #10;
        $display("TC2 (LW-Rs Hazard): MemRead_EX=%b, FwdRS=%b, Stall=%b", MemRead_EX, forward_rs, stallSignal);
        if (stallSignal == 1'b1)
            $display("Yayy (; Correctly stalled for load use on Rs.");
        else
            $display("Fail :( Failed to stall for Rs dependency.");


        // test case 3: Data is already in MEM stage (No stall)
        
        MemRead_EX = 1; forward_rs = 2'b10; forward_rt = 2'b00; forward_rp = 2'b00;
        #10;
        $display("TC3 (MEM stage forward): MemRead_EX=%b, FwdRS=%b, Stall=%b", MemRead_EX, forward_rs, stallSignal);
        if (stallSignal == 1'b0)
            $display("Yayy (; No stall because data has reached the MEM stage.");
        else
            $display("Fail :( Stalled even though data is ready to forward from MEM.");

        $display("Stall Unit Verification Complete.");
        $finish;
    end

endmodule
