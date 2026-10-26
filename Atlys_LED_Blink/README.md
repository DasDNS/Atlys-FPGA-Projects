# Project 01 — LED Blink on Digilent Atlys FPGA

## 1. Overview

This project implements a blinking LED using Verilog HDL on the **Digilent Atlys development board**, which features a Xilinx Spartan-6 XC6SLX45 FPGA.

The design uses the board's 100 MHz clock to drive a counter. When the counter reaches a predefined value, the LED output toggles between HIGH and LOW.

This is an introductory FPGA project that demonstrates clocked logic, counters, registers, non-blocking assignments, FPGA pin constraints, and timing constraints.

## 2. Hardware and Tools

- **FPGA board:** Digilent Atlys
- **FPGA device:** Xilinx Spartan-6 XC6SLX45
- **HDL:** Verilog
- **Development environment:** Xilinx ISE Design Suite 14.7
- **Programming tool:** iMPACT
- **Programming interface:** JTAG
- **Clock frequency:** 100 MHz (10 ns period)

## 3. Project Files

| File | Purpose |
|---|---|
| `led_blink.v` | Verilog source code describing the LED blinking circuit |
| `led_blink.ucf` | Pin assignments and clock timing constraints |
| `Atlys_LED_Blink.xise` | Xilinx ISE project file |
| `led_blink.bit` | Generated FPGA configuration bitstream, if retained |

The `.v` file describes the circuit. The `.ucf` file maps the circuit's top-level signals to physical FPGA pins and specifies the clock timing requirement.

## 4. Hardware Connections

| Signal | FPGA package pin | Purpose |
|---|---|---|
| `clk` | `L15` | 100 MHz board clock input |
| `led` | `U18` | LED output |

The clock pin assignment and LED pin assignment are defined in the UCF file.

## 5. Verilog Source Code

```verilog
`timescale 1ns / 1ps

