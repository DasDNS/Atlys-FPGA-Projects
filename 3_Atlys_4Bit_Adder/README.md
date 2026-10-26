# Atlys FPGA Project 03: 4-Bit Ripple Carry Adder

A beginner-friendly FPGA project using Verilog HDL and the Digilent Atlys development board. This project implements a 4-bit binary adder using four interconnected full-adder modules and displays the 5-bit addition result on five LEDs.

## 1. Project Overview

The objective of this project is to add two unsigned 4-bit binary numbers using the slide switches on the FPGA development board.

- **Input A:** Four slide switches, `SW4` to `SW7`
- **Input B:** Four slide switches, `SW0` to `SW3`
- **Output:** Five LEDs, `LD0` to `LD4`

Each input represents an unsigned binary number from 0 to 15. Adding the two numbers can produce a result from 0 to 30, which requires five bits.

The design uses four full adders connected in series to create a **4-bit ripple carry adder**.

### Example

Suppose:

- \(A = 9 = 1001_2\)
- \(B = 6 = 0110_2\)

The result is:

\[
1001_2 + 0110_2 = 01111_2
\]

The five output LEDs represent the binary result `01111`, with `LD4` as the most significant bit and `LD0` as the least significant bit.

## 2. Hardware and Software

### Hardware

- **FPGA development board:** Digilent Atlys
- **FPGA device:** Xilinx Spartan-6 XC6SLX45
- **Inputs:** Eight slide switches
- **Outputs:** Five LEDs

### Software

- Xilinx ISE Design Suite 14.7
- Verilog HDL
- Xilinx iMPACT for programming the FPGA

## 3. Project Files

| File | Purpose |
|---|---|
| `adder4.v` | Contains the `full_adder` and `adder4` module definitions |
| `adder4.ucf` | Assigns physical FPGA pins to the switches and LEDs |
| `adder4.bit` | Generated FPGA bitstream used to configure the device |

The filenames may vary depending on how the project was created in Xilinx ISE.

## 4. Verilog HDL Source Code

```verilog
`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    10:53:40 10/14/2026
// Design Name:
// Module Name:    adder4
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

module full_adder (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);

    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);

endmodule


module adder4 (
    input  wire [7:0] sw,
    output wire [4:0] led
);

    wire [3:0] a;
    wire [3:0] b;
    wire [3:0] sum;
    wire [4:0] carry;

    assign a = sw[7:4];
    assign b = sw[3:0];

    assign carry[0] = 1'b0;

    full_adder FA0 (
        .a(a[0]), .b(b[0]), .cin(carry[0]),
        .sum(sum[0]), .cout(carry[1])
    );

    full_adder FA1 (
        .a(a[1]), .b(b[1]), .cin(carry[1]),
        .sum(sum[1]), .cout(carry[2])
    );

    full_adder FA2 (
        .a(a[2]), .b(b[2]), .cin(carry[2]),
        .sum(sum[2]), .cout(carry[3])
    );

    full_adder FA3 (
        .a(a[3]), .b(b[3]), .cin(carry[3]),
        .sum(sum[3]), .cout(carry[4])
    );

    assign led[3:0] = sum;
    assign led[4]   = carry[4];

endmodule
```

## 5. Understanding the Verilog Code

### 5.1 The `timescale` directive

```verilog
`timescale 1ns / 1ps
```

This specifies the time unit and time precision used in simulation.

- `1ns`: One simulation time unit is one nanosecond.
- `1ps`: The simulation time precision is one picosecond.

This design has no explicit delays or clocked processes, so the directive does not set the operating speed of the adder.

### 5.2 The `full_adder` module

```verilog
module full_adder (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);
```

A full adder is a combinational circuit that adds three single-bit inputs:

- `a`: First input bit.
- `b`: Second input bit.
- `cin`: Carry-in from the previous, less significant bit.
- `sum`: Result bit for the current position.
- `cout`: Carry-out to the next, more significant bit.

A full adder can produce a sum bit of `0` or `1`, and a carry-out bit of `0` or `1`.

### 5.3 The sum equation

```verilog
assign sum = a ^ b ^ cin;
```

The `^` operator represents bitwise XOR.

XOR produces `1` when an odd number of its input bits are `1`.

The sum equation is:

\[
S = A \oplus B \oplus C_{in}
\]

For example, if `a = 1`, `b = 1`, and `cin = 0`, the sum is `0` because `1 XOR 1 XOR 0 = 0`.

### 5.4 The carry-out equation

```verilog
assign cout = (a & b) | (a & cin) | (b & cin);
```

This equation determines whether the addition generates a carry.

- `&` is the bitwise AND operator.
- `|` is the bitwise OR operator.
- Parentheses group the terms.

The carry equation is:

\[
C_{out} = (A \land B) \lor (A \land C_{in}) \lor (B \land C_{in})
\]

A carry-out occurs when at least two of the three input bits are `1`.

For example:

