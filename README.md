# Digilent Atlys FPGA — 4-Bit Full Adder / Subtractor

**Beginner’s Step-by-Step Guide**  
**FPGA:** Spartan-6 XC6SLX45 · **Tools:** Xilinx ISE 14.7 WebPACK · iMPACT

> This Markdown file is a text-only conversion of the supplied PDF. Images and screenshots have been omitted. Figure captions and references to screenshots may also be absent where they were embedded as images.

---

DIGILENT ATLYS FPGA
         4-Bit Full Adder - Add and Subtractor

                    Spartan-6 XC6SLX45 • Xilinx ISE 14.7 WebPACK • iMPACT

## 1. Introduction: The Development Board and Software
The Digilent Atlys is an FPGA development board built around the Xilinx Spartan-6 LX45 FPGA. An FPGA (Field-
Programmable Gate Array) is a digital logic device whose internal logic and connections can be configured by loading
a design. Unlike a microcontroller program that normally executes instructions sequentially on a processor, FPGA logic
is configured as hardware and can operate in parallel.
The Atlys includes eight slide switches, six pushbuttons, eight user LEDs, a 100 MHz clock oscillator, memory,
Ethernet, HDMI, audio and USB interfaces. This project uses the clock, eight slide switches, two pushbuttons and five
result LEDs.

### 1.1 Software
·   Xilinx ISE Design Suite 14.7 WebPACK: creates the project, synthesizes and implements the design, and generates
    the .bit file.
·   Verilog HDL: describes the calculator logic.
·   UCF (User Constraints File): maps Verilog signals to physical FPGA pins and sets I/O electrical standards.
·   iMPACT: detects the FPGA through JTAG and loads the .bit file.

The steps assume ISE is installed at ~/Documents/14.7/ISE_DS and the environment script is
~/Documents/14.7/ISE_DS/settings64.sh.

