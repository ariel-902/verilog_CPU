module MEM_WB
(
	clk_i,
	start_i,
	stall_i,
	RegWrite_i,
	MemToReg_i,
	ALUResult_i,
	DataMemReadData_i,
	RDData_i,
	RDaddr_i,
	ALUResult_o,
	RegWrite_o,
	MemToReg_o,
	DataMemReadData_o,
	RDaddr_o
);

input	clk_i, RegWrite_i, MemToReg_i, start_i, stall_i;
input	[31:0]	ALUResult_i, RDData_i, DataMemReadData_i;
input	[4:0]	RDaddr_i;

output	 RegWrite_o, MemToReg_o;
output	[31:0]	ALUResult_o, DataMemReadData_o;

reg	 RegWrite_o, MemToReg_o;
reg	[31:0]	ALUResult_o, DataMemReadData_o;
output reg	[4:0]	RDaddr_o;

always@(posedge clk_i) begin
	if(~start_i) begin
		ALUResult_o <= 0;
		RDaddr_o <= 0;
		RegWrite_o <= 0;
		MemToReg_o <= 0;
		DataMemReadData_o<=0;
	end
	else if (stall_i != 1) begin
		ALUResult_o <= ALUResult_i;
		RDaddr_o <= RDaddr_i;
		RegWrite_o <= RegWrite_i;
		MemToReg_o <= MemToReg_i;
		DataMemReadData_o <= DataMemReadData_i;
	end
end

endmodule






