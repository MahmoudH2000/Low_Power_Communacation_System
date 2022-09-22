module stop_check (
    // input & output ports
    input  wire       CLK,
    input  wire       Reset,
    input  wire       stop_bit,
    input  wire       start_check_EN,
    output reg        stop_error
);

wire stop_bit_check;
assign stop_bit_check = stop_bit == 1'b0;

always @(posedge CLK, negedge Reset) begin
    if (!Reset) begin
        stop_error <= 1'b0;
    end
    else if (start_check_EN) begin
        stop_error <= stop_bit_check;
    end
    else begin
        stop_error <= 1'b0;
    end
end

endmodule