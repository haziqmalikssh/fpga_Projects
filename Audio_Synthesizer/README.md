# FPGA Audio Synthesizer

A digital synthesizer with multiple waveforms, filter, envelope, and effects controlled by 4 buttons using a click-count system.

## Demo

[![Demo Video](https://img.youtube.com/vi/WbtO7lYJ_3s/0.jpg)](https://youtube.com/shorts/WbtO7lYJ_3s)

## How It Works

**Click buttons to change settings, then press any button to play the configured sound.**

### Button Controls

| Button | Function | Options |
|--------|----------|---------|
| **KEY1** | Note Selection | C4→D4→E4→F4→G4→A4→B4→C5 (8 notes) | 
| **KEY2** | Waveform | Saw→Square→Triangle→Sine (4 types) | led2 |
| **KEY3** | Filter Cutoff | Bright→Medium→Dark→Muffled (4 levels) | 
| **KEY4** | Effects | None→Vibrato→Slow Attack→Tremolo (4 modes) | 

Each button cycles through its options on each click. LEDs indicate setting (ON when count ≥ 2 or 4).

## Usage Example

1. Click KEY1 twice → Select E4 note
2. Click KEY2 once → Sawtooth waveform  
3. Click KEY3 once → Bright filter
4. Click KEY4 twice → Add vibrato
5. Press and hold any button → Plays E4 with vibrato and smooth envelope

## Architecture

```
Oscillator (DDS) → Filter (LPF) → Envelope (ADSR) → PWM Output
                      ↓
                    LFO (for effects)
```

- **Oscillator**: 32-bit DDS generates precise frequencies
- **Filter**: Variable low-pass filter for tone control
- **Envelope**: ADSR (Attack-Decay-Sustain-Release) for smooth note shaping
- **LFO**: 5Hz modulation for vibrato/tremolo effects
- **Output**: 16-bit PWM to buzzer (pin 110)

## Pin Map

| Signal | Pin | Signal | Pin |
|--------|-----|--------|-----|
| FPGA_CLK | 23 | KEY1 | 88 |
| RESET | 25 | KEY2 | 89 |
| beep | 110 | KEY3 | 90 |
| led1 | 87 | KEY4 | 91 |
| led2 | 86 | led3 | 85 |
| led4 | 84 | - | - |

All buttons and RESET are active-low. 50ms debounce on all inputs.