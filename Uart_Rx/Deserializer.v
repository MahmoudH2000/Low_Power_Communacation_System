module Deserializer (
    // input & output ports
    input  wire       CLK,      
    input  wire       Reset,      
    input  wire       sampled_data,
    input  wire       deser_en,
    input  wire       sampled,
    output reg  [7:0] P_Data
);

integer i;

always @(posedge CLK, negedge Reset) begin
    if (!Reset) begin
        P_Data <= 0;
    end
    else if(deser_en) begin
        if (sampled) begin
            P_Data[7] <= sampled_data;

            for (i = 6; i >= 0; i=i-1) begin // shifting loop
                P_Data[i] <= P_Data[i+1];
            end
        end
        
    end
end
    
endmodule