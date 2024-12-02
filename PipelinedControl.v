`timescale 1ns / 1ps


`timescale 1ns / 1ps

`define RTYPEOPCODE 6'b000000
`define LWOPCODE        6'b100011
`define SWOPCODE        6'b101011
`define BEQOPCODE       6'b000100
`define JOPCODE     6'b000010
`define ORIOPCODE       6'b001101
`define ADDIOPCODE  6'b001000
`define ADDIUOPCODE 6'b001001
`define ANDIOPCODE  6'b001100
`define LUIOPCODE       6'b001111
`define SLTIOPCODE  6'b001010
`define SLTIUOPCODE 6'b001011
`define XORIOPCODE  6'b001110

`define AND     4'b0000
`define OR      4'b0001
`define ADD     4'b0010
`define SLL     4'b0011
`define SRL     4'b0100
`define SUB     4'b0110
`define SLT     4'b0111
`define ADDU    4'b1000
`define SUBU    4'b1001
`define XOR     4'b1010
`define SLTU    4'b1011
`define NOR     4'b1100
`define SRA     4'b1101
`define LUI     4'b1110
`define FUNC    4'b1111


module PipelinedControl(UseShamt, func, UseImmed,RegDst, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, Jump, SignExtend, ALUOp, Opcode, Bubble);
//module PipelinedControl(UseImmed,RegDst, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, Jump, SignExtend, ALUOp, Opcode, Bubble);
   input [5:0] Opcode;
   input [5:0] func;
   input Bubble;
   output UseShamt; 
   output UseImmed;
   output RegDst;
   output ALUSrc;
   output MemToReg;
   output RegWrite;
   output MemRead;
   output MemWrite;
   output Branch;
   output Jump;
   output SignExtend;
   output [3:0] ALUOp;
	 
	reg	RegDst, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, Jump, SignExtend, UseShamt,UseImmed;
	reg  [3:0] ALUOp;
	always @ (Opcode or Bubble or func) begin
		if(Bubble) begin
			//Put your code here!
			RegDst <= 0;ALUSrc <=  0;MemToReg <=  0;
            RegWrite <=  0;MemRead <= 0;MemWrite <=  0;
            Branch <= 0;Jump <= 0;SignExtend <=  1'b0;
            ALUOp <= `FUNC;
            UseShamt <=1'b0;
            UseImmed<=1'b0;
		end
		else begin
			case(Opcode)
		      	   `RTYPEOPCODE: begin
               		    	RegDst <=  1;
                	    	ALUSrc <=  0;
                	    	MemToReg <=  0;
                	   	 RegWrite <=  1;
                	    	MemRead <=  0;
                	    	MemWrite <=  0;
                	    	Branch <=  0;
                	    	Jump <=  0;
                	    	SignExtend <=  1'b0;
                	    	ALUOp <=  `FUNC;
                	        UseShamt = (func == 6'b000010 || func == 6'b000011 ||func == 6'b000000) ? 1'b1 : 1'b0;
                	         UseImmed<=0;
            		    end
            /*add your code here. Reuse your code from lab 10 from the file Lab10_SingleCycleControl.v */
           `LWOPCODE: begin
                RegDst <= 0;ALUSrc <=  1;MemToReg <=  1;
                RegWrite <=  1;MemRead <= 1;MemWrite <=  0;
                Branch <= 0;Jump <= 0;SignExtend <=  1'b1;
                ALUOp <= `ADD;
                UseShamt <=1'b0;
                UseImmed<=1'b1;
            end
            `SWOPCODE: begin
                RegDst <= 0;ALUSrc <= 1;MemToReg <= 0;
                RegWrite <= 0;MemRead <= 0;MemWrite <= 1;
                Branch <= 0;Jump <= 0;SignExtend <= 1'b0;
                ALUOp <= `ADD;
                UseShamt <=0;
                UseImmed<=1'b1;
            end      
            `BEQOPCODE: begin
                RegDst <= 0;ALUSrc <= 0;MemToReg <=  0;
                RegWrite <= 0;MemRead <= 0;MemWrite <=  0;
                Branch <= 1;Jump <=  0;SignExtend <= 1'b1;
                ALUOp <= `SUB;
                 UseShamt <=0;
                 UseImmed<=1'b0;                
            end        
            `JOPCODE: begin
                    RegDst <= 0;ALUSrc <= 0;MemToReg <= 0;
                    RegWrite <= 0;MemRead <=  0;MemWrite <= 0;
                    Branch <=  0;Jump <=  1;SignExtend <=  1'b0;
                    ALUOp <= `AND;
                     UseShamt <=0;
                     UseImmed<=0;
                end              
            `ORIOPCODE: begin
                    RegDst <= 0; ALUSrc <= 1;MemToReg <= 0;
                    RegWrite <=  1; MemRead <=0;MemWrite <=  0;
                    Branch <= 0;Jump <= 0;SignExtend <= 1'b0;
                    ALUOp <= `OR;
                     UseShamt <=0;
                     UseImmed<=1'b1;
                end      
            `ADDIOPCODE : begin
                RegDst <= 0;ALUSrc <= 1;MemToReg <= 0;
                RegWrite <= 1;MemRead <= 0;MemWrite <=0;
                Branch <= 0; Jump <= 0;SignExtend <= 1'b1;
                ALUOp <=  `ADD;
                UseShamt <=0;
               UseImmed<=1'b1;
            end  
            `ADDIUOPCODE: begin
                RegDst <= 0;ALUSrc <= 1;MemToReg <= 0;
                RegWrite <= 1;MemRead <= 0;MemWrite <= 0;
                Branch <= 0;Jump <= 0;SignExtend <= 1'b0;
                ALUOp <= `ADDU;
                 UseShamt <=0;
                 UseImmed<=1'b1;
            end
            `ANDIOPCODE: begin
                RegDst <= 0;ALUSrc <= 1;MemToReg <=  0;
                RegWrite <= 1;MemRead <=  0;MemWrite <= 0;
                Branch <= 0;Jump <=  0;SignExtend <= 1'b0;
                ALUOp <= `AND;
                 UseShamt <=0;
                 UseImmed<=1'b1;
            end
            `LUIOPCODE: begin
                RegDst <= 0;ALUSrc <= 1;MemToReg <=  0;
                RegWrite <= 1;MemRead <= 0;MemWrite <=  0;
                Branch <= 0;Jump <= 0;SignExtend <= 1'b1;
                ALUOp <= `LUI;
                 UseShamt <=0;
                 UseImmed<=1'b1;
            end  
            `SLTIOPCODE: begin
                RegDst <= 0;ALUSrc <= 1;MemToReg <= 0;
                RegWrite <=  1;MemRead <=  0;MemWrite <= 0;
                Branch <= 0;Jump <= 0;SignExtend <= 1'b1;
                ALUOp <= `SLT;
                 UseShamt <=0;
                 UseImmed<=1'b1;
            end 
            `SLTIUOPCODE : begin
                RegDst <=0;ALUSrc <= 1;MemToReg <= 0;
                RegWrite <=  1;MemRead <=  0;MemWrite <=  0;
                Branch <= 0;Jump <= 0;SignExtend <=  1'b1;
                ALUOp <= `SLTU;
                 UseShamt <=0;
                 UseImmed<=1'b1;
            end 
            `XORIOPCODE: begin
                RegDst <= 0; ALUSrc <= 1; MemToReg <= 0;
                RegWrite <=1;MemRead <= 0;MemWrite <= 0;
                Branch <= 0;Jump <=  0;SignExtend <= 1'b0;
                ALUOp <= `XOR;
                 UseShamt <=0;
                 UseImmed<=1'b1;
            end 
           	            default: begin
                	    	RegDst <= #2 1'bx;
                	    	ALUSrc <= #2 1'bx;
                	    	MemToReg <= #2 1'bx;
                	    	RegWrite <= #2 1'bx;
                	    	MemRead <= #2 1'bx;
                	    	MemWrite <= #2 1'bx;
                	    	Branch <= #2 1'bx;
                	    	Jump <= #2 1'bx;
                	    	SignExtend <= #2 1'bx;
                	    	ALUOp <= #2 4'bxxxx;
                            // UseShamt <=1'bx;
                             UseImmed<=1'bx;
            		   end
			endcase
		end
	end
endmodule
