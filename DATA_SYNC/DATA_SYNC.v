//------------------------------------------------------//
/*   This module is an enable based data synchronizer   */
/* It's configurable to work with slow to fast crossing */
/*  Or fast to slow crossing using the parameter S_TO_F */
//------------------------------------------------------//
module DATA_SYNC #(parameter NUM_Stages = 2, 
                   parameter Width = 8, 
                   parameter S_TO_F = 1) (
    // input & output ports
    input  wire [Width-1:0] Async_bus, 
    input  wire             bus_EN, 
    input  wire             CLK, 
    input  wire             Reset,
    output reg  [Width-1:0] sync_bus,
    output reg              EN_pulse
);

reg  [NUM_Stages-1:0] flops_out;
reg                   Pulse_gen_FF;
wire                  Pulse_gen_out;
wire [Width-1:0]      MUX_out;

integer i;

always @(posedge CLK, negedge Reset) begin
    if (!Reset) begin

        for (i = 0; i<NUM_Stages; i=i+1) begin
        flops_out[i] <= 0;
        end
        Pulse_gen_FF <= 0;
        sync_bus <= 0;
        EN_pulse <= 0;
    end
    else begin

        flops_out[0] <= bus_EN;
        for (i = 1; i<NUM_Stages; i=i+1) begin
            flops_out[i] <= flops_out[i-1];
        end
        Pulse_gen_FF <= flops_out[NUM_Stages-1];
        sync_bus <= MUX_out;
        EN_pulse <= Pulse_gen_out;
    end
end

generate
    if (S_TO_F) begin : Slow_TO_Fast
        assign Pulse_gen_out = ~Pulse_gen_FF & flops_out[NUM_Stages-1];
    end
    else begin : Fast_TO_Slow
        assign Pulse_gen_out = Pulse_gen_FF ^ flops_out[NUM_Stages-1];
    end
endgenerate

assign MUX_out = Pulse_gen_out ? Async_bus:sync_bus;
    
endmodule