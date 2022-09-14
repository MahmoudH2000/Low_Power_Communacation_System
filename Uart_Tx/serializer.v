module serializer #(parameter width = 8)(
    //input & output ports
    input  wire             CLK,
    input  wire             Reset,
    input  wire [width-1:0] Data,
    input  wire             Ser_EN,
    output reg              ser_data,
    output wire             Ser_done
);

reg [width-1:0]         Reg_Data;
reg [$clog2(width):0] counter;

assign Ser_done = (counter == (width)) ? 1:0;

always @(posedge CLK, negedge Reset) begin
    if (!Reset) begin
        ser_data <= 1'b0;
        Reg_Data <= 0;
        counter  <= 0;
    end
    else if (Ser_EN) begin
        if (counter == 0) begin
            ser_data <= 1'b0;
            Reg_Data <= Data;
            counter <= counter + 1;
        end
        else begin
            {Reg_Data, ser_data} <= {1'b0, Reg_Data};
            counter <= counter + 1;
        end
    end
end
    
endmodule