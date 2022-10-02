`timescale 1ps/1fs
module Synchronizer_tb ();

localparam NUM_Stages_tb = 6;
localparam Width_tb = 9;

reg  [Width_tb-1:0] Async_data_tb; 
reg                 CLK_tb; 
reg                 Reset_tb;
wire [Width_tb-1:0] sync_data_tb;

Synchronizer #(.NUM_Stages(NUM_Stages_tb), .Width(Width_tb)) DUT(
    // input & output ports
    .Async_data(Async_data_tb), 
    .CLK(CLK_tb), 
    .Reset(Reset_tb),
    .sync_data(sync_data_tb)
);

initial begin
    CLK_tb = 1;
    
    Async_data_tb = {Width_tb{1'b1}}; 
    
    #5
    
    rst();

    repeat(NUM_Stages_tb) @(posedge CLK_tb);

    #1

    if (sync_data_tb == Async_data_tb) begin
        $display("test passed");
    end
    else begin
        $display("test failed");
    end

    #100
    $finish;

end

task rst();
begin
    Reset_tb = 1;
    #1
    Reset_tb = 0;
    #1
    Reset_tb = 1;
end
endtask

always #5 CLK_tb = ~CLK_tb;

endmodule