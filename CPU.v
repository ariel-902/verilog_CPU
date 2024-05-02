`include "MUX32.v"
`include "PC.v"
`include "Adder.v"
`include "Instruction_Memory.v"
`include "ALU.v"
`include "shift.v"
`include "Sign_Extend.v"
`include "IF_ID.v"
`include "Control.v"
`include "Registers.v"
`include "ID_EX.v"
`include "ALU_Control.v"
`include "Hazard_Detect.v"
`include "MUX_Control.v"
`include "ForwardingUnit.v"
`include "ForwardingMUX.v"
`include "EX_MEM.v"
`include "Data_Memory.v"
`include "MEM_WB.v"
`include "dcache_controller.v"
`include "dcache_sram.v"


module CPU
(
    clk_i, 
    start_i,
    rst_i,
    mem_data_i, 
    mem_ack_i,     
    mem_data_o, 
    mem_addr_o,     
    mem_enable_o, 
    mem_write_o
);

//-------------------------- Ports ----------------------------------//
input                 clk_i, start_i, rst_i, mem_ack_i;
input      [255:0]    mem_data_i;
output     [255:0]    mem_data_o;
output      [31:0]    mem_addr_o;
output                mem_enable_o, mem_write_o;


//------------------------- Wire&Reg -------------------------------//
wire    [31:0]      PC_to_InstrMem, inst, add_to_PC;
wire    [31:0]      IF_ID_Instr_o,  IF_ID_PC_o;
wire    [11:0]      IF_ID_pcIm_o;


wire    [1:0]       Control_ALUOp_o;
wire                Control_ALUSrc_o;
wire                Control_RegWrite_o;
wire                Control_MemToReg_o;
wire                Control_MemRd_o;
wire                Control_MemWr_o;
wire                Control_store_or_not_o;

wire    [31:0]      RgData1_o, RgData2_o;
wire    [31:0]      SignExtend_to_ID_EX;


wire    [1:0]       ID_EX_ALUOp_o;
wire                ID_EX_ALUSrc_o;
wire                ID_EX_RegWrite_o;
wire                ID_EX_MemToReg_o;
wire                ID_EX_MemRd_o;
wire                ID_EX_MemWr_o;
wire    [31:0]      ID_EX_SignExtend_o;

wire    [31:0]      ID_EX_Instr_o, ID_EX_PC_o;

wire    [31:0]      ID_EX_Rs1_data, ID_EX_Rs2_data;
wire    [4:0]       ID_EX_Rs1_addr, ID_EX_Rs2_addr, ID_EX_Rd_addr;


wire    [9:0]       ALU_function_i;

wire                EX_MEM_RegWrite_o;
wire                EX_MEM_MemToReg_o;
wire                EX_MEM_MemRd_o;
wire                EX_MEM_MemWr_o;
wire    [4:0]       EX_MEM_Rd_addr_o;
wire    [31:0]      EX_MEM_ALU_Result_o;
wire    [31:0]      EX_MEM_Instr_o, EX_MEM_PC_o;
wire                EX_MEM_Zero_o;
wire    [31:0]      EX_MEM_WriteData;

wire                MEM_WB_RegWrite_o;
wire                MEM_WB_MemToReg_o;
wire    [4:0]       MEM_WB_Rd_addr_o;
wire    [31:0]      MEM_WB_ALU_Result_o;
wire    [31:0]      MEM_WB_DataMemory_o;

wire    [1:0]       ForwardA_to_MUX, ForwardB_to_MUX;
wire    [31:0]      ForwardA_data_o, ForwardB_data_o;

wire    [31:0]      MUX32_to_ALU;
wire    [31:0]      ALU_Result;
wire                ALU_Zero_o;
wire    [31:0]      DataMemory_ReadData;
wire                hazard_stall_bit_o;

wire    [4:0]       Control_MUX_Rd_addr_o;
wire    [1:0]       Control_MUX_ALUOp_o;
wire                Control_MUX_ALUSrc_o, Control_MUX_RegWrite_o, Control_MUX_MemToReg_o, Control_MUX_MemRead_o, Control_MUX_MemWrite_o;


wire    [31:0]      shift1_data_o, Beq_addr_Add_result_o;
wire    [31:0]      PC_select_Result_o;

wire                RegEqual, isBranch, PC_Branch_Select;


wire    [11:0]      pcIm;
wire    [31:0]      PCImmExtend_data_o;
wire    [31:0]      memToReg_data_o;
wire    [31:0]      MUX_ALUSrc_data_o;
wire    [2:0]       ALU_Control_ALUCtrl_o;

wire                memStall;



//------------------------- Assignment -------------------------------//
assign RegEqual = (RgData1_o == RgData2_o);
assign isBranch = (IF_ID_Instr_o[6:0] == 7'b1100011)? 1'b1: 1'b0;
assign PC_Branch_Select = RegEqual & isBranch;
assign ALU_function_i = {ID_EX_Instr_o[31:25], ID_EX_Instr_o[14:12]};
assign pcIm = {inst[31], inst[7], inst[30:25], inst[11:8]};



Control Control(
    .Op_i            (IF_ID_Instr_o[6:0]),
    .ALUOp_o         (Control_ALUOp_o),
    .ALUSrc_o        (Control_ALUSrc_o),
    .RegWrite_o      (Control_RegWrite_o),
    .MemRead_o       (Control_MemRd_o),
    .MemWrite_o      (Control_MemWr_o),
    .MemToReg_o      (Control_MemToReg_o),
    .store_or_not_o  (Control_store_or_not_o)
);

Adder Add_PC(
    .data1_in   (PC_to_InstrMem),
    .data2_in   (32'd4),
    .data_o     (add_to_PC)
);

PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .pc_i       (PC_select_Result_o),
    .stall_i    (memStall),
    .PCWrite_i  (!hazard_stall_bit_o),
    .pc_o       (PC_to_InstrMem)
);


Instruction_Memory Instruction_Memory(
    .addr_i     (PC_to_InstrMem), 
    .instr_o    (inst)
);

Registers Registers(
    .clk_i          (clk_i),
    .RS1addr_i      (IF_ID_Instr_o[19:15]),     
    .RS2addr_i      (IF_ID_Instr_o[24:20]),     
    .RDaddr_i       (MEM_WB_Rd_addr_o), 
    .RDdata_i       (memToReg_data_o),
    .RegWrite_i     (MEM_WB_RegWrite_o), 
    .RS1data_o      (RgData1_o),
    .RS2data_o      (RgData2_o)
);

MUX32 MUX_ALUSrc(
    .data1_i    (ForwardB_data_o),
    .data2_i    (ID_EX_SignExtend_o),
    .select_i   (ID_EX_ALUSrc_o),
    .data_o     (MUX_ALUSrc_data_o)
);

Sign_Extend Sign_Extend(
    .select_i       (Control_store_or_not_o),
    .data0_i        (IF_ID_Instr_o[31:20]),
    .data1_i        ({IF_ID_Instr_o[31:25], IF_ID_Instr_o[11:7]}),
    .data_o         (SignExtend_to_ID_EX)
);

ALU ALU(
    .data1_i    (ForwardA_data_o),
    .data2_i    (MUX_ALUSrc_data_o),
    .ALUCtrl_i  (ALU_Control_ALUCtrl_o),
    .data_o     (ALU_Result),
    .Zero_o     (ALU_Zero_o)
);

ALU_Control ALU_Control(
    .funct_i    (ALU_function_i),
    .ALUOp_i    (ID_EX_ALUOp_o),
    .ALUCtrl_o  (ALU_Control_ALUCtrl_o)
);

IF_ID IF_ID(
    .clk_i      (clk_i),
    .start_i    (start_i),
    .stall_i    (memStall),
    .pc_i       (PC_to_InstrMem),
    .inst_i     (inst), 
    .hazard_i   (hazard_stall_bit_o),
    .flush_i    (PC_Branch_Select),
    .pcIm_i     (pcIm),
    .pcIm_o     (IF_ID_pcIm_o),
    .pc_o       (IF_ID_PC_o),
    .inst_o     (IF_ID_Instr_o)
);

ID_EX ID_EX(
    .clk_i          (clk_i),
    .start_i        (start_i),
    .stall_i        (memStall),
    .inst_i         (IF_ID_Instr_o),
    .pc_i           (IF_ID_PC_o),
    .pcEx_i         (PCImmExtend_data_o),
    .RegWrite_i     (Control_MUX_RegWrite_o),
    .MemToReg_i     (Control_MUX_MemToReg_o),
    .MemRead_i      (Control_MUX_MemRead_o),
    .MemWrite_i     (Control_MUX_MemWrite_o),
    .ALUOp_i        (Control_MUX_ALUOp_o),
    .ALUSrc_i       (Control_MUX_ALUSrc_o),
    .data1_i        (RgData1_o),
    .data2_i        (RgData2_o),
    .SignExtended_i (SignExtend_to_ID_EX),
    .rd_i           (Control_MUX_Rd_addr_o),
    .PC_branch_select_i (PC_Branch_Select),
    .RS1addr_i      (IF_ID_Instr_o[19:15]),     
    .RS2addr_i      (IF_ID_Instr_o[24:20]),
    .inst_o         (ID_EX_Instr_o),     
    .pc_o           (ID_EX_PC_o),
    .SignExtended_o (ID_EX_SignExtend_o),
    .rd_o           (ID_EX_Rd_addr),
    .ALUOp_o        (ID_EX_ALUOp_o),
    .ALUSrc_o       (ID_EX_ALUSrc_o),
    .RegWrite_o     (ID_EX_RegWrite_o),
    .MemToReg_o     (ID_EX_MemToReg_o),
    .MemRead_o      (ID_EX_MemRd_o),
    .MemWrite_o     (ID_EX_MemWr_o),
    .PC_branch_select_o (),
    .data1_o    (ID_EX_Rs1_data),
    .data2_o    (ID_EX_Rs2_data),
    .RS1addr_o  (ID_EX_Rs1_addr),
    .RS2addr_o  (ID_EX_Rs2_addr)
);

EX_MEM EX_MEM(
    .clk_i          (clk_i),
    .start_i        (start_i),
    .stall_i        (memStall),
    .RegWrite_i     (ID_EX_RegWrite_o),
    .MemToReg_i     (ID_EX_MemToReg_o),
    .MemRead_i      (ID_EX_MemRd_o),
    .MemWrite_i     (ID_EX_MemWr_o),
    .data2_i        (ForwardB_data_o),
    .rd_i           (ID_EX_Rd_addr),
    .ALUResult_i    (ALU_Result),
    .zero_i         (ALU_Zero_o),
    .pc_i           (ID_EX_PC_o),
    .instr_i        (ID_EX_Instr_o),
    .RegWrite_o     (EX_MEM_RegWrite_o),
    .MemToReg_o     (EX_MEM_MemToReg_o),
    .MemRead_o      (EX_MEM_MemRd_o),
    .MemWrite_o     (EX_MEM_MemWr_o),
    .data2_o        (EX_MEM_WriteData),
    .rd_o           (EX_MEM_Rd_addr_o),
    .ALUResult_o    (EX_MEM_ALU_Result_o),
    .zero_o         (),
    .pc_o           (),
    .instr_o        (EX_MEM_Instr_o)
);

MEM_WB MEM_WB(
    .clk_i              (clk_i),
    .start_i            (start_i),
    .stall_i            (memStall),
    .ALUResult_i        (EX_MEM_ALU_Result_o),
    .RegWrite_i         (EX_MEM_RegWrite_o),
    .MemToReg_i         (EX_MEM_MemToReg_o),
    .DataMemReadData_i  (DataMemory_ReadData),
    .RDData_i           (EX_MEM_WriteData),
    .RDaddr_i           (EX_MEM_Rd_addr_o),
    .ALUResult_o        (MEM_WB_ALU_Result_o),
    .RegWrite_o         (MEM_WB_RegWrite_o),
    .MemToReg_o         (MEM_WB_MemToReg_o),
    .DataMemReadData_o  (MEM_WB_DataMemory_o),
    .RDaddr_o           (MEM_WB_Rd_addr_o)         
);

dcache_controller  dcache
(
    // System clock, reset and stall
    .clk_i  (clk_i), 
    .rst_i  (rst_i),
    
    // to Data Memory interface        
    .mem_data_i         (mem_data_i), 
    .mem_ack_i          (mem_ack_i),     
    .mem_data_o         (mem_data_o), 
    .mem_addr_o         (mem_addr_o),     
    .mem_enable_o       (mem_enable_o), 
    .mem_write_o        (mem_write_o),

    // to CPU interface    
    .cpu_data_i     (EX_MEM_WriteData), 
    .cpu_addr_i     (EX_MEM_ALU_Result_o),     
    .cpu_MemRead_i  (EX_MEM_MemRd_o), 
    .cpu_MemWrite_i (EX_MEM_MemWr_o), 
    .cpu_data_o     (DataMemory_ReadData), 
    .cpu_stall_o    (memStall)    
);

forwardingUnit forwardingUnit(
    .ID_EX_Rs1        (ID_EX_Rs1_addr),
    .ID_EX_Rs2        (ID_EX_Rs2_addr),
    .EX_MEM_RegWrite  (EX_MEM_RegWrite_o),
    .EX_MEM_Rd        (EX_MEM_Rd_addr_o),
    .MEM_WB_RegWrite  (MEM_WB_RegWrite_o),
    .MEM_WB_Rd        (MEM_WB_Rd_addr_o),
    .ForwardA_o         (ForwardA_to_MUX),
    .ForwardB_o         (ForwardB_to_MUX)
);


ForwardingMUX ForwardA(
    .ForwardBits_i (ForwardA_to_MUX),
    .ID_EX_data_i   (ID_EX_Rs1_data),
    .MEM_ALUResult (EX_MEM_ALU_Result_o),
    .WB_writeData (memToReg_data_o),
    .data_o   (ForwardA_data_o)
);

ForwardingMUX ForwardB(
    .ForwardBits_i (ForwardB_to_MUX),
    .ID_EX_data_i   (ID_EX_Rs2_data),
    .MEM_ALUResult (EX_MEM_ALU_Result_o),
    .WB_writeData (memToReg_data_o),
    .data_o   (ForwardB_data_o)
);

MUX32 pcSelect(
    .data1_i    (add_to_PC),
    .data2_i    (Beq_addr_Add_result_o),
    .select_i   (PC_Branch_Select),
    .data_o     (PC_select_Result_o)
);

ALU BeqAdd(
    .data1_i    (IF_ID_PC_o),
    .data2_i    (shift1_data_o),
    .ALUCtrl_i  (3'b001),
    .data_o     (Beq_addr_Add_result_o),
    .Zero_o     ()
);

Shift shift(
    .data_i (PCImmExtend_data_o),
    .data_o (shift1_data_o)
);

Sign_Extend PCImmExtend(
    .select_i       (1'b0),
    .data0_i        (IF_ID_pcIm_o),
    .data1_i        (12'b0),
    .data_o         (PCImmExtend_data_o)
);

Hazard_Detect Hazard_Detect(
    .IF_ID_Rs1_i         (IF_ID_Instr_o[24:20]),
    .IF_ID_Rs2_i         (IF_ID_Instr_o[19:15]),
    .ID_EX_Rd_addr_i     (ID_EX_Rd_addr),
    .ID_EX_MEMread_i     (ID_EX_MemRd_o),
    .stall_bit_o         (hazard_stall_bit_o)
);


Control_MUX Control_MUX(
    .stall_i        (hazard_stall_bit_o), 
    .Rd_addr_i      (IF_ID_Instr_o[11:7]),  
    .ALUOp_i        (Control_ALUOp_o), 
    .ALUSrc_i       (Control_ALUSrc_o),  
    .RegWrite_i     (Control_RegWrite_o), 
    .MemToReg_i     (Control_MemToReg_o), 
    .MemRead_i      (Control_MemRd_o),
    .MemWrite_i     (Control_MemWr_o),
    .Rd_addr_o      (Control_MUX_Rd_addr_o),  
    .ALUOp_o        (Control_MUX_ALUOp_o), 
    .ALUSrc_o       (Control_MUX_ALUSrc_o),  
    .RegWrite_o     (Control_MUX_RegWrite_o), 
    .MemToReg_o     (Control_MUX_MemToReg_o),  
    .MemRead_o      (Control_MUX_MemRead_o),
    .MemWrite_o     (Control_MUX_MemWrite_o)  
);

MUX32 WB_MUX(
    .data1_i        (MEM_WB_ALU_Result_o),
    .data2_i        (MEM_WB_DataMemory_o),
    .select_i       (MEM_WB_MemToReg_o),
    .data_o         (memToReg_data_o)
);

endmodule
