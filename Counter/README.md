# FPGA 4-Digit Decimal Counter

![Demo](https://img.youtube.com/vi/xFDzwvmDq7Q/0.jpg)

A simple VHDL implementation of an auto-incrementing 4-digit decimal counter (0000 → 9999) displayed on a 7-segment display using multiplexing.

## Features
- Counts from **0000 to 9999** with automatic rollover
- Digit refresh rate: ~380 Hz (flicker-free)
- Increment interval: ~0.33 seconds
- Active-low common-anode 7-segment drive
- Synchronous reset (active-low)

## Target Platform
- FPGA with 50 MHz clock (e.g., DE10-Lite, Basys 3, Nexys A7)
- 4-digit 7-segment display (common-anode)

## Demo
[![Watch Demo](https://img.youtube.com/vi/xFDzwvmDq7Q/0.jpg)](https://youtube.com/shorts/xFDzwvmDq7Q)

▶️ [Click to watch the counter in action](https://youtube.com/shorts/xFDzwvmDq7Q)