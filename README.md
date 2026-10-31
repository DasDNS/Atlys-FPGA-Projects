# Digilent Atlys FPGA Guide

**Beginner's Step-by-Step Guide**\
**FPGA:** Spartan-6 XC6SLX45 · **Tools:** Xilinx ISE Design Suite 14.7
WebPACK · iMPACT

------------------------------------------------------------------------

# 1. Introduction

## 1.1 About the Digilent Atlys FPGA board

The Digilent Atlys is an FPGA development board built around the Xilinx
Spartan-6 LX45 FPGA.

An FPGA (Field-Programmable Gate Array) is a digital logic device whose
internal logic and connections can be configured by loading a design.
Unlike a microcontroller program that normally executes instructions
sequentially on a processor, FPGA logic is configured as hardware and
can operate in parallel.

The Atlys includes:

-   Eight slide switches
-   Six pushbuttons
-   Eight user LEDs
-   A 100 MHz clock oscillator
-   Memory, Ethernet, HDMI, audio and USB interfaces

<img width="600" height="600" alt="Picture" src="https://github.com/user-attachments/assets/c3a85463-1131-4c70-9bd1-c83c989ec837" />

# 2. Hardware and Software Requirements

## 2.1 Hardware

-   Digilent Atlys FPGA development board
-   Xilinx Spartan-6 XC6SLX45 FPGA
-   Eight slide switches
-   Two pushbuttons
-   Eight user LEDs
-   100 MHz clock source
-   Board power supply
-   Digilent USB programming cable connected to the board's Adept/JTAG
    USB port

<img width="567" height="567" alt="Picture" src="https://github.com/user-attachments/assets/49308f2b-3f5c-4fc5-9350-0ac6449a1a21" />

## 2.2 Software

-   **Xilinx ISE Design Suite 14.7 WebPACK:** Creates the project,
    synthesizes and implements the design, and generates the `.bit`
    file.
-   **Verilog HDL:** Describes the calculator logic.
-   **UCF (User Constraints File):** Maps Verilog signals to physical
    FPGA pins and sets I/O electrical standards.
-   **iMPACT:** Detects the FPGA through JTAG and loads the `.bit` file.

The steps in this guide assume ISE is installed at:

``` bash
~/Documents/14.7/ISE_DS
```

The environment script is assumed to be:

``` bash
~/Documents/14.7/ISE_DS/settings64.sh
```

If your installation is in a different directory, use your actual
installation path in the commands.

# 3. Install Xilinx ISE 14.7

## 3.1 Download the software

Go to the Xilinx/AMD ISE 14.7 download page:

https://www.amd.com/en/support/downloads/adaptive-socs-and-fpgas/legacy-ise/v2012_4---14_7.html

ISE 14.7 is the version used for this Spartan-6 project.

<img width="1919" height="895" alt="Picture" src="https://github.com/user-attachments/assets/81e4f822-0ff4-461f-89db-42de85124a7c" />

Download all four files provided for the installation.

## 3.2 Extract and install

1.  Extract `Xilinx_ISE_DS_14.7_1015_1-1.tar`.
2.  Add the `.lic` license file as required by the installation.
3.  Start the graphical installation wizard.
4.  Follow the installation steps.

If the Digilent programming driver or runtime installation fails, follow
the USB and Adept troubleshooting procedure in the next section before
using iMPACT.

## 3.3 Load the ISE environment

Open a terminal and run:

``` bash
source ~/Documents/14.7/ISE_DS/settings64.sh
```

To launch ISE from the terminal:

``` bash
ise
```

Add the license file when prompted.

# 4. Set Up Digilent USB/JTAG Support on Ubuntu

This section covers the USB detection and Digilent Adept checks used
when iMPACT cannot detect the Atlys board. Perform these checks before
repeatedly retrying JTAG detection.

## 4.1 Connect the board and check USB detection

1.  Power on the Atlys board using its separate power supply.
2.  Connect its USB programming cable.
3.  Open a normal terminal.
4.  Run:

``` bash
lsusb
```

If the board is connected and detected, you may see output similar to:

``` text
Bus 001 Device 009: ID 1443:0007 Digilent Development board JTAG
```

The bus and device numbers (`001` and `009` here) are examples only.
They may differ on your computer or after reconnecting the board.
`1443:0007` is the USB vendor ID and product ID observed for the
Digilent development board in the original setup; it may differ for
another device or board revision.

Now check specifically for that ID:

