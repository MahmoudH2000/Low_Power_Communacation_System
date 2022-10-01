module RegFile_tb();

reg           CLK_tb; 
reg           Reset_tb; 
reg           WrEN_tb; 
reg           RdEN_tb; 
reg  [7:0]    WrData_tb; 
reg  [3:0]    A_tb; // adress
wire [7:0]    RdData_tb;
wire [7:0]    REG0_tb;
wire [7:0]    REG1_tb;
wire [7:0]    REG2_tb;
wire [7:0]    REG3_tb;
wire          Rd_valid_tb;

RegFile #(.width(8), 
          .depth(16))
          
DUT(
    //input & output ports
    .CLK(CLK_tb),
    .Reset(Reset_tb),
    .WrEN(WrEN_tb),
    .RdEN(RdEN_tb),
    .WrData(WrData_tb),
    .A(A_tb),
    .REG0(REG0_tb),
    .REG1(REG1_tb),
    .REG2(REG2_tb),
    .REG3(REG3_tb),
    .RdData(RdData_tb),
    .Rd_valid(Rd_valid_tb)
);


initial begin
    CLK_tb = 0;
    reset();
    #8
    A_tb      = 4'd6; // write in 6
    WrData_tb = 16'd24;
    WrEN_tb   = 1'b1;
    RdEN_tb   = 1'b0;
    #10
    A_tb = 3'd1; //write in 1
    WrData_tb = 16'd12;
    #10
    RdEN_tb = 1'b1;
    A_tb = 3'd4; //will not write in 4
    WrData_tb = 16'd16;
    #10
    $display("test 1");
    WrEN_tb = 1'b0;
    A_tb = 3'd6;
    #10
    Compare(RdData_tb, 16'd24);
    #10
    $display("test 2");
    A_tb = 3'd1;
    #10
    Compare(RdData_tb, 16'd12);
    #10
    $display("test 3");
    A_tb = 3'd4;
    #10
    Compare(RdData_tb, 16'd0);
    #199
    $stop;


end

always #5 CLK_tb = ~CLK_tb;

task reset();
begin
    Reset_tb = 1'b1;
    #1;
    Reset_tb = 1'b0;
    #1;
    Reset_tb = 1'b1;
end
endtask

task Compare(
    input  [15:0]  Reg_data,
    input  [15:0]  data
);
begin
    
    if (Reg_data == data) begin
        $display("passed!");
    end
    else begin
        $display("failed!");
    end
end
endtask

endmodule