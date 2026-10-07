library ieee;
use ieee.std_logic_1164.all;

package exp_pipeline_pkg is

    
    type stage1_out_t is record
        y_val    : std_logic_vector(63 downto 0); 
        flags    : std_logic_vector(5 downto 0);  
    end record;

    
    type stage2_out_t is record
        p_a      : std_logic_vector(63 downto 0); 
        yfrac    : std_logic_vector(31 downto 0); 
        val_lut  : std_logic_vector(31 downto 0); 
        yint     : std_logic_vector(7 downto 0);  
        flags    : std_logic_vector(5 downto 0);
    end record;

    
    type stage3_out_t is record
        p_c      : std_logic_vector(63 downto 0); 
        val_lut  : std_logic_vector(31 downto 0); 
        yint     : std_logic_vector(7 downto 0);  
        flags    : std_logic_vector(5 downto 0);
    end record;

   
    type stage4_out_t is record
        mantissa : std_logic_vector(31 downto 0); 
        yint     : std_logic_vector(7 downto 0);  
        flags    : std_logic_vector(5 downto 0);
    end record;

end package exp_pipeline_pkg;