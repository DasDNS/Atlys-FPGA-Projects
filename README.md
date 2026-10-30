# Digilent Atlys FPGA --- Installation, Setup and Programming Guide

Beginner's guide for installing Xilinx ISE Design Suite 14.7 on Ubuntu 24.04 LTS,
creating a Verilog project, generating a bitstream, programming the
Digilent Atlys Spartan-6 FPGA through JTAG, and testing a 4-bit
adder/subtractor.

> **Board:** Digilent Atlys, Spartan-6 XC6SLX45, CSG324, speed grade -3\
> **Tools:** Xilinx ISE Design Suite 14.7 WebPACK, Verilog HDL and
> iMPACT\
> **Example clock:** 100 MHz \
> **Example project:** 4-bit adder/subtractor with debounced push
> buttons

This guide consolidates the procedures from the accompanying 4-Bit Full
Adder - Add and Subtractor guide. It also includes practical notes and
screenshots. Replace the example installation paths and
verify pin assignments for your own board.

## Contents

1.  Introduction and requirements
2.  Download and install ISE 14.7
3.  Load the ISE environment
4.  Connect the board and check USB detection
5.  Configure USB permissions
6.  Check Digilent Adept libraries and plugin
7.  Troubleshoot iMPACT
8.  Understand the example design
9.  Create an ISE project
10. Add Verilog and UCF files
11. Synthesis, implementation and bitstream generation
12. Program the FPGA
13. Operate and test the design
14. Troubleshooting
15. References

------------------------------------------------------------------------

## 1. Introduction and requirements

The Digilent Atlys is an FPGA development board based on the Xilinx
Spartan-6 LX45. An FPGA is configured as digital hardware; unlike a
typical microcontroller program, FPGA logic can operate in parallel.

The Atlys provides slide switches, push buttons, LEDs, a 100 MHz
oscillator, memory, Ethernet, HDMI, audio and USB interfaces. The
example project uses eight switches, two push buttons, the clock and
five result LEDs.

### Hardware

-   Digilent Atlys FPGA board
-   Atlys power supply
-   USB cable connected to the Digilent Adept/JTAG programming port
-   Ubuntu computer

### Software

  -----------------------------------------------------------------------
  Software                            Purpose
  ----------------------------------- -----------------------------------
  Xilinx ISE Design Suite 14.7        Project creation, synthesis,
  WebPACK                             implementation and bitstream
                                      generation

  Verilog HDL                         Hardware description language

  UCF                                 Physical FPGA pin and I/O-standard
                                      constraints

  iMPACT                              JTAG chain detection and FPGA
                                      programming
  -----------------------------------------------------------------------

**ISE device settings**

  Property        Value
  --------------- -------------
  Family          Spartan6
  Device          XC6SLX45
  Package         CSG324
  Speed grade     -3
  Design flow     ISE WebPACK
  Preferred HDL   Verilog

ISE 14.7 is a legacy toolchain for devices such as Spartan-6.
Installation and cable-driver behaviour can vary between Ubuntu
releases.

**\[SCREENSHOT PLACEHOLDER --- Atlys board overview\]**

`images/atlys-board-overview.png`

## 2. Download and install Xilinx ISE 14.7

### 2.1 Download

1.  Open the official AMD legacy ISE download page:\
    <https://www.amd.com/en/support/downloads/adaptive-socs-and-fpgas/legacy-ise/v2012_4---14_7.html>
2.  Locate ISE Design Suite 14.7.
3.  Download the required installation files. The original setup used
    four files.
4.  Extract the main archive, named similar to
    `Xilinx_ISE_DS_14.7_1015_1-1.tar`.
5.  Keep the required `.lic` license file available.

The download page and package layout may change. Follow AMD's current
instructions and use the package intended for your host system.

**\[SCREENSHOT PLACEHOLDER --- AMD download page\]**

`images/ise-download-page.png`

**\[SCREENSHOT PLACEHOLDER --- Downloaded and extracted installer
files\]**

`images/ise-downloaded-files.png`

### 2.2 Install

