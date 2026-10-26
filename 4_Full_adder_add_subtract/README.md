# Atlys FPGA Project 04: 4-Bit Adder/Subtractor with Debounced Push Buttons

A beginner-friendly FPGA project using Verilog HDL and the Digilent Atlys development board. This project implements a selectable 4-bit binary adder/subtractor with two push buttons, clock-based button debouncing, and LED output.

## 1. Project Overview

The objective of this project is to perform addition or subtraction on two unsigned 4-bit binary numbers using the slide switches on the Atlys FPGA board.

The operation is selected using two physical push buttons:

- **ADD button:** Selects addition mode.
- **SUB button:** Selects subtraction mode.

The selected operation remains active until the other button is pressed.

### Inputs and outputs

- **Operand A:** Slide switches SW7–SW4.
- **Operand B:** Slide switches SW3–SW0.
- **ADD button:** F5.
- **SUB button:** F6.
- **Clock:** L15, assumed to be a 100 MHz clock.
- **Result:** LEDs LD4–LD0.
- **Unused LEDs:** LD7–LD5 are held LOW by the design.

The circuit uses a five-bit arithmetic result. Addition produces values from 0 to 30, while subtraction produces a five-bit result that can be interpreted as a two's-complement signed value.

## 2. Hardware and Software

### Hardware

- **FPGA development board:** Digilent Atlys
- **FPGA device:** Xilinx Spartan-6 XC6SLX45
- Eight slide switches
- Two push buttons
- Eight LEDs
- FPGA clock source

### Software

- Xilinx ISE Design Suite 14.7
- Verilog HDL
- Xilinx iMPACT for FPGA programming

## 3. Project Files

| File | Purpose |
|---|---|
| `full_adder_add_subtract.v` | Contains the `debounce_button` and `adder4` modules |
| `full_adder_add_subtract.ucf` | Assigns physical FPGA pins and I/O standards |
| `full_adder_add_subtract.bit` | Generated FPGA bitstream |

The exact filenames may differ depending on how the project was created in Xilinx ISE.

## 4. Verilog HDL Source Code

```verilog
`timescale 1ns / 1ps

