module CLK_div_tb ();
    

reg           CLK_Ref_tb;
reg           Reset_tb;
reg           CLK_EN_tb;
reg   [4:0]   div_tb;
wire          CLK_div_out_tb;

always #5 CLK_Ref_tb = ~CLK_Ref_tb;

CLK_div DUT(
    .CLK_Ref(CLK_Ref_tb),
    .Reset(Reset_tb),
    .CLK_EN(CLK_EN_tb),
    .div(div_tb),
    .CLK_div_out(CLK_div_out_tb)
);

initial begin

    initialize();
    rst();
    div_tb = 0;
    #1000
    rst();
    div_tb = 1;
    #1000
    rst();
    div_tb = 2;
    #1000
    rst();
    div_tb = 3;
    #1000
    rst();
    div_tb = 4;
    #1000
    rst();
    div_tb = 7;
    #1000
    rst();
    div_tb = 10;
    #1000
    CLK_EN_tb = 0;
    #1000
    CLK_EN_tb = 1;
    rst();
    div_tb = 5;
    #5000
    $stop;
end


task initialize();
begin
    CLK_Ref_tb = 1;
    CLK_EN_tb  = 1;
end
endtask

task rst();
begin
    Reset_tb = 1;
    #1
    Reset_tb = 0;
    #1
    Reset_tb = 1;
end
endtask


endmodule