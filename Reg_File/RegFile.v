module RegFile #(parameter width = 8, parameter depth = 16)(
    //input & output ports
    input   wire                       CLK,
    input   wire                       Reset,
    input   wire                       WrEN,
    input   wire                       RdEN,
    input   wire [width-1:0]           WrData,
    input   wire [$clog2(depth)-1:0]   A, // adress
    output  wire [width-1:0]           REG0,
    output  wire [width-1:0]           REG1,
    output  wire [width-1:0]           REG2,
    output  wire [width-1:0]           REG3,
    output  reg  [width-1:0]           RdData,
    output  reg                        Rd_valid
);

integer i;

reg [width-1:0] reg_file [depth-1:0];

always @(posedge CLK, negedge Reset) begin
    
    if (!Reset) begin
        
        RdData <= 0;
        Rd_valid <= 0;

        for (i = 0; i<depth; i=i+1) begin
            if (i == 2) begin
                reg_file[i] = 'b0_01000_0_1; // floating _ prescale _ Paritytype _ parityEnable
            end
            else if (i == 3) begin
                reg_file[i] = 'b000_01000;   // floating _ div ratio
            end
            else begin
                reg_file[i] <= 16'b0;    
            end
             
        end

    end

    else if (RdEN && !WrEN) begin
        RdData <= reg_file[A];
        Rd_valid <= 1;
    end

    else if (!RdEN && WrEN) begin
        reg_file[A] <= WrData;
    end
    else begin
        Rd_valid <= 0;
    end
end

assign REG0 = reg_file[0];
assign REG1 = reg_file[1];
assign REG2 = reg_file[2];
assign REG3 = reg_file[3];
    
endmodule