module debounce_button #(
    parameter integer CLK_HZ = 100_000_000
)(
    input  wire clk,
    input  wire button_in,
    output reg  press_pulse = 1'b0
);

    reg sync_1 = 1'b0;
    reg sync_2 = 1'b0;

    reg stable_state = 1'b0;

    localparam integer DEBOUNCE_COUNT = CLK_HZ / 100;

    reg [19:0] counter = 0;

    always @(posedge clk) begin
        sync_1 <= button_in;
        sync_2 <= sync_1;

        press_pulse <= 1'b0;

        if (sync_2 == stable_state) begin
            counter <= 0;
        end
        else if (counter >= DEBOUNCE_COUNT - 1) begin
            counter <= 0;
            stable_state <= sync_2;

            if (sync_2 == 1'b1)
                press_pulse <= 1'b1;
        end
        else begin
            counter <= counter + 1'b1;
        end
    end

endmodule


module adder4 (
    input  wire       clk,
    input  wire [7:0] sw,
    input  wire       btn_add,
    input  wire       btn_sub,
    output wire [7:0] led
);

    wire [3:0] a;
    wire [3:0] b;

    wire add_press;
    wire sub_press;

    // 0 = ADD, 1 = SUBTRACT.
    reg sub_mode = 1'b0;

    assign a = sw[7:4];
    assign b = sw[3:0];

    debounce_button ADD_BUTTON (
        .clk(clk),
        .button_in(btn_add),
        .press_pulse(add_press)
    );

    debounce_button SUB_BUTTON (
        .clk(clk),
        .button_in(btn_sub),
        .press_pulse(sub_press)
    );

    always @(posedge clk) begin
        if (add_press)
            sub_mode <= 1'b0;
        else if (sub_press)
            sub_mode <= 1'b1;
    end

    wire [4:0] a_ext;
    wire [4:0] b_ext;
    wire [4:0] result;

    assign a_ext = {1'b0, a};
    assign b_ext = {1'b0, b};

    assign result = sub_mode
                  ? (a_ext - b_ext)
                  : (a_ext + b_ext);

    assign led[4:0] = result;
    assign led[7:5] = 3'b000;

endmodule
```

## 5. Understanding the Verilog Code

### 5.1 The `timescale` directive

```verilog
`timescale 1ns / 1ps
```

This sets the time unit and precision used in simulation.

- `1ns`: One simulation time unit is one nanosecond.
- `1ps`: The simulation time precision is one picosecond.

It does not establish the physical FPGA clock frequency. That depends on the board's clock source and the design's clock constraints.

### 5.2 The `debounce_button` module

```verilog
module debounce_button #(
    parameter integer CLK_HZ = 100_000_000
)(
    input  wire clk,
    input  wire button_in,
    output reg  press_pulse = 1'b0
);
```

This module filters short changes in a mechanical button signal and generates a pulse when a new stable press is detected.

- `CLK_HZ`: A parameter specifying the expected clock frequency, set to 100 MHz by default.
- `clk`: The clock input.
- `button_in`: The raw physical button signal.
- `press_pulse`: A one-clock-cycle event indicating a detected press.

The `#(...)` syntax declares module parameters. Parameters allow a design to be configured without rewriting the module's internal logic.

### 5.3 Synchronising the button input

```verilog
reg sync_1 = 1'b0;
reg sync_2 = 1'b0;
```

The button is an asynchronous input: it can change independently of the FPGA clock.

The clocked block samples it through two registers:

```verilog
sync_1 <= button_in;
sync_2 <= sync_1;
```

These registers form a two-stage synchroniser. This reduces the chance that metastability in the first register propagates into the rest of the synchronous design.

A synchroniser and a debounce filter solve different problems:

- **Synchronisation:** Helps safely transfer an asynchronous signal into a clock domain.
- **Debouncing:** Rejects rapid transitions caused by mechanical contact bounce.

Both are useful for physical push buttons.

### 5.4 Storing the stable button state

```verilog
reg stable_state = 1'b0;
```

This register stores the last accepted button state.

The circuit compares the synchronised input with this stored state. If they match, the counter is reset:

```verilog
if (sync_2 == stable_state) begin
    counter <= 0;
end
```

If they differ, the counter advances until the new state has remained different for the required interval.

### 5.5 Calculating the debounce interval

```verilog
localparam integer DEBOUNCE_COUNT = CLK_HZ / 100;
reg [19:0] counter = 0;
```

`localparam` defines a constant that cannot be overridden as a module parameter.

With a 100 MHz clock:

\[
\text{DEBOUNCE\_COUNT}
=\frac{100{,}000{,}000}{100}
=1{,}000{,}000
\]

A 100 MHz clock has a period of 10 ns, so one million clock cycles correspond to approximately 10 ms.

The counter is 20 bits wide, giving it a range from 0 to 1,048,575. This is sufficient for the default count of one million.

### 5.6 Accepting a stable button change

```verilog
else if (counter >= DEBOUNCE_COUNT - 1) begin
    counter <= 0;
    stable_state <= sync_2;
```

Once the counter reaches the threshold, the circuit accepts the new button state and resets the counter.

The nonblocking assignment operator `<=` is used for register updates in the clocked process.

### 5.7 Generating a one-cycle press pulse

```verilog
press_pulse <= 1'b0;
```

At every clock cycle, the pulse is cleared by default.

When a new stable HIGH state is accepted:

```verilog
if (sync_2 == 1'b1)
    press_pulse <= 1'b1;
```

The output becomes HIGH for one clock cycle. At 100 MHz, one clock cycle lasts 10 ns.

This produces one event per accepted press, rather than keeping the event signal HIGH for the entire time the button is held down.

The design assumes the button's pressed state is logic HIGH. Verify this against the actual board circuitry if the button behaves unexpectedly.

### 5.8 The top-level `adder4` module

```verilog
module adder4 (
    input  wire       clk,
    input  wire [7:0] sw,
    input  wire       btn_add,
    input  wire       btn_sub,
    output wire [7:0] led
);
```

This module connects the switch inputs, button debouncers, operation-selection register, arithmetic logic, and LED outputs.

The eight-bit switch bus is split into two four-bit operands:

```verilog
assign a = sw[7:4];
assign b = sw[3:0];
```

- `a` receives SW7–SW4.
- `b` receives SW3–SW0.

### 5.9 Instantiating two debounce modules

```verilog
debounce_button ADD_BUTTON (
    .clk(clk),
    .button_in(btn_add),
    .press_pulse(add_press)
);

debounce_button SUB_BUTTON (
    .clk(clk),
    .button_in(btn_sub),
    .press_pulse(sub_press)
);
```

Two instances of the same reusable module are created:

- `ADD_BUTTON` debounces the ADD button.
- `SUB_BUTTON` debounces the SUB button.

Each has its own synchroniser registers, stable-state register, and counter.

The named port connections, such as `.button_in(btn_add)`, connect the corresponding module ports to signals in the top-level design.

### 5.10 Remembering the selected operation

```verilog
reg sub_mode = 1'b0;
```

This register stores the selected arithmetic mode.

- `0`: Addition.
- `1`: Subtraction.

The mode changes only when a debounced press pulse is received:

```verilog
always @(posedge clk) begin
    if (add_press)
        sub_mode <= 1'b0;
    else if (sub_press)
        sub_mode <= 1'b1;
end
```

If both pulses occur in the same clock cycle, the ADD branch takes priority because it appears first in the `if`/`else if` statement.

Otherwise, the selected mode remains unchanged until another button event occurs.

### 5.11 Extending the operands to five bits

```verilog
wire [4:0] a_ext;
wire [4:0] b_ext;
wire [4:0] result;

assign a_ext = {1'b0, a};
assign b_ext = {1'b0, b};
```

The concatenation operator `{}` combines bits. Here, a zero is placed before each four-bit operand.

For example:

```text
a     = 1001   (9)
a_ext = 01001  (9)
```

Zero-extension preserves the unsigned input value while making the arithmetic result five bits wide.

### 5.12 Selecting addition or subtraction

```verilog
assign result = sub_mode
              ? (a_ext - b_ext)
              : (a_ext + b_ext);
```

This uses the conditional operator:

```text
condition ? value_if_true : value_if_false
```

When `sub_mode` is HIGH, the subtraction expression is selected. Otherwise, addition is selected.

The arithmetic is combinational: whenever an operand or the selected mode changes, the result is recalculated by the hardware.

### 5.13 Connecting the result to the LEDs

```verilog
assign led[4:0] = result;
assign led[7:5] = 3'b000;
```

The five-bit result is connected to LEDs LD4–LD0. The remaining three outputs are held LOW.

The result bit mapping is:

| LED | Result bit |
|---|---|
| LD0 | `result[0]` |
| LD1 | `result[1]` |
| LD2 | `result[2]` |
| LD3 | `result[3]` |
| LD4 | `result[4]` |
| LD5–LD7 | Always 0 |

## 6. User Constraints File (UCF)

The UCF maps the logical Verilog ports to physical FPGA pins.

```text
# Atlys slide switches SW0-SW7
NET "sw<0>" LOC = "A10" | IOSTANDARD = LVCMOS33;
NET "sw<1>" LOC = "D14" | IOSTANDARD = LVCMOS33;
NET "sw<2>" LOC = "C14" | IOSTANDARD = LVCMOS33;
NET "sw<3>" LOC = "P15" | IOSTANDARD = LVCMOS33;
NET "sw<4>" LOC = "P12" | IOSTANDARD = LVCMOS33;
NET "sw<5>" LOC = "R5" | IOSTANDARD = LVCMOS33;
NET "sw<6>" LOC = "T5" | IOSTANDARD = LVCMOS33;
NET "sw<7>" LOC = "E4" | IOSTANDARD = LVCMOS33;

# Light Emitting Diodes
NET "led<0>" LOC = "U18" | IOSTANDARD=LVCMOS25 | SLEW=QUIETIO | DRIVE=2;
NET "led<1>" LOC = "M14" | IOSTANDARD=LVCMOS25 | SLEW=QUIETIO | DRIVE=2;
NET "led<2>" LOC = "N14" | IOSTANDARD=LVCMOS25 | SLEW=QUIETIO | DRIVE=2;
NET "led<3>" LOC = "L14" | IOSTANDARD=LVCMOS25 | SLEW=QUIETIO | DRIVE=2;
NET "led<4>" LOC = "M13" | IOSTANDARD=LVCMOS25 | SLEW=QUIETIO | DRIVE=2;
NET "led<5>" LOC = "D4"  | IOSTANDARD=LVCMOS33 | SLEW=QUIETIO | DRIVE=2;
NET "led<6>" LOC = "P16" | IOSTANDARD=LVCMOS25 | SLEW=QUIETIO | DRIVE=2;
NET "led<7>" LOC = "N12" | IOSTANDARD=LVCMOS33 | SLEW=QUIETIO | DRIVE=2;

NET "clk"     LOC = "L15" | IOSTANDARD = LVCMOS33;
NET "btn_add" LOC = "F5"  | IOSTANDARD = LVCMOS33;
NET "btn_sub" LOC = "F6"  | IOSTANDARD = LVCMOS33;
```

### 6.1 Switch pin assignments

| Switch | Signal | FPGA pin |
|---|---|---|
| SW0 | `sw[0]` | A10 |
| SW1 | `sw[1]` | D14 |
| SW2 | `sw[2]` | C14 |
| SW3 | `sw[3]` | P15 |
| SW4 | `sw[4]` | P12 |
| SW5 | `sw[5]` | R5 |
| SW6 | `sw[6]` | T5 |
| SW7 | `sw[7]` | E4 |

### 6.2 LED pin assignments

| LED | Signal | FPGA pin |
|---|---|---|
| LD0 | `led[0]` | U18 |
| LD1 | `led[1]` | M14 |
| LD2 | `led[2]` | N14 |
| LD3 | `led[3]` | L14 |
| LD4 | `led[4]` | M13 |
| LD5 | `led[5]` | D4 |
| LD6 | `led[6]` | P16 |
| LD7 | `led[7]` | N12 |

The supplied UCF also specifies `SLEW=QUIETIO` and `DRIVE=2` on the LED outputs. These are output electrical configuration settings. The I/O standards are preserved as supplied; verify them against the board's electrical documentation before changing them.

### 6.3 Clock and button assignments

| Signal | FPGA pin | Purpose |
|---|---|---|
| `clk` | L15 | Clock input |
| `btn_add` | F5 | Select addition |
| `btn_sub` | F6 | Select subtraction |

The code assumes a 100 MHz clock. The UCF assigns the clock pin but does not include a `PERIOD` timing constraint. For a properly constrained ISE design, add a clock-period constraint appropriate to the board's actual clock source, such as a 10 ns period if the input is confirmed to be 100 MHz.

## 7. How the Circuit Works

The overall signal flow is:

**Slide switches → two 4-bit operands → arithmetic logic → five-bit result → LEDs**

Meanwhile:

**ADD/SUB push buttons → synchronisers and debounce counters → press pulses → operation-selection register**

The button subsystem determines which arithmetic operation is selected. The arithmetic logic then calculates the result using the current switch values.

The operands can change at any time, and the displayed result updates without needing another button press. The buttons select the operation; they do not trigger a one-time calculation.

## 8. Example Calculations

### Example 1: Addition

Select ADD and set:

```text
A = 0011 (3)
B = 0010 (2)
```

The result is:

```text
00101 (5)
```

Expected LED output, from LD4 to LD0: `00101`.

### Example 2: Addition with a carry into the fifth bit

Select ADD and set:

```text
A = 1111 (15)
B = 1111 (15)
```

The result is:

```text
11110 (30)
```

Expected LED output: `11110`.

### Example 3: Positive subtraction

Select SUB and set:

```text
A = 1001 (9)
B = 0101 (5)
```

The result is:

```text
00100 (+4)
```

Expected LED output: `00100`.

### Example 4: Negative subtraction

Select SUB and set:

```text
A = 0101 (5)
B = 1001 (9)
```

The five-bit result is:

```text
11100
```

Interpreted as a five-bit two's-complement signed number, `11100` represents `-4`.

The LEDs show the raw binary representation, not a minus sign.

## 9. Building the Project in Xilinx ISE 14.7

1. Open Xilinx ISE Design Suite.
2. Create a project named `Atlys_4Bit_Adder_Subtractor`.
3. Select the correct Atlys FPGA device configuration: `XC6SLX45`, package `CSG324`, speed grade `-3`.
4. Add the Verilog source file containing both modules.
5. Set `adder4` as the top-level module.
6. Add the UCF file containing the switch, LED, clock, and button constraints.
7. Add an appropriate clock-period constraint for the actual board clock.
8. Run **Synthesize - XST**.
9. Run **Implement Design**.
10. Run **Generate Programming File**.
11. Review the synthesis, mapping, and timing reports for errors.

## 10. Programming and Testing

1. Connect the Atlys board to your computer through its JTAG programming interface.
2. Power on the board.
3. Launch Xilinx iMPACT.
4. Initialise the JTAG chain using Boundary Scan.
5. Assign the generated `.bit` file to the FPGA.
6. Program the device.
7. Set SW7–SW4 to choose operand A.
8. Set SW3–SW0 to choose operand B.
9. Press ADD or SUB to select the desired operation.
10. Read the result from LD4–LD0.

Allow the debounce interval to elapse after pressing a button before expecting the selected mode to update.
