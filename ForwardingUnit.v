`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/02/2022 12:46:11 PM
// Design Name: 
// Module Name: ForwardingUnit
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


//module ForwardingUnit(UseShamt,UseImmed, ID_Rs, ID_Rt, EX_Rw, MEM_Rw, EX_RegWrite, MEM_RegWrite, AluOpCtrlA, AluOpCtrlB, 
//						DataMemForwardCtrl_EX, DataMemForwardCtrl_MEM);
module ForwardingUnit(UseShamt , UseImmed , ID_Rs , ID_Rt , EX_Rw , MEM_Rw,
  EX_RegWrite , MEM_RegWrite , AluOpCtrlA , AluOpCtrlB , DataMemForwardCtrl_EX ,DataMemForwardCtrl_MEM );						
	
	input UseImmed, UseShamt; //Input/Output Declarations
	input [4:0] ID_Rs, ID_Rt, EX_Rw, MEM_Rw;
	input EX_RegWrite, MEM_RegWrite;
	output reg [1:0]AluOpCtrlA, AluOpCtrlB;
	output reg DataMemForwardCtrl_EX, DataMemForwardCtrl_MEM;
	
	//Logic for AluOpCtrl_A
	always @(*) 
		begin
			if (UseShamt == 0 /*&& (EX_Rw != 0 || MEM_Rw != 0 )*/)
				begin
					//Select data from Writeback Stage to Forward to ALU
					if (ID_Rs == MEM_Rw && (MEM_Rw != EX_Rw || EX_RegWrite == 0) && MEM_RegWrite == 1) AluOpCtrlA <= 2'b11;
					//Select Data from ALU output to forward to ALU Input
					else if (ID_Rs == EX_Rw && EX_RegWrite == 1) AluOpCtrlA <= 2'b10;
					//Select Register Data as ALU Input
					else AluOpCtrlA <= 2'b01;
				end
			else if (UseShamt == 1) AluOpCtrlA <= 2'b01;
			else AluOpCtrlA <= 2'b01;	
	
		end
	
	//Logic for AluOpCtrl_B	
	always @(*) 
		begin
			if (UseImmed == 0 /*&& (EX_Rw != 0 || MEM_Rw != 0 )*/)
				begin
					//Select data from Writeback stage as input
					if (ID_Rt == MEM_Rw && (MEM_Rw != EX_Rw || EX_RegWrite == 0) && MEM_RegWrite == 1) AluOpCtrlB <= 2'b11;
					//Select data from ALU output as ALU input
					else if (ID_Rt == EX_Rw && EX_RegWrite == 1) AluOpCtrlB <= 2'b10;
					else AluOpCtrlB <= 2'b01;
				end
			else if (UseImmed == 1) AluOpCtrlB <= 2'b01;
			else AluOpCtrlB <= 2'b01;
		end
	
	//Logic for DataMemForwardCtrl_EX and DataMemForwardCtrl_MEM
	always @(*) 
		begin
			if(MEM_RegWrite == 1 && ID_Rt == MEM_Rw)
				begin
					DataMemForwardCtrl_EX <= 1'b1; //Select Data from WriteBack stage to write into memory 
					DataMemForwardCtrl_MEM <= 1'b0;
				end
			else
				begin
					if(EX_RegWrite == 1 && ID_Rt == EX_Rw)	
						begin
							DataMemForwardCtrl_EX <= 1'b0; //Select Register Write data to data from previous stage to write
							DataMemForwardCtrl_MEM <= 1'b1;
						end
					else
						begin
							DataMemForwardCtrl_EX <= 1'b0;
							DataMemForwardCtrl_MEM <= 1'b0;
						end
				end	
		end
endmodule

//  module ForwardingUnit(UseShamt , UseImmed , ID_Rs , ID_Rt , EX_Rw , MEM_Rw,
//  EX_RegWrite , MEM_RegWrite , AluOpCtrlA , AluOpCtrlB , DataMemForwardCtrl_EX ,DataMemForwardCtrl_MEM ) ;


//  input UseShamt , UseImmed ;
//  input [4 : 0] ID_Rs , ID_Rt , EX_Rw , MEM_Rw;
//  input EX_RegWrite , MEM_RegWrite ;
//  output reg [1:0] AluOpCtrlA , AluOpCtrlB ;
//  output reg DataMemForwardCtrl_EX , DataMemForwardCtrl_MEM ;



//  // always@(EX_RegWrite or MEM_RegWrite or MEM_Rw or EX_Rw or ID_Rs or ID_Rt)
//  // begin
//  // if (!UseShamt && MEM_Rw != 0 && EX_Rw!=0)
//  //     begin
//  //     if ((ID_Rs == MEM_Rw) && (EX_Rw != MEM_Rw) && MEM_RegWrite)
//  //          begin
//  //          AluOpCtrlA = 2'b11;
//  //          end
//  //     else if ((ID_Rs == EX_Rw) && (EX_RegWrite == 1))
//  //         begin
//  //          AluOpCtrlA = 2'b10;
//  //         end
//  //     else
//  //         AluOpCtrlA = 2'b01;
//  //     end
   
//  // else if (UseShamt)

//  //     begin
//  //         AluOpCtrlA = 2'b00;
//  //     end
   
//  //     else
//  //     begin
//  //         AluOpCtrlA = 2'b01;
//  //     end
//  // end


//  always@(EX_RegWrite or MEM_RegWrite or MEM_Rw or EX_Rw or ID_Rs or ID_Rt)
//  begin
//  if (!UseShamt && MEM_Rw != 0 && EX_Rw!=0)
//      begin
//      if ((ID_Rs == EX_Rw) && (EX_RegWrite == 1))
//           begin
//           AluOpCtrlA = 2'b10;
//           end
//      else if ((ID_Rs == MEM_Rw) && (MEM_RegWrite == 1))
//          begin
//           AluOpCtrlA = 2'b11;
//          end
//      else
//          AluOpCtrlA = 2'b01;
//      end
   
//  else if (UseShamt)

//      begin
//          AluOpCtrlA = 2'b00;
//      end
   
//      else
//      begin
//          AluOpCtrlA = 2'b01;
//      end
//  end



// //  always@(*)
// //  begin
// //  if (!UseImmed && MEM_Rw != 0 && EX_Rw!=0)
// //      begin
// //      if ((ID_Rt == MEM_Rw) && (EX_Rw != MEM_Rw) && MEM_RegWrite)
// //           begin
// //           AluOpCtrlB = 2'b11;
// //           end
// //      else if ((ID_Rt == EX_Rw) && (EX_RegWrite == 1))
// //           AluOpCtrlB = 2'b10;
// //      else
// //          AluOpCtrlB = 2'b01;
// //      end
   
// //  else if (UseImmed)
// //          AluOpCtrlB = 2'b00;
// //      else
// //          AluOpCtrlB = 2'b01;
// //  end


//  always@(*)
//  begin
//  if (!UseImmed && MEM_Rw != 0 && EX_Rw!=0)
//      begin
//      if ((ID_Rt == EX_Rw)  && (EX_RegWrite == 1))
//           begin
//           AluOpCtrlB = 2'b10;
//           end
//      else if ((ID_Rt == MEM_Rw) && (MEM_RegWrite == 1))
//           AluOpCtrlB = 2'b11;
//      else
//          AluOpCtrlB = 2'b01;
//      end
   
//  else if (UseImmed)
//          AluOpCtrlB = 2'b00;
//      else
//          AluOpCtrlB = 2'b01;
//  end




//  always@(*)
//  begin
//  if(MEM_RegWrite == 1 && ID_Rt == MEM_Rw)
//     begin
//       DataMemForwardCtrl_EX = 1'b1;
//       DataMemForwardCtrl_MEM = 1'b0;
//     end

//  else if ((ID_Rt == EX_Rw) && (EX_RegWrite == 1))
//      begin
//           DataMemForwardCtrl_EX = 1'b0;
//           DataMemForwardCtrl_MEM = 1'b1;
//      end
//  else
//      begin
//           DataMemForwardCtrl_EX = 1'b0;
//           DataMemForwardCtrl_MEM = 1'b0;
//      end
//  end


//  endmodule


// module ForwardingUnit(UseShamt, UseImmed, ID_Rs, ID_Rt, EX_Rw, MEM_Rw, EX_RegWrite, MEM_RegWrite, AluOpCtrlA, AluOpCtrlB, DataMemForwardCtrl_EX, DataMemForwardCtrl_MEM);
//   input UseShamt, UseImmed;
//   input [4:0] ID_Rs, ID_Rt, EX_Rw, MEM_Rw;
//   input EX_RegWrite, MEM_RegWrite;
//   output reg [1:0] AluOpCtrlA, AluOpCtrlB;
//   output reg DataMemForwardCtrl_EX, DataMemForwardCtrl_MEM;
  
//   //These four nets check for RAW dependancy.
//   wire ID_RS_written_by_EX_RW;
//   wire ID_RT_written_by_EX_RW;
//   wire ID_RS_written_by_MEM_RW;
//   wire ID_RT_written_by_MEM_RW;
//   assign ID_RS_written_by_EX_RW = (ID_Rs == EX_Rw) && (ID_Rs != 5'b0) && EX_RegWrite;
//   assign ID_RT_written_by_EX_RW = (ID_Rt == EX_Rw) && (ID_Rt != 5'b0) && EX_RegWrite;
//   assign ID_RS_written_by_MEM_RW = (ID_Rs == MEM_Rw) && (ID_Rs != 5'b0) && MEM_RegWrite;
//   assign ID_RT_written_by_MEM_RW = (ID_Rt == MEM_Rw) && (ID_Rt != 5'b0) && MEM_RegWrite;
  
//   always@(*) begin
//     case({ID_RS_written_by_EX_RW, ID_RS_written_by_MEM_RW, UseShamt})
//       3'b000: begin
//         AluOpCtrlA = 2'b01;
//       end
//       3'b100: begin //100 or 110, since execute stage takes precedence over memory stage.
//         AluOpCtrlA = 2'b10;
//       end
//       3'b110: begin //100 or 110, since execute stage takes precedence over memory stage.
//         AluOpCtrlA = 2'b10;
//       end
//       3'b010: begin
//         AluOpCtrlA = 2'b11;
//       end
//       3'b001: begin
//         /*if(ID_Rs == 5'b0) begin
//           AluO*/
//           AluOpCtrlA = 2'b01;
//         //end
//       end
//       3'b011: begin
//         /*if(ID_Rs == 5'b0) begin
//           AluOpCtrlA = 2'b00;
//         end
//         else begin*/
//           AluOpCtrlA = 2'b00;
//         //end
//       end
//       3'b101: begin
//         /*if(ID_Rs == 5'b0) begin
//           AluOpCtrlA = 2'b00;
//         end
//         else begin*/
//           AluOpCtrlA = 2'b00;
//         //end
//       end
//       3'b111: begin
//         /*if(ID_Rs == 5'b0) begin
//           AluOpCtrlA = 2'b00;
//         end
//         else begin*/
//           AluOpCtrlA = 2'b00;
//         //end
//       end
//     endcase
    
//     case({ID_RT_written_by_EX_RW, ID_RT_written_by_MEM_RW, UseImmed})
//       3'b000: begin
//         AluOpCtrlB = 2'b01;
//       end
//       3'b100: begin //100 or 110, since execute stage takes precedence over memory stage.
//         AluOpCtrlB = 2'b10;
//       end
//       3'b110: begin //100 or 110, since execute stage takes precedence over memory stage.
//         AluOpCtrlB = 2'b10;
//       end
//       3'b010: begin
//         AluOpCtrlB = 2'b11;
//       end
//       3'b001: begin
//         if(ID_Rt == 5'b0) begin
//           AluOpCtrlB = 2'b01;
//         end
//         else begin
//           AluOpCtrlB = 2'b00;
//         end
//       end
//       3'b011: begin
//         if(ID_Rt == 5'b0) begin
//           AluOpCtrlB = 2'b01;
//         end
//         else begin
//           AluOpCtrlB = 2'b00;
//         end
//       end
//       3'b101: begin
//         if(ID_Rt == 5'b0) begin
//           AluOpCtrlB = 2'b01;
//         end
//         else begin
//           AluOpCtrlB = 2'b00;
//         end
//       end
//       3'b111: begin
//         if(ID_Rt == 5'b0) begin
//           AluOpCtrlB = 2'b01;
//         end
//         else begin
//           AluOpCtrlB = 2'b00;
//         end
//       end
//     endcase
    
//     case({ID_RT_written_by_EX_RW, ID_RT_written_by_MEM_RW})
//       2'b00: begin
//         DataMemForwardCtrl_EX = 1'b0;
//         DataMemForwardCtrl_MEM = 1'b0;
//       end
//       2'b01: begin
//         DataMemForwardCtrl_EX = 1'b1;
//         DataMemForwardCtrl_MEM = 1'b0;
//       end
//       2'b11: begin
//         DataMemForwardCtrl_EX = 1'b1;
//         DataMemForwardCtrl_MEM = 1'b0;
//       end
//       2'b10: begin
//         DataMemForwardCtrl_EX = 1'b0;
//         DataMemForwardCtrl_MEM = 1'b1;
//       end
//     endcase
//   end  
// endmodule