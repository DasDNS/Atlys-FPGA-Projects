`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:08:15 10/14/2026 
// Design Name: 
// Module Name:    led_blink 
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


