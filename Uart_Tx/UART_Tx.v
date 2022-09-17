module UART_Tx  #(parameter width = 8)(
    //input & output ports
    input  wire             CLK,
    input  wire             Reset,
    input  wire             Parity_type,
    input  wire             Parity_EN,
    input  wire             Data_valid,
    input  wire [width-1:0] Data,
    output reg              Busy,
    output reg              Tx_out
);

wire       Parity_bit;
wire [1:0] Mux_control;
wire       Ser_done;
wire       Ser_Data;
wire       Ser_EN;
wire       Busy_comp;
reg        Tx_out_comp;

always @(*) begin
    case (Mux_control)
        2'b00: Tx_out_comp = 1'b0;
        2'b01: Tx_out_comp = 1'b1;
        2'b10: Tx_out_comp = Ser_Data;
        2'b11: Tx_out_comp = Parity_bit;
    endcase
end

always @(posedge CLK, negedge Reset) begin
    if (!Reset) begin
        Tx_out <= 1'b0;
        Busy   <= 1'b0;
    end
    else begin
        Tx_out <= Tx_out_comp;
        Busy   <= Busy_comp;
    end
end

assign Parity_bit = Parity_type ? (~^Data):(^Data);

Tx_Control_mealy Tx_Control_mealy_top(
    //input & output ports
    .CLK(CLK),
    .Reset(Reset),
    .Ser_done(Ser_done),
    .Data_valid(Data_valid),
    .Parity_EN(Parity_EN),
    .Ser_EN(Ser_EN),
    .Mux_control(Mux_control),
    .Busy(Busy_comp)
);

serializer #(.width(width)) serializer_top(
    //input & output ports
    .CLK(CLK),
    .Reset(Reset),
    .Data(Data),
    .Data_valid(Data_valid),
    .Ser_EN(Ser_EN),
    .Busy(Busy),
    .Ser_data(Ser_Data),
    .Ser_done(Ser_done)
);
    
endmodule