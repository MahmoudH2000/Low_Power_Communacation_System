# Low_Power_Communacation_System
![image](https://user-images.githubusercontent.com/71590162/194552515-91a693b0-8c2a-41cd-85c3-a24ae6f18132.png)  
# Project phases
  • RTL Design from Scratch of system blocks (ALU, Register File, Integer Clock Divider, Clock Gating, Synchronizers, Main Controller, UART TX, UART RX).

  • Integrate and verify functionality through self-checking testbench.

  • Constraining the system using synthesis TCL scripts.

  • Synthesize and optimize the design using design compiler tool.

  • Analyze Timing paths and fix setup and hold violations.

  • Verify Functionality equivalence using Formality tool.

  • Physical implementation of the system passing through ASIC flow phases and generate the GDS File.

  • Verify functionality post-layout considering the actual delay.

# Description
It is responsible of receiving commands through UART receiver to do different system functions as registerfile reading/writing
or doing some processing using ALU block and send result through UART transmitter communication protocol.
his system contains 9 blocks

1) Clock Domain 1 (REF_CLK)
  
      • RegFile
  
      • ALU
  
      • Clock Gating
  
      • SYS_CTRL
  
2) Clock Domain 2 (UART_CLK)
 
      • UART_TX
  
      • UART_RX
  
      • Clock Divider
  
3) Synchronizers
  
      • RST Synchronizer
  
      • Data Synchronizer
  
      • Bit Synchronizer

# Supported Operations
1) ALU Operations:
    
    • Addition
    
    • Subtraction
    
    • Multiplication
    
    • Division

    • AND

    • OR

    • NAND

    • NOR

    • XOR

    • XNOR

    • CMP: A == B

    • CMP: A > B
    
    • CMP: A < B

    • SHIFT: A >> 1

    • SHIFT: A << 1

2) Register File Operations

    • Register File Write
    
    • Register File read

# Supported Commands

1) Register File Write command (3 Frames)

    Frame 1: 
    
        RF_Wr_CMD (0xAA)
      
    Frame 2: 
    
        RF_Wr_Addr 
      
    Frame 3: 
    
        RF_Wr_Data 
    
    Example:
    
        AA ----> 1010 ----> 11110000
        
    which means that I want to write 8'b11110000 in adress 1010 in the Reg_File.
 
2) Register File Read command (2 frames)

    Frame 1: 
    
        RF_Rd_CMD (0xBB)
      
    Frame 2: 
    
        RF_Rd_Addr 
    
    Example:
    
        BB ----> 1010 
        
    which means that I want to Read adress 1010 in the Reg_File.

3) ALU Operation command with operand (4 frames)

    Frame 1: 
    
        ALU_OPER_W_OP_CMD (0xCC)
      
    Frame 2: 
    
        Operand A 
      
    Frame 3: 
    
        Operand B 
    
    Frame 4: 
    
        ALU FUN 
    
    Example:
    
        CC ----> 00001111 ----> 11110000 ----> 0000
        
    which means that I want to add 00001111 and 11110000. 

2) ALU Operation command with No operand (2 frames)

    Frame 1: 
    
        ALU_OPER_W_NOP_CMD (0xDD)
      
    Frame 2: 
    
        ALU FUN 
    
    Example:
    
        DD ----> 0000 
        
    which means that I want to add A and B which are already stored in the Reg_File.
    
# System Specifications

   • Reference clock (REF_CLK) is 50 MHz

   • UART clock (UART_CLK) is 9.6 KHz

   • Div_ratio is 8

   • Clock Divider is always on (clock divider enable = 1)
      
