`timescale 1ns/1ps
module UART_Tx_tb ();

/* tp signals diclaration */ 
reg            CLK_tb;
reg            Reset_tb;
reg            Parity_type_tb;
reg            Parity_EN_tb;
reg            Data_valid_tb;
reg  [7:0]     Data_tb;
wire           Busy_tb;
wire           Tx_out_tb;

/* UART_Tx instantiation */
UART_Tx  #(.width(8)) DUT(
    //input & output ports
    .CLK(CLK_tb),
    .Reset(Reset_tb),
    .Parity_type(Parity_type_tb),
    .Parity_EN(Parity_EN_tb),
    .Data_valid(Data_valid_tb),
    .Data(Data_tb),
    .Busy(Busy_tb),
    .Tx_out(Tx_out_tb)
);


initial begin
// signals itialization 
CLK_tb         = 1'b1;
Reset_tb       = 1'b1;
Data_tb        = 8'b01010101;
Parity_EN_tb   = 1'b1;
Parity_type_tb = 1'b0;
Data_valid_tb  = 1'b0;
// Reset
#2.5
Reset_tb       = 1'b0;    
#2.5
Reset_tb       = 1'b1; 
#102

// raising the data valid
Data_valid_tb  = 1'b1;
#5
Data_valid_tb  = 1'b0;

//change the data
#5
Data_tb        = 8'b10101010;

// raising the data valid to test that the Uart doen't work during sending
#25
Data_valid_tb  = 1'b1;
#5
Data_valid_tb  = 1'b0;
#20

// raising the data valid to send the new data again and chaning the parity
Parity_type_tb = 1'b1;
Data_valid_tb  = 1'b1;
#5
Data_valid_tb  = 1'b0;
#100

// disenabling the parity bit and puting new data on the bus
Data_tb        = 8'b11001010;
Parity_EN_tb   = 1'b0;
#5

// raising the data valid to send the new data again
Data_valid_tb  = 1'b1;
#5
Data_valid_tb  = 1'b0;

#100

$stop;
end
 
always #2.5 CLK_tb = ~CLK_tb ;

endmodule