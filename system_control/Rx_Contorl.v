module Rx_Contorl #(
    parameter width = 8,
    parameter depth = 16
) (
    // input & output ports
    input  wire                       CLK,       
    input  wire                       Reset,
    input  wire  [width-1:0]          Rx_P_Data,
    input  wire                       RxValid,            
    input  wire  [width-1:0]          RdData,
    input  wire                       RdValid,
    output reg                        ALU_EN,               
    output reg                        ALU_FUN,               
    output reg                        CLK_GATE_EN,               
    output reg   [$clog2(depth)-1:0]  Reg_File_Adress,               
    output reg                        WrEN,               
    output reg                        RdEN,               
    output reg   [width-1:0]          WrData,              
);
    
endmodule