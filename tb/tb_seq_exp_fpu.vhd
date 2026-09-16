library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_seq_exp_fpu is

end entity tb_seq_exp_fpu;

architecture sim of tb_seq_exp_fpu is
   
    component seq_exp_fpu is
        port (
            clk, reset, valid_i, ready_i : in std_logic;
            valid_o, ready_o             : out std_logic;
            operand_i                    : in std_logic_vector(31 downto 0);
            result_o                     : out std_logic_vector(31 downto 0);
            flag_o                       : out std_logic_vector(4 downto 0)
        );
    end component;

   
    signal clk       : std_logic := '0';
    signal reset     : std_logic := '0';
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
        reset     => reset,
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
        
        reset <= '1';
        valid_i <= '0';
        ready_i <= '0';
        wait for 20 ns;
        reset <= '0';
        wait for 20 ns;
        
        
        -- Zero Positivo (+0.0), valore atteso: 1.0 (x"3F800000")
        operand_i <= x"00000000";
        valid_i <= '1'; wait until rising_edge(clk); valid_i <= '0';
        wait until valid_o = '1';
        ready_i <= '1'; wait until rising_edge(clk); ready_i <= '0';
        wait for 30 ns;

       --zero negativo (-0.0), valore atteso: 1.0 (x"3F800000")
        operand_i <= x"80000000";
        valid_i <= '1'; wait until rising_edge(clk); valid_i <= '0';
        wait until valid_o = '1';
        ready_i <= '1'; wait until rising_edge(clk); ready_i <= '0';
        wait for 30 ns;
        -- Più Infinito (+Inf) val atteso: +Inf (x"7F800000") 
        operand_i <= x"7F800000";
        valid_i <= '1'; wait until rising_edge(clk); valid_i <= '0';
        wait until valid_o = '1';
        ready_i <= '1'; wait until rising_edge(clk); ready_i <= '0';
        wait for 30 ns;
        
        --Meno Infinito (-Inf) val atteso: 0.0 
        operand_i <= x"FF800000";
        valid_i <= '1'; wait until rising_edge(clk); valid_i <= '0';
        wait until valid_o = '1';
        ready_i <= '1'; wait until rising_edge(clk); ready_i <= '0';
        wait for 30 ns;

        -- Not-a-Number (NaN) val atteso: NaN (x"7FC00000")
        operand_i <= x"7FC00000";
        valid_i <= '1'; wait until rising_edge(clk); valid_i <= '0';
        wait until valid_o = '1';
        ready_i <= '1'; wait until rising_edge(clk); ready_i <= '0';
        wait for 30 ns;

        --Overflow (Es. ingresso +90.0), val atteso: +Inf (x"7F800000")
        operand_i <= x"42B40000";
        valid_i <= '1'; wait until rising_edge(clk); valid_i <= '0';
        wait until valid_o = '1';
        ready_i <= '1'; wait until rising_edge(clk); ready_i <= '0';
        wait for 30 ns;

        -- Underflow (Es. ingresso -105.0) val atteso: 0.0 
        operand_i <= x"C2D20000";
        valid_i <= '1'; wait until rising_edge(clk); valid_i <= '0';
        wait until valid_o = '1';
        ready_i <= '1'; wait until rising_edge(clk); ready_i <= '0';
        wait for 30 ns;

        --Numero Positivo (+1.0) val atteso: (~2.718, x"402DF8B6")
        operand_i <= x"3F800000";
        valid_i <= '1'; wait until rising_edge(clk); valid_i <= '0';
        wait until valid_o = '1';
        ready_i <= '1'; wait until rising_edge(clk); ready_i <= '0';
        wait for 30 ns;

     -- Numero Negativo (-1.0) val atteso: 1/e (~0.367, x"3EBC5A3A")
        operand_i <= x"BF800000";
        valid_i <= '1'; wait until rising_edge(clk); valid_i <= '0';
        wait until valid_o = '1';
        ready_i <= '1'; wait until rising_edge(clk); ready_i <= '0';
        wait for 30 ns;

        --Valore Generico Positivo (+6.5) val atteso: e^6.5 = ~665.14 (x"44264B72")
        operand_i <= x"40D00000";
        valid_i <= '1'; wait until rising_edge(clk); valid_i <= '0';
        wait until valid_o = '1';
        ready_i <= '1'; wait until rising_edge(clk); ready_i <= '0';
        wait for 30 ns;

      
        std.env.stop;
    end process;
end architecture;
