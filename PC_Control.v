// Bismillah
module PC_Control(
    input [31:0] current_pc, sign_ext_off, rs_data,       
    input [1:0]  PCSrc,        
    input ExecuteEn,     
    output reg [31:0] next_pc
);

    always @(*) begin
        case(PCSrc)
    
            2'b00: next_pc = current_pc + 32'd1;

            2'b01: begin
                if (ExecuteEn)
                    next_pc = current_pc + sign_ext_off;
                else
                    next_pc = current_pc + 32'd1;
            end

            2'b10: begin
                if (ExecuteEn)
                    next_pc = rs_data;
                else
                    next_pc = current_pc + 32'd1;
            end

            default: next_pc = current_pc + 32'd1;
        endcase
    end
endmodule		


`timescale 1ns/1ps
module PC_Control_tb;

    reg [31:0] current_pc, sign_ext_off, rs_data;
    reg [1:0]  PCSrc;
    reg ExecuteEn;

    wire [31:0] next_pc;

    PC_Control uut(
        .current_pc(current_pc),
        .sign_ext_off(sign_ext_off),
        .rs_data(rs_data),
        .PCSrc(PCSrc),
        .ExecuteEn(ExecuteEn),
        .next_pc(next_pc)
    );

    initial begin
        $display("Starting PC Control Verification");

        current_pc = 32'd100;    
        sign_ext_off = 32'd20;   
        rs_data = 32'd500;         
		
        
        // test case 1: sequential increment 
			
        PCSrc = 2'b00; ExecuteEn = 1'b1;
        #10;
        $display("TC1 (normal): PC=%d, Sel=%b, En=%b, Out=%d", current_pc, PCSrc, ExecuteEn, next_pc);
        if (next_pc == 32'd101)
            $display("Yayy (; normal increment worked correctly.");
        else
            $display("Fail :( sequential increment mismatch.");	 
			

        // test case 2: J/CALL with Predicate = 1
			
        PCSrc = 2'b01; ExecuteEn = 1'b1;
        #10;
        $display("TC2 (jump true): PC=%d, Off=%d, En=%b, Out=%d", current_pc,sign_ext_off,ExecuteEn,next_pc);
        if (next_pc == 32'd120)
            $display("Yayy (; Predicated Jump calculated correctly.");
        else
            $display("Fail :( Jump target mismatch.");
	 
			
        // test case 3: J/CALL with Predicate = 0
    
        PCSrc = 2'b01; ExecuteEn = 1'b0;
        #10;
        $display("TC3 (jump false): PC=%d, Off=%d, En=%b, Out=%d", current_pc, sign_ext_off, ExecuteEn, next_pc);
        if (next_pc == 32'd101)
            $display("Yayy (; predicate false --> PC+1.");
        else
            $display("Fail :( Jump was taken despite false predicate.");		 
			

        // test case 4: JR with Predicate = 1
       
        PCSrc = 2'b10; ExecuteEn = 1'b1;
        #10;
        $display("TC4 (JR true): PC=%d, Rs=%d, En=%b, Out=%d", current_pc, rs_data, ExecuteEn, next_pc);
        if (next_pc == 32'd500)
            $display("Yayy (; JR target address loaded correctly.");
        else
            $display("Fail :( JR address mismatch.");
		 
			
        // test case 5: JR with Predicate = 0
       
        PCSrc = 2'b10; ExecuteEn = 1'b0;
        #10;
        $display("TC5 (JR false): PC=%d, Rs=%d, En=%b, Out=%d", current_pc, rs_data, ExecuteEn, next_pc);
        if (next_pc == 32'd101)
            $display("Yayy (; Predicate false --> PC+1 for JR.");
        else
            $display("Fail :( JR was taken despite false predicate.");
		

        $display("PC_Control Verification Complete.");
        $finish;
    end

endmodule