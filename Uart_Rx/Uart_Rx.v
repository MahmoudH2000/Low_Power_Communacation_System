module Uart_Rx (
    // input & output ports
    input  wire        CLK,
    input  wire        Reset,
    input  wire        S_Data,
    input  wire        Parity_EN,
    input  wire        Parity_type,
    input  wire  [4:0] Prescale,    // note that it has to be >= 5
    output wire        Parity_error,
    output wire        stop_error,
    output wire        Data_valid,
    output wire  [7:0] P_Data
);

//  internal signals
wire        S_EN;
wire        deser_en;
wire        Parity_check_EN;
wire        start_check_EN;
wire        stop_check_EN;
wire        sampled;
wire        Sampled_bit;
wire  [3:0] bit_count;
wire  [4:0] edge_count;
wire        start_error;

/*  Edge Bit Counter instantiation */
Edge_Bit_Counter Edge_Bit_Counter_top(
    // input & output ports
    .CLK(CLK),
    .Reset(Reset),
    .Prescale(Prescale),
    .count_EN(S_EN),
    .bit_count(bit_count),
    .edge_count(edge_count)
);

/*  Data sampler instantiation */
Data_sampler Data_sampler_top(
    // input & output ports
    .CLK(CLK),
    .Reset(Reset),
    .S_Data(S_Data),
    .edge_count(edge_count),
    .S_EN(S_EN), 
    .Prescale(Prescale),
    .sampled(sampled),
    .Sampled_bit(Sampled_bit)
);

/*  Deserializer instantiation */
Deserializer Deserializer_top(
    // input & output ports
    .CLK(CLK),    
    .Reset(Reset),  
    .sampled_data(Sampled_bit),
    .deser_en(deser_en),
    .sampled(sampled),
    .P_Data(P_Data)
);

/*  Parity bit checkerer instantiation */
Parity_check Parity_check_top(
    // input & output ports
    .CLK(CLK),
    .Reset(Reset),
    .Parity_bit(Sampled_bit),
    .P_Data(P_Data),
    .Parity_type(Parity_type),
    .Parity_check_EN(Parity_check_EN),
    .Parity_error(Parity_error)
);

/*  start bit checker instantiation */
start_check start_check_top(
    // input & output ports
    .CLK(CLK),
    .Reset(Reset),
    .start_bit(Sampled_bit),
    .start_check_EN(start_check_EN),
    .start_error(start_error)
);

/*  stop bit checker instantiation */
stop_check stop_check_top(
    // input & output ports
    .CLK(CLK),
    .Reset(Reset),
    .stop_bit(Sampled_bit),
    .stop_check_EN(stop_check_EN),
    .stop_error(stop_error)
);

/*  FSM instantiation */
Rx_control Rx_control_top(
    // input & output ports
    .CLK(CLK),
    .Reset(Reset),
    .S_Data(S_Data),
    .bit_count(bit_count),
    .sampled(sampled),
    .Parity_EN(Parity_EN),
    .Parity_error(Parity_error),
    .start_error(start_error),
    .stop_error(stop_error),
    .Parity_check_EN(Parity_check_EN),
    .start_check_EN(start_check_EN),
    .stop_check_EN(stop_check_EN),
    .S_EN(S_EN),
    .deser_en(deser_en),
    .Data_valid(Data_valid)
);

endmodule