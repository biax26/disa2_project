library ieee;
use ieee.std_logic_1164.all;

use work.exp_pipeline_pkg.all; 

entity pipelined_exp_fpu is
    port (
        -- Global
        clk       : in  std_logic;
        rst_n     : in  std_logic; 

        -- Input Interface
        operand_i : in  std_logic_vector(31 downto 0);
        valid_i   : in  std_logic;
        ready_o   : out std_logic;

        -- Output Interface
        result_o  : out std_logic_vector(31 downto 0);
        flags_o   : out std_logic_vector(5 downto 0);
        valid_o   : out std_logic;
        ready_i   : in  std_logic
    );
end entity pipelined_exp_fpu;

architecture structural of pipelined_exp_fpu is

    signal s1_valid_to_s2, s2_ready_to_s1 : std_logic;
    signal s2_valid_to_s3, s3_ready_to_s2 : std_logic;
    signal s3_valid_to_s4, s4_ready_to_s3 : std_logic;
    signal s4_valid_to_s5, s5_ready_to_s4 : std_logic;

    signal s1_data_to_s2 : stage1_out_t;
    signal s2_data_to_s3 : stage2_out_t;
    signal s3_data_to_s4 : stage3_out_t;
    signal s4_data_to_s5 : stage4_out_t;

begin

   
    STAGE_1 : entity work.stage1
        port map (
            clk_i          => clk,
            reset_n_i      => rst_n,
            input_valid_i  => valid_i,          
            input_ready_o  => ready_o,          
            data_i         => operand_i,        
            output_valid_o => s1_valid_to_s2,
            output_ready_i => s2_ready_to_s1,
            data_o         => s1_data_to_s2     
        );

        STAGE_2 : entity work.stage2
        port map (
            clk_i          => clk,
            reset_n_i      => rst_n,
            input_valid_i  => s1_valid_to_s2,
            input_ready_o  => s2_ready_to_s1,
            data_i         => s1_data_to_s2,
            output_valid_o => s2_valid_to_s3,
            output_ready_i => s3_ready_to_s2,
            data_o         => s2_data_to_s3
        );

    
    STAGE_3 : entity work.stage3
        port map (
            clk_i          => clk,
            reset_n_i      => rst_n,
            input_valid_i  => s2_valid_to_s3,
            input_ready_o  => s3_ready_to_s2,
            data_i         => s2_data_to_s3,
            output_valid_o => s3_valid_to_s4,
            output_ready_i => s4_ready_to_s3,
            data_o         => s3_data_to_s4
        );

    
    STAGE_4 : entity work.stage4
        port map (
            clk_i          => clk,
            reset_n_i      => rst_n,
            input_valid_i  => s3_valid_to_s4,
            input_ready_o  => s4_ready_to_s3,
            data_i         => s3_data_to_s4,
            output_valid_o => s4_valid_to_s5,
            output_ready_i => s5_ready_to_s4,
            data_o         => s4_data_to_s5
        );

        STAGE_5 : entity work.stage5
        port map (
            clk_i          => clk,
            reset_n_i      => rst_n,
            input_valid_i  => s4_valid_to_s5,
            input_ready_o  => s5_ready_to_s4,
            data_i         => s4_data_to_s5,
            output_valid_o => valid_o,          
            output_ready_i => ready_i,          
            result_o       => result_o,         
            flags_o        => flags_o           
        );

end architecture structural;