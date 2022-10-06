module Tx_Control #(
    parameter width = 8
) (
    // input & outputs ports
    input  wire  [width-1:0]           RdData,
    input  wire                        Rd_valid,
    input  wire  [(2*width)-1:0]       ALU_out,
    input  wire                        ALU_out_valid,
    input  wire  [3:0]                 ALU_FUN,
    input  wire                        ALU_EN,               
    input  wire                        RdEN,
    output reg   [width-1:0]           Tx_Data,
    output reg                         Tx_Data_valid
);



endmodule