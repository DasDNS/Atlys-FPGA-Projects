`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:57:57 10/14/2026 
// Design Name: 
// Module Name:    full_adder_add_subtract 
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
//
//////////////////////////////////////////////////////////////////////////////////

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

    // 0 = ADD, 1 = SUBTRACT.
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

    // Remember the selected operation.
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

