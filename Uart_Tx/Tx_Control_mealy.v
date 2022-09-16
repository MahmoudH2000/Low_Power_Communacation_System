module Tx_Control_mealy (
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
reg [1:0] Mux_control_comp;
reg       Busy_comp;


//state transision always
always @(posedge CLK, negedge Reset) begin
    if (!Reset) begin
        curr_state  <= Idle;
        Ser_EN      <= 1'b0;
        Mux_control <= 2'b00;
        Busy        <= 1'b0;
    end
    else begin
        curr_state <= next_state;
        Mux_control <= Mux_control_comp;
        Busy        <= Busy_comp;
    end
end

//next state and output logic
always @(*) begin
    case (curr_state)

        Idle: begin
            if (Data_valid && Reset) begin
                next_state  = Start;
                Mux_control_comp = 2'b00;
                Busy_comp        = 1'b1;
                Ser_EN           = 1'b0;
            end
            else begin
                next_state  = Idle;
                Mux_control_comp = 2'b01;
                Busy_comp        = 1'b0;
                Ser_EN           = 1'b0;
            end
        end
        
        Start: begin
            next_state  = Send;
            Mux_control_comp = 2'b10;
            Busy_comp        = 1'b1;
            Ser_EN           = 1'b1;
        end 

        Send: begin
            if (!Ser_done) begin
                next_state  = Send; 
                Mux_control_comp = 2'b10;
                Busy_comp        = 1'b1;
                Ser_EN           = 1'b1;
            end
            else begin
                if (Parity_EN) begin
                    next_state  = Parity;
                    Mux_control_comp = 2'b11;
                    Busy_comp        = 1'b1;
                    Ser_EN           = 1'b0;
                end
                else begin
                    next_state  = Idle;
                    Mux_control_comp = 2'b01;
                    Busy_comp        = 1'b1;
                    Ser_EN           = 1'b0;
                end
            end
        end

        Parity: begin
            next_state = Idle;
            Mux_control_comp = 2'b01;
            Busy_comp        = 1'b1;
            Ser_EN           = 1'b0;
        end

        default: begin
            next_state  = Idle;
            Mux_control_comp = 2'b01;
            Busy_comp        = 1'b0;
            Ser_EN           = 1'b0;
        end 
    endcase
end


    
endmodule