``` bash
lsusb -d 1443:0007
```

Expected output resembles:

``` text
Bus 001 Device 007: ID 1443:0007 Digilent Development board JTAG
```

-   If the board appears, continue to the next step.
-   If nothing appears, check the USB cable, board power, USB port and
    physical connection first.

**Important:** Run this check in a normal terminal before sourcing the
ISE environment.

## 4.2 Check the Digilent USB permissions rule

Run:

``` bash
ls -l /etc/udev/rules.d/52-digilent-usb.rules
```

If the file exists, continue to the next step.

If it reports `No such file or directory`, locate the rule file included
with the Digilent installation:

``` bash
find "$HOME" /opt /usr/local \
     -type f -name '52-digilent-usb.rules' 2>/dev/null
```

If this finds a file, use its actual path in the following commands. For
example, if it is found at the location used on the previous laptop:

``` bash
sudo cp \
"$HOME/Documents/14.7/ISE_DS/ISE/bin/lin64/digilent/digilent.adept.runtime_2.13.1-x86_64/52-digilent-usb.rules" \
/etc/udev/rules.d/52-digilent-usb.rules

sudo chmod 644 /etc/udev/rules.d/52-digilent-usb.rules
sudo udevadm control --reload-rules
```

Do not blindly copy that example path if ISE is installed elsewhere.

If `find` does not locate the file, stop and investigate the Digilent
installation instead of creating an empty rule.

## 4.3 Reconnect the board and check permissions

Unplug the programming USB cable, wait a few seconds, and reconnect it.

Run:

``` bash
lsusb -d 1443:0007
```

Read the current bus and device numbers. You can also use this command
to find the device path automatically, so you do not have to type the
changing numbers:

``` bash
device_path=$(lsusb -d 1443:0007 | awk 'NR==1 {printf "/dev/bus/usb/%s/%s", $2, substr($4,1,3)}')

if [ -n "$device_path" ] && [ -e "$device_path" ]; then
    ls -l "$device_path"
else
    echo "Atlys USB device not found"
fi
```

An example of the permissions observed on the previous laptop was:

``` text
crw-rw-rw- 1 root root ... /dev/bus/usb/001/009
```

This means the device had read/write permissions for all users.

If your new laptop shows different permissions, do not immediately
change them to `777` or make other broad permission changes. Check
whether the udev rule matches the connected device and whether it was
reloaded.

## 4.4 Check the Digilent Adept runtime libraries

Run:

``` bash
ls -l /usr/local/lib64/digilent/adept/
```

Then:

``` bash
ls -l /usr/local/sbin/dftdrvdtch
```

Then:

``` bash
ldconfig -p | grep -E 'libdjtg|libusb-1.0'
```

On the previous laptop, the Adept directory contained
`libdjtg.so.2.10.1` and other Digilent libraries. The `dftdrvdtch`
utility and `libusb-1.0` were also present.

However, `libdjtg` did not initially appear in the dynamic linker cache.
That led to the next step.

If these files or directories are missing on another computer, do not
assume the next command will fix everything. First confirm whether the
Digilent Adept runtime was installed successfully.

## 4.5 Check for Digilent command-line utilities

Run:

``` bash
find /usr/local /opt "$HOME" \
  -type f \( -name 'djtgcfg' -o -name 'dadutil' \) 2>/dev/null
```

On the previous laptop, this returned no results. That alone does not
prove the Adept runtime is broken, so continue with the next step.

## 4.6 Register the Digilent Adept library directory

This was the most promising fix from the previous troubleshooting
session.

First, verify that the directory contains the library:

``` bash
ls -l /usr/local/lib64/digilent/adept/libdjtg.so*
```

If the library exists in that directory, register it with Linux's
dynamic linker:

``` bash
echo '/usr/local/lib64/digilent/adept' | \
  sudo tee /etc/ld.so.conf.d/digilent-adept.conf

sudo ldconfig
```

Now check whether the library appears in the linker cache:

``` bash
ldconfig -p | grep libdjtg
```

You should see an entry referring to `libdjtg.so.2` or the installed
version in the Adept directory.

If the library is installed somewhere else, use its actual directory
instead. If it is missing, do not register a directory that does not
contain it.

## 4.7 Check the ISE Digilent plugin

On the previous laptop, the plugin location was checked with:

``` bash
ls -l "$HOME/.cse/lin64/14.1/plugins/Digilent/libCseDigilent/"
```

Then missing library dependencies were checked with:

