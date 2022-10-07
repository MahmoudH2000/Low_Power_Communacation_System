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
/*          internal signals               */
//---------------------------------------------

reg [width-1:0]  ALU_out_M; // most significant bits
reg              Tx_valid_comp;
reg [width-1:0]  Tx_Data_comp;

//---------------------------------------------
/*          Registring the Data              */
//---------------------------------------------
always @(posedge CLK, negedge Reset) begin
    if (!Reset) begin
        ALU_out_M <= 0;
    end
    else if (ALU_out_valid && !ALU_FUN[3] && !ALU_FUN[2]) begin
        ALU_out_M <= ALU_out[(2*width)-1:width];
    end
end

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
        Tx_Data       <= 0;
    end
    else  begin
        Tx_Data       <= Tx_Data_comp;
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
                if (!ALU_FUN[3] && !ALU_FUN[2]) begin
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
                Tx_Data_comp  = 0;
            end
        end 

        wait_s: begin
            next_state    = AlU_trans;
            Tx_valid_comp = 0;
            Tx_Data_comp  = ALU_out_M;
        end

        AlU_trans: begin
            if (!Busy) begin
                next_state    = Idle;
                Tx_valid_comp = 1;
                Tx_Data_comp  = ALU_out_M;
            end
            else begin
                next_state    = AlU_trans;
                Tx_valid_comp = 0;
                Tx_Data_comp  = 0;
            end
        end

        default: begin
            next_state = Idle;
        end
        
    endcase
end

endmodule