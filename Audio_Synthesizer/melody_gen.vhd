library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tone_gen is
  port (
    FPGA_CLK : in  std_logic;  -- 50 MHz clock (pin 23)
    RESET    : in  std_logic;  -- Reset button (pin 25)
    KEY1     : in  std_logic;  -- Play button (pin 88)
    beep     : out std_logic;  -- Buzzer output (pin 110)
    led1     : out std_logic   -- Playing indicator (pin 87)
  );
end entity;

architecture rtl of tone_gen is
  
  constant CLOCK_FREQ : integer := 50000000;
  
  -- Note frequencies
  constant C4  : integer := 262;
  constant D4  : integer := 294;
  constant E4  : integer := 330;
  constant F4  : integer := 349;
  constant G4  : integer := 392;
  constant A4  : integer := 440;
  constant REST : integer := 1;  -- Very high "frequency" for silence
  
  -- Melody: "Twinkle Twinkle Little Star"
  type melody_array is array (0 to 41) of integer;
  constant MELODY : melody_array := (
    C4, C4, G4, G4, A4, A4, G4, REST,
    F4, F4, E4, E4, D4, D4, C4, REST,
    G4, G4, F4, F4, E4, E4, D4, REST,
    G4, G4, F4, F4, E4, E4, D4, REST,
    C4, C4, G4, G4, A4, A4, G4, REST,
    F4, F4
  );
  
  -- Note duration: 25,000,000 cycles = 0.5 seconds
  constant NOTE_LENGTH : integer := 25000000;
  
  signal note_index : integer range 0 to 42 := 0;
  signal note_timer : integer range 0 to 25000000 := 0;
  signal tone_counter : integer range 0 to 100000 := 0;
  signal half_period : integer range 0 to 100000 := 1;
  signal tone : std_logic := '0';
  
begin

  process(FPGA_CLK, RESET)
  begin
    if RESET = '0' then
      note_index <= 0;
      note_timer <= 0;
      tone_counter <= 0;
      tone <= '0';
      
    elsif rising_edge(FPGA_CLK) then
      
      -- Calculate half period for current note
      half_period <= CLOCK_FREQ / (2 * MELODY(note_index));
      
      -- Generate tone (same method as your working tone_gen)
      if tone_counter = half_period then
        tone_counter <= 0;
        tone <= not tone;
      else
        tone_counter <= tone_counter + 1;
      end if;
      
      -- Note duration timer
      if note_timer = NOTE_LENGTH then
        note_timer <= 0;
        tone_counter <= 0;
        
        if note_index = 41 then
          -- Loop back to start
          note_index <= 0;
        else
          note_index <= note_index + 1;
        end if;
      else
        note_timer <= note_timer + 1;
      end if;
      
    end if;
  end process;
  
  beep <= tone;
  led1 <= '1';

end architecture;