module serializer #(parameter width = 8)(
    //input & output ports
    input  wire             CLK,
    input  wire             Reset,
    input  wire [width-1:0] Data,
    input  wire             Data_valid,
    input  wire             Ser_EN,
    input  wire             Busy,
    output reg              Ser_data_out,
    output wire             Ser_done
);

reg [width-1:0]         Reg_Data;
reg [$clog2(width):0]   counter;
reg                     Ser_data;

assign Ser_done = (counter == (width)) ? 1:0;

always @(posedge CLK, negedge Reset) begin
    if (!Reset) begin
        Ser_data <= 1'b0;
        Reg_Data <= 0;
        counter  <= 0;
    end
    else if (Data_valid && !Busy) begin
        Reg_Data <= Data>>1'b1;
        Ser_data <= Data[0];
        counter  <= 0;
    end
    else if(Ser_EN) begin
        {Reg_Data, Ser_data} <= {1'b0, Reg_Data};
        counter <= counter + 1;
    end
    
end

always @(posedge CLK, negedge Reset) begin
    if (!Reset) begin
        Ser_data_out <= 1'b0;
    end
    else begin
        Ser_data_out <= Ser_data;
    end
end
    
endmodule