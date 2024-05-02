module ID_EX
(
	clk_i,
	start_i,
	stall_i, 
	inst_i,
	pc_i,
	pcEx_i,
	RegWrite_i,
	MemToReg_i,
	MemRead_i,
	MemWrite_i,
	ALUOp_i,
	ALUSrc_i,
	rd_i,
	data1_i,
	data2_i,
	SignExtended_i,
	RS1addr_i,     
    RS2addr_i,
	RegWrite_o,
	MemToReg_o,
	MemRead_o,
	MemWrite_o,
	ALUOp_o,
	ALUSrc_o,
	inst_o,
	PC_branch_select_i,
	SignExtended_o,
	rd_o,
	PC_branch_select_o,
	pc_o,
	pcEx_o,
	data1_o,
	data2_o,
	RS1addr_o,
	RS2addr_o
);

input	clk_i, stall_i,ALUSrc_i, RegWrite_i, MemToReg_i, MemRead_i, MemWrite_i, start_i; 
input	[31:0]	inst_i, pc_i, data1_i, data2_i, SignExtended_i;
input	[1:0]	ALUOp_i;
input 	[4:0]	rd_i,RS1addr_i,RS2addr_i;
input  [31:0] pcEx_i;
input PC_branch_select_i;

output	ALUSrc_o, RegWrite_o, MemToReg_o, MemRead_o, MemWrite_o;  
output	[31:0]	inst_o, pc_o, data1_o, data2_o, SignExtended_o;
output	[1:0]	ALUOp_o;
output 	[4:0]	rd_o,RS1addr_o,RS2addr_o;
output  [31:0] pcEx_o;
output reg PC_branch_select_o;

reg	ALUSrc_o, RegWrite_o, MemToReg_o, MemRead_o, MemWrite_o;  
reg	[31:0]	inst_o, pc_o, data1_o, data2_o, SignExtended_o,pcEx_o;
reg	[1:0]	ALUOp_o;
reg [4:0]	rd_o,RS1addr_o,RS2addr_o;

always@(posedge clk_i) begin
	if(~start_i) begin
		inst_o <= 0;
		pc_o <= 0 ;
		data1_o <= 0;
		data2_o <= 0;
		SignExtended_o <= 0;
		rd_o <= 0;
		ALUOp_o <= 0;
		ALUSrc_o <= 0;
		RegWrite_o <= 0;
		MemToReg_o <= 0;
		MemRead_o <= 0;
		MemWrite_o <= 0;
		pcEx_o <= 0;
		PC_branch_select_o <=0;
		RS1addr_o <= 0;
		RS2addr_o <= 0;
	end
	else if (stall_i != 1) begin
		inst_o <= inst_i;
		pc_o <= pc_i ;
		data1_o <= data1_i;
		data2_o <= data2_i;
		SignExtended_o <= SignExtended_i;
		rd_o <= rd_i;
		ALUOp_o <= ALUOp_i;
		ALUSrc_o <= ALUSrc_i;
		RegWrite_o <= RegWrite_i;
		MemToReg_o <= MemToReg_i;
		MemRead_o <= MemRead_i;
		MemWrite_o <= MemWrite_i;
		pcEx_o <= pcEx_i;
		PC_branch_select_o <= PC_branch_select_i;
		RS1addr_o <= RS1addr_i;
		RS2addr_o <= RS2addr_i;
	end
end

endmodule



