module Control(
    Op_i       ,
    RegWrite_o ,
    MemToReg_o ,
    MemRead_o  ,
    MemWrite_o,
    ALUOp_o    ,
    ALUSrc_o   ,
    store_or_not_o
);

// Interface

input   [6:0]     Op_i;
output  [1:0]     ALUOp_o;
output            ALUSrc_o, RegWrite_o, MemToReg_o, MemRead_o, MemWrite_o, store_or_not_o;


// Wires & Registers
reg                ALUSrc_o, RegWrite_o, MemToReg_o, MemRead_o, MemWrite_o, store_or_not_o;
reg      [1:0]     ALUOp_o;

always@(*)begin

  case(Op_i)

  7'b0110011 : begin            // R-type
      ALUOp_o = 2'b10;
      ALUSrc_o = 1'b0;
      RegWrite_o = 1'b1;
      MemRead_o = 1'b0;
      MemWrite_o = 1'b0;
      MemToReg_o = 1'b0;
      store_or_not_o = 1'b0;
  end

  7'b0010011 : begin            //I
      ALUOp_o = 2'b11;
      ALUSrc_o = 1'b1;
      RegWrite_o = 1'b1;
      MemRead_o = 1'b0;
      MemWrite_o = 1'b0;
      MemToReg_o = 1'b0;
      store_or_not_o = 1'b0;
  end

  7'b0000011 : begin            //lw
      ALUOp_o = 2'b00;
      ALUSrc_o = 1'b1;
      MemRead_o = 1'b1;
      MemToReg_o = 1'b1;
      RegWrite_o = 1'b1;
      MemWrite_o = 1'b0;
      store_or_not_o = 1'b0;
  end

  7'b0100011 : begin            //sw
      ALUOp_o = 2'b00;
      ALUSrc_o = 1'b1;
      MemWrite_o = 1'b1;
      RegWrite_o = 1'b0;
      MemRead_o = 1'b0;
      MemToReg_o = 1'b0;
      store_or_not_o = 1'b1;
  end

  7'b1100011 : begin            //beq
      ALUOp_o = 2'b01;
      ALUSrc_o = 1'b1;
      RegWrite_o = 1'b0;
      MemRead_o = 1'b0;
      MemWrite_o = 1'b0;
      MemToReg_o = 1'b0;
      store_or_not_o = 1'b0;
  end

  default : begin
      ALUOp_o = 2'b11;
      ALUSrc_o = 1'b1;
      RegWrite_o = 1'b0;
      MemRead_o = 1'b0;
      MemWrite_o = 1'b0;
      MemToReg_o = 1'b0;
      store_or_not_o = 1'b0;
  end
  endcase
end
endmodule