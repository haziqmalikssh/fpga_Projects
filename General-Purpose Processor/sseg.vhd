LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

ENTITY sseg IS
PORT ( bcd : IN STD_LOGIC_VECTOR(3 DOWNTO 0) ;
sign : IN STD_LOGIC;
leds, ledn : OUT STD_LOGIC_VECTOR(0 TO 6) ) ;
END sseg ;

ARCHITECTURE Behavior OF sseg IS
BEGIN
PROCESS ( bcd, sign )

BEGIN
if (sign = '1') then
ledn <= NOT ("0000001");
end if;
IF (sign ='0') then
ledn <= NOT("0000000");
end if;



CASE bcd IS --abcdefg
WHEN "0000" =>leds <= NOT ("1111110"); --0-9 down
WHEN "0001" =>leds <= NOT ("0110000");
WHEN "0010" =>leds <= NOT ("1101101") ;
WHEN "0011" =>leds <= NOT ("1111001") ;
WHEN "0100" =>leds <= NOT ("0110011") ;
WHEN "0101" =>leds <= NOT ("1011011") ;
WHEN "0110" =>leds <= NOT ("1011111") ;
WHEN "0111" =>leds <= NOT ("1110000") ;
WHEN "1000" =>leds <= NOT ("1111111") ;
WHEN "1001" =>leds <= NOT ("1110011") ;

WHEN "1010" =>leds <= NOT("1110111") ; --A
WHEN "1011" =>leds <= NOT("0011111") ; --B
WHEN "1100" =>leds <= NOT("1001110") ; --C
WHEN "1101" =>leds <= NOT("0111101") ; --D
WHEN "1110" =>leds <= NOT("1001111") ; --E
WHEN "1111" =>leds <= NOT("1000111") ; --F
WHEN OTHERS =>leds <= NOT("-------") ;--System is off
END CASE ;
END PROCESS ;

END Behavior ;