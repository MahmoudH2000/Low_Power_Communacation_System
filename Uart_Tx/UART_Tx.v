module UART_Tx  #(parameter width = 8)(
    //input & output ports
    input  wire             CLK,
    input  wire             Reset,
    input  wire             Parity_type, // odd or even
    input  wire             Parity_EN,   // enable the parity or send with out it
    input  wire             Data_valid,  // High for one CLK cycle it tells me that the data is ready
    input  wire [width-1:0] Data,        
    output reg              Busy,        // high when the uart is sending (I.e. not Idle)
    output reg              Tx_out       // data sent
);

/*
the Uart receved the data and waits for the Data_valid signal 
when it gets high the serializer and the FSM start working
*/ 


/*      internal signals    */
wire       Parity_bit;
wire [1:0] Mux_control;
wire       Ser_done;
wire       Ser_Data;
wire       Ser_EN;
reg        Tx_out_comp;
wire       Busy_comp;
wire       valid_instop;


/*   the MUX that controls which output to send
     start bit                     = 00
     stop bit and Idle             = 01
     data (I.e. serializer output) = 10 
     parity bit                    = 11            */
always @(*) begin
    case (Mux_control)
        2'b00: Tx_out_comp = 1'b0;
        2'b01: Tx_out_comp = 1'b1;
        2'b10: Tx_out_comp = Ser_Data;
        2'b11: Tx_out_comp = Parity_bit;
    endcase
end

/* registering the outputs */
always @(posedge CLK, negedge Reset) begin
    if (!Reset) begin
        Tx_out <= 1'b0;
        Busy   <= 0;
    end
    else begin
        Tx_out <= Tx_out_comp;
        Busy   <= Busy_comp;
    end
end

/* Parit bit calculation*/
assign Parity_bit = Parity_type ? (~^Data):(^Data);

/* FSM instantiation */
Tx_Control Tx_Control_mealy_top(
    .CLK(CLK),
    .Reset(Reset),
    .Ser_done(Ser_done),
    .Data_valid(Data_valid),
    .Parity_EN(Parity_EN),
    .Ser_EN(Ser_EN),
    .Mux_control(Mux_control),
    .Busy(Busy_comp),
    .valid_instop(valid_instop)
);

/* serializer instantiation */
serializer #(.width(width)) serializer_top(
    .CLK(CLK),
    .Reset(Reset),
    .valid_instop(valid_instop),
    .Data(Data),
    .Data_valid(Data_valid),
    .Ser_EN(Ser_EN),
    .Busy(Busy_comp),
    .Ser_data(Ser_Data),
    .Ser_done(Ser_done)
);
    
endmodule