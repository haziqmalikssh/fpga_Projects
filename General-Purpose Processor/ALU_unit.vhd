LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;

entity ALU_unit is 
    port ( 
        clk, res : in std_logic;                   
        sign1, sign2 : out std_logic;
          Reg1, Reg2 : in std_logic_vector(7 downto 0); 
        opcode : in std_logic_vector(7 downto 0);     
        Result : out std_logic_vector(7 downto 0)     
    );
end ALU_unit;

architecture calculation of ALU_unit is
signal Result1:STD_LOGIC_VECTOR(7DOWNTO 0);
begin
    process (clk, res)
    begin
        if res = '1' then
            Result <= "00000000"; 
        elsif (clk'EVENT AND clk = '1') then
            case opcode is
                when "00000001" => 
                    Result <= Reg1 + Reg2;
                when "00000010" => 
                    Result <= Reg1 - Reg2;
                when "00000100" => 
                    Result <= not Reg1;
                when "00001000" => 
                    Result <= not (Reg1 and Reg2); 
                when "00010000" => 
                    Result <= not (Reg1 or Reg2);
                when "00100000" => 
                    Result <= Reg1 and Reg2;
                when "01000000" => 
                    Result <= Reg1 xor Reg2;
                when "10000000" => 
                    Result <= Reg1 or Reg2; 
                when others => 
                    Result <= "00000000"; 
                end case;
        end if; 
    end process;
end calculation;