1.  Open a terminal in the extracted installer directory.
2.  Locate and launch the installer executable or setup script included
    in the package, following its instructions.
3.  If the graphical installer does not open, inspect the terminal
    output for missing libraries or permission errors.
4.  Follow the installation wizard.
5.  Select the ISE design tools needed for Spartan-6 development,
    including iMPACT.
6.  Install Digilent/Adept components if offered.
7.  Complete installation and note the installation directory.
8.  Apply the license file if requested, using the license supplied for
    your installation.

The example installation path used throughout this guide is:

``` bash
~/Documents/14.7/ISE_DS
```

The environment script is:

``` bash
~/Documents/14.7/ISE_DS/settings64.sh
```

Your paths may differ.

**\[SCREENSHOT PLACEHOLDER --- Installer wizard\]**

`images/ise-install-wizard.png`

**\[SCREENSHOT PLACEHOLDER --- Component selection\]**

`images/ise-install-components.png`

**\[SCREENSHOT PLACEHOLDER --- License setup, if shown\]**

`images/ise-license-setup.png`

**\[SCREENSHOT PLACEHOLDER --- Installation completed\]**

`images/ise-install-complete.png`

If the legacy cable-driver installation fails, do not immediately assume
JTAG programming is impossible. Continue with the Digilent USB/Adept
checks below. Retain installer error messages for troubleshooting.

## 3. Load the ISE environment

ISE tools need environment variables configured by `settings64.sh`.

For the example path:

``` bash
source "$HOME/Documents/14.7/ISE_DS/settings64.sh"
```

Start Project Navigator:

``` bash
ise
```

Start iMPACT:

``` bash
impact
```

If you do not know where ISE was installed, locate the environment
script:

``` bash
find "$HOME" /opt /usr/local \
  -type f -name 'settings64.sh' 2>/dev/null
```

Use the actual path returned by the command.

**\[SCREENSHOT PLACEHOLDER --- Terminal with environment loaded\]**

`images/ise-environment-terminal.png`

**\[SCREENSHOT PLACEHOLDER --- ISE Project Navigator\]**

`images/ise-project-navigator.png`

## 4. Connect the Atlys and check USB detection

1.  Power the Atlys board using its separate power supply.
2.  Connect the USB programming cable to the Digilent Adept/JTAG USB
    connector.
3.  Open a normal terminal and run:

``` bash
lsusb
```

The previous setup detected an entry similar to:

``` text
Bus 001 Device 009: ID 1443:0007 Digilent Development board JTAG
```

Bus and device numbers are examples and change when devices reconnect.
Filter by the observed vendor/product ID:

``` bash
lsusb -d 1443:0007
```

Example:

``` text
Bus 001 Device 007: ID 1443:0007 Digilent Development board JTAG
```

If no device appears, check board power, cable, USB connector and
computer port. Run this initial check before sourcing the ISE
environment.

`1443:0007` is the ID observed in the documented setup. If your board
reports a different ID, investigate the detected entry rather than
assuming this ID must apply.

**\[SCREENSHOT PLACEHOLDER --- lsusb showing Digilent JTAG board\]**

`images/lsusb-atlys-detected.png`

## 5. Configure Digilent USB permissions

The udev rule used in the previous setup was:

``` text
/etc/udev/rules.d/52-digilent-usb.rules
```

Check whether it exists:

``` bash
ls -l /etc/udev/rules.d/52-digilent-usb.rules
```

If missing, search the installation:

``` bash
find "$HOME" /opt /usr/local \
  -type f -name '52-digilent-usb.rules' 2>/dev/null
```

If found, copy it using the actual path returned by `find`. An example
path from the previous installation is:

``` bash
sudo cp \
  "$HOME/Documents/14.7/ISE_DS/ISE/bin/lin64/digilent/digilent.adept.runtime_2.13.1-x86_64/52-digilent-usb.rules" \
  /etc/udev/rules.d/52-digilent-usb.rules
```

Do not blindly use this example if your installation directory or Adept
runtime version differs. If `find` returns no result, investigate the
Adept installation instead of creating an empty rule.

