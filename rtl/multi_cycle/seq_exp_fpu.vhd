library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seq_exp_fpu is 
    port (
    clk, reset, valid_i, ready_i: in std_logic;
    valid_o, ready_o: out std_logic;
    operand_i: in std_logic_vector(31 downto 0);
    result_o: out std_logic_vector(31 downto 0);
    flag_o: out std_logic_vector(4 downto 0)
    );
end entity seq_exp_fpu;

architecture behavior of seq_exp_fpu is
   
 signal ps, ns: integer;
  signal clear_reg_yfrac_small_19, enable_reg_yfrac_small_19, clear_reg_ylut_5, enable_reg_ylut_5, 
          clear_reg_yint_8, enable_reg_yint_8, selmux1, selmux2, clear_reg_operand_i, enable_reg_operand_i, 
          clear_regp, enable_regp, clear_regs, enable_regs : std_logic;
 signal reg_operand_i_out, val_lut, c2, regs_out, regp_out, mux1_out, mux2_out, const_log2e,  
          add2_out, c0, c1, flags_comp_out, operand_i_q_8_24, 
          risy_32, reg_yfrac_small_out, numero_finale, regp_in , mantissa_completa: std_logic_vector(31 downto 0);
   signal yint_8, reg_out_yint_8, esponente_ieee, const_127: std_logic_vector(7 downto 0);
   signal yfrac_small_19: std_logic_vector(18 downto 0);
   signal ylut_5, address_in: std_logic_vector(4 downto 0);
   signal y, mul2_out, mul3_out : std_logic_vector(63 downto 0);
   signal flagok: std_logic;
   signal flags_interne: std_logic_vector(5 downto 0);
begin

flag_o<= flags_interne (4 downto 0);
risy_32 <= y(55 downto 24);
yfrac_small_19 <= risy_32(18 downto 0);
ylut_5 <= risy_32(23 downto 19);
yint_8<=risy_32(31 downto 24);
regp_in <= mul2_out(55 downto 24);
mantissa_completa <= mul3_out(55 downto 24);
     MIA_ROM : entity work.lut_rom
        port map (
            indirizzo => address_in, 
            dato      => val_lut    
        );

const_log2e <= x"01715476";
const_127<=x"7F";
c0 <= x"01000000"; 
c1 <= x"00B17218"; 
c2 <= x"003D7F41"; 

state_register: process (clk, reset)
begin
    if reset = '1' then
        ps <= 0;
    elsif rising_edge(clk) then
        ps <= ns;
    end if;
end process;

cl1 : process(ps, valid_i, flagok, ready_i)
begin
    case ps is
        when 0 => 
            if valid_i = '1' then 
                ns <= 1;
            else 
                ns <= 0;
            end if;
        when 1 => 
            if flagok = '1' then 
                ns <= 2;
            else
                ns <= 3;
            end if;
        when 2 => 
            if ready_i = '1' then 
                ns <= 0;
            else 
                ns <= 2;
            end if;
        when 3 => ns <= 4;
        when 4 => ns <= 5;
        when 5 => ns <= 6;
        when 6 => ns <= 7;
        when 7 => ns <= 8;
        when 8 => ns <= 9;
        when 9 => ns <= 10;
        when 10=> ns <= 11;
        when 11=> ns <= 12;
        when 12=> ns <= 13;
        when 13=> 
            if ready_i = '1' then 
                ns <= 0;
            else 
                ns <= 13;
            end if;
        when others => ns <= 0;
    end case;
end process cl1;

cl2: process(ps)
begin
     ready_o <= '0';
        valid_o <= '0';
        clear_reg_operand_i <= '0';
        enable_reg_operand_i <= '0';
        clear_reg_yfrac_small_19 <= '0';
        enable_reg_yfrac_small_19 <= '0';
        clear_reg_ylut_5 <= '0';
        enable_reg_ylut_5 <= '0';
        clear_reg_yint_8 <= '0';
        enable_reg_yint_8 <= '0';
        clear_regp <= '0';
        enable_regp <= '0';
        clear_regs <= '0';
        enable_regs <= '0';
        selmux1 <= '0';
        selmux2 <= '0';
    case ps is 
        when 0 => 
            ready_o <= '1';
            valid_o <='0';
            enable_reg_operand_i <= '1';
        when 1 => ready_o <= '0';
        when 2 => valid_o <= '1';
        when 3 => 
            enable_reg_yfrac_small_19 <= '1';
            enable_reg_ylut_5<='1';
            enable_reg_yint_8<='1';
        when 4 => selmux1 <= '0';
        when 5 => 
            selmux1 <='0';
            enable_regp <= '1';
        when 6 => selmux2 <='1';
        when 7 => 
            selmux2 <= '1';
            enable_regs <= '1';
        when 8 => selmux1 <='1';
        when 9 => 
            selmux1 <= '1';
            enable_regp<='1';
        when 10 => selmux2<='0';
        when 11 => 
            selmux2<='0';
            enable_regs<='1';
        when 12 => NULL;
        when 13 => valid_o <= '1';
        when others => NULL;
    end case;
