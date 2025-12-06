library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- 4-DIGIT DECIMAL COUNTER (0000 to 9999)
-- Counts up automatically, displays on 7-segment display
-- Based on the working Verilog example from your board

entity counter is
    port (
        clk     : in  std_logic;                      -- 50 MHz clock
        rst_n   : in  std_logic;                      -- Reset button (active-low)
        btn     : in  std_logic_vector(3 downto 0);   -- Not used in counter
        btn_op  : in  std_logic;                      -- Not used in counter
        an      : out std_logic_vector(3 downto 0);   -- Digit anodes (active-low)
        sseg    : out std_logic_vector(7 downto 0)    -- 7-segment display
    );
end entity;

architecture rtl of counter is
    -- Digit selection counter (for multiplexing)
    signal dig_counter : unsigned(23 downto 0) := (others=>'0');
    signal dig_sel     : std_logic_vector(1 downto 0);
    
    -- Decimal digit counters (0-9 for each digit)
    signal dec_counter0 : integer range 0 to 9 := 0;  -- Ones
    signal dec_counter1 : integer range 0 to 9 := 0;  -- Tens
    signal dec_counter2 : integer range 0 to 9 := 0;  -- Hundreds
    signal dec_counter3 : integer range 0 to 9 := 0;  -- Thousands
    
    -- 7-segment patterns (matching your board's encoding)
    type seg_array is array (0 to 9) of std_logic_vector(7 downto 0);
    constant SEG7 : seg_array := (
        "11000000",  -- 0
        "11111001",  -- 1
        "10100100",  -- 2
        "10110000",  -- 3
        "10011001",  -- 4
        "10010010",  -- 5
        "10000010",  -- 6
        "11111000",  -- 7
        "10000000",  -- 8
        "10010000"   -- 9
    );
    
    signal seg_write : std_logic_vector(7 downto 0);
    
begin
    
    -- Main counter process
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            -- Reset all counters
            dig_counter <= (others => '0');
            dec_counter0 <= 0;
            dec_counter1 <= 0;
            dec_counter2 <= 0;
            dec_counter3 <= 0;
            
        elsif rising_edge(clk) then
            -- Fast multiplexing counter (changes digit display)
            dig_counter <= dig_counter + 1;
            
            -- Slow counting (increment every ~0.335 seconds at 50MHz)
            -- When dig_counter wraps around to 0 (every 2^23 clocks)
            if dig_counter(23) = '1' and dig_counter(22 downto 0) = (22 downto 0 => '0') then
                -- Increment ones digit
                if dec_counter0 = 9 then
                    dec_counter0 <= 0;
                    -- Carry to tens
                    if dec_counter1 = 9 then
                        dec_counter1 <= 0;
                        -- Carry to hundreds
                        if dec_counter2 = 9 then
                            dec_counter2 <= 0;
                            -- Carry to thousands
                            if dec_counter3 = 9 then
                                dec_counter3 <= 0;
                            else
                                dec_counter3 <= dec_counter3 + 1;
                            end if;
                        else
                            dec_counter2 <= dec_counter2 + 1;
                        end if;
                    else
                        dec_counter1 <= dec_counter1 + 1;
                    end if;
                else
                    dec_counter0 <= dec_counter0 + 1;
                end if;
            end if;
        end if;
    end process;
    
    -- Select which digit to display (top 2 bits for multiplexing)
    dig_sel <= std_logic_vector(dig_counter(15 downto 14));
    
    -- Digit selection (active-LOW anodes)
    process(dig_sel)
    begin
        case dig_sel is
            when "00" => an <= "1110";  -- Digit 0 (ones - rightmost)
            when "01" => an <= "1101";  -- Digit 1 (tens)
            when "10" => an <= "1011";  -- Digit 2 (hundreds)
            when "11" => an <= "0111";  -- Digit 3 (thousands - leftmost)
            when others => an <= "1111";
        end case;
    end process;
    
    -- Select which digit's value to display
    process(dig_sel, dec_counter0, dec_counter1, dec_counter2, dec_counter3)
    begin
        case dig_sel is
            when "00" => 
                seg_write <= SEG7(dec_counter0);  -- Display ones
            when "01" => 
                seg_write <= SEG7(dec_counter1);  -- Display tens
            when "10" => 
                seg_write <= SEG7(dec_counter2);  -- Display hundreds
            when "11" => 
                seg_write <= SEG7(dec_counter3);  -- Display thousands
            when others => 
                seg_write <= "11111111";  -- All segments off
        end case;
    end process;
    
    -- Output segments
    sseg <= seg_write;
    
end rtl;