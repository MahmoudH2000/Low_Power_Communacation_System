module SYNC_FIFO #(parameter width = 8,
                   parameter FDPTH = 4) (
    // input & output ports
    input  wire                 CLK,
    input  wire                 Reset,
    input  wire                 ALU_valid,
    input  wire                 RD_valid,
    input  wire                 RD_EN,
    input  wire [3:0]           ALU_FUN,
    input  wire [(width*2)-1:0] ALU_out,
    input  wire [width-1:0]     RD_out,
    output wire                 Embty,
    output reg  [width-1:0]     Data,
    output reg                  valid
);

//--------------------------//
//      internal signals    //
//--------------------------//
reg  [width-1:0]         FIFO    [FDPTH-1:0];
reg  [$clog2(FDPTH):0]   Wr_ptr;
reg  [$clog2(FDPTH):0]   Rd_ptr;
wire                     Full_1;
wire                     Full_2;
wire                     is_Arith;
wire [$clog2(FDPTH)-1:0] Wrptrplus1;
wire                     FULL;

integer i;

assign Embty      = Rd_ptr == Wr_ptr;
assign Full_1     = ~Wr_ptr[$clog2(FDPTH)] == Rd_ptr[$clog2(FDPTH)];
assign Full_2     = Wr_ptr[$clog2(FDPTH)-1:0] == Rd_ptr[$clog2(FDPTH)-1:0];
assign FULL       = Full_1 && Full_2;
assign is_Arith   = !ALU_FUN[3] && !ALU_FUN[2];
assign Wrptrplus1 = Wr_ptr[$clog2(FDPTH)-1:0] + 1;

always @(posedge CLK, negedge Reset) begin
    if (!Reset) begin
        for (i = 0; i<FDPTH; i=i+1) begin
            FIFO[i] <= 'b0;    
        end
    Wr_ptr <= 0;
    end

    else if (ALU_valid && !RD_valid && !RD_EN && !FULL) begin
        if (is_Arith) begin
            FIFO[Wr_ptr[$clog2(FDPTH)-1:0]] <= ALU_out[width-1:0];
            FIFO[Wrptrplus1]                <= ALU_out[(2*width)-1:width];
            Wr_ptr                          <= Wr_ptr + 2;
        end
        else begin
            FIFO[Wr_ptr[$clog2(FDPTH)-1:0]] <= ALU_out[width-1:0];
            Wr_ptr                          <= Wr_ptr + 1;
        end
    end

    else if (!ALU_valid && RD_valid && !RD_EN && !FULL) begin
        FIFO[Wr_ptr[$clog2(FDPTH)-1:0]] <= RD_out;
        Wr_ptr                          <= Wr_ptr + 1;
    end
end

always @(posedge CLK, negedge Reset) begin
    if (!Reset) begin
        Data   <= 0;
        valid  <= 0;
        Rd_ptr <= 0;
    end
    
    else if (!ALU_valid && !RD_valid && RD_EN && !Embty) begin
        Data   <= FIFO[Rd_ptr[$clog2(FDPTH)-1:0]];
        valid  <= ~valid;
        Rd_ptr <= Rd_ptr + 1;
    end
end

endmodule