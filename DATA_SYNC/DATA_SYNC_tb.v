`timescale 1ps/1fs
module DATA_SYNC_tb ();

localparam NUM_Stages_tb = 2;
localparam Width_tb = 8;

reg   [Width_tb-1:0]  Async_bus_tb; 
reg                   bus_EN_tb; 
reg                   CLK_tb; 
reg                   Reset_tb;
wire  [Width_tb-1:0]  sync_bus_tb;
wire                  EN_pulse_tb;


DATA_SYNC #(.NUM_Stages(NUM_Stages_tb), .Width(Width_tb)) DUT(
    // input & output ports
    .Async_bus(Async_bus_tb), 
    .bus_EN(bus_EN_tb), 
    .CLK(CLK_tb), 
    .Reset(Reset_tb),
    .sync_bus(sync_bus_tb),
    .EN_pulse(EN_pulse_tb)
);


initial begin
    CLK_tb = 1;
    
    Async_bus_tb = {Width_tb{1'b1}}; 
    bus_EN_tb = 1;
    
    #5
    
    rst();

    repeat(NUM_Stages_tb+1) @(posedge CLK_tb);

    #1

    if (Async_bus_tb == sync_bus_tb && EN_pulse_tb == 1) begin
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
    Reset_tb = 1;
    #1
    Reset_tb = 0;
    #1
    Reset_tb = 1;
end
endtask

always #5 CLK_tb = ~CLK_tb;

endmodule