Set permissions and reload the rules:

``` bash
sudo chmod 644 /etc/udev/rules.d/52-digilent-usb.rules
sudo udevadm control --reload-rules
```

Unplug the programming cable, wait a few seconds, and reconnect it. Then
check detection again:

``` bash
lsusb -d 1443:0007
```

### Check the current USB device permissions

Bus and device numbers change. This command discovers the current device
node:

``` bash
device_path=$(lsusb -d 1443:0007 | awk 'NR==1 {printf "/dev/bus/usb/%s/%s", $2, substr($4,1,3)}')

if [ -n "$device_path" ] && [ -e "$device_path" ]; then
    ls -l "$device_path"
else
    echo "Atlys USB device not found"
fi
```

The previous computer showed permissions similar to:

``` text
crw-rw-rw- 1 root root ... /dev/bus/usb/001/009
```

If your permissions differ, check the udev rule and reload procedure. Do
not use broad permission changes such as `chmod 777` as a quick fix.

**\[SCREENSHOT PLACEHOLDER --- udev rule file\]**

`images/digilent-udev-rule.png`

**\[SCREENSHOT PLACEHOLDER --- USB device permissions\]**

`images/atlys-usb-permissions.png`

## 6. Check Digilent Adept libraries and the ISE plugin

If `lsusb` detects the board but iMPACT cannot initialise the JTAG
chain, inspect the runtime libraries and plugin.

### 6.1 Adept runtime directory

``` bash
ls -l /usr/local/lib64/digilent/adept/
```

The previous setup contained libraries including `libdjtg.so.2.10.1`.
Exact names and locations can differ.

Check the driver utility:

``` bash
ls -l /usr/local/sbin/dftdrvdtch
```

Check the dynamic linker cache:

``` bash
ldconfig -p | grep -E 'libdjtg|libusb-1.0'
```

The previous setup initially showed `libusb-1.0` but did not show
`libdjtg` in the linker cache.

### 6.2 Register the Adept library directory

First verify that the library exists:

``` bash
ls -l /usr/local/lib64/digilent/adept/libdjtg.so*
```

If it exists in that directory, register the directory:

``` bash
echo '/usr/local/lib64/digilent/adept' | \
  sudo tee /etc/ld.so.conf.d/digilent-adept.conf

sudo ldconfig
```

Check:

``` bash
ldconfig -p | grep libdjtg
```

You should see an entry referring to `libdjtg.so.2` or the installed
version. If the library is elsewhere, use its actual directory. Do not
register a directory that does not contain the library.

### 6.3 Search for Adept command-line tools

``` bash
find /usr/local /opt "$HOME" \
  -type f \( -name 'djtgcfg' -o -name 'dadutil' \) 2>/dev/null
```

The previous computer returned no results. This alone does not prove the
runtime is broken.

### 6.4 Check the ISE Digilent plugin

The previous installation used:

``` bash
ls -l "$HOME/.cse/lin64/14.1/plugins/Digilent/libCseDigilent/"
```

Check dependencies:

``` bash
ldd "$HOME/.cse/lin64/14.1/plugins/Digilent/libCseDigilent/libCseDigilent.so" \
  | grep 'not found'
```

If this prints nothing, no missing dependencies were reported by that
check.

If the directory does not exist, locate the plugin:

``` bash
find "$HOME" /opt /usr/local \
  -type f -name 'libCseDigilent.so' 2>/dev/null
```

Use the actual path returned by `find` with `ldd`. If dependencies are
missing, record their names and investigate those specific libraries.

**\[SCREENSHOT PLACEHOLDER --- Adept library directory\]**

`images/adept-library-directory.png`

**\[SCREENSHOT PLACEHOLDER --- ldconfig showing libdjtg\]**

`images/ldconfig-libdjtg.png`

**\[SCREENSHOT PLACEHOLDER --- Plugin dependency check\]**

`images/digilent-plugin-ldd.png`

## 7. Troubleshoot iMPACT/JTAG detection

