module Rx_Contorl #(
    parameter width = 8,
    parameter depth = 16
) (
    // input & output ports

    //---------------------------------------------
    /*            CLK & Reset                    */
    //---------------------------------------------
    input  wire                       CLK,       
    input  wire                       Reset,
    //---------------------------------------------
    /*          Receiver_output                  */
    //---------------------------------------------
    input  wire  [width-1:0]          Rx_P_Data,
    input  wire                       RxValid,
    //---------------------------------------------
    /*            ALU inputs                     */
    //---------------------------------------------
    output reg                        ALU_EN,               
    output reg   [3:0]                ALU_FUN, 
    //---------------------------------------------
    /*            Reg_File inputs                */
    //---------------------------------------------
    output wire  [$clog2(depth)-1:0]  Reg_File_Adress,               
    output reg                        WrEN,               
    output reg                        RdEN,               
    output reg   [width-1:0]          WrData,
    //---------------------------------------------
    /*               CLK_Gate                    */
    //---------------------------------------------   
    output reg                        CLK_GATE_EN
);

//---------------------------------------------
/*               States                      */
//--------------------------------------------- 
localparam Idle          = 3'b000;
localparam WAddr_Receive = 3'b010;
localparam Data_Receive  = 3'b011;
localparam RAddr_Receive = 3'b001;   
localparam A_Receive     = 3'b100;
localparam B_Receive     = 3'b101;
localparam FUN_Receive   = 3'b111;

reg [2:0] curr_state;
reg [2:0] next_state;

//---------------------------------------------
/*          internal signals               */
//---------------------------------------------

reg                     Add_R_E;       // high when the addres is read
reg                     RdEN_comp;     // high when we are ready to read from the reg_file
reg [$clog2(depth)-1:0] WAdress;       // adress to write in data
reg [$clog2(depth)-1:0] op_addres; // adress to write the operands 

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
            if (RxValid) begin
                case (Rx_P_Data)
                    'hAA:    next_state = WAddr_Receive;
                    'hBB:    next_state = RAddr_Receive;
                    'hCC:    next_state = A_Receive;
                    'hDD:    next_state = FUN_Receive;
                    default: next_state = Idle;
                endcase
            end
            else begin
                next_state = Idle;
            end
        end

/*              Write command                */
        WAddr_Receive: begin
            if (RxValid) begin
                next_state = Data_Receive;
            end
            else begin
                next_state = WAddr_Receive;
            end
        end

        Data_Receive: begin
            if (RxValid) begin
                next_state = Idle;
            end
            else begin
                next_state = Data_Receive;
            end
        end

/*              Read command                 */
        RAddr_Receive: begin
            if (RxValid) begin
                next_state = Idle;
            end
            else begin
                next_state = RAddr_Receive;
            end
        end
        
/*        ALU command with operands          */
        A_Receive: begin
            if (RxValid) begin
                next_state = B_Receive;
            end
            else begin
                next_state = A_Receive;
            end
        end

        B_Receive: begin
            if (RxValid) begin
                next_state = FUN_Receive;
            end
            else begin
                next_state = B_Receive;
            end
        end

        FUN_Receive: begin
            if (RxValid) begin
                next_state = Idle;
            end
            else begin
                next_state = FUN_Receive;
            end
        end
        
        default: next_state = Idle;
    endcase
end

//---------------------------------------------
/*     outputs calculations always           */
//--------------------------------------------- 

always @(posedge CLK, negedge Reset) begin
    if (!Reset) begin
        WAdress = 0;
    end
    else if (Add_R_E) begin
        WAdress = Rx_P_Data;
    end
end

always @(posedge CLK, negedge Reset) begin
    if (!Reset) begin
        RdEN = 0;
    end
    else if (RdEN_comp) begin
        RdEN = 1;
    end
    else begin
        RdEN = 0;
    end
end

assign Reg_File_Adress = (curr_state==Data_Receive || curr_state==Idle) ? WAdress : op_addres;