``` bash
ldd "$HOME/.cse/lin64/14.1/plugins/Digilent/libCseDigilent/libCseDigilent.so" \
  | grep 'not found'
```

If the second command prints nothing, it found no missing dependencies
in that check.

If the directory does not exist, do not assume the installation is
broken. The location may differ on another laptop. Locate the plugin
with:

``` bash
find "$HOME" /opt /usr/local \
  -type f -name 'libCseDigilent.so' 2>/dev/null
```

Use the path returned by `find` when running `ldd`. If it reports
missing libraries, record the names rather than installing random
packages.

## 4.8 Launch iMPACT again

First, locate the ISE environment script if you do not know the
installation path:

``` bash
find "$HOME" /opt /usr/local \
  -type f -name 'settings64.sh' 2>/dev/null
```

Use the path corresponding to your ISE 14.7 installation. For example:

``` bash
source "$HOME/Documents/14.7/ISE_DS/settings64.sh"
impact
```

Inside iMPACT:

1.  Select **Configure devices using Boundary-Scan (JTAG)**.
2.  Click **OK**.
3.  Try **Initialize Chain**.
4.  If the FPGA appears as `xc6slx45`, right-click it.
5.  Select **Assign New Configuration File** and choose your generated
    `.bit` file.
6.  Select **No** if asked whether to assign an SPI/BPI PROM file.
7.  Right-click the FPGA and select **Program**.
8.  Leave **Verify** unchecked, as in the previous procedure, and click
    **OK/Program**.

If programming succeeds, test the FPGA design.

## 4.9 If the `windrvr6` warning remains

You may still see a message like:

``` text
WARNING:iMPACT - Module windrvr6 is not loaded.
Cable connection failed.
Cable autodetection failed.
```

This warning refers to the legacy Xilinx cable-driver mechanism. It does
not, by itself, establish whether the Digilent runtime or JTAG interface
will work.

If iMPACT still cannot detect the board after the checks above:

-   Save the complete iMPACT console log.
-   Check the output of `ldconfig -p | grep libdjtg`.
-   Check the plugin's `ldd` output.
-   Recheck USB permissions using the current device path.

Do not repeatedly retry detection without gathering the new output.

# 5. Understand the Calculator and Binary Arithmetic

## 5.1 Four-bit numbers

Each slide switch represents one bit.

-   ON/high means `1`.
-   OFF/low means `0`.

Four bits represent unsigned values from 0 to 15.

For example:

-   `0111₂` = 7
-   `0011₂` = 3

## 5.2 Full-adder logic

A full adder processes three one-bit inputs: A, B and carry-in (`Cin`).
It produces a sum bit (`S`) and carry-out (`Cout`). The carry-out feeds
the next more-significant stage.

The equations are:

``` text
S    = A XOR B XOR Cin
Cout = (A AND B) OR (A AND Cin) OR (B AND Cin)
```

In a four-stage ripple-carry structure, FA0 processes bit 0 and begins
with `Cin = 0`. FA1, FA2 and FA3 process higher bits. The final carry C4
is the fifth result bit.

The current Verilog implementation in this guide uses the `+` and `-`
operators; synthesis maps these arithmetic expressions into FPGA logic.
The full-adder equations explain the underlying binary arithmetic
structure.

## 5.3 Addition example: 7 + 3

``` text
A = 0111 (7)
B = 0011 (3)
-----------
7 + 3 = 01010
```

The result is binary `01010`, decimal 10.

-   LD4 = 0
-   LD3 = 1
-   LD2 = 0
-   LD1 = 1
-   LD0 = 0

## 5.4 Subtraction and two's complement

A common digital method computes:

``` text
A - B = A + (~B) + 1
```

Invert B and add one, then add it to A. The current code uses a five-bit
subtraction expression, which synthesis implements as FPGA logic.

The largest addition is:

``` text
15 + 15 = 30 = 11110
```

Therefore, five bits are required.

Subtraction results range from -15 to +15 and are displayed as five-bit
two's complement. LD4 is the sign bit for these subtraction results.

Examples:

``` text
7 + 3  = 01010  (10)
3 - 7  = 11100  (-4 in 5-bit two's complement)
15 + 1 = 10000  (16)
```

# 6. Create the ISE Project

## Step 1 --- Load the ISE environment and launch ISE

Open a terminal:

``` bash
source ~/Documents/14.7/ISE_DS/settings64.sh
ise
```

Add the license file when prompted.

