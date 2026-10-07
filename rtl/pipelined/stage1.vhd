library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.exp_pipeline_pkg.all;

entity stage1 is
    port (
        clk_i          : in  std_logic;
        reset_n_i      : in  std_logic;

        -- Upstream handshake
        input_valid_i  : in  std_logic;
        input_ready_o  : out std_logic;
        data_i         : in  std_logic_vector(31 downto 0);

        -- Downstream handshake
        output_valid_o : out std_logic;
        output_ready_i : in  std_logic;
        data_o         : out stage1_out_t
    );
end entity stage1;

architecture rtl of stage1 is

    constant const_log2e : std_logic_vector(31 downto 0) := x"01715476";

    signal output_valid_q : std_logic;
    signal input_ready    : std_logic;
    signal register_en    : std_logic;

    signal flags_interne    : std_logic_vector(5 downto 0);
    signal operand_i_q_8_24 : std_logic_vector(31 downto 0);
    signal y_val            : std_logic_vector(63 downto 0);
    
    signal next_data_o      : stage1_out_t;

begin
    
   flags_comparator: process(data_i)
        variable exp_v  : std_logic_vector(7 downto 0);
        variable mant_v : std_logic_vector(22 downto 0);
        variable sign_v : std_logic;
    begin
        sign_v := data_i(31);
        exp_v  := data_i(30 downto 23);
        mant_v := data_i(22 downto 0);

               
        
        if exp_v = x"FF" and mant_v /= "00000000000000000000000" then
            flags_interne <= "010000"; -- NaN (10 hex)

        elsif exp_v = x"FF" and mant_v = "00000000000000000000000" then
        if sign_v = '0' then
                flags_interne <= "000101"; -- +Inf (05 hex)
            else
                flags_interne <= "000011"; -- -Inf (03 hex)
            end if;

        elsif exp_v = x"00" and mant_v = "00000000000000000000000" then
            flags_interne <= "000000"; -- Zero (00 hex)

       elsif sign_v = '0' and unsigned(data_i(30 downto 0)) > unsigned'(x"42B170A4") then
            flags_interne <= "000101"; -- Overflow (05 hex)

        elsif sign_v = '1' and unsigned(data_i(30 downto 0)) > unsigned'(x"42CFF0A4") then
            flags_interne <= "000011"; -- Underflow (03 hex)

        else
            flags_interne <= "000001"; -- Normale (01 hex)
        end if;
    end process flags_comparator;

    
    ieee_to_fixed_converter: process(data_i)
        variable exp_biased : unsigned(7 downto 0);
        variable exp_true   : integer;
        variable mantissa   : unsigned(23 downto 0); 
        variable base_val   : unsigned(31 downto 0);
        variable shifted_val: unsigned(31 downto 0);
    begin
        exp_biased := unsigned(data_i(30 downto 23));
        exp_true   := to_integer(exp_biased) - 127;
        mantissa   := '1' & unsigned(data_i(22 downto 0));
        base_val   := "0000000" & mantissa & '0';
        
        if exp_true > 0 then
            shifted_val := shift_left(base_val, exp_true);
        elsif exp_true < 0 then
            shifted_val := shift_right(base_val, -exp_true);
        else
            shifted_val := base_val; 
        end if;
        
        if data_i(31) = '1' then
            operand_i_q_8_24 <= std_logic_vector(-signed(shifted_val));
        else
            operand_i_q_8_24 <= std_logic_vector(shifted_val);
        end if;
        
        if data_i(30 downto 0) = "0000000000000000000000000000000" then
            operand_i_q_8_24 <= (others => '0');
        end if;
    end process ieee_to_fixed_converter;

    
    mul1: process(operand_i_q_8_24)
    begin
        y_val <= std_logic_vector( signed(operand_i_q_8_24) * signed(const_log2e) );
    end process mul1;

    
    next_data_o.y_val <= y_val;
    next_data_o.flags <= flags_interne;

    
    input_ready <= (not output_valid_q) or output_ready_i;
    register_en <= input_valid_i and input_ready;

    input_ready_o <= input_ready;
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
        data_o.y_val <= (others => '0');
        data_o.flags <= (others => '0');
    elsif rising_edge(clk_i) then
        if input_valid_i = '1' and input_ready = '1' then
            data_o <= next_data_o; 
        end if;
    end if;
end process;

end architecture rtl;