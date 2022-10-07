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
    input  wire  [(2*width)-1:0]      ALU_out,
    input  wire                       ALU_out_valid,
    output reg                        ALU_EN,               
    output reg   [3:0]                ALU_FUN, 
    //---------------------------------------------
    /*       Reg_File inputs & outputs           */
    //---------------------------------------------
    input  wire  [width-1:0]          RdData,
    input  wire                       Rd_valid,
    output wire  [$clog2(depth)-1:0]  Reg_File_Adress,               
    output reg                        WrEN,               
    output reg                        RdEN,               
    output reg   [width-1:0]          WrData,
    //---------------------------------------------
    /*     transmitter inputs & outputs          */
    //---------------------------------------------
    input  wire                        Busy,
    output reg   [width-1:0]           Tx_Data,
    output reg                         Tx_Data_valid,
    //---------------------------------------------
    /*               CLK_Gate                    */
    //---------------------------------------------   
    output reg                        CLK_GATE_EN   
);

//---------------------------------------------
/*          Tx_Control instantiation         */
//---------------------------------------------
Tx_Control #(.width(width)) Tx_Control_top (
    .CLK(CLK),       
    .Reset(Reset),
    .RdData(RdData),
    .Rd_valid(Rd_valid),
    .ALU_out(ALU_out),
    .ALU_out_valid(ALU_out_valid),
    .ALU_FUN(ALU_FUN),
    .Busy(Busy),
    .Tx_Data(Tx_Data),
    .Tx_Data_valid(Tx_Data_valid)
);

//---------------------------------------------
/*          Rx_Control instantiation         */
//---------------------------------------------
Rx_Control #(.width(width), .depth(depth)) 
Rx_Control_top(
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
    
endmodule