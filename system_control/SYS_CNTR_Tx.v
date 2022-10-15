module SYS_CNTR_Tx (
    //---------------------------------------------
    /*            CLK & Reset                    */
    //---------------------------------------------
    input  wire        CLK,       
    input  wire        Reset,
    //---------------------------------------------
    /*          transmitter outputs               */
    //---------------------------------------------
    input  wire        Busy,
    input  wire        can_send,
    //---------------------------------------------
    /*             FIFO input & outputs          */
    //---------------------------------------------
    input  wire        Empty,
    output reg         FIFO_EN
);

//---------------------------------------------
/*               States                      */
//--------------------------------------------- 
localparam Idle    = 1'b0;
localparam sending = 1'b1;

reg  curr_state;
reg  next_state;

//---------------------------------------------
/*          curr states always               */
//--------------------------------------------- 
always @(posedge CLK, negedge Reset) begin
    if (!Reset) begin
        curr_state <= 0;
    end
    else begin
        curr_state <= next_state;
    end
end

//---------------------------------------------
/*       next States & output always         */
//--------------------------------------------- 
always @(*) begin
    case (curr_state)
        Idle: begin
            if (!Empty &&  (!Busy | can_send)) begin
                next_state = sending;
                FIFO_EN    = 1;
            end
            else begin
                next_state = Idle;
                FIFO_EN    = 0;
            end
        end

        sending: begin
            if (Busy) begin
                next_state = Idle;
                FIFO_EN    = 0;
            end
            else begin
                next_state = sending;
                FIFO_EN    = 0;
            end
        end 
    endcase
end


endmodule