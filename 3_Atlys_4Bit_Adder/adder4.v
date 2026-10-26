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
//
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



