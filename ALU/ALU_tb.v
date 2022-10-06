`timescale 1us/1ns
module ALU_tb ();
    
    reg  [15:0]    A_tb;
    reg  [15:0]    B_tb;
    reg            ALU_EN_tb;
    reg  [3:0]     ALU_FUN_tb;
    reg            clk_tb;
    reg            Reset_tb;
    wire [31:0]    ALU_out_tb;
    wire           Out_valid_tb;


    ALU #(.A_width(16),
          .B_width(16))
DUT(
    .CLK(clk_tb),
    .Reset(Reset_tb),
    .ALU_EN(ALU_EN_tb),
    .A(A_tb), 
    .B(B_tb),
    .ALU_FUN(ALU_FUN_tb),
    .ALU_out(ALU_out_tb),
    .Out_valid(Out_valid_tb)
);

    initial begin
        clk_tb = 1'b0;
        A_tb = 16'd0;
        B_tb = 16'd0;
        ALU_FUN_tb = 4'd0;
        ALU_EN_tb = 1;
        //Reset
        Reset_tb = 1;
        #1
        Reset_tb = 0;
        #1
        Reset_tb = 1;
        #1

        $display("addition test");

        A_tb = 16'd11;
        B_tb = 16'd300;
        ALU_FUN_tb = 4'd0;
        #7
        if (ALU_out_tb != 32'd311) begin
            $display ("addition test FAILED") ;
        end
        else begin
            $display ("addition test PASSED") ;
        end
        
        #3

        $display("substraction test");

        A_tb = 16'd542;
        B_tb = 16'd42;
        ALU_FUN_tb = 4'd1;
        #7
        if (ALU_out_tb != 32'd500) begin
            $display ("substraction test FAILED") ;
        end
        else begin
            $display ("substraction test PASSED") ;
        end

        #3

        $display("multiply test");

        A_tb = 16'd2222;
        B_tb = 16'd2222;
        ALU_FUN_tb = 4'd2;
        #7
        if (ALU_out_tb != 32'd4937284) begin
            $display ("multiply test FAILED") ;
        end
        else begin
            $display ("multiply test PASSED") ;
        end

        #3

        $display("div test");

        A_tb = 16'd999;
        B_tb = 16'd9;
        ALU_FUN_tb = 4'd3;
        #7
        if (ALU_out_tb != 32'd111) begin
            $display ("div test FAILED") ;
        end
        else begin
            $display ("div test PASSED") ;
        end

        #3

        $display("AND test");

        A_tb = 16'b1011101010101010;
        B_tb = 16'b1000110011101110;
        ALU_FUN_tb = 4'd4;
        #7
        if (ALU_out_tb != 32'b1000100010101010) begin
            $display ("AND test FAILED") ;
        end
        else begin
            $display ("AND test PASSED") ;
        end

        #3

        $display("or test");

        A_tb = 16'b1011101010101010;
        B_tb = 16'b1000110011101110;
        ALU_FUN_tb = 4'd5;
        #7
        if (ALU_out_tb != 32'b1011111011101110) begin
            $display ("OR test FAILED") ;
        end
        else begin
            $display ("OR test PASSED") ;
        end

        #3

        $display("NAND test");

        A_tb = 16'b1011101010101010;
        B_tb = 16'b1000110011101110;
        ALU_FUN_tb = 4'd6;
        #7
        if (ALU_out_tb[15:0] != 16'b0111011101010101) begin
            $display ("NAND test FAILED") ;
        end
        else begin
            $display ("NAND test PASSED") ;
        end

        #3

        $display("NOR test");

        A_tb = 16'b1011101010101010;
        B_tb = 16'b1000110011101110;
        ALU_FUN_tb = 4'd7;
        #7
        if (ALU_out_tb[15:0] != 16'b0100000100010001) begin
            $display ("NOR test FAILED") ;
        end
        else begin
            $display ("NOR test PASSED") ;
        end

        #3

        $display("XOR test");

        A_tb = 16'b1011101010101010;
        B_tb = 16'b1000110011101110;
        ALU_FUN_tb = 4'd8;
        #7
        if (ALU_out_tb[15:0] != 16'b0011011001000100) begin
            $display ("XOR test FAILED") ;
        end
        else begin
            $display ("XOR test PASSED") ;
        end

        #3

        $display("XNOR test");

        A_tb = 16'b1011101010101010;
        B_tb = 16'b1000110011101110;
        ALU_FUN_tb = 4'd9;
        #7
        if (ALU_out_tb[15:0] != 16'b1100100110111011) begin
            $display ("XNOR test FAILED") ;
        end
        else begin
            $display ("XNOR test PASSED") ;
        end
        
        #3

        $display("equality test");

        A_tb = 16'd762;
        B_tb = 16'd762;
        ALU_FUN_tb = 4'd10;
        #7
        if (ALU_out_tb != 32'b1) begin
            $display ("equality test FAILED") ;
        end
        else begin
            $display ("equality test PASSED") ;
        end

        #3

        $display("not equality test");

        A_tb = 16'd342;
        B_tb = 16'd711;
        ALU_FUN_tb = 4'd10;
        #7
        if (ALU_out_tb == 32'b0) begin
            $display ("equality test PASSED") ;
        end
        else begin
            $display ("equality test FAILED") ;
        end

        #3

        $display("> test");

        A_tb = 16'd7787;
        B_tb = 16'd778;
        ALU_FUN_tb = 4'd11;
        #7
        if (ALU_out_tb != 32'd2) begin
            $display ("> test FAILED") ;
        end
        else begin
            $display ("> test PASSED") ;
        end

        #3

        $display("not > test");

        A_tb = 16'd7628;
        B_tb = 16'd7911;
        ALU_FUN_tb = 4'd11;
        #7
        if (ALU_out_tb == 32'b0) begin
            $display ("not > test PASSED") ;
        end
        else begin
            $display ("not > test FAILED") ;
        end

        #3

        $display("< test");

        A_tb = 16'd7877;
        B_tb = 16'd7977;
        ALU_FUN_tb = 4'd12;
        #7
        if (ALU_out_tb != 32'd3) begin
            $display ("< test FAILED") ;
        end
        else begin
            $display ("< test PASSED") ;
        end

        #3

        $display("not < test");

        A_tb = 16'd7628;
        B_tb = 16'd71;
        ALU_FUN_tb = 4'd12;
        #7
        if (ALU_out_tb == 32'b0) begin
            $display ("not < test PASSED") ;
        end
        else begin
            $display ("not < test FAILED") ;
        end

        #3

        $display(">> test");

        A_tb = 16'b1101010110110101;
        ALU_FUN_tb = 4'd13;
        #7
        if (ALU_out_tb != 32'b0110101011011010) begin
            $display (">> test FAILED") ;
        end
        else begin
            $display (">> test PASSED") ;
        end

        #3

        $display("<< test");

        A_tb = 16'b1101010110110101;
        ALU_FUN_tb = 4'd14;
        #7
        if (ALU_out_tb != 32'b11010101101101010) begin
            $display ("<< test FAILED") ;
        end
        else begin
            $display ("<< test PASSED") ;
        end

        #3

        $display("default test");

        A_tb = 16'b1101010110110101;
        ALU_FUN_tb = 4'd15;
        #7
        if (ALU_out_tb != 32'b0) begin
            $display ("default test FAILED") ;
        end
        else begin
            $display ("default test PASSED") ;
        end     

        
        ALU_EN_tb = 0;
        #3

        $display("enable test");

        A_tb = 16'd6;
        B_tb = 16'd6;
        ALU_FUN_tb = 4'd0;
        #7
        if (ALU_out_tb == 32'b0) begin
            $display ("enable test passed") ;
        end
        else begin
            $display ("enable test failed") ;
        end
        #100
        $stop;

    end

    always #5 clk_tb = ~clk_tb;

endmodule
