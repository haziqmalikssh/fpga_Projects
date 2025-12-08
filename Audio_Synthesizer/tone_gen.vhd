library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tone_gen is
  port (
    FPGA_CLK : in  std_logic;  -- 50 MHz clock (pin 23)
    RESET    : in  std_logic;  -- Reset button (pin 25)
    KEY1     : in  std_logic;  -- Multi-function: Note selection (pin 88)
    KEY2     : in  std_logic;  -- Multi-function: Waveform selection (pin 89)
    KEY3     : in  std_logic;  -- Multi-function: Filter control (pin 90)
    KEY4     : in  std_logic;  -- Multi-function: Effect control (pin 91)
    beep     : out std_logic;  -- Buzzer output (pin 110)
    led1     : out std_logic;  -- Note indicator (pin 87)
    led2     : out std_logic;  -- Waveform indicator (pin 86)
    led3     : out std_logic;  -- Filter indicator (pin 85)
    led4     : out std_logic   -- Effect indicator (pin 84)
  );
end entity;

architecture rtl of tone_gen is
  -- Clock frequency
  constant CLOCK_FREQ : integer := 50000000;
  
  -- Note frequencies for 8 notes (C, D, E, F, G, A, B, C_high)
  type freq_array is array (0 to 7) of integer;
  constant NOTE_FREQS : freq_array := (262, 294, 330, 349, 392, 440, 494, 523);
  
  -- Phase accumulator for DDS
  constant PHASE_BITS : integer := 32;
  signal phase_acc : unsigned(PHASE_BITS-1 downto 0) := (others => '0');
  signal phase_inc : unsigned(PHASE_BITS-1 downto 0) := (others => '0');
  signal base_phase_inc : unsigned(PHASE_BITS-1 downto 0) := (others => '0');
  
  -- Click counters for each key
  signal key1_clicks : integer range 0 to 7 := 0;
  signal key2_clicks : integer range 0 to 3 := 0;
  signal key3_clicks : integer range 0 to 3 := 0;
  signal key4_clicks : integer range 0 to 3 := 0;
  
  -- Key state tracking
  signal key1_last : std_logic := '1';
  signal key2_last : std_logic := '1';
  signal key3_last : std_logic := '1';
  signal key4_last : std_logic := '1';
  
  -- Debounce
  signal debounce_cnt : integer range 0 to 2500000 := 0;
  signal keys_stable : std_logic_vector(3 downto 0) := "1111";
  
  -- LFO for vibrato/tremolo
  signal lfo_phase : unsigned(23 downto 0) := (others => '0');
  signal lfo_inc : unsigned(23 downto 0) := to_unsigned(335544, 24);
  signal lfo_value : signed(15 downto 0) := (others => '0');
  
  -- Envelope generator
  constant ENV_BITS : integer := 16;
  signal envelope : unsigned(ENV_BITS-1 downto 0) := (others => '0');
  signal attack_rate : unsigned(ENV_BITS-1 downto 0) := to_unsigned(8192, ENV_BITS);
  constant DECAY_RATE : unsigned(ENV_BITS-1 downto 0) := to_unsigned(2048, ENV_BITS);
  constant SUSTAIN_LEVEL : unsigned(ENV_BITS-1 downto 0) := to_unsigned(40960, ENV_BITS);
  constant RELEASE_RATE : unsigned(ENV_BITS-1 downto 0) := to_unsigned(1024, ENV_BITS);
  
  type env_state_t is (IDLE, ATTACK, DECAY, SUSTAIN, RELEASE);
  signal env_state : env_state_t := IDLE;
  
  -- Note playing trigger
  signal note_trigger : std_logic := '0';
  signal any_key_pressed : std_logic := '0';
  signal any_key_last : std_logic := '0';
  
  -- Waveform generation
  signal waveform_sel : integer range 0 to 3 := 0;
  signal waveform : signed(15 downto 0) := (others => '0');
  signal raw_waveform : signed(15 downto 0) := (others => '0');
  
  -- Filter
  signal filter_output : signed(15 downto 0) := (others => '0');
  signal filter_accum : signed(23 downto 0) := (others => '0');
  signal filter_coeff : unsigned(7 downto 0) := to_unsigned(128, 8);
  
  -- PWM
  signal pwm_counter : unsigned(15 downto 0) := (others => '0');
  signal amplitude : signed(15 downto 0) := (others => '0');
  
  -- Effect settings
  signal effect_mode : integer range 0 to 3 := 0;
  
