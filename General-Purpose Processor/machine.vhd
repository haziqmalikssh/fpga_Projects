LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity machine IS
    port (
        data_in, clk, reset : in std_logic;
        student_id          : out std_logic_vector(3 downto 0);
        current_state       : out std_logic_vector(2 downto 0)
    );
end machine;

architecture fsm of machine is
    type state_type is (s0, s1, s2, s3, s4, s5, s6, s7);
    signal yfsm : state_type;
begin
    process (clk, reset)
    begin
        if reset = '1' then
            yfsm <= s0;
        elsif (clk'event and clk = '1') then
            case yfsm is
                when s0 => 
                    yfsm <= s1;
                when s1 => 
                    yfsm <= s2;
                when s2 => 
                    yfsm <= s3;
                when s3 => 
                    yfsm <= s4;
                when s4 => 
                    yfsm <= s5;
                when s5 => 
                    yfsm <= s6;
                when s6 => 
                    yfsm <= s7;
                when s7 => 
                    yfsm <= s0;
                when others =>
                    yfsm <= s0;
            end case;
        end if;
    end process;

    process (yfsm)
    begin
        case yfsm is
            when s0 => 
                current_state <= "000";
                student_id <= "0000";
            when s1 => 
                current_state <= "001";
                student_id <= "0001"; 
            when s2 => 
                current_state <= "010";
                student_id <= "0010"; 
            when s3 => 
                current_state <= "011";
                student_id <= "0110";
            when s4 => 
                current_state <= "100";
                student_id <= "0000"; 
            when s5 => 
                current_state <= "101";
                student_id <= "0011";
            when s6 => 
                current_state <= "110";
                student_id <= "0101";
            when s7 => 
                current_state <= "111";
                student_id <= "0000";
            when others =>
                current_state <= "000";
                student_id <= "0101";
        end case;
    end process;
end fsm;