library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.exp_pipeline_pkg.all;

entity stage2 is
    port (
        clk_i          : in  std_logic;
        reset_n_i      : in  std_logic;

        -- Upstream handshake (Da Stadio 1)
        input_valid_i  : in  std_logic;
        input_ready_o  : out std_logic;
        data_i         : in  stage1_out_t;

        -- Downstream handshake (Verso Stadio 3)
        output_valid_o : out std_logic;
        output_ready_i : in  std_logic;
        data_o         : out stage2_out_t
    );
end entity stage2;

architecture rtl of stage2 is

    constant c2 : std_logic_vector(31 downto 0) := x"003D7F7B";

    
    signal output_valid_q : std_logic;
    signal input_ready    : std_logic;
    signal register_en    : std_logic;

    
    signal risy_32        : std_logic_vector(31 downto 0);
    signal yfrac_small_19 : std_logic_vector(18 downto 0);
    signal ylut_5         : std_logic_vector(4 downto 0);
    signal yint_8         : std_logic_vector(7 downto 0);
    signal yfrac_32       : std_logic_vector(31 downto 0);
    
    signal val_lut        : std_logic_vector(31 downto 0);
    signal p_a            : std_logic_vector(63 downto 0);
    
    signal next_data_o    : stage2_out_t;

begin

    risy_32        <= data_i.y_val(55 downto 24);
    yfrac_small_19 <= risy_32(18 downto 0);
    ylut_5         <= risy_32(23 downto 19);
    yint_8         <= risy_32(31 downto 24);
    yfrac_32       <= "0000000000000" & yfrac_small_19;
    MIA_ROM : entity work.lut_rom
        port map (
            indirizzo => ylut_5,
            dato      => val_lut
        );

    mul2_step1: process(yfrac_32)
    begin
        p_a <= std_logic_vector(signed(yfrac_32) * signed(c2));
    end process mul2_step1;

    next_data_o.p_a     <= p_a;
    next_data_o.yfrac   <= yfrac_32;
    next_data_o.val_lut <= val_lut;
    next_data_o.yint    <= yint_8;
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
            data_o.p_a     <= (others => '0');
            data_o.yfrac   <= (others => '0');
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