module Tx_Control (
    //input & output ports
    input  wire       CLK,
    input  wire       Reset,
    input  wire       Ser_done,
    input  wire       Data_valid,
    input  wire       Parity_EN,
    output reg        Ser_EN,
    output reg  [1:0] Mux_control,
    output reg        Busy
);

localparam Idle   = 2'b00;
localparam Start  = 2'b01;
localparam Send   = 2'b11;
localparam Parity = 2'b10;

reg [1:0] next_state;
reg [1:0] curr_state;

//state transision always
always @(posedge CLK, negedge Reset) begin
    if (!Reset) begin
        curr_state <= Idle;
    end
    else begin
        curr_state <= next_state;
    end
end

//next state logic
always @(*) begin
    case (curr_state)

        Idle: begin
            if (Data_valid) begin
                next_state = Start;
            end
            else begin
                next_state = Idle;
            end
        end
        
        Start: next_state = Send;

        Send: begin
            if (!Ser_done) begin
                next_state = Send;
            end
            else begin
                if (Parity_EN) begin
                    next_state = Parity;
                end
                else begin
                    next_state = Idle;
                end
            end
        end

        Parity: next_state = Idle;

        default: next_state = Idle;
    endcase
end

//output always
always @(*) begin
    case(curr_state)

        Idle: begin
            Mux_control = 2'b01;
            Busy        = 1'b0;
            Ser_EN      = 1'b0;
        end
        
        Start: begin
            Mux_control = 2'b00;
            Busy        = 1'b1;
            Ser_EN      = 1'b1;
        end

        Send: begin
            Mux_control = 2'b10;
            Busy        = 1'b1;
            Ser_EN      = 1'b1;
        end

        Parity: begin
            Mux_control = 2'b11;
            Busy        = 1'b1;
            Ser_EN      = 1'b0;
        end

        default: begin
            Mux_control = 2'b01;
            Busy        = 1'b0;
            Ser_EN      = 1'b0; 
        end

    endcase
end
    
endmodule