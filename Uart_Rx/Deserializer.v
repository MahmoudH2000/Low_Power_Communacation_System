module Deserializer #(parameter width = 8)
(
    // input & output ports
    input  wire             CLK,      
    input  wire             Reset,      
    input  wire             sampled_data, // input from the data sampler
    input  wire             deser_en,     // enable segnal
    input  wire             sampled,      //  high for one clock cycle when a bit is sambled
    output reg  [width-1:0] P_Data        // output parallel Data
);

integer i; // loop integer

always @(posedge CLK, negedge Reset) begin
    if (!Reset) begin
        P_Data <= 0;
    end
    else if(deser_en && sampled) begin
        
        P_Data[width-1] <= sampled_data;
        
        for (i = width-2; i >= 0; i=i-1) begin // shifting loop
            P_Data[i] <= P_Data[i+1];
        end
        
    end
end
    
endmodule