--Memoria ROM
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lut_rom is 
    port (
        indirizzo: in std_logic_vector(4 downto 0);
        dato: out std_logic_vector(31 downto 0)
    );
end entity lut_rom;

architecture behavior of lut_rom is
    type t_rom is array (0 to 31) of std_logic_vector(31 downto 0);
    constant rom_data: t_rom := (
        0=>x"01000000",
        1=>x"01059B0D", 
        2=>x"010B5587", 
        3=>x"0111301D", 
        4=>x"01172B84", 
        5=>x"011D4873", 
        6=>x"012387A7", 
        7=>x"0129E9DF", 
        8=>x"01306FE1", 
        9=>x"01371A73", 
        10=>x"013DEA65",
        11=>x"0144E086", 
        12=>x"014BFDAD", 
        13=>x"015342B5", 
        14=>x"015AB07E", 
        15=>x"016247EB", 
        16=>x"016A09E6", 
        17=>x"0171F75F", 
        18=>x"017A1147", 
        19=>x"0182589A", 
        20=>x"018ACE54",
        21=>x"0193737B", 
        22=>x"019C4918", 
        23=>x"01A5503B", 
        24=>x"01AE89FA", 
        25=>x"01B7F76F", 
        26=>x"01C199BE", 
        27=>x"01CB720E", 
        28=>x"01D5818E", 
        29=>x"01DFC973", 
        30=>x"01EA4AFA", 
        31=>x"01F50766"  
    );
    begin
        dato <= rom_data(to_integer(unsigned(indirizzo)));
    end architecture behavior;
