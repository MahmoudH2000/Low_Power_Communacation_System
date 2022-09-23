module Rx_control (
    // input & output ports
    input  wire        CLK,
    input  wire        Reset,
    input  wire        S_Data,
    input  wire  [3:0] bit_count,
    input  wire        sampled,
    input  wire        Parity_EN,
    input  wire        Parity_error,
    input  wire        start_error,
    input  wire        stop_error,
    output reg         Parity_check_EN,
    output reg         start_check_EN,
    output reg         stop_check_EN,
    output reg         count_EN,
    output reg         S_EN,
    output reg         deser_en,
    output reg         Data_valid
);

localparam Idle         = 3'b000;
localparam Start        = 3'b001;
localparam Start_check  = 3'b011;
localparam Send         = 3'b010;
localparam Parity       = 3'b110;
localparam Parity_check = 3'b100;
localparam Stop         = 3'b101;
localparam Stop_check   = 3'b111;

reg [2:0] next_state;
reg [2:0] curr_state;

always @(posedge CLK, negedge Reset) begin
    if (!Reset) begin
        curr_state <= Idle;
    end
    else begin
        curr_state <= next_state;
    end
end

always @(*) begin
    
    case (curr_state)

        Idle: begin
            if (!S_Data) begin
                next_state      = Start;
                Parity_check_EN = 0;
                start_check_EN  = 0; 
                stop_check_EN   = 0;
                count_EN        = 1;
                S_EN            = 1; 
                deser_en        = 0;
                Data_valid      = 0;
            end
            else begin
                next_state      = Idle;
                Parity_check_EN = 0;
                start_check_EN  = 0; 
                stop_check_EN   = 0;
                count_EN        = 0;
                S_EN            = 0; 
                deser_en        = 0;
                Data_valid      = 0;
            end
        end

        Start: begin
            if (sampled) begin
                next_state      = Start_check;
                Parity_check_EN = 0;
                start_check_EN  = 1; 
                stop_check_EN   = 0;
                count_EN        = 1;
                S_EN            = 1; 
                deser_en        = 0;
                Data_valid      = 0;
            end
            else begin
                next_state      = Start;
                Parity_check_EN = 0;
                start_check_EN  = 0; 
                stop_check_EN   = 0;
                count_EN        = 1;
                S_EN            = 1; 
                deser_en        = 0;
                Data_valid      = 0;
            end
        end

        Start_check: begin
            if (start_error) begin
                next_state      = Idle;
                Parity_check_EN = 0;
                start_check_EN  = 0; 
                stop_check_EN   = 0;
                count_EN        = 0;
                S_EN            = 0; 
                deser_en        = 0;
                Data_valid      = 0;
            end
            else if (bit_count == 1) begin
                next_state      = Send;
                Parity_check_EN = 0;
                start_check_EN  = 0; 
                stop_check_EN   = 0;
                count_EN        = 1;
                S_EN            = 1; 
                deser_en        = 1;
                Data_valid      = 0;
            end
            else begin
                next_state      = Start_check;
                Parity_check_EN = 0;
                start_check_EN  = 1; 
                stop_check_EN   = 0;
                count_EN        = 1;
                S_EN            = 1; 
                deser_en        = 0;
                Data_valid      = 0;
            end
        end

        Send: begin
            if (bit_count == 4'b1001) begin
                if (Parity_EN) begin
                    next_state      = Parity;
                    Parity_check_EN = 0;
                    start_check_EN  = 0; 
                    stop_check_EN   = 0;
                    count_EN        = 1;
                    S_EN            = 1; 
                    deser_en        = 0;
                    Data_valid      = 0;
                end
                else begin
                    next_state      = Stop;
                    Parity_check_EN = 0;
                    start_check_EN  = 0; 
                    stop_check_EN   = 0;
                    count_EN        = 1;
                    S_EN            = 1; 
                    deser_en        = 0;
                    Data_valid      = 0;
                end
            end
            else begin
                next_state      = Send;
                Parity_check_EN = 0;
                start_check_EN  = 0; 
                stop_check_EN   = 0;
                count_EN        = 1;
                S_EN            = 1; 
                deser_en        = 1;
                Data_valid      = 0;
            end
        end

        Parity: begin
            if (sampled) begin
                next_state      = Parity_check;
                Parity_check_EN = 1;
                start_check_EN  = 0; 
                stop_check_EN   = 0;
                count_EN        = 1;
                S_EN            = 1; 
                deser_en        = 0;
                Data_valid      = 0;
            end
            else begin
                next_state      = Parity;
                Parity_check_EN = 0;
                start_check_EN  = 0; 
                stop_check_EN   = 0;
                count_EN        = 1;
                S_EN            = 1; 
                deser_en        = 0;
                Data_valid      = 0;
            end
        end

        Parity_check: begin
            if (Parity_error) begin
                next_state      = Idle;
                Parity_check_EN = 0;
                start_check_EN  = 0; 
                stop_check_EN   = 0;
                count_EN        = 0;
                S_EN            = 0; 
                deser_en        = 0;
                Data_valid      = 0;
            end
            else if (bit_count == 4'b1010) begin
                next_state      = Stop;
                Parity_check_EN = 0;
                start_check_EN  = 0; 
                stop_check_EN   = 0;
                count_EN        = 1;
                S_EN            = 1; 
                deser_en        = 0;
                Data_valid      = 0;
            end
            else begin
                next_state      = Parity_check;
                Parity_check_EN = 1;
                start_check_EN  = 0; 
                stop_check_EN   = 0;
                count_EN        = 1;
                S_EN            = 1; 
                deser_en        = 0;
                Data_valid      = 0;
            end
        end

        Stop: begin
            if (sampled) begin
                next_state      = Stop_check;
                Parity_check_EN = 0;
                start_check_EN  = 0; 
                stop_check_EN   = 1;
                count_EN        = 1;
                S_EN            = 1; 
                deser_en        = 0;
                Data_valid      = 0;
            end
            else begin
                next_state      = Stop;
                Parity_check_EN = 0;
                start_check_EN  = 0; 
                stop_check_EN   = 0;
                count_EN        = 1;
                S_EN            = 1; 
                deser_en        = 0;
                Data_valid      = 0;
            end
        end

        Stop_check: begin
            if (stop_error) begin
                next_state      = Idle;
                Parity_check_EN = 0;
                start_check_EN  = 0; 
                stop_check_EN   = 0;
                count_EN        = 0;
                S_EN            = 0; 
                deser_en        = 0;
                Data_valid      = 0;
            end
            else if (!S_Data) begin
                next_state      = Start;
                Parity_check_EN = 0;
                start_check_EN  = 0; 
                stop_check_EN   = 0;
                count_EN        = 1;
                S_EN            = 1; 
                deser_en        = 0;
                Data_valid      = 1;
            end
            else begin
                next_state      = Idle;
                Parity_check_EN = 0;
                start_check_EN  = 0; 
                stop_check_EN   = 0;
                count_EN        = 0;
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
            count_EN        = 0;
            S_EN            = 0; 
            deser_en        = 0;
            Data_valid      = 0;
        end
    endcase
end

endmodule