begin

  process(FPGA_CLK, RESET)
    variable temp_mult : signed(32 downto 0);
    variable filtered : signed(23 downto 0);
    variable phase_mod : signed(31 downto 0);
  begin
    if RESET = '0' then
      phase_acc <= (others => '0');
      envelope <= (others => '0');
      env_state <= IDLE;
      key1_clicks <= 0;
      key2_clicks <= 0;
      key3_clicks <= 0;
      key4_clicks <= 0;
      key1_last <= '1';
      key2_last <= '1';
      key3_last <= '1';
      key4_last <= '1';
      debounce_cnt <= 0;
      filter_accum <= (others => '0');
      lfo_phase <= (others => '0');
      
    elsif rising_edge(FPGA_CLK) then
      
      -- Debounce keys
      if debounce_cnt < 2500000 then
        debounce_cnt <= debounce_cnt + 1;
      else
        debounce_cnt <= 0;
        keys_stable <= KEY1 & KEY2 & KEY3 & KEY4;
      end if;
      
      -- Detect KEY1 click (note selection)
      if keys_stable(3) = '0' and key1_last = '1' then
        if key1_clicks = 7 then
          key1_clicks <= 0;
        else
          key1_clicks <= key1_clicks + 1;
        end if;
      end if;
      key1_last <= keys_stable(3);
      
      -- Detect KEY2 click (waveform selection)
      if keys_stable(2) = '0' and key2_last = '1' then
        if key2_clicks = 3 then
          key2_clicks <= 0;
        else
          key2_clicks <= key2_clicks + 1;
        end if;
      end if;
      key2_last <= keys_stable(2);
      waveform_sel <= key2_clicks;
      
      -- Detect KEY3 click (filter cutoff)
      if keys_stable(1) = '0' and key3_last = '1' then
        if key3_clicks = 3 then
          key3_clicks <= 0;
        else
          key3_clicks <= key3_clicks + 1;
        end if;
      end if;
      key3_last <= keys_stable(1);
      
      -- Update filter based on click count
      if key3_clicks = 0 then
        filter_coeff <= to_unsigned(200, 8);
      elsif key3_clicks = 1 then
        filter_coeff <= to_unsigned(128, 8);
      elsif key3_clicks = 2 then
        filter_coeff <= to_unsigned(64, 8);
      else
        filter_coeff <= to_unsigned(32, 8);
      end if;
      
      -- Detect KEY4 click (effects)
      if keys_stable(0) = '0' and key4_last = '1' then
        if key4_clicks = 3 then
          key4_clicks <= 0;
        else
          key4_clicks <= key4_clicks + 1;
        end if;
      end if;
      key4_last <= keys_stable(0);
      effect_mode <= key4_clicks;
      
      -- Update LED indicators
      if key1_clicks >= 4 then
        led1 <= '1';
      else
        led1 <= '0';
      end if;
      
      if key2_clicks >= 2 then
        led2 <= '1';
      else
        led2 <= '0';
      end if;
      
      if key3_clicks >= 2 then
        led3 <= '1';
      else
        led3 <= '0';
      end if;
      
      if key4_clicks >= 2 then
        led4 <= '1';
      else
        led4 <= '0';
      end if;
      
      -- Detect any key press for note trigger
      any_key_pressed <= '0';
      if keys_stable /= "1111" then
        any_key_pressed <= '1';
      end if;
      
      note_trigger <= '0';
      if any_key_pressed = '1' and any_key_last = '0' then
        note_trigger <= '1';
      end if;
      any_key_last <= any_key_pressed;
      
      -- Calculate phase increment based on selected note
      if key1_clicks = 0 then
        base_phase_inc <= to_unsigned((NOTE_FREQS(0) * 85899), PHASE_BITS);
      elsif key1_clicks = 1 then
        base_phase_inc <= to_unsigned((NOTE_FREQS(1) * 85899), PHASE_BITS);
      elsif key1_clicks = 2 then
        base_phase_inc <= to_unsigned((NOTE_FREQS(2) * 85899), PHASE_BITS);
      elsif key1_clicks = 3 then
        base_phase_inc <= to_unsigned((NOTE_FREQS(3) * 85899), PHASE_BITS);
      elsif key1_clicks = 4 then
        base_phase_inc <= to_unsigned((NOTE_FREQS(4) * 85899), PHASE_BITS);
      elsif key1_clicks = 5 then
        base_phase_inc <= to_unsigned((NOTE_FREQS(5) * 85899), PHASE_BITS);
      elsif key1_clicks = 6 then
        base_phase_inc <= to_unsigned((NOTE_FREQS(6) * 85899), PHASE_BITS);
      else
        base_phase_inc <= to_unsigned((NOTE_FREQS(7) * 85899), PHASE_BITS);
      end if;
      
      -- LFO generation
      lfo_phase <= lfo_phase + lfo_inc;
      lfo_value <= signed(lfo_phase(23 downto 8));
      
      -- Apply effects based on KEY4 clicks
      if effect_mode = 0 then
        phase_inc <= base_phase_inc;
        attack_rate <= to_unsigned(8192, ENV_BITS);
      elsif effect_mode = 1 then
        phase_mod := signed(base_phase_inc(31 downto 0)) + (lfo_value * 8);
        phase_inc <= unsigned(phase_mod);
        attack_rate <= to_unsigned(8192, ENV_BITS);
      elsif effect_mode = 2 then
        phase_inc <= base_phase_inc;
        attack_rate <= to_unsigned(2048, ENV_BITS);
      else
        phase_inc <= base_phase_inc;
        attack_rate <= to_unsigned(16384, ENV_BITS);
      end if;
      
      -- Phase accumulator
      phase_acc <= phase_acc + phase_inc;
      
      -- Generate waveforms
      if waveform_sel = 0 then
        raw_waveform <= signed(phase_acc(PHASE_BITS-1 downto PHASE_BITS-16));
      elsif waveform_sel = 1 then
        if phase_acc(PHASE_BITS-1) = '1' then
          raw_waveform <= to_signed(16384, 16);
        else
          raw_waveform <= to_signed(-16384, 16);
        end if;
      elsif waveform_sel = 2 then
        if phase_acc(PHASE_BITS-1) = '0' then
          raw_waveform <= shift_left(signed(phase_acc(PHASE_BITS-1 downto PHASE_BITS-16)), 1);
        else
          raw_waveform <= shift_left(signed(not phase_acc(PHASE_BITS-1 downto PHASE_BITS-16)), 1);
        end if;
      else
        if phase_acc(PHASE_BITS-1) = '0' then
          raw_waveform <= shift_left(signed(phase_acc(PHASE_BITS-1 downto PHASE_BITS-16)), 1);
        else
          raw_waveform <= shift_left(signed(not phase_acc(PHASE_BITS-1 downto PHASE_BITS-16)), 1);
        end if;
      end if;
      
      -- Low-pass filter
      filtered := filter_accum + resize(signed(raw_waveform) * signed('0' & filter_coeff), 24);
      filter_accum <= filtered - (filter_accum / 256);
      filter_output <= filter_accum(23 downto 8);
      waveform <= filter_output;
      
      -- ADSR Envelope
      if env_state = IDLE then
        envelope <= (others => '0');
        if note_trigger = '1' then
          env_state <= ATTACK;
        end if;
      elsif env_state = ATTACK then
        if envelope < 65535 then
          envelope <= envelope + attack_rate;
        else
          envelope <= to_unsigned(65535, ENV_BITS);
          env_state <= DECAY;
        end if;
        if any_key_pressed = '0' then
          env_state <= RELEASE;
        end if;
      elsif env_state = DECAY then
        if envelope > SUSTAIN_LEVEL then
          envelope <= envelope - DECAY_RATE;
        else
          env_state <= SUSTAIN;
        end if;
        if any_key_pressed = '0' then
          env_state <= RELEASE;
        end if;
      elsif env_state = SUSTAIN then
        envelope <= SUSTAIN_LEVEL;
        if any_key_pressed = '0' then
          env_state <= RELEASE;
        end if;
      else
        if envelope > RELEASE_RATE then
          envelope <= envelope - RELEASE_RATE;
        else
          envelope <= (others => '0');
          env_state <= IDLE;
        end if;
      end if;
      
      -- Apply envelope
      temp_mult := waveform * signed('0' & envelope);
      
      -- Apply tremolo effect if enabled
      if effect_mode = 3 then
        temp_mult := temp_mult + resize((temp_mult * lfo_value) / 32768, 33);
      end if;
      
      amplitude <= temp_mult(32 downto 17);
      
      -- PWM output
      pwm_counter <= pwm_counter + 1;
      if signed(pwm_counter) < amplitude then
        beep <= '1';
      else
        beep <= '0';
      end if;
      
    end if;
  end process;

end architecture;