`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/02/2022 04:08:59 PM
// Design Name: 
// Module Name: Hazard
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


module Hazard( IFwrite, PC_write, bubble , addrSel, Jump , Branch , ALUZero ,
memReadEX , currRs , currRt , prevRt , UseShamt , UseImmed , Clk , Rst ) ;

output reg IFwrite , PC_write , bubble ;
output reg [1:0] addrSel ;
input Jump , Branch , ALUZero , memReadEX , Clk , Rst ;
input UseShamt , UseImmed ;
input [ 4 : 0 ] currRs , currRt , prevRt ;
	
	/*state definition for FSM*/
				parameter NoHazard_state = 3'b000;
				parameter Branch0_state = 3'b001;
				parameter Branch1_state = 3'b010;
				parameter Jump_state = 3'b011;
				parameter LoadHazard_state = 3'b100;
				/*Define a name for each of the states so it is easier to 					debug and follow*/ 
				 
	
	
	
	/*internal state*/
	reg [2:0] FSM_state, FSM_nxt_state;
	reg [4:0] rw1; //rw history registers
	
	/*create compare logic*/
	//assign  cmp1 = (((currRs==rw1)||(currRs==rw1))&&(prevRt!= 0)) ? 1:0;
	/* cmp1 finds the dependancy btween current instruction and theonebefore make 	cmpx if needed*/

reg LdHazard;
//assign LdHazard = (prevRt == currRt) ? (memReadEX & !UseImmed) : ((prevRt == currRs) ? (memReadEX & !UseShamt) : 0);


 	always @ (*) begin //Check for Load Hazard based on Comparision of Source registers with previous instructions
 		if (prevRt != 0) begin
 			if ((currRs == prevRt || currRt == prevRt) && memReadEX == 1'b1 && UseImmed == 1'b0 && UseShamt == 1'b0) LdHazard <= 1'b1;
 			else if (UseShamt == 1'b1 && currRs == prevRt && memReadEX == 1'b1) LdHazard <= 1'b1;
 			else if (UseImmed == 1'b1 && currRs == prevRt && memReadEX == 1'b1) LdHazard <= 1'b1;
 			else LdHazard <= 1'b0;
 		end
 		else LdHazard <= 1'b0;
 	end



//reg LdHazard
// always@(*)
// begin
//    if(prevRt!=0)
//    begin
//     case({memReadEX,UseShamt,UseImmed})
//     3'b100:
//         begin
//             if(prevRt==currRs || prevRt== currRt)
//                 LdHazard<=1;
//             else
//                 LdHazard<=0;   
//         end
//     3'b110:
//         begin
//             if(prevRt==currRs)
//             LdHazard<=1;
//         else
//             LdHazard<=0;              
//         end
//     3'b101:
//         begin
//             if(prevRt==currRs)
//             LdHazard<=1;
//         else
//             LdHazard<=0;              
//         end
//     default:
//         begin
// 			LdHazard<=0;
//         end
//    endcase
//    end
//    else
//     LdHazard<=0;
// end




	
		
	/*FSM state register*/
	always @(negedge Clk) begin
		if(Rst == 0) 
			FSM_state <= 0;
		else
			FSM_state <= FSM_nxt_state; //Assign Next State to FSM if Reset is not Applied
	end
	
	/*FSM next state and output logic*/
	always @(*) begin //combinatory logic
		case(FSM_state)
			NoHazard_state: begin 
				if(!LdHazard && !Jump && !Branch) begin  //No Hazard Stay in Same State
					IFwrite = 1;
					PC_write = 1;
					bubble   = 0;
					addrSel  = 2'b00;
					FSM_nxt_state = NoHazard_state;
				end 
				else if(LdHazard) begin //Load Hazard -> Jump to Corresponding State
					IFwrite = 1;
					PC_write = 1;
					bubble = 0;
					//bubble = (LdHazard && prevRt == currRt) ? 2'b01 : 2'b10;
					addrSel  = 2'b00; //Sending this value for no operation.
					FSM_nxt_state = LoadHazard_state;
				end
				else if(Jump== 1'b1 )//&& LdHazard==0 && Branch==0) begin //prioritize jump
					begin
					FSM_nxt_state <=  Jump_state;  //Jump Detected Set Next State to Jump
                    IFwrite <= 1; 
                    PC_write <= 1;
                    bubble <= 0;
                    addrSel <= 2'b00;
				end
				else if(Branch)
				begin
                    FSM_nxt_state <=  Branch0_state; //Branch Condition Encountered, Enter Branch decision Phase
                    IFwrite <= 1; 
                    PC_write <= 1;
                    bubble <= 0;
                    addrSel <= 2'b00;				    
				end

				else
				begin
                    FSM_nxt_state <=  NoHazard_state; // If No Condition is Met stay in same
                    IFwrite <= 1; 
                    PC_write <= 1;
                    bubble <= 0;
                    addrSel <= 2'b00;
				end
			end
			Branch0_state: begin
			     if(ALUZero==1)// && Branch==1) //Branch is not Taken
			     begin
                     FSM_nxt_state <=  Branch1_state; //Go to Branch Taken Phase
                     IFwrite <= 0; 
                     PC_write <= 0;
                     bubble <= 1;
                     addrSel <= 2'b00;			         
			     end
			     else
			     begin
                      FSM_nxt_state <=  NoHazard_state;//Branch1_state;//NoHazard_state
                      IFwrite <= 1; 
                      PC_write <= 1;
                      bubble <= 1;
                      addrSel <= 2'b00;    
			     
			     end
			end
			Branch1_state: begin //Return to No-Hazard State branch is resolved
                         FSM_nxt_state <=  NoHazard_state;
                         IFwrite <= 1; 
                         PC_write <= 1;
                         bubble <= 0;
                         addrSel <= 2'b10;   
                     
            end
            
            Jump_state: begin //In Jump State, get back to No Hazard
                         FSM_nxt_state <=  NoHazard_state;
                         IFwrite <= 1; 
                         PC_write <= 0;
                         bubble <= 1;
                         addrSel <= 2'b01;             
            end
			LoadHazard_state: begin //Return to No Hazard State from Load State
				FSM_nxt_state <=  NoHazard_state;
				IFwrite <= 0; 
				PC_write <= 0;
				bubble <= 1;
				addrSel <= 2'b00; 
			end
			
			default: begin
				FSM_nxt_state <=  NoHazard_state;
				PC_write <=  1'bx;
				IFwrite <=  1'bx;
				bubble  <=  1'bx;
				addrSel <= 2'bxx;
			end
		endcase
	end
endmodule

// `define NO_HAZARD  3'b000
// `define DATA_HAZARD 3'b001
// `define JUMP   3'b010
// `define BRANCH_0   3'b011
// `define BRANCH_1   3'b100

