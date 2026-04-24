// Bismillah
module PredicateUnit(
    input [4:0]  Rp_addr,   
    input [31:0] Rp_data,  
    output ExecuteEn  
);

    assign ExecuteEn = (Rp_addr == 5'd0) ? 1'b1 : (Rp_data != 32'd0);

endmodule		  


`timescale 1ns/1ps
module PredicateUnit_tb;
    reg [4:0]  Rp_addr;
    reg [31:0] Rp_data;
    wire ExecuteEn;

    PredicateUnit uut (
        .Rp_addr(Rp_addr),
        .Rp_data(Rp_data),
        .ExecuteEn(ExecuteEn)
    );

    initial begin
        $display("Starting PredicateUnit Verification");

        // test case 1: uncond ex using R0
        
        Rp_addr = 5'd0; Rp_data = 32'd0;
        #10;
        $display("TC1 (R0 Check): Addr=%d, Data=%h, Out=%b", Rp_addr, Rp_data, ExecuteEn);
        if (ExecuteEn == 1'b1)
            $display("Yayy (; R0 unconditional rule worked.");
        else
            $display("Fail :( R0 should always be enabled.");
				
				
        // test case 2: Predicated ex (Reg has data)
        
        Rp_addr = 5'd5; Rp_data = 32'h123;
        #10;
        $display("TC2 (non zero Rp): Addr=%d, Data=%h, Out=%b", Rp_addr, Rp_data, ExecuteEn);
        if (ExecuteEn == 1'b1)
            $display("Yayy (; Predicate enabled correctly for non zero data.");
        else
            $display("Fail :( Predicate should be enabled.");
	   
			
        // test case 3: Predicated ex (Reg is 0)
       
        Rp_addr = 5'd5; Rp_data = 32'h0;
        #10;
        $display("TC3 (Zero Rp): Addr=%d, Data=%h, Out=%b", Rp_addr, Rp_data, ExecuteEn);
        if (ExecuteEn == 1'b0)
            $display("Yayy (; Predicate disabled correctly for zero data.");
        else
            $display("Fail :( Predicate should be disabled.");

        $display("PredicateUnit Verification Complete.");
        $finish;
    end

endmodule