module Data_sampler (
    // input & output ports
    input  wire        CLK,
    input  wire        Reset,
    input  wire        S_Data,
    input  wire  [4:0] edge_count,
    input  wire        S_EN,        // sampling enable 
    input  wire  [4:0] Prescale,
    output reg         sampled,
    output reg         Sampled_bit
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
assign Prescale_shifted        = Prescale >> 1'b1;
assign Prescale_shifted_plus1  = Prescale_shifted + 1;
assign Prescale_shifted_plus2  = Prescale_shifted_plus1 + 1;
assign Prescale_shifted_minus1 = Prescale_shifted - 1;
assign equal_shifted           = Prescale_shifted        == edge_count;
assign equal_shifted_plus1     = Prescale_shifted_plus1  == edge_count;
assign sampled_comp            = Prescale_shifted_plus2  == edge_count;
assign equal_shifted_minus1    = Prescale_shifted_minus1 == edge_count;

always @(posedge CLK, negedge Reset) begin
    if (!Reset) begin
        sample_1    <= 0;
        sample_2    <= 0;
        sample_3    <= 0;
        Sampled_bit <= 0;
        sampled     <= 0;
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
            Sampled_bit <= (sample_1 & sample_2) | (sample_1 & sample_3) | (sample_3 & sample_2);
        end
    end

    else begin
        sample_1    <= 0;
        sample_2    <= 0;
        sample_3    <= 0;
        Sampled_bit <= 0;
        sampled     <= 0;
    end
end

endmodule