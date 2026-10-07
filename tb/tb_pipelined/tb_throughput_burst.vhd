library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_throughput_burst is
end tb_throughput_burst;

architecture behavior of tb_throughput_burst is

    
    component pipelined_exp_fpu
    port(
        clk       : in  std_logic;
        rst_n     : in  std_logic;
        
        operand_i : in  std_logic_vector(31 downto 0);
        valid_i   : in  std_logic;
        ready_o   : out std_logic;
        
        result_o  : out std_logic_vector(31 downto 0);
        flags_o   : out std_logic_vector(5 downto 0);
        valid_o   : out std_logic;
        ready_i   : in  std_logic
    );
    end component;

    
    signal tb_clk       : std_logic := '0';
    signal tb_rst_n     : std_logic := '0';
    signal tb_operand_i : std_logic_vector(31 downto 0) := (others => '0');
    signal tb_valid_i   : std_logic := '0';
    signal tb_ready_i   : std_logic := '0';
    
    signal result_o     : std_logic_vector(31 downto 0);
    signal flags_o      : std_logic_vector(5 downto 0);
    signal valid_o      : std_logic;
    signal ready_o      : std_logic;

    
    constant CLK_PERIOD : time := 10 ns;

begin

    
    UUT: pipelined_exp_fpu 
    port map (
        clk       => tb_clk,
        rst_n     => tb_rst_n,
        operand_i => tb_operand_i,
        valid_i   => tb_valid_i,
        ready_o   => ready_o,
        result_o  => result_o,
        flags_o   => flags_o,
        valid_o   => valid_o,
        ready_i   => tb_ready_i
    );

    
    clk_process : process
    begin
        tb_clk <= '0';
        wait for CLK_PERIOD/2;
        tb_clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    
    stim_proc: process
    begin
        
        tb_rst_n     <= '0';
        tb_valid_i   <= '0';
        tb_ready_i   <= '0';
        tb_operand_i <= (others => '0');
        wait for 20 ns;
        
        tb_rst_n <= '1';  
        wait for 30 ns;    

        
        wait until falling_edge(tb_clk);
        
        
        tb_valid_i <= '1'; 
        tb_ready_i <= '1'; 

        
        tb_operand_i <= x"3F800000"; 
        wait until rising_edge(tb_clk) and ready_o = '1';
        
        
        tb_operand_i <= x"40000000"; 
        wait until rising_edge(tb_clk) and ready_o = '1';
        
        
        tb_operand_i <= x"40400000"; 
        wait until rising_edge(tb_clk) and ready_o = '1';
        
        
        tb_operand_i <= x"BF800000"; 
        wait until rising_edge(tb_clk) and ready_o = '1';
        
        
        tb_operand_i <= x"40D00000"; 
        wait until rising_edge(tb_clk) and ready_o = '1';

        
        wait until falling_edge(tb_clk);
        tb_valid_i <= '0';
        
        
        wait for 100 ns; 

        
        std.env.stop;
    end process;

end behavior;