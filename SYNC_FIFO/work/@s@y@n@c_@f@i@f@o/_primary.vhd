library verilog;
use verilog.vl_types.all;
entity SYNC_FIFO is
    generic(
        width           : integer := 8;
        Depth           : integer := 4
    );
    port(
        CLK             : in     vl_logic;
        Reset           : in     vl_logic;
        ALU_valid       : in     vl_logic;
        RD_valid        : in     vl_logic;
        RD_EN           : in     vl_logic;
        ALU_FUN         : in     vl_logic_vector(3 downto 0);
        ALU_out         : in     vl_logic_vector;
        RD_out          : in     vl_logic_vector;
        Embty           : out    vl_logic;
        Data            : out    vl_logic_vector;
        valid           : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of width : constant is 1;
    attribute mti_svvh_generic_type of Depth : constant is 1;
end SYNC_FIFO;
