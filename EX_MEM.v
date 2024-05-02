module EX_MEM(
 clk_i,
 start_i,
 stall_i, 
 RegWrite_i,
 MemToReg_i,
 MemRead_i,
 MemWrite_i,
 data2_i,   
 rd_i,    
 ALUResult_i,
 zero_i,
 pc_i,
 instr_i,
 RegWrite_o,
 MemToReg_o,  
 MemRead_o,
 MemWrite_o,
 data2_o,   
 rd_o,    
 ALUResult_o,
 zero_o,
 pc_o,
 instr_o
);

input     clk_i, zero_i, stall_i, RegWrite_i, MemToReg_i, MemRead_i, MemWrite_i, start_i;
input  [31:0]  pc_i, ALUResult_i, data2_i;
input  [4:0]    rd_i;
input   [31:0]   instr_i;

output   [31:0]   instr_o;
output     zero_o, RegWrite_o, MemToReg_o, MemRead_o, MemWrite_o;
output  [31:0]  pc_o, ALUResult_o, data2_o;
output   [4:0]   rd_o;


reg                  zero_o, RegWrite_o, MemToReg_o, MemRead_o, MemWrite_o;
reg         [31:0]    pc_o, instr_o, data2_o;
reg      [31:0]  ALUResult_o;
reg         [4:0]     rd_o;

always@(posedge clk_i) begin
 if(~start_i) begin
      pc_o <= 0;
      zero_o <= 0;
      ALUResult_o <= 0;
      data2_o <= 0;
      rd_o <= 0;
      RegWrite_o <= 0;
      MemToReg_o <= 0;
      MemRead_o <= 0;
      MemWrite_o <= 0;
      instr_o <= 0;
 end
 else if (stall_i != 1) begin
      pc_o <= pc_i;
      zero_o <= zero_i;
      ALUResult_o <= ALUResult_i;
      data2_o <= data2_i;
      rd_o <= rd_i;
      RegWrite_o <= RegWrite_i;
      MemToReg_o <= MemToReg_i;
      MemRead_o <= MemRead_i;
      MemWrite_o <= MemWrite_i;
      instr_o    <= instr_i;
 end
end

endmodule