module Edge_Bit_Counter (
    // input & output ports
    input                CLK,
    input                Reset,
    input  wire  [4:0]   Prescale,
    input  wire          count_EN,   // enale signal
    output reg   [3:0]   bit_count,
    output reg   [4:0]   edge_count
);

// internal wire
reg  edge_count_done;
wire edge_end;

assign edge_end = (edge_count == Prescale);

always @(*) begin
    if (edge_end) begin
        edge_count_done = 1'b1;
    end
    else begin
        edge_count_done = 1'b0;
    end
end

always @(posedge CLK, negedge Reset) begin
    if (!Reset) begin
        bit_count  <= 4'b0;
        edge_count <= 5'b1;
    end
    else if (count_EN) begin
        if (edge_count_done) begin
            bit_count  <= bit_count+1;
            edge_count <= 5'b1;
        end
        else begin
            edge_count <= edge_count + 1;
        end
    end
    else begin
        bit_count  <= 4'b0;
        edge_count <= 5'b1;
    end
end

endmodule