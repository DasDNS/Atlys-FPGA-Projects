# Digilent Atlys FPGA 

**Beginner’s Step-by-Step Guide**  
**FPGA:** Spartan-6 XC6SLX45 · **Tools:** Xilinx ISE 14.7 WebPACK · iMPACT

--------------------------------------------

<img width="600" height="600" alt="Picture" src="https://github.com/user-attachments/assets/2984280b-ce56-4fb8-b06c-c2c2d6bade75" />

## 1. Introduction: The Development Board and Software
The Digilent Atlys is an FPGA development board built around the Xilinx Spartan-6 LX45 FPGA. An FPGA (Field-
Programmable Gate Array) is a digital logic device whose internal logic and connections can be configured by loading
a design. Unlike a microcontroller program that normally executes instructions sequentially on a processor, FPGA logic
is configured as hardware and can operate in parallel.
The Atlys includes eight slide switches, six pushbuttons, eight user LEDs, a 100 MHz clock oscillator, memory,
Ethernet, HDMI, audio and USB interfaces. This project uses the clock, eight slide switches, two pushbuttons and five
result LEDs.

<img width="600" height="600" alt="Picture" src="https://github.com/user-attachments/assets/506d1ef0-c215-4edf-abc1-2b2105657fa7" />

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

<img width="1919" height="895" alt="Picture" src="https://github.com/user-attachments/assets/bed561b1-c5b3-46e6-91fb-384a4bbbe15a" />

Download all the four files.
Extract the Xilinx_ISE_DS_14.7_1015_1-1.tar and add the .lic license file.

<img width="1073" height="558" alt="Picture" src="https://github.com/user-attachments/assets/45af3c0d-9fcb-46df-b931-2bc306109195" />

<img width="987" height="703" alt="Picture" src="https://github.com/user-attachments/assets/3c2a6fc3-4dc3-4e56-a7e6-99b6baed14de" />

<img width="1149" height="279" alt="Picture" src="https://github.com/user-attachments/assets/ea47cebf-ef64-41eb-a9a6-3f94e350e992" />

The graphical installation wizard should open.

<img width="1140" height="713" alt="Picture" src="https://github.com/user-attachments/assets/ffb7019f-9a09-424c-a714-90290b8d4fc3" />

<img width="1140" height="713" alt="Picture" src="https://github.com/user-attachments/assets/6be97708-6a4e-4517-a43a-4e850949df4b" />

<img width="1140" height="713" alt="Picture" src="https://github.com/user-attachments/assets/56349351-457d-4484-b19a-ee3ee916eb7e" />

<img width="1140" height="713" alt="Picture" src="https://github.com/user-attachments/assets/170ac859-9393-46ac-a698-edd630dd45f9" />

<img width="1140" height="713" alt="Picture" src="https://github.com/user-attachments/assets/2b3593b4-03b8-4340-a6c9-417bec7feaea" />

<img width="977" height="713" alt="Picture" src="https://github.com/user-attachments/assets/cb022f80-1c8c-4129-8fb5-98552ae8ed13" />

<img width="977" height="713" alt="Picture" src="https://github.com/user-attachments/assets/49f1d2a4-b0ec-4bc9-ab69-6e179f970da5" />

<img width="977" height="713" alt="Picture" src="https://github.com/user-attachments/assets/67fe7b96-893a-4b42-8341-1d5eede8423f" />

<img width="977" height="713" alt="Picture" src="https://github.com/user-attachments/assets/c271ac16-3ea1-4382-a980-97b4b0264ae9" />

When installing, if the drive installation failed, follow the steps listed here before using iMPACT.

<img width="1919" height="1080" alt="Picture" src="https://github.com/user-attachments/assets/8cc27144-ba95-4b15-a967-f41533511323" />

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


## 4. Create the ISE Project
### Step 1 — Open a terminal and load the ISE environment:
  source ~/Documents/14.7/ISE_DS/settings64.sh
  ise

<img width="1429" height="400" alt="Picture" src="https://github.com/user-attachments/assets/c9b01779-14b1-4a87-8b54-7f6913c26e68" />

<img width="860" height="598" alt="Picture" src="https://github.com/user-attachments/assets/a0b7a5ee-b026-4663-98ff-32bfef96c898" />

<img width="1919" height="1080" alt="Picture" src="https://github.com/user-attachments/assets/747db908-6db3-4451-9cb4-20c6ecf02cdb" />

Add the license file when prompted.

