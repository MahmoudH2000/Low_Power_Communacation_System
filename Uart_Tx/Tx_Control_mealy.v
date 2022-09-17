module Tx_Control_mealy (
    //input & output ports
    input  wire       CLK,
    input  wire       Reset,
    input  wire       Ser_done,       // when the serializer is done with the data
    input  wire       Data_valid,     // high for one CLK cycle it tells me that the data is ready
    input  wire       Parity_EN,      // parity Enable
    output reg        Ser_EN,         // to tell the serializer to start working
    output reg  [1:0] Mux_control,   
    output reg        Busy            // high when the uart is sending (I.e. not Idle)
);

/*
the module is a finite state machine that controls the uart workings. 
it has four state either Idle, start, send, and Parity.
when the data_valid is raised the Ser_EN gets high and it sends the start bit hence he next state is start.
as it sends the start bit the serializer has already loaded the data and is ready to send the first bit.
next the FSM imediatly goes to the Send state and doen't change its state till the serializer send the Ser_done.
when the Ser_done is raised we check the Parity enable signal if it's high we go to the parity state then the parity state
if not we go the Idle state directly.
*/


/*   state diclation   */
localparam Idle   = 2'b00;
localparam Start  = 2'b01;
localparam Send   = 2'b11;
localparam Parity = 2'b10;

reg [1:0] next_state;
reg [1:0] curr_state;
reg       Busy_comp;

/*  state transision always */
always @(posedge CLK, negedge Reset) begin
    if (!Reset) begin
        curr_state  <= Idle;
        Busy        <= 0;
    end
    else begin
        curr_state <= next_state;
        Busy       <= Busy_comp;
    end
end

/*  next state and output logic */
always @(*) begin
    case (curr_state)

        Idle: begin
            if (Data_valid && !Busy) begin
                next_state  = Start;
                Mux_control = 2'b00;
                Busy_comp   = 1'b1;
                Ser_EN      = 1'b0;
            end
            else begin
                next_state  = Idle;
                Mux_control = 2'b01;
                Busy_comp   = 1'b0;
                Ser_EN      = 1'b0;
            end
        end
        
        Start: begin
            next_state  = Send;
            Mux_control = 2'b10;
            Busy_comp   = 1'b1;
            Ser_EN      = 1'b1;
        end 

        Send: begin
            if (!Ser_done) begin
                next_state  = Send; 
                Mux_control = 2'b10;
                Busy_comp   = 1'b1;
                Ser_EN      = 1'b1;
            end
            else begin
                if (Parity_EN) begin
                    next_state  = Parity;
                    Mux_control = 2'b11;
                    Busy_comp   = 1'b1;
                    Ser_EN      = 1'b0;
                end
                else begin
                    next_state  = Idle;
                    Mux_control = 2'b01;
                    Busy_comp   = 1'b1;
                    Ser_EN      = 1'b0;
                end
            end
        end

        Parity: begin
            next_state = Idle;
            Mux_control = 2'b01;
            Busy_comp   = 1'b1;
            Ser_EN      = 1'b0;
        end

        default: begin
            next_state  = Idle;
            Mux_control = 2'b01;
            Busy_comp   = 1'b0;
            Ser_EN      = 1'b0;
        end 
    endcase
end


    
endmodule