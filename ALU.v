`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/02/2022 04:04:30 PM
// Design Name: 
// Module Name: ALU
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


//OP Codes for ALU Operations
`define AND 4'b0000
`define OR 4'b0001
`define ADD 4'b0010
`define SLL 4'b0011
`define SRL 4'b0100
`define SUB 4'b0110
`define SLT 4'b0111
`define ADDU 4'b1000
`define SUBU 4'b1001
`define XOR 4'b1010
`define SLTU 4'b1011
`define NOR 4'b1100
`define SRA 4'b1101
`define LUI 4'b1110

module ALU(BusW, Zero, BusA, BusB, ALUCtrl);

input wire [31:0] BusA, BusB; //Define Inputs and Outputs accroding to their Bit lenghts
output reg [31:0] BusW;
input wire [3:0] ALUCtrl;
output wire Zero;

reg [31:0] temp;

wire less;
//wire [63:0]Bus64;
assign Zero = BusW ? 1'b0 : 1'b1;
assign less = ({1'b0, BusA} < {1'b0, BusB}  ? 1'b1 : 1'b0);
//assign Bus64 =
always@(*)begin
case (ALUCtrl)
`AND:   BusW <= BusA & BusB; //Logical AND
`OR:    BusW <= BusA | BusB; //Logical OR
`ADD:   BusW <= BusA + BusB; //Addition
`ADDU:  BusW <= BusA + BusB; //UnSigned Add
`SLL:   BusW <= BusA << BusB; //Logical Left Shift
`SRL:   BusW <= BusA >> BusB; //Logical Right Shift
`SUB:   BusW <= BusA - BusB; //Subtraction
`SUBU:  BusW <= BusA - BusB; 
`XOR:   BusW <= BusA ^ BusB; //Bitwise Exclusive oR
`NOR:   BusW <= ~(BusA | BusB); //Logical Not-OR
`SLT:  //BusW <= (~(BusA)+1)>(~(BusB)+1);//BusW <= (BusA-BusB)>>31; //Set Less Than
        begin
            if(BusA[31] != BusB[31])
                BusW <= (BusA[31] > BusB[31]) ? 1'b1 : 1'b0;
            else
                BusW <= (BusA < BusB) ? 1'b1 : 1'b0;
        end
`SLTU: //Set Less Than Unsigned Operation logic
   begin
            if(BusA[31] != BusB[31])
                BusW <= (BusA[31] > BusB[31]) ? 1'b0 : 1'b1;
            else
                BusW <= (BusA < BusB) ? 1'b1 : 1'b0;
        end
`SRA:  //Arithmetic Shift Right
  begin
      //BusW <= (BusB[31]) ? (BusB >>> BusA) : (BusB >> BusA);
      BusW <= $signed(BusA) >>> BusB;
  end
`LUI:  //Load Upper Immediate, Load 16-bit data into 16-bit MSB
begin
temp = BusB << 16;
BusW <= {temp[31:16], BusA[15:0]};
end
default:BusW <= 0;
endcase

end
endmodule