module led_blink (
    input  wire clk,
    output reg  led = 1'b0
);

    reg [25:0] counter = 26'd0;

    always @(posedge clk) begin
        if (counter == 26'd49_999_999) begin
            counter <= 26'd0;
            led <= ~led;
        end else begin
            counter <= counter + 1'b1;
        end
    end

endmodule
```

## 6. Understanding the Verilog Code

### 6.1 The timescale directive

```verilog
`timescale 1ns / 1ps
```

This directive specifies the time unit and time precision used by simulation:

- `1ns` — the simulation time unit is one nanosecond.
- `1ps` — the simulation time precision is one picosecond.

It does not configure the physical FPGA clock or make the circuit operate at a particular frequency.

### 6.2 The module declaration

```verilog
module led_blink (
    input  wire clk,
    output reg  led = 1'b0
);
```

- `module led_blink` defines a hardware block named `led_blink`.
- `input wire clk` declares the one-bit clock input.
- `output reg led = 1'b0` declares the LED output and initializes it to logic `0`.

The `reg` type allows `led` to be assigned inside a procedural `always` block. In Verilog, `reg` does not automatically mean that the signal must become a physical register; the logic describing how it is assigned determines the hardware.

The initial value means the LED signal starts at logic LOW where the FPGA tool and device support this initialization. On the board, the visible LED behaviour also depends on the board's LED wiring and polarity.

### 6.3 The counter declaration

```verilog
reg [25:0] counter = 26'd0;
```

This declares a 26-bit register named `counter`, initially set to zero.

- `[25:0]` means the register contains 26 bits, numbered from bit 25 down to bit 0.
- `26'd0` means the decimal value zero represented using a 26-bit value.
- The counter stores its current count between clock edges.

A 26-bit unsigned counter can represent values from 0 to 67,108,863, which is enough to count to 49,999,999.

### 6.4 The clocked always block

```verilog
always @(posedge clk) begin
```

This block runs on every rising edge of `clk`.

A rising edge is a transition from logic LOW (`0`) to logic HIGH (`1`). At 100 MHz, rising edges occur every 10 nanoseconds.

The FPGA implements this behaviour using clocked digital hardware, such as flip-flops, rather than executing the block like a software loop.

### 6.5 Checking the terminal count

```verilog
if (counter == 26'd49_999_999) begin
```

This checks whether the counter has reached 49,999,999.

The underscore in `49_999_999` is only a readability separator. Verilog ignores it when interpreting the number.

The counter begins at zero and increases once per rising clock edge. When the old counter value equals the terminal count, the design resets the counter and toggles the LED.

### 6.6 Resetting the counter and toggling the LED

```verilog
counter <= 26'd0;
led <= ~led;
```

- `counter <= 26'd0;` schedules the counter to return to zero.
- `led <= ~led;` schedules the LED signal to take the opposite of its current value.
- `~` is the bitwise NOT operator.

Therefore:

- If `led` is `0`, it changes to `1`.
- If `led` is `1`, it changes to `0`.

The LED changes state once every 50,000,000 clock cycles.

### 6.7 Incrementing the counter

```verilog
end else begin
    counter <= counter + 1'b1;
end
```

If the counter has not reached the terminal count, it increments by one.

`1'b1` represents the one-bit binary value `1`.

The `<=` operator is a **non-blocking assignment**, conventionally used for clocked sequential logic. The right-hand sides are evaluated using the values before the non-blocking updates take effect at the end of the current simulation time step.

This is important: the `if` condition checks the counter's current value, not a value that has already been incremented in the same block.

### 6.8 End of the module

```verilog
endmodule
```

This keyword ends the `led_blink` module definition.

## 7. How the LED Blink Timing Works

The Atlys board clock is assumed to be 100 MHz:

\[
T_{\text{clock}} = \frac{1}{100\,000\,000} = 10\text{ ns}
\]

The counter reaches its terminal value after 50,000,000 clock cycles, counting from zero through 49,999,999.

The time between LED transitions is therefore:

\[
T_{\text{toggle}} =
\frac{50\,000\,000}{100\,000\,000}
= 0.5\text{ s}
\]

The LED toggles every **0.5 seconds**.

A complete blink cycle consists of one LOW-to-HIGH transition and one HIGH-to-LOW transition:

\[
T_{\text{blink}} = 2 \times 0.5 = 1\text{ s}
\]

Therefore, the expected blink frequency is:

\[
f_{\text{blink}} = \frac{1}{1\text{ s}} = 1\text{ Hz}
\]

Expected behaviour:

- LED initially starts at logic LOW.
- After approximately 0.5 seconds, the LED signal changes state.
- After another 0.5 seconds, it changes state again.
- The sequence repeats continuously while the FPGA remains configured and clocked.

## 8. UCF Constraints File

```text
NET "clk" LOC = "L15" | IOSTANDARD = LVCMOS33;
NET "clk" TNM_NET = "sys_clk_pin";
TIMESPEC "TS_sys_clk_pin" = PERIOD "sys_clk_pin" 10 ns HIGH 50%;
NET "led" LOC = "U18" | IOSTANDARD = LVCMOS25;
```

### 8.1 Clock pin assignment

```text
NET "clk" LOC = "L15" | IOSTANDARD = LVCMOS33;
```

This maps the Verilog input `clk` to FPGA package pin `L15` and specifies its I/O standard as `LVCMOS33`.

### 8.2 Clock timing group

```text
NET "clk" TNM_NET = "sys_clk_pin";
```

This assigns the clock net to a timing group named `sys_clk_pin`. The timing group is referenced by the following timing constraint.

### 8.3 Clock period constraint

```text
TIMESPEC "TS_sys_clk_pin" = PERIOD "sys_clk_pin" 10 ns HIGH 50%;
```

This specifies a clock period of 10 ns with a 50% duty cycle.

- Period: 10 ns
- Frequency: 100 MHz
- HIGH portion of the clock period: 5 ns
- LOW portion of the clock period: 5 ns

This constraint tells the implementation tools the intended clock timing. It does not generate the clock; the board's physical oscillator supplies it.

### 8.4 LED pin assignment

```text
NET "led" LOC = "U18" | IOSTANDARD = LVCMOS25;
```

This maps the Verilog output `led` to FPGA package pin `U18` and specifies the `LVCMOS25` I/O standard.

Use the I/O standard provided by the official constraints for the exact Atlys board revision. Do not change it simply to remove a warning.

## 9. Build and Program the FPGA

1. Open Xilinx ISE Design Suite 14.7.
2. Open `Atlys_LED_Blink.xise`.
3. Confirm that `led_blink` is the top-level module.
4. Check that `led_blink.ucf` is included in the project.
5. Run **Synthesize - XST**.
6. Run **Implement Design**.
7. Run **Generate Programming File** to generate `led_blink.bit`.
8. Open iMPACT and select Boundary-Scan (JTAG).
9. Initialize the JTAG chain and identify the Spartan-6 FPGA.
10. Assign `led_blink.bit` to the FPGA and program it.
11. Observe LED `U18` and verify that it changes state approximately every half-second.

A bitstream loaded over JTAG is normally volatile: the FPGA must be programmed again after power is removed unless non-volatile configuration memory is programmed separately.

## 10. What This Project Demonstrates

- Creating a Verilog module with input and output ports.
- Declaring registers and vectors.
- Using `always @(posedge clk)` for clocked logic.
- Using an `if/else` condition in sequential logic.
- Incrementing and resetting a counter.
- Using non-blocking assignments (`<=`).
- Toggling a signal using bitwise NOT (`~`).
- Mapping logical signals to FPGA pins through a UCF file.
- Specifying clock timing requirements.
- Synthesizing, implementing, generating a bitstream, and programming a physical FPGA.

## 11. Notes

This project is intended for educational purposes. Pin assignments and I/O standards should be checked against the official reference constraints for the specific Atlys board revision.