// module HazardUnit(IF_Write, PC_Write, bubble, addrSel, Jump, Branch, ALUZero, memReadEX, currRs, currRt, prevRt, UseShamt, UseImmed, Clk, Rst);

// output reg IF_Write, PC_Write, bubble;
// output reg [1:0]addrSel;
// input Jump,Branch, ALUZero, memReadEX, Clk, Rst;
// input UseImmed, UseShamt;
// input [4:0] currRt, currRs, prevRt;

// reg DATA_HAZARD; //register containing state of load related RAW hazard

// reg [2:0] current_state, next_state;

// //Load related RAW data hazard detection logic
// always @ (*) begin
// if (prevRt != 0) begin
// if ((currRs == prevRt || currRt == prevRt) && memReadEX == 1'b1 && UseImmed == 1'b0 && UseShamt == 1'b0) DATA_HAZARD <= 1'b1; // checking for prev rt and present rt or source is previous instruction destination
// else if (UseShamt == 1'b1 && currRs == prevRt && memReadEX == 1'b1) DATA_HAZARD <= 1'b1; // checking if  source is previous instruction destination and use shamt == 1
// else if (UseImmed == 1'b1 && currRs == prevRt && memReadEX == 1'b1) DATA_HAZARD <= 1'b1; // checking if source is previous instruction destination and use immed == 1
// else DATA_HAZARD <= 1'b0;
// end
// else DATA_HAZARD <= 1'b0;
// end

// //FSM for hazard detection unit
//     // sequential logic
// always @(posedge Clk, negedge Rst) begin
// if (!Rst) begin
// current_state <= `NO_HAZARD;
// end
// else begin
// current_state <= next_state;
// end
// end

// //logic for state change and output (Combinational)
// always @(*) begin
// case (current_state)
// `NO_HAZARD : begin
// if (DATA_HAZARD == 1'b1) next_state <= `DATA_HAZARD; // If data_hard then move to data_hazard state
// else if (Jump == 1'b1) next_state <= `JUMP; // If jump is 1 move to jump state
// else if (Branch == 1'b1) next_state <= `BRANCH_0; // if branch is 1 move to branch state
// else next_state <= `NO_HAZARD; // else same

// PC_Write <= 1'b1; // 1 -> normal
// IF_Write <= 1'b1; // 1 -> normal
// bubble <= 1'b0; // normal
//                             addrSel <= 2'b00; // PC+4
// end

// `DATA_HAZARD :begin
// next_state <= `NO_HAZARD;

// PC_Write <=1'b0; // 0 -> prev PC
// IF_Write <=1'b0; // 0 -> prev instruction
// bubble <= 1'b1;  // 1 -> stall at EX
// addrSel <= 2'b00; //pc+4
// end

// `JUMP :begin
// next_state <= `NO_HAZARD;

// PC_Write <=1'b1; // 1 -> normal
// IF_Write <=1'b0; // 0 -> prev instruction
// bubble <= 1'b1; // 1 -> stall at Ex
// addrSel <= 2'b01; //JUMP Target
// end

// `BRANCH_0   :begin
// if (!ALUZero) next_state <= `NO_HAZARD; // no hazard state
// else next_state <= `BRANCH_1; // Branch another state becuase of penalty
// PC_Write <=1'b0; // 0 -> prev PC
// IF_Write <=1'b0; // 0 -> prev instruction
// bubble <= 1'b1; // 1 -> stall at EX
//                             addrSel <= 2'b00; //pc+4
// end

// `BRANCH_1   :begin
// next_state <= `NO_HAZARD;
// PC_Write <=1'b1; // 1 -> normal
// IF_Write <=1'b0; // 0 -> prev instruction
// bubble <= 1'b1; // 1 -> stall at Ex PC_Write <=1'b1;
//                             addrSel <= 2'b10; //Branch Target
// end
// default   :begin
// PC_Write <=1'b0; // 0 -> prev PC
// IF_Write <=1'b0; // 0 -> prev instruction
// bubble <= 1'b1;  // 1 -> stall at EX
// addrSel <= 2'b00; //pc+4
// end
// endcase
// end

// endmodule


 