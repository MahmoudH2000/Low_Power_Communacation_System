module Synchronizer #(parameter NUM_Stages = 2, parameter Width = 1) (
    // input & output ports
    input  wire [Width-1:0] Async_data, 
    input  wire             CLK, 
    input  wire             Reset,
    output reg  [Width-1:0] sync_data
);

reg  [Width-1:0] flops_out [NUM_Stages-2:0];

integer i;

always @(posedge CLK, negedge Reset) begin
    if (!Reset) begin

        for (i = 0; i<(NUM_Stages-1); i=i+1) begin
        flops_out[i] <= 0;
        end
        sync_data <= 0;

    end
    else begin

        flops_out[0] <= Async_data;
        for (i = 1; i<(NUM_Stages-1); i=i+1) begin
            flops_out[i] <= flops_out[i-1];
        end
        sync_data <= flops_out [NUM_Stages-2];

    end
    
end
    
endmodule