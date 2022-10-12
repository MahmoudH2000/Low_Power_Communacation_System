module ALU #(parameter A_width = 8,
             parameter B_width = 8,
             parameter OUT_width = A_width+B_width)
(
    input  wire                   CLK,
    input  wire                   Reset,
    input  wire                   ALU_EN,
    input  wire   [A_width-1:0]   A, 
    input  wire   [B_width-1:0]   B,
    input  wire   [3:0]           ALU_FUN,
    output reg    [OUT_width-1:0] ALU_out,
    output reg                    Out_valid
);

reg [OUT_width-1:0] ALU_out_comb;
reg                 Out_valid_comb;

always @(*) begin

    if (ALU_EN) begin
        Out_valid_comb = 1'b1;
        case (ALU_FUN)

            4'b0000: begin
                ALU_out_comb = A + B;
            end

            4'b0001: begin
                ALU_out_comb = A - B;
            end

            4'b0010: begin
                ALU_out_comb = A * B;
            end

            4'b0011: begin
                ALU_out_comb = A / B;
            end

            4'b0100: begin
                ALU_out_comb = A & B;
            end

            4'b0101: begin
                ALU_out_comb = A | B;
            end

            4'b0110: begin
                ALU_out_comb = ~(A & B);
            end

            4'b0111: begin
                ALU_out_comb = ~(A | B);
            end

            4'b1000: begin
                ALU_out_comb = A ^ B;
  
            end

            4'b1001: begin
                ALU_out_comb = (A ~^ B);
            end

            4'b1010: begin
                if (A==B) begin
                  ALU_out_comb = 16'b1;
                end
                else begin
                   ALU_out_comb = 16'b0;
                end
     
            end

            4'b1011: begin
                if (A>B) begin
                    ALU_out_comb = 16'b10;
                end
                else begin
                    ALU_out_comb = 16'b0;
                end
     
            end

            4'b1100: begin
                if (A<B) begin
                    ALU_out_comb = 16'b11;
                end
                else begin
                    ALU_out_comb = 16'b0;
                end
     
            end

            4'b1101: begin
                ALU_out_comb = A >> 1'b1;
            end

            4'b1110: begin
                ALU_out_comb = A << 1'b1;
            end

            default: begin
                ALU_out_comb = 16'b0;
            end
        endcase
    end

    else begin
        ALU_out_comb = 'b0;
        Out_valid_comb = 1'b0;
    end
        
end

always @(posedge CLK,  negedge Reset) begin
    if (!Reset) begin
        Out_valid <= 1'b0;
    end
    else begin
        Out_valid <= Out_valid_comb; 
    end
    
end

always @(posedge CLK,  negedge Reset) begin
    if (!Reset) begin
        ALU_out   <=  'b0;
    end
    else if (ALU_EN) begin
        ALU_out   <= ALU_out_comb; 
    end
end

endmodule