<img width="1279" height="960" alt="Picture" src="https://github.com/user-attachments/assets/2219e233-206d-4113-8a04-4d22ca294970" />

<img width="814" height="786" alt="Picture" src="https://github.com/user-attachments/assets/b860c5f0-2d67-4a74-b1b4-b093704096fc" />

<img width="504" height="486" alt="Picture" src="https://github.com/user-attachments/assets/8f3a2ab5-b356-486c-a295-9dda8ca32e7c" />

<img width="1254" height="931" alt="Picture" src="https://github.com/user-attachments/assets/0e1db4b0-f8fa-4c0c-bf3c-d829e94a0b51" />

### Step 2 — In ISE, choose File → New Project.

<img width="1279" height="720" alt="Picture" src="https://github.com/user-attachments/assets/f2656c0a-b10c-4a3e-a3c1-e8b5a1edfd38" />

### Step 3 — Name the project Atlys_Adder_Subtractor. Choose an easy-to-find folder, for example
~/Documents/FPGA/Atlys_Adder_Subtractor, and click Next.

<img width="641" height="711" alt="Picture" src="https://github.com/user-attachments/assets/443637f1-1816-4fc6-838d-53ecff603277" />

<img width="641" height="711" alt="Picture" src="https://github.com/user-attachments/assets/5177f787-aa0d-4b3e-9b56-50204b8e625a" />

### Step 4 — Choose Family Spartan6, Device XC6SLX45, Package CSG324 and Speed -3. Select ISE WebPACK design
flow if prompted. Click Next.

<img width="916" height="867" alt="Picture" src="https://github.com/user-attachments/assets/6996294a-541b-44ca-9888-0f8039833e84" />

### Step 5 — Choose Verilog as the preferred HDL, continue through the wizard and click Finish.

<img width="916" height="867" alt="Picture" src="https://github.com/user-attachments/assets/af5dd402-55aa-4e54-a08b-be088fc11ca9" />

<img width="1919" height="1080" alt="Picture" src="https://github.com/user-attachments/assets/f3fd714e-ce8c-435b-ad13-9ec286bb9556" />

### Step 6 — Choose Project → New Source, select Verilog Module, name it adder4, then finish the wizard.

<img width="1279" height="960" alt="Picture" src="https://github.com/user-attachments/assets/7c5e901c-771f-4dcf-8d7c-9e3c4399a377" />

<img width="1919" height="1080" alt="Picture" src="https://github.com/user-attachments/assets/4ce8d523-e0b3-4d24-bf7a-46df21eab574" />

<img width="1919" height="1080" alt="Picture" src="https://github.com/user-attachments/assets/37bcd628-e43f-4165-a1a6-45bcc6016e1c" />

<img width="1919" height="1080" alt="Picture" src="https://github.com/user-attachments/assets/2d972cf7-e6b6-4440-bdfd-f062417d5e0f" />

### Step 7 — Open adder4.v, replace its contents with the code in Section 5, and save.

<img width="1919" height="1080" alt="Picture" src="https://github.com/user-attachments/assets/4e857fb7-a081-474e-9905-50e947956ddf" />

<img width="1919" height="1080" alt="Picture" src="https://github.com/user-attachments/assets/3d6d33bb-d938-4e72-a669-4775c40d1748" />

### Step 8 — Create or add a UCF file named adder4.ucf and paste the constraints in Section 6.

<img width="1279" height="960" alt="Picture" src="https://github.com/user-attachments/assets/30277845-ee7c-489f-9965-8b65d0fbdb5e" />

<img width="1919" height="1080" alt="Picture" src="https://github.com/user-attachments/assets/135d1e36-a847-4261-8e58-c2d7a8fb2fc2" />

<img width="1919" height="1080" alt="Picture" src="https://github.com/user-attachments/assets/5eccd05d-53b8-4373-ad53-84d79475f05e" />

<img width="1919" height="1080" alt="Picture" src="https://github.com/user-attachments/assets/9b2d7ffc-9d54-4900-b21e-ed9d0190f0f6" />

<img width="1919" height="1080" alt="Picture" src="https://github.com/user-attachments/assets/0ab32b48-95cc-4025-8659-2bd8580b5d57" />

<img width="1919" height="1080" alt="Picture" src="https://github.com/user-attachments/assets/11c47232-dd1e-40a8-8ba9-5262a4b8ddc3" />

<img width="1919" height="1080" alt="Picture" src="https://github.com/user-attachments/assets/430c7ffa-6f6e-4e3f-978b-7d420fb66047" />

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

