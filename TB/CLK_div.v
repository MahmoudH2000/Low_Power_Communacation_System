module CLK_div (
    //input & ouput ports
    input   wire        CLK_Ref,
    input   wire        Reset,
    input   wire        CLK_EN,
    input   wire [4:0]  div,
    output  reg         CLK_div_out
);

reg         CLK_div;
reg         flag;
reg  [3:0]  counter;
wire [3:0]  div_ratio;
wire        Is_Odd;
wire        shift_even;
wire        shift_odd;
reg         EN;

assign div_ratio  = div >> 1'b1;
assign Is_Odd     = div[0];
assign shift_even = counter == (div_ratio-1'b1);
assign shift_odd  = counter == div_ratio;


always @(posedge CLK_Ref, negedge Reset) begin
    
    EN <= CLK_EN && div != 5'b1 && div != 5'b0;
    
    if (!Reset) begin
        counter <= 4'b0;
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