module start_check (
    // input & output ports
    input  wire       CLK,
    input  wire       Reset,
    input  wire       start_bit,      // START bit received 
    input  wire       start_check_EN, // enable signal 
    output reg        start_error
);

wire start_bit_check;
assign start_bit_check = start_bit == 1'b1;  // error if not 0

always @(posedge CLK, negedge Reset) begin
    if (!Reset) begin
        start_error <= 1'b0;
    end
    else if (start_check_EN) begin
        start_error <= start_bit_check;
    end
end

endmodule