Launch iMPACT after sourcing the environment:

``` bash
source "$HOME/Documents/14.7/ISE_DS/settings64.sh"
impact
```

Inside iMPACT:

1.  Select **Configure devices using Boundary-Scan (JTAG)**.
2.  Click **OK**.
3.  Choose **Initialize Chain**.
4.  The FPGA should be detected as `xc6slx45`.
5.  Right-click the FPGA and choose **Assign New Configuration File**.
6.  Select the generated `.bit` file.
7.  If asked to assign an SPI/BPI PROM file, select **No** for this JTAG
    procedure.
8.  Right-click the FPGA and choose **Program**.
9.  Leave **Verify** unchecked, as in the documented procedure.
10. Click **OK/Program** and wait for the result.

**\[SCREENSHOT PLACEHOLDER --- iMPACT Boundary Scan\]**

`images/impact-boundary-scan.png`

**\[SCREENSHOT PLACEHOLDER --- Initialised chain\]**

`images/impact-initialized-chain.png`

**\[SCREENSHOT PLACEHOLDER --- Assigning bitstream\]**

`images/impact-assign-bitstream.png`

### If the `windrvr6` warning remains

Messages may include:

``` text
WARNING:iMPACT - Module windrvr6 is not loaded.
Cable connection failed.
Cable autodetection failed.
```

This warning refers to the legacy Xilinx cable-driver mechanism. By
itself, it does not establish whether the Digilent runtime or JTAG
interface will work.

If the board is still not detected:

-   Save the complete iMPACT console log.
-   Check `ldconfig -p | grep libdjtg`.
-   Check the plugin's `ldd` output.
-   Recheck USB permissions using the current device path.
-   Confirm the board is powered and visible in `lsusb`.

Avoid repeatedly retrying without checking the diagnostic output.

## 8. Understand the example design

The example is a 4-bit adder/subtractor. It accepts two unsigned
four-bit operands:

-   A = SW7--SW4.
-   B = SW3--SW0.

The operation is selected by push buttons:

-   ADD: BTNC (centre button), mapped to F5 in this project.
-   SUBTRACT: BTNR (right button), mapped to F6 in this project.

The selected mode remains active after the button is released. ADD is
the startup mode. LD4--LD0 display the five-bit result; LD4 is the most
significant bit. LD7--LD5 are forced LOW.

### 8.1 Binary arithmetic

Four bits represent unsigned values from 0 to 15:

``` text
0111₂ = 7
0011₂ = 3
```

The largest sum is 15 + 15 = 30, or `11110`, so five result bits are
required.

### 8.2 Full-adder theory

A full adder accepts A, B and carry-in (`Cin`), and produces sum (`S`)
and carry-out (`Cout`):

``` text
S    = A XOR B XOR Cin
Cout = (A AND B) OR (A AND Cin) OR (B AND Cin)
```

Four full-adder stages connected in sequence form a ripple-carry adder.
Each stage's carry-out feeds the next more-significant stage.

The example Verilog below uses the `+` and `-` operators rather than
explicitly instantiating four full-adder modules. Synthesis maps those
arithmetic expressions into FPGA logic. The full-adder explanation
describes the underlying arithmetic structure.

**\[IMAGE PLACEHOLDER --- Four-stage ripple-carry adder diagram\]**

`images/ripple-carry-adder.png`

### 8.3 Subtraction and two's complement

A common digital subtraction method is:

``` text
A - B = A + (~B) + 1
```

The example uses five-bit subtraction. Differences from -15 to +15 fit
in five-bit two's-complement representation. LD4 is the sign bit for
these subtraction results.

  Operation   Five-bit result     Decimal interpretation
  ----------- ----------------- ------------------------
  7 + 3       `01010`                                 10
  3 - 7       `11100`                                 -4
  15 + 1      `10000`                                 16

## 9. Create an ISE project

Start ISE:

``` bash
source "$HOME/Documents/14.7/ISE_DS/settings64.sh"
ise
```

In Project Navigator:

