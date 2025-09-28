# Digital Audio Synthesizer Core (440 Hz Tone Generator)

## Project Overview

This project implements a fundamental Digital Audio Synthesizer Core entirely in VHDL, synthesized onto an Altera Cyclone IV E Field-Programmable Gate Array (FPGA). The core functionality is to act as a Numerically Controlled Oscillator (NCO) to generate a precise, fixed-frequency square wave output that can be connected to an external speaker or amplifier circuit.

This is the initial stage of a full synthesizer, demonstrating proficiency in digital signal generation and timing control using hardware description languages.

## Key Features

* **Fixed-Frequency Tone Generation:** Generates a precise 440 Hz (A4 note) square wave, demonstrating fundamental digital frequency division.
* **VHDL Implementation:** Logic implemented using concurrent and sequential VHDL processes, utilizing integer arithmetic for clock cycle counting.
* **Clock Domain Management:** Utilizes a 50 MHz input clock (CLK) to accurately derive the target 440 Hz frequency signal.
* **Fully Synthesizable:** Code is optimized for efficient resource utilization on the target FPGA fabric.
* **High-Resolution Timing:** Achieves accurate audio frequency generation limited only by the master clock frequency.

## Architecture and Implementation Details

The core logic uses a single counter, running on the 50 MHz system clock, to determine the duration of the high and low states of the square wave.

The half-period count (N) is calculated as:

```
N = Clock Frequency / (2 × Tone Frequency) = 50,000,000 / (2 × 440) = 56,818 clock cycles
```

The VHDL counter increments every clock cycle. When the counter reaches 56,818, it resets to zero and toggles the `square` signal, thereby creating the 440 Hz square wave output.

## Hardware and Pin Assignments

| Component | Signal Name | Type | Target Pin | FPGA Board |
|-----------|-------------|------|------------|------------|
| System Clock (Input) | `clk` | `std_logic` | PIN_23 | Cyclone IV E: EP4CE6E22C8 |
| Audio Output (Square Wave) | `pwm_out` | `std_logic` | PIN_43 | Cyclone IV E: EP4CE6E22C8 |

## Next Steps and Future Expansion

The project is designed for scalability and can be extended to a full instrument by adding the following modules:

1. **Variable Frequency Control:** Implement external inputs (buttons/switches) to dynamically update the tone frequency, enabling multiple musical notes.

2. **Pulse Width Modulation (PWM):** Convert the output to a true PWM signal to control the duty cycle, thereby allowing for digital volume control (acting as a Voltage-Controlled Amplifier (VCA) equivalent).

3. **Digital-to-Analog Conversion (DAC):** Integrate an R-2R resistor ladder or an external DAC to convert the digital output to a continuous analog audio signal for higher fidelity.

4. **Envelope Generator (EG):** Implement ADSR (Attack, Decay, Sustain, Release) control to shape the volume over time, essential for realistic musical sounds.