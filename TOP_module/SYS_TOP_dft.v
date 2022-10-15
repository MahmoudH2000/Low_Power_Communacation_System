module SYS_TOP #(
    parameter width = 8,
    parameter depth = 16
) (
    //------------------------------------//
    //            DFT_signals             //
    //------------------------------------//
    input  wire              scan_CLK,
	input  wire              scan_RST,
	input  wire  [2:0]       SI,
	output wire  [2:0]       SO,
	input  wire              test_mode,
	input  wire              SE,
    //------------------------------------//
    //       input & output signals       //
    //------------------------------------//
    input  wire              REF_CLK,
    input  wire              UART_CLK,
    input  wire              Reset,
    input  wire              Rx_IN,
    output wire              Tx_out,
    output wire              Parity_error,
    output wire              Stop_error
);

wire                      Tx_CLK;
wire                      REF_RST;
wire                      Uart_RST;
wire                      Gated_CLK;
wire [width-1:0]          Rx_out;
wire [width-1:0]          Rx_out_sync;
wire                      Busy_sync;
wire                      Busy;
wire [width-1:0]          Tx_Data_REF; //unsync
wire [width-1:0]          Tx_IN;
wire                      RxValid;
wire                      RxValid_sync;
wire                      Tx_valid_REF; //unsync
wire                      Tx_valid;
wire [(2*width)-1:0]      ALU_out;
wire                      ALU_out_valid;
wire                      ALU_EN;
wire [3:0]                ALU_FUN; 
wire [width-1:0]          RdData;
wire                      Rd_valid;
wire [$clog2(depth)-1:0]  Reg_File_Adress;
wire                      WrEN;
wire                      RdEN;
wire [width-1:0]          WrData;
wire                      CLK_GATE_EN;
wire [width-1:0]          REG0;
wire [width-1:0]          REG1;
wire [width-1:0]          REG2;
wire [width-1:0]          REG3;
wire                      can_send;
wire                      can_send_sync;
wire                      Empty;
wire                      FIFO_EN;

//----------------------------------------------------------//
//                           DFT                            //
//----------------------------------------------------------//
wire CLK_M_REF;  
wire CLK_M_UART; 
wire div_CLK_M;  
wire RST_M;     
wire RST_M_UART;
wire RST_M_REF;  

assign CLK_M_REF  = test_mode ? scan_CLK : REF_CLK;
assign CLK_M_UART = test_mode ? scan_CLK : UART_CLK;
assign div_CLK_M  = test_mode ? scan_CLK : Tx_CLK;
assign RST_M      = test_mode ? scan_RST : Reset;
assign RST_M_UART = test_mode ? scan_RST : Uart_RST;
assign RST_M_REF  = test_mode ? scan_RST : REF_RST;

//---------------------------------------------
/*         FIFO instantiation                */
//---------------------------------------------
SYNC_FIFO #(.width(width),
            .FDPTH(4)) SYNC_FIFO_top(
    // input & output ports
    .CLK(CLK_M_REF),
    .Reset(RST_M_REF),
    .ALU_valid(ALU_out_valid),
    .RD_valid(Rd_valid),
    .RD_EN(FIFO_EN),
    .ALU_FUN(ALU_FUN),
    .ALU_out(ALU_out),
    .RD_out(RdData),
    .Embty(Empty),
    .Data(Tx_Data_REF),
    .valid(Tx_valid_REF)
);

//---------------------------------------------
/*       SYSTEM Control instantiation        */
//---------------------------------------------
SYS_Control #(
    .width(width),
    .depth(depth)
) SYS_Control_top(
    .CLK(CLK_M_REF),       
    .Reset(RST_M_REF),
    .Rx_P_Data(Rx_out_sync),
    .RxValid(RxValid_sync),
    .ALU_EN(ALU_EN),               
    .ALU_FUN(ALU_FUN),
    .Reg_File_Adress(Reg_File_Adress),               
    .WrEN(WrEN),               
    .RdEN(RdEN),               
    .WrData(WrData),
    .Busy(Busy_sync),
    .can_send(can_send_sync),
    .Empty(Empty),
    .FIFO_EN(FIFO_EN),
    .CLK_GATE_EN(CLK_GATE_EN) 
);

//---------------------------------------------
/*          CLOCK GATE instantiation         */
//---------------------------------------------
CLK_GATE CLK_GATE_top(
    .CLK_EN(CLK_GATE_EN||test_mode),
    .CLK(CLK_M_REF),
    .GATED_CLK(Gated_CLK)
);

