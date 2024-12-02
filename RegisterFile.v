`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/02/2022 04:01:28 PM
// Design Name: 
// Module Name: RegisterFile
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


module RegisterFile( BusA ,BusB, BusW, RA, RB, RW, RegWr, Clk);

    input Clk,RegWr; //Define Inputs and O/Ps according to their bit lengths
    input [4:0] RA, RB, RW;
    reg [31:0] GPR[31:0];
    input [31:0] BusW;
    output  [31:0] BusA, BusB;

    assign BusA = RA ? GPR[RA] : 0;  //Read 0 Whenever read address is given as zero
        assign BusB = RB ? GPR[RB] : 0;  // Connecting R0 to ground.
        
    always @(posedge Clk)  //Triggered on every negative edge of clock
    begin   // Below code is executed on every negative edge of clock
        
        if(RegWr==1 & RW!= 5'b0)   // if Write Enable is high and write address is not 0
        begin
            GPR[RW] <= BusW;  // Write BusW value to the register of selected address when Write 
        end
    
    end
endmodule