<img width="1919" height="1080" alt="Picture" src="https://github.com/user-attachments/assets/c185204f-30ad-43a6-a2ec-71fcd45413ee" />

<img width="1919" height="1080" alt="Picture" src="https://github.com/user-attachments/assets/826bb81f-630d-49b3-a262-a32a204993e1" />

### Step 2 — If synthesis completes, double-click Implement Design.

<img width="1919" height="1080" alt="Picture" src="https://github.com/user-attachments/assets/ba155e99-350a-4195-9070-6002c6f96d52" />

<img width="1919" height="1080" alt="Picture" src="https://github.com/user-attachments/assets/55ca5450-1cde-4e92-b00d-c488a891bb69" />

### Step 3 — If implementation completes, double-click Generate Programming File.

<img width="1919" height="1080" alt="Picture" src="https://github.com/user-attachments/assets/c4412092-a359-46c7-8f81-602cc9f56c3c" />

<img width="1919" height="1080" alt="Picture" src="https://github.com/user-attachments/assets/86a85cff-3ca4-4daf-9262-41a1a4ed95aa" />

### Step 4 — Confirm that adder4.bit is created in the project's implementation directory.

<img width="1917" height="740" alt="Picture" src="https://github.com/user-attachments/assets/84ea0db5-f4c2-4da4-beb1-4f681d970a12" />

<img width="1919" height="1080" alt="Picture" src="https://github.com/user-attachments/assets/4cc9f3dd-0004-4e56-83e7-ede29e9a86ca" />

### Step 5 — A Place:838 mixed-I/O-standard warning can appear because the LED bus intentionally contains
LVCMOS25 and LVCMOS33 signals. The warning alone does not prove the arithmetic failed.
### Step 6 — If any process fails, read the first ERROR in the Console and resolve it before programming.

## 8. Program the FPGA Using iMPACT
### Step 1 — Power the Atlys and connect the Digilent USB programming cable to the board’s Adept/JTAG USB port.
### Step 2 — In ISE, run Configure Target Device (iMPACT), or launch impact from a terminal after sourcing
settings64.sh.

<img width="1337" height="440" alt="Picture" src="https://github.com/user-attachments/assets/1baa5252-cba7-48a4-b775-4d0961833b00" />

### Step 3 — Create an iMPACT project if prompted and select Boundary Scan.

<img width="1026" height="805" alt="Picture" src="https://github.com/user-attachments/assets/6f30c28b-77c1-4517-ae8d-abeac685bba7" />

### Step 4 — Right-click in the Boundary Scan area and choose Initialize Chain. The FPGA should be detected as
xc6slx45.

<img width="1026" height="805" alt="Picture" src="https://github.com/user-attachments/assets/0571487a-6ba6-4b17-b133-83c1f459d71a" />

<img width="1026" height="805" alt="Picture" src="https://github.com/user-attachments/assets/7a5f6877-efa5-43f3-8d83-cdf7c2d5799b" />

### Step 5 — When prompted to assign a configuration file, select the generated adder4.bit by clicking ‘Open’ button and
then when prompted to upload the .bit to flash PROM, press NO.

<img width="1026" height="805" alt="Picture" src="https://github.com/user-attachments/assets/4985c9f9-9357-4847-8f02-b2926b0d2ede" />

<img width="1026" height="805" alt="Picture" src="https://github.com/user-attachments/assets/643eadf2-b775-4324-b0b5-5fda8a5e7fae" />

<img width="1026" height="805" alt="Picture" src="https://github.com/user-attachments/assets/75761492-3167-4507-bb88-7ede1fccb008" />

### Step 6 — Assign the bitstream to the xc6slx45 device.

<img width="1026" height="805" alt="Picture" src="https://github.com/user-attachments/assets/4cef2579-a739-465a-8dab-6e779bab4529" />

<img width="1026" height="805" alt="Picture" src="https://github.com/user-attachments/assets/dda4b8e1-28dd-4479-90d5-c72eedac6801" />

### Step 7 — Right-click the FPGA and select Program. Wait for the success message.

<img width="1026" height="805" alt="Picture" src="https://github.com/user-attachments/assets/a86fcb13-fdd6-4fd1-bee5-64b7d10cfc33" />

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

Learning note: the full-adder diagram explains the arithmetic structure. The supplied Verilog uses the + and - operators,
which synthesis maps into FPGA logic.