## Step 2 --- Create a new project

In ISE, choose:

**File → New Project**

## Step 3 --- Name the project

Name the project:

``` text
Atlys_Adder_Subtractor
```

Choose an easy-to-find folder, for example:

``` text
~/Documents/FPGA/Atlys_Adder_Subtractor
```

Click **Next**.

## Step 4 --- Select the FPGA device

Choose:

-   Family: `Spartan6`
-   Device: `XC6SLX45`
-   Package: `CSG324`
-   Speed: `-3`

Select the ISE WebPACK design flow if prompted. Click **Next**.

## Step 5 --- Select the HDL

Choose Verilog as the preferred HDL, continue through the wizard and
click **Finish**.

## Step 6 --- Create the Verilog source

Choose:

**Project → New Source → Verilog Module**

Name it:

``` text
adder4
```

Then finish the wizard.

## Step 7 --- Add the Verilog code

Open `adder4.v`, replace its contents with the code in Section 7, and
save.

## Step 8 --- Create or add the UCF file

Create or add a UCF file named:

``` text
adder4.ucf
```

Paste the constraints from Section 8.

## Step 9 --- Set the top module

Confirm `adder4` is the top module. If needed, right-click it in the
Hierarchy pane and choose **Set as Top Module**.

# 7. Complete Verilog Code

This version uses a 20-bit debounce counter, sufficient for
approximately 10 ms at 100 MHz. ADD is the startup default. Pressing a
button selects that mode until the other button is pressed.

``` verilog
`timescale 1ns / 1ps

