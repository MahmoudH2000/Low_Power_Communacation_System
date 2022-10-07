module stop_check (
    // input & output ports
    input  wire       CLK,
    input  wire       Reset,
    input  wire       stop_bit,        // STOP bit received 
    input  wire       stop_check_EN,   // enable signal 
    output reg        stop_error
);

wire stop_bit_check;
assign stop_bit_check = stop_bit == 1'b0; // error if not 1

always @(posedge CLK, negedge Reset) begin
    if (!Reset) begin
        stop_error <= 1'b0;
    end
    else if (stop_check_EN) begin
        stop_error <= stop_bit_check;
    end
end

endmodule