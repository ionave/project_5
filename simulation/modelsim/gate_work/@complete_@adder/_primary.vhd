library verilog;
use verilog.vl_types.all;
entity Complete_Adder is
    port(
        Clk             : in     vl_logic;
        Reset_L         : in     vl_logic;
        LoadB_L         : in     vl_logic;
        Run             : in     vl_logic;
        SW              : in     vl_logic_vector(15 downto 0);
        Cout            : out    vl_logic;
        AhexL           : out    vl_logic_vector(6 downto 0);
        AhexU           : out    vl_logic_vector(6 downto 0);
        BhexL           : out    vl_logic_vector(6 downto 0);
        BhexU           : out    vl_logic_vector(6 downto 0)
    );
end Complete_Adder;
