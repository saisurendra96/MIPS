`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/02/2022 04:02:58 PM
// Design Name: 
// Module Name: SignExtender
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SignExtender(signExtImm, imm16, signExtend);
input [15:0] imm16;
input signExtend;
output  [31:0] signExtImm;
assign signExtImm = signExtend ? {{16{imm16[15]}},imm16[15:0]} : {16'h0,imm16[15:0]};
endmodule
