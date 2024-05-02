module ALU
(
    data1_i, 
    data2_i, 
    ALUCtrl_i, 
    data_o,
    Zero_o
);

// Interface
input       [31:0] data1_i;
input       [31:0] data2_i;
input       [2:0]  ALUCtrl_i;
output      [31:0] data_o;
output      Zero_o;

// Wires & Registers
reg         [31:0]   data_o;
reg                  Zero_o;

parameter ADD = 3'b001;
parameter SUB = 3'b010;
parameter AND = 3'b011;
parameter OR  = 3'b100;
parameter XOR = 3'b101;
parameter MUL = 3'b110;
parameter SRAI= 3'b111;
parameter SLL = 3'b000;

/* implement here */
always@(*)begin
Zero_o   = (data1_i - data2_i)? 0:1;
case(ALUCtrl_i)

  AND : begin
    data_o = data1_i & data2_i;
  end

  XOR : begin
    data_o = data1_i ^ data2_i;
  end

  SLL : begin
    data_o = data1_i << data2_i;
  end

  ADD : begin
    data_o = data1_i + data2_i;
  end

  SUB : begin
    data_o = data1_i - data2_i;
  end

  MUL : begin
    data_o = data1_i * data2_i;
  end

  SRAI : begin
    data_o = $signed(data1_i) >>> data2_i[4:0];
  end

  default : begin
    data_o = data1_i;
  end

endcase
end

endmodule
