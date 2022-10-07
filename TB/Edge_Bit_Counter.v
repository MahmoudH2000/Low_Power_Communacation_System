module Edge_Bit_Counter #(parameter width = 8)
(
    // input & output ports
    input                               CLK,
    input                               Reset,
    input  wire  [4:0]                  Prescale,   // note that it has to be >= 5
    input  wire                         count_EN,   // enale signal
    output wire                         Last_edge,
    output reg   [$clog2(width+3)-1:0]  bit_count,  // nember of bits received
    output reg   [4:0]                  edge_count // number of edges in the received bit
);

// internal wire

assign Last_edge = (edge_count == Prescale);  

always @(posedge CLK, negedge Reset) begin
    if (!Reset) begin
        bit_count  <= 4'b0;
        edge_count <= 5'b1; // starts at 1
    end
    else if (count_EN) begin
        if (Last_edge) begin
            bit_count  <= bit_count+1;  // increment when finished counting the edges of the received bit
            edge_count <= 5'b1;         // restart the edge count
        end
        else begin
            edge_count <= edge_count + 1; // increment the edge count
        end
    end
    else begin
        bit_count  <= 4'b0;
        edge_count <= 5'b1;
    end
end

endmodule