//---------------------------------------------
/*        REF_RST sync instantiation         */
//---------------------------------------------
RST_SYNC #(.NUM_Stages(2)) 
RST_SYNC_REF(
    .CLK(CLK_M_REF), 
    .Async_Reset(Reset),
    .sync_Reset(REF_RST)
);

//---------------------------------------------
/*        UART_RST sync instantiation        */
//---------------------------------------------
RST_SYNC #(.NUM_Stages(2)) 
RST_SYNC_UART(
    .CLK(CLK_M_UART), 
    .Async_Reset(Reset),
    .sync_Reset(Uart_RST)
);

//---------------------------------------------
/*         CLOCK divider instantiation       */
//---------------------------------------------
CLK_div CLK_div_top(
    .CLK_Ref(CLK_M_UART),
    .Reset(RST_M_UART),
    .CLK_EN(1'b1),
    .div(REG3[3:0]),
    .CLK_div_out(Tx_CLK)
);

//---------------------------------------------
/*         Register File instantiation       */
//---------------------------------------------
RegFile #(.width(width), .depth(depth))
RegFile_top(
    .CLK(CLK_M_REF),
    .Reset(RST_M_REF),
    .WrEN(WrEN),
    .RdEN(RdEN),
    .WrData(WrData),
    .A(Reg_File_Adress),
    .REG0(REG0),
    .REG1(REG1),
    .REG2(REG2),
    .REG3(REG3),
    .RdData(RdData),
    .Rd_valid(Rd_valid)
);

//---------------------------------------------
/*              ALU instantiation            */
//---------------------------------------------
ALU #(.A_width(width),
      .B_width(width),
      .OUT_width(width*2)
) ALU_top (
    .CLK(Gated_CLK),
    .Reset(RST_M_REF),
    .ALU_EN(ALU_EN),
    .A(REG0), 
    .B(REG1),
    .ALU_FUN(ALU_FUN),
    .ALU_out(ALU_out),
    .Out_valid(ALU_out_valid)
);

//---------------------------------------------
/*        can_send bit sync instantiation    */
//---------------------------------------------
BIT_SYNC #(.NUM_Stages(2), 
           .Width(1)
) BIT_SYNC_CanSend (
    .Async_data(can_send), 
    .CLK(CLK_M_REF), 
    .Reset(RST_M_REF),
    .sync_data(can_send_sync)
);

//---------------------------------------------
/*          Busy bit sync instantiation      */
//---------------------------------------------
BIT_SYNC #(.NUM_Stages(2), 
           .Width(1)
) BIT_SYNC_Busy (
    .Async_data(Busy), 
    .CLK(CLK_M_REF), 
    .Reset(RST_M_REF),
    .sync_data(Busy_sync)
);

//---------------------------------------------
/*             Tx sync instantiation         */
//---------------------------------------------
DATA_SYNC_F2S #(.NUM_Stages(2), 
            .Width(width)
) DATA_SYNC_Tx (
    .Async_bus(Tx_Data_REF), 
    .bus_EN(Tx_valid_REF), 
    .CLK(div_CLK_M), 
    .Reset(RST_M_UART),
    .sync_bus(Tx_IN),
    .EN_pulse(Tx_valid)
);

//---------------------------------------------
/*             Rx sync instantiation         */
//---------------------------------------------
DATA_SYNC_S2F #(.NUM_Stages(2), 
            .Width(width)
) DATA_SYNC_Rx (
    .Async_bus(Rx_out), 
    .bus_EN(RxValid), 
    .CLK(CLK_M_REF), 
    .Reset(RST_M_REF),
    .sync_bus(Rx_out_sync),
    .EN_pulse(RxValid_sync)
);

//---------------------------------------------
/*               UART instantiation          */
//---------------------------------------------
UART  #(.width(width)
) UART_top(
    .Tx_CLK(div_CLK_M),
    .Rx_CLK(CLK_M_UART),
    .Reset(RST_M_UART),
    .Rx_IN(Rx_IN),
    .Rx_out(Rx_out),
    .Rx_valid(RxValid),
    .Parity_error(Parity_error),
    .stop_error(Stop_error),
    .Tx_valid(Tx_valid),    
    .TX_Data(Tx_IN),        
    .Busy(Busy),         
    .Tx_out(Tx_out),
    .Parity_EN(REG2[0]),
    .Parity_type(REG2[1]),
    .Prescale(REG2[6:2]),
    .can_send(can_send)    
);
    
endmodule