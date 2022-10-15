module SYS_Control #(
    parameter width = 8,
    parameter depth = 16
) (
    //---------------------------------------------
    /*            CLK & Reset                    */
    //---------------------------------------------
    input  wire                       CLK,       
    input  wire                       Reset,
    //---------------------------------------------
    /*          Receiver_output                  */
    //---------------------------------------------
    input  wire  [width-1:0]          Rx_P_Data,
    input  wire                       RxValid,
    //---------------------------------------------
    /*        ALU inputs & outputs               */
    //---------------------------------------------
    output wire                       ALU_EN,               
    output wire  [3:0]                ALU_FUN, 
    //---------------------------------------------
    /*       Reg_File inputs & outputs           */
    //---------------------------------------------
    output wire  [$clog2(depth)-1:0]  Reg_File_Adress,               
    output wire                       WrEN,               
    output wire                       RdEN,               
    output wire  [width-1:0]          WrData,
    //---------------------------------------------
    /*     transmitter inputs & outputs          */
    //---------------------------------------------
    input  wire                       Busy, // to tell the controller you can send
    input  wire                       can_send, // to tell the controller you can send
    //---------------------------------------------
    /*                 FIFO                      */
    //--------------------------------------------- 
    input  wire                       Empty,
    output wire                       FIFO_EN,
    //---------------------------------------------
    /*               CLK_Gate                    */
    //---------------------------------------------   
    output wire                       CLK_GATE_EN   
);

//---------------------------------------------
/*          Rx_Control instantiation         */
//---------------------------------------------
SYS_CNTR_Rx #(.width(width), .depth(depth)) 
SYS_CNTR_Rx_top(
    .CLK(CLK),       
    .Reset(Reset),
    .Rx_P_Data(Rx_P_Data),
    .RxValid(RxValid),
    .ALU_EN(ALU_EN),               
    .ALU_FUN(ALU_FUN), 
    .Reg_File_Adress(Reg_File_Adress),               
    .WrEN(WrEN),               
    .RdEN(RdEN),               
    .WrData(WrData),  
    .CLK_GATE_EN(CLK_GATE_EN)
);

//---------------------------------------------
/*          Tx_Control instantiation         */
//---------------------------------------------
SYS_CNTR_Tx SYS_CNTR_Tx_top(
    .CLK(CLK),       
    .Reset(Reset),
    .Busy(Busy),
    .can_send(can_send),
    .Empty(Empty),
    .FIFO_EN(FIFO_EN)
);


    
endmodule