1.  Select **File → New Project**.
2.  Enter a project name, for example `Atlys_Adder_Subtractor`.
3.  Choose a convenient project directory, for example
    `~/Documents/FPGA/Atlys_Adder_Subtractor`.
4.  Click **Next**.

**\[SCREENSHOT PLACEHOLDER --- New Project wizard\]**

`images/ise-new-project.png`

Set:

  Property             Value
  -------------------- --------------------------
  Family               Spartan6
  Device               XC6SLX45
  Package              CSG324
  Speed                -3
  Preferred Language   Verilog
  Design Flow          ISE WebPACK, if prompted

Click **Next**, choose Verilog as the preferred HDL, continue through
the wizard and click **Finish**.

**\[SCREENSHOT PLACEHOLDER --- Device properties\]**

`images/ise-device-properties.png`

**\[SCREENSHOT PLACEHOLDER --- Project wizard finish\]**

`images/ise-project-finish.png`

## 10. Add Verilog and UCF files

### 10.1 Add Verilog

1.  Select **Project → New Source**.
2.  Choose **Verilog Module**.
3.  Name it `adder4`.
4.  Complete the wizard.
5.  Open `adder4.v`, replace its contents with the complete design
    source, and save.

The source contains two modules:

-   `debounce_button`: synchronises the asynchronous button input,
    filters contact bounce and generates a one-clock-cycle press pulse.
-   `adder4`: connects switches, debouncers, operation-selection
    register, arithmetic logic and LEDs.

**\[SCREENSHOT PLACEHOLDER --- New Verilog source wizard\]**

`images/ise-add-verilog-source.png`

**\[SCREENSHOT PLACEHOLDER --- Verilog code in editor\]**

`images/ise-verilog-editor.png`

### 10.2 Add the UCF

Create or add `adder4.ucf` and enter the constraints in Section 11. The
UCF signal names must match the top-level Verilog ports exactly: `clk`,
`sw`, `btn_add`, `btn_sub` and `led`.

**\[SCREENSHOT PLACEHOLDER --- UCF editor\]**

`images/ise-ucf-editor.png`

### 10.3 Set the top-level module

Confirm `adder4` is the top module. If necessary, right-click `adder4`
in the Hierarchy pane and choose **Set as Top Module**.

**\[SCREENSHOT PLACEHOLDER --- Set as Top Module\]**

`images/ise-set-top-module.png`

## 11. Synthesis, implementation and bitstream generation

### 11.1 UCF constraints

The following constraints are the supplied example for the Atlys board:

``` text
# Atlys slide switches SW0-SW7
NET "sw<0>" LOC = "A10" | IOSTANDARD = LVCMOS33;
NET "sw<1>" LOC = "D14" | IOSTANDARD = LVCMOS33;
NET "sw<2>" LOC = "C14" | IOSTANDARD = LVCMOS33;
NET "sw<3>" LOC = "P15" | IOSTANDARD = LVCMOS33;
NET "sw<4>" LOC = "P12" | IOSTANDARD = LVCMOS33;
NET "sw<5>" LOC = "R5"  | IOSTANDARD = LVCMOS33;
NET "sw<6>" LOC = "T5"  | IOSTANDARD = LVCMOS33;
NET "sw<7>" LOC = "E4"  | IOSTANDARD = LVCMOS33;

# LEDs
NET "led<0>" LOC = "U18" | IOSTANDARD=LVCMOS25 | SLEW=QUIETIO | DRIVE=2;
NET "led<1>" LOC = "M14" | IOSTANDARD=LVCMOS25 | SLEW=QUIETIO | DRIVE=2;
NET "led<2>" LOC = "N14" | IOSTANDARD=LVCMOS25 | SLEW=QUIETIO | DRIVE=2;
NET "led<3>" LOC = "L14" | IOSTANDARD=LVCMOS25 | SLEW=QUIETIO | DRIVE=2;
NET "led<4>" LOC = "M13" | IOSTANDARD=LVCMOS25 | SLEW=QUIETIO | DRIVE=2;
NET "led<5>" LOC = "D4"  | IOSTANDARD=LVCMOS33 | SLEW=QUIETIO | DRIVE=2;
NET "led<6>" LOC = "P16" | IOSTANDARD=LVCMOS25 | SLEW=QUIETIO | DRIVE=2;
NET "led<7>" LOC = "N12" | IOSTANDARD=LVCMOS33 | SLEW=QUIETIO | DRIVE=2;

# Clock and buttons
NET "clk"     LOC = "L15" | IOSTANDARD = LVCMOS33;
NET "btn_add" LOC = "F5"  | IOSTANDARD = LVCMOS33;
NET "btn_sub" LOC = "F6"  | IOSTANDARD = LVCMOS33;
```

