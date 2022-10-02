module RST_sync #(parameter NUM_Stages = 2) (
    // input & output ports
    input  wire             CLK, 
    input  wire             Async_Reset,
    output reg              sync_Reset
);

reg  [NUM_Stages-2:0] flops_out;

integer i;

always @(posedge CLK, negedge Async_Reset) begin
    if (!Async_Reset) begin

        for (i = 0; i<(NUM_Stages-1); i=i+1) begin
        flops_out[i] <= 0;
        end
        sync_Reset <= 0;

    end
    else begin

        flops_out[0] <= 1'b1;
        for (i = 1; i<(NUM_Stages-1); i=i+1) begin
            flops_out[i] <= flops_out[i-1];
        end
        sync_Reset <= flops_out [NUM_Stages-2];

    end
    
end
    
endmodule