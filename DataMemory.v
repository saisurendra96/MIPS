`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/02/2022 04:06:10 PM
// Design Name: 
// Module Name: DataMemory
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



module DataMemory(ReadData, Address, WriteData, MemoryRead, MemoryWrite, Clock) ;
    input MemoryRead, MemoryWrite, Clock; //Define Inputs and O/Ps according to their bit lenghts
    input [5:0] Address;
    input [31:0] WriteData;
    reg [31:0] mem[63:0];

    output reg [31:0] ReadData;

always@(posedge Clock) // trigger below code for read logic on every positive edge of clock
begin
        if(MemoryRead==1 & MemoryWrite==0) // Check if read enable is high
        begin
                ReadData <= mem[Address]; // load data from memory to read data bus
        end
end
always@(negedge Clock) //Trigger below code for write logic on negative edge of clock
begin
        if(MemoryWrite==1 & MemoryRead==0) //check if Write Enable is high
        begin
                mem[Address] <= WriteData; //Write data on write bus to memory
        end
end

endmodule