module debounce_button #(
    parameter integer CLK_HZ = 100_000_000
)(
    input  wire clk,
    input  wire button_in,
    output reg  press_pulse = 1'b0
);

    // Synchronize the asynchronous button input.
    reg sync_1 = 1'b0;
    reg sync_2 = 1'b0;

    // Store the debounced button state.
    reg stable_state = 1'b0;

    // Approximately 10 ms debounce interval.
    localparam integer DEBOUNCE_COUNT = CLK_HZ / 100;

    reg [19:0] counter = 0;

    always @(posedge clk) begin
        sync_1 <= button_in;
        sync_2 <= sync_1;

        // Default: no press event.
        press_pulse <= 1'b0;

        if (sync_2 == stable_state) begin
            counter <= 0;
        end
        else if (counter >= DEBOUNCE_COUNT - 1) begin
            counter <= 0;
            stable_state <= sync_2;

            // Generate a pulse only on a new press.
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

    // 0 = ADD, 1 = SUBTRACT. ADD is the startup mode.
    reg sub_mode = 1'b0;

    assign a = sw[7:4];
    assign b = sw[3:0];

    // Debounce the two push buttons.
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

    // If both buttons are pressed together, ADD has priority.
    always @(posedge clk) begin
        if (add_press)
            sub_mode <= 1'b0;
        else if (sub_press)
            sub_mode <= 1'b1;
    end

    // Use five-bit arithmetic so subtraction results
    // are displayed in five-bit two's complement.
    wire [4:0] a_ext;
    wire [4:0] b_ext;
    wire [4:0] result;

    assign a_ext = {1'b0, a};
    assign b_ext = {1'b0, b};

    assign result = sub_mode
                  ? (a_ext - b_ext)
                  : (a_ext + b_ext);

    // LD4 is the fifth bit of the result.
    assign led[4:0] = result;

    // Unused LEDs are kept low.
    assign led[7:5] = 3'b000;

endmodule
```

# 8. Complete UCF Constraints

These constraints use the pin assignments discussed for the Atlys board.
The LED I/O standards intentionally differ, matching the reference UCF
shared for this project. Do not change them only to suppress the
mixed-bus warning.

``` text
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
NET "led<5>" LOC = "D4" | IOSTANDARD=LVCMOS33 | SLEW=QUIETIO | DRIVE=2;
NET "led<6>" LOC = "P16" | IOSTANDARD=LVCMOS25 | SLEW=QUIETIO | DRIVE=2;
NET "led<7>" LOC = "N12" | IOSTANDARD=LVCMOS33 | SLEW=QUIETIO | DRIVE=2;

NET "clk" LOC = "L15" | IOSTANDARD=LVCMOS33;
NET "btn_add" LOC = "F5" | IOSTANDARD=LVCMOS33;
NET "btn_sub" LOC = "F6" | IOSTANDARD=LVCMOS33;
```

## 8.1 Switch pin assignments

  Switch   Verilog signal   FPGA pin
  -------- ---------------- ----------
  SW0      `sw[0]`          A10
  SW1      `sw[1]`          D14
  SW2      `sw[2]`          C14
  SW3      `sw[3]`          P15
  SW4      `sw[4]`          P12
  SW5      `sw[5]`          R5
  SW6      `sw[6]`          T5
  SW7      `sw[7]`          E4

## 8.2 LED pin assignments

  LED   Verilog signal   FPGA pin   I/O standard
  ----- ---------------- ---------- --------------
  LD0   `led[0]`         U18        LVCMOS25
  LD1   `led[1]`         M14        LVCMOS25
  LD2   `led[2]`         N14        LVCMOS25
  LD3   `led[3]`         L14        LVCMOS25
  LD4   `led[4]`         M13        LVCMOS25
  LD5   `led[5]`         D4         LVCMOS33
  LD6   `led[6]`         P16        LVCMOS25
  LD7   `led[7]`         N12        LVCMOS33

The LED outputs also specify `SLEW=QUIETIO` and `DRIVE=2`.

## 8.3 Clock and button assignments

  Signal      FPGA pin   Purpose
  ----------- ---------- --------------------
  `clk`       L15        Clock input
  `btn_add`   F5         ADD selection
  `btn_sub`   F6         SUBTRACT selection

Assumptions: the 100 MHz clock is on L15; BTNC is F5; BTNR is F6.
Confirm against the board revision and the known-working LED-blink
project.

The comments in a UCF are explanatory only; the `LOC` and `IOSTANDARD`
attributes are the actual constraints.

The UCF shown above does not include a clock-period `TIMESPEC`. For a
properly constrained ISE design, add a clock-period constraint
appropriate to the actual board clock. If the clock on L15 is confirmed
to be 100 MHz, its period is 10 ns.

# 9. Synthesize, Implement and Generate the Bitstream

## Step 1 --- Synthesize

In the Processes pane, double-click **Synthesize - XST** and wait for
completion.

## Step 2 --- Implement

If synthesis completes, double-click **Implement Design**.

## Step 3 --- Generate the programming file

If implementation completes, double-click **Generate Programming File**.

## Step 4 --- Confirm the bitstream

Confirm that `adder4.bit` is created in the project's implementation
directory.

## Step 5 --- Understand the mixed-I/O-standard warning

A `Place:838` mixed-I/O-standard warning can appear because the LED bus
intentionally contains LVCMOS25 and LVCMOS33 signals.

The warning alone does not prove the arithmetic failed. The reference
constraints intentionally use mixed standards on the LED bus. Do not
change valid assignments just to silence the warning.

## Step 6 --- Resolve errors

If any process fails, read the first `ERROR` in the Console and resolve
it before programming.

# 10. Program the FPGA Using iMPACT

## Step 1 --- Connect the board

Power the Atlys and connect the Digilent USB programming cable to the
board's Adept/JTAG USB port.

## Step 2 --- Launch iMPACT

In ISE, run **Configure Target Device (iMPACT)**, or launch `impact`
from a terminal after sourcing `settings64.sh`.

## Step 3 --- Select Boundary Scan

Create an iMPACT project if prompted and select **Boundary Scan**.

## Step 4 --- Initialise the JTAG chain

Right-click in the Boundary Scan area and choose **Initialize Chain**.

The FPGA should be detected as:

``` text
xc6slx45
```

## Step 5 --- Select the bitstream

When prompted to assign a configuration file, select the generated
`adder4.bit` by clicking **Open**.

When prompted to upload the `.bit` to flash PROM, press **NO**.

## Step 6 --- Assign the bitstream

Assign the bitstream to the `xc6slx45` device.

## Step 7 --- Program

Right-click the FPGA and select **Program**. Wait for the success
message.

## Step 8 --- Test

Follow the operating and test instructions in the next section.

> JTAG-loaded configuration is volatile. After removing board power,
> program the `.bit` file again unless you separately program the SPI
> flash for automatic configuration at power-up.

# 11. Operate and Test the Calculator

## 11.1 Enter A and B

Set A using SW7--SW4 and B using SW3--SW0.

-   ON/high means `1`.
-   OFF/low means `0`.

Read each group from its most significant bit to its least significant
bit.

## 11.2 Select an operation

-   **ADD:** Press BTNC (centre pushbutton) once, then release it.
    Addition stays selected.
-   **SUBTRACT:** Press BTNR (right pushbutton) once, then release it.
    Subtraction stays selected.

To return to addition, press BTNC again.

These are mode-selection buttons; you do not need to hold them down.
Allow the debounce interval to elapse before expecting the selected mode
to update.

## 11.3 Read the result

LD4--LD0 display the five result bits.

-   LD4 is the most significant bit.
-   LD0 is the least significant bit.
-   A lit LED represents `1`.
-   An unlit LED represents `0`.
-   LD7--LD5 are forced LOW by the program.

## 11.4 Example results

  A             B             Selected mode   LD4 LD3 LD2 LD1 LD0
  ------------- ------------- --------------- ---------------------
  7 (`0111`)    3 (`0011`)    ADD             `01010` = 10
  7 (`0111`)    3 (`0011`)    SUBTRACT        `00100` = 4
  3 (`0011`)    7 (`0111`)    SUBTRACT        `11100` = -4
  15 (`1111`)   1 (`0001`)    ADD             `10000` = 16
  15 (`1111`)   15 (`1111`)   ADD             `11110` = 30

## 11.5 Test procedure

1.  Set SW7--SW4 to `0111` (A = 7).
2.  Set SW3--SW0 to `0011` (B = 3).
3.  Press BTNC and confirm LD4--LD0 show `01010` (10).
4.  Release BTNC; ADD remains selected.
5.  Press BTNR and confirm LD4--LD0 show `00100` (4).
6.  Release BTNR; SUBTRACT remains selected.
7.  Set A = `0011` (3) and B = `0111` (7).
8.  Ensure SUBTRACT is selected. The LEDs should show `11100`, which
    represents -4 in five-bit two's complement.
9.  Press BTNC again and verify that the mode returns to ADD.

# 12. Troubleshooting

  -----------------------------------------------------------------------
  Problem                             What to check
  ----------------------------------- -----------------------------------
  Top module missing                  Set `adder4` as the top module and
                                      save all source files.

  UCF errors                          Check that the UCF names match the
                                      Verilog ports exactly: `clk`, `sw`,
                                      `btn_add`, `btn_sub` and `led`.

  Buttons do not select correctly     Verify BTNC/F5, BTNR/F6, clock L15
                                      and button polarity against your
                                      board revision.

  `Place:838` warning                 The reference constraints
                                      intentionally use mixed standards
                                      on the LED bus. Do not change valid
                                      assignments just to silence the
                                      warning.

  Design disappears after power-off   JTAG configuration is volatile;
                                      reprogram after power-up unless SPI
                                      flash is separately configured.

  Wrong numerical result              Check switch order, selected
                                      operation, and read LD4 as the most
                                      significant result bit.

  iMPACT cannot detect the board      Follow the USB detection, udev
                                      permissions, Adept runtime, dynamic
                                      linker and plugin checks in Section
                                      4.

  `windrvr6` warning                  The warning relates to the legacy
                                      Xilinx cable-driver mechanism.
                                      Gather the iMPACT log and
                                      diagnostic outputs rather than
                                      repeatedly retrying detection.
  -----------------------------------------------------------------------

# 13. References

-   Digilent Atlys official reference page:\
    https://digilent.com/reference/programmable-logic/atlys/reference-manual

-   Digilent Atlys Reference Manual (2013):\
    https://wwwpub.zih.tu-dresden.de/\~ss17/wiki/www.mr.inf.tu-dresden.de/wiki/Atlys_rm1f5c.pdf?fileId=448

-   Digilent Atlys Reference Manual (2018):\
    https://wwwpub.zih.tu-dresden.de/\~ss17/wiki/www.mr.inf.tu-dresden.de/wiki/Atlys_rm1f5c.pdf?fileId=448

-   User Constraints File for the Digilent Atlys board, Rev. C:\
    https://github.com/alexforencich/verilog-uart/blob/master/example/ATLYS/fpga/fpga.ucf

-   ChatGPT project discussion:\
    https://chatgpt.com/share/6acf2123-45a0-83e8-ac6b-4410a6652b7c

------------------------------------------------------------------------

## Learning Note

The full-adder diagram explains the underlying arithmetic structure. The
supplied Verilog uses the `+` and `-` operators, which synthesis maps
into FPGA logic.

This project brings together FPGA project creation, Verilog module
design, binary arithmetic, input synchronisation, button debouncing,
clocked mode selection, pin constraints, synthesis, implementation, JTAG
programming and hardware testing.
