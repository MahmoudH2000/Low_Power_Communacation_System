module SYS_CNTR_Tx #(
    parameter width = 8
) (
    //---------------------------------------------
    /*            CLK & Reset                    */
    //---------------------------------------------
    input  wire                        CLK,       
    input  wire                        Reset,
    //---------------------------------------------
    /*            Reg_File outputs               */
    //---------------------------------------------
    input  wire  [width-1:0]           RdData,
    input  wire                        Rd_valid,
    //---------------------------------------------
    /*            ALU outputs                    */
    //---------------------------------------------
    input  wire  [(2*width)-1:0]       ALU_out,
    input  wire                        ALU_out_valid,
    input  wire  [3:0]                 ALU_FUN,
    //---------------------------------------------
    /*          transmitter outputs               */
    //---------------------------------------------
    input  wire                        Busy,
    input  wire                        can_send, // to tell the controller you can send
    //---------------------------------------------
    /*          transmitter inputs               */
    //---------------------------------------------
    output reg   [width-1:0]           Tx_Data,
    output reg                         Tx_Data_valid
);

//---------------------------------------------
/*               States                      */
//--------------------------------------------- 

localparam Idle      = 2'b00;
localparam wait_s    = 2'b01; // wait state for the busy signal to rise
localparam AlU_trans = 2'b11;   

reg [1:0] curr_state;
reg [1:0] next_state;

//---------------------------------------------
/*          internal signals                 */
//---------------------------------------------

wire                 is_Arith;   // high if we are making an arithmatic op
reg                  Tx_valid_comp;
reg [width-1:0]      Tx_Data_comp;
reg                  ALU_send;   // high if we are sending ALU output
reg                  Reg_send;   // high if we are sending Reg_File output

//---------------------------------------------
/*      Data Registring and calculations     */
//---------------------------------------------

always @(posedge CLK, negedge Reset) begin
    if (!Reset) begin
        ALU_send  <= 0;
        Reg_send  <= 0;
    end
    else if (ALU_out_valid && !Busy) begin
        ALU_send  <= 1;
        Reg_send  <= 0;
    end
    else if (Rd_valid && !Busy) begin
        ALU_send  <= 0;
        Reg_send  <= 1;
    end
end

assign is_Arith = !ALU_FUN[3] && !ALU_FUN[2];

//---------------------------------------------
/*          Registring the outputs           */
//---------------------------------------------
always @(posedge CLK, negedge Reset) begin

    //--------------------------------------------------------//
    /* this a toggel flip flop for the Ffast to slow crossing */
    //--------------------------------------------------------//
    if (!Reset) begin
        Tx_Data_valid <= 0;
    end
    else if (Tx_valid_comp)  begin
        Tx_Data_valid <= !Tx_Data_valid;  
    end
    
end

always @(posedge CLK, negedge Reset) begin
    if (!Reset) begin
        Tx_Data <= 0;
    end
    else  begin
        Tx_Data <= Tx_Data_comp;
    end
end

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
/*          next States always               */
//--------------------------------------------- 

always @(*) begin
    
    case (curr_state)
        Idle: begin
            if (Rd_valid && !Busy) begin

                next_state    = Idle;
                Tx_valid_comp = 1;
                Tx_Data_comp  = RdData;

            end
            else if (ALU_out_valid && !Busy) begin

                if (is_Arith) begin
                    next_state = wait_s;
                end
                else begin
                    next_state = Idle;
                end
                Tx_valid_comp = 1;
                Tx_Data_comp  = ALU_out[width-1:0];

            end
            else begin

                next_state    = Idle;
                Tx_valid_comp = 0;
                case ({ALU_send,Reg_send})
                    2'b01:  Tx_Data_comp  = RdData;
                    2'b10: begin
                        if (is_Arith) begin
                            Tx_Data_comp = ALU_out[(2*width)-1:width];
                        end
                        else begin
                            Tx_Data_comp = ALU_out[width-1:0];
                        end
                    end  
                    default: Tx_Data_comp = 0;
                endcase
                
            end
        end 

        wait_s: begin
            next_state    = AlU_trans;
            Tx_valid_comp = 0;
            Tx_Data_comp  = ALU_out[width-1:0];
        end

        AlU_trans: begin
            if (can_send) begin
                next_state    = Idle;
                Tx_valid_comp = 1;
                Tx_Data_comp  = ALU_out[(2*width)-1:width];
            end
            else begin
                next_state    = AlU_trans;
                Tx_valid_comp = 0;
                Tx_Data_comp  = ALU_out[width-1:0];
            end
        end

        default: begin
            next_state    = Idle;
            Tx_valid_comp = 0;
            case ({ALU_send,Reg_send})
                2'b01:  Tx_Data_comp  = RdData;
                2'b10: begin
                    if (is_Arith) begin
                        Tx_Data_comp = ALU_out[(2*width)-1:width];
                    end
                    else begin
                        Tx_Data_comp = ALU_out[width-1:0];
                    end
                end  
                default: Tx_Data_comp = 0;
            endcase
        end
        
    endcase
end

endmodule