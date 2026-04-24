// Bismillah
module DataMemory(
    input clk, MEM_W, MEM_R,            
    input [31:0] address, data_in,   
    output reg [31:0] data_out 
);
    // 4KB
    reg [31:0] RAM [1023:0];
    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1) begin
            RAM[i] = 32'h0; 
        end
        RAM[0] = 32'h0000000A;
        RAM[1] = 32'h00000014;
        RAM[5] = 32'hBADBADBA; 	
		RAM[20] = 32'hBADBADBA; 
    end
	
 	 //asynchronous read 
    always @(*) begin
        if (MEM_R)
            data_out = RAM[address[9:0]]; // using only the 10 LSB to cover all the 1024 words
        else
            data_out = 32'h0; 
    end

    //synchronous write
    always @(posedge clk) begin
        if (MEM_W) begin
            RAM[address[9:0]] <= data_in;
        end
    end

endmodule		 


`timescale 1ns/1ps
module DataMemory_tb;

  
    reg clk, MEM_W, MEM_R;
    reg [31:0] address, data_in;
    wire [31:0] data_out;

    DataMemory uut (
        .clk(clk),
        .MEM_W(MEM_W),
        .MEM_R(MEM_R),
        .address(address),
        .data_in(data_in),
        .data_out(data_out)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        MEM_W = 0;
        MEM_R = 0;
        address = 0;
        data_in = 0;

        #10;

        // test case 1: check preloaded values (check load)
			
        $display("TC1: reading address 5");
        address = 32'd5; MEM_R = 1;
        #5;
        if (data_out == 32'hBADBADBA) 
            $display("Yayy (; preloaded value found at address 5.");
        else 
            $display("Fail :( Address 5 gave %h", data_out);   
			

        // test case 2: write then read (check store)
			
        $display("TC2: Writing 0x1234 to address 10");
        address = 32'd10; data_in = 32'h1234; MEM_W = 1; MEM_R = 0;
        #10; 
        MEM_W = 0;
        $display("Reading back address 10...");
        MEM_R = 1;
        #5;
        if (data_out == 32'h1234)
            $display("Yayy (; Data successfully stored and read.");
        else
            $display("Fail :( Write/Read failed. Got %h", data_out);	 
			

        // test case 3: Disabled Write   
		
        $display("TC3: Attempting to overwrite address 5 with MEM_W = 0");
        address = 32'd5; data_in = 32'h0; MEM_W = 0;
        #10;
        MEM_R = 1;
        #5;
        if (data_out == 32'hBADBADBA)
            $display("Yayy (; Memory was protected (No write happened).");
        else
            $display("Fail :( Memory was corrupted without MEM_W!");

        $display("Data Memory Verification Complete.");
        $finish;
    end

endmodule
