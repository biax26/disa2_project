library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_seq_exp_fpu2 is

end entity tb_seq_exp_fpu2;

architecture sim of tb_seq_exp_fpu2 is
   
    component seq_exp_fpu is
        port (
            clk, reset_n, valid_i, ready_i : in std_logic;
            valid_o, ready_o             : out std_logic;
            operand_i                    : in std_logic_vector(31 downto 0);
            result_o                     : out std_logic_vector(31 downto 0);
            flag_o                       : out std_logic_vector(4 downto 0)
        );
    end component;

   
    signal clk       : std_logic := '0';
    signal reset_n     : std_logic := '1';
    signal valid_i   : std_logic := '0';
    signal ready_i   : std_logic := '0';
    signal operand_i : std_logic_vector(31 downto 0) := (others => '0');
    
    signal valid_o   : std_logic;
    signal ready_o   : std_logic;
    signal result_o  : std_logic_vector(31 downto 0);
    signal flag_o    : std_logic_vector(4 downto 0);
    
    constant CLK_PERIOD : time := 10 ns;
    
begin
   
    DUT: seq_exp_fpu port map (
        clk       => clk,
        reset_n     => reset_n,
        valid_i   => valid_i,
        ready_i   => ready_i,
        valid_o   => valid_o,
        ready_o   => ready_o,
        operand_i => operand_i,
        result_o  => result_o,
        flag_o    => flag_o
    );

    
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;
    
   
    stimulus_process: process
    begin
        
        reset_n <= '0';
        valid_i <= '0';
        ready_i <= '0';
        wait for 20 ns;
        reset_n <= '1';
        wait for 20 ns;
        
        operand_i <= x"C188F981";
        valid_i <= '1'; wait until rising_edge(clk); valid_i <= '0';
        wait until valid_o = '1';
        ready_i <= '1'; wait until rising_edge(clk); ready_i <= '0';
        wait for 33 ns;

        operand_i <= x"C13EA097";
        valid_i <= '1'; wait until rising_edge(clk); valid_i <= '0';
        wait until valid_o = '1';
        ready_i <= '1'; wait until rising_edge(clk); ready_i <= '0';
        wait for 33 ns;

        operand_i <= x"407D4D00";
        valid_i <= '1'; wait until rising_edge(clk); valid_i <= '0';
        wait until valid_o = '1';
        ready_i <= '1'; wait until rising_edge(clk); ready_i <= '0';
        wait for 33 ns;

        operand_i <= x"419EB83C";
        valid_i <= '1'; wait until rising_edge(clk); valid_i <= '0';
        wait until valid_o = '1';
        ready_i <= '1'; wait until rising_edge(clk); ready_i <= '0';
        wait for 33 ns;

        operand_i <= x"40C61F68";
        valid_i <= '1'; wait until rising_edge(clk); valid_i <= '0';
        wait until valid_o = '1';
        ready_i <= '1'; wait until rising_edge(clk); ready_i <= '0';
        wait for 33 ns;

        operand_i <= x"C18DDD1F";
        valid_i <= '1'; wait until rising_edge(clk); valid_i <= '0';
        wait until valid_o = '1';
        ready_i <= '1'; wait until rising_edge(clk); ready_i <= '0';
        wait for 33 ns;

        operand_i <= x"C16080B8";
        valid_i <= '1'; wait until rising_edge(clk); valid_i <= '0';
        wait until valid_o = '1';
        ready_i <= '1'; wait until rising_edge(clk); ready_i <= '0';
        wait for 33 ns;

        operand_i <= x"3D6CE800";
        valid_i <= '1'; wait until rising_edge(clk); valid_i <= '0';
        wait until valid_o = '1';
        ready_i <= '1'; wait until rising_edge(clk); ready_i <= '0';
        wait for 33 ns;

        operand_i <= x"40FA859C";
        valid_i <= '1'; wait until rising_edge(clk); valid_i <= '0';
        wait until valid_o = '1';
        ready_i <= '1'; wait until rising_edge(clk); ready_i <= '0';
        wait for 33 ns;

        operand_i <= x"4110558C";
        valid_i <= '1'; wait until rising_edge(clk); valid_i <= '0';
        wait until valid_o = '1';
        ready_i <= '1'; wait until rising_edge(clk); ready_i <= '0';
        wait for 33 ns;
      
        std.env.stop;
    end process;
end architecture;