The clock and button assumptions are L15 = 100 MHz, BTNC = F5 and BTNR =
F6. Confirm them against your board revision and known-working
constraints.

The supplied LED bus intentionally mixes LVCMOS25 and LVCMOS33. Do not
change assignments simply to silence a warning; verify electrical
compatibility against the board documentation.

### 11.2 Add a clock timing constraint

The UCF above assigns the clock pin but does not specify its period. If
L15 is confirmed to be 100 MHz, add:

``` text
NET "clk" TNM_NET = "sys_clk_pin";
TIMESPEC "TS_sys_clk_pin" = PERIOD "sys_clk_pin" 10 ns HIGH 50%;
```

A 100 MHz clock has a 10 ns period. Use the actual period if your clock
source differs.

### 11.3 Run synthesis

1.  In the Processes pane, double-click **Synthesize - XST**.
2.  Wait for completion.
3.  Check the Console and synthesis reports for errors.

**\[SCREENSHOT PLACEHOLDER --- Synthesis complete\]**

`images/ise-synthesis-complete.png`

### 11.4 Run implementation

If synthesis succeeds, double-click **Implement Design** and wait for
completion. Review the Console and implementation reports.

**\[SCREENSHOT PLACEHOLDER --- Implementation complete\]**

`images/ise-implementation-complete.png`

### 11.5 Generate the bitstream

1.  Double-click **Generate Programming File**.
2.  Wait for completion.
3.  Locate the generated `.bit` file in the project implementation
    output directory.

The exact output path depends on the project location and ISE
configuration.

**\[SCREENSHOT PLACEHOLDER --- Bitstream generated\]**

`images/ise-bitstream-generated.png`

A `Place:838` mixed-I/O-standard warning can appear because the supplied
LED constraints intentionally mix LVCMOS25 and LVCMOS33. The warning
alone does not prove that the arithmetic design failed. If a process
fails, find and resolve the first actual `ERROR` in the Console before
programming.

## 12. Program the FPGA using iMPACT

1.  Power the Atlys board.
2.  Connect the Digilent programming USB cable to the Adept/JTAG USB
    port.
3.  Confirm USB detection with `lsusb`.
4.  Launch **Configure Target Device (iMPACT)** from ISE, or run
    `impact` from a terminal after sourcing `settings64.sh`.
5.  If prompted, create an iMPACT project.
6.  Select **Boundary Scan**.
7.  Right-click the Boundary Scan area and choose **Initialize Chain**.
8.  The FPGA should be detected as `xc6slx45`.
9.  When prompted, select the generated `.bit` file.
10. If asked to assign an SPI/BPI PROM file, select **No** for this JTAG
    procedure.
11. Right-click the FPGA and select **Program**.
12. Leave **Verify** unchecked, following the procedure documented for
    this project.
13. Start programming and wait for the success message.

**\[SCREENSHOT PLACEHOLDER --- iMPACT Boundary Scan\]**

`images/impact-boundary-scan.png`

**\[SCREENSHOT PLACEHOLDER --- JTAG chain detected\]**

`images/impact-initialized-chain.png`

**\[SCREENSHOT PLACEHOLDER --- Bitstream selection\]**

`images/impact-select-bit-file.png`

**\[SCREENSHOT PLACEHOLDER --- Program dialog\]**

`images/impact-program-dialog.png`