```text
a   = 1
b   = 1
cin = 0
-----------
sum = 0
cout = 1
```

The binary result of `1 + 1 + 0` is `10`, so the sum bit is `0` and the carry-out is `1`.

### 5.5 Why use two `assign` statements?

```verilog
assign sum  = a ^ b ^ cin;
assign cout = (a & b) | (a & cin) | (b & cin);
```

The full adder has two independent outputs. Each continuous assignment describes the combinational logic needed to drive one output.

The FPGA tools synthesise these expressions into hardware logic. They are not executed as sequential software instructions.

### 5.6 The `adder4` module

```verilog
module adder4 (
    input  wire [7:0] sw,
    output wire [4:0] led
);
```

This is the top-level module that connects the eight switches to the four full adders and routes the five result bits to the LEDs.

- `input wire [7:0] sw`: An eight-bit input bus.
- `output wire [4:0] led`: A five-bit output bus.

In Verilog, the range `[7:0]` includes eight bits: 7, 6, 5, 4, 3, 2, 1, and 0. Similarly, `[4:0]` contains five bits.

### 5.7 Internal wires

```verilog
wire [3:0] a;
wire [3:0] b;
wire [3:0] sum;
wire [4:0] carry;
```

These wires connect different parts of the circuit.

- `a`: The first 4-bit operand.
- `b`: The second 4-bit operand.
- `sum`: The four sum bits generated by the full adders.
- `carry`: The carry chain, including the initial carry-in and the final carry-out.

The carry bus contains five bits because it needs one initial carry value and one carry result from each of the four stages.

### 5.8 Mapping the switches to operands

```verilog
assign a = sw[7:4];
assign b = sw[3:0];
```

These statements divide the eight switch inputs into two four-bit numbers.

- `sw[7:4]` supplies operand `a`.
- `sw[3:0]` supplies operand `b`.

For example, if `sw[7:4] = 1001` and `sw[3:0] = 0110`, then `a = 9` and `b = 6`.

### 5.9 Initialising the carry chain

```verilog
assign carry[0] = 1'b0;
```

The `1'b0` literal means a one-bit binary value of zero.

The first full adder receives this value as its carry-in because there is no preceding bit in an ordinary two-operand addition.

The carry chain is then:

```text
carry[0] = 0  -> initial carry-in
carry[1]     -> carry-out from FA0
carry[2]     -> carry-out from FA1
carry[3]     -> carry-out from FA2
carry[4]     -> carry-out from FA3
```

### 5.10 Instantiating the full adders

The design creates four instances of the `full_adder` module.

```verilog
full_adder FA0 (
    .a(a[0]), .b(b[0]), .cin(carry[0]),
    .sum(sum[0]), .cout(carry[1])
);
```

This is an example of **module instantiation**.

- `full_adder` is the module being used.
- `FA0` is the instance name.
- `.a(a[0])` connects the instance's `a` input to bit 0 of operand `a`.
- `.b(b[0])` connects the instance's `b` input to bit 0 of operand `b`.
- `.cin(carry[0])` connects the carry-in.
- `.sum(sum[0])` connects the sum output.
- `.cout(carry[1])` connects the carry-out to the next stage.

The dot notation is called *named port connection*. It connects signals by their declared port names rather than by their positions in the module declaration.

The remaining instances follow the same pattern:

| Instance | Operand bits | Carry-in | Sum output | Carry-out |
|---|---|---|---|---|
| `FA0` | Bit 0 | `carry[0]` | `sum[0]` | `carry[1]` |
| `FA1` | Bit 1 | `carry[1]` | `sum[1]` | `carry[2]` |
| `FA2` | Bit 2 | `carry[2]` | `sum[2]` | `carry[3]` |
| `FA3` | Bit 3 | `carry[3]` | `sum[3]` | `carry[4]` |

The least significant bit is added first. Each stage's carry-out feeds the next stage's carry-in.

This is why the design is called a **ripple carry adder**: the carry signal propagates from one full-adder stage to the next.

### 5.11 Connecting the result to the LEDs

```verilog
assign led[3:0] = sum;
assign led[4]   = carry[4];
```

The four sum bits are connected to LEDs 0 through 3.

The final carry-out is connected to LED 4, making the complete five-bit result:

```text
led[4] led[3] led[2] led[1] led[0]
  C4     S3     S2     S1     S0
```

This represents the unsigned addition result, including the final carry bit.

## 6. User Constraints File (UCF)

The UCF file maps each switch and LED signal to its physical FPGA package pin.

