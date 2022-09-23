module Parity_check (
    // input & output ports
    input  wire       CLK,
    input  wire       Reset,
    input  wire       Parity_bit,
    input  wire [7:0] P_Data,
    input  wire       Parity_type,
    input  wire       Parity_check_EN,
    output reg        Parity_error
);
    
wire Data_Parity;
wire Parity_error_comp;

assign Data_Parity = Parity_type ? (~^P_Data):(^P_Data);

assign Parity_error_comp = (Data_Parity == Parity_bit) ? 1'b0:1'b1;

always @(posedge CLK, negedge Reset) begin
    if (!Reset) begin
        Parity_error <= 1'b0;
    end
    else if (Parity_check_EN) begin
        Parity_error <= Parity_error_comp;
    end
    else begin
        Parity_error <= 1'b0;
    end
end

endmodule