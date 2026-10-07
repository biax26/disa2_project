library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.exp_pipeline_pkg.all;

entity stage3 is
    port (
        clk_i          : in  std_logic;
        reset_n_i      : in  std_logic;

        -- Upstream handshake (Da Stadio 2)
        input_valid_i  : in  std_logic;
        input_ready_o  : out std_logic;
        data_i         : in  stage2_out_t;

        -- Downstream handshake (Verso Stadio 4)
        output_valid_o : out std_logic;
        output_ready_i : in  std_logic;
        data_o         : out stage3_out_t
    );
end entity stage3;

architecture rtl of stage3 is

    constant c1 : std_logic_vector(31 downto 0) := x"00B17218";
    signal output_valid_q : std_logic;
    signal input_ready    : std_logic;
    signal register_en    : std_logic;
    signal p_a_32         : std_logic_vector(31 downto 0);
    signal p_b            : std_logic_vector(31 downto 0);
    signal p_c            : std_logic_vector(63 downto 0);
    signal next_data_o    : stage3_out_t;

begin

     p_a_32 <= data_i.p_a(55 downto 24);

    add_step: process(p_a_32)
    begin
        p_b <= std_logic_vector(signed(p_a_32) + signed(c1));
    end process add_step;

    mul_step: process(data_i.yfrac, p_b)
    begin
        p_c <= std_logic_vector(signed(data_i.yfrac) * signed(p_b));
    end process mul_step;

    next_data_o.p_c     <= p_c;
    next_data_o.val_lut <= data_i.val_lut; 
    next_data_o.yint    <= data_i.yint;    
    next_data_o.flags   <= data_i.flags;   
    
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
            data_o.p_c     <= (others => '0');
            data_o.val_lut <= (others => '0');
            data_o.yint    <= (others => '0');
            data_o.flags   <= (others => '0');
        elsif rising_edge(clk_i) then
            if register_en = '1' then
                data_o <= next_data_o; 
            end if;
        end if;
    end process;

end architecture rtl;