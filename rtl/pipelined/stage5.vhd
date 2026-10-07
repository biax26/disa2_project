library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.exp_pipeline_pkg.all;

entity stage5 is
    port (
        clk_i          : in  std_logic;
        reset_n_i      : in  std_logic;

        
        input_valid_i  : in  std_logic;
        input_ready_o  : out std_logic;
        data_i         : in  stage4_out_t;

        
        output_valid_o : out std_logic;
        output_ready_i : in  std_logic;
        
        
        result_o       : out std_logic_vector(31 downto 0);
        flags_o        : out std_logic_vector(5 downto 0)
    );
end entity stage5;

architecture rtl of stage5 is

    
    constant const_127 : std_logic_vector(7 downto 0) := x"7F";
    signal output_valid_q : std_logic;
    signal input_ready    : std_logic;
    signal register_en    : std_logic;

    signal esponente_ieee : std_logic_vector(7 downto 0);
    signal numero_finale  : std_logic_vector(31 downto 0);
    
   
    signal next_result    : std_logic_vector(31 downto 0);
    signal next_flags     : std_logic_vector(5 downto 0);

begin

       
    add_exp: process(data_i.yint)
    begin
        esponente_ieee <= std_logic_vector(signed(data_i.yint) + signed(const_127));
    end process add_exp;

    
    final_pack : process(esponente_ieee, data_i.mantissa)
    begin
    numero_finale <= '0' & esponente_ieee & data_i.mantissa(23 downto 1);
    end process final_pack;

   
    mux_final: process(data_i.flags, numero_finale)
    begin
        if data_i.flags = "000000" then
            next_result <= x"3F800000"; 
            
        elsif data_i.flags = "000011" then
            next_result <= x"00000000"; 
            
        elsif data_i.flags = "000101" then
            next_result <= x"7F800000"; 
            
        elsif data_i.flags = "010000" then
            next_result <= x"7FC00000";             
        elsif data_i.flags = "000001" then
            next_result <= numero_finale; 
            
        else 
            next_result <= numero_finale; 
        end if;
    end process mux_final;

    
    next_flags <= data_i.flags(5 downto 0);

    
    
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
            result_o <= (others => '0');
            flags_o  <= (others => '0');
        elsif rising_edge(clk_i) then
            if register_en = '1' then
                result_o <= next_result;
                flags_o  <= next_flags;
            end if;
        end if;
    end process;

end architecture rtl;