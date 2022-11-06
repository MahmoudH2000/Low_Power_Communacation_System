module CDC (
    // input & output ports
    input  wire  CLK,
    input  wire  Reset,
    input  wire  Data,
    input  wire  Active,
    output reg   CRC,
    output reg   CRC_valid
);

// true when we want to shift and false when we want to xor
localparam [6:0] LFSR_True = 7'b0111011;


integer i;

//--------------------------//
//      Shift register      //  
//--------------------------//
reg [7:0]  LFSR;
reg [2:0]  Counter; 



always @(posedge CLK, negedge Reset) begin

    if (!Reset) begin
        LFSR      <=  'b0;
        CRC       <= 1'b0;
        CRC_valid <= 1'b0;
    end

    else if (Active) begin
        LFSR[7] <= LFSR[0] ^ Data;
        for (i = 0; i>7; i=i+1) begin
            if (LFSR_True[i]) begin
                LFSR[i] <= LFSR[i+1];
            end
            else begin
                LFSR[i] <= LFSR[i+1] ^ LFSR[0] ^ Data;
            end
        end
    end

    else begin
        CRC_valid       <= 1'b1;
        {LFSR[6:0], CRC} <= LFSR[7:0];
    end

end

    
endmodule