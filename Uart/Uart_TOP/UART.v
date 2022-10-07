module UART  #(parameter width = 8
) (
    //-------------------------------//
    /*        Clocks and Reset       */
    //-------------------------------//
    input  wire              Tx_CLK,
    input  wire              Rx_CLK,
    input  wire              Reset,
    //-------------------------------//
    /*     Rx inputs & outputs       */
    //-------------------------------//
    input  wire              Rx_IN,
    output wire  [width-1:0] Rx_out,
    output wire              Rx_valid,
    output wire              Parity_error,
    output wire              stop_error,
    //-------------------------------//
    /*     Rx inputs & outputs       */
    //-------------------------------//
    input  wire              Tx_valid,    // High for one CLK cycle it tells me that the data is ready
    input  wire  [7:0]       TX_Data,        
    output reg               Busy,         // high when the uart is sending (I.e. not Idle)
    //-------------------------------//
    /*        configurations         */
    //-------------------------------//
    input  wire              Parity_EN,
    input  wire              Parity_type,
    input  wire  [4:0]       Prescale    // note that it has to be >= 5
);

//---------------------------------------------
/*              Rx instantiation             */
//---------------------------------------------
Uart_Rx #(parameter width = 8) Uart_Rx_top
(
    .CLK(Rx_CLK),
    .Reset(Reset),
    .S_Data(Rx_IN),
    .Parity_EN(Parity_EN),
    .Parity_type(Parity_type),
    .Prescale(Prescale),
    .Parity_error(Parity_error),
    .stop_error(stop_error),
    .Data_valid(Rx_valid),
    .P_Data(Rx_out)
);
endmodule