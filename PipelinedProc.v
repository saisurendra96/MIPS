`timescale 1ns / 1ps


module PipelinedProc(CLK, Reset_L, startPC, dMemOut);
	input CLK;
	input Reset_L;
	input [31:0] startPC;
	output [31:0] dMemOut;

    //Hazard Controls
	wire Bubble;
	wire PCWrite;
	wire IFWrite;
	

    //Stage 1 Signals
	wire	[31:0]	currentPCPlus4;
	wire	[31:0]	jumpDescisionTarget;
	reg	[31:0]	nextPC;
	reg	[31:0]	currentPC;
	wire	[31:0]	currentInstruction;

    //Stage2 Signals
    reg [31:0] currentInstruction2;
//se
    wire	[5:0]	opcode;
	wire	[4:0]	rs, rt, rd;
	wire	[15:0]	imm16;
	wire	[4:0]	shamt;
	wire	[5:0]	func;
	wire	[31:0]	busA, busB, ALUImmRegChoice, signExtImm;
	wire	[31:0]	jumpTarget;
	wire [1:0] addrSel;
    wire	regDst, aluSrc, memToReg, regWrite, memRead, memWrite, branch, jump, signExtend;
	wire UseShamt, UseImmed;
	wire	UseShiftField;
	wire	rsUsed, rtUsed;
	wire	[4:0]	rw;
	wire	[3:0]	aluOp;
	wire	[31:0]	ALUBIn;
	wire	[31:0]	ALUAIn;
	wire    [31:0]  currentPCPlus42;

	//Stage 3 Signals
	reg	[31:0]	ALUAIn3, ALUBIn3, busB3, signExtImm3;
	reg	[4:0]	rw3;
	reg	[5:0]	func3;
	reg [31:0] currentPC2;
	reg [31:0] currentPC3;
	reg [31:0] WriteData3;
	reg [1:0] AluOpCtrlA3;
	reg [1:0] AluOpCtrlB3;
	reg [25:0] instr25to0_3;
	wire	[31:0]	shiftedSignExtImm;
	wire	[31:0]	branchDst;
	wire	[3:0]	aluCtrl;
	wire	aluZero;
	wire	[31:0]	aluOut;
	//Stage 3 Control Signals
	reg	regDst3, memToReg3, regWrite3, memRead3, memWrite3, branch3;
	reg	[3:0]	aluOp3;
	reg DataMemForwardCtrl_EX3;
	reg DataMemForwardCtrl_MEM3;

	//Stage 4 Signals
	reg	aluZero4;
	reg	[31:0]	branchDst4, aluOut4, busB4;
	reg	[4:0]	rw4;
	wire	[31:0]	memOut;
	reg [31:0] WriteData4_EX;
	reg [31:0] WriteData4;

	assign dMemOut = memOut;

	//Stage 4 Control Signals
	reg memToReg4, regWrite4, memRead4, memWrite4, branch4;
	reg DataMemForwardCtrl_MEM4;
	
	//Stage 5 Signals
	reg	[31:0]	memOut5, aluOut5;
	reg	[4:0]	rw5;
	wire	[31:0]	regWriteData;
	
	//Stage 5 Control
	reg memToReg5, regWrite5;

	//Wires for Forwarding Unit
	wire [1:0] AluOpCtrlA,AluOpCtrlB;
	reg [31:0] BusA, BusB; //For Implementing ALU mUx
	wire DataMemForwardCtrl_EX, DataMemForwardCtrl_MEM;
	

	//Stage 1 Logic

//	assign jumpDescisionTarget = (jump & (IFWrite==0)) ? jumpTarget : currentPCPlus4;
//		assign jumpDescisionTarget = jumpTarget;
	assign jumpDescisionTarget = (jump ) ? jumpTarget : currentPCPlus4;

	always @ (negedge CLK) begin
        if(~Reset_L)
			currentPC = startPC;
		else if(PCWrite)
			currentPC = nextPC; //Assign nectPC if not reset .
	    else
	       currentPC <= currentPC; 
    end
    
	assign  currentPCPlus4 = currentPC + 4; //Intermediate PC+4 to compute next PC.


	always@(*)
	begin
	case(addrSel) //Select value to be updated to PC based on addrSel Control Signal.
	2'b00: nextPC <= currentPCPlus4;
	2'b01: nextPC <= jumpDescisionTarget;
	2'b10: nextPC <= branchDst4;//branchDst4 modified as branchDst
	2'b11: nextPC <= nextPC;
	default: nextPC <= currentPCPlus4;
	endcase
	end
	//Instantiate the Instruction Memory Module
	InstructionMemory instrMemory(currentInstruction, currentPC);
	
	


    //Stage 2 Logic Decode Phase
	always @ (negedge CLK or negedge Reset_L) begin
		if(~Reset_L)
			begin
			currentInstruction2 = 32'b0;
			currentPC2 = 32'b0;
			end
		else if(IFWrite) begin //Latch to data from IF Stage
			currentInstruction2 = currentInstruction; 
			currentPC2 = currentPC;
		end
	end
	assign currentPCPlus42 = currentPCPlus4;
    assign {opcode, rs, rt, rd, shamt, func} = currentInstruction2;
	assign imm16 = currentInstruction2[15:0]; //16-bit Immediate Value

	//Instantiate Register File
	RegisterFile Registers( .BusA(busA) ,.BusB(busB), .BusW(regWriteData), .RA(rs), .RB(rt), .RW(rw5), .RegWr(regWrite5), .Clk(CLK));
	//Instantiate Pipelined Controller
    PipelinedControl controller(.UseShamt(UseShamt), .func(func),.UseImmed(UseImmed),.RegDst(regDst), .ALUSrc(aluSrc), .MemToReg(memToReg), .RegWrite(regWrite), 
	                           .MemRead(memRead), .MemWrite(memWrite), .Branch(branch), .Jump(jump), .SignExtend(signExtend), .ALUOp(aluOp), .Opcode(opcode), .Bubble(Bubble));
	
	
	ForwardingUnit ForwardingUnitForPipeline(.UseShamt(UseShamt) ,  .UseImmed(UseImmed) , .ID_Rs(rs) , .ID_Rt(rt) , .EX_Rw(rw3) , .MEM_Rw(rw4),
                    .EX_RegWrite(regWrite3) , .MEM_RegWrite(regWrite4) , .AluOpCtrlA(AluOpCtrlA) , .AluOpCtrlB(AluOpCtrlB) , .DataMemForwardCtrl_EX(DataMemForwardCtrl_EX) ,.DataMemForwardCtrl_MEM(DataMemForwardCtrl_MEM) ) ; //Check UseShamt, UsezImmed LAter
	
	//Intsantiate Hazard Detection Unit
	Hazard hazard(.IFwrite(IFWrite), .PC_write(PCWrite), .bubble(Bubble), .addrSel(addrSel), .Jump(jump), .Branch(branch), .ALUZero(aluZero), .memReadEX(memRead3),
	             .currRs(rs), .currRt(rt), .prevRt(rw3 ), .UseShamt(UseShamt), .UseImmed(UseImmed), .Clk(CLK), .Rst(Reset_L)
				 );
	//Sign Extension for Immediate value.
	SignExtender immExt(.signExtImm(signExtImm), .imm16(imm16), .signExtend(signExtend));
	

	//Logic For Jump Address
	assign jumpDistance = {currentInstruction2[25:0], 2'b00};
	assign jumpTarget = {currentPCPlus42[31:28], jumpDistance};//PC value for JUMP
//	assign jumpTarget = {currentPCPlus42[31:28], currentInstruction2[25:0], 2'b00};
	assign  rw = regDst ? rd : rt; //MUX to select Register to write
	assign UseShiftField = ((aluOp == 4'b1111) && ((func == 6'b000000) || (func == 6'b000010) || (func == 6'b000011)));
	assign  rsUsed = (opcode != 6'b001111/*LUI*/) & ~UseShiftField;
	assign  rtUsed = (opcode == 6'b0) || branch || (opcode == 6'b101011/*SW*/);
	//Mux to selectt busB or SignExtended Immediate value for ALU
	assign  ALUImmRegChoice = aluSrc ? signExtImm : busB;
	assign  ALUAIn = UseShiftField ? busB : busA; //MUX to select ALU input A based on ShiftField
	assign  ALUBIn = UseShiftField ? {27'b0, shamt} : ALUImmRegChoice; //Modify ALU as BusA shift BusB


	//Stage 3 Logic
	always @ (negedge CLK or negedge Reset_L) begin
		if(~Reset_L) begin
			ALUAIn3 <= 0;
			ALUBIn3 <= 0;
			busB3 <= 0;
			signExtImm3 <= 0;
			rw3 <= 0;
			regDst3 <= 0;
			memToReg3 <= 0;
			regWrite3 <= 0;
			memRead3 <= 0;
			memWrite3 <= 0;
			branch3 <= 0;
			aluOp3 <= 0;
			DataMemForwardCtrl_EX3 <=0;
			DataMemForwardCtrl_MEM3 <= 0; 
			AluOpCtrlA3 <= 0;
			AluOpCtrlB3 <= 0;
			instr25to0_3 <= 0;
			currentPC3 <= 0;
			func3 <= 0;
		end
		else if(Bubble) begin
			ALUAIn3 <= 0;
			ALUBIn3 <= 0;
			busB3 <= 0;
			signExtImm3 <= 0;
			rw3 <= 0;
			regDst3 <= 0;
			memToReg3 <= 0;
			regWrite3 <= 0;
			memRead3 <= 0;
			memWrite3 <= 0;
			branch3 <= 0;
			aluOp3 <= 0;
			DataMemForwardCtrl_EX3 <=0;
			DataMemForwardCtrl_MEM3 <= 0; 
			AluOpCtrlA3 <= 0;
			AluOpCtrlB3 <= 0;
			instr25to0_3 <= 0;
			currentPC3 <= 0;
			func3 <= 0;
		end
		else begin //Latch to data from Decode Stage if rest or bubble are not
			ALUAIn3 <= ALUAIn;
			ALUBIn3 <= ALUBIn;
			busB3 <= busB;
			signExtImm3 <= signExtImm;
			rw3 <= rw;
			regDst3 <= regDst;
			memToReg3 <= memToReg;
			regWrite3 <= regWrite;
			memRead3 <= memRead;
			memWrite3 <= memWrite;
			branch3 <= branch;
			aluOp3 <= aluOp;
			DataMemForwardCtrl_EX3 <= DataMemForwardCtrl_EX;
			DataMemForwardCtrl_MEM3 <= DataMemForwardCtrl_MEM;//Newly Added
			AluOpCtrlA3 <= AluOpCtrlA;
			AluOpCtrlB3 <= AluOpCtrlB; //Kept AluOpCtrlb3
			instr25to0_3 <= currentInstruction2[25:0];
			currentPC3 <= currentPC2;
			func3 <= func;
		end
	end
	
	
	assign shiftedSignExtImm = {signExtImm3[29:0], 2'b0};
	 //Calcualte branch destination address
	assign  branchDst = currentPC3 + shiftedSignExtImm;
	//Instantiate ALU, ALU Control Modules
	ALUControl mainALUControl (.ALUCtrl(aluCtrl), .ALUOp(aluOp3), .FuncCode(func3));
	ALU mainALU(.BusW(aluOut), .Zero(aluZero), .BusA(BusA), .BusB(BusB), .ALUCtrl(aluCtrl));
    
	always@(*)
	begin
		//Select Input A from Register or Forwarding data based on AluOpCtrlA
		case(AluOpCtrlA3) 
		2'b00: BusA <= instr25to0_3[10:6];
		2'b01: BusA <= ALUAIn3; //regWriteData;
		2'b10: BusA <= aluOut4;
		2'b11: BusA <= regWriteData;
		default: BusA <= 'bx;
		endcase
	end 
	always@(*)
	begin
		//Select Input B from Register or Forwarding data based on AluOpCtrlB
		case(AluOpCtrlB3)
		2'b00: BusB <= signExtImm3;
		2'b01: BusB <= ALUBIn3; //regWriteData;
		2'b10: BusB <= aluOut4;
		2'b11: BusB <= regWriteData;
		default: BusB <= 'bx;
		endcase
	end 
	
	//Mux to select Data/Register to Write in Memory
	always@(*)
	begin
	case(DataMemForwardCtrl_MEM3)
	0:  WriteData3 <= busB3;
	1:  WriteData3 <= regWriteData;
	endcase
	end


	//Stage 4 Memory Stage
	always @ (negedge CLK or negedge Reset_L) begin
		if(~Reset_L) begin
			aluZero4 <= 0;
			branchDst4 <= 0;
			aluOut4 <= 0;
			busB4 <= 0;
			rw4 <= 0;
			memToReg4 <= 0;
			regWrite4 <= 0;
			memRead4 <= 0;
			memWrite4 <= 0;
			branch4 <= 0;
			DataMemForwardCtrl_MEM4 <= 0;
			WriteData4_EX <= 0;
		end
		else begin //Latch to data from Execute Stage
			aluZero4 <= aluZero;
			branchDst4 <= branchDst;
			aluOut4 <= aluOut;
			busB4 <= busB3;
			rw4 <= rw3;
			memToReg4 <= memToReg3;
			regWrite4 <= regWrite3;
			memRead4 <= memRead3;
			memWrite4 <= memWrite3;
			branch4 <= branch3;
			DataMemForwardCtrl_MEM4 <= DataMemForwardCtrl_MEM3;
			WriteData4_EX <= WriteData3;
		end
	end
	always@(*)
	begin
		//Select Data to write into Memory based on Control Signal
		case(DataMemForwardCtrl_MEM4) 
		0: WriteData4 <= WriteData4_EX;
		1: WriteData4 <= regWriteData;
		endcase
	end

	//DataMemory dmem(memOut, aluOut4[5:0], busB4, memRead4, memWrite4, CLK);
	DataMemory dmem(.ReadData(memOut), .Address(aluOut4[5:0]), .WriteData(WriteData4), .MemoryRead(memRead4), .MemoryWrite(memWrite4), .Clock(CLK));


	//Stage 5
	always @ (negedge CLK or negedge Reset_L) begin
		if(~Reset_L) begin
			memOut5 <= 0;
			aluOut5 <= 0;
			rw5 <= 0;
			memToReg5 <= 0;
			regWrite5 <= 0;
		end
		else begin //Latch to Data from Memory Phase
			memOut5 <= memOut;
			aluOut5 <= aluOut4;
			rw5 <= rw4;
			memToReg5 <= memToReg4;
			regWrite5 <= regWrite4;
		end
	end
	//Select Data to be Written into Register File Memory O/P or ALU Output
	assign #2 regWriteData = memToReg5 ? memOut5 : aluOut5;

endmodule
