module Tx_Control (
    //input & output ports
    input  wire       CLK,
    input  wire       Reset,
    input  wire       Ser_done,       // when the serializer is done with the data
    input  wire       Data_valid,     // high for one CLK cycle it tells me that the data is ready
    input  wire       Parity_EN,      // parity Enable
    output reg        Ser_EN,         // to tell the serializer to start working
    output reg        Busy,           // high when the uart is sending (I.e. not Idle)   
    output reg  [1:0] Mux_control,   
    output reg        valid_instop,   // if the data_valid is high during the stop state it gets high to make it send data
    output reg        can_send        // an output to tell the master that you can send again     
);

/*
the module is a finite state machine that controls the uart workings. 
it has five state either Idle, start, send, and Parity.
when the data_valid is raised the Ser_EN gets high and it sends the start bit hence he next state is start.
as it sends the start bit the serializer has already loaded the data and is ready to send the first bit.
next the FSM imediatly goes to the Send state and doen't change its state till the serializer send the Ser_done.
when the Ser_done is raised we check the Parity enable signal if it's high we go to the parity state then the parity state
if not we go the Idle state directly.
*/


/*   state diclation   */
localparam Idle   = 3'b000;
localparam Start  = 3'b001;
localparam Send   = 3'b011;
localparam Parity = 3'b010;
localparam Stop   = 3'b110;

reg [2:0] next_state;
reg [2:0] curr_state;

/*  state transision always */
always @(posedge CLK, negedge Reset) begin
    if (!Reset) begin
        curr_state  <= Idle;
    end
    else begin
        curr_state  <= next_state;
    end
end

/*  next state and output logic */
always @(*) begin
    can_send = 0;
    case (curr_state)

        Idle: begin
            if (Data_valid) begin
                next_state  = Start;
                
            end
            else begin
                next_state  = Idle;
            end
            Mux_control  = 2'b01;
            Busy         = 1'b0;
            Ser_EN       = 1'b0;
            valid_instop = 0;
        end
        
        Start: begin
            next_state  = Send;
            Mux_control = 2'b00;
            Busy        = 1'b1;
            Ser_EN      = 1'b1;
            valid_instop = 0;
        end 

        Send: begin
            if (!Ser_done) begin
                can_send     = 0;
                next_state  = Send; 
            end
            else begin
                if (Parity_EN) begin
                    can_send     = 1;
                    next_state  = Parity;
                end
                else begin
                    can_send     = 1;
                    next_state  = Stop;
                end
            end
            Mux_control = 2'b10;
            Busy        = 1'b1;
            Ser_EN      = 1'b1;
            valid_instop = 0;
        end

        Parity: begin
            next_state  = Stop;
            Mux_control = 2'b11;
            Busy        = 1'b1;
            Ser_EN      = 1'b0;
            valid_instop = 0;
        end

        Stop: begin
            if (Data_valid) begin
                next_state  = Start;
                valid_instop = 1;
            end
            else begin
                next_state  = Idle;
                valid_instop = 0;
            end
            Mux_control = 2'b01;
            Busy        = 1'b1;
            Ser_EN      = 1'b0;
        end

        default: begin
            next_state  = Idle;
            Mux_control = 2'b01;
            Busy        = 1'b0;
            Ser_EN      = 1'b0;
            valid_instop = 0;
            can_send     =0;
        end 
    endcase
end


    
endmodule