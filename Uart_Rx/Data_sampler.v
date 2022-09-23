module Data_sampler (
    // input & output ports
    input  wire        CLK,
    input  wire        Reset,
    input  wire  [4:0] Prescale,
    input  wire        S_Data,      // serial data 
    input  wire  [4:0] edge_count,  // number of edges in the received bit
    input  wire        S_EN,        // sampling enable 
    output reg         sampled,     // high for one clock cycle when a bit is sambled
    output reg         Sampled_bit  // output sampled bit
);

//internal signals
wire [4:0] Prescale_shifted;  
wire [4:0] Prescale_shifted_plus1;
wire [4:0] Prescale_shifted_plus2;
wire [4:0] Prescale_shifted_minus1;
wire equal_shifted;
wire equal_shifted_plus1;
wire equal_shifted_plus2;
wire sampled_comp;
reg sample_1;
reg sample_2;
reg sample_3;

// combinational logic
assign Prescale_shifted        = Prescale >> 1'b1;     // Prescale / 2 and it's time for the second sample
assign Prescale_shifted_minus1 = Prescale_shifted - 1; // time of the first sample
assign Prescale_shifted_plus1  = Prescale_shifted + 1; // time of the third sample
assign Prescale_shifted_plus2  = Prescale_shifted_plus1 + 1; // time to output the sampled bit

// conditional statements
assign equal_shifted           = Prescale_shifted        == edge_count;
assign equal_shifted_plus1     = Prescale_shifted_plus1  == edge_count;
assign sampled_comp            = Prescale_shifted_plus2  == edge_count;
assign equal_shifted_minus1    = Prescale_shifted_minus1 == edge_count;

// sequential block
always @(posedge CLK, negedge Reset) begin
    if (!Reset) begin
        sample_1    <= 0;
        sample_2    <= 0;
        sample_3    <= 0;
        sampled     <= 0;
        Sampled_bit <= 0;
    end
    
    else if (S_EN) begin
        sampled <= sampled_comp;

        if (equal_shifted_minus1) begin
            sample_1 <= S_Data;
        end
        else if (equal_shifted) begin
            sample_2 <= S_Data;
        end
        else if (equal_shifted_plus1) begin
            sample_3 <= S_Data;
        end
        if (sampled_comp) begin
            // take the majority bit if 
            // if we sampled 2 ones or more then the Sampled_bit = 1
            // else the Sampled_bit = 0
            Sampled_bit <= (sample_1 & sample_2) | (sample_1 & sample_3) | (sample_3 & sample_2); 
        end
    end

    else begin
        sample_1    <= 0;
        sample_2    <= 0;
        sample_3    <= 0;
        sampled     <= 0;
        Sampled_bit <= 0;
    end
end

endmodule