always @(*) begin
    
    Add_R_E      = 0;
    op_addres    = 0;

    case (curr_state)
        Idle: begin
            ALU_EN       = 0;               
            ALU_FUN      = 0; 
            WrEN         = 0;               
            RdEN_comp    = 0;               
            WrData       = 0;
            CLK_GATE_EN  = 0;
        end

/*              Write command                */
        WAddr_Receive: begin
            if (RxValid) begin
                ALU_EN      = 0;               
                ALU_FUN     = 0; 
                Add_R_E     = 1;              
                WrEN        = 0;               
                RdEN_comp   = 0;               
                WrData      = 0;
                CLK_GATE_EN = 0;
            end
            else begin
                ALU_EN      = 0;               
                ALU_FUN     = 0; 
                Add_R_E     = 0;               
                WrEN        = 0;               
                RdEN_comp   = 0;               
                WrData      = 0;
                CLK_GATE_EN = 0;
            end
        end

        Data_Receive: begin
            if (RxValid) begin
                ALU_EN      = 0;               
                ALU_FUN     = 0;               
                WrEN        = 1;               
                RdEN_comp   = 0;               
                WrData      = Rx_P_Data;
                CLK_GATE_EN = 0;
            end
            else begin
                ALU_EN      = 0;               
                ALU_FUN     = 0;               
                WrEN        = 0;               
                RdEN_comp   = 0;               
                WrData      = 0;
                CLK_GATE_EN = 0;
            end
        end

/*              Read command                 */
        RAddr_Receive: begin
            if (RxValid) begin
                ALU_EN      = 0;               
                ALU_FUN     = 0; 
                Add_R_E     = 1;               
                WrEN        = 0;               
                RdEN_comp   = 1;               
                WrData      = 0;
                CLK_GATE_EN = 0;
            end
            else begin
                ALU_EN      = 0;               
                ALU_FUN     = 0; 
                Add_R_E     = 0;               
                WrEN        = 0;               
                RdEN_comp   = 0;               
                WrData      = 0;
                CLK_GATE_EN = 0;
            end
        end
        
/*        ALU command with operands          */
        A_Receive: begin
            if (RxValid) begin
                ALU_EN      = 0;               
                ALU_FUN     = 0;                
                WrEN        = 1;               
                RdEN_comp   = 0; 
                op_addres   = 0;               
                WrData      = Rx_P_Data;
                CLK_GATE_EN = 0;
            end
            else begin
                ALU_EN      = 0;               
                ALU_FUN     = 0;              
                WrEN        = 0;               
                RdEN_comp   = 0;               
                WrData      = 0;
                CLK_GATE_EN = 0;
            end
        end

        B_Receive: begin
            if (RxValid) begin
                ALU_EN      = 0;               
                ALU_FUN     = 0;                
                WrEN        = 1;               
                RdEN_comp   = 0; 
                op_addres   = 1;               
                WrData      = Rx_P_Data;
                CLK_GATE_EN = 0;
            end
            else begin
                ALU_EN      = 0;               
                ALU_FUN     = 0;               
                WrEN        = 0;               
                RdEN_comp   = 0; 
                op_addres   = 0;               
                WrData      = 0;
                CLK_GATE_EN = 0;
            end
        end

        FUN_Receive: begin
            if (RxValid) begin
                ALU_EN      = 1;               
                ALU_FUN     = Rx_P_Data;               
                WrEN        = 0;               
                RdEN_comp   = 0;               
                WrData      = 0;
                CLK_GATE_EN = 1;
            end
            else begin
                ALU_EN      = 0;               
                ALU_FUN     = 0;               
                WrEN        = 0;               
                RdEN_comp   = 0;               
                WrData      = 0;
                CLK_GATE_EN = 0;
            end
        end
        
        default: begin
            ALU_EN      = 0;               
            ALU_FUN     = 0;               
            WrEN        = 0;               
            RdEN_comp   = 0;               
            WrData      = 0;
            CLK_GATE_EN = 0;
        end
    endcase
end

endmodule