**\[SCREENSHOT PLACEHOLDER --- Programming success\]**

`images/impact-programming-success.png`

A JTAG-loaded configuration is volatile. Removing board power loses the
configuration, so program the `.bit` file again after power-up unless
you separately configure the SPI flash for automatic startup
configuration.

## 13. Operate and test the adder/subtractor

### 13.1 Set the operands

-   A is set using SW7--SW4.
-   B is set using SW3--SW0.
-   Switch ON/high means `1`.
-   Switch OFF/low means `0`.

Read each group from its most significant bit to its least significant
bit.

**\[IMAGE PLACEHOLDER --- Switch mapping\]**

`images/operand-switch-mapping.png`

### 13.2 Select the operation

-   Press BTNC (centre button) once and release it to select ADD.
-   Press BTNR (right button) once and release it to select SUBTRACT.
-   The selected operation remains active after release.
-   Press BTNC again to return to addition.

These buttons select a mode; they do not need to be held down.

**\[IMAGE PLACEHOLDER --- Operation buttons and LEDs\]**

`images/operation-buttons-result-leds.png`

### 13.3 Read the output

LD4--LD0 display the five-bit result. LD4 is the most significant bit
and LD0 the least significant bit. A lit LED represents `1`; an unlit
LED represents `0`. LD7--LD5 are forced LOW.

              A             B Mode       LD4--LD0
  ------------- ------------- ---------- --------------
     7 (`0111`)    3 (`0011`) ADD        `01010` = 10
     7 (`0111`)    3 (`0011`) SUBTRACT   `00100` = 4
     3 (`0011`)    7 (`0111`) SUBTRACT   `11100` = -4
    15 (`1111`)    1 (`0001`) ADD        `10000` = 16
    15 (`1111`)   15 (`1111`) ADD        `11110` = 30

### 13.4 Test procedure

1.  Set SW7--SW4 to `0111` (A = 7).
2.  Set SW3--SW0 to `0011` (B = 3).
3.  Press BTNC and confirm LD4--LD0 show `01010` (10). Release BTNC; ADD
    remains selected.
4.  Press BTNR and confirm LD4--LD0 show `00100` (4). Release BTNR;
    SUBTRACT remains selected.
5.  Set A to `0011` (3) and B to `0111` (7). Ensure SUBTRACT is
    selected. The LEDs should show `11100`, representing -4 in five-bit
    two's complement.
6.  Press BTNC and verify that the mode returns to ADD.

**\[SCREENSHOT PLACEHOLDER --- Board displaying addition result\]**

`images/test-addition-on-board.png`

**\[SCREENSHOT PLACEHOLDER --- Board displaying subtraction result\]**

`images/test-subtraction-on-board.png`

## 14. Troubleshooting

  -----------------------------------------------------------------------
  Symptom                             Checks
  ----------------------------------- -----------------------------------
  `ise` or `impact` not found         Source the correct `settings64.sh`
                                      and verify the installation path

  Board absent from `lsusb`           Check power, cable, USB port and
                                      selected board connector

  USB detected but JTAG fails         Check udev rule, current USB
                                      permissions, Adept libraries and
                                      plugin

  `windrvr6` warning                  This is a legacy driver warning;
                                      also inspect Digilent runtime and
                                      plugin

  `libdjtg` absent from linker cache  Verify the library exists, register
                                      its actual directory and run
                                      `sudo ldconfig`

  Plugin dependencies missing         Run `ldd` on the actual
                                      `libCseDigilent.so` and investigate
                                      reported dependencies

  JTAG chain does not initialise      Recheck USB detection, permissions,
                                      runtime, plugin and board power

  FPGA not detected as `xc6slx45`     Check board connection and JTAG
                                      chain

  Top module missing                  Set `adder4` as top module

  UCF errors                          Match UCF names to Verilog ports:
                                      `clk`, `sw`, `btn_add`, `btn_sub`,
                                      `led`

  Buttons do not select modes         Verify BTNC/F5, BTNR/F6, clock L15
                                      and button polarity for the board
                                      revision

  Mixed-I/O-standard warning          The reference LED constraints
                                      intentionally mix standards; verify
                                      assignments rather than changing
                                      them merely to silence the warning

  Design disappears after power-off   JTAG configuration is volatile;
                                      reprogram after power-up unless SPI
                                      flash is configured

  Wrong numerical result              Check switch ordering, selected
                                      mode and LD4 as the most
                                      significant result bit
  -----------------------------------------------------------------------

