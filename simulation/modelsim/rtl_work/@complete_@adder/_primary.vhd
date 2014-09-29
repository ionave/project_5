library verilog;
use verilog.vl_types.all;
entity Complete_Adder is
    port(
        T               : in     vl_logic_vector(15 downto 0);
        U               : in     vl_logic_vector(15 downto 0);
        v_in            : in     vl_logic;
        W               : out    vl_logic_vector(15 downto 0);
        v_out           : out    vl_logic
    );
end Complete_Adder;
