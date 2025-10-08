# RISC-V FPGA Microcoded Function Unit

This repository contains the hardware design for a **microcoded function unit**, likely an **Arithmetic Logic Unit (ALU)**, implemented as part of a **RISC-V** processor on an **FPGA**.

---

## Project Details

* **Target Hardware:** **Intel Altera FPGA Board**.
* **Design Tools:** **Quartus** (Used for synthesis, fitting, and programming).
* **Purpose:** To provide a set of essential **arithmetic and logic operations** controlled by a unique **microcode word**.

---

## Microcode Specification

The function unit is controlled by a microcode signal, defining the following core operations:

|Function#| Microcode         | Boolean Operation / Function |
| :---:   | :---: | :---:     |
| 1       | `...000000000001` | **sum**($A, B$) |
| 2       | `...000000000010` | **diff**($A, B$) |
| 3       | `...000000000100` | $\overline{A}$ (NOT A) |
| 4       | `...000000001000` | $A \cdot \overline{B}$ |
| 5       | `...000000010000` | $\overline{A + B}$ (NOR) |
| 6       | `...000000100000` | $A \cdot B$ (AND) |
| 7       | `...000001000000` | $A \oplus B$ (XOR) |
| 8       | `...000010000000` | $A + B$ (OR) |
| 9       | `...000100000000` | $\overline{A \oplus B}$ (XNOR) |

---

## Build and Implementation

1.  Open the project in **Quartus Prime**.
2.  Compile and synthesize the VHDL. 
3.  Program the Intel Altera FPGA board using the Quartus Programmer tool.