Useful diagnostic commands:

``` bash
# Check USB detection
lsusb -d 1443:0007

# Find Digilent udev rule
find "$HOME" /opt /usr/local \
  -type f -name '52-digilent-usb.rules' 2>/dev/null

# Check Adept libraries
ls -l /usr/local/lib64/digilent/adept/
ldconfig -p | grep -E 'libdjtg|libusb-1.0'

# Find ISE Digilent plugin
find "$HOME" /opt /usr/local \
  -type f -name 'libCseDigilent.so' 2>/dev/null

# Find ISE environment script
find "$HOME" /opt /usr/local \
  -type f -name 'settings64.sh' 2>/dev/null
```

## 15. Important notes

-   Paths and Adept runtime versions in this guide are examples from one
    Ubuntu installation. Use paths that actually exist on your computer.
-   The clock assignment assumes L15 is the 100 MHz clock. Verify this
    against the board documentation.
-   The button mapping assumes BTNC = F5 and BTNR = F6. Confirm it for
    your board revision.
-   The supplied LED UCF entries mix LVCMOS25 and LVCMOS33. They are
    reproduced from the project constraints; check electrical
    compatibility against the board documentation.
-   This procedure programs the FPGA over JTAG. It does not program
    non-volatile SPI flash.
-   The guide records a troubleshooting approach, not a guarantee that
    every Ubuntu/ISE installation has identical libraries or paths.
-   Keep complete iMPACT console logs when troubleshooting.

## 16. References

1.  AMD/Xilinx --- ISE Design Suite 14.7 legacy download:\
    <https://www.amd.com/en/support/downloads/adaptive-socs-and-fpgas/legacy-ise/v2012_4---14_7.html>
2.  Digilent --- Atlys Reference Manual:\
    <https://digilent.com/reference/programmable-logic/atlys/reference-manual>
3.  Atlys Reference Manual PDF mirror cited in the source guide:\
    <https://wwwpub.zih.tu-dresden.de/~ss17/wiki/www.mr.inf.tu-dresden.de/wiki/Atlys_rm1f5c.pdf?fileId=448>
4.  Example Atlys UCF constraints:\
    <https://github.com/alexforencich/verilog-uart/blob/master/example/ATLYS/fpga/fpga.ucf>

------------------------------------------------------------------------

## Suggested repository layout

If this is the main repository README, keep images in a root-level
`images/` folder:

``` text
Atlys-FPGA-Projects/
├── README.md
├── images/
│   ├── atlys-board-overview.png
│   ├── ise-download-page.png
│   ├── ise-install-wizard.png
│   ├── ise-project-navigator.png
│   ├── lsusb-atlys-detected.png
│   ├── atlys-usb-permissions.png
│   ├── adept-library-directory.png
│   ├── impact-initialized-chain.png
│   ├── ise-new-project.png
│   ├── ise-device-properties.png
│   ├── ise-verilog-editor.png
│   ├── ise-ucf-editor.png
│   ├── ise-synthesis-complete.png
│   ├── ise-implementation-complete.png
│   ├── ise-bitstream-generated.png
│   ├── impact-programming-success.png
│   ├── operand-switch-mapping.png
│   ├── operation-buttons-result-leds.png
│   ├── test-addition-on-board.png
│   └── test-subtraction-on-board.png
└── Atlys_4Bit_Adder_Subtractor/
    ├── adder4.v
    ├── adder4.ucf
    └── README.md
```

The screenshot references in this document are placeholders. Add your
own images using the filenames shown, or update the Markdown paths to
match your chosen filenames.

**End of guide.**
