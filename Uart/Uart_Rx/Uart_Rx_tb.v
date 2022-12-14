module Uart_Rx_tb ();

integer i;

parameter width = 8;

reg          CLK_tb;
reg          Reset_tb;
reg          S_Data_tb;
reg          Parity_EN_tb;
reg          Parity_type_tb;
reg  [4:0]   Prescale_tb;
wire         Parity_error_tb;
wire         stop_error_tb;
wire         Data_valid_tb;
wire [7:0]   P_Data_tb;

Uart_Rx #(.width(width))
DUT(
    // input & output ports
    .CLK(CLK_tb),
    .Reset(Reset_tb),
    .S_Data(S_Data_tb),
    .Parity_EN(Parity_EN_tb),
    .Parity_type(Parity_type_tb),
    .Prescale(Prescale_tb),
    .Parity_error(Parity_error_tb),
    .stop_error(stop_error_tb),
    .Data_valid(Data_valid_tb),
    .P_Data(P_Data_tb)
);
 
initial begin
CLK_tb            = 1'b1;
Reset_tb          = 1'b1;
S_Data_tb         = 1'b1;
Parity_EN_tb      = 1'b1;
Parity_type_tb    = 1'b0;
Prescale_tb       = 5'b01000;

//  Reset
#5
Reset_tb = 1'b0;   
#5
Reset_tb = 1'b1;  

#30 

send_data_P(11'b0_01010000_0_1); // send 10  with no errors
send_data_P(11'b0_00100110_1_1); // send 100 with no errors
send_data_P(11'b0_01010000_1_1); // send 10  with parity error
send_data_P(11'b0_00100110_0_1); // send 100 with parity error
send_data_P(11'b0_01010000_0_0); // send 10  with stop error
send_data_P(11'b0_00100110_1_0); // send 100 with stop error
send_data_P(11'b0_01001100_1_1); // send 50  with no errors
#100

// start glitch
Parity_type_tb    = 1'b1;
#2
S_Data_tb = 0;
#20
S_Data_tb = 1;
#((Prescale_tb-1)*20);


// send all ones 
S_Data_tb = 0;
#(Prescale_tb*20);
S_Data_tb = 1;
#(Prescale_tb*200);

// send 100 with no parity 
Parity_EN_tb      = 1'b0;
Parity_type_tb    = 1'b0;
send_data_no_P(10'b0_00100110_1);

#500

$stop ;

end

task send_data_P (
    input  [10:0] data
);
begin
    for (i = 10; i>=0; i=i-1) begin
        S_Data_tb = data[i];
        #(Prescale_tb*20);
    end
end

endtask

task send_data_no_P (
    input  [9:0] data
);
begin
    for (i = 9; i>=0; i=i-1) begin
        S_Data_tb = data[i];
        #(Prescale_tb*20);
    end
end

endtask
 

always #10 CLK_tb = ~CLK_tb ;



endmodule