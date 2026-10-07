library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.exp_pipeline_pkg.all;

entity stage4 is
    port (
        clk_i          : in  std_logic;
        reset_n_i      : in  std_logic;

        
        input_valid_i  : in  std_logic;
        input_ready_o  : out std_logic;
        data_i         : in  stage3_out_t;

      
        output_valid_o : out std_logic;
        output_ready_i : in  std_logic;
        data_o         : out stage4_out_t
    );
end entity stage4;

architecture rtl of stage4 is
    constant c0 : std_logic_vector(31 downto 0) := x"01000000";
    signal output_valid_q : std_logic;
    signal input_ready    : std_logic;
    signal register_en    : std_logic;
    signal p_c_32         : std_logic_vector(31 downto 0);
    signal p_d            : std_logic_vector(31 downto 0);
    signal m_64           : std_logic_vector(63 downto 0);
    signal mantissa_32    : std_logic_vector(31 downto 0);
    signal next_data_o    : stage4_out_t;

begin

        
    p_c_32 <= data_i.p_c(55 downto 24);

    
    add_step: process(p_c_32)
    begin
        p_d <= std_logic_vector(signed(p_c_32) + signed(c0));
    end process add_step;

    mul_step: process(data_i.val_lut, p_d)
    begin
    m_64 <= std_logic_vector(signed(data_i.val_lut) * signed(p_d));
    end process mul_step;

    
    mantissa_32 <= m_64(55 downto 24);

    next_data_o.mantissa <= mantissa_32;
    next_data_o.yint     <= data_i.yint;  
    next_data_o.flags    <= data_i.flags; 


        
    input_ready <= (not output_valid_q) or output_ready_i;
    register_en <= input_valid_i and input_ready;

    input_ready_o  <= input_ready;
    output_valid_o <= output_valid_q;

    
    process (clk_i, reset_n_i)
    begin
        if reset_n_i = '0' then
            output_valid_q <= '0';
        elsif rising_edge(clk_i) then
            if input_ready = '1' then
                output_valid_q <= input_valid_i;
            end if;
        end if;
    end process;

    
    process (clk_i, reset_n_i)
    begin
        if reset_n_i = '0' then
            data_o.mantissa <= (others => '0');
            data_o.yint     <= (others => '0');
            data_o.flags    <= (others => '0');
        elsif rising_edge(clk_i) then
            if register_en = '1' then
                data_o <= next_data_o; 
            end if;
        end if;
    end process;

end architecture rtl;