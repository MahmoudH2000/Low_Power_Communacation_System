module serializer #(parameter width = 8)(
    //input & output ports
    input  wire             CLK,
    input  wire             Reset,
    input  wire             valid_instop,
    input  wire [width-1:0] Data,
    input  wire             Data_valid,  // High for one CLK cycle it tells me that the data is ready
    input  wire             Ser_EN,      // sent by the FSM to tell the serializer to start working
    input  wire             Busy,        // to tell the serializer that the uart is sending so don't accept new data
    output reg              Ser_data,    // serialized output
    output wire             Ser_done     // when the serializer is done
);

/*
this block is used to serializ the input data 
input:  d[n-1:0]
output: d[0] d[1] d[2] .... d[n-1]
*/


/*      internal signals    */
reg [width-1:0]         Reg_Data;
reg [$clog2(width):0]   counter;


/* if counter equal the number of bits of the input then the serializer is done */
assign Ser_done = (counter == (width)) ? 1:0; 

/*   sequential always to serialize the data   */
always @(posedge CLK, negedge Reset) begin
    if (!Reset) begin
        Ser_data <= 1'b0;
        Reg_Data <= 0;
        counter  <= 0;
    end
    else if (valid_instop || (Data_valid && !Busy)) begin
        Reg_Data <= Data;       // register the data
        counter  <= 0;          // begin to count
    end
    else if(Ser_EN) begin
        {Reg_Data, Ser_data} <= {1'b0, Reg_Data};
        counter <= counter + 1;
    end
    
end
    
endmodule