library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tone_gen is
  port (
    clk   : in  std_logic; -- e.g., 50 MHz
    pwm_out : out std_logic
  );
end entity;

architecture rtl of tone_gen is
  constant CLOCK_FREQ : integer := 50000000;  -- 50 MHz
  constant TONE_FREQ  : integer := 440;       -- 440 Hz (A4)
  constant HALF_PERIOD : integer := CLOCK_FREQ / (2 * TONE_FREQ);

  signal counter : integer range 0 to HALF_PERIOD := 0;
  signal square  : std_logic := '0';
begin

  process(clk)
  begin
    if rising_edge(clk) then
      if counter = HALF_PERIOD then
        counter <= 0;
        square <= not square; -- toggle to make square wave
      else
        counter <= counter + 1;
      end if;
    end if;
  end process;

  pwm_out <= square;

end architecture;
