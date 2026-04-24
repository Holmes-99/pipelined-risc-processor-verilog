// Bismillah
module InstructionMemory(
    input  [31:0] address,
    output reg [31:0] inst 
);
    reg [31:0] ROM [1023:0];

    initial begin
        integer i;
        for (i = 0; i < 1024; i = i + 1) begin
            ROM[i] = 32'h0;
        end
        $readmemh("inst.txt", ROM);
    end
    always @(*) begin
        inst = ROM[address[9:0]];
    end

endmodule			 


`timescale 1ns/1ps	
module InstructionMemory_tb;
		
	reg [31:0] address;
	wire [31:0] inst;
	
	InstructionMemory uut (
	    .address(address),
	    .inst(inst)
	);
	
	initial begin
	    $display("Starting Instruction Memory Verification");
	
	    address = 32'd0;
	    #10;
	    $display("TC1: Address 0 | Instruction: %h", inst);
	    if (inst !== 32'hx)
	        $display("Yayy (; Successfully read address 0.");
	    else
	        $display("Fail :( Data is unknown at address 0.");
	
	    $display("Verification Complete.");
	    $finish;
	end		
endmodule
