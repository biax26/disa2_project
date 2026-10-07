library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_backpressure_fpu is
end entity tb_backpressure_fpu;

architecture sim of tb_backpressure_fpu is

    
    signal tb_clk       : std_logic := '0';
    signal tb_reset_n   : std_logic := '0'; 
    signal tb_valid_i   : std_logic := '0';
    signal tb_ready_i   : std_logic := '0';
    signal tb_operand_i : std_logic_vector(31 downto 0) := (others => '0');
    
    signal valid_o      : std_logic;
    signal ready_o      : std_logic;
    signal result_o     : std_logic_vector(31 downto 0);
    signal flags_o      : std_logic_vector(5 downto 0);
    
    constant CLK_PERIOD : time := 10 ns;
    
begin

    
    DUT: entity work.pipelined_exp_fpu
        port map (
            clk       => tb_clk,
            rst_n     => tb_reset_n,
            operand_i => tb_operand_i,
            valid_i   => tb_valid_i,
            ready_o   => ready_o,
            result_o  => result_o,
            flags_o   => flags_o,
            valid_o   => valid_o,
            ready_i   => tb_ready_i
        );

    
    clk_process: process
    begin
        tb_clk <= '0';
        wait for CLK_PERIOD/2;
        tb_clk <= '1';
        wait for CLK_PERIOD/2;
    end process;
    
    
    stimulus_process: process
    begin
        
        tb_reset_n <= '0';
        tb_valid_i <= '0';
        tb_ready_i <= '0';
        wait for 20 ns;
        tb_reset_n <= '1'; 
        wait for 20 ns;
        wait until rising_edge(tb_clk); 
        
        
        tb_ready_i <= '1'; 
        tb_valid_i <= '1';

        
        tb_operand_i <= x"3F800000"; 
        wait until rising_edge(tb_clk) and ready_o = '1';
        wait for 1 ps; 
        
        tb_operand_i <= x"40000000"; 
        wait until rising_edge(tb_clk) and ready_o = '1';
        wait for 1 ps;

        tb_operand_i <= x"40400000"; 
        wait until rising_edge(tb_clk) and ready_o = '1';
        wait for 1 ps;

       
        tb_ready_i <= '0'; 
        tb_operand_i <= x"40800000"; 
        
        
        wait for CLK_PERIOD * 6;

        
        wait until falling_edge(tb_clk);
        tb_ready_i <= '1';

        
        wait until rising_edge(tb_clk) and ready_o = '1';
        wait for 1 ps;

        
        tb_valid_i <= '0';

        wait for CLK_PERIOD * 10;

        
        std.env.stop;
    end process;

end architecture sim;