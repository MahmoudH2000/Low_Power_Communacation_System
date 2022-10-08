`timescale 1ps/1ps
module SYS_TP ();
    
integer i;    
//-------------------------//
/*  parameters definition  */   
//-------------------------//
parameter width = 8;
parameter depth = 16;

//-------------------------//
/*    DUT instantiation    */   
//-------------------------//
reg  REF_CLK_tb;
reg  UART_CLK_tb;
reg  Reset_tb;
reg  Rx_IN_tb;
wire Tx_out_tb;
wire Parity_error_tb;
wire Stop_error_tb;

SYS_TOP #(
    .width(width),
    .depth(depth)
) DUT (
    .REF_CLK(REF_CLK_tb),
    .UART_CLK(UART_CLK_tb),
    .Reset(Reset_tb),
    .Rx_IN(Rx_IN_tb),
    .Tx_out(Tx_out_tb),
    .Parity_error(Parity_error_tb),
    .Stop_error(Stop_error_tb)
);

//-------------------------//
/*      initial block      */   
//-------------------------//

initial begin
REF_CLK_tb        = 1'b1;
UART_CLK_tb       = 1'b1;
Reset_tb          = 1'b1;
Rx_IN_tb          = 1'b1;

//  Reset
#100
Reset_tb = 1'b0;   
#100
Reset_tb = 1'b1;  

#30 

send_data_P(11'b0_01010101_0_1); // write
send_data_P(11'b0_01010000_0_1); // Adress = 1010
send_data_P(11'b0_11111111_0_1); // data = 11111111
#200
send_data_P(11'b0_11011101_0_1); // Read
send_data_P(11'b0_01010000_0_1); // Adress = 1010
#200
send_data_P(11'b0_00110011_0_1); // ALU_OP
send_data_P(11'b0_11110000_0_1); // A = 00001111
send_data_P(11'b0_11111111_0_1); // B = 11111111
send_data_P(11'b0_00000000_0_1); // ADD = 100001110
#200
send_data_P(11'b0_00110011_0_1); // ALU_OP
send_data_P(11'b0_00010000_1_1); // A = 8
send_data_P(11'b0_00000001_1_1); // B = 128
send_data_P(11'b0_01000000_1_1); // mul = 100_00000000
#8800
send_data_P(11'b0_10111011_0_1); // ALU_with_no_OP
send_data_P(11'b0_11010000_1_1); // compare A > B
#200
send_data_P(11'b0_10111011_0_1); // ALU_with_no_OP
send_data_P(11'b0_00110000_0_1); // compare A < B

#100000

$stop ;

end

task send_data_P (
    input  [width+2:0] data
);
begin
    for (i = width+2; i>=0; i=i-1) begin
        Rx_IN_tb = data[i];
        #(8*100);
    end
end
endtask

always #50 UART_CLK_tb = ~UART_CLK_tb ;
always #1 REF_CLK_tb  = ~REF_CLK_tb ;


endmodule