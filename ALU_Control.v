module ALU_Control(
    funct_i,
    ALUOp_i,
    ALUCtrl_o 
);

// Interface
input [9:0] funct_i;
input [1:0] ALUOp_i;
output[2:0] ALUCtrl_o;

// Wires & Registers
reg       [2:0]   ALUCtrl_o;

always@(*)begin
  case(ALUOp_i)

    2'b11 : begin
        if (funct_i[2:0] == 3'b000) begin
            ALUCtrl_o = 3'b001;         //addi
        end
        else if (funct_i[2:0] == 3'b101) begin
            ALUCtrl_o = 3'b111;         //SRAI
        end
    end

    2'b10 : begin
        case(funct_i)

            10'b0000000000 : begin
                ALUCtrl_o = 3'b001;//add
            end
            10'b0100000000 : begin
                ALUCtrl_o = 3'b010;//sub
            end
            10'b0000001000 : begin
                ALUCtrl_o = 3'b110;//MUL
            end
            10'b0000000110 : begin
                ALUCtrl_o = 3'b100;//OR
            end
            10'b0000000111 : begin
                ALUCtrl_o = 3'b011;//AND
            end
            default : begin
                ALUCtrl_o = 3'b001;
            end
            10'b0000000001 : begin
                ALUCtrl_o = 3'b000;
            end
        endcase
    end

    2'b01 : begin                   //beq,ALU do subtraction
        ALUCtrl_o = 3'b010;         //sub
    end

    2'b00 : begin                   // lw or sw
        ALUCtrl_o <= 3'b001;
    end

    default : begin
        ALUCtrl_o = 3'b001;         //default add
    end
endcase

end
endmodule