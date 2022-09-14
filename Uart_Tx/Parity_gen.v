module Parity_gen #(parameter width = 8)(
    //input & output ports
    input  wire             Parity_type,
    input  wire [width-1:0] Data,
    output wire             Parity_bit
);

assign Parity_bit = Parity_type ? (~^Data):(^Data);

endmodule