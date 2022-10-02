`timescale 1ps/1fs
module RST_SYNC_tb ();

localparam NUM_Stages_tb = 2;

reg                 CLK_tb; 
reg                 Async_Reset_tb;
wire                sync_Reset_tb;

RST_SYNC #(.NUM_Stages(NUM_Stages_tb)) DUT(
    // input & output ports
    .CLK(CLK_tb), 
    .Async_Reset(Async_Reset_tb),
    .sync_Reset(sync_Reset_tb)
);

initial begin
    CLK_tb = 1;
    
    
    #5
    
    rst();

    repeat(NUM_Stages_tb) @(posedge CLK_tb);

    #1

    if (sync_Reset_tb == 1) begin
        $display("test passed");
    end
    else begin
        $display("test failed");
    end

    #100
    $stop;

end

task rst();
begin
    Async_Reset_tb = 1;
    #1
    Async_Reset_tb = 0;
    #1
    Async_Reset_tb = 1;
end
endtask

always #5 CLK_tb = ~CLK_tb;

endmodule