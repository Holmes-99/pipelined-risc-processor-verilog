module RegFile(
    input clk, rst, ActualRegWrite, 
    input [4:0] rs, rt, rp, rd,
    input [31:0] data_in, next_pc,   
    output [31:0] rsdata, rtdata, rpdata,
    output [31:0] current_pc 
);

    reg [31:0] Registers [31:0]; 

    assign rsdata = (rs == 5'd0) ? 32'd0 : Registers[rs];
    assign rtdata = (rt == 5'd0) ? 32'd0 : Registers[rt];
    assign rpdata = (rp == 5'd0) ? 32'd0 : Registers[rp];
    
    assign current_pc = Registers[30];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            integer i;
            for (i = 0; i < 32; i = i + 1) Registers[i] <= 32'h0;  

        end 
        else begin
            Registers[30] <= next_pc;
			
            if (ActualRegWrite && rd != 5'd0 && rd != 5'd30) begin
                Registers[rd] <= data_in;
            end
        end
    end
endmodule	



`timescale 1ns/1ps
module RegFile_tb;
	
    reg clk, rst, ActualRegWrite;
    reg [4:0] rs, rt, rp, rd;
    reg [31:0] data_in;
    reg [31:0] next_pc;        
    wire [31:0] current_pc;   
    wire [31:0] rsdata, rtdata, rpdata;

    RegFile uut (
        .clk(clk),
        .rst(rst),
        .rs(rs),
        .rt(rt),
        .rp(rp),
        .rd(rd),
        .data_in(data_in),
        .next_pc(next_pc),     
        .ActualRegWrite(ActualRegWrite),
        .rsdata(rsdata),
        .rtdata(rtdata),
        .rpdata(rpdata),
        .current_pc(current_pc)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        rs = 0; rt = 0; rp = 0; rd = 0;
        data_in = 0;
        next_pc = 32'hAAAABBBB; 
        ActualRegWrite = 0;
        #10 rst = 0;
        #10;

        //test case 1: checking reading/writing correctness 		
			
        $display("TC1: writing 0x1234 to R5 and reading using all regs");
        rd = 5'd5; data_in = 32'h1234; ActualRegWrite = 1;
        next_pc = 32'h4; 
        #10; 
        ActualRegWrite = 0;
        rs = 5'd5; rt = 5'd5; rp = 5'd5;
        #1; 
        if (rsdata == 32'h1234 && rtdata == 32'h1234 && rpdata == 32'h1234)
            $display("Yayy (; R5 read correctly on all ports.");
        else
            $display("Fail :( R5 read error. Reg[Rs]:%h", rsdata);	   
			

        //test case 2: blocking writing on R0	
		
        $display("TC2: trying to write 0xFFFF to R0");
        rd = 5'd0; data_in = 32'hFFFF; ActualRegWrite = 1;
        next_pc = 32'h8;
        #10;
        ActualRegWrite = 0;
        rs = 5'd0;
        #1;
        if (rsdata == 32'd0)
            $display("Yayy (; R0 remained zero despite write attempt.");
        else
            $display("Fail :( R0 was overwritten 0_0 value: %h", rsdata);	 
			

        //test case 3: R30/PC Protection
		
        $display("TC3: Attempting to write 0xDEADBEEF to R30/PC");
        next_pc = 32'h100; 
        rd = 5'd30; data_in = 32'hDEADBEEF; ActualRegWrite = 1;
        #10;
        ActualRegWrite = 0;
        rs = 5'd30;
        #1;
        if (current_pc == 32'h100) 
            $display("Yayy (; R30 ignored the data_in and stayed as current_pc.");
        else
            $display("Fail :( R30 was overwritten by instruction 0_0 value: %h", current_pc);
			

        //test case 4: Predicated Execution Gating
			
        $display("TC4: trying to write to R10 with ActualRegWrite = 0 (predicate false)");
        rd = 5'd10; data_in = 32'h7777; ActualRegWrite = 0;
        next_pc = 32'h104;
        #10;
        rs = 5'd10;
        #1;
        if (rsdata == 32'd0)
            $display("Yayy (; R10 not written because RegWrite = 0.");
        else
            $display("Fail :( R10 written despite predicate being false.");
	 

        //test casae 5: PC value update
		
        $display("TC5: Verifying R30 changes when current_pc changes externally");
        next_pc = 32'h200; 
        #10;
        rs = 5'd30;
        #1;
        if (current_pc == 32'h200)
            $display("Yayy (; R30 correctly reflects the new current_pc.");
        else
            $display("Fail :( R30 did not track the external PC change.");

        $display("Testbench complete.");
        $finish;
    end

endmodule
