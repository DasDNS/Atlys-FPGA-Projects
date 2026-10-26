# Atlys FPGA Project 02: Button-Controlled LED

A beginner-friendly FPGA project using Verilog HDL and the Digilent Atlys development board. This project demonstrates how to read a push-button input and directly control an LED output using a continuous assignment.

## 1. Project Overview

The objective of this project is to control an LED using a physical push button connected to the FPGA.

When the button input is at logic HIGH (`1`), the LED output is assigned logic HIGH (`1`). When the button input is at logic LOW (`0`), the LED output is assigned logic LOW (`0`).

The relationship is:

| Button input (`btn`) | LED output (`led`) |
|---|---|
| `0` | `0` |
| `1` | `1` |

The actual visible ON/OFF behaviour depends on the board's electrical connections and signal polarity.

## 2. Hardware and Software

### Hardware

- **FPGA development board:** Digilent Atlys
- **FPGA device:** Xilinx Spartan-6 XC6SLX45
- **Input:** On-board push button connected to FPGA pin F5
- **Output:** On-board LED connected to FPGA pin U18

### Software

- Xilinx ISE Design Suite 14.7
- Verilog HDL
- Xilinx iMPACT for programming the FPGA

## 3. Project Files

The main source files are:

| File | Purpose |
|---|---|
| `button_led.v` | Verilog module that connects the button input to the LED output |
| `button_led.ucf` | User Constraints File that assigns FPGA pins and electrical standards |
| `button_led.bit` | Generated FPGA bitstream used to configure the FPGA |

*Note: The exact filenames may vary depending on the names used when creating the project in Xilinx ISE.*

## 4. Verilog HDL Source Code

```verilog
`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    10:38:24 10/14/2026
// Design Name:
// Module Name:    button_led
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//////////////////////////////////////////////////////////////////////////////////

module button_led(
    input btn,
    output led
);

    assign led = btn;

endmodule
```

## 5. Understanding the Verilog Code

### 5.1 The `timescale` directive

```verilog
`timescale 1ns / 1ps
```

This directive specifies the time unit and time precision used by Verilog simulation.

- `1ns`: The simulation time unit is one nanosecond.
- `1ps`: The simulation time precision is one picosecond.

This project contains no explicit delays, so the directive does not determine the button response speed. The actual response is affected by the FPGA's hardware propagation delay and the electrical behaviour of the button and LED circuits.

### 5.2 The module declaration

```verilog
module button_led(
    input btn,
    output led
);
```

The `module` keyword defines a hardware design block.

- `button_led`: The name of the module.
- `input btn`: An input port that receives the button's digital signal.
- `output led`: An output port that drives the LED signal.

The parentheses contain the module's port declarations. The semicolon after the closing parenthesis completes the module header.

Unlike the previous LED Blink project, this module does not require a clock input.

### 5.3 The continuous assignment

```verilog
assign led = btn;
```

This is the main statement in the project.

The `assign` keyword creates a **continuous assignment**. It continuously drives the left-hand signal, `led`, using the value of the right-hand signal, `btn`.

The relationship can be written as:

\[
led = btn
\]

Therefore:

- If `btn = 1`, then `led = 1`.
- If `btn = 0`, then `led = 0`.

In hardware, synthesis implements this relationship as a direct combinational signal path between the FPGA input and output logic. It does not require a software loop or a clocked process.

### 5.4 Why is `led` not declared as `reg`?

In this code, `led` is declared as:

```verilog
output led
```

This is valid Verilog because a continuous assignment traditionally drives a net, and an output port without an explicit data type defaults to a net type.

A declaration such as `output reg led` is typically used when a procedural block, such as an `always` block, assigns the output in Verilog. It is unnecessary for this design.

### 5.5 The `endmodule` keyword

```verilog
endmodule
```

This marks the end of the `button_led` module definition.

## 6. User Constraints File (UCF)

The UCF file maps the Verilog module's logical ports to physical pins on the FPGA.

```text
NET "btn" LOC = "F5" | IOSTANDARD = LVCMOS33;
NET "led" LOC = "U18" | IOSTANDARD = LVCMOS25;
```

### 6.1 Button pin assignment

```text
NET "btn" LOC = "F5" | IOSTANDARD = LVCMOS33;
```

- `NET "btn"` identifies the signal named `btn` in the Verilog module.
- `LOC = "F5"` assigns that signal to FPGA package pin F5.
- `IOSTANDARD = LVCMOS33` specifies the 3.3 V LVCMOS I/O standard for that signal.

### 6.2 LED pin assignment

```text
NET "led" LOC = "U18" | IOSTANDARD = LVCMOS25;
```

- `NET "led"` identifies the output signal named `led`.
- `LOC = "U18"` assigns it to FPGA package pin U18.
- `IOSTANDARD = LVCMOS25` specifies the 2.5 V LVCMOS I/O standard for that signal.

The I/O standards above are the settings used in this project's constraints. Ensure that they are compatible with the actual board connections and the Atlys board documentation.

## 7. How the Design Works on the FPGA

The design follows this signal path:

**Physical button → FPGA input pin F5 → `btn` signal → continuous assignment → `led` signal → FPGA output pin U18 → LED**

When the electrical signal at pin F5 changes, the FPGA input signal `btn` changes. The continuous assignment propagates that logic value to `led`, and the FPGA drives the corresponding output signal at U18.

There is no counter, memory, clock divider, or state machine in this design.

## 8. Building the Project in Xilinx ISE 14.7

1. Open Xilinx ISE Design Suite.
2. Create a new project named `Atlys_Button_LED`.
3. Select the Spartan-6 device settings appropriate for the Atlys board: `XC6SLX45`, package `CSG324`, speed grade `-3`.
4. Add a Verilog source file named `button_led.v`.
5. Enter the Verilog code provided above.
6. Add a UCF constraints file named `button_led.ucf`.
7. Enter the two pin constraints.
8. Run **Synthesize - XST**.
9. Run **Implement Design**.
10. Run **Generate Programming File** to create the `.bit` bitstream.

Check the synthesis and implementation reports for errors before programming the FPGA.

## 9. Programming and Testing

1. Connect the Atlys board to your computer using the appropriate JTAG programming connection.
2. Power on the board.
3. Open Xilinx iMPACT.
4. Select **Boundary Scan** and initialize the JTAG chain.
5. Assign the generated `.bit` file to the detected FPGA.
6. Program the FPGA.
7. Press and release the physical button.
8. Observe whether the LED follows the button input.

The LED should follow the logic level of the button input. Verify the board's button polarity and LED electrical behaviour if the visible response is opposite to what you expect.

The FPGA configuration is generally volatile, so the design may need to be programmed again after the board is powered off unless a suitable non-volatile configuration method is used.

## 10. Concepts Demonstrated

This project introduces several important FPGA and digital design concepts:

- Verilog module declarations
- Input and output ports
- Continuous assignments using `assign`
- Combinational logic
- FPGA package pin assignments
- I/O electrical standards in a UCF file
- Synthesis and FPGA implementation
- Bitstream generation and JTAG programming
- The relationship between logical signals and physical hardware

## 11. Learning Outcome

This project demonstrates how a simple Verilog description can represent real digital hardware. The `assign` statement describes a continuous relationship between two signals, while the UCF file connects those logical signals to physical FPGA pins.

It is a useful first step toward understanding combinational logic before progressing to clocked circuits, counters, finite-state machines, and more advanced FPGA designs.