```text
# Slide switches SW0 to SW7
NET "sw<0>" LOC = "A10" | IOSTANDARD = LVCMOS33;
NET "sw<1>" LOC = "D14" | IOSTANDARD = LVCMOS33;
NET "sw<2>" LOC = "C14" | IOSTANDARD = LVCMOS33;
NET "sw<3>" LOC = "P15" | IOSTANDARD = LVCMOS33;
NET "sw<4>" LOC = "P12" | IOSTANDARD = LVCMOS33;
NET "sw<5>" LOC = "R5"  | IOSTANDARD = LVCMOS33;
NET "sw<6>" LOC = "T5"  | IOSTANDARD = LVCMOS33;
NET "sw<7>" LOC = "E4"  | IOSTANDARD = LVCMOS33;

# LEDs LD0 to LD4
NET "led<0>" LOC = "U18" | IOSTANDARD = LVCMOS25;
NET "led<1>" LOC = "M14" | IOSTANDARD = LVCMOS25;
NET "led<2>" LOC = "N14" | IOSTANDARD = LVCMOS25;
NET "led<3>" LOC = "L14" | IOSTANDARD = LVCMOS25;
NET "led<4>" LOC = "M13" | IOSTANDARD = LVCMOS25;
```

### 6.1 Switch assignments

Each `NET "sw<n>"` entry assigns a bit of the `sw` input bus to a physical FPGA pin.

All eight switch signals use `IOSTANDARD = LVCMOS33` in this project's UCF.

| Switch | Verilog signal | FPGA pin |
|---|---|---|
| SW0 | `sw[0]` | A10 |
| SW1 | `sw[1]` | D14 |
| SW2 | `sw[2]` | C14 |
| SW3 | `sw[3]` | P15 |
| SW4 | `sw[4]` | P12 |
| SW5 | `sw[5]` | R5 |
| SW6 | `sw[6]` | T5 |
| SW7 | `sw[7]` | E4 |

### 6.2 LED assignments

The five output bits use `IOSTANDARD = LVCMOS25`.

| LED | Verilog signal | FPGA pin |
|---|---|---|
| LD0 | `led[0]` | U18 |
| LD1 | `led[1]` | M14 |
| LD2 | `led[2]` | N14 |
| LD3 | `led[3]` | L14 |
| LD4 | `led[4]` | M13 |

The I/O standards shown here are taken from the supplied constraints. Verify that they match the board's electrical requirements before modifying the assignments.

## 7. How the Circuit Works

The complete data path is:

**Eight slide switches → two 4-bit operands → four full adders → four sum bits plus final carry → five LEDs**

When a switch changes, the corresponding input bit changes. The combinational logic recalculates the addition, and the output LEDs reflect the new result after the circuit's propagation delay.

No clock or reset signal is required because this design is purely combinational.

## 8. Example Calculations

### Example 1: Adding 3 and 2

```text
A = 0011  (3)
B = 0010  (2)
-----------
  = 00101 (5)
```

Expected output:

| LED | LD4 | LD3 | LD2 | LD1 | LD0 |
|---|---:|---:|---:|---:|---:|
| Value | 0 | 0 | 1 | 0 | 1 |

### Example 2: Adding 9 and 6

```text
A = 1001  (9)
B = 0110  (6)
-----------
  = 01111 (15)
```

Expected output: `01111`.

### Example 3: Adding 15 and 15

```text
A = 1111  (15)
B = 1111  (15)
-----------
  = 11110 (30)
```

Expected output: `11110`.

This final example demonstrates why the design requires five output bits. The result of adding two 4-bit unsigned values can exceed the maximum 4-bit value of 15.

## 9. Building the Project in Xilinx ISE 14.7

1. Open Xilinx ISE Design Suite.
2. Create a project named `Atlys_4Bit_Adder`.
3. Select the Atlys FPGA device configuration: `XC6SLX45`, package `CSG324`, speed grade `-3`.
4. Add the Verilog source file containing both `full_adder` and `adder4`.
5. Set `adder4` as the top-level module if ISE has not selected it automatically.
6. Add the UCF file containing the eight switch and five LED constraints.
7. Run **Synthesize - XST**.
8. Run **Implement Design**.
9. Run **Generate Programming File** to create the `.bit` file.
10. Review the synthesis and implementation reports for errors.

## 10. Programming and Testing

1. Connect the Atlys board to your computer through the JTAG programming interface.
2. Power on the board.
3. Launch Xilinx iMPACT.
4. Initialise the JTAG chain using Boundary Scan.
5. Assign the generated `.bit` file to the FPGA.
6. Program the FPGA.
7. Use SW7–SW4 to select operand A.
8. Use SW3–SW0 to select operand B.
9. Read the binary result on LD4–LD0.

For example, set SW7–SW4 to `1001` and SW3–SW0 to `0110`. The expected five-bit result is `01111`.

## 11. Concepts Demonstrated

This project introduces the following FPGA and digital design concepts:

- Binary addition
- Full-adder logic
- XOR, AND, and OR operators
- Combinational logic
- Verilog module declarations
- Named port connections
- Module instantiation and hardware hierarchy
- Vector and bit-select notation
- Carry propagation
- Ripple carry adder architecture
- FPGA pin constraints and I/O standards
- Synthesis, implementation, and bitstream generation

