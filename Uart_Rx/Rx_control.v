module Rx_control (
    // input & output ports
    input  wire        CLK,
    input  wire        Reset,
    input  wire        S_Data,        // serial data receiveda
    input  wire  [3:0] bit_count,     // number of bits received
    input  wire        sampled,       // high for one clock cycle when a new bit is sampled
    input  wire        Parity_EN,
    input  wire        Parity_error,
    input  wire        start_error,
    input  wire        stop_error,
    input  wire        Last_edge,       // last edge in the bit
    output reg         Parity_check_EN, //enble signal
    output reg         start_check_EN,  //enble signal
    output reg         stop_check_EN,   //enble signal
    output reg         S_EN,            //enble signal
    output reg         deser_en,        //enble signal
    output reg         Data_valid       //high for one clock cycle when the data is received correctly
);

/* this is a finite state machine that has 6 states 
it's default state is the idle state but when the 
serial data to be received gets low to starts receiving*/

localparam Idle         = 3'b000;
localparam Start        = 3'b001;
localparam Receive      = 3'b011; 
localparam Parity       = 3'b010; 
localparam Stop         = 3'b110;
localparam error_check  = 3'b100; // check the Stop bit & parity bit

reg [2:0] next_state;
reg [2:0] curr_state;

/* state transition always*/
always @(posedge CLK, negedge Reset) begin
    if (!Reset) begin
        curr_state <= Idle;
    end
    else begin
        curr_state <= next_state;
    end
end
/* next state & ouput logic*/
always @(*) begin
    
    case (curr_state)

        Idle: begin
            if (!S_Data) begin
                next_state      = Start;
                Parity_check_EN = 0;
                start_check_EN  = 0; 
                stop_check_EN   = 0;
                S_EN            = 1; 
                deser_en        = 0;
                Data_valid      = 0;                
            end
            else begin
                next_state      = Idle;
                Parity_check_EN = 0;
                start_check_EN  = 0; 
                stop_check_EN   = 0;
                S_EN            = 0; 
                deser_en        = 0;
                Data_valid      = 0;
            end
        end

        Start: begin

            if (Last_edge) begin
                if (!start_error) begin
                    next_state      = Receive;
                    Parity_check_EN = 0;
                    stop_check_EN   = 0;
                    start_check_EN  = 0;
                    S_EN            = 1; 
                    deser_en        = 1;
                    Data_valid      = 0;
                end
                else begin
                        next_state      = Idle;
                        Parity_check_EN = 0;
                        start_check_EN  = 0;
                        stop_check_EN   = 0;
                        S_EN            = 0; 
                        deser_en        = 0;
                        Data_valid      = 0;
                    end 
                end
            else begin
                next_state      = Start;
                Parity_check_EN = 0;
                if (sampled) begin
                    start_check_EN  = 1; 
                end
                else begin
                    start_check_EN  = 0; 
                end 
                stop_check_EN   = 0;
                S_EN            = 1; 
                deser_en        = 0;
                Data_valid      = 0; 
            end
        end

        Receive: begin
            if (bit_count == 4'b1000 && Last_edge) begin
                if (Parity_EN) begin
                    next_state      = Parity;
                    Parity_check_EN = 0;
                    start_check_EN  = 0; 
                    stop_check_EN   = 0;  
                    S_EN            = 1; 
                    deser_en        = 0;
                    Data_valid      = 0;
                end
                else begin
                    next_state      = Stop;
                    Parity_check_EN = 0;
                    start_check_EN  = 0; 
                    stop_check_EN   = 0;   
                    S_EN            = 1; 
                    deser_en        = 0;
                    Data_valid      = 0;
                end
            end
            else begin
                next_state      = Receive;
                Parity_check_EN = 0;
                start_check_EN  = 0; 
                stop_check_EN   = 0;
                S_EN            = 1; 
                deser_en        = 1;
                Data_valid      = 0;
            end
        end

        Parity: begin
            
            if (Last_edge) begin
                next_state      = Stop;
                Parity_check_EN = 0;
                start_check_EN  = 0; 
                stop_check_EN   = 0;   
                S_EN            = 1; 
                deser_en        = 0;
                Data_valid      = 0;
            end
            else begin
                next_state      = Parity;
                if (sampled) begin
                    Parity_check_EN  = 1; 
                end
                else begin
                    Parity_check_EN  = 0; 
                end
                start_check_EN  = 0; 
                stop_check_EN   = 0;  
                S_EN            = 1; 
                deser_en        = 0;
                Data_valid      = 0;
            end
        end

        Stop: begin
            if (sampled) begin
                next_state      = error_check;
                Parity_check_EN = 0;
                start_check_EN  = 0; 
                stop_check_EN   = 1;   
                S_EN            = 1; 
                deser_en        = 0;
                Data_valid      = 0;
            end
            else begin
                next_state      = Stop;
                Parity_check_EN = 0;
                start_check_EN  = 0; 
                stop_check_EN   = 0;
                S_EN            = 1; 
                deser_en        = 0;
                Data_valid      = 0;
            end
        end

        error_check: begin
            if (stop_error || Parity_error) begin
                next_state      = Idle;
                Parity_check_EN = 0;
                start_check_EN  = 0; 
                stop_check_EN   = 0;
                S_EN            = 0; 
                deser_en        = 0;
                Data_valid      = 0;
            end
            else begin
                next_state      = Idle;
                Parity_check_EN = 0;
                start_check_EN  = 0; 
                stop_check_EN   = 0;
                S_EN            = 0; 
                deser_en        = 0;
                Data_valid      = 1;
            end
        end

        default: begin
            next_state      = Idle;
            Parity_check_EN = 0;
            start_check_EN  = 0; 
            stop_check_EN   = 0;
            S_EN            = 0; 
            deser_en        = 0;
            Data_valid      = 0;
        end
    endcase
end

endmodule