end process cl2;

        reg_operand_i: process(clk, clear_reg_operand_i)
    begin
        if clear_reg_operand_i = '1' then
            reg_operand_i_out <= (others=>'0');
        elsif rising_edge(clk) then 
            if enable_reg_operand_i = '1' then
                reg_operand_i_out <= operand_i;
            end if; 
        end if;     
    end process;

    flags_comparator: process(reg_operand_i_out)
    begin
        flagok        <= '0';       
        flags_interne <= "000001";   
        flags_comp_out <= reg_operand_i_out;
        
        if reg_operand_i_out = x"7FC00000" then 
            flags_interne <= "010000"; 
            flagok        <= '1';     
            
        elsif unsigned(reg_operand_i_out) > unsigned'(x"42B170A4") and reg_operand_i_out(31) = '0' then 
            flags_interne <= "000101"; 
            flagok        <= '1';
            
        elsif unsigned(reg_operand_i_out) > unsigned'(x"C2CFF0A4") and reg_operand_i_out(31) = '1' then 
            flags_interne <= "000011"; 
            flagok        <= '1';
            
        elsif reg_operand_i_out = x"00000000" or reg_operand_i_out = x"80000000" then
            flags_interne <= "100000";
            flagok        <= '1';
            
        elsif reg_operand_i_out = x"7F800000" then
            flags_interne <= "000000"; 
            flagok        <= '1';
            
        end if;
    end process;

    mux_final:process(flags_interne, numero_finale)
    begin
        if flags_interne = "000011" then 
            result_o <= x"00000000";
            elsif flags_interne = "000101" then
                result_o <= x"7F800000";
            elsif flags_interne = "010000" then
                result_o <= x"7FC00000";
            elsif flags_interne = "100000" then
                result_o <= x"3F800000";
            elsif flags_interne = "000000" then
                result_o <= x"7F800000";
            else 
                result_o <= numero_finale; 
            end if;
        end process mux_final;
    
    ieee_to_fixed_converter: process(flags_comp_out)
        variable exp_biased : unsigned(7 downto 0);
        variable exp_true   : integer;
        variable mantissa   : unsigned(23 downto 0); 
        variable base_val   : unsigned(31 downto 0);
        variable shifted_val: unsigned(31 downto 0);
    begin
        exp_biased := unsigned(flags_comp_out(30 downto 23));
        
        exp_true   := to_integer(exp_biased) - 127;
        
        mantissa   := '1' & unsigned(flags_comp_out(22 downto 0));
        
        base_val   := "0000000" & mantissa & '0';
        
        if exp_true > 0 then
            shifted_val := shift_left(base_val, exp_true);
        elsif exp_true < 0 then
            shifted_val := shift_right(base_val, -exp_true);
        else
            shifted_val := base_val; 
        end if;
        
        if flags_comp_out(31) = '1' then
            operand_i_q_8_24 <= std_logic_vector(-signed(shifted_val));
        else
            operand_i_q_8_24 <= std_logic_vector(shifted_val);
        end if;
        
        if flags_comp_out(30 downto 0) = "0000000000000000000000000000000" then
            operand_i_q_8_24 <= (others => '0');
        end if;
    end process;

    mul1: process(operand_i_q_8_24, const_log2e)
    begin
        y <= std_logic_vector( signed(operand_i_q_8_24) * signed(const_log2e) );
    end process mul1;
    
    reg_yint_8: process(clk, clear_reg_yint_8)
    begin
        if clear_reg_yint_8 = '1' then
            reg_out_yint_8 <= (others => '0');
        elsif rising_edge(clk) then 
            if enable_reg_yint_8 = '1' then
                reg_out_yint_8 <= yint_8;
            end if;
        end if;
    end process reg_yint_8;

    reg_ylut_5: process(clk, clear_reg_ylut_5)
    begin
        if clear_reg_ylut_5 = '1' then
            address_in <= (others => '0');
        elsif rising_edge(clk) then 
            if enable_reg_ylut_5 = '1' then
                address_in<= ylut_5;
            end if;
        end if;
    end process reg_ylut_5;

    reg_yfrac_small_19: process(clk, clear_reg_yfrac_small_19)
    begin
        if clear_reg_yfrac_small_19 = '1' then
            reg_yfrac_small_out <= (others => '0');
        elsif rising_edge(clk) then 
            if enable_reg_yfrac_small_19 = '1' then
                reg_yfrac_small_out <=  "0000000000000" & yfrac_small_19;
            end if;
        end if;
    end process reg_yfrac_small_19;
    
add1: process(reg_out_yint_8, const_127)
begin
    esponente_ieee<= std_logic_vector(signed(reg_out_yint_8) + signed(const_127));
end process;

mux1:process(selmux1, c2, regs_out)
begin
    if selmux1 = '0' then
        mux1_out <= c2;
    else 
        mux1_out <= regs_out;
    end if;
end process mux1;

mux2: process(selmux2, c0, c1)
begin
    if selmux2 = '0' then
    mux2_out <= c0;
else 
    mux2_out <= c1;
end if;
end process mux2;


mul2: process (reg_yfrac_small_out, mux1_out)
begin
    mul2_out <= std_logic_vector(signed(reg_yfrac_small_out)*signed(mux1_out));
end process mul2;

regp: process(clk, clear_regp)
begin
if clear_regp = '1' then
    regp_out <= (others=> '0');
elsif rising_edge(clk) then if enable_regp = '1' then
    regp_out <= regp_in;
end if;
end if;
end process regp;

mul3: process (val_lut, regs_out)
begin
    mul3_out <= std_logic_vector(signed(val_lut)*signed(regs_out));
end process mul3;

add2: process(regp_out, mux2_out)
begin
    add2_out <= std_logic_vector(signed(regp_out)+signed(mux2_out));
end process add2;
regs: process(clk, clear_regs)
begin
    if clear_regs = '1' then
    regs_out <= (others => '0');
    elsif rising_edge(clk) then if enable_regs = '1' then
        regs_out <= add2_out;
    end if;
end if;
end process regs;    
final_pack : process(esponente_ieee, mantissa_completa)
begin
numero_finale <= '0' & esponente_ieee & mantissa_completa(23 downto 1);
end process final_pack;
    
    end architecture behavior;