### How to install the software?
Go to the link: https://www.amd.com/en/support/downloads/adaptive-socs-and-fpgas/legacy-ise/v2012_4---14_7.html
(14.7 is the latest software that supports DIGILENT Atyls

Download all the four files.
Extract the Xilinx_ISE_DS_14.7_1015_1-1.tar and add the .lic license file.

The graphical installation wizard should open.

When installing, if the drive installation failed, follow the steps listed here before using iMPACT.

Power on the Atlys board using the separate power supply and connect its USB programming cable.
Open up a terminal and run
lsusb
If the board is connected and detected, you should see output similar to:
Bus 001 Device 009: ID 1443:0007 Digilent Development board JTAG
The 001 and 009 values are just examples; yours may differ.
1443:0007 is the USB vendor ID and product ID for the Digilent development board detected for me so it might be
different for you.

### Step 1 — Connect the board and check USB detection
Open a normal terminal and run:
lsusb -d 1443:0007

Expected output will resemble:
Bus 001 Device 007: ID 1443:0007 Digilent Development board JTAG

The bus and device numbers are examples only.
    ·   If the board appears, continue to Step 2.
    ·   If nothing appears, check the USB cable, board power, USB port, and connection first.
Important: Run this check in a normal terminal before sourcing the ISE environment.

### Step 2 — Check the Digilent USB permissions rule
Run:

ls -l /etc/udev/rules.d/52-digilent-usb.rules

If the file exists, continue to Step 3.
If it reports No such file or directory, locate the rule file included with the Digilent installation:
find "$HOME" /opt /usr/local \
     -type f -name '52-digilent-usb.rules' 2>/dev/null

If this finds a file, use its actual path in the following commands. For example, if it is found at the
location used on my laptop:
sudo cp
"$HOME/Documents/14.7/ISE_DS/ISE/bin/lin64/digilent/digilent.adept.runtime_2.13.1-
x86_64/52-digilent-usb.rules" \
     /etc/udev/rules.d/52-digilent-usb.rules

sudo chmod 644 /etc/udev/rules.d/52-digilent-usb.rules
sudo udevadm control --reload-rules

Do not blindly copy that example path if your new laptop has ISE installed elsewhere.
If find does not locate the file, stop and investigate the Digilent installation instead of creating an empty
rule.

### Step 3 — Reconnect the board and check permissions
Unplug the programming USB cable, wait a few seconds, and reconnect it.
Run:
lsusb -d 1443:0007

Read the current bus and device numbers. Then use them to check the USB device permissions.
For convenience, this command finds the device path automatically, so you don't have to type the
changing numbers:
device_path=$(lsusb -d 1443:0007 | awk 'NR==1 {printf "/dev/bus/usb/%s/%s", $2,
substr($4,1,3)}')
if [ -n "$device_path" ] && [ -e "$device_path" ]; then
       ls -l "$device_path"
else
       echo "Atlys USB device not found"
fi

An example of the permissions we saw on your previous laptop was:
crw-rw-rw- 1 root root ... /dev/bus/usb/001/009

This means the device had read/write permissions for all users. If your new laptop shows different
permissions, don't immediately change them to 777 or make other broad permission changes. Check
whether the udev rule matches the connected device and whether it was reloaded.

### Step 4 — Check the Digilent Adept runtime libraries
Run:
ls -l /usr/local/lib64/digilent/adept/

Then:
ls -l /usr/local/sbin/dftdrvdtch

Then:
ldconfig -p | grep -E 'libdjtg|libusb-1.0'

On your laptop, the Adept directory should contained libdjtg.so.2.10.1 and other Digilent libraries.
The dftdrvdtch utility and libusb-1.0 should also be present.
However, libdjtg did not initially appear in the dynamic linker cache. That led us to the next step.
If these files or directories are missing on the new laptop, don't assume the next command will fix
everything; first confirm whether the Digilent Adept runtime was installed successfully.

### Step 5 — Check for Digilent command-line utilities
Run:
find /usr/local /opt "$HOME" \
  -type f \( -name 'djtgcfg' -o -name 'dadutil' \) 2>/dev/null

On your previous laptop, this returned no results.
That alone does not prove the Adept runtime is broken, so continue with the next step.

### Step 6 — Register the Digilent Adept library directory
This is the most promising fix from our previous troubleshooting session.
First, verify that the directory exists:
ls -l /usr/local/lib64/digilent/adept/libdjtg.so*

If the library exists in that directory, register it with Linux's dynamic linker:
echo '/usr/local/lib64/digilent/adept' | \
  sudo tee /etc/ld.so.conf.d/digilent-adept.conf

sudo ldconfig

Now check whether the library appears in the linker cache:
ldconfig -p | grep libdjtg

You should see an entry referring to libdjtg.so.2 or the installed version in the Adept directory.
If the library is installed somewhere else, use its actual directory instead. If it is missing, do not register
a directory that doesn't contain it.

### Step 7 — Check the ISE Digilent plugin
On your previous laptop, we checked this plugin location:

ls -l "$HOME/.cse/lin64/14.1/plugins/Digilent/libCseDigilent/"

Then we checked for missing library dependencies:
ldd "$HOME/.cse/lin64/14.1/plugins/Digilent/libCseDigilent/libCseDigilent.so" \
  | grep 'not found'

If the second command prints nothing, it found no missing dependencies in that check.
If the directory doesn't exist, don't assume the installation is broken. The location may differ on the new
laptop. Locate the plugin with:
find "$HOME" /opt /usr/local \
  -type f -name 'libCseDigilent.so' 2>/dev/null

Use the path returned by find when running ldd. If it reports missing libraries, record the names rather
than installing random packages.

### Step 8 — Launch iMPACT again
First, locate the ISE environment script if you don't know the installation path:
find "$HOME" /opt /usr/local \
  -type f -name 'settings64.sh' 2>/dev/null

Use the path corresponding to your ISE 14.7 installation. For example, if it is installed at the same
location as before:
source "$HOME/Documents/14.7/ISE_DS/settings64.sh"
impact

Inside iMPACT:
## 1. Select Configure devices using Boundary-Scan (JTAG).
## 2. Click OK.
## 3. Try Initialize Chain.
## 4. If the FPGA appears as xc6slx45, right-click it.
## 5. Select Assign New Configuration File and choose your generated .bit file.
## 6. Select No if asked whether to assign an SPI/BPI PROM file.
## 7. Right-click the FPGA and select Program.
## 8. Leave Verify unchecked, as in our previous procedure, and click OK/Program.
If programming succeeds, you can test the FPGA design.

### Step 9 — If the windrvr6 warning remains
You may still see a message like:
WARNING:iMPACT - Module windrvr6 is not loaded.
Cable connection failed.
Cable autodetection failed.

This warning refers to the legacy Xilinx cable-driver mechanism. It does not, by itself, establish whether
the Digilent runtime or JTAG interface will work.
If iMPACT still cannot detect the board after the checks above:

·   Save the complete iMPACT console log.
    ·   Check the output of ldconfig -p | grep libdjtg.
    ·   Check the plugin's ldd output.
    ·   Recheck the USB permissions using the current device path.
Do not repeatedly retry detection without gathering the new output.

## 2. Intended Program: Calculator Operation
The design adds or subtracts two unsigned 4-bit operands. SW7–SW4 are operand A and SW3–SW0 are operand B.
Press BTNC (centre button) to select ADD; press BTNR (right button) to select SUBTRACT. The selected mode stays
active after release. ADD is selected at startup.
A clocked mode register remembers the selection. Synchronization, debounce logic and press-pulse generation reduce
the chance that the mechanical contact bounce of a pushbutton is interpreted as several presses.

## 3. Theory: Binary Arithmetic
### 3.1 Four-bit numbers
Each switch represents one bit. ON/high means 1 and OFF/low means 0. Four bits represent 0–15. For example, 0111₂
= 7 and 0011₂ = 3.

### 3.2 Full-adder logic
A full adder processes three one-bit inputs: A, B and carry-in (Cin). It produces a sum bit S and carry-out Cout. The
carry-out feeds the next more-significant stage.
  S    = A XOR B XOR Cin
  Cout = (A AND B) OR (A AND Cin) OR (B AND Cin)

FA0 processes bit 0 and begins with Cin = 0. FA1, FA2 and FA3 process higher bits. The final carry C4 is the fifth
result bit. The current Verilog uses + and - operators; synthesis maps these arithmetic expressions into FPGA logic. The
diagram explains the underlying binary arithmetic structure.

### 3.3 Example: 7 + 3
      A = 0111 (7)
      B = 0011 (3)
   7 + 3 = 01010 (5-bit result, decimal 10)

The result is binary 01010. LD4 is 0, LD3 is 1, LD2 is 0, LD1 is 1 and LD0 is 0.

### 3.4 Subtraction and two’s complement
A common digital method computes A − B as A + (~B) + 1. Invert B and add one, then add it to A. The current code
uses a five-bit subtraction expression, which synthesis implements as FPGA logic.

The largest addition is 15 + 15 = 30 (11110), so five bits are required. Subtraction results range from −15 to +15 and
are displayed as five-bit two’s complement. LD4 is the sign bit for these subtraction results.
   7 + 3 = 01010 (10)
   3 - 7 = 11100 (-4 in 5-bit two's complement)
   15 + 1 = 10000 (16)

## 4. Create the ISE Project
### Step 1 — Open a terminal and load the ISE environment:
  source ~/Documents/14.7/ISE_DS/settings64.sh
  ise

Add the license file when prompted.

### Step 2 — In ISE, choose File → New Project.

### Step 3 — Name the project Atlys_Adder_Subtractor. Choose an easy-to-find folder, for example
~/Documents/FPGA/Atlys_Adder_Subtractor, and click Next.

### Step 4 — Choose Family Spartan6, Device XC6SLX45, Package CSG324 and Speed -3. Select ISE WebPACK design
flow if prompted. Click Next.

### Step 5 — Choose Verilog as the preferred HDL, continue through the wizard and click Finish.

### Step 6 — Choose Project → New Source, select Verilog Module, name it adder4, then finish the wizard.

### Step 7 — Open adder4.v, replace its contents with the code in Section 5, and save.

### Step 8 — Create or add a UCF file named adder4.ucf and paste the constraints in Section 6.

### Step 9 — Confirm adder4 is the top module. If needed, right-click it in the Hierarchy pane and choose Set as Top
Module.

## 5. Complete Verilog Code
This version uses a 20-bit debounce counter, sufficient for approximately 10 ms at 100 MHz. ADD is the startup
default. Pressing a button selects that mode until the other button is pressed.
  module debounce_button #(
       parameter integer CLK_HZ = 100_000_000
  )(
       input wire clk,
       input wire button_in,
       output reg press_pulse = 1'b0
  );
       reg sync_1 = 1'b0;
       reg sync_2 = 1'b0;
       reg stable_state = 1'b0;

       localparam integer DEBOUNCE_COUNT = CLK_HZ / 100; // 10 ms
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
     input wire        clk,
     input wire [7:0] sw,
     input wire        btn_add,
     input wire        btn_sub,
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

     debounce_button ADD_BUTTON (
          .clk(clk), .button_in(btn_add), .press_pulse(add_press)
     );
     debounce_button SUB_BUTTON (
          .clk(clk), .button_in(btn_sub), .press_pulse(sub_press)
     );

     // If both buttons are pressed together, ADD has priority.
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
     assign result = sub_mode ? (a_ext - b_ext) : (a_ext + b_ext);

     assign led[4:0] = result;
     assign led[7:5] = 3'b000;
endmodule

## 6. Complete UCF Constraints
These constraints use the pin assignments discussed for the Atlys board. The LED I/O standards intentionally differ,
matching the reference UCF shared for this project. Do not change them only to suppress the mixed-bus warning.
  NET "sw<0>" LOC = "A10" | IOSTANDARD = LVCMOS33;
  NET "sw<1>" LOC = "D14" | IOSTANDARD = LVCMOS33;
  NET "sw<2>" LOC = "C14" | IOSTANDARD = LVCMOS33;
  NET "sw<3>" LOC = "P15" | IOSTANDARD = LVCMOS33;
  NET "sw<4>" LOC = "P12" | IOSTANDARD = LVCMOS33;
  NET "sw<5>" LOC = "R5" | IOSTANDARD = LVCMOS33;
  NET "sw<6>" LOC = "T5" | IOSTANDARD = LVCMOS33;
  NET "sw<7>" LOC = "E4" | IOSTANDARD = LVCMOS33;

  NET "led<0>" LOC = "U18" | IOSTANDARD=LVCMOS25 | SLEW=QUIETIO | DRIVE=2;
  NET "led<1>" LOC = "M14" | IOSTANDARD=LVCMOS25 | SLEW=QUIETIO | DRIVE=2;
  NET "led<2>" LOC = "N14" | IOSTANDARD=LVCMOS25 | SLEW=QUIETIO | DRIVE=2;
  NET "led<3>" LOC = "L14" | IOSTANDARD=LVCMOS25 | SLEW=QUIETIO | DRIVE=2;
  NET "led<4>" LOC = "M13" | IOSTANDARD=LVCMOS25 | SLEW=QUIETIO | DRIVE=2;
  NET "led<5>" LOC = "D4" | IOSTANDARD=LVCMOS33 | SLEW=QUIETIO | DRIVE=2;
  NET "led<6>" LOC = "P16" | IOSTANDARD=LVCMOS25 | SLEW=QUIETIO | DRIVE=2;
  NET "led<7>" LOC = "N12" | IOSTANDARD=LVCMOS33 | SLEW=QUIETIO | DRIVE=2;

  NET "clk"   LOC = "L15" | IOSTANDARD=LVCMOS33;
  NET "btn_add" LOC = "F5" | IOSTANDARD=LVCMOS33;
  NET "btn_sub" LOC = "F6" | IOSTANDARD=LVCMOS33;

Assumptions: the 100 MHz clock is on L15; BTNC is F5; BTNR is F6. Confirm against the board revision and the
known-working LED-blink project. The comments in a UCF are explanatory only; the LOC and IOSTANDARD
attributes are the actual constraints.

## 7. Synthesize, Implement and Generate the Bitstream
### Step 1 — In the Processes pane, double-click Synthesize - XST and wait for completion.

### Step 2 — If synthesis completes, double-click Implement Design.

### Step 3 — If implementation completes, double-click Generate Programming File.

### Step 4 — Confirm that adder4.bit is created in the project's implementation directory.

### Step 5 — A Place:838 mixed-I/O-standard warning can appear because the LED bus intentionally contains
LVCMOS25 and LVCMOS33 signals. The warning alone does not prove the arithmetic failed.
### Step 6 — If any process fails, read the first ERROR in the Console and resolve it before programming.

## 8. Program the FPGA Using iMPACT
### Step 1 — Power the Atlys and connect the Digilent USB programming cable to the board’s Adept/JTAG USB port.
### Step 2 — In ISE, run Configure Target Device (iMPACT), or launch impact from a terminal after sourcing
settings64.sh.

### Step 3 — Create an iMPACT project if prompted and select Boundary Scan.

### Step 4 — Right-click in the Boundary Scan area and choose Initialize Chain. The FPGA should be detected as
xc6slx45.

### Step 5 — When prompted to assign a configuration file, select the generated adder4.bit by clicking ‘Open’ button and
then when prompted to upload the .bit to flash PROM, press NO.

### Step 6 — Assign the bitstream to the xc6slx45 device.

### Step 7 — Right-click the FPGA and select Program. Wait for the success message.

### Step 8 — Follow the tests in Section 9.
JTAG-loaded configuration is volatile. After removing board power, program the .bit file again unless you separately
program the SPI flash for automatic configuration at power-up.

## 9. How to Operate the Calculator
### 9.1 Enter A and B
Set A using SW7–SW4 and B using SW3–SW0. ON/high means 1; OFF/low means 0. Read each group from its most
significant bit to its least significant bit.

### 9.2 Select an operation
ADD: press BTNC (centre pushbutton) once, then release it. Addition stays selected.
SUBTRACT: press BTNR (right pushbutton) once, then release it. Subtraction stays selected.
To return to addition, press BTNC again. These are mode-selection buttons; you do not need to hold them down.

### 9.3 Read the result
LD4–LD0 display the five result bits. LD4 is the most significant bit; LD0 is the least significant bit. A lit LED
represents 1 and an unlit LED represents 0. LD7–LD5 are forced low by the program.
A                             B                                 Selected mode                    LD4 LD3 LD2 LD1 LD0
7 (0111)                      3 (0011)                          ADD                              01010 = 10
7 (0111)                      3 (0011)                          SUBTRACT                         00100 = 4
3 (0011)                      7 (0111)                          SUBTRACT                         11100 = −4
15 (1111)                     1 (0001)                          ADD                              10000 = 16
15 (1111)                     15 (1111)                         ADD                              11110 = 30

## 10. Test the Design
·   Set SW7–SW4 to 0111 (A = 7). Set SW3–SW0 to 0011 (B = 3).
·   Press BTNC and confirm LD4–LD0 show 01010 (10). Release BTNC; ADD remains selected.
·   Press BTNR and confirm LD4–LD0 show 00100 (4). Release BTNR; SUBTRACT remains selected.

·   Set A = 0011 (3) and B = 0111 (7). Ensure SUBTRACT is selected. The LEDs should show 11100, which
    represents −4 in five-bit two’s complement.
·   Press BTNC again and verify that the mode returns to ADD.

## 11. Troubleshooting
Top module missing: Set adder4 as the top module and save all source files.
UCF errors: Check that the UCF names match the Verilog ports exactly: clk, sw, btn_add, btn_sub and led.
Buttons do not select correctly: Verify BTNC/F5, BTNR/F6, clock L15 and button polarity against your board
revision.
Place:838 warning: The reference constraints intentionally use mixed standards on the LED bus. Do not change valid
assignments just to silence the warning.
Design disappears after power-off: JTAG configuration is volatile; reprogram after power-up unless SPI flash is
separately configured.
Wrong numerical result: Check switch order, selected operation, and read LD4 as the most significant result bit.

## 12. References
·   Digilent Atlys official reference page: https://digilent.com/reference/programmable-logic/atlys/reference-manual
·   Digilent Atlys Reference Manual (2013): https://wwwpub.zih.tu-dresden.de/~ss17/wiki/www.mr.inf.tu-
    dresden.de/wiki/Atlys_rm1f5c.pdf?fileId=448
·   Digilent Atlys Reference Manual (2018): https://wwwpub.zih.tu-dresden.de/~ss17/wiki/www.mr.inf.tu-
    dresden.de/wiki/Atlys_rm1f5c.pdf?fileId=448
·   User Constraints File for the Digilent Atlys board, Rev. C: https://github.com/alexforencich/verilog-
    uart/blob/master/example/ATLYS/fpga/fpga.ucf

·   ChatGPT link: https://chatgpt.com/share/6acf2123-45a0-83e8-ac6b-4410a6652b7c

Learning note: the full-adder diagram explains the arithmetic structure. The supplied Verilog uses the + and - operators,
which synthesis maps into FPGA logic.
