module CLK_div (
    //input & ouput ports
    input   wire        CLK_Ref,
    input   wire        Reset,
    input   wire        CLK_EN,
    input   wire [3:0]  div,
    output  reg         CLK_div_out
);

reg         CLK_div;
reg         flag;
reg  [2:0]  counter;
wire [2:0]  div_ratio;
wire        Is_Odd;
wire        shift_even;
wire        shift_odd;
wire        EN;

assign div_ratio  = div >> 1'b1;
assign Is_Odd     = div[0];
assign shift_even = counter == (div_ratio-1'b1);
assign shift_odd  = counter == div_ratio;

assign EN = CLK_EN && (div != 4'b1) && (div != 4'b0);

always @(posedge CLK_Ref, negedge Reset) begin
    
    if (!Reset) begin
        counter <= 3'b0;
        flag    <= 1'b0;
        CLK_div <= 1'b0;
    end    

    else if(EN)  begin
        if ((shift_odd && flag) || (shift_even && !flag)) begin
            CLK_div <= ~CLK_div;
            counter <= 1'b0;
            if (Is_Odd && shift_even) begin
                flag <= 1'b1;
            end
            else begin
                flag <= 1'b0;
            end
        end
        else begin
            CLK_div <= CLK_div;
            counter <= counter + 1'b1;
            flag    <= flag;
        end
    end 
end

always @(*) begin
    if (EN) begin
        CLK_div_out = CLK_div;
    end
    else begin
        CLK_div_out = CLK_Ref;
    end
end


endmodule